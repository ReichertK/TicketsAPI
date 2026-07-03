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
-- Current Database: `cdk_tkt_dev`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `cdk_tkt_dev` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `cdk_tkt_dev`;

--
-- Table structure for table `accion`
--

DROP TABLE IF EXISTS `accion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accion` (
  `idAccion` bigint(20) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idAccion`,`codigo`),
  KEY `KEY_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
-- Table structure for table `audit_config`
--

DROP TABLE IF EXISTS `audit_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_config` (
  `id_audit_config` int(11) NOT NULL AUTO_INCREMENT,
  `entidad` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_entidad` int(11) DEFAULT NULL,
  `accion` enum('INSERT','UPDATE','DELETE','TOGGLE','ASSIGN','REVOKE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `campo_modificado` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valor_anterior` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valor_nuevo` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuario_id` int(11) NOT NULL,
  `usuario_nombre` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `descripcion` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_audit_config`),
  KEY `idx_ac_entidad` (`entidad`,`id_entidad`),
  KEY `idx_ac_usuario` (`usuario_id`,`fecha`),
  KEY `idx_ac_fecha` (`fecha`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_config`
--

LOCK TABLES `audit_config` WRITE;
/*!40000 ALTER TABLE `audit_config` DISABLE KEYS */;
INSERT INTO `audit_config` VALUES (3,'departamento',85,'TOGGLE','activo','1','0',1,'Administrador','2026-02-20 16:31:55','Departamento Desactivado: AuditTest_Updated'),(4,'departamento',86,'INSERT',NULL,NULL,'<script>alert(123)</script> emoji_test kanji_test',1,'Administrador','2026-02-20 17:43:30','Departamento creado: <script>alert(123)</script> emoji_test kanji_test'),(5,'departamento',87,'TOGGLE','activo','1','0',1,'Administrador','2026-02-24 14:07:25','Departamento Desactivado: Depto UTF8MB4 ?'),(6,'departamento',59,'TOGGLE','activo','1','0',1,'Administrador','2026-02-27 17:16:52','Departamento Desactivado: Administración'),(7,'departamento',59,'TOGGLE','activo','0','1',1,'Administrador','2026-02-27 17:16:55','Departamento Activado: Administración'),(8,'departamento',33,'TOGGLE','activo','1','0',1,'Administrador','2026-03-03 12:36:39','Departamento Desactivado: Caja / Facturación / Autorizaciones'),(9,'departamento',33,'TOGGLE','activo','0','1',1,'Administrador','2026-03-03 12:36:42','Departamento Activado: Caja / Facturación / Autorizaciones'),(10,'rol',1,'UPDATE','nombre',NULL,'Supervisor',1,'Administrador','2026-03-03 12:37:12','Rol actualizado: Supervisor');
/*!40000 ALTER TABLE `audit_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_log` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `tabla` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_registro` bigint(20) DEFAULT NULL,
  `accion` enum('INSERT','UPDATE','DELETE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `usuario_nombre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valores_antiguos` mediumtext COLLATE utf8mb4_unicode_ci,
  `valores_nuevos` mediumtext COLLATE utf8mb4_unicode_ci,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_auditoria`),
  KEY `idx_auditoria_tabla_fecha` (`tabla`,`fecha`),
  KEY `idx_auditoria_usuario_fecha` (`usuario_id`,`fecha`),
  KEY `idx_auditoria_id_registro` (`tabla`,`id_registro`),
  KEY `idx_auditoria_accion` (`accion`,`fecha`),
  KEY `idx_auditoria_fecha_id` (`fecha`,`id_auditoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `Nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1',
  `fechaBaja` datetime DEFAULT NULL,
  PRIMARY KEY (`Id_Departamento`),
  UNIQUE KEY `uq_depto_nombre` (`Nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departamento`
--

LOCK TABLES `departamento` WRITE;
/*!40000 ALTER TABLE `departamento` DISABLE KEYS */;
INSERT INTO `departamento` VALUES (1,'Departamento A',NULL,1,NULL),(2,'Departamento B',NULL,1,NULL),(3,'Departamento C',NULL,1,NULL),(4,'Mesa de Ayuda / Soporte N1',NULL,1,NULL),(5,'Soporte N2 / Plataformas',NULL,1,NULL),(6,'Infraestructura',NULL,1,NULL),(7,'Redes',NULL,1,NULL),(8,'Telecomunicaciones',NULL,1,NULL),(9,'Seguridad Informática',NULL,1,NULL),(10,'Desarrollo de Software',NULL,1,NULL),(11,'QA / Testing',NULL,1,NULL),(12,'Bases de Datos / DBA',NULL,1,NULL),(13,'Aplicaciones Corporativas / ERP',NULL,1,NULL),(14,'BI / Analítica',NULL,1,NULL),(15,'Gestión de Servicios (ITSM)',NULL,1,NULL),(16,'Ventas / Comercial',NULL,1,NULL),(17,'Atención al Cliente',NULL,1,NULL),(18,'Operaciones',NULL,1,NULL),(19,'Logística',NULL,1,NULL),(20,'Producción',NULL,1,NULL),(21,'Calidad',NULL,1,NULL),(22,'Compras / Abastecimiento',NULL,1,NULL),(23,'Finanzas / Contabilidad',NULL,1,NULL),(24,'Tesorería',NULL,1,NULL),(25,'Créditos y Cobranzas',NULL,1,NULL),(26,'Recursos Humanos',NULL,1,NULL),(27,'Marketing / Comunicación',NULL,1,NULL),(28,'Legal',NULL,1,NULL),(29,'Dirección / Gerencia',NULL,0,'2026-02-10 14:02:37'),(30,'Sucursales / Oficinas',NULL,1,NULL),(31,'Recepción y Admisión',NULL,1,NULL),(32,'Turnos / Call Center',NULL,1,NULL),(33,'Caja / Facturación / Autorizaciones',NULL,1,NULL),(34,'Atención al Paciente',NULL,1,NULL),(35,'Radiología Convencional (Rayos X)',NULL,1,NULL),(36,'Tomografía Computada (TC)',NULL,1,NULL),(37,'Resonancia Magnética (RM)',NULL,1,NULL),(38,'Ecografía',NULL,1,NULL),(39,'Mamografía',NULL,1,NULL),(40,'Densitometría Ósea (DEXA)',NULL,1,NULL),(41,'Medicina Nuclear',NULL,1,NULL),(42,'Radiología Intervencionista / Hemodinamia',NULL,1,NULL),(43,'Médicos Informantes (Radiología)',NULL,1,NULL),(44,'Técnicos Radiólogos',NULL,1,NULL),(45,'Jefatura de Diagnóstico por Imágenes',NULL,1,NULL),(46,'Protección Radiológica / Física Médica',NULL,1,NULL),(47,'Archivo y Entrega de Estudios',NULL,1,NULL),(48,'Calidad Clínica / Protocolos',NULL,1,NULL),(49,'Consultorios',NULL,1,NULL),(50,'Kinesiología y Rehabilitación',NULL,1,NULL),(51,'Sistemas / Soluciones IT',NULL,1,NULL),(52,'PACS / RIS',NULL,1,NULL),(53,'Integraciones HIS/EMR (HL7/DICOM)',NULL,1,NULL),(54,'Seguridad de la Información',NULL,1,NULL),(55,'Mantenimiento Edilicio',NULL,1,NULL),(56,'Mantenimiento Biomédico',NULL,1,NULL),(57,'Compras / Suministros (Insumos Radiológicos)',NULL,1,NULL),(58,'Servicios Generales / Limpieza',NULL,1,NULL),(59,'Administración',NULL,1,NULL),(60,'Legales y Compliance',NULL,1,NULL),(61,'Calidad y Auditoría',NULL,1,NULL),(62,'Marketing / Comunicación Institucional',NULL,1,NULL),(63,'Dirección Médica',NULL,1,NULL),(64,'Dirección General / Gerencia',NULL,1,NULL),(65,'Sistemas',NULL,1,NULL),(66,'Comercial',NULL,1,NULL),(68,'RRHH',NULL,1,NULL),(83,'Finanzas','Departamento de Finanzas',1,NULL),(87,'Depto UTF8MB4 ?','Kanji 全球',0,'2026-02-24 11:07:25');
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
  `cuit` varchar(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'cuit de la empresa sin guion',
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'descripcion o razon social',
  `codigo` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'codigo de la empresa',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idEmpresa`),
  KEY `KEY_cuit` (`cuit`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
-- Table structure for table `error_log`
--

DROP TABLE IF EXISTS `error_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `error_log` (
  `id_error` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `origen` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `severidad` enum('INFO','WARN','ERROR','FATAL') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ERROR',
  `codigo_error` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mensaje` varchar(2000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `detalle` mediumtext COLLATE utf8mb4_unicode_ci,
  `usuario_id` int(11) DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_error`),
  KEY `idx_error_fecha` (`fecha`),
  KEY `idx_error_origen` (`origen`,`fecha`),
  KEY `idx_error_severidad` (`severidad`,`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `error_log`
--

LOCK TABLES `error_log` WRITE;
/*!40000 ALTER TABLE `error_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `error_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estado`
--

DROP TABLE IF EXISTS `estado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estado` (
  `Id_Estado` int(11) NOT NULL AUTO_INCREMENT,
  `TipoEstado` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1',
  `fechaBaja` datetime DEFAULT NULL,
  PRIMARY KEY (`Id_Estado`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estado`
--

LOCK TABLES `estado` WRITE;
/*!40000 ALTER TABLE `estado` DISABLE KEYS */;
INSERT INTO `estado` VALUES (1,'Abierto',NULL,1,NULL),(2,'En Proceso',NULL,1,NULL),(3,'Cerrado',NULL,1,NULL),(4,'En Espera',NULL,1,NULL),(5,'Pendiente Aprobación',NULL,1,NULL),(6,'Resuelto',NULL,1,NULL),(7,'Reabierto',NULL,1,NULL);
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
  `usuario_nombre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `razon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_failed_login_usuario_fecha` (`usuario_nombre`,`fecha`),
  KEY `idx_failed_login_ip_fecha` (`ip_address`,`fecha`),
  KEY `idx_failed_login_reciente` (`fecha`),
  KEY `idx_fla_usuario_fecha` (`usuario_nombre`,`fecha`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_login_attempts`
--

LOCK TABLES `failed_login_attempts` WRITE;
/*!40000 ALTER TABLE `failed_login_attempts` DISABLE KEYS */;
INSERT INTO `failed_login_attempts` VALUES (1,'admin','127.0.0.1','2026-02-27 13:50:20',NULL),(2,'admin','127.0.0.1','2026-02-27 13:50:28',NULL),(3,'Admin','127.0.0.1','2026-02-27 13:59:35',NULL),(4,'admin','127.0.0.1','2026-02-27 14:05:57',NULL),(5,'admin','127.0.0.1','2026-02-27 14:06:23',NULL),(6,'admin@tickets.com','127.0.0.1','2026-02-27 15:30:21',NULL),(7,'sepervisor','127.0.0.1','2026-02-27 16:44:46',NULL),(8,'admin@test.com','127.0.0.1','2026-02-28 13:44:45',NULL),(9,'admin@test.com','127.0.0.1','2026-02-28 13:44:59',NULL),(10,'admin@test.com','127.0.0.1','2026-02-28 13:45:12',NULL),(11,'admin@test.com','127.0.0.1','2026-02-28 13:45:18',NULL),(12,'admin','127.0.0.1','2026-03-03 12:42:05',NULL),(13,'admin','127.0.0.1','2026-03-03 13:00:17',NULL),(14,'admin','127.0.0.1','2026-03-03 13:00:18',NULL),(15,'admin','127.0.0.1','2026-03-03 13:00:22',NULL),(16,'admin','127.0.0.1','2026-03-03 13:00:23',NULL);
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
  `Tipo_Grupo` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Id_Grupo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupo`
--

LOCK TABLES `grupo` WRITE;
/*!40000 ALTER TABLE `grupo` DISABLE KEYS */;
INSERT INTO `grupo` VALUES (1,'admin'),(2,'usuario');
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
  `Nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Categoria` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_departamento` int(11) DEFAULT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1',
  `fechaBaja` datetime DEFAULT NULL,
  PRIMARY KEY (`Id_Motivo`),
  UNIQUE KEY `uq_motivo_nombre_cat` (`Nombre`,`Categoria`),
  KEY `idx_motivo_depto` (`id_departamento`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `motivo`
--

LOCK TABLES `motivo` WRITE;
/*!40000 ALTER TABLE `motivo` DISABLE KEYS */;
INSERT INTO `motivo` VALUES (1,'Motivo A',NULL,NULL,NULL,1,NULL),(2,'Motivo B',NULL,NULL,NULL,1,NULL),(3,'Motivo C',NULL,NULL,NULL,1,NULL),(4,'Turno / Reprogramación',NULL,NULL,NULL,1,NULL),(5,'Autorización de Obra Social',NULL,NULL,NULL,1,NULL),(6,'Facturación / Cobranza',NULL,NULL,NULL,1,NULL),(7,'Recepción / Admisión',NULL,NULL,NULL,1,NULL),(8,'Entrega de Estudios / Duplicado',NULL,NULL,NULL,1,NULL),(9,'Satisfacción del Paciente / Queja',NULL,NULL,NULL,1,NULL),(10,'Rayos X - Orden / Preparación',NULL,NULL,NULL,1,NULL),(11,'Rayos X - Resultado / Entrega',NULL,NULL,NULL,1,NULL),(12,'Tomografía - Orden / Preparación',NULL,NULL,NULL,1,NULL),(13,'Tomografía - Contraste / Reacción',NULL,NULL,NULL,1,NULL),(14,'Resonancia - Orden / Preparación',NULL,NULL,NULL,1,NULL),(15,'Resonancia - Implantes / Contraindicaciones',NULL,NULL,NULL,1,NULL),(16,'Ecografía - Agenda / Preparación',NULL,NULL,NULL,1,NULL),(17,'Mamografía - Orden / Preparación',NULL,NULL,NULL,1,NULL),(18,'DEXA - Orden / Preparación',NULL,NULL,NULL,1,NULL),(19,'Informe - Retraso',NULL,NULL,NULL,1,NULL),(20,'Informe - Aclaración / Addendum',NULL,NULL,NULL,1,NULL),(21,'Informe - Corrección de Datos',NULL,NULL,NULL,1,NULL),(22,'PACS - Visualización de Imágenes',NULL,NULL,NULL,1,NULL),(23,'PACS - Envío/Recepción DICOM',NULL,NULL,NULL,1,NULL),(24,'RIS - Agenda / Admisión',NULL,NULL,NULL,1,NULL),(25,'RIS - Falla de Integración',NULL,NULL,NULL,1,NULL),(26,'HIS/EMR - Interfaz HL7',NULL,NULL,NULL,1,NULL),(27,'Portal Paciente / Médicos - Acceso',NULL,NULL,NULL,1,NULL),(28,'Equipamiento RX - Falla',NULL,NULL,NULL,1,NULL),(29,'Tomógrafo - Falla',NULL,NULL,NULL,1,NULL),(30,'Resonador - Falla',NULL,NULL,NULL,1,NULL),(31,'Ecógrafo - Falla',NULL,NULL,NULL,1,NULL),(32,'Mamógrafo - Falla',NULL,NULL,NULL,1,NULL),(33,'Impresora Dry - Falla / Insumos',NULL,NULL,NULL,1,NULL),(34,'CR/DR - Digitalizador - Falla',NULL,NULL,NULL,1,NULL),(35,'Protección Radiológica',NULL,NULL,NULL,1,NULL),(36,'Calibración / Control de Calidad',NULL,NULL,NULL,1,NULL),(37,'Gestión de Incidentes (Seguridad Info)',NULL,NULL,NULL,1,NULL),(38,'Kinesiología - Agenda / Práctica',NULL,NULL,NULL,1,NULL),(39,'Consultorios - Agenda / Atención',NULL,NULL,NULL,1,NULL),(40,'Infraestructura - Climatización',NULL,NULL,NULL,1,NULL),(41,'Infraestructura - Electricidad',NULL,NULL,NULL,1,NULL),(42,'Servicios - Limpieza / Residuos Patológicos',NULL,NULL,NULL,1,NULL),(43,'Incidente',NULL,'Soporte',NULL,1,NULL),(44,'Solicitud',NULL,'Servicio',NULL,1,NULL),(45,'Consulta',NULL,'Información',NULL,1,NULL),(60,'Error de Factura','Error en facturación','Finanzas',NULL,0,'2026-02-20 11:32:26');
/*!40000 ALTER TABLE `motivo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificacion_alerta`
--

DROP TABLE IF EXISTS `notificacion_alerta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificacion_alerta` (
  `id_alerta` bigint(20) NOT NULL AUTO_INCREMENT,
  `id_usuario` bigint(20) NOT NULL COMMENT 'Usuario destinatario',
  `tipo` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'mencion' COMMENT 'mencion, asignacion, etc.',
  `id_ticket` bigint(20) DEFAULT NULL,
  `id_comentario` bigint(20) DEFAULT NULL,
  `mensaje` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `leida` tinyint(1) NOT NULL DEFAULT '0',
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_alerta`),
  KEY `idx_alerta_usuario_leida` (`id_usuario`,`leida`,`fecha`),
  KEY `idx_alerta_ticket` (`id_ticket`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificacion_alerta`
--

LOCK TABLES `notificacion_alerta` WRITE;
/*!40000 ALTER TABLE `notificacion_alerta` DISABLE KEYS */;
INSERT INTO `notificacion_alerta` VALUES (1,2,'mencion',9,4,'Te mencionaron en el ticket #9',0,'2026-02-27 15:54:25'),(2,2,'mencion',6,NULL,'Te asignaron el ticket #6',0,'2026-02-27 16:39:46'),(3,2,'mencion',8,NULL,'Te asignaron el ticket #8',0,'2026-02-27 16:40:15'),(4,2,'asignacion',7,NULL,'Te asignaron el ticket #7',0,'2026-02-27 16:42:53'),(5,3,'asignacion',3,NULL,'Te asignaron el ticket #3',0,'2026-02-28 18:17:53'),(6,3,'asignacion',11,NULL,'Te asignaron el ticket #11',0,'2026-03-03 12:35:28'),(7,2,'asignacion',1,NULL,'Te asignaron el ticket #1',0,'2026-03-03 15:18:28'),(8,2,'asignacion',11,NULL,'Te asignaron el ticket #11',0,'2026-03-03 15:35:42'),(9,2,'asignacion',7,NULL,'Te asignaron el ticket #7',0,'2026-03-03 15:43:20'),(10,2,'asignacion',13,NULL,'Te asignaron el ticket #13',0,'2026-03-03 15:45:49');
/*!40000 ALTER TABLE `notificacion_alerta` ENABLE KEYS */;
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
  `Mensaje` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Fecha_Creacion` datetime NOT NULL,
  `Leida` int(1) DEFAULT '0',
  PRIMARY KEY (`Id_Notificacion`),
  KEY `Id_Usuario` (`Id_Usuario`),
  CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`Id_Usuario`) REFERENCES `usuario` (`idUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `nombre` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'descripcion o nombre del perfil',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idPerfil`),
  KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `codigoAccion` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'codigo (accion) concatenados por coma',
  `idSistema` varchar(8) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'idSistema (sistema)',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`ID`),
  KEY `KEY_perfil` (`idPerfil`),
  KEY `KEY_accion` (`codigoAccion`),
  KEY `KEY_sistema` (`idSistema`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `codigo` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`idPermiso`),
  UNIQUE KEY `uq_permiso_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permiso`
--

LOCK TABLES `permiso` WRITE;
/*!40000 ALTER TABLE `permiso` DISABLE KEYS */;
INSERT INTO `permiso` VALUES (1,'TKT_CREATE','Crear tickets'),(2,'TKT_LIST_ALL','Listar todos'),(3,'TKT_LIST_ASSIGNED','Listar asignados'),(4,'TKT_EDIT_ANY','Editar cualquiera'),(5,'TKT_EDIT_ASSIGNED','Editar asignados'),(6,'TKT_DELETE','Eliminar'),(7,'TKT_APPROVE','Aprobar'),(8,'TKT_COMMENT','Comentar'),(9,'TKT_START','Iniciar'),(10,'TKT_RESOLVE','Resolver'),(11,'TKT_EXPORT','Exportar'),(12,'TKT_WAIT','Poner en espera'),(13,'TKT_REQUEST_APPROVAL','Solicitar aprobación'),(14,'TKT_CLOSE','Cerrar'),(15,'TKT_REOPEN','Reabrir'),(16,'TKT_RBAC_ADMIN','Admin RBAC'),(17,'TKT_ASSIGN','Asignar tickets a otros usuarios'),(18,'VER_SOLO_DEPARTAMENTO','Ver solo tickets del departamento propio');
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
  `NombrePrioridad` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1',
  `fechaBaja` datetime DEFAULT NULL,
  PRIMARY KEY (`Id_Prioridad`),
  UNIQUE KEY `uq_prioridad_nombre` (`NombrePrioridad`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prioridad`
--

LOCK TABLES `prioridad` WRITE;
/*!40000 ALTER TABLE `prioridad` DISABLE KEYS */;
INSERT INTO `prioridad` VALUES (1,'Alta',NULL,1,NULL),(2,'Media',NULL,1,NULL),(3,'Baja',NULL,1,NULL),(7,'Crítica',NULL,1,NULL);
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
  `nombre` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`idRol`),
  UNIQUE KEY `uq_rol_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol_permiso`
--

LOCK TABLES `rol_permiso` WRITE;
/*!40000 ALTER TABLE `rol_permiso` DISABLE KEYS */;
INSERT INTO `rol_permiso` VALUES (1,1),(2,1),(3,1),(10,1),(11,1),(12,1),(1,2),(3,2),(10,2),(1,3),(2,3),(3,3),(11,3),(10,4),(1,5),(2,5),(3,5),(10,5),(10,6),(10,7),(11,7),(1,8),(2,8),(3,8),(11,8),(1,9),(2,9),(3,9),(1,10),(2,10),(3,10),(10,10),(1,11),(10,11),(1,12),(2,12),(3,12),(10,12),(1,13),(2,13),(3,13),(10,13),(1,14),(2,14),(3,14),(10,14),(1,15),(10,15),(10,16),(1,17),(10,17),(3,18);
/*!40000 ALTER TABLE `rol_permiso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sistema`
--

DROP TABLE IF EXISTS `sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sistema` (
  `idSistema` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idSistema`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `descripcion` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo` varchar(6) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `domicilio` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `afip` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1000',
  `habilitado` int(1) DEFAULT '0',
  PRIMARY KEY (`idSucursal`),
  UNIQUE KEY `uq_sucursal_desc` (`descripcion`),
  KEY `KEY_empresa` (`idEmpresa`),
  KEY `KEY_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `Contenido` mediumtext COLLATE utf8mb4_unicode_ci,
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
  CONSTRAINT `fk_tkt_depto` FOREIGN KEY (`Id_Departamento`) REFERENCES `departamento` (`Id_Departamento`),
  CONSTRAINT `fk_tkt_empresa` FOREIGN KEY (`Id_Empresa`) REFERENCES `empresa` (`idEmpresa`) ON UPDATE CASCADE,
  CONSTRAINT `fk_tkt_estado` FOREIGN KEY (`Id_Estado`) REFERENCES `estado` (`Id_Estado`),
  CONSTRAINT `fk_tkt_motivo` FOREIGN KEY (`Id_Motivo`) REFERENCES `motivo` (`Id_Motivo`),
  CONSTRAINT `fk_tkt_perfil` FOREIGN KEY (`Id_Perfil`) REFERENCES `perfil` (`idPerfil`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tkt_prioridad` FOREIGN KEY (`Id_Prioridad`) REFERENCES `prioridad` (`Id_Prioridad`),
  CONSTRAINT `fk_tkt_sucursal` FOREIGN KEY (`Id_Sucursal`) REFERENCES `sucursal` (`idSucursal`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tkt_usuario_asignado` FOREIGN KEY (`Id_Usuario_Asignado`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tkt_usuario_creador` FOREIGN KEY (`Id_Usuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt`
--

LOCK TABLES `tkt` WRITE;
/*!40000 ALTER TABLE `tkt` DISABLE KEYS */;
/*!40000 ALTER TABLE `tkt` ENABLE KEYS */;
UNLOCK TABLES;
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
  `estado` enum('pendiente','aprobado','rechazado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `comentario` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_solicitud` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_respuesta` datetime DEFAULT NULL,
  PRIMARY KEY (`id_aprob`),
  KEY `idx_pendientes` (`aprobador_id`,`estado`),
  KEY `idx_aprobacion_tkt_estado` (`id_tkt`,`estado`),
  KEY `fk_aprobacion_solicitante` (`solicitante_id`),
  CONSTRAINT `fk_aprobacion_aprobador` FOREIGN KEY (`aprobador_id`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_aprobacion_solicitante` FOREIGN KEY (`solicitante_id`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_aprobacion_tkt` FOREIGN KEY (`id_tkt`) REFERENCES `tkt` (`Id_Tkt`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_aprobacion`
--

LOCK TABLES `tkt_aprobacion` WRITE;
/*!40000 ALTER TABLE `tkt_aprobacion` DISABLE KEYS */;
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
  `comentario` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_comentario`),
  KEY `idx_tkt_fecha` (`id_tkt`,`fecha`),
  KEY `fk_comentario_usuario` (`id_usuario`),
  CONSTRAINT `fk_comentario_tkt` FOREIGN KEY (`id_tkt`) REFERENCES `tkt` (`Id_Tkt`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comentario_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_comentario`
--

LOCK TABLES `tkt_comentario` WRITE;
/*!40000 ALTER TABLE `tkt_comentario` DISABLE KEYS */;
/*!40000 ALTER TABLE `tkt_comentario` ENABLE KEYS */;
UNLOCK TABLES;
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

--
-- Table structure for table `tkt_notificacion_lectura`
--

DROP TABLE IF EXISTS `tkt_notificacion_lectura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_notificacion_lectura` (
  `id_ticket` bigint(20) NOT NULL,
  `id_usuario` bigint(20) NOT NULL,
  `leido` tinyint(1) NOT NULL DEFAULT '0',
  `fecha_cambio` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_ticket`,`id_usuario`),
  KEY `idx_usuario_leido` (`id_usuario`,`leido`),
  KEY `idx_ticket` (`id_ticket`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_notificacion_lectura`
--

LOCK TABLES `tkt_notificacion_lectura` WRITE;
/*!40000 ALTER TABLE `tkt_notificacion_lectura` DISABLE KEYS */;
/*!40000 ALTER TABLE `tkt_notificacion_lectura` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tkt_permiso`
--

DROP TABLE IF EXISTS `tkt_permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tkt_permiso` (
  `id_permiso` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `habilitado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_permiso`),
  UNIQUE KEY `codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_permiso`
--

LOCK TABLES `tkt_permiso` WRITE;
/*!40000 ALTER TABLE `tkt_permiso` DISABLE KEYS */;
INSERT INTO `tkt_permiso` VALUES (1,'TKT_LIST_ALL','Ver todos los tickets',1),(2,'TKT_LIST_ASSIGNED','Ver mis asignados',1),(3,'TKT_VIEW_DETAIL','Ver detalle',1),(4,'TKT_CREATE','Crear ticket',1),(5,'TKT_EDIT_ASSIGNED','Editar si soy asignado',1),(6,'TKT_EDIT_ANY','Editar cualquiera',1),(7,'TKT_ASSIGN','Asignar tickets',1),(8,'TKT_CLOSE','Cerrar tickets',1),(9,'TKT_DELETE','Eliminar tickets',1),(10,'TKT_EXPORT','Exportar CSV',1),(11,'TKT_COMMENT','Comentar',1),(34,'TKT_RBAC_ADMIN','Administrar roles y permisos',1),(35,'TKT_START','Iniciar trabajo / mover a En Proceso',1),(36,'TKT_WAIT','Poner / sacar de Espera',1),(37,'TKT_REQUEST_APPROVAL','Solicitar aprobación',1),(38,'TKT_APPROVE','Aprobar / Rechazar',1),(39,'TKT_RESOLVE','Marcar como Resuelto',1),(40,'TKT_REOPEN','Reabrir ticket',1),(41,'VER_SOLO_DEPARTAMENTO','Ver solo tickets del departamento propio',1);
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
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `habilitado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_rol_permiso`
--

LOCK TABLES `tkt_rol_permiso` WRITE;
/*!40000 ALTER TABLE `tkt_rol_permiso` DISABLE KEYS */;
INSERT INTO `tkt_rol_permiso` VALUES (1,1),(2,1),(4,1),(6,1),(1,2),(3,2),(1,3),(2,3),(3,3),(4,3),(1,4),(2,4),(3,4),(1,5),(3,5),(1,6),(2,6),(1,7),(2,7),(1,8),(2,8),(3,8),(1,9),(1,10),(2,10),(4,10),(1,11),(2,11),(3,11),(1,34),(1,35),(2,35),(3,35),(1,36),(2,36),(3,36),(1,37),(2,37),(3,37),(1,38),(2,38),(6,38),(1,39),(2,39),(3,39),(1,40),(2,40),(3,41);
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
  `Term` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Id_Tkt`,`Term`),
  KEY `idx_term` (`Term`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_search`
--

LOCK TABLES `tkt_search` WRITE;
/*!40000 ALTER TABLE `tkt_search` DISABLE KEYS */;
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
  `fecha_registro` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_tkt`,`id_usuario`),
  KEY `idx_ts_usuario` (`id_usuario`),
  CONSTRAINT `fk_suscriptor_tkt` FOREIGN KEY (`id_tkt`) REFERENCES `tkt` (`Id_Tkt`) ON DELETE CASCADE,
  CONSTRAINT `fk_suscriptor_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_suscriptor`
--

LOCK TABLES `tkt_suscriptor` WRITE;
/*!40000 ALTER TABLE `tkt_suscriptor` DISABLE KEYS */;
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
  `comentario` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `motivo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_json` longtext COLLATE utf8mb4_unicode_ci,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_transicion`
--

LOCK TABLES `tkt_transicion` WRITE;
/*!40000 ALTER TABLE `tkt_transicion` DISABLE KEYS */;
/*!40000 ALTER TABLE `tkt_transicion` ENABLE KEYS */;
UNLOCK TABLES;
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
  `permiso_requerido` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `requiere_aprobacion` tinyint(1) NOT NULL DEFAULT '0',
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `habilitado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_regla` (`estado_from`,`estado_to`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_transicion_regla`
--

LOCK TABLES `tkt_transicion_regla` WRITE;
/*!40000 ALTER TABLE `tkt_transicion_regla` DISABLE KEYS */;
INSERT INTO `tkt_transicion_regla` VALUES (1,1,2,0,'TKT_START',0,'Iniciar/tomar ticket',1),(2,2,3,1,'TKT_CLOSE',0,'Cierre directo desde proceso',1),(4,4,3,1,'TKT_WAIT',0,'Cerrar desde espera',1),(6,5,3,0,'TKT_APPROVE',0,'Aprobar y cerrar',1),(7,5,6,0,'TKT_APPROVE',0,'Aprobar como resuelto',1),(9,6,7,0,'TKT_REOPEN',0,'Reabrir por inconformidad',1),(38,2,4,1,'TKT_WAIT',0,'Pausar trabajo',1),(39,4,2,1,'TKT_WAIT',0,'Retomar trabajo',1),(40,2,5,1,'TKT_REQUEST_APPROVAL',1,'Solicitar aprobacion',1),(41,5,2,0,'TKT_APPROVE',0,'Aprobar y continuar',1),(43,2,6,1,'TKT_RESOLVE',0,'DESHABILITADA - requiere flujo de aprobacion (2->5->6). Solo bypass via super_admin',0),(44,6,3,0,'TKT_CLOSE',0,'Confirmar cierre final',1),(45,3,7,0,'TKT_REOPEN',0,'Reapertura de ticket cerrado',1),(46,7,2,0,'TKT_START',0,'Retomar ticket reabierto',1),(47,1,4,0,'TKT_WAIT',0,'Poner en espera antes de iniciar',1);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tkt_usuario_rol`
--

LOCK TABLES `tkt_usuario_rol` WRITE;
/*!40000 ALTER TABLE `tkt_usuario_rol` DISABLE KEYS */;
INSERT INTO `tkt_usuario_rol` VALUES (1,1);
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
  `nombre` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nota` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `passwordUsuario` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `passwordUsuarioEnc` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `firma` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `firma_aclaracion` text COLLATE utf8mb4_unicode_ci,
  `fechaAlta` date DEFAULT NULL,
  `fechaBaja` date DEFAULT NULL,
  `tipo` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT 'INT' COMMENT 'INT: Interno cediac, CLI: Cliente proveedor',
  `idCliente` bigint(10) DEFAULT '0',
  `idKine` bigint(20) DEFAULT '0',
  `refresh_token_hash` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refresh_token_expires` datetime DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `intentos_fallidos` int(11) NOT NULL DEFAULT '0',
  `bloqueado_hasta` datetime DEFAULT NULL,
  `Id_Departamento` int(11) DEFAULT NULL,
  PRIMARY KEY (`idUsuario`),
  KEY `KEY_cliente` (`idCliente`),
  KEY `KEY_kinesiologo` (`idKine`),
  KEY `KEY_tipo` (`tipo`),
  KEY `KEY_nombre` (`nombre`),
  KEY `idx_usuario_nombre` (`nombre`),
  KEY `IX_usuario_idUsuario` (`idUsuario`),
  KEY `fk_usuario_depto` (`Id_Departamento`),
  CONSTRAINT `fk_usuario_depto` FOREIGN KEY (`Id_Departamento`) REFERENCES `departamento` (`Id_Departamento`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'Admin',NULL,NULL,NULL,'changeme','$2a$11$OCUJTtpfbs7i6Fg5SqTKlOfrLVjlT57UHkERj1Rc3OyY/Y0ptdkVm',NULL,NULL,'2026-03-06',NULL,'INT',0,0,'2cvZ2M1iEoz1vtmx8AJHXM3k59puim5w5FmeXyra4CA=','2026-03-13 15:53:47','2026-03-06 12:53:47',0,NULL,NULL);
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
  `idSistema` varchar(8) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'idSistema (cdk_usuarios.sistema)',
  `idPerfil` bigint(20) DEFAULT '0' COMMENT 'idPerfil (cdk_usuario.perfil)',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`ID`),
  KEY `KEY_usuario` (`idUsuario`),
  KEY `KEY_empresa` (`idEmpresa`),
  KEY `KEY_sucursal` (`idSucursal`),
  KEY `KEY_sistema` (`idSistema`),
  KEY `KEY_perfil` (`idPerfil`)
) ENGINE=InnoDB AUTO_INCREMENT=1039 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_empresa_sucursal_perfil_sistema`
--

LOCK TABLES `usuario_empresa_sucursal_perfil_sistema` WRITE;
/*!40000 ALTER TABLE `usuario_empresa_sucursal_perfil_sistema` DISABLE KEYS */;
INSERT INTO `usuario_empresa_sucursal_perfil_sistema` VALUES (1033,1,1,2,'CDK_TKT',1,1),(1034,2,1,2,'CDK_TKT',3,1),(1035,3,1,2,'CDK_TKT',1,1),(1036,1,1,1,NULL,1,0),(1037,2,1,1,NULL,1,0),(1038,3,1,1,NULL,1,0);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_rol`
--

LOCK TABLES `usuario_rol` WRITE;
/*!40000 ALTER TABLE `usuario_rol` DISABLE KEYS */;
INSERT INTO `usuario_rol` VALUES (1,10);
/*!40000 ALTER TABLE `usuario_rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_tipo`
--

DROP TABLE IF EXISTS `usuario_tipo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario_tipo` (
  `usuTipoId` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuTipoDesc` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuTipoHabil` int(1) DEFAULT '0',
  PRIMARY KEY (`usuTipoId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_tipo`
--

LOCK TABLES `usuario_tipo` WRITE;
/*!40000 ALTER TABLE `usuario_tipo` DISABLE KEYS */;
INSERT INTO `usuario_tipo` VALUES ('CLI','Cliente/Proveedor',0),('INT','Interno',0);
/*!40000 ALTER TABLE `usuario_tipo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'cdk_tkt_dev'
--

--
-- Dumping routines for database 'cdk_tkt_dev'
--
/*!50003 DROP PROCEDURE IF EXISTS `seed_sp_tkt_permiso_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `seed_sp_tkt_permiso_crear`(IN w_codigo VARCHAR(50), IN w_desc VARCHAR(200))
    COMMENT 'SEED: crea un permiso en tkt_permiso si no existe'
BEGIN
  INSERT IGNORE INTO tkt_permiso(codigo, descripcion) VALUES (w_codigo, w_desc);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `seed_sp_tkt_rol_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `seed_sp_tkt_rol_crear`(IN w_nombre VARCHAR(50), IN w_desc VARCHAR(200))
    COMMENT 'SEED: crea un rol en tkt_rol si no existe'
BEGIN
  INSERT IGNORE INTO tkt_rol(nombre, descripcion) VALUES (w_nombre, w_desc);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `seed_sp_tkt_rol_permiso_asignar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `seed_sp_tkt_rol_permiso_asignar`(IN w_nombre_rol VARCHAR(64), IN w_codigo_permiso VARCHAR(64))
    COMMENT 'SEED: asigna un permiso a un rol (crea si no existen)'
BEGIN
  DECLARE v_idRol INT; DECLARE v_idPermiso INT;
  SELECT idRol INTO v_idRol FROM rol WHERE nombre = w_nombre_rol LIMIT 1;
  IF v_idRol IS NULL THEN INSERT INTO rol(nombre) VALUES (w_nombre_rol); SET v_idRol = LAST_INSERT_ID(); END IF;
  SELECT idPermiso INTO v_idPermiso FROM permiso WHERE codigo = w_codigo_permiso LIMIT 1;
  IF v_idPermiso IS NULL THEN INSERT INTO permiso(codigo) VALUES (w_codigo_permiso); SET v_idPermiso = LAST_INSERT_ID(); END IF;
  INSERT IGNORE INTO rol_permiso(idRol,idPermiso) VALUES (v_idRol, v_idPermiso);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `seed_sp_tkt_seed_basico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `seed_sp_tkt_seed_basico`()
    COMMENT 'SEED: crea roles, permisos y asignaciones iniciales del modulo tickets'
BEGIN
  CALL seed_sp_tkt_rol_crear('Administrador','Acceso total');
  CALL seed_sp_tkt_rol_crear('Supervisor','Supervisa y edita, sin eliminar');
  CALL seed_sp_tkt_rol_crear('Operador','Opera tickets asignados');
  CALL seed_sp_tkt_rol_crear('Consulta','Solo lectura y exportar');
  CALL seed_sp_tkt_permiso_crear('TKT_LIST_ALL','Ver todos los tickets');
  CALL seed_sp_tkt_permiso_crear('TKT_LIST_ASSIGNED','Ver mis asignados');
  CALL seed_sp_tkt_permiso_crear('TKT_VIEW_DETAIL','Ver detalle');
  CALL seed_sp_tkt_permiso_crear('TKT_CREATE','Crear ticket');
  CALL seed_sp_tkt_permiso_crear('TKT_EDIT_ASSIGNED','Editar si soy asignado');
  CALL seed_sp_tkt_permiso_crear('TKT_EDIT_ANY','Editar cualquiera');
  CALL seed_sp_tkt_permiso_crear('TKT_ASSIGN','Asignar tickets');
  CALL seed_sp_tkt_permiso_crear('TKT_CLOSE','Cerrar tickets');
  CALL seed_sp_tkt_permiso_crear('TKT_DELETE','Eliminar tickets');
  CALL seed_sp_tkt_permiso_crear('TKT_EXPORT','Exportar CSV');
  CALL seed_sp_tkt_permiso_crear('TKT_COMMENT','Comentar');
  CALL seed_sp_tkt_permiso_crear('TKT_APPROVE','Aprobar tickets');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_LIST_ALL');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_LIST_ASSIGNED');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_VIEW_DETAIL');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_CREATE');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_EDIT_ANY');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_EDIT_ASSIGNED');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_ASSIGN');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_CLOSE');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_DELETE');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_EXPORT');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_COMMENT');
  CALL seed_sp_tkt_rol_permiso_asignar('Administrador','TKT_APPROVE');
  CALL seed_sp_tkt_rol_permiso_asignar('Supervisor','TKT_LIST_ALL');
  CALL seed_sp_tkt_rol_permiso_asignar('Supervisor','TKT_VIEW_DETAIL');
  CALL seed_sp_tkt_rol_permiso_asignar('Supervisor','TKT_EDIT_ANY');
  CALL seed_sp_tkt_rol_permiso_asignar('Supervisor','TKT_ASSIGN');
  CALL seed_sp_tkt_rol_permiso_asignar('Supervisor','TKT_CLOSE');
  CALL seed_sp_tkt_rol_permiso_asignar('Supervisor','TKT_EXPORT');
  CALL seed_sp_tkt_rol_permiso_asignar('Supervisor','TKT_COMMENT');
  CALL seed_sp_tkt_rol_permiso_asignar('Operador','TKT_LIST_ASSIGNED');
  CALL seed_sp_tkt_rol_permiso_asignar('Operador','TKT_VIEW_DETAIL');
  CALL seed_sp_tkt_rol_permiso_asignar('Operador','TKT_CREATE');
  CALL seed_sp_tkt_rol_permiso_asignar('Operador','TKT_EDIT_ASSIGNED');
  CALL seed_sp_tkt_rol_permiso_asignar('Operador','TKT_CLOSE');
  CALL seed_sp_tkt_rol_permiso_asignar('Operador','TKT_COMMENT');
  CALL seed_sp_tkt_rol_permiso_asignar('Consulta','TKT_LIST_ALL');
  CALL seed_sp_tkt_rol_permiso_asignar('Consulta','TKT_VIEW_DETAIL');
  CALL seed_sp_tkt_rol_permiso_asignar('Consulta','TKT_EXPORT');
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `seed_sp_tkt_usuario_rol_asignar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `seed_sp_tkt_usuario_rol_asignar`(IN w_idUsuario BIGINT, IN w_nombre_rol VARCHAR(64))
    COMMENT 'SEED: asigna un rol a un usuario'
BEGIN
  DECLARE v_idRol INT;
  SELECT idRol INTO v_idRol FROM rol WHERE nombre = w_nombre_rol LIMIT 1;
  IF v_idRol IS NULL THEN INSERT INTO rol(nombre) VALUES (w_nombre_rol); SET v_idRol = LAST_INSERT_ID(); END IF;
  INSERT IGNORE INTO usuario_rol(idUsuario,idRol) VALUES (w_idUsuario, v_idRol);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
  DECLARE v_rol_actor INT DEFAULT NULL;
  DECLARE v_ticket_existe INT DEFAULT 0;
  DECLARE v_usuario_existe INT DEFAULT 0;

  
  SELECT COUNT(*) INTO v_ticket_existe FROM tkt WHERE Id_Tkt = p_id_tkt AND Habilitado = 1;
  IF v_ticket_existe = 0 THEN
    SET p_resultado = 'Error: Ticket no existe o está inhabilitado';
    LEAVE proc;
  END IF;

  
  SELECT COUNT(*) INTO v_usuario_existe FROM usuario WHERE idUsuario = p_id_usuario_asignado AND fechaBaja IS NULL;
  IF v_usuario_existe = 0 THEN
    SET p_resultado = CONCAT('Error: Usuario ', p_id_usuario_asignado, ' no existe o está inactivo');
    LEAVE proc;
  END IF;

  
  SELECT Id_Usuario_Asignado INTO v_asignado_actual FROM tkt WHERE Id_Tkt = p_id_tkt;
  SELECT idRol INTO v_rol_actor FROM usuario_rol WHERE idUsuario = p_id_usuario_actor LIMIT 1;

  
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
    
    IF v_rol_actor NOT IN (10, 1) THEN
      SET p_resultado = 'Error: Solo Administradores y Supervisores pueden asignar tickets a otros usuarios';
      LEAVE proc;
    END IF;

    
    IF v_asignado_actual IS NOT NULL THEN
      IF v_rol_actor != 10 THEN
        SET p_resultado = 'Error: El ticket ya tiene un usuario asignado. Solo el Administrador puede reasignar';
        LEAVE proc;
      END IF;

      
      IF p_comentario IS NULL OR TRIM(p_comentario) = '' THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Comentario obligatorio: debe justificar la reasignación del ticket';
      END IF;

      
      INSERT INTO tkt_comentario (id_tkt, id_usuario, comentario, fecha)
      VALUES (p_id_tkt, p_id_usuario_actor, CONCAT('[Reasignación] ', p_comentario), NOW());
    END IF;
  END IF;

  
  UPDATE tkt
     SET Id_Usuario_Asignado = p_id_usuario_asignado,
         Date_Asignado = NOW()
   WHERE Id_Tkt = p_id_tkt;

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
    -- Result Set 1: Conteo total de no leídos
    SELECT 
        COUNT(*) AS total_no_leidos,
        SUM(CASE WHEN t.Id_Usuario_Asignado = p_id_usuario AND t.Id_Estado NOT IN (3) THEN 1 ELSE 0 END) AS pendientes_asignados
    FROM tkt_notificacion_lectura nl
    INNER JOIN tkt t ON nl.id_ticket = t.Id_Tkt
    WHERE nl.id_usuario = p_id_usuario 
      AND nl.leido = 0
      AND t.Habilitado = 1;

    -- Result Set 2: Últimos 5 tickets no leídos con detalle
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
      u.passwordUsuarioEnc AS Contraseña,
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
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
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
  FROM tkt_usuario_rol tur
  JOIN tkt_rol_permiso trp ON tur.id_rol = trp.id_rol
  JOIN tkt_permiso tp ON trp.id_permiso = tp.id_permiso
  WHERE tur.idUsuario = p_id_usuario_actor AND tp.codigo = 'TKT_RBAC_ADMIN';

  SELECT COUNT(*) INTO v_puede_ver_todos
  FROM tkt_usuario_rol tur
  JOIN tkt_rol_permiso trp ON tur.id_rol = trp.id_rol
  JOIN tkt_permiso tp ON trp.id_permiso = tp.id_permiso
  WHERE tur.idUsuario = p_id_usuario_actor
    AND tp.codigo IN ('TKT_LIST_ALL', 'VER_SOLO_DEPARTAMENTO', 'TKT_RBAC_ADMIN');

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
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
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
    DECLARE v_aprob_existente INT DEFAULT 0;
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

    -- FIX: Assignment validation - ticket must be assigned before En Proceso
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

        -- FIX: Permission check via tkt_* RBAC tables (consistent with C# AuthService)
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

        IF v_requiere_propietario = 1 THEN
            IF v_asignado_actual IS NULL OR v_asignado_actual <> p_id_usuario_actor THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el usuario asignado puede realizar esta transicion';
            END IF;
        END IF;

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

-- Dump completed on 2026-07-02 11:55:12
