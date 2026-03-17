using Dapper;
using MySqlConnector;

namespace TicketsAPI.Services.Implementations
{
    /// Servicio de protección contra fuerza bruta.
    /// Registra intentos fallidos, bloquea cuentas tras N fallos y desbloquea automáticamente.
    public class BruteForceProtectionService
    {
        private readonly string _connectionString;
        private readonly ILogger<BruteForceProtectionService> _logger;

        private const int MaxIntentosFallidos = 5;
        private const int MinutosBloqueo = 15;

        public BruteForceProtectionService(string connectionString, ILogger<BruteForceProtectionService> logger)
        {
            _connectionString = connectionString;
            _logger = logger;
        }

        /// Verifica si el usuario está bloqueado por intentos fallidos.
        /// Si el bloqueo ha expirado, lo limpia automáticamente.
        public virtual async Task<(bool Bloqueado, int IntentosRestantes, DateTime? BloqueadoHasta)> VerificarBloqueoAsync(string nombreUsuario)
        {
            try
            {
                using var conn = new MySqlConnection(_connectionString);
                var usuario = await conn.QuerySingleOrDefaultAsync<dynamic>(
                    @"SELECT idUsuario, intentos_fallidos, bloqueado_hasta 
                      FROM usuario 
                      WHERE nombre = @nombre OR email = @nombre
                      LIMIT 1",
                    new { nombre = nombreUsuario });

                if (usuario == null)
                    return (false, MaxIntentosFallidos, null); // Usuario no existe, dejamos que LoginAsync maneje

                DateTime? bloqueadoHasta = usuario.bloqueado_hasta as DateTime?;
                int intentos = (int)(usuario.intentos_fallidos ?? 0);

                // Si está bloqueado pero el bloqueo expiró, limpiar
                if (bloqueadoHasta.HasValue && bloqueadoHasta.Value <= DateTime.Now)
                {
                    await conn.ExecuteAsync(
                        "UPDATE usuario SET intentos_fallidos = 0, bloqueado_hasta = NULL WHERE idUsuario = @id",
                        new { id = (long)usuario.idUsuario });
                    _logger.LogInformation("Bloqueo expirado y limpiado para usuario {User}", nombreUsuario);
                    return (false, MaxIntentosFallidos, null);
                }

                // Si está bloqueado y no ha expirado
                if (bloqueadoHasta.HasValue && bloqueadoHasta.Value > DateTime.Now)
                {
                    return (true, 0, bloqueadoHasta);
                }

                return (false, MaxIntentosFallidos - intentos, null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verificando bloqueo para {User}", nombreUsuario);
                return (false, MaxIntentosFallidos, null); // En caso de error, no bloquear
            }
        }

        /// Registra un intento fallido de login. Si alcanza el máximo, bloquea la cuenta.
        public virtual async Task RegistrarIntentoFallidoAsync(string nombreUsuario, string ipAddress)
        {
            try
            {
                using var conn = new MySqlConnection(_connectionString);

                // 1. Registrar en tabla de detalle
                await conn.ExecuteAsync(
                    @"INSERT INTO failed_login_attempts (usuario_nombre, ip_address, fecha) 
                      VALUES (@usuario, @ip, NOW())",
                    new { usuario = nombreUsuario, ip = ipAddress });

                // 2. Incrementar contador en usuario
                var result = await conn.QuerySingleOrDefaultAsync<dynamic>(
                    @"UPDATE usuario 
                      SET intentos_fallidos = intentos_fallidos + 1 
                      WHERE nombre = @nombre OR email = @nombre;
                      SELECT idUsuario, intentos_fallidos 
                      FROM usuario 
                      WHERE nombre = @nombre OR email = @nombre 
                      LIMIT 1",
                    new { nombre = nombreUsuario });

                if (result != null)
                {
                    int intentos = (int)(result.intentos_fallidos ?? 0);

                    // 3. Si alcanzó el máximo, bloquear
                    if (intentos >= MaxIntentosFallidos)
                    {
                        var bloqueadoHasta = DateTime.Now.AddMinutes(MinutosBloqueo);
                        await conn.ExecuteAsync(
                            "UPDATE usuario SET bloqueado_hasta = @hasta WHERE idUsuario = @id",
                            new { hasta = bloqueadoHasta, id = (long)result.idUsuario });

                        _logger.LogWarning(
                            "🔒 Usuario {User} BLOQUEADO hasta {Hasta} por {Max} intentos fallidos desde IP {IP}",
                            nombreUsuario, bloqueadoHasta.ToString("HH:mm:ss"), MaxIntentosFallidos, ipAddress);
                    }
                    else
                    {
                        _logger.LogWarning(
                            "⚠️ Intento fallido {N}/{Max} para {User} desde IP {IP}",
                            intentos, MaxIntentosFallidos, nombreUsuario, ipAddress);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error registrando intento fallido para {User}", nombreUsuario);
            }
        }

        /// Limpia el contador de intentos fallidos después de un login exitoso.
        public virtual async Task LimpiarIntentosAsync(string nombreUsuario)
        {
            try
            {
                using var conn = new MySqlConnection(_connectionString);
                await conn.ExecuteAsync(
                    "UPDATE usuario SET intentos_fallidos = 0, bloqueado_hasta = NULL WHERE nombre = @nombre OR email = @nombre",
                    new { nombre = nombreUsuario });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error limpiando intentos para {User}", nombreUsuario);
            }
        }
    }
}
