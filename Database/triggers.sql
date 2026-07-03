
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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER audit_tkt_insert
AFTER INSERT ON tkt
FOR EACH ROW
BEGIN
  INSERT INTO audit_log
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_nuevos, fecha, descripcion)
  VALUES
  ('tkt', NEW.Id_Tkt, 'INSERT', NEW.Id_Usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.Id_Usuario),
   CONCAT(
     '{"estado":', COALESCE(NEW.Id_Estado, 'null'),
     ',"prioridad":', COALESCE(NEW.Id_Prioridad, 'null'),
     ',"departamento":', COALESCE(NEW.Id_Departamento, 'null'),
     ',"empresa":', COALESCE(NEW.Id_Empresa, 'null'),
     ',"asignado":', COALESCE(NEW.Id_Usuario_Asignado, 'null'),
     ',"motivo":', COALESCE(NEW.Id_Motivo, 'null'),
     '}'
   ),
   NOW(),
   CONCAT('Nuevo ticket #', NEW.Id_Tkt, ' creado por usuario ', COALESCE(NEW.Id_Usuario, 'N/A')));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER audit_tkt_update
AFTER UPDATE ON tkt
FOR EACH ROW
BEGIN
  INSERT INTO audit_log
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion)
  VALUES
  ('tkt', NEW.Id_Tkt, 'UPDATE', NEW.Id_Usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.Id_Usuario),
   CONCAT(
     '{"estado":', COALESCE(OLD.Id_Estado, 'null'),
     ',"prioridad":', COALESCE(OLD.Id_Prioridad, 'null'),
     ',"departamento":', COALESCE(OLD.Id_Departamento, 'null'),
     ',"asignado":', COALESCE(OLD.Id_Usuario_Asignado, 'null'),
     ',"motivo":', COALESCE(OLD.Id_Motivo, 'null'),
     '}'
   ),
   CONCAT(
     '{"estado":', COALESCE(NEW.Id_Estado, 'null'),
     ',"prioridad":', COALESCE(NEW.Id_Prioridad, 'null'),
     ',"departamento":', COALESCE(NEW.Id_Departamento, 'null'),
     ',"asignado":', COALESCE(NEW.Id_Usuario_Asignado, 'null'),
     ',"motivo":', COALESCE(NEW.Id_Motivo, 'null'),
     '}'
   ),
   NOW(),
   CONCAT('Ticket #', NEW.Id_Tkt, ' actualizado'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER audit_tkt_delete
AFTER DELETE ON tkt
FOR EACH ROW
BEGIN
  INSERT INTO audit_log
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, fecha, descripcion)
  VALUES
  ('tkt', OLD.Id_Tkt, 'DELETE', OLD.Id_Usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = OLD.Id_Usuario),
   CONCAT(
     '{"estado":', COALESCE(OLD.Id_Estado, 'null'),
     ',"prioridad":', COALESCE(OLD.Id_Prioridad, 'null'),
     ',"departamento":', COALESCE(OLD.Id_Departamento, 'null'),
     ',"asignado":', COALESCE(OLD.Id_Usuario_Asignado, 'null'),
     ',"contenido":"', REPLACE(COALESCE(LEFT(OLD.Contenido, 200), ''), '"', '\\"'), '"',
     '}'
   ),
   NOW(),
   CONCAT('Ticket #', OLD.Id_Tkt, ' eliminado'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER audit_comentario_insert 
AFTER INSERT ON tkt_comentario 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_nuevos, fecha, descripcion) 
  VALUES 
  ('tkt_comentario', NEW.id_comentario, 'INSERT', NEW.id_usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.id_usuario),
   NEW.comentario,
   NOW(),
   CONCAT('Comentario ', NEW.id_comentario, ' añadido al ticket ', NEW.id_tkt));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER audit_comentario_update 
AFTER UPDATE ON tkt_comentario 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion) 
  VALUES 
  ('tkt_comentario', NEW.id_comentario, 'UPDATE', NEW.id_usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.id_usuario),
   OLD.comentario,
   NEW.comentario,
   NOW(),
   CONCAT('Comentario ', NEW.id_comentario, ' actualizado en ticket ', NEW.id_tkt));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER audit_comentario_delete 
AFTER DELETE ON tkt_comentario 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, fecha, descripcion) 
  VALUES 
  ('tkt_comentario', OLD.id_comentario, 'DELETE', OLD.id_usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = OLD.id_usuario),
   OLD.comentario,
   NOW(),
   CONCAT('Comentario ', OLD.id_comentario, ' eliminado del ticket ', OLD.id_tkt));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
ALTER DATABASE `cdk_tkt_dev` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER audit_transicion_estado
AFTER INSERT ON tkt_transicion
FOR EACH ROW
BEGIN
  INSERT INTO audit_log
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_nuevos, fecha, descripcion)
  VALUES
  ('tkt_transicion', NEW.id_transicion, 'INSERT', NEW.id_usuario_actor,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.id_usuario_actor),
   CONCAT(
     '{"ticket":', COALESCE(NEW.id_tkt, 'null'),
     ',"estado_from":', COALESCE(NEW.estado_from, 'null'),
     ',"estado_to":', COALESCE(NEW.estado_to, 'null'),
     ',"asignado_old":', COALESCE(NEW.id_usuario_asignado_old, 'null'),
     ',"asignado_new":', COALESCE(NEW.id_usuario_asignado_new, 'null'),
     '}'
   ),
   NOW(),
   CONCAT('Ticket #', COALESCE(NEW.id_tkt, '?'), ' transicion de estado ', COALESCE(NEW.estado_from, '?'), ' -> ', COALESCE(NEW.estado_to, '?')));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

