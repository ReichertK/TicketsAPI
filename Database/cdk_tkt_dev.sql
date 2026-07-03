/*
SQLyog Ultimate v11.11 (64 bit)
MySQL - 5.5.27 : Database - cdk_tkt_dev
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`cdk_tkt_dev` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `cdk_tkt_dev`;

/*Table structure for table `accion` */

DROP TABLE IF EXISTS `accion`;

CREATE TABLE `accion` (
  `idAccion` bigint(20) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idAccion`,`codigo`),
  KEY `KEY_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `accion` */

LOCK TABLES `accion` WRITE;

insert  into `accion`(`idAccion`,`codigo`,`nombre`,`habilitado`) values (1,'A','Alta',0),(2,'B','Baja',0),(3,'M','Modificar',0),(4,'V','Ver',0);

UNLOCK TABLES;

/*Table structure for table `audit_config` */

DROP TABLE IF EXISTS `audit_config`;

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

/*Data for the table `audit_config` */

LOCK TABLES `audit_config` WRITE;

insert  into `audit_config`(`id_audit_config`,`entidad`,`id_entidad`,`accion`,`campo_modificado`,`valor_anterior`,`valor_nuevo`,`usuario_id`,`usuario_nombre`,`fecha`,`descripcion`) values (3,'departamento',85,'TOGGLE','activo','1','0',1,'Administrador','2026-02-20 13:31:55','Departamento Desactivado: AuditTest_Updated'),(4,'departamento',86,'INSERT',NULL,NULL,'<script>alert(123)</script> emoji_test kanji_test',1,'Administrador','2026-02-20 14:43:30','Departamento creado: <script>alert(123)</script> emoji_test kanji_test'),(5,'departamento',87,'TOGGLE','activo','1','0',1,'Administrador','2026-02-24 11:07:25','Departamento Desactivado: Depto UTF8MB4 ?'),(6,'departamento',59,'TOGGLE','activo','1','0',1,'Administrador','2026-02-27 14:16:52','Departamento Desactivado: Administración'),(7,'departamento',59,'TOGGLE','activo','0','1',1,'Administrador','2026-02-27 14:16:55','Departamento Activado: Administración'),(8,'departamento',33,'TOGGLE','activo','1','0',1,'Administrador','2026-03-03 09:36:39','Departamento Desactivado: Caja / Facturación / Autorizaciones'),(9,'departamento',33,'TOGGLE','activo','0','1',1,'Administrador','2026-03-03 09:36:42','Departamento Activado: Caja / Facturación / Autorizaciones'),(10,'rol',1,'UPDATE','nombre',NULL,'Supervisor',1,'Administrador','2026-03-03 09:37:12','Rol actualizado: Supervisor');

UNLOCK TABLES;

/*Table structure for table `audit_log` */

DROP TABLE IF EXISTS `audit_log`;

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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `audit_log` */

LOCK TABLES `audit_log` WRITE;

insert  into `audit_log`(`id_auditoria`,`tabla`,`id_registro`,`accion`,`usuario_id`,`usuario_nombre`,`valores_antiguos`,`valores_nuevos`,`fecha`,`ip_address`,`descripcion`) values (5,'tkt_transicion',2,'INSERT',1,'Admin',NULL,'{\"ticket\":1,\"estado_from\":2,\"estado_to\":6,\"asignado_old\":null,\"asignado_new\":null}','2026-07-02 12:30:17',NULL,'Ticket #1 transicion de estado 2 -> 6'),(6,'tkt',1,'DELETE',1,'Admin','{\"estado\":6,\"prioridad\":null,\"departamento\":null,\"asignado\":1,\"contenido\":\"TEST transicion 2->6 (borrar)\"}',NULL,'2026-07-02 12:30:17',NULL,'Ticket #1 eliminado'),(7,'tkt',2,'INSERT',1,'Admin',NULL,'{\"estado\":1,\"prioridad\":1,\"departamento\":59,\"empresa\":1,\"asignado\":null,\"motivo\":null}','2026-07-02 13:40:54',NULL,'Nuevo ticket #2 creado por usuario 1'),(8,'tkt',3,'INSERT',1,'Admin',NULL,'{\"estado\":1,\"prioridad\":1,\"departamento\":1,\"empresa\":1,\"asignado\":null,\"motivo\":40}','2026-07-02 13:42:13',NULL,'Nuevo ticket #3 creado por usuario 1'),(9,'tkt',4,'INSERT',1,'Admin',NULL,'{\"estado\":1,\"prioridad\":2,\"departamento\":40,\"empresa\":1,\"asignado\":null,\"motivo\":26}','2026-07-02 13:47:23',NULL,'Nuevo ticket #4 creado por usuario 1'),(10,'tkt',4,'UPDATE',1,'Admin','{\"estado\":1,\"prioridad\":2,\"departamento\":40,\"asignado\":null,\"motivo\":26}','{\"estado\":1,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','2026-07-02 13:47:41',NULL,'Ticket #4 actualizado'),(11,'tkt',4,'UPDATE',1,'Admin','{\"estado\":1,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','{\"estado\":2,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','2026-07-02 13:47:57',NULL,'Ticket #4 actualizado'),(12,'tkt_transicion',3,'INSERT',1,'Admin',NULL,'{\"ticket\":4,\"estado_from\":1,\"estado_to\":2,\"asignado_old\":null,\"asignado_new\":null}','2026-07-02 13:47:57',NULL,'Ticket #4 transicion de estado 1 -> 2'),(13,'tkt',4,'UPDATE',1,'Admin','{\"estado\":2,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','{\"estado\":5,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','2026-07-02 13:48:42',NULL,'Ticket #4 actualizado'),(14,'tkt_transicion',4,'INSERT',1,'Admin',NULL,'{\"ticket\":4,\"estado_from\":2,\"estado_to\":5,\"asignado_old\":null,\"asignado_new\":null}','2026-07-02 13:48:42',NULL,'Ticket #4 transicion de estado 2 -> 5'),(15,'tkt',4,'UPDATE',1,'Admin','{\"estado\":5,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','{\"estado\":6,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','2026-07-02 13:48:49',NULL,'Ticket #4 actualizado'),(16,'tkt_transicion',5,'INSERT',1,'Admin',NULL,'{\"ticket\":4,\"estado_from\":5,\"estado_to\":6,\"asignado_old\":null,\"asignado_new\":null}','2026-07-02 13:48:49',NULL,'Ticket #4 transicion de estado 5 -> 6'),(17,'tkt',4,'UPDATE',1,'Admin','{\"estado\":6,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','{\"estado\":3,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','2026-07-02 13:48:55',NULL,'Ticket #4 actualizado'),(18,'tkt_transicion',6,'INSERT',1,'Admin',NULL,'{\"ticket\":4,\"estado_from\":6,\"estado_to\":3,\"asignado_old\":null,\"asignado_new\":null}','2026-07-02 13:48:55',NULL,'Ticket #4 transicion de estado 6 -> 3'),(19,'tkt',4,'UPDATE',1,'Admin','{\"estado\":3,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','{\"estado\":7,\"prioridad\":2,\"departamento\":40,\"asignado\":1,\"motivo\":26}','2026-07-02 13:49:02',NULL,'Ticket #4 actualizado'),(20,'tkt_transicion',7,'INSERT',1,'Admin',NULL,'{\"ticket\":4,\"estado_from\":3,\"estado_to\":7,\"asignado_old\":null,\"asignado_new\":null}','2026-07-02 13:49:02',NULL,'Ticket #4 transicion de estado 3 -> 7'),(21,'tkt',5,'INSERT',1,'Admin',NULL,'{\"estado\":1,\"prioridad\":2,\"departamento\":25,\"empresa\":1,\"asignado\":null,\"motivo\":19}','2026-07-02 14:01:59',NULL,'Nuevo ticket #5 creado por usuario 1'),(22,'tkt',5,'UPDATE',1,'Admin','{\"estado\":1,\"prioridad\":2,\"departamento\":25,\"asignado\":null,\"motivo\":19}','{\"estado\":1,\"prioridad\":2,\"departamento\":25,\"asignado\":2,\"motivo\":19}','2026-07-02 14:02:32',NULL,'Ticket #5 actualizado');

UNLOCK TABLES;

/*Table structure for table `departamento` */

DROP TABLE IF EXISTS `departamento`;

CREATE TABLE `departamento` (
  `Id_Departamento` int(20) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1',
  `fechaBaja` datetime DEFAULT NULL,
  PRIMARY KEY (`Id_Departamento`),
  UNIQUE KEY `uq_depto_nombre` (`Nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `departamento` */

LOCK TABLES `departamento` WRITE;

insert  into `departamento`(`Id_Departamento`,`Nombre`,`Descripcion`,`Habilitado`,`fechaBaja`) values (1,'Departamento A',NULL,1,NULL),(2,'Departamento B',NULL,1,NULL),(3,'Departamento C',NULL,1,NULL),(4,'Mesa de Ayuda / Soporte N1',NULL,1,NULL),(5,'Soporte N2 / Plataformas',NULL,1,NULL),(6,'Infraestructura',NULL,1,NULL),(7,'Redes',NULL,1,NULL),(8,'Telecomunicaciones',NULL,1,NULL),(9,'Seguridad Informática',NULL,1,NULL),(10,'Desarrollo de Software',NULL,1,NULL),(11,'QA / Testing',NULL,1,NULL),(12,'Bases de Datos / DBA',NULL,1,NULL),(13,'Aplicaciones Corporativas / ERP',NULL,1,NULL),(14,'BI / Analítica',NULL,1,NULL),(15,'Gestión de Servicios (ITSM)',NULL,1,NULL),(16,'Ventas / Comercial',NULL,1,NULL),(17,'Atención al Cliente',NULL,1,NULL),(18,'Operaciones',NULL,1,NULL),(19,'Logística',NULL,1,NULL),(20,'Producción',NULL,1,NULL),(21,'Calidad',NULL,1,NULL),(22,'Compras / Abastecimiento',NULL,1,NULL),(23,'Finanzas / Contabilidad',NULL,1,NULL),(24,'Tesorería',NULL,1,NULL),(25,'Créditos y Cobranzas',NULL,1,NULL),(26,'Recursos Humanos',NULL,1,NULL),(27,'Marketing / Comunicación',NULL,1,NULL),(28,'Legal',NULL,1,NULL),(29,'Dirección / Gerencia',NULL,0,'2026-02-10 14:02:37'),(30,'Sucursales / Oficinas',NULL,1,NULL),(31,'Recepción y Admisión',NULL,1,NULL),(32,'Turnos / Call Center',NULL,1,NULL),(33,'Caja / Facturación / Autorizaciones',NULL,1,NULL),(34,'Atención al Paciente',NULL,1,NULL),(35,'Radiología Convencional (Rayos X)',NULL,1,NULL),(36,'Tomografía Computada (TC)',NULL,1,NULL),(37,'Resonancia Magnética (RM)',NULL,1,NULL),(38,'Ecografía',NULL,1,NULL),(39,'Mamografía',NULL,1,NULL),(40,'Densitometría Ósea (DEXA)',NULL,1,NULL),(41,'Medicina Nuclear',NULL,1,NULL),(42,'Radiología Intervencionista / Hemodinamia',NULL,1,NULL),(43,'Médicos Informantes (Radiología)',NULL,1,NULL),(44,'Técnicos Radiólogos',NULL,1,NULL),(45,'Jefatura de Diagnóstico por Imágenes',NULL,1,NULL),(46,'Protección Radiológica / Física Médica',NULL,1,NULL),(47,'Archivo y Entrega de Estudios',NULL,1,NULL),(48,'Calidad Clínica / Protocolos',NULL,1,NULL),(49,'Consultorios',NULL,1,NULL),(50,'Kinesiología y Rehabilitación',NULL,1,NULL),(51,'Sistemas / Soluciones IT',NULL,1,NULL),(52,'PACS / RIS',NULL,1,NULL),(53,'Integraciones HIS/EMR (HL7/DICOM)',NULL,1,NULL),(54,'Seguridad de la Información',NULL,1,NULL),(55,'Mantenimiento Edilicio',NULL,1,NULL),(56,'Mantenimiento Biomédico',NULL,1,NULL),(57,'Compras / Suministros (Insumos Radiológicos)',NULL,1,NULL),(58,'Servicios Generales / Limpieza',NULL,1,NULL),(59,'Administración',NULL,1,NULL),(60,'Legales y Compliance',NULL,1,NULL),(61,'Calidad y Auditoría',NULL,1,NULL),(62,'Marketing / Comunicación Institucional',NULL,1,NULL),(63,'Dirección Médica',NULL,1,NULL),(64,'Dirección General / Gerencia',NULL,1,NULL),(65,'Sistemas',NULL,1,NULL),(66,'Comercial',NULL,1,NULL),(68,'RRHH',NULL,1,NULL),(83,'Finanzas','Departamento de Finanzas',1,NULL),(87,'Depto UTF8MB4 ?','Kanji 全球',0,'2026-02-24 11:07:25');

UNLOCK TABLES;

/*Table structure for table `empresa` */

DROP TABLE IF EXISTS `empresa`;

CREATE TABLE `empresa` (
  `idEmpresa` bigint(20) NOT NULL AUTO_INCREMENT,
  `cuit` varchar(11) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'cuit de la empresa sin guion',
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'descripcion o razon social',
  `codigo` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'codigo de la empresa',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idEmpresa`),
  KEY `KEY_cuit` (`cuit`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `empresa` */

LOCK TABLES `empresa` WRITE;

insert  into `empresa`(`idEmpresa`,`cuit`,`nombre`,`codigo`,`habilitado`) values (1,'30708839309','CEDIAC BERAZATEGUI S.R.L.','CDK',0),(2,'30714800392','SUR SALUDPYME S.R.L.','SUR',0);

UNLOCK TABLES;

/*Table structure for table `error_log` */

DROP TABLE IF EXISTS `error_log`;

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

/*Data for the table `error_log` */

LOCK TABLES `error_log` WRITE;

UNLOCK TABLES;

/*Table structure for table `estado` */

DROP TABLE IF EXISTS `estado`;

CREATE TABLE `estado` (
  `Id_Estado` int(11) NOT NULL AUTO_INCREMENT,
  `TipoEstado` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1',
  `fechaBaja` datetime DEFAULT NULL,
  PRIMARY KEY (`Id_Estado`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `estado` */

LOCK TABLES `estado` WRITE;

insert  into `estado`(`Id_Estado`,`TipoEstado`,`Descripcion`,`Habilitado`,`fechaBaja`) values (1,'Abierto',NULL,1,NULL),(2,'En Proceso',NULL,1,NULL),(3,'Cerrado',NULL,1,NULL),(4,'En Espera',NULL,1,NULL),(5,'Pendiente Aprobación',NULL,1,NULL),(6,'Resuelto',NULL,1,NULL),(7,'Reabierto',NULL,1,NULL);

UNLOCK TABLES;

/*Table structure for table `failed_login_attempts` */

DROP TABLE IF EXISTS `failed_login_attempts`;

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
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `failed_login_attempts` */

LOCK TABLES `failed_login_attempts` WRITE;

insert  into `failed_login_attempts`(`id`,`usuario_nombre`,`ip_address`,`fecha`,`razon`) values (6,'admin@tickets.com','127.0.0.1','2026-02-27 12:30:21',NULL),(7,'sepervisor','127.0.0.1','2026-02-27 13:44:46',NULL),(8,'admin@test.com','127.0.0.1','2026-02-28 10:44:45',NULL),(9,'admin@test.com','127.0.0.1','2026-02-28 10:44:59',NULL),(10,'admin@test.com','127.0.0.1','2026-02-28 10:45:12',NULL),(11,'admin@test.com','127.0.0.1','2026-02-28 10:45:18',NULL);

UNLOCK TABLES;

/*Table structure for table `grupo` */

DROP TABLE IF EXISTS `grupo`;

CREATE TABLE `grupo` (
  `Id_Grupo` int(11) NOT NULL AUTO_INCREMENT,
  `Tipo_Grupo` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Id_Grupo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `grupo` */

LOCK TABLES `grupo` WRITE;

insert  into `grupo`(`Id_Grupo`,`Tipo_Grupo`) values (1,'admin'),(2,'usuario');

UNLOCK TABLES;

/*Table structure for table `motivo` */

DROP TABLE IF EXISTS `motivo`;

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

/*Data for the table `motivo` */

LOCK TABLES `motivo` WRITE;

insert  into `motivo`(`Id_Motivo`,`Nombre`,`Descripcion`,`Categoria`,`id_departamento`,`Habilitado`,`fechaBaja`) values (1,'Motivo A',NULL,NULL,NULL,1,NULL),(2,'Motivo B',NULL,NULL,NULL,1,NULL),(3,'Motivo C',NULL,NULL,NULL,1,NULL),(4,'Turno / Reprogramación',NULL,NULL,NULL,1,NULL),(5,'Autorización de Obra Social',NULL,NULL,NULL,1,NULL),(6,'Facturación / Cobranza',NULL,NULL,NULL,1,NULL),(7,'Recepción / Admisión',NULL,NULL,NULL,1,NULL),(8,'Entrega de Estudios / Duplicado',NULL,NULL,NULL,1,NULL),(9,'Satisfacción del Paciente / Queja',NULL,NULL,NULL,1,NULL),(10,'Rayos X - Orden / Preparación',NULL,NULL,NULL,1,NULL),(11,'Rayos X - Resultado / Entrega',NULL,NULL,NULL,1,NULL),(12,'Tomografía - Orden / Preparación',NULL,NULL,NULL,1,NULL),(13,'Tomografía - Contraste / Reacción',NULL,NULL,NULL,1,NULL),(14,'Resonancia - Orden / Preparación',NULL,NULL,NULL,1,NULL),(15,'Resonancia - Implantes / Contraindicaciones',NULL,NULL,NULL,1,NULL),(16,'Ecografía - Agenda / Preparación',NULL,NULL,NULL,1,NULL),(17,'Mamografía - Orden / Preparación',NULL,NULL,NULL,1,NULL),(18,'DEXA - Orden / Preparación',NULL,NULL,NULL,1,NULL),(19,'Informe - Retraso',NULL,NULL,NULL,1,NULL),(20,'Informe - Aclaración / Addendum',NULL,NULL,NULL,1,NULL),(21,'Informe - Corrección de Datos',NULL,NULL,NULL,1,NULL),(22,'PACS - Visualización de Imágenes',NULL,NULL,NULL,1,NULL),(23,'PACS - Envío/Recepción DICOM',NULL,NULL,NULL,1,NULL),(24,'RIS - Agenda / Admisión',NULL,NULL,NULL,1,NULL),(25,'RIS - Falla de Integración',NULL,NULL,NULL,1,NULL),(26,'HIS/EMR - Interfaz HL7',NULL,NULL,NULL,1,NULL),(27,'Portal Paciente / Médicos - Acceso',NULL,NULL,NULL,1,NULL),(28,'Equipamiento RX - Falla',NULL,NULL,NULL,1,NULL),(29,'Tomógrafo - Falla',NULL,NULL,NULL,1,NULL),(30,'Resonador - Falla',NULL,NULL,NULL,1,NULL),(31,'Ecógrafo - Falla',NULL,NULL,NULL,1,NULL),(32,'Mamógrafo - Falla',NULL,NULL,NULL,1,NULL),(33,'Impresora Dry - Falla / Insumos',NULL,NULL,NULL,1,NULL),(34,'CR/DR - Digitalizador - Falla',NULL,NULL,NULL,1,NULL),(35,'Protección Radiológica',NULL,NULL,NULL,1,NULL),(36,'Calibración / Control de Calidad',NULL,NULL,NULL,1,NULL),(37,'Gestión de Incidentes (Seguridad Info)',NULL,NULL,NULL,1,NULL),(38,'Kinesiología - Agenda / Práctica',NULL,NULL,NULL,1,NULL),(39,'Consultorios - Agenda / Atención',NULL,NULL,NULL,1,NULL),(40,'Infraestructura - Climatización',NULL,NULL,NULL,1,NULL),(41,'Infraestructura - Electricidad',NULL,NULL,NULL,1,NULL),(42,'Servicios - Limpieza / Residuos Patológicos',NULL,NULL,NULL,1,NULL),(43,'Incidente',NULL,'Soporte',NULL,1,NULL),(44,'Solicitud',NULL,'Servicio',NULL,1,NULL),(45,'Consulta',NULL,'Información',NULL,1,NULL),(60,'Error de Factura','Error en facturación','Finanzas',NULL,0,'2026-02-20 11:32:26');

UNLOCK TABLES;

/*Table structure for table `notificacion_alerta` */

DROP TABLE IF EXISTS `notificacion_alerta`;

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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `notificacion_alerta` */

LOCK TABLES `notificacion_alerta` WRITE;

insert  into `notificacion_alerta`(`id_alerta`,`id_usuario`,`tipo`,`id_ticket`,`id_comentario`,`mensaje`,`leida`,`fecha`) values (1,2,'mencion',9,4,'Te mencionaron en el ticket #9',0,'2026-02-27 12:54:25'),(2,2,'mencion',6,NULL,'Te asignaron el ticket #6',0,'2026-02-27 13:39:46'),(3,2,'mencion',8,NULL,'Te asignaron el ticket #8',0,'2026-02-27 13:40:15'),(4,2,'asignacion',7,NULL,'Te asignaron el ticket #7',0,'2026-02-27 13:42:53'),(5,3,'asignacion',3,NULL,'Te asignaron el ticket #3',0,'2026-02-28 15:17:53'),(6,3,'asignacion',11,NULL,'Te asignaron el ticket #11',0,'2026-03-03 09:35:28'),(7,2,'asignacion',1,NULL,'Te asignaron el ticket #1',0,'2026-03-03 12:18:28'),(8,2,'asignacion',11,NULL,'Te asignaron el ticket #11',0,'2026-03-03 12:35:42'),(9,2,'asignacion',7,NULL,'Te asignaron el ticket #7',0,'2026-03-03 12:43:20'),(10,2,'asignacion',13,NULL,'Te asignaron el ticket #13',0,'2026-03-03 12:45:49'),(11,2,'asignacion',5,NULL,'Te asignaron el ticket #5',0,'2026-07-02 14:02:32');

UNLOCK TABLES;

/*Table structure for table `notificaciones` */

DROP TABLE IF EXISTS `notificaciones`;

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

/*Data for the table `notificaciones` */

LOCK TABLES `notificaciones` WRITE;

UNLOCK TABLES;

/*Table structure for table `perfil` */

DROP TABLE IF EXISTS `perfil`;

CREATE TABLE `perfil` (
  `idPerfil` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id de perfil',
  `nombre` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'descripcion o nombre del perfil',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idPerfil`),
  KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `perfil` */

LOCK TABLES `perfil` WRITE;

insert  into `perfil`(`idPerfil`,`nombre`,`habilitado`) values (1,'Operador',0),(2,'Auditor Médico',0),(3,'Supervisor',0),(4,'Administrador',0),(5,'Prestador',0),(6,'Operador internación',0),(7,'Auditor internación',0),(8,'Médico informante',0),(9,'Técnica/o',0),(10,'Secretaria/o',0),(11,'Técnica/o Jefe',0),(12,'Consulta',0);

UNLOCK TABLES;

/*Table structure for table `perfil_accion_sistema` */

DROP TABLE IF EXISTS `perfil_accion_sistema`;

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

/*Data for the table `perfil_accion_sistema` */

LOCK TABLES `perfil_accion_sistema` WRITE;

insert  into `perfil_accion_sistema`(`ID`,`idPerfil`,`codigoAccion`,`idSistema`,`habilitado`) values (1,1,'A,B,M,V','CDK_CNS',0),(2,3,'A,B,M,V','CDK_CNS',0),(3,4,'A,B,M,V','CDK_CNS',0),(4,1,'A,B,M,V','CDK_AUT',0),(5,2,'A,B,M,V','CDK_AUT',0),(6,3,'A,B,M,V','CDK_AUT',0),(7,4,'A,B,M,V','CDK_AUT',0),(8,5,'A,B,M,V','CDK_AUT',0),(9,6,'A,B,M,V','CDK_AUT',0),(10,7,'A,B,M,V','CDK_AUT',0),(11,1,'A,B,M,V','CDK_PAD',0),(12,3,'A,B,M,V','CDK_PAD',0),(13,4,'A,B,M,V','CDK_PAD',0),(14,1,'A,B,M,V','CDK_EST',0),(15,4,'A,B,M,V','CDK_EST',0),(16,1,'A,B,M,V','CDK_RYS',0),(17,4,'A,B,M,V','CDK_RYS',0),(18,1,'A,B,M,V','CDK_STK',0),(19,3,'A,B,M,V','CDK_STK',0),(20,4,'A,B,M,V','CDK_STK',0),(21,8,'A,B,M,V','CDK_EST',0),(22,1,'A,B,M,V','CDK_FIS',0),(23,3,'A,B,M,V','CDK_FIS',0),(24,4,'A,B,M,V','CDK_FIS',0),(25,9,'A,B,M,V','CDK_EST',0),(26,10,'A,B,M,V','CDK_EST',0),(27,11,'A,B,M,V','CDK_EST',0);

UNLOCK TABLES;

/*Table structure for table `permiso` */

DROP TABLE IF EXISTS `permiso`;

CREATE TABLE `permiso` (
  `idPermiso` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`idPermiso`),
  UNIQUE KEY `uq_permiso_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `permiso` */

LOCK TABLES `permiso` WRITE;

insert  into `permiso`(`idPermiso`,`codigo`,`descripcion`) values (1,'TKT_CREATE','Crear tickets'),(2,'TKT_LIST_ALL','Listar todos'),(3,'TKT_LIST_ASSIGNED','Listar asignados'),(4,'TKT_EDIT_ANY','Editar cualquiera'),(5,'TKT_EDIT_ASSIGNED','Editar asignados'),(6,'TKT_DELETE','Eliminar'),(7,'TKT_APPROVE','Aprobar'),(8,'TKT_COMMENT','Comentar'),(9,'TKT_START','Iniciar'),(10,'TKT_RESOLVE','Resolver'),(11,'TKT_EXPORT','Exportar'),(12,'TKT_WAIT','Poner en espera'),(13,'TKT_REQUEST_APPROVAL','Solicitar aprobación'),(14,'TKT_CLOSE','Cerrar'),(15,'TKT_REOPEN','Reabrir'),(16,'TKT_RBAC_ADMIN','Admin RBAC'),(17,'TKT_ASSIGN','Asignar tickets a otros usuarios'),(18,'VER_SOLO_DEPARTAMENTO','Ver solo tickets del departamento propio'),(19,'TKT_VIEW_DETAIL','Ver detalle del ticket');

UNLOCK TABLES;

/*Table structure for table `prioridad` */

DROP TABLE IF EXISTS `prioridad`;

CREATE TABLE `prioridad` (
  `Id_Prioridad` int(11) NOT NULL AUTO_INCREMENT,
  `NombrePrioridad` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Habilitado` tinyint(1) NOT NULL DEFAULT '1',
  `fechaBaja` datetime DEFAULT NULL,
  PRIMARY KEY (`Id_Prioridad`),
  UNIQUE KEY `uq_prioridad_nombre` (`NombrePrioridad`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `prioridad` */

LOCK TABLES `prioridad` WRITE;

insert  into `prioridad`(`Id_Prioridad`,`NombrePrioridad`,`Descripcion`,`Habilitado`,`fechaBaja`) values (1,'Alta',NULL,1,NULL),(2,'Media',NULL,1,NULL),(3,'Baja',NULL,1,NULL),(7,'Crítica',NULL,1,NULL);

UNLOCK TABLES;

/*Table structure for table `rol` */

DROP TABLE IF EXISTS `rol`;

CREATE TABLE `rol` (
  `idRol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`idRol`),
  UNIQUE KEY `uq_rol_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `rol` */

LOCK TABLES `rol` WRITE;

insert  into `rol`(`idRol`,`nombre`) values (10,'Administrador'),(2,'Agente'),(11,'Aprobador'),(12,'Consulta'),(3,'Operador'),(1,'Supervisor');

UNLOCK TABLES;

/*Table structure for table `rol_permiso` */

DROP TABLE IF EXISTS `rol_permiso`;

CREATE TABLE `rol_permiso` (
  `idRol` int(11) NOT NULL,
  `idPermiso` int(11) NOT NULL,
  PRIMARY KEY (`idRol`,`idPermiso`),
  KEY `fk_rol_permiso_permiso` (`idPermiso`),
  CONSTRAINT `fk_rol_permiso_permiso` FOREIGN KEY (`idPermiso`) REFERENCES `permiso` (`idPermiso`) ON DELETE CASCADE,
  CONSTRAINT `fk_rol_permiso_rol` FOREIGN KEY (`idRol`) REFERENCES `rol` (`idRol`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `rol_permiso` */

LOCK TABLES `rol_permiso` WRITE;

insert  into `rol_permiso`(`idRol`,`idPermiso`) values (1,1),(2,1),(3,1),(10,1),(1,2),(10,2),(11,2),(12,2),(1,3),(2,3),(3,3),(10,3),(1,4),(10,4),(1,5),(2,5),(3,5),(10,5),(10,6),(1,7),(10,7),(11,7),(1,8),(2,8),(3,8),(10,8),(11,8),(1,9),(2,9),(3,9),(10,9),(1,10),(2,10),(3,10),(10,10),(1,11),(10,11),(12,11),(1,12),(2,12),(3,12),(10,12),(1,13),(2,13),(3,13),(10,13),(1,14),(3,14),(10,14),(1,15),(2,15),(3,15),(10,15),(10,16),(1,17),(10,17),(1,18),(3,18),(10,18),(1,19),(2,19),(3,19),(10,19),(11,19),(12,19);

UNLOCK TABLES;

/*Table structure for table `sistema` */

DROP TABLE IF EXISTS `sistema`;

CREATE TABLE `sistema` (
  `idSistema` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idSistema`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `sistema` */

LOCK TABLES `sistema` WRITE;

insert  into `sistema`(`idSistema`,`nombre`,`habilitado`) values ('CDK_AUT','AUTORIZACIONES',0),('CDK_CNS','CONSUMOS',0),('CDK_CNV','CONVENIOS',0),('CDK_EST','IMÁGENES',0),('CDK_FIS','FISIO',0),('CDK_HUB','HUB',0),('CDK_NYP','NORMAS Y PROCEDIMIENTOS',0),('CDK_PAD','PADRÓN',0),('CDK_RYS','RECLAMOS/SUGERENCIAS',0),('CDK_STK','STOCK',0),('CDK_TKT','TICKETS',1),('CDK_TUR','TURNOS',0);

UNLOCK TABLES;

/*Table structure for table `sucursal` */

DROP TABLE IF EXISTS `sucursal`;

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

/*Data for the table `sucursal` */

LOCK TABLES `sucursal` WRITE;

insert  into `sucursal`(`idSucursal`,`idEmpresa`,`descripcion`,`codigo`,`domicilio`,`telefono`,`email`,`afip`,`habilitado`) values (1,1,'CALLE 10','C10','CALLE 10 5085 E/ 150 Y 151 - BERAZATEGUI','42568000',NULL,'1001',0),(2,1,'CALLE 7','C7','CALLE 7 4655 E/ 146 Y 147 - BERAZATEGUI',NULL,NULL,'1002',0),(3,2,'SAN JUSTO','C6','AV. MITRE 580 - BERAZATEGUI',NULL,NULL,'1001',1),(4,2,'MORENO 500','QM500','MORENO 522 - QUILMES',NULL,NULL,'1001',1),(5,2,'CAP QUILMES','CENT','CENTRAL DE GESTION',NULL,NULL,'1001',1),(6,1,'CAPILLA','CAPI',NULL,NULL,NULL,'1004',1),(7,1,'CENTRO MEDICO MONTEA','CMM','BERNARDO DE MONTEAGUDO 2632 - F. VARELA',NULL,NULL,'1005',1),(8,1,'H. PRIMO 343','HP343','HUMBERTO PRIMO 343 - QUILMES',NULL,NULL,'1006',0),(9,1,'SOLANO','SOL',NULL,NULL,NULL,'1000',1),(10,0,'Casa Central',NULL,NULL,NULL,NULL,'1000',0),(11,0,'Sucursal Norte',NULL,NULL,NULL,NULL,'1000',0),(12,0,'Sucursal Sur',NULL,NULL,NULL,NULL,'1000',0);

UNLOCK TABLES;

/*Table structure for table `tkt` */

DROP TABLE IF EXISTS `tkt`;

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `tkt` */

LOCK TABLES `tkt` WRITE;

insert  into `tkt`(`Id_Tkt`,`Id_Estado`,`Date_Creado`,`Date_Cierre`,`Date_Asignado`,`Date_Cambio_Estado`,`Id_Usuario`,`Id_Usuario_Asignado`,`Id_Empresa`,`Id_Perfil`,`Id_Motivo`,`Id_Sucursal`,`Habilitado`,`Id_Prioridad`,`Contenido`,`Id_Departamento`) values (2,1,'2026-07-02 13:40:54',NULL,NULL,NULL,1,NULL,1,1,NULL,2,1,1,'Ticket de prueba local',59),(3,1,'2026-07-02 13:42:13',NULL,NULL,NULL,1,NULL,1,1,40,2,1,1,'prueba manual',1),(4,7,'2026-07-02 13:47:23','2026-07-02 13:48:55','2026-07-02 13:47:41','2026-07-02 13:49:02',1,1,1,1,26,2,1,2,'asdasdasdasd',40),(5,1,'2026-07-02 14:01:59',NULL,'2026-07-02 14:02:32',NULL,1,2,1,1,19,2,1,2,'prueba para admin2',25);

UNLOCK TABLES;

/*Table structure for table `tkt_aprobacion` */

DROP TABLE IF EXISTS `tkt_aprobacion`;

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `tkt_aprobacion` */

LOCK TABLES `tkt_aprobacion` WRITE;

insert  into `tkt_aprobacion`(`id_aprob`,`id_tkt`,`solicitante_id`,`aprobador_id`,`estado`,`comentario`,`fecha_solicitud`,`fecha_respuesta`) values (1,4,1,1,'pendiente','asdasdasd','2026-07-02 13:48:42',NULL);

UNLOCK TABLES;

/*Table structure for table `tkt_comentario` */

DROP TABLE IF EXISTS `tkt_comentario`;

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

/*Data for the table `tkt_comentario` */

LOCK TABLES `tkt_comentario` WRITE;

UNLOCK TABLES;

/*Table structure for table `tkt_notificacion_lectura` */

DROP TABLE IF EXISTS `tkt_notificacion_lectura`;

CREATE TABLE `tkt_notificacion_lectura` (
  `id_ticket` bigint(20) NOT NULL,
  `id_usuario` bigint(20) NOT NULL,
  `leido` tinyint(1) NOT NULL DEFAULT '0',
  `fecha_cambio` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_ticket`,`id_usuario`),
  KEY `idx_usuario_leido` (`id_usuario`,`leido`),
  KEY `idx_ticket` (`id_ticket`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `tkt_notificacion_lectura` */

LOCK TABLES `tkt_notificacion_lectura` WRITE;

insert  into `tkt_notificacion_lectura`(`id_ticket`,`id_usuario`,`leido`,`fecha_cambio`) values (5,2,1,'2026-07-02 14:29:17');

UNLOCK TABLES;

/*Table structure for table `tkt_search` */

DROP TABLE IF EXISTS `tkt_search`;

CREATE TABLE `tkt_search` (
  `Id_Tkt` bigint(20) NOT NULL,
  `Term` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Id_Tkt`,`Term`),
  KEY `idx_term` (`Term`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `tkt_search` */

LOCK TABLES `tkt_search` WRITE;

UNLOCK TABLES;

/*Table structure for table `tkt_suscriptor` */

DROP TABLE IF EXISTS `tkt_suscriptor`;

CREATE TABLE `tkt_suscriptor` (
  `id_tkt` bigint(20) NOT NULL,
  `id_usuario` bigint(20) NOT NULL DEFAULT '0',
  `fecha_registro` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_tkt`,`id_usuario`),
  KEY `idx_ts_usuario` (`id_usuario`),
  CONSTRAINT `fk_suscriptor_tkt` FOREIGN KEY (`id_tkt`) REFERENCES `tkt` (`Id_Tkt`) ON DELETE CASCADE,
  CONSTRAINT `fk_suscriptor_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `tkt_suscriptor` */

LOCK TABLES `tkt_suscriptor` WRITE;

UNLOCK TABLES;

/*Table structure for table `tkt_transicion` */

DROP TABLE IF EXISTS `tkt_transicion`;

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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `tkt_transicion` */

LOCK TABLES `tkt_transicion` WRITE;

insert  into `tkt_transicion`(`id_transicion`,`id_tkt`,`estado_from`,`estado_to`,`id_usuario_actor`,`id_usuario_asignado_old`,`id_usuario_asignado_new`,`comentario`,`motivo`,`meta_json`,`fecha`) values (3,4,1,2,1,NULL,NULL,'en proceso prueba',NULL,NULL,'2026-07-02 13:47:57'),(4,4,2,5,1,NULL,NULL,'asdasdasd',NULL,NULL,'2026-07-02 13:48:42'),(5,4,5,6,1,NULL,NULL,'prueba',NULL,NULL,'2026-07-02 13:48:49'),(6,4,6,3,1,NULL,NULL,'prueba',NULL,NULL,'2026-07-02 13:48:55'),(7,4,3,7,1,NULL,NULL,'prueba',NULL,NULL,'2026-07-02 13:49:02');

UNLOCK TABLES;

/*Table structure for table `tkt_transicion_regla` */

DROP TABLE IF EXISTS `tkt_transicion_regla`;

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

/*Data for the table `tkt_transicion_regla` */

LOCK TABLES `tkt_transicion_regla` WRITE;

insert  into `tkt_transicion_regla`(`id`,`estado_from`,`estado_to`,`requiere_propietario`,`permiso_requerido`,`requiere_aprobacion`,`descripcion`,`habilitado`) values (1,1,2,0,'TKT_START',0,'Iniciar/tomar ticket',1),(2,2,3,1,'TKT_CLOSE',0,'Cierre directo desde proceso',1),(4,4,3,1,'TKT_WAIT',0,'Cerrar desde espera',1),(6,5,3,0,'TKT_APPROVE',0,'Aprobar y cerrar',1),(7,5,6,0,'TKT_APPROVE',0,'Aprobar como resuelto',1),(9,6,7,0,'TKT_REOPEN',0,'Reabrir por inconformidad',1),(38,2,4,1,'TKT_WAIT',0,'Pausar trabajo',1),(39,4,2,1,'TKT_WAIT',0,'Retomar trabajo',1),(40,2,5,1,'TKT_REQUEST_APPROVAL',1,'Solicitar aprobacion',1),(41,5,2,0,'TKT_APPROVE',0,'Aprobar y continuar',1),(43,2,6,1,'TKT_RESOLVE',0,'Resolver directo desde En Proceso (sin aprobacion)',1),(44,6,3,0,'TKT_CLOSE',0,'Confirmar cierre final',1),(45,3,7,0,'TKT_REOPEN',0,'Reapertura de ticket cerrado',1),(46,7,2,0,'TKT_START',0,'Retomar ticket reabierto',1),(47,1,4,0,'TKT_WAIT',0,'Poner en espera antes de iniciar',1);

UNLOCK TABLES;

/*Table structure for table `usuario` */

DROP TABLE IF EXISTS `usuario`;

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `usuario` */

LOCK TABLES `usuario` WRITE;

insert  into `usuario`(`idUsuario`,`nombre`,`telefono`,`email`,`nota`,`passwordUsuario`,`passwordUsuarioEnc`,`firma`,`firma_aclaracion`,`fechaAlta`,`fechaBaja`,`tipo`,`idCliente`,`idKine`,`refresh_token_hash`,`refresh_token_expires`,`last_login`,`intentos_fallidos`,`bloqueado_hasta`,`Id_Departamento`) values (1,'Admin',NULL,'admin@local.test',NULL,'changeme','$2a$11$vBoOmWtwW1h2.3UEE.8O9u9hX8/7/nvJewXpjxSyc.21CY5yZCQja',NULL,NULL,'2026-07-02',NULL,'INT',0,0,'VbhiYPtljOYKm7pXg3YoLBzs1ESUuZ8dcOj5aHlyWjc=','2026-07-09 17:22:53','2026-07-02 14:22:53',0,NULL,NULL),(2,'admin2',NULL,'admin@admin.com',NULL,'$2a$11$Km1anTerfsAW4uzg.Pa5S.HGUl5JOESfWSz1zUVrffwQVmM4WyCse','$2a$11$Km1anTerfsAW4uzg.Pa5S.HGUl5JOESfWSz1zUVrffwQVmM4WyCse',NULL,NULL,'2026-07-02',NULL,'INT',0,1,'SrparG/8tFqquTXiLfkpXe6C/flFh1bnXc7G4Bg6Z5s=','2026-07-09 17:01:21','2026-07-02 14:01:21',0,NULL,NULL);

UNLOCK TABLES;

/*Table structure for table `usuario_empresa_sucursal_perfil_sistema` */

DROP TABLE IF EXISTS `usuario_empresa_sucursal_perfil_sistema`;

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

/*Data for the table `usuario_empresa_sucursal_perfil_sistema` */

LOCK TABLES `usuario_empresa_sucursal_perfil_sistema` WRITE;

insert  into `usuario_empresa_sucursal_perfil_sistema`(`ID`,`idUsuario`,`idEmpresa`,`idSucursal`,`idSistema`,`idPerfil`,`habilitado`) values (1033,1,1,2,'CDK_TKT',1,1),(1034,2,1,2,'CDK_TKT',3,1),(1035,3,1,2,'CDK_TKT',1,1),(1036,1,1,1,NULL,1,0),(1037,2,1,1,NULL,1,0),(1038,3,1,1,NULL,1,0);

UNLOCK TABLES;

/*Table structure for table `usuario_rol` */

DROP TABLE IF EXISTS `usuario_rol`;

CREATE TABLE `usuario_rol` (
  `idUsuario` bigint(20) NOT NULL DEFAULT '0',
  `idRol` int(11) NOT NULL,
  PRIMARY KEY (`idUsuario`,`idRol`),
  KEY `fk_usuario_rol_rol` (`idRol`),
  CONSTRAINT `fk_usuario_rol_rol` FOREIGN KEY (`idRol`) REFERENCES `rol` (`idRol`) ON DELETE CASCADE,
  CONSTRAINT `fk_usuario_rol_usuario` FOREIGN KEY (`idUsuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `usuario_rol` */

LOCK TABLES `usuario_rol` WRITE;

insert  into `usuario_rol`(`idUsuario`,`idRol`) values (1,10),(2,10);

UNLOCK TABLES;

/*Table structure for table `usuario_tipo` */

DROP TABLE IF EXISTS `usuario_tipo`;

CREATE TABLE `usuario_tipo` (
  `usuTipoId` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuTipoDesc` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usuTipoHabil` int(1) DEFAULT '0',
  PRIMARY KEY (`usuTipoId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `usuario_tipo` */

LOCK TABLES `usuario_tipo` WRITE;

insert  into `usuario_tipo`(`usuTipoId`,`usuTipoDesc`,`usuTipoHabil`) values ('CLI','Cliente/Proveedor',0),('INT','Interno',0);

UNLOCK TABLES;

/* Trigger structure for table `tkt` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `audit_tkt_insert` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `audit_tkt_insert` AFTER INSERT ON `tkt` FOR EACH ROW BEGIN
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
END */$$


DELIMITER ;

/* Trigger structure for table `tkt` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `audit_tkt_update` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `audit_tkt_update` AFTER UPDATE ON `tkt` FOR EACH ROW BEGIN
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
END */$$


DELIMITER ;

/* Trigger structure for table `tkt` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `audit_tkt_delete` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `audit_tkt_delete` AFTER DELETE ON `tkt` FOR EACH ROW BEGIN
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
     ',"contenido":"', REPLACE(COALESCE(LEFT(OLD.Contenido, 200), ''), '"', '\"'), '"',
     '}'
   ),
   NOW(),
   CONCAT('Ticket #', OLD.Id_Tkt, ' eliminado'));
END */$$


DELIMITER ;

/* Trigger structure for table `tkt_comentario` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `audit_comentario_insert` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `audit_comentario_insert` AFTER INSERT ON `tkt_comentario` FOR EACH ROW BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_nuevos, fecha, descripcion) 
  VALUES 
  ('tkt_comentario', NEW.id_comentario, 'INSERT', NEW.id_usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.id_usuario),
   NEW.comentario,
   NOW(),
   CONCAT('Comentario ', NEW.id_comentario, ' añadido al ticket ', NEW.id_tkt));
END */$$


DELIMITER ;

/* Trigger structure for table `tkt_comentario` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `audit_comentario_update` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `audit_comentario_update` AFTER UPDATE ON `tkt_comentario` FOR EACH ROW BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion) 
  VALUES 
  ('tkt_comentario', NEW.id_comentario, 'UPDATE', NEW.id_usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = NEW.id_usuario),
   OLD.comentario,
   NEW.comentario,
   NOW(),
   CONCAT('Comentario ', NEW.id_comentario, ' actualizado en ticket ', NEW.id_tkt));
END */$$


DELIMITER ;

/* Trigger structure for table `tkt_comentario` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `audit_comentario_delete` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `audit_comentario_delete` AFTER DELETE ON `tkt_comentario` FOR EACH ROW BEGIN
  INSERT INTO audit_log 
  (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, fecha, descripcion) 
  VALUES 
  ('tkt_comentario', OLD.id_comentario, 'DELETE', OLD.id_usuario,
   (SELECT nombre FROM usuario WHERE idUsuario = OLD.id_usuario),
   OLD.comentario,
   NOW(),
   CONCAT('Comentario ', OLD.id_comentario, ' eliminado del ticket ', OLD.id_tkt));
END */$$


DELIMITER ;

/* Trigger structure for table `tkt_transicion` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `audit_transicion_estado` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `audit_transicion_estado` AFTER INSERT ON `tkt_transicion` FOR EACH ROW BEGIN
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
END */$$


DELIMITER ;

/* Procedure structure for procedure `sp_actualizar_tkt` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_actualizar_tkt` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_actualizar_tkt`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_agregar_tkt` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_agregar_tkt` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_agregar_tkt`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_agregar_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_agregar_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_agregar_usuario`(
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
    
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_alertas_no_leidas` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_alertas_no_leidas` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_alertas_no_leidas`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_asignar_ticket` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_asignar_ticket` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_asignar_ticket`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_crear_alerta_mencion` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_crear_alerta_mencion` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_alerta_mencion`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_dashboard_tickets` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_dashboard_tickets` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_dashboard_tickets`(
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_departamento_actualizar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_departamento_actualizar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_departamento_actualizar`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_departamento_crear` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_departamento_crear` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_departamento_crear`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_estado` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_estado` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_estado`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_motivo` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_motivo` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_motivo`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_prioridad` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_prioridad` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_prioridad`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_editar_usuario`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_eliminar_ticket` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_eliminar_ticket` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_ticket`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_eliminar_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_eliminar_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_eliminar_usuario`(
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
    
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_estado_crear` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_estado_crear` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estado_crear`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_global_search` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_global_search` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_global_search`(
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
        CONCAT('#', t.Id_Tkt, ' â€“ ', LEFT(t.Contenido, 80)) AS titulo,
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_tkts` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_tkts` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_tkts`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_usuario`(w_nombre VARCHAR(40), w_email VARCHAR(50), w_tipoID VARCHAR(3), w_habilitado INT(1))
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
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_UsuEmpSucPerSis` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_UsuEmpSucPerSis` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_UsuEmpSucPerSis`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_marcar_alerta_leida` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_marcar_alerta_leida` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_marcar_alerta_leida`(
    IN p_id_alerta  BIGINT,
    IN p_id_usuario BIGINT
)
BEGIN
    UPDATE notificacion_alerta
    SET leida = 1
    WHERE id_alerta = p_id_alerta AND id_usuario = p_id_usuario;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_motivo_crear` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_motivo_crear` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_motivo_crear`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_detalle_ticket` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_detalle_ticket` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_detalle_ticket`(IN w_Id_Tkt BIGINT)
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_resumen_notificaciones` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_resumen_notificaciones` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_resumen_notificaciones`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_usuarios` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_usuarios` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_usuarios`()
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_permiso_guardar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_permiso_guardar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_permiso_guardar`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_permiso_listar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_permiso_listar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_permiso_listar`()
BEGIN
    SELECT idPermiso, codigo, descripcion FROM permiso ORDER BY codigo;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_prioridad_crear` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_prioridad_crear` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_prioridad_crear`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_rol_eliminar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_rol_eliminar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_eliminar`(IN p_idRol INT)
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_rol_guardar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_rol_guardar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_guardar`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_rol_listar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_rol_listar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_listar`()
BEGIN
    SELECT r.idRol, r.nombre, COUNT(rp.idPermiso) AS total_permisos
    FROM rol r
    LEFT JOIN rol_permiso rp ON r.idRol = rp.idRol
    GROUP BY r.idRol, r.nombre
    ORDER BY r.idRol;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_rol_permiso_gestionar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_rol_permiso_gestionar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_permiso_gestionar`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_ticket_stats` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_ticket_stats` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ticket_stats`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_cola_trabajo` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_cola_trabajo` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_cola_trabajo`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_comentar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_comentar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_comentar`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_comentarios_por_ticket` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_comentarios_por_ticket` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_comentarios_por_ticket`(IN p_id_tkt BIGINT)
BEGIN
  SELECT c.id_comentario, c.id_tkt, c.id_usuario, c.comentario, c.fecha,
         u.nombre, u.email
  FROM tkt_comentario c
  LEFT JOIN usuario u ON u.idUsuario = c.id_usuario
  WHERE c.id_tkt = p_id_tkt
  ORDER BY c.fecha ASC;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_gestionar_suscripcion` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_gestionar_suscripcion` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_gestionar_suscripcion`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_historial` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_historial` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_historial`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_mis_tickets` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_mis_tickets` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_mis_tickets`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_permisos_por_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_permisos_por_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_permisos_por_usuario`(IN w_idUsuario BIGINT)
BEGIN
  SELECT p.codigo
    FROM usuario_rol ur
    JOIN rol_permiso rp ON rp.idRol = ur.idRol
    JOIN permiso p ON p.idPermiso = rp.idPermiso
   WHERE ur.idUsuario = w_idUsuario;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_todos` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_todos` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_todos`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_transicionar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_transicionar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_transicionar`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_usuario_reset_password` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_usuario_reset_password` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_reset_password`(
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
END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
