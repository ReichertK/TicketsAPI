-- ================================================
-- FIX ALL TRIGGERS - ESTRUCTURA CORRECTA
-- ================================================
-- Este script dropea y recrea todos los triggers
-- con la estructura correcta de audit_log
-- ================================================

USE cdk_tkt_dev;

-- ====== PASO 1: VALIDAR ESTRUCTURA ======
SELECT 'TABLA: audit_log' as PASO_1;
DESCRIBE audit_log;

-- ====== PASO 2: DROPEAR TRIGGERS EXISTENTES ======
SELECT '========================================' as PASO_2;
SELECT 'Dropping old triggers...' as STATUS;

DROP TRIGGER IF EXISTS audit_tkt_insert;
DROP TRIGGER IF EXISTS audit_tkt_update;
DROP TRIGGER IF EXISTS audit_comentario_insert;
DROP TRIGGER IF EXISTS audit_transicion_estado;
DROP TRIGGER IF EXISTS audit_comentario_update;
DROP TRIGGER IF EXISTS audit_comentario_delete;
DROP TRIGGER IF EXISTS audit_tkt_delete;

SELECT 'All triggers dropped successfully' as STATUS;

-- ====== PASO 3: RECREAR TRIGGERS CON ESTRUCTURA CORRECTA ======
SELECT '========================================' as PASO_3;
SELECT 'Creating corrected triggers...' as STATUS;

-- TRIGGER 1: audit_tkt_insert
DELIMITER //
CREATE TRIGGER audit_tkt_insert 
AFTER INSERT ON tkt 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_nuevos, fecha, descripcion) 
  VALUES 
  ('tkt', NEW.Id_Tkt, 'INSERT', NEW.Id_Usuario, 
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.Id_Usuario), 
   CONCAT('Ticket creado - Empresa: ', NEW.Id_Empresa, ', Asignado a: ', NEW.Id_Usuario_Asignado),
   NOW(),
   CONCAT('Nuevo ticket ', NEW.Id_Tkt, ' creado por usuario ', NEW.Id_Usuario));
END//
DELIMITER ;

-- TRIGGER 2: audit_tkt_update
DELIMITER //
CREATE TRIGGER audit_tkt_update 
AFTER UPDATE ON tkt 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion) 
  VALUES 
  ('tkt', NEW.Id_Tkt, 'UPDATE', NEW.Id_Usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.Id_Usuario),
   CONCAT('Estado: ', OLD.Id_Estado, ', Usuario Asignado: ', OLD.Id_Usuario_Asignado),
   CONCAT('Estado: ', NEW.Id_Estado, ', Usuario Asignado: ', NEW.Id_Usuario_Asignado),
   NOW(),
   CONCAT('Ticket ', NEW.Id_Tkt, ' actualizado'));
END//
DELIMITER ;

-- TRIGGER 3: audit_tkt_delete
DELIMITER //
CREATE TRIGGER audit_tkt_delete 
AFTER DELETE ON tkt 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, fecha, descripcion) 
  VALUES 
  ('tkt', OLD.Id_Tkt, 'DELETE', OLD.Id_Usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = OLD.Id_Usuario),
   CONCAT('Contenido: ', OLD.Contenido),
   NOW(),
   CONCAT('Ticket ', OLD.Id_Tkt, ' eliminado'));
END//
DELIMITER ;

-- TRIGGER 4: audit_comentario_insert
DELIMITER //
CREATE TRIGGER audit_comentario_insert 
AFTER INSERT ON tkt_comentario 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_nuevos, fecha, descripcion) 
  VALUES 
  ('tkt_comentario', NEW.id_comentario, 'INSERT', NEW.id_usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.id_usuario),
   NEW.comentario,
   NOW(),
   CONCAT('Comentario ', NEW.id_comentario, ' añadido al ticket ', NEW.id_tkt));
END//
DELIMITER ;

-- TRIGGER 5: audit_comentario_update
DELIMITER //
CREATE TRIGGER audit_comentario_update 
AFTER UPDATE ON tkt_comentario 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion) 
  VALUES 
  ('tkt_comentario', NEW.id_comentario, 'UPDATE', NEW.id_usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.id_usuario),
   OLD.comentario,
   NEW.comentario,
   NOW(),
   CONCAT('Comentario ', NEW.id_comentario, ' actualizado en ticket ', NEW.id_tkt));
END//
DELIMITER ;

-- TRIGGER 6: audit_comentario_delete
DELIMITER //
CREATE TRIGGER audit_comentario_delete 
AFTER DELETE ON tkt_comentario 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, fecha, descripcion) 
  VALUES 
  ('tkt_comentario', OLD.id_comentario, 'DELETE', OLD.id_usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = OLD.id_usuario),
   OLD.comentario,
   NOW(),
   CONCAT('Comentario ', OLD.id_comentario, ' eliminado del ticket ', OLD.id_tkt));
END//
DELIMITER ;

-- TRIGGER 7: audit_transicion_estado
DELIMITER //
CREATE TRIGGER audit_transicion_estado 
AFTER INSERT ON tkt_transicion 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_nuevos, fecha, descripcion) 
  VALUES 
  ('tkt_transicion', NEW.id_transicion, 'INSERT', NEW.id_usuario_actor,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.id_usuario_actor),
   CONCAT('Transicion de estado: ', NEW.estado_from, ' -> ', NEW.estado_to),
   NOW(),
   CONCAT('Ticket ', NEW.id_tkt, ' cambió de estado'));
END//
DELIMITER ;

SELECT 'All triggers created successfully!' as STATUS;

-- ====== PASO 4: VERIFICAR TRIGGERS CREADOS ======
SELECT '========================================' as PASO_4;
SELECT 'Verifying triggers:' as STATUS;
SHOW TRIGGERS;

-- ====== PASO 5: PRUEBAS DE VALIDACIÓN ======
SELECT '========================================' as PASO_5;
SELECT 'Testing INSERT trigger on tkt...' as TEST_1;

-- Contar registros antes
SELECT COUNT(*) as registros_antes FROM audit_log WHERE tabla = 'tkt' AND accion = 'INSERT';

-- Hacer un INSERT en tkt (transacción de prueba, sin commit)
-- INSERT INTO tkt (Id_Empresa, Id_Usuario, Id_Usuario_Asignado, Id_Estado, Id_Motivo, Contenido, Date_Creado, Habilitado)
-- VALUES (1, 1, 1, 1, 1, 'TEST TRIGGER', NOW(), 1);

-- Contar registros después
-- SELECT COUNT(*) as registros_despues FROM audit_log WHERE tabla = 'tkt' AND accion = 'INSERT';

SELECT '========================================' as PASO_6;
SELECT 'Trigger fix complete!' as STATUS;
SELECT 'All triggers are now correctly configured with audit_log structure' as RESULTADO;
