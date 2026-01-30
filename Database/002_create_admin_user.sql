-- ============================================================================
-- FASE 0: Script de Setup Inicial
-- Crear usuario admin y rol de administrador
-- Compatible: MySQL 5.5.27+
-- ============================================================================

-- 1. Crear rol de Administrador si no existe
INSERT IGNORE INTO rol (idRol, nombre, descripcion, estado)
VALUES (1, 'Administrador', 'Rol de administrador del sistema', 1);

-- 2. Crear usuario admin
-- Nota: La contraseña "admin123" se almacena en SHA256
-- Para cambiarla después, usar el endpoint POST /api/v1/usuarios/1/change-password
INSERT INTO usuario 
  (nombre, email, passwordUsuario, fechaAlta, tipo, idRol)
VALUES 
  ('admin', 'admin@system.com', 'admin123', CURDATE(), 'ADM', 1)
ON DUPLICATE KEY UPDATE 
  email = 'admin@system.com', 
  fechaAlta = CURDATE();

-- 3. Obtener ID del usuario admin (para verificación)
SELECT 'Usuario Admin Creado:' as Resultado;
SELECT idUsuario, nombre, email, idRol FROM usuario WHERE nombre = 'admin';

-- 4. Crear permisos para admin (si tabla tkt_rol_permiso existe)
-- Dar acceso a todos los permisos
INSERT IGNORE INTO tkt_rol_permiso (idRol, idPermiso, estado)
SELECT 1, idPermiso, 1 FROM tkt_permiso;

-- 5. Verificar setup
SELECT 'Setup Completado:' as Status;
SELECT COUNT(*) as 'Total Usuarios' FROM usuario;
SELECT COUNT(*) as 'Total Roles' FROM rol;
SELECT COUNT(*) as 'Total Permisos Asignados' FROM tkt_rol_permiso WHERE idRol = 1;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
