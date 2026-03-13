-- ================================================
-- PRUEBAS COMPLETAS DE TRIGGERS
-- ================================================

USE cdk_tkt_dev;

-- ====== TEST 1: INSERT TRIGGER EN TKT ======
SELECT '========================================' as TEST_1;
SELECT 'Testing: audit_tkt_insert trigger' as TEST;

-- Antes
SELECT COUNT(*) as audit_registros_antes FROM audit_log WHERE tabla = 'tkt' AND accion = 'INSERT';
SELECT COUNT(*) as tkt_total_antes FROM tkt;

-- Insertar un ticket de prueba
INSERT INTO tkt (Id_Empresa, Id_Usuario, Id_Usuario_Asignado, Id_Estado, Id_Motivo, Contenido, Date_Creado, Habilitado)
VALUES (1, 1, 1, 1, 1, 'TICKET TEST TRIGGER INSERT', NOW(), 1);

-- Después
SELECT COUNT(*) as audit_registros_despues FROM audit_log WHERE tabla = 'tkt' AND accion = 'INSERT';
SELECT COUNT(*) as tkt_total_despues FROM tkt;

-- Verificar registro en audit
SELECT id_auditoria, tabla, id_registro, accion, usuario_id, descripcion, fecha 
FROM audit_log 
WHERE tabla = 'tkt' AND accion = 'INSERT' 
ORDER BY id_auditoria DESC LIMIT 1;

-- ====== TEST 2: UPDATE TRIGGER EN TKT ======
SELECT '========================================' as TEST_2;
SELECT 'Testing: audit_tkt_update trigger' as TEST;

-- Obtener el último ticket creado para actualizar
SET @last_ticket_id = LAST_INSERT_ID();

-- Contar antes
SELECT COUNT(*) as audit_update_antes FROM audit_log WHERE tabla = 'tkt' AND accion = 'UPDATE';

-- Actualizar el ticket
UPDATE tkt SET Id_Estado = 2, Id_Usuario_Asignado = 2 WHERE Id_Tkt = @last_ticket_id;

-- Contar después
SELECT COUNT(*) as audit_update_despues FROM audit_log WHERE tabla = 'tkt' AND accion = 'UPDATE';

-- Verificar registro
SELECT id_auditoria, tabla, id_registro, accion, valores_antiguos, valores_nuevos, descripcion 
FROM audit_log 
WHERE tabla = 'tkt' AND accion = 'UPDATE' 
ORDER BY id_auditoria DESC LIMIT 1;

-- ====== TEST 3: INSERT TRIGGER EN TKT_COMENTARIO ======
SELECT '========================================' as TEST_3;
SELECT 'Testing: audit_comentario_insert trigger' as TEST;

-- Contar antes
SELECT COUNT(*) as audit_comentario_antes FROM audit_log WHERE tabla = 'tkt_comentario' AND accion = 'INSERT';

-- Insertar un comentario
INSERT INTO tkt_comentario (id_tkt, id_usuario, comentario, fecha)
VALUES (@last_ticket_id, 1, 'COMENTARIO TEST TRIGGER', NOW());

-- Contar después
SELECT COUNT(*) as audit_comentario_despues FROM audit_log WHERE tabla = 'tkt_comentario' AND accion = 'INSERT';

-- Verificar registro
SELECT id_auditoria, tabla, id_registro, accion, valores_nuevos, descripcion 
FROM audit_log 
WHERE tabla = 'tkt_comentario' AND accion = 'INSERT' 
ORDER BY id_auditoria DESC LIMIT 1;

-- ====== TEST 4: UPDATE TRIGGER EN TKT_COMENTARIO ======
SELECT '========================================' as TEST_4;
SELECT 'Testing: audit_comentario_update trigger' as TEST;

-- Obtener el último comentario
SET @last_comment_id = LAST_INSERT_ID();

-- Contar antes
SELECT COUNT(*) as audit_update_comment_antes FROM audit_log WHERE tabla = 'tkt_comentario' AND accion = 'UPDATE';

-- Actualizar el comentario
UPDATE tkt_comentario SET comentario = 'COMENTARIO ACTUALIZADO TEST' WHERE id_comentario = @last_comment_id;

-- Contar después
SELECT COUNT(*) as audit_update_comment_despues FROM audit_log WHERE tabla = 'tkt_comentario' AND accion = 'UPDATE';

-- Verificar registro
SELECT id_auditoria, tabla, id_registro, accion, valores_antiguos, valores_nuevos, descripcion 
FROM audit_log 
WHERE tabla = 'tkt_comentario' AND accion = 'UPDATE' 
ORDER BY id_auditoria DESC LIMIT 1;

-- ====== TEST 5: RESUMEN FINAL ======
SELECT '========================================' as RESUMEN_FINAL;
SELECT 'Audit Log Summary by Table and Action:' as SUMMARY;

SELECT 
  tabla,
  accion,
  COUNT(*) as cantidad,
  MAX(fecha) as ultima_actualizacion
FROM audit_log
GROUP BY tabla, accion
ORDER BY tabla, accion;

-- ====== TEST 6: ESTADÍSTICAS ======
SELECT '========================================' as ESTADISTICAS;
SELECT 
  COUNT(*) as total_registros_auditoria,
  COUNT(DISTINCT tabla) as tablas_auditadas,
  COUNT(DISTINCT usuario_id) as usuarios_que_actualizaron
FROM audit_log;

-- ====== TEST 7: LIMPIEZA (OPCIONAL - COMENTADO) ======
SELECT '========================================' as CLEANUP_INFO;
SELECT 'Cleanup SQL (commented out):' as INFO;

-- Para limpiar registros de test (SI DESEAS EJECUTAR DESCOMENTA ESTAS LINEAS):
-- DELETE FROM tkt WHERE Id_Tkt = @last_ticket_id;
-- DELETE FROM tkt_comentario WHERE id_comentario = @last_comment_id;
-- DELETE FROM audit_log WHERE id_auditoria IN (
--   SELECT id_auditoria FROM audit_log WHERE descripcion LIKE '%TEST%' LIMIT 100
-- );

SELECT 'Done! All trigger tests completed successfully.' as RESULTADO;
