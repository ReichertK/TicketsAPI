using Dapper;
using MySqlConnector;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    /// <summary>
    /// Implementación del servicio de auditoría de configuración.
    /// Inserta registros en la tabla audit_config para rastrear cambios
    /// en entidades administrativas (departamentos, motivos, roles, permisos).
    /// </summary>
    public class ConfigAuditService : IConfigAuditService
    {
        private readonly string _connectionString;
        private readonly ILogger<ConfigAuditService> _logger;

        public ConfigAuditService(string connectionString, ILogger<ConfigAuditService> logger)
        {
            _connectionString = connectionString;
            _logger = logger;
        }

        public async Task RegistrarConfiguracionAsync(
            string entidad,
            int? idEntidad,
            string accion,
            string? campoModificado,
            string? valorAnterior,
            string? valorNuevo,
            int usuarioId,
            string? usuarioNombre = null,
            string? descripcion = null)
        {
            try
            {
                using var conn = new MySqlConnection(_connectionString);
                await conn.ExecuteAsync(@"
                    INSERT INTO audit_config 
                        (entidad, id_entidad, accion, campo_modificado, valor_anterior, valor_nuevo, usuario_id, usuario_nombre, descripcion)
                    VALUES 
                        (@entidad, @idEntidad, @accion, @campoModificado, @valorAnterior, @valorNuevo, @usuarioId, @usuarioNombre, @descripcion)",
                    new
                    {
                        entidad,
                        idEntidad,
                        accion,
                        campoModificado,
                        valorAnterior = Truncate(valorAnterior, 500),
                        valorNuevo = Truncate(valorNuevo, 500),
                        usuarioId,
                        usuarioNombre = Truncate(usuarioNombre, 100),
                        descripcion = Truncate(descripcion, 500)
                    });
            }
            catch (Exception ex)
            {
                // La auditoría no debe romper la operación principal
                _logger.LogError(ex, "Error al registrar auditoría de config: {Entidad} {Accion} id={IdEntidad}",
                    entidad, accion, idEntidad);
            }
        }

        private static string? Truncate(string? value, int maxLength)
            => value != null && value.Length > maxLength ? value[..maxLength] : value;
    }
}
