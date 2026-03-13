-- ============================================================================
-- Migración: 4 Módulos Nuevos
-- Fecha: 2026-02-27
-- Compatible: MySQL 5.5
-- ============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. SP: sp_global_search  (Búsqueda Global con RBAC)
-- ─────────────────────────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS sp_global_search;
DELIMITER $$
CREATE PROCEDURE sp_global_search(
    IN p_termino        VARCHAR(100),
    IN p_id_usuario     BIGINT,
    IN p_es_admin       TINYINT,      -- 1 = Admin/Supervisor, 0 = usuario común
    IN p_limite         INT
)
BEGIN
    DECLARE v_depto_usuario INT DEFAULT NULL;
    DECLARE v_term VARCHAR(102);

    IF p_limite IS NULL OR p_limite < 1 THEN
        SET p_limite = 10;
    END IF;

    SET v_term = CONCAT('%', IFNULL(p_termino, ''), '%');

    -- Obtener departamento del usuario (para filtro RBAC)
    IF p_es_admin = 0 THEN
        SELECT Id_Departamento INTO v_depto_usuario
        FROM usuario WHERE idUsuario = p_id_usuario LIMIT 1;
    END IF;

    -- ── Tickets ──
    -- Admin: ve todos. Usuario común: solo su depto + tickets activos (Habilitado=1, no cerrados Id_Estado<>3)
    SELECT
        'ticket' AS categoria,
        t.Id_Tkt AS id,
        CONCAT('#', t.Id_Tkt, ' – ', LEFT(t.Contenido, 80)) AS titulo,
        CONCAT('/tickets/', t.Id_Tkt) AS url,
        e.TipoEstado AS extra
    FROM tkt t
    LEFT JOIN estado e ON e.Id_Estado = t.Id_Estado
    WHERE
        (t.Id_Tkt = CAST(REPLACE(p_termino, '#', '') AS SIGNED)
         OR t.Contenido LIKE v_term)
        AND (p_es_admin = 1
             OR (t.Habilitado = 1
                 AND t.Id_Estado <> 3
                 AND (t.Id_Departamento = v_depto_usuario
                      OR t.Id_Usuario = p_id_usuario
                      OR t.Id_Usuario_Asignado = p_id_usuario)))
    ORDER BY t.Date_Creado DESC
    LIMIT p_limite;

    -- ── Usuarios ──
    SELECT
        'usuario' AS categoria,
        u.idUsuario AS id,
        u.nombre AS titulo,
        CONCAT('/usuarios') AS url,
        IFNULL(u.email, '') AS extra
    FROM usuario u
    WHERE
        u.fechaBaja IS NULL
        AND (u.nombre LIKE v_term OR u.email LIKE v_term)
    ORDER BY u.nombre ASC
    LIMIT p_limite;

    -- ── Departamentos ──
    SELECT
        'departamento' AS categoria,
        d.Id_Departamento AS id,
        d.Nombre AS titulo,
        CONCAT('/departamentos') AS url,
        '' AS extra
    FROM departamento d
    WHERE
        d.Habilitado = 1
        AND d.Nombre LIKE v_term
    ORDER BY d.Nombre ASC
    LIMIT p_limite;
END$$
DELIMITER ;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. SP: sp_ticket_stats  (Mini-Dashboard de Estadísticas)
-- ─────────────────────────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS sp_ticket_stats;
DELIMITER $$
CREATE PROCEDURE sp_ticket_stats(
    IN p_id_usuario      BIGINT,
    IN p_es_admin        TINYINT,
    IN p_id_estado       INT,
    IN p_id_prioridad    INT,
    IN p_id_departamento INT,
    IN p_busqueda        VARCHAR(200)
)
BEGIN
    DECLARE v_depto_usuario INT DEFAULT NULL;
    DECLARE v_term VARCHAR(202) DEFAULT NULL;

    IF p_es_admin = 0 THEN
        SELECT Id_Departamento INTO v_depto_usuario
        FROM usuario WHERE idUsuario = p_id_usuario LIMIT 1;
    END IF;

    IF p_busqueda IS NOT NULL AND p_busqueda <> '' THEN
        SET v_term = CONCAT('%', p_busqueda, '%');
    END IF;

    -- Conteo de Abiertos (Id_Estado = 1)
    SELECT
        SUM(CASE WHEN t.Id_Estado = 1 THEN 1 ELSE 0 END) AS abiertos,
        SUM(CASE WHEN t.Id_Usuario_Asignado IS NULL AND t.Id_Estado NOT IN (3, 6) THEN 1 ELSE 0 END) AS sin_asignar,
        SUM(CASE WHEN t.Id_Estado NOT IN (3, 6) AND t.Date_Creado < DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 ELSE 0 END) AS vencidos,
        COUNT(*) AS total_filtro
    FROM tkt t
    WHERE t.Habilitado = 1
      AND (p_es_admin = 1
           OR t.Id_Departamento = v_depto_usuario
           OR t.Id_Usuario = p_id_usuario
           OR t.Id_Usuario_Asignado = p_id_usuario)
      AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
      AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
      AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
      AND (v_term IS NULL OR t.Contenido LIKE v_term);
END$$
DELIMITER ;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Tabla: notificacion_alerta (persistencia de menciones @usuario)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notificacion_alerta (
    id_alerta       BIGINT       NOT NULL AUTO_INCREMENT,
    id_usuario      BIGINT       NOT NULL COMMENT 'Usuario destinatario',
    tipo            VARCHAR(30)  NOT NULL DEFAULT 'mencion' COMMENT 'mencion, asignacion, etc.',
    id_ticket       BIGINT       NULL,
    id_comentario   BIGINT       NULL,
    mensaje         VARCHAR(500) NOT NULL,
    leida           TINYINT(1)   NOT NULL DEFAULT 0,
    fecha           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_alerta),
    KEY idx_alerta_usuario_leida (id_usuario, leida, fecha),
    KEY idx_alerta_ticket (id_ticket)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. SP: sp_crear_alerta_mencion (Insertar alertas de mención)
-- ─────────────────────────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS sp_crear_alerta_mencion;
DELIMITER $$
CREATE PROCEDURE sp_crear_alerta_mencion(
    IN p_id_usuario_destino BIGINT,
    IN p_id_ticket          BIGINT,
    IN p_id_comentario      BIGINT,
    IN p_mensaje            VARCHAR(500),
    OUT p_id_alerta         BIGINT
)
BEGIN
    INSERT INTO notificacion_alerta (id_usuario, tipo, id_ticket, id_comentario, mensaje)
    VALUES (p_id_usuario_destino, 'mencion', p_id_ticket, p_id_comentario, p_mensaje);
    SET p_id_alerta = LAST_INSERT_ID();
END$$
DELIMITER ;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. SP: sp_alertas_no_leidas (Contar y listar alertas no leídas)
-- ─────────────────────────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS sp_alertas_no_leidas;
DELIMITER $$
CREATE PROCEDURE sp_alertas_no_leidas(
    IN p_id_usuario BIGINT,
    IN p_limite     INT
)
BEGIN
    IF p_limite IS NULL OR p_limite < 1 THEN
        SET p_limite = 20;
    END IF;

    SELECT
        a.id_alerta   AS IdAlerta,
        a.tipo        AS Tipo,
        a.id_ticket   AS IdTicket,
        a.id_comentario AS IdComentario,
        a.mensaje     AS Mensaje,
        a.leida       AS Leida,
        a.fecha       AS Fecha
    FROM notificacion_alerta a
    WHERE a.id_usuario = p_id_usuario
      AND a.leida = 0
    ORDER BY a.fecha DESC
    LIMIT p_limite;
END$$
DELIMITER ;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. SP: sp_marcar_alerta_leida
-- ─────────────────────────────────────────────────────────────────────────────
DROP PROCEDURE IF EXISTS sp_marcar_alerta_leida;
DELIMITER $$
CREATE PROCEDURE sp_marcar_alerta_leida(
    IN p_id_alerta  BIGINT,
    IN p_id_usuario BIGINT
)
BEGIN
    UPDATE notificacion_alerta
    SET leida = 1
    WHERE id_alerta = p_id_alerta AND id_usuario = p_id_usuario;
END$$
DELIMITER ;

-- ─────────────────────────────────────────────────────────────────────────────
-- Fin de la migración
-- ─────────────────────────────────────────────────────────────────────────────
