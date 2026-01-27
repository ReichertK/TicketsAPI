using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;
using Serilog;
using System.Text;
using TicketsAPI.Config;
using TicketsAPI.Middleware;
using MySqlConnector;
using AspNetCoreRateLimit;
using TicketsAPI.Models;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Repositories.Implementations;

var builder = WebApplication.CreateBuilder(args);

// ==================== LOGGING ====================
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console()
    .WriteTo.File(
        path: builder.Configuration["Logging:FileLogging:Path"] ?? "logs/tickets-api-.txt",
        retainedFileCountLimit: int.Parse(builder.Configuration["Logging:FileLogging:RetainedFileCountLimit"] ?? "30"),
        rollingInterval: RollingInterval.Day,
        outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj}{NewLine}{Exception}"
    )
    .CreateLogger();

builder.Host.UseSerilog();

try
{
    Log.Information("Iniciando aplicación TicketsAPI");

    // ==================== CORS ====================
    var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>();
    var allowedMethods = builder.Configuration.GetSection("Cors:AllowedMethods").Get<string[]>();
    var allowedHeaders = builder.Configuration.GetSection("Cors:AllowedHeaders").Get<string[]>();

    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowFrontend", policy =>
        {
            var defaults = new[] { "http://localhost:3000", "http://localhost:5173", "https://localhost:5001", "http://localhost:5000" };
            policy.WithOrigins(allowedOrigins ?? defaults)
                  .WithMethods(allowedMethods ?? new[] { "GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS" })
                  .WithHeaders(allowedHeaders ?? new[] { "*" })
                  .AllowCredentials();
        });
    });

    // ==================== AUTHENTICATION ====================
    // Bind JwtSettings for DI consumers (AuthService)
    builder.Services.Configure<TicketsAPI.Config.JwtSettings>(builder.Configuration.GetSection("JwtSettings"));
    var jwtSettings = builder.Configuration.GetSection("JwtSettings");
    var secretKey = jwtSettings["SecretKey"];
    var issuer = jwtSettings["Issuer"];
    var audience = jwtSettings["Audience"];

    builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey ?? "your-super-secret-key-min-32-chars-required-for-production")),
                ValidateIssuer = true,
                ValidIssuer = issuer,
                ValidateAudience = true,
                ValidAudience = audience,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromMinutes(5),
                RoleClaimType = ClaimTypes.Role
            };

            // SignalR WebSocket support
            options.Events = new JwtBearerEvents
            {
                OnMessageReceived = context =>
                {
                    var accessToken = context.Request.Query["access_token"];
                    var path = context.HttpContext.Request.Path;

                    if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                    {
                        context.Token = accessToken;
                    }

                    return Task.CompletedTask;
                }
            };
        });

    builder.Services.AddAuthorization();

    // ==================== RATE LIMITING (IP) ====================
    builder.Services.AddMemoryCache();
    builder.Services.Configure<IpRateLimitOptions>(builder.Configuration.GetSection("IpRateLimiting"));
    builder.Services.Configure<IpRateLimitPolicies>(builder.Configuration.GetSection("IpRateLimitPolicies"));
    builder.Services.AddInMemoryRateLimiting();
    builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();

    // ==================== DEPENDENCY INJECTION ====================
    // Priorizar DbTkt para entorno local segun appsettings
    var connectionString = builder.Configuration.GetConnectionString("DbTkt")
        ?? builder.Configuration.GetConnectionString("DefaultConnection")
        ?? builder.Configuration.GetSection("ApiSettings").GetValue<string>("ConnectionString")
        ?? builder.Configuration.GetValue<string>("ConnectionString")
        ?? throw new InvalidOperationException("ConnectionString no configurada. Defina 'ConnectionStrings:DbTkt' o 'ConnectionStrings:DefaultConnection'.");

    var csBuilder = new MySqlConnectionStringBuilder(connectionString);
    var hasPassword = !string.IsNullOrWhiteSpace(csBuilder.Password);
    var sanitizedConnectionString = csBuilder.ConnectionString;
    if (hasPassword)
    {
        sanitizedConnectionString = sanitizedConnectionString.Replace(csBuilder.Password, "***", StringComparison.Ordinal);
    }
    Log.Information("Environment: {Environment}; Usando cadena de conexión (pwd presente: {HasPassword}): {ConnectionString}",
        builder.Environment.EnvironmentName,
        hasPassword,
        sanitizedConnectionString);

    // Registrar repositorios (MySQL 5.5 compatible)
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IUsuarioRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.UsuarioRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.ITicketRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.TicketRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IBaseRepository<Ticket>>(sp =>
        sp.GetRequiredService<TicketsAPI.Repositories.Interfaces.ITicketRepository>());
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IEstadoRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.EstadoRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IPrioridadRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.PrioridadRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IDepartamentoRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.DepartamentoRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IBaseRepository<Departamento>>(sp =>
        sp.GetRequiredService<TicketsAPI.Repositories.Interfaces.IDepartamentoRepository>());
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IPoliticaTransicionRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.PoliticaTransicionRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IRolRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.RolRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IPermisoRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.PermisoRepository(connectionString));
    
    // Registrar repositorios adicionales (nuevos endpoints)
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IMotivoRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.MotivoRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IBaseRepository<Motivo>>(sp =>
        sp.GetRequiredService<TicketsAPI.Repositories.Interfaces.IMotivoRepository>());
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IBaseRepository<Aprobacion>>(sp =>
        new TicketsAPI.Repositories.Implementations.AprobacionRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IBaseRepository<Transicion>>(sp =>
        new TicketsAPI.Repositories.Implementations.TransicionRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IBaseRepository<Grupo>>(sp =>
        new TicketsAPI.Repositories.Implementations.GrupoRepository(connectionString));
    
    // Registrar ComentarioRepository como ambas interfaces
    var comentarioRepository = new TicketsAPI.Repositories.Implementations.ComentarioRepository(connectionString);
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IBaseRepository<Comentario>>(comentarioRepository);
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IComentarioRepository>(comentarioRepository);

    // Registrar servicios
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IAuthService, TicketsAPI.Services.Implementations.AuthService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.ITicketService, TicketsAPI.Services.Implementations.TicketService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IEstadoService, TicketsAPI.Services.Implementations.EstadoService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IPrioridadService, TicketsAPI.Services.Implementations.PrioridadService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IDepartamentoService, TicketsAPI.Services.Implementations.DepartamentoService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.INotificacionService, TicketsAPI.Services.Implementations.NotificacionService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IExportService, TicketsAPI.Services.Implementations.ExportService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IReporteService, TicketsAPI.Services.Implementations.ReporteService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Implementations.CacheService>();

    // ==================== MEMORY CACHE ====================
    builder.Services.AddMemoryCache();

    // ==================== AUTOMAPPER ====================
    builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

    // ==================== CONTROLLERS & API ====================
    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();

    // ==================== SWAGGER ====================
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
        {
            Title = "Tickets API",
            Version = "1.0.0",
            Description = @"API REST para gestión integral de tickets con soporte para:
- Autenticación JWT
- Búsqueda avanzada full-text
- Exportación a CSV
- Reportes y analytics en tiempo real
- SignalR para notificaciones
- Sistema de permisos por roles",
            Contact = new Microsoft.OpenApi.Models.OpenApiContact
            {
                Name = "Equipo de Desarrollo",
                Email = "dev@ticketsapi.com",
                Url = new Uri("https://github.com/ReichertK/TicketsAPI")
            },
            License = new Microsoft.OpenApi.Models.OpenApiLicense
            {
                Name = "MIT License",
                Url = new Uri("https://opensource.org/licenses/MIT")
            }
        });

        // Agrupar endpoints por tags
        c.TagActionsBy(api =>
        {
            if (api.GroupName != null)
                return new[] { api.GroupName };

            var controllerName = api.ActionDescriptor.RouteValues["controller"];
            return new[] { controllerName ?? "General" };
        });

        // Ordenar tags alfabéticamente
        c.OrderActionsBy(api => $"{api.ActionDescriptor.RouteValues["controller"]}_{api.HttpMethod}");

        // Agregar descripciones de tags
        c.DocumentFilter<SwaggerTagDescriptionsDocumentFilter>();

        // Agregar autenticación JWT al Swagger
        c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
        {
            In = Microsoft.OpenApi.Models.ParameterLocation.Header,
            Description = @"JWT Authorization header usando Bearer scheme.
                
Ejemplo: 'Bearer {token}'
                
1. Haga login en /api/v1/Auth/login
2. Copie el token de la respuesta
3. Click en 'Authorize' arriba
4. Ingrese solo el token (sin 'Bearer')
5. Click 'Authorize' y 'Close'",
            Name = "Authorization",
            Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
            Scheme = "bearer",
            BearerFormat = "JWT"
        });

        c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
        {
            {
                new Microsoft.OpenApi.Models.OpenApiSecurityScheme
                {
                    Reference = new Microsoft.OpenApi.Models.OpenApiReference
                    {
                        Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                        Id = "Bearer"
                    }
                },
                new string[] { }
            }
        });

        // XML documentation
        var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
        var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
        if (File.Exists(xmlPath))
            c.IncludeXmlComments(xmlPath);
    });

    // Leer setting para habilitar Swagger independientemente del entorno
    var enableSwaggerSetting = builder.Configuration.GetValue<bool>("ApiSettings:EnableSwagger", builder.Environment.IsDevelopment());

    // ==================== SIGNALR ====================
    builder.Services.AddSignalR()
        .AddMessagePackProtocol();

    // ==================== HEALTH CHECK ====================
    builder.Services.AddHealthChecks()
        .AddCheck<DatabaseHealthCheck>("Database");

    // ==================== BUILD ====================
    var app = builder.Build();

    // ==================== CACHE WARMUP ====================
    // Pre-cargar cache de referencias al iniciar
    using (var scope = app.Services.CreateScope())
    {
        var cacheService = scope.ServiceProvider.GetRequiredService<TicketsAPI.Services.Implementations.CacheService>();
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
        
        try
        {
            logger.LogInformation("Iniciando cache warmup...");
            await cacheService.WarmupCacheAsync();
            logger.LogInformation("Cache warmup completado exitosamente");
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Error en cache warmup - continuando sin cache precargado");
        }
    }

    // ==================== MIDDLEWARE ====================
    // Error handling
    app.UseMiddleware<ExceptionHandlingMiddleware>();

    // CORS
    app.UseCors("AllowFrontend");


    // Swagger
    if (enableSwaggerSetting)
    {
        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "Tickets API v1");
            c.RoutePrefix = "swagger";
        });
    }

    app.UseHttpsRedirection();
    // Aplicar rate limiting antes de auth para proteger endpoints de SP
    app.UseIpRateLimiting();
    app.UseAuthentication();
    app.UseAuthorization();

    // ==================== ENDPOINTS ====================
    // Página de bienvenida mínima en '/'
    app.MapGet("/", () =>
    {
        var html = @"<!doctype html>
        <html lang='es'>
        <head><meta charset='utf-8'><title>TicketsAPI</title><style>body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu;max-width:720px;margin:40px auto;padding:0 16px;line-height:1.6}a{color:#0b5cff;text-decoration:none}a:hover{text-decoration:underline}.tag{display:inline-block;background:#eef3ff;border:1px solid #cfe0ff;color:#0b5cff;border-radius:6px;padding:2px 8px;font-size:12px;margin-left:8px}</style></head>
        <body>
        <h1>TicketsAPI</h1>
        <p>Bienvenido. Recursos útiles:</p>
        <ul>
            <li><a href='/swagger'>Swagger UI</a> <span class='tag'>API Docs</span></li>
            <li><a href='/health'>/health</a> <span class='tag'>Health</span></li>
            <li><a href='/api/sp'>/api/sp</a> <span class='tag'>JWT + 60/min</span></li>
        </ul>
        </body></html>";
        return Results.Content(html, "text/html");
    });
    app.MapControllers();
    app.MapHealthChecks("/health");
    app.MapHub<TicketHub>("/hubs/tickets");

    // ==================== RUN ====================
    await app.RunAsync();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Aplicación terminó inesperadamente");
}
finally
{
    await Log.CloseAndFlushAsync();
}
