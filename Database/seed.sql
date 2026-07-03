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
  (16, 'TKT_RBAC_ADMIN', 'Admin RBAC'),
  (17, 'TKT_ASSIGN', 'Asignar tickets a otros usuarios'),
  (18, 'VER_SOLO_DEPARTAMENTO', 'Ver solo tickets del departamento propio'),
  (19, 'TKT_VIEW_DETAIL', 'Ver detalle del ticket');

INSERT INTO `rol_permiso` (`idRol`, `idPermiso`) VALUES
  -- Administrador (10): todos
  (10,1),(10,2),(10,3),(10,4),(10,5),(10,6),(10,7),(10,8),(10,9),(10,10),(10,11),(10,12),(10,13),(10,14),(10,15),(10,16),(10,17),(10,18),(10,19),
  -- Supervisor (1): todo menos DELETE(6) y RBAC_ADMIN(16)
  (1,1),(1,2),(1,3),(1,4),(1,5),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,17),(1,18),(1,19),
  -- Agente (2): operar tickets asignados
  (2,1),(2,3),(2,5),(2,8),(2,9),(2,10),(2,12),(2,13),(2,15),(2,19),
  -- Operador (3): como Agente + cerrar(14) + ver solo depto(18)
  (3,1),(3,3),(3,5),(3,8),(3,9),(3,10),(3,12),(3,13),(3,14),(3,15),(3,18),(3,19),
  -- Aprobador (11): aprobar y ver
  (11,2),(11,7),(11,8),(11,19),
  -- Consulta (12): solo lectura y exportar
  (12,2),(12,11),(12,19);

-- ─────────────────────────────────────
-- Transition Rules (State Machine) — reglas reales de la BD
-- RBAC unificado en rol/permiso/rol_permiso/usuario_rol.
-- Las tablas tkt_rol / tkt_permiso / tkt_rol_permiso / tkt_usuario_rol fueron eliminadas.
-- ─────────────────────────────────────
INSERT INTO `tkt_transicion_regla` (`id`, `estado_from`, `estado_to`, `requiere_propietario`, `permiso_requerido`, `requiere_aprobacion`, `habilitado`, `descripcion`) VALUES
  (1, 1, 2, 0, 'TKT_START', 0, 1, 'Iniciar/tomar ticket'),
  (2, 2, 3, 1, 'TKT_CLOSE', 0, 1, 'Cierre directo desde proceso'),
  (4, 4, 3, 1, 'TKT_WAIT', 0, 1, 'Cerrar desde espera'),
  (6, 5, 3, 0, 'TKT_APPROVE', 0, 1, 'Aprobar y cerrar'),
  (7, 5, 6, 0, 'TKT_APPROVE', 0, 1, 'Aprobar como resuelto'),
  (9, 6, 7, 0, 'TKT_REOPEN', 0, 1, 'Reabrir por inconformidad'),
  (38, 2, 4, 1, 'TKT_WAIT', 0, 1, 'Pausar trabajo'),
  (39, 4, 2, 1, 'TKT_WAIT', 0, 1, 'Retomar trabajo'),
  (40, 2, 5, 1, 'TKT_REQUEST_APPROVAL', 1, 1, 'Solicitar aprobacion'),
  (41, 5, 2, 0, 'TKT_APPROVE', 0, 1, 'Aprobar y continuar'),
  (43, 2, 6, 1, 'TKT_RESOLVE', 0, 1, 'Resolver directo desde En Proceso (sin aprobacion)'),
  (44, 6, 3, 0, 'TKT_CLOSE', 0, 1, 'Confirmar cierre final'),
  (45, 3, 7, 0, 'TKT_REOPEN', 0, 1, 'Reapertura de ticket cerrado'),
  (46, 7, 2, 0, 'TKT_START', 0, 1, 'Retomar ticket reabierto'),
  (47, 1, 4, 0, 'TKT_WAIT', 0, 1, 'Poner en espera antes de iniciar');

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
