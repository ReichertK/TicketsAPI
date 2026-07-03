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
-- Table structure for table `bancos_depositos`
--

DROP TABLE IF EXISTS `bancos_depositos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bancos_depositos` (
  `deposito_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dep_fecha` date DEFAULT NULL,
  `dep_notas` char(254) DEFAULT NULL,
  `cuenta_id` bigint(10) DEFAULT '0',
  `dep_carga` datetime DEFAULT NULL,
  `dep_anulado` datetime DEFAULT NULL,
  PRIMARY KEY (`deposito_id`),
  KEY `fecha` (`dep_fecha`),
  KEY `cuenta` (`cuenta_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bancos_depositos`
--

LOCK TABLES `bancos_depositos` WRITE;
/*!40000 ALTER TABLE `bancos_depositos` DISABLE KEYS */;
/*!40000 ALTER TABLE `bancos_depositos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bancos_sucursales`
--

DROP TABLE IF EXISTS `bancos_sucursales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bancos_sucursales` (
  `bco_id` int(11) NOT NULL AUTO_INCREMENT,
  `bco_descripcion` char(30) DEFAULT NULL,
  `bco_clearing` int(11) DEFAULT NULL,
  `bco_web` char(20) DEFAULT NULL,
  `bco_habil` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`bco_id`),
  UNIQUE KEY `bco_id` (`bco_id`),
  UNIQUE KEY `Alter_Key1` (`bco_id`),
  UNIQUE KEY `idx_bc_001` (`bco_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bancos_sucursales`
--

LOCK TABLES `bancos_sucursales` WRITE;
/*!40000 ALTER TABLE `bancos_sucursales` DISABLE KEYS */;
/*!40000 ALTER TABLE `bancos_sucursales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja_cheques`
--

DROP TABLE IF EXISTS `caja_cheques`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja_cheques` (
  `chq_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cuenta_id` int(4) NOT NULL COMMENT 'si es 9999 es chq de terceros',
  `empre_id` int(4) NOT NULL DEFAULT '1',
  `MOV_ID` bigint(20) DEFAULT NULL,
  `mov_fecha` date DEFAULT NULL,
  `STK_CHQ_NRO` varchar(20) NOT NULL,
  `stk_chq_femisin` date DEFAULT NULL,
  `stk_chq_fvto` date DEFAULT NULL,
  `stk_chq_clearing` int(3) DEFAULT NULL,
  `stk_chq_importe` decimal(10,2) DEFAULT '0.00',
  `cuit` varchar(11) DEFAULT NULL,
  `stk_chq_nombre_apagar` varchar(40) DEFAULT NULL,
  `stk_chq_fAlta` datetime DEFAULT NULL,
  `stk_chq_anulado` date DEFAULT NULL,
  `stk_chq_fdeposito` date DEFAULT NULL,
  `stk_chq_fcambio` date DEFAULT NULL COMMENT 'fecha que se cambio el cheque en mesa',
  `Usuario_id_alta` bigint(10) DEFAULT NULL,
  `Usuario_id_baja` bigint(10) DEFAULT NULL,
  UNIQUE KEY `Id_cheques` (`chq_id`),
  UNIQUE KEY `NRO_CHEQUE` (`STK_CHQ_NRO`,`cuenta_id`),
  KEY `id_egreso` (`MOV_ID`),
  KEY `id_banco` (`cuenta_id`),
  KEY `cuit` (`cuit`),
  KEY `empresa` (`empre_id`),
  CONSTRAINT `caja_cheques_ibfk_1` FOREIGN KEY (`cuenta_id`) REFERENCES `caja_cuentas` (`cuenta_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja_cheques`
--

LOCK TABLES `caja_cheques` WRITE;
/*!40000 ALTER TABLE `caja_cheques` DISABLE KEYS */;
/*!40000 ALTER TABLE `caja_cheques` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja_compensaciones`
--

DROP TABLE IF EXISTS `caja_compensaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja_compensaciones` (
  `empresa_id` int(4) DEFAULT '1',
  `mov_id` bigint(20) NOT NULL,
  `compen_tipo` int(3) unsigned NOT NULL DEFAULT '0',
  `compen_importe` decimal(12,2) DEFAULT NULL,
  `compen_fbaja` date DEFAULT NULL,
  `compen_falta` date DEFAULT NULL,
  KEY `compen_tipo` (`compen_tipo`),
  KEY `empresa_id` (`empresa_id`),
  KEY `mov_id` (`mov_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja_compensaciones`
--

LOCK TABLES `caja_compensaciones` WRITE;
/*!40000 ALTER TABLE `caja_compensaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `caja_compensaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja_cuentas`
--

DROP TABLE IF EXISTS `caja_cuentas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja_cuentas` (
  `empre_id` int(4) DEFAULT NULL,
  `cuenta_id` int(4) NOT NULL AUTO_INCREMENT,
  `tipo_cta_id` bigint(10) DEFAULT '5',
  `bco_id` varchar(11) NOT NULL,
  `cta_sucursal` varchar(30) DEFAULT NULL,
  `cta_cuit` varchar(13) DEFAULT NULL,
  `cta_nombres` varchar(30) NOT NULL,
  `cta_numero` varchar(20) DEFAULT NULL,
  `cta_cbu` varchar(27) DEFAULT NULL,
  `cta_domomicilio` varchar(60) DEFAULT NULL,
  `cta_tel_contacto` varchar(80) DEFAULT NULL,
  `cta_falta` datetime DEFAULT NULL,
  `cta_fbaja` datetime DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`cuenta_id`),
  KEY `empre` (`empre_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja_cuentas`
--

LOCK TABLES `caja_cuentas` WRITE;
/*!40000 ALTER TABLE `caja_cuentas` DISABLE KEYS */;
/*!40000 ALTER TABLE `caja_cuentas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja_tarjetas`
--

DROP TABLE IF EXISTS `caja_tarjetas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja_tarjetas` (
  `tarj_id` int(11) NOT NULL,
  `tarj_descripcion` char(30) DEFAULT NULL,
  `tarj_abrev` char(10) DEFAULT NULL,
  `tar_deb_cred` varchar(1) DEFAULT 'C',
  `tarj_titular` varchar(30) DEFAULT NULL,
  `tarj_vencimiento` varchar(6) DEFAULT NULL,
  `tarj_numero` varchar(20) DEFAULT NULL,
  `tarj_obser` varchar(40) DEFAULT NULL,
  `tar_habil` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`tarj_id`),
  UNIQUE KEY `tarj_id` (`tarj_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja_tarjetas`
--

LOCK TABLES `caja_tarjetas` WRITE;
/*!40000 ALTER TABLE `caja_tarjetas` DISABLE KEYS */;
/*!40000 ALTER TABLE `caja_tarjetas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cajas`
--

DROP TABLE IF EXISTS `cajas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cajas` (
  `empre_id` int(4) DEFAULT '1',
  `sucursal_id` int(11) NOT NULL,
  `caja_id` int(11) NOT NULL AUTO_INCREMENT,
  `caja_descripcion` varchar(20) DEFAULT NULL,
  `caja_ult_cierre` datetime DEFAULT NULL,
  `caja_central` tinyint(1) DEFAULT '0',
  `caja_habil` tinyint(1) DEFAULT '1',
  `caja_fcarga` datetime DEFAULT NULL,
  PRIMARY KEY (`caja_id`,`sucursal_id`),
  UNIQUE KEY `caja_id` (`caja_id`),
  KEY `sucursal_id` (`sucursal_id`),
  KEY `empre` (`empre_id`),
  CONSTRAINT `cajas_ibfk_1` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursales` (`sucursal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cajas`
--

LOCK TABLES `cajas` WRITE;
/*!40000 ALTER TABLE `cajas` DISABLE KEYS */;
/*!40000 ALTER TABLE `cajas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `centros_costos`
--

DROP TABLE IF EXISTS `centros_costos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `centros_costos` (
  `CD_id` int(5) NOT NULL AUTO_INCREMENT,
  `Empresa_id` int(3) NOT NULL DEFAULT '1',
  `CD_numero` int(5) NOT NULL,
  `CD_descripcion` varchar(30) NOT NULL,
  `CD_habilitado` int(1) DEFAULT '0' COMMENT '0- habilitado , 1 -deshabilitado',
  PRIMARY KEY (`CD_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `centros_costos`
--

LOCK TABLES `centros_costos` WRITE;
/*!40000 ALTER TABLE `centros_costos` DISABLE KEYS */;
/*!40000 ALTER TABLE `centros_costos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `certificados_retenciones`
--

DROP TABLE IF EXISTS `certificados_retenciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `certificados_retenciones` (
  `cert_id` int(3) NOT NULL AUTO_INCREMENT,
  `cert_descripcion` varchar(30) NOT NULL,
  `cert_abreviatura` varchar(6) NOT NULL,
  `cert_numera` bigint(10) NOT NULL DEFAULT '0' COMMENT 'ultimo numero del certificado',
  `cert_minimo_imponible` decimal(15,2) DEFAULT '0.00',
  `cert_alicuota` decimal(6,2) DEFAULT '0.00',
  `cert_vigencia` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cert_id`),
  KEY `descripcion` (`cert_descripcion`),
  KEY `id_fecha` (`cert_id`,`cert_vigencia`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificados_retenciones`
--

LOCK TABLES `certificados_retenciones` WRITE;
/*!40000 ALTER TABLE `certificados_retenciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `certificados_retenciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cierres_caja`
--

DROP TABLE IF EXISTS `cierres_caja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cierres_caja` (
  `ccaja_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ccaja_periodo` varchar(6) DEFAULT NULL,
  `ccaja_fecha_inicio` date DEFAULT NULL,
  `ccaja_imppesos` decimal(12,2) DEFAULT '0.00',
  `ccaja_impdolares` decimal(12,2) DEFAULT '0.00',
  `ccaja_chq_terceros` decimal(12,2) DEFAULT '0.00',
  `ccaja_chq_propios` decimal(12,2) DEFAULT '0.00',
  `ccaja_cantidad` int(11) DEFAULT '0',
  `caja_id` int(11) NOT NULL,
  `sucursal_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `ccaja_fecha_cierre` date DEFAULT NULL,
  `ccaja_fecha_proceso` date DEFAULT NULL,
  `ccaja_hora` varchar(8) DEFAULT NULL,
  `ccaja_imppesos_fin` decimal(12,2) DEFAULT '0.00',
  `ccaja_impdolares_fin` decimal(12,2) DEFAULT '0.00',
  `ccaja_chq_terceros_fin` decimal(12,2) DEFAULT '0.00',
  `ccaja_chq_propios_fin` decimal(12,2) DEFAULT '0.00',
  KEY `ccaja_id` (`ccaja_id`),
  KEY `periodo` (`ccaja_periodo`),
  KEY `caja_suc` (`sucursal_id`,`caja_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cierres_caja`
--

LOCK TABLES `cierres_caja` WRITE;
/*!40000 ALTER TABLE `cierres_caja` DISABLE KEYS */;
/*!40000 ALTER TABLE `cierres_caja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cierres_caja_detalle`
--

DROP TABLE IF EXISTS `cierres_caja_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cierres_caja_detalle` (
  `ccaja_id` bigint(20) NOT NULL,
  `conc_tipo` int(1) DEFAULT '0' COMMENT '0 ingreso 1 Egreso',
  `concepto_id` int(11) DEFAULT NULL,
  `ccajad_imppesos` decimal(12,2) DEFAULT '0.00',
  `ccajad_impdolares` decimal(12,2) DEFAULT '0.00',
  `ccajad_impchqt` decimal(12,2) DEFAULT NULL,
  `ccajad_impchqp` decimal(12,2) DEFAULT NULL,
  `ccajad_plan_cta` varchar(10) DEFAULT NULL,
  `ejercicio_id` int(4) DEFAULT NULL,
  KEY `ccaja_id` (`ccaja_id`),
  KEY `indconc` (`concepto_id`),
  CONSTRAINT `cierres_caja_detalle_ibfk_1` FOREIGN KEY (`ccaja_id`) REFERENCES `cierres_caja` (`ccaja_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cierres_caja_detalle`
--

LOCK TABLES `cierres_caja_detalle` WRITE;
/*!40000 ALTER TABLE `cierres_caja_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `cierres_caja_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clientes` (
  `cli_cuit` char(11) NOT NULL COMMENT 'cuit cliente',
  `cli_nombre` char(40) DEFAULT NULL COMMENT 'nombre de fantasia',
  `cli_razsoc` char(30) DEFAULT NULL COMMENT 'nombre legal',
  `cli_domicilio` char(60) DEFAULT NULL COMMENT 'direccion',
  `cli_telefono` char(60) DEFAULT NULL COMMENT 'telefono',
  `cli_movil` char(60) DEFAULT NULL COMMENT 'celular o moviles',
  `cli_cod_radio` char(20) DEFAULT NULL COMMENT 'codigo de radio',
  `cli_email` char(80) DEFAULT NULL COMMENT 'email de constacto',
  `bco_id` int(11) DEFAULT '66' COMMENT 'id tablas bcos',
  `tipo_cta_id` int(2) DEFAULT '5' COMMENT 'id tipo de cta.',
  `cli_cta_banco` char(60) DEFAULT NULL COMMENT 'nro de cuenta',
  `tiva_id` int(11) NOT NULL DEFAULT '1' COMMENT 'id tipo de iva',
  `cli_nro_iibb` char(11) NOT NULL DEFAULT '0',
  `usuario_id` int(11) DEFAULT NULL,
  `cli_falta` date DEFAULT NULL,
  `cli_fbaja` date DEFAULT NULL,
  `cli_datos_contacto` varchar(254) DEFAULT NULL,
  `cli_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cli_lleva_cta` int(1) NOT NULL DEFAULT '0' COMMENT 'si lleva cta cte / 0 - no lleva ctacte / 1 - lleva ctacte',
  PRIMARY KEY (`cli_cuit`,`tiva_id`),
  UNIQUE KEY `cuit` (`cli_cuit`),
  KEY `idx_cuit` (`cli_cuit`),
  KEY `idx_nombre` (`cli_nombre`),
  KEY `idx_razsoc` (`cli_razsoc`),
  KEY `tiva_id` (`tiva_id`),
  KEY `bancos` (`bco_id`),
  KEY `tipos_ctas` (`tipo_cta_id`),
  KEY `cli_id` (`cli_id`),
  KEY `IDX_LLEVACTA` (`cli_lleva_cta`),
  CONSTRAINT `bancos` FOREIGN KEY (`bco_id`) REFERENCES `bancos_sucursales` (`bco_id`),
  CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`tiva_id`) REFERENCES `tipos_iva` (`tiva_id`),
  CONSTRAINT `tipos_ctas` FOREIGN KEY (`tipo_cta_id`) REFERENCES `tipos_cuentas` (`tipo_cta_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compras`
--

DROP TABLE IF EXISTS `compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compras` (
  `id_sucursal` int(10) DEFAULT NULL,
  `id_caja` int(10) DEFAULT NULL,
  `comp_expediente` varchar(10) DEFAULT NULL,
  `id_compras` bigint(20) NOT NULL AUTO_INCREMENT,
  `cuit` varchar(11) NOT NULL,
  `tcomp_id` int(5) NOT NULL,
  `comp_fechacpbte` date NOT NULL,
  `comp_nrocpbte` varchar(20) NOT NULL,
  `prov_razsocial` varchar(130) NOT NULL,
  `prov_pagadero` varchar(130) NOT NULL,
  `comp_dias` int(3) DEFAULT NULL,
  `comp_vto` date DEFAULT NULL,
  `tiva_id` int(2) NOT NULL DEFAULT '1',
  `comp_anulado` datetime DEFAULT NULL,
  `usu_id` int(11) DEFAULT NULL,
  `comp_iva21` double(12,2) DEFAULT NULL,
  `comp_iva105` double(12,2) DEFAULT '0.00',
  `comp_iva_diferencial` double(10,2) DEFAULT '0.00',
  `comp_percep_iva` double(12,2) DEFAULT NULL,
  `comp_percep_iibb` double(12,2) DEFAULT NULL,
  `comp_reten_iibb` double(12,2) DEFAULT NULL,
  `comp_reten_ganancias` double(12,2) DEFAULT NULL,
  `comp_varios` double(12,2) DEFAULT NULL,
  `comp_bruto` double(12,2) NOT NULL,
  `comp_total` double(12,2) NOT NULL,
  `mmot_id` int(11) DEFAULT NULL,
  `CD_numero` int(5) DEFAULT '1' COMMENT 'Costo Departamental',
  `comp_detalle` varchar(254) DEFAULT NULL,
  `comp_fcarga` datetime NOT NULL COMMENT 'fecha de carga',
  `comp_fbaja` date DEFAULT NULL COMMENT 'fecha de baja',
  `comp_periodo` varchar(6) DEFAULT NULL COMMENT 'periodo de liq de impuestos',
  `comp_fprocesado` datetime DEFAULT NULL COMMENT 'fecha de proceso de liq. impuestos',
  `mov_fecha` date DEFAULT NULL COMMENT 'fecha de pago',
  `mov_id` bigint(20) DEFAULT NULL COMMENT 'id de movimiento de egreso',
  `id_egreso` bigint(20) DEFAULT NULL,
  `ejercicio_id` int(4) DEFAULT NULL COMMENT 'id de ejercicio economico',
  `empresa_id` int(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_compras`),
  UNIQUE KEY `comprobante` (`cuit`,`tcomp_id`,`comp_nrocpbte`,`comp_total`,`empresa_id`),
  KEY `tipo_comprobante` (`tcomp_id`),
  KEY `mov_id` (`mov_id`),
  KEY `id_sucursal` (`id_sucursal`),
  KEY `id_caja` (`id_caja`),
  KEY `id_egreso` (`id_egreso`),
  KEY `expediente` (`comp_expediente`),
  KEY `mmot_id` (`mmot_id`),
  KEY `costoD` (`CD_numero`),
  KEY `fk_ejercicio` (`ejercicio_id`),
  KEY `empresa` (`empresa_id`),
  CONSTRAINT `cuit` FOREIGN KEY (`cuit`) REFERENCES `proveedores` (`cuit`),
  CONSTRAINT `empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`empre_id`),
  CONSTRAINT `fk_ejercicio` FOREIGN KEY (`ejercicio_id`) REFERENCES `ejercicios` (`ejercicio_id`),
  CONSTRAINT `tipo_comprobante` FOREIGN KEY (`tcomp_id`) REFERENCES `tipos_comprobantes` (`tcomp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compras`
--

LOCK TABLES `compras` WRITE;
/*!40000 ALTER TABLE `compras` DISABLE KEYS */;
/*!40000 ALTER TABLE `compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compras_conceptos`
--

DROP TABLE IF EXISTS `compras_conceptos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compras_conceptos` (
  `id_compras` bigint(20) NOT NULL,
  `comp_iva21` double(12,2) DEFAULT NULL,
  `comp_iva105` double(12,2) DEFAULT NULL,
  `comp_percep_iva` double(12,2) DEFAULT NULL,
  `comp_percep_iibb` double(12,2) DEFAULT NULL,
  `comp_reten_iibb` double(12,2) DEFAULT NULL,
  `comp_reten_ganacias` double(12,2) DEFAULT NULL,
  `comp_varios` double(12,2) DEFAULT NULL,
  `comp_bruto` double(12,2) DEFAULT NULL,
  `comp_total` double(12,2) DEFAULT NULL,
  `comp_periodo` varchar(6) DEFAULT NULL,
  `comp_fprocesado` datetime DEFAULT NULL,
  `comp_anulado` int(1) DEFAULT NULL,
  KEY `id_compras` (`id_compras`),
  CONSTRAINT `compras_conceptos_ibfk_1` FOREIGN KEY (`id_compras`) REFERENCES `compras` (`id_compras`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compras_conceptos`
--

LOCK TABLES `compras_conceptos` WRITE;
/*!40000 ALTER TABLE `compras_conceptos` DISABLE KEYS */;
/*!40000 ALTER TABLE `compras_conceptos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compras_periodos_liquidados`
--

DROP TABLE IF EXISTS `compras_periodos_liquidados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compras_periodos_liquidados` (
  `ejercicio_id` int(4) NOT NULL DEFAULT '1',
  `empre_id` int(4) DEFAULT '1',
  `Periodo` varchar(6) NOT NULL,
  `comp_fproceso` datetime NOT NULL,
  PRIMARY KEY (`Periodo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compras_periodos_liquidados`
--

LOCK TABLES `compras_periodos_liquidados` WRITE;
/*!40000 ALTER TABLE `compras_periodos_liquidados` DISABLE KEYS */;
/*!40000 ALTER TABLE `compras_periodos_liquidados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conceptos_movimientos`
--

DROP TABLE IF EXISTS `conceptos_movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conceptos_movimientos` (
  `empre_id` int(4) NOT NULL DEFAULT '1',
  `concepto_id` bigint(10) NOT NULL AUTO_INCREMENT,
  `conc_descripcion` varchar(40) DEFAULT NULL,
  `conc_tipo` smallint(1) DEFAULT '0' COMMENT '0-ingreso , 1-egreso',
  `conc_categoria` int(3) DEFAULT '100' COMMENT '100 caja central - 110 cajas chicas',
  `conc_habilitado` smallint(1) DEFAULT '0' COMMENT '0- habilitado 1- deshabil',
  `conc_falta` date DEFAULT NULL,
  `usuario_id` bigint(10) DEFAULT NULL,
  PRIMARY KEY (`concepto_id`),
  KEY `usuario` (`usuario_id`),
  KEY `empre_id` (`empre_id`),
  CONSTRAINT `empre` FOREIGN KEY (`empre_id`) REFERENCES `empresas` (`empre_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conceptos_movimientos`
--

LOCK TABLES `conceptos_movimientos` WRITE;
/*!40000 ALTER TABLE `conceptos_movimientos` DISABLE KEYS */;
/*!40000 ALTER TABLE `conceptos_movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `costo_departamental`
--

DROP TABLE IF EXISTS `costo_departamental`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `costo_departamental` (
  `CD_id` int(5) NOT NULL AUTO_INCREMENT,
  `Empresa_id` int(3) NOT NULL DEFAULT '1',
  `CD_numero` int(5) NOT NULL,
  `CD_descripcion` varchar(30) NOT NULL,
  `CD_habilitado` int(1) DEFAULT '0' COMMENT '0- habilitado , 1 -deshabilitado',
  PRIMARY KEY (`CD_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `costo_departamental`
--

LOCK TABLES `costo_departamental` WRITE;
/*!40000 ALTER TABLE `costo_departamental` DISABLE KEYS */;
/*!40000 ALTER TABLE `costo_departamental` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ctacte_ajustes`
--

DROP TABLE IF EXISTS `ctacte_ajustes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ctacte_ajustes` (
  `id_ajuste` bigint(20) NOT NULL AUTO_INCREMENT,
  `cuit` varchar(13) DEFAULT NULL,
  `ajuste_debe` decimal(14,2) DEFAULT NULL,
  `ajuste_haber` decimal(14,2) DEFAULT NULL,
  `ajuste_concepto` varchar(150) DEFAULT NULL,
  `ajuste_fecha` date NOT NULL,
  `ajuste_anulacion` date DEFAULT NULL,
  PRIMARY KEY (`id_ajuste`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ctacte_ajustes`
--

LOCK TABLES `ctacte_ajustes` WRITE;
/*!40000 ALTER TABLE `ctacte_ajustes` DISABLE KEYS */;
/*!40000 ALTER TABLE `ctacte_ajustes` ENABLE KEYS */;
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
-- Table structure for table `deptos_contables`
--

DROP TABLE IF EXISTS `deptos_contables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deptos_contables` (
  `empre_id` int(4) NOT NULL,
  `depto_id` bigint(10) NOT NULL AUTO_INCREMENT,
  `depto_nombre` varchar(30) DEFAULT NULL,
  `depto_habilitado` int(1) DEFAULT '0',
  PRIMARY KEY (`empre_id`,`depto_id`),
  KEY `depto_id` (`depto_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deptos_contables`
--

LOCK TABLES `deptos_contables` WRITE;
/*!40000 ALTER TABLE `deptos_contables` DISABLE KEYS */;
/*!40000 ALTER TABLE `deptos_contables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ejercicios`
--

DROP TABLE IF EXISTS `ejercicios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ejercicios` (
  `ejercicio_id` int(3) NOT NULL AUTO_INCREMENT COMMENT 'id interno de registro',
  `ejercicio_nro` int(3) DEFAULT NULL COMMENT 'nro de ejercicio',
  `empresa_id` int(4) DEFAULT NULL COMMENT 'nro de empresa',
  `ejer_fdesde` date DEFAULT NULL COMMENT 'fecha de inicio del ejercico',
  `ejer_fhasta` date DEFAULT NULL COMMENT 'fecha final del ejercicio',
  `ejer_fecha_alta` datetime DEFAULT NULL COMMENT 'fecha y hora sistemico que se generara el ejercicio',
  `ejer_fecha_cierre` datetime DEFAULT NULL COMMENT 'fecha y hora que se realiza el cierre sistemico del ejercicio',
  PRIMARY KEY (`ejercicio_id`),
  KEY `ejer_empresa` (`ejercicio_nro`,`empresa_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ejercicios`
--

LOCK TABLES `ejercicios` WRITE;
/*!40000 ALTER TABLE `ejercicios` DISABLE KEYS */;
/*!40000 ALTER TABLE `ejercicios` ENABLE KEYS */;
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
-- Table structure for table `empresas`
--

DROP TABLE IF EXISTS `empresas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `empresas` (
  `empre_id` int(4) NOT NULL AUTO_INCREMENT,
  `CUIT` varchar(11) NOT NULL,
  `empre_razon_social` varchar(30) DEFAULT NULL,
  `empre_habilitar` int(1) DEFAULT '0' COMMENT '0-ESTA HABILITADO 1-DESHABILITADO',
  PRIMARY KEY (`empre_id`),
  KEY `cuit` (`CUIT`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empresas`
--

LOCK TABLES `empresas` WRITE;
/*!40000 ALTER TABLE `empresas` DISABLE KEYS */;
/*!40000 ALTER TABLE `empresas` ENABLE KEYS */;
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
-- Table structure for table `facturas_cli`
--

DROP TABLE IF EXISTS `facturas_cli`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `facturas_cli` (
  `factura_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `FECHA_COMP` date DEFAULT NULL,
  `TIPO_COMP` char(2) DEFAULT NULL,
  `CONT_FISCA` char(1) DEFAULT NULL,
  `PTO_VTA` char(4) DEFAULT NULL,
  `NRO_CPBTE` char(8) DEFAULT NULL,
  `NROC_REGIS` char(8) DEFAULT NULL,
  `NRO_PAG` char(3) DEFAULT NULL,
  `COD_DOC` char(2) DEFAULT NULL,
  `NRO_DOC` char(11) DEFAULT NULL,
  `NOMBRE` char(30) DEFAULT NULL,
  `IMP_TOTAL` decimal(15,2) DEFAULT NULL,
  `IMP_NOGRAV` decimal(15,2) DEFAULT NULL,
  `IMP_NETG` decimal(15,2) DEFAULT NULL,
  `IMP_IMPLIQ` decimal(15,2) DEFAULT NULL,
  `IMP_RNI` decimal(15,2) DEFAULT NULL,
  `IMP_OPEXEN` decimal(15,2) DEFAULT NULL,
  `IMP_PERCEP` decimal(15,2) DEFAULT NULL,
  `IMP_PERIIB` decimal(15,2) DEFAULT NULL,
  `IMP_PEMUNI` decimal(15,2) DEFAULT NULL,
  `IMP_IMPINT` decimal(15,2) DEFAULT NULL,
  `IMP_TRANSP` decimal(15,2) DEFAULT NULL,
  `TIP_RESPON` char(2) DEFAULT NULL,
  `TIP_MONEDA` char(3) DEFAULT NULL,
  `TIP_CAMBIO` char(10) DEFAULT NULL,
  `CNT_ALIIVA` char(1) DEFAULT NULL,
  `COD_OPERA` char(1) DEFAULT NULL,
  `COD_AUTCP` char(14) DEFAULT NULL,
  `COMP_VTO` date DEFAULT NULL,
  `COMP_ANUL` date DEFAULT NULL,
  `ejercicio_id` int(4) DEFAULT NULL,
  PRIMARY KEY (`factura_id`),
  UNIQUE KEY `ind000` (`FECHA_COMP`,`PTO_VTA`,`NRO_CPBTE`),
  KEY `indcuit` (`NRO_DOC`),
  KEY `indnombre` (`NOMBRE`),
  KEY `indcod_autor` (`COD_AUTCP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facturas_cli`
--

LOCK TABLES `facturas_cli` WRITE;
/*!40000 ALTER TABLE `facturas_cli` DISABLE KEYS */;
/*!40000 ALTER TABLE `facturas_cli` ENABLE KEYS */;
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
-- Table structure for table `formas_pago`
--

DROP TABLE IF EXISTS `formas_pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `formas_pago` (
  `tfpago_id` int(11) NOT NULL AUTO_INCREMENT,
  `tfpago_descripcion` char(30) DEFAULT NULL,
  `tfpago_abrev` char(6) DEFAULT NULL,
  `tfpago_cpo1` varchar(20) DEFAULT NULL,
  `tfpago_cpo2` varchar(20) DEFAULT NULL,
  `tfpago_cpo3` varchar(20) DEFAULT NULL COMMENT 'tipo de comprobante',
  `tfpago_tipo` int(1) NOT NULL DEFAULT '3' COMMENT 'tipo 1=pagos 2=cobranzas 3=ambos',
  `tfpago_habil` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`tfpago_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `formas_pago`
--

LOCK TABLES `formas_pago` WRITE;
/*!40000 ALTER TABLE `formas_pago` DISABLE KEYS */;
/*!40000 ALTER TABLE `formas_pago` ENABLE KEYS */;
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
-- Table structure for table `menues`
--

DROP TABLE IF EXISTS `menues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menues` (
  `menu_id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_descripcion` char(20) DEFAULT NULL,
  `menu_habil` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menues`
--

LOCK TABLES `menues` WRITE;
/*!40000 ALTER TABLE `menues` DISABLE KEYS */;
/*!40000 ALTER TABLE `menues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menues_permisos`
--

DROP TABLE IF EXISTS `menues_permisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menues_permisos` (
  `perfil_id` int(11) NOT NULL,
  `permiso_id` int(11) NOT NULL,
  `perm_habil` tinyint(1) DEFAULT '0',
  `menu_id` int(11) NOT NULL,
  PRIMARY KEY (`perfil_id`,`permiso_id`,`menu_id`),
  KEY `permiso_id` (`permiso_id`),
  KEY `menu_id` (`menu_id`),
  CONSTRAINT `menues_permisos_ibfk_1` FOREIGN KEY (`perfil_id`) REFERENCES `perfiles_usuarios` (`perfil_id`),
  CONSTRAINT `menues_permisos_ibfk_2` FOREIGN KEY (`permiso_id`) REFERENCES `permisos_menu` (`permiso_id`),
  CONSTRAINT `menues_permisos_ibfk_3` FOREIGN KEY (`menu_id`) REFERENCES `menues` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menues_permisos`
--

LOCK TABLES `menues_permisos` WRITE;
/*!40000 ALTER TABLE `menues_permisos` DISABLE KEYS */;
/*!40000 ALTER TABLE `menues_permisos` ENABLE KEYS */;
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
-- Table structure for table `motivos_movimientos`
--

DROP TABLE IF EXISTS `motivos_movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `motivos_movimientos` (
  `empre_id` int(4) NOT NULL DEFAULT '1',
  `mmot_id` int(11) NOT NULL,
  `mmot_descripcion` varchar(80) DEFAULT NULL,
  `mmot_cpo1` varchar(20) DEFAULT NULL,
  `mmot_cpo2` varchar(20) DEFAULT NULL,
  `mmot_cpo3` varchar(20) DEFAULT NULL,
  `mmot_abrev` varchar(4) DEFAULT NULL,
  `mmot_tipo` char(1) DEFAULT NULL COMMENT 'i= ingreso , e= egreso',
  `mmot_habil` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`mmot_id`,`empre_id`),
  UNIQUE KEY `mmot_id` (`mmot_id`,`empre_id`),
  KEY `empre` (`empre_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `motivos_movimientos`
--

LOCK TABLES `motivos_movimientos` WRITE;
/*!40000 ALTER TABLE `motivos_movimientos` DISABLE KEYS */;
/*!40000 ALTER TABLE `motivos_movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mov_caja_det_cpbte`
--

DROP TABLE IF EXISTS `mov_caja_det_cpbte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mov_caja_det_cpbte` (
  `mov_id` bigint(20) NOT NULL,
  `tcomp_id` int(11) NOT NULL,
  `cuit` varchar(11) DEFAULT NULL,
  `mov_nro_cprte` varchar(12) DEFAULT NULL,
  `mov_fecha_cpte` date DEFAULT NULL,
  `mov_cpbte_importe` decimal(16,2) DEFAULT NULL,
  `mov_importe_cobrado` decimal(13,2) DEFAULT NULL,
  `mov_importe_dif` decimal(13,2) DEFAULT NULL,
  `proc_lote` varchar(20) DEFAULT NULL,
  UNIQUE KEY `nrocpbte` (`tcomp_id`,`cuit`,`mov_nro_cprte`,`mov_fecha_cpte`),
  KEY `cuit` (`cuit`),
  KEY `MOVID` (`mov_id`),
  CONSTRAINT `mov_caja_det_cpbte_ibfk_1` FOREIGN KEY (`mov_id`) REFERENCES `movcaja` (`mov_id`),
  CONSTRAINT `mov_caja_det_cpbte_ibfk_2` FOREIGN KEY (`tcomp_id`) REFERENCES `tipos_comprobantes` (`tcomp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mov_caja_det_cpbte`
--

LOCK TABLES `mov_caja_det_cpbte` WRITE;
/*!40000 ALTER TABLE `mov_caja_det_cpbte` DISABLE KEYS */;
/*!40000 ALTER TABLE `mov_caja_det_cpbte` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mov_caja_fpagos`
--

DROP TABLE IF EXISTS `mov_caja_fpagos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mov_caja_fpagos` (
  `tfpago_id` int(11) NOT NULL,
  `mov_id` bigint(20) NOT NULL,
  `tfpago_importe` decimal(15,2) DEFAULT NULL,
  PRIMARY KEY (`tfpago_id`,`mov_id`),
  KEY `mov_id` (`mov_id`),
  CONSTRAINT `mov_caja_fpagos_ibfk_1` FOREIGN KEY (`tfpago_id`) REFERENCES `formas_pago` (`tfpago_id`),
  CONSTRAINT `mov_caja_fpagos_ibfk_2` FOREIGN KEY (`mov_id`) REFERENCES `movcaja` (`mov_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mov_caja_fpagos`
--

LOCK TABLES `mov_caja_fpagos` WRITE;
/*!40000 ALTER TABLE `mov_caja_fpagos` DISABLE KEYS */;
/*!40000 ALTER TABLE `mov_caja_fpagos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mov_cheques_terceros`
--

DROP TABLE IF EXISTS `mov_cheques_terceros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mov_cheques_terceros` (
  `chqt_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `empre_id` int(4) DEFAULT '1',
  `mov_id` bigint(20) NOT NULL DEFAULT '0' COMMENT 'MOV_ID DE COBRANZAS POR DONDE INGRESO',
  `id_egreso` bigint(20) DEFAULT '0' COMMENT 'MOV_ID DE SALIDA PAGO U DEPOSITO',
  `id_ingreso` bigint(20) DEFAULT '0',
  `chqt_femisin` date DEFAULT NULL,
  `chqt_fvto` date DEFAULT NULL,
  `chqt_clearing` int(3) DEFAULT '48',
  `chqt_importe` decimal(10,2) DEFAULT NULL,
  `bco_id` int(11) NOT NULL,
  `chqt_nro` varchar(20) DEFAULT NULL,
  `chqt_cta_nom` varchar(50) DEFAULT NULL,
  `chqt_cta_nro` varchar(20) DEFAULT NULL,
  `chqt_cta_cuit` varchar(15) DEFAULT NULL,
  `chqt_cta_dom_pago` varchar(50) DEFAULT NULL,
  `chqt_anulado` date DEFAULT NULL,
  `deposito_id` bigint(20) DEFAULT '0',
  `chqt_fdeposito` date DEFAULT NULL,
  `chqt_cambio` date DEFAULT NULL,
  `chqt_entregado` date DEFAULT NULL,
  PRIMARY KEY (`chqt_id`),
  KEY `bcoid_nro` (`bco_id`,`chqt_nro`),
  KEY `movid` (`mov_id`),
  KEY `idingreso` (`id_egreso`),
  KEY `idegreso` (`id_egreso`),
  CONSTRAINT `mov_cheques_terceros_ibfk_2` FOREIGN KEY (`bco_id`) REFERENCES `bancos_sucursales` (`bco_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mov_cheques_terceros`
--

LOCK TABLES `mov_cheques_terceros` WRITE;
/*!40000 ALTER TABLE `mov_cheques_terceros` DISABLE KEYS */;
/*!40000 ALTER TABLE `mov_cheques_terceros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mov_tarjetas`
--

DROP TABLE IF EXISTS `mov_tarjetas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mov_tarjetas` (
  `tarj_id` int(11) NOT NULL,
  `mov_id` bigint(20) NOT NULL,
  `mov_tarj_numero` char(20) DEFAULT NULL,
  `mov_tarj_seguridad` varchar(4) DEFAULT NULL,
  `mov_tarj_vto` varchar(4) DEFAULT NULL,
  `mov_tarj_titular` char(20) DEFAULT NULL,
  `mov_importe` decimal(10,2) DEFAULT NULL,
  `mov_tarj_autor` varchar(20) DEFAULT NULL,
  `mov_tarj_tk_posnet` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`tarj_id`,`mov_id`),
  KEY `mov_id` (`mov_id`),
  KEY `tarjeta` (`tarj_id`),
  CONSTRAINT `mov_tarjetas_ibfk_1` FOREIGN KEY (`tarj_id`) REFERENCES `caja_tarjetas` (`tarj_id`),
  CONSTRAINT `mov_tarjetas_ibfk_2` FOREIGN KEY (`mov_id`) REFERENCES `movcaja` (`mov_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mov_tarjetas`
--

LOCK TABLES `mov_tarjetas` WRITE;
/*!40000 ALTER TABLE `mov_tarjetas` DISABLE KEYS */;
/*!40000 ALTER TABLE `mov_tarjetas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movcaja`
--

DROP TABLE IF EXISTS `movcaja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movcaja` (
  `mov_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `mov_idtipo` smallint(1) NOT NULL COMMENT '0-ingreso 1-Egreso',
  `cuit` char(11) NOT NULL COMMENT '999- agrup impr facturas // 888- gastos',
  `mmot_id` int(11) NOT NULL DEFAULT '9999999',
  `concepto_id` bigint(10) DEFAULT NULL,
  `mov_fecha` date DEFAULT NULL,
  `mov_periodo` varchar(6) DEFAULT NULL,
  `mov_importe_total` decimal(14,2) DEFAULT '0.00',
  `mov_importe_bruto` decimal(12,2) NOT NULL DEFAULT '0.00',
  `mov_imp_impuestos` decimal(10,2) DEFAULT '0.00',
  `mov_imp_dolares` decimal(10,2) DEFAULT '0.00',
  `mov_imp_pesos` decimal(10,2) DEFAULT '0.00',
  `mov_soloefvo` int(1) DEFAULT '0' COMMENT '0-solo efvo , 1-no solo efvo',
  `tcomp_id` int(11) DEFAULT '0',
  `mov_nro_cpbte` varchar(20) DEFAULT NULL,
  `mov_detalle` varchar(250) DEFAULT NULL,
  `proc_lote` varchar(20) DEFAULT '0',
  `caja_id` int(11) NOT NULL,
  `sucursal_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `mov_fcreacion` datetime DEFAULT NULL,
  `mov_observa` varchar(250) DEFAULT NULL,
  `cierre_id` bigint(20) DEFAULT '0' COMMENT 'id de cabecera de las cajas de las sucursales',
  `ccaja_id` bigint(20) DEFAULT '0',
  `MOV_ANULACION` datetime DEFAULT NULL,
  `ejercicio_id` int(4) DEFAULT NULL,
  `empresa_id` int(4) DEFAULT '1',
  PRIMARY KEY (`mov_id`,`mov_importe_bruto`),
  KEY `cuit` (`cuit`),
  KEY `usuario_id` (`usuario_id`),
  KEY `caja_id` (`caja_id`,`sucursal_id`),
  KEY `movcaja_ibfk_6` (`mmot_id`),
  KEY `ind_Sucursal` (`sucursal_id`,`mov_fecha`),
  KEY `lote` (`proc_lote`),
  KEY `concepto` (`concepto_id`),
  KEY `conc_fecha` (`concepto_id`,`mov_fecha`),
  KEY `conc_periodo` (`concepto_id`,`mov_periodo`),
  KEY `tcomp` (`tcomp_id`),
  KEY `comprobante` (`tcomp_id`,`mov_nro_cpbte`),
  KEY `id_cierre` (`ccaja_id`),
  CONSTRAINT `movcaja_concep` FOREIGN KEY (`concepto_id`) REFERENCES `conceptos_movimientos` (`concepto_id`),
  CONSTRAINT `movcaja_ibfk_3` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`),
  CONSTRAINT `movcaja_ibfk_4` FOREIGN KEY (`caja_id`, `sucursal_id`) REFERENCES `cajas` (`caja_id`, `sucursal_id`),
  CONSTRAINT `movcaja_ibfk_5` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursales` (`sucursal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movcaja`
--

LOCK TABLES `movcaja` WRITE;
/*!40000 ALTER TABLE `movcaja` DISABLE KEYS */;
/*!40000 ALTER TABLE `movcaja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movcaja_cabecera`
--

DROP TABLE IF EXISTS `movcaja_cabecera`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movcaja_cabecera` (
  `id_cabecera_movcaja` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id de cabecera',
  `caja_id` int(11) NOT NULL DEFAULT '0' COMMENT 'nro de caja de la tabla cajas',
  `movcab_apertura` datetime DEFAULT NULL COMMENT 'fecha y hora de la creacion de la cabecera',
  `movcab_cierre` datetime DEFAULT NULL COMMENT 'fecha y hora del cierre de la caja',
  `movcab_ingresos` double(14,2) DEFAULT '0.00' COMMENT 'total ingresos',
  `movcab_egresos` double(14,2) DEFAULT '0.00' COMMENT 'total egresos',
  `movcab_total` double(14,2) DEFAULT '0.00' COMMENT 'total de cierre de la cabecera',
  `id_usuario` int(11) DEFAULT NULL COMMENT 'usuario de creacion de la cabecera',
  `movcab_total_pausado` double(14,2) DEFAULT '0.00' COMMENT 'total de subcierre',
  `movcab_cnt_movimientos` int(7) DEFAULT '0' COMMENT 'cantidad de movimentos de subcierre',
  `movcab_estado` int(1) DEFAULT '0' COMMENT '0 Abierto - 1 pausado',
  `saini_monto` double(12,2) DEFAULT '0.00' COMMENT 'monto saldo inicial (si tiene) tabla movcaja_saldo_inicial',
  PRIMARY KEY (`id_cabecera_movcaja`,`caja_id`),
  KEY `ind_usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movcaja_cabecera`
--

LOCK TABLES `movcaja_cabecera` WRITE;
/*!40000 ALTER TABLE `movcaja_cabecera` DISABLE KEYS */;
/*!40000 ALTER TABLE `movcaja_cabecera` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movcaja_cheques`
--

DROP TABLE IF EXISTS `movcaja_cheques`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movcaja_cheques` (
  `movcaja_chq_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `movcaja_ID` bigint(20) NOT NULL DEFAULT '0' COMMENT 'movcaja_id (movcaja_detalles)',
  `STK_CHQ_NRO` varchar(20) NOT NULL COMMENT 'numero del cheque',
  `stk_chq_femision` date NOT NULL COMMENT 'fecha de emision del cheque',
  `stk_chq_fvto` date DEFAULT NULL COMMENT 'fecha de vencimiento (fecha emision mas 30 dias)',
  `stk_chq_clearing` int(3) NOT NULL DEFAULT '48' COMMENT 'tiempo que tardan en acreditar el cheque (24, 48, 72, 96 hrs)',
  `stk_chq_importe` decimal(10,2) DEFAULT '0.00' COMMENT 'importe del cheque',
  `bco_id` int(11) DEFAULT '0' COMMENT 'id banco',
  `chq_cta_nom` varchar(50) DEFAULT NULL COMMENT 'Titular de la Cta.',
  `chq_cta_nro` varchar(20) DEFAULT NULL COMMENT 'Cuenta Nro.',
  `chq_cta_cuit` varchar(15) DEFAULT NULL COMMENT 'CUIT librador',
  `chq_cta_dom_pago` varchar(50) DEFAULT NULL COMMENT 'sucursal de pago , ej: “Irigoyen 324 - Lanus”',
  UNIQUE KEY `Id_cheques` (`movcaja_chq_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movcaja_cheques`
--

LOCK TABLES `movcaja_cheques` WRITE;
/*!40000 ALTER TABLE `movcaja_cheques` DISABLE KEYS */;
/*!40000 ALTER TABLE `movcaja_cheques` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movcaja_detalles`
--

DROP TABLE IF EXISTS `movcaja_detalles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movcaja_detalles` (
  `movcaja_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `caja_id` int(11) NOT NULL DEFAULT '0' COMMENT 'id caja (cajas)',
  `mov_idtipo` smallint(1) NOT NULL DEFAULT '0' COMMENT '0-ingreso 1-Egreso',
  `movcaja_feccarga` datetime NOT NULL COMMENT 'fecha de carga del movimiento',
  `concepto_id` bigint(10) NOT NULL DEFAULT '0' COMMENT 'id concepto (conceptos_movimientos)',
  `tcomp_id` int(11) NOT NULL DEFAULT '0' COMMENT 'tipo de comprobante interviniente (tipos_comprobantes)',
  `movcaja_nro_cpbte` char(14) DEFAULT NULL COMMENT 'nro de comprobante',
  `CUIT` char(11) DEFAULT NULL COMMENT 'CUIT / CUIL',
  `tdoc_id` int(3) DEFAULT '0' COMMENT 'tipo de docuemnto en caso de no CUIT/CUIL',
  `nro_doc` char(10) DEFAULT NULL COMMENT 'nro de doc',
  `movcaja_Nombre` char(50) DEFAULT NULL COMMENT 'nombre de la entidad que realiza el movimiento',
  `movcaja_bruto_bruto` double(12,2) DEFAULT '0.00' COMMENT 'monto bruto',
  `movcaja_bruto_iva21` double(12,2) DEFAULT '0.00' COMMENT 'bruto sobre el cual se aplica iva21',
  `movcaja_bruto_iva105` double(12,2) DEFAULT '0.00' COMMENT 'bruto sobre el cual se aplica iva 10,5',
  `movcaja_bruto_iibb` double(12,2) DEFAULT '0.00' COMMENT 'bruto sobre el cual se aplica IIBB',
  `movcaja_iva21` double(12,2) DEFAULT '0.00' COMMENT '% IVA 21',
  `movcaja_iva105` double(12,2) DEFAULT '0.00' COMMENT '% IVA 10,5',
  `movcaja_iibb` double(12,2) DEFAULT '0.00' COMMENT '% IIBB (3,5)',
  `movcaja_percepciones` double(12,2) DEFAULT '0.00' COMMENT 'Percepciones',
  `movcaja_imp_no_gravado` double(12,2) DEFAULT '0.00' COMMENT 'importe no gravado',
  `movcaja_total` double(13,2) DEFAULT '0.00' COMMENT 'total de movimientos',
  `movcaja_fecha_anulado` datetime DEFAULT NULL COMMENT 'fecha anulacion del movimiento',
  `id_usuario_llave` int(11) DEFAULT '0' COMMENT 'llave autorizadora del movimiento',
  `movcaja_fhora_llave` datetime DEFAULT NULL COMMENT 'fecha y hora de la autorizacion',
  `Id_usuario` int(11) DEFAULT '0' COMMENT 'id de usuario de la carga',
  `id_cabecera_movcaja` bigint(20) DEFAULT '0' COMMENT 'id cabecera (movcaja_cabecera)',
  PRIMARY KEY (`movcaja_id`,`caja_id`),
  KEY `ind_caja` (`caja_id`),
  KEY `ind_concepto` (`concepto_id`),
  KEY `ind_tcomp` (`tcomp_id`),
  KEY `ind_usuario` (`Id_usuario`),
  KEY `ind_usu_llave` (`id_usuario_llave`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movcaja_detalles`
--

LOCK TABLES `movcaja_detalles` WRITE;
/*!40000 ALTER TABLE `movcaja_detalles` DISABLE KEYS */;
/*!40000 ALTER TABLE `movcaja_detalles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movcaja_saldo_inicial`
--

DROP TABLE IF EXISTS `movcaja_saldo_inicial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movcaja_saldo_inicial` (
  `saini_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id saldo inicial',
  `caja_id` int(11) DEFAULT '0' COMMENT 'id caja',
  `id_cabecera_movcaja_egr` bigint(20) DEFAULT '0' COMMENT 'id movcaja_cabecera egreso',
  `saini_monto` double(12,2) DEFAULT '0.00' COMMENT 'monto para saldo inicial proxima apertura',
  `saini_fecha_uso` datetime DEFAULT NULL COMMENT 'fecha y hora utilizado',
  `id_cabecera_movcaja_ing` bigint(20) DEFAULT '0' COMMENT 'id movcaja_cabecera ingreso',
  PRIMARY KEY (`saini_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movcaja_saldo_inicial`
--

LOCK TABLES `movcaja_saldo_inicial` WRITE;
/*!40000 ALTER TABLE `movcaja_saldo_inicial` DISABLE KEYS */;
/*!40000 ALTER TABLE `movcaja_saldo_inicial` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimientos_rubros`
--

DROP TABLE IF EXISTS `movimientos_rubros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movimientos_rubros` (
  `EMPRE_ID` int(4) NOT NULL,
  `rubro_id` int(4) NOT NULL AUTO_INCREMENT,
  `rubro_descripcion` varchar(30) DEFAULT NULL,
  `rubro_habilitado` int(1) DEFAULT '0' COMMENT '0=habilitado . 1 = deshabilitado',
  PRIMARY KEY (`rubro_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimientos_rubros`
--

LOCK TABLES `movimientos_rubros` WRITE;
/*!40000 ALTER TABLE `movimientos_rubros` DISABLE KEYS */;
/*!40000 ALTER TABLE `movimientos_rubros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notas_deb_creditos`
--

DROP TABLE IF EXISTS `notas_deb_creditos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notas_deb_creditos` (
  `empre_id` int(2) DEFAULT NULL COMMENT 'nro de empresa',
  `notadc_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id propio autoincremental',
  `mov_id` bigint(20) DEFAULT NULL COMMENT 'id de movimeinto de caja',
  `tcomp_id` int(4) DEFAULT NULL COMMENT 'codigo de comprobante que (NC o ND)',
  `id_compras` bigint(20) DEFAULT NULL COMMENT 'id de comprobante compras',
  `id_ventas` bigint(20) DEFAULT NULL COMMENT 'id de comprobante ventas',
  `notadc_numero` varchar(14) DEFAULT NULL COMMENT 'nro comprobante AFIP o interno',
  `notadc_importe` double(14,2) DEFAULT NULL COMMENT 'importe Debito/credito',
  `notadc_falta` date DEFAULT NULL,
  `notadc_fbaja` date DEFAULT NULL,
  PRIMARY KEY (`notadc_id`),
  KEY `empresa` (`empre_id`),
  KEY `movimiento` (`mov_id`),
  KEY `compras` (`id_compras`),
  KEY `ventas` (`id_ventas`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notas_deb_creditos`
--

LOCK TABLES `notas_deb_creditos` WRITE;
/*!40000 ALTER TABLE `notas_deb_creditos` DISABLE KEYS */;
/*!40000 ALTER TABLE `notas_deb_creditos` ENABLE KEYS */;
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
-- Table structure for table `numerador_compras`
--

DROP TABLE IF EXISTS `numerador_compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `numerador_compras` (
  `empre_id` int(4) NOT NULL DEFAULT '1',
  `Periodo` varchar(4) NOT NULL,
  `numero` bigint(6) DEFAULT NULL,
  `cierre_periodo` datetime DEFAULT NULL,
  PRIMARY KEY (`Periodo`,`empre_id`),
  KEY `empre` (`empre_id`),
  CONSTRAINT `fk_empre` FOREIGN KEY (`empre_id`) REFERENCES `empresas` (`empre_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `numerador_compras`
--

LOCK TABLES `numerador_compras` WRITE;
/*!40000 ALTER TABLE `numerador_compras` DISABLE KEYS */;
/*!40000 ALTER TABLE `numerador_compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `numeradores`
--

DROP TABLE IF EXISTS `numeradores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `numeradores` (
  `empre_id` int(4) NOT NULL DEFAULT '1',
  `tcomp_id` int(11) NOT NULL,
  `num_detalle` varchar(20) DEFAULT NULL,
  `num_valor` bigint(20) DEFAULT '0',
  `num_paso` int(2) DEFAULT '1',
  `num_habil` int(1) DEFAULT '0',
  `num_lock` int(1) DEFAULT '0',
  PRIMARY KEY (`empre_id`,`tcomp_id`),
  KEY `tcomp` (`tcomp_id`),
  KEY `empresa` (`empre_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `numeradores`
--

LOCK TABLES `numeradores` WRITE;
/*!40000 ALTER TABLE `numeradores` DISABLE KEYS */;
/*!40000 ALTER TABLE `numeradores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `opciones_menu`
--

DROP TABLE IF EXISTS `opciones_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opciones_menu` (
  `prog_id` int(11) NOT NULL AUTO_INCREMENT,
  `prog_descripcion` varchar(30) DEFAULT NULL,
  `prog_habilitado` int(1) DEFAULT '0',
  PRIMARY KEY (`prog_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `opciones_menu`
--

LOCK TABLES `opciones_menu` WRITE;
/*!40000 ALTER TABLE `opciones_menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `opciones_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ordenes_pago`
--

DROP TABLE IF EXISTS `ordenes_pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ordenes_pago` (
  `Ordenp_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `ordenp_nro` varchar(10) DEFAULT NULL COMMENT 'aamm-99999',
  `empresa_id` int(4) NOT NULL,
  `cuit` varchar(13) NOT NULL,
  `id_compras` bigint(20) NOT NULL,
  `Ordenp_pagar` decimal(14,2) DEFAULT '0.00',
  `ordenp_estado` varchar(4) DEFAULT NULL,
  `MOV_ID` bigint(20) NOT NULL,
  PRIMARY KEY (`Ordenp_ID`),
  KEY `empresa_id` (`empresa_id`),
  CONSTRAINT `ordenes_pago_ibfk_1` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`empre_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordenes_pago`
--

LOCK TABLES `ordenes_pago` WRITE;
/*!40000 ALTER TABLE `ordenes_pago` DISABLE KEYS */;
/*!40000 ALTER TABLE `ordenes_pago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parciales_comprobantes`
--

DROP TABLE IF EXISTS `parciales_comprobantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parciales_comprobantes` (
  `parciales_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `id_compras` bigint(20) NOT NULL DEFAULT '0',
  `id_venta` bigint(20) NOT NULL DEFAULT '0',
  `mov_id` bigint(20) NOT NULL DEFAULT '0',
  `parc_importe_pago` double(14,2) DEFAULT '0.00',
  `parc_importe_saldo` double(14,2) DEFAULT '0.00',
  `parc_anulado` date DEFAULT NULL,
  PRIMARY KEY (`parciales_id`),
  KEY `compras` (`id_compras`),
  KEY `ventas` (`id_venta`),
  KEY `movimiento` (`mov_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parciales_comprobantes`
--

LOCK TABLES `parciales_comprobantes` WRITE;
/*!40000 ALTER TABLE `parciales_comprobantes` DISABLE KEYS */;
/*!40000 ALTER TABLE `parciales_comprobantes` ENABLE KEYS */;
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
-- Table structure for table `perfiles_usuarios`
--

DROP TABLE IF EXISTS `perfiles_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `perfiles_usuarios` (
  `perfil_id` int(11) NOT NULL,
  `perf_nombre` varchar(30) DEFAULT NULL,
  `perf_habil` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`perfil_id`),
  UNIQUE KEY `perfil_id` (`perfil_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfiles_usuarios`
--

LOCK TABLES `perfiles_usuarios` WRITE;
/*!40000 ALTER TABLE `perfiles_usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `perfiles_usuarios` ENABLE KEYS */;
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
-- Table structure for table `permisos_menu`
--

DROP TABLE IF EXISTS `permisos_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permisos_menu` (
  `permiso_id` int(11) NOT NULL AUTO_INCREMENT,
  `perfil_id` int(11) NOT NULL,
  `prog_id` int(11) NOT NULL,
  `perm_descrip` varchar(30) DEFAULT NULL,
  `perm_falta` date DEFAULT NULL,
  `perm_fbaja` date DEFAULT NULL,
  PRIMARY KEY (`permiso_id`),
  UNIQUE KEY `permiso_id` (`permiso_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permisos_menu`
--

LOCK TABLES `permisos_menu` WRITE;
/*!40000 ALTER TABLE `permisos_menu` DISABLE KEYS */;
/*!40000 ALTER TABLE `permisos_menu` ENABLE KEYS */;
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
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedores` (
  `cuit` char(11) NOT NULL,
  `prov_nombre` char(80) DEFAULT NULL,
  `prov_razsocial` char(130) DEFAULT NULL,
  `prov_pagadero` varchar(130) DEFAULT NULL,
  `prov_direccion` char(60) DEFAULT NULL,
  `prov_telefono` char(30) DEFAULT NULL,
  `prov_movil` char(20) DEFAULT NULL,
  `prov_cod_radio` char(20) DEFAULT NULL,
  `prov_email` char(60) DEFAULT NULL,
  `prov_cbu` char(30) DEFAULT NULL,
  `prov_iibb` char(13) DEFAULT NULL,
  `bco_id` int(11) NOT NULL DEFAULT '66',
  `tipo_cta_id` int(5) DEFAULT '5',
  `prov_nro_cta` varchar(30) DEFAULT NULL,
  `tiva_id` int(2) NOT NULL,
  `prov_tiene_ctacte` int(1) DEFAULT '0' COMMENT '0 si lleva cta cte / 1 no lleva cta cte',
  `PROV_CONTACTO` varchar(254) DEFAULT NULL,
  `prov_dias` int(3) DEFAULT '0',
  `id_rubro` int(4) NOT NULL DEFAULT '0',
  `prov_fbaja` date DEFAULT NULL,
  `prov_falta` date DEFAULT NULL,
  `prov_id` bigint(10) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`cuit`,`tiva_id`,`prov_id`),
  UNIQUE KEY `cuit` (`cuit`),
  UNIQUE KEY `idx_cuit` (`cuit`),
  KEY `idx_nombre` (`prov_nombre`),
  KEY `idx_razsoc` (`prov_razsocial`),
  KEY `tiva_id` (`tiva_id`),
  KEY `prov_id` (`prov_id`),
  CONSTRAINT `proveedores_ibfk_1` FOREIGN KEY (`tiva_id`) REFERENCES `tipos_iva` (`tiva_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relacion_comp_pagos`
--

DROP TABLE IF EXISTS `relacion_comp_pagos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relacion_comp_pagos` (
  `id_compras` bigint(20) unsigned NOT NULL,
  `mov_id` bigint(20) unsigned NOT NULL,
  `fecha_aplicacion` date DEFAULT NULL,
  `rel_importe` decimal(15,2) NOT NULL,
  KEY `id_compras` (`id_compras`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relacion_comp_pagos`
--

LOCK TABLES `relacion_comp_pagos` WRITE;
/*!40000 ALTER TABLE `relacion_comp_pagos` DISABLE KEYS */;
/*!40000 ALTER TABLE `relacion_comp_pagos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `relacion_comprobante_procesos`
--

DROP TABLE IF EXISTS `relacion_comprobante_procesos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relacion_comprobante_procesos` (
  `relacion_id` int(5) NOT NULL AUTO_INCREMENT,
  `empresa_id` int(4) NOT NULL DEFAULT '1',
  `tcomp_id` bigint(20) unsigned NOT NULL,
  `proceso` varchar(4) NOT NULL,
  `relacion_habil` int(1) NOT NULL DEFAULT '0' COMMENT '0-habilitado / 1-No habil',
  `relacion_detalle` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`relacion_id`),
  KEY `TIPOCPBTE` (`tcomp_id`),
  KEY `TIPOPROC` (`proceso`),
  KEY `EMPRESA` (`empresa_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `relacion_comprobante_procesos`
--

LOCK TABLES `relacion_comprobante_procesos` WRITE;
/*!40000 ALTER TABLE `relacion_comprobante_procesos` DISABLE KEYS */;
/*!40000 ALTER TABLE `relacion_comprobante_procesos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `retenciones`
--

DROP TABLE IF EXISTS `retenciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `retenciones` (
  `retencion_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tcomp_id` int(11) NOT NULL,
  `reten_nombre` varchar(30) DEFAULT NULL,
  `reten_imp_areten` double(14,2) NOT NULL,
  `reten_alicuota` double(5,2) NOT NULL,
  `reten_fecha` date NOT NULL,
  `id_compras` bigint(20) DEFAULT NULL,
  `id_venta` bigint(20) DEFAULT NULL,
  `reten_retenido` double(14,2) NOT NULL,
  `reten_certificado` varchar(20) NOT NULL,
  `mov_id` bigint(20) DEFAULT NULL,
  `reten_fbaja` date DEFAULT NULL,
  `reten_falta` date DEFAULT NULL,
  PRIMARY KEY (`retencion_id`),
  KEY `tipocomp` (`tcomp_id`),
  KEY `movid` (`mov_id`),
  KEY `id_compras` (`id_compras`),
  KEY `id_venta` (`id_venta`),
  CONSTRAINT `retenciones_ibfk_3` FOREIGN KEY (`tcomp_id`) REFERENCES `tipos_comprobantes` (`tcomp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `retenciones`
--

LOCK TABLES `retenciones` WRITE;
/*!40000 ALTER TABLE `retenciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `retenciones` ENABLE KEYS */;
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
-- Table structure for table `rubros`
--

DROP TABLE IF EXISTS `rubros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rubros` (
  `empresa_id` int(4) NOT NULL DEFAULT '1',
  `rubro_tipo` varchar(2) NOT NULL DEFAULT 'PR',
  `rubro_codigo` int(3) NOT NULL,
  `rubro_descripcion` varchar(40) NOT NULL,
  `rubro_habilitado` int(1) DEFAULT '0' COMMENT '0- habilitado 1-deshabilitado'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rubros`
--

LOCK TABLES `rubros` WRITE;
/*!40000 ALTER TABLE `rubros` DISABLE KEYS */;
/*!40000 ALTER TABLE `rubros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rubros_temp`
--

DROP TABLE IF EXISTS `rubros_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rubros_temp` (
  `empresa_id` int(4) NOT NULL DEFAULT '1',
  `rubro_tipo` varchar(2) NOT NULL DEFAULT 'PR' COMMENT 'PR es proveedor',
  `rubro_codigo` int(3) NOT NULL,
  `rubro_descripcion` varchar(40) NOT NULL,
  `rubro_habilitado` int(1) DEFAULT '0' COMMENT '0- habilitado 1-deshabilitado'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rubros_temp`
--

LOCK TABLES `rubros_temp` WRITE;
/*!40000 ALTER TABLE `rubros_temp` DISABLE KEYS */;
/*!40000 ALTER TABLE `rubros_temp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `saldos_ctasctes`
--

DROP TABLE IF EXISTS `saldos_ctasctes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `saldos_ctasctes` (
  `cuit` char(11) NOT NULL,
  `empre_id` int(4) NOT NULL DEFAULT '1',
  `ejercicio_id` int(4) NOT NULL DEFAULT '1',
  `sal_fecha_aplic` date DEFAULT NULL,
  `sal_importe` decimal(16,2) DEFAULT NULL,
  `Sal_ejerc_anulado` date DEFAULT NULL,
  `sal_ejerc_cerrado` date DEFAULT NULL,
  `sal_fechora_carga` datetime DEFAULT NULL,
  `usuario_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`cuit`,`empre_id`,`ejercicio_id`),
  KEY `cuit` (`cuit`),
  KEY `usuario_id` (`usuario_id`),
  KEY `ejecicio_id` (`ejercicio_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `saldos_ctasctes`
--

LOCK TABLES `saldos_ctasctes` WRITE;
/*!40000 ALTER TABLE `saldos_ctasctes` DISABLE KEYS */;
/*!40000 ALTER TABLE `saldos_ctasctes` ENABLE KEYS */;
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
  `refresh_token_hash` varchar(512) COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_token_hash` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_inicio` datetime DEFAULT NULL,
  `fecha_vencimiento` datetime DEFAULT NULL,
  `ip_address` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activa` tinyint(1) DEFAULT '1',
  `fecha_cierre` datetime DEFAULT NULL,
  PRIMARY KEY (`id_sesion`),
  KEY `idx_sesiones_usuario_activa` (`id_usuario`,`activa`),
  KEY `idx_sesiones_token_fecha` (`fecha_vencimiento`,`activa`),
  KEY `idx_sesiones_ip` (`ip_address`,`fecha_inicio`),
  CONSTRAINT `sesiones_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`idUsuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
-- Table structure for table `sucursales`
--

DROP TABLE IF EXISTS `sucursales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sucursales` (
  `empre_id` int(4) NOT NULL DEFAULT '1',
  `sucursal_id` int(11) NOT NULL AUTO_INCREMENT,
  `sucur_descripcion` varchar(20) NOT NULL,
  `sucur_codigo` varchar(6) DEFAULT NULL,
  `sucur_domicilio` varchar(50) DEFAULT NULL,
  `sucur_telefono` varchar(60) DEFAULT NULL,
  `sucur_email` varchar(60) DEFAULT NULL,
  `sucur_afip` varchar(4) NOT NULL DEFAULT '1000',
  PRIMARY KEY (`empre_id`,`sucursal_id`),
  UNIQUE KEY `sucursal_id` (`sucursal_id`),
  KEY `suc_afip` (`sucur_afip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sucursales`
--

LOCK TABLES `sucursales` WRITE;
/*!40000 ALTER TABLE `sucursales` DISABLE KEYS */;
/*!40000 ALTER TABLE `sucursales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipos_comprobantes`
--

DROP TABLE IF EXISTS `tipos_comprobantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tipos_comprobantes` (
  `tcomp_id` int(11) NOT NULL AUTO_INCREMENT,
  `tcomp_descripcion` varchar(20) DEFAULT NULL,
  `tcomp_cpo1` char(20) DEFAULT NULL,
  `tcomp_cpo2` char(20) DEFAULT NULL,
  `tcomp_cpo3` char(20) DEFAULT NULL,
  `tcomp_afip` int(3) DEFAULT NULL,
  `tcomp_abrev` varchar(6) DEFAULT NULL,
  `tcomp_habil` tinyint(1) DEFAULT '1',
  `tcomp_numera` tinyint(1) NOT NULL DEFAULT '0',
  `tcomp_signo` int(2) DEFAULT '1',
  PRIMARY KEY (`tcomp_id`),
  UNIQUE KEY `tcomp_id` (`tcomp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipos_comprobantes`
--

LOCK TABLES `tipos_comprobantes` WRITE;
/*!40000 ALTER TABLE `tipos_comprobantes` DISABLE KEYS */;
/*!40000 ALTER TABLE `tipos_comprobantes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipos_cuentas`
--

DROP TABLE IF EXISTS `tipos_cuentas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tipos_cuentas` (
  `tipo_cta_id` int(2) NOT NULL AUTO_INCREMENT,
  `tcta_descripcion` varchar(20) DEFAULT NULL,
  `tcta_abrevido` varchar(6) DEFAULT NULL,
  `tcta_habil` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`tipo_cta_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipos_cuentas`
--

LOCK TABLES `tipos_cuentas` WRITE;
/*!40000 ALTER TABLE `tipos_cuentas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tipos_cuentas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipos_doc`
--

DROP TABLE IF EXISTS `tipos_doc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tipos_doc` (
  `doc_id` int(11) NOT NULL AUTO_INCREMENT,
  `doc_codigo` varchar(10) DEFAULT NULL,
  `doc_desc` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`doc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipos_doc`
--

LOCK TABLES `tipos_doc` WRITE;
/*!40000 ALTER TABLE `tipos_doc` DISABLE KEYS */;
/*!40000 ALTER TABLE `tipos_doc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipos_impuestos`
--

DROP TABLE IF EXISTS `tipos_impuestos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tipos_impuestos` (
  `timp_id` int(11) NOT NULL AUTO_INCREMENT,
  `timp_descripcion` varchar(20) DEFAULT NULL,
  `timpo_alicuota` decimal(10,2) DEFAULT NULL,
  `timp_abrev` varchar(4) DEFAULT NULL,
  `timp_cpo1` varchar(20) DEFAULT NULL,
  `timp_cpo2` varchar(20) DEFAULT NULL,
  `timp_cpo3` varchar(20) DEFAULT NULL,
  `timp_habil` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`timp_id`),
  UNIQUE KEY `timp_id` (`timp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipos_impuestos`
--

LOCK TABLES `tipos_impuestos` WRITE;
/*!40000 ALTER TABLE `tipos_impuestos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tipos_impuestos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipos_iva`
--

DROP TABLE IF EXISTS `tipos_iva`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tipos_iva` (
  `tiva_id` int(11) NOT NULL AUTO_INCREMENT,
  `tiva_descripcion` varchar(30) DEFAULT NULL,
  `tiva_porcen` int(11) DEFAULT NULL,
  `tiva_cpo1` varchar(20) DEFAULT NULL,
  `tiva_cpo2` varchar(20) DEFAULT NULL,
  `tiva_cpo3` varchar(20) DEFAULT NULL,
  `tiva_afip` varchar(3) DEFAULT NULL,
  `tiva_habil` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`tiva_id`),
  UNIQUE KEY `tiva_id` (`tiva_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipos_iva`
--

LOCK TABLES `tipos_iva` WRITE;
/*!40000 ALTER TABLE `tipos_iva` DISABLE KEYS */;
/*!40000 ALTER TABLE `tipos_iva` ENABLE KEYS */;
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
-- Table structure for table `transferencias`
--

DROP TABLE IF EXISTS `transferencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transferencias` (
  `Trans_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Trans_tipo` varchar(4) NOT NULL,
  `Mov_id` bigint(20) NOT NULL,
  `Trans_fecha` date NOT NULL,
  `Cuenta_id` bigint(20) NOT NULL,
  `banco_id` bigint(10) NOT NULL,
  `trans_cuenta_destino` varchar(60) NOT NULL,
  `trans_comprobante` varchar(30) NOT NULL,
  `trans_titular` varchar(60) NOT NULL,
  `trans_detalle` varchar(100) NOT NULL,
  `trans_importe` double(16,2) NOT NULL,
  `trans_fbaja` datetime DEFAULT NULL,
  KEY `Trans_id` (`Trans_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transferencias`
--

LOCK TABLES `transferencias` WRITE;
/*!40000 ALTER TABLE `transferencias` DISABLE KEYS */;
/*!40000 ALTER TABLE `transferencias` ENABLE KEYS */;
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
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `usuario_id` int(11) NOT NULL AUTO_INCREMENT,
  `usu_nombre` char(30) DEFAULT NULL,
  `usu_logon` varchar(10) DEFAULT NULL,
  `usu_logon_md5` varchar(32) DEFAULT NULL,
  `usu_contra` varchar(15) NOT NULL,
  `usu_contra_md5` varchar(32) DEFAULT NULL,
  `usu_fecha_a` date DEFAULT NULL,
  `usu_fecha_b` date DEFAULT NULL,
  `usu_habil` tinyint(1) DEFAULT '0',
  `perfil_id` int(11) NOT NULL,
  `usu_mod_clave` int(1) DEFAULT '0',
  PRIMARY KEY (`usuario_id`,`perfil_id`),
  UNIQUE KEY `usuario_id` (`usuario_id`),
  KEY `perfil_id` (`perfil_id`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`perfil_id`) REFERENCES `perfiles_usuarios` (`perfil_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios_cajas`
--

DROP TABLE IF EXISTS `usuarios_cajas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios_cajas` (
  `usucaja_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id usuario caja',
  `usuario_id` int(11) DEFAULT '0' COMMENT 'id usuario',
  `caja_id` int(11) DEFAULT '0' COMMENT 'id caja',
  `usucaja_habil` int(11) DEFAULT '0' COMMENT '0 habilitado, 1 deshabilitado',
  PRIMARY KEY (`usucaja_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios_cajas`
--

LOCK TABLES `usuarios_cajas` WRITE;
/*!40000 ALTER TABLE `usuarios_cajas` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuarios_cajas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios_empresas`
--

DROP TABLE IF EXISTS `usuarios_empresas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios_empresas` (
  `usuario_id` int(11) DEFAULT NULL COMMENT 'id de usuario',
  `empre_id` int(4) DEFAULT NULL COMMENT 'id de empresa',
  `rel_usu_emp_habil` int(1) DEFAULT '0' COMMENT 'habilitado de la relacion',
  KEY `fk_usu` (`usuario_id`),
  KEY `fk_emp` (`empre_id`),
  CONSTRAINT `fk_emp` FOREIGN KEY (`empre_id`) REFERENCES `empresas` (`empre_id`),
  CONSTRAINT `fk_usu` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios_empresas`
--

LOCK TABLES `usuarios_empresas` WRITE;
/*!40000 ALTER TABLE `usuarios_empresas` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuarios_empresas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ventas`
--

DROP TABLE IF EXISTS `ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ventas` (
  `empre_id` int(4) NOT NULL DEFAULT '1',
  `id_sucursal` int(11) NOT NULL DEFAULT '1',
  `id_caja` int(11) NOT NULL DEFAULT '1',
  `id_venta` bigint(20) NOT NULL AUTO_INCREMENT,
  `cli_cuit` varchar(11) NOT NULL,
  `tcomp_id` int(11) NOT NULL,
  `venta_fechacpbte` date NOT NULL,
  `venta_nrocpbte` varchar(12) NOT NULL,
  `cli_nombre` varchar(40) NOT NULL,
  `cli_razsoc` varchar(40) NOT NULL,
  `venta_dias` int(3) DEFAULT NULL,
  `venta_vto` date DEFAULT NULL,
  `tiva_id` int(11) NOT NULL DEFAULT '1',
  `venta_anulado` datetime DEFAULT NULL,
  `usu_id` int(11) DEFAULT NULL,
  `venta_total` double(12,2) NOT NULL,
  `venta_imp_No_gravado` double(12,2) DEFAULT NULL,
  `venta_imp_Neto_gravado` double(12,2) DEFAULT NULL,
  `venta_imp_liquido` double(12,2) DEFAULT NULL,
  `venta_imp_RNI` double(12,2) DEFAULT NULL,
  `venta_imp_oper_exentas_iva` double(12,2) DEFAULT NULL,
  `venta_imp_percepcion` double(12,2) DEFAULT NULL,
  `venta_imp_percep_iibb` double(12,2) DEFAULT NULL,
  `venta_imp_percep_municipal` double(12,2) DEFAULT NULL,
  `venta_imp_impuestos_internos` double(12,2) DEFAULT NULL,
  `mmot_id` int(11) DEFAULT NULL,
  `venta_detalle` varchar(254) DEFAULT NULL,
  `venta_fcarga` datetime NOT NULL COMMENT 'fecha de carga',
  `venta_fbaja` date DEFAULT NULL COMMENT 'fecha de baja',
  `venta_periodo` varchar(6) DEFAULT NULL COMMENT 'periodo de liq de impuestos',
  `venta_fprocesado` datetime DEFAULT NULL COMMENT 'fecha de proceso de liq. impuestos',
  `mov_fecha` date DEFAULT NULL COMMENT 'fecha de pago',
  `mov_id` bigint(20) DEFAULT NULL COMMENT 'id de movimiento de egreso',
  `proc_lote` varchar(20) DEFAULT NULL,
  `id_autoriz_afip` varchar(40) DEFAULT NULL,
  `ejercicio_id` int(4) DEFAULT NULL,
  `neto_21` double(15,2) DEFAULT '0.00',
  `iva_21` double(12,2) DEFAULT '0.00',
  `neto_105` double(15,2) DEFAULT '0.00',
  `iva_105` double(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id_venta`),
  UNIQUE KEY `nro_cpbte` (`cli_cuit`,`tcomp_id`,`venta_nrocpbte`),
  KEY `tip_comp` (`tcomp_id`),
  KEY `iva` (`tiva_id`),
  KEY `usuario` (`usu_id`),
  KEY `Motivos` (`mmot_id`),
  KEY `lote` (`id_sucursal`,`proc_lote`),
  KEY `ejercicio` (`ejercicio_id`),
  KEY `empre` (`empre_id`),
  CONSTRAINT `cli_cuit` FOREIGN KEY (`cli_cuit`) REFERENCES `clientes` (`cli_cuit`),
  CONSTRAINT `ejercicio` FOREIGN KEY (`ejercicio_id`) REFERENCES `ejercicios` (`ejercicio_id`),
  CONSTRAINT `iva` FOREIGN KEY (`tiva_id`) REFERENCES `tipos_iva` (`tiva_id`),
  CONSTRAINT `Motivos` FOREIGN KEY (`mmot_id`) REFERENCES `motivos_movimientos` (`mmot_id`),
  CONSTRAINT `tip_comp` FOREIGN KEY (`tcomp_id`) REFERENCES `tipos_comprobantes` (`tcomp_id`),
  CONSTRAINT `usuario` FOREIGN KEY (`usu_id`) REFERENCES `usuarios` (`usuario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ventas`
--

LOCK TABLES `ventas` WRITE;
/*!40000 ALTER TABLE `ventas` DISABLE KEYS */;
/*!40000 ALTER TABLE `ventas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'cdk_tkt_dev'
--

--
-- Dumping routines for database 'cdk_tkt_dev'
--
/*!50003 DROP FUNCTION IF EXISTS `fnumeracpbte` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fnumeracpbte`(idtipo int ) RETURNS bigint(20)
BEGIN
    DECLARE V_RETURN INT UNSIGNED DEFAULT 0 ;
    declare v_nro bigint(20) default  0 ;
    declare nrotxt char(20) ; 
    declare wcomp int(1) ;
    set wcomp = (select tcomp_numera from tipos_comprobantes WHERE tcomp_id = idtipo ) ;
    if wcomp = 1 then 
      UPDATE tipos_comprobantes SET tcomp_cpo3 = "3"  WHERE tcomp_id = idtipo AND tcomp_NUMERA =1;
		SET V_RETURN := ROW_COUNT() ; 
		IF V_RETURN > 0 THEN  
			SET v_nro = (SELECT tcomp_cpo2 FROM tipos_comprobantes WHERE tcomp_id = idtipo  ) +1;
			SET nrotxt = CONVERT(v_nro, CHAR) ; 
			UPDATE tipos_comprobantes SET tcomp_cpo2 = nrotxt , tcomp_cpo3 = "0" WHERE tcomp_id = idtipo  ;
			-- SET V_RETURN := ROW_COUNT() ; 
			SET V_RETURN := nrotxt ; 
		else	
		   SET V_RETURN := 0 ; 
		END IF    ;
	 else
	    SET V_RETURN := -1 ;
	 end if ; 	
	return (V_RETURN);
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funabm_conceptos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funabm_conceptos`(wmov int(1) ,widconc bigint(10) , wdes varchar(40), wtipo smallint(1) , whabil smallint(1) ,  wusu int(5) ) RETURNS bigint(10)
BEGIN
       declare wid bigint(10) default 0 ; 
       if wmov = 0  then 
			  INSERT INTO conceptos_movimientos (conc_descripcion, conc_tipo , conc_habilitado , conc_falta , usuario_id) 
                VALUES (wdes, wtipo , whabil , NOW(), wusu ) ; 
           set wid := (select last_insert_id());
       end if ; 
               
       IF wmov = 1  THEN 
			  update conceptos_movimientos set conc_descripcion = wdes , conc_tipo = wtipo, 
			      conc_habilitado = whabil  , usuario_id = wusu  WHERE  concepto_id = widconc  ;  
			  SET wid := (SELECT row_count());
       END IF ;
       IF wmov = 2  THEN 
			  UPDATE conceptos_movimientos SET  conc_habilitado = whabil  , usuario_id = wusu   WHERE  concepto_id = widconc ;  
			  SET wid := (SELECT ROW_COUNT());
       END IF ;	
	    return wid ; 		
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAltaCierres_caja` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAltaCierres_caja`(wperi varchar(6), wfecini DATE,wsucu INT(11), wcaja INT(11),
                                                    wimppesos DECIMAL (12,2), 
																			  wimpdol DECIMAL(12,2) ,
																			  wimpchqt DECIMAL(12,2) , 
																			  wimpchqp DECIMAL(12,2) , 
																			  wusuario bigint(20)) RETURNS bigint(10)
BEGIN
        DECLARE whay BIGINT(20) DEFAULT 0 ;
        DECLARE whayper varchar(6) DEFAULT 0 ;
        declare wresul BIGint(10) default 0 ;
        set whay = (select ccaja_id from cierres_caja where wfecini between ccaja_fecha_inicio 
                   and ccaja_fecha_cierre and sucursal_id = wsucu and caja_id = wcaja ) ;
                   
        SET whayper = (SELECT ccaja_periodo FROM cierres_caja WHERE wperi = ccaja_periodo 
                   AND sucursal_id = wsucu AND caja_id = wcaja ) ;
        if isnull(whay) = 0 then 
           -- la fecha esta en otro cierre
           set wresul = 0 ; 
        else 
           if ISNULL(whayper) = 0 THEN 
              SET wresul =0 ; 
           else 
				  insert into cierres_caja (ccaja_periodo, ccaja_fecha_inicio, ccaja_imppesos, ccaja_impdolares, 
													ccaja_chq_terceros, ccaja_chq_propios, caja_id, sucursal_id,usuario_id )
										Values(wperi , wfecini, wimppesos, wimpdol, wimpchqt, wimpchqp,wcaja, wsucu ,  wusuario ) ; 
              SET wresul = (SELECT LAST_INSERT_ID()) ; 	
              update movcaja set ccaja_id = wresul 
                     where ccaja_id = 0 
                     AND sucursal_id = wsucu 
                     AND caja_id = wcaja; 
           end if ; 
        end if ;
        return wresul ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAltaCompras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAltaCompras`(wid_sucursal INT(10), 
			 wid_caja  INT(10) ,
			 wcuit VARCHAR(15), 
			 wtcomp_id INT(5), 
			 wcomp_fechacpbte DATE, 
			 wcomp_nrocpbte VARCHAR(15), 
			 wprov_razsocial VARCHAR(40), 
			 wprov_pagadero VARCHAR(40) , 
			 wcomp_dias INT(3), 
			 wcomp_vto DATE, 
			 wtiva_id INT(2), 
			 wcomp_iva21 DOUBLE(12,2), 
			 wcomp_iva105  DOUBLE(12,2) , 
			 wcomp_iva_diferencial  DOUBLE(12,2) , 
			 wcomp_percep_iva DOUBLE(12,2), 
			 wcomp_percep_iibb DOUBLE(12,2), 
			 wcomp_reten_iibb DOUBLE(12,2), 
			 wcomp_reten_ganancias DOUBLE(12,2),  
			 wcomp_varios DOUBLE(12,2),  
			 wcomp_bruto  DOUBLE(12,2), 
			 wcomp_total DOUBLE(12,2),  
			 wcomp_fcarga DATETIME ,
			 wmmot_id INT(11) ,
			 wcomp_detalle VARCHAR(255) ,
			  wcd_numero INT(5) , 
			  wempresa_id INT(4), 
			  wperiodo VARCHAR(4), 
			  wbruto_iva21 DOUBLE(12,2),
			  wbruto_iva105	DOUBLE(12,2),
			  wbruto_nograbado DOUBLE (12,2), 
			  wbruto_iva_diferencial DOUBLE(12,2) ) RETURNS varchar(10) CHARSET utf8
BEGIN 
       DECLARE wid_compras BIGINT(20) ; 
       DECLARE wnroexped  VARCHAR(10) ; 
       DECLARE wpernum VARCHAR(4) ;
       -- SET wnroexped = funNumExpedientes("1704") ; 
       SET wnroexped = funNumExpedientes(wperiodo,wempresa_id ) ; 
       IF wnroexped <> "-1" THEN 
	       INSERT INTO compras ( id_sucursal, 
				id_caja ,
				cuit, 
				tcomp_id, 
				comp_fechacpbte, 
				comp_nrocpbte, 
				prov_razsocial, 
				prov_pagadero ,
				   comp_dias, 
				   comp_vto, 
				   tiva_id, 
				   comp_iva21, 
				   comp_iva105 , 
				   comp_iva_difErencial , 
				   comp_percep_iva, 
				   comp_percep_iibb,
				   comp_reten_iibb, 
				   comp_reten_ganancias, 
				   comp_varios, 
				   comp_bruto ,
				   comp_total, 
				   comp_fcarga ,
				   mmot_id , 
			   comp_detalle , CD_numero ,empresa_id  , 
			   comp_bruto_iva21 , 
			   comp_bruto_iva105, 
			   comp_bruto_no_gravado, 
			   comp_bruto_iva_diferencial) VALUES 
			(wid_sucursal, 
				wid_caja ,
				wcuit, 
				wtcomp_id, 
				wcomp_fechacpbte, 
				wcomp_nrocpbte, 
				wprov_razsocial, 
				wprov_pagadero ,
				   wcomp_dias, 
				   wcomp_vto, 
				   wtiva_id, 
				   wcomp_iva21, 
				   wcomp_iva105 , 
				   wcomp_iva_diferencial , 
				   wcomp_percep_iva, 
				   wcomp_percep_iibb,
				   wcomp_reten_iibb, 
				   wcomp_reten_ganancias, 
				   wcomp_varios, 
				   wcomp_bruto ,
				   wcomp_total, 
				   wcomp_fcarga,
				   wmmot_id , 
				wcomp_detalle, wcd_numero , wempresa_id, 
				wbruto_iva21 ,
			  wbruto_iva105	,
			  wbruto_nograbado , 
			  wbruto_iva_diferencial ) ; 
		  SET wid_compras :=  (SELECT LAST_INSERT_ID()) ;      
		  UPDATE compras SET comp_expediente = wnroexped WHERE id_compras = wid_compras ; 
        END IF ; 
        RETURN wnroexped ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAltaCompras_olds` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAltaCompras_olds`(wnroexped VARCHAR(10) , wid_sucursal INT(10), 
			 wid_caja  INT(10) ,
			 wcuit VARCHAR(15), 
			 wtcomp_id INT(5), 
			 wcomp_fechacpbte DATE, 
			 wcomp_nrocpbte VARCHAR(20), 
			 wprov_razsocial VARCHAR(130), 
			 wprov_pagadero VARCHAR(130) , 
			 wcomp_dias INT(3), 
			 wcomp_vto DATE, 
			 wtiva_id INT(2), 
			 wcomp_iva21 DOUBLE(12,2), 
			 wcomp_iva105 DOUBLE(12,2) , 
			 wcomp_percep_iva DOUBLE(12,2), 
			 wcomp_percep_iibb DOUBLE(12,2), 
			 wcomp_reten_iibb DOUBLE(12,2), 
			 wcomp_reten_ganancias DOUBLE(12,2),  
			 wcomp_varios DOUBLE(12,2),  
			 wcomp_bruto  DOUBLE(12,2), 
			 wcomp_total DOUBLE(12,2),  
			 wcomp_fcarga DATETIME ,
			 wmmot_id INT(11) ,
			 wcomp_detalle VARCHAR(255) , wcd_numero INT(5) , wempresa_id INT(4) ) RETURNS varchar(10) CHARSET utf8
BEGIN 
       DECLARE wid_compras BIGINT(20) ; 
       DECLARE wexist_cuits varchar(11) default NULL ; 
       DECLARE wpernum VARCHAR(4) ;
       SET wexist_cuits = (SELECT CUIT FROM PROVEEDORES WHERE CUIT = wcuit) ;
       IF ISNULL(wexist_cuits) = 1 THEN
          INSERT INTO PROVEEDORES (CUIT, prov_razsocial , prov_pagadero, TIVA_ID ) VALUES ( wcuit,wprov_razsocial , wprov_razsocial,wtiva_id ) ; 
       END IF ;
       INSERT INTO compras ( 
          comp_expediente , 
          id_sucursal, 
	  id_caja ,
	  cuit, 
	  tcomp_id, 
	  comp_fechacpbte, 
	  comp_nrocpbte, 
	  prov_razsocial, 
	  prov_pagadero ,
	  comp_dias, 
	  comp_vto, 
	  tiva_id, 
	  comp_iva21, 
	  comp_iva105 , 
	  comp_percep_iva, 
	  comp_percep_iibb,
	  comp_reten_iibb, 
	  comp_reten_ganancias, 
	  comp_varios, 
	  comp_bruto ,
	  comp_total, 
	  comp_fcarga ,
	  mmot_id , 
	  comp_detalle , CD_numero ,empresa_id )
	VALUES 
	( wnroexped, 
	  wid_sucursal, 
	  wid_caja ,
	  wcuit, 
	  wtcomp_id, 
	  wcomp_fechacpbte, 
	  wcomp_nrocpbte, 
	  wprov_razsocial, 
	  wprov_pagadero ,
	  wcomp_dias, 
	  wcomp_vto, 
	  wtiva_id, 
	  wcomp_iva21, 
	  wcomp_iva105 , 
	  wcomp_percep_iva, 
	  wcomp_percep_iibb,
	  wcomp_reten_iibb, 
	  wcomp_reten_ganancias, 
	  wcomp_varios, 
	  wcomp_bruto ,
	  wcomp_total, 
	  wcomp_fcarga,
	  wmmot_id , 
	  wcomp_detalle, wcd_numero , wempresa_id) ; 
          SET wid_compras :=  (SELECT LAST_INSERT_ID()) ;    
        
       RETURN wnroexped ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAltaSaldos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAltaSaldos`(wid_sucursal int(10), 
			 wid_caja  INT(10) ,			/*xxxxxxxxxxxxxx*/
			 wcuit varchar(15), 			-- xxxxxxxxxxx
			 wtcomp_id int(5), 			-- xxxxxxxxxxxxxxxxx
			 wcomp_fechacpbte date, 		
			 wcomp_nrocpbte varchar(15), 		
			 wprov_razsocial varchar(40), 		
			 wprov_pagadero varchar(40) , 		
			 wcomp_dias int(3), 			
			 wcomp_vto date, 			
			 wtiva_id int(2), 			
			 wcomp_iva21 double(12,2), 		
			 wcomp_iva_diferencial  double(12,2) , 	
			 wcomp_percep_iva double(12,2), 	
			 wcomp_percep_iibb DOUBLE(12,2), 	
			 wcomp_reten_iibb DOUBLE(12,2), 
			 wcomp_reten_ganancias DOUBLE(12,2), 	 
			 wcomp_varios DOUBLE(12,2),  		
			 wcomp_bruto  DOUBLE(12,2),		
			 wcomp_total DOUBLE(12,2),  		
			 wcomp_fcarga datetime , 		
			 wmmot_id int(11) , 			
			 wcomp_detalle varchar(255) , 		
			 wcd_numero int(5) , 			
			 wempresa_id int(4), 			
			 wcomp_iva105 double(10,2) ) RETURNS varchar(10) CHARSET utf8
BEGIN 
       declare wid_compras bigint(20) ; 
       declare wnroexped  varchar(10) ; 
       declare wpernum varchar(4) ;
       set wpernum = CONCAT(RIGHT(YEAR(NOW()),2), RIGHT(CONCAT("00",MONTH(NOW())),2)) ;
       SET wnroexped = funNumExpedientes("1803") ; 
       -- SET wnroexped = funNumExpedientes(wpernum) ; 
       insert into compras ( id_sucursal, 
						id_caja ,
						cuit, 
						tcomp_id, 
						comp_fechacpbte, 
						comp_nrocpbte, 
						prov_razsocial, 
						prov_pagadero ,
						   comp_dias, 
						   comp_vto, 
						   tiva_id, 
						   comp_iva21, 
						   comp_iva105 , 
						   comp_iva_difErencial , 
						   comp_percep_iva, 
						   comp_percep_iibb,
						   comp_reten_iibb, 
						   comp_reten_ganancias, 
						   comp_varios, 
						   comp_bruto ,
						   comp_total, 
						   comp_fcarga ,
						   mmot_id , 
					   comp_detalle , CD_numero ,empresa_id , comp_fprocesado, comp_periodo ) values 
					(wid_sucursal, 
						wid_caja ,
						wcuit, 
						wtcomp_id, 
						wcomp_fechacpbte, 
						wcomp_nrocpbte, 
						wprov_razsocial, 
						wprov_pagadero ,
						   wcomp_dias, 
						   wcomp_vto, 
						   wtiva_id, 
						   wcomp_iva21, 
						   wcomp_iva105 , 
						   wcomp_iva_diferencial , 
						   wcomp_percep_iva, 
						   wcomp_percep_iibb,
						   wcomp_reten_iibb, 
						   wcomp_reten_ganancias, 
						   wcomp_varios, 
						   wcomp_bruto ,
						   wcomp_total, 
						   wcomp_fcarga,
						   wmmot_id , 
						wcomp_detalle, wcd_numero , wempresa_id, '2018-03-01' , '032018') ; 
          set wid_compras :=  (select last_insert_id()) ;      
          UPDATE compras SET comp_expediente = wnroexped where id_compras = wid_compras ; 
          return wnroexped ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAlta_cuentas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAlta_cuentas`( widcta bigint(10) , wbco_id  varchar(11) ,wcta_sucursal  varchar(30),	wcta_cuit  varchar(13) ,
              wcta_nombres  varchar(30), wcta_numero  varchar(20) ,wcta_cbu  varchar(27) ,
              wcta_domomicilio  varchar(60),wcta_tel_contacto  varchar(80),wcta_falta  datetime , wusuario_id  int(11)  ,
              Wtipo_cta_id BIGINT(10), wempresaid int(3)) RETURNS bigint(10)
BEGIN
		 declare wlastKey bigint(10);
		 if widcta = 0 then 
			 insert into caja_cuentas ( empre_id , bco_id ,
				cta_sucursal ,
				cta_cuit ,
				cta_nombres ,
				cta_numero ,
				cta_cbu ,
				cta_domomicilio ,
				cta_tel_contacto,
				cta_falta ,
				usuario_id ,
				tipo_cta_id)
				values 
				(wempresaid, wbco_id ,
				wcta_sucursal ,
				wcta_cuit ,
				wcta_nombres ,
				wcta_numero ,
				wcta_cbu ,
				wcta_domomicilio ,
				wcta_tel_contacto,
				wcta_falta ,
				wusuario_id,
				Wtipo_cta_id )        ; 
			  set wlastKey := (select last_insert_id()) ; 
			else 
			   update caja_cuentas set bco_id = wbco_id ,
				cta_sucursal = wcta_sucursal, 
				cta_cuit = wcta_cuit, 
				cta_nombres = wcta_nombres ,
				cta_numero = wcta_numero, 
				cta_cbu = wcta_cbu ,
				cta_domomicilio = wcta_domomicilio, 
				cta_tel_contacto= wcta_tel_contacto,
				cta_falta = wcta_falta, 
				usuario_id = wusuario_id ,
				tipo_cta_id = Wtipo_cta_id where cuenta_id = widcta;
			   
			SET wlastKey = 1 ; 
		   end if 	; 	  
		return wlastKey ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAlta_notas_DC` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAlta_notas_DC`( wempre_id int(4) ,
				wtcomp_id int(4), 
				wmov_id bigint(20) , 
				wid_compras bigint(20),  
				wid_ventas bigint(20), 
				wnotadc_numero varchar(14),   
				wnotadc_importe double(16,2) ) RETURNS int(11)
BEGIN
       declare wreturn bigint(10) ;
       DECLARE walta date default date(now()) ; 
       insert into notas_deb_creditos (empre_id  ,tcomp_id , mov_id ,  id_compras ,  id_ventas , notadc_numero , notadc_importe, notadc_falta )
             values (wempre_id  ,wtcomp_id , wmov_id ,  wid_compras ,  wid_ventas , wnotadc_numero ,   wnotadc_importe , walta ) ;
       
       SET wreturn := (SELECT LAST_INSERT_ID()) ;
       return wreturn ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAlta_Retenciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAlta_Retenciones`(wempre INT(4) , wsucur INT(4) , widtipo INT(11) , 
                                                                          wreten_imp_areten double(14,2) , wreten_alicuota double(10,2) ,
                                                                          wreten_fecha date ,wid_compras bigint(20), 
							                   wid_venta bigint(20), wreten_retenido double (14,2),
							                    wmov_id bigint(20), wreten_falta date, WNRO_CPBTE VARCHAR(15) ) RETURNS varchar(20) CHARSET latin1
BEGIN
    declare wxcertificado varchar(20)  default "0";
    
    IF wnro_cpbte = '' then 
       set wxcertificado =  funNum_Certificados_retencion( wempre  , wsucur  , widtipo  ) ;
    else 
       SET wxcertificado =  WNRO_CPBTE ;
    end if  ;
    IF wxcertificado <> "0" then 
  
	INSERT INTO RETENCIONES (tcomp_id, reten_imp_areten , reten_alicuota ,reten_fecha ,id_compras, 
		id_venta, reten_retenido, reten_certificado, mov_id, reten_falta) 
		VALUES ( widtipo, wreten_imp_areten , wreten_alicuota ,wreten_fecha ,wid_compras, 
		wid_venta, wreten_retenido, wxcertificado , wmov_id, wreten_falta );
					
    end if ;
    return wxcertificado ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAlta_rubros` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAlta_rubros`(wempresa_id  INT(4), wrubro_codigo  INT (4), wrubro_descripcion VARCHAR(30) , wrubro_tipo VARCHAR(4), wrubro_habilitado INT(1)) RETURNS int(5)
BEGIN
       DECLARE wnroreg INT(5);
       INSERT INTO rubros (empresa_id ,rubro_codigo, rubro_descripcion  , rubro_tipo , rubro_habilitado)
            VALUES (wempresa_id, wrubro_codigo , wrubro_descripcion  , wrubro_tipo , wrubro_habilitado );
        SET wnroreg :=     (SELECT LAST_INSERT_ID());
        RETURN wnroreg;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAlta_Transferencias` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAlta_Transferencias`(wTrans_tipo VARCHAR(4) ,
						  wMov_id BIGINT(20) ,
						  wTrans_fecha DATE ,
						  wCuenta_id BIGINT(20),
						  wbanco_id BIGINT(10) ,
						  wtrans_cuenta_destino VARCHAR(60) ,
						  wtrans_comprobante VARCHAR(30) ,
						  wtrans_titular VARCHAR(60),
						  wtrans_detalle VARCHAR(100) ,
						  wtrans_importe DOUBLE(16,2) ) RETURNS bigint(20)
BEGIN
	DECLARE wid_tranf BIGINT(20) ;
	  INSERT INTO transferencias (Trans_tipo,
		  Mov_id ,
		  Trans_fecha ,
		  Cuenta_id ,
		  banco_id ,
		  trans_cuenta_destino,
		  trans_comprobante ,
		  trans_titular ,
		  trans_detalle ,
		  trans_importe ,
		  trans_fbaja )
	   VALUES 
		 ( WTrans_tipo,
		  WMov_id ,
		  WTrans_fecha ,
		  WCuenta_id ,
		  Wbanco_id ,
		  Wtrans_cuenta_destino,
		  Wtrans_comprobante ,
		  Wtrans_titular ,
		  Wtrans_detalle ,
		  Wtrans_importe ,
		  NULL  );
	SET wid_tranf :=  (SELECT LAST_INSERT_ID()) ; 
	RETURN wid_tranf ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funAnular_movcaja` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funAnular_movcaja`(widmov bigint(20)) RETURNS int(1)
BEGIN
       declare wvalor integer(1) default 0 ;  
       declare wsoloefvo integer(1) default 0 ; 
       DECLARE whaymov_terceros BIGINT(20) DEFAULT 0 ; 
       DECLARE whaymov_propios BIGINT(20) DEFAULT 0 ; 
       set wsoloefvo = (select mov_soloefvo from movcaja where mov_id = widmov);
       SET wvalor = 0 ; 
       if wsoloefvo = 0 then 
		    -- DELETE FROM MOVCAJA WHERE MOV_ID = IDMOV ;
		    UPDATE MOVCAJA SET MOV_ANULACION = NOW()  WHERE MOV_ID = widmov ;
		    set wvalor = 1 ; 
       else 
			 set whaymov_terceros = (select id_egreso from mov_cheques_terceros 
														where mov_id = widmov and 
																(id_egreso > 0 or ISNULL(chqt_anulado) = 0 or 
														 ISNULL(chqt_fdeposito) = 0 or
														 ISNULL(chqt_entregado) = 0 or 
														 ISNULL(chqt_cambio) = 0  )  ) ;
			 if isnull(whaymov_terceros) = 1 then
				 delete FROM mov_cheques_terceros WHERE MOV_ID = WIDMOV  ; 
				 update mov_cheques_terceros set id_egreso = 0 , chqt_entregado = NULL where id_egreso = widmov       ; 
				 UPDATE CAJA_CHEQUES SET STK_CHQ_FEMISIN = NULL ,
						STK_CHQ_FVTO = NULL ,  STK_CHQ_IMPORTE = 0 ,
						 CUIT = "", STK_CHQ_NOMBRE_APAGAR = "", MOV_ID = NULL , MOV_FECHA = NULL  WHERE MOV_ID = widmov ; 
				 UPDATE MOVCAJA SET MOV_ANULACION = NOW()  WHERE MOV_ID = widmov ;
				 SET wvalor = 1 ; 
			 else 
			    SET wvalor = 2 ; 
			 end if ;       
       end if ; 
       return wvalor ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funBuscaEjercicioVigente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funBuscaEjercicioVigente`() RETURNS int(4)
BEGIN
	declare wid_ejercicio int(4) default 9999;
	set wid_ejercicio = (SELECT ejercicio_nro FROM ejercicios WHERE ISNULL(ejer_fecha_cierre) = 1) ;
	if isnull(wid_ejercicio) = 1 then 
	    set  wid_ejercicio = 9999 ;
	end if ;
	return wid_ejercicio;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCargaChqsTerceros` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCargaChqsTerceros`(
						  wmov_id BIGINT(20) ,
						  wempre int(4) , 
						  wid_egreso BIGINT(20) ,
						  wid_ingreso BIGINT(20),
						  wchqt_femisin DATE ,
						  wchqt_fvto DATE ,
						  wchqt_clearing INT(3),
						  wchqt_importe DECIMAL(10,2),
						  wbco_id INT(11) ,
						  wchqt_nro VARCHAR(20) ,
						  wchqt_cta_nom VARCHAR(50),
						  wchqt_cta_nro VARCHAR(20),
						  wchqt_cta_cuit VARCHAR(15),
						  wchqt_cta_dom_pago VARCHAR(50) ) RETURNS int(2)
BEGIN
       DECLARE	V_RETURN  INT(2) ;
			INSERT INTO mov_cheques_terceros (mov_id , empre_id ,
			  id_egreso ,
			  id_ingreso ,
			  chqt_femisin,
			  chqt_fvto ,
			  chqt_clearing ,
			  chqt_importe,
			  bco_id ,
			  chqt_nro ,
			  chqt_cta_nom ,
			  chqt_cta_nro ,
			  chqt_cta_cuit ,
			  chqt_cta_dom_pago ) 
			VALUES 
			 (  wmov_id , wempre ,
				wid_egreso ,
				wid_ingreso ,
				wchqt_femisin,
				wchqt_fvto ,
				wchqt_clearing ,
				wchqt_importe,
				wbco_id ,
				wchqt_nro ,
				wchqt_cta_nom ,
				wchqt_cta_nro ,
				wchqt_cta_cuit ,
				wchqt_cta_dom_pago );
	SET V_RETURN := ROW_COUNT();
	UPDATE MOVCAJA SET mov_soloefvo = 1 WHERE mov_id =  wmov_id ;  
	RETURN V_RETURN ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCargaCliente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCargaCliente`(wcli_cuit CHAR(11),
          wcli_nombre CHAR(40),
          wcli_razsoc CHAR(30),
          wcli_domicilio CHAR(60),
          wcli_telefono CHAR(60),
          wcli_movil CHAR(60),
          wcli_cod_radio CHAR(20),
          wcli_email CHAR(80),
          wbco_id INT(11),
          wtipo_cta_id INT(2),
          wcli_cta_banco CHAR(60),
          wtiva_id INT(11),
          wcli_nro_iibb CHAR(11),
          wusuario_id INT(11),
          wcli_falta DATE ,
          wcli_datos_contacto CHAR(254), 
          wcli_lleva_cta INT(1) ) RETURNS bigint(10)
BEGIN
      DECLARE wid_cliente BIGINT(10) ;
	      INSERT  INTO clientes(
		  cli_cuit,
		  cli_nombre,
		  cli_razsoc,
		  cli_domicilio,
		  cli_telefono,
		  cli_movil,
		  cli_cod_radio,
		  cli_email,
		  bco_id,
		  tipo_cta_id,
		  cli_cta_banco,
		  tiva_id,
		  cli_nro_iibb,
		  usuario_id,
		  cli_falta,
		  cli_datos_contacto, cli_lleva_cta) VALUES (
		  wcli_cuit,
		  wcli_nombre,
		  wcli_razsoc,
		  wcli_domicilio,
		  wcli_telefono,
		  wcli_movil,
		  wcli_cod_radio,
		  wcli_email,
		  wbco_id,
		  wtipo_cta_id,
		  wcli_cta_banco,
		  wtiva_id,
		  wcli_nro_iibb,
		  wusuario_id,
		  wcli_falta,
		  wcli_datos_contacto, 
		  wcli_lleva_cta);
	 SET wid_cliente :=  (SELECT LAST_INSERT_ID()) ;      
         RETURN wid_cliente ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCargaFactura_elect` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCargaFactura_elect`(wid_sucursal INT(11) ,
				wcli_cuit VARCHAR(11) , 
				wtcomp_id INT(11) , 
				wventa_fechacpbte DATE ,
				wventa_nrocpbte VARCHAR(15) ,
				wcli_nombre VARCHAR(40) , 
				wcli_razsoc VARCHAR(40) ,
				wventa_dias INT(3) ,
				wventa_vto DATE ,
				wtiva_id INT(11)  ,
				wventa_anulado DATETIME ,
				wusu_id INT(11) ,
				wventa_total DOUBLE(12,2) ,
				wventa_imp_No_gravado DOUBLE(12,2) ,
				wventa_imp_Neto_gravado DOUBLE(12,2) ,
				wventa_imp_liquido DOUBLE(12,2) ,
				wventa_imp_RNI DOUBLE(12,2) ,
				wventa_imp_oper_exentas_iva DOUBLE(12,2) , 
				wventa_imp_percepcion DOUBLE(12,2) ,
				wventa_imp_percep_iibb DOUBLE(12,2) ,
				wventa_imp_percep_municipal DOUBLE(12,2) ,
				wventa_imp_impuestos_internos DOUBLE(12,2) ,
				wventa_detalle VARCHAR(254) ,
				wventa_fcarga DATETIME  ,
				wventa_fbaja DATE  ,
				wventa_periodo VARCHAR(6)  ,
				wid_autoriz_afip VARCHAR(40),
				wUsuarioid BIGINT(20) , 
				wnrolote VARCHAR (20) , 
				wempre INT(4), 
				wnet21 DOUBLE(15,2) ,  
				wiva21 DOUBLE (15,2) , 
				wnet105 DOUBLE(15,2), 
				wiva105 DOUBLE(15,2) ) RETURNS bigint(20)
BEGIN
     DECLARE wid_venta BIGINT(20);
     DECLARE wxsucur INT(11);
     DECLARE wxticomp INT(2) ; 
     DECLARE wxcajaid  INT(11) ; 
     DECLARE wxtiva CHAR(2) ; 
     DECLARE wxhaycuit CHAR(11) DEFAULT NULL ; 
     DECLARE wid_movi BIGINT(20) ;
     DECLARE wperiodofact CHAR(6) ; 
     DECLARE wxctacontable INT(7) ; 
     
     SET wxsucur = IF(wid_sucursal = "1001" , 1, (SELECT sucursal_ID FROM sucursales WHERE  sucur_afip = wid_sucursal LIMIT 1 )) ;
     SET wxticomp = (SELECT tcomp_id FROM tipos_comprobantes WHERE tcomp_afip = wtcomp_id ) ; 
     SET wxcajaid = (SELECT caja_id FROM cajas WHERE sucursal_ID = wxsucur AND caja_central = 1 ) ;
     SET wxtiva = (SELECT tiva_id FROM tipos_iva WHERE tiva_afip = wtiva_id  ) ;
     
     -- TIPO DE IMPUTACION VTA GRABADA O EXENTA     
     IF WXTIVA = 5 THEN
        SET wxctacontable = 4110102 ; 
     ELSE 
        SET wxctacontable = 4110101 ;
     END IF  ; 
     
     -- insercion del nuevo cliente si no existe -- 
     -- ===========================================
     SET wxhaycuit = (SELECT cli_cuit FROM clientes WHERE wcli_cuit = cli_cuit )  ;
     IF ISNULL(wxhaycuit) = 1 THEN 
        INSERT INTO clientes (cli_cuit , cli_nombre, cli_razsoc , tiva_id, cli_falta ) VALUES (wcli_cuit , wcli_nombre , wcli_razsoc, wxtiva , date(now()) );
     END IF ; 
     -- ===========================================
     
	  INSERT INTO ventas (empre_id , id_sucursal, id_caja ,  cli_cuit, tcomp_id,venta_fechacpbte ,
			  venta_nrocpbte , cli_nombre , cli_razsoc , venta_dias , venta_vto ,
			  tiva_id , usu_id  , venta_total , venta_imp_No_gravado ,venta_imp_Neto_gravado , venta_imp_liquido ,
			  venta_imp_RNI ,venta_imp_oper_exentas_iva ,venta_imp_percepcion ,venta_imp_percep_iibb , venta_imp_percep_municipal ,
			  venta_imp_impuestos_internos , mmot_id ,venta_detalle,venta_fcarga ,venta_fbaja ,venta_periodo , id_autoriz_afip, proc_lote,
			  neto_21 , neto_105 , iva_21, iva_105 ) 
			VALUES (wempre, wxsucur,wxcajaid, wcli_cuit, wxticomp,wventa_fechacpbte ,
			  CONCAT( wid_sucursal,wventa_nrocpbte) ,wcli_nombre , wcli_razsoc , wventa_dias , wventa_vto ,
			  wxtiva , wusu_id  ,wventa_total , wventa_imp_No_gravado ,wventa_imp_Neto_gravado ,wventa_imp_liquido ,
			  wventa_imp_RNI ,wventa_imp_oper_exentas_iva ,wventa_imp_percepcion ,wventa_imp_percep_iibb , wventa_imp_percep_municipal ,
			  wventa_imp_impuestos_internos ,wxctacontable,wventa_detalle, wventa_fcarga ,wventa_fbaja , wventa_periodo ,wid_autoriz_afip, wnrolote ,
			  wnet21 , wnet105 , wiva21, wiva105 );
			  
       SET wid_venta :=  (SELECT LAST_INSERT_ID()) ;
   --     SET wperiodofact = RIGHT(CONCAT("000" , CONCAT(MONTH(wventa_fechacpbte), YEAR(wventa_fechacpbte))),6); 
       -- incorporación de movimientos de caja --
       -- =======================================
 --      IF wid_movi > 0 then 
 --         UPDATE ventas SET mov_id = wid_movi , mov_fecha = DATE(NOW()) WHERE wid_venta = id_venta ; 
 --       END IF  	;
       RETURN wid_venta ; 		  
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCargaIngEgr_Caja` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCargaIngEgr_Caja`(
									  wmov_idtipo smallint(1),
									  wcuit char(11),
									  wconcepto_id bigint(10),
									  wmov_fecha date ,
									  wmov_periodo varchar(6) ,
									  wmov_importe_bruto decimal(12,2) ,
									  wmov_imp_impuestos decimal(10,2) ,
									  wmov_imp_dolares decimal(10,2), 
 									  wcaja_id int(11) ,
									  wsucursal_id int(11), 
									  wusuario_id int(11),
									  wmov_fcreacion datetime ,
									  wmov_observa varchar(250), 
										wmov_soloefvo int(1) ,
										wtcomp_id  bigint(20) ,
										wmov_nro_cpbte varchar(11) , 
										wmov_imp_pesos decimal(12,2) , wccaja_id int(11)) RETURNS bigint(20)
BEGIN
    declare wid_movcaja bigint(20) ; 
     DECLARE wxsucur INT(11);
     DECLARE wxcajaid  INT(11) ; 
     SET wxsucur = wsucursal_id  ;
     SET wxcajaid = wcaja_id ;
		insert into movcaja (mov_idtipo,
										cuit ,
									concepto_id  ,
									mov_fecha ,
									mov_periodo  ,
									mov_importe_total ,
									mov_importe_bruto  ,
									mov_imp_impuestos  ,
									mov_imp_dolares  ,
									caja_id  ,
									sucursal_id , 
									usuario_id ,
									mov_fcreacion  ,
									mov_detalle ,
									mov_soloefvo, 
									tcomp_id , 
									mov_nro_cpbte,
									mov_imp_pesos ,
									ccaja_id 	) 
						values  (wmov_idtipo,
									wcuit ,
									wconcepto_id  ,
									wmov_fecha ,
									wmov_periodo  ,
									(wmov_importe_bruto + wmov_imp_impuestos) , 
									wmov_importe_bruto  ,
									wmov_imp_impuestos  ,
									wmov_imp_dolares ,
									wxcajaid  ,
									wxsucur , 
									wusuario_id ,
									wmov_fcreacion  ,
									wmov_observa ,
									wmov_soloefvo ,
									wtcomp_id , 
									wmov_nro_cpbte , 
									wmov_imp_pesos,
									wccaja_id ) ; 
			SET wid_movcaja :=  (SELECT LAST_INSERT_ID()) ;
			return wid_movcaja ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCargaMov_Caja` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCargaMov_Caja`(
									  wmov_idtipo smallint(1),
									  wcuit char(11),
									  wmmot_id int(11),
									  wmov_fecha date ,
									  wmov_periodo varchar(6) ,
									  wmov_importe_bruto decimal(12,2) ,
									  wmov_imp_impuestos decimal(10,2) ,
									  wmov_imp_dolares decimal(10,2), 
 									  wcaja_id int(11) ,
									  wsucursal_id int(11), 
									  wusuario_id int(11),
									  wmov_fcreacion datetime ,
									  wmov_observa varchar(250) , 
									  wempre int(4) , 
									  wlote varchar (20) , 
									  wcierreID bigint(20) , 
									  wejercicioID bigint(20)  ) RETURNS bigint(20)
BEGIN
    declare wid_movcaja bigint(20) ; 
     DECLARE wxsucur INT(11);
     DECLARE wxcajaid  INT(11) ; 
   
     SET wxcajaid = (SELECT caja_id FROM cajas WHERE wempre = empre_id  AND caja_central = 1  limit 1) ;
       SET wxsucur = (SELECT sucursal_ID FROM cajas WHERE  caja_id = wxcajaid LIMIT 1);
		insert into movcaja (mov_idtipo,
							cuit ,
						mmot_id ,
						mov_fecha ,
						mov_periodo  ,
						mov_importe_total ,
						mov_importe_bruto  ,
						mov_imp_impuestos  ,
						mov_imp_dolares  ,
						caja_id  ,
						sucursal_id , 
						usuario_id ,
						mov_fcreacion  ,
						mov_detalle ,
						mov_imp_pesos ,
						concepto_id , 
						empresa_id , ccaja_id  , ejercicio_id ) 
				values  (wmov_idtipo,
						wcuit ,
						wmmot_id ,
						wmov_fecha ,
						wmov_periodo  ,
						(wmov_importe_bruto + wmov_imp_impuestos) , 
						wmov_importe_bruto  ,
						wmov_imp_impuestos  ,
						wmov_imp_dolares ,
						wxcajaid  ,
						wxsucur , 
						wusuario_id ,
						wmov_fcreacion  ,
						wmov_observa ,
						(wmov_importe_bruto + wmov_imp_impuestos), 
						1, wempre , wcierreID ,  wejercicioID ) ; 
			SET wid_movcaja :=  (SELECT LAST_INSERT_ID()) ;
			
			update ventas set mov_id = wid_movcaja where proc_lote = wlote  and isnull(mov_id) = 1; 
			
			
         return wid_movcaja; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCargaMov_Caja_v2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCargaMov_Caja_v2`(
wmov_idtipo smallint(1),
wcuit char(11),
wconcepto_id  int(11),
wmov_fecha date ,
wmov_periodo varchar(6) ,
wmov_importe_bruto decimal(12,2) ,
wmov_imp_impuestos decimal(10,2) ,
wmov_imp_dolares decimal(10,2), 
wcaja_id int(11) ,   
wcabecera_id int (11), 
wsucursal_id int(11), 
wusuario_id int(11),
wmov_fcreacion datetime ,
wmov_observa varchar(250) , 
wempre int(4) , 
wlote varchar (20) , 
wcierre_id bigint(20), 
wcierreID bigint(20) , 
wejercicioID bigint(20)  ) RETURNS bigint(20)
BEGIN
    declare wid_movcaja bigint(20) default 0; 
    -- DECLARE wxsucur INT(11);
    -- DECLARE wxcajaid  INT(11) ; 
    -- SET wxsucur = (SELECT sucursal_ID FROM cajas WHERE  caja_id = wcaja_id LIMIT 1);
    
    insert into movcaja (mov_idtipo, cuit , concepto_id ,mov_fecha ,mov_periodo  ,mov_importe_total ,mov_importe_bruto  ,mov_imp_impuestos  ,mov_imp_dolares  ,caja_id  ,sucursal_id , usuario_id ,mov_fcreacion  ,mov_detalle ,mov_imp_pesos , empresa_id , cierre_id , ccaja_id  , ejercicio_id ) values  (wmov_idtipo,wcuit ,wconcepto_id ,wmov_fecha ,wmov_periodo  ,(wmov_importe_bruto + wmov_imp_impuestos) , wmov_importe_bruto  ,wmov_imp_impuestos  ,wmov_imp_dolares ,wcaja_id  ,wsucursal_id , wusuario_id ,wmov_fcreacion  ,wmov_observa ,(wmov_importe_bruto + wmov_imp_impuestos), wempre , wcierre_id , wcierreID ,  wejercicioID ) ; 
    
    SET wid_movcaja :=  (SELECT LAST_INSERT_ID()) ;
    
    
    return wid_movcaja; 
         
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCargaProveedor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCargaProveedor`(  wcuit CHAR(11)  ,
							  wprov_nombre CHAR(80)  ,
							  wprov_razsocial CHAR(130)  ,
							  wprov_pagadero VARCHAR(130)  ,
							  wprov_direccion CHAR(60)  ,
							  wprov_telefono CHAR(30)  ,
							  wprov_movil CHAR(20)  ,
							  wprov_cod_radio CHAR(20)  ,
							  wprov_email CHAR(60)  ,
							  wprov_cbu CHAR(30)  ,
							  wbco_id INT(11)  ,
							  wtipo_cta_id INT(5)  ,
							  wprov_nro_cta VARCHAR(30)  ,
							  wtiva_id INT(2)  ,
							  wprov_tiene_ctacte INT(1)  ,
							  wPROV_CONTACTO VARCHAR(254)  ,
							  wprov_dias INT(3)  ,
							  wprov_fbaja DATE  ,
							  wprov_falta DATE ,
							  wproviibb  varchar(13) , wrubro int(3) ) RETURNS bigint(20)
BEGIN
    declare wid_proveedor bigint(10) ;
    
			insert into proveedores  ( cuit ,
			  prov_nombre ,
			  prov_razsocial ,
			  prov_pagadero ,
			  prov_direccion ,
			  prov_telefono ,
			  prov_movil ,
			  prov_cod_radio,
			  prov_email ,
			  prov_cbu,
			  bco_id ,
			  tipo_cta_id,
			  prov_nro_cta,
			  tiva_id ,
			  prov_tiene_ctacte ,
			  PROV_CONTACTO ,
			  prov_dias ,
			  prov_fbaja ,
			  prov_falta ,
			  prov_iibb, id_rubro )
			values (wcuit ,
			  wprov_nombre ,
			  wprov_razsocial ,
			  wprov_pagadero ,
			  wprov_direccion ,
			  wprov_telefono ,
			  wprov_movil ,
			  wprov_cod_radio,
			  wprov_email ,
			  wprov_cbu,
			  wbco_id ,
			  wtipo_cta_id,
			  wprov_nro_cta,
			  wtiva_id ,
			  wprov_tiene_ctacte ,
			  wPROV_CONTACTO ,
			  wprov_dias ,
			  wprov_fbaja ,
			  wprov_falta,
			  wproviibb, wrubro ) ;
			SET wid_proveedor :=  (SELECT LAST_INSERT_ID()) ;      
         RETURN wid_proveedor ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCargaProveedorRedcido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCargaProveedorRedcido`(  wcuit CHAR(11)  ,
	  wprov_nombre CHAR(40)  , wprov_razsocial CHAR(30)  ,  wprov_pagadero VARCHAR(40)  ,
	wtiva_id INT(2)  , wprov_tiene_ctacte INT(1)  , wprov_falta DATE ,WID_RUBRO INT(4)) RETURNS bigint(20)
BEGIN
    DECLARE wid_proveedor BIGINT(10) ;
    
			INSERT INTO proveedores  ( cuit ,
			  prov_nombre ,
			  prov_razsocial ,
			  prov_pagadero ,
			  tiva_id ,
			  prov_tiene_ctacte ,
			  prov_falta, 
			  ID_RUBRO )
			VALUES (wcuit ,
			  wprov_nombre ,
			  wprov_razsocial ,
			  wprov_pagadero ,
			  wtiva_id ,
			  wprov_tiene_ctacte ,
			  wprov_falta, 
			  WID_RUBRO) ;
			SET wid_proveedor :=  (SELECT LAST_INSERT_ID()) ;      
         RETURN wid_proveedor ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCargaSaldos_ctasctes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCargaSaldos_ctasctes`(wcuit char(11) ,
					wsal_ejercicio varchar(4) ,
					wsal_fecha_aplic date ,
					wsal_importe decimal(16,2),
					wsal_fechora_carga datetime ,
					wusuario_id int(10), wempre INT(4)) RETURNS int(10)
BEGIN
    declare wnroreg int(10) ;
           insert into saldos_ctasctes (cuit,
							sal_ejercicio,
							sal_fecha_aplic,
							sal_importe ,
							sal_fechora_carga,
							usuario_id ,empre_id ) values 
							(wcuit,
							wsal_ejercicio,
							wsal_fecha_aplic,
							wsal_importe ,
							wsal_fechora_carga,
							wusuario_id , wempre) ;
			set wnroreg := (SELECT ROW_COUNT());	
			return wnroreg ;		
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCarga_cobro` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCarga_cobro`(
                     Fmov_idtipo smallint(1) ,
                     Fcuit VARCHAR(15),
                     Fmmot_id int(11) , 
                     Fmov_fecha DATE , 
                     Fmov_importe_total DECIMAL(15,2), 
                     Fcaja_id INT(11), 
                     Fsucursal_id INT(11),
                     Fusuario_id INT(11), 
                     Fmov_fcreacion DATETIME , 
                     Fmov_observa VARCHAR(250) , 
                     wempre int(4) , 
                     wid_ejercicio int(4) , 
                     wmovdetalle varchar (250) , 
                     Fconcepto_id bigint(10), 
                     Fccaja_id bigint(20), 
                     Fpesos double(14,2) , 
                     Fdolares double(14,2), 
                     Fnro_comprobante varchar(20)) RETURNS bigint(20)
BEGIN
declare wreturn bigint (20) ;
	INSERT INTO movcaja(mov_idtipo,cuit,
		mmot_id,  mov_fecha, mov_importe_total,caja_id,
		sucursal_id,usuario_id, mov_fcreacion,
		mov_observa, empresa_id, ejercicio_id, mov_detalle, 
		concepto_id , ccaja_id, mov_imp_pesos, mov_imp_dolares , mov_nro_cpbte) 
	VALUES (Fmov_idtipo,    Fcuit,
		Fmmot_id,  Fmov_fecha, Fmov_importe_total, Fcaja_id, Fsucursal_id, Fusuario_id, Fmov_fcreacion, 
		Fmov_observa, wempre , wid_ejercicio, wmovdetalle, Fconcepto_id, Fccaja_id, Fpesos , Fdolares, Fnro_comprobante );
     set wreturn =  (select last_insert_id()) ; 
     return wreturn ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCarga_egreso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCarga_egreso`(Fmov_idtipo smallint(1) ,Fcuit VARCHAR(15),Fmmot_id int(11) , Fmov_fecha DATE , 
    Fmov_importe_total DECIMAL(15,2), Fcaja_id INT(11), 
    Fsucursal_id INT(11),Fusuario_id INT(11), Fmov_fcreacion DATETIME , Fmov_observa VARCHAR(250) , wempre int(4) , wid_ejercicio int(4) , 
    wmovdetalle varchar (250) , Fconcepto_id bigint(10), Fccaja_id bigint(20), Fpesos double(14,2) , Fdolares double(14,2)) RETURNS bigint(20)
BEGIN
declare wreturn bigint (20) ;
	INSERT INTO movcaja(mov_idtipo,cuit,
		mmot_id,  mov_fecha, mov_importe_total,caja_id,sucursal_id,usuario_id, mov_fcreacion,
		mov_observa, empresa_id, ejercicio_id, mov_detalle, concepto_id , ccaja_id, mov_imp_pesos, mov_imp_dolares ) 
	VALUES (Fmov_idtipo,    Fcuit,
		Fmmot_id,  Fmov_fecha, Fmov_importe_total, Fcaja_id, Fsucursal_id, Fusuario_id, Fmov_fcreacion, 
		Fmov_observa, wempre , wid_ejercicio, wmovdetalle, Fconcepto_id, Fccaja_id, Fpesos , Fdolares );
     set wreturn =  (select last_insert_id()) ; 
     return wreturn ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCertificaReten` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCertificaReten`(wtcomp_id BIGINT(20)) RETURNS int(1)
BEGIN
    DECLARE wvalor INT(1) DEFAULT 0; 
    DECLARE wprefijo VARCHAR(2) ; 
    
    SET wprefijo = (SELECT LEFT(tcomp_abrev,2) FROM tipos_comprobantes WHERE tcomp_id = wtcomp_id) ;
    IF wprefijo = "CR" THEN 
       SET WVALOR = 1;
    ELSE 
       SET WVALOR = 0;
    END IF ;
    RETURN WVALOR ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funComprobanteNumerable` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funComprobanteNumerable`(wtcomp_id BIGINT(20)) RETURNS int(10)
BEGIN
	DECLARE WRETURN INT(10) ; 
	SET WRETURN = (SELECT tcomp_numera FROM tipos_comprobantes WHERE tcomp_id = wtcomp_id) ;
	RETURN WRETURN ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funControl_ordenes_de_pago` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funControl_ordenes_de_pago`(wid_compras bigint(20)) RETURNS int(1)
BEGIN
        declare westa_op int(1) ;
        declare wnroid bigint(20) ; 
        set wnroid   =  (SELECT id_compras FROM ordenes_pago WHERE id_compras = wid_compras AND ordenp_estado = "PEND"  );
        set westa_op = isnull(wnroid) ;
        -- westa_op = 1 no esta en ninguna OP , westa_op = 0 esta en una op
        return westa_op ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funControl_Saldos_comprobantes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funControl_Saldos_comprobantes`(widcompras BIGINT(20), widventas BIGINT(20)) RETURNS double(16,2)
BEGIN
	DECLARE ftotal_pagos DOUBLE(16,2) DEFAULT 0; 
        DECLARE wImporte_comprobante DOUBLE(16,2) DEFAULT 0 ; 
	DECLARE wSaldo DOUBLE(16,2) DEFAULT 0; 
	
       IF widcompras <> 0 THEN 
	      SET wImporte_comprobante = (SELECT comp_total AS total_deuda  FROM compras WHERE id_compras = widcompras  AND ISNULL(comp_fbaja) = 1);       
	      SET ftotal_pagos = (SELECT SUM(parc_importe_pago) AS total_pagos  
	             FROM parciales_comprobantes WHERE id_compras = widcompras  AND ISNULL(parc_anulado) = 1 AND MOV_ID <> 0 );
	      SET ftotal_pagos = IF(ISNULL(ftotal_pagos )=1,0,ftotal_pagos ) ; 
	       SET wSaldo = wImporte_comprobante - ftotal_pagos ;
	ELSE 
	      
	       IF widventas <> 0 THEN 
	           SET wImporte_comprobante = (SELECT venta_total AS total_credito  FROM ventas  WHERE id_venta = widventas  AND ISNULL(venta_fbaja) = 1);
	           SET ftotal_pagos = (SELECT SUM(parc_importe_pago) AS total_pagos  FROM parciales_comprobantes WHERE id_venta = widventas  AND ISNULL(parc_anulado) = 1);
	           SET ftotal_pagos = IF(ISNULL(ftotal_pagos )=1,0,ftotal_pagos ) ;
	           -- ACA CALCULO CUANTO ME DEBE DEL COMPROBANTE 
	           -- ========================================
	           SET wSaldo = wImporte_comprobante - ftotal_pagos ;
	       END IF ;    
       END IF;
       RETURN wSaldo ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funCtrolperiodos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funCtrolperiodos`(wper varchar(6), wsave int(1)) RETURNS int(11)
BEGIN
        declare w_return int (1) ;
        if isnull(wsave)= 1 or wsave = 0  then 
				set w_return = (SELECT COUNT(*) AS cnt FROM compras_periodos_liquidados WHERE periodo = wper ) ;
		  else 		
		     insert into compras_periodos_liquidados ( periodo, comp_fproceso ) values ( wper, now() ) ; 
		     set w_return = (select row_count()) ; 
		  end if ;	
        return w_return;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funGrabachqsPropios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funGrabachqsPropios`(wfechamov DATE , wmovid BIGINT(20) ,
         wpagar_a VARCHAR(70), wfechapago DATE , wimporte DECIMAL(15,2), wcuit VARCHAR(15), wchqid BIGINT(20)) RETURNS int(10)
BEGIN
    DECLARE w_return INT (10) DEFAULT 0 ;
    UPDATE caja_cheques SET mov_id = wmovid , mov_fecha = wfechamov , 
                         stk_chq_nombre_apagar = wpagar_a , stk_chq_fvto = wfechapago ,
                         stk_chq_importe = wimporte , cuit = wcuit WHERE chq_id = wchqid ;
    SET w_return  := ROW_COUNT()                    ; 
    UPDATE MOVCAJA set mov_soloefvo = 1 where mov_id =  wmovid ;                     
    RETURN w_return ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funGrabarComprobantes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funGrabarComprobantes`( wfechaegreso datetime , widegreso bigint (20), 
         wcomprobante bigint(20), WMMOT_ID BIGINT(10), WDETALLE VARCHAR(255) , wparcial double(14,2) ) RETURNS int(10)
BEGIN
       DECLARE V_RETURN INT UNSIGNED DEFAULT 0 ;
       DECLARE WSALDO_COMPROBANTE double(16,2 ) DEFAULT 0 ;
       
       IF wparcial <> 0 THEN 
           INSERT INTO  Parciales_comprobantes (id_compras , id_venta, mov_id, parc_importe_pago, parc_importe_saldo)  
           VALUES (wcomprobante, 0,widegreso, wparcial, 0 ) ;  
       END IF ;
       
	SET WSALDO_COMPROBANTE = (SELECT comp_total AS total_deuda  FROM compras WHERE id_compras = wcomprobante  AND ISNULL(comp_fbaja) = 1);
       IF WSALDO_COMPROBANTE = 0 THEN 
	       update compras set mov_fecha = wfechaegreso , 
	       mov_id = widegreso , mmot_id = wmmot_id , comp_detalle = wdetalle  
		 where id_compras in(wcomprobante);
	ELSE 
	       UPDATE compras SET mmot_id = wmmot_id , comp_detalle = wdetalle  
		 WHERE id_compras IN(wcomprobante);		 
	END IF ;	 
       
       SET V_RETURN := ROW_COUNT() ; 
       return V_RETURN ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funGrabarComprobantes_ventas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funGrabarComprobantes_ventas`( wfechaegreso DATETIME , 
          widegreso BIGINT (20), 
          wcomprobante BIGINT(20), 
          WMMOT_ID BIGINT(10), 
          WDETALLE VARCHAR(255) , 
          wparcial DOUBLE(14,2) ) RETURNS int(10)
BEGIN
       DECLARE V_RETURN INT UNSIGNED DEFAULT 0 ;
       DECLARE WSALDO_COMPROBANTE DOUBLE(16,2 ) DEFAULT 0 ;
       
       IF wparcial <> 0 THEN 
           INSERT INTO  Parciales_comprobantes (
                id_venta, 
                id_compras ,
                mov_id, 
                parc_importe_pago, 
                parc_importe_saldo)  
           VALUES 
               (wcomprobante,
                0,
                widegreso, 
                wparcial, 
                0 ) ;  
       END IF ;
       
	SET WSALDO_COMPROBANTE = 
	  (SELECT venta_total AS total_deuda  FROM ventas WHERE id_venta = wcomprobante  AND ISNULL(venta_fbaja) = 1);
       IF WSALDO_COMPROBANTE = 0 THEN 
	       UPDATE ventas 
	            SET mov_fecha = wfechaegreso , 
	                mov_id = widegreso , 
	                mmot_id = wmmot_id , 
	                venta_detalle = wdetalle  
		 WHERE id_venta IN(wcomprobante);
	ELSE 
	       UPDATE ventas
		     SET mmot_id = wmmot_id , 
			 venta_detalle = wdetalle  
		 WHERE id_venta IN(wcomprobante);		 
	END IF ;	 
       
       SET V_RETURN := ROW_COUNT() ; 
       RETURN V_RETURN ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funModifCliente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funModifCliente`(wcli_cuit CHAR(11),
          wcli_nombre CHAR(40),
          wcli_razsoc CHAR(30),
          wcli_domicilio CHAR(60),
          wcli_telefono CHAR(60),
          wcli_movil CHAR(60),
          wcli_cod_radio CHAR(20),
          wcli_email CHAR(80),
          wbco_id INT(11),
          wtipo_cta_id INT(2),
          wcli_cta_banco CHAR(60),
          wtiva_id INT(11),
          wcli_nro_iibb CHAR(11),
          wusuario_id INT(11),
          wcli_falta DATE ,
          wcli_fbaja DATE , 
          wcli_datos_contacto CHAR(254),widcli BIGINT(20), wcli_lleva_cta INT(1)) RETURNS bigint(10)
BEGIN
      DECLARE wcntreg BIGINT(10) ;
      UPDATE clientes SET cli_cuit = wcli_cuit, 
          cli_nombre = wcli_nombre , 
          cli_razsoc = wcli_razsoc,
          cli_domicilio = wcli_domicilio,
          cli_telefono = wcli_telefono,
          cli_movil = wcli_movil,
          cli_cod_radio = wcli_cod_radio,
          cli_email = wcli_email,
          bco_id = wbco_id,
          tipo_cta_id = wtipo_cta_id,
          cli_cta_banco = wcli_cta_banco,
          tiva_id = wtiva_id,
          cli_nro_iibb = wcli_nro_iibb,
          usuario_id = wusuario_id,
          cli_falta = wcli_falta,
          cli_fbaja = wcli_fbaja,
          cli_datos_contacto = wcli_datos_contacto , 
          cli_lleva_cta = wcli_lleva_cta
          WHERE cli_id = widcli ;
			SET wcntreg  :=  (SELECT ROW_COUNT()) ;      
         RETURN wcntreg ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funModificacion_rubros` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funModificacion_rubros`(wempresa_id  INT(4 ), wrubro_codigo INT (3) , wrubro_descripcion VARCHAR(30) , wrubro_tipo VARCHAR(4), wrubro_habilitado INT(1)) RETURNS int(5)
BEGIN
       DECLARE wnroreg INT(5);
       UPDATE rubros SET rubro_descripcion = wrubro_descripcion, 
                                       rubro_tipo = wrubro_tipo, 
                                       rubro_habilitado = wrubro_habilitado  
                                       WHERE empresa_id = wempresa_id AND rubro_codigo = wrubro_codigo ; 
        SET wnroreg :=     (SELECT LAST_INSERT_ID());
        RETURN wnroreg;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funModifProveedor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funModifProveedor`(wprov_id bigint(10), wcuit CHAR(11)  ,
						  wprov_nombre CHAR(40)  ,
						  wprov_razsocial CHAR(30)  ,
						  wprov_pagadero VARCHAR(40)  ,
						  wprov_direccion CHAR(60)  ,
						  wprov_telefono CHAR(30)  ,
						  wprov_movil CHAR(20)  ,
						  wprov_cod_radio CHAR(20)  ,
						  wprov_email CHAR(60)  ,
						  wprov_cbu CHAR(30)  ,
						  wbco_id INT(11)  ,
						  wtipo_cta_id INT(5)  ,
						  wprov_nro_cta VARCHAR(30)  ,
						  wtiva_id INT(2)  ,
						  wprov_tiene_ctacte INT(1)  ,
						  wPROV_CONTACTO VARCHAR(254)  ,
						  wprov_dias INT(3)  ,
						  wprov_fbaja DATE  ,
						  wprov_falta DATE ,
						  wprovIIBB varchar(13), wrubro int(3)) RETURNS int(11)
BEGIN
	   declare wcntModificados int(2) ; 
	   update proveedores 
	    set cuit = wcuit ,
			  prov_nombre =   wprov_nombre ,
			  prov_razsocial =  wprov_razsocial ,
			  prov_pagadero =   wprov_pagadero ,
			  prov_direccion =wprov_direccion ,
			  prov_telefono = wprov_telefono,
			  prov_movil = wprov_movil,
			  prov_cod_radio = wprov_cod_radio,
			  prov_email = wprov_email,
			  prov_cbu = wprov_cbu,
			  bco_id =wbco_id ,
			  tipo_cta_id = wtipo_cta_id,
			  prov_nro_cta = wprov_nro_cta,
			  tiva_id = wtiva_id ,
			  prov_tiene_ctacte = wprov_tiene_ctacte,
			  PROV_CONTACTO= wPROV_CONTACTO ,
			  prov_dias = wprov_dias ,
			  prov_fbaja = wprov_fbaja ,
			  prov_falta = wprov_falta , 
			  prov_iibb = wprovIIBB ,
			  id_rubro = wrubro 
		where prov_id = wprov_id ;
		set wcntModificados := (select ROW_COUNT());
		return wcntModificados;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funNumComprobanteInterno` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funNumComprobanteInterno`( wempre INT(4) , idtipo INT (11) ) RETURNS bigint(20)
BEGIN
    DECLARE V_RETURN INT UNSIGNED DEFAULT 0 ;
    DECLARE v_nro BIGINT(20) DEFAULT  0 ;
    DECLARE nrotxt CHAR(20) ; 
    DECLARE wcomp INT(1) ;
    SET wcomp = (SELECT tcomp_numera FROM tipos_comprobantes WHERE tcomp_id = idtipo ) ;
    IF wcomp = 1 THEN 
      UPDATE numeradores SET num_lock = 1  WHERE tcomp_id = idtipo AND empre_id = wempre ;
		SET V_RETURN := ROW_COUNT() ; 
		IF V_RETURN > 0 THEN  
			SET v_nro = (SELECT num_valor FROM numeradores WHERE tcomp_id = idtipo AND empre_id = wempre  ) +1;
			--  SET nrotxt = CONVERT(v_nro, CHAR) ; 
			UPDATE numeradores SET num_valor = v_nro , num_lock ="0" WHERE tcomp_id = idtipo AND empre_id = wempre ;
			-- SET V_RETURN := ROW_COUNT() ; 
			SET V_RETURN := v_nro ; 
		ELSE	
		   SET V_RETURN := 0 ; 
		END IF    ;
	 ELSE
	    SET V_RETURN := -1 ;
	 END IF ; 	
	RETURN (V_RETURN);
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funNumExpedientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funNumExpedientes`(wper VARCHAR(4), wempre INT(4)) RETURNS varchar(10) CHARSET utf8
BEGIN
       DECLARE wnum BIGINT(6); 
       DECLARE newnum BIGINT (6);
       DECLARE numenv VARCHAR(10) ;
       SET wnum = (SELECT numero FROM Numerador_compras WHERE periodo = wper AND empre_id = wempre) ;
       IF ISNULL(wnum) = 0  THEN 
          SET newnum = wnum + 1 ; 
          UPDATE Numerador_compras SET numero = newnum WHERE periodo = wper AND empre_id = wempre  ;
          SET numenv = CONCAT(wper, RIGHT(CONCAT("0000000000000000",newnum),6)) ; 
       ELSE 
           SET numenv = "-1" ; 
       END IF ;
       
       RETURN numenv ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funNumExpedientes_BAK` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funNumExpedientes_BAK`(wper varchar(4)) RETURNS varchar(10) CHARSET utf8
BEGIN
       declare wnum bigint(6); 
       declare newnum bigint (6);
       DECLARE numenv varchar(10) ;
       set wnum = (select numero from Numerador_compras where periodo = wper) ;
       if isnull(wnum) = 0  then 
          set newnum = wnum + 1 ; 
          update Numerador_compras set numero = newnum where periodo = wper ;
          set numenv = concat(wper, RIGHT(CONCAT("0000000000000000",newnum),6)) ; 
       else 
          insert into Numerador_compras (periodo, numero ) values (wper,1) ;
          SET numenv = CONCAT(wper, RIGHT(CONCAT("0000000000000000",1),6)) ; 
       end if ;
       return numenv ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funNum_Certificados_retencion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funNum_Certificados_retencion`( wempre INT(4) , wsucur int(5) , idtipo int (11) ) RETURNS varchar(14) CHARSET latin1
BEGIN
    DECLARE V_RETURN varchar (14) ;
    declare v_nro bigint(20) default  0 ;
    declare nrotxt char(20) ; 
    declare wcomp int(1) ;
    declare wsucur_format varchar(5) ; 
    set wsucur_format = right(concat("00000", trim(wsucur)),5) ; 
      UPDATE numeradores SET num_lock = 1  WHERE tcomp_id = idtipo and empre_id = wempre ;
		SET wcomp := ROW_COUNT() ; 
		IF wcomp > 0 THEN  
			SET v_nro = (SELECT num_valor FROM numeradores WHERE tcomp_id = idtipo AND empre_id = wempre  ) +1;
			--  SET nrotxt = CONVERT(v_nro, CHAR) ; 
			UPDATE numeradores SET num_valor = v_nro , num_lock ="0" WHERE tcomp_id = idtipo AND empre_id = wempre ;
			-- SET V_RETURN := ROW_COUNT() ; 
			SET V_RETURN := concat(wsucur_format, "-", right(concat( "00000000",v_nro ),8)); 
		else	
		   SET V_RETURN := "0" ; 
		END IF    ;
	return (V_RETURN);
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funPeriodo_caja_vig` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funPeriodo_caja_vig`(wcaja int(11) , wsuc int(11)) RETURNS varchar(17) CHARSET utf8
BEGIN
        declare wper varchar(17) ; 
        set wper = (select concat(ccaja_periodo,",",ccaja_fecha_inicio) from cierres_caja where caja_id = wcaja and sucursal_id = wsuc and isnull(ccaja_fecha_cierre) = 1 ) ; 
        if isnull(wper) = 1 then 
           set wper = "999999,9999999999";
        end if ; 
        return wper ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funRelacion_comprobante_proceso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funRelacion_comprobante_proceso`(wempreid int(3) , wtcomp_id bigint(10) , wproceso char(4)) RETURNS int(10)
BEGIN
        DECLARE wvalor int (10) ;
	SET wvalor = (SELECT RELACION_ID FROM relacion_comprobante_procesos
	    WHERE relacion_habil = 0 AND 
	          TCOMP_ID = wtcomp_id AND 
	          PROCESO  = wproceso and 
	          empresa_id = wempreid ) ;
	IF ISNULL(wvalor) = 1 THEN 
	   set wvalor = 0  ;
	end if     ; 
	return wvalor ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `funUpdateVtas_idmov` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `funUpdateVtas_idmov`(wnrolote varchar(20), widmov bigint (20) , wfechacarga varchar(10)) RETURNS int(4)
BEGIN
       declare cntfact int (4) ; 
       UPDATE ventas SET mov_id = widmov , mov_fecha = wfechacarga  where proc_lote = wnrolote ;
       
       insert into mov_caja_det_cpbte select V.mov_id , V.tcomp_id , V.cli_cuit, V.venta_nrocpbte , 
           V.venta_fechacpbte , V.venta_total , V.venta_total as cob, 0, V.proc_lote 
           FROM VENTAS V WHERE V.proc_lote = wnrolote ; 
       set  cntfact := 0; 
       return cntfact ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fun_anulacion_cheques` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fun_anulacion_cheques`(widcta bigint(20) , wdesde bigint(20) , whasta bigint(20), widusu bigint(20)) RETURNS int(5)
BEGIN
        DECLARE whay int (5) ;
        declare wnro bigint(20) ; 
        set wnro = wdesde ; 
        SET whay = (select count(chq_id) from caja_cheques where cuenta_id = widcta and
                    STK_CHQ_NRO between wdesde and whasta and  isnull(stk_chq_anulado) = 0 ) ;
                    
        if whay = 0 then 
        
           update caja_cheques set stk_chq_anulado = date(now()) ,usuario_id_baja = widusu where cuenta_id = widcta 
                AND STK_CHQ_NRO BETWEEN wdesde AND whasta AND  ISNULL(stk_chq_anulado) = 1 ; 
           set whay = (select row_count()) ;
          
		  ELSE 
		  
		     SET whay = -1 ;  	  
		     
        end if ; 
        
        return whay  ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fun_Anular_Pagos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fun_Anular_Pagos`(wnro_op VARCHAR(10), wElimina INT(1) ) RETURNS int(1)
BEGIN
        DECLARE widcomp BIGINT(20) ; 
        DECLARE wmovid BIGINT(20) ; 
        DECLARE wsalida int(1) default 1 ; 
	SET wmovid = (SELECT MOV_ID  FROM ordenes_pago  WHERE ordenp_nro = wnro_op limit 1 );
	 -- elimina pagos 
	DELETE FROM retenciones WHERE  mov_id = wmovid ;  
	DELETE FROM transferencias WHERE  mov_id = wmovid ; 
	DELETE FROM notas_deb_creditos WHERE  mov_id = wmovid ;    
	UPDATE caja_cheques SET mov_id = NULL  , 
				mov_fecha = NULL ,  
				stk_chq_fvto = NULL  , 
				stk_chq_importe = 0 , 
				stk_chq_nombre_apagar = NULL , 
				cuit = NULL  
				WHERE mov_id = wmovid ;
	DELETE FROM parciales_comprobantes WHERE  mov_id = wmovid ; 
	update ordenes_pago set ordenes_pago.`ordenp_estado` = "ANUL" , ordenp_fecestado = now() where mov_id = wmovid ;
	UPDATE movcaja SET MOV_ANULACION = NOW() WHERE  mov_id = wmovid  ;
	return wsalida ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fun_generacion_cheques` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fun_generacion_cheques`(widcta bigint(20) , wdesde bigint(20) , whasta bigint(20), widusu bigint(20)) RETURNS int(5)
BEGIN
        DECLARE whay int (5) ;
        declare wnro bigint(20) ; 
        set wnro = wdesde ; 
        SET whay = (select count(chq_id) from caja_cheques where cuenta_id = widcta and STK_CHQ_NRO between wdesde and whasta ) ;
        if whay = 0 then 
			  WHILE wnro <= whasta DO
				 insert caja_cheques (cuenta_id , STK_CHQ_NRO, stk_chq_fAlta , usuario_id_alta ) 
					 values (widcta, wnro , date(now()) , widusu ) ; 
				 SET wnro = wnro +1 ;
				 set whay = whay +1 ; 
			  END WHILE;
		  ELSE 
		     SET whay = -1 ;  	  
        end if ; 
        
        return whay  ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fun_movcaja_actualizar_cabecera` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fun_movcaja_actualizar_cabecera`(w_cabeceraId bigint(20)) RETURNS varchar(100) CHARSET latin1
BEGIN
	declare mensaje varchar(100) default "";
	declare ingresos double(14,2) default 0.00;
	declare egresos double(14,2) default 0.00;
	declare cntMovimientos int default 0;
	
	set ingresos = (select IF(ISNULL(SUM(movcaja_total)), 0.00, SUM(movcaja_total)) from movcaja_detalles where id_cabecera_movcaja = w_cabeceraId and mov_idtipo = 0 and isnull(movcaja_fecha_anulado));
	SET egresos = (SELECT if(isnull(SUM(movcaja_total)), 0.00, SUM(movcaja_total)) FROM movcaja_detalles WHERE id_cabecera_movcaja = w_cabeceraId AND mov_idtipo = 1 and ISNULL(movcaja_fecha_anulado));	
	set cntMovimientos = (SELECT COUNT(*) FROM movcaja_detalles WHERE id_cabecera_movcaja = w_cabeceraId);
	
	update movcaja_cabecera c set movcab_ingresos = ingresos, movcab_egresos = egresos, movcab_total = ingresos - egresos, movcab_cnt_movimientos = cntMovimientos where id_cabecera_movcaja = w_cabeceraId;
	
	set mensaje = "success";
	
	return mensaje;
	
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fun_movcaja_generar_cabecera` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fun_movcaja_generar_cabecera`(w_CajaId INT, w_UsuarioId INT) RETURNS varchar(120) CHARSET latin1
BEGIN
	DECLARE ahora DATETIME DEFAULT NOW();
	DECLARE seguir INT DEFAULT 0;
	DECLARE mensaje varchar(100) DEFAULT "";
	DECLARE cabeceraAbierta INT DEFAULT 0; -- (0) = No hay, (>0) = Hay
	DECLARE idCabecera BIGINT(20) DEFAULT 0;
	DECLARE funResp INT DEFAULT 0;
	
	-- Validar si hay una cabecera abierta
	SET cabeceraAbierta = (SELECT COUNT(*) FROM movcaja_cabecera WHERE caja_id = w_CajaId AND ISNULL(movcab_cierre));
	
	IF cabeceraAbierta > 0 THEN
		SET seguir = 1;
		SET mensaje = "No es posible procesar la solicitud, hay un ejercicio abierto para esta caja.";
	END IF;
	
	IF seguir = 0 THEN
		
		INSERT INTO movcaja_cabecera (caja_id, movcab_apertura, id_usuario) VALUES (w_CajaId, ahora, w_UsuarioId);
		
		SET idCabecera = LAST_INSERT_ID();
				
		-- Verificar si hay saldo inicial para la caja
		SET funResp = fun_movcaja_saldo_inicial(w_CajaId, w_UsuarioId, idCabecera);
		
		SET mensaje = "success";
	END IF;
		
	return CONCAT(idCabecera, ";", mensaje);
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fun_movcaja_saldo_inicial` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 FUNCTION `fun_movcaja_saldo_inicial`(w_CajaId int, w_UsuarioId int, w_idCabecera bigint) RETURNS int(11)
BEGIN
	DECLARE haySaldo INT DEFAULT 0;
	DECLARE idSaldo BIGINT(20) DEFAULT 0;
	DECLARE montoSaldo DOUBLE(12,2) DEFAULT 0.00;
	DECLARE ahora DATETIME DEFAULT NOW();
	DECLARE mensaje TEXT DEFAULT "";
	declare resp int default 0;
		
	SET haySaldo = (SELECT COUNT(*) FROM movcaja_saldo_inicial WHERE caja_id = w_CajaId AND ISNULL(saini_fecha_uso));
	IF haySaldo > 0 THEN		
		SET idSaldo = (SELECT saini_id FROM movcaja_saldo_inicial WHERE caja_id = w_CajaId AND ISNULL(saini_fecha_uso) LIMIT 1);
		SET montoSaldo = (SELECT saini_monto FROM movcaja_saldo_inicial WHERE saini_id = idSaldo);
			
		-- Cargar movcaja_detalles saldo de apertura
		INSERT INTO movcaja_detalles(caja_id, mov_idtipo, movcaja_feccarga, concepto_id, tcomp_id, movcaja_nro_cpbte, CUIT, tdoc_id, nro_doc, movcaja_nombre, movcaja_bruto_bruto, movcaja_total, id_usuario, id_cabecera_movcaja) VALUES (w_CajaId, 0, ahora, 101, 0, "", "", 0, "", "", montoSaldo, montoSaldo, w_UsuarioId, w_idCabecera);
			
		-- Actualizar movcaja_saldo_inicial
		UPDATE movcaja_saldo_inicial SET saini_fecha_uso = ahora, id_cabecera_movcaja_ing = w_idCabecera WHERE saini_id = idSaldo;
			
		-- Actualizar movcaja_cabecera
		UPDATE movcaja_cabecera SET saini_monto = montoSaldo WHERE id_cabecera_movcaja = w_idCabecera;
			
		-- Actualizar monto movcaja_cabecera
		SET mensaje = fun_movcaja_actualizar_cabecera(w_idCabecera);
		
	END IF;
	
	return resp;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Alta_depositos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `Alta_depositos`(wfecha DATE , widcta  bigint(10), wnota VARCHAR(250), wlista VARCHAR(500))
BEGIN
		DECLARE wfechacarga DATETIME DEFAULT NOW() ; 
		DECLARE wnumlast BIGINT(20) DEFAULT 0 ; 
		-- DECLARE @wxx VARCHAR(500) DEFAULT "" ; 
       INSERT INTO bancos_depositos (dep_fecha , CUENTA_ID , dep_notas , dep_carga ) VALUES (wfecha, widcta, wnota,wfechacarga);
       SET wnumlast := (SELECT LAST_INSERT_ID()) ; 
       SET @wxx := CONCAT("UPDATE mov_cheques_terceros SET deposito_id = ", wnumlast,", chqt_fdeposito = '" , wfecha  ,"'  WHERE chqt_id IN (",wlista,")"); 
       -- set @wxcomm := trim(@wxcomm) ; 
       prepare stmt from @wxx ; 
       execute stmt ; 
       DEALLOCATE PREPARE stmt;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `consulta_chqs_terceros` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `consulta_chqs_terceros`( wtipo int(1) , wfd DATE, wfh DATE)
BEGIN
       if isnull(wtipo) = 1 then 
          set wtipo = 0 ;
       end if ;
		 -- CHEQUES VENCIDOS
		 -- =====================       
		 IF wtipo = 0 THEN 
						SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1  AND chqt_fvto < DATE(NOW()) ORDER BY chqt_fvto ASC ;
		 end if; 
		 -- POR ANULADOS
		 -- =====================		 
       IF wtipo = 1 THEN 
						SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 0 AND chqt_anulado between wfd and wfh AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1  order by chqt_anulado asc  ;
		 END IF ;
		 -- CHEQUES A VENCER
		 -- =====================		 
       IF wtipo = 2 THEN 
						SELECT a.* , b.bco_descripcion, 0 as tmpopcion FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1 and chqt_fvto between wfd and wfh order by chqt_fvto ;
		 END IF 	;	 
		 -- POR FECHA DE CAMBIO 
		 -- =====================		 		 
       IF wtipo = 3 THEN 
						SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 0  and chqt_cambio BETWEEN wfd AND wfh ORDER BY chqt_cambio ;
		 END IF ;	
		 -- POR FECHA DE ENTREGADO 
		 -- =====================			 
		 IF wtipo = 4 THEN 
						SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 0 AND chqt_entregado BETWEEN wfd AND wfh  AND 
				 ISNULL(chqt_cambio) = 1  ORDER BY chqt_entregado ASC ;
		 END IF ;	
		 -- CHEQUES DEPOSITADOS
		 -- =====================			 
		 IF wtipo = 5 THEN 
						SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 0 AND  chqt_fdeposito BETWEEN wfd AND wfh  AND
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1  ORDER BY chqt_fdeposito ASC ;
		 END IF ;	    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ctactecompras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `ctactecompras`(wempre INT(4), wcuit CHAR(11) , wfdesde DATE , wfhasta DATE )
BEGIN
      IF wempre <> 0  THEN 
	      SELECT COMP_FECHACPBTE, CONCAT(TCOMP_DESCRIPCION,": ",COMP_NROCPBTE) AS CPBTE , 
	             (COMP_TOTAL * TCOMP_SIGNO) AS COMP_TOTAL
		  FROM COMPRAS C, TIPOS_COMPROBANTES TC
	       WHERE TC.TCOMP_ID = C.TCOMP_ID 
		     AND ISNULL(COMP_FBAJA) = 1 
		     AND tcomp_cpo1 <> "X"
		     AND CUIT = wcuit 
		     AND empresa_id = wempre 
		     AND  comp_fechacpbte BETWEEN  wfdesde AND wfhasta ; 
	ELSE 
	      SELECT COMP_FECHACPBTE, CONCAT(TCOMP_DESCRIPCION,": ",COMP_NROCPBTE) AS CPBTE , 
	              (COMP_TOTAL * TCOMP_SIGNO) AS COMP_TOTAL	
		  FROM COMPRAS C, TIPOS_COMPROBANTES TC
	       WHERE TC.TCOMP_ID = C.TCOMP_ID 
		     AND ISNULL(COMP_FBAJA) = 1 
		     AND tcomp_cpo1 <> "X"
		     AND CUIT = wcuit 
		     AND  comp_fechacpbte BETWEEN  wfdesde AND wfhasta ; 	      	     
       END IF ;		     
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ctactemovcaja` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `ctactemovcaja`(wempre INT(4), wcuit CHAR(11) , wfdesde DATE , wfhasta DATE)
BEGIN
	IF wempre <> 0  THEN 
	     SELECT 0 AS mov_tipo , MOV_FECHA ,  
	      TRIM(mov_detalle) AS CPBTE ,   
		  MOV_IMPORTE_TOTAL  AS IMPORTE , MOV_ID 
	      FROM MOVCAJA 
	         WHERE CUIT = wcuit AND  
	         empresa_id = wempre AND 
	          MOV_FECHA BETWEEN wfdesde AND wfhasta AND 
	          ISNULL(MOV_ANULACION) = 1 ;
	ELSE 
	     SELECT 0 AS mov_tipo , MOV_FECHA ,  
	      TRIM(mov_detalle) AS CPBTE ,   
		  MOV_IMPORTE_TOTAL  AS IMPORTE , MOV_ID
	      FROM MOVCAJA WHERE CUIT = wcuit  AND  MOV_FECHA BETWEEN wfdesde AND wfhasta AND 
	          ISNULL(MOV_ANULACION) = 1 ;	
	END IF ;
      
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ctacteventas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `ctacteventas`(wcuit char(11) , wAgrupada int(1), wfdesde date , wfhasta date , wempre int(4))
BEGIN
      if wempre = 0 then  
              if wAgrupada = 1 then 
		      SELECT mov_id, venta_FECHACPBTE, CONCAT("Agrupadas",": ",proc_lote) AS CPBTE , SUM(venta_TOTAL	) AS venta_total
			  FROM ventas C, TIPOS_COMPROBANTES TC
		       WHERE TC.TCOMP_ID = C.TCOMP_ID 
			     AND (ISNULL(venta_FBAJA) = 1 OR ISNULL(venta_anulado) = 1)
			     AND tcomp_cpo1 <> "X"
			     AND  venta_fcarga BETWEEN wfdesde AND wfhasta
			     AND ISNULL(mov_id ) = 0 
			     GROUP BY mov_id ; 
	       else
		      SELECT venta_FECHACPBTE, CONCAT(TCOMP_DESCRIPCION,": ",venta_NROCPBTE) AS CPBTE , venta_TOTAL	
			  FROM ventas C, TIPOS_COMPROBANTES TC
		       WHERE TC.TCOMP_ID = C.TCOMP_ID 
			     AND (ISNULL(venta_FBAJA) = 1 OR ISNULL(venta_anulado) = 1)
			     AND tcomp_cpo1 <> "X"
			     AND cli_CUIT = wcuit 
			     AND  venta_fechacpbte BETWEEN  wfdesde AND wfhasta ;	               
	       end if 	;     
      else 
	      SELECT venta_FECHACPBTE, CONCAT(TCOMP_DESCRIPCION,": ",venta_NROCPBTE) AS CPBTE , venta_TOTAL	
		  FROM ventas C, TIPOS_COMPROBANTES TC
	       WHERE TC.TCOMP_ID = C.TCOMP_ID 
		     AND (ISNULL(venta_FBAJA) = 1 or ISNULL(venta_anulado) = 1)
		     and tcomp_cpo1 <> "X"
		     AND cli_CUIT = wcuit 
		     AND  c.empre_id = wempre  
		     and  venta_fechacpbte between  wfdesde and wfhasta ; 
	end if;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Modifica_depositos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `Modifica_depositos`(wid_dep BIGINT(20), wfecha_dep DATE , wfecha_anul DATE , widcta_dep  BIGINT(10), wnota VARCHAR(250))
BEGIN
	
	UPDATE bancos_depositos SET dep_fecha= wfecha_dep , 
				    dep_anulado = wfecha_anul , 
				    cuenta_id = widcta_dep , 
				    dep_notas = wnota 
		WHERE deposito_id = wid_dep ;
		
	UPDATE mov_cheques_terceros SET chqt_fdeposito =  wfecha_dep WHERE   deposito_id =  wid_dep ;
       
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mostrar_caja_sucur` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `mostrar_caja_sucur`(WCAJA BIGINT(10))
BEGIN 
		SELECT sucur_descripcion AS SUCUR , CAJA_DESCRIPCION AS CAJA 
        FROM CAJAS C, SUCURSALES S 
        WHERE C.`sucursal_id` = S.`sucursal_id` AND C.CAJA_ID = WCAJA ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mostrar_cartera_propia_libre` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `mostrar_cartera_propia_libre`(wcuenta bigint(20), wvisto int(1))
BEGIN
    if wvisto = 0 then 
			/**que tengan vto y a su vez esten anulados */
			SELECT stk_chq_nro , stk_chq_nombre_apagar, stk_chq_importe, stk_chq_fvto , 
				chq_id, ch.cuenta_id , bco_descripcion, 
				IF(ISNULL(stk_chq_anulado)=1,SPACE(20),stk_chq_anulado) AS anulado ,
				IF(ISNULL(stk_chq_femisin)=1,SPACE(20),stk_chq_femisin) AS emision ,
				IF(ISNULL(stk_chq_falta)=1,SPACE(20),stk_chq_falta) AS alta , 
				IF(ISNULL(stk_chq_fvto)=1,SPACE(20),stk_chq_fvto) AS VTO , stk_chq_nombre_apagar as apagar 
			FROM caja_cheques ch, caja_cuentas c , bancos_sucursales b 
				WHERE ch.`cuenta_id` = c.`cuenta_id` AND 
						b.bco_id = c.bco_id AND 
						ch.cuenta_id = wcuenta and stk_chq_importe = 0 
						and isnull(stk_chq_fvto) = 1 AND  ISNULL(stk_chq_anulado) = 1 
						  ORDER BY stk_chq_nro  ; 
	  end if ; 					
     IF wvisto = 1 THEN 
			/* Solo anulados */
			SELECT stk_chq_nro , stk_chq_nombre_apagar, stk_chq_importe, stk_chq_fvto , 
			chq_id, ch.cuenta_id , bco_descripcion, 
			IF(ISNULL(stk_chq_anulado)=1,SPACE(20),stk_chq_anulado) AS anulado ,
			IF(ISNULL(stk_chq_femisin)=1,SPACE(20),stk_chq_femisin) AS emision ,
			IF(ISNULL(stk_chq_falta)=1,SPACE(20),stk_chq_falta) AS alta , 
					IF(ISNULL(stk_chq_fvto)=1,SPACE(20),stk_chq_fvto) AS VTO , stk_chq_nombre_apagar AS apagar 
			FROM caja_cheques ch, caja_cuentas c , bancos_sucursales b 
				WHERE ch.`cuenta_id` = c.`cuenta_id` AND 
						b.bco_id = c.bco_id AND 
						ch.cuenta_id = wcuenta AND 
						stk_chq_importe <> 0 AND 
						ISNULL(stk_chq_fvto) = 0 
						     and isnull(stk_chq_anulado) = 1  ORDER BY stk_chq_nro  ; 
	   END IF ; 	
      IF wvisto = 2 THEN 
		/*todos sin anular*/
		SELECT stk_chq_nro , stk_chq_nombre_apagar, stk_chq_importe, stk_chq_fvto , 
				chq_id, ch.cuenta_id , bco_descripcion, 
				IF(ISNULL(stk_chq_anulado)=1,SPACE(20),stk_chq_anulado) AS anulado ,
				IF(ISNULL(stk_chq_femisin)=1,SPACE(20),stk_chq_femisin) AS emision ,
				IF(ISNULL(stk_chq_falta)=1,SPACE(20),stk_chq_falta) AS alta , 
				IF(ISNULL(stk_chq_fvto)=1,SPACE(20),stk_chq_fvto) AS VTO , stk_chq_nombre_apagar AS apagar 
		FROM caja_cheques ch, caja_cuentas c , bancos_sucursales b 
			WHERE ch.`cuenta_id` = c.`cuenta_id` AND 
					b.bco_id = c.bco_id AND 
					ch.cuenta_id = wcuenta  AND ISNULL(stk_chq_anulado) = 0
					 ORDER BY stk_chq_nro  ; 
	    END IF ; 	  
      IF wvisto = 3 THEN 
		SELECT stk_chq_nro , stk_chq_nombre_apagar, stk_chq_importe, stk_chq_fvto , 
			chq_id, ch.cuenta_id , bco_descripcion, 
			IF(ISNULL(stk_chq_anulado)=1,SPACE(20),stk_chq_anulado) AS anulado ,
			IF(ISNULL(stk_chq_femisin)=1,SPACE(20),stk_chq_femisin) AS emision ,
			IF(ISNULL(stk_chq_falta)=1,SPACE(20),stk_chq_falta) AS alta , 
			IF(ISNULL(stk_chq_fvto)=1,SPACE(20),stk_chq_fvto) AS VTO , stk_chq_nombre_apagar AS apagar 
		FROM caja_cheques ch, caja_cuentas c , bancos_sucursales b 
			WHERE ch.`cuenta_id` = c.`cuenta_id` AND 
					b.bco_id = c.bco_id AND 
					ch.cuenta_id = wcuenta 
					 ORDER BY stk_chq_nro  ; 
	    END IF ; 	     	       
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mostrar_chqs_terceros` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `mostrar_chqs_terceros`( wtipo INT(1))
BEGIN
       IF ISNULL(wtipo) = 1 THEN 
          SET wtipo = 0 ;
       END IF ;
       IF wtipo = 0 THEN 
          /* TODOS LOS CHQS TERCEROS DISPONIBLES 
          -----------------------------------------*/
	  SELECT a.* , b.bco_descripcion, 0 AS tmpopcion FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1  AND 
				 id_egreso = 0  ;
	 END IF; 
       IF wtipo = 1 THEN 
          /* TODOS LOS CHQS TERCEROS ANULADOS --
          -----------------------------------------*/       
	  SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 0 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1 AND 
				 id_egreso = 0  ;
	 END IF ;
       IF wtipo = 2 THEN 
          /* TODOS LOS CHQS TERCEROS DEPOSITADOS --
          ----------------------------------------- */      
	  SELECT a.* , b.bco_descripcion, 0 AS tmpopcion FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 0 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1 AND 
				 id_egreso = 0  ;
	 END IF 	;	 		 		 
       IF wtipo = 3 THEN 
          /* TODOS LOS CHQS TERCEROS CAMBIADOS --
          -----------------------------------------*/       
	  SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 0 AND 
				 id_egreso = 0  ;
	 END IF ;	
	IF wtipo = 4 THEN 
          /*  TODOS LOS CHQS TERCEROS ENTREGADO --
          -----------------------------------------*/	
	   SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
		  WHERE b.bco_id = a.bco_id AND 
			 ISNULL(chqt_anulado) = 1 AND 
			 ISNULL(chqt_fdeposito) = 1 AND 
			 ISNULL(chqt_entregado) = 0 AND 
			 ISNULL(chqt_cambio) = 1 AND 
				 id_egreso = 0  ;
	 END IF ;	
	IF wtipo = 5 THEN 
          /* TODOS LOS CHQS TERCEROS USADOS EN PAGOS 
          ---------------------------------------------*/	
	   SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
		  WHERE b.bco_id = a.bco_id AND 
			 ISNULL(chqt_anulado) = 1 AND 
			 ISNULL(chqt_fdeposito) = 1 AND 
			 ISNULL(chqt_entregado) = 1 AND 
			 ISNULL(chqt_cambio) = 1 AND 
				 id_egreso <> 0  ;
	 END IF ;		 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mostrar_chqs_terceros_clientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `mostrar_chqs_terceros_clientes`( wtipo INT(1))
BEGIN
       IF ISNULL(wtipo) = 1 THEN 
          SET wtipo = 0 ;
       END IF ;
       IF wtipo = 0 THEN 
          /* TODOS LOS CHQS TERCEROS DISPONIBLES 
          -----------------------------------------*/
	  SELECT a.* , b.bco_descripcion, 0 AS tmpopcion, c.cli_nombre as cliente , m.mov_nro_cpbte as cpbte  
	            FROM mov_cheques_terceros a, bancos_sucursales b , movcaja m , clientes c 
			  WHERE b.bco_id = a.bco_id AND m.mov_id = a.mov_id and c.cli_cuit = m.cuit  and 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1  AND 
				 id_egreso = 0  ;
	 END IF; 
       IF wtipo = 1 THEN 
          /* TODOS LOS CHQS TERCEROS ANULADOS --
          -----------------------------------------*/       
	  SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 0 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1 AND 
				 id_egreso = 0  ;
	 END IF ;
       IF wtipo = 2 THEN 
          /* TODOS LOS CHQS TERCEROS DEPOSITADOS --
          ----------------------------------------- */      
	  SELECT a.* , b.bco_descripcion, 0 AS tmpopcion FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 0 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1 AND 
				 id_egreso = 0  ;
	 END IF 	;	 		 		 
       IF wtipo = 3 THEN 
          /* TODOS LOS CHQS TERCEROS CAMBIADOS --
          -----------------------------------------*/       
	  SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
			  WHERE b.bco_id = a.bco_id AND 
				 ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 0 AND 
				 id_egreso = 0  ;
	 END IF ;	
	IF wtipo = 4 THEN 
          /*  TODOS LOS CHQS TERCEROS ENTREGADO --
          -----------------------------------------*/	
	   SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
		  WHERE b.bco_id = a.bco_id AND 
			 ISNULL(chqt_anulado) = 1 AND 
			 ISNULL(chqt_fdeposito) = 1 AND 
			 ISNULL(chqt_entregado) = 0 AND 
			 ISNULL(chqt_cambio) = 1 AND 
				 id_egreso = 0  ;
	 END IF ;	
	IF wtipo = 5 THEN 
          /* TODOS LOS CHQS TERCEROS USADOS EN PAGOS 
          ---------------------------------------------*/	
	   SELECT a.* , b.bco_descripcion, 0 AS tmpopcion  FROM mov_cheques_terceros a, bancos_sucursales b 
		  WHERE b.bco_id = a.bco_id AND 
			 ISNULL(chqt_anulado) = 1 AND 
			 ISNULL(chqt_fdeposito) = 1 AND 
			 ISNULL(chqt_entregado) = 1 AND 
			 ISNULL(chqt_cambio) = 1 AND 
				 id_egreso <> 0  ;
	 END IF ;		 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mostrar_cuentas_bancarias` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `mostrar_cuentas_bancarias`(muestrabajas int(1))
BEGIN
       if muestra_bajas = 0 then 
          SELECT CONCAT(bco_descripcion , ' - Suc.: ' , cta_sucursal ,' - A nombre: ' , cta_nombres ,' - Cta: ' ,  cta_numero ) AS titcta , 
                cuenta_id FROM caja_cuentas c, bancos_sucursales b 
                WHERE  b.bco_id = c.bco_id AND ISNULL(cta_fbaja) = 0 ;
       else 
           
          SELECT CONCAT(bco_descripcion , ' - Suc.: ' , cta_sucursal ,' - A nombre: ' , cta_nombres ,' - Cta: ' ,  cta_numero ) AS titcta , 
                cuenta_id FROM caja_cuentas c, bancos_sucursales b 
                WHERE  b.bco_id = c.bco_id AND ISNULL(cta_fbaja) = 1  ;        
       end if ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mostrar_ejercicio_vigente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `mostrar_ejercicio_vigente`(wempre int(4))
BEGIN
           SELECT ejercicio_id , ejercicio_nro , ejer_fdesde FROM ejercicios WHERE empresa_id = wempre AND ISNULL(ejer_fhasta) = 1 ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `MOSTRAR_MOV_CAJA` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `MOSTRAR_MOV_CAJA`( wxsucur int(11), wxcaja int(11) , wxccaja_id int(11))
BEGIN
      
      DECLARE WMOV_ID BIGINT(20) ;
      DECLARE WMOV_FECHA DATE ;
      DECLARE WMOV_DETALLE VARCHAR(100) ;
      DECLARE WCOMPROBANTE VARCHAR(20) ;
      DECLARE WIMPORTE DECIMAL (14,2) ;
      DECLARE WCONCEPTO_ID BIGINT(10) ; 
      DECLARE WMOVTIPO INT(1) ;       
      DECLARE WCHQ CHARACTER(1) DEFAULT "T" ;
      DECLARE WCHQ_ID BIGINT(20) ;
      DECLARE WBCO_ID int(11);
      DECLARE WBCO_DETALLE VARCHAR(100) ;
      DECLARE WNRO_CHQ VARCHAR(10) ;
      DECLARE WCHQ_VTO DATE ; 
      DECLARE WCHQ_IMPORTE DECIMAL(14,2) ;
      DECLARE Wtcomp_id INT(11) ;   
      DECLARE Wmov_nro_cpbte VARCHAR(20) ;
      DECLARE WSUCUR INT(11) ;
      DECLARE WCAJA INT(11)   ; 
      DECLARE WIMPPESOS DECIMAL(10,2) DEFAULT 0  ;
      DECLARE WIMPDOLARES DECIMAL (10,2) DEFAULT 0 ; 
      DECLARE Wmov_soloefvo INT(1) DEFAULT 0 ; 
      declare hacer INT(1) DEFAULT 0 ; 
      DECLARE cRegcaja CURSOR FOR SELECT MOV_ID, MOV_FECHA , MOV_DETALLE  , mov_importe_total ,  CONCEPTO_ID , 
                MOV_IDTIPO , tcomp_id , mov_nro_cpbte , SUCURSAL_ID , CAJA_ID , MOV_IMP_DOLARES , MOV_IMP_PESOS , mov_soloefvo
                FROM MOVCAJA  WHERE SUCURSAL_ID =wxsucur AND CAJA_ID = wxcaja and CCaja_id = wxccaja_id  AND ISNULL(MOV_ANULACION) = 1; 
      
      DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET hacer = 1;    
        
      DROP TABLE IF EXISTS  CAJA_TEMP ;
      CREATE TEMPORARY TABLE CAJA_TEMP ( MOV_ID BIGINT(20) , 
               MOV_FECHA DATE , 
               MOV_DETALLE VARCHAR(100) ,
               COMPROBANTE VARCHAR(20) , 
               IMPORTE DECIMAL (14,2) , 
               CONCEPTO_ID BIGINT(10) , 
               MOV_IDTIPO INT(1) default 0 , 
               CHQ CHARACTER(1) DEFAULT "T" , 
               CHQ_ID BIGINT(20)DEFAULT 0  , 
               BCO_ID INT(11) DEFAULT  0, 
               BCO_DETALLE VARCHAR(100) DEFAULT " " , 
               NRO_CHQ VARCHAR(10) DEFAULT " ",
               CHQ_VTO CHAR(10) DEFAULT " " ,                 
               CHQ_IMPORTE DECIMAL (14,2) DEFAULT 0 ,
               sucursal_id INT(11) , 
               CAJA_ID INT(11) , 
               IMPDOLARES DECIMAL (10,2) DEFAULT 0,
               IMPPESOS DECIMAL(10,2) DEFAULT 0   ) ;
                
      OPEN cRegcaja ;
      set hacer = 0 ; 
      REPEAT         
        FETCH NEXT FROM cRegcaja
            INTO WMOV_ID, WMOV_FECHA ,WMOV_DETALLE  , WIMPORTE ,  WCONCEPTO_ID , WMOVTIPO, 
                  wtcomp_id , wmov_nro_cpbte ,WSUCUR , WCAJA , WIMPDOLARES , WIMPPESOS , Wmov_soloefvo ;
            
         if hacer=0 then          
            if Wtcomp_id > 0 then 
               SET WCOMPROBANTE = (select tcomp_abrev from tipos_comprobantes where tcomp_id = wtcomp_id );    
               set wcomprobante = concat(wcomprobante,"-",wmov_nro_cpbte) ; 
            else    
               SET WCOMPROBANTE = "" ;    
            end if  ;
            
            INSERT INTO CAJA_TEMP (MOV_ID , MOV_FECHA , MOV_DETALLE ,cOMPROBANTE ,IMPORTE ,CONCEPTO_ID , 
                                    MOV_IDTIPO, SUCURSAL_ID , CAJA_ID, IMPDOLARES ,IMPPESOS) 
                   VALUES (wMOV_ID , wMOV_FECHA , wMOV_DETALLE ,WCOMPROBANTE ,wIMPORTE ,wCONCEPTO_ID , 
                           wMOVTIPO ,WSUCUR , WCAJA, WIMPDOLARES , WIMPPESOS) ;
            IF Wmov_soloefvo = 1 THEN                
		INSERT INTO CAJA_TEMP  
			SELECT WMOV_ID ,WMOV_FECHA,WMOV_DETALLE ,WCOMPROBANTE ,WIMPORTE ,WCONCEPTO_ID,WMOVTIPO , "T"  ,
			  CT.CHQT_ID, CT.BCO_ID ,LEFT(B.BCO_DESCRIPCION,30) ,  CT.CHQT_NRO , CT.CHQT_FVTO , 
			  CT.CHQT_IMPORTE, WSUCUR , WCAJA , WIMPDOLARES , WIMPPESOS
			  FROM mov_cheques_terceros CT , bancos_sucursales B 
				  WHERE  B.BCO_ID = CT.BCO_ID  AND  MOV_ID = WMOV_ID ;
							  
		insert into CAJA_TEMP  
			SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE , WCOMPROBANTE , WIMPORTE , WCONCEPTO_ID, WMOVTIPO  , "T" ,
			  CT.CHQT_ID, CT.BCO_ID ,LEFT(B.BCO_DESCRIPCION,30) ,  CT.CHQT_NRO , CT.CHQT_FVTO , 
			  CT.CHQT_IMPORTE, WSUCUR , WCAJA , WIMPDOLARES , WIMPPESOS
			  FROM mov_cheques_terceros CT , bancos_sucursales B 
				 WHERE  B.BCO_ID = CT.BCO_ID  AND  ID_EGRESO = WMOV_ID ;
						
		INSERT INTO CAJA_TEMP  
		  SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE , WCOMPROBANTE , WIMPORTE , WCONCEPTO_ID, WMOVTIPO , "P"  ,
			  cc.`chq_id`, cc.`cuenta_id`, CONCAT(LEFT(B.`bco_descripcion`,20), "#" , cta.CTA_NUMERO ) , 
			  cc.stk_chq_nro , cc.stk_chq_fvto, cc.`stk_chq_importe`,  WSUCUR , WCAJA, WIMPDOLARES , WIMPPESOS
			  FROM  caja_cheques cc ,  CAJA_CUENTAS cta , bancos_sucursales B 
				  WHERE  cta.cuenta_id = cc.cuenta_id AND B.`bco_id`= cta.`bco_id` AND cc.mov_id = WMOV_ID ;
	    END IF ; 
         end if ;	
      UNTIL hacer END REPEAT;  
		 
      select * from caja_temp ORDER BY MOV_FECHA, MOV_ID , CHQ_ID asc ; 
      DROP TABLE IF EXISTS  CAJA_TEMP ;
       
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `MOSTRAR_MOV_CAJA_11` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `MOSTRAR_MOV_CAJA_11`( wxsucur INT(11), wxcaja INT(11) , wxccaja_id INT(11))
BEGIN
 
      DROP TABLE IF EXISTS  CAJA_TEMP ;
      CREATE TEMPORARY TABLE CAJA_TEMP ( MOV_ID BIGINT(20) , 
               MOV_FECHA DATE , 
               MOV_DETALLE VARCHAR(250) ,
               COMPROBANTE VARCHAR(20) , 
               IMPORTE DECIMAL (14,2) , 
               CONCEPTO_ID BIGINT(11) , 
               MOV_IDTIPO INT(1) DEFAULT 0 , 
               CHQ CHARACTER(1) DEFAULT "T" , 
               CHQ_ID BIGINT(20)DEFAULT 0  , 
               BCO_ID INT(11) DEFAULT  0, 
               BCO_DETALLE VARCHAR(100) DEFAULT " " , 
               NRO_CHQ VARCHAR(20) DEFAULT " ",
               CHQ_VTO DATE DEFAULT '0000-00-00'   ,                 
               CHQ_IMPORTE DECIMAL (14,2) DEFAULT 0 ,
               sucursal_id INT(11) , 
               CAJA_ID INT(11) , 
               IMPDOLARES DECIMAL (10,2) DEFAULT 0,
               IMPPESOS DECIMAL(10,2) DEFAULT 0  , 
               cuentaid BIGINT(20) DEFAULT 0  ) ;
                
      -- CARGA MOVIMIENTO DE LA CAJA 
      INSERT INTO CAJA_TEMP (MOV_ID , MOV_FECHA , MOV_DETALLE ,cOMPROBANTE ,IMPORTE ,CONCEPTO_ID , 
                                    MOV_IDTIPO, SUCURSAL_ID , CAJA_ID, IMPDOLARES ,IMPPESOS) 
                     SELECT MV.MOV_ID, MV.MOV_FECHA , MV.MOV_DETALLE ,
                      mov_nro_cpbte   ,
                     MV.MOV_IMPORTE_TOTAL ,MV.CONCEPTO_ID ,MV.MOV_IDTIPO, 
                     MV.SUCURSAL_ID , MV.CAJA_ID, MV.MOV_IMP_DOLARES ,MV.MOV_IMP_PESOS 
                                    FROM MOVCAJA MV 
                                    WHERE   MV.MOV_ID IN (SELECT CR.MOV_ID FROM movcaja CR WHERE SUCURSAL_ID =wxsucur AND 
							CAJA_ID = wxcaja AND 
							CCaja_id = wxccaja_id  AND 
							ISNULL(MOV_ANULACION) = 1);  
                     
      -- CARGO LOS CHEQUES DE TERCEROS 
		INSERT INTO CAJA_TEMP  (MOV_ID , MOV_FECHA , MOV_DETALLE ,cOMPROBANTE ,IMPORTE ,CONCEPTO_ID , 
                                    CHQ, SUCURSAL_ID , CAJA_ID, IMPDOLARES ,IMPPESOS, 
                                               CHQ_ID , 
					       BCO_ID , 
					       BCO_DETALLE  , 
					       NRO_CHQ ,
					       CHQ_VTO  ,                 
					       CHQ_IMPORTE ) 			       
			SELECT ct.MOV_ID ,MV.MOV_FECHA ," " ," "  ,0,0 , "T" ,0, 0 , 0, 0 ,  
			  CT.CHQT_ID, CT.BCO_ID ,LEFT(B.BCO_DESCRIPCION,30) ,  CT.CHQT_NRO , CT.CHQT_FVTO , 
			  CT.CHQT_IMPORTE
			  FROM mov_cheques_terceros CT , bancos_sucursales B , MOVCAJA MV
				  WHERE  B.BCO_ID = CT.BCO_ID  AND MV.MOV_ID = CT.MOV_ID AND 
				     (ct.MOV_ID IN (SELECT CR.MOV_ID FROM movcaja CR WHERE SUCURSAL_ID =wxsucur AND 
							CAJA_ID = wxcaja AND 
							CCaja_id = wxccaja_id  AND 
							ISNULL(MOV_ANULACION) = 1) OR
				       ct.MOV_ID IN (SELECT CR.MOV_ID FROM movcaja CR WHERE SUCURSAL_ID =wxsucur AND 
							CAJA_ID = wxcaja AND 
							CCaja_id = wxccaja_id  AND 
							ISNULL(MOV_ANULACION) = 1));  
      
      -- CARGO LOS CHEQUES PROPIOS
		INSERT INTO CAJA_TEMP  (MOV_ID , MOV_FECHA , MOV_DETALLE ,cOMPROBANTE ,IMPORTE ,CONCEPTO_ID , 
                                    CHQ, SUCURSAL_ID , CAJA_ID, IMPDOLARES ,IMPPESOS, 
                                               CHQ_ID , 
					       BCO_ID , 
					       BCO_DETALLE  , 
					       NRO_CHQ ,
					       CHQ_VTO  ,                 
					       CHQ_IMPORTE )
			SELECT cc.MOV_ID ,MV.MOV_FECHA ," " ," "  ,0,0 , "P" ,0, 0 , 0, 0 ,
			  cc.chq_id, cc.cuenta_id,  CONCAT(LEFT(B.`bco_descripcion`,20), "#" , cta.CTA_NUMERO ) , 
			  cc.stk_chq_nro , cc.stk_chq_fvto, cc.`stk_chq_importe`
			  FROM  caja_cheques cc ,  CAJA_CUENTAS cta , bancos_sucursales B , MOVCAJA MV
				  WHERE  
				  cta.cuenta_id = cc.cuenta_id AND 
				  B.`bco_id`= cta.`bco_id` AND  MV.MOV_ID = CC.MOV_ID AND 
				  cc.mov_id IN (SELECT CR.MOV_ID FROM movcaja CR WHERE SUCURSAL_ID =wxsucur AND 
							CAJA_ID = wxcaja AND 
							CCaja_id = wxccaja_id  AND 
							ISNULL(MOV_ANULACION) = 1) ;
   		 
      SELECT * FROM caja_temp ORDER BY MOV_FECHA,  MOV_ID , CHQ_ID ASC ; 
      DROP TABLE IF EXISTS  CAJA_TEMP ;
       
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mostrar_mov_caja_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `mostrar_mov_caja_id`(  wxmov_id BIGint(20))
BEGIN
      
      DECLARE WMOV_ID BIGINT(20) ;
      DECLARE WMOV_FECHA DATE ;
      DECLARE WMOV_DETALLE VARCHAR(250) ;
      DECLARE WCOMPROBANTE VARCHAR(20) ;
      DECLARE WIMPORTE DECIMAL (14,2) ;
      DECLARE WCONCEPTO_ID BIGINT(10) ; 
      DECLARE WMOVTIPO INT(1) ;       
      DECLARE WCHQ CHARACTER(1) DEFAULT "T" ;
      DECLARE WCHQ_ID BIGINT(20) ;
      DECLARE WBCO_ID int(11);
      DECLARE WBCO_DETALLE VARCHAR(50) ;
      DECLARE WNRO_CHQ VARCHAR(10) ;
      DECLARE WCHQ_VTO DATE ; 
      DECLARE WCHQ_IMPORTE DECIMAL(14,2) ;
      DECLARE Wtcomp_id INT(11) ;   
      DECLARE Wmov_nro_cpbte VARCHAR(20) ;
      DECLARE WSUCUR INT(11) ;
      DECLARE WCAJA INT(11)   ; 
      DECLARE WIMPPESOS DECIMAL(10,2) DEFAULT 0  ;
      DECLARE WIMPDOLARES DECIMAL (10,2) DEFAULT 0 ; 
      DECLARE Wmov_soloefvo INT(1) DEFAULT 0 ; 
      declare hacer INT(1) DEFAULT 0 ; 
      DECLARE cRegcaja CURSOR FOR SELECT MOV_ID, MOV_FECHA , MOV_DETALLE  , mov_importe_total ,  CONCEPTO_ID , 
                MOV_IDTIPO , tcomp_id , mov_nro_cpbte , SUCURSAL_ID , CAJA_ID , MOV_IMP_DOLARES , MOV_IMP_PESOS , mov_soloefvo
                FROM MOVCAJA  WHERE MOV_ID = WXMOV_ID ; 
      
      DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET hacer = 1;    
        
      DROP TABLE IF EXISTS  CAJA_MOV_ID ;
      CREATE TEMPORARY TABLE CAJA_MOV_ID ( MOV_ID BIGINT(20) , 
               MOV_FECHA DATE , 
               MOV_DETALLE VARCHAR(250) ,
               COMPROBANTE VARCHAR(20) , 
               IMPORTE DECIMAL (14,2) , 
               CONCEPTO_ID BIGINT(10) , 
               MOV_IDTIPO INT(1) default 0 , 
               CHQ CHARACTER(1) DEFAULT "T" , 
               CHQ_ID BIGINT(20)DEFAULT 0  , 
               BCO_ID INT(11) DEFAULT  0, 
               BCO_DETALLE VARCHAR(50) DEFAULT " " , 
               NRO_CHQ VARCHAR(10) DEFAULT "",
               CHQ_VTO CHAR(10) DEFAULT "" ,                 
               CHQ_IMPORTE DECIMAL (14,2) DEFAULT 0 ,
               sucursal_id INT(11) , 
               CAJA_ID INT(11) , 
               IMPDOLARES DECIMAL (10,2) DEFAULT 0,
               IMPPESOS DECIMAL(10,2) DEFAULT 0 ,
               t_comp_id BIGINT(11) , 
               nro_comprb varchar(12) ) ;
      OPEN cRegcaja ;
      set hacer = 0 ; 
      REPEAT         
        FETCH NEXT FROM cRegcaja
            INTO WMOV_ID, WMOV_FECHA ,WMOV_DETALLE  , WIMPORTE ,  WCONCEPTO_ID , WMOVTIPO, 
                  wtcomp_id , wmov_nro_cpbte ,WSUCUR , WCAJA , WIMPDOLARES , WIMPPESOS , Wmov_soloefvo ;
            
         if hacer=0 then          
            if Wtcomp_id > 0 then 
               SET WCOMPROBANTE = (select tcomp_abrev from tipos_comprobantes where tcomp_id = wtcomp_id );    
               set wcomprobante = concat(wcomprobante,"-",wmov_nro_cpbte) ; 
            else    
               SET WCOMPROBANTE = "" ;    
            end if  ;
            
            INSERT INTO CAJA_MOV_ID (MOV_ID , MOV_FECHA , MOV_DETALLE ,cOMPROBANTE ,IMPORTE ,CONCEPTO_ID , 
                                    MOV_IDTIPO,  SUCURSAL_ID , CAJA_ID, IMPDOLARES ,IMPPESOS, t_comp_id , nro_comprb, chq ) 
                   VALUES (wMOV_ID , wMOV_FECHA , wMOV_DETALLE ,WCOMPROBANTE ,wIMPORTE ,wCONCEPTO_ID , 
                           wMOVTIPO ,WSUCUR , WCAJA, WIMPDOLARES , WIMPPESOS, wtcomp_id , wmov_nro_cpbte ,"X"  ) ;
            IF Wmov_soloefvo = 1 THEN                
					INSERT INTO CAJA_MOV_ID  
						SELECT WMOV_ID ,WMOV_FECHA,WMOV_DETALLE ,WCOMPROBANTE ,WIMPORTE ,WCONCEPTO_ID,WMOVTIPO , "T"  ,
						  CT.CHQT_ID, CT.BCO_ID ,LEFT(B.BCO_DESCRIPCION,30) ,  CT.CHQT_NRO , CT.CHQT_FVTO , 
						  CT.CHQT_IMPORTE, WSUCUR , WCAJA , WIMPDOLARES , WIMPPESOS, 0 , ""
						  FROM mov_cheques_terceros CT , bancos_sucursales B 
							  WHERE  B.BCO_ID = CT.BCO_ID  AND  MOV_ID = WMOV_ID ;
										  
					insert into CAJA_MOV_ID  
						SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE , WCOMPROBANTE , WIMPORTE , WCONCEPTO_ID, WMOVTIPO  , "T" ,
						  CT.CHQT_ID, CT.BCO_ID ,LEFT(B.BCO_DESCRIPCION,30) ,  CT.CHQT_NRO , CT.CHQT_FVTO , 
						  CT.CHQT_IMPORTE, WSUCUR , WCAJA , WIMPDOLARES , WIMPPESOS, 0 , ""
						  FROM mov_cheques_terceros CT , bancos_sucursales B 
							 WHERE  B.BCO_ID = CT.BCO_ID  AND  ID_EGRESO = WMOV_ID ;
									
					INSERT INTO CAJA_MOV_ID  
					  SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE , WCOMPROBANTE , WIMPORTE , WCONCEPTO_ID, WMOVTIPO , "P"  ,
						  cc.`chq_id`, cc.`cuenta_id`, CONCAT(LEFT(B.`bco_descripcion`,20), "#" , cta.CTA_NUMERO ) , 
						  cc.stk_chq_nro , cc.stk_chq_fvto, cc.`stk_chq_importe`,  WSUCUR , WCAJA, WIMPDOLARES , WIMPPESOS, 0 , ""
						  FROM  caja_cheques cc ,  CAJA_CUENTAS cta , bancos_sucursales B 
							  WHERE  cta.cuenta_id = cc.cuenta_id AND B.`bco_id`= cta.`bco_id` AND cc.mov_id = WMOV_ID ;
				END IF ; 
			end if ;	
       UNTIL hacer END REPEAT;  
                 
       select * from CAJA_MOV_ID ORDER BY MOV_FECHA, MOV_ID , CHQ_ID asc ; 
      DROP TABLE IF EXISTS  CAJA_TEMP ;
       
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mostrar_mov_caja_xls` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `mostrar_mov_caja_xls`( wxsucur int(11), wxcaja int(11) , wxccaja_id int(11))
BEGIN
      
      DECLARE WMOV_ID BIGINT(20) ;
      DECLARE WMOV_FECHA DATE ;
      DECLARE WMOV_DETALLE VARCHAR(30) ;
      DECLARE WCOMPROBANTE VARCHAR(20) ;
      DECLARE WIMPORTE DECIMAL (14,2) ;
      DECLARE WCONCEPTO_ID BIGINT(10) ; 
      DECLARE WMOVTIPO INT(1) ;       
      DECLARE WCHQ CHARACTER(1) DEFAULT "T" ;
      DECLARE WCHQ_ID BIGINT(20) ;
      DECLARE WBCO_ID int(11);
      DECLARE WBCO_DETALLE VARCHAR(30) ;
      DECLARE WNRO_CHQ VARCHAR(10) ;
      DECLARE WCHQ_VTO DATE ; 
      DECLARE WCHQ_IMPORTE DECIMAL(14,2) ;
      DECLARE Wtcomp_id INT(11) ;   
      DECLARE Wmov_nro_cpbte VARCHAR(20) ;
      DECLARE WSUCUR INT(11) ;
      DECLARE WCAJA INT(11)   ; 
      DECLARE WIMPPESOS DECIMAL(10,2) DEFAULT 0  ;
      DECLARE WIMPDOLARES DECIMAL (10,2) DEFAULT 0 ; 
      DECLARE Wmov_soloefvo INT(1) DEFAULT 0 ; 
      declare hacer INT(1) DEFAULT 0 ; 
      DECLARE cRegcaja CURSOR FOR SELECT MOV_ID, MOV_FECHA , MOV_DETALLE  , mov_importe_total ,  CONCEPTO_ID , 
                MOV_IDTIPO , tcomp_id , mov_nro_cpbte , SUCURSAL_ID , CAJA_ID , MOV_IMP_DOLARES , MOV_IMP_PESOS , mov_soloefvo
                FROM MOVCAJA  WHERE SUCURSAL_ID =wxsucur AND CAJA_ID = wxcaja and CCaja_id = wxccaja_id  AND ISNULL(MOV_ANULACION) = 1; 
      
      DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET hacer = 1;    
        
      DROP TABLE IF EXISTS  CAJA_TEMP ;
      CREATE TEMPORARY TABLE CAJA_TEMP ( MOV_ID BIGINT(20) , 
               MOV_FECHA DATE , 
               MOV_DETALLE VARCHAR(30) ,
               COMPROBANTE VARCHAR(20) , 
               IMPORTE DECIMAL (14,2) , 
               CONCEPTO_ID BIGINT(10) , 
               MOV_IDTIPO INT(1) default 0 , 
               CHQ CHARACTER(1) DEFAULT " " , 
               CHQ_ID BIGINT(20)DEFAULT 0  , 
               BCO_ID INT(11) DEFAULT  0, 
               BCO_DETALLE VARCHAR(30) DEFAULT " " , 
               NRO_CHQ VARCHAR(10) DEFAULT "",
               CHQ_VTO CHAR(10) DEFAULT "" ,                 
               CHQ_IMPORTE DECIMAL (14,2) DEFAULT 0 ,
               sucursal_id INT(11) , 
               CAJA_ID INT(11) , 
               IMPDOLARES DECIMAL (10,2) DEFAULT 0,
               IMPPESOS DECIMAL(10,2) DEFAULT 0   ) ;
                
      OPEN cRegcaja ;
      set hacer = 0 ; 
      REPEAT         
        FETCH NEXT FROM cRegcaja
            INTO WMOV_ID, WMOV_FECHA ,WMOV_DETALLE  , WIMPORTE ,  WCONCEPTO_ID , WMOVTIPO, 
                  wtcomp_id , wmov_nro_cpbte ,WSUCUR , WCAJA , WIMPDOLARES , WIMPPESOS , Wmov_soloefvo ;
            
         if hacer=0 then          
            if Wtcomp_id > 0 then 
               SET WCOMPROBANTE = (select tcomp_abrev from tipos_comprobantes where tcomp_id = wtcomp_id );    
               set wcomprobante = concat(wcomprobante,"-",wmov_nro_cpbte) ; 
            else    
               SET WCOMPROBANTE = "" ;    
            end if  ;
            
            INSERT INTO CAJA_TEMP (MOV_ID , MOV_FECHA , MOV_DETALLE ,cOMPROBANTE ,IMPORTE ,CONCEPTO_ID , 
                                    MOV_IDTIPO, SUCURSAL_ID , CAJA_ID, IMPDOLARES ,IMPPESOS) 
                   VALUES (wMOV_ID , wMOV_FECHA , wMOV_DETALLE ,WCOMPROBANTE ,wIMPORTE ,wCONCEPTO_ID , 
                           wMOVTIPO ,WSUCUR , WCAJA, WIMPDOLARES , WIMPPESOS) ;
            IF Wmov_soloefvo = 1 THEN                
					INSERT INTO CAJA_TEMP  
						SELECT WMOV_ID ,WMOV_FECHA," " ," " ,0 ," ", " " , "T"  ,
						  CT.CHQT_ID, CT.BCO_ID ,LEFT(B.BCO_DESCRIPCION,30) ,  CT.CHQT_NRO , CT.CHQT_FVTO , 
						  CT.CHQT_IMPORTE, WSUCUR , WCAJA , WIMPDOLARES , WIMPPESOS
						  FROM mov_cheques_terceros CT , bancos_sucursales B 
							  WHERE  B.BCO_ID = CT.BCO_ID  AND  MOV_ID = WMOV_ID ;
										  
					insert into CAJA_TEMP  
						SELECT WMOV_ID , WMOV_FECHA, " " ," " ,0 ," ", " "  , "T" ,
						  CT.CHQT_ID, CT.BCO_ID ,LEFT(B.BCO_DESCRIPCION,30) ,  CT.CHQT_NRO , CT.CHQT_FVTO , 
						  CT.CHQT_IMPORTE, WSUCUR , WCAJA , WIMPDOLARES , WIMPPESOS
						  FROM mov_cheques_terceros CT , bancos_sucursales B 
							 WHERE  B.BCO_ID = CT.BCO_ID  AND  ID_EGRESO = WMOV_ID ;
									
					INSERT INTO CAJA_TEMP  
					  SELECT WMOV_ID , WMOV_FECHA," " ," " ,0 ," ", " " , "P"  ,
						  cc.`chq_id`, cc.`cuenta_id`, CONCAT(LEFT(B.`bco_descripcion`,20), "#" , cta.CTA_NUMERO ) , 
						  cc.stk_chq_nro , cc.stk_chq_fvto, cc.`stk_chq_importe`,  WSUCUR , WCAJA, WIMPDOLARES , WIMPPESOS
						  FROM  caja_cheques cc ,  CAJA_CUENTAS cta , bancos_sucursales B 
							  WHERE  cta.cuenta_id = cc.cuenta_id AND B.`bco_id`= cta.`bco_id` AND cc.mov_id = WMOV_ID ;
				END IF ; 
			end if ;	
       UNTIL hacer END REPEAT;  
                 
       select * from caja_temp ORDER BY MOV_FECHA, MOV_ID  asc ; 
      DROP TABLE IF EXISTS  CAJA_TEMP ;
       
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_anular_detalle` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_anular_detalle`(w_detalleId bigint, w_cabeceraId bigint, w_usuarioId int, w_usuarioPassword varchar(10))
BEGIN
	declare ahora datetime default now();
	declare mensaje varchar(100) default "";
	declare seguir int default 0;
	declare usuarioOk int default 0;
	
	start transaction;
	
	-- Verificar que el usuario exista
	set usuarioOk = (select count(*) from usuarios where usuario_id = w_usuarioId);
	if usuarioOk = 0 then
		set mensaje = "El ID de usuario no existe.";
		set seguir = 1;
	end if;
	
	-- Verificar que la contraseña es correcta.
	if seguir = 0 then	
		set usuarioOk = (select count(*) from usuarios where usuario_id = w_usuarioId and usu_contra_md5 = md5(w_usuarioPassword));
		if usuarioOk = 0 then
			set mensaje = "La contraseña es incorrecta.";
			set seguir = 1;
		end if;
	end if;
	
	-- Verificar que esté activo.
	if seguir = 0 then
		set usuarioOk = (select count(*) from usuarios where usuario_id = w_usuarioId AND isnull(usu_fecha_b));
		if usuarioOk = 0 then
			set mensaje = "El usuario esta inactivo.";
			set seguir = 1;
		end if;
	end if;
	
	-- Verificar que tenga perfil administrador
	if seguir = 0 then
		set usuarioOk = (SELECT COUNT(*) FROM usuarios WHERE usuario_id = w_usuarioId AND perfil_id >= 2000);
		if usuarioOk = 0 then
			set mensaje = "El usuario no tiene perfil administrador.";
			set seguir = 1;
		end if;
	end if;
	
	
	-- Actualizar movcaja_detalles
	if seguir = 0 then
		UPDATE movcaja_detalles SET movcaja_fecha_anulado = ahora, id_usuario_llave = w_usuarioId, movcaja_fhora_llave = ahora WHERE movcaja_id = w_detalleId;
		SET mensaje = fun_movcaja_actualizar_cabecera(w_cabeceraId);
		set mensaje = "success";
	end if;
	
	commit;
	
	select mensaje;
	
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_cargar_detalle` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_cargar_detalle`(w_CajaId int, w_MovTipoId int, w_ConceptoId bigint, w_CmpteTipoId int, w_NroCmpte varchar(14), w_Cuit varchar(11), w_TipoDocId int(3), w_NroDoc varchar(10), w_NombreEntidad varchar(50), w_BrutoBruto double(12,2), w_BrutoIva21 DOUBLE(12,2), w_BrutoIva105 DOUBLE(12,2), w_BrutoIIBB DOUBLE(12,2), w_Iva21 DOUBLE(12,2), w_Iva105 DOUBLE(12,2), w_IIBB DOUBLE(12,2), w_Percepcion DOUBLE(12,2), w_ImpNoGravado DOUBLE(12,2), w_Total DOUBLE(13,2), w_UsuarioId int, w_CabeceraId bigint(20), w_PagoChq longtext)
BEGIN
	declare ahora datetime default now();
	declare movcajaId bigint(20) default 0;
	declare mensaje text default "";
	
	start transaction;
	
	-- Cargar movimiento
	insert into movcaja_detalles (caja_id, mov_idtipo, movcaja_feccarga, concepto_id, tcomp_id, movcaja_nro_cpbte, cuit, tdoc_id, nro_doc, movcaja_nombre, movcaja_bruto_bruto, movcaja_bruto_iva21, movcaja_bruto_iva105, movcaja_bruto_iibb, movcaja_iva21, movcaja_iva105, movcaja_iibb, movcaja_percepciones, movcaja_imp_no_gravado, movcaja_total, id_usuario, id_cabecera_movcaja) values (w_CajaId, w_MovTipoId, ahora, w_ConceptoId, w_CmpteTipoId, w_NroCmpte, w_Cuit, w_TipoDocId, w_NroDoc, w_NombreEntidad, w_BrutoBruto, w_BrutoIva21, w_BrutoIva105, w_BrutoIIBB, w_Iva21, w_Iva105, w_IIBB, w_Percepcion, w_ImpNoGravado, w_Total, w_UsuarioId, w_CabeceraId);
	
	SET movcajaId = LAST_INSERT_ID();
	
	-- Cargar cheques si hay
	IF w_PagoChq != "" THEN
		-- w_PagoChq: (movcaja_id, '{stk_chq_nro}', '{stk_chq_femision}', '{stk_chq_fvto}', {stk_chq_clearing}, '{stk_chq_importe}', {bco_id}, '{chq_cta_nom}', '{chq_cta_nro}', '{chq_cta_cuit}', '{chq_cta_dom_pago}')
		SET w_PagoChq = REPLACE(w_PagoChq, "movcaja_id", movcajaId);
		SET @query1 = CONCAT("insert into movcaja_cheques (movcaja_id, stk_chq_nro, stk_chq_femision, stk_chq_fvto, stk_chq_clearing, stk_chq_importe, bco_id, chq_cta_nom, chq_cta_nro, chq_cta_cuit, chq_cta_dom_pago) values ", w_PagoChq);
		PREPARE stmt1 FROM @query1;
		EXECUTE stmt1;
		
		update movcaja_cheques set stk_chq_fvto = date_add(stk_chq_femision, interval 30 day) where movcaja_id = movcajaId;
	END IF;
	
	-- Actualizar movcaja_cabecera
	set mensaje = fun_movcaja_actualizar_cabecera(w_CabeceraId);
	
	commit;
	
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_cerrar_cabecera` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_cerrar_cabecera`(w_cabeceraId bigint, w_cabeceraApertura datetime, w_cajaId int, w_sucursalId int, w_usuarioId int, w_empresaId int, w_retiro double(12,2))
BEGIN	
	declare brutoIngresos double(12,2) default 0.00;
	declare brutoEgresos double(12,2) default 0.00;
	declare impuestosIngresos double(10,2) default 0.00;
	declare impuestosEgresos double(10,2) default 0.00;
	declare idMovcaja bigint(20) default 0;
	declare fechaCierre datetime default now();
	declare cajaDescripcion VARCHAR(100) default "";
	declare saldoDisponible double(14,2) default 0.00;
	declare seguir int default 0;
	declare mensaje varchar(100) default "";
	
	start transaction;
	
	-- Cargar egreso movcaja_detalles y movcaja_saldo_inicial si hay retiro
	if w_retiro > 0.00 then
	
		-- Verificar si hay disponible el monto
		SET saldoDisponible = (SELECT movcab_total FROM movcaja_cabecera WHERE id_cabecera_movcaja = w_cabeceraId);
		
		if w_retiro > saldoDisponible then
			set seguir = 1;
			set mensaje = concat("El monto ingresado supera el saldo disponible. ($ ", saldoDisponible, ")");
		end if;
		
		if seguir = 0 then
		
			-- Cargar movcaja_detalles movimiento egreso saldo apertura
			INSERT INTO movcaja_detalles(caja_id, mov_idtipo, movcaja_feccarga, concepto_id, tcomp_id, movcaja_nro_cpbte, CUIT, tdoc_id, nro_doc, movcaja_nombre, movcaja_bruto_bruto, movcaja_total, id_usuario, id_cabecera_movcaja) VALUES (w_cajaId, 1, fechaCierre, 100, 0, "", "", 0, "", "", w_retiro, w_retiro, w_usuarioId, w_cabeceraId);
			
			-- Cargar movcaja_saldo_inicial si hay retiro
			INSERT INTO movcaja_saldo_inicial (caja_id, id_cabecera_movcaja_egr, saini_monto) VALUES (w_cajaId, w_cabeceraId, w_retiro);
		end if;
		
	end if;
	
	if seguir = 0 then
	
		-- Cargar movcaja		
		set brutoIngresos = (select sum(movcaja_bruto_bruto) from movcaja_detalles where mov_idtipo = 0 and isnull(movcaja_fecha_anulado) and id_cabecera_movcaja = w_cabeceraId);
		
		SET brutoEgresos = (SELECT SUM(movcaja_bruto_bruto) FROM movcaja_detalles WHERE mov_idtipo = 1 AND ISNULL(movcaja_fecha_anulado) AND id_cabecera_movcaja = w_cabeceraId);
		
		SET impuestosIngresos = (SELECT SUM(movcaja_iva21 + movcaja_iva105 + movcaja_iibb + movcaja_percepciones + movcaja_imp_no_gravado) FROM movcaja_detalles WHERE mov_idtipo = 0 AND ISNULL(movcaja_fecha_anulado) AND id_cabecera_movcaja = w_cabeceraId);
		
		SET impuestosEgresos = (SELECT SUM(movcaja_iva21 + movcaja_iva105 + movcaja_iibb + movcaja_percepciones + movcaja_imp_no_gravado) FROM movcaja_detalles WHERE mov_idtipo = 1 AND ISNULL(movcaja_fecha_anulado) AND id_cabecera_movcaja = w_cabeceraId);
		
		SET cajaDescripcion = (SELECT concat(c.caja_descripcion, " - ", s.sucur_descripcion, " - ", e.empre_razon_social) FROM cajas c, sucursales s, empresas e WHERE s.sucursal_id = c.sucursal_id and e.empre_id = c.empre_id and c.caja_id = w_cajaId);
		
		
		set idMovcaja = funCargaMov_Caja_v2(0, '99999999999', 4, w_cabeceraApertura, date_format(w_cabeceraApertura, "%m%Y"), brutoIngresos - brutoEgresos, impuestosIngresos - impuestosEgresos, 0.00, w_cajaId, 0, w_sucursalId, w_usuarioId, w_cabeceraApertura, concat("Cierre Caja ", DATE_FORMAT(fechaCierre, "%d/%m/%y"), " ", cajaDescripcion), w_empresaId, "", w_cabeceraId, 0, 0);
		
		-- Cargar cheques mov_cheques_terceros
		IF idMovcaja > 0 THEN
			SET @query = CONCAT("INSERT mov_cheques_terceros (empre_id, mov_id, id_ingreso, chqt_femisin, chqt_fvto, chqt_clearing, chqt_importe, bco_id, chqt_nro, chqt_cta_nom, chqt_cta_nro, chqt_cta_cuit, chqt_cta_dom_pago, chqt_anulado) SELECT ", w_empresaId, ", ", idMovcaja, ", d.id_cabecera_movcaja, ch.stk_chq_femision, ch.stk_chq_fvto, ch.stk_chq_clearing, ch.stk_chq_importe, ch.bco_id, ch.stk_chq_nro, ch.chq_cta_nom, ch.chq_cta_nro, ch.chq_cta_cuit, ch.chq_cta_dom_pago, DATE_FORMAT(d.movcaja_fecha_anulado, '%Y-%m-%d') FROM movcaja_cheques ch, movcaja_detalles d WHERE ch.movcaja_id = d.movcaja_id AND d.id_cabecera_movcaja = ", w_cabeceraId);
			
			PREPARE stmt FROM @query;
			EXECUTE stmt;
		END IF;
			
		-- Actualizar movcaja_cabecera
		update movcaja_cabecera set movcab_cierre = fechaCierre, movcab_ingresos = brutoIngresos + impuestosIngresos, movcab_egresos = brutoEgresos + impuestosEgresos, movcab_total = brutoIngresos + impuestosIngresos - brutoEgresos - impuestosEgresos where id_cabecera_movcaja = w_cabeceraId;
		
		set mensaje = "success";
	end if;
		
	commit;
	
	select mensaje;
		
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_generar_cabecera` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_generar_cabecera`(w_CajaId int, w_UsuarioId int)
BEGIN
	DECLARE ahora DATETIME DEFAULT NOW();
	DECLARE seguir INT DEFAULT 0;
	DECLARE mensaje TEXT DEFAULT "";
	DECLARE cabeceraAbierta INT DEFAULT 0; -- (0) = No hay, (>0) = Hay
	DECLARE idCabecera BIGINT(20) DEFAULT 0;
	declare funResp int default 0;
	
	START TRANSACTION;
	
	-- Validar si hay una cabecera abierta
	SET cabeceraAbierta = (SELECT COUNT(*) FROM movcaja_cabecera WHERE caja_id = w_CajaId AND ISNULL(movcab_cierre));
	
	IF cabeceraAbierta > 0 THEN
		SET seguir = 1;
		SET mensaje = "No es posible procesar la solicitud, hay un ejercicio abierto para esta caja.";
	END IF;
	
	IF seguir = 0 THEN
		
		INSERT INTO movcaja_cabecera (caja_id, movcab_apertura, id_usuario) VALUES (w_CajaId, ahora, w_UsuarioId);
		
		SET idCabecera = LAST_INSERT_ID();
				
		-- Verificar si hay saldo inicial para la caja
		set funResp = fun_movcaja_saldo_inicial(w_CajaId, w_UsuarioId, idCabecera);
		
		SET mensaje = "success";
	END IF;
	
	COMMIT;
	
	SELECT mensaje;
	
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_listar_cabeceras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_listar_cabeceras`(w_cajaId int)
BEGIN
	
	start transaction;
	
	SELECT cb.*, cj.empre_id, e.empre_razon_social, cj.sucursal_id, s.sucur_codigo, s.sucur_descripcion, cj.caja_descripcion, u.usu_nombre FROM movcaja_cabecera cb, cajas cj, empresas e, sucursales s, usuarios u WHERE cj.caja_id = cb.caja_id AND e.empre_id = cj.empre_id AND s.sucursal_id = cj.sucursal_id AND u.usuario_id = cb.id_usuario AND cb.caja_id = w_cajaId;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_listar_cabecera_detalles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_listar_cabecera_detalles`(w_cabeceraId bigint(20), w_movTipoId text, w_conceptoId text, w_usuarioId text)
BEGIN
	
	start transaction;
	
	set @query = concat("SELECT d.*, c.caja_descripcion, c.empre_id, e.empre_razon_social, c.sucursal_id, s.sucur_codigo, s.sucur_descripcion, IF(d.id_usuario_llave > 0, (SELECT usu_nombre FROM usuarios WHERE usuario_id = d.id_usuario_llave), '') 'usu_llave_nombre' , u.usu_nombre, cm.conc_descripcion, (select count(*) from movcaja_cheques where movcaja_Id = d.movcaja_id) 'cantidad_cheques', IF(d.tdoc_id > 0, (SELECT CONCAT(doc_codigo, ';', doc_desc) FROM tipos_doc WHERE doc_id = d.tdoc_id), '') 'tdoc_info', if(d.tcomp_id > 0, (select concat(if(isnull(tcomp_abrev), '', tcomp_abrev), ';', if(isnull(tcomp_descripcion), '', tcomp_descripcion)) from tipos_comprobantes where tcomp_id = d.tcomp_id), '') 'tcomp_info'
	FROM movcaja_detalles d, cajas c, empresas e, sucursales s, usuarios u, conceptos_movimientos cm 
	WHERE c.caja_id = d.caja_id 
	AND e.empre_id = c.empre_id 
	AND s.sucursal_id = c.sucursal_id 
	AND u.usuario_id = d.id_usuario 
	AND cm.concepto_id = d.concepto_id 
	AND d.id_cabecera_movcaja = ", w_cabeceraId);
	
	if w_movTipoId != "" then
		set @query = concat(@query, " AND d.mov_idtipo IN (", w_movTipoId, ")");
	end if;
	
	IF w_conceptoId != "" THEN
		SET @query = CONCAT(@query, " AND d.concepto_id IN (", w_conceptoId, ")");
	END IF;
	
	IF w_usuarioId != "" THEN
		SET @query = CONCAT(@query, " AND d.id_usuario IN (", w_usuarioId, ")");
	END IF;
	
	prepare stmt from @query;
	execute stmt;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_listar_cajas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_listar_cajas`()
BEGIN
	
	start transaction;
	
	SELECT c.*, e.empre_razon_social, s.sucur_codigo, s.sucur_descripcion FROM cajas c, empresas e, sucursales s WHERE e.empre_id = c.empre_id AND s.sucursal_id = c.sucursal_id;	
		
	commit;
	
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_listar_cajas_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_listar_cajas_usuario`(w_usuarioId int)
BEGIN
	
	start transaction;
	
	SELECT uc.usucaja_id, c.*, e.empre_razon_social, s.sucur_codigo, s.sucur_descripcion 
	FROM usuarios_cajas uc, cajas c, empresas e, sucursales s 
	WHERE c.caja_id = uc.caja_id
	AND e.empre_id = c.empre_id 
	AND s.sucursal_id = c.sucursal_id
	AND uc.usuario_id = w_usuarioId
	AND uc.usucaja_habil = 0;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_listar_cheques_detalle` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_listar_cheques_detalle`(w_detalleId bigint)
BEGIN
	start transaction;
	
	select c.*, b.bco_descripcion from movcaja_cheques c, bancos_sucursales b where b.bco_id = c.bco_id and c.movcaja_ID = w_detalleId;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_listar_conceptos_cabecera` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_listar_conceptos_cabecera`(w_cabeceraId bigint, w_tipoMovId text)
BEGIN
	
	start transaction;
	
	set @query = concat("SELECT d.concepto_id, c.conc_descripcion
	FROM movcaja_detalles d, conceptos_movimientos c
	WHERE c.concepto_id = d.concepto_id
	AND d.id_cabecera_movcaja = ", w_cabeceraId, "
	AND d.mov_idtipo IN (", w_tipoMovId, ")
	GROUP BY d.concepto_id");
	
	prepare stmt from @query;
	execute stmt;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_listar_detalles_anulados` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_listar_detalles_anulados`(w_empreId text)
BEGIN
	
	start transaction;
	
	set @query = concat("SELECT d.*, uc.usu_nombre 'usucar_nombre', ua.usu_nombre 'usuanu_nombre', c.movcab_apertura, c.movcab_cierre, c.movcab_ingresos, c.movcab_egresos, c.movcab_total, c.movcab_cnt_movimientos, c.movcab_estado, c.saini_monto, j.caja_descripcion, co.conc_descripcion,
	if(d.tcomp_id > 0, (select concat(if(isnull(tcomp_descripcion), '', tcomp_descripcion), ';', IF(ISNULL(tcomp_abrev), '', tcomp_abrev)) from tipos_comprobantes where tcomp_id = d.tcomp_id), '') 'tcomp_datos', s.sucur_descripcion,
	e.empre_razon_social
	FROM movcaja_detalles d, movcaja_cabecera c, usuarios uc, usuarios ua, cajas j, conceptos_movimientos co, sucursales s, empresas e
	WHERE c.id_cabecera_movcaja = d.id_cabecera_movcaja
	AND uc.usuario_id = d.id_usuario
	AND ua.usuario_id = d.id_usuario_llave
	AND j.caja_id = d.caja_id
	and co.concepto_id = d.concepto_id
	and s.sucursal_id = j.sucursal_id
	and e.empre_id = s.empre_id
	AND ISNULL(d.movcaja_fecha_anulado) = 0
	AND j.empre_id IN (", w_empreId, ")
	ORDER BY d.movcaja_feccarga DESC");
	
	prepare stmt from @query;
	execute stmt;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_listar_empresas_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_listar_empresas_usuario`(w_usuarioId int)
BEGIN
	
	start transaction;
	
	SELECT ue.*, e.empre_razon_social, u.usu_nombre
	FROM usuarios_empresas ue, empresas e, usuarios u
	WHERE e.empre_id = ue.empre_id
	AND u.usuario_id = ue.usuario_id
	AND ue.usuario_id = w_usuarioId
	ORDER BY e.empre_razon_social ASC;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_listar_usuarios_cabecera` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_listar_usuarios_cabecera`(w_cabeceraId BIGINT)
BEGIN
	
	start transaction;
	
	SELECT d.id_usuario, u.usu_nombre
	FROM movcaja_detalles d, usuarios u
	WHERE u.usuario_id = d.id_usuario
	AND d.id_cabecera_movcaja = w_cabeceraId
	GROUP BY d.id_usuario
	ORDER BY u.usu_nombre ASC;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_movimiento_caja_caja` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_movimiento_caja_caja`(w_idCajaIng int, w_idCabeceraMovcajaIng bigint, w_idCajaEgr int, w_idCabeceraMovcajaEgr bigint, w_monto double(13,2), w_usuarioId int)
BEGIN
	declare ok int default 0;
	declare seguir int default 0;
	declare mensaje varchar(100) default "";
	declare movcabTotalCabeceraEgr double(14,2) default 0;
	declare ahora datetime default now();
	declare respGenerarCabecera varchar(120) default "";
	declare generarCabecera int default 0; -- 0 No, 1 Si
	
	start transaction;
	
	-- Validar si el monto ingresado esta disponible para retirar de la caja egreso
	set movcabTotalCabeceraEgr = (select movcab_total from movcaja_cabecera where id_cabecera_movcaja = w_idCabeceraMovcajaEgr);
	if movcabTotalCabeceraEgr < w_monto then
		set seguir = 1;
		set mensaje = "El monto ingresado es mayor al monto disponible para retirar de la apertura seleccionada.";
	end if;
	
	if seguir = 0 then
	
		-- Cargar movimiento egreso
		insert into movcaja_detalles (caja_id, mov_idtipo, movcaja_feccarga, concepto_id, tcomp_id, movcaja_nro_cpbte, CUIT, tdoc_id, nro_doc, movcaja_nombre, movcaja_bruto_bruto, movcaja_total, id_usuario, id_cabecera_movcaja) values (w_idCajaEgr, 1, ahora, 103, 0, "", "", 0, "", "", w_monto, w_monto, w_usuarioId, w_idCabeceraMovcajaEgr);
		
		-- Actualizar movcaja_cabecera egreso
		set mensaje = fun_movcaja_actualizar_cabecera(w_idCabeceraMovcajaEgr);
		
		-- Verificar si w_idCabeceraMovcajaIng es 0 (generar nueva cabecera) o mayor a 0 (verificar que no este cerrada)
		if w_idCabeceraMovcajaIng = 0 then		
			set generarCabecera = 1;
		else
			-- Verificar que no este cerrada (Si es 0 esta cerrada, si es 1 esta abierta)
			SET ok = (SELECT COUNT(*) FROM movcaja_cabecera WHERE id_cabecera_movcaja = w_idCabeceraMovcajaIng AND ISNULL(movcab_cierre));
			IF ok = 0 THEN
				SET generarCabecera = 1;
			END IF;
		end if;
		
		select generarCabecera;
		
		if generarCabecera = 0 then
		
			-- Cargar movimiento ingreso
			INSERT INTO movcaja_detalles (caja_id, mov_idtipo, movcaja_feccarga, concepto_id, tcomp_id, movcaja_nro_cpbte, CUIT, tdoc_id, nro_doc, movcaja_nombre, movcaja_bruto_bruto, movcaja_total, id_usuario, id_cabecera_movcaja) VALUES (w_idCajaIng, 0, ahora, 106, 0, "", "", 0, "", "", w_monto, w_monto, w_usuarioId, w_idCabeceraMovcajaIng);
			
			-- Actualizar movcaja_cabecera ingreso
			SET mensaje = fun_movcaja_actualizar_cabecera(w_idCabeceraMovcajaIng);
			
			SET mensaje = "success";
		else	
		
			-- Generar nueva cabecera
			SET respGenerarCabecera = fun_movcaja_generar_cabecera(w_idCajaIng, w_usuarioId);
			SET w_idCabeceraMovcajaIng = SUBSTRING_INDEX(respGenerarCabecera, ";", 1);
			SET mensaje = SUBSTRING_INDEX(respGenerarCabecera, ";", -1);
			
			IF mensaje = "success" THEN
			
				-- Cargar movimiento ingreso
				INSERT INTO movcaja_detalles (caja_id, mov_idtipo, movcaja_feccarga, concepto_id, tcomp_id, movcaja_nro_cpbte, CUIT, tdoc_id, nro_doc, movcaja_nombre, movcaja_bruto_bruto, movcaja_total, id_usuario, id_cabecera_movcaja) VALUES (w_idCajaIng, 0, ahora, 106, 0, "", "", 0, "", "", w_monto, w_monto, w_usuarioId, w_idCabeceraMovcajaIng);
				
				-- Actualizar movcaja_cabecera ingreso
				SET mensaje = fun_movcaja_actualizar_cabecera(w_idCabeceraMovcajaIng);
				
				SET mensaje = "success";
			END IF;
		end if;
	end if;
	
	commit;
	
	select mensaje;
	
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_pausar_cabecera` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_pausar_cabecera`(w_cabeceraId bigint, w_estadoId int)
BEGIN
	
	start transaction;
	
	update movcaja_cabecera set movcab_total_pausado = movcab_total, movcab_estado = w_estadoId where id_cabecera_movcaja = w_cabeceraId;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_traer_cabecera` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_traer_cabecera`(w_cabeceraId bigint)
BEGIN
	
	start transaction;
	
	SELECT cb.*, cj.empre_id, e.empre_razon_social, cj.sucursal_id, s.sucur_codigo, s.sucur_descripcion, cj.caja_descripcion, u.usu_nombre FROM movcaja_cabecera cb, cajas cj, empresas e, sucursales s, usuarios u WHERE cj.caja_id = cb.caja_id AND e.empre_id = cj.empre_id AND s.sucursal_id = cj.sucursal_id AND u.usuario_id = cb.id_usuario AND cb.id_cabecera_movcaja = w_cabeceraId;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `movcaja_traer_detalle` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `movcaja_traer_detalle`(w_detalleId bigint)
BEGIN
	
	start transaction;
	
	SELECT d.*, c.caja_descripcion, c.empre_id, e.empre_razon_social, c.sucursal_id, s.sucur_codigo, s.sucur_descripcion, IF(d.id_usuario_llave > 0, (SELECT usu_nombre FROM usuarios WHERE usuario_id = d.id_usuario_llave), '') 'usu_llave_nombre' , u.usu_nombre, cm.conc_descripcion,
	(SELECT COUNT(*) FROM movcaja_cheques WHERE movcaja_Id = d.movcaja_id) 'cantidad_cheques', if(d.tdoc_id > 0, (select concat(doc_codigo, ';', doc_desc) from tipos_doc where doc_id = d.tdoc_id), '') 'tdoc_info', if(d.tcomp_id > 0, (select concat(if(isnull(tcomp_abrev), '', tcomp_abrev), ';', if(isnull(tcomp_descripcion), '', tcomp_descripcion)) from tipos_comprobantes where tcomp_id = d.tcomp_id), '') 'tcomp_info'
	FROM movcaja_detalles d, cajas c, empresas e, sucursales s, usuarios u, conceptos_movimientos cm
	WHERE c.caja_id = d.caja_id 
	AND e.empre_id = c.empre_id 
	AND s.sucursal_id = c.sucursal_id 
	AND u.usuario_id = d.id_usuario 
	AND cm.concepto_id = d.concepto_id
	AND d.movcaja_id = w_detalleId;
	
	commit;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Resumen_disponibilidad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `Resumen_disponibilidad`(wccajaid bigint(20))
BEGIN
      declare wdisp_total decimal(11,2) ; 
      declare wdisp_cant INT(6) ; 
      DECLARE wvto_1_total decimal(10,2);
      DECLARE wvto_1_cant INT(6) ;       
      declare wvto_7_total decimal(10,2) ;
      DECLARE wvto_7_cant INT(6) ; 
      declare wtotal_pesos decimal(12,2) ; 
      declare wtotal_dolares decimal(12,2) ;
      declare wchqemi_total  decimal (12,2) ;
      declare wchqemi_cant DECIMAL (12,2) ; 
      DECLARE wchqemi_1_total decimal(12,2) ;
      DECLARE wchqemi_1_cant DECIMAL(12,2) ;
      declare wchqemi_7_cant decimal(12,2) ;
      DECLARE wchqemi_7_total DECIMAL(12,2) ;      
      DECLARE wchqt_pasados DECIMAL(12,2) ; 
      declare whoy date default date(now()) ;
      declare wmanana date default date_add(date(now()), interval 1 day) ;
      declare w7dias date DEFAULT DATE_ADD(DATE(NOW()), INTERVAL 7 DAY) ;
      
		set wdisp_total =	(SELECT sum(chqt_importe) as total FROM mov_cheques_terceros
			  WHERE  ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1  );
				 
			SET wdisp_cant := ROW_COUNT() ;	 
			
		set wvto_1_total =	(SELECT SUM(chqt_importe) AS total FROM mov_cheques_terceros
			  WHERE  ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1  and chqt_fvto between whoy and wmanana);
			SET wvto_1_cant := ROW_COUNT() ;
				 
 		SET wchqt_pasados =	(SELECT SUM(chqt_importe) AS total FROM mov_cheques_terceros
			  WHERE  ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1  AND chqt_fvto < whoy );
			
		SET wvto_7_total =	(SELECT SUM(chqt_importe) AS total FROM mov_cheques_terceros
			  WHERE  ISNULL(chqt_anulado) = 1 AND 
				 ISNULL(chqt_fdeposito) = 1 AND 
				 ISNULL(chqt_entregado) = 1 AND 
				 ISNULL(chqt_cambio) = 1  AND chqt_fvto BETWEEN whoy AND w7dias);
				 
		SET wvto_7_cant := ROW_COUNT() ;
		set wtotal_dolares = (SELECT sum(IF(MOV_IDTIPO=1,MOV_IMP_DOLARES*-1,MOV_IMP_DOLARES )) FROM MOVCAJA  WHERE CCAJA_ID = wccajaid AND ISNULL(MOV_ANULACION)=1 ) ; 
		set wtotal_pesos = (select SUM(IF(MOV_IDTIPO=1,MOV_IMP_PESOS*-1,MOV_IMP_PESOS)) FROM MOVCAJA  WHERE CCAJA_ID = wccajaid AND ISNULL(MOV_ANULACION)=1  ) ;
   SET  wchqemi_total = (SELECT SUM(stk_chq_importe) FROM caja_cheques 
            WHERE stk_chq_importe <> 0 and 
                    isnull(stk_chq_fvto) = 0 and 
                    ISNULL(stk_chq_anulado) =1 and 
							ISNULL(stk_chq_fdeposito)=1 and 
							ISNULL(stk_chq_fcambio)=1  ) ;
							
      SET wchqemi_cant := ROW_COUNT() ;
   SET  wchqemi_1_total = (SELECT SUM(stk_chq_importe)  FROM caja_cheques  
            WHERE  ISNULL(stk_chq_fvto) = 0 AND 
                    ISNULL(stk_chq_anulado) =1 AND 
							ISNULL(stk_chq_fdeposito)=1 AND 
							ISNULL(stk_chq_fcambio)=1 AND Stk_chq_fvto BETWEEN whoy AND wmanana ) ;
							
      SET wchqemi_1_cant := ROW_COUNT() ;
		SET  wchqemi_7_total = (SELECT SUM(stk_chq_importe)  FROM caja_cheques  
            WHERE ISNULL(stk_chq_fvto) = 0 AND 
                    ISNULL(stk_chq_anulado) =1 AND 
							ISNULL(stk_chq_fdeposito)=1 AND 
							ISNULL(stk_chq_fcambio)=1 AND Stk_chq_fvto BETWEEN whoy AND w7dias ) ;
							
      SET wchqemi_7_cant := ROW_COUNT() ;
      
      SELECT IFNULL(wdisp_total,0) AS  disp_total ,IF(wdisp_cant<0,0,wdisp_cant) AS disp_cant , 
             IFNULL(wvto_1_total,0) AS vto_1_total , IF(wvto_1_cant<0,0,wvto_1_cant )AS vto_1_cant ,        
             IFNULL(wvto_7_total,0) AS vto_7_total , IF(wvto_7_cant<0,0,wvto_7_cant)  AS vto_7_cant , 
             IFNULL(wtotal_dolares,0) as total_dolares, IFNULL(wtotal_pesos,0) as total_pesos, 
             IFNULL(wchqemi_total,0) AS  chqemi_total, IF(wchqemi_cant<0,0,wchqemi_cant) AS chqemi_cant , 
             IFNULL(wchqemi_1_total,0) AS chqemi_1_total, IF(wchqemi_1_cant<0,0,wchqemi_1_cant) AS chqemi_1_cant ,
             IFNULL(wchqemi_7_total,0) AS chqemi_7_total, IF(wchqemi_7_cant<0,0,wchqemi_7_cant) AS chqemi_7_cant ,
             IFNULL(wchqt_pasados,0) as chqt_pasados; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
/*!50003 DROP PROCEDURE IF EXISTS `spMuestraClientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `spMuestraClientes`(westado int(1) /*0- todos , 1-solo activos , 2- solo bajas */)
BEGIN
      if westado = 0 then 
         SELECT CL.*, if(isnull(cli_fbaja)=0,"BAJA", "ACTIVO") as estado 
             FROM clientes CL ORDER BY cli_nombre ; 
      end if ; 
      IF westado = 1 THEN 
         SELECT CL.*, IF(ISNULL(cli_fbaja)=0,"BAJA", "ACTIVO") AS estado 
             FROM clientes CL WHERE ISNULL(cli_fbaja)=0  ORDER BY cli_nombre ;       
      END IF ; 
      IF westado = 2 THEN 
         SELECT CL.*, IF(ISNULL(cli_fbaja)=0,"BAJA", "ACTIVO") AS estado 
             FROM clientes CL WHERE ISNULL(cli_fbaja)=1  ORDER BY cli_nombre ;      
      END IF ; 
      
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
/*!50003 DROP PROCEDURE IF EXISTS `SP_ANULAR_COBROS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `SP_ANULAR_COBROS`(wempresa INT(4 ) , wmovid BIGINT (20))
BEGIN
	DECLARE wfecha_baja DATETIME DEFAULT NOW() ; 
	
	-- BOORA PARCIALES DE COMPROBANTES DE VENTAS Y ND AGREGADAS -- 
	UPDATE parciales_comprobantes SET parc_anulado = wfecha_baja WHERE  mov_id = wmovid ;
        -- ==============================================================================================================
        -- BORRAR  RETENCIONES  -- 
	UPDATE retenciones SET RETEN_FBAJA = wfecha_baja  WHERE   mov_id = wmovid ;
        -- ==============================================================================================================
        -- BORRA TRANSFERENC`saldos_pendientes_compras`IAS 
        UPDATE transferencias SET TRANS_FBAJA = wfecha_baja WHERE  mov_id = wmovid  ;
        -- ==============================================================================================================
	-- BORRA NOTAS DE DEBITOS 
	UPDATE notas_deb_creditos SET NOTADC_FBAJA = wfecha_baja WHERE  mov_id = wmovid ;
        -- ==============================================================================================================
        -- EFECTIVO
         UPDATE movcaja SET MOV_anulacion = wfecha_baja WHERE mov_id =   wmovid ;     
        -- ==============================================================================================================
        -- CARGA CHEQUES DE TERCEROS
        UPDATE  mov_cheques_terceros SET MOV_ID = WMOVID   WHERE  mov_id = wmovid ;
        -- ==============================================================================================================
      -- caja_compensaciones
        DELETE FROM caja_compensaciones WHERE MOV_ID = wmovid ;
		     
            
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Anular_Pagos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Anular_Pagos`(wnro_op VARCHAR(10), wElimina INT(1) )
BEGIN
        DECLARE widcomp BIGINT(20) ; 
        DECLARE wmovid BIGINT(20) ; 
	SET wmovid = (SELECT MOV_ID  FROM ordenes_pago  WHERE ordenp_nro = wnro_op LIMIT 1 );
        IF wElimina = 1 THEN 
           	 -- elimina pagos 
		DELETE FROM retenciones WHERE  mov_id = wmovid ;  
		DELETE FROM transferencias WHERE  mov_id = wmovid ; 
		DELETE FROM notas_deb_creditos WHERE  mov_id = wmovid ;    
		UPDATE caja_cheques SET mov_id = NULL  , 
					mov_fecha = NULL ,  
					stk_chq_fvto = NULL  , 
					stk_chq_importe = 0 , 
					stk_chq_nombre_apagar = NULL , 
					cuit = NULL  
					WHERE mov_id = wmovid ;
		DELETE FROM parciales_comprobantes WHERE  mov_id = wmovid ; 
		DELETE FROM caja_compensaciones WHERE  mov_id = wmovid ; 
		UPDATE ordenes_pago SET ordenes_pago.`ordenp_estado` = "ANUL" WHERE mov_id = wmovid ;
		UPDATE movcaja SET MOV_ANULACION = NOW() WHERE  mov_id = wmovid  ;
	END IF ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Anular_Pagos_movid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Anular_Pagos_movid`(wmovid bigint(20), wElimina INT(1) )
BEGIN
        DECLARE widcomp BIGINT(20) ; 
        IF wElimina = 1 THEN 
           	 -- elimina pagos 
		DELETE FROM retenciones WHERE  mov_id = wmovid ;  
		DELETE FROM transferencias WHERE  mov_id = wmovid ; 
		DELETE FROM notas_deb_creditos WHERE  mov_id = wmovid ;    
		UPDATE caja_cheques SET mov_id = NULL  , 
					mov_fecha = NULL ,  
					stk_chq_fvto = NULL  , 
					stk_chq_importe = 0 , 
					stk_chq_nombre_apagar = NULL , 
					cuit = NULL  
					WHERE mov_id = wmovid ;
		DELETE FROM parciales_comprobantes WHERE  mov_id = wmovid ; 
		DELETE FROM caja_compensaciones WHERE  mov_id = wmovid ; 
		UPDATE ordenes_pago SET ordenes_pago.`ordenp_estado` = "ANUL" WHERE mov_id = wmovid ;
		UPDATE movcaja SET MOV_ANULACION = NOW() WHERE  mov_id = wmovid  ;
	END IF ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Anular_Pagos_movid_certificados_negativos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Anular_Pagos_movid_certificados_negativos`(wmovid BIGINT(20), wElimina INT(1) )
BEGIN
        DECLARE widcomp BIGINT(20) ; 
	DECLARE salida INT(1) DEFAULT 0 ; 
	DECLARE wempresa INT (4) ;
	DECLARE wretencion_id BIGINT(20); 
	DECLARE wtcomp_id INT(11);
	DECLARE wreten_nombre VARCHAR(30);
	DECLARE wreten_imp_areten DOUBLE(14,2);
	DECLARE wreten_alicuota DOUBLE(5,2) ;
	DECLARE wreten_fecha DATE ;
	DECLARE wid_compras BIGINT(20);
	DECLARE wid_venta BIGINT(20) ;
	DECLARE wreten_retenido DOUBLE(14,2) ;
	DECLARE wreten_certificado VARCHAR(20) ;
	DECLARE wmov_id BIGINT(20) DEFAULT NULL;
	DECLARE wreten_fbaja DATE DEFAULT NULL;
	DECLARE wreten_falta DATE DEFAULT NULL;	
	DECLARE wfecha_anul DATETIME	 DEFAULT NOW();
	DECLARE anular_reten CURSOR FOR SELECT * FROM retenciones WHERE mov_id = wmovid ; 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET salida = 1;
	
         IF wElimina = 1 THEN 
           	 -- elimina pagos 
		 SET wempresa = (SELECT empresa_id FROM movcaja WHERE mov_id = wmovid LIMIT 1); 
		 OPEN anular_reten;
                 REPEAT         
			FETCH NEXT FROM anular_reten 
				      INTO wretencion_id, wtcomp_id ,wreten_nombre ,wreten_imp_areten , wreten_alicuota, 
						wreten_fecha ,  wid_compras,wid_venta , wreten_retenido , wreten_certificado ,
						wmov_id , wreten_fbaja , wreten_falta ;
				IF salida=0 THEN	 
					SELECT `funAlta_Retenciones`(wempresa , 1 , wtcomp_id, wreten_imp_areten,wreten_alicuota,
					wreten_fecha, wid_compras, wid_venta , wreten_retenido * -1 , wmovid ,DATE( NOW()), " " ) ;
				END IF ; 	
		UNTIL  salida  END REPEAT ; 
		UPDATE transferencias SET trans_fbaja =  wfecha_anul WHERE  mov_id = wmovid ; 
		UPDATE notas_deb_creditos SET notadc_fbaja  = DATE(NOW())  WHERE  mov_id = wmovid ;    
		UPDATE caja_cheques SET mov_id = NULL  , 
					mov_fecha = NULL ,   
					stk_chq_fvto = NULL  , 
					stk_chq_importe = 0 , 
					stk_chq_nombre_apagar = NULL , 
					cuit = NULL  WHERE mov_id = wmovid ;
		DELETE FROM parciales_comprobantes WHERE  mov_id = wmovid ; 
		DELETE FROM caja_compensaciones WHERE  mov_id = wmovid ; 
		UPDATE ordenes_pago SET ordenes_pago.`ordenp_estado` = "ANUL" WHERE mov_id = wmovid ;
		UPDATE movcaja SET MOV_ANULACION = NOW() WHERE  mov_id = wmovid  ;
	END IF ; 
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_Carga_Ordenes_Pago` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Carga_Ordenes_Pago`(wempreid INT(4), wtipocomp INT(5) , WCUIT VARCHAR(13), wcomprobantes VARCHAR(4500), wordenp_estado CHAR(4) , mov_id BIGINT(20))
BEGIN
        DECLARE wnroOP BIGINT(20);
        DECLARE wnroOPstr VARCHAR(10) ;
        DECLARE wComando VARCHAR(4500)  ; 
        
        SET wnroOP = (SELECT funNumComprobanteInterno(wempreid,wtipocomp) ) ;
        IF wnroOP > 0 THEN 
           SET wnroOPstr = CONCAT(SUBSTR( CONVERT(YEAR(NOW()), CHAR),3,2), 
                          RIGHT(CONCAT("00", CONVERT(MONTH(NOW()),CHAR)),2),"-", 
                          RIGHT(CONCAT("00000",CONVERT(wnroOP, CHAR)),5 )) ;
  
	   SET wcomprobantes = REPLACE(wcomprobantes, '@1' , wcuit ) ; 
	   SET wcomprobantes = REPLACE(wcomprobantes, '@2' , wnroOPstr ) ; 
	   SET wComando = CONCAT( "INSERT INTO ordenes_pago (empresa_id ,  cuit, ordenp_nro ,id_compras , Ordenp_pagar , ordenp_estado , mov_id ) VALUES ",trim(wcomprobantes) );
	   set @wcomm = wComando;
	   PREPARE stmt1 FROM @wcomm ; 
	   EXECUTE stmt1 ;
	   SELECT * FROM ordenes_pago WHERE ordenp_nro = wnroOPstr; 
        END IF ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Carga_Ordenes_Pago2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Carga_Ordenes_Pago2`(wempreid INT(4), wtipocomp INT(5) , WCUIT VARCHAR(13),
      wcomprobantes VARCHAR(2500), wordenp_estado CHAR(4) , mov_id BIGINT(20))
BEGIN
        DECLARE wnroOP BIGINT(20);
        DECLARE wnroOPstr VARCHAR(10) ;
        DECLARE WCOMANDO VARCHAR (3000) ; 
        
        SET wnroOP = (SELECT funNumComprobanteInterno(wempreid,wtipocomp) ) ;
        IF wnroOP > 0 THEN 
           SET wnroOPstr = CONCAT(SUBSTR( CONVERT(YEAR(NOW()), CHAR),3,2), 
                          RIGHT(CONCAT("00", CONVERT(MONTH(NOW()),CHAR)),2),"-", 
                          RIGHT(CONCAT("00000",CONVERT(wnroOP, CHAR)),5 )) ;
  
	   SET wcomprobantes = REPLACE(wcomprobantes, '@1' , wcuit ) ; 
	   SET wcomprobantes = REPLACE(wcomprobantes, '@2' , wnroOPstr ) ; 
	   SET WCOMANDO = CONCAT( "INSERT INTO ordenes_pago (empresa_id ,  cuit, ordenp_nro ,id_compras , Ordenp_pagar , ordenp_estado , mov_id ) VALUES ",  wcomprobantes );
	   SELECT  length(WCOMANDO) ; /*WCOMANDO*/ 
	   SELECT WCOMANDO ; 
        END IF ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Carga_Ordenes_Pago3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Carga_Ordenes_Pago3`(wempreid INT(4), wtipocomp INT(5) , WCUIT VARCHAR(13), wcomprobantes VARCHAR(2500), wordenp_estado CHAR(4) , mov_id BIGINT(20))
BEGIN
        DECLARE wnroOP BIGINT(20);
        DECLARE wnroOPstr VARCHAR(10) ;
        DECLARE wComando blob  ; 
        
        SET wnroOP = 1500 /*(SELECT funNumComprobanteInterno(wempreid,wtipocomp) ) ;*/; 
        IF wnroOP > 0 THEN 
           SET wnroOPstr = CONCAT(SUBSTR( CONVERT(YEAR(NOW()), CHAR),3,2), 
                          RIGHT(CONCAT("00", CONVERT(MONTH(NOW()),CHAR)),2),"-", 
                          RIGHT(CONCAT("00000",CONVERT(wnroOP, CHAR)),5 )) ;
  
	   SET wcomprobantes = REPLACE(wcomprobantes, '@1' , wcuit ) ; 
	   SET wcomprobantes = REPLACE(wcomprobantes, '@2' , wnroOPstr ) ; 
	   SET wComando = CONCAT( "INSERT INTO ordenes_pago (empresa_id ,  cuit, ordenp_nro ,id_compras , Ordenp_pagar , ordenp_estado , mov_id ) VALUES ",trim(wcomprobantes) );
	   set @wcomm = wComando;
	   PREPARE stmt1 FROM @wcomm ; 
	   EXECUTE stmt1 ;
	   SELECT * FROM ordenes_pago WHERE ordenp_nro = wnroOPstr; 
        END IF ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_compras_SIAP` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `sp_compras_SIAP`(wempresa INT(2) , wperiodo varchar(4) )
BEGIN
  SELECT  c.`id_compras` , tc.`tcomp_afip` , tc.tcomp_id,  tc.tcomp_abrev,   REPLACE(c.comp_fechacpbte,"-","") AS fecha_comp , 
		RIGHT(CONCAT("000",tc.`tcomp_afip` ),3)AS td_afip , 
		if( tc.tcomp_afip = "099", "099", REPLACE(LEFT(TRIM(c.`comp_nrocpbte`),5),"-","")) AS pvta ,
		c.`comp_nrocpbte` AS nro_comp ,  "0000000000000000" AS desp_import ,  
		iF( tc.tcomp_afip = "099", "99",RIGHT(CONCAT("00", tc.`tcomp_afip`),2)) AS cod_doc_vend  ,  	                 
		RIGHT(CONCAT("00000000000000000000" , c.`cuit`),20) AS ident_vendedor ,  
	c.`prov_razsocial` AS ape_nom_vend ,  
	RIGHT(CONCAT("000000000000000" , REPLACE(CONVERT(c.`comp_total`, CHARACTER),".","")),15) AS imp_tot_operacion , 
	 "000000000000000" AS imp_concep_quenocomponen ,  "000000000000000" AS imp_exento ,
	RIGHT(CONCAT("000000000000000" , REPLACE(CONVERT(c.comp_percep_iva, CHARACTER),".","")),15)AS percep_iva ,
	 "000000000000000" AS percep_otros ,  
	RIGHT(CONCAT("000000000000000" , REPLACE(CONVERT(c.`comp_percep_iibb`, CHARACTER),".","")),15)  AS percep_iibb , 
	  "000000000000000" AS percep_imp_municipales , 
	   "000000000000000" AS imp_impuestos_internos , 
	  "PES" AS moneda ,   
	  "0000000000" AS  tipo_cambio , 
	    "1" AS cnt_ali_iva ,  
	    "000000000000000" AS crdito_fiscal , 
	  "000000000000000" AS otros_tributos ,  
	   c.`cuit` AS cuit_emisor ,   
	   c.`prov_razsocial` AS nom_emisor ,
	  c.`comp_iva105` AS iva_105 ,   
	  c.`comp_iva21` AS iva_21 
 FROM compras c, tipos_comprobantes tc , centros_costos cd    
    WHERE tc.tcomp_id = c.tcomp_id AND 
	 cd.CD_ID  = c.cd_numero AND 
	 funRelacion_comprobante_proceso(1,c.tcomp_id,"LIQC") > 0 AND 
	ISNULL(comp_fbaja) = 1  AND 
	ISNULL(comp_fprocesado) = 1 AND 
	ISNULL(comp_periodo) = 1 AND  (LEFT(c.`comp_expediente`,4)= wperiodo OR LEFT(c.`comp_expediente`,4)<  wperiodo ) AND 
	ISNULL(tc.`tcomp_afip`)= 0 AND  c.empresa_id = wempresa
ORDER BY comp_fechacpbte; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_comprobantes_cargados` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_comprobantes_cargados`(wempre int(4) , wper char(4))
BEGIN
    
			 SELECT  CONCAT(tc.tcomp_abrev,': ' ,comp_nrocpbte) AS cpbte , 
						 c.id_sucursal as suc, 
						  c.id_caja as numcaja , 
						  c.comp_expediente as exped,  
						  c.id_compras as idcomp , 
						  c.cuit , 
						  c.tcomp_id as idtcomp , 
						  c.comp_fechacpbte  as fcpbte , 
						  c.comp_nrocpbte as nrocpbte , 
						  c.prov_razsocial as nomprov ,  
						  c.prov_pagadero as nompaga , 
						  c.comp_dias as dias , 
						  c.comp_vto as vto ,
						  c.tiva_id as idtiva, 
						  if(isnull(c.comp_anulado)=1,"  ",c.comp_anulado)  as anul , 
						  c.usu_id as idusu ,
						  c.comp_iva21 as iva21 , 
						  c.comp_iva105 as iva105 ,
						  c.comp_iva_diferencial ,  
						  c.comp_percep_iva as periva ,
						  c.comp_percep_iibb as periibb,
						  c.comp_reten_iibb as retiibb ,
						  c.comp_reten_ganancias as retganan , 
						  c.comp_varios as varios , 
						  c.comp_bruto as bruto , 
						  c.comp_total as total ,
						  c.mmot_id  as motivo , 
						  c.comp_detalle as obser , 
						  c.comp_fcarga as fcarga,
						  IF(ISNULL(c.comp_fbaja)=1, "  ",c.comp_fbaja) as fbaja,
						  IF(ISNULL(c.comp_periodo)=1,"  ",c.comp_periodo) as periodo,
						  IF(ISNULL(c.comp_fprocesado) =1, "  " ,c.comp_fprocesado )as fproc , 
						  IF(ISNULL(c.mov_fecha)=1," ",c.mov_fecha)  as fmov,
						  c.mov_id  as idmov,
						  IF(ISNULL(c.id_egreso)=1,"",c.id_egreso) as idegre, 
						  tcomp_descripcion AS nomcomp,
						  sucur_descripcion as sucnom ,
						  concat(c.mmot_id ," - ",m.mmot_descripcion) as nommotxx  
				 FROM compras c, tipos_comprobantes tc   , sucursales s , motivos_movimientos m
					WHERE tc.tcomp_id = c.tcomp_id 
					AND s.empre_id = wempre
					    and s.sucursal_id  = c.id_sucursal 
					    AND M.EMPRE_ID= WEMPRE
					    and m.mmot_id  = c.mmot_id 
					    AND LEFT(comp_expediente,4) = TRIM(wper)  AND empresa_id = wempre  ORDER BY comp_expediente; 
							
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_comprobantes_compras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_comprobantes_compras`(wperiodo VARCHAR(6), 
									wfechahasta varchar(19), 
									wper_a_liq int(1), 
									wempre int(4) )
BEGIN
    declare wmes int(2) ;
    declare wano int(4) ; 
    
     if isnull(wperiodo) = 1  then  
          -- consulta de todos los comprobantes que tengo sin liquidar  
          --  EJ.:   '' , '2016-08-24', 0       
	 SELECT  CONCAT(tc.tcomp_abrev,': ' ,comp_nrocpbte) AS cpbte , 
		 (COMP_TOTAL*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS total_signado ,
		   (comp_bruto*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_bruto_s ,
		   (comp_iva21*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_iva21_s ,
		   (comp_iva105*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_iva105_s ,
		   (comp_percep_iva*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_percep_iva_s ,
		   (comp_percep_iibb*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_percep_iibb_s ,
		   (comp_reten_iibb*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_reten_iibb_s ,
		   (comp_reten_ganancias*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_reten_gcias_s ,
		   (comp_varios*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_varios_s ,		 
		  c.*, 
		  IF(ISNULL(comp_vto)=1,"",comp_vto) AS comp_vto2  , 
		  " " AS marca, tcomp_descripcion as cdoc, 
		  cd_descripcion AS cd_det
	 FROM compras c, tipos_comprobantes tc , centros_costos cd    
		WHERE tc.tcomp_id = c.tcomp_id AND 
		      cd.CD_ID  = c.cd_numero AND 
		      funRelacion_comprobante_proceso(wempre,c.tcomp_id,"LIQC") > 0 AND 
			ISNULL(comp_fbaja) = 1  AND 
			isnull(comp_fprocesado) = 1 and 
			isnull(comp_periodo) = 1 and 
			comp_fechacpbte <= wfechahasta  and 
			c.empresa_id = wempre
			ORDER BY comp_fechacpbte; 
      else 
          if wper_a_liq = 1  then 
		  -- consulta de comprobantes a liquidar por un periodo 
		  --  EJ.: 072016 , '', 1
		     set wmes = left(wperiodo,2) ; 
		     set wano = right(wperiodo,2) ;           
		    SELECT  CONCAT(tc.tcomp_abrev,': ' , 
		            comp_nrocpbte) AS cpbte ,
		           (COMP_TOTAL*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS total_signado ,
		           (comp_bruto*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_bruto_s ,
		           (comp_iva21*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_iva21_s ,
		           (comp_iva105*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_iva105_s ,
		           (comp_percep_iva*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_percep_iva_s ,
		           (comp_percep_iibb*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_percep_iibb_s ,
		           (comp_reten_iibb*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_reten_iibb_s ,
		           (comp_reten_ganancias*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_reten_gcias_s ,
		           (comp_varios*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_varios_s ,
			   c.*,  
			   IF(ISNULL(comp_vto)=1,"",comp_vto) AS comp_vto2 , 
			   " " AS marca, 
			   tcomp_descripcion AS cdoc , 
			   cd_descripcion AS cd_det
		    FROM compras c, tipos_comprobantes tc    , centros_costos cd    
				WHERE tc.tcomp_id = c.tcomp_id AND 
					 cd.CD_ID  = c.cd_numero AND
		  		        funRelacion_comprobante_proceso(wempre,c.tcomp_id,"LIQC") > 0 AND
					ISNULL(comp_fbaja) = 1  AND 
					mid(comp_expediente,3,2) <= wmes and 
					mid(comp_expediente,1,2) <= wano and 
					isnull(comp_periodo) = 1 and 
					isnull(comp_fprocesado) = 1  and
					c.empresa_id = wempre
					ORDER BY comp_fechacpbte;       
          else 
		  -- consulta de comprobantes ya liquidados en un periodo 
		  --  EJ.: 072016 , '', 0          
		    SELECT  CONCAT(tc.tcomp_abrev,': ' ,comp_nrocpbte) AS cpbte , 
				(COMP_TOTAL*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS total_signado ,
				   (comp_bruto*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_bruto_s ,
				   (comp_iva21*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_iva21_s ,
				   (comp_iva105*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_iva105_s ,
				   (comp_percep_iva*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_percep_iva_s ,
				   (comp_percep_iibb*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_percep_iibb_s ,
				   (comp_reten_iibb*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_reten_iibb_s ,
				   (comp_reten_ganancias*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_reten_gcias_s ,
				   (comp_varios*IF(tc.tcomp_signo=0,1,tc.tcomp_signo)) AS comp_varios_s ,				
					c.*, IF(ISNULL(comp_vto)=1,"",comp_vto) AS comp_vto2  , 
					" " AS marca, tcomp_descripcion AS cdoc, cd_descripcion AS cd_det
			 FROM compras c, tipos_comprobantes tc    , centros_costos cd   
				WHERE tc.tcomp_id = c.tcomp_id AND 
					      cd.CD_ID  = c.cd_numero AND 
					      funRelacion_comprobante_proceso(wempre,c.tcomp_id,"LIQC") > 0 AND 
						ISNULL(comp_fbaja) = 1  AND 
						comp_periodo = wperiodo  and 
						c.empresa_id = wempre 
						ORDER BY comp_fechacpbte;       
	 end if 	;			
      end if   ;                
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_comprobantes_cuit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_comprobantes_cuit`(wempre INT(4), wcCuit VARCHAR(15), wproceso VARCHAR(4))
BEGIN
    -- "TODO" muestra todos los comprobantes sin distincion de procesos.
     IF wproceso = "TODO" THEN 
	SELECT  CONCAT(tc.tcomp_abrev,': ' , 
	       comp_nrocpbte) AS cpbte ,  c.*
	       , IF(ISNULL(comp_vto)=1,"",
	       comp_vto) AS comp_vto2  , 
	       " " AS marca,
	      IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, 
	      tiva_descripcion, mmot_descripcion , 
	      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) AS pagar ,
	       (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) AS saldo 
	  FROM compras c, tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
	    WHERE tc.tcomp_id = c.tcomp_id 
		AND ti.tiva_id=c.tiva_id 
		AND mt.mmot_id = c.mmot_id 
		AND mt.empre_id = wempre
		AND c.cuit = wcCuit 
		AND c.empresa_id = wempre  
		AND ISNULL(comp_fbaja) = 1  
		AND ISNULL(mov_fecha) = 1 
		ORDER BY comp_fechacpbte ;     
     ELSE 	
	SELECT  CONCAT(tc.tcomp_abrev,': ' , 
	       comp_nrocpbte) AS cpbte ,  c.*
	       , IF(ISNULL(comp_vto)=1,"",
	       comp_vto) AS comp_vto2  , 
	       " " AS marca,
	      IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, 
	      tiva_descripcion, mmot_descripcion , 
	      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) AS pagar , 
	      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) AS SALDO
	  FROM compras c, tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
	    WHERE tc.tcomp_id = c.tcomp_id 
		AND ti.tiva_id=c.tiva_id 
		AND mt.mmot_id = c.mmot_id 
		AND mt.empre_id = wempre
		AND c.cuit = wcCuit 
		AND c.empresa_id = wempre  
		AND ISNULL(comp_fbaja) = 1  
		AND ISNULL(mov_fecha) = 1 
		AND  funRelacion_comprobante_proceso(wempre,c.tcomp_id,wproceso) > 0 
		ORDER BY comp_fechacpbte ;
      END IF ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_comprobantes_cuit_BAK` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_comprobantes_cuit_BAK`(wempre int(4), wcCuit varchar(15), wproceso varchar(4))
BEGIN
    -- "TODO" muestra todos los comprobantes sin distincion de procesos.
     if wproceso = "TODO" THEN 
	SELECT  CONCAT(tc.tcomp_abrev,': ' , 
	       comp_nrocpbte) AS cpbte ,  c.*
	       , IF(ISNULL(comp_vto)=1,"",
	       comp_vto) AS comp_vto2  , 
	       " " AS marca,
	      IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, 
	      tiva_descripcion, mmot_descripcion , 
	      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) AS pagar 
	  FROM compras c, tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
	    WHERE tc.tcomp_id = c.tcomp_id 
		AND ti.tiva_id=c.tiva_id 
		AND mt.mmot_id = c.mmot_id 
		AND mt.empre_id = wempre
		AND c.cuit = wcCuit 
		AND c.empresa_id = wempre  
		AND ISNULL(comp_fbaja) = 1  
		AND ISNULL(mov_fecha) = 1 
		ORDER BY comp_fechacpbte ;     
     ELSE 	
	SELECT  CONCAT(tc.tcomp_abrev,': ' , 
	       comp_nrocpbte) AS cpbte ,  c.*
	       , if(isnull(comp_vto)=1,"",
	       comp_vto) as comp_vto2  , 
	       " " as marca,
	      if(isnull(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) as imprime, 
	      tiva_descripcion, mmot_descripcion , 
	      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) as pagar  
	  FROM compras c, tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
	    WHERE tc.tcomp_id = c.tcomp_id 
		AND ti.tiva_id=c.tiva_id 
		and mt.mmot_id = c.mmot_id 
		and mt.empre_id = wempre
		and c.cuit = wcCuit 
		and c.empresa_id = wempre  
		and isnull(comp_fbaja) = 1  
		AND ISNULL(mov_fecha) = 1 
		AND  funRelacion_comprobante_proceso(wempre,c.tcomp_id,wproceso) > 0 
		order by comp_fechacpbte ;
      END IF ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_control_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_control_usuario`(Pusu varchar(15), Pcla varchar(10), wempresa int(4) )
BEGIN
			-- select * from usuarios u , empresas e  where usu_logon = Pusu and usu_contra = Pcla  and usu_habil = 0 ;
			SELECT u.* FROM usuarios u , usuarios_empresas e  WHERE  e.usuario_id = u.usuario_id  AND  empre_id = wempresa AND     usu_logon = Pusu AND usu_contra = Pcla  AND usu_habil = 0 ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cpbtes_pendientes_compras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_cpbtes_pendientes_compras`(wempre INT(1), WCUIT VARCHAR(11))
BEGIN
	IF LENGTH(WCUIT) <11   THEN 
		SELECT  CONCAT(tc.tcomp_abrev,': ' , 
		       comp_nrocpbte) AS cpbte ,  c.*
		       ,pr.prov_nombre , pr.id_rubro , rub.rubro_descripcion , IF(ISNULL(comp_vto)=1,"",
		       comp_vto) AS comp_vto2  , 
		       " " AS marca,
		      IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, 
		      tiva_descripcion, mmot_descripcion , 
		      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) AS pagar,  pr.prov_nombre
		  FROM compras c, proveedores pr, rubros rub,  tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
		    WHERE  pr.cuit =c.cuit 
		        AND rub.rubro_codigo = pr.id_rubro 
		        AND tc.tcomp_id = c.tcomp_id 
			AND ti.tiva_id=c.tiva_id 
			AND mt.mmot_id = c.mmot_id 
			AND mt.empre_id = wempre
			AND c.empresa_id = wempre  
			AND rub.empresa_id = wempre
			AND ISNULL(comp_fbaja) = 1  
			AND ISNULL(mov_fecha) = 1 
			AND  funRelacion_comprobante_proceso(wempre,c.tcomp_id,"ORDP") > 0 
			ORDER BY  prov_razsocial , comp_fechacpbte  ;   
	ELSE 
		SELECT  CONCAT(tc.tcomp_abrev,': ' , 
		       comp_nrocpbte) AS cpbte ,  c.*
		       ,pr.prov_nombre, pr.id_rubro , rub.rubro_descripcion ,IF(ISNULL(comp_vto)=1,"",
		       comp_vto) AS comp_vto2  , 
		       " " AS marca,
		      IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, 
		      tiva_descripcion, mmot_descripcion , 
		      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) AS pagar ,  pr.prov_nombre
		  FROM compras c, proveedores pr, rubros rub, tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
		    WHERE  pr.cuit =c.cuit  
		        AND rub.rubro_codigo = pr.id_rubro
		        AND tc.tcomp_id = c.tcomp_id 
			AND ti.tiva_id=c.tiva_id 
			AND mt.mmot_id = c.mmot_id 
			AND mt.empre_id = wempre
			AND c.empresa_id = wempre
			AND rub.empresa_id = wempre
			AND C.CUIT = WCUIT    
			AND ISNULL(comp_fbaja) = 1  
			AND ISNULL(mov_fecha) = 1 
			AND  funRelacion_comprobante_proceso(wempre,c.tcomp_id,"ORDP") > 0 
			ORDER BY  prov_razsocial , comp_fechacpbte  ;	   		
	END IF ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cpbtes_pendientes_compras_consumos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_cpbtes_pendientes_compras_consumos`(wempre INT(1), WCUIT VARCHAR(11))
BEGIN
	DECLARE  hecho  BOOL DEFAULT  FALSE ; 
DROP TABLE IF EXISTS TMP_CPBTE_DEUDAS ; 
CREATE TEMPORARY TABLE TMP_CPBTE_DEUDAS   SELECT pr.prov_razsocial AS Razon_social ,  
		                 pr.prov_nombre  AS  nombre ,   
		                 c.comp_fechacpbte AS EMISION , 
				  c.CUIT , 
				  c.`comp_nrocpbte`  AS NRO_COMPROBANTE, 
				  c.`comp_expediente` AS EXPEDIENTE ,  
				  CONCAT(tc.tcomp_abrev,': ' ,  c.comp_nrocpbte) AS CPBTE_COMPLETO , 
				  pr.prov_nombre, pr.id_rubro , 
				  rub.rubro_descripcion AS descripcion_rubro ,
				   c.tcomp_id AS ID_TCOMP , 
				  tc.tcomp_descripcion  AS descripcion_tcomp , 
				  c.tiva_id  AS id_iva , 
		                  ti.tiva_descripcion  AS descripcion_iva ,   
		                  mt.mmot_id AS id_motivo , 
		                  mt.mmot_descripcion AS descripcion_motivo ,
		                  c.comp_total AS total_general , 
		                  (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(c.id_compras,0) ) AS  pagar  
		  FROM compras c, proveedores pr, rubros rub, tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
		    WHERE  pr.cuit =c.cuit  
		        AND rub.rubro_codigo = pr.id_rubro
		        AND tc.tcomp_id = c.tcomp_id 
			AND ti.tiva_id=c.tiva_id 
			AND mt.mmot_id = c.mmot_id 
			AND mt.empre_id = wempre
			AND c.empresa_id = wempre
			AND rub.empresa_id = wempre
			AND C.CUIT = WCUIT   
			AND ISNULL(comp_fbaja) = 1  
			AND ISNULL(mov_fecha) = 1 
			AND  funRelacion_comprobante_proceso(1,c.tcomp_id,"ORDP") > 0   ;   
		
    
     select * from  TMP_CPBTE_DEUDAS where pagar =  total_general order by emision   ;
        
        
   
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_datos_cierres_caja` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_datos_cierres_caja`(wfecini Date, wfecfin Date, wcaja int(11), wsucu int(11), wccaja_id int(11))
BEGIN
		SELECT  m.conc_tipo ,
				c.concepto_id , conc_descripcion, 
				 IF(conc_tipo=0,SUM(mov_importe_total),SUM(mov_importe_total)*-1) AS total ,  
				 IF(conc_tipo=0,SUM(mov_imp_pesos),SUM(mov_imp_pesos)*-1) AS tot_pesos , 
				 IF(conc_tipo=0,SUM(mov_imp_dolares),SUM(mov_imp_dolares)*-1) AS tot_dolares , 
				 IFNULL(IF(conc_tipo=0,(SELECT SUM(chqt_importe) FROM mov_cheques_terceros cht WHERE cht.mov_id = c.mov_id),
				        (SELECT SUM(chqt_importe) FROM mov_cheques_terceros cht WHERE cht.mov_id = c.mov_id)*-1),0) AS total_chq_terceros , 
				 IFNULL(IF(conc_tipo=0,(SELECT SUM(stk_chq_importe) FROM caja_cheques chp WHERE chp.mov_id = c.mov_id),
				        (SELECT SUM(stk_chq_importe) FROM caja_cheques chp WHERE chp.mov_id = c.mov_id)*-1) ,0) AS total_chq_propios 
				 FROM movcaja c , conceptos_movimientos m  
				  WHERE  m.concepto_id = c.concepto_id AND 
						ISNULL(mov_anulacion ) = 1 AND 
				      mov_fecha BETWEEN  wfecini AND wfecfin AND caja_id = wcaja and sucursal_id = wsucu and ccaja_id = wccaja_id 
					GROUP BY m.conc_tipo , concepto_id ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_facturas_electronicas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_facturas_electronicas`(wempre INT(4), wspPeriodo CHAR(6))
BEGIN
      SELECT v.* , IF(ISNULL(v.`venta_anulado`)=1," ",v.`venta_anulado`) AS Anulado, sucur_descripcion , 
           caja_descripcion, tcomp_descripcion, CONCAT(tcomp_descripcion,"-",v.venta_nrocpbte) AS comprob ,
           CONCAT(tcomp_abrev,"-",v.venta_nrocpbte) AS comp_abrev , 
           tiva_descripcion AS tipo_iva , tiva_cpo1 AS tipo_iva_red ,  mmot_descripcion AS motivo , tcomp_signo AS signo  
	   FROM VENTAS v, sucursales s, cajas c , tipos_comprobantes tc , tipos_iva ti , motivos_movimientos mm
	        WHERE s.sucursal_id = v.id_sucursal AND 
			(c.sucursal_id = v.id_sucursal AND c.caja_id= v.id_caja) AND 
			tc.tcomp_id = v.tcomp_id AND
			ti.tiva_id = v.tiva_id AND 
			mm.mmot_id = v.mmot_id AND 
			VENTA_PERIODO  = wspPeriodo  AND 
			v.empre_id = wempre  AND 
			mm.empre_id = wempre  
			ORDER BY venta_nrocpbte ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_grabacion_cierre_caja` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_grabacion_cierre_caja`(WCCAJAID BIGINT(20), 
                                                           wfecini DATE, 
                                                           wfecfin DATE, 
                                                           wcaja INT(11), 
                                                           wsucu INT(11), 
                                                           wimppesos DECIMAL (12,2) , 
																			  wimpdol DECIMAL(12,2) ,
																			  wimpchqt DECIMAL(12,2) , 
																			  wimpchqp DECIMAL(12,2) )
BEGIN
        DECLARE wconc_tipo INT(1); 
        DECLARE wconcepto_id BIGINT(20) ; 
        DECLARE wtot_pesos DECIMAL(12,2) ; 
        DECLARE wtot_dolares DECIMAL(12,2); 
        DECLARE wtotal_chqt DECIMAL (12,2); 
        DECLARE wtotal_chqp DECIMAL(12,2) ; 
		  DECLARE done INT(1) ; 
             
			UPDATE cierres_caja SET  ccaja_fecha_cierre = wfecfin , 
							 ccaja_fecha_proceso = DATE(NOW()) , 
							 ccaja_hora = TIME(NOW()) ,  
							 ccaja_imppesos_fin    = wimppesos  , 
							 ccaja_impdolares_fin = wimpdol  ,
							 ccaja_chq_terceros_fin = wimpchqt  , 
							 ccaja_chq_propios_fin = wimpchqp 
							 	WHERE ccaja_id = WCCAJAID ; 
							 
							 
          update movcaja set  ccaja_id = 0  where	mov_fecha not between wfecini and  wfecfin  
                                            and caja_id = wcaja 
                                            and sucursal_id = wsucu 
                                            and ccaja_id = WCCAJAID ;
							 
         INSERT INTO cierres_caja_detalle  SELECT  WCCAJAID, m.conc_tipo ,c.concepto_id ,  
					 IF(conc_tipo=0,SUM(mov_imp_pesos),SUM(mov_imp_pesos)*-1) AS tot_pesos , 
					 IF(conc_tipo=0,SUM(mov_imp_dolares),SUM(mov_imp_dolares)*-1) AS tot_dolares , 
					 IFNULL(IF(conc_tipo=0,(SELECT SUM(chqt_importe) FROM mov_cheques_terceros cht WHERE cht.mov_id = c.mov_id),
							  (SELECT SUM(chqt_importe) FROM mov_cheques_terceros cht WHERE cht.mov_id = c.mov_id)*-1),0) AS total_chqt , 
					 IFNULL(IF(conc_tipo=0,(SELECT SUM(stk_chq_importe) FROM caja_cheques chp WHERE chp.mov_id = c.mov_id),
							  (SELECT SUM(stk_chq_importe) FROM caja_cheques chp WHERE chp.mov_id = c.mov_id)*-1) ,0) AS total_chqp  , "" 
					 FROM movcaja c , conceptos_movimientos m  
					  WHERE  m.concepto_id = c.concepto_id  AND ccaja_id = WCCAJAID
						GROUP BY m.conc_tipo , concepto_id ;	
						
													 
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
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_listar_UsuEmpSucPerSis`(w_usuarioID bigint(20), w_empresaID bigint(20), w_sucursalID bigint(20), w_sistemaID varchar(8), w_perfilID bigint(20), w_habilitado int(1))
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_mostrar_deposito` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_mostrar_deposito`(widdepo BIGINT(20))
BEGIN
	IF widdepo = 0 THEN 
	   SELECT * FROM bancos_depositos WHERE ISNULL(dep_anulado) = 1;
	ELSE 
	   SELECT * FROM bancos_depositos WHERE ISNULL(dep_anulado) = 1 AND deposito_id = widdepo;
	END IF ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mostrar_mov_caja_pagos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_mostrar_mov_caja_pagos`( wPmov_id int(20))
BEGIN
      
      DECLARE WMOV_ID BIGINT(20) ;
      DECLARE WMOV_FECHA DATE ;
      DECLARE WMOV_DETALLE VARCHAR(80) ;
      DECLARE WCOMPROBANTE VARCHAR(20) ;
      DECLARE WIMPORTE DECIMAL (14,2) ;
      DECLARE WCONCEPTO_ID BIGINT(10) ; 
      DECLARE WMOVTIPO INT(1) ;       
      DECLARE WCHQ CHARACTER(1) DEFAULT "T" ;
      DECLARE WCHQ_ID BIGINT(20) ;
      DECLARE WBCO_ID int(11);
      DECLARE WBCO_DETALLE VARCHAR(30) ;
      DECLARE WNRO_CHQ VARCHAR(10) ;
      DECLARE WCHQ_VTO DATE ; 
      DECLARE WCHQ_IMPORTE DECIMAL(14,2) ;
      DECLARE Wtcomp_id INT(11) ;   
      DECLARE Wmov_nro_cpbte VARCHAR(20) ;
      DECLARE WSUCURSAL_ID INT(11) ;
      DECLARE WCAJA_ID INT(11)   ; 
      DECLARE WMOV_IDTIPO INT(1)   ; 
      DECLARE Wmov_IMP_PESOS DECIMAL(10,2) DEFAULT 0  ;
      DECLARE WMOV_IMP_DOLARES DECIMAL (10,2) DEFAULT 0 ; 
      DECLARE Wmov_soloefvo INT(1) DEFAULT 0 ; 
      declare hacer INT(1) DEFAULT 0 ; 
      DECLARE Wid_compras bigint(20) ;
      DECLARE Wordenp_pagar double(15,2) ;
      DECLARE Wordenp_nro  varchar(12) ; 
      DECLARE wmov_importe_total DOUBLE(15,2) ;
      DECLARE Wreten_alicuota DOUBLE(5,2) ;
      DECLARE Wreten_imp_areten double(15,2);
      DECLARE Wreten_retenido double(15,2);
      DECLARE Wparc_importe_pago DOUBLE(15,2);
      declare wcomp_nrocpbte varchar(13); 
      
      DECLARE cRegcaja CURSOR FOR 		     
              SELECT m.mov_id, m.mov_fecha , m.mov_detalle , CONCAT(tc.tcomp_abrev ,"-",c.comp_nrocpbte) AS comprobante ,
               m.mov_importe_total ,  concepto_id  , 
                m.mov_idtipo , m.tcomp_id , m.mov_nro_cpbte , sucursal_id , caja_id , 
                m.mov_imp_dolares , m.mov_imp_pesos , m.mov_soloefvo , p.id_compras , 
                c.comp_nrocpbte , p.parc_importe_pago , o.ordenp_nro , o.Ordenp_pagar 
           FROM MOVCAJA M , parciales_comprobantes p , ordenes_pago o , compras c , tipos_comprobantes tc
                    WHERE  p.mov_id = m.mov_id AND o.id_compras= p.id_compras AND o.MOV_ID = p.mov_id 
                    AND c.id_compras = p.id_compras AND tc.tcomp_id = c.tcomp_id AND 
                       m.mov_id = wPmov_id  AND ISNULL(MOV_ANULACION) = 1 ;
  
      DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET hacer = 1;    
        
      DROP TABLE IF EXISTS  CAJA_TEMP ;
      CREATE TEMPORARY TABLE CAJA_TEMP ( 
               MOV_ID BIGINT(20) , 
               MOV_FECHA DATE , 
               MOV_DETALLE VARCHAR(80) ,
               COMPROBANTE VARCHAR(20) , 
               IMPORTE DECIMAL (14,2) , 
               CONCEPTO_ID BIGINT(10) , 
               MOV_IDTIPO INT(1) default 0 , 
               CHQ CHARACTER(1) DEFAULT " " , 
               CHQ_ID BIGINT(20)DEFAULT 0  , 
               BCO_ID INT(11) DEFAULT  0, 
               BCO_DETALLE VARCHAR(60) DEFAULT " " , 
               NRO_CHQ VARCHAR(10) DEFAULT "",
               CHQ_VTO CHAR(10) DEFAULT "" ,                 
               CHQ_IMPORTE DECIMAL (14,2) DEFAULT 0 ,
               sucursal_id INT(11) , 
               CAJA_ID INT(11) , 
               IMPDOLARES DECIMAL (10,2) DEFAULT 0,
               IMPPESOS DECIMAL(10,2) DEFAULT 0 , 
	       ID_COMPRAS BIGINT(20) ,
	       ORDENP_PAGAR DOUBLE(15,2) ,
	       ORDENP_NRO  VARCHAR(12) ,
	       RETEN_ALICUOTA DOUBLE(5,2) ,
	       RETEN_IMP_ARETEN DOUBLE(15,2),
	       RETEN_RETENIDO DOUBLE(15,2),
	       PARC_IMPORTE_PAGO DOUBLE(15,2)   ) ;
                
      OPEN cRegcaja ;
      set hacer = 0 ; 
      REPEAT         
      
        FETCH NEXT FROM cRegcaja
            INTO  wmov_id, wmov_fecha , wmov_detalle , wcomprobante ,
               wmov_importe_total ,  wconcepto_id  , 
                wmov_idtipo ,wtcomp_id , Wmov_nro_cpbte , wsucursal_id , wcaja_id , 
                wmov_imp_dolares , wmov_imp_pesos , wmov_soloefvo , wid_compras , 
                wcomp_nrocpbte , wparc_importe_pago , wordenp_nro , wOrdenp_pagar  ;
            
         if hacer=0 then          
            
            set Wreten_alicuota = (select reten_alicuota  from retenciones where mov_id = wmov_id and id_compras = wid_compras   );
            SET Wreten_alicuota = ifnull(Wreten_alicuota,0) ;
            SET Wreten_imp_areten = (SELECT reten_imp_areten  FROM retenciones WHERE mov_id = wmov_id AND id_compras = wid_compras   ); 
            SET Wreten_imp_areten = IFNULL(Wreten_imp_areten,0);
            SET Wreten_retenido = (SELECT reten_retenido  FROM retenciones WHERE mov_id = wmov_id AND id_compras = wid_compras   ); 
            SET Wreten_retenido = IFNULL(Wreten_retenido,0);
            
            INSERT INTO CAJA_TEMP (MOV_ID , MOV_FECHA , MOV_DETALLE ,cOMPROBANTE ,IMPORTE ,CONCEPTO_ID , 
                                    MOV_IDTIPO,CHQ , SUCURSAL_ID , CAJA_ID, IMPDOLARES ,IMPPESOS ,id_compras ,
                                     ordenp_pagar ,ordenp_nro,reten_alicuota,reten_imp_areten,
					reten_retenido , parc_importe_pago) 
                   VALUES (wMOV_ID , wMOV_FECHA , wMOV_DETALLE ,WCOMPROBANTE ,wmov_importe_total ,wCONCEPTO_ID , 
                           wMOVTIPO , "X" , wsucursal_id, WCAJA_ID , WMOV_IMP_DOLARES , Wmov_IMP_PESOS, Wid_compras , Wordenp_pagar ,
                           Wordenp_nro, Wreten_alicuota, Wreten_imp_areten, Wreten_retenido , Wparc_importe_pago) ;
                           
            IF Wmov_soloefvo = 1 THEN                
		INSERT INTO CAJA_TEMP  
			SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE ,WCOMPROBANTE , wmov_importe_total , WCONCEPTO_ID,
			       WMOVTIPO , "T"  , CT.CHQT_ID,CT.BCO_ID ,  LEFT(B.BCO_DESCRIPCION,30) ,  
			       CT.CHQT_NRO ,CT.CHQT_FVTO , CT.CHQT_IMPORTE,   wsucursal_id, WCAJA_ID , 
			       WMOV_IMP_DOLARES ,Wmov_IMP_PESOS ,Wid_compras , Wordenp_pagar , Wordenp_nro, 
			       Wreten_alicuota,Wreten_imp_areten,Wreten_retenido , Wparc_importe_pago 
			  FROM mov_cheques_terceros CT , bancos_sucursales B 
			       WHERE  B.BCO_ID = CT.BCO_ID  AND  MOV_ID = WMOV_ID ;
							  
		insert into CAJA_TEMP  
			SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE , WCOMPROBANTE , wmov_importe_total , WCONCEPTO_ID, WMOVTIPO  , "T" ,
			  CT.CHQT_ID, CT.BCO_ID ,LEFT(B.BCO_DESCRIPCION,30) ,  CT.CHQT_NRO , CT.CHQT_FVTO , 
			  CT.CHQT_IMPORTE, wsucursal_id, WCAJA_ID , WMOV_IMP_DOLARES , Wmov_IMP_PESOS ,Wid_compras , Wordenp_pagar ,
                           Wordenp_nro, Wreten_alicuota, Wreten_imp_areten, Wreten_retenido , Wparc_importe_pago
                         FROM mov_cheques_terceros CT , bancos_sucursales B 
				 WHERE  B.BCO_ID = CT.BCO_ID  AND  ID_EGRESO = WMOV_ID ;
						
		INSERT INTO CAJA_TEMP  
		  SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE , WCOMPROBANTE , wmov_importe_total , WCONCEPTO_ID, WMOVTIPO , "P"  ,
			  cc.`chq_id`, cc.`cuenta_id`, CONCAT(LEFT(B.`bco_descripcion`,20), "#" , cta.CTA_NUMERO ) , 
			  cc.stk_chq_nro , cc.stk_chq_fvto, cc.`stk_chq_importe`,  wsucursal_id, WCAJA_ID , 
			  WMOV_IMP_DOLARES , Wmov_IMP_PESOS , Wid_compras , Wordenp_pagar ,
                           Wordenp_nro, Wreten_alicuota, Wreten_imp_areten, Wreten_retenido , 
                           Wparc_importe_pago
			  FROM  caja_cheques cc ,  CAJA_CUENTAS cta , bancos_sucursales B 
				  WHERE  cta.cuenta_id = cc.cuenta_id AND B.`bco_id`= cta.`bco_id` AND cc.mov_id = WMOV_ID ;
	    END IF ; 
         end if ;	
      UNTIL hacer END REPEAT;  
		 
      select * from caja_temp ORDER BY MOV_FECHA, MOV_ID , CHQ_ID asc ; 
      DROP TABLE IF EXISTS  CAJA_TEMP ;
       
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mostrar_mov_caja_pagos_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_mostrar_mov_caja_pagos_2`( wPmov_id INT(20))
BEGIN
      
      DECLARE WMOV_ID BIGINT(20) ;
      DECLARE WMOV_FECHA DATE ;
      DECLARE WMOV_DETALLE VARCHAR(150) ;
      DECLARE WCOMPROBANTE VARCHAR(20) ;
      DECLARE WIMPORTE DECIMAL (14,2) ;
      DECLARE WCONCEPTO_ID BIGINT(10) ; 
      DECLARE WMOVTIPO INT(1) ;       
      DECLARE WCHQ CHARACTER(1) DEFAULT "T" ;
      DECLARE WCHQ_ID BIGINT(20) ;
      DECLARE WBCO_ID INT(11);
      DECLARE WBCO_DETALLE VARCHAR(30) ;
      DECLARE WNRO_CHQ VARCHAR(10) ;
      DECLARE WCHQ_VTO DATE ; 
      DECLARE WCHQ_IMPORTE DECIMAL(14,2) ;
      DECLARE Wtcomp_id INT(11) ;   
      DECLARE Wmov_nro_cpbte VARCHAR(20) ;
      DECLARE WSUCURSAL_ID INT(11) ;
      DECLARE WCAJA_ID INT(11)   ; 
      DECLARE WMOV_IDTIPO INT(1)   ; 
      DECLARE Wmov_IMP_PESOS DECIMAL(10,2) DEFAULT 0  ;
      DECLARE WMOV_IMP_DOLARES DECIMAL (10,2) DEFAULT 0 ; 
      DECLARE Wmov_soloefvo INT(1) DEFAULT 0 ; 
      DECLARE hacer INT(1) DEFAULT 0 ; 
      DECLARE Wid_compras BIGINT(20) ;
      DECLARE Wordenp_pagar DOUBLE(15,2) ;
      DECLARE Wordenp_nro  VARCHAR(12) ; 
      DECLARE wmov_importe_total DOUBLE(15,2) ;
      DECLARE Wreten_alicuota DOUBLE(5,2) ;
      DECLARE Wreten_imp_areten DOUBLE(15,2);
      DECLARE Wreten_retenido DOUBLE(15,2);
      DECLARE Wparc_importe_pago DOUBLE(15,2);
      DECLARE wcomp_nrocpbte VARCHAR(13); 
      DECLARE w1ra INT(1) DEFAULT 0 ; 
      DECLARE cRegcaja CURSOR FOR 		     
              SELECT m.mov_id, m.mov_fecha , m.mov_detalle , m.mov_importe_total , 
                m.mov_idtipo , m.tcomp_id , m.mov_nro_cpbte , m.sucursal_id , m.caja_id , 
                m.mov_imp_dolares , m.mov_imp_pesos , m.mov_soloefvo ,  
                p.parc_importe_pago , p.id_compras , 
                CONCAT(tc.tcomp_abrev ,"-",c.comp_nrocpbte) AS comprobante
           FROM MOVCAJA M , parciales_comprobantes p , compras c , tipos_comprobantes tc 
               WHERE  p.mov_id = m.mov_id AND 
                      c.id_compras = p.id_compras AND 
                      tc.tcomp_id = c.tcomp_id AND
                   m.mov_id = wPmov_id  AND 
                   ISNULL(MOV_ANULACION) = 1 ;
                      
  
      DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET hacer = 1;    
        
      DROP TABLE IF EXISTS  CAJA_TEMP ;
      CREATE TEMPORARY TABLE CAJA_TEMP ( 
               MOV_ID BIGINT(20) , 
               MOV_FECHA DATE , 
               MOV_DETALLE VARCHAR(150) ,
               COMPROBANTE VARCHAR(20) , 
               IMPORTE DECIMAL (14,2) , 
               CONCEPTO_ID BIGINT(10) , 
               MOV_IDTIPO INT(1) DEFAULT 0 , 
               CHQ CHARACTER(1) DEFAULT " " , 
               CHQ_ID BIGINT(20)DEFAULT 0  , 
               BCO_ID INT(11) DEFAULT  0, 
               BCO_DETALLE VARCHAR(60) DEFAULT " " , 
               NRO_CHQ VARCHAR(10) DEFAULT "",
               CHQ_VTO CHAR(10) DEFAULT "" ,                 
               CHQ_IMPORTE DECIMAL (14,2) DEFAULT 0 ,
               sucursal_id INT(11) , 
               CAJA_ID INT(11) , 
               IMPDOLARES DECIMAL (10,2) DEFAULT 0,
               IMPPESOS DECIMAL(10,2) DEFAULT 0 , 
	       ID_COMPRAS BIGINT(20) ,
	       ORDENP_PAGAR DOUBLE(15,2) ,
	       ORDENP_NRO  VARCHAR(12) ,
	       RETEN_ALICUOTA DOUBLE(5,2) ,
	       RETEN_IMP_ARETEN DOUBLE(15,2),
	       RETEN_RETENIDO DOUBLE(15,2),
	       PARC_IMPORTE_PAGO DOUBLE(15,2) , 
	       TIPO_REGISTRO CHAR(3) ) ;
                
      OPEN cRegcaja ;
      SET hacer = 0 ; 
      REPEAT         
      
        FETCH NEXT FROM cRegcaja
            INTO  wmov_id, wmov_fecha , wmov_detalle , wmov_importe_total , 
                wmov_idtipo , wtcomp_id , wmov_nro_cpbte , wsucursal_id , wcaja_id , 
                wmov_imp_dolares , wmov_imp_pesos , wmov_soloefvo , wparc_importe_pago , wid_compras , wcomprobante;
            
         IF hacer=0 THEN    
            -- BUSCO LAS RETENCIONES REALIZADAS AL COMPROBANTE
            -- ================================================
            SET Wreten_alicuota = (SELECT reten_alicuota  FROM retenciones WHERE mov_id = wmov_id AND id_compras = wid_compras   );
            SET Wreten_alicuota = IFNULL(Wreten_alicuota,0) ;
            SET Wreten_imp_areten = (SELECT reten_imp_areten  FROM retenciones WHERE mov_id = wmov_id AND id_compras = wid_compras   ); 
            SET Wreten_imp_areten = IFNULL(Wreten_imp_areten,0);
            SET Wreten_retenido = (SELECT reten_retenido  FROM retenciones WHERE mov_id = wmov_id AND id_compras = wid_compras   ); 
            SET Wreten_retenido = IFNULL(Wreten_retenido,0);
            
	    -- CARGO >>> MOV + PAGO PARCIAL + COMPROBANTE + RETENCIONES 
	    -- =========================================================    
	    INSERT INTO CAJA_TEMP (MOV_ID , MOV_FECHA , MOV_DETALLE ,COMPROBANTE,IMPORTE ,concepto_id ,
		        MOV_IDTIPO, CHQ , SUCURSAL_ID , CAJA_ID, IMPDOLARES ,IMPPESOS  ,
		        tipo_registro ,  PARC_IMPORTE_PAGO ,ID_COMPRAS , RETEN_ALICUOTA ,RETEN_IMP_ARETEN , RETEN_RETENIDO ) 
	        VALUES (wmov_id , wmov_fecha , wmov_detalle ,wcomprobante ,wmov_importe_total ,wconcepto_id , 
		        wmovtipo , "X" , wsucursal_id, wcaja_id , wmov_imp_dolares , wmov_imp_pesos, "MOV",
		         wparc_importe_pago , wid_compras, wreten_alicuota, wreten_imp_areten, wreten_retenido) ; 
		         
		         
            -- CHEQUES DE PROPIOS Y DE TERCEROS 
            -- =========================================================        
            IF wmov_soloefvo = 1 AND w1ra = 0 THEN  
                SET w1ra = 1  ;              
		INSERT INTO CAJA_TEMP  
			SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE ,WCOMPROBANTE , wmov_importe_total , WCONCEPTO_ID,
			       WMOVTIPO , "T"  , CT.CHQT_ID,CT.BCO_ID ,  LEFT(B.BCO_DESCRIPCION,30) ,  
			       CT.CHQT_NRO ,CT.CHQT_FVTO , CT.CHQT_IMPORTE,   wsucursal_id, WCAJA_ID , 
			       0 ,0 ,0 , 0 , "", 
			       Wreten_alicuota,Wreten_imp_areten,Wreten_retenido , Wparc_importe_pago , "CHT"
			  FROM mov_cheques_terceros CT , bancos_sucursales B 
			       WHERE  B.BCO_ID = CT.BCO_ID  AND  MOV_ID = WMOV_ID ;
							  
		INSERT INTO CAJA_TEMP  
			SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE , WCOMPROBANTE , wmov_importe_total , WCONCEPTO_ID, WMOVTIPO  , "T" ,
			  CT.CHQT_ID, CT.BCO_ID ,LEFT(B.BCO_DESCRIPCION,30) ,  CT.CHQT_NRO , CT.CHQT_FVTO , 
			  CT.CHQT_IMPORTE, wsucursal_id, WCAJA_ID , 0 , 0 ,0 , 0 ,"", 0, 0, 0 , 0 , "CHT"
                         FROM mov_cheques_terceros CT , bancos_sucursales B 
				 WHERE  B.BCO_ID = CT.BCO_ID  AND  ID_EGRESO = WMOV_ID ;
						
		INSERT INTO CAJA_TEMP  
		  SELECT WMOV_ID , WMOV_FECHA, WMOV_DETALLE , WCOMPROBANTE , wmov_importe_total , WCONCEPTO_ID, WMOVTIPO , "P"  ,
			  cc.`chq_id`, cc.`cuenta_id`, CONCAT(LEFT(B.`bco_descripcion`,20), "#" , cta.CTA_NUMERO ) , 
			  cc.stk_chq_nro , cc.stk_chq_fvto, cc.`stk_chq_importe`,  wsucursal_id, WCAJA_ID , 0 , 0 ,0 , 0 ,"", 
			   0, 0, 0 , 0, "CHP"
			  FROM  caja_cheques cc ,  CAJA_CUENTAS cta , bancos_sucursales B 
				  WHERE  cta.cuenta_id = cc.cuenta_id AND B.`bco_id`= cta.`bco_id` AND cc.mov_id = WMOV_ID ;
	    END IF ; 
         END IF ;	
      UNTIL hacer END REPEAT;  
		 
      SELECT * FROM caja_temp ORDER BY MOV_FECHA, MOV_ID , CHQ_ID ASC ; 
      DROP TABLE IF EXISTS  CAJA_TEMP ;
       
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mostrar_ordenes_pago_pendientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_mostrar_ordenes_pago_pendientes`(wnroop VARCHAR(10), wresumen INT(1) , westado VARCHAR(4) )
BEGIN
       IF wnroop = "0" THEN 
          IF wresumen = 1 THEN 
		 SELECT ordenp_nro , op.cuit , id_compras , ordenp_pagar , prov_razsocial  
		     FROM ordenes_pago op , proveedores p  
		     WHERE p.cuit = op.cuit AND  ordenp_estado = westado GROUP BY ordenp_nro ; 
          ELSE 
		 SELECT ordenp_nro , op.cuit , id_compras , ordenp_pagar , prov_razsocial  
		     FROM ordenes_pago op , proveedores p  
		     WHERE p.cuit = op.cuit AND  ordenp_estado = westado ;           
          END IF ;
       ELSE 
           IF wresumen = 1 THEN 
		 SELECT ordenp_nro , op.cuit , id_compras , ordenp_pagar , prov_razsocial  
		     FROM ordenes_pago op , proveedores p  
		     WHERE p.cuit = op.cuit AND ordenp_nro=wnroop  GROUP BY ordenp_nro ; 
          ELSE 
		SELECT   CONCAT(tc.tcomp_abrev,': ' , comp_nrocpbte) AS cpbte ,  c.*
		       , IF(ISNULL(comp_vto)=1,"",comp_vto) AS comp_vto2  , " " AS marca, 
		      IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, 
		      tiva_descripcion, mmot_descripcion , 
		      Ordenp_pagar  AS pagar , Ordenp_pagar  AS SALDO 
		  FROM ordenes_pago op , compras c, tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
		    WHERE c.id_compras = op.id_compras 
		        AND tc.tcomp_id= c.tcomp_id  
			AND ti.tiva_id = c.tiva_id 
			AND mt.mmot_id = c.mmot_id 
			AND op.ordenp_estado = westado
			AND op.ordenp_nro = wnroop
			AND ISNULL(comp_fbaja) = 1  
			AND ISNULL(mov_fecha) = 1 
			GROUP BY c.id_compras 
			ORDER BY comp_fechacpbte ;           
          END IF ;
       END IF ;
       	     
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mostrar_retenciones` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_mostrar_retenciones`(wmov_id BIGINT(20))
BEGIN
	IF wmov_id = 0 THEN
		SELECT CONCAT(t.`tcomp_descripcion`, " Nro. " , C.`comp_nrocpbte`) AS cpbte , C.`empresa_id`  , C.`comp_total`,
		       C.`comp_expediente`, C.`prov_razsocial` , 
			 R.*  , P.`prov_direccion` , P.CUIT, " " as marca
		  FROM RETENCIONES R  , COMPRAS C , proveedores P , tipos_comprobantes T
		    WHERE  C.`id_compras`= R.`id_compras` AND  
			   P.`cuit`= C.`cuit` AND
			   t.`tcomp_id` = c.`tcomp_id` ;	
	ELSE 
		SELECT CONCAT(t.`tcomp_descripcion`, " Nro. " , C.`comp_nrocpbte`) AS cpbte , C.`empresa_id`  , C.`comp_total`,
		       C.`comp_expediente`, C.`prov_razsocial` , 
			 R.*  , P.`prov_direccion` , P.CUIT, " " AS marca
		  FROM RETENCIONES R  , COMPRAS C , proveedores P , tipos_comprobantes T
		    WHERE  C.`id_compras`= R.`id_compras` AND  
			   P.`cuit`= C.`cuit` AND
			   t.`tcomp_id` = c.`tcomp_id` AND 
			    R.MOV_ID = wmov_id;
	END IF 	;	    
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mostrar_retenciones_full` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `sp_mostrar_retenciones_full`(wempre int(3) )
BEGIN
	SELECT  "IIBB" AS IMPUESTO , C.PROV_RAZSOCIAL AS RAZON_SOCIAL , C.CUIT ,
	      comp_expediente AS EXPEDIENTE,  comp_fechacpbte AS FECHA_CPBTE , 
	      CONCAT(tcomp_descripcion, "-" , comp_nrocpbte ) AS CPBTE ,  
	      reten_certificado AS CERTIFICADO , reten_fecha AS FECHA_RETENCION ,
	       reten_imp_areten AS IMPORTE_GRAVADO , 
	      reten_alicuota AS ALICUOTA , reten_retenido AS RETENIDO
	   FROM RETENCIONES R , COMPRAS C , MOVCAJA M , TIPOS_COMPROBANTES T
	   WHERE C.`id_compras`= R.`id_compras` AND 
		 M.`mov_id`=R.`mov_id` AND 
		 T.`tcomp_id` = C.`tcomp_id` and C.EMPRESA_ID = wempre 
		 ORDER BY comp_expediente ; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mostrar_retenciones_Xid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_mostrar_retenciones_Xid`(wretencion_id BIGINT(20))
BEGIN
	IF wretencion_id = 0 THEN
		SELECT CONCAT(t.`tcomp_descripcion`, " Nro. " , C.`comp_nrocpbte`) AS cpbte , C.`empresa_id`  , C.`comp_total`,
		       C.`comp_expediente`, C.`prov_razsocial` , 
			 R.*  , P.`prov_direccion` , P.CUIT, " " AS marca
		  FROM RETENCIONES R  , COMPRAS C , proveedores P , tipos_comprobantes T
		    WHERE  C.`id_compras`= R.`id_compras` AND  
			   P.`cuit`= C.`cuit` AND
			   t.`tcomp_id` = c.`tcomp_id` ;	
	ELSE 
		SELECT CONCAT(t.`tcomp_descripcion`, " Nro. " , C.`comp_nrocpbte`) AS cpbte , C.`empresa_id`  , C.`comp_total`,
		       C.`comp_expediente`, C.`prov_razsocial` , 
			 R.*  , P.`prov_direccion` , P.CUIT, " " AS marca
		  FROM RETENCIONES R  , COMPRAS C , proveedores P , tipos_comprobantes T
		    WHERE  C.`id_compras`= R.`id_compras` AND  
			   P.`cuit`= C.`cuit` AND
			   t.`tcomp_id` = c.`tcomp_id` AND 
			    R.retencion_id = wretencion_id;
	END IF 	;	    
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mostrar_reten_ventas_compras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `sp_mostrar_reten_ventas_compras`(wempre int(3), wdesde date , whasta date )
BEGIN
	DROP TABLE IF EXISTS list_reten  ;
	CREATE TEMPORARY TABLE LIST_RETEN 
	SELECT (SELECT TRIM(LEFT(tt.tcomp_abrev,6)) FROM tipos_comprobantes tt WHERE tt.tcomp_id = r.tcomp_id LIMIT 1) AS IMPUESTO , 
	C.PROV_RAZSOCIAL AS RAZON_SOCIAL ,
	C.CUIT ,
	comp_expediente AS EXPEDIENTE,  
	comp_fechacpbte AS FECHA_CPBTE , 
	CONCAT(t.tcomp_abrev, "-" , comp_nrocpbte ) AS CPBTE ,  
	reten_certificado AS CERTIFICADO , 
	reten_fecha AS FECHA_RETENCION ,
	reten_imp_areten AS IMPORTE_GRAVADO , 
	reten_alicuota AS ALICUOTA , 
	reten_retenido AS RETENIDO
	   FROM RETENCIONES R , COMPRAS C , MOVCAJA M , TIPOS_COMPROBANTES T
	   WHERE C.`id_compras`= R.`id_compras` AND 
		 M.`mov_id`=R.`mov_id` AND reten_fecha BETWEEN wdesde AND whasta AND 
		 T.`tcomp_id` = C.`tcomp_id` AND C.EMPRESA_ID = wempre AND c.ID_COMPRAS <> 0
		 ORDER BY comp_expediente ;  
		 
	INSERT INTO LIST_RETEN  SELECT (SELECT TRIM(left(tt.tcomp_abrev,6)) FROM tipos_comprobantes tt WHERE tt.tcomp_id = r.tcomp_id LIMIT 1) , 
	C.CLI_NOMBRE  ,
	C.CLI_CUIT ,
	"" ,  
	VENTA_fechacpbte  , 
	CONCAT(t.tcomp_abrev, "-" , venta_nrocpbte ) AS CPBTE ,  
	reten_certificado  , 
	reten_fecha  ,
	reten_imp_areten , 
	reten_alicuota , 
	reten_retenido 
	   FROM RETENCIONES R , VENTAS C , MOVCAJA M , TIPOS_COMPROBANTES T
	   WHERE C.`id_venta`= R.`id_venta` AND 
		 M.`mov_id`=R.`mov_id` AND  
		 T.`tcomp_id` = C.`tcomp_id` AND 
		 reten_fecha BETWEEN wdesde AND whasta AND 
		 C.EMPRE_ID = wempre AND c.ID_VENTA <> 0 ;
	SELECT * FROM list_reten ;
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_MuestraClientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_MuestraClientes`(westado INT(1) /*0- todos , 1-solo activos , 2- solo bajas */, wconcta INT(1))
BEGIN
     IF wconcta = 0 THEN 
	      IF westado = 0 THEN 
		 SELECT CL.*, IF(ISNULL(cli_fbaja)=0,"BAJA", "ACTIVO") AS estado 
		     FROM clientes CL WHERE cli_lleva_cta = 0 ORDER BY cli_nombre ; 
	      END IF ; 
	      IF westado = 1 THEN 
		 SELECT CL.*, IF(ISNULL(cli_fbaja)=0,"BAJA", "ACTIVO") AS estado 
		     FROM clientes CL WHERE ISNULL(cli_fbaja)=0 AND cli_lleva_cta = 0 ORDER BY cli_nombre ;       
	      END IF ; 
	      IF westado = 2 THEN 
		 SELECT CL.*, IF(ISNULL(cli_fbaja)=0,"BAJA", "ACTIVO") AS estado 
		     FROM clientes CL WHERE ISNULL(cli_fbaja)=1 AND cli_lleva_cta = 0  ORDER BY cli_nombre ;      
	      END IF ; 
     ELSE 
              IF westado = 0 THEN 
		      SELECT CL.*, IF(ISNULL(cli_fbaja)=0,"BAJA", "ACTIVO") AS estado 
			     FROM clientes CL WHERE cli_lleva_cta = 1 ORDER BY cli_nombre ; 
	      END IF ; 
	      IF westado = 1 THEN 
			 SELECT CL.*, IF(ISNULL(cli_fbaja)=0,"BAJA", "ACTIVO") AS estado 
			     FROM clientes CL WHERE ISNULL(cli_fbaja)=0  AND cli_lleva_cta = 1 ORDER BY cli_nombre ;       
	      END IF ; 
	      IF westado = 2 THEN 
			 SELECT CL.*, IF(ISNULL(cli_fbaja)=0,"BAJA", "ACTIVO") AS estado 
			     FROM clientes CL WHERE ISNULL(cli_fbaja)=1 AND cli_lleva_cta = 1  ORDER BY cli_nombre ;      
	      END IF ;
     END IF  ;
      
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_numerador_expedientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_numerador_expedientes`( wempre int(4))
BEGIN
         SELECT * FROM numerador_compras WHERE empre_id = wempre AND ISNULL(cierre_periodo ) = 1 ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_periodo_caja` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_periodo_caja`(wcaja int(11), wsuc int(11), wtipo int(1) )
BEGIN
       if wtipo = 0 then 
			 SELECT ccaja_periodo AS periodo , ccaja_fecha_inicio AS inicio , ccaja_fecha_cierre AS cierre , 
			      ccaja_fecha_proceso AS proceso , ccaja_id as cierreid , ccaja_imppesos, ccaja_impdolares, 
			      ccaja_chq_terceros ,ccaja_chq_propios
				  FROM cierres_caja 
				  WHERE caja_id = wcaja AND sucursal_id = wsuc AND ISNULL(ccaja_fecha_cierre) = 1 ;
		 end if 	; 	  
       IF wtipo = 1 THEN 
			 SELECT ccaja_periodo AS periodo , ccaja_fecha_inicio AS inicio , ccaja_fecha_cierre AS cierre , 
			      ccaja_fecha_proceso AS proceso , ccaja_id AS cierreid , ccaja_imppesos, ccaja_impdolares, 
			      ccaja_chq_terceros ,ccaja_chq_propios
				  FROM cierres_caja 
				  WHERE caja_id = wcaja AND sucursal_id = wsuc AND ISNULL(ccaja_fecha_cierre) = 0 ; 		     
		 end if 	;	
		 
       IF wtipo = 9 THEN 
          if wcaja = 0  then 
					SELECT cc.* , sucur_descripcion as dsc_suc , caja_descripcion as dsc_caja , 
					      (select usu_nombre from usuarios u where u.usuario_id = cc.usuario_id) as usuario
							FROM cierres_caja cc, sucursales s , cajas c 
							WHERE s.sucursal_id  = cc.sucursal_id  and c.caja_id = cc.caja_id 
								order by dsc_suc ,  dsc_caja, ccaja_periodo		   ; 		     
			 else 
					SELECT cc.* , sucur_descripcion AS dsc_suc , caja_descripcion AS dsc_caja ,
					     (SELECT usu_nombre FROM usuarios u WHERE u.usuario_id = cc.usuario_id) AS usuario
							FROM cierres_caja cc, sucursales s , cajas c 
							WHERE s.sucursal_id  = cc.sucursal_id  AND c.caja_id = cc.caja_id and 
							 cc.sucursal_id = wsuc and cc.caja_id = wcaja ORDER BY dsc_suc ,  dsc_caja, ccaja_periodo		; 		     			 
			 end if ;				
		 END IF 	;			 		 	 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_proximo_cheque` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`%`*/ /*!50003 PROCEDURE `sp_proximo_cheque`(wcuenta integer(5))
BEGIN
 -- cuenta_id, STK_CHQ_NRO,  CHQ_ID 
SELECT  *   
      FROM CAJA_CHEQUES WHERE CUENTA_ID = wcuenta 
                AND ISNULL(STK_CHQ_FEMISIN)= 1 AND ISNULL(stk_chq_anulado)= 1 
                  ORDER BY stk_chq_nro ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_resumen_gral_compras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_resumen_gral_compras`(wejercicio int (3))
BEGIN
    
			 SELECT  tc.tcomp_abrev, 
						 c.id_sucursal as suc, 
						  c.id_caja as numcaja , 
						  c.id_compras as idcomp , 
						  c.cuit , 
						  c.tcomp_id as idtcomp , 
						  c.comp_fechacpbte  as fcpbte , 
						  c.comp_nrocpbte as nrocpbte , 
						  c.prov_razsocial as nomprov ,  
						  c.comp_vto as vto ,
						  ti.tiva_cpo1 as cat , 
						  if(isnull(c.comp_anulado)=1,"  ",c.comp_anulado)  as anul , 
						  c.usu_id as idusu ,
						  c.comp_iva21 as iva21 , 
						  c.comp_iva105 as iva105 , 
						  c.comp_percep_iva as periva ,
						  c.comp_percep_iibb as periibb,
						  c.comp_reten_iibb as retiibb ,
						  c.comp_reten_ganancias as retganan , 
						  c.comp_varios as varios , 
						  c.comp_bruto as bruto , 
						  c.comp_total as total ,
						  c.mmot_id  as motivo , 
						  c.comp_detalle as obser , 
						  c.comp_fcarga as fcarga,
						  IF(ISNULL(c.comp_fbaja)=1, "  ",c.comp_fbaja) as fbaja,
						  IF(ISNULL(c.comp_periodo)=1,"  ",c.comp_periodo) as periodo,
						  IF(ISNULL(c.comp_fprocesado) =1, "  " ,c.comp_fprocesado )as fproc , 
						  IF(ISNULL(c.mov_fecha)=1," ",c.mov_fecha)  as fmov,
						  c.mov_id  as idmov,
						  IF(ISNULL(c.id_egreso)=1,"",c.id_egreso) as idegre, 
						  tcomp_descripcion AS nomcomp,
						  sucur_descripcion as sucnom ,
						  concat(c.mmot_id ," - ",m.mmot_descripcion) as nommotxx  
				 FROM compras c, tipos_comprobantes tc   , sucursales s , motivos_movimientos m , tipos_iva ti
					WHERE tc.tcomp_id = c.tcomp_id 
					    and s.sucursal_id  = c.id_sucursal 
					    and m.mmot_id  = c.mmot_id 
					    and ti.tiva_id = c.tiva_id 
					    AND ejercicio_id = wejercicio ORDER BY comp_expediente; 
					    -- AND CONCAT( CONVERT(MONTH(comp_fechacpbte),CHAR(2)) , CONVERT(YEAR(comp_fechacpbte), CHAR(4)) ) = TRIM(wper) 
							
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_saldos_ctasctes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_saldos_ctasctes`(wcuit char(11) , wempre int(4))
BEGIN
	if wempre = 0 then 
		SELECT  2 as mov_tipo, sal_fecha_aplic as fecha  , 
				concat("Saldo Inicial ",sal_ejercicio) as cpbte,  
				sal_importe as importe
		     FROM saldos_ctasctes 
		     WHERE cuit = wcuit 
			    and isnull(Sal_ejerc_anulado) = 1; 
	else 
		SELECT  2 AS mov_tipo, sal_fecha_aplic AS fecha  , 
			CONCAT("Saldo Inicial ",sal_ejercicio) AS cpbte,  
			sal_importe AS importe
		     FROM saldos_ctasctes 
		     WHERE cuit = wcuit  and 
		            empre_id = wempre 
			    AND ISNULL(Sal_ejerc_anulado) = 1; 
	end if;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Saldos_pendientes_compras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Saldos_pendientes_compras`(wempre INT(1), WCUIT VARCHAR(11))
BEGIN
	IF LENGTH(WCUIT) <11   THEN 
		SELECT  CONCAT(tc.tcomp_abrev,': ' , 
		       comp_nrocpbte) AS cpbte ,  c.*
		       ,pr.prov_nombre , pr.id_rubro , rub.rubro_descripcion , IF(ISNULL(comp_vto)=1,"",
		       comp_vto) AS comp_vto2  , 
		       " " AS marca,
		      IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, 
		      tiva_descripcion, mmot_descripcion , 
		      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) AS pagar,  pr.prov_nombre
		  FROM compras c, proveedores pr, rubros rub,  tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
		    WHERE  pr.cuit =c.cuit 
		        AND rub.rubro_codigo = pr.id_rubro 
		        AND tc.tcomp_id = c.tcomp_id 
			AND ti.tiva_id=c.tiva_id 
			AND mt.mmot_id = c.mmot_id 
			AND mt.empre_id = wempre
			AND c.empresa_id = wempre  
			AND rub.empresa_id = wempre
			AND ISNULL(comp_fbaja) = 1  
			AND ISNULL(mov_fecha) = 1 
			AND  funRelacion_comprobante_proceso(wempre,c.tcomp_id,"ORDP") > 0 
			ORDER BY  prov_razsocial , comp_fechacpbte  ;   
	ELSE 
		SELECT  CONCAT(tc.tcomp_abrev,': ' , 
		       comp_nrocpbte) AS cpbte ,  c.*
		       ,pr.prov_nombre, pr.id_rubro , rub.rubro_descripcion ,IF(ISNULL(comp_vto)=1,"",
		       comp_vto) AS comp_vto2  , 
		       " " AS marca,
		      IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, 
		      tiva_descripcion, mmot_descripcion , 
		      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(id_compras,0) ) AS pagar ,  pr.prov_nombre
		  FROM compras c, proveedores pr, rubros rub, tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
		    WHERE  pr.cuit =c.cuit  
		        AND rub.rubro_codigo = pr.id_rubro
		        AND tc.tcomp_id = c.tcomp_id 
			AND ti.tiva_id=c.tiva_id 
			AND mt.mmot_id = c.mmot_id 
			AND mt.empre_id = wempre
			AND c.empresa_id = wempre
			AND rub.empresa_id = wempre
			AND C.CUIT = WCUIT    
			AND ISNULL(comp_fbaja) = 1  
			AND ISNULL(mov_fecha) = 1 
			AND  funRelacion_comprobante_proceso(wempre,c.tcomp_id,"ORDP") > 0 
			ORDER BY  prov_razsocial , comp_fechacpbte  ;	   		
	END IF ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Saldos_pendientes_ventas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Saldos_pendientes_ventas`(wempre INT(1), WCUIT VARCHAR(11), wctate INT(1), wproc VARCHAR(4))
BEGIN
	IF LENGTH(WCUIT) <11   THEN 
		SELECT v.cli_cuit , v.venta_nrocpbte,  CONCAT(tc.tcomp_abrev,': ' , 
		       venta_nrocpbte) AS cpbte , CL.CLI_RAZSOC AS CLI_RAZSOC_CL , cl.cli_nombre AS cli_nombre_CL, 
		       " " AS marca,  v.* ,
		       IF(ISNULL(tc.tcomp_cpo3)=1,"    ", 
		       tc.tcomp_numera) AS imprime, 
		      tiva_descripcion, mmot_descripcion  , 
		      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(0,v.id_venta) ) AS pagar 		      
		  FROM ventas v, clienteS cl, rubros rub,  tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
		    WHERE  cl.cli_cuit =v.CLI_cuit 
		        AND tc.tcomp_id = v.tcomp_id 
			AND ti.tiva_id=v.tiva_id 
			AND mt.mmot_id = v.mmot_id 
			AND mt.empre_id = wempre
			AND v.empre_id = wempre  
			AND ISNULL(venta_fbaja) = 1  
			AND cli_lleva_cta = wctate
			AND  EXISTS(SELECT RELACION_ID FROM relacion_comprobante_procesos WHERE relacion_habil = 0 AND 
	          TCOMP_ID = v.tcomp_id AND 
	          PROCESO  = wproc AND 
	          empresa_id = wempre)
			GROUP BY v.cli_cuit , v.venta_nrocpbte 
			ORDER BY  cl.cli_nombre , venta_fechacpbte  ;   
	ELSE 
		SELECT  CONCAT(tc.tcomp_abrev,': ' , 
		       venta_nrocpbte) AS cpbte , CL.CLI_RAZSOC AS CLI_RAZSOC_CL , cl.cli_nombre AS cli_nombre_CL,
		       " " AS marca,  v.* ,
		       IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, 
		      tiva_descripcion, mmot_descripcion , 
		      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(0,v.id_venta) ) AS pagar , 
		      (SELECT caja_ctas_ctes.funControl_Saldos_comprobantes(0,v.id_venta) ) AS SALDO		      
		  FROM ventas v, clienteS cl, rubros rub,  tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
		    WHERE  cl.cli_cuit =v.CLI_cuit 
		        AND tc.tcomp_id = v.tcomp_id 
			AND ti.tiva_id=v.tiva_id 
			AND mt.mmot_id = v.mmot_id 
			AND mt.empre_id = wempre
			AND v.empre_id = wempre  
			AND v.CLI_CUIT = WCUIT
			AND ISNULL(venta_fbaja) = wctate  
			AND cli_lleva_cta = wctate
			AND  EXISTS(SELECT RELACION_ID FROM relacion_comprobante_procesos WHERE relacion_habil = 0 AND 
	          TCOMP_ID = v.tcomp_id AND 
	          PROCESO  = wproc AND 
	          empresa_id = wempre)
			GROUP BY v.cli_cuit , v.venta_nrocpbte
			ORDER BY  cl.cli_nombre , venta_fechacpbte  ;	   		
	END IF ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_Update_chqs_terceros_pagos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Update_chqs_terceros_pagos`( wmovid BIGINT(20), wid_cheques VARCHAR(500) )
BEGIN
    DECLARE V_RETURN INT (10) DEFAULT 0 ;
    
      SET @wcomm = CONCAT( "UPDATE MOV_CHEQUES_TERCEROS SET ID_EGRESO = ",wmovid,
           " WHERE CHQT_ID IN(",wid_cheques,")  " );
       PREPARE stmt1 FROM @wcomm ; 
       EXECUTE stmt1 ;
       SET V_RETURN := ROW_COUNT() ;
       SELECT V_RETURN ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Update_Ordenes_Pago` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Update_Ordenes_Pago`( WCUIT VARCHAR(13), wcomprobantes VARCHAR(550), wordenp_estado CHAR(4) , mov_id BIGINT(20), wOrdPago varchar(10))
BEGIN
        DECLARE wnroOP BIGINT(20);
        DECLARE wnroOPstr VARCHAR(10) ;
        delete from ordenes_pago where ordenp_nro = wOrdPago; 
	   SET wnroOPstr = wOrdPago ;
	   SET wcomprobantes = REPLACE(wcomprobantes, '@1' , wcuit ) ; 
	   SET wcomprobantes = REPLACE(wcomprobantes, '@2' , wnroOPstr ) ; 
	   SET @wcomm = CONCAT( "INSERT INTO ordenes_pago (empresa_id ,  cuit, ordenp_nro ,id_compras , Ordenp_pagar , ordenp_estado , mov_id ) VALUES ",  wcomprobantes );
	   PREPARE stmt1 FROM @wcomm ; 
	   EXECUTE stmt1 ;
	   SELECT * FROM ordenes_pago WHERE ordenp_nro = wnroOPstr; 
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
/*!50003 DROP PROCEDURE IF EXISTS `sp_VENTAS_Ailcuotas_SIAP` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_VENTAS_Ailcuotas_SIAP`(wempre INT(4), wspPeriodo CHAR(6))
BEGIN
      SELECT REPLACE(v.venta_fechacpbte,"-" , "")AS FEC , 
            RIGHT(CONCAT("000",tc.tcomp_id),3) AS tcomp_id , 
             right(concat("000",tc.tcomp_afip),3) as tcomp_afip , 
             v.tiva_id as tipoIVA , 
             right(concat("00000",LEFT(v.venta_nrocpbte,4)), 5)as pto_vta , 
             RIGHT(CONCAT("00000000000000000000",substr(v.venta_nrocpbte,5)), 20)as  nro ,
               CASE 
		    WHEN v.tiva_id = 6 AND v.tcomp_id in (5,8,16) 
		               THEN  RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(round(v.venta_total /1.21,2)   , CHARACTER),".","")),15) 
		    WHEN v.tiva_id <> 6 AND v.tcomp_id IN (4,7,8)
		               THEN    RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(v.venta_imp_neto_gravado  , CHARACTER),".","")),15)
		    ELSE  "000000000000000" 
		END AS imp_neto_grav , 
               CASE 
		    WHEN v.tiva_id = 6 AND v.tcomp_id IN (5,8,16) 
		               THEN  "0005"  
		    WHEN v.tiva_id <> 6 AND v.tcomp_id IN (4,7,8)
		               THEN  RIGHT(CONCAT("0000",REPLACE(CONVERT(if (round((v.venta_total-v.venta_imp_neto_gravado)*100 / v.venta_total,2)>  10.6, 5,4)   , CHARACTER),".","")),4)
		    ELSE  "0000" 
		END AS cod_alicuota_iva ,		
               CASE 
		    WHEN v.tiva_id = 6 AND v.tcomp_id IN (5,8,16) 
		               THEN  RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(ROUND(v.venta_total -(v.venta_total / 1.21),2)  , CHARACTER),".","")),15)
		    WHEN v.tiva_id <> 6 AND v.tcomp_id IN (4,7,8)
		         THEN  RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(ROUND((v.venta_total-v.venta_imp_neto_gravado)*100 / v.venta_total,2)  , CHARACTER),".","")),15)
		    ELSE  "000000000000000" 
		 END AS importe_iva 
	   FROM VENTAS v,  tipos_comprobantes tc  
	        WHERE tc.tcomp_id = v.tcomp_id AND
			VENTA_PERIODO  = wspPeriodo  AND 
			v.empre_id = wempre  and v.tiva_id <> 5 
			ORDER BY venta_nrocpbte ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ventas_cuit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_ventas_cuit`(wempre int(4), wcCuit varchar(15))
BEGIN
  SELECT  CONCAT(tc.tcomp_abrev,': ' ,venta_nrocpbte) AS cpbte ,  c.*, IF(ISNULL(venta_vto)=1,"",venta_vto) AS comp_vto2  , " " AS marca,
       IF(ISNULL(tc.tcomp_cpo3)=1,"    ", tc.tcomp_numera) AS imprime, tiva_descripcion, mmot_descripcion , venta_total AS pagar
          FROM ventas c, tipos_comprobantes tc  , tipos_iva ti, motivos_movimientos mt 
            WHERE tc.tcomp_id = c.tcomp_id 
			AND ti.tiva_id=c.tiva_id 
			AND mt.mmot_id = c.mmot_id 
			AND mt.empre_id = wempre
			AND  c.cli_cuit = wcCuit 
			AND   c.empre_id = wempre
			AND ISNULL(venta_fbaja) = 1  
			AND ISNULL(mov_fecha) = 1;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_VENTAS_SIAP` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_VENTAS_SIAP`(wempre INT(4), wspPeriodo CHAR(6))
BEGIN
      SELECT REPLACE(v.venta_fechacpbte,"-" , "")AS FEC , 
             right(concat("000",tc.tcomp_afip),3) as tcomp_afip , 
             right(concat("00000",LEFT(v.venta_nrocpbte,4)), 5)as pto_vta , 
             RIGHT(CONCAT("00000000000000000000",substr(v.venta_nrocpbte,5)), 20)as  nro   ,
             RIGHT(CONCAT("00000000000000000000",SUBSTR(v.venta_nrocpbte,5)), 20)AS  nro_hasta   ,
             if(v.tcomp_id = 6 and LENGTH(CONVERT(v.cli_cuit, UNSIGNED)<  9 ), "96", "80")as  tdoc , 
             RIGHT(CONCAT("00000000000000000000",v.cli_cuit), 20) as nrodoc_cuit , 
             left(v.cli_nombre,20) as nom , 
             RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(v.venta_total, CHARACTER),".","")),15)as total , 
             RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(IF(v.tcomp_id in (5,8,16)and v.tiva_id = 6,  0,  v.venta_imp_No_gravado), CHARACTER),".","")),15)AS no_gravado ,
             "000000000000000" as perc_no_cat , 
              RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(IF(v.tcomp_id IN (5,8,16)AND v.tiva_id = 6,  0,v.venta_imp_oper_exentas_iva), CHARACTER),".","")),15)AS exentas , 
               "000000000000000" AS pago_a_cta , 
               RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(v.venta_imp_percep_iibb, CHARACTER),".","")),15)AS perc_iibb , 
               RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(v.venta_imp_percep_municipal, CHARACTER),".","")),15)AS perc_muni ,
                RIGHT(CONCAT("000000000000000",REPLACE(CONVERT(v.venta_imp_impuestos_internos, CHARACTER),".","")),15)AS imp_internos , 
                "PES" as moneda ,
                "0000000000"  as t_cambio ,
                "1"   as cnt_iva , 
                right( concat("000000000000000000000000", REPLACE(v.venta_fechacpbte,"-" , "")),24) as final 
	   FROM VENTAS v,  tipos_comprobantes tc 
	        WHERE tc.tcomp_id = v.tcomp_id AND
			VENTA_PERIODO  = wspPeriodo  AND 
			v.empre_id = wempre  
			ORDER BY venta_nrocpbte ;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Ver_cobros` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Ver_cobros`(wempresa INT(4 ) , wmovid BIGINT (20))
BEGIN
	DECLARE widcomp BIGINT(20) ; 
	DECLARE wnro_recibo VARCHAR(13) ; 
	DROP TABLE IF EXISTS datos_cobros ;
       CREATE TEMPORARY TABLE  datos_cobros
	       ( tipo VARCHAR(6) , 
		 detalle VARCHAR(100) , 
		 importe_pagado DECIMAL(14,2) ,
		 importe_formas DECIMAL(14,2) ,
		 tmov_id BIGINT(20) , 
		 tid_compras BIGINT(20) , 
		 tordenp_nro VARCHAR(13))	; 
        SET wnro_recibo = (SELECT mov_nro_cpbte FROM movcaja WHERE mov_id = wmovid);
	
	-- CARGO COMPROBANTES DE VENTAS -- 
 	INSERT INTO datos_cobros 
 	     SELECT  "CPBTE",CONCAT(tcomp_abrev ,":",c.venta_nrocpbte   ), 
 	             IF(t.tcomp_signo = -1,0, p.parc_importe_pago) ,
 	             IF(t.tcomp_signo = -1, p.parc_importe_pago,0), 
 	             p.mov_id , p.id_venta , wnro_recibo
              FROM parciales_comprobantes p, ventas c , tipos_comprobantes t 
              WHERE c.id_venta= p.id_venta AND 
                   t.tcomp_id = c.tcomp_id AND   p.mov_id = wmovid ;
             -- CONCAT( t.tcomp_abrev ," :",  c.venta_nrocpbte  )
 --       ==============================================================================================================
        -- CARGO RETENCIONES  -- 
	INSERT INTO datos_cobros 
                SELECT "RETEN" , CONCAT("Cert.:", reten_certificado, "/Ali.: ", 
                     reten_alicuota , "%/ Imponible: $", reten_imp_areten, " ", 
                     (SELECT CONCAT("[" , t.tcomp_abrev , ":", c.venta_nrocpbte , "]" )  
			FROM  VENTAS c , tipos_comprobantes t WHERE t.tcomp_id = c.tcomp_id AND c.id_venta = r.id_venta )) AS DET ,
                   0,  reten_retenido , mov_id , r.id_venta , wnro_recibo 
	       FROM retenciones r WHERE  mov_id = wmovid ;
        -- ==============================================================================================================
        -- TRANSFERENCIAS 
        INSERT INTO datos_cobros 
	SELECT  "TRANSF" ,  CONCAT("cta: ", CONCAT(b.bco_descripcion,"-",  c.cta_sucursal,"-", c.cta_nombres,"-", c.cta_numero)  )  , 0,
	       trans_importe , mov_id , 0 , wnro_recibo
		FROM transferencias T , CAJA_CUENTAS C, BANCOS_SUCURSALES B 
		     WHERE C.CUENTA_ID = T.CUENTA_ID AND 
		               b.bco_id = c.bco_id AND
		                mov_id = wmovid  ;
        -- ==============================================================================================================
	-- NOTAS DE DEBITOS 
	INSERT INTO datos_cobros 	 
	SELECT  "NOTAD" ,  CONCAT("ND: ", notadc_numero , (SELECT CONCAT("[" , t.tcomp_abrev , ":", c.venta_nrocpbte , "]" )  
             FROM  ventas c , tipos_comprobantes t WHERE t.tcomp_id = c.tcomp_id AND  c.id_venta =  n.id_ventas  ) )  , 0, 
		notadc_importe , mov_id , n.id_ventas , wnro_recibo
         FROM notas_deb_creditos n WHERE  mov_id = wmovid ;
         INSERT INTO datos_cobros 
         SELECT "EFVO" , "Efectivo ........" , 0,  mov_imp_pesos, mov_id , 0 , wnro_recibo
                  FROM movcaja 
			WHERE mov_id =   wmovid ;     
        -- ==============================================================================================================
        -- CARGA CHEQUES DE TERCEROS
        INSERT INTO datos_cobros 
         SELECT "CHQT" ,  CONCAT("BCO. ", chqt_cta_nom,"/ Cta.Emisora: ", 
                chqt_cta_nro,  "Nro Chq: ", CH.`CHQT_NRO` , " Fecha pago: " ,  CH.`chqt_fvto` ) AS det , 
			   0, CH.`chqt_importe` , MOV_ID , 0 ,  wnro_recibo
	    FROM mov_cheques_terceros ch 
			WHERE ch.EMPRE_ID = wempresa   AND mov_id = wmovid; 
        -- ==============================================================================================================
      -- caja_compensaciones
        INSERT INTO datos_cobros 
	SELECT "COMPEN" , "COMPENSACIONES ....." , 0, COMPEN_IMPORTE , MOV_ID , 0 , wnro_recibo
		     FROM caja_compensaciones WHERE MOV_ID = wmovid ;
		     
        SELECT * FROM datos_cobros ; 		     
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Ver_cobroS_det` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Ver_cobroS_det`(wempresa INT(4 ) , wmovid BIGINT (20))
BEGIN
	DECLARE widcomp BIGINT(20) ; 
	DECLARE wnro_recibo VARCHAR(13) ; 
	DECLARE wnombre VARCHAR (150); 
	DROP TABLE IF EXISTS datos_cobros ;
       CREATE TEMPORARY TABLE  datos_cobros
						       ( tipo VARCHAR(6) , 
							 detalle VARCHAR(150) , 
							 importe_pagado DECIMAL(14,2) ,
							 importe_formas DECIMAL(14,2) ,
							 tmov_id BIGINT(20) , 
							 tid_compras BIGINT(20) , 
							 tordenp_nro VARCHAR(13))	; 
        SET wnro_recibo = (SELECT mov_nro_cpbte FROM movcaja WHERE mov_id = wmovid);
        SET  wnombre = (SELECT CONCAT(m.mov_fecha,"--", p.prov_razsocial, " - Cuit ", m.`cuit`)AS deta 
                FROM movcaja m , proveedores p WHERE m.`cuit` = p.`cuit` AND m.mov_id  = wmovid  LIMIT 1 );
	INSERT INTO datos_cobros (tipo ,  detalle , importe_pagado  , importe_formas  , tmov_id  , tid_compras  ,  tordenp_nro)
	          VALUES ("CUIT" , wnombre, 0,0,0,0," ");
	-- CARGO COMPROBANTES DE VENTAS -- 
 	INSERT INTO datos_cobros 
 	     SELECT  "CPBTE",CONCAT(tcomp_abrev ,":",c.venta_nrocpbte   ), 
 	             IF(t.tcomp_signo = -1,0, p.parc_importe_pago) ,
 	             IF(t.tcomp_signo = -1, p.parc_importe_pago,0), 
 	             p.mov_id , p.id_venta , wnro_recibo
              FROM parciales_comprobantes p, ventas c , tipos_comprobantes t 
              WHERE c.id_venta= p.id_venta AND 
                   t.tcomp_id = c.tcomp_id AND   p.mov_id = wmovid ;
             -- CONCAT( t.tcomp_abrev ," :",  c.venta_nrocpbte  )
 --       ==============================================================================================================
        -- CARGO RETENCIONES  -- 
	INSERT INTO datos_cobros 
                SELECT "RETEN" , CONCAT("Cert.:", reten_certificado, "/Ali.: ", 
                     reten_alicuota , "%/ Imponible: $", reten_imp_areten, " ", 
                     (SELECT CONCAT("[" , t.tcomp_abrev , ":", c.venta_nrocpbte , "]" )  
			FROM  VENTAS c , tipos_comprobantes t WHERE t.tcomp_id = c.tcomp_id AND c.id_venta = r.id_venta )) AS DET ,
                   0,  reten_retenido , mov_id , r.id_venta , wnro_recibo 
	       FROM retenciones r WHERE  mov_id = wmovid ;
        -- ==============================================================================================================
        -- TRANSFERENCIAS 
        INSERT INTO datos_cobros 
	SELECT  "TRANSF" ,  CONCAT("cta: ", CONCAT(b.bco_descripcion,"-",  c.cta_sucursal,"-", c.cta_nombres,"-", c.cta_numero)  )  , 0,
	       trans_importe , mov_id , 0 , wnro_recibo
		FROM transferencias T , CAJA_CUENTAS C, BANCOS_SUCURSALES B 
		     WHERE C.CUENTA_ID = T.CUENTA_ID AND 
		               b.bco_id = c.bco_id AND
		                mov_id = wmovid  ;
        -- ==============================================================================================================
	-- NOTAS DE DEBITOS 
	INSERT INTO datos_cobros 	 
	SELECT  "NOTAD" ,  CONCAT("ND: ", notadc_numero , (SELECT CONCAT("[" , t.tcomp_abrev , ":", c.venta_nrocpbte , "]" )  
             FROM  ventas c , tipos_comprobantes t WHERE t.tcomp_id = c.tcomp_id AND  c.id_venta =  n.id_ventas  ) )  , 0, 
		notadc_importe , mov_id , n.id_ventas , wnro_recibo
         FROM notas_deb_creditos n WHERE  mov_id = wmovid ;
         INSERT INTO datos_cobros 
         SELECT "EFVO" , "Efectivo ........" , 0,  mov_imp_pesos, mov_id , 0 , wnro_recibo
                  FROM movcaja 
			WHERE mov_id =   wmovid ;     
        -- ==============================================================================================================
        -- CARGA CHEQUES DE TERCEROS
        INSERT INTO datos_cobros 
         SELECT "CHQT" ,  CONCAT( b.bco_descripcion, " || ",  chqt_cta_nom," ||Cta: ", 
                chqt_cta_nro,  " ||Nro: ", CH.`CHQT_NRO` , " | Pago: " ,  CH.`chqt_fvto` ) AS det , 
			   0, CH.`chqt_importe` , MOV_ID , 0 ,  wnro_recibo
	    FROM mov_cheques_terceros ch , bancos_sucursales b 
			WHERE  b.bco_id = ch.bco_id AND ch.EMPRE_ID = wempresa   AND mov_id = wmovid; 
        -- ==============================================================================================================
      -- caja_compensaciones
        INSERT INTO datos_cobros 
	SELECT "COMPEN" , "COMPENSACIONES ....." , 0, COMPEN_IMPORTE , MOV_ID , 0 , wnro_recibo
		     FROM caja_compensaciones WHERE MOV_ID = wmovid ;
		     
        SELECT * FROM datos_cobros ; 		     
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ver_DebitosCreditos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_ver_DebitosCreditos`(wempre INT(2), wcuit VARCHAR(11), wtipo VARCHAR(1) )
BEGIN
SET wcuit = TRIM(wcuit) ; 
SELECT CLI_CUIT, CONCAT(v.tcomp_id ," ", tcomp_descripcion , " Nro.: ", venta_nrocpbte ) AS cpbte ,  
       venta_fechacpbte,id_venta , v.`venta_total`, 
       funControl_Saldos_comprobantes(0,id_venta ) AS saldo , " " AS marca 
	FROM VENTAS v , tipos_comprobantes t  
	    WHERE t.tcomp_id = v.tcomp_id AND
	    funControl_Saldos_comprobantes(0,id_venta ) > 0 AND 
	    IF( wtipo = "C" , (v.tcomp_id IN (7,15,16)) , (v.tcomp_id IN (8,17,18))) AND 
	    v.empre_id = wempre AND 
	    cli_cuit = wcuit  
	    ORDER BY cli_cuit; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Ver_Pagos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Ver_Pagos`(wempresa INT(4 ) , wmovid BIGINT (20) )
BEGIN
	DECLARE widcomp BIGINT(20) ; 
	DECLARE wnro_op VARCHAR(10) ; 
	
	DROP TABLE IF EXISTS datos_pago ;
       CREATE TEMPORARY TABLE  datos_pago
	       ( tipo VARCHAR(6) , 
		 detalle VARCHAR(150) , 
		 importe_pagado DECIMAL(14,2) ,
		 importe_formas DECIMAL(14,2) ,
		 tmov_id BIGINT(20) , 
		 tid_compras BIGINT(20) , 
		 tordenp_nro VARCHAR(13), RET_ID BIGINT(20))	; 
	
	SET wnro_op = (SELECT ordenp_nro FROM ordenes_pago  WHERE MOV_ID = wmovid LIMIT 1 );
 
	
	-- CARGO COMPROBANTES DE COMPRAS -- 
	INSERT INTO datos_pago 
	     SELECT  "CPBTE",  CONCAT("Exp.:", c.comp_expediente,"/" , t.tcomp_abrev , " :", c.comp_nrocpbte  )  AS DET  , 
                  parc_importe_pago , 0, p.mov_id , p.id_compras , wnro_op, 0 AS ret_id 
             FROM parciales_comprobantes p, compras c , tipos_comprobantes t 
             WHERE c.id_compras = p.id_compras AND t.tcomp_id = c.tcomp_id AND p.mov_id = wmovid ;
        -- ==============================================================================================================
        -- CARGO RETENCIONES  -- 
	INSERT INTO datos_pago 
                SELECT "RETEN" , CONCAT(TRIM( tc.tcomp_abrev), ".:" , reten_certificado, "/Ali.: ", reten_alicuota , "%/ ", 
                     (SELECT CONCAT("[" , t.tcomp_abrev , ":", c.comp_nrocpbte , "]" ) FROM  compras c , tipos_comprobantes t 
                      WHERE t.tcomp_id = c.tcomp_id AND c.id_compras = r.id_compras )) AS DET ,
                   0,  reten_retenido , mov_id , r.id_compras , wnro_op ,  r.retencion_id  AS ret_id 
	       FROM retenciones r , tipos_comprobantes tc 
	            WHERE r.tcomp_id = tc.tcomp_id AND r.mov_id = wmovid ;
        -- ==============================================================================================================
        -- TRANSFERENCIAS 
        INSERT INTO datos_pago 
	SELECT  "TRANSF" ,  CONCAT("CBU: ", trans_cuenta_destino,"[" , trans_titular , "]"  )  , 0,
	       trans_importe , mov_id , 0 , wnro_op ,  0 AS ret_id 
		FROM transferencias WHERE mov_id = wmovid  ;
	INSERT INTO datos_pago 	 
	SELECT  "NOTAD" ,  CONCAT("ND: ", notadc_numero , (SELECT CONCAT("[" , t.tcomp_abrev , ":", c.comp_nrocpbte , "]" )  
             FROM  compras c , tipos_comprobantes t WHERE t.tcomp_id = c.tcomp_id AND c.id_compras = n.id_compras ) )  , 0, 
		notadc_importe , mov_id , n.id_compras , wnro_op ,  0 AS ret_id 
         FROM notas_deb_creditos n WHERE  mov_id = wmovid ;
         INSERT INTO datos_pago 
         SELECT "EFVO" , "Efectivo ........" , 0,  mov_imp_pesos, mov_id , 0 , wnro_op ,  0 AS ret_id 
                  FROM movcaja 
			WHERE mov_id =   wmovid ;     
        INSERT INTO datos_pago 
         SELECT "CHQP" ,  CONCAT(BCO_DESCRIPCION,"-Suc.: ",TRIM(cta_sucursal),"- Cta.:",
			  TRIM(CTA_NUMERO) , " Nro:" , CH.`STK_CHQ_NRO` ," $" ," Pago: " ,  CH.`stk_chq_fvto` ) AS det , 
			   0, CH.`stk_chq_importe` , MOV_ID , 0 ,  wnro_op,  0 AS ret_id 
		FROM caja_cheques ch,  CAJA_CUENTAS C , bancos_sucursales B 
			WHERE c.`cuenta_id` = ch.`cuenta_id` AND 
				B.BCO_Id = C.`bco_id` AND  
			ch.CUENTA_ID = 1 AND ch.EMPRE_ID = wempresa   AND mov_id = wmovid;
        INSERT INTO datos_pago 
         SELECT "CHQT" ,  CONCAT(b.BCO_DESCRIPCION,"- Cta.:", TRIM(chqt_CTA_NRO) ,
			  " CHQ:" , cht.`CHQT_NRO` ," $" ," Fpago: " ,  CHt.`chqt_fvto` ) AS det , 
			   0, cht.`chqt_importe` , id_egreso , 0 ,  wnro_op ,  0 AS ret_id 
		FROM MOV_cheques_terceros cht,   bancos_sucursales B 
			WHERE B.BCO_Id = cht.`bco_id` AND   id_egreso = wmovid;
						
        INSERT INTO datos_pago 
	SELECT "COMPEN" , "COMPENSACIONES ....." , 0, COMPEN_IMPORTE , MOV_ID , 0 , wnro_op ,  0 AS ret_id 
		     FROM caja_compensaciones WHERE MOV_ID = wmovid ;
		     
        SELECT * FROM datos_pago ; 		     
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `test_sp_fill_audit_fast` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `test_sp_fill_audit_fast`()
    COMMENT 'TEST ONLY: genera datos masivos en audit_log (duplicacion exponencial) para pruebas de rendimiento'
BEGIN
  DECLARE i INT DEFAULT 0;
  
  WHILE i < 1000 DO
    INSERT INTO audit_log (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion)
    VALUES (
      ELT(1+FLOOR(RAND()*5),'tkt','usuario','departamento','motivo','rol'),
      FLOOR(1+RAND()*10000),
      ELT(1+FLOOR(RAND()*3),'INSERT','UPDATE','DELETE'),
      FLOOR(1+RAND()*18),
      CONCAT('User_',FLOOR(1+RAND()*18)),
      '{"campo":"old"}', '{"campo":"new"}',
      DATE_SUB(NOW(),INTERVAL FLOOR(RAND()*730) DAY),
      CONCAT('Op#',i)
    );
    SET i = i + 1;
  END WHILE;
  
  SET i = 0;
  WHILE i < 10 DO
    INSERT INTO audit_log (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion)
    SELECT tabla, FLOOR(1+RAND()*10000), accion, FLOOR(1+RAND()*18), 
           CONCAT('User_',FLOOR(1+RAND()*18)), valores_antiguos, valores_nuevos,
           DATE_SUB(NOW(),INTERVAL FLOOR(RAND()*730) DAY),
           CONCAT('Doubled#',i)
    FROM audit_log LIMIT 1000000;
    SET i = i + 1;
    SELECT CONCAT('Doubling pass ',i,' - rows: ',(SELECT COUNT(*) FROM audit_log)) as progress;
  END WHILE;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `test_sp_fill_audit_log` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `test_sp_fill_audit_log`()
    COMMENT 'TEST ONLY: genera 1M de registros en audit_log fila por fila para pruebas de rendimiento'
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE batch_size INT DEFAULT 1000;
  DECLARE total INT DEFAULT 1000000;
  
  WHILE i < total DO
    INSERT INTO audit_log (tabla, id_registro, accion, usuario_id, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion)
    VALUES (
      ELT(1 + FLOOR(RAND() * 5), 'tkt', 'usuario', 'departamento', 'motivo', 'rol'),
      FLOOR(1 + RAND() * 10000),
      ELT(1 + FLOOR(RAND() * 3), 'INSERT', 'UPDATE', 'DELETE'),
      FLOOR(1 + RAND() * 18),
      CONCAT('User_', FLOOR(1 + RAND() * 18)),
      '{"campo":"valor_viejo"}',
      '{"campo":"valor_nuevo"}',
      DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 730) DAY) + INTERVAL FLOOR(RAND() * 86400) SECOND,
      CONCAT('Operacion de prueba #', i)
    );
    SET i = i + 1;
    
    IF i MOD 10000 = 0 THEN
      SELECT CONCAT('Inserted ', i, ' rows') as progress;
    END IF;
  END WHILE;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Update_chequesT_varios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `Update_chequesT_varios`( wfecha date , wcampo varchar(30),wlista varchar (500))
BEGIN
       SET @wxx := CONCAT("UPDATE mov_cheques_terceros SET ",wcampo," = '" , wfecha , "'  WHERE chqt_id IN (",wlista,")"); 
       PREPARE stmt FROM @wxx ; 
       EXECUTE stmt ; 
       DEALLOCATE PREPARE stmt;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `validar_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `validar_usuario`(w_Usuario varchar(10), w_Password varchar(15))
BEGIN
	declare existeUsuario int default 0;
	declare contraseniaOk int default 0;
	declare estaActivo int default 0;
	declare seguir int default 0;
	declare mensaje text default "0";
		
	start transaction;
	
	-- Verificar si existe usuario
	set existeUsuario = (select count(*) from usuarios where usu_logon_md5 = md5(w_Usuario));
	if existeUsuario = 0 then
		set seguir = 1;
		set mensaje = "El usuario no existe.";
	end if;
	
	-- Verificar si la contraseña es correcta
	if seguir = 0 then
		SET contraseniaOk = (SELECT COUNT(*) FROM usuarios WHERE usu_logon_md5 = md5(w_Usuario) and usu_contra_md5 = md5(w_Password));
		if contraseniaOk = 0 then
			set seguir = 1;
			set mensaje = "La contraseña es incorrecta.";
		end if;
	end if;
	
	-- Verificar que el usuario este activo
	if seguir = 0 then
		set estaActivo = (select count(*) from usuarios WHERE usu_logon_md5 = MD5(w_Usuario) AND usu_contra_md5 = MD5(w_Password) and isnull(usu_fecha_b));
		if estaActivo = 0 then
			set seguir = 1;
			set mensaje = "El usuario esta dado de baja.";
		end if;
	end if;
	
	-- Traer usuario
	if seguir = 0 then
		select "success" as mensaje, u.* from usuarios u WHERE usu_logon_md5 = MD5(w_Usuario) AND usu_contra_md5 = MD5(w_Password);
	else
		select mensaje;
	end if;
	
	commit;
	
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

-- Dump completed on 2026-07-02 11:48:48
