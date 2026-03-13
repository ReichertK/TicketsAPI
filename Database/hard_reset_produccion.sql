-- =====================================================
-- HARD RESET: Limpiar datos de prueba para producción
-- Base de datos: tickets_db
-- =====================================================
-- PRECAUCIÓN: Este script elimina TODOS los tickets,
-- auditorías de transición y usuarios no-admin.
-- =====================================================

-- 1. Limpiar auditoría de transiciones
TRUNCATE TABLE audit_transicion_estado;

-- 2. Eliminar comentarios (FK a tickets)
DELETE FROM comentario;

-- 3. Eliminar historial de estados (FK a tickets)
DELETE FROM historial_estado_ticket;

-- 4. Eliminar tickets
DELETE FROM tkt;

-- 5. Eliminar usuarios no-admin (preservar admin)
DELETE FROM usuario WHERE idUsuario != 1;

-- 6. Resetear AUTO_INCREMENT
ALTER TABLE audit_transicion_estado AUTO_INCREMENT = 1;
ALTER TABLE comentario AUTO_INCREMENT = 1;
ALTER TABLE historial_estado_ticket AUTO_INCREMENT = 1;
ALTER TABLE tkt AUTO_INCREMENT = 1;
ALTER TABLE usuario AUTO_INCREMENT = 2;

-- Verificación
SELECT 'audit_transicion_estado' AS tabla, COUNT(*) AS registros FROM audit_transicion_estado
UNION ALL
SELECT 'comentario', COUNT(*) FROM comentario
UNION ALL
SELECT 'historial_estado_ticket', COUNT(*) FROM historial_estado_ticket
UNION ALL
SELECT 'tkt', COUNT(*) FROM tkt
UNION ALL
SELECT 'usuario', COUNT(*) FROM usuario;
