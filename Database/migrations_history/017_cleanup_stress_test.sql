-- ==============================================================
-- Script de Limpieza Post-Stress-Test
-- Base de datos: tickets_db
-- Fecha generación: Febrero 2026
-- 
-- PROPÓSITO: Eliminar los ~6,000 registros de prueba generados
-- durante las pruebas T1-T5 del stress test, restaurando la BD
-- a un estado limpio de producción.
--
-- TICKETS ORIGINALES PRESERVADOS: Id_Tkt 1-8 (QA previo)
-- TRANSICIONES PRESERVADAS: id_transicion 1-11 (todas son de tickets 1-7)
-- ==============================================================

-- Verificar estado ANTES de la limpieza
SELECT '=== ESTADO ANTES DE LIMPIEZA ===' as info;
SELECT 'tkt' as tabla, COUNT(*) as registros FROM tkt
UNION ALL SELECT 'tkt_transicion', COUNT(*) FROM tkt_transicion
UNION ALL SELECT 'tkt_notificacion_lectura', COUNT(*) FROM tkt_notificacion_lectura
UNION ALL SELECT 'tkt_comentario', COUNT(*) FROM tkt_comentario
UNION ALL SELECT 'tkt_suscriptor', COUNT(*) FROM tkt_suscriptor
UNION ALL SELECT 'tkt_aprobacion', COUNT(*) FROM tkt_aprobacion
UNION ALL SELECT 'audit_log', COUNT(*) FROM audit_log
UNION ALL SELECT 'audit_config', COUNT(*) FROM audit_config;

-- ==============================================================
-- PASO 1: Eliminar tickets de prueba (Id_Tkt > 8)
-- Las FKs con CASCADE eliminarán automáticamente:
--   - tkt_transicion (registros de tickets > 8)
--   - tkt_comentario (registros de tickets > 8)
--   - tkt_suscriptor (registros de tickets > 8)
--   - tkt_aprobacion (registros de tickets > 8)
-- ==============================================================
SELECT '=== ELIMINANDO TICKETS DE PRUEBA (Id_Tkt > 8) ===' as paso;

DELETE FROM tkt WHERE Id_Tkt > 8;

SELECT CONCAT('Tickets restantes: ', COUNT(*)) as resultado FROM tkt;

-- ==============================================================
-- PASO 2: Limpiar notificaciones de lectura huérfanas
-- (por si quedaron de tickets eliminados; no tiene FK CASCADE)
-- ==============================================================
SELECT '=== LIMPIANDO NOTIFICACIONES HUÉRFANAS ===' as paso;

DELETE nl FROM tkt_notificacion_lectura nl
LEFT JOIN tkt t ON nl.id_ticket = t.Id_Tkt
WHERE t.Id_Tkt IS NULL;

-- ==============================================================
-- PASO 3: Limpiar audit_log de registros de prueba
-- Se eliminan los registros que referencian tickets > 8
-- y los generados durante el stress test
-- ==============================================================
SELECT '=== LIMPIANDO AUDIT_LOG DE PRUEBA ===' as paso;

DELETE FROM audit_log 
WHERE (tabla = 'tkt' AND id_registro > 8)
   OR (tabla = 'tkt_transicion' AND id_registro NOT IN (
       SELECT id_transicion FROM tkt_transicion
   ))
   OR descripcion LIKE '%stress%'
   OR descripcion LIKE '%Stress%'
   OR descripcion LIKE '%concurrency%'
   OR descripcion LIKE '%CONCURRENCY%'
   OR descripcion LIKE '%zombie%'
   OR descripcion LIKE '%Zombie%';

SELECT CONCAT('audit_log restantes: ', COUNT(*)) as resultado FROM audit_log;

-- ==============================================================
-- PASO 4: Limpiar audit_config de registros de prueba
-- ==============================================================
SELECT '=== LIMPIANDO AUDIT_CONFIG DE PRUEBA ===' as paso;

DELETE FROM audit_config 
WHERE descripcion LIKE '%stress%'
   OR descripcion LIKE '%Stress%'
   OR descripcion LIKE '%concurrency%'
   OR descripcion LIKE '%CONCURRENCY%'
   OR descripcion LIKE '%Zombie%'
   OR descripcion LIKE '%zombie%'
   OR descripcion LIKE '%ConcurrencyTest%'
   OR descripcion LIKE '%Motivo_Stress%';

-- ==============================================================
-- PASO 5: Limpiar departamento de prueba de concurrencia
-- ==============================================================
SELECT '=== LIMPIANDO DEPARTAMENTO DE PRUEBA ===' as paso;

DELETE FROM departamento WHERE nombre LIKE 'CONCURRENCY%' OR nombre LIKE 'ConcurrencyTest%';

SELECT CONCAT('Departamentos restantes: ', COUNT(*)) as resultado FROM departamento;

-- ==============================================================
-- PASO 6: Limpiar motivo de prueba de stress
-- ==============================================================
SELECT '=== LIMPIANDO MOTIVO DE PRUEBA ===' as paso;

DELETE FROM motivo WHERE nombre LIKE 'Motivo_Stress%';

SELECT CONCAT('Motivos restantes: ', COUNT(*)) as resultado FROM motivo;

-- ==============================================================
-- PASO 7: Limpiar roles de prueba zombie
-- ==============================================================
SELECT '=== LIMPIANDO ROLES ZOMBIE ===' as paso;

DELETE FROM rol WHERE nombre LIKE 'RolZombie%';

-- ==============================================================
-- PASO 8: Resetear AUTO_INCREMENT de tkt al siguiente valor limpio
-- ==============================================================
SELECT '=== RESETEANDO AUTO_INCREMENT ===' as paso;

ALTER TABLE tkt AUTO_INCREMENT = 9;

-- ==============================================================
-- VERIFICACIÓN FINAL
-- ==============================================================
SELECT '=== ESTADO DESPUÉS DE LIMPIEZA ===' as info;
SELECT 'tkt' as tabla, COUNT(*) as registros FROM tkt
UNION ALL SELECT 'tkt_transicion', COUNT(*) FROM tkt_transicion
UNION ALL SELECT 'tkt_notificacion_lectura', COUNT(*) FROM tkt_notificacion_lectura
UNION ALL SELECT 'tkt_comentario', COUNT(*) FROM tkt_comentario
UNION ALL SELECT 'tkt_suscriptor', COUNT(*) FROM tkt_suscriptor
UNION ALL SELECT 'tkt_aprobacion', COUNT(*) FROM tkt_aprobacion
UNION ALL SELECT 'audit_log', COUNT(*) FROM audit_log
UNION ALL SELECT 'audit_config', COUNT(*) FROM audit_config;

SELECT '=== LIMPIEZA COMPLETADA ===' as resultado;
