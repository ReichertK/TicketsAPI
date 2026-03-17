-- ======================================================================
-- Migration 002: Fix Business Logic - Visibility & State Transitions
-- Date: 2025-01-02
-- Description:
--   1. Creates VER_SOLO_DEPARTAMENTO permission (tkt_permiso + legacy)
--   2. Assigns VER_SOLO_DEPARTAMENTO to Operador role
--   3. Rewrites sp_tkt_todos: permission-based visibility via tkt_* tables
--   4. Patches sp_tkt_transicionar:
--      a) Assignment validation before En Proceso
--      b) RBAC check migrated from legacy tables to tkt_* tables
-- ======================================================================

-- -------------------------------------------------------
-- 1. Create VER_SOLO_DEPARTAMENTO permission
-- -------------------------------------------------------
INSERT IGNORE INTO tkt_permiso (codigo, descripcion, habilitado)
VALUES ('VER_SOLO_DEPARTAMENTO', 'Ver solo tickets del departamento propio', 1);

-- Assign to Operador (tkt_rol.id_rol = 3)
INSERT IGNORE INTO tkt_rol_permiso (id_rol, id_permiso)
SELECT 3, id_permiso FROM tkt_permiso WHERE codigo = 'VER_SOLO_DEPARTAMENTO';

-- Legacy mirror for backward compatibility
INSERT IGNORE INTO permiso (codigo, descripcion)
VALUES ('VER_SOLO_DEPARTAMENTO', 'Ver solo tickets del departamento propio');

INSERT IGNORE INTO rol_permiso (idRol, idPermiso)
SELECT 3, idPermiso FROM permiso WHERE codigo = 'VER_SOLO_DEPARTAMENTO';


-- -------------------------------------------------------
-- 2. Fix sp_tkt_todos - Permission-based visibility
-- -------------------------------------------------------
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
  DECLARE v_depto_actor INT DEFAULT NULL;
  DECLARE v_es_admin INT DEFAULT 0;
  DECLARE v_puede_ver_todos INT DEFAULT 0;

  SET v_offset = (p_page - 1) * p_page_size;

  IF p_ordenar_por IS NULL THEN SET p_ordenar_por = 'fecha'; END IF;
  IF p_orden_desc IS NULL THEN SET p_orden_desc = 1; END IF;

  -- Check if user is admin (has TKT_RBAC_ADMIN) via tkt_* RBAC tables
  SELECT COUNT(*) INTO v_es_admin
  FROM tkt_usuario_rol tur
  JOIN tkt_rol_permiso trp ON tur.id_rol = trp.id_rol
  JOIN tkt_permiso tp ON trp.id_permiso = tp.id_permiso
  WHERE tur.idUsuario = p_id_usuario_actor AND tp.codigo = 'TKT_RBAC_ADMIN';

  -- Check if user can access "Todos" view (TKT_LIST_ALL or VER_SOLO_DEPARTAMENTO or TKT_RBAC_ADMIN)
  SELECT COUNT(*) INTO v_puede_ver_todos
  FROM tkt_usuario_rol tur
  JOIN tkt_rol_permiso trp ON tur.id_rol = trp.id_rol
  JOIN tkt_permiso tp ON trp.id_permiso = tp.id_permiso
  WHERE tur.idUsuario = p_id_usuario_actor
    AND tp.codigo IN ('TKT_LIST_ALL', 'VER_SOLO_DEPARTAMENTO', 'TKT_RBAC_ADMIN');

  IF v_puede_ver_todos = 0 THEN
    -- User has no visibility permission for this view
    SET p_total = 0;
  ELSE

    -- Non-admin: get user's department for filtering
    IF v_es_admin = 0 THEN
      SELECT Id_Departamento INTO v_depto_actor
      FROM usuario WHERE idUsuario = p_id_usuario_actor;
    END IF;

    -- Count
    SELECT COUNT(*) INTO p_total
    FROM tkt t
    WHERE t.Habilitado = 1
      AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
      AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
      AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
      AND (p_id_usuario_asignado IS NULL OR t.Id_Usuario_Asignado = p_id_usuario_asignado)
      AND (p_busqueda IS NULL OR t.Contenido LIKE CONCAT('%', p_busqueda, '%'))
      AND (
        v_es_admin > 0
        OR t.Id_Departamento = v_depto_actor
        OR t.Id_Usuario = p_id_usuario_actor
      );

    -- Data
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
      AND (
        v_es_admin > 0
        OR t.Id_Departamento = v_depto_actor
        OR t.Id_Usuario = p_id_usuario_actor
      )
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


-- -------------------------------------------------------
-- 3. Fix sp_tkt_transicionar - Assignment check + tkt_* RBAC
-- -------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_tkt_transicionar;

DELIMITER $$
CREATE PROCEDURE sp_tkt_transicionar(
    IN p_id_tkt BIGINT,
    IN p_estado_to INT,
    IN p_id_usuario_actor INT,
    IN p_comentario VARCHAR(1000),
    IN p_motivo VARCHAR(255),
    IN p_id_asignado_nuevo INT,
    IN p_meta_json LONGTEXT,
    IN p_es_super_admin TINYINT(1)
)
proc: BEGIN
    DECLARE v_estado_from INT DEFAULT NULL;
    DECLARE v_asignado_actual INT DEFAULT NULL;
    DECLARE v_regla_id INT DEFAULT NULL;
    DECLARE v_requiere_propietario TINYINT(1) DEFAULT 0;
    DECLARE v_permiso_requerido VARCHAR(50) DEFAULT NULL;
    DECLARE v_requiere_aprob TINYINT(1) DEFAULT 0;
    DECLARE v_tiene_permiso INT DEFAULT 0;
    DECLARE v_estado_destino_valido INT DEFAULT 0;
    DECLARE v_es_aprobador INT DEFAULT 0;
    DECLARE v_aprob_existente INT DEFAULT 0;
    DECLARE v_nombre_actor VARCHAR(100) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Actor name for audit
    SELECT nombre INTO v_nombre_actor FROM usuario WHERE idUsuario = p_id_usuario_actor LIMIT 1;

    -- Comment is mandatory
    IF p_comentario IS NULL OR TRIM(p_comentario) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El comentario es obligatorio para cambiar de estado';
    END IF;

    -- Validate destination state
    SELECT COUNT(*) INTO v_estado_destino_valido
    FROM estado WHERE Id_Estado = p_estado_to AND Habilitado = 1;
    IF v_estado_destino_valido = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado destino no valido o deshabilitado';
    END IF;

    START TRANSACTION;

    SELECT Id_Estado, Id_Usuario_Asignado
    INTO v_estado_from, v_asignado_actual
    FROM tkt WHERE Id_Tkt = p_id_tkt FOR UPDATE;

    IF v_estado_from IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ticket no encontrado';
    END IF;

    IF v_estado_from = p_estado_to THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ticket ya se encuentra en ese estado';
    END IF;

    -- ============================================================
    -- FIX: Assignment validation - ticket must be assigned before
    -- advancing to En Proceso (2). If caller provides
    -- p_id_asignado_nuevo, that counts as simultaneous assignment.
    -- ============================================================
    IF p_estado_to = 2
       AND v_asignado_actual IS NULL
       AND (p_id_asignado_nuevo IS NULL OR p_id_asignado_nuevo = 0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El ticket debe tener un usuario asignado antes de avanzar a En Proceso';
    END IF;

    -- Fetch transition rule
    SELECT id, requiere_propietario, permiso_requerido, requiere_aprobacion
    INTO v_regla_id, v_requiere_propietario, v_permiso_requerido, v_requiere_aprob
    FROM tkt_transicion_regla
    WHERE estado_from = v_estado_from AND estado_to = p_estado_to AND habilitado = 1
    LIMIT 1;

    -- Non-admin checks
    IF p_es_super_admin = 0 THEN

        -- Only the assigned user (or admin) can change state
        IF v_asignado_actual IS NOT NULL AND v_asignado_actual <> p_id_usuario_actor THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el usuario asignado al ticket puede cambiar su estado';
        END IF;

        -- Transition rule must exist
        IF v_regla_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de estado no permitida';
        END IF;

        -- ============================================================
        -- FIX: Permission check via tkt_* RBAC tables (consistent
        -- with C# AuthService which also uses tkt_* tables)
        -- ============================================================
        IF v_permiso_requerido IS NOT NULL THEN
            SELECT COUNT(*) INTO v_tiene_permiso
            FROM tkt_usuario_rol tur
            JOIN tkt_rol_permiso trp ON tur.id_rol = trp.id_rol
            JOIN tkt_permiso tp ON trp.id_permiso = tp.id_permiso
            WHERE tur.idUsuario = p_id_usuario_actor AND tp.codigo = v_permiso_requerido;
            IF v_tiene_permiso = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permiso insuficiente para esta transicion';
            END IF;
        END IF;

        -- Owner check
        IF v_requiere_propietario = 1 THEN
            IF v_asignado_actual IS NULL OR v_asignado_actual <> p_id_usuario_actor THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el usuario asignado puede realizar esta transicion';
            END IF;
        END IF;

        -- Approval authority check (from Pendiente Aprobación)
        IF v_estado_from = 5 THEN
            SELECT COUNT(*) INTO v_es_aprobador
            FROM tkt_usuario_rol tur
            JOIN tkt_rol_permiso trp ON tur.id_rol = trp.id_rol
            JOIN tkt_permiso tp ON trp.id_permiso = tp.id_permiso
            WHERE tur.idUsuario = p_id_usuario_actor AND tp.codigo = 'TKT_APPROVE';
            IF v_es_aprobador = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se requiere permiso de aprobador para esta transicion';
            END IF;
        END IF;

        -- Approval prerequisite: En Proceso -> Resuelto requires prior approval
        IF v_estado_from = 2 AND p_estado_to = 6 THEN
            SELECT COUNT(*) INTO v_aprob_existente
            FROM tkt_aprobacion
            WHERE id_tkt = p_id_tkt AND estado = 'aprobado';
            IF v_aprob_existente = 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Este ticket requiere aprobacion previa antes de ser resuelto. Use el flujo: En Proceso -> Pendiente Aprobacion -> Resuelto';
            END IF;
        END IF;

    ELSE
        -- Super admin bypass — audit if skipping approval
        IF v_estado_from = 2 AND p_estado_to = 6 THEN
            SELECT COUNT(*) INTO v_aprob_existente
            FROM tkt_aprobacion
            WHERE id_tkt = p_id_tkt AND estado = 'aprobado';
            IF v_aprob_existente = 0 THEN
                INSERT INTO audit_log (tabla, id_registro, accion, usuario_id, usuario_nombre, descripcion)
                VALUES ('tkt', p_id_tkt, 'UPDATE', p_id_usuario_actor, v_nombre_actor,
                    CONCAT('ADMIN BYPASS: Ticket ', p_id_tkt, ' resuelto sin aprobacion previa por super_admin ', v_nombre_actor));
            END IF;
        END IF;
    END IF;

    -- Create approval record if rule requires it
    IF v_requiere_aprob = 1 THEN
        INSERT INTO tkt_aprobacion(id_tkt, solicitante_id, aprobador_id, comentario)
        VALUES(p_id_tkt, p_id_usuario_actor, COALESCE(p_id_asignado_nuevo, p_id_usuario_actor), p_comentario);
    END IF;

    -- Apply new assignment if provided
    IF p_id_asignado_nuevo IS NOT NULL THEN
        SET v_asignado_actual = p_id_asignado_nuevo;
    END IF;

    -- Update ticket
    UPDATE tkt
    SET Id_Estado = p_estado_to,
        Id_Usuario_Asignado = v_asignado_actual,
        Date_Cambio_Estado = NOW(),
        Date_Cierre = IF(p_estado_to = 3, NOW(), Date_Cierre),
        Date_Asignado = IF(p_id_asignado_nuevo IS NOT NULL, NOW(), Date_Asignado)
    WHERE Id_Tkt = p_id_tkt;

    -- Record transition history
    INSERT INTO tkt_transicion(id_tkt, estado_from, estado_to, id_usuario_actor, comentario, motivo, meta_json)
    VALUES(p_id_tkt, v_estado_from, p_estado_to, p_id_usuario_actor, p_comentario, p_motivo, p_meta_json);

    -- Notify assigned user
    IF v_asignado_actual IS NOT NULL AND v_asignado_actual <> p_id_usuario_actor THEN
        INSERT INTO tkt_notificacion_lectura (id_ticket, id_usuario, leido, fecha_cambio)
        VALUES (p_id_tkt, v_asignado_actual, 0, NOW())
        ON DUPLICATE KEY UPDATE leido = 0, fecha_cambio = NOW();
    END IF;

    -- Notify subscribers
    INSERT INTO tkt_notificacion_lectura (id_ticket, id_usuario, leido, fecha_cambio)
    SELECT p_id_tkt, s.id_usuario, 0, NOW()
    FROM tkt_suscriptor s
    WHERE s.id_tkt = p_id_tkt AND s.id_usuario <> p_id_usuario_actor
    ON DUPLICATE KEY UPDATE leido = 0, fecha_cambio = NOW();

    -- Notify ticket creator
    INSERT INTO tkt_notificacion_lectura (id_ticket, id_usuario, leido, fecha_cambio)
    SELECT p_id_tkt, t.Id_Usuario, 0, NOW()
    FROM tkt t
    WHERE t.Id_Tkt = p_id_tkt AND t.Id_Usuario <> p_id_usuario_actor
    ON DUPLICATE KEY UPDATE leido = 0, fecha_cambio = NOW();

    COMMIT;

    SELECT 1 AS success, 'OK' AS message, p_estado_to AS nuevo_estado, v_asignado_actual AS id_asignado;
END$$
DELIMITER ;
