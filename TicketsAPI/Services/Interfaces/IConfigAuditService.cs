namespace TicketsAPI.Services.Interfaces
{
    public interface IConfigAuditService
    {
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
