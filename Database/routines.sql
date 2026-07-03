-- MySQL dump 10.13  Distrib 5.5.27, for Win64 (x86)
--
-- Host: localhost    Database: cdk_tkt_dev
-- ------------------------------------------------------
-- Server version	5.5.27

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping routines for database 'cdk_tkt_dev'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_actualizar_tkt` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_actualizar_tkt`(
  IN w_id_tkt BIGINT,
  IN w_id_estado INT,
  IN w_id_usuario INT,
  IN w_id_empresa INT,
  IN w_id_perfil INT,
  IN w_id_motivo INT,
  IN w_id_sucursal INT,
  IN w_id_prioridad INT,
  IN w_contenido TEXT,
  IN w_id_departamento INT,
  IN w_id_usuario_actor INT,
  OUT p_resultado VARCHAR(255)
)
proc: BEGIN
  DECLARE v_count INT;
  DECLARE v_creador INT;
  DECLARE v_asignado INT;
  
  -- Verificar que el ticket existe
  SELECT Id_Usuario, Id_Usuario_Asignado INTO v_creador, v_asignado
  FROM tkt WHERE Id_Tkt = w_id_tkt;
  
  IF v_creador IS NULL THEN
    SET p_resultado = 'Error: Ticket no existe';
    LEAVE proc;
  END IF;
  
  -- Validar prioridad existe
  IF w_id_prioridad IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count FROM prioridad WHERE Id_Prioridad = w_id_prioridad;
    IF v_count = 0 THEN
      SET p_resultado = CONCAT('Error: Prioridad ', w_id_prioridad, ' no existe');
      LEAVE proc;
    END IF;
  END IF;
  
  -- Validar departamento existe
  IF w_id_departamento IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count FROM departamento WHERE Id_Departamento = w_id_departamento;
    IF v_count = 0 THEN
      SET p_resultado = CONCAT('Error: Departamento ', w_id_departamento, ' no existe');
      LEAVE proc;
    END IF;
  END IF;
  
  -- Validar motivo existe (opcional)
  IF w_id_motivo IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count FROM motivo WHERE Id_Motivo = w_id_motivo;
    IF v_count = 0 THEN
      SET p_resultado = CONCAT('Error: Motivo ', w_id_motivo, ' no existe');
      LEAVE proc;
    END IF;
  END IF;
  
  -- Actualizar ticket
  UPDATE tkt
     SET Id_Estado = w_id_estado,
         Id_Usuario = w_id_usuario,
         Id_Empresa = w_id_empresa,
         Id_Perfil = w_id_perfil,
         Id_Motivo = w_id_motivo,
         Id_Sucursal = w_id_sucursal,
         Id_Prioridad = w_id_prioridad,
         Contenido = w_contenido,
         Id_Departamento = w_id_departamento,
         Date_Cambio_Estado = IF(Id_Estado <> w_id_estado, NOW(), Date_Cambio_Estado)
   WHERE Id_Tkt = w_id_tkt;
  
  SET p_resultado = 'OK';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_agregar_tkt` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_agregar_tkt`(
  IN w_id_estado INT,
  IN w_id_usuario INT,
  IN w_id_empresa INT,
  IN w_id_perfil INT,
  IN w_id_motivo INT,
  IN w_id_sucursal INT,
  IN w_id_prioridad INT,
  IN w_contenido TEXT,
  IN w_id_departamento INT,
  OUT p_resultado VARCHAR(255)
)
proc: BEGIN
  DECLARE v_count INT;
  
  -- Validar prioridad existe
  IF w_id_prioridad IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count FROM prioridad WHERE Id_Prioridad = w_id_prioridad;
    IF v_count = 0 THEN
      SET p_resultado = CONCAT('Error: Prioridad ', w_id_prioridad, ' no existe');
      LEAVE proc;
    END IF;
  END IF;
  
  -- Validar departamento existe
  IF w_id_departamento IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count FROM departamento WHERE Id_Departamento = w_id_departamento;
    IF v_count = 0 THEN
      SET p_resultado = CONCAT('Error: Departamento ', w_id_departamento, ' no existe');
      LEAVE proc;
    END IF;
  END IF;
  
  -- Validar motivo existe (opcional)
  IF w_id_motivo IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count FROM motivo WHERE Id_Motivo = w_id_motivo;
    IF v_count = 0 THEN
      SET p_resultado = CONCAT('Error: Motivo ', w_id_motivo, ' no existe');
      LEAVE proc;
    END IF;
  END IF;
  
  -- Validar usuario existe
  IF w_id_usuario IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count FROM usuario WHERE idUsuario = w_id_usuario;
    IF v_count = 0 THEN
      SET p_resultado = CONCAT('Error: Usuario ', w_id_usuario, ' no existe');
      LEAVE proc;
    END IF;
  END IF;
  
  -- Validar estado existe
  IF w_id_estado IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count FROM estado WHERE Id_Estado = w_id_estado;
    IF v_count = 0 THEN
      SET p_resultado = CONCAT('Error: Estado ', w_id_estado, ' no existe');
      LEAVE proc;
    END IF;
  END IF;
  
  -- Insertar ticket
  INSERT INTO tkt
    (Id_Estado, Id_Usuario, Id_Empresa, Id_Perfil, Id_Motivo, Id_Sucursal,
     Id_Prioridad, Contenido, Id_Departamento, Date_Creado, Habilitado)
  VALUES
    (w_id_estado, w_id_usuario, w_id_empresa, w_id_perfil, w_id_motivo, w_id_sucursal,
     w_id_prioridad, w_contenido, w_id_departamento, NOW(), 1);
  
  SET p_resultado = 'OK';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_agregar_usuario` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_agregar_usuario`(
    IN p_nombre VARCHAR(40),
    IN p_email VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_id_departamento BIGINT(20),
    IN p_id_rol INT,
    OUT p_id BIGINT(20),
    OUT p_resultado VARCHAR(100)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    
    START TRANSACTION;
    
    SELECT COUNT(*) INTO v_existe 
    FROM usuario 
    WHERE email = p_email AND p_email IS NOT NULL AND p_email != '';
    
    IF v_existe > 0 THEN
        SET p_resultado = 'Error: El email ya esta registrado';
        SET p_id = 0;
        ROLLBACK;
    ELSE
        INSERT INTO usuario (
            nombre, 
            email, 
            passwordUsuario, 
            passwordUsuarioEnc,
            fechaAlta,
            idKine,
            tipo
        ) VALUES (
            p_nombre,
            p_email,
            p_password,
            p_password,
            CURDATE(),
            COALESCE(p_id_departamento, 0),
            'INT'
        );
        
        SET p_id = LAST_INSERT_ID();
        
        IF p_id_rol IS NOT NULL AND p_id_rol > 0 THEN
            INSERT INTO usuario_rol (idUsuario, idRol)
            VALUES (p_id, p_id_rol);
        END IF;
        
        SET p_resultado = 'success';
        COMMIT;
    END IF;
    
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_alertas_no_leidas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_alertas_no_leidas`(
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_asignar_ticket` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_asignar_ticket`(
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

  SELECT COUNT(*) INTO v_puede_asignar
  FROM usuario_rol ur
  JOIN rol_permiso rp ON ur.idRol = rp.idRol
  JOIN permiso pm ON rp.idPermiso = pm.idPermiso
  WHERE ur.idUsuario = p_id_usuario_actor AND pm.codigo = 'TKT_ASSIGN';

  IF p_id_usuario_asignado = p_id_usuario_actor THEN
    IF v_asignado_actual IS NOT NULL AND v_asignado_actual = p_id_usuario_asignado THEN
      SET p_resultado = 'OK';
      LEAVE proc;
    END IF;
    IF v_asignado_actual IS NOT NULL AND v_asignado_actual != p_id_usuario_asignado THEN
      SET p_resultado = 'Error: No puedes auto-asignarte un ticket que ya tiene un usuario asignado';
      LEAVE proc;
    END IF;
  ELSE
    IF v_puede_asignar = 0 THEN
      SET p_resultado = 'Error: No tiene el permiso TKT_ASSIGN para asignar tickets a otros usuarios';
      LEAVE proc;
    END IF;

    IF v_asignado_actual IS NOT NULL THEN
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

  
  IF p_id_usuario_asignado <> p_id_usuario_actor THEN
    INSERT INTO tkt_notificacion_lectura (id_ticket, id_usuario, leido, fecha_cambio)
    VALUES (p_id_tkt, p_id_usuario_asignado, 0, NOW())
    ON DUPLICATE KEY UPDATE leido = 0, fecha_cambio = NOW();
  END IF;

  SET p_resultado = 'OK';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_crear_alerta_mencion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_crear_alerta_mencion`(
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_dashboard_tickets` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_dashboard_tickets`(
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

    SELECT COUNT(*) INTO v_total
    FROM tkt
    WHERE Habilitado = 1
      AND (w_id_usuario IS NULL OR Id_Usuario = w_id_usuario OR Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);

    SELECT COUNT(*) INTO v_abiertos
    FROM tkt
    WHERE Habilitado = 1
      AND Date_Cierre IS NULL
      AND (w_id_usuario IS NULL OR Id_Usuario = w_id_usuario OR Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);

    SELECT COUNT(*) INTO v_cerrados
    FROM tkt
    WHERE Habilitado = 1
      AND Date_Cierre IS NOT NULL
      AND (w_id_usuario IS NULL OR Id_Usuario = w_id_usuario OR Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);

    SELECT COUNT(*) INTO v_en_proceso
    FROM tkt t
    INNER JOIN estado e ON t.Id_Estado = e.Id_Estado
    WHERE t.Habilitado = 1
      AND (e.TipoEstado LIKE '%Progreso%' OR e.TipoEstado = 'En Proceso')
      AND (w_id_usuario IS NULL OR t.Id_Usuario = w_id_usuario OR t.Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR t.Id_Departamento = w_id_departamento);

    IF w_id_usuario IS NOT NULL THEN
        SELECT COUNT(*) INTO v_asignados_a_mi
        FROM tkt
        WHERE Habilitado = 1
          AND Id_Usuario_Asignado = w_id_usuario
          AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);
    END IF;

    SELECT IFNULL(ROUND(AVG(TIMESTAMPDIFF(HOUR, Date_Creado, Date_Cierre)), 2), 0.00)
    INTO v_tiempo_promedio
    FROM tkt
    WHERE Habilitado = 1
      AND Date_Cierre IS NOT NULL
      AND Date_Creado IS NOT NULL
      AND (w_id_usuario IS NULL OR Id_Usuario = w_id_usuario OR Id_Usuario_Asignado = w_id_usuario)
      AND (w_id_departamento IS NULL OR Id_Departamento = w_id_departamento);

    SELECT 
        v_total AS TicketsTotal,
        v_abiertos AS TicketsAbiertos,
        v_cerrados AS TicketsCerrados,
        v_en_proceso AS TicketsEnProceso,
        v_asignados_a_mi AS TicketsAsignadosAMi,
        v_tiempo_promedio AS TiempoPromedioResolucion;

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_departamento_actualizar` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_departamento_actualizar`(
  IN p_id INT,
  IN p_nombre VARCHAR(50),
  IN p_descripcion VARCHAR(255),
  OUT p_resultado VARCHAR(255)
)
BEGIN
  DECLARE v_exists INT DEFAULT 0;
  DECLARE v_dup INT DEFAULT 0;

  SELECT COUNT(*) INTO v_exists FROM departamento WHERE Id_Departamento = p_id;
  IF v_exists = 0 THEN
    SET p_resultado = 'Error: Departamento no encontrado';
  ELSE
    SELECT COUNT(*) INTO v_dup
    FROM departamento
    WHERE Nombre = p_nombre AND Id_Departamento != p_id;

    IF v_dup > 0 THEN
      SET p_resultado = 'Error: Ya existe un departamento con ese nombre';
    ELSE
      UPDATE departamento
      SET Nombre = p_nombre,
          Descripcion = p_descripcion
      WHERE Id_Departamento = p_id;
      SET p_resultado = 'OK';
    END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_departamento_crear` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_departamento_crear`(
  IN p_nombre VARCHAR(50),
  OUT p_id INT,
  OUT p_resultado VARCHAR(255)
)
BEGIN
  DECLARE v_existe INT;
  SELECT COUNT(*) INTO v_existe FROM departamento WHERE Nombre = p_nombre;
  IF v_existe > 0 THEN
    SET p_resultado = 'Error: Nombre existente';
    SET p_id = 0;
  ELSE
    INSERT INTO departamento (Nombre) VALUES (p_nombre);
    SET p_id = LAST_INSERT_ID();
    SET p_resultado = 'OK';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_editar_estado` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_editar_estado`(
  IN p_id INT,
  IN p_nombre VARCHAR(100),
  IN p_descripcion VARCHAR(255),
  OUT p_resultado VARCHAR(255)
)
BEGIN
  DECLARE v_exists INT DEFAULT 0;
  
  SELECT COUNT(*) INTO v_exists FROM estado WHERE Id_Estado = p_id;
  IF v_exists = 0 THEN
    SET p_resultado = 'Error: Estado no encontrado';
  ELSE
    UPDATE estado 
    SET TipoEstado = p_nombre,
        Descripcion = p_descripcion
    WHERE Id_Estado = p_id;
    SET p_resultado = 'OK';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_editar_motivo` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_editar_motivo`(
  IN p_id INT,
  IN p_nombre VARCHAR(100),
  IN p_descripcion VARCHAR(255),
  IN p_categoria VARCHAR(100),
  OUT p_resultado VARCHAR(255)
)
BEGIN
  DECLARE v_exists INT DEFAULT 0;
  
  SELECT COUNT(*) INTO v_exists FROM motivo WHERE Id_Motivo = p_id;
  IF v_exists = 0 THEN
    SET p_resultado = 'Error: Motivo no encontrado';
  ELSE
    UPDATE motivo 
    SET Nombre = p_nombre,
        Descripcion = p_descripcion,
        Categoria = p_categoria
    WHERE Id_Motivo = p_id;
    SET p_resultado = 'OK';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_editar_prioridad` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_editar_prioridad`(
  IN p_id INT,
  IN p_nombre VARCHAR(100),
  IN p_descripcion VARCHAR(255),
  OUT p_resultado VARCHAR(255)
)
BEGIN
  DECLARE v_exists INT DEFAULT 0;
  
  SELECT COUNT(*) INTO v_exists FROM prioridad WHERE Id_Prioridad = p_id;
  IF v_exists = 0 THEN
    SET p_resultado = 'Error: Prioridad no encontrada';
  ELSE
    UPDATE prioridad 
    SET NombrePrioridad = p_nombre,
        Descripcion = p_descripcion
    WHERE Id_Prioridad = p_id;
    SET p_resultado = 'OK';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_editar_usuario` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_editar_usuario`(
    IN p_id_usuario BIGINT(20),
    IN p_nombre VARCHAR(40),
    IN p_email VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_id_departamento BIGINT(20),
    IN p_id_rol INT,
    OUT p_resultado VARCHAR(100)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM usuario WHERE idUsuario = p_id_usuario;
    
    IF v_existe = 0 THEN
        SET p_resultado = 'Error: Usuario no encontrado';
    ELSE
        UPDATE usuario 
        SET nombre = COALESCE(p_nombre, nombre),
            email = COALESCE(p_email, email),
            passwordUsuario = IF(p_password IS NOT NULL AND p_password != '', p_password, passwordUsuario),
            passwordUsuarioEnc = IF(p_password IS NOT NULL AND p_password != '', p_password, passwordUsuarioEnc),
            idKine = COALESCE(p_id_departamento, idKine)
        WHERE idUsuario = p_id_usuario;
        
        IF p_id_rol IS NOT NULL AND p_id_rol > 0 THEN
            INSERT INTO usuario_rol (idUsuario, idRol)
            VALUES (p_id_usuario, p_id_rol)
            ON DUPLICATE KEY UPDATE idRol = p_id_rol;
        END IF;
        
        SET p_resultado = 'success';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_eliminar_ticket` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_eliminar_ticket`(
  IN w_id_ticket INT,
  OUT p_resultado VARCHAR(255)
)
proc: BEGIN
  DECLARE v_existe INT;
  
  -- Validar que el ticket existe
  SELECT COUNT(*) INTO v_existe FROM tkt WHERE Id_Tkt = w_id_ticket;
  IF v_existe = 0 THEN
    SET p_resultado = 'Error: Ticket no existe';
    LEAVE proc;
  END IF;
  
  -- Soft delete
  UPDATE tkt SET Habilitado = 0 WHERE Id_Tkt = w_id_ticket;
  SET p_resultado = 'OK';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_eliminar_usuario` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_eliminar_usuario`(
    IN p_id_usuario BIGINT(20),
    OUT p_resultado VARCHAR(100)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    
    START TRANSACTION;
    
    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_existe
    FROM usuario
    WHERE idUsuario = p_id_usuario;
    
    IF v_existe = 0 THEN
        SET p_resultado = 'Error: Usuario no encontrado';
        ROLLBACK;
    ELSE
        -- Soft delete: marcar como dado de baja
        UPDATE usuario 
        SET fechaBaja = CURDATE()
        WHERE idUsuario = p_id_usuario;
        
        SET p_resultado = 'success';
        COMMIT;
    END IF;
    
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_estado_crear` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_estado_crear`(
  IN p_tipo_estado VARCHAR(100),
  OUT p_id INT,
  OUT p_resultado VARCHAR(100)
)
proc: BEGIN
  IF p_tipo_estado IS NULL OR TRIM(p_tipo_estado) = '' THEN
    SET p_resultado = 'Error: TipoEstado requerido';
    SET p_id = 0;
    LEAVE proc;
  END IF;

  INSERT INTO estado (TipoEstado) VALUES (p_tipo_estado);
  SET p_id = LAST_INSERT_ID();
  SET p_resultado = 'success';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_global_search` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_global_search`(
    IN p_termino        VARCHAR(100),
    IN p_id_usuario     BIGINT,
    IN p_es_admin       TINYINT,      
    IN p_limite         INT
)
BEGIN
    DECLARE v_depto_usuario INT DEFAULT NULL;
    DECLARE v_term VARCHAR(102);

    IF p_limite IS NULL OR p_limite < 1 THEN
        SET p_limite = 10;
    END IF;

    SET v_term = CONCAT('%', IFNULL(p_termino, ''), '%');

    
    IF p_es_admin = 0 THEN
        SELECT Id_Departamento INTO v_depto_usuario
        FROM usuario WHERE idUsuario = p_id_usuario LIMIT 1;
    END IF;

    
    
    SELECT
        'ticket' AS categoria,
        t.Id_Tkt AS id,
        CONCAT('#', t.Id_Tkt, ' ÔÇô ', LEFT(t.Contenido, 80)) AS titulo,
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listar_tkts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_listar_tkts`(
    IN w_Id_Tkt BIGINT(20),
    IN w_Id_Estado INT(10),
    IN w_Date_Creado DATE,
    IN w_Date_Cierre DATETIME,
    IN w_Date_Asignado DATETIME,
    IN w_Date_Cambio_Estado DATETIME,
    IN w_Id_Usuario INT(20),
    IN w_Nombre_Usuario VARCHAR(150),
    IN w_Id_Empresa INT(20),
    IN w_Id_Perfil INT(20),
    IN w_Id_Motivo INT(20),
    IN w_Id_Sucursal INT(20),
    IN w_Habilitado INT(20),
    IN w_Id_Prioridad INT(20),
    IN w_Contenido VARCHAR(150),
    IN w_Id_Departamento INT(20),
    IN w_Page INT,
    IN w_Page_Size INT,
    OUT totalRecords INT
)
BEGIN
    DECLARE v_offset INT;
    SET v_offset = (w_Page - 1) * w_Page_Size;

    DROP TEMPORARY TABLE IF EXISTS tmp_tickets;
    CREATE TEMPORARY TABLE tmp_tickets (
        Id_Tkt BIGINT(20),
        Id_Estado INT(10),
        Date_Creado DATETIME,
        Date_Cierre DATETIME,
        Date_Asignado DATETIME,
        Date_Cambio_Estado DATETIME,
        Id_Usuario BIGINT(20),
        Id_Usuario_Asignado BIGINT(20),
        Id_Empresa BIGINT(20),
        Id_Perfil BIGINT(20),
        Id_Motivo INT(20),
        Id_Sucursal BIGINT(20),
        Habilitado INT(20),
        Id_Prioridad INT(20),
        Contenido TEXT,
        Id_Departamento INT(11),
        Nombre_Usuario VARCHAR(150),
        Nombre_Asignado VARCHAR(150),
        Nombre_Departamento VARCHAR(255),
        NombrePrioridad VARCHAR(100),
        TipoEstado VARCHAR(100)
    );

    INSERT INTO tmp_tickets
    SELECT
        t.Id_Tkt,
        t.Id_Estado,
        t.Date_Creado,
        t.Date_Cierre,
        t.Date_Asignado,
        t.Date_Cambio_Estado,
        t.Id_Usuario,
        t.Id_Usuario_Asignado,
        t.Id_Empresa,
        t.Id_Perfil,
        t.Id_Motivo,
        t.Id_Sucursal,
        t.Habilitado,
        t.Id_Prioridad,
        t.Contenido,
        t.Id_Departamento,
        u.nombre AS Nombre_Usuario,
        ua.nombre AS Nombre_Asignado,
        d.Nombre AS Nombre_Departamento,
        p.NombrePrioridad,
        e.TipoEstado
    FROM tkt t
    LEFT JOIN usuario u  ON t.Id_Usuario = u.idUsuario
    LEFT JOIN usuario ua ON t.Id_Usuario_Asignado = ua.idUsuario
    LEFT JOIN departamento d ON t.Id_Departamento = d.Id_Departamento
    LEFT JOIN prioridad p ON t.Id_Prioridad = p.Id_Prioridad
    LEFT JOIN estado e ON t.Id_Estado = e.Id_Estado
    WHERE 1 = 1
      AND (w_Id_Tkt IS NULL OR t.Id_Tkt = w_Id_Tkt)
      AND (w_Id_Estado IS NULL OR t.Id_Estado = w_Id_Estado)
      AND (w_Date_Creado IS NULL OR DATE(t.Date_Creado) = w_Date_Creado)
      AND (w_Date_Cierre IS NULL OR t.Date_Cierre <= w_Date_Cierre)
      AND (w_Date_Asignado IS NULL OR t.Date_Asignado >= w_Date_Asignado)
      AND (w_Date_Cambio_Estado IS NULL OR t.Date_Cambio_Estado <= w_Date_Cambio_Estado)
      AND (w_Id_Usuario IS NULL OR t.Id_Usuario = w_Id_Usuario)
      AND (w_Nombre_Usuario IS NULL OR u.nombre LIKE CONCAT('%', w_Nombre_Usuario, '%'))
      AND (w_Id_Empresa IS NULL OR t.Id_Empresa = w_Id_Empresa)
      AND (w_Id_Perfil IS NULL OR t.Id_Perfil = w_Id_Perfil)
      AND (w_Id_Motivo IS NULL OR t.Id_Motivo = w_Id_Motivo)
      AND (w_Id_Sucursal IS NULL OR t.Id_Sucursal = w_Id_Sucursal)
      AND (w_Habilitado IS NULL OR t.Habilitado = w_Habilitado)
      AND (w_Id_Prioridad IS NULL OR t.Id_Prioridad = w_Id_Prioridad)
      AND (w_Contenido IS NULL OR t.Contenido LIKE CONCAT('%', w_Contenido, '%'))
      AND (w_Id_Departamento IS NULL OR t.Id_Departamento = w_Id_Departamento);

    SELECT COUNT(*) INTO totalRecords FROM tmp_tickets;

    SELECT * FROM tmp_tickets
    LIMIT v_offset, w_Page_Size;

    DROP TEMPORARY TABLE IF EXISTS tmp_tickets;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listar_usuario` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_listar_usuario`(w_nombre VARCHAR(40), w_email VARCHAR(50), w_tipoID VARCHAR(3), w_habilitado INT(1))
BEGIN
	START TRANSACTION;	
	SET @query = "
		SELECT
		u.*,
		ut.usuTipoDesc
		FROM
		usuario u,
		usuario_tipo ut
		WHERE
		ut.usuTipoId = u.tipo
	";
	IF w_nombre != "" THEN
		SET @query = CONCAT(@query, " AND u.nombre LIKE '%", w_nombre, "%'");
	END IF;
	IF w_email != "" THEN
		SET @query = CONCAT(@query, " AND u.email LIKE '%", w_email, "%'");
	END IF;		
	IF w_tipoID != "0" THEN
		SET @query = CONCAT(@query, " AND u.tipo = '", w_tipoID, "'");
	END IF;
	IF w_habilitado > -1 THEN
		SET @query = CONCAT(@query,  " AND ISNULL(u.fechaBaja) = ", if(w_habilitado = 0, "1", "0"));
	END IF;	
	PREPARE stmt FROM @query;
	EXECUTE stmt;
	COMMIT;
	END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listar_UsuEmpSucPerSis` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_listar_UsuEmpSucPerSis`(
  IN w_usuarioID  INT,
  IN w_empresaID  INT,
  IN w_sucursalID INT,
  IN w_sistemaID  VARCHAR(8),
  IN w_perfilID   INT,
  IN w_habilitado INT
)
BEGIN
  SELECT
    m.idUsuario  AS idUsuario,
    m.idEmpresa  AS idEmpresa,
    m.idSucursal AS idSucursal,
    m.idPerfil   AS idPerfil,
    m.idSistema  AS idSistema,
    m.habilitado AS habilitado
  FROM usuario_empresa_sucursal_perfil_sistema m
  WHERE m.idUsuario = w_usuarioID
    AND (w_empresaID  = -1 OR m.idEmpresa  = w_empresaID)
    AND (w_sucursalID = -1 OR m.idSucursal = w_sucursalID)
    AND (w_sistemaID IS NULL OR w_sistemaID = '' OR m.idSistema = w_sistemaID)
    AND (w_perfilID   =  0 OR m.idPerfil    = w_perfilID)
    AND (w_habilitado = -1 OR m.habilitado  = w_habilitado)
  ORDER BY m.habilitado DESC, m.ID ASC
  LIMIT 1;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_marcar_alerta_leida` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_marcar_alerta_leida`(
    IN p_id_alerta  BIGINT,
    IN p_id_usuario BIGINT
)
BEGIN
    UPDATE notificacion_alerta
    SET leida = 1
    WHERE id_alerta = p_id_alerta AND id_usuario = p_id_usuario;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_motivo_crear` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_motivo_crear`(
  IN p_nombre VARCHAR(255),
  IN p_categoria VARCHAR(255),
  OUT p_id INT,
  OUT p_resultado VARCHAR(255)
)
BEGIN
  DECLARE v_existe INT;
  SELECT COUNT(*) INTO v_existe FROM motivo WHERE Nombre = p_nombre AND ((Categoria IS NULL AND p_categoria IS NULL) OR Categoria = p_categoria);
  IF v_existe > 0 THEN
    SET p_resultado = 'Error: Motivo existente';
    SET p_id = 0;
  ELSE
    INSERT INTO motivo (Nombre, Categoria) VALUES (p_nombre, p_categoria);
    SET p_id = LAST_INSERT_ID();
    SET p_resultado = 'OK';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_obtener_detalle_ticket` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_obtener_detalle_ticket`(IN w_Id_Tkt BIGINT)
BEGIN
  SELECT 
         t.Id_Tkt,
         t.Contenido,
         t.Id_Estado,
         t.Id_Prioridad,
         t.Id_Departamento,
         t.Id_Usuario,
         t.Id_Usuario_Asignado,
         t.Id_Empresa,
         t.Id_Perfil,
         t.Id_Sucursal,
         t.Date_Creado,
         t.Date_Asignado,
         t.Date_Cierre,
         t.Date_Cambio_Estado,
         t.Id_Motivo,
         t.Habilitado,
         u.idUsuario AS U_IdUsuario,
         u.nombre AS UsuarioNombre,
         u.email AS UsuarioEmail,
         ua.idUsuario AS U_IdUsuario_Asignado,
         ua.nombre AS UsuarioAsignadoNombre,
         ua.email AS UsuarioAsignadoEmail,
         d.Id_Departamento AS DepartamentoId,
         d.Nombre AS DepartamentoNombre,
         p.Id_Prioridad AS PrioridadId,
         p.NombrePrioridad AS PrioridadNombre,
         e.Id_Estado AS EstadoId,
         e.TipoEstado AS EstadoNombre,
         m.Id_Motivo AS MotivoId,
         m.Nombre AS MotivoNombre
    FROM tkt t
    LEFT JOIN usuario u  ON u.idUsuario  = t.Id_Usuario
    LEFT JOIN usuario ua ON ua.idUsuario = t.Id_Usuario_Asignado
    LEFT JOIN departamento d ON d.Id_Departamento = t.Id_Departamento
    LEFT JOIN prioridad p    ON p.Id_Prioridad = t.Id_Prioridad
    LEFT JOIN estado e       ON e.Id_Estado   = t.Id_Estado
    LEFT JOIN motivo m       ON m.Id_Motivo   = t.Id_Motivo
   WHERE t.Id_Tkt = w_Id_Tkt
   LIMIT 1;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_obtener_resumen_notificaciones` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_obtener_resumen_notificaciones`(
    IN p_id_usuario BIGINT
)
BEGIN
    -- Result Set 1: Conteo total de no le├¡dos
    SELECT 
        COUNT(*) AS total_no_leidos,
        SUM(CASE WHEN t.Id_Usuario_Asignado = p_id_usuario AND t.Id_Estado NOT IN (3) THEN 1 ELSE 0 END) AS pendientes_asignados
    FROM tkt_notificacion_lectura nl
    INNER JOIN tkt t ON nl.id_ticket = t.Id_Tkt
    WHERE nl.id_usuario = p_id_usuario 
      AND nl.leido = 0
      AND t.Habilitado = 1;

    -- Result Set 2: ├Ültimos 5 tickets no le├¡dos con detalle
    SELECT 
        t.Id_Tkt AS id_ticket,
        t.Contenido AS contenido,
        t.Id_Estado AS id_estado,
        e.TipoEstado AS estado_nombre,
        p.NombrePrioridad AS prioridad_nombre,
        t.Date_Cambio_Estado AS fecha_cambio,
        CASE WHEN t.Id_Usuario_Asignado = p_id_usuario THEN 1 ELSE 0 END AS es_asignado_a_mi
    FROM tkt_notificacion_lectura nl
    INNER JOIN tkt t ON nl.id_ticket = t.Id_Tkt
    LEFT JOIN estado e ON t.Id_Estado = e.Id_Estado
    LEFT JOIN prioridad p ON t.Id_Prioridad = p.Id_Prioridad
    WHERE nl.id_usuario = p_id_usuario 
      AND nl.leido = 0
      AND t.Habilitado = 1
    ORDER BY nl.fecha_cambio DESC
    LIMIT 5;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_obtener_usuarios` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_obtener_usuarios`()
BEGIN
  SELECT 
      u.idUsuario AS Id_Usuario,
      u.nombre AS Nombre,
      u.email AS Email,
      u.passwordUsuarioEnc AS Contrase├▒a,
      u.idKine AS Id_Departamento,
      COALESCE(ur.idRol, 0) AS Id_Rol
    FROM usuario u
    LEFT JOIN usuario_rol ur ON u.idUsuario = ur.idUsuario
   ORDER BY u.nombre;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_permiso_guardar` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_permiso_guardar`(
    IN p_idPermiso INT,
    IN p_codigo VARCHAR(64),
    IN p_descripcion VARCHAR(200)
)
BEGIN
    IF p_idPermiso IS NULL OR p_idPermiso = 0 THEN
        INSERT INTO permiso (codigo, descripcion) VALUES (p_codigo, p_descripcion);
        SELECT LAST_INSERT_ID() AS idPermiso, p_codigo AS codigo, p_descripcion AS descripcion;
    ELSE
        UPDATE permiso SET codigo = p_codigo, descripcion = p_descripcion WHERE idPermiso = p_idPermiso;
        SELECT p_idPermiso AS idPermiso, p_codigo AS codigo, p_descripcion AS descripcion;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_permiso_listar` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_permiso_listar`()
BEGIN
    SELECT idPermiso, codigo, descripcion FROM permiso ORDER BY codigo;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_prioridad_crear` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_prioridad_crear`(
  IN p_nombre_prioridad VARCHAR(100),
  OUT p_id INT,
  OUT p_resultado VARCHAR(100)
)
proc: BEGIN
  DECLARE v_count INT;
  IF p_nombre_prioridad IS NULL OR TRIM(p_nombre_prioridad) = '' THEN
    SET p_resultado = 'Error: NombrePrioridad requerido';
    SET p_id = 0;
    LEAVE proc;
  END IF;

  SELECT COUNT(*) INTO v_count FROM prioridad WHERE NombrePrioridad = p_nombre_prioridad;
  IF v_count > 0 THEN
    SET p_resultado = 'Error: Prioridad ya existe';
    SET p_id = 0;
    LEAVE proc;
  END IF;

  INSERT INTO prioridad (NombrePrioridad) VALUES (p_nombre_prioridad);
  SET p_id = LAST_INSERT_ID();
  SET p_resultado = 'success';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_eliminar` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rol_eliminar`(IN p_idRol INT)
BEGIN
    IF p_idRol = 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar el rol Administrador';
    END IF;

    IF EXISTS (SELECT 1 FROM usuario_rol WHERE idRol = p_idRol LIMIT 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: hay usuarios con este rol asignado';
    END IF;

    DELETE FROM rol_permiso WHERE idRol = p_idRol;
    DELETE FROM rol WHERE idRol = p_idRol;
    SELECT ROW_COUNT() AS eliminado;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_guardar` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rol_guardar`(
    IN p_idRol INT,
    IN p_nombre VARCHAR(64)
)
BEGIN
    IF p_idRol IS NULL OR p_idRol = 0 THEN
        INSERT INTO rol (nombre) VALUES (p_nombre);
        SELECT LAST_INSERT_ID() AS idRol, p_nombre AS nombre;
    ELSE
        UPDATE rol SET nombre = p_nombre WHERE idRol = p_idRol;
        SELECT p_idRol AS idRol, p_nombre AS nombre;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_listar` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rol_listar`()
BEGIN
    SELECT r.idRol, r.nombre, COUNT(rp.idPermiso) AS total_permisos
    FROM rol r
    LEFT JOIN rol_permiso rp ON r.idRol = rp.idRol
    GROUP BY r.idRol, r.nombre
    ORDER BY r.idRol;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_permiso_gestionar` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rol_permiso_gestionar`(
    IN p_idRol INT,
    IN p_permisos_csv TEXT
)
BEGIN
    DELETE FROM rol_permiso WHERE idRol = p_idRol;

    IF p_permisos_csv IS NOT NULL AND p_permisos_csv != '' THEN
        INSERT INTO rol_permiso (idRol, idPermiso)
        SELECT p_idRol, idPermiso FROM permiso
        WHERE FIND_IN_SET(idPermiso, p_permisos_csv) > 0;
    END IF;

    SELECT COUNT(*) AS total_asignados FROM rol_permiso WHERE idRol = p_idRol;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ticket_stats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_ticket_stats`(
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tkt_cola_trabajo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tkt_cola_trabajo`(
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

  SET v_offset = (p_page - 1) * p_page_size;

  IF p_ordenar_por IS NULL THEN SET p_ordenar_por = 'fecha'; END IF;
  IF p_orden_desc IS NULL THEN SET p_orden_desc = 1; END IF;

  
  SELECT COUNT(*) INTO p_total
  FROM tkt t
  WHERE t.Id_Usuario_Asignado = p_id_usuario_actor
    AND t.Id_Estado != 3                    
    AND t.Habilitado = 1
    AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
    AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
    AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
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
  WHERE t.Id_Usuario_Asignado = p_id_usuario_actor
    AND t.Id_Estado != 3
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tkt_comentar` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tkt_comentar`(
  IN p_id_tkt BIGINT,
  IN p_id_usuario INT,
  IN p_comentario VARCHAR(2000)
)
BEGIN
  DECLARE v_existe INT;
  
  IF p_comentario IS NULL OR LENGTH(TRIM(p_comentario)) = 0 THEN
    SELECT 0 success, 'Comentario vacio' mensaje;
  ELSE
    -- Validar que el ticket existe
    SELECT COUNT(*) INTO v_existe FROM tkt WHERE Id_Tkt = p_id_tkt;
    IF v_existe = 0 THEN
      SELECT 0 success, 'Ticket no existe' mensaje;
    ELSE
      INSERT INTO tkt_comentario(id_tkt, id_usuario, comentario, fecha)
      VALUES(p_id_tkt, p_id_usuario, p_comentario, NOW());
      SELECT 1 success, 'Comentario agregado' mensaje;
    END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tkt_comentarios_por_ticket` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tkt_comentarios_por_ticket`(IN p_id_tkt BIGINT)
BEGIN
  SELECT c.id_comentario, c.id_tkt, c.id_usuario, c.comentario, c.fecha,
         u.nombre, u.email
  FROM tkt_comentario c
  LEFT JOIN usuario u ON u.idUsuario = c.id_usuario
  WHERE c.id_tkt = p_id_tkt
  ORDER BY c.fecha ASC;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tkt_gestionar_suscripcion` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tkt_gestionar_suscripcion`(
    IN p_id_tkt BIGINT,
    IN p_id_usuario BIGINT,
    IN p_accion VARCHAR(20)
)
proc: BEGIN
    DECLARE v_existe_tkt INT DEFAULT 0;
    DECLARE v_ya_suscrito INT DEFAULT 0;

    SELECT COUNT(*) INTO v_existe_tkt FROM tkt WHERE Id_Tkt = p_id_tkt;
    IF v_existe_tkt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ticket no encontrado';
    END IF;

    SELECT COUNT(*) INTO v_ya_suscrito
    FROM tkt_suscriptor WHERE id_tkt = p_id_tkt AND id_usuario = p_id_usuario;

    IF p_accion = 'suscribir' THEN
        IF v_ya_suscrito > 0 THEN
            SELECT 0 AS success, 'Ya suscrito' AS message, v_ya_suscrito AS total;
            LEAVE proc;
        END IF;
        INSERT INTO tkt_suscriptor(id_tkt, id_usuario) VALUES(p_id_tkt, p_id_usuario);
        SELECT 1 AS success, 'OK' AS message,
               (SELECT COUNT(*) FROM tkt_suscriptor WHERE id_tkt = p_id_tkt) AS total;

    ELSEIF p_accion = 'desuscribir' THEN
        IF v_ya_suscrito = 0 THEN
            SELECT 0 AS success, 'No suscrito' AS message, 0 AS total;
            LEAVE proc;
        END IF;
        DELETE FROM tkt_suscriptor WHERE id_tkt = p_id_tkt AND id_usuario = p_id_usuario;
        SELECT 1 AS success, 'OK' AS message,
               (SELECT COUNT(*) FROM tkt_suscriptor WHERE id_tkt = p_id_tkt) AS total;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Accion no valida';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tkt_historial` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tkt_historial`(
    IN p_id_tkt BIGINT
)
BEGIN
    SELECT 
        tr.id_transicion AS orden,
        'TRANSICION' AS tipo,
        tr.fecha,
        tr.estado_from AS estadofrom,
        tr.estado_to AS estadoto,
        ef.TipoEstado AS estadofrom_nombre,
        et.TipoEstado AS estadoto_nombre,
        tr.id_usuario_actor AS id_usuario,
        u.nombre AS usuario_nombre,
        tr.comentario AS comentario,
        tr.motivo AS motivo
    FROM tkt_transicion tr
    LEFT JOIN estado ef ON ef.Id_Estado = tr.estado_from
    LEFT JOIN estado et ON et.Id_Estado = tr.estado_to
    LEFT JOIN usuario u ON u.idUsuario = tr.id_usuario_actor
    WHERE tr.id_tkt = p_id_tkt
    UNION ALL
    SELECT 
        c.id_comentario AS orden,
        'COMENTARIO' AS tipo,
        c.fecha,
        NULL AS estadofrom,
        NULL AS estadoto,
        NULL AS estadofrom_nombre,
        NULL AS estadoto_nombre,
        c.id_usuario AS id_usuario,
        u.nombre AS usuario_nombre,
  c.comentario AS comentario,
        NULL AS motivo
    FROM tkt_comentario c
    LEFT JOIN usuario u ON u.idUsuario = c.id_usuario
    WHERE c.id_tkt = p_id_tkt
    ORDER BY fecha, orden;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tkt_mis_tickets` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tkt_mis_tickets`(
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

  
  IF p_ordenar_por IS NULL THEN SET p_ordenar_por = 'fecha'; END IF;
  IF p_orden_desc IS NULL THEN SET p_orden_desc = 1; END IF;

  
  SELECT COUNT(*) INTO p_total
  FROM tkt t
  WHERE t.Id_Usuario = p_id_usuario
    AND t.Habilitado = 1
    AND (p_id_estado IS NULL OR t.Id_Estado = p_id_estado)
    AND (p_id_prioridad IS NULL OR t.Id_Prioridad = p_id_prioridad)
    AND (p_id_departamento IS NULL OR t.Id_Departamento = p_id_departamento)
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tkt_permisos_por_usuario` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tkt_permisos_por_usuario`(IN w_idUsuario BIGINT)
BEGIN
  SELECT p.codigo
    FROM usuario_rol ur
    JOIN rol_permiso rp ON rp.idRol = ur.idRol
    JOIN permiso p ON p.idPermiso = rp.idPermiso
   WHERE ur.idUsuario = w_idUsuario;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tkt_todos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tkt_todos`(
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tkt_transicionar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tkt_transicionar`(
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_reset_password` */;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_usuario_reset_password`(
    IN p_id_usuario_target INT,
    IN p_nuevo_password_hash VARCHAR(255),
    IN p_id_usuario_admin INT,
    OUT p_resultado VARCHAR(200)
)
BEGIN
    DECLARE v_nombre_target VARCHAR(100);
    DECLARE v_nombre_admin VARCHAR(100);
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM usuario WHERE idUsuario = p_id_usuario_target;
    IF v_existe = 0 THEN
        SET p_resultado = 'Error: Usuario destino no encontrado';
    ELSE
        SELECT nombre INTO v_nombre_target FROM usuario WHERE idUsuario = p_id_usuario_target LIMIT 1;
        SELECT nombre INTO v_nombre_admin FROM usuario WHERE idUsuario = p_id_usuario_admin LIMIT 1;
        
        UPDATE usuario 
        SET passwordUsuarioEnc = p_nuevo_password_hash,
            passwordUsuario = p_nuevo_password_hash
        WHERE idUsuario = p_id_usuario_target;
        
        INSERT INTO audit_log (tabla, id_registro, accion, usuario_id, usuario_nombre, descripcion)
        VALUES ('usuario', p_id_usuario_target, 'UPDATE', p_id_usuario_admin, v_nombre_admin,
            CONCAT('RESET PASSWORD: Admin ', v_nombre_admin, ' (id=', p_id_usuario_admin, 
                   ') restablecio la contrasena del usuario ', v_nombre_target, ' (id=', p_id_usuario_target, ')'));
        
        SET p_resultado = 'success';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-02 14:17:52
