-- Fix: sp_asignar_ticket - idempotente cuando el usuario intenta auto-asignarse
-- un ticket que ya le pertenece. Retorna 'OK' silenciosamente en lugar de error.
-- Compatible con MySQL 5.5

DROP PROCEDURE IF EXISTS sp_asignar_ticket;

DELIMITER $$
CREATE PROCEDURE sp_asignar_ticket(
  IN p_id_tkt BIGINT,
  IN p_id_usuario_asignado INT,
  IN p_id_usuario_actor INT,
  IN p_comentario VARCHAR(500),
  OUT p_resultado VARCHAR(255)
)
proc: BEGIN
  DECLARE v_asignado_actual INT DEFAULT NULL;
  DECLARE v_rol_actor INT DEFAULT NULL;
  DECLARE v_ticket_existe INT DEFAULT 0;
  DECLARE v_usuario_existe INT DEFAULT 0;

  -- 1. Validar que el ticket existe
  SELECT COUNT(*) INTO v_ticket_existe FROM tkt WHERE Id_Tkt = p_id_tkt AND Habilitado = 1;
  IF v_ticket_existe = 0 THEN
    SET p_resultado = 'Error: Ticket no existe o está inhabilitado';
    LEAVE proc;
  END IF;

  -- 2. Validar que el usuario destino existe
  SELECT COUNT(*) INTO v_usuario_existe FROM usuario WHERE idUsuario = p_id_usuario_asignado AND fechaBaja IS NULL;
  IF v_usuario_existe = 0 THEN
    SET p_resultado = CONCAT('Error: Usuario ', p_id_usuario_asignado, ' no existe o está inactivo');
    LEAVE proc;
  END IF;

  -- 3. Obtener asignado actual y rol del actor
  SELECT Id_Usuario_Asignado INTO v_asignado_actual FROM tkt WHERE Id_Tkt = p_id_tkt;
  SELECT idRol INTO v_rol_actor FROM usuario_rol WHERE idUsuario = p_id_usuario_actor LIMIT 1;

  -- 4. REGLA: Auto-asignación
  IF p_id_usuario_asignado = p_id_usuario_actor THEN
    -- Si ya está asignado al mismo usuario, es idempotente → OK silencioso
    IF v_asignado_actual IS NOT NULL AND v_asignado_actual = p_id_usuario_asignado THEN
      SET p_resultado = 'OK';
      LEAVE proc;
    END IF;
    -- Si tiene otro dueño, solo admin/supervisor pueden hacer esto
    IF v_asignado_actual IS NOT NULL AND v_asignado_actual != p_id_usuario_asignado THEN
      SET p_resultado = 'Error: No puedes auto-asignarte un ticket que ya tiene un usuario asignado';
      LEAVE proc;
    END IF;
  ELSE
    -- 5. REGLA: Asignación a terceros requiere ser Admin(10) o Supervisor(1)
    IF v_rol_actor NOT IN (10, 1) THEN
      SET p_resultado = 'Error: Solo Administradores y Supervisores pueden asignar tickets a otros usuarios';
      LEAVE proc;
    END IF;

    -- 6. REGLA: Si el ticket ya tiene dueño, solo Admin puede reasignar
    IF v_asignado_actual IS NOT NULL THEN
      IF v_rol_actor != 10 THEN
        SET p_resultado = 'Error: El ticket ya tiene un usuario asignado. Solo el Administrador puede reasignar';
        LEAVE proc;
      END IF;

      -- 7. REGLA: Admin reasignando requiere comentario obligatorio
      IF p_comentario IS NULL OR TRIM(p_comentario) = '' THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Comentario obligatorio: debe justificar la reasignación del ticket';
      END IF;

      -- Registrar comentario de reasignación
      INSERT INTO tkt_comentario (id_tkt, id_usuario, comentario, fecha)
      VALUES (p_id_tkt, p_id_usuario_actor, CONCAT('[Reasignación] ', p_comentario), NOW());
    END IF;
  END IF;

  -- 8. Ejecutar asignación
  UPDATE tkt
     SET Id_Usuario_Asignado = p_id_usuario_asignado,
         Date_Asignado = NOW()
   WHERE Id_Tkt = p_id_tkt;

  SET p_resultado = 'OK';
END$$
DELIMITER ;
