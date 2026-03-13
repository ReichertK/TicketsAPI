-- ══════════════════════════════════════════════════════════════
--  TAREA 4: Corregir triggers de auditoría para evitar NULL
--  Root cause: MySQL CONCAT(..., NULL, ...) = NULL
--  Fix: Usar COALESCE + formato JSON legible
-- ══════════════════════════════════════════════════════════════

DELIMITER $$

-- ─── tkt: INSERT ────────────────────────────────────────────
DROP TRIGGER IF EXISTS audit_tkt_insert$$
CREATE TRIGGER audit_tkt_insert
AFTER INSERT ON tkt
FOR EACH ROW
BEGIN
  INSERT INTO audit_log
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_nuevos, fecha, descripcion)
  VALUES
  ('tkt', NEW.Id_Tkt, 'INSERT', NEW.Id_Usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.Id_Usuario),
   CONCAT(
     '{"estado":', COALESCE(NEW.Id_Estado, 'null'),
     ',"prioridad":', COALESCE(NEW.Id_Prioridad, 'null'),
     ',"departamento":', COALESCE(NEW.Id_Departamento, 'null'),
     ',"empresa":', COALESCE(NEW.Id_Empresa, 'null'),
     ',"asignado":', COALESCE(NEW.Id_Usuario_Asignado, 'null'),
     ',"motivo":', COALESCE(NEW.Id_Motivo, 'null'),
     '}'
   ),
   NOW(),
   CONCAT('Nuevo ticket #', NEW.Id_Tkt, ' creado por usuario ', COALESCE(NEW.Id_Usuario, 'N/A')));
END$$

-- ─── tkt: UPDATE ────────────────────────────────────────────
DROP TRIGGER IF EXISTS audit_tkt_update$$
CREATE TRIGGER audit_tkt_update
AFTER UPDATE ON tkt
FOR EACH ROW
BEGIN
  INSERT INTO audit_log
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion)
  VALUES
  ('tkt', NEW.Id_Tkt, 'UPDATE', NEW.Id_Usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.Id_Usuario),
   CONCAT(
     '{"estado":', COALESCE(OLD.Id_Estado, 'null'),
     ',"prioridad":', COALESCE(OLD.Id_Prioridad, 'null'),
     ',"departamento":', COALESCE(OLD.Id_Departamento, 'null'),
     ',"asignado":', COALESCE(OLD.Id_Usuario_Asignado, 'null'),
     ',"motivo":', COALESCE(OLD.Id_Motivo, 'null'),
     '}'
   ),
   CONCAT(
     '{"estado":', COALESCE(NEW.Id_Estado, 'null'),
     ',"prioridad":', COALESCE(NEW.Id_Prioridad, 'null'),
     ',"departamento":', COALESCE(NEW.Id_Departamento, 'null'),
     ',"asignado":', COALESCE(NEW.Id_Usuario_Asignado, 'null'),
     ',"motivo":', COALESCE(NEW.Id_Motivo, 'null'),
     '}'
   ),
   NOW(),
   CONCAT('Ticket #', NEW.Id_Tkt, ' actualizado'));
END$$

-- ─── tkt: DELETE ────────────────────────────────────────────
DROP TRIGGER IF EXISTS audit_tkt_delete$$
CREATE TRIGGER audit_tkt_delete
AFTER DELETE ON tkt
FOR EACH ROW
BEGIN
  INSERT INTO audit_log
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, fecha, descripcion)
  VALUES
  ('tkt', OLD.Id_Tkt, 'DELETE', OLD.Id_Usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = OLD.Id_Usuario),
   CONCAT(
     '{"estado":', COALESCE(OLD.Id_Estado, 'null'),
     ',"prioridad":', COALESCE(OLD.Id_Prioridad, 'null'),
     ',"departamento":', COALESCE(OLD.Id_Departamento, 'null'),
     ',"asignado":', COALESCE(OLD.Id_Usuario_Asignado, 'null'),
     ',"contenido":"', REPLACE(COALESCE(LEFT(OLD.Contenido, 200), ''), '"', '\\"'), '"',
     '}'
   ),
   NOW(),
   CONCAT('Ticket #', OLD.Id_Tkt, ' eliminado'));
END$$

-- ─── tkt_transicion: INSERT ────────────────────────────────
DROP TRIGGER IF EXISTS audit_transicion_estado$$
CREATE TRIGGER audit_transicion_estado
AFTER INSERT ON tkt_transicion
FOR EACH ROW
BEGIN
  INSERT INTO audit_log
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_nuevos, fecha, descripcion)
  VALUES
  ('tkt_transicion', NEW.id_transicion, 'INSERT', NEW.id_usuario_actor,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.id_usuario_actor),
   CONCAT(
     '{"ticket":', COALESCE(NEW.id_tkt, 'null'),
     ',"estado_from":', COALESCE(NEW.estado_from, 'null'),
     ',"estado_to":', COALESCE(NEW.estado_to, 'null'),
     ',"asignado_old":', COALESCE(NEW.id_usuario_asignado_old, 'null'),
     ',"asignado_new":', COALESCE(NEW.id_usuario_asignado_new, 'null'),
     '}'
   ),
   NOW(),
   CONCAT('Ticket #', COALESCE(NEW.id_tkt, '?'), ' transicion de estado ', COALESCE(NEW.estado_from, '?'), ' -> ', COALESCE(NEW.estado_to, '?')));
END$$

DELIMITER ;
