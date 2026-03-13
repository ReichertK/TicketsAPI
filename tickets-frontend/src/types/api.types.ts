export interface LoginRequest {
  usuario: string;
  contraseña: string;
}

export interface LoginResponse {
  id_Usuario: number;
  nombre: string;
  email: string;
  token: string;
  refreshToken: string;
  rol: RolDTO;
  permisos: string[];
}

export interface RolDTO {
  id_Rol: number;
  nombre_Rol: string;
  descripcion: string;
  activo: boolean;
}

export interface UsuarioDTO {
  id_Usuario: number;
  nombre: string;
  apellido: string;
  email: string;
  id_Rol: number;
  id_Departamento?: number;
  activo: boolean;
  fecha_Registro: string;
  ultima_Sesion?: string;
  rol?: RolDTO;
  departamento?: DepartamentoDTO;
}

export interface DepartamentoDTO {
  id_Departamento: number;
  nombre: string;
  descripcion: string;
  activo: boolean;
}

export interface TicketDTO {
  id_Tkt: number;
  id_Estado?: number;
  estado?: EstadoDTO;
  id_Prioridad?: number;
  prioridad?: PrioridadDTO;
  id_Departamento?: number;
  departamento?: DepartamentoDTO;
  id_Usuario?: number;
  usuarioCreador?: UsuarioDTO;
  id_Usuario_Asignado?: number;
  usuarioAsignado?: UsuarioDTO;
  id_Motivo?: number;
  motivoNombre?: string;
  date_Creado?: string;
  date_Asignado?: string;
  date_Cierre?: string;
  contenido?: string;
  comentarios?: ComentarioDTO[];
  historial?: HistorialTicketDTO[];
}

export interface EstadoDTO {
  id_Estado: number;
  nombre_Estado: string;
  color: string;
  orden: number;
  activo: boolean;
}

export interface PrioridadDTO {
  id_Prioridad: number;
  nombre_Prioridad: string;
  valor: number;
  color: string;
  activo: boolean;
}

export interface ComentarioDTO {
  id_Comentario: number;
  id_Ticket: number;
  id_Usuario: number;
  usuario?: UsuarioDTO;
  contenido: string;
  fecha_Creacion: string;
  privado: boolean;
}

export interface HistorialTicketDTO {
  id_Historial: number;
  id_Ticket: number;
  id_Usuario: number;
  usuario?: UsuarioDTO;
  accion: string;
  campo_Modificado?: string;
  valor_Anterior?: string;
  valor_Nuevo?: string;
  fecha_Cambio: string;
}

export interface CreateUpdateTicketDTO {
  contenido: string;
  id_Prioridad: number;
  id_Departamento: number;
  id_Usuario_Asignado?: number;
  id_Motivo?: number;
}

export interface DashboardDTO {
  ticketsTotal: number;
  ticketsAbiertos: number;
  ticketsCerrados: number;
  ticketsEnProceso: number;
  ticketsAsignadosAMi: number;
  ticketsPorEstado: Record<string, number>;
  ticketsPorPrioridad: Record<string, number>;
  ticketsPorDepartamento: Record<string, number>;
  tiempoPromedioResolucion: number;
  tasaCumplimientoSLA: number;
}

export interface ApiResponse<T> {
  exitoso: boolean;
  mensaje: string;
  datos?: T;
  errores: string[];
}

export interface PaginatedResponse<T> {
  datos: T[];
  totalRegistros: number;
  totalPaginas: number;
  paginaActual: number;
  tamañoPagina: number;
  tienePaginaAnterior: boolean;
  tienePaginaSiguiente: boolean;
}

// ── DTOs de creación/actualización ───────────────────────────────

export interface CreateUpdateUsuarioDTO {
  nombre: string;
  apellido: string;
  email: string;
  usuario_Correo?: string;
  password?: string;
  id_Rol: number;
  id_Departamento?: number;
}

export interface CreateUpdateDepartamentoDTO {
  nombre: string;
  descripcion?: string;
}

// ── Motivos ──────────────────────────────────────────────────────

export interface MotivoDTO {
  id_Motivo: number;
  nombre: string;
  descripcion: string;
  categoria?: string;
  activo: boolean;
}

export interface CreateUpdateMotivoDTO {
  nombre: string;
  descripcion?: string;
  categoria?: string;
}

// ── Estados / Prioridades Admin ─────────────────────────────────

export interface CreateUpdateEstadoDTO {
  nombre: string;
  descripcion?: string;
}

export interface CreateUpdatePrioridadDTO {
  nombre: string;
  descripcion?: string;
}

// ── Transiciones de Estado ───────────────────────────────────────

export interface TransicionPermitidaDTO {
  id_Estado_Destino: number;
  nombre_Estado: string;
  color: string;
  permiso_Requerido?: string;
  requiere_Propietario: boolean;
  requiere_Aprobacion: boolean;
}

// ── Suscripciones ────────────────────────────────────────────────

export interface SuscriptorDTO {
  id_Usuario: number;
  nombre: string;
  email: string;
  fecha_Registro: string;
}

export interface SuscripcionInfoDTO {
  suscriptores: SuscriptorDTO[];
  estaSuscrito: boolean;
  total: number;
}

// ── Notificaciones ───────────────────────────────────────────────

export interface NotificacionResumenDTO {
  totalNoLeidos: number;
  pendientesAsignados: number;
  ultimosNoLeidos: NotificacionTicketDTO[];
}

export interface NotificacionTicketDTO {
  id_Ticket: number;
  contenido: string;
  id_Estado: number;
  estado_Nombre: string;
  prioridad_Nombre: string;
  fecha_Cambio: string;
  es_Asignado_A_Mi: boolean;
}

// ── RBAC: Roles y Permisos ───────────────────────────────────────

export interface RolListDTO {
  idRol: number;
  nombre: string;
  totalPermisos: number;
}

export interface PermisoListDTO {
  idPermiso: number;
  codigo: string;
  descripcion: string;
}



// ==================== AUDIT LOG DTOs ====================
export interface AuditLogDTO {
  idAuditoria: number;
  tabla: string;
  idRegistro: number | null;
  accion: string;
  usuarioId: number | null;
  usuarioNombre: string | null;
  valoresAntiguos: string | null;
  valoresNuevos: string | null;
  ipAddress: string | null;
  fecha: string;
  descripcion: string | null;
}

export interface AuditLogFiltro {
  tabla?: string;
  accion?: string;
  usuarioId?: number;
  busqueda?: string;
  fechaDesde?: string;
  fechaHasta?: string;
  pagina?: number;
  porPagina?: number;
}

export interface AuditLogStats {
  totalEstimado: number;
  porAccion: Record<string, number>;
  porTabla: Record<string, number>;
  primeraFecha: string | null;
  ultimaFecha: string | null;
}

export interface AuditLogFiltersOptions {
  tablas: string[];
  acciones: string[];
}

// ── Historial de Transiciones (enriquecido) ─────────────────────

export interface TransicionHistorialDTO {
  idTransicion: number;
  idTkt: number;
  estadoFromId: number | null;
  estadoFromNombre: string | null;
  estadoToId: number;
  estadoToNombre: string;
  usuarioActorId: number | null;
  usuarioActorNombre: string | null;
  usuarioAsignadoOldId: number | null;
  usuarioAsignadoNewId: number | null;
  comentario: string | null;
  motivo: string | null;
  fecha: string;
}

// ── Búsqueda Global (Command Palette) ───────────────────────────

export interface GlobalSearchItem {
  categoria: string;
  id: number;
  titulo: string;
  extra: string | null;
}

export interface GlobalSearchResult {
  tickets: GlobalSearchItem[];
  usuarios: GlobalSearchItem[];
  departamentos: GlobalSearchItem[];
}

// ── Estadísticas de Tickets (Mini-Dashboard) ────────────────────

export interface TicketStatsDTO {
  abiertos: number;
  sinAsignar: number;
  vencidos: number;
  totalFiltro: number;
}


