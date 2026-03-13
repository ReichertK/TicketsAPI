-- ============================================================
-- STORED PROCEDURE: sp_dashboard_tickets
-- Purpose: Calcular métricas del dashboard en DB (optimizado)
-- MySQL 5.5 compatible
-- Fecha: 30 de diciembre de 2024
-- ============================================================

USE tickets_db;

DROP PROCEDURE IF EXISTS sp_dashboard_tickets;

CREATE PROCEDURE sp_dashboard_tickets(
    IN w_id_usuario INT,
    IN w_id_departamento INT
)
BEGIN
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_abiertos INT DEFAULT 0;
    DECLARE v_cerrados INT DEFAULT 0;
    DECLARE v_en_proceso INT DEFAULT 0;
    DECLARE v_asignados_a_mi INT DEFAULT 0;
    DECLARE v_tiempo_promedio DECIMAL(10,2) DEFAULT 0.00;

    -- Total de tickets (filtro opcional por usuario/departamento)
    SELECT COUNT(*) INTO v_total
    FROM tkt
    WHERE Habilitado = 1
      AND (w_id_usuario IS NULL OR Id_Usuario = w_id_usuario OR Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);

    -- Tickets abiertos (sin fecha de cierre)
    SELECT COUNT(*) INTO v_abiertos
    FROM tkt
    WHERE Habilitado = 1
      AND Date_Cierre IS NULL
      AND (w_id_usuario IS NULL OR Id_Usuario = w_id_usuario OR Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);

    -- Tickets cerrados
    SELECT COUNT(*) INTO v_cerrados
    FROM tkt
    WHERE Habilitado = 1
      AND Date_Cierre IS NOT NULL
      AND (w_id_usuario IS NULL OR Id_Usuario = w_id_usuario OR Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);

    -- Tickets en proceso (estado En Proceso)
    SELECT COUNT(*) INTO v_en_proceso
    FROM tkt t
    INNER JOIN estado e ON t.Id_Estado = e.Id_Estado
    WHERE t.Habilitado = 1
      AND (e.TipoEstado LIKE '%Progreso%' OR e.TipoEstado = 'En Proceso')
      AND (w_id_usuario IS NULL OR t.Id_Usuario = w_id_usuario OR t.Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR t.Id_Departamento = w_id_departamento);

    -- Tickets asignados a mí
    IF w_id_usuario IS NOT NULL THEN
        SELECT COUNT(*) INTO v_asignados_a_mi
        FROM tkt
        WHERE Habilitado = 1
          AND Id_Usuario_Asignado = w_id_usuario
          AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);
    END IF;

    -- Tiempo promedio de resolución (horas)
    SELECT IFNULL(ROUND(AVG(TIMESTAMPDIFF(HOUR, Date_Creado, Date_Cierre)), 2), 0.00)
    INTO v_tiempo_promedio
    FROM tkt
    WHERE Habilitado = 1
      AND Date_Cierre IS NOT NULL
      AND Date_Creado IS NOT NULL
      AND (w_id_usuario IS NULL OR Id_Usuario = w_id_usuario OR Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);

    -- Result set 1: Resumen
    SELECT 
        v_total AS TicketsTotal,
        v_abiertos AS TicketsAbiertos,
        v_cerrados AS TicketsCerrados,
        v_en_proceso AS TicketsEnProceso,
        v_asignados_a_mi AS TicketsAsignadosAMi,
        v_tiempo_promedio AS TiempoPromedioResolucion;

    -- Result set 2: Tickets por estado
    SELECT 
        IFNULL(e.TipoEstado, 'Sin Estado') AS Nombre,
        COUNT(*) AS Cantidad
    FROM tkt t
    LEFT JOIN estado e ON t.Id_Estado = e.Id_Estado
    WHERE t.Habilitado = 1
      AND (w_id_usuario IS NULL OR t.Id_Usuario = w_id_usuario OR t.Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR t.Id_Departamento = w_id_departamento)
    GROUP BY e.TipoEstado
    ORDER BY Cantidad DESC;

    -- Result set 3: Tickets por prioridad
    SELECT 
        IFNULL(p.NombrePrioridad, 'Sin Prioridad') AS Nombre,
        COUNT(*) AS Cantidad
    FROM tkt t
    LEFT JOIN prioridad p ON t.Id_Prioridad = p.Id_Prioridad
    WHERE t.Habilitado = 1
      AND (w_id_usuario IS NULL OR t.Id_Usuario = w_id_usuario OR t.Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR t.Id_Departamento = w_id_departamento)
    GROUP BY p.NombrePrioridad
    ORDER BY Cantidad DESC;

    -- Result set 4: Tickets por departamento
    SELECT 
        IFNULL(d.Nombre, 'Sin Departamento') AS Nombre,
        COUNT(*) AS Cantidad
    FROM tkt t
    LEFT JOIN departamento d ON t.Id_Departamento = d.Id_Departamento
    WHERE t.Habilitado = 1
      AND (w_id_usuario IS NULL OR t.Id_Usuario = w_id_usuario OR t.Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR t.Id_Departamento = w_id_departamento)
    GROUP BY d.Nombre
    ORDER BY Cantidad DESC;

END;
