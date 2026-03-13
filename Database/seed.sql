-- =====================================================
-- Tickets API — Seed Data (Demo)
-- =====================================================
-- Run AFTER schema.sql
-- Creates demo users, roles, permissions and sample tickets.
-- Default admin credentials: admin / admin123
-- =====================================================

USE `tickets_db`;

SET FOREIGN_KEY_CHECKS = 0;

-- ─────────────────────────────────────
-- Catalog: Actions
-- ─────────────────────────────────────
INSERT INTO `accion` (`idAccion`, `codigo`, `nombre`, `habilitado`) VALUES
  (1, 'A', 'Alta', 0),
  (2, 'B', 'Baja', 0),
  (3, 'M', 'Modificar', 0),
  (4, 'V', 'Ver', 0);

-- ─────────────────────────────────────
-- Catalog: Ticket States
-- ─────────────────────────────────────
INSERT INTO `estado` (`Id_Estado`, `TipoEstado`) VALUES
  (1, 'Abierto'),
  (2, 'En Proceso'),
  (3, 'Cerrado'),
  (4, 'En Espera'),
  (5, 'Pendiente Aprobación'),
  (6, 'Resuelto'),
  (7, 'Reabierto');

-- ─────────────────────────────────────
-- Catalog: Priorities
-- ─────────────────────────────────────
INSERT INTO `prioridad` (`Id_Prioridad`, `NombrePrioridad`) VALUES
  (1, 'Alta'),
  (2, 'Media'),
  (3, 'Baja'),
  (7, 'Crítica');

-- ─────────────────────────────────────
-- Catalog: Groups
-- ─────────────────────────────────────
INSERT INTO `grupo` (`Id_Grupo`, `Tipo_Grupo`) VALUES
  (1, 'admin'),
  (2, 'usuario');

-- ─────────────────────────────────────
-- Catalog: User Types
-- ─────────────────────────────────────
INSERT INTO `usuario_tipo` (`usuTipoId`, `usuTipoDesc`, `usuTipoHabil`) VALUES
  ('CLI', 'Cliente/Proveedor', 0),
  ('INT', 'Interno', 0);

-- ─────────────────────────────────────
-- Demo Departments
-- ─────────────────────────────────────
INSERT INTO `departamento` (`Id_Departamento`, `Nombre`) VALUES
  (1, 'Soporte Técnico'),
  (2, 'Desarrollo de Software'),
  (3, 'Infraestructura'),
  (4, 'Recursos Humanos'),
  (5, 'Administración'),
  (6, 'Atención al Cliente'),
  (7, 'Calidad'),
  (8, 'Redes');

-- ─────────────────────────────────────
-- Demo Motives (Ticket Reasons)
-- ─────────────────────────────────────
INSERT INTO `motivo` (`Id_Motivo`, `Nombre`, `Categoria`) VALUES
  (1, 'Problema con impresora', 'Hardware'),
  (2, 'Falla de red / conectividad', 'Infraestructura'),
  (3, 'Solicitud de acceso a sistema', 'Accesos'),
  (4, 'Error en aplicación', 'Software'),
  (5, 'Problema con correo electrónico', 'Software'),
  (6, 'Solicitud de nuevo equipo', 'Hardware'),
  (7, 'Consulta general', 'Información'),
  (8, 'Incidente de seguridad', 'Seguridad');

-- ─────────────────────────────────────
-- Demo Company & Branch
-- ─────────────────────────────────────
INSERT INTO `empresa` (`idEmpresa`, `cuit`, `nombre`, `codigo`, `habilitado`) VALUES
  (1, '30000000001', 'Demo Corp S.A.', 'DMO', 0);

INSERT INTO `sucursal` (`idSucursal`, `idEmpresa`, `descripcion`, `codigo`, `domicilio`, `habilitado`) VALUES
  (1, 1, 'Casa Central', 'CC', 'Av. Principal 1234', 0),
  (2, 1, 'Sucursal Norte', 'SN', 'Calle Norte 567', 0);

-- ─────────────────────────────────────
-- Profiles
-- ─────────────────────────────────────
INSERT INTO `perfil` (`idPerfil`, `nombre`, `habilitado`) VALUES
  (1, 'Operador', 0),
  (2, 'Auditor', 0),
  (3, 'Supervisor', 0),
  (4, 'Administrador', 0);

-- ─────────────────────────────────────
-- Systems
-- ─────────────────────────────────────
INSERT INTO `sistema` (`idSistema`, `nombre`, `habilitado`) VALUES
  ('TKT_SYS', 'Sistema de Tickets', 0);

-- ─────────────────────────────────────
-- RBAC: Legacy Roles & Permissions
-- ─────────────────────────────────────
INSERT INTO `rol` (`idRol`, `nombre`) VALUES
  (1, 'Supervisor'),
  (2, 'Agente'),
  (3, 'Operador'),
  (10, 'Administrador'),
  (11, 'Aprobador'),
  (12, 'Consulta');

INSERT INTO `permiso` (`idPermiso`, `codigo`, `descripcion`) VALUES
  (1, 'TKT_CREATE', 'Crear tickets'),
  (2, 'TKT_LIST_ALL', 'Listar todos'),
  (3, 'TKT_LIST_ASSIGNED', 'Listar asignados'),
  (4, 'TKT_EDIT_ANY', 'Editar cualquiera'),
  (5, 'TKT_EDIT_ASSIGNED', 'Editar asignados'),
  (6, 'TKT_DELETE', 'Eliminar'),
  (7, 'TKT_APPROVE', 'Aprobar'),
  (8, 'TKT_COMMENT', 'Comentar'),
  (9, 'TKT_START', 'Iniciar'),
  (10, 'TKT_RESOLVE', 'Resolver'),
  (11, 'TKT_EXPORT', 'Exportar'),
  (12, 'TKT_WAIT', 'Poner en espera'),
  (13, 'TKT_REQUEST_APPROVAL', 'Solicitar aprobación'),
  (14, 'TKT_CLOSE', 'Cerrar'),
  (15, 'TKT_REOPEN', 'Reabrir'),
  (16, 'TKT_RBAC_ADMIN', 'Admin RBAC');

INSERT INTO `rol_permiso` (`idRol`, `idPermiso`) VALUES
  -- Administrador: todos
  (10,1),(10,2),(10,4),(10,5),(10,6),(10,7),(10,10),(10,11),(10,12),(10,13),(10,14),(10,15),(10,16),
  -- Supervisor
  (1,1),(1,2),(1,4),(1,7),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),
  -- Agente
  (2,3),(2,5),(2,8),(2,9),(2,10),(2,13),(2,15),
  -- Operador
  (3,1),(3,3),(3,5),(3,8),(3,9),(3,10),
  -- Aprobador
  (11,1),
  -- Consulta
  (12,1);

-- ─────────────────────────────────────
-- RBAC: Ticket Module Roles & Permissions
-- ─────────────────────────────────────
INSERT INTO `tkt_rol` (`id_rol`, `nombre`, `descripcion`, `habilitado`) VALUES
  (1, 'Administrador', 'Acceso total', 1),
  (2, 'Supervisor', 'Supervisa y edita, sin eliminar', 1),
  (3, 'Operador', 'Opera tickets asignados', 1),
  (4, 'Consulta', 'Solo lectura y exportar', 1),
  (6, 'Aprobador', 'Puede aprobar/rechazar tickets', 1);

INSERT INTO `tkt_permiso` (`id_permiso`, `codigo`, `descripcion`, `habilitado`) VALUES
  (1, 'TKT_LIST_ALL', 'Ver todos los tickets', 1),
  (2, 'TKT_LIST_ASSIGNED', 'Ver mis asignados', 1),
  (3, 'TKT_VIEW_DETAIL', 'Ver detalle', 1),
  (4, 'TKT_CREATE', 'Crear ticket', 1),
  (5, 'TKT_EDIT_ASSIGNED', 'Editar si soy asignado', 1),
  (6, 'TKT_EDIT_ANY', 'Editar cualquiera', 1),
  (7, 'TKT_ASSIGN', 'Asignar tickets', 1),
  (8, 'TKT_CLOSE', 'Cerrar tickets', 1),
  (9, 'TKT_DELETE', 'Eliminar tickets', 1),
  (10, 'TKT_EXPORT', 'Exportar CSV', 1),
  (11, 'TKT_COMMENT', 'Comentar', 1),
  (34, 'TKT_RBAC_ADMIN', 'Administrar roles y permisos', 1),
  (35, 'TKT_START', 'Iniciar trabajo', 1),
  (36, 'TKT_WAIT', 'Poner / sacar de Espera', 1),
  (37, 'TKT_REQUEST_APPROVAL', 'Solicitar aprobación', 1),
  (38, 'TKT_APPROVE', 'Aprobar / Rechazar', 1),
  (39, 'TKT_RESOLVE', 'Marcar como Resuelto', 1),
  (40, 'TKT_REOPEN', 'Reabrir ticket', 1);

INSERT INTO `tkt_rol_permiso` (`id_rol`, `id_permiso`) VALUES
  -- Administrador (all)
  (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,34),(1,35),(1,36),(1,37),(1,38),(1,39),(1,40),
  -- Supervisor
  (2,1),(2,3),(2,4),(2,6),(2,7),(2,8),(2,10),(2,11),(2,35),(2,36),(2,37),(2,38),(2,39),(2,40),
  -- Operador
  (3,2),(3,3),(3,4),(3,5),(3,8),(3,11),(3,35),(3,36),(3,37),(3,39),
  -- Consulta
  (4,1),(4,3),(4,10),
  -- Aprobador
  (6,1),(6,38);

-- ─────────────────────────────────────
-- Transition Rules (State Machine)
-- ─────────────────────────────────────
INSERT INTO `tkt_transicion_regla` (`id`, `estado_from`, `estado_to`, `requiere_propietario`, `permiso_requerido`, `requiere_aprobacion`, `habilitado`, `descripcion`) VALUES
  (1, 1, 2, 0, 'TKT_ASSIGN', 0, 1, 'Abierto → En Proceso (asignar)'),
  (2, 2, 3, 1, 'TKT_START', 0, 1, 'En Proceso → Cerrado'),
  (3, 3, 4, 1, 'TKT_WAIT', 0, 1, 'Cerrado → En Espera'),
  (4, 4, 3, 1, 'TKT_WAIT', 0, 1, 'En Espera → Cerrado'),
  (5, 3, 5, 1, 'TKT_REQUEST_APPROVAL', 1, 1, 'Cerrado → Pendiente Aprobación'),
  (6, 5, 3, 0, 'TKT_APPROVE', 0, 1, 'Pendiente Aprobación → Cerrado (rechazar)'),
  (7, 5, 6, 0, 'TKT_APPROVE', 0, 1, 'Pendiente Aprobación → Resuelto (aprobar)'),
  (8, 3, 6, 1, 'TKT_RESOLVE', 0, 1, 'Cerrado → Resuelto'),
  (9, 6, 7, 0, 'TKT_CLOSE', 0, 1, 'Resuelto → Reabierto'),
  (38, 2, 4, 1, 'TKT_WAIT', 0, 1, 'En Proceso → En Espera'),
  (39, 4, 2, 1, 'TKT_WAIT', 0, 1, 'En Espera → En Proceso'),
  (40, 2, 5, 1, 'TKT_REQUEST_APPROVAL', 1, 1, 'En Proceso → Pendiente Aprobación'),
  (41, 5, 2, 0, 'TKT_APPROVE', 0, 1, 'Pendiente Aprobación → En Proceso'),
  (44, 6, 3, 0, 'TKT_CLOSE', 0, 1, 'Resuelto → Cerrado'),
  (45, 3, 7, 0, 'TKT_REOPEN', 0, 1, 'Cerrado → Reabierto'),
  (46, 7, 2, 0, 'TKT_START', 0, 1, 'Reabierto → En Proceso');

-- ─────────────────────────────────────
-- Demo Users  (password: admin123 → MD5)
-- ─────────────────────────────────────
-- admin123 = MD5: 0192023a7bbd73250516f069df18b500
INSERT INTO `usuario` (`idUsuario`, `nombre`, `telefono`, `email`, `passwordUsuario`, `passwordUsuarioEnc`, `fechaAlta`, `tipo`) VALUES
  (1, 'Admin',       NULL, 'admin@demo.com',       'admin123', '0192023a7bbd73250516f069df18b500', CURDATE(), 'INT'),
  (2, 'Supervisor',  NULL, 'supervisor@demo.com',  'admin123', '0192023a7bbd73250516f069df18b500', CURDATE(), 'INT'),
  (3, 'Operador',    NULL, 'operador@demo.com',    'admin123', '0192023a7bbd73250516f069df18b500', CURDATE(), 'INT'),
  (4, 'Consulta',    NULL, 'consulta@demo.com',    'admin123', '0192023a7bbd73250516f069df18b500', CURDATE(), 'INT');

-- Legacy role mapping
INSERT INTO `usuario_rol` (`idUsuario`, `idRol`) VALUES
  (1, 10),  -- Admin → Administrador
  (2, 1),   -- Supervisor
  (3, 3),   -- Operador
  (4, 12);  -- Consulta

-- Ticket module role mapping
INSERT INTO `tkt_usuario_rol` (`idUsuario`, `id_rol`) VALUES
  (1, 1),  -- Admin → Administrador
  (2, 2),  -- Supervisor
  (3, 3),  -- Operador
  (4, 4);  -- Consulta

-- User-Company-Branch-Profile assignment
INSERT INTO `usuario_empresa_sucursal_perfil_sistema` (`idUsuario`, `idEmpresa`, `idSucursal`, `idSistema`, `idPerfil`, `habilitado`) VALUES
  (1, 1, 0, 'TKT_SYS', 4, 0),
  (2, 1, 0, 'TKT_SYS', 3, 0),
  (3, 1, 0, 'TKT_SYS', 1, 0),
  (4, 1, 0, 'TKT_SYS', 1, 0);

-- ─────────────────────────────────────
-- Sample Tickets
-- ─────────────────────────────────────
INSERT INTO `tkt` (`Id_Tkt`, `Id_Estado`, `Date_Creado`, `Id_Usuario`, `Id_Usuario_Asignado`, `Id_Empresa`, `Id_Perfil`, `Id_Motivo`, `Id_Sucursal`, `Habilitado`, `Id_Prioridad`, `Contenido`, `Id_Departamento`) VALUES
  (1, 1, NOW() - INTERVAL 5 DAY, 3, NULL,  1, 1, 1, 1, 1, 1, 'La impresora del 2do piso no enciende. Ya se verificó el cable de alimentación y sigue sin responder.', 1),
  (2, 2, NOW() - INTERVAL 4 DAY, 4, 3,     1, 1, 2, 1, 1, 7, 'Se cae la red WiFi en la sala de reuniones cada 15 minutos. Afecta a todos los dispositivos.', 3),
  (3, 2, NOW() - INTERVAL 3 DAY, 3, 2,     1, 1, 4, 2, 1, 2, 'La aplicación de gestión arroja error 500 al intentar generar reportes mensuales.', 2),
  (4, 4, NOW() - INTERVAL 2 DAY, 2, 3,     1, 3, 3, 1, 1, 2, 'Solicito acceso al sistema de facturación para el nuevo empleado Juan Pérez.', 5),
  (5, 6, NOW() - INTERVAL 1 DAY, 3, 2,     1, 1, 5, 1, 1, 3, 'No puedo enviar correos con adjuntos mayores a 5MB. El error dice "quota exceeded".', 1),
  (6, 3, NOW(),                   4, 3,     1, 1, 7, 2, 1, 3, '¿Cuál es el procedimiento para solicitar una laptop de reemplazo?', 6);

-- Sample transitions for tickets
INSERT INTO `tkt_transicion` (`id_tkt`, `estado_from`, `estado_to`, `id_usuario_actor`, `comentario`, `fecha`) VALUES
  (2, 1, 2, 2, 'Asignado al equipo de infraestructura', NOW() - INTERVAL 3 DAY),
  (3, 1, 2, 1, 'Revisando logs del servidor', NOW() - INTERVAL 2 DAY),
  (4, 1, 2, 1, 'Procesando solicitud de acceso', NOW() - INTERVAL 1 DAY),
  (4, 2, 4, 2, 'En espera de aprobación del jefe de área', NOW() - INTERVAL 12 HOUR),
  (5, 1, 2, 2, 'Revisando configuración de Exchange', NOW() - INTERVAL 20 HOUR),
  (5, 2, 6, 2, 'Se ajustó la cuota de correo. Verificar.', NOW() - INTERVAL 4 HOUR),
  (6, 1, 2, 3, 'Revisando inventario disponible', NOW() - INTERVAL 6 HOUR),
  (6, 2, 3, 1, 'Consulta respondida vía correo', NOW() - INTERVAL 1 HOUR);

-- Sample comments
INSERT INTO `tkt_comentario` (`id_tkt`, `id_usuario`, `comentario`, `fecha`) VALUES
  (1, 3, 'Revisé el cable y el enchufe, todo parece estar bien. Podría ser la fuente de poder.', NOW() - INTERVAL 4 DAY),
  (2, 2, 'Se reinició el access point. Monitorearemos las próximas horas.', NOW() - INTERVAL 2 DAY),
  (2, 3, 'Sigue cayéndose. Ahora cada 30 minutos.', NOW() - INTERVAL 1 DAY),
  (3, 2, 'El error viene de un timeout en la consulta a la base de datos.', NOW() - INTERVAL 1 DAY),
  (5, 2, 'Cuota aumentada de 5MB a 25MB por adjunto.', NOW() - INTERVAL 4 HOUR),
  (6, 3, 'El procedimiento está documentado en el portal de RRHH, sección "Equipamiento".', NOW() - INTERVAL 2 HOUR);

-- Search index for full-text search
INSERT INTO `tkt_search` (`Id_Tkt`, `Term`) VALUES
  (1, 'impresora'), (1, 'enciende'), (1, 'cable'),
  (2, 'wifi'), (2, 'red'), (2, 'reuniones'),
  (3, 'error'), (3, 'reportes'), (3, '500'),
  (4, 'acceso'), (4, 'facturación'),
  (5, 'correo'), (5, 'adjuntos'), (5, 'quota'),
  (6, 'laptop'), (6, 'reemplazo');

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- Seed complete.
--
-- Demo Users:
--   admin      / admin123  → Administrador (full access)
--   supervisor / admin123  → Supervisor
--   operador   / admin123  → Operador
--   consulta   / admin123  → Consulta (read-only)
-- =====================================================
