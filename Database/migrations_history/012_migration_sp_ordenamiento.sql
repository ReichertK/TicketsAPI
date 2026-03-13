-- ============================================================================
-- Migration: Agregar ORDER BY dinámico a SPs de listado de tickets
-- Compatible con MySQL 5.5 (sin PREPARED STATEMENTS dentro de SPs)
-- Fecha: 2026-02-27
-- ============================================================================
-- Estrategia: Usamos múltiples columnas en ORDER BY con IF() para activar
-- solo la columna deseada. El parámetro p_ordenar_por acepta:
--   'fecha'        → t.Date_Creado
--   'estado'       → e.Id_Estado  
--   'prioridad'    → CASE semántico (Crítica=1, Alta=2, Media=3, Baja=4)
--   'departamento' → d.Nombre
--   NULL/otro      → t.Date_Creado (default)
-- p_orden_desc: 1 = DESC (default), 0 = ASC
-- ============================================================================

-- ── 1. sp_tkt_mis_tickets ───────────────────────────────────────────────────

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
  IN p_ordenar_por VARCHAR(20),
  IN p_orden_desc TINYINT,
  OUT p_total INT
)
BEGIN
  DECLARE v_offset INT;
  SET v_offset = (p_page - 1) * p_page_size;

  -- Defaults
  IF p_ordenar_por IS NULL THEN SET p_ordenar_por = 'fecha'; END IF;
  IF p_orden_desc IS NULL THEN SET p_orden_desc = 1; END IF;

  -- Total
  SELECT COUNT(*) INTO p_total
  FROM tkt t
  WHERE t.Id_Usuario = p_id_usuario
    AND t.Habilitado = 1
    AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
    AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
    AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
    AND (p_busqueda IS NULL OR t.Contenido LIKE CONCAT('%', p_busqueda, '%'));

  -- Datos paginados con ORDER BY dinámico
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
  ORDER BY
    CASE WHEN p_ordenar_por = 'fecha' AND p_orden_desc = 1 THEN t.Date_Creado END DESC,
    CASE WHEN p_ordenar_por = 'fecha' AND p_orden_desc = 0 THEN t.Date_Creado END ASC,
    CASE WHEN p_ordenar_por = 'estado' AND p_orden_desc = 1 THEN e.Id_Estado END DESC,
    CASE WHEN p_ordenar_por = 'estado' AND p_orden_desc = 0 THEN e.Id_Estado END ASC,
    CASE WHEN p_ordenar_por = 'prioridad' AND p_orden_desc = 1 THEN
      CASE p.Id_Prioridad WHEN 7 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END
    END DESC,
    CASE WHEN p_ordenar_por = 'prioridad' AND p_orden_desc = 0 THEN
      CASE p.Id_Prioridad WHEN 7 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END
    END ASC,
    CASE WHEN p_ordenar_por = 'departamento' AND p_orden_desc = 1 THEN d.Nombre END DESC,
    CASE WHEN p_ordenar_por = 'departamento' AND p_orden_desc = 0 THEN d.Nombre END ASC,
    t.Id_Tkt DESC
  LIMIT v_offset, p_page_size;
END$$
DELIMITER ;


-- ── 2. sp_tkt_cola_trabajo ──────────────────────────────────────────────────

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
  IN p_ordenar_por VARCHAR(20),
  IN p_orden_desc TINYINT,
  OUT p_total INT
)
BEGIN
  DECLARE v_offset INT;
  DECLARE v_rol_actor INT DEFAULT NULL;
  DECLARE v_depto_actor INT DEFAULT NULL;

  SET v_offset = (p_page - 1) * p_page_size;

  -- Defaults
  IF p_ordenar_por IS NULL THEN SET p_ordenar_por = 'fecha'; END IF;
  IF p_orden_desc IS NULL THEN SET p_orden_desc = 1; END IF;

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
    AND (v_rol_actor IN (10, 1) OR t.Id_Departamento = v_depto_actor);

  -- Datos paginados con ORDER BY dinámico
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
  ORDER BY
    CASE WHEN p_ordenar_por = 'fecha' AND p_orden_desc = 1 THEN t.Date_Creado END DESC,
    CASE WHEN p_ordenar_por = 'fecha' AND p_orden_desc = 0 THEN t.Date_Creado END ASC,
    CASE WHEN p_ordenar_por = 'estado' AND p_orden_desc = 1 THEN e.Id_Estado END DESC,
    CASE WHEN p_ordenar_por = 'estado' AND p_orden_desc = 0 THEN e.Id_Estado END ASC,
    CASE WHEN p_ordenar_por = 'prioridad' AND p_orden_desc = 1 THEN
      CASE p.Id_Prioridad WHEN 7 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END
    END DESC,
    CASE WHEN p_ordenar_por = 'prioridad' AND p_orden_desc = 0 THEN
      CASE p.Id_Prioridad WHEN 7 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END
    END ASC,
    CASE WHEN p_ordenar_por = 'departamento' AND p_orden_desc = 1 THEN d.Nombre END DESC,
    CASE WHEN p_ordenar_por = 'departamento' AND p_orden_desc = 0 THEN d.Nombre END ASC,
    t.Id_Tkt DESC
  LIMIT v_offset, p_page_size;
END$$
DELIMITER ;


-- ── 3. sp_tkt_todos ─────────────────────────────────────────────────────────

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
  IN p_ordenar_por VARCHAR(20),
  IN p_orden_desc TINYINT,
  OUT p_total INT
)
BEGIN
  DECLARE v_offset INT;
  DECLARE v_rol_actor INT DEFAULT NULL;

  SET v_offset = (p_page - 1) * p_page_size;

  -- Defaults
  IF p_ordenar_por IS NULL THEN SET p_ordenar_por = 'fecha'; END IF;
  IF p_orden_desc IS NULL THEN SET p_orden_desc = 1; END IF;

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
    ORDER BY
      CASE WHEN p_ordenar_por = 'fecha' AND p_orden_desc = 1 THEN t.Date_Creado END DESC,
      CASE WHEN p_ordenar_por = 'fecha' AND p_orden_desc = 0 THEN t.Date_Creado END ASC,
      CASE WHEN p_ordenar_por = 'estado' AND p_orden_desc = 1 THEN e.Id_Estado END DESC,
      CASE WHEN p_ordenar_por = 'estado' AND p_orden_desc = 0 THEN e.Id_Estado END ASC,
      CASE WHEN p_ordenar_por = 'prioridad' AND p_orden_desc = 1 THEN
        CASE p.Id_Prioridad WHEN 7 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END
      END DESC,
      CASE WHEN p_ordenar_por = 'prioridad' AND p_orden_desc = 0 THEN
        CASE p.Id_Prioridad WHEN 7 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END
      END ASC,
      CASE WHEN p_ordenar_por = 'departamento' AND p_orden_desc = 1 THEN d.Nombre END DESC,
      CASE WHEN p_ordenar_por = 'departamento' AND p_orden_desc = 0 THEN d.Nombre END ASC,
      t.Id_Tkt DESC
    LIMIT v_offset, p_page_size;
  END IF;
END$$
DELIMITER ;
