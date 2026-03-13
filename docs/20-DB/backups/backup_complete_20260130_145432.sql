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
-- Table structure for table `accion`
--

DROP TABLE IF EXISTS `accion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accion` (
  `idAccion` bigint(20) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(1) NOT NULL,
  `nombre` varchar(30) DEFAULT NULL,
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idAccion`,`codigo`),
  KEY `KEY_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accion`
--

LOCK TABLES `accion` WRITE;
/*!40000 ALTER TABLE `accion` DISABLE KEYS */;
INSERT INTO `accion` VALUES (1,'A','Alta',0),(2,'B','Baja',0),(3,'M','Modificar',0),(4,'V','Ver',0);
/*!40000 ALTER TABLE `accion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_log` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `tabla` varchar(50) NOT NULL,
  `id_registro` bigint(20) DEFAULT NULL,
  `accion` enum('INSERT','UPDATE','DELETE') NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `usuario_nombre` varchar(50) DEFAULT NULL,
  `valores_antiguos` text,
  `valores_nuevos` text,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(15) DEFAULT NULL,
  `descripcion` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_auditoria`),
  KEY `idx_auditoria_tabla_fecha` (`tabla`,`fecha`),
  KEY `idx_auditoria_usuario_fecha` (`usuario_id`,`fecha`),
  KEY `idx_auditoria_id_registro` (`tabla`,`id_registro`),
  KEY `idx_auditoria_accion` (`accion`,`fecha`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departamento`
--

DROP TABLE IF EXISTS `departamento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `departamento` (
  `Id_Departamento` int(20) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`Id_Departamento`),
  UNIQUE KEY `uq_depto_nombre` (`Nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departamento`
--

LOCK TABLES `departamento` WRITE;
/*!40000 ALTER TABLE `departamento` DISABLE KEYS */;
INSERT INTO `departamento` VALUES (59,'Administración'),(13,'Aplicaciones Corporativas / ERP'),(47,'Archivo y Entrega de Estudios'),(17,'Atención al Cliente'),(34,'Atención al Paciente'),(12,'Bases de Datos / DBA'),(14,'BI / Analítica'),(33,'Caja / Facturación / Autorizaciones'),(21,'Calidad'),(48,'Calidad Clínica / Protocolos'),(61,'Calidad y Auditoría'),(66,'Comercial'),(22,'Compras / Abastecimiento'),(57,'Compras / Suministros (Insumos Radiológicos)'),(49,'Consultorios'),(25,'Créditos y Cobranzas'),(40,'Densitometría Ósea (DEXA)'),(1,'Departamento A'),(2,'Departamento B'),(3,'Departamento C'),(10,'Desarrollo de Software'),(29,'Dirección / Gerencia'),(64,'Dirección General / Gerencia'),(63,'Dirección Médica'),(38,'Ecografía'),(23,'Finanzas / Contabilidad'),(15,'Gestión de Servicios (ITSM)'),(6,'Infraestructura'),(53,'Integraciones HIS/EMR (HL7/DICOM)'),(45,'Jefatura de Diagnóstico por Imágenes'),(50,'Kinesiología y Rehabilitación'),(28,'Legal'),(60,'Legales y Compliance'),(19,'Logística'),(39,'Mamografía'),(56,'Mantenimiento Biomédico'),(55,'Mantenimiento Edilicio'),(27,'Marketing / Comunicación'),(62,'Marketing / Comunicación Institucional'),(41,'Medicina Nuclear'),(43,'Médicos Informantes (Radiología)'),(4,'Mesa de Ayuda / Soporte N1'),(18,'Operaciones'),(52,'PACS / RIS'),(20,'Producción'),(46,'Protección Radiológica / Física Médica'),(11,'QA / Testing'),(35,'Radiología Convencional (Rayos X)'),(42,'Radiología Intervencionista / Hemodinamia'),(31,'Recepción y Admisión'),(26,'Recursos Humanos'),(7,'Redes'),(37,'Resonancia Magnética (RM)'),(68,'RRHH'),(54,'Seguridad de la Información'),(9,'Seguridad Informática'),(58,'Servicios Generales / Limpieza'),(65,'Sistemas'),(51,'Sistemas / Soluciones IT'),(5,'Soporte N2 / Plataformas'),(30,'Sucursales / Oficinas'),(44,'Técnicos Radiólogos'),(8,'Telecomunicaciones'),(24,'Tesorería'),(36,'Tomografía Computada (TC)'),(32,'Turnos / Call Center'),(16,'Ventas / Comercial');
/*!40000 ALTER TABLE `departamento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empresa`
--

DROP TABLE IF EXISTS `empresa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `empresa` (
  `idEmpresa` bigint(20) NOT NULL AUTO_INCREMENT,
  `cuit` varchar(11) DEFAULT NULL COMMENT 'cuit de la empresa sin guion',
  `nombre` varchar(50) DEFAULT NULL COMMENT 'descripcion o razon social',
  `codigo` varchar(3) DEFAULT NULL COMMENT 'codigo de la empresa',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idEmpresa`),
  KEY `KEY_cuit` (`cuit`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empresa`
--

LOCK TABLES `empresa` WRITE;
/*!40000 ALTER TABLE `empresa` DISABLE KEYS */;
INSERT INTO `empresa` VALUES (1,'30708839309','CEDIAC BERAZATEGUI S.R.L.','CDK',0),(2,'30714800392','SUR SALUDPYME S.R.L.','SUR',0);
/*!40000 ALTER TABLE `empresa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estado`
--

DROP TABLE IF EXISTS `estado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estado` (
  `Id_Estado` int(11) NOT NULL AUTO_INCREMENT,
  `TipoEstado` varchar(100) NOT NULL,
  PRIMARY KEY (`Id_Estado`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estado`
--

LOCK TABLES `estado` WRITE;
/*!40000 ALTER TABLE `estado` DISABLE KEYS */;
INSERT INTO `estado` VALUES (1,'Abierto'),(2,'En Proceso'),(3,'Cerrado'),(4,'En Espera'),(5,'Pendiente Aprobación'),(6,'Resuelto'),(7,'Reabierto');
/*!40000 ALTER TABLE `estado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_login_attempts`
--

DROP TABLE IF EXISTS `failed_login_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `failed_login_attempts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_nombre` varchar(50) DEFAULT NULL,
  `ip_address` varchar(15) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `razon` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_failed_login_usuario_fecha` (`usuario_nombre`,`fecha`),
  KEY `idx_failed_login_ip_fecha` (`ip_address`,`fecha`),
  KEY `idx_failed_login_reciente` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_login_attempts`
--

LOCK TABLES `failed_login_attempts` WRITE;
/*!40000 ALTER TABLE `failed_login_attempts` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_login_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grupo`
--

DROP TABLE IF EXISTS `grupo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grupo` (
  `Id_Grupo` int(11) NOT NULL AUTO_INCREMENT,
  `Tipo_Grupo` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Id_Grupo`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupo`
--

LOCK TABLES `grupo` WRITE;
/*!40000 ALTER TABLE `grupo` DISABLE KEYS */;
INSERT INTO `grupo` VALUES (1,'admin'),(2,'usuario'),(3,'Test'),(4,'Test'),(5,NULL);
/*!40000 ALTER TABLE `grupo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `motivo`
--

DROP TABLE IF EXISTS `motivo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `motivo` (
  `Id_Motivo` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Categoria` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Id_Motivo`),
  UNIQUE KEY `uq_motivo_nombre_cat` (`Nombre`,`Categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `motivo`
--

LOCK TABLES `motivo` WRITE;
/*!40000 ALTER TABLE `motivo` DISABLE KEYS */;
INSERT INTO `motivo` VALUES (5,'Autorización de Obra Social',NULL),(36,'Calibración / Control de Calidad',NULL),(45,'Consulta','Información'),(39,'Consultorios - Agenda / Atención',NULL),(34,'CR/DR - Digitalizador - Falla',NULL),(18,'DEXA - Orden / Preparación',NULL),(16,'Ecografía - Agenda / Preparación',NULL),(31,'Ecógrafo - Falla',NULL),(8,'Entrega de Estudios / Duplicado',NULL),(28,'Equipamiento RX - Falla',NULL),(6,'Facturación / Cobranza',NULL),(37,'Gestión de Incidentes (Seguridad Info)',NULL),(26,'HIS/EMR - Interfaz HL7',NULL),(33,'Impresora Dry - Falla / Insumos',NULL),(43,'Incidente','Soporte'),(20,'Informe - Aclaración / Addendum',NULL),(21,'Informe - Corrección de Datos',NULL),(19,'Informe - Retraso',NULL),(40,'Infraestructura - Climatización',NULL),(41,'Infraestructura - Electricidad',NULL),(38,'Kinesiología - Agenda / Práctica',NULL),(17,'Mamografía - Orden / Preparación',NULL),(32,'Mamógrafo - Falla',NULL),(1,'Motivo A',NULL),(2,'Motivo B',NULL),(3,'Motivo C',NULL),(23,'PACS - Envío/Recepción DICOM',NULL),(22,'PACS - Visualización de Imágenes',NULL),(27,'Portal Paciente / Médicos - Acceso',NULL),(35,'Protección Radiológica',NULL),(10,'Rayos X - Orden / Preparación',NULL),(11,'Rayos X - Resultado / Entrega',NULL),(7,'Recepción / Admisión',NULL),(30,'Resonador - Falla',NULL),(15,'Resonancia - Implantes / Contraindicaciones',NULL),(14,'Resonancia - Orden / Preparación',NULL),(24,'RIS - Agenda / Admisión',NULL),(25,'RIS - Falla de Integración',NULL),(9,'Satisfacción del Paciente / Queja',NULL),(42,'Servicios - Limpieza / Residuos Patológicos',NULL),(44,'Solicitud','Servicio'),(13,'Tomografía - Contraste / Reacción',NULL),(12,'Tomografía - Orden / Preparación',NULL),(29,'Tomógrafo - Falla',NULL),(4,'Turno / Reprogramación',NULL);
/*!40000 ALTER TABLE `motivo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificaciones`
--

DROP TABLE IF EXISTS `notificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones` (
  `Id_Notificacion` bigint(20) NOT NULL AUTO_INCREMENT,
  `Id_Usuario` bigint(20) NOT NULL,
  `Mensaje` varchar(255) NOT NULL,
  `Fecha_Creacion` datetime NOT NULL,
  `Leida` int(1) DEFAULT '0',
  PRIMARY KEY (`Id_Notificacion`),
  KEY `Id_Usuario` (`Id_Usuario`),
  CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`Id_Usuario`) REFERENCES `usuario` (`idUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificaciones`
--

LOCK TABLES `notificaciones` WRITE;
/*!40000 ALTER TABLE `notificaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `notificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perfil`
--

DROP TABLE IF EXISTS `perfil`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `perfil` (
  `idPerfil` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id de perfil',
  `nombre` varchar(30) NOT NULL COMMENT 'descripcion o nombre del perfil',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idPerfil`),
  KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfil`
--

LOCK TABLES `perfil` WRITE;
/*!40000 ALTER TABLE `perfil` DISABLE KEYS */;
INSERT INTO `perfil` VALUES (1,'Operador',0),(2,'Auditor Médico',0),(3,'Supervisor',0),(4,'Administrador',0),(5,'Prestador',0),(6,'Operador internación',0),(7,'Auditor internación',0),(8,'Médico informante',0),(9,'Técnica/o',0),(10,'Secretaria/o',0),(11,'Técnica/o Jefe',0),(12,'Consulta',0);
/*!40000 ALTER TABLE `perfil` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perfil_accion_sistema`
--

DROP TABLE IF EXISTS `perfil_accion_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `perfil_accion_sistema` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `idPerfil` bigint(20) DEFAULT '0' COMMENT 'idPerfil (Perfil)',
  `codigoAccion` varchar(20) DEFAULT NULL COMMENT 'codigo (accion) concatenados por coma',
  `idSistema` varchar(8) DEFAULT NULL COMMENT 'idSistema (sistema)',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`ID`),
  KEY `KEY_perfil` (`idPerfil`),
  KEY `KEY_accion` (`codigoAccion`),
  KEY `KEY_sistema` (`idSistema`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfil_accion_sistema`
--

LOCK TABLES `perfil_accion_sistema` WRITE;
/*!40000 ALTER TABLE `perfil_accion_sistema` DISABLE KEYS */;
INSERT INTO `perfil_accion_sistema` VALUES (1,1,'A,B,M,V','CDK_CNS',0),(2,3,'A,B,M,V','CDK_CNS',0),(3,4,'A,B,M,V','CDK_CNS',0),(4,1,'A,B,M,V','CDK_AUT',0),(5,2,'A,B,M,V','CDK_AUT',0),(6,3,'A,B,M,V','CDK_AUT',0),(7,4,'A,B,M,V','CDK_AUT',0),(8,5,'A,B,M,V','CDK_AUT',0),(9,6,'A,B,M,V','CDK_AUT',0),(10,7,'A,B,M,V','CDK_AUT',0),(11,1,'A,B,M,V','CDK_PAD',0),(12,3,'A,B,M,V','CDK_PAD',0),(13,4,'A,B,M,V','CDK_PAD',0),(14,1,'A,B,M,V','CDK_EST',0),(15,4,'A,B,M,V','CDK_EST',0),(16,1,'A,B,M,V','CDK_RYS',0),(17,4,'A,B,M,V','CDK_RYS',0),(18,1,'A,B,M,V','CDK_STK',0),(19,3,'A,B,M,V','CDK_STK',0),(20,4,'A,B,M,V','CDK_STK',0),(21,8,'A,B,M,V','CDK_EST',0),(22,1,'A,B,M,V','CDK_FIS',0),(23,3,'A,B,M,V','CDK_FIS',0),(24,4,'A,B,M,V','CDK_FIS',0),(25,9,'A,B,M,V','CDK_EST',0),(26,10,'A,B,M,V','CDK_EST',0),(27,11,'A,B,M,V','CDK_EST',0);
/*!40000 ALTER TABLE `perfil_accion_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permiso`
--

DROP TABLE IF EXISTS `permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permiso` (
  `idPermiso` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(64) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`idPermiso`),
  UNIQUE KEY `uq_permiso_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permiso`
--

LOCK TABLES `permiso` WRITE;
/*!40000 ALTER TABLE `permiso` DISABLE KEYS */;
INSERT INTO `permiso` VALUES (1,'TKT_CREATE','Crear tickets'),(2,'TKT_LIST_ALL','Listar todos'),(3,'TKT_LIST_ASSIGNED','Listar asignados'),(4,'TKT_EDIT_ANY','Editar cualquiera'),(5,'TKT_EDIT_ASSIGNED','Editar asignados'),(6,'TKT_DELETE','Eliminar'),(7,'TKT_APPROVE','Aprobar'),(8,'TKT_COMMENT','Comentar'),(9,'TKT_START','Iniciar'),(10,'TKT_RESOLVE','Resolver'),(11,'TKT_EXPORT','Exportar'),(12,'TKT_WAIT','Poner en espera'),(13,'TKT_REQUEST_APPROVAL','Solicitar aprobación'),(14,'TKT_CLOSE','Cerrar'),(15,'TKT_REOPEN','Reabrir'),(16,'TKT_RBAC_ADMIN','Admin RBAC');
/*!40000 ALTER TABLE `permiso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prioridad`
--

DROP TABLE IF EXISTS `prioridad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prioridad` (
  `Id_Prioridad` int(11) NOT NULL AUTO_INCREMENT,
  `NombrePrioridad` varchar(100) NOT NULL,
  PRIMARY KEY (`Id_Prioridad`),
  UNIQUE KEY `uq_prioridad_nombre` (`NombrePrioridad`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prioridad`
--

LOCK TABLES `prioridad` WRITE;
/*!40000 ALTER TABLE `prioridad` DISABLE KEYS */;
INSERT INTO `prioridad` VALUES (1,'Alta'),(3,'Baja'),(7,'Crítica'),(2,'Media');
/*!40000 ALTER TABLE `prioridad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rol` (
  `idRol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(64) NOT NULL,
  PRIMARY KEY (`idRol`),
  UNIQUE KEY `uq_rol_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol`
--

LOCK TABLES `rol` WRITE;
/*!40000 ALTER TABLE `rol` DISABLE KEYS */;
INSERT INTO `rol` VALUES (10,'Administrador'),(2,'Agente'),(11,'Aprobador'),(12,'Consulta'),(3,'Operador'),(1,'Supervisor');
/*!40000 ALTER TABLE `rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol_permiso`
--

DROP TABLE IF EXISTS `rol_permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rol_permiso` (
  `idRol` int(11) NOT NULL,
  `idPermiso` int(11) NOT NULL,
  PRIMARY KEY (`idRol`,`idPermiso`),
  KEY `fk_rol_permiso_permiso` (`idPermiso`),
  CONSTRAINT `fk_rol_permiso_permiso` FOREIGN KEY (`idPermiso`) REFERENCES `permiso` (`idPermiso`) ON DELETE CASCADE,
  CONSTRAINT `fk_rol_permiso_rol` FOREIGN KEY (`idRol`) REFERENCES `rol` (`idRol`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol_permiso`
--

LOCK TABLES `rol_permiso` WRITE;
/*!40000 ALTER TABLE `rol_permiso` DISABLE KEYS */;
INSERT INTO `rol_permiso` VALUES (1,1),(3,1),(10,1),(11,1),(12,1),(1,2),(10,2),(2,3),(3,3),(1,4),(10,4),(2,5),(3,5),(10,5),(10,6),(1,7),(10,7),(2,8),(3,8),(2,9),(3,9),(1,10),(2,10),(3,10),(10,10),(1,11),(10,11),(1,12),(10,12),(1,13),(2,13),(10,13),(1,14),(10,14),(1,15),(2,15),(10,15),(10,16);
/*!40000 ALTER TABLE `rol_permiso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sesiones`
--

DROP TABLE IF EXISTS `sesiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sesiones` (
  `id_sesion` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` bigint(20) NOT NULL,
  `refresh_token_hash` varchar(512) NOT NULL,
  `access_token_hash` varchar(512) DEFAULT NULL,
  `fecha_inicio` datetime DEFAULT NULL,
  `fecha_vencimiento` datetime DEFAULT NULL,
  `ip_address` varchar(15) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `activa` tinyint(1) DEFAULT '1',
  `fecha_cierre` datetime DEFAULT NULL,
  PRIMARY KEY (`id_sesion`),
  KEY `idx_sesiones_usuario_activa` (`id_usuario`,`activa`),
  KEY `idx_sesiones_token_fecha` (`fecha_vencimiento`,`activa`),
  KEY `idx_sesiones_ip` (`ip_address`,`fecha_inicio`),
  CONSTRAINT `sesiones_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sesiones`
--

LOCK TABLES `sesiones` WRITE;
/*!40000 ALTER TABLE `sesiones` DISABLE KEYS */;
/*!40000 ALTER TABLE `sesiones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sistema`
--

DROP TABLE IF EXISTS `sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sistema` (
  `idSistema` varchar(8) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idSistema`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sistema`
--

LOCK TABLES `sistema` WRITE;
/*!40000 ALTER TABLE `sistema` DISABLE KEYS */;
INSERT INTO `sistema` VALUES ('CDK_AUT','AUTORIZACIONES',0),('CDK_CNS','CONSUMOS',0),('CDK_CNV','CONVENIOS',0),('CDK_EST','IMÁGENES',0),('CDK_FIS','FISIO',0),('CDK_HUB','HUB',0),('CDK_NYP','NORMAS Y PROCEDIMIENTOS',0),('CDK_PAD','PADRÓN',0),('CDK_RYS','RECLAMOS/SUGERENCIAS',0),('CDK_STK','STOCK',0),('CDK_TKT','TICKETS',1),('CDK_TUR','TURNOS',0);
/*!40000 ALTER TABLE `sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sucursal`
--

DROP TABLE IF EXISTS `sucursal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sucursal` (
  `idSucursal` bigint(20) NOT NULL AUTO_INCREMENT,
  `idEmpresa` bigint(20) NOT NULL DEFAULT '0',
  `descripcion` varchar(50) NOT NULL,
  `codigo` varchar(6) DEFAULT NULL,
  `domicilio` varchar(150) DEFAULT NULL,
  `telefono` varchar(60) DEFAULT NULL,
  `email` varchar(60) DEFAULT NULL,
  `afip` varchar(4) NOT NULL DEFAULT '1000',
  `habilitado` int(1) DEFAULT '0',
  PRIMARY KEY (`idSucursal`),
  UNIQUE KEY `uq_sucursal_desc` (`descripcion`),
  KEY `KEY_empresa` (`idEmpresa`),
  KEY `KEY_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sucursal`
--

LOCK TABLES `sucursal` WRITE;
/*!40000 ALTER TABLE `sucursal` DISABLE KEYS */;
INSERT INTO `sucursal` VALUES (1,1,'CALLE 10','C10','CALLE 10 5085 E/ 150 Y 151 - BERAZATEGUI','42568000',NULL,'1001',0),(2,1,'CALLE 7','C7','CALLE 7 4655 E/ 146 Y 147 - BERAZATEGUI',NULL,NULL,'1002',0),(3,2,'SAN JUSTO','C6','AV. MITRE 580 - BERAZATEGUI',NULL,NULL,'1001',1),(4,2,'MORENO 500','QM500','MORENO 522 - QUILMES',NULL,NULL,'1001',1),(5,2,'CAP QUILMES','CENT','CENTRAL DE GESTION',NULL,NULL,'1001',1),(6,1,'CAPILLA','CAPI',NULL,NULL,NULL,'1004',1),(7,1,'CENTRO MEDICO MONTEA','CMM','BERNARDO DE MONTEAGUDO 2632 - F. VARELA',NULL,NULL,'1005',1),(8,1,'H. PRIMO 343','HP343','HUMBERTO PRIMO 343 - QUILMES',NULL,NULL,'1006',0),(9,1,'SOLANO','SOL',NULL,NULL,NULL,'1000',1),(10,0,'Casa Central',NULL,NULL,NULL,NULL,'1000',0),(11,0,'Sucursal Norte',NULL,NULL,NULL,NULL,'1000',0),(12,0,'Sucursal Sur',NULL,NULL,NULL,NULL,'1000',0);
/*!40000 ALTER TABLE `sucursal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tkt`
--

DROP TABLE IF EXISTS `tkt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt` (
  `Id_Tkt` bigint(20) NOT NULL AUTO_INCREMENT,
  `Id_Estado` int(10) DEFAULT '1',
  `Date_Creado` datetime DEFAULT NULL,
  `Date_Cierre` datetime DEFAULT NULL,
  `Date_Asignado` datetime DEFAULT NULL,
  `Date_Cambio_Estado` datetime DEFAULT NULL,
  `Id_Usuario` bigint(20) DEFAULT NULL,
  `Id_Usuario_Asignado` bigint(20) DEFAULT NULL,
  `Id_Empresa` bigint(20) DEFAULT NULL,
  `Id_Perfil` bigint(20) DEFAULT NULL,
  `Id_Motivo` int(20) DEFAULT NULL,
  `Id_Sucursal` bigint(20) DEFAULT NULL,
  `Habilitado` int(20) DEFAULT '1',
  `Id_Prioridad` int(20) DEFAULT NULL,
  `Contenido` text,
  `Id_Departamento` int(11) DEFAULT NULL,
  PRIMARY KEY (`Id_Tkt`),
  KEY `IX_tkt_Filtros` (`Id_Estado`,`Id_Prioridad`,`Id_Departamento`,`Date_Creado`),
  KEY `IX_tkt_DateCreado` (`Date_Creado`),
  KEY `IX_tkt_Usuario` (`Id_Usuario`),
  KEY `idx_tkt_estado` (`Id_Estado`),
  KEY `idx_tkt_prioridad` (`Id_Prioridad`),
  KEY `idx_tkt_departamento` (`Id_Departamento`),
  KEY `idx_tkt_usuario` (`Id_Usuario`),
  KEY `idx_tkt_creado` (`Date_Creado`),
  KEY `ix_tkt_estado_hab_fecha` (`Id_Estado`,`Habilitado`,`Date_Creado`),
  KEY `ix_tkt_usuario_fecha` (`Id_Usuario`,`Date_Creado`),
  KEY `ix_tkt_asignado_estado` (`Id_Usuario_Asignado`,`Id_Estado`),
  KEY `ix_tkt_depto_fecha` (`Id_Departamento`,`Date_Creado`),
  KEY `ix_tkt_prioridad_fecha` (`Id_Prioridad`,`Date_Creado`),
  KEY `ix_tkt_motivo_fecha` (`Id_Motivo`,`Date_Creado`),
  KEY `ix_tkt_estado_cierre` (`Id_Estado`,`Date_Cierre`),
  KEY `idx_tkt_estado_fecha` (`Id_Estado`,`Date_Creado`),
  KEY `idx_tkt_asignado_estado_fecha` (`Id_Usuario_Asignado`,`Id_Estado`,`Date_Creado`),
  KEY `idx_tkt_usuario_estado_fecha` (`Id_Usuario`,`Id_Estado`,`Date_Creado`),
  KEY `idx_tkt_depto_estado_fecha` (`Id_Departamento`,`Id_Estado`,`Date_Creado`),
  KEY `idx_tkt_motivo_estado_fecha` (`Id_Motivo`,`Id_Estado`,`Date_Creado`),
  KEY `idx_tkt_prioridad_estado_fecha` (`Id_Prioridad`,`Id_Estado`,`Date_Creado`),
  KEY `idx_tkt_contenido_prefix` (`Contenido`(50)),
  KEY `fk_tkt_empresa` (`Id_Empresa`),
  KEY `fk_tkt_sucursal` (`Id_Sucursal`),
  KEY `fk_tkt_perfil` (`Id_Perfil`),
  CONSTRAINT `fk_tkt_perfil` FOREIGN KEY (`Id_Perfil`) REFERENCES `perfil` (`idPerfil`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tkt_depto` FOREIGN KEY (`Id_Departamento`) REFERENCES `departamento` (`Id_Departamento`),
  CONSTRAINT `fk_tkt_empresa` FOREIGN KEY (`Id_Empresa`) REFERENCES `empresa` (`idEmpresa`) ON UPDATE CASCADE,
  CONSTRAINT `fk_tkt_estado` FOREIGN KEY (`Id_Estado`) REFERENCES `estado` (`Id_Estado`),
  CONSTRAINT `fk_tkt_motivo` FOREIGN KEY (`Id_Motivo`) REFERENCES `motivo` (`Id_Motivo`),
  CONSTRAINT `fk_tkt_prioridad` FOREIGN KEY (`Id_Prioridad`) REFERENCES `prioridad` (`Id_Prioridad`),
  CONSTRAINT `fk_tkt_sucursal` FOREIGN KEY (`Id_Sucursal`) REFERENCES `sucursal` (`idSucursal`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tkt_usuario_asignado` FOREIGN KEY (`Id_Usuario_Asignado`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tkt_usuario_creador` FOREIGN KEY (`Id_Usuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt`
--

LOCK TABLES `tkt` WRITE;
/*!40000 ALTER TABLE `tkt` DISABLE KEYS */;
INSERT INTO `tkt` VALUES (1,2,'2025-11-18 14:19:44',NULL,'2025-11-18 14:25:47','2026-01-27 14:58:02',1,2,0,4,6,2,0,1,'esto es una prueba',21),(2,1,'2025-11-21 11:35:49',NULL,'2025-12-04 13:13:44',NULL,1,1,0,4,39,10,1,7,'Esto es una prueba Beta',59),(3,3,'2025-11-21 11:59:22',NULL,'2025-11-21 11:59:32','2025-12-09 13:09:42',1,3,0,4,6,1,1,2,'Prueba de seguimiento',66),(4,2,'2025-11-21 12:33:30',NULL,'2025-12-04 13:04:38','2025-11-21 13:52:28',1,2,0,4,5,1,1,3,'aaaaaaaaaaaaaaaaaaaa sssssssss',59),(5,2,'2025-11-21 14:36:17',NULL,'2025-12-09 11:38:55','2025-12-04 11:18:03',1,2,0,4,8,2,1,2,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',66),(6,3,'2025-12-04 10:29:13',NULL,'2025-12-09 12:01:53','2025-12-09 13:37:17',1,2,0,4,18,2,0,2,'Esto es un test',13),(8,1,'2025-12-23 14:37:07',NULL,NULL,NULL,1,2,NULL,NULL,6,NULL,1,1,'test swager',1),(9,1,'2025-12-23 14:47:36',NULL,NULL,NULL,1,NULL,1,0,3,0,1,1,'test swager 2',1),(10,1,'2026-01-23 13:50:49',NULL,NULL,NULL,1,NULL,1,0,NULL,0,1,1,'Ticket de prueba QA - 2026-01-23T13:50:49.120178',1),(11,1,'2026-01-27 12:34:51',NULL,NULL,NULL,1,NULL,1,0,1,0,1,1,'test creacion de ticket swagger',1),(12,1,'2026-01-27 13:00:43',NULL,NULL,NULL,1,NULL,1,0,5,0,1,1,'Ticket integración 1769529643',59),(13,1,'2026-01-27 13:02:01',NULL,NULL,NULL,1,NULL,1,0,5,0,1,1,'Ticket integración 1769529721',59),(14,1,'2026-01-27 13:04:32',NULL,NULL,NULL,1,NULL,1,0,5,0,1,1,'Ticket integración 1769529871',59),(15,1,'2026-01-27 13:05:16',NULL,NULL,NULL,1,NULL,1,0,5,0,1,1,'Ticket integración 1769529915',59),(16,1,'2026-01-27 13:06:56',NULL,NULL,NULL,1,NULL,1,0,5,0,1,1,'Ticket integración 1769530016',59),(17,1,'2026-01-27 13:13:32',NULL,NULL,'2026-01-27 13:13:33',1,1,1,0,NULL,0,1,1,'Test 1769530412',59),(18,1,'2026-01-27 13:15:22',NULL,NULL,'2026-01-27 13:15:22',1,1,1,0,NULL,0,1,1,'Test 1769530522',59),(19,1,'2026-01-27 13:23:14',NULL,NULL,'2026-01-27 13:23:14',1,1,1,0,NULL,0,1,1,'Test 1769530994',59),(20,1,'2026-01-27 13:23:42',NULL,NULL,'2026-01-27 13:23:43',1,1,1,0,NULL,0,1,1,'Test 1769531022',59),(21,1,'2026-01-27 13:41:06',NULL,NULL,NULL,1,NULL,1,0,NULL,0,1,1,'Test 1769532066',59),(22,1,'2026-01-27 13:41:37',NULL,NULL,NULL,1,NULL,1,0,NULL,0,1,1,'Test 1769532097',59),(23,1,'2026-01-27 13:54:54',NULL,NULL,NULL,1,NULL,1,0,NULL,0,1,1,'Test 1769532894',59),(24,1,'2026-01-27 13:55:11',NULL,NULL,NULL,1,NULL,1,0,NULL,0,1,1,'Test 1769532911',59),(25,1,'2026-01-27 13:56:14',NULL,NULL,NULL,1,NULL,1,0,NULL,0,1,1,'Test 1769532974',59),(26,1,'2026-01-27 13:57:37',NULL,NULL,'2026-01-27 13:57:38',1,2,1,0,NULL,0,1,1,'Test 1769533057',59),(27,1,'2026-01-27 13:58:45',NULL,NULL,'2026-01-27 13:58:46',1,2,1,0,NULL,0,1,1,'Test 1769533125',59),(28,1,'2026-01-27 14:44:13',NULL,NULL,'2026-01-27 14:44:14',1,2,1,0,NULL,0,1,1,'Test 1769535853',59),(29,1,'2026-01-27 14:45:07',NULL,NULL,'2026-01-27 14:45:07',1,2,1,0,NULL,0,1,1,'Test 1769535907',59),(30,1,'2026-01-27 14:48:55',NULL,NULL,'2026-01-27 14:48:55',1,2,1,0,NULL,0,1,1,'Test 1769536135',59),(31,1,'2026-01-27 15:01:23',NULL,NULL,'2026-01-27 15:01:23',1,2,1,0,NULL,0,1,1,'Test 1769536883',59);
/*!40000 ALTER TABLE `tkt` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
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
   CONCAT('Ticket creado - Empresa: ', NEW.Id_Empresa, ', Asignado a: ', NEW.Id_Usuario_Asignado),
   NOW(),
   CONCAT('Nuevo ticket ', NEW.Id_Tkt, ' creado por usuario ', NEW.Id_Usuario));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
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
   CONCAT('Estado: ', OLD.Id_Estado, ', Usuario Asignado: ', OLD.Id_Usuario_Asignado),
   CONCAT('Estado: ', NEW.Id_Estado, ', Usuario Asignado: ', NEW.Id_Usuario_Asignado),
   NOW(),
   CONCAT('Ticket ', NEW.Id_Tkt, ' actualizado'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
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
   CONCAT('Contenido: ', OLD.Contenido),
   NOW(),
   CONCAT('Ticket ', OLD.Id_Tkt, ' eliminado'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tkt_aprobacion`
--

DROP TABLE IF EXISTS `tkt_aprobacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_aprobacion` (
  `id_aprob` bigint(20) NOT NULL AUTO_INCREMENT,
  `id_tkt` bigint(20) NOT NULL,
  `solicitante_id` bigint(20) DEFAULT NULL,
  `aprobador_id` bigint(20) DEFAULT NULL,
  `estado` enum('pendiente','aprobado','rechazado') NOT NULL DEFAULT 'pendiente',
  `comentario` varchar(1000) DEFAULT NULL,
  `fecha_solicitud` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_respuesta` datetime DEFAULT NULL,
  PRIMARY KEY (`id_aprob`),
  KEY `idx_pendientes` (`aprobador_id`,`estado`),
  KEY `idx_aprobacion_tkt_estado` (`id_tkt`,`estado`),
  KEY `fk_aprobacion_solicitante` (`solicitante_id`),
  CONSTRAINT `fk_aprobacion_aprobador` FOREIGN KEY (`aprobador_id`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_aprobacion_solicitante` FOREIGN KEY (`solicitante_id`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_aprobacion_tkt` FOREIGN KEY (`id_tkt`) REFERENCES `tkt` (`Id_Tkt`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_aprobacion`
--

LOCK TABLES `tkt_aprobacion` WRITE;
/*!40000 ALTER TABLE `tkt_aprobacion` DISABLE KEYS */;
INSERT INTO `tkt_aprobacion` VALUES (1,1,1,1,'pendiente','esto es una prueba de solicitud de aprobacion','2025-11-18 17:38:01',NULL),(2,1,1,1,'pendiente','Prueba B de solicitud','2025-11-21 13:59:59',NULL),(3,6,0,0,'pendiente',NULL,'2026-01-27 12:37:27',NULL),(4,21,1,0,'pendiente',NULL,'2026-01-27 16:41:07',NULL),(5,22,1,0,'pendiente',NULL,'2026-01-27 16:41:39',NULL),(6,24,1,0,'pendiente',NULL,'2026-01-27 16:55:14',NULL),(7,25,1,0,'pendiente',NULL,'2026-01-27 16:56:16',NULL),(8,26,1,0,'pendiente',NULL,'2026-01-27 16:57:39',NULL),(9,27,1,0,'pendiente',NULL,'2026-01-27 16:58:47',NULL),(10,28,1,0,'pendiente',NULL,'2026-01-27 17:44:15',NULL),(11,29,1,0,'pendiente',NULL,'2026-01-27 17:45:07',NULL),(12,30,1,0,'pendiente',NULL,'2026-01-27 17:48:56',NULL),(13,31,1,0,'pendiente',NULL,'2026-01-27 18:01:24',NULL);
/*!40000 ALTER TABLE `tkt_aprobacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tkt_comentario`
--

DROP TABLE IF EXISTS `tkt_comentario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_comentario` (
  `id_comentario` bigint(20) NOT NULL AUTO_INCREMENT,
  `id_tkt` bigint(20) NOT NULL,
  `id_usuario` bigint(20) DEFAULT NULL,
  `comentario` text NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_comentario`),
  KEY `idx_tkt_fecha` (`id_tkt`,`fecha`),
  KEY `fk_comentario_usuario` (`id_usuario`),
  CONSTRAINT `fk_comentario_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_comentario_tkt` FOREIGN KEY (`id_tkt`) REFERENCES `tkt` (`Id_Tkt`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_comentario`
--

LOCK TABLES `tkt_comentario` WRITE;
/*!40000 ALTER TABLE `tkt_comentario` DISABLE KEYS */;
INSERT INTO `tkt_comentario` VALUES (2,3,3,'prueba 1234','2025-11-21 15:01:26'),(3,3,3,'hola','2025-11-21 15:20:32'),(4,3,3,'tests','2025-11-21 15:21:53'),(5,4,3,'aaa','2025-11-21 16:33:13'),(6,4,1,'test edicion swagger','2025-11-21 16:52:28'),(7,4,1,'aaa','2025-11-21 17:04:46'),(8,4,1,'test test','2025-11-21 17:35:13'),(9,1,1,'test','2025-12-04 13:34:10'),(10,2,1,'[Asignación] aaaa','2025-12-04 15:55:39'),(11,4,1,'[Asignación] aaaaa','2025-12-04 16:04:38'),(12,6,1,'test','2025-12-04 16:33:10'),(13,6,1,'aaaaaaa','2025-12-04 16:33:20'),(14,6,1,'aaaaaa','2025-12-04 16:33:44'),(15,6,1,'test','2025-12-04 16:39:51'),(16,6,1,'aaa','2025-12-09 14:08:46'),(17,5,1,'[Asignación] aaa','2025-12-09 14:38:55'),(18,6,1,'[Asignación] asd','2025-12-09 14:54:30'),(19,6,1,'[Asignación] aa','2025-12-09 15:01:53'),(20,12,1,'Comentario integ 1769529644','2026-01-27 16:00:45'),(21,13,1,'Comentario integ 1769529721','2026-01-27 16:02:02'),(22,14,1,'Comentario integ 1769529872','2026-01-27 16:04:33'),(23,15,1,'Comentario integ 1769529917','2026-01-27 16:05:17'),(24,16,1,'Comentario integ 1769530017','2026-01-27 16:06:57'),(25,17,1,'Comment 1769530413','2026-01-27 16:13:33'),(26,18,1,'Comment 1769530522','2026-01-27 16:15:22'),(27,19,1,'Comment 1769530995','2026-01-27 16:23:15'),(28,20,1,'Comment 1769531023','2026-01-27 16:23:43'),(29,24,1,'Comentario 1769532912','2026-01-27 16:55:12'),(30,25,1,'Comentario 1769532975','2026-01-27 16:56:15'),(31,26,1,'Comentario 1769533058','2026-01-27 16:57:38'),(32,27,1,'Comentario 1769533126','2026-01-27 16:58:46'),(33,28,1,'Comentario 1769535854','2026-01-27 17:44:15'),(34,29,1,'Comentario 1769535907','2026-01-27 17:45:07'),(35,30,1,'Comentario 1769536135','2026-01-27 17:48:55'),(36,31,1,'Comentario 1769536883','2026-01-27 18:01:24');
/*!40000 ALTER TABLE `tkt_comentario` ENABLE KEYS */;
UNLOCK TABLES;
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

--
-- Table structure for table `tkt_permiso`
--

DROP TABLE IF EXISTS `tkt_permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_permiso` (
  `id_permiso` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `habilitado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_permiso`),
  UNIQUE KEY `codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_permiso`
--

LOCK TABLES `tkt_permiso` WRITE;
/*!40000 ALTER TABLE `tkt_permiso` DISABLE KEYS */;
INSERT INTO `tkt_permiso` VALUES (1,'TKT_LIST_ALL','Ver todos los tickets',1),(2,'TKT_LIST_ASSIGNED','Ver mis asignados',1),(3,'TKT_VIEW_DETAIL','Ver detalle',1),(4,'TKT_CREATE','Crear ticket',1),(5,'TKT_EDIT_ASSIGNED','Editar si soy asignado',1),(6,'TKT_EDIT_ANY','Editar cualquiera',1),(7,'TKT_ASSIGN','Asignar tickets',1),(8,'TKT_CLOSE','Cerrar tickets',1),(9,'TKT_DELETE','Eliminar tickets',1),(10,'TKT_EXPORT','Exportar CSV',1),(11,'TKT_COMMENT','Comentar',1),(34,'TKT_RBAC_ADMIN','Administrar roles y permisos',1),(35,'TKT_START','Iniciar trabajo / mover a En Proceso',1),(36,'TKT_WAIT','Poner / sacar de Espera',1),(37,'TKT_REQUEST_APPROVAL','Solicitar aprobación',1),(38,'TKT_APPROVE','Aprobar / Rechazar',1),(39,'TKT_RESOLVE','Marcar como Resuelto',1),(40,'TKT_REOPEN','Reabrir ticket',1);
/*!40000 ALTER TABLE `tkt_permiso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tkt_rol`
--

DROP TABLE IF EXISTS `tkt_rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_rol` (
  `id_rol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `habilitado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_rol`
--

LOCK TABLES `tkt_rol` WRITE;
/*!40000 ALTER TABLE `tkt_rol` DISABLE KEYS */;
INSERT INTO `tkt_rol` VALUES (1,'Administrador','Acceso total',1),(2,'Supervisor','Supervisa y edita, sin eliminar',1),(3,'Operador','Opera tickets asignados',1),(4,'Consulta','Solo lectura y exportar',1),(6,'Aprobador','Puede aprobar/rechazar tickets en pendiente de aprobación',1);
/*!40000 ALTER TABLE `tkt_rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tkt_rol_permiso`
--

DROP TABLE IF EXISTS `tkt_rol_permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_rol_permiso` (
  `id_rol` int(11) NOT NULL,
  `id_permiso` int(11) NOT NULL,
  PRIMARY KEY (`id_rol`,`id_permiso`),
  KEY `idx_trp_permiso` (`id_permiso`),
  CONSTRAINT `fk_trp_perm` FOREIGN KEY (`id_permiso`) REFERENCES `tkt_permiso` (`id_permiso`),
  CONSTRAINT `fk_trp_rol` FOREIGN KEY (`id_rol`) REFERENCES `tkt_rol` (`id_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_rol_permiso`
--

LOCK TABLES `tkt_rol_permiso` WRITE;
/*!40000 ALTER TABLE `tkt_rol_permiso` DISABLE KEYS */;
INSERT INTO `tkt_rol_permiso` VALUES (1,1),(2,1),(4,1),(6,1),(1,2),(3,2),(1,3),(2,3),(3,3),(4,3),(1,4),(2,4),(3,4),(1,5),(3,5),(1,6),(2,6),(1,7),(2,7),(1,8),(2,8),(3,8),(1,9),(1,10),(2,10),(4,10),(1,11),(2,11),(3,11),(1,34),(1,35),(2,35),(3,35),(1,36),(2,36),(3,36),(1,37),(2,37),(3,37),(1,38),(2,38),(6,38),(1,39),(2,39),(3,39),(1,40),(2,40);
/*!40000 ALTER TABLE `tkt_rol_permiso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tkt_search`
--

DROP TABLE IF EXISTS `tkt_search`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_search` (
  `Id_Tkt` bigint(20) NOT NULL,
  `Term` varchar(60) NOT NULL,
  PRIMARY KEY (`Id_Tkt`,`Term`),
  KEY `idx_term` (`Term`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_search`
--

LOCK TABLES `tkt_search` WRITE;
/*!40000 ALTER TABLE `tkt_search` DISABLE KEYS */;
INSERT INTO `tkt_search` VALUES (4,'aaaaaaaaaaaaaaaaaaaa'),(2,'beta'),(2,'esto'),(6,'esto'),(2,'prueba'),(3,'prueba'),(3,'seguimiento'),(4,'sssssssss'),(6,'test');
/*!40000 ALTER TABLE `tkt_search` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tkt_suscriptor`
--

DROP TABLE IF EXISTS `tkt_suscriptor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_suscriptor` (
  `id_tkt` bigint(20) NOT NULL,
  `id_usuario` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_tkt`,`id_usuario`),
  KEY `idx_ts_usuario` (`id_usuario`),
  CONSTRAINT `fk_suscriptor_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE,
  CONSTRAINT `fk_suscriptor_tkt` FOREIGN KEY (`id_tkt`) REFERENCES `tkt` (`Id_Tkt`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_suscriptor`
--

LOCK TABLES `tkt_suscriptor` WRITE;
/*!40000 ALTER TABLE `tkt_suscriptor` DISABLE KEYS */;
INSERT INTO `tkt_suscriptor` VALUES (3,1),(5,1),(3,3),(4,3);
/*!40000 ALTER TABLE `tkt_suscriptor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tkt_transicion`
--

DROP TABLE IF EXISTS `tkt_transicion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_transicion` (
  `id_transicion` bigint(20) NOT NULL AUTO_INCREMENT,
  `id_tkt` bigint(20) NOT NULL,
  `estado_from` int(11) DEFAULT NULL,
  `estado_to` int(11) NOT NULL,
  `id_usuario_actor` bigint(20) DEFAULT NULL,
  `id_usuario_asignado_old` bigint(20) DEFAULT NULL,
  `id_usuario_asignado_new` bigint(20) DEFAULT NULL,
  `comentario` varchar(1000) DEFAULT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `meta_json` longtext,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_transicion`),
  KEY `idx_tkt_fecha` (`id_tkt`,`fecha`),
  KEY `idx_estado_to` (`estado_to`),
  KEY `idx_transicion_tkt_fecha` (`id_tkt`,`fecha`),
  KEY `fk_transicion_usuario` (`id_usuario_actor`),
  KEY `fk_transicion_estado_prev` (`estado_from`),
  CONSTRAINT `fk_transicion_estado_nuevo` FOREIGN KEY (`estado_to`) REFERENCES `estado` (`Id_Estado`),
  CONSTRAINT `fk_transicion_estado_prev` FOREIGN KEY (`estado_from`) REFERENCES `estado` (`Id_Estado`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_transicion_tkt` FOREIGN KEY (`id_tkt`) REFERENCES `tkt` (`Id_Tkt`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_transicion_usuario` FOREIGN KEY (`id_usuario_actor`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_transicion`
--

LOCK TABLES `tkt_transicion` WRITE;
/*!40000 ALTER TABLE `tkt_transicion` DISABLE KEYS */;
INSERT INTO `tkt_transicion` VALUES (1,1,1,2,1,NULL,NULL,'Esto es una prueba',NULL,NULL,'2025-11-18 17:37:09'),(2,1,2,5,1,NULL,NULL,'esto es una prueba de solicitud de aprobacion',NULL,NULL,'2025-11-18 17:38:01'),(3,1,5,6,1,NULL,NULL,'esto es una prueba de aprobacion de una solicitud de aprobacion',NULL,NULL,'2025-11-18 17:38:42'),(4,1,6,3,1,NULL,NULL,'esto es un test de cerrar',NULL,NULL,'2025-11-21 13:58:34'),(5,1,3,7,1,NULL,NULL,'esto es un test de reabrir','prueba',NULL,'2025-11-21 13:59:00'),(6,1,7,2,1,NULL,NULL,'prueba A',NULL,NULL,'2025-11-21 13:59:27'),(7,1,2,5,1,NULL,NULL,'Prueba B de solicitud',NULL,NULL,'2025-11-21 13:59:59'),(8,1,5,6,1,NULL,NULL,'aprobado prueba',NULL,NULL,'2025-11-21 14:00:21'),(9,1,6,3,1,NULL,NULL,'prueba',NULL,NULL,'2025-11-21 14:45:11'),(10,3,1,2,3,NULL,NULL,'Prueba tomar ticket',NULL,NULL,'2025-11-21 15:00:46'),(11,3,2,6,3,NULL,NULL,'prueba resolucion 567',NULL,NULL,'2025-11-21 15:02:02'),(12,3,6,7,1,NULL,NULL,'aaaaaaa','bbbbbb',NULL,'2025-11-21 15:03:36'),(13,4,1,2,3,NULL,NULL,'aaa',NULL,NULL,'2025-11-21 16:33:20'),(14,4,2,6,3,NULL,NULL,'resuelto',NULL,NULL,'2025-11-21 16:33:48'),(15,4,6,7,1,NULL,NULL,'aaa','aaa',NULL,'2025-11-21 16:34:36'),(16,4,7,2,1,NULL,NULL,'aaa',NULL,NULL,'2025-11-21 16:52:28'),(17,5,1,2,1,NULL,NULL,'a',NULL,NULL,'2025-11-21 17:36:49'),(18,5,2,6,1,NULL,NULL,'test',NULL,NULL,'2025-12-04 13:49:16'),(19,5,6,3,1,NULL,NULL,'aaaaa',NULL,NULL,'2025-12-04 13:57:02'),(20,5,3,7,1,NULL,NULL,'aaaaaaaa',NULL,NULL,'2025-12-04 14:01:01'),(21,1,3,7,1,NULL,NULL,'aaaaa',NULL,NULL,'2025-12-04 14:08:26'),(22,6,1,2,1,NULL,NULL,'aaa',NULL,NULL,'2025-12-04 14:17:00'),(23,5,7,2,2,NULL,NULL,'aaa',NULL,NULL,'2025-12-04 14:18:03'),(24,6,2,4,1,NULL,NULL,'aaaa',NULL,NULL,'2025-12-04 16:05:11'),(25,6,4,2,1,NULL,NULL,'aaa',NULL,NULL,'2025-12-09 15:40:52'),(26,6,2,3,1,NULL,NULL,'aaaa',NULL,NULL,'2025-12-09 15:41:21'),(27,6,3,4,1,NULL,NULL,'test super admin',NULL,NULL,'2025-12-09 15:50:31'),(28,3,7,2,2,NULL,NULL,'aaa',NULL,NULL,'2025-12-09 15:51:02'),(29,3,2,3,1,NULL,NULL,'aaa',NULL,NULL,'2025-12-09 16:09:42'),(30,6,4,3,1,NULL,NULL,'aaaaaaaaaaaaa',NULL,NULL,'2025-12-09 16:37:17'),(31,1,7,2,1,NULL,NULL,'Test',NULL,NULL,'2026-01-27 17:58:02');
/*!40000 ALTER TABLE `tkt_transicion` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
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
   CONCAT('Transicion de estado: ', NEW.estado_from, ' -> ', NEW.estado_to),
   NOW(),
   CONCAT('Ticket ', NEW.id_tkt, ' cambió de estado'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tkt_transicion_regla`
--

DROP TABLE IF EXISTS `tkt_transicion_regla`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_transicion_regla` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `estado_from` int(11) DEFAULT NULL,
  `estado_to` int(11) NOT NULL,
  `requiere_propietario` tinyint(1) NOT NULL DEFAULT '0',
  `permiso_requerido` varchar(50) DEFAULT NULL,
  `requiere_aprobacion` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_regla` (`estado_from`,`estado_to`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_transicion_regla`
--

LOCK TABLES `tkt_transicion_regla` WRITE;
/*!40000 ALTER TABLE `tkt_transicion_regla` DISABLE KEYS */;
INSERT INTO `tkt_transicion_regla` VALUES (1,1,2,0,'TKT_ASSIGN',0),(2,2,3,1,'TKT_START',0),(3,3,4,1,'TKT_WAIT',0),(4,4,3,1,'TKT_WAIT',0),(5,3,5,1,'TKT_REQUEST_APPROVAL',1),(6,5,3,0,'TKT_APPROVE',0),(7,5,6,0,'TKT_APPROVE',0),(8,3,6,1,'TKT_RESOLVE',0),(9,6,7,0,'TKT_CLOSE',0),(38,2,4,1,'TKT_WAIT',0),(39,4,2,1,'TKT_WAIT',0),(40,2,5,1,'TKT_REQUEST_APPROVAL',1),(41,5,2,0,'TKT_APPROVE',0),(43,2,6,1,'TKT_RESOLVE',0),(44,6,3,0,'TKT_CLOSE',0),(45,3,7,0,'TKT_REOPEN',0),(46,7,2,0,'TKT_START',0);
/*!40000 ALTER TABLE `tkt_transicion_regla` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tkt_usuario_rol`
--

DROP TABLE IF EXISTS `tkt_usuario_rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_usuario_rol` (
  `idUsuario` bigint(20) NOT NULL,
  `id_rol` int(11) NOT NULL,
  PRIMARY KEY (`idUsuario`,`id_rol`),
  KEY `IX_tur_usuario` (`idUsuario`),
  KEY `IX_tur_rol` (`id_rol`),
  KEY `idx_tur_usuario` (`idUsuario`),
  CONSTRAINT `fk_tur_rol` FOREIGN KEY (`id_rol`) REFERENCES `tkt_rol` (`id_rol`),
  CONSTRAINT `fk_tur_usuario` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_usuario_rol`
--

LOCK TABLES `tkt_usuario_rol` WRITE;
/*!40000 ALTER TABLE `tkt_usuario_rol` DISABLE KEYS */;
INSERT INTO `tkt_usuario_rol` VALUES (1,1),(2,2),(3,3);
/*!40000 ALTER TABLE `tkt_usuario_rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario` (
  `idUsuario` bigint(20) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(40) NOT NULL,
  `telefono` varchar(40) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `nota` varchar(200) DEFAULT NULL,
  `passwordUsuario` varchar(50) DEFAULT NULL,
  `passwordUsuarioEnc` varchar(35) DEFAULT NULL COMMENT 'password de usuario encriptado md5',
  `firma` varchar(40) DEFAULT NULL,
  `firma_aclaracion` tinytext,
  `fechaAlta` date DEFAULT NULL,
  `fechaBaja` date DEFAULT NULL,
  `tipo` varchar(3) DEFAULT 'INT' COMMENT 'INT: Interno cediac, CLI: Cliente proveedor',
  `idCliente` bigint(10) DEFAULT '0',
  `idKine` bigint(20) DEFAULT '0',
  `refresh_token_hash` varchar(512) DEFAULT NULL,
  `refresh_token_expires` datetime DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  PRIMARY KEY (`idUsuario`),
  KEY `KEY_cliente` (`idCliente`),
  KEY `KEY_kinesiologo` (`idKine`),
  KEY `KEY_tipo` (`tipo`),
  KEY `KEY_nombre` (`nombre`),
  KEY `idx_usuario_nombre` (`nombre`),
  KEY `IX_usuario_idUsuario` (`idUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'Admin',NULL,NULL,NULL,'changeme','4cb9c8a8048fd02294477fcb1a41191a',NULL,NULL,'2026-01-30',NULL,'INT',0,0,'xC28Fku2NFApVOfgIrAMTuY8UBoidYy/ABD1S82+c7I=','2026-02-06 17:29:14','2026-01-30 14:29:14'),(2,'Supervisor',NULL,NULL,NULL,'changeme','4cb9c8a8048fd02294477fcb1a41191a',NULL,NULL,'2025-11-18',NULL,'INT',0,0,NULL,NULL,NULL),(3,'Operador Uno',NULL,NULL,NULL,'changeme','4cb9c8a8048fd02294477fcb1a41191a',NULL,NULL,'2025-11-18',NULL,'INT',0,0,NULL,NULL,NULL);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_empresa_sucursal_perfil_sistema`
--

DROP TABLE IF EXISTS `usuario_empresa_sucursal_perfil_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario_empresa_sucursal_perfil_sistema` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `idUsuario` bigint(20) DEFAULT '0' COMMENT 'idUsuario (Usuario)',
  `idEmpresa` bigint(20) DEFAULT '0' COMMENT 'idEmpresa (Empresa)',
  `idSucursal` bigint(20) DEFAULT '0' COMMENT 'idSucursal (Sucursal)',
  `idSistema` varchar(8) DEFAULT NULL COMMENT 'idSistema (cdk_usuarios.sistema)',
  `idPerfil` bigint(20) DEFAULT '0' COMMENT 'idPerfil (cdk_usuario.perfil)',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`ID`),
  KEY `KEY_usuario` (`idUsuario`),
  KEY `KEY_empresa` (`idEmpresa`),
  KEY `KEY_sucursal` (`idSucursal`),
  KEY `KEY_sistema` (`idSistema`),
  KEY `KEY_perfil` (`idPerfil`)
) ENGINE=InnoDB AUTO_INCREMENT=1036 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_empresa_sucursal_perfil_sistema`
--

LOCK TABLES `usuario_empresa_sucursal_perfil_sistema` WRITE;
/*!40000 ALTER TABLE `usuario_empresa_sucursal_perfil_sistema` DISABLE KEYS */;
INSERT INTO `usuario_empresa_sucursal_perfil_sistema` VALUES (1033,1,0,2,'CDK_TKT',4,1),(1034,2,0,2,'CDK_TKT',3,1),(1035,3,0,2,'CDK_TKT',1,1);
/*!40000 ALTER TABLE `usuario_empresa_sucursal_perfil_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_rol`
--

DROP TABLE IF EXISTS `usuario_rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario_rol` (
  `idUsuario` bigint(20) NOT NULL DEFAULT '0',
  `idRol` int(11) NOT NULL,
  PRIMARY KEY (`idUsuario`,`idRol`),
  KEY `fk_usuario_rol_rol` (`idRol`),
  CONSTRAINT `fk_usuario_rol_rol` FOREIGN KEY (`idRol`) REFERENCES `rol` (`idRol`) ON DELETE CASCADE,
  CONSTRAINT `fk_usuario_rol_usuario` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_rol`
--

LOCK TABLES `usuario_rol` WRITE;
/*!40000 ALTER TABLE `usuario_rol` DISABLE KEYS */;
INSERT INTO `usuario_rol` VALUES (2,1),(3,3),(1,10);
/*!40000 ALTER TABLE `usuario_rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_tipo`
--

DROP TABLE IF EXISTS `usuario_tipo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario_tipo` (
  `usuTipoId` varchar(4) NOT NULL,
  `usuTipoDesc` varchar(50) DEFAULT NULL,
  `usuTipoHabil` int(1) DEFAULT '0',
  PRIMARY KEY (`usuTipoId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_tipo`
--

LOCK TABLES `usuario_tipo` WRITE;
/*!40000 ALTER TABLE `usuario_tipo` DISABLE KEYS */;
INSERT INTO `usuario_tipo` VALUES ('CLI','Cliente/Proveedor',0),('INT','Interno',0);
/*!40000 ALTER TABLE `usuario_tipo` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-30 14:54:34
