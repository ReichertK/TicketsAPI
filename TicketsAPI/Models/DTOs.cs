using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TicketsAPI.Models.DTOs
{
    // AUTH DTOs
    /// DTO para login
    public class LoginRequest
    {
        [Required(ErrorMessage = "El usuario es requerido")]
        public string Usuario { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es requerida")]
        public string Contraseña { get; set; } = string.Empty;
    }

    /// DTO para restablecer contraseña (admin)
    public class ResetPasswordRequest
    {
        [Required(ErrorMessage = "La nueva contraseña es requerida")]
        [MinLength(6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres")]
        public string NuevaPassword { get; set; } = string.Empty;
    }

    /// DTO para respuesta de login
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

    /// DTO para renovar token
    public class RefreshTokenRequest
    {
        [Required]
        public string RefreshToken { get; set; } = string.Empty;
    }

    // USER DTOs
    /// DTO para usuario
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

    /// DTO para crear/actualizar usuario
    public class CreateUpdateUsuarioDTO
    {
        [Required(ErrorMessage = "El nombre es requerido")]
        public string Nombre { get; set; } = string.Empty;

        public string Apellido { get; set; } = string.Empty;

        [Required(ErrorMessage = "El email es requerido")]
        [EmailAddress(ErrorMessage = "Email inválido")]
        public string Email { get; set; } = string.Empty;

        public string Usuario_Correo { get; set; } = string.Empty;

        [JsonPropertyName("password")]
        public string? Password { get; set; }

        public string? Contraseña { get; set; }

        [Required(ErrorMessage = "El rol es requerido")]
        public int Id_Rol { get; set; }

        public int? Id_Departamento { get; set; }
    }

    /// DTO para cambiar contraseña
    public class ChangePasswordDTO
    {
        [Required(ErrorMessage = "La contraseña actual es requerida")]
        public string PasswordActual { get; set; } = string.Empty;

        [Required(ErrorMessage = "La nueva contraseña es requerida")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "La contraseña debe tener entre 6 y 100 caracteres")]
        public string PasswordNueva { get; set; } = string.Empty;
    }

    // ROLE & PERMISSION DTOs
    /// DTO para rol
    public class RolDTO
    {
        public int Id_Rol { get; set; }
        public string Nombre_Rol { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public List<PermisoDTO>? Permisos { get; set; }
    }

    /// DTO para permiso
    public class PermisoDTO
    {
        public int Id_Permiso { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Modulo { get; set; } = string.Empty;
    }

    // DEPARTMENT DTOs
    /// DTO para departamento
    public class DepartamentoDTO
    {
        public int Id_Departamento { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
    }

    // TICKET DTOs
    /// DTO para crear/actualizar ticket
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

    /// DTO para ticket (respuesta)
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
        public string? MotivoNombre { get; set; }
        public int? Habilitado { get; set; }
        public List<ComentarioDTO>? Comentarios { get; set; }
        public List<HistorialTicketDTO>? Historial { get; set; }
    }

    /// DTO para transición de estado
    public class TransicionEstadoDTO
    {
        public int Id_Estado_Nuevo { get; set; }

        [JsonPropertyName("id_Estado_Destino")]
        public int? Id_Estado_Destino { get; set; }

        public string? Comentario { get; set; }
        public string? Motivo { get; set; }
        public int? Id_Usuario_Asignado_Nuevo { get; set; }
    }

    // STATUS & PRIORITY DTOs
    /// DTO para estado
    public class EstadoDTO
    {
        public int Id_Estado { get; set; }
        public string Nombre_Estado { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public int Orden { get; set; }
        public bool Activo { get; set; }
    }

    /// DTO para prioridad
    public class PrioridadDTO
    {
        public int Id_Prioridad { get; set; }
        public string Nombre_Prioridad { get; set; } = string.Empty;
        public int Valor { get; set; }
        public string Color { get; set; } = string.Empty;
        public bool Activo { get; set; }
    }

    // COMMENT & HISTORY DTOs
    /// DTO para comentario
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

    /// DTO para crear/actualizar comentario
    public class CreateUpdateComentarioDTO
    {
        [Required(ErrorMessage = "El contenido es requerido")]
        [StringLength(1000, MinimumLength = 1, ErrorMessage = "El comentario debe tener máximo 1000 caracteres")]
        public string Contenido { get; set; } = string.Empty;

        public bool Privado { get; set; } = false;
    }

    /// DTO para historial de ticket
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

    // PAGINATION & RESPONSE DTOs
    /// DTO para filtros de búsqueda
    public class TicketFiltroDTO
    {
        public int? Id_Estado { get; set; }
        public int? Id_Prioridad { get; set; }
        public int? Id_Departamento { get; set; }
        public int? Id_Usuario_Asignado { get; set; }
        public int? Id_Motivo { get; set; }
        public int? Id_Usuario { get; set; }
        public DateTime? Fecha_Desde { get; set; }
        public DateTime? Fecha_Hasta { get; set; }
        
        [StringLength(500, ErrorMessage = "La búsqueda no puede exceder 500 caracteres")]
        [RegularExpression(@"^[^;'""]*$", ErrorMessage = "La búsqueda contiene caracteres no permitidos")]
        public string? Busqueda { get; set; }
        
        // Opciones de búsqueda avanzada
        public bool? BuscarEnComentarios { get; set; } = false;
        public bool? BuscarEnContenido { get; set; } = true;
        
        [StringLength(20)]
        public string? TipoBusqueda { get; set; } = "contiene"; // "contiene", "exacta", "comienza", "termina"
        
        public string? Ordenar_Por { get; set; }
        public bool? Orden_Descendente { get; set; }
        public int Pagina { get; set; } = 1;
        public int TamañoPagina { get; set; } = 20;

        /// Tipo de vista: "mis-tickets", "cola", "todos".
        /// Se pasa como query param. El servicio selecciona el SP correcto.
        public string? Vista { get; set; }

        /// Filtro "sin asignar" para la cola de trabajo (legacy, ahora se usa Vista=cola).
        public bool? SinAsignar { get; set; }

        /// ID del usuario que visualiza. Cuando está seteado, el filtro se comporta como:
        /// (creador = VistaUsuarioId) OR (asignado = VistaUsuarioId)
        /// Si además VistaUsuarioDepartamentoId está seteado, agrega: OR (departamento = VistaUsuarioDepartamentoId)
        /// Se setea automáticamente en TicketService según permisos del usuario.
        [System.Text.Json.Serialization.JsonIgnore]
        public int? VistaUsuarioId { get; set; }

        /// Departamento del usuario que visualiza. Cuando está seteado junto con VistaUsuarioId,
        /// permite ver tickets del mismo departamento (para usuarios con VER_SOLO_DEPARTAMENTO o TKT_LIST_ALL).
        [System.Text.Json.Serialization.JsonIgnore]
        public int? VistaUsuarioDepartamentoId { get; set; }
    }

    /// DTO para asignación de ticket
    public class AsignarTicketDTO
    {
        [Required(ErrorMessage = "El ID de usuario es requerido")]
        public int Id_Usuario_Asignado { get; set; }

        /// Comentario obligatorio al reasignar (cuando el ticket ya tenía dueño)
        public string? Comentario { get; set; }
    }

    /// DTO para respuesta paginada
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

    /// DTO para respuesta de API
    public class ApiResponse<T>
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public T? Datos { get; set; }
        public List<string> Errores { get; set; } = new();
    }

    /// DTO para estadísticas del dashboard
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

    // MOTIVO DTOs
    /// DTO para motivo de ticket
    public class MotivoDTO
    {
        public int Id_Motivo { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string? Categoria { get; set; }
        public bool Activo { get; set; }
    }

    /// DTO para crear/actualizar motivo
    public class CreateUpdateMotivoDTO
    {
        public string Nombre { get; set; } = string.Empty;
        [JsonPropertyName("descripcion")]
        public string? Descripcion { get; set; }
        public string? Categoria { get; set; }
    }

    // ESTADO / PRIORIDAD ADMIN DTOs
    /// DTO para crear/actualizar estado
    public class CreateUpdateEstadoDTO
    {
        [Required(ErrorMessage = "El nombre es requerido")]
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
    }

    /// DTO para crear/actualizar prioridad
    public class CreateUpdatePrioridadDTO
    {
        [Required(ErrorMessage = "El nombre es requerido")]
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
    }

    // GRUPO DTOs
    /// DTO para grupo
    public class GrupoDTO
    {
        public int Id_Grupo { get; set; }
        public string? Tipo_Grupo { get; set; }
    }

    // APROBACION DTOs
    /// DTO para solicitud de aprobación
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

    /// DTO para crear aprobación
    public class CreateAprobacionDTO
    {
        [Required]
        public int Id_Usuario_Aprobador { get; set; }
    }

    /// DTO para responder aprobación
    public class ResponderAprobacionDTO
    {
        [Required]
        public bool Aprobado { get; set; }
        public string? Comentario { get; set; }
    }

    // TRANSICION DTOs
    /// DTO para transición de estado
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

    /// DTO para crear/actualizar departamento
    public class CreateUpdateDepartamentoDTO
    {
        [Required]
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
    }

    // TRANSICION RESULT DTO
    /// Resultado de la transición de estado de un ticket (salida de sp_tkt_transicionar)
    public class TransicionResultDTO
    {
        public int Success { get; set; }  // 1 = éxito, 0 = error
        public string? Message { get; set; }  // Mensaje del SP
        public string? NuevoEstado { get; set; }  // Nuevo estado asignado
        public int? IdAsignado { get; set; }  // Usuario asignado (si aplica)
    }

    // COMENTARIO RESULT DTO
    /// Resultado de la creación de comentario (salida de sp_tkt_comentar)
    public class ComentarioResultDTO
    {
        public int Success { get; set; }  // 1 = éxito, 0 = error
        public string? Message { get; set; }  // Mensaje del SP
        public int? IdComentario { get; set; }  // ID del comentario creado (si aplica)
    }

    // REPORTES DTOs
    /// DTO para reporte agrupado por estado
    public class ReporteEstadoDTO
    {
        public string NombreEstado { get; set; } = string.Empty;
        public int Cantidad { get; set; }
        public double Porcentaje { get; set; }
        public string Color { get; set; } = string.Empty;
    }

    /// DTO para reporte agrupado por prioridad
    public class ReportePrioridadDTO
    {
        public string NombrePrioridad { get; set; } = string.Empty;
        public int Cantidad { get; set; }
        public double Porcentaje { get; set; }
        public string Color { get; set; } = string.Empty;
    }

    /// DTO para reporte agrupado por departamento
    public class ReporteDepartamentoDTO
    {
        public string NombreDepartamento { get; set; } = string.Empty;
        public int Cantidad { get; set; }
        public double Porcentaje { get; set; }
        public int TicketsAbiertos { get; set; }
        public int TicketsCerrados { get; set; }
    }

    /// DTO para reporte de tendencias por periodo
    public class TendenciaDTO
    {
        public string Periodo { get; set; } = string.Empty; // "2024-01-27", "Semana 4", "Enero 2024"
        public int TicketsCreados { get; set; }
        public int TicketsCerrados { get; set; }
        public int TicketsAbiertos { get; set; }
        public double TiempoPromedioResolucionHoras { get; set; }
    }

    /// DTO para filtros de reportes
    public class FiltroReporteDTO
    {
        public DateTime? FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }
        public int? IdDepartamento { get; set; }
        public int? IdEstado { get; set; }
        public int? IdPrioridad { get; set; }
        public string? AgrupacionPeriodo { get; set; } = "dia"; // "dia", "semana", "mes"
    }

    // SUSCRIPCION DTOs
    /// Resultado de sp_tkt_gestionar_suscripcion
    public class SuscripcionResultDTO
    {
        public int Success { get; set; }
        public string? Message { get; set; }
        public int Total { get; set; }
    }

    /// DTO para un suscriptor de ticket
    public class SuscriptorDTO
    {
        public int Id_Usuario { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public DateTime Fecha_Registro { get; set; }
    }

    // NOTIFICACION LECTURA DTOs
    /// Resumen de notificaciones no leídas
    public class NotificacionResumenDTO
    {
        public int TotalNoLeidos { get; set; }
        public int PendientesAsignados { get; set; }
        public List<NotificacionTicketDTO> UltimosNoLeidos { get; set; } = new();
    }

    /// Ticket no leído en dropdown de notificaciones
    public class NotificacionTicketDTO
    {
        public long Id_Ticket { get; set; }
        public string? Contenido { get; set; }
        public int Id_Estado { get; set; }
        public string Estado_Nombre { get; set; } = string.Empty;
        public string? Prioridad_Nombre { get; set; }
        public DateTime? Fecha_Cambio { get; set; }
        public bool Es_Asignado_A_Mi { get; set; }
    }

    // RBAC (Roles & Permisos) DTOs

    public class RolListDTO
    {
        public int IdRol { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public int TotalPermisos { get; set; }
    }

    public class PermisoListDTO
    {
        public int IdPermiso { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
    }

    public class CreateUpdateRolDTO
    {
        [Required(ErrorMessage = "El nombre del rol es requerido")]
        [StringLength(64)]
        public string Nombre { get; set; } = string.Empty;
    }

    public class CreateUpdatePermisoDTO
    {
        [Required(ErrorMessage = "El código del permiso es requerido")]
        [StringLength(64)]
        public string Codigo { get; set; } = string.Empty;
        [StringLength(200)]
        public string Descripcion { get; set; } = string.Empty;
    }

    public class AsignarPermisosRolDTO
    {
        [Required]
        public List<int> PermisoIds { get; set; } = new();
    }

    public class AsignarRolUsuarioDTO
    {
        [Required]
        public int IdRol { get; set; }
    }

    // AUDIT LOG DTOs
    /// DTO para registros de auditoría (audit_log)
    public class AuditLogDTO
    {
        public long IdAuditoria { get; set; }
        public string Tabla { get; set; } = string.Empty;
        public int? IdRegistro { get; set; }
        public string Accion { get; set; } = string.Empty;
        public int? UsuarioId { get; set; }
        public string? UsuarioNombre { get; set; }
        public string? ValoresAntiguos { get; set; }
        public string? ValoresNuevos { get; set; }
        public string? IpAddress { get; set; }
        public DateTime Fecha { get; set; }
        public string? Descripcion { get; set; }
    }

    /// Filtros para consultar audit_log
    public class AuditLogFiltroDTO
    {
        public string? Tabla { get; set; }
        public string? Accion { get; set; }
        public int? UsuarioId { get; set; }
        public string? Busqueda { get; set; }
        public DateTime? FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }
        public int Pagina { get; set; } = 1;
        public int PorPagina { get; set; } = 50;
    }

    /// Resumen de estadísticas del audit_log
    public class AuditLogStatsDTO
    {
        public long TotalEstimado { get; set; }
        public Dictionary<string, long> PorAccion { get; set; } = new();
        public Dictionary<string, long> PorTabla { get; set; } = new();
        public DateTime? PrimeraFecha { get; set; }
        public DateTime? UltimaFecha { get; set; }
    }

    /// DTO para historial de transiciones de un ticket (datos enriquecidos).
    public class TransicionHistorialDTO
    {
        public long IdTransicion { get; set; }
        public long IdTkt { get; set; }
        public int? EstadoFromId { get; set; }
        public string? EstadoFromNombre { get; set; }
        public int EstadoToId { get; set; }
        public string EstadoToNombre { get; set; } = string.Empty;
        public long? UsuarioActorId { get; set; }
        public string? UsuarioActorNombre { get; set; }
        public long? UsuarioAsignadoOldId { get; set; }
        public long? UsuarioAsignadoNewId { get; set; }
        public string? Comentario { get; set; }
        public string? Motivo { get; set; }
        public DateTime Fecha { get; set; }
    }

    // GLOBAL SEARCH DTOs
    /// Resultado individual de la búsqueda global
    public class GlobalSearchItemDTO
    {
        public string Categoria { get; set; } = string.Empty;
        public long Id { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string? Extra { get; set; }
    }

    /// Resultado agrupado de la búsqueda global
    public class GlobalSearchResultDTO
    {
        public List<GlobalSearchItemDTO> Tickets { get; set; } = new();
        public List<GlobalSearchItemDTO> Usuarios { get; set; } = new();
        public List<GlobalSearchItemDTO> Departamentos { get; set; } = new();
    }

    // TICKET STATS DTOs
    /// Estadísticas rápidas de tickets para el mini-dashboard
    public class TicketStatsDTO
    {
        public int Abiertos { get; set; }
        public int SinAsignar { get; set; }
        public int Vencidos { get; set; }
        public int TotalFiltro { get; set; }
    }

    // ALERTAS / MENCIONES DTOs
    /// Alerta de mención (@usuario)
    public class AlertaDTO
    {
        public long IdAlerta { get; set; }
        public string Tipo { get; set; } = string.Empty;
        public long? IdTicket { get; set; }
        public long? IdComentario { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public bool Leida { get; set; }
        public DateTime Fecha { get; set; }
    }

    /// DTO para respuesta de exportación
    public class ExportResultDTO
    {
        public string FileName { get; set; } = string.Empty;
        public string ContentType { get; set; } = string.Empty;
        public byte[] Data { get; set; } = Array.Empty<byte>();
    }
}
