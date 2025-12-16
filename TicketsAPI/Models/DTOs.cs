using System.ComponentModel.DataAnnotations;

namespace TicketsAPI.Models.DTOs
{
    // ==================== AUTH DTOs ====================
    /// <summary>
    /// DTO para login
    /// </summary>
    public class LoginRequest
    {
        [Required(ErrorMessage = "El usuario es requerido")]
        public string Usuario { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es requerida")]
        public string Contraseña { get; set; } = string.Empty;
    }

    /// <summary>
    /// DTO para respuesta de login
    /// </summary>
    public class LoginResponse
    {
        public int Id_Usuario { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
        public RolDTO? Rol { get; set; }
        public List<string> Permisos { get; set; } = new();
    }

    /// <summary>
    /// DTO para renovar token
    /// </summary>
    public class RefreshTokenRequest
    {
        [Required]
        public string RefreshToken { get; set; } = string.Empty;
    }

    // ==================== USER DTOs ====================
    /// <summary>
    /// DTO para usuario
    /// </summary>
    public class UsuarioDTO
    {
        public int Id_Usuario { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Apellido { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public int Id_Rol { get; set; }
        public int? Id_Departamento { get; set; }
        public bool Activo { get; set; }
        public DateTime Fecha_Registro { get; set; }
        public DateTime? Ultima_Sesion { get; set; }
        public RolDTO? Rol { get; set; }
        public DepartamentoDTO? Departamento { get; set; }
    }

    /// <summary>
    /// DTO para crear/actualizar usuario
    /// </summary>
    public class CreateUpdateUsuarioDTO
    {
        [Required(ErrorMessage = "El nombre es requerido")]
        public string Nombre { get; set; } = string.Empty;

        [Required(ErrorMessage = "El apellido es requerido")]
        public string Apellido { get; set; } = string.Empty;

        [Required(ErrorMessage = "El email es requerido")]
        [EmailAddress(ErrorMessage = "Email inválido")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "El usuario es requerido")]
        public string Usuario_Correo { get; set; } = string.Empty;

        public string? Contraseña { get; set; }

        [Required(ErrorMessage = "El rol es requerido")]
        public int Id_Rol { get; set; }

        public int? Id_Departamento { get; set; }
    }

    // ==================== ROLE & PERMISSION DTOs ====================
    /// <summary>
    /// DTO para rol
    /// </summary>
    public class RolDTO
    {
        public int Id_Rol { get; set; }
        public string Nombre_Rol { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public List<PermisoDTO>? Permisos { get; set; }
    }

    /// <summary>
    /// DTO para permiso
    /// </summary>
    public class PermisoDTO
    {
        public int Id_Permiso { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Modulo { get; set; } = string.Empty;
    }

    // ==================== DEPARTMENT DTOs ====================
    /// <summary>
    /// DTO para departamento
    /// </summary>
    public class DepartamentoDTO
    {
        public int Id_Departamento { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
    }

    // ==================== TICKET DTOs ====================
    /// <summary>
    /// DTO para crear/actualizar ticket
    /// </summary>
    public class CreateUpdateTicketDTO
    {
        [Required(ErrorMessage = "El contenido es requerido")]
        [StringLength(10000, MinimumLength = 10, ErrorMessage = "El contenido debe tener entre 10 y 10000 caracteres")]
        public string Contenido { get; set; } = string.Empty;

        [Required(ErrorMessage = "La prioridad es requerida")]
        public int Id_Prioridad { get; set; }

        [Required(ErrorMessage = "El departamento es requerido")]
        public int Id_Departamento { get; set; }

        public int? Id_Usuario_Asignado { get; set; }
        public int? Id_Motivo { get; set; }
    }

    /// <summary>
    /// DTO para ticket (respuesta)
    /// </summary>
    public class TicketDTO
    {
        public long Id_Tkt { get; set; }
        public int? Id_Estado { get; set; }
        public EstadoDTO? Estado { get; set; }
        public int? Id_Prioridad { get; set; }
        public PrioridadDTO? Prioridad { get; set; }
        public int? Id_Departamento { get; set; }
        public DepartamentoDTO? Departamento { get; set; }
        public int? Id_Usuario { get; set; }
        public UsuarioDTO? UsuarioCreador { get; set; }
        public int? Id_Usuario_Asignado { get; set; }
        public UsuarioDTO? UsuarioAsignado { get; set; }
        public int? Id_Empresa { get; set; }
        public int? Id_Perfil { get; set; }
        public int? Id_Sucursal { get; set; }
        public DateTime? Date_Creado { get; set; }
        public DateTime? Date_Asignado { get; set; }
        public DateTime? Date_Cierre { get; set; }
        public DateTime? Date_Cambio_Estado { get; set; }
        public string? Contenido { get; set; }
        public int? Id_Motivo { get; set; }
        public int? Habilitado { get; set; }
        public List<ComentarioDTO>? Comentarios { get; set; }
        public List<HistorialTicketDTO>? Historial { get; set; }
    }

    /// <summary>
    /// DTO para transición de estado
    /// </summary>
    public class TransicionEstadoDTO
    {
        [Required(ErrorMessage = "El nuevo estado es requerido")]
        public int Id_Estado_Nuevo { get; set; }

        public string? Comentario { get; set; }
        public string? Motivo { get; set; }
    }

    // ==================== STATUS & PRIORITY DTOs ====================
    /// <summary>
    /// DTO para estado
    /// </summary>
    public class EstadoDTO
    {
        public int Id_Estado { get; set; }
        public string Nombre_Estado { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public int Orden { get; set; }
        public bool Activo { get; set; }
    }

    /// <summary>
    /// DTO para prioridad
    /// </summary>
    public class PrioridadDTO
    {
        public int Id_Prioridad { get; set; }
        public string Nombre_Prioridad { get; set; } = string.Empty;
        public int Valor { get; set; }
        public string Color { get; set; } = string.Empty;
        public bool Activo { get; set; }
    }

    // ==================== COMMENT & HISTORY DTOs ====================
    /// <summary>
    /// DTO para comentario
    /// </summary>
    public class ComentarioDTO
    {
        public int Id_Comentario { get; set; }
        public int Id_Ticket { get; set; }
        public int Id_Usuario { get; set; }
        public UsuarioDTO? Usuario { get; set; }
        public string Contenido { get; set; } = string.Empty;
        public DateTime Fecha_Creacion { get; set; }
        public DateTime? Fecha_Actualizacion { get; set; }
        public bool Privado { get; set; }
    }

    /// <summary>
    /// DTO para crear/actualizar comentario
    /// </summary>
    public class CreateUpdateComentarioDTO
    {
        [Required(ErrorMessage = "El contenido es requerido")]
        [StringLength(1000, MinimumLength = 1, ErrorMessage = "El comentario debe tener máximo 1000 caracteres")]
        public string Contenido { get; set; } = string.Empty;

        public bool Privado { get; set; } = false;
    }

    /// <summary>
    /// DTO para historial de ticket
    /// </summary>
    public class HistorialTicketDTO
    {
        public int Id_Historial { get; set; }
        public int Id_Ticket { get; set; }
        public int Id_Usuario { get; set; }
        public UsuarioDTO? Usuario { get; set; }
        public string Accion { get; set; } = string.Empty;
        public string? Campo_Modificado { get; set; }
        public string? Valor_Anterior { get; set; }
        public string? Valor_Nuevo { get; set; }
        public DateTime Fecha_Cambio { get; set; }
    }

    // ==================== PAGINATION & RESPONSE DTOs ====================
    /// <summary>
    /// DTO para filtros de búsqueda
    /// </summary>
    public class TicketFiltroDTO
    {
        public int? Id_Estado { get; set; }
        public int? Id_Prioridad { get; set; }
        public int? Id_Departamento { get; set; }
        public int? Id_Usuario_Asignado { get; set; }
        public DateTime? Fecha_Desde { get; set; }
        public DateTime? Fecha_Hasta { get; set; }
        public string? Busqueda { get; set; }
        public string? Ordenar_Por { get; set; }
        public bool? Orden_Descendente { get; set; }
        public int Pagina { get; set; } = 1;
        public int TamañoPagina { get; set; } = 20;
    }

    /// <summary>
    /// DTO para respuesta paginada
    /// </summary>
    public class PaginatedResponse<T>
    {
        public List<T> Datos { get; set; } = new();
        public int TotalRegistros { get; set; }
        public int TotalPaginas { get; set; }
        public int PaginaActual { get; set; }
        public int TamañoPagina { get; set; }
        public bool TienePaginaAnterior { get; set; }
        public bool TienePaginaSiguiente { get; set; }
    }

    /// <summary>
    /// DTO para respuesta de API
    /// </summary>
    public class ApiResponse<T>
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public T? Datos { get; set; }
        public List<string> Errores { get; set; } = new();
    }

    /// <summary>
    /// DTO para estadísticas del dashboard
    /// </summary>
    public class DashboardDTO
    {
        public int TicketsTotal { get; set; }
        public int TicketsAbiertos { get; set; }
        public int TicketsCerrados { get; set; }
        public int TicketsEnProceso { get; set; }
        public int TicketsAsignadosAMi { get; set; }
        public Dictionary<string, int> TicketsPorEstado { get; set; } = new();
        public Dictionary<string, int> TicketsPorPrioridad { get; set; } = new();
        public Dictionary<string, int> TicketsPorDepartamento { get; set; } = new();
        public decimal TiempoPromedioResolucion { get; set; }
        public decimal TasaCumplimientoSLA { get; set; }
    }

    // ==================== MOTIVO DTOs ====================
    /// <summary>
    /// DTO para motivo de ticket
    /// </summary>
    public class MotivoDTO
    {
        public int Id_Motivo { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Categoria { get; set; }
    }

    /// <summary>
    /// DTO para crear/actualizar motivo
    /// </summary>
    public class CreateUpdateMotivoDTO
    {
        [Required]
        public string Nombre { get; set; } = string.Empty;
        public string? Categoria { get; set; }
    }

    // ==================== GRUPO DTOs ====================
    /// <summary>
    /// DTO para grupo
    /// </summary>
    public class GrupoDTO
    {
        public int Id_Grupo { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public bool Activo { get; set; }
    }

    // ==================== APROBACION DTOs ====================
    /// <summary>
    /// DTO para solicitud de aprobación
    /// </summary>
    public class AprobacionDTO
    {
        public int Id_Aprobacion { get; set; }
        public int Id_Tkt { get; set; }
        public int Id_Usuario_Solicitante { get; set; }
        public int Id_Usuario_Aprobador { get; set; }
        public string Estado { get; set; } = "Pendiente";
        public DateTime Fecha_Solicitud { get; set; }
        public DateTime? Fecha_Respuesta { get; set; }
    }

    /// <summary>
    /// DTO para crear aprobación
    /// </summary>
    public class CreateAprobacionDTO
    {
        [Required]
        public int Id_Usuario_Aprobador { get; set; }
    }

    /// <summary>
    /// DTO para responder aprobación
    /// </summary>
    public class ResponderAprobacionDTO
    {
        [Required]
        public bool Aprobado { get; set; }
        public string? Comentario { get; set; }
    }

    // ==================== TRANSICION DTOs ====================
    /// <summary>
    /// DTO para transición de estado
    /// </summary>
    public class TransicionDTO
    {
        public int Id_Transicion { get; set; }
        public int Id_Tkt { get; set; }
        public int Id_Estado_Anterior { get; set; }
        public int Id_Estado_Nuevo { get; set; }
        public int Id_Usuario { get; set; }
        public string? Comentario { get; set; }
        public DateTime Fecha { get; set; }
    }

    /// <summary>
    /// DTO para crear/actualizar departamento
    /// </summary>
    public class CreateUpdateDepartamentoDTO
    {
        [Required]
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
    }
}
