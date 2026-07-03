-- ─────────────────────────────────────────────────────────────
-- Migracion 004: asignacion por permiso TKT_ASSIGN (no por ID de rol)
-- Antes sp_asignar_ticket validaba v_rol_actor IN (10,1) y reasignacion
-- solo rol 10. Ahora usa el permiso TKT_ASSIGN, coherente con el RBAC
-- unificado (Supervisor tambien puede asignar/reasignar).
-- ─────────────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_asignar_ticket;

DELIMITER //
CREATE PROCEDURE sp_asignar_ticket(
  IN p_id_tkt BIGINT,
  IN p_id_usuario_asignado INT,
  IN p_id_usuario_actor INT,
  IN p_comentario VARCHAR(500),
  OUT p_resultado VARCHAR(255)
)
proc: BEGIN
  DECLARE v_asignado_actual INT DEFAULT NULL;
  DECLARE v_ticket_existe INT DEFAULT 0;
  DECLARE v_usuario_existe INT DEFAULT 0;
  DECLARE v_puede_asignar INT DEFAULT 0;

  SELECT COUNT(*) INTO v_ticket_existe FROM tkt WHERE Id_Tkt = p_id_tkt AND Habilitado = 1;
  IF v_ticket_existe = 0 THEN
    SET p_resultado = 'Error: Ticket no existe o esta inhabilitado';
    LEAVE proc;
  END IF;

  SELECT COUNT(*) INTO v_usuario_existe FROM usuario WHERE idUsuario = p_id_usuario_asignado AND fechaBaja IS NULL;
  IF v_usuario_existe = 0 THEN
    SET p_resultado = CONCAT('Error: Usuario ', p_id_usuario_asignado, ' no existe o esta inactivo');
    LEAVE proc;
  END IF;

  SELECT Id_Usuario_Asignado INTO v_asignado_actual FROM tkt WHERE Id_Tkt = p_id_tkt;

  -- Permiso de asignacion a otros usuarios (por codigo, no por ID de rol)
  SELECT COUNT(*) INTO v_puede_asignar
  FROM usuario_rol ur
  JOIN rol_permiso rp ON ur.idRol = rp.idRol
  JOIN permiso pm ON rp.idPermiso = pm.idPermiso
  WHERE ur.idUsuario = p_id_usuario_actor AND pm.codigo = 'TKT_ASSIGN';

  IF p_id_usuario_asignado = p_id_usuario_actor THEN
    -- Auto-asignacion: solo si el ticket esta libre
    IF v_asignado_actual IS NOT NULL AND v_asignado_actual = p_id_usuario_asignado THEN
      SET p_resultado = 'OK';
      LEAVE proc;
    END IF;
    IF v_asignado_actual IS NOT NULL AND v_asignado_actual != p_id_usuario_asignado THEN
      SET p_resultado = 'Error: No puedes auto-asignarte un ticket que ya tiene un usuario asignado';
      LEAVE proc;
    END IF;
  ELSE
    -- Asignar a otro usuario: requiere permiso TKT_ASSIGN
    IF v_puede_asignar = 0 THEN
      SET p_resultado = 'Error: No tiene el permiso TKT_ASSIGN para asignar tickets a otros usuarios';
      LEAVE proc;
    END IF;

    IF v_asignado_actual IS NOT NULL THEN
      -- Reasignacion: exige comentario justificatorio (permiso ya validado)
      IF p_comentario IS NULL OR TRIM(p_comentario) = '' THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Comentario obligatorio: debe justificar la reasignacion del ticket';
      END IF;

      INSERT INTO tkt_comentario (id_tkt, id_usuario, comentario, fecha)
      VALUES (p_id_tkt, p_id_usuario_actor, CONCAT('[Reasignacion] ', p_comentario), NOW());
    END IF;
  END IF;

  UPDATE tkt
     SET Id_Usuario_Asignado = p_id_usuario_asignado,
         Date_Asignado = NOW()
   WHERE Id_Tkt = p_id_tkt;

  SET p_resultado = 'OK';
END //
DELIMITER ;
