-- Agregar campos de refresh token a tabla usuario
-- Compatible con MySQL 5.5.27
-- Ejecutar en: cdk_tkt_dev

-- Agregar columna refresh_token_hash si no existe
SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='usuario' AND COLUMN_NAME='refresh_token_hash' AND TABLE_SCHEMA=DATABASE()) > 0,
  'Columna ya existe: refresh_token_hash',
  'ALTER TABLE usuario ADD COLUMN refresh_token_hash VARCHAR(512) DEFAULT NULL COMMENT "Hash del refresh token para validación segura"'
) AS resultado;

-- Si la columna NO existe, ejecutar esto manualmente:
-- ALTER TABLE usuario ADD COLUMN refresh_token_hash VARCHAR(512) DEFAULT NULL COMMENT 'Hash del refresh token para validación segura';

-- Agregar columna refresh_token_expires si no existe
SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='usuario' AND COLUMN_NAME='refresh_token_expires' AND TABLE_SCHEMA=DATABASE()) > 0,
  'Columna ya existe: refresh_token_expires',
  'ALTER TABLE usuario ADD COLUMN refresh_token_expires DATETIME DEFAULT NULL COMMENT "Fecha de vencimiento del refresh token"'
) AS resultado;

-- Si la columna NO existe, ejecutar esto manualmente:
-- ALTER TABLE usuario ADD COLUMN refresh_token_expires DATETIME DEFAULT NULL COMMENT 'Fecha de vencimiento del refresh token';

-- Agregar columna last_login si no existe
SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='usuario' AND COLUMN_NAME='last_login' AND TABLE_SCHEMA=DATABASE()) > 0,
  'Columna ya existe: last_login',
  'ALTER TABLE usuario ADD COLUMN last_login DATETIME DEFAULT NULL COMMENT "Última vez que el usuario se autenticó"'
) AS resultado;

-- Si la columna NO existe, ejecutar esto manualmente:
-- ALTER TABLE usuario ADD COLUMN last_login DATETIME DEFAULT NULL COMMENT 'Última vez que el usuario se autenticó';

-- ==================== SCRIPT DIRECTO (COPIAR Y EJECUTAR) ====================
-- Si las columnas no existen, ejecute estas líneas directamente:

ALTER TABLE usuario ADD COLUMN refresh_token_hash VARCHAR(512) DEFAULT NULL;
ALTER TABLE usuario ADD COLUMN refresh_token_expires DATETIME DEFAULT NULL;
ALTER TABLE usuario ADD COLUMN last_login DATETIME DEFAULT NULL;

-- Crear índices (ignorar si ya existen)
-- ALTER TABLE usuario ADD INDEX idx_usuario_refresh_token (refresh_token_hash);
-- ALTER TABLE usuario ADD INDEX idx_usuario_last_login (last_login);

-- ==================== VERIFICACIÓN ====================
-- Verificar que las columnas fueron agregadas:
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'usuario' AND TABLE_SCHEMA = DATABASE() 
AND COLUMN_NAME IN ('refresh_token_hash', 'refresh_token_expires', 'last_login');
