using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Repositories.Interfaces
{
    /// <summary>
    /// Interfaz base para repositorios genéricos
    /// </summary>
    public interface IBaseRepository<T> where T : class
    {
        Task<T?> GetByIdAsync(int id);
        Task<List<T>> GetAllAsync();
        Task<int> CreateAsync(T entity);
        Task<bool> UpdateAsync(T entity);
        Task<bool> DeleteAsync(int id);
    }

    /// <summary>
    /// Interfaz para repositorio de usuarios
    /// </summary>
    public interface IUsuarioRepository : IBaseRepository<Models.Entities.Usuario>
    {
        Task<Models.Entities.Usuario?> GetByEmailAsync(string email);
        Task<Models.Entities.Usuario?> GetByUsuarioAsync(string usuario);
        Task<List<Models.Entities.Usuario>> GetByRolAsync(int idRol);
        Task<List<Models.Entities.Usuario>> GetByDepartamentoAsync(int idDepartamento);
        Task<List<Models.Entities.Usuario>> GetFilteredAsync(string? nombre, string? email, string? tipo, int? habilitado);
        Task<bool> UpdateLastSessionAsync(int idUsuario);
        Task<bool> ExistsAsync(int id);
        Task<bool> SaveRefreshTokenAsync(int idUsuario, string refreshTokenHash, DateTime expiresAt);
        Task<Models.Entities.Usuario?> GetByRefreshTokenAsync(string refreshTokenHash);
        Task<bool> ClearRefreshTokenAsync(int idUsuario);
        Task<bool> UpdatePasswordHashAsync(int idUsuario, string newHash);
        /// <summary>
        /// Obtiene todos los usuarios con Rol y Departamento en una sola consulta JOIN (elimina N+1).
        /// </summary>
        Task<List<Models.Entities.Usuario>> GetAllWithRelationsAsync();
        /// <summary>
        /// Toggle soft-delete: si fechaBaja IS NULL → pone CURDATE(); si tiene fecha → la limpia.
        /// Retorna true si se logró la operación.
        /// </summary>
        Task<bool> ToggleActiveAsync(int idUsuario);
        Task<(int idEmpresa, int idSucursal, int idPerfil)?> GetUsuarioContextoAsync(int idUsuario);
        /// <summary>
        /// Restablecer contraseña via SP sp_usuario_reset_password (Admin-only, con audit_log).
        /// </summary>
        Task<bool> ResetPasswordAsync(int idUsuarioTarget, string nuevoPasswordHash, int idUsuarioAdmin);
    }

    /// <summary>
    /// Interfaz para repositorio de tickets
    /// </summary>
    public interface ITicketRepository : IBaseRepository<Models.Entities.Ticket>
    {
        Task<PaginatedResponse<TicketDTO>> GetFilteredAsync(TicketFiltroDTO filtro);
        Task<PaginatedResponse<TicketDTO>> GetFilteredAdvancedAsync(TicketFiltroDTO filtro);
        Task<TicketDTO?> GetDetailAsync(int id);
            Task<bool> UpdateViaStoredProcedureAsync(long idTkt, int idEstado, int? idUsuario, int? idEmpresa, int? idPerfil, int? idMotivo, int? idSucursal, int idPrioridad, string contenido, int idDepartamento, int idUsuarioActor);
        Task<bool> AssignViaStoredProcedureAsync(long idTkt, int idUsuarioAsignado, int idUsuarioActor, string? comentario);
        Task<TransicionResultDTO> TransicionarEstadoViaStoredProcedureAsync(
            int idTkt,
            int estadoTo,
            int idUsuarioActor,
            string? comentario = null,
            string? motivo = null,
            int? idAsignadoNuevo = null,
            string? metaJson = null,
            bool esSuperAdmin = false);
        Task<List<HistorialTicketDTO>> GetHistorialViaStoredProcedureAsync(int idTkt);

        // ── Vistas de listado (SPs dedicados) ─────────────────────────
        Task<PaginatedResponse<TicketDTO>> GetMisTicketsAsync(int idUsuario, TicketFiltroDTO filtro);
        Task<PaginatedResponse<TicketDTO>> GetColaTrabajoAsync(int idUsuarioActor, TicketFiltroDTO filtro);
        Task<PaginatedResponse<TicketDTO>> GetTodosTicketsAsync(int idUsuarioActor, TicketFiltroDTO filtro);

        // ── Suscripciones ─────────────────────────────────────────────
        Task<SuscripcionResultDTO> GestionarSuscripcionAsync(int idTkt, int idUsuario, string accion);
        Task<List<SuscriptorDTO>> GetSuscriptoresAsync(int idTkt);
        Task<bool> EstaSuscritoAsync(int idTkt, int idUsuario);
    }

    /// <summary>
    /// Interfaz para repositorio de estados
    /// </summary>
    public interface IEstadoRepository : IBaseRepository<Models.Entities.Estado>
    {
        Task<Models.Entities.Estado?> GetByNombreAsync(string nombre);
        Task<List<Models.Entities.Estado>> GetAllActiveAsync();
        Task<bool> ExistsAsync(int id);
        /// <summary>
        /// Toggle soft-delete: si Habilitado = 1 → desactiva; si 0 → reactiva.
        /// Protege estados críticos (Abierto, Cerrado) de ser desactivados.
        /// </summary>
        Task<bool> ToggleStatusAsync(int id);
    }

    /// <summary>
    /// Interfaz para repositorio de prioridades
    /// </summary>
    public interface IPrioridadRepository : IBaseRepository<Models.Entities.Prioridad>
    {
        Task<Models.Entities.Prioridad?> GetByNombreAsync(string nombre);
        Task<List<Models.Entities.Prioridad>> GetAllActiveAsync();
        Task<bool> ExistsAsync(int id);
        /// <summary>
        /// Toggle soft-delete: si Habilitado = 1 → desactiva; si 0 → reactiva.
        /// </summary>
        Task<bool> ToggleStatusAsync(int id);
    }

    /// <summary>
    /// Interfaz para repositorio de departamentos
    /// </summary>
    public interface IDepartamentoRepository : IBaseRepository<Models.Entities.Departamento>
    {
        Task<Models.Entities.Departamento?> GetByNombreAsync(string nombre);
        Task<List<Models.Entities.Departamento>> GetAllActiveAsync();
        Task<bool> ExistsAsync(int id);
        /// <summary>
        /// Toggle soft-delete: si Habilitado = 1 → desactiva; si 0 → reactiva.
        /// </summary>
        Task<bool> ToggleStatusAsync(int id);
    }

    /// <summary>
    /// Interfaz para repositorio de comentarios
    /// </summary>
    public interface IComentarioRepository : IBaseRepository<Models.Entities.Comentario>
    {
        Task<List<Models.Entities.Comentario>> GetByTicketAsync(int idTicket);
        Task<List<Models.Entities.Comentario>> GetByUsuarioAsync(int idUsuario);
        Task<ComentarioResultDTO> CrearComentarioViaStoredProcedureAsync(int idTkt, int idUsuario, string comentario);
    }

    /// <summary>
    /// Interfaz para repositorio de historial
    /// </summary>
    public interface IHistorialRepository : IBaseRepository<Models.Entities.HistorialTicket>
    {
        Task<List<Models.Entities.HistorialTicket>> GetByTicketAsync(int idTicket);
        Task<List<Models.Entities.HistorialTicket>> GetByUsuarioAsync(int idUsuario);
    }

    /// <summary>
    /// Interfaz para repositorio de roles
    /// </summary>
    public interface IRolRepository : IBaseRepository<Models.Entities.Rol>
    {
        Task<Models.Entities.Rol?> GetByNombreAsync(string nombre);
        Task<Models.Entities.Rol?> GetWithPermisosAsync(int id);
        Task<List<RolListDTO>> ListarRolesAsync();
        Task<int> GuardarRolAsync(int? idRol, string nombre);
        Task EliminarRolAsync(int idRol);
        Task<int> GestionarPermisosAsync(int idRol, string permisosCsv);
        Task AsignarRolAUsuarioAsync(int idUsuario, int idRol);
    }

    /// <summary>
    /// Interfaz para repositorio de permisos
    /// </summary>
    public interface IPermisoRepository : IBaseRepository<Models.Entities.Permiso>
    {
        Task<Models.Entities.Permiso?> GetByCodigoAsync(string codigo);
        Task<List<Models.Entities.Permiso>> GetByModuloAsync(string modulo);
        Task<List<Models.Entities.Permiso>> GetByRolAsync(int idRol);
        Task<List<string>> GetCodigosByUsuarioAsync(int idUsuario);
        Task<List<PermisoListDTO>> ListarPermisosAsync();
        Task<PermisoListDTO> GuardarPermisoAsync(int? idPermiso, string codigo, string descripcion);
    }

    /// <summary>
    /// Interfaz para repositorio de políticas de transición
    /// </summary>
    public interface IPoliticaTransicionRepository : IBaseRepository<Models.Entities.PoliticaTransicion>
    {
        Task<Models.Entities.PoliticaTransicion?> GetTransicionAsync(int idEstadoOrigen, int idEstadoDestino, int idRol);
        Task<List<Models.Entities.PoliticaTransicion>> GetPosiblesTransicionesAsync(int idEstadoActual, int idRol);
    }

    /// <summary>
    /// Interfaz para repositorio de motivos
    /// </summary>
    public interface IMotivoRepository : IBaseRepository<Models.Entities.Motivo>
    {
        Task<bool> ExistsAsync(int id);
        Task<Models.Entities.Motivo?> GetByNombreAsync(string nombre);
        Task<List<Models.Entities.Motivo>> GetAllActiveAsync();
        /// <summary>
        /// Toggle soft-delete: si Habilitado = 1 → desactiva; si 0 → reactiva.
        /// </summary>
        Task<bool> ToggleStatusAsync(int id);
        /// <summary>
        /// Obtener motivos activos filtrados por departamento (para selector dinámico en frontend).
        /// </summary>
        Task<List<Models.Entities.Motivo>> GetByDepartamentoAsync(int idDepartamento);
    }

    /// <summary>
    /// Interfaz para repositorio de reportes
    /// </summary>
    public interface IReporteRepository
    {
        Task<DashboardDTO> GetDashboardAsync(int? idUsuario, int? idDepartamento);
    }

    /// <summary>
    /// Interfaz para repositorio de notificaciones de lectura
    /// </summary>
    public interface INotificacionLecturaRepository
    {
        Task<NotificacionResumenDTO> GetResumenAsync(int idUsuario);
        Task MarcarLeidoAsync(int idTicket, int idUsuario);
        Task MarcarTodosLeidosAsync(int idUsuario);
    }
}
