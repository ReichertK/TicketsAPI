using Dapper;
using MySqlConnector;
using Microsoft.Extensions.Caching.Memory;

namespace TicketsAPI.Middleware
{
    /// Middleware que valida en cada request autenticado que el usuario
    /// siga activo (fechaBaja IS NULL). Si fue desactivado, devuelve 401.
    /// Usa cache in-memory de 30 s para minimizar el impacto en BD.
    public class UserActiveValidationMiddleware
    {
        private readonly RequestDelegate _next;
        private static readonly TimeSpan CacheDuration = TimeSpan.FromSeconds(30);
        private const string CachePrefix = "UserActive_";

        public UserActiveValidationMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IConfiguration configuration, IMemoryCache cache)
        {
            if (context.User.Identity?.IsAuthenticated == true)
            {
                var userIdClaim = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                                  ?? context.User.FindFirst("sub")?.Value;

                if (int.TryParse(userIdClaim, out var userId))
                {
                    var cacheKey = $"{CachePrefix}{userId}";

                    // Intentar obtener del cache
                    if (!cache.TryGetValue(cacheKey, out bool isActive))
                    {
                        // Consultar BD
                        var connectionString = configuration.GetConnectionString("DbTkt")
                            ?? configuration.GetConnectionString("DefaultConnection");

                        using var conn = new MySqlConnection(connectionString);
                        var fechaBaja = await conn.QuerySingleOrDefaultAsync<DateTime?>(
                            "SELECT fechaBaja FROM usuario WHERE idUsuario = @id",
                            new { id = userId });

                        isActive = !fechaBaja.HasValue;

                        // Guardar en cache
                        cache.Set(cacheKey, isActive, CacheDuration);
                    }

                    if (!isActive)
                    {
                        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                        context.Response.ContentType = "application/json";
                        await context.Response.WriteAsJsonAsync(new
                        {
                            exitoso = false,
                            mensaje = "Usuario desactivado o inexistente",
                            errores = new[] { "El usuario ha sido dado de baja del sistema" }
                        });
                        return;
                    }
                }
            }

            await _next(context);
        }
    }

    /// Extension method para registrar el middleware de validación de usuario activo
    public static class UserActiveValidationMiddlewareExtensions
    {
        public static IApplicationBuilder UseUserActiveValidation(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<UserActiveValidationMiddleware>();
        }
    }
}
