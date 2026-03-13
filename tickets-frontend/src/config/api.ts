export const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1';

export const API_ENDPOINTS = {
  // Auth
  LOGIN: '/Auth/login',
  REFRESH_TOKEN: '/Auth/refresh-token',
  LOGOUT: '/Auth/logout',
  
  // Tickets
  TICKETS: '/Tickets',
  TICKETS_SEARCH: '/Tickets/Search',
  TICKETS_BY_ID: (id: number) => `/Tickets/${id}`,
  TICKETS_ASSIGN: (id: number) => `/Tickets/${id}/asignar`,
  TICKETS_CHANGE_STATUS: (id: number) => `/Tickets/${id}/cambiar-estado`,
  TICKETS_CLOSE: (id: number) => `/Tickets/${id}/cerrar`,
  TICKETS_TRANSITIONS: (id: number) => `/Tickets/${id}/transiciones-permitidas`,
  TICKETS_HISTORIAL: (id: number) => `/Tickets/${id}/historial`,
  TICKETS_TRANSITIONS_HISTORY: (id: number) => `/Tickets/${id}/Historial-Transiciones`,
  TICKETS_COMMENTS: (id: number) => `/Tickets/${id}/Comments`,
  TICKETS_SUBSCRIBE: (id: number) => `/Tickets/${id}/suscribir`,
  TICKETS_SUBSCRIBERS: (id: number) => `/Tickets/${id}/suscriptores`,
  
  // Dashboard
  DASHBOARD: '/Reportes/Dashboard',
  REPORTES_ESTADO: '/Reportes/Estado',
  REPORTES_PRIORIDAD: '/Reportes/Prioridad',
  REPORTES_DEPARTAMENTO: '/Reportes/Departamento',
  REPORTES_TENDENCIAS: '/Reportes/Tendencias',
  
  // Usuarios
  USUARIOS: '/Usuarios',
  USUARIOS_PARA_ASIGNAR: '/Usuarios/para-asignar',
  USUARIOS_BY_ID: (id: number) => `/Usuarios/${id}`,
  USUARIOS_SEARCH: '/Usuarios/Search',
  
  // Departamentos
  DEPARTAMENTOS: '/Departamentos',
  DEPARTAMENTOS_BY_ID: (id: number) => `/Departamentos/${id}`,
  
  // Referencias
  ESTADOS: '/References/Estados',
  PRIORIDADES: '/References/Prioridades',
  MOTIVOS: '/Motivos',
  GRUPOS: '/Grupos',

  // Admin CRUD (all records, including inactive)
  ADMIN_ESTADOS: '/Estados',
  ADMIN_ESTADOS_BY_ID: (id: number) => `/Estados/${id}`,
  ADMIN_PRIORIDADES: '/Prioridades',
  ADMIN_PRIORIDADES_BY_ID: (id: number) => `/Prioridades/${id}`,

  // Notificaciones
  NOTIFICACIONES_RESUMEN: '/Notificaciones/resumen',
  NOTIFICACIONES_MARCAR_LEIDO: (id: number) => `/Notificaciones/${id}/leido`,
  NOTIFICACIONES_MARCAR_TODOS: '/Notificaciones/marcar-todos-leidos',

  // RBAC: Roles y Permisos
  ROLES: '/Roles',
  ROLES_BY_ID: (id: number) => `/Roles/${id}`,
  ROLES_PERMISOS: (id: number) => `/Roles/${id}/permisos`,
  ROLES_ASIGNAR_USUARIO: (idUsuario: number) => `/Roles/asignar-usuario/${idUsuario}`,
  PERMISOS: '/Permisos',
  PERMISOS_BY_ID: (id: number) => `/Permisos/${id}`,

  // Audit Logs
  AUDIT_LOGS: '/AuditLogs',
  AUDIT_LOGS_STATS: '/AuditLogs/stats',
  AUDIT_LOGS_FILTERS: '/AuditLogs/filters',
  AUDIT_LOGS_EXPORT: '/AuditLogs/export',

  // Búsqueda Global (Command Palette)
  GLOBAL_SEARCH: '/Search',

  // Alertas / Menciones
  ALERTAS: '/Alertas',
  ALERTAS_MARCAR_LEIDA: (id: number) => `/Alertas/${id}/leida`,
  ALERTAS_MARCAR_TODAS: '/Alertas/marcar-todas',

  // Estadísticas de Tickets (mini-dashboard)
  TICKET_STATS: '/Tickets/stats',
};
