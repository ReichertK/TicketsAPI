using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Serilog;
using System.Text;
using TicketsAPI.Config;
using TicketsAPI.Middleware;

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
            policy.WithOrigins(allowedOrigins ?? new[] { "http://localhost:3000", "http://localhost:5173" })
                  .WithMethods(allowedMethods ?? new[] { "GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS" })
                  .WithHeaders(allowedHeaders ?? new[] { "*" })
                  .AllowCredentials();
        });
    });

    // ==================== AUTHENTICATION ====================
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
                ClockSkew = TimeSpan.FromMinutes(5)
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

    // ==================== DEPENDENCY INJECTION ====================
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    builder.Services.AddSingleton(connectionString);

    // Registrar repositorios y servicios
    // TODO: Agregar registros cuando se implementen

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
            Description = "API REST para gestión integral de tickets",
            Contact = new Microsoft.OpenApi.Models.OpenApiContact
            {
                Name = "Equipo de Desarrollo",
                Url = new Uri("https://github.com/ReichertK/TicketsAPI")
            }
        });

        // Agregar autenticación JWT al Swagger
        c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
        {
            In = Microsoft.OpenApi.Models.ParameterLocation.Header,
            Description = "Ingrese JWT token",
            Name = "Authorization",
            Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
            Scheme = "Bearer"
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

    // ==================== SIGNALR ====================
    builder.Services.AddSignalR()
        .AddMessagePackProtocol();

    // ==================== HEALTH CHECK ====================
    builder.Services.AddHealthChecks()
        .AddCheck<DatabaseHealthCheck>("Database");

    // ==================== BUILD ====================
    var app = builder.Build();

    // ==================== MIDDLEWARE ====================
    // Error handling
    app.UseMiddleware<ExceptionHandlingMiddleware>();

    // CORS
    app.UseCors("AllowFrontend");

    // Swagger
    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "Tickets API v1");
            c.RoutePrefix = string.Empty;
        });
    }

    app.UseHttpsRedirection();
    app.UseAuthentication();
    app.UseAuthorization();

    // ==================== ENDPOINTS ====================
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
