DROP PROCEDURE IF EXISTS sp_ticket_stats;
DELIMITER //
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

    SELECT
        SUM(CASE WHEN t.Id_Estado = 1 THEN 1 ELSE 0 END) AS Abiertos,
        SUM(CASE WHEN t.Id_Usuario_Asignado IS NULL AND t.Id_Estado NOT IN (3, 6) THEN 1 ELSE 0 END) AS SinAsignar,
        SUM(CASE WHEN t.Id_Estado NOT IN (3, 6) AND t.Date_Creado < DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 ELSE 0 END) AS Vencidos,
        COUNT(*) AS TotalFiltro
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
END//
DELIMITER ;
