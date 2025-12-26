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
        Task<bool> UpdateLastSessionAsync(int idUsuario);
        Task<bool> ExistsAsync(int id);
    }

    /// <summary>
    /// Interfaz para repositorio de tickets
    /// </summary>
    public interface ITicketRepository : IBaseRepository<Models.Entities.Ticket>
    {
        Task<PaginatedResponse<TicketDTO>> GetFilteredAsync(TicketFiltroDTO filtro);
        [System.Obsolete("No usar: bypass de stored procedures y validaciones de permisos. Usar GetFilteredAsync (sp_listar_tkts).")]
        Task<List<Models.Entities.Ticket>> GetByUsuarioCreadorAsync(int idUsuario);
        [System.Obsolete("No usar: bypass de stored procedures y validaciones de permisos. Usar GetFilteredAsync (sp_listar_tkts).")]
        Task<List<Models.Entities.Ticket>> GetByUsuarioAsignadoAsync(int idUsuario);
        [System.Obsolete("No usar: bypass de stored procedures y validaciones de permisos. Usar GetFilteredAsync (sp_listar_tkts).")]
        Task<List<Models.Entities.Ticket>> GetByEstadoAsync(int idEstado);
        [System.Obsolete("No usar: bypass de stored procedures y validaciones de permisos. Usar GetFilteredAsync (sp_listar_tkts).")]
        Task<List<Models.Entities.Ticket>> GetByDepartamentoAsync(int idDepartamento);
        Task<TicketDTO?> GetDetailAsync(int id);
            Task<bool> UpdateViaStoredProcedureAsync(long idTkt, int idEstado, int? idUsuario, int? idEmpresa, int? idPerfil, int? idMotivo, int? idSucursal, int idPrioridad, string contenido, int idDepartamento);
        Task<TransicionResultDTO> TransicionarEstadoViaStoredProcedureAsync(
            int idTkt,
            int estadoTo,
            int idUsuarioActor,
            string? comentario = null,
            string? motivo = null,
            int? idAsignadoNuevo = null,
            string? metaJson = null);
        Task<List<HistorialTicketDTO>> GetHistorialViaStoredProcedureAsync(int idTkt);
    }

    /// <summary>
    /// Interfaz para repositorio de estados
    /// </summary>
    public interface IEstadoRepository : IBaseRepository<Models.Entities.Estado>
    {
        Task<Models.Entities.Estado?> GetByNombreAsync(string nombre);
        Task<List<Models.Entities.Estado>> GetAllActiveAsync();
    }

    /// <summary>
    /// Interfaz para repositorio de prioridades
    /// </summary>
    public interface IPrioridadRepository : IBaseRepository<Models.Entities.Prioridad>
    {
        Task<Models.Entities.Prioridad?> GetByNombreAsync(string nombre);
        Task<List<Models.Entities.Prioridad>> GetAllActiveAsync();
        Task<bool> ExistsAsync(int id);
    }

    /// <summary>
    /// Interfaz para repositorio de departamentos
    /// </summary>
    public interface IDepartamentoRepository : IBaseRepository<Models.Entities.Departamento>
    {
        Task<Models.Entities.Departamento?> GetByNombreAsync(string nombre);
        Task<List<Models.Entities.Departamento>> GetAllActiveAsync();
        Task<bool> ExistsAsync(int id);
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
    }

    /// <summary>
    /// Interfaz para repositorio de permisos
    /// </summary>
    public interface IPermisoRepository : IBaseRepository<Models.Entities.Permiso>
    {
        Task<Models.Entities.Permiso?> GetByCodigoAsync(string codigo);
        Task<List<Models.Entities.Permiso>> GetByModuloAsync(string modulo);
        Task<List<Models.Entities.Permiso>> GetByRolAsync(int idRol);
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
    }
}
