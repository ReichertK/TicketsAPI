namespace TicketsAPI.Models.Entities
{
    /// Entidad de Usuario con información de autenticación y perfil
    public class Usuario
    {
        public int Id_Usuario { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Apellido { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Usuario_Correo { get; set; } = string.Empty;
        public string Contraseña { get; set; } = string.Empty;
        public int Id_Rol { get; set; }
        public int? Id_Departamento { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime Fecha_Registro { get; set; }
        public DateTime? Ultima_Sesion { get; set; }
        public string? RefreshTokenHash { get; set; }
        public DateTime? RefreshTokenExpires { get; set; }

        // Navegación
        public virtual Rol? Rol { get; set; }
        public virtual Departamento? Departamento { get; set; }
    }

    /// Entidad de Rol con permisos granulares (RBAC)
    public class Rol
    {
        public int Id_Rol { get; set; }
        public string Nombre_Rol { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; } = true;
        public DateTime Fecha_Creacion { get; set; }

        // Navegación
        public virtual ICollection<RolPermiso>? RolPermisos { get; set; }
        public virtual ICollection<Usuario>? Usuarios { get; set; }
    }

    /// Entidad de Permiso para control granular
    public class Permiso
    {
        public int Id_Permiso { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Modulo { get; set; } = string.Empty;
        public bool Activo { get; set; } = true;

        // Navegación
        public virtual ICollection<RolPermiso>? RolPermisos { get; set; }
    }

    /// Tabla de unión: Rol-Permiso
    public class RolPermiso
    {
        public int Id_RolPermiso { get; set; }
        public int Id_Rol { get; set; }
        public int Id_Permiso { get; set; }
        public DateTime Fecha_Asignacion { get; set; }

        // Navegación
        public virtual Rol? Rol { get; set; }
        public virtual Permiso? Permiso { get; set; }
    }

    /// Entidad de Departamento
    public class Departamento
    {
        public int Id_Departamento { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; } = true;

        // Navegación
        public virtual ICollection<Usuario>? Usuarios { get; set; }
        public virtual ICollection<Ticket>? Tickets { get; set; }
    }

    /// Estados del ciclo de vida del ticket
    public class Estado
    {
        public int Id_Estado { get; set; }
        public string Nombre_Estado { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Color { get; set; } = "#6c757d"; // Color por defecto gris
        public int Orden { get; set; }
        public bool Activo { get; set; } = true;

        // Navegación
        public virtual ICollection<Ticket>? Tickets { get; set; }
    }

    /// Prioridades de los tickets
    public class Prioridad
    {
        public int Id_Prioridad { get; set; }
        public string Nombre_Prioridad { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public int Valor { get; set; } // 1: Baja, 2: Media, 3: Alta, 4: Crítica
        public string Color { get; set; } = "#6c757d";
        public bool Activo { get; set; } = true;

        // Navegación
        public virtual ICollection<Ticket>? Tickets { get; set; }
    }

    /// Entidad principal de Ticket
    public class Ticket
    {
        public long Id_Tkt { get; set; }
        public int? Id_Estado { get; set; }
        public DateTime? Date_Creado { get; set; }
        public DateTime? Date_Cierre { get; set; }
        public DateTime? Date_Asignado { get; set; }
        public DateTime? Date_Cambio_Estado { get; set; }
        public int? Id_Usuario { get; set; }
        public int? Id_Usuario_Asignado { get; set; }
        public int? Id_Empresa { get; set; }
        public int? Id_Perfil { get; set; }
        public int? Id_Motivo { get; set; }
        public int? Id_Sucursal { get; set; }
        public int? Habilitado { get; set; }
        public int? Id_Prioridad { get; set; }
        public string? Contenido { get; set; }
        public int? Id_Departamento { get; set; }

        // Navegación
        public virtual Estado? Estado { get; set; }
        public virtual Prioridad? Prioridad { get; set; }
        public virtual Departamento? Departamento { get; set; }
        public virtual Usuario? UsuarioCreador { get; set; }
        public virtual Usuario? UsuarioAsignado { get; set; }
        public virtual Usuario? UsuarioAprobador { get; set; }
        public virtual ICollection<HistorialTicket>? Historial { get; set; }
        public virtual ICollection<Comentario>? Comentarios { get; set; }
    }

    /// Historial de cambios y auditoría de ticket
    public class HistorialTicket
    {
        public int Id_Historial { get; set; }
        public int Id_Ticket { get; set; }
        public int Id_Usuario { get; set; }
        public string Accion { get; set; } = string.Empty; // "Creado", "Transicionado", "Modificado", etc
        public string? Campo_Modificado { get; set; }
        public string? Valor_Anterior { get; set; }
        public string? Valor_Nuevo { get; set; }
        public DateTime Fecha_Cambio { get; set; }
        public string? Ip_Address { get; set; }
        public string? User_Agent { get; set; }

        // Navegación
        public virtual Ticket? Ticket { get; set; }
        public virtual Usuario? Usuario { get; set; }
    }

    /// Comentarios en tickets
    public class Comentario
    {
        public int Id_Comentario { get; set; }
        public int Id_Ticket { get; set; }
        public int Id_Usuario { get; set; }
        public string Contenido { get; set; } = string.Empty;
        public DateTime Fecha_Creacion { get; set; }
        public DateTime? Fecha_Actualizacion { get; set; }
        public bool Privado { get; set; } = false;

        // Navegación
        public virtual Ticket? Ticket { get; set; }
        public virtual Usuario? Usuario { get; set; }
    }

    /// Políticas de transición de estado (Máquina de estados)
    public class PoliticaTransicion
    {
        public int Id_Politica { get; set; }
        public int Id_Estado_Origen { get; set; }
        public int Id_Estado_Destino { get; set; }
        public int Id_Rol { get; set; }
        public bool Permitida { get; set; } = true;
        public string? Permiso_Requerido { get; set; }
        public bool Requiere_Propietario { get; set; }
        public bool Requiere_Aprobacion { get; set; }
        public string? Descripcion { get; set; }
        public bool Habilitado { get; set; } = true;

        // Navegación
        public virtual Estado? EstadoOrigen { get; set; }
        public virtual Estado? EstadoDestino { get; set; }
        public virtual Rol? Rol { get; set; }
    }

    /// Motivos/Categorías para los tickets
    public class Motivo
    {
        public int Id_Motivo { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string? Categoria { get; set; }
        public bool Activo { get; set; } = true;
    }

    /// Aprobaciones de tickets
    public class Aprobacion
    {
        public int Id_Aprobacion { get; set; }
        public int Id_Tkt { get; set; }
        public int Id_Usuario_Solicitante { get; set; }
        public int Id_Usuario_Aprobador { get; set; }
        public string Estado { get; set; } = "Pendiente"; // Pendiente, Aprobada, Rechazada
        public DateTime Fecha_Solicitud { get; set; }
        public DateTime? Fecha_Respuesta { get; set; }
        public string? Comentario_Respuesta { get; set; }
    }

    /// Transiciones de estado de tickets
    public class Transicion
    {
        public int Id_Transicion { get; set; }
        public int Id_Tkt { get; set; }
        public int Id_Estado_Anterior { get; set; }
        public int Id_Estado_Nuevo { get; set; }
        public int Id_Usuario { get; set; }
        public string? Comentario { get; set; }
        public DateTime Fecha { get; set; }
    }

    /// Grupos de usuarios
    public class Grupo
    {
        public int Id_Grupo { get; set; }
        public string? Tipo_Grupo { get; set; }
    }
}
