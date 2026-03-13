-- ============================================================================
-- MIGRACIÓN: Vistas de listado y reglas de asignación
-- Fecha: 2026-02-13
-- ============================================================================

-- ── 1. SP de Asignación con reglas estrictas ────────────────────────────────

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

  -- 4. REGLA: Auto-asignación solo si el ticket NO tiene asignado
  IF p_id_usuario_asignado = p_id_usuario_actor THEN
    IF v_asignado_actual IS NOT NULL THEN
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


-- ── 2. SP: Mis Tickets (Vista Creador) ──────────────────────────────────────
-- Devuelve TODOS los tickets donde el usuario es creador (Id_Usuario = actor)
-- sin importar estado ni asignación.

DROP PROCEDURE IF EXISTS sp_tkt_mis_tickets;

DELIMITER $$
CREATE PROCEDURE sp_tkt_mis_tickets(
  IN p_id_usuario INT,
  IN p_id_estado INT,
  IN p_id_prioridad INT,
  IN p_id_departamento INT,
  IN p_busqueda VARCHAR(150),
  IN p_page INT,
  IN p_page_size INT,
  OUT p_total INT
)
BEGIN
  DECLARE v_offset INT;
  SET v_offset = (p_page - 1) * p_page_size;

  -- Total
  SELECT COUNT(*) INTO p_total
  FROM tkt t
  WHERE t.Id_Usuario = p_id_usuario
    AND t.Habilitado = 1
    AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
    AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
    AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
    AND (p_busqueda IS NULL OR t.Contenido LIKE CONCAT('%', p_busqueda, '%'));

  -- Datos paginados
  SELECT
    t.Id_Tkt, t.Id_Estado, t.Id_Prioridad, t.Id_Departamento,
    t.Id_Usuario, t.Id_Usuario_Asignado, t.Id_Empresa,
    t.Date_Creado, t.Date_Asignado, t.Date_Cierre, t.Date_Cambio_Estado,
    t.Contenido, t.Id_Motivo, t.Habilitado,
    e.TipoEstado       AS Nombre_Estado,
    p.NombrePrioridad   AS Nombre_Prioridad,
    d.Nombre            AS Nombre_Departamento,
    uc.nombre           AS Nombre_Creador,
    uc.email            AS Email_Creador,
    ua.idUsuario        AS Id_Asignado,
    ua.nombre           AS Nombre_Asignado,
    ua.email            AS Email_Asignado
  FROM tkt t
  LEFT JOIN estado e     ON t.Id_Estado = e.Id_Estado
  LEFT JOIN prioridad p  ON t.Id_Prioridad = p.Id_Prioridad
  LEFT JOIN departamento d ON t.Id_Departamento = d.Id_Departamento
  LEFT JOIN usuario uc   ON t.Id_Usuario = uc.idUsuario
  LEFT JOIN usuario ua   ON t.Id_Usuario_Asignado = ua.idUsuario
  WHERE t.Id_Usuario = p_id_usuario
    AND t.Habilitado = 1
    AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
    AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
    AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
    AND (p_busqueda IS NULL OR t.Contenido LIKE CONCAT('%', p_busqueda, '%'))
  ORDER BY t.Date_Creado DESC
  LIMIT v_offset, p_page_size;
END$$
DELIMITER ;


-- ── 3. SP: Cola de Trabajo (Vista Disponibles) ─────────────────────────────
-- Tickets sin asignar (Id_Usuario_Asignado IS NULL).
-- Admin/Supervisor: ven TODOS los nulos.
-- Operador: solo nulos de su propio departamento.

DROP PROCEDURE IF EXISTS sp_tkt_cola_trabajo;

DELIMITER $$
CREATE PROCEDURE sp_tkt_cola_trabajo(
  IN p_id_usuario_actor INT,
  IN p_id_estado INT,
  IN p_id_prioridad INT,
  IN p_id_departamento INT,
  IN p_busqueda VARCHAR(150),
  IN p_page INT,
  IN p_page_size INT,
  OUT p_total INT
)
BEGIN
  DECLARE v_offset INT;
  DECLARE v_rol_actor INT DEFAULT NULL;
  DECLARE v_depto_actor INT DEFAULT NULL;

  SET v_offset = (p_page - 1) * p_page_size;

  -- Obtener rol y departamento del actor
  SELECT idRol INTO v_rol_actor FROM usuario_rol WHERE idUsuario = p_id_usuario_actor LIMIT 1;
  SELECT Id_Departamento INTO v_depto_actor FROM usuario WHERE idUsuario = p_id_usuario_actor;

  -- Total
  SELECT COUNT(*) INTO p_total
  FROM tkt t
  WHERE t.Id_Usuario_Asignado IS NULL
    AND t.Habilitado = 1
    AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
    AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
    AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
    AND (p_busqueda IS NULL OR t.Contenido LIKE CONCAT('%', p_busqueda, '%'))
    -- Filtro de departamento para Operadores (rol 3)
    AND (v_rol_actor IN (10, 1) OR t.Id_Departamento = v_depto_actor);

  -- Datos paginados
  SELECT
    t.Id_Tkt, t.Id_Estado, t.Id_Prioridad, t.Id_Departamento,
    t.Id_Usuario, t.Id_Usuario_Asignado, t.Id_Empresa,
    t.Date_Creado, t.Date_Asignado, t.Date_Cierre, t.Date_Cambio_Estado,
    t.Contenido, t.Id_Motivo, t.Habilitado,
    e.TipoEstado       AS Nombre_Estado,
    p.NombrePrioridad   AS Nombre_Prioridad,
    d.Nombre            AS Nombre_Departamento,
    uc.nombre           AS Nombre_Creador,
    uc.email            AS Email_Creador,
    NULL                AS Id_Asignado,
    NULL                AS Nombre_Asignado,
    NULL                AS Email_Asignado
  FROM tkt t
  LEFT JOIN estado e     ON t.Id_Estado = e.Id_Estado
  LEFT JOIN prioridad p  ON t.Id_Prioridad = p.Id_Prioridad
  LEFT JOIN departamento d ON t.Id_Departamento = d.Id_Departamento
  LEFT JOIN usuario uc   ON t.Id_Usuario = uc.idUsuario
  WHERE t.Id_Usuario_Asignado IS NULL
    AND t.Habilitado = 1
    AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
    AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
    AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
    AND (p_busqueda IS NULL OR t.Contenido LIKE CONCAT('%', p_busqueda, '%'))
    AND (v_rol_actor IN (10, 1) OR t.Id_Departamento = v_depto_actor)
  ORDER BY t.Date_Creado DESC
  LIMIT v_offset, p_page_size;
END$$
DELIMITER ;


-- ── 4. SP: Todos los Tickets (Vista Global) ────────────────────────────────
-- Solo accesible para Admin(10) y Supervisor(1).
-- Si el rol no es 10 o 1, devuelve 0 registros.

DROP PROCEDURE IF EXISTS sp_tkt_todos;

DELIMITER $$
CREATE PROCEDURE sp_tkt_todos(
  IN p_id_usuario_actor INT,
  IN p_id_estado INT,
  IN p_id_prioridad INT,
  IN p_id_departamento INT,
  IN p_id_usuario_asignado INT,
  IN p_busqueda VARCHAR(150),
  IN p_page INT,
  IN p_page_size INT,
  OUT p_total INT
)
BEGIN
  DECLARE v_offset INT;
  DECLARE v_rol_actor INT DEFAULT NULL;

  SET v_offset = (p_page - 1) * p_page_size;

  SELECT idRol INTO v_rol_actor FROM usuario_rol WHERE idUsuario = p_id_usuario_actor LIMIT 1;

  -- Solo Admin y Supervisor ven todo
  IF v_rol_actor NOT IN (10, 1) THEN
    SET p_total = 0;
  ELSE
    SELECT COUNT(*) INTO p_total
    FROM tkt t
    WHERE t.Habilitado = 1
      AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
      AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
      AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
      AND (p_id_usuario_asignado IS NULL OR t.Id_Usuario_Asignado = p_id_usuario_asignado)
      AND (p_busqueda IS NULL OR t.Contenido LIKE CONCAT('%', p_busqueda, '%'));

    SELECT
      t.Id_Tkt, t.Id_Estado, t.Id_Prioridad, t.Id_Departamento,
      t.Id_Usuario, t.Id_Usuario_Asignado, t.Id_Empresa,
      t.Date_Creado, t.Date_Asignado, t.Date_Cierre, t.Date_Cambio_Estado,
      t.Contenido, t.Id_Motivo, t.Habilitado,
      e.TipoEstado       AS Nombre_Estado,
      p.NombrePrioridad   AS Nombre_Prioridad,
      d.Nombre            AS Nombre_Departamento,
      uc.nombre           AS Nombre_Creador,
      uc.email            AS Email_Creador,
      ua.idUsuario        AS Id_Asignado,
      ua.nombre           AS Nombre_Asignado,
      ua.email            AS Email_Asignado
    FROM tkt t
    LEFT JOIN estado e     ON t.Id_Estado = e.Id_Estado
    LEFT JOIN prioridad p  ON t.Id_Prioridad = p.Id_Prioridad
    LEFT JOIN departamento d ON t.Id_Departamento = d.Id_Departamento
    LEFT JOIN usuario uc   ON t.Id_Usuario = uc.idUsuario
    LEFT JOIN usuario ua   ON t.Id_Usuario_Asignado = ua.idUsuario
    WHERE t.Habilitado = 1
      AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
      AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
      AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
      AND (p_id_usuario_asignado IS NULL OR t.Id_Usuario_Asignado = p_id_usuario_asignado)
      AND (p_busqueda IS NULL OR t.Contenido LIKE CONCAT('%', p_busqueda, '%'))
    ORDER BY t.Date_Creado DESC
    LIMIT v_offset, p_page_size;
  END IF;
END$$
DELIMITER ;
