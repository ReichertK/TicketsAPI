namespace TicketsAPI.Models.Entities
{
    /// <summary>
    /// Entidad de Usuario con información de autenticación y perfil
    /// </summary>
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

        // Navegación
        public virtual Rol? Rol { get; set; }
        public virtual Departamento? Departamento { get; set; }
    }

    /// <summary>
    /// Entidad de Rol con permisos granulares (RBAC)
    /// </summary>
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

    /// <summary>
    /// Entidad de Permiso para control granular
    /// </summary>
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

    /// <summary>
    /// Tabla de unión: Rol-Permiso
    /// </summary>
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

    /// <summary>
    /// Entidad de Departamento
    /// </summary>
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

    /// <summary>
    /// Estados del ciclo de vida del ticket
    /// </summary>
    public class Estado
    {
        public int Id_Estado { get; set; }
        public string Nombre_Estado { get; set; } = string.Empty;
        public string Color { get; set; } = "#6c757d"; // Color por defecto gris
        public int Orden { get; set; }
        public bool Activo { get; set; } = true;

        // Navegación
        public virtual ICollection<Ticket>? Tickets { get; set; }
    }

    /// <summary>
    /// Prioridades de los tickets
    /// </summary>
    public class Prioridad
    {
        public int Id_Prioridad { get; set; }
        public string Nombre_Prioridad { get; set; } = string.Empty;
        public int Valor { get; set; } // 1: Baja, 2: Media, 3: Alta, 4: Crítica
        public string Color { get; set; } = "#6c757d";
        public bool Activo { get; set; } = true;

        // Navegación
        public virtual ICollection<Ticket>? Tickets { get; set; }
    }

    /// <summary>
    /// Entidad principal de Ticket
    /// </summary>
    public class Ticket
    {
        public int Id_Ticket { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public int Id_Estado { get; set; }
        public int Id_Prioridad { get; set; }
        public int Id_Departamento { get; set; }
        public int Id_Usuario_Creador { get; set; }
        public int? Id_Usuario_Asignado { get; set; }
        public int? Id_Usuario_Aprobador { get; set; }
        public DateTime Fecha_Creacion { get; set; }
        public DateTime? Fecha_Asignacion { get; set; }
        public DateTime? Fecha_Cierre { get; set; }
        public DateTime Fecha_Actualizacion { get; set; }
        public string? Notas { get; set; }
        public int? Dias_Para_Resolucion { get; set; }

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

    /// <summary>
    /// Historial de cambios y auditoría de ticket
    /// </summary>
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

    /// <summary>
    /// Comentarios en tickets
    /// </summary>
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

    /// <summary>
    /// Políticas de transición de estado (Máquina de estados)
    /// </summary>
    public class PoliticaTransicion
    {
        public int Id_Politica { get; set; }
        public int Id_Estado_Origen { get; set; }
        public int Id_Estado_Destino { get; set; }
        public int Id_Rol { get; set; }
        public bool Permitida { get; set; } = true;

        // Navegación
        public virtual Estado? EstadoOrigen { get; set; }
        public virtual Estado? EstadoDestino { get; set; }
        public virtual Rol? Rol { get; set; }
    }
}
