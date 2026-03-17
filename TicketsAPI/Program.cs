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
using FluentValidation;
using TicketsAPI.Validators;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Services.Implementations;

var builder = WebApplication.CreateBuilder(args);

// Logging
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", Serilog.Events.LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore", Serilog.Events.LogEventLevel.Warning)
    .MinimumLevel.Override("System", Serilog.Events.LogEventLevel.Warning)
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

    // CORS
    var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>();
    var allowedMethods = builder.Configuration.GetSection("Cors:AllowedMethods").Get<string[]>();
    var allowedHeaders = builder.Configuration.GetSection("Cors:AllowedHeaders").Get<string[]>();

    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowFrontend", policy =>
        {
            var defaults = new[] { "http://localhost:3000", "http://localhost:5173", "http://localhost:5174", "http://localhost:5175", "https://localhost:5001", "http://localhost:5000" };
            policy.WithOrigins(allowedOrigins ?? defaults)
                  .WithMethods(allowedMethods ?? new[] { "GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS" })
                  .WithHeaders(allowedHeaders ?? new[] { "*" })
                  .AllowCredentials();
        });
    });

    // JWT Authentication
    builder.Services.Configure<TicketsAPI.Config.JwtSettings>(builder.Configuration.GetSection("JwtSettings"));
    var jwtSettings = builder.Configuration.GetSection("JwtSettings");
    var secretKey = jwtSettings["SecretKey"];
    var issuer = jwtSettings["Issuer"];
    var audience = jwtSettings["Audience"];

    // Validar SecretKey
    if (string.IsNullOrWhiteSpace(secretKey))
        throw new InvalidOperationException("JwtSettings:SecretKey no está configurada. Defínela en appsettings.json o en variables de entorno.");
    if (secretKey.StartsWith("your-super-secret-key", StringComparison.OrdinalIgnoreCase))
        throw new InvalidOperationException("JwtSettings:SecretKey sigue siendo el valor por defecto. Cámbiala por una clave segura de al menos 32 caracteres.");

    builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
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

    // Rate limiting
    builder.Services.AddMemoryCache();
    builder.Services.Configure<IpRateLimitOptions>(builder.Configuration.GetSection("IpRateLimiting"));
    builder.Services.Configure<IpRateLimitPolicies>(builder.Configuration.GetSection("IpRateLimitPolicies"));
    builder.Services.AddInMemoryRateLimiting();
    builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();

    // Dependency injection
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

    // Registrar repositorios
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IUsuarioRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.UsuarioRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.ITicketRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.TicketRepository(connectionString));
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.IReporteRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.ReporteRepository(connectionString));
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
    
    // Registrar repositorios adicionales
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

    // Registrar NotificacionLecturaRepository
    builder.Services.AddSingleton<TicketsAPI.Repositories.Interfaces.INotificacionLecturaRepository>(sp =>
        new TicketsAPI.Repositories.Implementations.NotificacionLecturaRepository(connectionString));

    // Registrar servicios
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IPasswordService, TicketsAPI.Services.Implementations.PasswordService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Implementations.BruteForceProtectionService>(sp =>
        new TicketsAPI.Services.Implementations.BruteForceProtectionService(
            connectionString,
            sp.GetRequiredService<ILogger<TicketsAPI.Services.Implementations.BruteForceProtectionService>>()));
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IAuthService, TicketsAPI.Services.Implementations.AuthService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.ITicketService, TicketsAPI.Services.Implementations.TicketService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IEstadoService, TicketsAPI.Services.Implementations.EstadoService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IPrioridadService, TicketsAPI.Services.Implementations.PrioridadService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IDepartamentoService, TicketsAPI.Services.Implementations.DepartamentoService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.INotificationProvider, TicketsAPI.Services.Implementations.SignalRNotificationProvider>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.INotificacionService, TicketsAPI.Services.Implementations.NotificacionService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IExportService, TicketsAPI.Services.Implementations.ExportService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IReporteService, TicketsAPI.Services.Implementations.ReporteService>();
    builder.Services.AddSingleton<TicketsAPI.Services.Implementations.CacheService>();
    builder.Services.AddScoped<IUsuarioService, UsuarioService>();

    // Registrar servicio de auditoría de configuración
    builder.Services.AddSingleton<TicketsAPI.Services.Interfaces.IConfigAuditService>(sp =>
        new TicketsAPI.Services.Implementations.ConfigAuditService(
            connectionString,
            sp.GetRequiredService<ILogger<TicketsAPI.Services.Implementations.ConfigAuditService>>()));

    builder.Services.AddMemoryCache();

    // Validación
    builder.Services.AddValidatorsFromAssemblyContaining<LoginRequestValidator>();

    // AutoMapper
    builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

    // Controllers
    builder.Services.AddControllers()
        .AddJsonOptions(options =>
        {
            // Forzar camelCase explícito para garantizar contrato con el frontend
            options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
            options.JsonSerializerOptions.DictionaryKeyPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
            options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
            // Permitir caracteres Unicode (emoji, kanji, acentos) sin escapar a \uXXXX
            options.JsonSerializerOptions.Encoder = System.Text.Encodings.Web.JavaScriptEncoder.Create(System.Text.Unicode.UnicodeRanges.All);
        });
    builder.Services.AddEndpointsApiExplorer();

    // Logging de validación
    builder.Services.Configure<Microsoft.AspNetCore.Mvc.ApiBehaviorOptions>(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var errors = context.ModelState
                .Where(e => e.Value?.Errors.Count > 0)
                .ToDictionary(
                    kvp => kvp.Key,
                    kvp => kvp.Value!.Errors.Select(e => e.ErrorMessage).ToArray()
                );

            Log.Warning("400 ModelState invalid for {Method} {Path}: {@Errors}",
                context.HttpContext.Request.Method,
                context.HttpContext.Request.Path + context.HttpContext.Request.QueryString,
                errors);

            return new Microsoft.AspNetCore.Mvc.BadRequestObjectResult(
                new Microsoft.AspNetCore.Mvc.ValidationProblemDetails(context.ModelState)
                {
                    Status = 400
                });
        };
    });

    // Swagger
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

    // SignalR
    builder.Services.AddSignalR(options =>
    {
        options.KeepAliveInterval = TimeSpan.FromSeconds(15);
        options.ClientTimeoutInterval = TimeSpan.FromMinutes(2);
        options.EnableDetailedErrors = builder.Environment.IsDevelopment();
    })
        .AddMessagePackProtocol();

    // Health checks
    builder.Services.AddHealthChecks()
        .AddCheck<DatabaseHealthCheck>("Database")
        .AddCheck<DashboardWarmupHealthCheck>("DashboardWarmup");

    // Build
    var app = builder.Build();

    // Cache warmup
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

        // Dashboard warmup: calentar InnoDB buffer pool y JIT
        try
        {
            logger.LogInformation("Iniciando dashboard warmup...");
            var healthCheckService = scope.ServiceProvider.GetRequiredService<Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckService>();
            var report = await healthCheckService.CheckHealthAsync(
                predicate: reg => reg.Name == "DashboardWarmup");
            logger.LogInformation("Dashboard warmup: {Status}", report.Status);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Error en dashboard warmup - continuando sin precarga");
        }
    }

    // Middleware pipeline
    app.UseValidationExceptionHandler();
    
    // Request correlation tracking
    app.UseRequestCorrelation();
    
    // Error handling
    app.UseMiddleware<ExceptionHandlingMiddleware>();

    // CORS
    app.UseCors("AllowFrontend");

    // WebSockets
    app.UseWebSockets();


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

    // HTTPS redirection deshabilitado temporalmente para desarrollo local
    // app.UseHttpsRedirection();

    // Servir archivos estáticos del SPA (wwwroot/)
    app.UseDefaultFiles();
    app.UseStaticFiles();

    // Aplicar rate limiting antes de auth para proteger endpoints de SP
    app.UseIpRateLimiting();
    app.UseAuthentication();
    app.UseUserActiveValidation();
    app.UseAuthorization();

    // Endpoints
    app.MapControllers();
    app.MapHealthChecks("/health");
    app.MapHub<TicketHub>("/hubs/tickets");

    // SPA Fallback: cualquier ruta no manejada por la API → index.html
    app.MapFallbackToFile("index.html");

    // Run
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
