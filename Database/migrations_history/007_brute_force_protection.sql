-- ============================================================
-- Migración: Protección contra fuerza bruta
-- Fecha: 2026-02-20
-- Descripción: Añade campos intentos_fallidos y bloqueado_hasta
--              a la tabla usuario. Aprovecha la tabla existente
--              failed_login_attempts para el registro detallado.
-- ============================================================

-- 1. Añadir columnas de bloqueo al usuario
ALTER TABLE usuario
  ADD COLUMN intentos_fallidos INT NOT NULL DEFAULT 0 AFTER last_login,
  ADD COLUMN bloqueado_hasta DATETIME NULL AFTER intentos_fallidos;

-- 2. Índice en failed_login_attempts para consultas de ventana temporal
ALTER TABLE failed_login_attempts
  ADD INDEX idx_fla_usuario_fecha (usuario_nombre, fecha);

-- 3. Verificación
SELECT 'Migración completada' as status;
DESCRIBE usuario;
