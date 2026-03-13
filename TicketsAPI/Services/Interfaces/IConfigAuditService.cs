namespace TicketsAPI.Services.Interfaces
{
    /// <summary>
    /// Servicio para registrar cambios de configuración en audit_config
    /// </summary>
    public interface IConfigAuditService
    {
        /// <summary>
        /// Registra un cambio de configuración (INSERT, UPDATE, DELETE, TOGGLE, ASSIGN, REVOKE)
        /// </summary>
        Task RegistrarConfiguracionAsync(
            string entidad,
            int? idEntidad,
            string accion,
            string? campoModificado,
            string? valorAnterior,
            string? valorNuevo,
            int usuarioId,
            string? usuarioNombre = null,
            string? descripcion = null);
    }
}
