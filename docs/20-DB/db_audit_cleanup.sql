-- ============================================================
-- AUDITORIA DB - IDENTIFICAR TABLAS SIN USO
-- MySQL 5.5 - Base: cdk_tkt_dev
-- Fecha: 2026-01-27
-- ============================================================

-- 1. CONTEO DE FILAS EN TABLAS CANDIDATAS
SELECT 'tkt_search' AS tbl, COUNT(*) AS rows FROM tkt_search
UNION ALL SELECT 'tkt_suscriptor', COUNT(*) FROM tkt_suscriptor
UNION ALL SELECT 'usuario_empresa_sucursal_perfil_sistema', COUNT(*) FROM usuario_empresa_sucursal_perfil_sistema
UNION ALL SELECT 'usuario_tipo', COUNT(*) FROM usuario_tipo
UNION ALL SELECT 'usuario_rol', COUNT(*) FROM usuario_rol
UNION ALL SELECT 'accion', COUNT(*) FROM accion
UNION ALL SELECT 'perfil', COUNT(*) FROM perfil
UNION ALL SELECT 'perfil_accion_sistema', COUNT(*) FROM perfil_accion_sistema
UNION ALL SELECT 'sistema', COUNT(*) FROM sistema;

-- 2. DEPENDENCIAS (FK) ENTRANTES PARA tkt_search
SELECT 'tkt_search' AS referenced_table, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'tkt_search' AND TABLE_SCHEMA = DATABASE();

-- 3. DEPENDENCIAS (FK) ENTRANTES PARA tkt_suscriptor
SELECT 'tkt_suscriptor' AS referenced_table, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'tkt_suscriptor' AND TABLE_SCHEMA = DATABASE();

-- 4. DEPENDENCIAS (FK) ENTRANTES PARA usuario_empresa_sucursal_perfil_sistema
SELECT 'usuario_empresa_sucursal_perfil_sistema' AS referenced_table, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'usuario_empresa_sucursal_perfil_sistema' AND TABLE_SCHEMA = DATABASE();

-- 5. DEPENDENCIAS (FK) ENTRANTES PARA usuario_tipo
SELECT 'usuario_tipo' AS referenced_table, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'usuario_tipo' AND TABLE_SCHEMA = DATABASE();

-- 6. DEPENDENCIAS (FK) ENTRANTES PARA usuario_rol
SELECT 'usuario_rol' AS referenced_table, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'usuario_rol' AND TABLE_SCHEMA = DATABASE();

-- 7. DEPENDENCIAS (FK) ENTRANTES PARA accion
SELECT 'accion' AS referenced_table, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'accion' AND TABLE_SCHEMA = DATABASE();

-- 8. DEPENDENCIAS (FK) ENTRANTES PARA perfil
SELECT 'perfil' AS referenced_table, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'perfil' AND TABLE_SCHEMA = DATABASE();

-- 9. DEPENDENCIAS (FK) ENTRANTES PARA perfil_accion_sistema
SELECT 'perfil_accion_sistema' AS referenced_table, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'perfil_accion_sistema' AND TABLE_SCHEMA = DATABASE();

-- 10. DEPENDENCIAS (FK) ENTRANTES PARA sistema
SELECT 'sistema' AS referenced_table, TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME = 'sistema' AND TABLE_SCHEMA = DATABASE();

-- ============================================================
-- CLEANUP (SOLO SI CONFIRMAS 0 ROWS Y 0 FKs ARRIBA)
-- COMENTADO POR SEGURIDAD - DESCOMENTAR Y EJECUTAR MANUALMENTE
-- ============================================================
/*
SET FOREIGN_KEY_CHECKS=0;

-- Tablas 100% sin uso confirmado
DROP TABLE IF EXISTS tkt_search;
DROP TABLE IF EXISTS tkt_suscriptor;
DROP TABLE IF EXISTS usuario_empresa_sucursal_perfil_sistema;
DROP TABLE IF EXISTS usuario_tipo;
DROP TABLE IF EXISTS usuario_rol;

-- Tablas legacy del modelo viejo de permisos (solo si sin FKs y sin filas)
DROP TABLE IF EXISTS accion;
DROP TABLE IF EXISTS perfil;
DROP TABLE IF EXISTS perfil_accion_sistema;
DROP TABLE IF EXISTS sistema;

SET FOREIGN_KEY_CHECKS=1;

-- Verificar que las tablas fueron eliminadas
SHOW TABLES;
*/
