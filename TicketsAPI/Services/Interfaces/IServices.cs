using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Services.Interfaces
{
    /// <summary>
    /// Interfaz para servicio de autenticación
    /// </summary>
    public interface IAuthService
    {
        Task<LoginResponse?> LoginAsync(LoginRequest request);
        Task<LoginResponse?> RefreshTokenAsync(string refreshToken);
        Task LogoutAsync(int idUsuario);
        Task<bool> ValidarPermisoAsync(int idUsuario, string codigoPermiso);
    }

    /// <summary>
    /// Interfaz para servicio de tickets
    /// </summary>
    public interface ITicketService
    {
        Task<TicketDTO?> GetByIdAsync(int id);
        Task<PaginatedResponse<TicketDTO>> GetFilteredAsync(TicketFiltroDTO filtro);
        Task<int> CreateAsync(CreateUpdateTicketDTO dto, int idUsuarioCreador);
        Task<bool> UpdateAsync(int id, CreateUpdateTicketDTO dto);
        Task<bool> TransicionarEstadoAsync(int id, TransicionEstadoDTO dto, int idUsuario);
        Task<bool> AsignarAsync(int id, int idUsuario);
        Task<bool> CloseAsync(int id, int idUsuario);
        Task<DashboardDTO> GetDashboardAsync(int idUsuario);
    }

    /// <summary>
    /// Interfaz para servicio de máquina de estados
    /// </summary>
    public interface IEstadoService
    {
        Task<List<EstadoDTO>> GetAllAsync();
        Task<EstadoDTO?> GetByIdAsync(int id);
        Task<List<TransicionPermitidaDTO>> GetTransicionesPermitidas(int idEstadoActual, int idRol);
        Task<bool> ValidarTransicionAsync(int idEstadoOrigen, int idEstadoDestino, int idRol);
    }

    /// <summary>
    /// Interfaz para servicio de usuarios
    /// </summary>
    public interface IUsuarioService
    {
        Task<UsuarioDTO?> GetByIdAsync(int id);
        Task<List<UsuarioDTO>> GetAllAsync();
        Task<List<UsuarioDTO>> GetByRolAsync(int idRol);
        Task<int> CreateAsync(CreateUpdateUsuarioDTO dto);
        Task<bool> UpdateAsync(int id, CreateUpdateUsuarioDTO dto);
        Task<bool> DeleteAsync(int id);
        Task<bool> ChangePasswordAsync(int id, string passwordActual, string passwordNueva);
    }

    /// <summary>
    /// Interfaz para servicio de comentarios
    /// </summary>
    public interface IComentarioService
    {
        Task<ComentarioDTO?> GetByIdAsync(int id);
        Task<List<ComentarioDTO>> GetByTicketAsync(int idTicket);
        Task<int> CreateAsync(int idTicket, CreateUpdateComentarioDTO dto, int idUsuario);
        Task<bool> UpdateAsync(int id, CreateUpdateComentarioDTO dto);
        Task<bool> DeleteAsync(int id, int idUsuario);
    }

    /// <summary>
    /// Interfaz para servicio de auditoría
    /// </summary>
    public interface IAuditoriaService
    {
        Task<List<HistorialTicketDTO>> GetHistorialTicketAsync(int idTicket);
        Task RegistrarCambioAsync(int idTicket, int idUsuario, string accion, 
            string? campoModificado = null, string? valorAnterior = null, string? valorNuevo = null);
        Task RegistrarAccesoAsync(int idUsuario, string accion, string? detalles = null);
    }

    /// <summary>
    /// Interfaz para servicio de notificaciones (SignalR)
    /// </summary>
    public interface INotificacionService
    {
        Task NotificarNuevoTicketAsync(int idTicket);
        Task NotificarActualizacionTicketAsync(int idTicket);
        Task NotificarSolicitudAprobacionAsync(int idTicket);
        Task NotificarTransicionEstadoAsync(int idTicket, string nuevoEstado);
        Task NotificarNuevoComentarioAsync(int idTicket);
    }

    /// <summary>
    /// Interfaz para servicio de permisos
    /// </summary>
    public interface IPermisoService
    {
        Task<List<PermisoDTO>> GetByRolAsync(int idRol);
        Task<List<string>> GetCodigosPermisosPorRolAsync(int idRol);
        Task<bool> TienePermisoAsync(int idUsuario, string codigoPermiso);
    }

    /// <summary>
    /// DTO auxiliar para transiciones permitidas
    /// </summary>
    public class TransicionPermitidaDTO
    {
        public int Id_Estado_Destino { get; set; }
        public string Nombre_Estado { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
    }
}
