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
CREATE DATABASE /*!32312 IF NOT EXISTS*/`cdk_tkt_dev` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `cdk_tkt_dev`;

/*Table structure for table `accion` */

DROP TABLE IF EXISTS `accion`;

CREATE TABLE `accion` (
  `idAccion` bigint(20) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(1) NOT NULL,
  `nombre` varchar(30) DEFAULT NULL,
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idAccion`,`codigo`),
  KEY `KEY_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

/*Data for the table `accion` */

LOCK TABLES `accion` WRITE;

insert  into `accion`(`idAccion`,`codigo`,`nombre`,`habilitado`) values (1,'A','Alta',0),(2,'B','Baja',0),(3,'M','Modificar',0),(4,'V','Ver',0);

UNLOCK TABLES;

/*Table structure for table `departamento` */

DROP TABLE IF EXISTS `departamento`;

CREATE TABLE `departamento` (
  `Id_Departamento` int(20) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`Id_Departamento`),
  UNIQUE KEY `uq_depto_nombre` (`Nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=latin1;

/*Data for the table `departamento` */

LOCK TABLES `departamento` WRITE;

insert  into `departamento`(`Id_Departamento`,`Nombre`) values (59,'Administración'),(13,'Aplicaciones Corporativas / ERP'),(47,'Archivo y Entrega de Estudios'),(17,'Atención al Cliente'),(34,'Atención al Paciente'),(12,'Bases de Datos / DBA'),(14,'BI / Analítica'),(33,'Caja / Facturación / Autorizaciones'),(21,'Calidad'),(48,'Calidad Clínica / Protocolos'),(61,'Calidad y Auditoría'),(66,'Comercial'),(22,'Compras / Abastecimiento'),(57,'Compras / Suministros (Insumos Radiológicos)'),(49,'Consultorios'),(25,'Créditos y Cobranzas'),(40,'Densitometría Ósea (DEXA)'),(1,'Departamento A'),(2,'Departamento B'),(3,'Departamento C'),(10,'Desarrollo de Software'),(29,'Dirección / Gerencia'),(64,'Dirección General / Gerencia'),(63,'Dirección Médica'),(38,'Ecografía'),(23,'Finanzas / Contabilidad'),(15,'Gestión de Servicios (ITSM)'),(6,'Infraestructura'),(53,'Integraciones HIS/EMR (HL7/DICOM)'),(45,'Jefatura de Diagnóstico por Imágenes'),(50,'Kinesiología y Rehabilitación'),(28,'Legal'),(60,'Legales y Compliance'),(19,'Logística'),(39,'Mamografía'),(56,'Mantenimiento Biomédico'),(55,'Mantenimiento Edilicio'),(27,'Marketing / Comunicación'),(62,'Marketing / Comunicación Institucional'),(41,'Medicina Nuclear'),(43,'Médicos Informantes (Radiología)'),(4,'Mesa de Ayuda / Soporte N1'),(18,'Operaciones'),(52,'PACS / RIS'),(20,'Producción'),(46,'Protección Radiológica / Física Médica'),(11,'QA / Testing'),(35,'Radiología Convencional (Rayos X)'),(42,'Radiología Intervencionista / Hemodinamia'),(31,'Recepción y Admisión'),(26,'Recursos Humanos'),(7,'Redes'),(37,'Resonancia Magnética (RM)'),(68,'RRHH'),(54,'Seguridad de la Información'),(9,'Seguridad Informática'),(58,'Servicios Generales / Limpieza'),(65,'Sistemas'),(51,'Sistemas / Soluciones IT'),(5,'Soporte N2 / Plataformas'),(30,'Sucursales / Oficinas'),(44,'Técnicos Radiólogos'),(8,'Telecomunicaciones'),(24,'Tesorería'),(36,'Tomografía Computada (TC)'),(32,'Turnos / Call Center'),(16,'Ventas / Comercial');

UNLOCK TABLES;

/*Table structure for table `empresa` */

DROP TABLE IF EXISTS `empresa`;

CREATE TABLE `empresa` (
  `idEmpresa` bigint(20) NOT NULL AUTO_INCREMENT,
  `cuit` varchar(11) DEFAULT NULL COMMENT 'cuit de la empresa sin guion',
  `nombre` varchar(50) DEFAULT NULL COMMENT 'descripcion o razon social',
  `codigo` varchar(3) DEFAULT NULL COMMENT 'codigo de la empresa',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idEmpresa`),
  KEY `KEY_cuit` (`cuit`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

/*Data for the table `empresa` */

LOCK TABLES `empresa` WRITE;

insert  into `empresa`(`idEmpresa`,`cuit`,`nombre`,`codigo`,`habilitado`) values (1,'30708839309','CEDIAC BERAZATEGUI S.R.L.','CDK',0),(2,'30714800392','SUR SALUDPYME S.R.L.','SUR',0);

UNLOCK TABLES;

/*Table structure for table `estado` */

DROP TABLE IF EXISTS `estado`;

CREATE TABLE `estado` (
  `Id_Estado` int(11) NOT NULL AUTO_INCREMENT,
  `TipoEstado` varchar(100) NOT NULL,
  PRIMARY KEY (`Id_Estado`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

/*Data for the table `estado` */

LOCK TABLES `estado` WRITE;

insert  into `estado`(`Id_Estado`,`TipoEstado`) values (1,'Abierto'),(2,'En Proceso'),(3,'Cerrado'),(4,'En Espera'),(5,'Pendiente Aprobación'),(6,'Resuelto'),(7,'Reabierto');

UNLOCK TABLES;

/*Table structure for table `grupo` */

DROP TABLE IF EXISTS `grupo`;

CREATE TABLE `grupo` (
  `Id_Grupo` int(11) NOT NULL AUTO_INCREMENT,
  `Tipo_Grupo` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Id_Grupo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

/*Data for the table `grupo` */

LOCK TABLES `grupo` WRITE;

insert  into `grupo`(`Id_Grupo`,`Tipo_Grupo`) values (1,'admin'),(2,'usuario');

UNLOCK TABLES;

/*Table structure for table `motivo` */

DROP TABLE IF EXISTS `motivo`;

CREATE TABLE `motivo` (
  `Id_Motivo` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Categoria` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`Id_Motivo`),
  UNIQUE KEY `uq_motivo_nombre_cat` (`Nombre`,`Categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=latin1;

/*Data for the table `motivo` */

LOCK TABLES `motivo` WRITE;

insert  into `motivo`(`Id_Motivo`,`Nombre`,`Categoria`) values (5,'Autorización de Obra Social',NULL),(36,'Calibración / Control de Calidad',NULL),(45,'Consulta','Información'),(39,'Consultorios - Agenda / Atención',NULL),(34,'CR/DR - Digitalizador - Falla',NULL),(18,'DEXA - Orden / Preparación',NULL),(16,'Ecografía - Agenda / Preparación',NULL),(31,'Ecógrafo - Falla',NULL),(8,'Entrega de Estudios / Duplicado',NULL),(28,'Equipamiento RX - Falla',NULL),(6,'Facturación / Cobranza',NULL),(37,'Gestión de Incidentes (Seguridad Info)',NULL),(26,'HIS/EMR - Interfaz HL7',NULL),(33,'Impresora Dry - Falla / Insumos',NULL),(43,'Incidente','Soporte'),(20,'Informe - Aclaración / Addendum',NULL),(21,'Informe - Corrección de Datos',NULL),(19,'Informe - Retraso',NULL),(40,'Infraestructura - Climatización',NULL),(41,'Infraestructura - Electricidad',NULL),(38,'Kinesiología - Agenda / Práctica',NULL),(17,'Mamografía - Orden / Preparación',NULL),(32,'Mamógrafo - Falla',NULL),(1,'Motivo A',NULL),(2,'Motivo B',NULL),(3,'Motivo C',NULL),(23,'PACS - Envío/Recepción DICOM',NULL),(22,'PACS - Visualización de Imágenes',NULL),(27,'Portal Paciente / Médicos - Acceso',NULL),(35,'Protección Radiológica',NULL),(10,'Rayos X - Orden / Preparación',NULL),(11,'Rayos X - Resultado / Entrega',NULL),(7,'Recepción / Admisión',NULL),(30,'Resonador - Falla',NULL),(15,'Resonancia - Implantes / Contraindicaciones',NULL),(14,'Resonancia - Orden / Preparación',NULL),(24,'RIS - Agenda / Admisión',NULL),(25,'RIS - Falla de Integración',NULL),(9,'Satisfacción del Paciente / Queja',NULL),(42,'Servicios - Limpieza / Residuos Patológicos',NULL),(44,'Solicitud','Servicio'),(13,'Tomografía - Contraste / Reacción',NULL),(12,'Tomografía - Orden / Preparación',NULL),(29,'Tomógrafo - Falla',NULL),(4,'Turno / Reprogramación',NULL);

UNLOCK TABLES;

/*Table structure for table `notificaciones` */

DROP TABLE IF EXISTS `notificaciones`;

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

/*Data for the table `notificaciones` */

LOCK TABLES `notificaciones` WRITE;

UNLOCK TABLES;

/*Table structure for table `perfil` */

DROP TABLE IF EXISTS `perfil`;

CREATE TABLE `perfil` (
  `idPerfil` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id de perfil',
  `nombre` varchar(30) NOT NULL COMMENT 'descripcion o nombre del perfil',
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idPerfil`),
  KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

/*Data for the table `perfil` */

LOCK TABLES `perfil` WRITE;

insert  into `perfil`(`idPerfil`,`nombre`,`habilitado`) values (1,'Operador',0),(2,'Auditor Médico',0),(3,'Supervisor',0),(4,'Administrador',0),(5,'Prestador',0),(6,'Operador internación',0),(7,'Auditor internación',0),(8,'Médico informante',0),(9,'Técnica/o',0),(10,'Secretaria/o',0),(11,'Técnica/o Jefe',0),(12,'Consulta',0);

UNLOCK TABLES;

/*Table structure for table `perfil_accion_sistema` */

DROP TABLE IF EXISTS `perfil_accion_sistema`;

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

/*Data for the table `perfil_accion_sistema` */

LOCK TABLES `perfil_accion_sistema` WRITE;

insert  into `perfil_accion_sistema`(`ID`,`idPerfil`,`codigoAccion`,`idSistema`,`habilitado`) values (1,1,'A,B,M,V','CDK_CNS',0),(2,3,'A,B,M,V','CDK_CNS',0),(3,4,'A,B,M,V','CDK_CNS',0),(4,1,'A,B,M,V','CDK_AUT',0),(5,2,'A,B,M,V','CDK_AUT',0),(6,3,'A,B,M,V','CDK_AUT',0),(7,4,'A,B,M,V','CDK_AUT',0),(8,5,'A,B,M,V','CDK_AUT',0),(9,6,'A,B,M,V','CDK_AUT',0),(10,7,'A,B,M,V','CDK_AUT',0),(11,1,'A,B,M,V','CDK_PAD',0),(12,3,'A,B,M,V','CDK_PAD',0),(13,4,'A,B,M,V','CDK_PAD',0),(14,1,'A,B,M,V','CDK_EST',0),(15,4,'A,B,M,V','CDK_EST',0),(16,1,'A,B,M,V','CDK_RYS',0),(17,4,'A,B,M,V','CDK_RYS',0),(18,1,'A,B,M,V','CDK_STK',0),(19,3,'A,B,M,V','CDK_STK',0),(20,4,'A,B,M,V','CDK_STK',0),(21,8,'A,B,M,V','CDK_EST',0),(22,1,'A,B,M,V','CDK_FIS',0),(23,3,'A,B,M,V','CDK_FIS',0),(24,4,'A,B,M,V','CDK_FIS',0),(25,9,'A,B,M,V','CDK_EST',0),(26,10,'A,B,M,V','CDK_EST',0),(27,11,'A,B,M,V','CDK_EST',0);

UNLOCK TABLES;

/*Table structure for table `permiso` */

DROP TABLE IF EXISTS `permiso`;

CREATE TABLE `permiso` (
  `idPermiso` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(64) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`idPermiso`),
  UNIQUE KEY `uq_permiso_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

/*Data for the table `permiso` */

LOCK TABLES `permiso` WRITE;

insert  into `permiso`(`idPermiso`,`codigo`,`descripcion`) values (1,'TKT_CREATE','Crear tickets'),(2,'TKT_LIST_ALL','Listar todos'),(3,'TKT_LIST_ASSIGNED','Listar asignados'),(4,'TKT_EDIT_ANY','Editar cualquiera'),(5,'TKT_EDIT_ASSIGNED','Editar asignados'),(6,'TKT_DELETE','Eliminar'),(7,'TKT_APPROVE','Aprobar'),(8,'TKT_COMMENT','Comentar'),(9,'TKT_START','Iniciar'),(10,'TKT_RESOLVE','Resolver'),(11,'TKT_EXPORT','Exportar'),(12,'TKT_WAIT','Poner en espera'),(13,'TKT_REQUEST_APPROVAL','Solicitar aprobación'),(14,'TKT_CLOSE','Cerrar'),(15,'TKT_REOPEN','Reabrir'),(16,'TKT_RBAC_ADMIN','Admin RBAC');

UNLOCK TABLES;

/*Table structure for table `prioridad` */

DROP TABLE IF EXISTS `prioridad`;

CREATE TABLE `prioridad` (
  `Id_Prioridad` int(11) NOT NULL AUTO_INCREMENT,
  `NombrePrioridad` varchar(100) NOT NULL,
  PRIMARY KEY (`Id_Prioridad`),
  UNIQUE KEY `uq_prioridad_nombre` (`NombrePrioridad`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

/*Data for the table `prioridad` */

LOCK TABLES `prioridad` WRITE;

insert  into `prioridad`(`Id_Prioridad`,`NombrePrioridad`) values (1,'Alta'),(3,'Baja'),(7,'Crítica'),(2,'Media');

UNLOCK TABLES;

/*Table structure for table `rol` */

DROP TABLE IF EXISTS `rol`;

CREATE TABLE `rol` (
  `idRol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(64) NOT NULL,
  PRIMARY KEY (`idRol`),
  UNIQUE KEY `uq_rol_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

/*Data for the table `rol` */

LOCK TABLES `rol` WRITE;

insert  into `rol`(`idRol`,`nombre`) values (10,'Administrador'),(2,'Agente'),(11,'Aprobador'),(12,'Consulta'),(3,'Operador'),(1,'Supervisor');

UNLOCK TABLES;

/*Table structure for table `rol_permiso` */

DROP TABLE IF EXISTS `rol_permiso`;

CREATE TABLE `rol_permiso` (
  `idRol` int(11) NOT NULL,
  `idPermiso` int(11) NOT NULL,
  PRIMARY KEY (`idRol`,`idPermiso`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `rol_permiso` */

LOCK TABLES `rol_permiso` WRITE;

insert  into `rol_permiso`(`idRol`,`idPermiso`) values (1,1),(1,2),(1,4),(1,7),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(2,3),(2,5),(2,8),(2,9),(2,10),(2,13),(2,15),(3,1),(3,3),(3,5),(3,8),(3,9),(3,10),(10,1),(10,2),(10,4),(10,5),(10,6),(10,7),(10,10),(10,11),(10,12),(10,13),(10,14),(10,15),(10,16),(11,1),(12,1);

UNLOCK TABLES;

/*Table structure for table `sistema` */

DROP TABLE IF EXISTS `sistema`;

CREATE TABLE `sistema` (
  `idSistema` varchar(8) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `habilitado` int(1) DEFAULT '0' COMMENT '0 si, 1 no',
  PRIMARY KEY (`idSistema`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `sistema` */

LOCK TABLES `sistema` WRITE;

insert  into `sistema`(`idSistema`,`nombre`,`habilitado`) values ('CDK_AUT','AUTORIZACIONES',0),('CDK_CNS','CONSUMOS',0),('CDK_CNV','CONVENIOS',0),('CDK_EST','IMÁGENES',0),('CDK_FIS','FISIO',0),('CDK_HUB','HUB',0),('CDK_NYP','NORMAS Y PROCEDIMIENTOS',0),('CDK_PAD','PADRÓN',0),('CDK_RYS','RECLAMOS/SUGERENCIAS',0),('CDK_STK','STOCK',0),('CDK_TUR','TURNOS',0);

UNLOCK TABLES;

/*Table structure for table `sucursal` */

DROP TABLE IF EXISTS `sucursal`;

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
  `Id_Usuario` int(20) DEFAULT NULL,
  `Id_Usuario_Asignado` int(20) DEFAULT NULL,
  `Id_Empresa` int(20) DEFAULT NULL,
  `Id_Perfil` int(20) DEFAULT NULL,
  `Id_Motivo` int(20) DEFAULT NULL,
  `Id_Sucursal` int(20) DEFAULT NULL,
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
  CONSTRAINT `fk_tkt_depto` FOREIGN KEY (`Id_Departamento`) REFERENCES `departamento` (`Id_Departamento`),
  CONSTRAINT `fk_tkt_estado` FOREIGN KEY (`Id_Estado`) REFERENCES `estado` (`Id_Estado`),
  CONSTRAINT `fk_tkt_motivo` FOREIGN KEY (`Id_Motivo`) REFERENCES `motivo` (`Id_Motivo`),
  CONSTRAINT `fk_tkt_prioridad` FOREIGN KEY (`Id_Prioridad`) REFERENCES `prioridad` (`Id_Prioridad`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

/*Data for the table `tkt` */

LOCK TABLES `tkt` WRITE;

insert  into `tkt`(`Id_Tkt`,`Id_Estado`,`Date_Creado`,`Date_Cierre`,`Date_Asignado`,`Date_Cambio_Estado`,`Id_Usuario`,`Id_Usuario_Asignado`,`Id_Empresa`,`Id_Perfil`,`Id_Motivo`,`Id_Sucursal`,`Habilitado`,`Id_Prioridad`,`Contenido`,`Id_Departamento`) values (1,7,'2025-11-18 14:19:44',NULL,'2025-11-18 14:25:47','2025-12-04 11:08:26',1,2,0,4,6,2,0,1,'esto es una prueba',21),(2,1,'2025-11-21 11:35:49',NULL,'2025-12-04 13:13:44',NULL,1,1,0,4,39,10,1,7,'Esto es una prueba Beta',59),(3,3,'2025-11-21 11:59:22',NULL,'2025-11-21 11:59:32','2025-12-09 13:09:42',1,3,0,4,6,1,1,2,'Prueba de seguimiento',66),(4,2,'2025-11-21 12:33:30',NULL,'2025-12-04 13:04:38','2025-11-21 13:52:28',1,2,0,4,5,1,1,3,'aaaaaaaaaaaaaaaaaaaa sssssssss',59),(5,2,'2025-11-21 14:36:17',NULL,'2025-12-09 11:38:55','2025-12-04 11:18:03',1,2,0,4,8,2,1,2,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',66),(6,3,'2025-12-04 10:29:13',NULL,'2025-12-09 12:01:53','2025-12-09 13:37:17',1,2,0,4,18,2,0,2,'Esto es un test',13),(8,1,'2025-12-23 14:37:07',NULL,NULL,NULL,0,2,NULL,NULL,6,NULL,1,1,'test swager',1),(9,1,'2025-12-23 14:47:36',NULL,NULL,NULL,0,NULL,1,0,3,0,1,1,'test swager 2',1),(10,1,'2026-01-23 13:50:49',NULL,NULL,NULL,1,NULL,1,0,NULL,0,1,1,'Ticket de prueba QA - 2026-01-23T13:50:49.120178',1);

UNLOCK TABLES;

/*Table structure for table `tkt_aprobacion` */

DROP TABLE IF EXISTS `tkt_aprobacion`;

CREATE TABLE `tkt_aprobacion` (
  `id_aprob` bigint(20) NOT NULL AUTO_INCREMENT,
  `id_tkt` bigint(20) NOT NULL,
  `solicitante_id` int(11) NOT NULL,
  `aprobador_id` int(11) NOT NULL,
  `estado` enum('pendiente','aprobado','rechazado') NOT NULL DEFAULT 'pendiente',
  `comentario` varchar(1000) DEFAULT NULL,
  `fecha_solicitud` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_respuesta` datetime DEFAULT NULL,
  PRIMARY KEY (`id_aprob`),
  KEY `idx_pendientes` (`aprobador_id`,`estado`),
  KEY `idx_aprobacion_tkt_estado` (`id_tkt`,`estado`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

/*Data for the table `tkt_aprobacion` */

LOCK TABLES `tkt_aprobacion` WRITE;

insert  into `tkt_aprobacion`(`id_aprob`,`id_tkt`,`solicitante_id`,`aprobador_id`,`estado`,`comentario`,`fecha_solicitud`,`fecha_respuesta`) values (1,1,1,1,'pendiente','esto es una prueba de solicitud de aprobacion','2025-11-18 14:38:01',NULL),(2,1,1,1,'pendiente','Prueba B de solicitud','2025-11-21 10:59:59',NULL);

UNLOCK TABLES;

/*Table structure for table `tkt_comentario` */

DROP TABLE IF EXISTS `tkt_comentario`;

CREATE TABLE `tkt_comentario` (
  `id_comentario` bigint(20) NOT NULL AUTO_INCREMENT,
  `id_tkt` bigint(20) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `comentario` text NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_comentario`),
  KEY `idx_tkt_fecha` (`id_tkt`,`fecha`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=latin1;

/*Data for the table `tkt_comentario` */

LOCK TABLES `tkt_comentario` WRITE;

insert  into `tkt_comentario`(`id_comentario`,`id_tkt`,`id_usuario`,`comentario`,`fecha`) values (1,1,1,'esto es una prueba','2025-11-18 14:36:29'),(2,3,3,'prueba 1234','2025-11-21 12:01:26'),(3,3,3,'hola','2025-11-21 12:20:32'),(4,3,3,'tests','2025-11-21 12:21:53'),(5,4,3,'aaa','2025-11-21 13:33:13'),(6,4,1,'[Transición] aaa','2025-11-21 13:52:28'),(7,4,1,'aaa','2025-11-21 14:04:46'),(8,4,1,'test test','2025-11-21 14:35:13'),(9,1,1,'test','2025-12-04 10:34:10'),(10,2,1,'[Asignación] aaaa','2025-12-04 12:55:39'),(11,4,1,'[Asignación] aaaaa','2025-12-04 13:04:38'),(12,6,1,'test','2025-12-04 13:33:10'),(13,6,1,'aaaaaaa','2025-12-04 13:33:20'),(14,6,1,'aaaaaa','2025-12-04 13:33:44'),(15,6,1,'test','2025-12-04 13:39:51'),(16,6,1,'aaa','2025-12-09 11:08:46'),(17,5,1,'[Asignación] aaa','2025-12-09 11:38:55'),(18,6,1,'[Asignación] asd','2025-12-09 11:54:30'),(19,6,1,'[Asignación] aa','2025-12-09 12:01:53');

UNLOCK TABLES;

/*Table structure for table `tkt_permiso` */

DROP TABLE IF EXISTS `tkt_permiso`;

CREATE TABLE `tkt_permiso` (
  `id_permiso` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `habilitado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_permiso`),
  UNIQUE KEY `codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;

/*Data for the table `tkt_permiso` */

LOCK TABLES `tkt_permiso` WRITE;

insert  into `tkt_permiso`(`id_permiso`,`codigo`,`descripcion`,`habilitado`) values (1,'TKT_LIST_ALL','Ver todos los tickets',1),(2,'TKT_LIST_ASSIGNED','Ver mis asignados',1),(3,'TKT_VIEW_DETAIL','Ver detalle',1),(4,'TKT_CREATE','Crear ticket',1),(5,'TKT_EDIT_ASSIGNED','Editar si soy asignado',1),(6,'TKT_EDIT_ANY','Editar cualquiera',1),(7,'TKT_ASSIGN','Asignar tickets',1),(8,'TKT_CLOSE','Cerrar tickets',1),(9,'TKT_DELETE','Eliminar tickets',1),(10,'TKT_EXPORT','Exportar CSV',1),(11,'TKT_COMMENT','Comentar',1),(34,'TKT_RBAC_ADMIN','Administrar roles y permisos',1),(35,'TKT_START','Iniciar trabajo / mover a En Proceso',1),(36,'TKT_WAIT','Poner / sacar de Espera',1),(37,'TKT_REQUEST_APPROVAL','Solicitar aprobación',1),(38,'TKT_APPROVE','Aprobar / Rechazar',1),(39,'TKT_RESOLVE','Marcar como Resuelto',1),(40,'TKT_REOPEN','Reabrir ticket',1);

UNLOCK TABLES;

/*Table structure for table `tkt_rol` */

DROP TABLE IF EXISTS `tkt_rol`;

CREATE TABLE `tkt_rol` (
  `id_rol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `habilitado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

/*Data for the table `tkt_rol` */

LOCK TABLES `tkt_rol` WRITE;

insert  into `tkt_rol`(`id_rol`,`nombre`,`descripcion`,`habilitado`) values (1,'Administrador','Acceso total',1),(2,'Supervisor','Supervisa y edita, sin eliminar',1),(3,'Operador','Opera tickets asignados',1),(4,'Consulta','Solo lectura y exportar',1),(6,'Aprobador','Puede aprobar/rechazar tickets en pendiente de aprobación',1);

UNLOCK TABLES;

/*Table structure for table `tkt_rol_permiso` */

DROP TABLE IF EXISTS `tkt_rol_permiso`;

CREATE TABLE `tkt_rol_permiso` (
  `id_rol` int(11) NOT NULL,
  `id_permiso` int(11) NOT NULL,
  PRIMARY KEY (`id_rol`,`id_permiso`),
  KEY `idx_trp_permiso` (`id_permiso`),
  CONSTRAINT `fk_trp_perm` FOREIGN KEY (`id_permiso`) REFERENCES `tkt_permiso` (`id_permiso`),
  CONSTRAINT `fk_trp_rol` FOREIGN KEY (`id_rol`) REFERENCES `tkt_rol` (`id_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `tkt_rol_permiso` */

LOCK TABLES `tkt_rol_permiso` WRITE;

insert  into `tkt_rol_permiso`(`id_rol`,`id_permiso`) values (1,1),(2,1),(4,1),(6,1),(1,2),(3,2),(1,3),(2,3),(3,3),(4,3),(1,4),(2,4),(3,4),(1,5),(3,5),(1,6),(2,6),(1,7),(2,7),(1,8),(2,8),(3,8),(1,9),(1,10),(2,10),(4,10),(1,11),(2,11),(3,11),(1,34),(1,35),(2,35),(3,35),(1,36),(2,36),(3,36),(1,37),(2,37),(3,37),(1,38),(2,38),(6,38),(1,39),(2,39),(3,39),(1,40),(2,40);

UNLOCK TABLES;

/*Table structure for table `tkt_search` */

DROP TABLE IF EXISTS `tkt_search`;

CREATE TABLE `tkt_search` (
  `Id_Tkt` bigint(20) NOT NULL,
  `Term` varchar(60) NOT NULL,
  PRIMARY KEY (`Id_Tkt`,`Term`),
  KEY `idx_term` (`Term`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `tkt_search` */

LOCK TABLES `tkt_search` WRITE;

insert  into `tkt_search`(`Id_Tkt`,`Term`) values (4,'aaaaaaaaaaaaaaaaaaaa'),(2,'beta'),(2,'esto'),(6,'esto'),(2,'prueba'),(3,'prueba'),(3,'seguimiento'),(4,'sssssssss'),(6,'test');

UNLOCK TABLES;

/*Table structure for table `tkt_suscriptor` */

DROP TABLE IF EXISTS `tkt_suscriptor`;

CREATE TABLE `tkt_suscriptor` (
  `id_tkt` bigint(20) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  PRIMARY KEY (`id_tkt`,`id_usuario`),
  KEY `idx_ts_usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `tkt_suscriptor` */

LOCK TABLES `tkt_suscriptor` WRITE;

insert  into `tkt_suscriptor`(`id_tkt`,`id_usuario`) values (3,1),(5,1),(3,3),(4,3);

UNLOCK TABLES;

/*Table structure for table `tkt_transicion` */

DROP TABLE IF EXISTS `tkt_transicion`;

CREATE TABLE `tkt_transicion` (
  `id_transicion` bigint(20) NOT NULL AUTO_INCREMENT,
  `id_tkt` bigint(20) NOT NULL,
  `estado_from` int(11) DEFAULT NULL,
  `estado_to` int(11) NOT NULL,
  `id_usuario_actor` int(11) NOT NULL,
  `id_usuario_asignado_old` bigint(20) DEFAULT NULL,
  `id_usuario_asignado_new` bigint(20) DEFAULT NULL,
  `comentario` varchar(1000) DEFAULT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `meta_json` longtext,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_transicion`),
  KEY `idx_tkt_fecha` (`id_tkt`,`fecha`),
  KEY `idx_estado_to` (`estado_to`),
  KEY `idx_transicion_tkt_fecha` (`id_tkt`,`fecha`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;

/*Data for the table `tkt_transicion` */

LOCK TABLES `tkt_transicion` WRITE;

insert  into `tkt_transicion`(`id_transicion`,`id_tkt`,`estado_from`,`estado_to`,`id_usuario_actor`,`id_usuario_asignado_old`,`id_usuario_asignado_new`,`comentario`,`motivo`,`meta_json`,`fecha`) values (1,1,1,2,1,NULL,NULL,'Esto es una prueba',NULL,NULL,'2025-11-18 14:37:09'),(2,1,2,5,1,NULL,NULL,'esto es una prueba de solicitud de aprobacion',NULL,NULL,'2025-11-18 14:38:01'),(3,1,5,6,1,NULL,NULL,'esto es una prueba de aprobacion de una solicitud de aprobacion',NULL,NULL,'2025-11-18 14:38:42'),(4,1,6,3,1,NULL,NULL,'esto es un test de cerrar',NULL,NULL,'2025-11-21 10:58:34'),(5,1,3,7,1,NULL,NULL,'esto es un test de reabrir','prueba',NULL,'2025-11-21 10:59:00'),(6,1,7,2,1,NULL,NULL,'prueba A',NULL,NULL,'2025-11-21 10:59:27'),(7,1,2,5,1,NULL,NULL,'Prueba B de solicitud',NULL,NULL,'2025-11-21 10:59:59'),(8,1,5,6,1,NULL,NULL,'aprobado prueba',NULL,NULL,'2025-11-21 11:00:21'),(9,1,6,3,1,NULL,NULL,'prueba',NULL,NULL,'2025-11-21 11:45:11'),(10,3,1,2,3,NULL,NULL,'Prueba tomar ticket',NULL,NULL,'2025-11-21 12:00:46'),(11,3,2,6,3,NULL,NULL,'prueba resolucion 567',NULL,NULL,'2025-11-21 12:02:02'),(12,3,6,7,1,NULL,NULL,'aaaaaaa','bbbbbb',NULL,'2025-11-21 12:03:36'),(13,4,1,2,3,NULL,NULL,'aaa',NULL,NULL,'2025-11-21 13:33:20'),(14,4,2,6,3,NULL,NULL,'resuelto',NULL,NULL,'2025-11-21 13:33:48'),(15,4,6,7,1,NULL,NULL,'aaa','aaa',NULL,'2025-11-21 13:34:36'),(16,4,7,2,1,NULL,NULL,'aaa',NULL,NULL,'2025-11-21 13:52:28'),(17,5,1,2,1,NULL,NULL,'a',NULL,NULL,'2025-11-21 14:36:49'),(18,5,2,6,1,NULL,NULL,'test',NULL,NULL,'2025-12-04 10:49:16'),(19,5,6,3,1,NULL,NULL,'aaaaa',NULL,NULL,'2025-12-04 10:57:02'),(20,5,3,7,1,NULL,NULL,'aaaaaaaa',NULL,NULL,'2025-12-04 11:01:01'),(21,1,3,7,1,NULL,NULL,'aaaaa',NULL,NULL,'2025-12-04 11:08:26'),(22,6,1,2,1,NULL,NULL,'aaa',NULL,NULL,'2025-12-04 11:17:00'),(23,5,7,2,2,NULL,NULL,'aaa',NULL,NULL,'2025-12-04 11:18:03'),(24,6,2,4,1,NULL,NULL,'aaaa',NULL,NULL,'2025-12-04 13:05:11'),(25,6,4,2,1,NULL,NULL,'aaa',NULL,NULL,'2025-12-09 12:40:52'),(26,6,2,3,1,NULL,NULL,'aaaa',NULL,NULL,'2025-12-09 12:41:21'),(27,6,3,4,1,NULL,NULL,'test super admin',NULL,NULL,'2025-12-09 12:50:31'),(28,3,7,2,2,NULL,NULL,'aaa',NULL,NULL,'2025-12-09 12:51:02'),(29,3,2,3,1,NULL,NULL,'aaa',NULL,NULL,'2025-12-09 13:09:42'),(30,6,4,3,1,NULL,NULL,'aaaaaaaaaaaaa',NULL,NULL,'2025-12-09 13:37:17');

UNLOCK TABLES;

/*Table structure for table `tkt_transicion_regla` */

DROP TABLE IF EXISTS `tkt_transicion_regla`;

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

/*Data for the table `tkt_transicion_regla` */

LOCK TABLES `tkt_transicion_regla` WRITE;

insert  into `tkt_transicion_regla`(`id`,`estado_from`,`estado_to`,`requiere_propietario`,`permiso_requerido`,`requiere_aprobacion`) values (1,1,2,0,'TKT_ASSIGN',0),(2,2,3,1,'TKT_START',0),(3,3,4,1,'TKT_WAIT',0),(4,4,3,1,'TKT_WAIT',0),(5,3,5,1,'TKT_REQUEST_APPROVAL',1),(6,5,3,0,'TKT_APPROVE',0),(7,5,6,0,'TKT_APPROVE',0),(8,3,6,1,'TKT_RESOLVE',0),(9,6,7,0,'TKT_CLOSE',0),(38,2,4,1,'TKT_WAIT',0),(39,4,2,1,'TKT_WAIT',0),(40,2,5,1,'TKT_REQUEST_APPROVAL',1),(41,5,2,0,'TKT_APPROVE',0),(43,2,6,1,'TKT_RESOLVE',0),(44,6,3,0,'TKT_CLOSE',0),(45,3,7,0,'TKT_REOPEN',0),(46,7,2,0,'TKT_START',0);

UNLOCK TABLES;

/*Table structure for table `tkt_usuario_rol` */

DROP TABLE IF EXISTS `tkt_usuario_rol`;

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

/*Data for the table `tkt_usuario_rol` */

LOCK TABLES `tkt_usuario_rol` WRITE;

insert  into `tkt_usuario_rol`(`idUsuario`,`id_rol`) values (1,1),(2,2),(3,3);

UNLOCK TABLES;

/*Table structure for table `usuario` */

DROP TABLE IF EXISTS `usuario`;

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
  PRIMARY KEY (`idUsuario`),
  KEY `KEY_cliente` (`idCliente`),
  KEY `KEY_kinesiologo` (`idKine`),
  KEY `KEY_tipo` (`tipo`),
  KEY `KEY_nombre` (`nombre`),
  KEY `idx_usuario_nombre` (`nombre`),
  KEY `IX_usuario_idUsuario` (`idUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

/*Data for the table `usuario` */

LOCK TABLES `usuario` WRITE;

insert  into `usuario`(`idUsuario`,`nombre`,`telefono`,`email`,`nota`,`passwordUsuario`,`passwordUsuarioEnc`,`firma`,`firma_aclaracion`,`fechaAlta`,`fechaBaja`,`tipo`,`idCliente`,`idKine`) values (1,'Admin',NULL,NULL,NULL,'changeme','4cb9c8a8048fd02294477fcb1a41191a',NULL,NULL,'2026-01-23',NULL,'INT',0,0),(2,'Supervisor',NULL,NULL,NULL,'changeme','4cb9c8a8048fd02294477fcb1a41191a',NULL,NULL,'2025-11-18',NULL,'INT',0,0),(3,'Operador Uno',NULL,NULL,NULL,'changeme','4cb9c8a8048fd02294477fcb1a41191a',NULL,NULL,'2025-11-18',NULL,'INT',0,0);

UNLOCK TABLES;

/*Table structure for table `usuario_empresa_sucursal_perfil_sistema` */

DROP TABLE IF EXISTS `usuario_empresa_sucursal_perfil_sistema`;

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
) ENGINE=InnoDB AUTO_INCREMENT=1033 DEFAULT CHARSET=utf8;

/*Data for the table `usuario_empresa_sucursal_perfil_sistema` */

LOCK TABLES `usuario_empresa_sucursal_perfil_sistema` WRITE;

insert  into `usuario_empresa_sucursal_perfil_sistema`(`ID`,`idUsuario`,`idEmpresa`,`idSucursal`,`idSistema`,`idPerfil`,`habilitado`) values (1,1,0,0,'CDK_AUT',4,0),(2,2,0,0,'CDK_AUT',4,0),(3,3,0,0,'CDK_AUT',1,1),(4,4,0,0,'CDK_AUT',4,1),(5,5,0,0,'CDK_AUT',4,0),(6,6,0,0,'CDK_AUT',1,0),(7,7,0,0,'CDK_AUT',1,1),(8,8,0,0,'CDK_AUT',6,1),(9,9,0,0,'CDK_AUT',1,0),(10,10,0,0,'CDK_AUT',1,0),(11,11,0,0,'CDK_AUT',5,1),(12,12,0,0,'CDK_AUT',1,0),(13,13,0,0,'CDK_AUT',7,0),(14,14,0,0,'CDK_AUT',4,0),(15,15,0,0,'CDK_AUT',4,0),(16,16,0,0,'CDK_AUT',2,1),(17,17,0,0,'CDK_AUT',6,0),(18,1,0,0,'CDK_PAD',4,0),(19,2,0,0,'CDK_PAD',4,0),(20,3,0,0,'CDK_PAD',1,1),(21,4,0,0,'CDK_PAD',4,1),(22,5,0,0,'CDK_PAD',4,0),(23,6,0,0,'CDK_PAD',1,0),(24,7,0,0,'CDK_PAD',1,1),(25,8,0,0,'CDK_PAD',1,1),(26,9,0,0,'CDK_PAD',4,0),(27,10,0,0,'CDK_PAD',1,0),(28,11,0,0,'CDK_PAD',1,1),(29,12,0,0,'CDK_PAD',1,0),(30,13,0,0,'CDK_PAD',1,0),(31,14,0,0,'CDK_PAD',4,0),(32,15,0,0,'CDK_PAD',4,0),(33,16,0,0,'CDK_PAD',1,1),(34,17,0,0,'CDK_PAD',4,0),(35,1,0,0,'CDK_CNS',4,0),(36,2,0,0,'CDK_CNS',4,0),(37,3,0,0,'CDK_CNS',1,1),(38,4,0,0,'CDK_CNS',3,1),(39,5,0,0,'CDK_CNS',4,0),(40,6,0,0,'CDK_CNS',1,0),(41,7,0,0,'CDK_CNS',1,1),(42,8,0,0,'CDK_CNS',1,1),(43,9,0,0,'CDK_CNS',1,0),(44,10,0,0,'CDK_CNS',1,0),(45,11,0,0,'CDK_CNS',1,1),(46,12,0,0,'CDK_CNS',1,0),(47,13,0,0,'CDK_CNS',1,0),(48,14,0,0,'CDK_CNS',4,0),(49,15,0,0,'CDK_CNS',4,0),(50,16,0,0,'CDK_CNS',1,1),(51,17,0,0,'CDK_CNS',1,0),(52,18,0,0,'CDK_CNS',1,1),(53,1,1,0,'CDK_EST',4,0),(54,2,1,0,'CDK_EST',4,0),(65,13,1,0,'CDK_EST',4,0),(70,18,1,0,'CDK_EST',1,0),(71,18,0,0,'CDK_AUT',1,1),(72,18,0,0,'CDK_PAD',1,1),(73,1,0,0,'CDK_RYS',4,0),(74,2,0,0,'CDK_RYS',4,0),(75,3,0,0,'CDK_RYS',1,1),(76,4,0,0,'CDK_RYS',1,1),(77,5,0,0,'CDK_RYS',4,0),(78,6,0,0,'CDK_RYS',1,0),(79,7,0,0,'CDK_RYS',1,1),(80,8,0,0,'CDK_RYS',1,1),(81,9,0,0,'CDK_RYS',1,0),(82,10,0,0,'CDK_RYS',1,0),(83,11,0,0,'CDK_RYS',1,1),(84,12,0,0,'CDK_RYS',1,0),(85,13,0,0,'CDK_RYS',1,0),(86,14,0,0,'CDK_RYS',4,0),(87,15,0,0,'CDK_RYS',4,0),(88,16,0,0,'CDK_RYS',1,1),(89,17,0,0,'CDK_RYS',1,0),(90,18,0,0,'CDK_RYS',1,1),(91,19,0,0,'CDK_AUT',1,1),(92,20,0,0,'CDK_AUT',1,1),(93,21,0,0,'CDK_AUT',1,1),(94,22,0,0,'CDK_AUT',1,1),(96,24,0,0,'CDK_AUT',1,1),(97,25,0,0,'CDK_AUT',1,1),(98,26,0,0,'CDK_AUT',1,1),(99,27,0,0,'CDK_AUT',1,1),(106,19,0,0,'CDK_PAD',1,1),(107,20,0,0,'CDK_PAD',1,1),(108,21,0,0,'CDK_PAD',1,1),(109,22,0,0,'CDK_PAD',1,1),(111,24,0,0,'CDK_PAD',1,1),(112,25,0,0,'CDK_PAD',1,1),(113,26,0,0,'CDK_PAD',1,1),(114,27,0,0,'CDK_PAD',1,1),(121,19,0,0,'CDK_CNS',1,1),(122,20,0,0,'CDK_CNS',1,1),(123,21,0,0,'CDK_CNS',1,1),(124,22,0,0,'CDK_CNS',1,1),(126,24,0,0,'CDK_CNS',1,1),(127,25,0,0,'CDK_CNS',1,1),(128,26,0,0,'CDK_CNS',1,1),(129,27,0,0,'CDK_CNS',1,1),(151,19,1,0,'CDK_EST',1,0),(157,25,1,0,'CDK_EST',1,0),(158,26,1,0,'CDK_EST',1,0),(166,19,0,0,'CDK_RYS',1,1),(167,20,0,0,'CDK_RYS',1,1),(168,21,0,0,'CDK_RYS',1,1),(169,22,0,0,'CDK_RYS',1,1),(171,24,0,0,'CDK_RYS',1,1),(172,25,0,0,'CDK_RYS',1,1),(173,26,0,0,'CDK_RYS',1,1),(174,27,0,0,'CDK_RYS',1,1),(181,1,1,1,'CDK_STK',4,0),(182,2,1,1,'CDK_STK',4,0),(185,5,1,1,'CDK_STK',4,0),(186,6,1,1,'CDK_STK',1,0),(189,9,1,1,'CDK_STK',1,0),(190,10,1,1,'CDK_STK',4,0),(193,13,1,1,'CDK_STK',1,0),(194,14,1,1,'CDK_STK',4,0),(195,15,1,1,'CDK_STK',4,0),(197,17,1,1,'CDK_STK',4,0),(198,18,1,1,'CDK_STK',1,1),(199,19,1,1,'CDK_STK',1,0),(205,25,1,1,'CDK_STK',1,0),(206,26,1,1,'CDK_STK',1,0),(207,27,1,1,'CDK_STK',1,0),(212,1,1,2,'CDK_STK',4,0),(213,2,1,2,'CDK_STK',4,0),(216,5,1,2,'CDK_STK',4,0),(217,6,1,2,'CDK_STK',1,0),(220,9,1,2,'CDK_STK',1,0),(221,10,1,2,'CDK_STK',4,0),(224,13,1,2,'CDK_STK',1,0),(225,14,1,2,'CDK_STK',4,0),(226,15,1,2,'CDK_STK',4,0),(228,17,1,2,'CDK_STK',4,0),(229,18,1,2,'CDK_STK',1,1),(230,19,1,2,'CDK_STK',1,0),(236,25,1,2,'CDK_STK',1,0),(237,26,1,2,'CDK_STK',1,0),(238,27,1,2,'CDK_STK',1,0),(305,1,1,8,'CDK_STK',4,0),(306,2,1,8,'CDK_STK',4,0),(309,5,1,8,'CDK_STK',4,0),(310,6,1,8,'CDK_STK',1,0),(313,9,1,8,'CDK_STK',1,0),(314,10,1,8,'CDK_STK',4,0),(317,13,1,8,'CDK_STK',1,0),(318,14,1,8,'CDK_STK',4,0),(319,15,1,8,'CDK_STK',4,0),(321,17,1,8,'CDK_STK',4,0),(322,18,1,8,'CDK_STK',1,1),(323,19,1,8,'CDK_STK',1,0),(329,25,1,8,'CDK_STK',1,0),(330,26,1,8,'CDK_STK',1,0),(331,27,1,8,'CDK_STK',1,0),(460,1,1,0,'CDK_STK',4,0),(461,2,1,0,'CDK_STK',4,0),(464,5,1,0,'CDK_STK',4,0),(465,6,1,0,'CDK_STK',1,0),(468,9,1,0,'CDK_STK',1,0),(469,10,1,0,'CDK_STK',4,0),(472,13,1,0,'CDK_STK',1,0),(473,14,1,0,'CDK_STK',4,0),(474,15,1,0,'CDK_STK',4,0),(476,17,1,0,'CDK_STK',4,0),(477,18,1,0,'CDK_STK',1,1),(478,19,1,0,'CDK_STK',1,0),(484,25,1,0,'CDK_STK',1,0),(485,26,1,0,'CDK_STK',1,0),(486,27,1,0,'CDK_STK',1,0),(523,29,1,0,'CDK_EST',4,1),(524,30,1,0,'CDK_EST',8,0),(525,31,1,0,'CDK_EST',4,0),(526,32,1,0,'CDK_EST',4,0),(527,1,1,2,'CDK_FIS',4,0),(528,33,1,2,'CDK_FIS',4,0),(529,34,1,2,'CDK_FIS',1,0),(530,35,1,2,'CDK_FIS',1,0),(531,36,1,2,'CDK_FIS',1,0),(532,37,1,2,'CDK_FIS',1,1),(533,38,1,2,'CDK_FIS',1,1),(534,39,1,2,'CDK_FIS',1,0),(535,40,1,2,'CDK_FIS',1,0),(536,41,1,2,'CDK_FIS',1,1),(537,42,1,2,'CDK_FIS',3,1),(538,43,1,2,'CDK_FIS',4,0),(540,1,1,8,'CDK_FIS',4,0),(541,33,1,8,'CDK_FIS',4,0),(542,34,1,8,'CDK_FIS',1,0),(543,35,1,8,'CDK_FIS',1,0),(544,36,1,8,'CDK_FIS',1,0),(545,37,1,8,'CDK_FIS',1,1),(546,38,1,8,'CDK_FIS',1,1),(547,39,1,8,'CDK_FIS',1,0),(548,40,1,8,'CDK_FIS',1,0),(549,41,1,8,'CDK_FIS',1,1),(550,42,1,8,'CDK_FIS',3,1),(551,43,1,8,'CDK_FIS',4,0),(553,33,0,0,'CDK_RYS',1,0),(554,42,0,0,'CDK_RYS',1,1),(555,43,0,0,'CDK_RYS',1,0),(556,44,1,2,'CDK_FIS',1,0),(557,44,1,8,'CDK_FIS',1,0),(558,44,0,0,'CDK_RYS',1,0),(559,14,1,2,'CDK_FIS',4,0),(560,14,1,8,'CDK_FIS',4,0),(561,45,1,2,'CDK_FIS',1,0),(562,45,1,8,'CDK_FIS',1,0),(563,44,0,0,'CDK_RYS',1,0),(564,2,1,2,'CDK_FIS',4,0),(565,2,1,8,'CDK_FIS',4,0),(566,46,1,0,'CDK_EST',1,0),(567,47,1,0,'CDK_EST',1,0),(568,48,1,2,'CDK_FIS',1,0),(569,48,1,8,'CDK_FIS',1,0),(570,49,1,2,'CDK_FIS',1,1),(571,49,1,8,'CDK_FIS',1,1),(573,50,1,0,'CDK_EST',1,1),(574,2,1,1,'CDK_EST',4,0),(575,2,1,2,'CDK_EST',4,0),(576,2,1,6,'CDK_EST',4,1),(577,2,1,7,'CDK_EST',4,1),(578,2,1,8,'CDK_EST',4,0),(579,2,1,9,'CDK_EST',4,1),(580,1,1,1,'CDK_EST',4,0),(581,1,1,2,'CDK_EST',4,0),(582,1,1,6,'CDK_EST',4,1),(583,1,1,7,'CDK_EST',4,1),(584,1,1,8,'CDK_EST',4,0),(585,1,1,9,'CDK_EST',4,1),(586,19,1,1,'CDK_EST',1,0),(587,19,1,2,'CDK_EST',1,0),(588,19,1,6,'CDK_EST',1,1),(589,19,1,7,'CDK_EST',1,1),(590,19,1,8,'CDK_EST',1,0),(591,19,1,9,'CDK_EST',1,1),(592,25,1,1,'CDK_EST',1,0),(593,25,1,2,'CDK_EST',1,0),(594,25,1,6,'CDK_EST',1,1),(595,25,1,7,'CDK_EST',1,1),(596,25,1,8,'CDK_EST',1,0),(597,25,1,9,'CDK_EST',1,1),(604,29,1,1,'CDK_EST',4,1),(605,29,1,2,'CDK_EST',4,1),(606,29,1,6,'CDK_EST',4,1),(607,29,1,7,'CDK_EST',4,1),(608,29,1,8,'CDK_EST',4,1),(609,29,1,9,'CDK_EST',4,1),(610,32,1,1,'CDK_EST',4,0),(611,32,1,2,'CDK_EST',4,0),(612,32,1,6,'CDK_EST',4,1),(613,32,1,7,'CDK_EST',4,1),(614,32,1,8,'CDK_EST',4,0),(615,32,1,9,'CDK_EST',4,1),(616,47,1,1,'CDK_EST',1,0),(617,47,1,2,'CDK_EST',1,0),(618,47,1,6,'CDK_EST',1,1),(619,47,1,7,'CDK_EST',1,1),(620,47,1,8,'CDK_EST',1,0),(621,47,1,9,'CDK_EST',1,1),(622,50,1,1,'CDK_EST',1,1),(623,50,1,2,'CDK_EST',1,1),(624,50,1,6,'CDK_EST',1,1),(625,50,1,7,'CDK_EST',1,1),(626,50,1,8,'CDK_EST',1,1),(627,50,1,9,'CDK_EST',1,1),(628,13,1,1,'CDK_EST',4,0),(629,13,1,2,'CDK_EST',4,0),(630,13,1,6,'CDK_EST',4,1),(631,13,1,7,'CDK_EST',4,1),(632,13,1,8,'CDK_EST',4,0),(633,13,1,9,'CDK_EST',4,1),(640,26,1,1,'CDK_EST',1,0),(641,26,1,2,'CDK_EST',1,0),(642,26,1,6,'CDK_EST',1,1),(643,26,1,7,'CDK_EST',1,1),(644,26,1,8,'CDK_EST',1,0),(645,26,1,9,'CDK_EST',1,1),(646,31,1,1,'CDK_EST',4,0),(647,31,1,2,'CDK_EST',4,0),(648,31,1,6,'CDK_EST',4,1),(649,31,1,7,'CDK_EST',4,1),(650,31,1,8,'CDK_EST',4,0),(651,31,1,9,'CDK_EST',4,1),(652,30,1,1,'CDK_EST',8,0),(653,30,1,2,'CDK_EST',8,0),(654,30,1,6,'CDK_EST',8,1),(655,30,1,7,'CDK_EST',8,1),(656,30,1,8,'CDK_EST',8,0),(657,30,1,9,'CDK_EST',8,1),(658,18,1,1,'CDK_EST',1,0),(659,18,1,2,'CDK_EST',1,0),(660,18,1,6,'CDK_EST',1,1),(661,18,1,7,'CDK_EST',1,1),(662,18,1,8,'CDK_EST',1,0),(663,18,1,9,'CDK_EST',1,1),(664,46,1,1,'CDK_EST',1,0),(665,46,1,2,'CDK_EST',1,0),(666,46,1,6,'CDK_EST',1,1),(667,46,1,7,'CDK_EST',1,1),(668,46,1,8,'CDK_EST',1,0),(669,46,1,9,'CDK_EST',1,1),(670,52,1,0,'CDK_EST',9,0),(671,52,1,1,'CDK_EST',9,0),(672,53,1,0,'CDK_EST',9,0),(673,53,1,1,'CDK_EST',9,0),(674,54,1,0,'CDK_EST',11,0),(675,54,1,1,'CDK_EST',11,0),(676,55,1,0,'CDK_EST',1,0),(677,55,1,1,'CDK_EST',1,0),(678,56,1,0,'CDK_EST',1,0),(679,57,1,0,'CDK_EST',9,0),(680,57,1,2,'CDK_EST',9,0),(681,58,1,0,'CDK_EST',9,0),(682,58,1,2,'CDK_EST',9,0),(683,59,1,0,'CDK_EST',9,0),(684,59,1,2,'CDK_EST',9,0),(685,60,1,0,'CDK_EST',9,0),(686,60,1,2,'CDK_EST',9,0),(687,61,1,0,'CDK_EST',9,0),(688,61,1,2,'CDK_EST',9,0),(689,62,1,0,'CDK_EST',9,0),(690,62,1,2,'CDK_EST',9,0),(691,63,1,0,'CDK_EST',9,0),(692,63,1,2,'CDK_EST',9,0),(693,64,1,0,'CDK_EST',9,0),(694,64,1,2,'CDK_EST',9,0),(695,65,1,0,'CDK_EST',9,0),(696,65,1,2,'CDK_EST',9,0),(697,66,1,0,'CDK_EST',9,0),(698,66,1,2,'CDK_EST',9,1),(699,67,1,0,'CDK_EST',1,0),(700,67,1,1,'CDK_EST',1,0),(701,67,1,2,'CDK_EST',1,0),(702,67,1,6,'CDK_EST',1,1),(703,67,1,7,'CDK_EST',1,1),(704,67,1,8,'CDK_EST',1,0),(705,67,1,9,'CDK_EST',1,1),(706,12,1,0,'CDK_EST',1,0),(707,12,1,1,'CDK_EST',1,0),(708,12,1,2,'CDK_EST',1,0),(709,12,1,6,'CDK_EST',1,1),(710,12,1,7,'CDK_EST',1,1),(711,12,1,8,'CDK_EST',1,0),(712,12,1,9,'CDK_EST',1,1),(713,68,1,0,'CDK_EST',1,1),(714,68,1,1,'CDK_EST',1,1),(715,68,1,2,'CDK_EST',1,1),(716,68,1,6,'CDK_EST',1,1),(717,68,1,7,'CDK_EST',1,1),(718,68,1,8,'CDK_EST',1,1),(719,68,1,9,'CDK_EST',1,1),(720,69,1,0,'CDK_EST',1,0),(721,69,1,1,'CDK_EST',1,0),(722,69,1,2,'CDK_EST',1,0),(723,69,1,6,'CDK_EST',1,1),(724,69,1,7,'CDK_EST',1,1),(725,69,1,8,'CDK_EST',1,0),(726,69,1,9,'CDK_EST',1,1),(727,56,1,1,'CDK_EST',1,0),(728,56,1,2,'CDK_EST',1,0),(729,56,1,8,'CDK_EST',1,0),(730,65,1,8,'CDK_EST',9,0),(731,54,1,2,'CDK_EST',11,0),(732,70,1,0,'CDK_EST',1,0),(733,70,1,1,'CDK_EST',1,0),(734,70,1,2,'CDK_EST',1,0),(735,70,1,8,'CDK_EST',1,0),(736,71,1,0,'CDK_EST',1,0),(737,71,1,1,'CDK_EST',1,0),(738,71,1,2,'CDK_EST',1,0),(739,71,1,8,'CDK_EST',1,0),(740,72,1,2,'CDK_FIS',1,0),(741,72,1,8,'CDK_FIS',1,0),(742,73,1,2,'CDK_FIS',1,1),(743,73,1,8,'CDK_FIS',1,1),(744,74,1,0,'CDK_EST',9,0),(745,74,1,2,'CDK_EST',9,0),(746,75,1,0,'CDK_EST',9,0),(747,75,1,8,'CDK_EST',9,0),(748,76,1,0,'CDK_EST',9,0),(749,76,1,8,'CDK_EST',9,0),(750,77,1,0,'CDK_EST',9,0),(751,77,1,8,'CDK_EST',9,0),(752,78,1,0,'CDK_EST',9,0),(753,78,1,8,'CDK_EST',9,0),(754,74,1,8,'CDK_EST',9,0),(755,79,1,0,'CDK_EST',10,0),(756,79,1,8,'CDK_EST',10,1),(757,80,1,0,'CDK_EST',10,0),(758,80,1,8,'CDK_EST',10,1),(759,81,1,0,'CDK_EST',8,0),(760,81,1,8,'CDK_EST',8,0),(761,82,1,0,'CDK_EST',9,0),(762,82,1,8,'CDK_EST',9,0),(763,83,1,0,'CDK_EST',9,0),(764,83,1,8,'CDK_EST',9,0),(765,84,1,0,'CDK_EST',8,0),(766,84,1,8,'CDK_EST',8,1),(767,85,1,0,'CDK_EST',8,0),(768,85,1,8,'CDK_EST',8,1),(769,86,1,0,'CDK_EST',8,0),(770,86,1,8,'CDK_EST',8,1),(771,87,1,0,'CDK_EST',8,0),(772,87,1,8,'CDK_EST',8,1),(773,88,1,0,'CDK_EST',1,0),(774,88,1,1,'CDK_EST',1,0),(775,88,1,2,'CDK_EST',1,0),(776,88,1,6,'CDK_EST',1,1),(777,88,1,8,'CDK_EST',1,0),(778,88,1,9,'CDK_EST',1,1),(779,88,1,7,'CDK_EST',1,1),(780,89,1,0,'CDK_EST',1,1),(781,89,1,1,'CDK_EST',1,1),(782,89,1,2,'CDK_EST',1,1),(783,89,1,6,'CDK_EST',1,1),(784,89,1,7,'CDK_EST',1,1),(785,89,1,8,'CDK_EST',1,1),(786,89,1,9,'CDK_EST',1,1),(787,90,1,0,'CDK_EST',9,0),(788,90,1,8,'CDK_EST',9,0),(789,91,1,2,'CDK_FIS',1,0),(790,91,1,8,'CDK_FIS',1,0),(791,92,1,0,'CDK_EST',1,0),(792,92,1,1,'CDK_EST',1,0),(793,92,1,2,'CDK_EST',1,0),(794,92,1,6,'CDK_EST',1,1),(795,92,1,7,'CDK_EST',1,1),(796,92,1,8,'CDK_EST',1,0),(797,92,1,9,'CDK_EST',1,1),(798,15,1,0,'CDK_EST',4,0),(799,15,1,1,'CDK_EST',4,0),(800,15,1,2,'CDK_EST',4,0),(801,15,1,6,'CDK_EST',4,1),(802,15,1,7,'CDK_EST',4,1),(803,15,1,8,'CDK_EST',4,0),(804,15,1,9,'CDK_EST',4,1),(805,14,1,0,'CDK_EST',4,0),(806,14,1,1,'CDK_EST',4,0),(807,14,1,2,'CDK_EST',4,0),(808,14,1,6,'CDK_EST',4,1),(809,14,1,7,'CDK_EST',4,1),(810,14,1,8,'CDK_EST',4,0),(811,14,1,9,'CDK_EST',4,1),(812,63,1,8,'CDK_EST',9,0),(813,84,1,2,'CDK_EST',8,1),(814,87,1,2,'CDK_EST',8,0),(815,85,1,1,'CDK_EST',8,1),(816,55,1,2,'CDK_EST',1,0),(817,55,1,8,'CDK_EST',1,0),(819,76,1,1,'CDK_EST',9,0),(820,76,1,2,'CDK_EST',9,0),(821,60,1,8,'CDK_EST',9,0),(822,93,1,0,'CDK_EST',1,0),(823,93,1,1,'CDK_EST',1,0),(824,93,1,2,'CDK_EST',1,0),(825,93,1,8,'CDK_EST',1,0),(826,94,1,0,'CDK_EST',8,0),(827,94,1,1,'CDK_EST',8,0),(828,94,1,2,'CDK_EST',8,0),(829,94,1,8,'CDK_EST',8,0),(830,95,1,0,'CDK_EST',1,0),(831,96,1,0,'CDK_EST',1,0),(832,96,1,1,'CDK_EST',1,0),(833,96,1,2,'CDK_EST',1,0),(834,96,1,8,'CDK_EST',1,0),(835,95,1,1,'CDK_EST',1,0),(836,95,1,2,'CDK_EST',1,0),(837,95,1,8,'CDK_EST',1,0),(838,97,1,0,'CDK_EST',9,0),(839,97,1,2,'CDK_EST',9,0),(840,98,1,0,'CDK_EST',9,0),(841,98,1,2,'CDK_EST',9,0),(842,99,1,0,'CDK_EST',9,0),(843,99,1,8,'CDK_EST',9,0),(844,100,1,0,'CDK_EST',4,0),(845,100,1,1,'CDK_EST',4,0),(846,100,1,2,'CDK_EST',4,0),(847,100,1,8,'CDK_EST',4,0),(848,2,0,0,'CDK_NYP',4,0),(849,101,1,0,'CDK_EST',9,0),(850,101,1,2,'CDK_EST',9,0),(851,101,1,8,'CDK_EST',9,0),(853,1,0,0,'CDK_NYP',4,0),(854,32,0,0,'CDK_NYP',4,0),(855,10,0,0,'CDK_NYP',4,0),(856,22,0,0,'CDK_NYP',4,1),(857,102,1,0,'CDK_EST',8,0),(858,102,1,8,'CDK_EST',8,0),(859,103,1,0,'CDK_EST',1,0),(860,104,1,0,'CDK_EST',1,0),(861,103,1,1,'CDK_EST',1,0),(862,103,1,2,'CDK_EST',1,0),(863,103,1,8,'CDK_EST',1,0),(864,104,1,1,'CDK_EST',1,0),(865,104,1,2,'CDK_EST',1,0),(866,104,1,8,'CDK_EST',1,0),(867,105,1,0,'CDK_EST',1,0),(868,105,1,1,'CDK_EST',1,0),(869,105,1,2,'CDK_EST',1,0),(870,105,1,8,'CDK_EST',1,0),(871,106,1,0,'CDK_EST',1,0),(872,106,1,1,'CDK_EST',1,0),(873,106,1,2,'CDK_EST',1,0),(874,106,1,8,'CDK_EST',1,0),(875,51,1,0,'CDK_EST',4,0),(876,51,1,1,'CDK_EST',4,0),(877,51,1,2,'CDK_EST',4,0),(878,51,1,8,'CDK_EST',4,0),(879,107,1,2,'CDK_FIS',1,0),(880,107,1,8,'CDK_FIS',1,0),(881,108,1,0,'CDK_EST',1,0),(882,108,1,1,'CDK_EST',1,0),(883,108,1,2,'CDK_EST',1,0),(884,108,1,8,'CDK_EST',1,0),(885,109,1,0,'CDK_EST',4,0),(886,109,1,1,'CDK_EST',4,0),(887,109,1,2,'CDK_EST',4,0),(888,109,1,8,'CDK_EST',4,0),(889,102,1,2,'CDK_EST',8,1),(890,85,1,2,'CDK_EST',8,0),(891,86,1,2,'CDK_EST',8,0),(892,110,1,0,'CDK_EST',9,0),(893,110,1,2,'CDK_EST',9,0),(894,111,0,0,'CDK_CNS',1,0),(895,111,0,0,'CDK_PAD',1,0),(896,111,0,0,'CDK_AUT',1,0),(897,5,1,0,'CDK_EST',4,0),(898,10,1,0,'CDK_EST',4,0),(899,5,1,1,'CDK_EST',4,0),(900,5,1,2,'CDK_EST',4,0),(901,5,1,8,'CDK_EST',4,0),(902,10,1,1,'CDK_EST',4,0),(903,10,1,2,'CDK_EST',4,0),(904,10,1,8,'CDK_EST',4,0),(905,17,1,0,'CDK_EST',1,0),(906,17,1,1,'CDK_EST',1,0),(907,17,1,2,'CDK_EST',1,0),(908,17,1,8,'CDK_EST',1,0),(909,112,0,0,'CDK_AUT',2,0),(910,112,0,0,'CDK_PAD',1,0),(911,54,1,8,'CDK_EST',11,0),(912,111,1,0,'CDK_EST',1,0),(913,111,1,1,'CDK_EST',1,0),(914,111,1,2,'CDK_EST',1,0),(915,111,1,8,'CDK_EST',1,0),(916,113,1,0,'CDK_EST',9,0),(917,113,1,2,'CDK_EST',9,0),(918,100,1,2,'CDK_FIS',1,0),(919,100,1,8,'CDK_FIS',1,0),(920,93,1,2,'CDK_FIS',1,0),(921,93,1,8,'CDK_FIS',1,0),(922,79,1,1,'CDK_EST',10,0),(923,114,1,0,'CDK_EST',8,0),(924,114,1,1,'CDK_EST',8,0),(925,75,1,1,'CDK_EST',9,0),(926,115,1,0,'CDK_EST',9,0),(927,115,1,2,'CDK_EST',9,0),(928,67,1,0,'CDK_STK',1,0),(929,67,1,1,'CDK_STK',1,0),(930,116,1,0,'CDK_EST',1,0),(931,116,1,1,'CDK_EST',1,0),(932,116,1,2,'CDK_EST',1,0),(933,116,1,8,'CDK_EST',1,0),(934,100,0,0,'CDK_AUT',4,0),(935,100,0,0,'CDK_PAD',4,0),(936,100,0,0,'CDK_CNS',4,0),(937,109,0,0,'CDK_PAD',4,0),(938,117,1,0,'CDK_EST',1,0),(939,117,1,1,'CDK_EST',1,0),(940,117,1,2,'CDK_EST',1,0),(941,117,1,8,'CDK_EST',1,0),(942,51,1,10,'CDK_EST',4,0),(943,14,1,10,'CDK_EST',4,0),(944,32,1,10,'CDK_EST',4,0),(945,100,1,10,'CDK_EST',4,0),(946,10,1,10,'CDK_EST',4,0),(947,109,1,10,'CDK_EST',4,0),(948,15,1,10,'CDK_EST',4,0),(949,13,1,10,'CDK_EST',4,0),(950,5,1,10,'CDK_EST',4,0),(951,2,1,10,'CDK_EST',4,0),(952,1,1,10,'CDK_EST',4,0),(953,88,1,10,'CDK_EST',1,0),(954,71,1,10,'CDK_EST',1,0),(955,18,1,10,'CDK_EST',1,0),(956,70,1,10,'CDK_EST',1,0),(957,117,1,10,'CDK_EST',1,0),(958,95,1,10,'CDK_EST',1,0),(959,69,1,10,'CDK_EST',1,0),(960,103,1,10,'CDK_EST',1,0),(961,47,1,10,'CDK_EST',1,0),(962,25,1,10,'CDK_EST',1,0),(963,56,1,10,'CDK_EST',1,0),(964,46,1,10,'CDK_EST',1,0),(965,67,1,10,'CDK_EST',1,0),(966,26,1,10,'CDK_EST',1,0),(967,17,1,10,'CDK_EST',1,0),(968,93,1,10,'CDK_EST',1,0),(969,111,1,10,'CDK_EST',1,0),(970,116,1,10,'CDK_EST',1,0),(971,55,1,10,'CDK_EST',1,0),(972,108,1,10,'CDK_EST',1,0),(973,96,1,10,'CDK_EST',1,0),(974,19,1,10,'CDK_EST',1,0),(975,92,1,10,'CDK_EST',1,0),(976,104,1,10,'CDK_EST',1,0),(977,105,1,10,'CDK_EST',1,0),(978,106,1,10,'CDK_EST',1,0),(979,118,1,0,'CDK_EST',8,0),(980,118,1,8,'CDK_EST',8,0),(981,119,1,0,'CDK_EST',8,0),(982,119,1,8,'CDK_EST',8,0),(983,120,1,0,'CDK_EST',9,0),(984,120,1,2,'CDK_EST',9,0),(985,121,1,2,'CDK_FIS',1,0),(986,121,1,8,'CDK_FIS',1,0),(987,122,1,0,'CDK_EST',9,0),(988,122,1,8,'CDK_EST',9,0),(989,58,1,8,'CDK_EST',9,0),(990,123,1,0,'CDK_EST',8,0),(991,124,1,0,'CDK_EST',8,0),(992,123,1,1,'CDK_EST',8,0),(993,123,1,2,'CDK_EST',8,0),(994,123,1,8,'CDK_EST',8,0),(995,124,1,1,'CDK_EST',8,0),(996,124,1,2,'CDK_EST',8,0),(997,124,1,8,'CDK_EST',8,0),(998,6,1,0,'CDK_EST',4,0),(999,6,1,1,'CDK_EST',4,0),(1000,6,1,2,'CDK_EST',4,0),(1001,6,1,8,'CDK_EST',4,0),(1002,114,1,2,'CDK_EST',8,0),(1003,51,2,0,'CDK_EST',4,0),(1004,98,1,8,'CDK_EST',9,0),(1005,62,1,8,'CDK_EST',9,0),(1007,125,0,0,'CDK_AUT',4,0),(1008,125,0,0,'CDK_CNS',4,0),(1009,125,1,0,'CDK_EST',4,0),(1010,125,1,1,'CDK_EST',4,0),(1011,125,1,2,'CDK_EST',4,0),(1012,125,1,6,'CDK_EST',4,1),(1013,125,1,7,'CDK_EST',4,1),(1014,125,1,8,'CDK_EST',4,0),(1015,125,1,9,'CDK_EST',4,1),(1016,125,1,10,'CDK_EST',4,0),(1017,125,1,2,'CDK_FIS',4,0),(1018,125,1,8,'CDK_FIS',4,0),(1019,125,0,0,'CDK_NYP',4,0),(1020,125,0,0,'CDK_PAD',4,0),(1021,125,0,0,'CDK_RYS',4,0),(1022,125,1,0,'CDK_STK',4,0),(1023,125,1,1,'CDK_STK',4,0),(1024,125,1,2,'CDK_STK',4,0),(1025,125,1,8,'CDK_STK',4,0),(1026,51,0,0,NULL,4,1),(1027,127,0,0,NULL,3,1),(1028,128,0,0,NULL,1,1),(1029,129,0,0,NULL,1,1),(1031,130,0,0,NULL,12,1),(1032,131,0,0,NULL,12,1);

UNLOCK TABLES;

/*Table structure for table `usuario_rol` */

DROP TABLE IF EXISTS `usuario_rol`;

CREATE TABLE `usuario_rol` (
  `idUsuario` int(11) NOT NULL,
  `idRol` int(11) NOT NULL,
  PRIMARY KEY (`idUsuario`,`idRol`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `usuario_rol` */

LOCK TABLES `usuario_rol` WRITE;

insert  into `usuario_rol`(`idUsuario`,`idRol`) values (1,10),(2,1),(3,3);

UNLOCK TABLES;

/*Table structure for table `usuario_tipo` */

DROP TABLE IF EXISTS `usuario_tipo`;

CREATE TABLE `usuario_tipo` (
  `usuTipoId` varchar(4) NOT NULL,
  `usuTipoDesc` varchar(50) DEFAULT NULL,
  `usuTipoHabil` int(1) DEFAULT '0',
  PRIMARY KEY (`usuTipoId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `usuario_tipo` */

LOCK TABLES `usuario_tipo` WRITE;

insert  into `usuario_tipo`(`usuTipoId`,`usuTipoDesc`,`usuTipoHabil`) values ('CLI','Cliente/Proveedor',0),('INT','Interno',0);

UNLOCK TABLES;

/* Function  structure for function  `fc_get_empresa` */

/*!50003 DROP FUNCTION IF EXISTS `fc_get_empresa` */;
DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` FUNCTION `fc_get_empresa`(w_ID bigint(20)) RETURNS varchar(200) CHARSET latin1
BEGIN
	declare _respuesta varchar(200) default "0;;";
	declare _existe int(11) default 0;
	
	if w_ID > 0 then
		set _existe = (
			select
			count(*)
			from
			empresa
			where
			idEmpresa = w_ID
		);
		if _existe > 0 then
			set _respuesta = (
				select
				concat(
					if(isnull(cuit), '', cuit), ";",
					IF(ISNULL(nombre), '', nombre), ";",
					IF(ISNULL(codigo), '', codigo)
				)
				from
				empresa
				where
				idEmpresa = w_ID
			);
		end if;
	end if;
	
	return _respuesta;
    END */$$
DELIMITER ;

/* Function  structure for function  `fc_get_perfil_sistema_con_sucursal` */

/*!50003 DROP FUNCTION IF EXISTS `fc_get_perfil_sistema_con_sucursal` */;
DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` FUNCTION `fc_get_perfil_sistema_con_sucursal`(w_idUsuario bigint(20), w_idEmpresa bigint(20), w_idSucursal bigint(20), w_idSistema varchar(8)) RETURNS varchar(100) CHARSET utf8
begin
	-- Formato respuesta: "id del perfil;Nombre de perfil"
	DECLARE respuesta VARCHAR(200) DEFAULT "0;sin-perfil;0;;0;";
	DECLARE existe INT DEFAULT 0;
	DECLARE seguir INT DEFAULT 0;
	
	-- Verificar si existe
	SET existe = (
		SELECT 
		COUNT(*) 
		FROM 
		usuario_empresa_sucursal_perfil_sistema 
		WHERE 
		idUsuario = w_idUsuario AND 
		idEmpresa = w_idEmpresa AND 
		idSucursal = w_idSucursal AND 
		idSistema = w_idSistema
	);
	
	IF existe = 0 THEN
		SET seguir = 1;
		SET respuesta = "0;No tiene perfil asignado.";
	END IF;
	
	-- Si tiene perfil, verificar si esta habilitado
	IF seguir = 0 THEN
		SET existe = (
			SELECT 
			COUNT(*) 
			FROM 
			usuario_empresa_sucursal_perfil_sistema 
			WHERE 
			idUsuario = w_idUsuario AND 
			idEmpresa = w_idEmpresa AND 
			idSucursal = w_idSucursal AND 
			idSistema = w_idSistema AND 
			habilitado = 0
		);
		
		IF existe = 0 THEN
			SET seguir = 1;
			SET respuesta = "0;No tiene el perfil habilitado.";
		END IF;
	END IF;
	
	-- Get perfil
	IF seguir = 0 THEN
		SET respuesta = (
			SELECT
			CONCAT(
			IF(ISNULL(uesps.idPerfil), 0, uesps.idPerfil), ";",
			IF(ISNULL(p.nombre), "", p.nombre), ";",
			uesps.idEmpresa, ";",
			IF(uesps.idEmpresa > 0, (SELECT nombre FROM empresa WHERE idEmpresa = uesps.idEmpresa), ''), ";",
			uesps.idSucursal, ";",
			IF(uesps.idSucursal > 0, (SELECT descripcion FROM sucursal WHERE idSucursal = uesps.idSucursal), '')
			)
			FROM
			usuario_empresa_sucursal_perfil_sistema uesps,
			perfil p
			WHERE 
			p.idPerfil = uesps.idPerfil AND 
			uesps.idUsuario = w_idUsuario AND 
			uesps.idEmpresa = w_idEmpresa AND 
			uesps.idSucursal = w_idSucursal AND 
			uesps.idSistema = w_idSistema
		);
		
	END IF;
	
	RETURN respuesta;
END */$$
DELIMITER ;

/* Function  structure for function  `fc_get_sucursal` */

/*!50003 DROP FUNCTION IF EXISTS `fc_get_sucursal` */;
DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` FUNCTION `fc_get_sucursal`(w_ID bigint(20)) RETURNS varchar(500) CHARSET latin1
BEGIN
	DECLARE _respuesta VARCHAR(500) DEFAULT ";;;;;";
	DECLARE _existe INT(11) DEFAULT 0;
	
	IF w_ID > 0 THEN
		SET _existe = (
			SELECT
			COUNT(*)
			FROM
			sucursal
			WHERE
			idSucursal = w_ID
		);
		IF _existe > 0 THEN
			SET _respuesta = (
				SELECT
				CONCAT(
					IF(ISNULL(descripcion), '', descripcion), ";",
					IF(ISNULL(codigo), '', codigo), ";",
					IF(ISNULL(domicilio), '', domicilio), ";",
					IF(ISNULL(telefono), '', telefono), ";",
					IF(ISNULL(email), '', email), ";",
					IF(ISNULL(afip), '', afip)
				)
				FROM
				sucursal
				WHERE
				idSucursal = w_ID
			);
		END IF;
	END IF;
	
	RETURN _respuesta;
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

/* Procedure structure for procedure `sp_agregar_empresa` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_agregar_empresa` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_agregar_empresa`(w_cuit varchar(11), w_nombre varchar(50), w_codigo varchar(3))
BEGIN
	declare _existe int(11) default 0;
	declare _seguir int(1) default 0;
	declare _mensaje varchar(100) default "";
	start transaction;
	set _existe = (
		select
		count(*)
		from
		empresa
		where
		cuit = w_cuit
	);
	if _existe > 0 then
		set _seguir = 1;
		set _mensaje = concat("Ya existe una empresa con el CUIT ", w_cuit);
	end if;
	if _seguir = 0 then
		insert empresa (
			cuit,
			nombre,
			codigo
		) values (
			w_cuit,
			w_nombre,
			w_codigo
		);
		set _mensaje = "success";
	end if;
	select _mensaje;
	commit;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_agregar_PerAccSis` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_agregar_PerAccSis` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_agregar_PerAccSis`(w_perfilID bigint(20), w_codigoAccion varchar(20), w_sistemaID varchar(8))
BEGIN
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";
	START TRANSACTION;
	SET _existe = (
		SELECT
		COUNT(*)
		FROM
		perfil_accion_sistema
		WHERE
		idPerfil = w_perfilID and 
		idSistema = w_sistemaID
	);
	IF _existe > 0 THEN
		SET _seguir = 1;
		SET _mensaje = "Ya existe el perfil para el sistema";
	END IF;
	IF _seguir = 0 THEN
		INSERT perfil_accion_sistema (
			idPerfil,
			codigoAccion,
			idSistema
		) VALUES (
			w_perfilID,
			w_codigoAccion,
			w_sistemaID
		);
		SET _mensaje = "success";
	END IF;
	SELECT _mensaje;
	COMMIT;	
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_agregar_perfil` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_agregar_perfil` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_agregar_perfil`(w_nombre varchar(30))
BEGIN
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";
	START TRANSACTION;
	SET _existe = (
		SELECT
		COUNT(*)
		FROM
		perfil
		WHERE
		nombre = w_nombre
	);
	IF _existe > 0 THEN
		SET _seguir = 1;
		SET _mensaje = CONCAT("Ya existe un perfil con el nombre ", w_nombre);
	END IF;
	IF _seguir = 0 THEN
		INSERT perfil (
			nombre
		) VALUES (
			w_nombre
		);
		SET _mensaje = "success";
	END IF;
	SELECT _mensaje;
	COMMIT;	
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_agregar_sistema` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_agregar_sistema` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_agregar_sistema`(w_ID varchar(8), w_nombre varchar(50))
BEGIN
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";
	START TRANSACTION;
	SET _existe = (
		SELECT
		COUNT(*)
		FROM
		sistema
		WHERE
		idSistema = w_ID
	);
	IF _existe > 0 THEN
		SET _seguir = 1;
		SET _mensaje = CONCAT("Ya existe un sistema con el ID/codigo ", w_ID);
	END IF;
	IF _seguir = 0 THEN
		INSERT sistema (
			idSistema,
			nombre
		) VALUES (
			w_ID,
			w_nombre
		);
		SET _mensaje = "success";
	END IF;
	SELECT _mensaje;
	COMMIT;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_agregar_sucursal` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_agregar_sucursal` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_agregar_sucursal`(w_empresaID bigint(20), w_descripcion varchar(50), w_codigo varchar(6), w_domicilio varchar(50), w_telefono varchar(60), w_email varchar(60), w_AFIPPuntoVenta varchar(4))
BEGIN
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";
	
	START TRANSACTION;
	
	SET _existe = (SELECT COUNT(*) FROM sucursal WHERE idEmpresa = w_empresaID and codigo = w_codigo);
	
	IF _existe > 0 THEN
		SET _seguir = 1;
		SET _mensaje = CONCAT("Ya existe una sucursal con el codigo ", w_codigo, " para la empresa seleccionada");
	END IF;
	
	IF _seguir = 0 THEN
		INSERT sucursal (idEmpresa, descripcion, codigo, domicilio, telefono, email, afip) VALUES (w_empresaID, upper(w_descripcion), upper(w_codigo), w_domicilio, w_telefono, w_email, w_AFIPPuntoVenta);
		
		SET _mensaje = "success";
	END IF;
	
	SELECT _mensaje;
	
	COMMIT;
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

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_agregar_usuario`(w_nombre varchar(40), w_telefono varchar(40), w_email varchar(50), w_nota varchar(200), w_username varchar(50), w_password varchar(50), w_firma varchar(40), w_tipoID varchar(3), w_clienteID bigint(10), w_kineID bigint(20))
BEGIN
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";
	declare _id bigint(20) default 0;
	
	START TRANSACTION;
	
	SET _existe = (SELECT COUNT(*) FROM usuario WHERE nombreUsuarioEnc = md5(w_username));
	
	IF _existe > 0 THEN
		SET _seguir = 1;
		SET _mensaje = "El Email de nombre de usuario ya existe";
	END IF;
	
	IF _seguir = 0 THEN
		INSERT usuario (nombre, telefono, email, nota, nombreUsuario, nombreUsuarioEnc, passwordUsuario, passwordUsuarioEnc, firma, fechaAlta, tipo, idCliente, idKine) VALUES (w_nombre, w_telefono, w_email, w_nota, w_username, md5(w_username), w_password, md5(w_password), w_firma, curdate(), w_tipoID, w_clienteID, w_kineID);	
		set _id = last_insert_id();
		SET _mensaje = "success";
	END IF;
	
	COMMIT;	
		
	SELECT _mensaje, _id;
	
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_agregar_UsuEmpSucPerSis` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_agregar_UsuEmpSucPerSis` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_agregar_UsuEmpSucPerSis`(w_usuarioID bigint(20), w_empresaID bigint(20), w_sucursalID bigint(20), w_sistemaID varchar(8), w_perfilID bigint(20))
BEGIN
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";
	START TRANSACTION;
	SET _existe = (
		SELECT
		COUNT(*)
		FROM
		usuario_empresa_sucursal_perfil_sistema
		WHERE
		idUsuario = w_usuarioID and 
		idEmpresa = w_empresaID and
		idSucursal = w_sucursalID and
		idSistema = w_sistemaID
	);
	IF _existe > 0 THEN
		SET _seguir = 1;
		SET _mensaje = "Ya existe el registro";
	END IF;
	IF _seguir = 0 THEN
		INSERT usuario_empresa_sucursal_perfil_sistema (
			idUsuario,
			idEmpresa,
			idSucursal,
			idSistema,
			idPerfil
		) VALUES (
			w_usuarioID,
			w_empresaID,
			w_sucursalID,
			w_sistemaID,
			w_perfilID
		);
		SET _mensaje = "success";
	END IF;
	SELECT _mensaje;
	COMMIT;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_asignar_ticket` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_asignar_ticket` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_asignar_ticket`(
  IN w_Id_Tkt BIGINT,
  IN w_Id_Usuario_Asignado INT,
  OUT p_resultado VARCHAR(255)
)
proc: BEGIN
  DECLARE v_count INT;
  DECLARE v_ticket_existe INT;
  
  -- Validar que el ticket existe
  SELECT COUNT(*) INTO v_ticket_existe FROM tkt WHERE Id_Tkt = w_Id_Tkt;
  IF v_ticket_existe = 0 THEN
    SET p_resultado = 'Error: Ticket no existe';
    LEAVE proc;
  END IF;
  
  -- Validar que el usuario existe
  SELECT COUNT(*) INTO v_count FROM usuario WHERE idUsuario = w_Id_Usuario_Asignado;
  IF v_count = 0 THEN
    SET p_resultado = CONCAT('Error: Usuario ', w_Id_Usuario_Asignado, ' no existe');
    LEAVE proc;
  END IF;
  
  -- Asignar ticket
  UPDATE tkt
     SET Id_Usuario_Asignado = w_Id_Usuario_Asignado,
         Date_Asignado = NOW()
   WHERE Id_Tkt = w_Id_Tkt;
  
  SET p_resultado = 'OK';
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_empresa` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_empresa` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_editar_empresa`(w_ID bigint(20), w_cuit varchar(11), w_nombre varchar(50), w_codigo varchar(3), w_habilitado int(1))
BEGIN
	declare _cuitAnterior varchar(11) default "";
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";	
	START TRANSACTION;
	set _cuitAnterior = (
		select
		cuit
		from
		empresa
		where
		idEmpresa = w_ID
	);
	if _cuitAnterior != w_cuit then
		SET _existe = (
			SELECT
			COUNT(*)
			FROM
			empresa
			WHERE
			cuit = w_cuit
		);
		IF _existe > 0 THEN
			SET _seguir = 1;
			SET _mensaje = CONCAT("Ya existe una empresa con el CUIT ", w_cuit);
		END IF;
	end if;
	
	IF _seguir = 0 THEN
		update empresa
		set
		cuit = w_cuit,
		nombre = w_nombre,
		codigo = w_codigo,
		habilitado = w_habilitado
		where
		idEmpresa = w_ID;
		SET _mensaje = "success";
	END IF;
	SELECT _mensaje;
	COMMIT;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_PerAccSis` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_PerAccSis` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_editar_PerAccSis`(w_ID bigint(20), w_codigoAccion VARCHAR(20), w_habilitado int(1))
BEGIN	
	START TRANSACTION;
	UPDATE perfil_accion_sistema
	SET
	codigoAccion = w_codigoAccion,
	habilitado = w_habilitado
	WHERE
	ID = w_ID;
	COMMIT;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_perfil` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_perfil` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_editar_perfil`(w_ID bigint(20), w_nombre varchar(30), w_habilitado int(1))
BEGIN
	DECLARE _nombreAnterior VARCHAR(30) DEFAULT "";
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";	
	START TRANSACTION;
	SET _nombreAnterior = (
		SELECT
		nombre
		FROM
		perfil
		WHERE
		idPerfil = w_ID
	);
	IF _nombreAnterior != w_nombre THEN
		SET _existe = (
			SELECT
			COUNT(*)
			FROM
			perfil
			WHERE
			nombre = w_nombre
		);
		IF _existe > 0 THEN
			SET _seguir = 1;
			SET _mensaje = CONCAT("Ya existe un perfil con el nombre ", w_nombre);
		END IF;
	END IF;
	
	IF _seguir = 0 THEN
		UPDATE perfil
		SET
		nombre = w_nombre,
		habilitado = w_habilitado
		WHERE
		idPerfil = w_ID;
		SET _mensaje = "success";
	END IF;
	SELECT _mensaje;
	COMMIT;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_sistema` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_sistema` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_editar_sistema`(w_ID varchar(8), w_nombre varchar(50), w_habilitado int(1))
BEGIN	
	START TRANSACTION;
	UPDATE sistema
	SET
	nombre = w_nombre,
	habilitado = w_habilitado
	WHERE
	idSistema = w_ID;
	COMMIT;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_sucursal` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_sucursal` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_editar_sucursal`(w_ID bigint(20), w_empresaID BIGINT(20), w_descripcion VARCHAR(50), w_codigo VARCHAR(6), w_domicilio VARCHAR(50), w_telefono VARCHAR(60), w_email VARCHAR(60), w_AFIPPuntoVenta VARCHAR(4), w_habilitado int(1))
BEGIN
	DECLARE _codigoAnterior VARCHAR(6) DEFAULT "";
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";	
	START TRANSACTION;
	SET _codigoAnterior = (
		SELECT
		codigo
		FROM
		sucursal
		WHERE
		idSucursal = w_ID
	);
	IF _codigoAnterior != w_codigo THEN
		SET _existe = (
			SELECT
			COUNT(*)
			FROM
			sucursal
			WHERE
			idEmpresa = w_empresaID and 
			codigo = w_codigo
		);
		IF _existe > 0 THEN
			SET _seguir = 1;
			SET _mensaje = CONCAT("Ya existe una sucursal con el codigo ", w_codigo, " para la empresa seleccionada");
		END IF;
	END IF;
	
	IF _seguir = 0 THEN
		UPDATE sucursal
		SET
		descripcion = w_descripcion,
		codigo = w_codigo,
		domicilio = w_domicilio,
		telefono = w_telefono,
		email = w_email,
		afip = w_AFIPPuntoVenta,
		habilitado = w_habilitado
		WHERE
		idSucursal = w_ID;
		SET _mensaje = "success";
	END IF;
	SELECT _mensaje;
	COMMIT;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_editar_usuario`(w_ID bigint(20), w_nombre VARCHAR(40), w_telefono VARCHAR(40), w_email VARCHAR(50), w_nota VARCHAR(200), w_username VARCHAR(50), w_password VARCHAR(50), w_firma VARCHAR(40), w_tipoID VARCHAR(3), w_clienteID BIGINT(10), w_kineID BIGINT(20), w_habilitado int(1), w_tipoEdit varchar(3))
BEGIN
	DECLARE _usernameEncAnterior VARCHAR(50) DEFAULT "";
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _seguir INT(1) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";	
	
	START TRANSACTION;
	
	SET _usernameEncAnterior = (SELECT nombreUsuarioEnc FROM usuario WHERE idUsuario = w_ID);
	
	IF _usernameEncAnterior != md5(w_username) THEN
		SET _existe = (SELECT COUNT(*) FROM usuario WHERE nombreUsuarioEnc = md5(w_username));
		IF _existe > 0 THEN
			SET _seguir = 1;
			SET _mensaje = "El Email ya fue registrado.";
		END IF;
	END IF;
	
	IF _seguir = 0 THEN	
		-- Si tipoEdit = "adm" => editar todos los campos; sino editar los principales.
		if w_tipoEdit = "adm" then		
			UPDATE usuario SET nombre = w_nombre, telefono = w_telefono, email = w_email, nombreUsuario = w_username, nombreUsuarioEnc = MD5(w_username), passwordUsuario = w_password, passwordUsuarioEnc = MD5(w_password), firma = w_firma, fechaBaja = IF(w_habilitado = 1, CURDATE(), NULL), tipo = w_tipoID, idCliente = w_clienteID, idKine = w_kineID WHERE idUsuario = w_ID;		
		else
			UPDATE usuario SET nombre = w_nombre, telefono = w_telefono, email = w_email, nota = w_nota, nombreUsuario = w_username, nombreUsuarioEnc = MD5(w_username), passwordUsuario = w_password, passwordUsuarioEnc = MD5(w_password) WHERE idUsuario = w_ID;		
		end if;
		
		SET _mensaje = "success";
	END IF;
	
	SELECT _mensaje;
	
	COMMIT;
	
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_editar_UsuEmpSucPerSis` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_editar_UsuEmpSucPerSis` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_editar_UsuEmpSucPerSis`(w_ID bigint(20), w_perfilID bigint(20), w_habilitado int(1))
BEGIN
	start transaction;
	update usuario_empresa_sucursal_perfil_sistema
	set
	idPerfil = w_perfilID,
	habilitado = w_habilitado
	where
	ID = w_ID;
	commit;
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

/* Procedure structure for procedure `sp_listar_departamento` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_departamento` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_departamento`()
BEGIN
    END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_empresas` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_empresas` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_empresas`()
BEGIN
	
	START TRANSACTION;
	
	SELECT * FROM empresa;
	
	COMMIT;
    END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_PerAccSis` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_PerAccSis` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_listar_PerAccSis`(w_perfilID bigint(20), w_sistemaID varchar(8), w_habilitado int(1))
BEGIN
	START TRANSACTION;	
	SET @query = "
		SELECT
		pas.*,
		p.nombre 'perfil_nombre',
		s.nombre 'sistema_nombre'
		FROM
		perfil_accion_sistema pas,
		perfil p,
		sistema s
		WHERE
		p.idPerfil = pas.idPerfil AND
		s.idSistema = pas.idSistema
	";	
	IF w_perfilID > 0 THEN
		SET @query = CONCAT(@query, " AND pas.idPerfil = ", w_perfilID);
	END IF;
	IF w_sistemaID != "0" THEN
		SET @query = CONCAT(@query, " AND pas.idSistema = '", w_sistemaID, "'");
	END IF;
	IF w_habilitado > -1 THEN
		SET @query = CONCAT(@query, " AND pas.habilitado = ", w_habilitado);
	END IF;	
	PREPARE stmt FROM @query;
	EXECUTE stmt;
	COMMIT;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_perfil` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_perfil` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_listar_perfil`(w_nombre varchar(30), w_habilitado int(1))
BEGIN
	start transaction;	
	set @query = "
		SELECT
		*
		FROM
		perfil
		WHERE
		idPerfil > 0
	";	
	if w_nombre != "" then
		set @query = concat(@query, " AND nombre LIKE '%", w_nombre, "%'");
	end if;
	IF w_habilitado > -1 THEN
		SET @query = CONCAT(@query, " AND habilitado = ", w_habilitado);
	END IF;	
	prepare stmt from @query;
	execute stmt;
	commit;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_sistema` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_sistema` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_sistema`()
BEGIN
	
	start transaction;
	
	select * from sistema;
	
	commit;
    END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_sucursales` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_sucursales` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_listar_sucursales`()
BEGIN
	
	START TRANSACTION;
	
	SELECT
	s.*,
	e.nombre 'emp_nombre'
	FROM
	sucursal s,
	empresa e
	WHERE
	e.idEmpresa = s.idEmpresa;
	
	COMMIT;
	
    END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_sucursales_por_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_sucursales_por_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_sucursales_por_usuario`(w_usuarioID bigint(20), w_empID bigint(20), w_sistID varchar(8))
BEGIN
	
	start transaction;
	
	SELECT
	uesps.*,
	s.descripcion 'suc_nombre',
	s.codigo 'suc_codigo'
	FROM
	usuario_empresa_sucursal_perfil_sistema uesps,
	sucursal s
	WHERE
	s.idSucursal = uesps.idSucursal and
	uesps.idUsuario = w_usuarioID AND
	uesps.idEmpresa = w_empID AND
	uesps.idSucursal > 0 AND
	uesps.idSistema = w_sistID;
		
	commit;
    END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_tkt` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_tkt` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_listar_tkt`(
    IN w_id_tkt BIGINT(20),
    IN w_id_estado INT(10),
    IN w_date_creado_desde DATETIME,
    IN w_date_creado_hasta DATETIME,
    IN w_date_cierre_desde DATETIME,
    IN w_date_cierre_hasta DATETIME,
    IN w_id_usuario INT(20),
    IN w_id_empresa INT(20),
    IN w_id_perfil INT(20),
    IN w_id_motivo INT(20),
    IN w_id_sucursal INT(20),
    IN w_habilitado INT(20),
    IN w_id_prioridad INT(20),
    IN w_contenido VARCHAR(150),
    IN page_number INT,
    IN page_size INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error en la consulta' AS mensaje;
    END;
    START TRANSACTION;
    SET @query = "
        SELECT
            t.*
        FROM
            tkt t
        WHERE 1 = 1
        -- ... condiciones de filtro ...
        ORDER BY t.Date_Creado DESC
        LIMIT ?, ?";
    PREPARE stmt FROM @query;
    SET @offset = (page_number - 1) * page_size;
    SET @limit_value = page_size;
    EXECUTE stmt USING @offset, @limit_value;
    COMMIT;
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
    
    -- Crear tabla temporal para resultados
    DROP TEMPORARY TABLE IF EXISTS tmp_tickets;
    CREATE TEMPORARY TABLE tmp_tickets (
        Id_Tkt BIGINT(20),
        Id_Estado INT(10),
        Date_Creado DATETIME,
        Date_Cierre DATETIME,
        Date_Asignado DATETIME,
        Date_Cambio_Estado DATETIME,
        Id_Usuario INT(20),
        Id_Empresa INT(20),
        Id_Perfil INT(20),
        Id_Motivo INT(20),
        Id_Sucursal INT(20),
        Habilitado INT(20),
        Id_Prioridad INT(20),
        Contenido TEXT,
        Id_Departamento INT(20),
        Nombre_Usuario VARCHAR(150),
        Nombre_Departamento VARCHAR(255),
        NombrePrioridad VARCHAR(100),
        TipoEstado VARCHAR(100)
    );
    
    -- Insertar resultados filtrados (sin concatenación directa)
    INSERT INTO tmp_tickets
    SELECT 
        t.Id_Tkt,
        t.Id_Estado,
        t.Date_Creado,
        t.Date_Cierre,
        t.Date_Asignado,
        t.Date_Cambio_Estado,
        t.Id_Usuario,
        t.Id_Empresa,
        t.Id_Perfil,
        t.Id_Motivo,
        t.Id_Sucursal,
        t.Habilitado,
        t.Id_Prioridad,
        t.Contenido,
        t.Id_Departamento,
        u.nombre AS Nombre_Usuario,
        d.Nombre AS Nombre_Departamento,
        p.NombrePrioridad,
        e.TipoEstado
    FROM tkt t
    LEFT JOIN usuario u ON t.Id_Usuario = u.idUsuario
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
    
    -- Obtener total de registros
    SELECT COUNT(*) INTO totalRecords FROM tmp_tickets;
    
    -- Retornar página solicitada
    SELECT * FROM tmp_tickets
    LIMIT v_offset, w_Page_Size;
    
    DROP TEMPORARY TABLE IF EXISTS tmp_tickets;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_listar_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_listar_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_listar_usuario`(w_nombre VARCHAR(40), w_username VARCHAR(50), w_tipoID VARCHAR(3), w_habilitado INT(1))
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
	IF w_username != "" THEN
		SET @query = CONCAT(@query, " AND u.nombreUsuario LIKE '%", w_username, "%'");
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

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_listar_UsuEmpSucPerSis`(w_usuarioID bigint(20), w_empresaID bigint(20), w_sucursalID bigint(20), w_sistemaID varchar(8), w_perfilID bigint(20), w_habilitado int(1))
BEGIN
	START TRANSACTION;	
	SET @query = "
		SELECT
		uesps.*,
		fc_get_empresa(uesps.idEmpresa) 'datos_empresa',
		fc_get_sucursal(uesps.idSucursal) 'datos_sucursal',
		s.nombre 'sistema_nombre',
		p.nombre 'perfil_nombre'
		FROM
		usuario_empresa_sucursal_perfil_sistema uesps,
		usuario u,
		sistema s,
		perfil p
		WHERE
		u.idUsuario = uesps.idUsuario AND
		s.idSistema = uesps.idSistema AND
		p.idPerfil = uesps.idPerfil
	";
	IF w_usuarioID > 0 THEN
		SET @query = CONCAT(@query, " AND uesps.idUsuario = ", w_usuarioID);
	END IF;
	IF w_empresaID > -1 THEN
		SET @query = CONCAT(@query, " AND uesps.idEmpresa = ", w_empresaID);
	END IF;
	IF w_sucursalID > -1 THEN
		SET @query = CONCAT(@query, " AND uesps.idSucursal = ", w_sucursalID);
	END IF;	
	IF w_sistemaID != "0" THEN
		SET @query = CONCAT(@query, " AND uesps.idSistema = '", w_sistemaID, "'");
	END IF;
	IF w_perfilID > 0 THEN
		SET @query = CONCAT(@query, " AND uesps.idPerfil = ", w_perfilID);
	END IF;	
	IF w_habilitado > -1 THEN
		SET @query = CONCAT(@query,  " AND uesps.habilitado = ", w_habilitado);
	END IF;	
	PREPARE stmt FROM @query;
	EXECUTE stmt;
	COMMIT;	
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_login` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_login` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login`(
    IN w_usuario VARCHAR(200),
    IN w_clave   VARCHAR(200)
)
BEGIN
    main: BEGIN
    DECLARE v_user_col VARCHAR(64);
    DECLARE v_has_pw TINYINT(1) DEFAULT 0;
    DECLARE v_has_pwenc TINYINT(1) DEFAULT 0;
    DECLARE v_has_userenccol TINYINT(1) DEFAULT 0;
    DECLARE v_has_fechaBaja TINYINT(1) DEFAULT 0;
    DECLARE v_has_uesps TINYINT(1) DEFAULT 0;
    DECLARE v_uid BIGINT DEFAULT 0;
    DECLARE v_msg VARCHAR(100) DEFAULT '';
    DECLARE v_idPerfil BIGINT DEFAULT 0;
    DECLARE v_nombrePerfil VARCHAR(100) DEFAULT '';
    DECLARE v_idEmpresa BIGINT DEFAULT 0;
    DECLARE v_empresaNombre VARCHAR(100) DEFAULT '';
    DECLARE v_idSucursal BIGINT DEFAULT 0;
    DECLARE v_sucursalNombre VARCHAR(100) DEFAULT '';
    DECLARE v_sql TEXT;
    -- Detectar columna de usuario preferida
    SET v_user_col := (
        SELECT IF(EXISTS(SELECT 1 FROM information_schema.columns 
                          WHERE table_schema = DATABASE() AND table_name = 'usuario' AND column_name = 'nombreUsuario'), 'nombreUsuario',
               IF(EXISTS(SELECT 1 FROM information_schema.columns 
                          WHERE table_schema = DATABASE() AND table_name = 'usuario' AND column_name = 'nombre'), 'nombre',
               IF(EXISTS(SELECT 1 FROM information_schema.columns 
                          WHERE table_schema = DATABASE() AND table_name = 'usuario' AND column_name = 'email'), 'email', 'nombre')))
    );
    SET v_has_userenccol := (
        SELECT EXISTS(SELECT 1 FROM information_schema.columns 
                       WHERE table_schema = DATABASE() AND table_name = 'usuario' AND column_name = 'nombreUsuarioEnc')
    );
    -- Detectar columnas de password disponibles
    SET v_has_pw := (
        SELECT EXISTS(SELECT 1 FROM information_schema.columns 
                       WHERE table_schema = DATABASE() AND table_name = 'usuario' AND column_name = 'passwordUsuario')
    );
    SET v_has_pwenc := (
        SELECT EXISTS(SELECT 1 FROM information_schema.columns 
                       WHERE table_schema = DATABASE() AND table_name = 'usuario' AND column_name = 'passwordUsuarioEnc')
    );
    SET v_has_fechaBaja := (
        SELECT EXISTS(SELECT 1 FROM information_schema.columns 
                       WHERE table_schema = DATABASE() AND table_name = 'usuario' AND column_name = 'fechaBaja')
    );
    SET v_has_uesps := (
        SELECT EXISTS(SELECT 1 FROM information_schema.tables 
                       WHERE table_schema = DATABASE() AND table_name = 'usuario_empresa_sucursal_perfil_sistema')
    );
    -- 1) Identificar usuario por (columna preferida) y/o por nombreUsuarioEnc = MD5(w_usuario)
    SET v_sql := CONCAT('SELECT idUsuario INTO @uid FROM usuario u WHERE (u.', v_user_col, ' = ?');
    IF v_has_userenccol = 1 THEN
        SET v_sql := CONCAT(v_sql, ' OR u.nombreUsuarioEnc = MD5(?)');
    END IF;
    SET v_sql := CONCAT(v_sql, ')');
    -- 2) Validar contraseña si hay columnas
    IF v_has_pw = 1 AND v_has_pwenc = 1 THEN
        SET v_sql := CONCAT(v_sql, ' AND (u.passwordUsuario = ? OR u.passwordUsuarioEnc = MD5(?))');
    ELSEIF v_has_pw = 1 AND v_has_pwenc = 0 THEN
        SET v_sql := CONCAT(v_sql, ' AND (u.passwordUsuario = ?)');
    ELSEIF v_has_pw = 0 AND v_has_pwenc = 1 THEN
        SET v_sql := CONCAT(v_sql, ' AND (u.passwordUsuarioEnc = MD5(?))');
    ELSE
        -- Sin columnas de password: no validamos clave (sólo entornos de migración)
        SET v_sql := CONCAT(v_sql, '');
    END IF;
    SET v_sql := CONCAT(v_sql, ' LIMIT 1');
    -- Ejecutar selección de uid con placeholders
    SET @p1 := w_usuario; -- para user_col = ?
    SET @p2 := w_usuario; -- para nombreUsuarioEnc = MD5(?) si existe
    SET @p3 := w_clave;   -- para passwordUsuario = ?
    SET @p4 := w_clave;   -- para passwordUsuarioEnc = MD5(?)
    IF v_has_userenccol = 1 THEN
        IF v_has_pw = 1 AND v_has_pwenc = 1 THEN
            SET @sql := v_sql; PREPARE stmt FROM @sql; EXECUTE stmt USING @p1, @p2, @p3, @p4; DEALLOCATE PREPARE stmt;
        ELSEIF v_has_pw = 1 AND v_has_pwenc = 0 THEN
            SET @sql := v_sql; PREPARE stmt FROM @sql; EXECUTE stmt USING @p1, @p2, @p3; DEALLOCATE PREPARE stmt;
        ELSEIF v_has_pw = 0 AND v_has_pwenc = 1 THEN
            SET @sql := v_sql; PREPARE stmt FROM @sql; EXECUTE stmt USING @p1, @p2, @p4; DEALLOCATE PREPARE stmt;
        ELSE
            SET @sql := v_sql; PREPARE stmt FROM @sql; EXECUTE stmt USING @p1, @p2; DEALLOCATE PREPARE stmt;
        END IF;
    ELSE
        IF v_has_pw = 1 AND v_has_pwenc = 1 THEN
            SET @sql := v_sql; PREPARE stmt FROM @sql; EXECUTE stmt USING @p1, @p3, @p4; DEALLOCATE PREPARE stmt;
        ELSEIF v_has_pw = 1 AND v_has_pwenc = 0 THEN
            SET @sql := v_sql; PREPARE stmt FROM @sql; EXECUTE stmt USING @p1, @p3; DEALLOCATE PREPARE stmt;
        ELSEIF v_has_pw = 0 AND v_has_pwenc = 1 THEN
            SET @sql := v_sql; PREPARE stmt FROM @sql; EXECUTE stmt USING @p1, @p4; DEALLOCATE PREPARE stmt;
        ELSE
            SET @sql := v_sql; PREPARE stmt FROM @sql; EXECUTE stmt USING @p1; DEALLOCATE PREPARE stmt;
        END IF;
    END IF;
    SET v_uid := @uid;
    -- Usuario inexistente o credenciales incorrectas
    IF v_uid IS NULL OR v_uid = 0 THEN
        SELECT 'El usuario o la contraseña son incorrectos.' AS Msg;
        LEAVE main;
    END IF;
    -- 3) Verificar activo (fechaBaja nula) si la columna existe
    IF v_has_fechaBaja = 1 THEN
        IF (SELECT COUNT(*) FROM usuario WHERE idUsuario = v_uid AND fechaBaja IS NULL) = 0 THEN
            SELECT 'El usuario está inactivo.' AS Msg;
            LEAVE main;
        END IF;
    END IF;
    -- 4) Verificar perfil habilitado SOLO si la tabla existe y tiene datos
    IF v_has_uesps = 1 THEN
        IF (SELECT COUNT(*) FROM usuario_empresa_sucursal_perfil_sistema) > 0 THEN
        SET v_idPerfil := 0; SET v_nombrePerfil := ''; SET v_idEmpresa := 0; SET v_idSucursal := 0; SET v_empresaNombre := ''; SET v_sucursalNombre := '';
        SELECT 
            uesps.idPerfil,
            (SELECT p.nombre FROM perfil p WHERE p.idPerfil = uesps.idPerfil LIMIT 1) AS nombrePerfil,
            uesps.idEmpresa,
            IF(uesps.idEmpresa > 0, (SELECT nombre FROM empresa WHERE idEmpresa = uesps.idEmpresa LIMIT 1), '') AS empresaNombre,
            uesps.idSucursal,
            IF(uesps.idSucursal > 0, (SELECT descripcion FROM sucursal WHERE idSucursal = uesps.idSucursal LIMIT 1), '') AS sucursalNombre
        INTO v_idPerfil, v_nombrePerfil, v_idEmpresa, v_empresaNombre, v_idSucursal, v_sucursalNombre
        FROM usuario_empresa_sucursal_perfil_sistema uesps
        WHERE uesps.idUsuario = v_uid AND uesps.habilitado = 1
        LIMIT 1;
        IF IFNULL(v_idPerfil,0) = 0 THEN
            SELECT 'No tiene perfil habilitado.' AS Msg; 
            LEAVE main;
        END IF;
        END IF;
    END IF;
    -- 5) Éxito: devolver el registro del usuario + metadatos de perfil (si hubieran)
    SELECT 
        'success' AS Msg,
        u.idUsuario AS IdUsuario,
        u.nombre AS Nombre,
        u.nombre AS NombreUsuario,
        u.passwordUsuario AS PasswordUsuario,
        u.tipo AS Tipo,
        u.idCliente AS IdCliente,
        IFNULL(v_idPerfil,0) AS IdPerfil,
        IFNULL(v_nombrePerfil,'') AS NombrePerfil,
        IFNULL(v_idEmpresa,0) AS empresaId,
        IFNULL(v_empresaNombre,'') AS empresaNombre,
        IFNULL(v_idSucursal,0) AS sucursalId,
        IFNULL(v_sucursalNombre,'') AS sucursalNombre
    FROM usuario u
    WHERE u.idUsuario = v_uid
    LIMIT 1;
    END; -- end label main
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_login.old` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_login.old` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login.old`(w_usuario VARCHAR(50), w_clave VARCHAR(50))
BEGIN
    DECLARE seguir INT DEFAULT 0;
    DECLARE existe INT DEFAULT 0;
    DECLARE msg VARCHAR(100) DEFAULT "";
    DECLARE usuarioId BIGINT(20) DEFAULT 0;
    DECLARE IdPerfil BIGINT(20) DEFAULT 0;
    DECLARE NombrePerfil VARCHAR(30) DEFAULT "";
    DECLARE empresaId BIGINT(20) DEFAULT 0;
    DECLARE empresaNombre VARCHAR(100) DEFAULT "";
    DECLARE sucursalId BIGINT(20) DEFAULT 0;
    DECLARE sucursalNombre VARCHAR(100) DEFAULT "";
    START TRANSACTION;
    -- Verificar si existe el usuario
    SET existe = (SELECT COUNT(*) FROM usuario WHERE nombreUsuarioEnc = MD5(w_usuario));
    IF existe = 0 THEN
        SET seguir = 1;
        SET msg = "El usuario no existe.";
    ELSE
        SET usuarioId = (SELECT idUsuario FROM usuario WHERE nombreUsuarioEnc = MD5(w_usuario));
    END IF;
    -- Verificar si la contraseña es correcta
    IF seguir = 0 THEN
        SET existe = (SELECT COUNT(*) FROM usuario WHERE idUsuario = usuarioId AND passwordUsuarioEnc = MD5(w_clave));
        IF existe = 0 THEN
            SET seguir = 1;
            SET msg = "La contraseña es incorrecta.";
        END IF;
    END IF;
    -- Verificar estado
    IF seguir = 0 THEN
        SET existe = (SELECT COUNT(*) FROM usuario WHERE idUsuario = usuarioId AND ISNULL(fechaBaja));
        IF existe = 0 THEN
            SET seguir = 1;
            SET msg = "El usuario está inactivo.";
        END IF;
    END IF;
    -- Verificar perfil habilitado
    IF seguir = 0 THEN
        SELECT
            uesps.idPerfil AS IdPerfil,
            p.nombre AS NombrePerfil,
            uesps.idEmpresa,
            IF(uesps.idEmpresa > 0, (SELECT nombre FROM empresa WHERE idEmpresa = uesps.idEmpresa), '') AS empresaNombre,
            uesps.idSucursal,
            IF(uesps.idSucursal > 0, (SELECT descripcion FROM sucursal WHERE idSucursal = uesps.idSucursal), '') AS sucursalNombre
        INTO
            IdPerfil,
            NombrePerfil,
            empresaId,
            empresaNombre,
            sucursalId,
            sucursalNombre
        FROM
            usuario_empresa_sucursal_perfil_sistema uesps
            JOIN perfil p ON p.idPerfil = uesps.idPerfil
        WHERE
            uesps.idUsuario = usuarioId AND uesps.habilitado = 1
        LIMIT 1;
        IF IdPerfil = 0 THEN
            SET seguir = 1;
            SET msg = "No tiene perfil habilitado.";
        END IF;
    END IF;
    IF seguir = 0 THEN
        SELECT
            "success" AS msg,
            u.idUsuario,
            u.nombre,
            u.nombreUsuario,
            u.passwordUsuario,
            u.tipo,
            u.idCliente,
            IdPerfil,
            NombrePerfil,
            empresaId,
            empresaNombre,
            sucursalId,
            sucursalNombre
        FROM
            usuario u
        WHERE
            u.nombreUsuarioEnc = MD5(w_usuario)
            AND u.passwordUsuarioEnc = MD5(w_clave);
    ELSE
        SELECT msg;
    END IF;
    COMMIT;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_login_hub` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_login_hub` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_login_hub`(w_usuario VARCHAR(50), w_password VARCHAR(50))
BEGIN
	DECLARE seguir INT DEFAULT 0;
	DECLARE existe INT DEFAULT 0;
	DECLARE msg VARCHAR(100) DEFAULT "";
	DECLARE usuarioId BIGINT(20) DEFAULT 0;
	DECLARE perfil VARCHAR(100) DEFAULT "";
	DECLARE perfilId BIGINT(20) DEFAULT 0;
	DECLARE perfilNombre VARCHAR(30) DEFAULT "";
	
	START TRANSACTION;
	
	-- Verificar si existe el usuario
	SET existe = (SELECT COUNT(*) FROM usuario WHERE nombreUsuarioEnc = MD5(w_usuario));
		
	IF existe = 0 THEN
		SET seguir = 1;
		SET msg = "El usuario no existe.";
	ELSE
		SET usuarioId = (SELECT idUsuario FROM usuario WHERE nombreUsuarioEnc = MD5(w_usuario));
	END IF;	
	
	-- Verificar si la contraseña es correcta
	IF seguir = 0 THEN
	
		SET existe = (SELECT COUNT(*) FROM usuario WHERE idUsuario = usuarioId AND passwordUsuarioEnc = MD5(w_password));
		
		IF existe = 0 THEN
		
			SET seguir = 1;
			SET msg = "La contraseña es incorrecta.";
		END IF;
	END IF;	
	
	-- Verificar estado
	IF seguir = 0 THEN
		SET existe = (SELECT COUNT(*) FROM usuario WHERE idUsuario = usuarioId AND ISNULL(fechaBaja));
		
		IF existe = 0 THEN
		
			SET seguir = 1;
			SET msg = "El usuario esta inactivo.";
		END IF;
	END IF;
	
	-- Verificar perfil
	IF seguir = 0 THEN
		SET perfil = fc_get_perfil_sistema_con_sucursal(usuarioId, 0, 0, "CDK_HUB");
		
		SET perfilId = SUBSTRING_INDEX(perfil, ";", 1);
		SET perfilNombre = SUBSTRING_INDEX(SUBSTRING_INDEX(perfil, ";", 2), ";", -1);
		
		IF perfilId = 0 THEN
			SET seguir = 1;
			SET msg = perfilNombre;
		END IF;
	END IF;
	
	IF seguir = 0 THEN
		SELECT
		"success" AS msg,
		u.idUsuario,
		u.nombre,
		u.nombreUsuario,
		u.passwordUsuario,
		u.tipo,
		u.idCliente,
		fc_get_perfil_sistema_con_sucursal(u.idUsuario, 0, 0, "CDK_HUB") 'perfil_datos'
		FROM
		usuario u
		WHERE
		u.nombreUsuarioEnc = MD5(w_usuario)
		AND u.passwordUsuarioEnc = MD5(w_password);		
	ELSE
		SELECT msg;	
	END IF;		
	
	COMMIT;
	END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_departamentos` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_departamentos` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_departamentos`()
BEGIN
  SELECT Id_Departamento, Nombre FROM departamento ORDER BY Nombre;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_detalle_ticket` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_detalle_ticket` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_detalle_ticket`(IN w_Id_Tkt BIGINT)
BEGIN
  SELECT t.Id_Tkt, t.Contenido, t.Date_Creado, t.Date_Cierre,
         u.idUsuario AS U_IdUsuario, u.nombre AS UsuarioNombre,
         ua.idUsuario AS U_IdUsuario_Asignado, ua.nombre AS UsuarioAsignadoNombre,
         d.Nombre AS DepartamentoNombre,
         p.NombrePrioridad AS PrioridadNombre,
         e.TipoEstado AS EstadoNombre,
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

/* Procedure structure for procedure `sp_obtener_estados` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_estados` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_estados`()
BEGIN
  SELECT Id_Estado, TipoEstado FROM estado ORDER BY Id_Estado;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_motivos` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_motivos` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_motivos`()
BEGIN
  SELECT Id_Motivo, Nombre, Categoria FROM motivo ORDER BY Nombre;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_prioridades` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_prioridades` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_prioridades`()
BEGIN
  SELECT Id_Prioridad, NombrePrioridad FROM prioridad ORDER BY Id_Prioridad;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_sucursales` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_sucursales` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_sucursales`()
BEGIN
  SELECT idSucursal, descripcion FROM sucursal ORDER BY descripcion;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_tkt_por_id` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_tkt_por_id` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_tkt_por_id`(IN w_id_tkt BIGINT)
BEGIN
  SELECT t.Id_Tkt, t.Id_Estado, t.Date_Creado, t.Date_Cierre, t.Date_Asignado, t.Date_Cambio_Estado,
         t.Id_Usuario, t.Id_Usuario_Asignado, t.Id_Empresa, t.Id_Perfil, t.Id_Motivo, t.Id_Sucursal,
         t.Habilitado, t.Contenido, t.Id_Prioridad, t.Id_Departamento,
         u.idUsuario AS U_IdUsuario, u.nombre AS Nombre_Usuario,
         d.Id_Departamento AS Id_Departamento, d.Nombre AS Nombre_Departamento,
         p.Id_Prioridad AS Id_Prioridad, p.NombrePrioridad,
         e.Id_Estado AS Id_Estado, e.TipoEstado
    FROM tkt t
    LEFT JOIN usuario u ON u.idUsuario = t.Id_Usuario
    LEFT JOIN departamento d ON d.Id_Departamento = t.Id_Departamento
    LEFT JOIN prioridad p ON p.Id_Prioridad = t.Id_Prioridad
    LEFT JOIN estado e ON e.Id_Estado = t.Id_Estado
   WHERE t.Id_Tkt = w_id_tkt
   LIMIT 1;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_obtener_usuarios` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_obtener_usuarios` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_usuarios`()
BEGIN
  SELECT idUsuario AS Id_Usuario, nombre AS Nombre_Usuario
    FROM usuario
   ORDER BY nombre;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_recuperar_password_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_recuperar_password_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_recuperar_password_usuario`(w_username varchar(50), w_newPassword varchar(50), w_email varchar(50))
BEGIN
	
	DECLARE _existe INT(11) DEFAULT 0;
	DECLARE _id BIGINT(20) DEFAULT 0;
	DECLARE _mensaje VARCHAR(100) DEFAULT "";
	
	START TRANSACTION;
	
	SET _existe = (
		SELECT COUNT(*) FROM usuario WHERE nombreUsuarioEnc = MD5(w_username)
	);
	
	IF _existe = 0 THEN
	
		SET _mensaje = CONCAT("No existe usuario ", w_username, ".");
		
	ELSEIF _existe = 1 THEN
	
		SET _id = (
			SELECT idUsuario FROM usuario WHERE nombreUsuarioEnc = MD5(w_username)
		);
		
		UPDATE usuario
		SET
		email = w_email,
		passwordUsuario = w_newPassword,
		passwordUsuarioEnc = MD5(w_newPassword)
		WHERE
		idUsuario = _id;
	
		SET _mensaje = "success";
	
	ELSE
	
		SET _mensaje = CONCAT("Hay dos o más usuarios con el username ", w_username, ".");
	END IF;
	COMMIT;
	
	SELECT _mensaje;
	
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

/* Procedure structure for procedure `sp_tkt_permiso_crear` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_permiso_crear` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_permiso_crear`(IN w_codigo VARCHAR(50), IN w_desc VARCHAR(200))
BEGIN
  INSERT IGNORE INTO tkt_permiso(codigo, descripcion) VALUES (w_codigo, w_desc);
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_rol_crear` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_rol_crear` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_rol_crear`(IN w_nombre VARCHAR(50), IN w_desc VARCHAR(200))
BEGIN
  INSERT IGNORE INTO tkt_rol(nombre, descripcion) VALUES (w_nombre, w_desc);
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_rol_permiso_asignar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_rol_permiso_asignar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_rol_permiso_asignar`(IN w_nombre_rol VARCHAR(64), IN w_codigo_permiso VARCHAR(64))
BEGIN
  DECLARE v_idRol INT; DECLARE v_idPermiso INT;
  SELECT idRol INTO v_idRol FROM rol WHERE nombre = w_nombre_rol LIMIT 1;
  IF v_idRol IS NULL THEN INSERT INTO rol(nombre) VALUES (w_nombre_rol); SET v_idRol = LAST_INSERT_ID(); END IF;
  SELECT idPermiso INTO v_idPermiso FROM permiso WHERE codigo = w_codigo_permiso LIMIT 1;
  IF v_idPermiso IS NULL THEN INSERT INTO permiso(codigo) VALUES (w_codigo_permiso); SET v_idPermiso = LAST_INSERT_ID(); END IF;
  INSERT IGNORE INTO rol_permiso(idRol,idPermiso) VALUES (v_idRol, v_idPermiso);
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_seed_asignar_roles_usuarios` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_seed_asignar_roles_usuarios` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_seed_asignar_roles_usuarios`()
BEGIN
  DECLARE v_has_EsAdmin TINYINT(1) DEFAULT 0;
  DECLARE v_has_Perfil  TINYINT(1) DEFAULT 0;
  DECLARE v_has_IdPerfil TINYINT(1) DEFAULT 0;
  DECLARE v_has_Id_Perfil TINYINT(1) DEFAULT 0;
  -- Asegurar que roles/permisos existen
  CALL sp_tkt_seed_minima();
  -- Detectar columnas de la tabla usuario
  SELECT EXISTS(
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='usuario' AND COLUMN_NAME='EsAdmin'
  ) INTO v_has_EsAdmin;
  SELECT EXISTS(
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='usuario' AND COLUMN_NAME='Perfil'
  ) INTO v_has_Perfil;
  SELECT EXISTS(
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='usuario' AND COLUMN_NAME='IdPerfil'
  ) INTO v_has_IdPerfil;
  SELECT EXISTS(
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='usuario' AND COLUMN_NAME='Id_Perfil'
  ) INTO v_has_Id_Perfil;
  -- Admin por EsAdmin=1
  IF v_has_EsAdmin = 1 THEN
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol
    FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Administrador'
    WHERE COALESCE(u.EsAdmin,0) = 1;
  END IF;
  -- Mapear por Perfil (texto)
  IF v_has_Perfil = 1 THEN
    -- Administrador
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Administrador'
    WHERE UPPER(TRIM(u.Perfil)) IN ('ADMINISTRADOR','ADMIN');
    -- Supervisor
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Supervisor'
    WHERE UPPER(TRIM(u.Perfil)) IN ('SUPERVISOR');
    -- Operador
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Operador'
    WHERE UPPER(TRIM(u.Perfil)) IN ('OPERADOR','AGENTE');
    -- Consulta
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Consulta'
    WHERE UPPER(TRIM(u.Perfil)) IN ('CONSULTA','CONSULTOR','VIEWER','READONLY');
  END IF;
  -- Mapear por IdPerfil (numérico)
  IF v_has_IdPerfil = 1 THEN
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Administrador'
    WHERE u.IdPerfil = 1;
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Supervisor'
    WHERE u.IdPerfil = 2;
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Operador'
    WHERE u.IdPerfil = 3;
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Consulta'
    WHERE u.IdPerfil = 4;
  END IF;
  -- Mapear por Id_Perfil (numérico, variante)
  IF v_has_Id_Perfil = 1 THEN
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Administrador'
    WHERE u.Id_Perfil = 1;
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Supervisor'
    WHERE u.Id_Perfil = 2;
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Operador'
    WHERE u.Id_Perfil = 3;
    INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
    SELECT u.idUsuario, r.id_rol FROM usuario u
    JOIN tkt_rol r ON r.nombre = 'Consulta'
    WHERE u.Id_Perfil = 4;
  END IF;
  -- Asignar por defecto 'Consulta' a los usuarios sin ningún rol aún
  INSERT IGNORE INTO tkt_usuario_rol (idUsuario, id_rol)
  SELECT u.idUsuario, r.id_rol
  FROM usuario u
  JOIN tkt_rol r ON r.nombre = 'Consulta'
  WHERE NOT EXISTS (SELECT 1 FROM tkt_usuario_rol ur WHERE ur.idUsuario = u.idUsuario);
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_seed_basico` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_seed_basico` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_seed_basico`()
BEGIN
  CALL sp_tkt_rol_crear('Administrador','Acceso total');
  CALL sp_tkt_rol_crear('Supervisor','Supervisa y edita, sin eliminar');
  CALL sp_tkt_rol_crear('Operador','Opera tickets asignados');
  CALL sp_tkt_rol_crear('Consulta','Solo lectura y exportar');
  CALL sp_tkt_permiso_crear('TKT_LIST_ALL','Ver todos los tickets');
  CALL sp_tkt_permiso_crear('TKT_LIST_ASSIGNED','Ver mis asignados');
  CALL sp_tkt_permiso_crear('TKT_VIEW_DETAIL','Ver detalle');
  CALL sp_tkt_permiso_crear('TKT_CREATE','Crear ticket');
  CALL sp_tkt_permiso_crear('TKT_EDIT_ASSIGNED','Editar si soy asignado');
  CALL sp_tkt_permiso_crear('TKT_EDIT_ANY','Editar cualquiera');
  CALL sp_tkt_permiso_crear('TKT_ASSIGN','Asignar tickets');
  CALL sp_tkt_permiso_crear('TKT_CLOSE','Cerrar tickets');
  CALL sp_tkt_permiso_crear('TKT_DELETE','Eliminar tickets');
  CALL sp_tkt_permiso_crear('TKT_EXPORT','Exportar CSV');
  CALL sp_tkt_permiso_crear('TKT_COMMENT','Comentar');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_LIST_ALL');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_LIST_ASSIGNED');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_VIEW_DETAIL');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_CREATE');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_EDIT_ANY');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_EDIT_ASSIGNED');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_ASSIGN');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_CLOSE');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_DELETE');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_EXPORT');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_COMMENT');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_LIST_ALL');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_VIEW_DETAIL');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_EDIT_ANY');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_ASSIGN');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_CLOSE');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_EXPORT');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_COMMENT');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_LIST_ASSIGNED');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_VIEW_DETAIL');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_CREATE');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_EDIT_ASSIGNED');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_CLOSE');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_COMMENT');
  CALL sp_tkt_rol_permiso_asignar('Consulta','TKT_LIST_ALL');
  CALL sp_tkt_rol_permiso_asignar('Consulta','TKT_VIEW_DETAIL');
  CALL sp_tkt_rol_permiso_asignar('Consulta','TKT_EXPORT');
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_seed_minima` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_seed_minima` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_seed_minima`()
BEGIN
  -- Roles
  CALL sp_tkt_rol_crear('Administrador','Acceso total');
  CALL sp_tkt_rol_crear('Supervisor','Supervisa y edita, sin eliminar');
  CALL sp_tkt_rol_crear('Operador','Opera tickets asignados');
  CALL sp_tkt_rol_crear('Consulta','Solo lectura y exportar');
  -- Permisos
  CALL sp_tkt_permiso_crear('TKT_LIST_ALL','Ver todos los tickets');
  CALL sp_tkt_permiso_crear('TKT_LIST_ASSIGNED','Ver mis asignados');
  CALL sp_tkt_permiso_crear('TKT_VIEW_DETAIL','Ver detalle');
  CALL sp_tkt_permiso_crear('TKT_CREATE','Crear ticket');
  CALL sp_tkt_permiso_crear('TKT_EDIT_ASSIGNED','Editar si soy asignado');
  CALL sp_tkt_permiso_crear('TKT_EDIT_ANY','Editar cualquiera');
  CALL sp_tkt_permiso_crear('TKT_ASSIGN','Asignar tickets');
  CALL sp_tkt_permiso_crear('TKT_CLOSE','Cerrar tickets');
  CALL sp_tkt_permiso_crear('TKT_DELETE','Eliminar tickets');
  CALL sp_tkt_permiso_crear('TKT_EXPORT','Exportar CSV');
  CALL sp_tkt_permiso_crear('TKT_COMMENT','Comentar');
  -- Asignación de permisos por rol
  -- Administrador: todos
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_LIST_ALL');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_LIST_ASSIGNED');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_VIEW_DETAIL');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_CREATE');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_EDIT_ANY');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_EDIT_ASSIGNED');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_ASSIGN');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_CLOSE');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_DELETE');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_EXPORT');
  CALL sp_tkt_rol_permiso_asignar('Administrador','TKT_COMMENT');
  -- Supervisor
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_LIST_ALL');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_VIEW_DETAIL');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_EDIT_ANY');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_ASSIGN');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_CLOSE');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_EXPORT');
  CALL sp_tkt_rol_permiso_asignar('Supervisor','TKT_COMMENT');
  -- Operador
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_LIST_ASSIGNED');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_VIEW_DETAIL');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_CREATE');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_EDIT_ASSIGNED');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_CLOSE');
  CALL sp_tkt_rol_permiso_asignar('Operador','TKT_COMMENT');
  -- Consulta
  CALL sp_tkt_rol_permiso_asignar('Consulta','TKT_LIST_ALL');
  CALL sp_tkt_rol_permiso_asignar('Consulta','TKT_VIEW_DETAIL');
  CALL sp_tkt_rol_permiso_asignar('Consulta','TKT_EXPORT');
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
    DECLARE v_estado_from INT;
    DECLARE v_asignado_actual INT;
    DECLARE v_requiere_propietario TINYINT(1);
    DECLARE v_permiso VARCHAR(50);
    DECLARE v_requiere_aprob TINYINT(1);
    DECLARE v_msg VARCHAR(255);
    DECLARE v_meta LONGTEXT;
    
    SET v_meta = p_meta_json;
    
    SELECT Id_Estado, Id_Usuario_Asignado INTO v_estado_from, v_asignado_actual
    FROM tkt WHERE Id_Tkt = p_id_tkt FOR UPDATE;
    
    IF v_estado_from IS NULL THEN
        SELECT 0 success, 'Ticket no encontrado' message, NULL nuevo_estado, NULL id_asignado;
        LEAVE proc;
    END IF;
    
    IF p_comentario IS NULL OR TRIM(p_comentario) = '' THEN
        SELECT 0 success, 'Comentario requerido' message, NULL nuevo_estado, NULL id_asignado;
        LEAVE proc;
    END IF;
    
    SELECT requiere_propietario, permiso_requerido, requiere_aprobacion
      INTO v_requiere_propietario, v_permiso, v_requiere_aprob
    FROM tkt_transicion_regla
    WHERE (estado_from IS NULL OR estado_from = v_estado_from)
      AND estado_to = p_estado_to
    LIMIT 1;
    
    IF v_requiere_propietario IS NULL AND v_permiso IS NULL THEN
        SELECT 0 success, 'Transicion no permitida' message, NULL nuevo_estado, NULL id_asignado;
        LEAVE proc;
    END IF;
    
    -- SUPER ADMIN BYPASS: Si p_es_super_admin = 1, saltar validacion de propietario
    IF v_requiere_propietario = 1 AND p_es_super_admin = 0 THEN
        IF v_asignado_actual IS NULL OR v_asignado_actual <> p_id_usuario_actor THEN
            SELECT 0 success, 'Solo el asignado puede realizar esta transicion' message, NULL nuevo_estado, NULL id_asignado;
            LEAVE proc;
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
           Date_Asignado = IF(p_id_asignado_nuevo IS NOT NULL AND p_id_asignado_nuevo <> v_asignado_actual, NOW(), Date_Asignado)
    WHERE Id_Tkt = p_id_tkt;
    
    INSERT INTO tkt_transicion(id_tkt, estado_from, estado_to, id_usuario_actor, comentario, motivo, meta_json)
    VALUES(p_id_tkt, v_estado_from, p_estado_to, p_id_usuario_actor, p_comentario, p_motivo, v_meta);
    
    SELECT 1 success, 'OK' message, p_estado_to nuevo_estado, v_asignado_actual id_asignado;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_tkt_usuario_rol_asignar` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_tkt_usuario_rol_asignar` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tkt_usuario_rol_asignar`(IN w_idUsuario BIGINT, IN w_nombre_rol VARCHAR(64))
BEGIN
  DECLARE v_idRol INT;
  SELECT idRol INTO v_idRol FROM rol WHERE nombre = w_nombre_rol LIMIT 1;
  IF v_idRol IS NULL THEN INSERT INTO rol(nombre) VALUES (w_nombre_rol); SET v_idRol = LAST_INSERT_ID(); END IF;
  INSERT IGNORE INTO usuario_rol(idUsuario,idRol) VALUES (w_idUsuario, v_idRol);
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_traer_usuario` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_traer_usuario` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`%` PROCEDURE `sp_traer_usuario`(w_id bigint(20))
BEGIN
	
	start transaction;
	
	select
	*
	from
	usuario
	where
	idUsuario = w_id;
	
	commit;
	
	END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
