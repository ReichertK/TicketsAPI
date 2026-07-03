-- =====================================================================
-- Migracion 003: Unificacion de RBAC + habilitar transicion En Proceso -> Resuelto
-- Fecha: 2026-07-02
-- Base: cdk_tkt_dev (MySQL 5.5)
--
-- CONTEXTO / PROBLEMA
--   Existian DOS sistemas RBAC paralelos con IDs de rol distintos:
--     * Legacy  : rol / permiso / rol_permiso / usuario_rol   (lo usa TODO el codigo C#
--                 -RolRepository, PermisoRepository, UsuarioRepository-, sp_tkt_permisos_por_usuario
--                 -que arma el JWT- y sp_asignar_ticket). IDs: Admin=10, Supervisor=1, Agente=2, Operador=3.
--     * Nuevo   : tkt_rol / tkt_permiso / tkt_rol_permiso / tkt_usuario_rol  (solo lo usaban
--                 sp_tkt_todos y sp_tkt_transicionar, introducidos por la migracion 002).
--   El mismo id 1 significaba Administrador en tkt_rol y Supervisor en legacy -> riesgo de drift.
--
-- SOLUCION
--   Se unifica TODO sobre las tablas legacy (rol/permiso/rol_permiso/usuario_rol), que son las
--   singulares del sistema de tickets y con las que ya trabaja la aplicacion. Se reescriben los 2 SPs
--   para leer legacy, se sanea/completa la matriz de permisos y se eliminan las tablas tkt_* RBAC.
--
--   Ademas se HABILITA la transicion directa En Proceso (2) -> Resuelto (6), que estaba
--   deshabilitada y ademas bloqueada por codigo dentro de sp_tkt_transicionar.
--
-- SEGURIDAD: backup previo en Database/backups/cdk_tkt_dev_PRE_RBAC_*.sql
-- =====================================================================

-- ---------------------------------------------------------------------
-- A) Catalogo de permisos: garantizar que exista TKT_VIEW_DETAIL (faltaba en legacy)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO permiso (codigo, descripcion) VALUES ('TKT_VIEW_DETAIL', 'Ver detalle del ticket');

-- ---------------------------------------------------------------------
-- B) Migrar (defensivo) asignaciones usuario-rol del sistema tkt_* al legacy, mapeando por NOMBRE de rol
--    (debe ejecutarse ANTES de eliminar las tablas tkt_*)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO usuario_rol (idUsuario, idRol)
SELECT tur.idUsuario, r.idRol
FROM tkt_usuario_rol tur
JOIN tkt_rol tr ON tr.id_rol = tur.id_rol
JOIN rol r ON r.nombre = tr.nombre;

-- ---------------------------------------------------------------------
-- C) Reconstruir la matriz rol_permiso de forma limpia y completa
-- ---------------------------------------------------------------------
DELETE FROM rol_permiso;

-- Administrador: TODOS los permisos
INSERT INTO rol_permiso (idRol, idPermiso)
SELECT r.idRol, p.idPermiso
FROM rol r CROSS JOIN permiso p
WHERE r.nombre = 'Administrador';

-- Supervisor: todo menos eliminar y administrar RBAC
INSERT INTO rol_permiso (idRol, idPermiso)
SELECT r.idRol, p.idPermiso
FROM rol r CROSS JOIN permiso p
WHERE r.nombre = 'Supervisor'
  AND p.codigo NOT IN ('TKT_DELETE', 'TKT_RBAC_ADMIN');

-- Agente: operar tickets asignados (sin cerrar ni ver todos)
INSERT INTO rol_permiso (idRol, idPermiso)
SELECT r.idRol, p.idPermiso
FROM rol r CROSS JOIN permiso p
WHERE r.nombre = 'Agente'
  AND p.codigo IN ('TKT_CREATE','TKT_VIEW_DETAIL','TKT_COMMENT','TKT_LIST_ASSIGNED',
                   'TKT_EDIT_ASSIGNED','TKT_START','TKT_WAIT','TKT_RESOLVE',
                   'TKT_REQUEST_APPROVAL','TKT_REOPEN');

-- Operador: como Agente + cerrar + ver los de su departamento
INSERT INTO rol_permiso (idRol, idPermiso)
SELECT r.idRol, p.idPermiso
FROM rol r CROSS JOIN permiso p
WHERE r.nombre = 'Operador'
  AND p.codigo IN ('TKT_CREATE','TKT_VIEW_DETAIL','TKT_COMMENT','TKT_LIST_ASSIGNED',
                   'TKT_EDIT_ASSIGNED','TKT_START','TKT_WAIT','TKT_CLOSE','TKT_RESOLVE',
                   'TKT_REQUEST_APPROVAL','TKT_REOPEN','VER_SOLO_DEPARTAMENTO');

-- Aprobador: aprobar / rechazar y ver
INSERT INTO rol_permiso (idRol, idPermiso)
SELECT r.idRol, p.idPermiso
FROM rol r CROSS JOIN permiso p
WHERE r.nombre = 'Aprobador'
  AND p.codigo IN ('TKT_VIEW_DETAIL','TKT_LIST_ALL','TKT_APPROVE','TKT_COMMENT');

-- Consulta: solo lectura y exportar
INSERT INTO rol_permiso (idRol, idPermiso)
SELECT r.idRol, p.idPermiso
FROM rol r CROSS JOIN permiso p
WHERE r.nombre = 'Consulta'
  AND p.codigo IN ('TKT_VIEW_DETAIL','TKT_LIST_ALL','TKT_EXPORT');

-- ---------------------------------------------------------------------
-- D) Habilitar transicion directa En Proceso (2) -> Resuelto (6)
-- ---------------------------------------------------------------------
UPDATE tkt_transicion_regla
   SET habilitado = 1
 WHERE estado_from = 2 AND estado_to = 6;

-- ---------------------------------------------------------------------
-- E) Reescribir sp_tkt_todos para leer las tablas legacy (usuario_rol/rol_permiso/permiso)
-- ---------------------------------------------------------------------
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

  SELECT COUNT(*) INTO v_es_admin
  FROM usuario_rol ur
  JOIN rol_permiso rp ON ur.idRol = rp.idRol
  JOIN permiso pm ON rp.idPermiso = pm.idPermiso
  WHERE ur.idUsuario = p_id_usuario_actor AND pm.codigo = 'TKT_RBAC_ADMIN';

  SELECT COUNT(*) INTO v_puede_ver_todos
  FROM usuario_rol ur
  JOIN rol_permiso rp ON ur.idRol = rp.idRol
  JOIN permiso pm ON rp.idPermiso = pm.idPermiso
  WHERE ur.idUsuario = p_id_usuario_actor
    AND pm.codigo IN ('TKT_LIST_ALL', 'VER_SOLO_DEPARTAMENTO', 'TKT_RBAC_ADMIN');

  IF v_puede_ver_todos = 0 THEN
    SET p_total = 0;
  ELSE

    IF v_es_admin = 0 THEN
      SELECT Id_Departamento INTO v_depto_actor
      FROM usuario WHERE idUsuario = p_id_usuario_actor;
    END IF;

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

-- ---------------------------------------------------------------------
-- F) Reescribir sp_tkt_transicionar:
--    * usa tablas legacy para los chequeos de permisos
--    * PERMITE la transicion directa En Proceso (2) -> Resuelto (6)
--      (se elimina el bloqueo que exigia aprobacion previa)
-- ---------------------------------------------------------------------
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
    DECLARE v_nombre_actor VARCHAR(100) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT nombre INTO v_nombre_actor FROM usuario WHERE idUsuario = p_id_usuario_actor LIMIT 1;

    IF p_comentario IS NULL OR TRIM(p_comentario) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El comentario es obligatorio para cambiar de estado';
    END IF;

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

    -- Un ticket debe tener asignado antes de pasar a En Proceso
    IF p_estado_to = 2
       AND v_asignado_actual IS NULL
       AND (p_id_asignado_nuevo IS NULL OR p_id_asignado_nuevo = 0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El ticket debe tener un usuario asignado antes de avanzar a En Proceso';
    END IF;

    SELECT id, requiere_propietario, permiso_requerido, requiere_aprobacion
    INTO v_regla_id, v_requiere_propietario, v_permiso_requerido, v_requiere_aprob
    FROM tkt_transicion_regla
    WHERE estado_from = v_estado_from AND estado_to = p_estado_to AND habilitado = 1
    LIMIT 1;

    IF p_es_super_admin = 0 THEN

        IF v_asignado_actual IS NOT NULL AND v_asignado_actual <> p_id_usuario_actor THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el usuario asignado al ticket puede cambiar su estado';
        END IF;

        IF v_regla_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transicion de estado no permitida';
        END IF;

        -- Chequeo de permiso via RBAC legacy (consistente con sp_tkt_permisos_por_usuario / AuthService)
        IF v_permiso_requerido IS NOT NULL THEN
            SELECT COUNT(*) INTO v_tiene_permiso
            FROM usuario_rol ur
            JOIN rol_permiso rp ON ur.idRol = rp.idRol
            JOIN permiso pm ON rp.idPermiso = pm.idPermiso
            WHERE ur.idUsuario = p_id_usuario_actor AND pm.codigo = v_permiso_requerido;
            IF v_tiene_permiso = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Permiso insuficiente para esta transicion';
            END IF;
        END IF;

        IF v_requiere_propietario = 1 THEN
            IF v_asignado_actual IS NULL OR v_asignado_actual <> p_id_usuario_actor THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el usuario asignado puede realizar esta transicion';
            END IF;
        END IF;

        -- Salir de Pendiente Aprobacion (5) exige permiso de aprobador
        IF v_estado_from = 5 THEN
            SELECT COUNT(*) INTO v_es_aprobador
            FROM usuario_rol ur
            JOIN rol_permiso rp ON ur.idRol = rp.idRol
            JOIN permiso pm ON rp.idPermiso = pm.idPermiso
            WHERE ur.idUsuario = p_id_usuario_actor AND pm.codigo = 'TKT_APPROVE';
            IF v_es_aprobador = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se requiere permiso de aprobador para esta transicion';
            END IF;
        END IF;

    END IF;

    -- Si la transicion requiere aprobacion, se registra la solicitud
    IF v_requiere_aprob = 1 THEN
        INSERT INTO tkt_aprobacion(id_tkt, solicitante_id, aprobador_id, comentario)
        VALUES(p_id_tkt, p_id_usuario_actor, COALESCE(p_id_asignado_nuevo, p_id_usuario_actor), p_comentario);
    END IF;

    IF p_id_asignado_nuevo IS NOT NULL THEN
        SET v_asignado_actual = p_id_asignado_nuevo;
    END IF;

    UPDATE tkt
    SET Id_Estado = p_estado_to,
        Id_Usuario_Asignado = v_asignado_actual,
        Date_Cambio_Estado = NOW(),
        Date_Cierre = IF(p_estado_to = 3, NOW(), Date_Cierre),
        Date_Asignado = IF(p_id_asignado_nuevo IS NOT NULL, NOW(), Date_Asignado)
    WHERE Id_Tkt = p_id_tkt;

    INSERT INTO tkt_transicion(id_tkt, estado_from, estado_to, id_usuario_actor, comentario, motivo, meta_json)
    VALUES(p_id_tkt, v_estado_from, p_estado_to, p_id_usuario_actor, p_comentario, p_motivo, p_meta_json);

    IF v_asignado_actual IS NOT NULL AND v_asignado_actual <> p_id_usuario_actor THEN
        INSERT INTO tkt_notificacion_lectura (id_ticket, id_usuario, leido, fecha_cambio)
        VALUES (p_id_tkt, v_asignado_actual, 0, NOW())
        ON DUPLICATE KEY UPDATE leido = 0, fecha_cambio = NOW();
    END IF;

    INSERT INTO tkt_notificacion_lectura (id_ticket, id_usuario, leido, fecha_cambio)
    SELECT p_id_tkt, s.id_usuario, 0, NOW()
    FROM tkt_suscriptor s
    WHERE s.id_tkt = p_id_tkt AND s.id_usuario <> p_id_usuario_actor
    ON DUPLICATE KEY UPDATE leido = 0, fecha_cambio = NOW();

    INSERT INTO tkt_notificacion_lectura (id_ticket, id_usuario, leido, fecha_cambio)
    SELECT p_id_tkt, t.Id_Usuario, 0, NOW()
    FROM tkt t
    WHERE t.Id_Tkt = p_id_tkt AND t.Id_Usuario <> p_id_usuario_actor
    ON DUPLICATE KEY UPDATE leido = 0, fecha_cambio = NOW();

    COMMIT;

    SELECT 1 AS success, 'OK' AS message, p_estado_to AS nuevo_estado, v_asignado_actual AS id_asignado;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- G) Eliminar procedimientos SEED obsoletos (sembraban las tablas tkt_* y no los llama el codigo)
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS seed_sp_tkt_permiso_crear;
DROP PROCEDURE IF EXISTS seed_sp_tkt_rol_crear;
DROP PROCEDURE IF EXISTS seed_sp_tkt_rol_permiso_asignar;
DROP PROCEDURE IF EXISTS seed_sp_tkt_seed_basico;
DROP PROCEDURE IF EXISTS seed_sp_tkt_usuario_rol_asignar;

-- ---------------------------------------------------------------------
-- H) Eliminar las tablas RBAC duplicadas tkt_* (ya migradas y sin uso)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS tkt_usuario_rol;
DROP TABLE IF EXISTS tkt_rol_permiso;
DROP TABLE IF EXISTS tkt_rol;
DROP TABLE IF EXISTS tkt_permiso;
