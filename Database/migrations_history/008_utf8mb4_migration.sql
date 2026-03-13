-- ============================================================
-- Migración 002: Internacionalización utf8mb4
-- Base de datos: tickets_db
-- Fecha: 2025-01-06
-- Descripción:
--   Convierte TODA la base de datos de latin1/utf8 a utf8mb4
--   con collation utf8mb4_unicode_ci para soporte completo
--   de emoji, kanji y caracteres multibyte (4 bytes).
--
-- Precauciones:
--   - Para tablas latin1: CONVERT TO es seguro si los datos
--     están realmente codificados en latin1. MySQL re-codifica
--     automáticamente a utf8mb4.
--   - Para tablas utf8: CONVERT TO es seguro ya que utf8mb4
--     es un superset de utf8 (3 bytes → 4 bytes).
--   - audit_log (~1.73M filas): puede tardar varios minutos.
--   - Se recomienda ejecutar fuera de horario productivo.
-- ============================================================

-- ── 1. Cambiar charset por defecto de la base de datos ──
ALTER DATABASE `tickets_db`
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

-- ── 2. Tablas prioritarias (mencionadas explícitamente) ──

-- usuario (actual: utf8_general_ci)
ALTER TABLE `usuario`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- tkt (actual: latin1_swedish_ci)
ALTER TABLE `tkt`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- departamento (actual: latin1_swedish_ci)
ALTER TABLE `departamento`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- motivo (actual: latin1_swedish_ci)
ALTER TABLE `motivo`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- audit_log (actual: utf8_general_ci) ⚠ tabla grande ~1.73M filas
ALTER TABLE `audit_log`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- audit_config (actual: utf8_general_ci)
ALTER TABLE `audit_config`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── 3. Resto de tablas latin1_swedish_ci ──

ALTER TABLE `grupo`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `notificaciones`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `permiso`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `rol`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `rol_permiso`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_aprobacion`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_comentario`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_permiso`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_rol`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_rol_permiso`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_search`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_suscriptor`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_transicion`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_transicion_regla`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `tkt_usuario_rol`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `usuario_rol`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── 4. Resto de tablas utf8_general_ci ──

ALTER TABLE `accion`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `empresa`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `error_log`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `estado`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `failed_login_attempts`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `perfil`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `perfil_accion_sistema`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `prioridad`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `sesiones`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `sistema`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `sucursal`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `usuario_empresa_sucursal_perfil_sistema`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `usuario_tipo`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ── 5. Tabla ya utf8mb4 pero con collation diferente ──

-- tkt_notificacion_lectura (actual: utf8mb4_general_ci → utf8mb4_unicode_ci)
ALTER TABLE `tkt_notificacion_lectura`
  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================
-- Verificación post-migración:
--
-- SELECT TABLE_NAME, TABLE_COLLATION
-- FROM information_schema.TABLES
-- WHERE TABLE_SCHEMA = 'tickets_db'
-- ORDER BY TABLE_NAME;
--
-- Resultado esperado: todas utf8mb4_unicode_ci
-- ============================================================
