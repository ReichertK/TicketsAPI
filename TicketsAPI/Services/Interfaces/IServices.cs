using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Services.Interfaces
{
    public interface IAuthService
    {
        Task<LoginResponse?> LoginAsync(LoginRequest request);
        Task<LoginResponse?> RefreshTokenAsync(string refreshToken);
        Task LogoutAsync(int idUsuario);
        Task<bool> ValidarPermisoAsync(int idUsuario, string codigoPermiso);
    }

    public interface ITicketService
    {
        Task<TicketDTO?> GetByIdAsync(int id);
        Task<PaginatedResponse<TicketDTO>> GetFilteredAsync(TicketFiltroDTO filtro, int idUsuarioActual);
        Task<int> CreateAsync(CreateUpdateTicketDTO dto, int idUsuarioCreador);
        Task<bool> UpdateAsync(int id, CreateUpdateTicketDTO dto, int idUsuarioActual);
        Task<bool> TransicionarEstadoAsync(int id, TransicionEstadoDTO dto, int idUsuario);
        Task<bool> AsignarAsync(int id, int idUsuarioAsignado, int idUsuarioActor, string? comentario);
        Task<bool> CloseAsync(int id, int idUsuario, string? comentario = null);
    }

    public interface IEstadoService
    {
        Task<List<EstadoDTO>> GetAllAsync();
        Task<EstadoDTO?> GetByIdAsync(int id);
        Task<List<TransicionPermitidaDTO>> GetTransicionesPermitidas(int idEstadoActual, int idRol);
        Task<bool> ValidarTransicionAsync(int idEstadoOrigen, int idEstadoDestino, int idRol);
    }

    public interface IUsuarioService
    {
        Task<UsuarioDTO?> GetByIdAsync(int id);
        Task<List<UsuarioDTO>> GetAllAsync();
        Task<List<UsuarioDTO>> GetFilteredAsync(string? nombre, string? email, string? tipo, int? habilitado);
        Task<List<UsuarioDTO>> GetByRolAsync(int idRol);
        Task<int> CreateAsync(CreateUpdateUsuarioDTO dto);
        Task<bool> UpdateAsync(int id, CreateUpdateUsuarioDTO dto);
        Task<bool> DeleteAsync(int id);
        Task<bool> ChangePasswordAsync(int id, string passwordActual, string passwordNueva);
        /// <summary>
        /// Restablecer contraseña de un usuario (desde panel Admin).
        /// </summary>
        Task<bool> ResetPasswordAsync(int idUsuarioTarget, int idUsuarioAdmin, string nuevaPassword);
    }

    public interface IComentarioService
    {
        Task<ComentarioDTO?> GetByIdAsync(int id);
        Task<List<ComentarioDTO>> GetByTicketAsync(int idTicket);
        Task<int> CreateAsync(int idTicket, CreateUpdateComentarioDTO dto, int idUsuario);
        Task<bool> UpdateAsync(int id, CreateUpdateComentarioDTO dto);
        Task<bool> DeleteAsync(int id, int idUsuario);
    }

    public interface IAuditoriaService
    {
        Task<List<HistorialTicketDTO>> GetHistorialTicketAsync(int idTicket);
        Task RegistrarCambioAsync(int idTicket, int idUsuario, string accion, 
            string? campoModificado = null, string? valorAnterior = null, string? valorNuevo = null);
        Task RegistrarAccesoAsync(int idUsuario, string accion, string? detalles = null);
    }

    public interface INotificacionService
    {
        Task NotificarNuevoTicketAsync(int idTicket);
        Task NotificarNuevoTicketAsync(int idTicket, int idUsuarioCreador);
        Task NotificarActualizacionTicketAsync(int idTicket);
        Task ActualizacionTicketAsync(int idTicket, int idUsuarioActualizador);
        Task NotificarSolicitudAprobacionAsync(int idTicket);
        Task SolicitudAprobacionAsync(int idTicket, int idUsuarioSolicitante, int idUsuarioAprobador);
        Task NotificarTransicionEstadoAsync(int idTicket, string nuevoEstado);
        Task TransicionEstadoAsync(int idTicket, int idUsuario, int idEstadoNuevo);
        Task NotificarNuevoComentarioAsync(int idTicket);
        Task NuevoComentarioAsync(int idTicket, int idUsuario, string comentario);
        /// <summary>
        /// Enviar alerta de mención (@usuario) a un usuario específico vía SignalR.
        /// </summary>
        Task MencionUsuarioAsync(int idUsuarioDestino, int idTicket, long idComentario, string mensaje);
        /// <summary>
        /// Notificar a un usuario que le asignaron un ticket vía SignalR.
        /// </summary>
        Task AsignacionTicketAsync(int idUsuarioDestino, int idTicket, string mensaje);
    }

    public interface IPermisoService
    {
        Task<List<PermisoDTO>> GetByRolAsync(int idRol);
        Task<List<string>> GetCodigosPermisosPorRolAsync(int idRol);
        Task<bool> TienePermisoAsync(int idUsuario, string codigoPermiso);
    }

    public interface IPrioridadService
    {
        Task<List<PrioridadDTO>> GetAllAsync();
        Task<PrioridadDTO?> GetByIdAsync(int id);
    }

    public interface IDepartamentoService
    {
        Task<List<DepartamentoDTO>> GetAllAsync();
        Task<DepartamentoDTO?> GetByIdAsync(int id);
    }

    /// <summary>
    /// DTO auxiliar para transiciones permitidas
    /// </summary>
    public class TransicionPermitidaDTO
    {
        public int Id_Estado_Destino { get; set; }
        public string Nombre_Estado { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public string? Permiso_Requerido { get; set; }
        public bool Requiere_Propietario { get; set; }
        public bool Requiere_Aprobacion { get; set; }
    }
}
