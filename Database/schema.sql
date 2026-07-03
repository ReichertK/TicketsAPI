-- =====================================================
-- Tickets API - Database Schema (solo tablas)
-- MySQL 5.5+ compatible
-- Generado desde la base real cdk_tkt_dev el 2026-07-02
-- Ejecutar este archivo PRIMERO; luego routines.sql, triggers.sql y seed.sql
-- RBAC unificado en tablas: rol / permiso / rol_permiso / usuario_rol
-- (se eliminaron las tablas duplicadas tkt_rol / tkt_permiso / tkt_rol_permiso / tkt_usuario_rol)
-- =====================================================

CREATE DATABASE IF NOT EXISTS `tickets_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `tickets_db`;

SET FOREIGN_KEY_CHECKS = 0;
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
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
DROP TABLE IF EXISTS `grupo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grupo` (
  `Id_Grupo` int(11) NOT NULL AUTO_INCREMENT,
  `Tipo_Grupo` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Id_Grupo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
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
DROP TABLE IF EXISTS `permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permiso` (
  `idPermiso` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`idPermiso`),
  UNIQUE KEY `uq_permiso_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
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

SET FOREIGN_KEY_CHECKS = 1;

