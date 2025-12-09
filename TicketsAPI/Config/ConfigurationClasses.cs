using Microsoft.Extensions.Diagnostics.HealthChecks;
using MySqlConnector;

namespace TicketsAPI.Config
{
    /// <summary>
    /// Health check para la base de datos
    /// </summary>
    public class DatabaseHealthCheck : IHealthCheck
    {
        private readonly string? _connectionString;

        public DatabaseHealthCheck(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            try
            {
                if (string.IsNullOrEmpty(_connectionString))
                {
                    return HealthCheckResult.Unhealthy("Connection string no configurada");
                }

                using (var connection = new MySqlConnection(_connectionString))
                {
                    await connection.OpenAsync(cancellationToken);
                    return HealthCheckResult.Healthy("Conexión a base de datos exitosa");
                }
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy($"Error: {ex.Message}");
            }
        }
    }

    /// <summary>
    /// Configuración JWT
    /// </summary>
    public class JwtSettings
    {
        public string SecretKey { get; set; } = string.Empty;
        public string Issuer { get; set; } = string.Empty;
        public string Audience { get; set; } = string.Empty;
        public int ExpirationMinutes { get; set; }
        public int RefreshTokenExpirationDays { get; set; }
    }

    /// <summary>
    /// Configuración CORS
    /// </summary>
    public class CorsSettings
    {
        public string[] AllowedOrigins { get; set; } = Array.Empty<string>();
        public string[] AllowedMethods { get; set; } = Array.Empty<string>();
        public string[] AllowedHeaders { get; set; } = Array.Empty<string>();
    }

    /// <summary>
    /// Configuración de API
    /// </summary>
    public class ApiSettings
    {
        public int PageSize { get; set; } = 20;
        public int MaxPageSize { get; set; } = 1000;
        public bool EnableSwagger { get; set; } = true;
        public string ApiVersion { get; set; } = "1.0.0";
    }
}
