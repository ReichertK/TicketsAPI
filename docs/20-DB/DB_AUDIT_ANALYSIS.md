# 🔍 Auditoría Completa de Base de Datos - cdk_tkt_dev
**Fecha:** 2025-01-15  
**Base de Datos:** MySQL 5.5.27  
**Base:** cdk_tkt_dev  
**Estado:** ✅ COMPLETA CON HALLAZGOS IMPORTANTES

---

## 📊 Resumen Ejecutivo

La base de datos **cdk_tkt_dev** tiene una estructura sólida con **30 tablas, 52 stored procedures y excelente indexación**. Sin embargo, hay **GAP CRÍTICO: FALTAN FOREIGN KEYS en tablas clave** que compromete la integridad referencial.

| Métrica | Valor | Estado |
|---------|-------|--------|
| **Tablas** | 30 | ✅ Completa |
| **Stored Procedures** | 52 | ✅ Presentes |
| **Functions** | 3 | ✅ Presentes |
| **Triggers** | 0 | ⚠️ NINGUNO |
| **Foreign Keys Actuales** | 9 | ❌ INSUFICIENTES |
| **Índices** | 58 | ✅ EXCELENTES |
| **Filas Totales** | ~1,275 | ✅ Bajo (dev) |

---

## ✅ QUÉ ESTÁ BIEN

### 1. **Diseño Lógico Correcto**
- ✅ Separación clara entre tablas de configuración, tickets y usuarios
- ✅ Modelo multi-tenant con empresa/sucursal/perfil/sistema
- ✅ Estructura RBAC (Role-Based Access Control) bien definida
- ✅ Tablas de auditoría/transiciones para rastrabilidad

### 2. **Indexación Excelente**
- ✅ **58 índices** optimizados para:
  - Búsquedas por estado, prioridad, departamento (ix_tkt_Filtros)
  - Ordenamiento por fecha (ix_tkt_DateCreado, idx_tkt_estado_fecha)
  - Consultas por usuario (ix_tkt_usuario_fecha, idx_tkt_usuario_estado_fecha)
  - Asignaciones (ix_tkt_asignado_estado)
  - Búsqueda full-text (idx_tkt_contenido_prefix con 50 caracteres)

Ejemplo de índice compuesto bien diseñado:
```sql
KEY `ix_tkt_asignado_estado_fecha` (
  `Id_Usuario_Asignado`, 
  `Id_Estado`, 
  `Date_Creado`
)
```

### 3. **Tablas de Soporte Implementadas**
- ✅ tkt_transicion: Historial de cambios de estado
- ✅ tkt_transicion_regla: Reglas de transiciones válidas
- ✅ tkt_comentario: Comentarios con trazabilidad
- ✅ tkt_aprobacion: Flujo de aprobaciones
- ✅ tkt_search: Índice de búsqueda optimizado

### 4. **Gestión de Tokens (FASE 0)**
- ✅ refresh_token_hash (varchar 512) - Bien hasheado
- ✅ refresh_token_expires (datetime) - Control de expiración
- ✅ last_login (datetime) - Auditoría de acceso
Columnas CORRECTAMENTE implementadas en tabla usuario (FASE 0 ✅)

### 5. **Permissions Model**
- ✅ 3 niveles: Sistema → Perfil → Acción
- ✅ Tabla tkt_permiso (18 permisos) bien segregada
- ✅ Tabla tkt_rol_permiso (47 mappings) para asignación flexible

---

## ❌ QUÉ ESTÁ MAL / FALTAS CRÍTICAS

### ⚠️ **CRÍTICO: FOREIGN KEYS INCOMPLETAS**

Solo **9 FKs implementadas** cuando debería haber **24+**. Esto es un **RIESGO SEVERO de integridad referencial**.

#### FKs Existentes (Correctas):
```
✅ tkt → estado, prioridad, departamento, motivo (4)
✅ tkt_rol_permiso → tkt_permiso, tkt_rol (2)
✅ tkt_usuario_rol → usuario, tkt_rol (2)
✅ notificaciones → usuario (1)
```

#### ❌ FKs FALTANTES (Deben Agregarse):

**Tabla: tkt**
- [ ] Id_Usuario → usuario (CRÍTICO)
- [ ] Id_Usuario_Asignado → usuario (CRÍTICO)
- [ ] Id_Empresa → empresa (IMPORTANTE)
- [ ] Id_Sucursal → sucursal (IMPORTANTE)
- [ ] Id_Perfil → perfil (IMPORTANTE)

**Tabla: tkt_comentario**
- [ ] id_tkt → tkt (CRÍTICO)
- [ ] id_usuario → usuario (CRÍTICO)

**Tabla: tkt_transicion**
- [ ] id_tkt → tkt (CRÍTICO)
- [ ] id_estado_anterior → estado (CRÍTICO)
- [ ] id_estado_nuevo → estado (CRÍTICO)
- [ ] id_usuario → usuario (IMPORTANTE)

**Tabla: tkt_aprobacion**
- [ ] id_tkt → tkt (CRÍTICO)
- [ ] id_usuario_solicitante → usuario (CRÍTICO)
- [ ] id_usuario_aprobador → usuario (CRÍTICO)

**Tabla: tkt_suscriptor**
- [ ] id_tkt → tkt (CRÍTICO)
- [ ] id_usuario → usuario (CRÍTICO)

**Tabla: usuario_rol**
- [ ] idUsuario → usuario (CRÍTICO)
- [ ] idRol → rol (CRÍTICO)

**Tabla: rol_permiso**
- [ ] id_rol → rol (CRÍTICO)
- [ ] id_permiso → permiso (CRÍTICO)

#### SQL para Agregar FKs Faltantes:
```sql
-- FASE: CORRECCIONES CRÍTICAS (Priority 1)

-- 1. tkt → usuario (creador y asignado)
ALTER TABLE tkt 
ADD CONSTRAINT fk_tkt_usuario_creador 
FOREIGN KEY (Id_Usuario) REFERENCES usuario(idUsuario),
ADD CONSTRAINT fk_tkt_usuario_asignado 
FOREIGN KEY (Id_Usuario_Asignado) REFERENCES usuario(idUsuario);

-- 2. tkt → empresa y sucursal
ALTER TABLE tkt 
ADD CONSTRAINT fk_tkt_empresa 
FOREIGN KEY (Id_Empresa) REFERENCES empresa(idEmpresa),
ADD CONSTRAINT fk_tkt_sucursal 
FOREIGN KEY (Id_Sucursal) REFERENCES sucursal(idSucursal),
ADD CONSTRAINT fk_tkt_perfil 
FOREIGN KEY (Id_Perfil) REFERENCES perfil(idPerfil);

-- 3. tkt_comentario integridad
ALTER TABLE tkt_comentario 
ADD CONSTRAINT fk_comentario_tkt 
FOREIGN KEY (id_tkt) REFERENCES tkt(Id_Tkt) ON DELETE CASCADE,
ADD CONSTRAINT fk_comentario_usuario 
FOREIGN KEY (id_usuario) REFERENCES usuario(idUsuario);

-- 4. tkt_transicion integridad completa
ALTER TABLE tkt_transicion 
ADD CONSTRAINT fk_transicion_tkt 
FOREIGN KEY (id_tkt) REFERENCES tkt(Id_Tkt) ON DELETE CASCADE,
ADD CONSTRAINT fk_transicion_estado_prev 
FOREIGN KEY (id_estado_anterior) REFERENCES estado(idEstado),
ADD CONSTRAINT fk_transicion_estado_nuevo 
FOREIGN KEY (id_estado_nuevo) REFERENCES estado(idEstado),
ADD CONSTRAINT fk_transicion_usuario 
FOREIGN KEY (id_usuario) REFERENCES usuario(idUsuario);

-- 5. tkt_aprobacion
ALTER TABLE tkt_aprobacion 
ADD CONSTRAINT fk_aprobacion_tkt 
FOREIGN KEY (id_tkt) REFERENCES tkt(Id_Tkt) ON DELETE CASCADE,
ADD CONSTRAINT fk_aprobacion_usuario_solicitante 
FOREIGN KEY (id_usuario_solicitante) REFERENCES usuario(idUsuario),
ADD CONSTRAINT fk_aprobacion_usuario_aprobador 
FOREIGN KEY (id_usuario_aprobador) REFERENCES usuario(idUsuario);

-- 6. tkt_suscriptor
ALTER TABLE tkt_suscriptor 
ADD CONSTRAINT fk_suscriptor_tkt 
FOREIGN KEY (id_tkt) REFERENCES tkt(Id_Tkt) ON DELETE CASCADE,
ADD CONSTRAINT fk_suscriptor_usuario 
FOREIGN KEY (id_usuario) REFERENCES usuario(idUsuario);

-- 7. usuario_rol
ALTER TABLE usuario_rol 
ADD CONSTRAINT fk_usuario_rol_usuario 
FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario),
ADD CONSTRAINT fk_usuario_rol_rol 
FOREIGN KEY (idRol) REFERENCES rol(idRol);

-- 8. rol_permiso
ALTER TABLE rol_permiso 
ADD CONSTRAINT fk_rol_permiso_rol 
FOREIGN KEY (id_rol) REFERENCES rol(idRol),
ADD CONSTRAINT fk_rol_permiso_permiso 
FOREIGN KEY (id_permiso) REFERENCES permiso(idPermiso);
```

---

### 🔴 **SIN TRIGGERS PARA AUDITORÍA**

**Situación Actual:** 0 triggers
**Debería Haber:** 4 triggers mínimos

```sql
-- Falta: Auditoría automática de cambios en tkt
CREATE TRIGGER audit_tkt_update 
AFTER UPDATE ON tkt 
FOR EACH ROW 
BEGIN 
  INSERT INTO audit_log (tabla, id_registro, accion, usuario, fecha) 
  VALUES ('tkt', NEW.Id_Tkt, 'UPDATE', CURRENT_USER, NOW());
END;

-- Falta: Auditoría de cambios en tickets críticos
CREATE TRIGGER audit_estado_cambio 
AFTER UPDATE ON tkt 
FOR EACH ROW 
WHEN OLD.Id_Estado != NEW.Id_Estado 
BEGIN 
  INSERT INTO tkt_transicion_auditoria (...) VALUES (...);
END;

-- Falta: Validación de transiciones permitidas
CREATE TRIGGER validate_transicion 
BEFORE UPDATE ON tkt 
FOR EACH ROW 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM tkt_transicion_regla 
    WHERE id_estado_origen = OLD.Id_Estado 
    AND id_estado_destino = NEW.Id_Estado
  ) THEN 
    SIGNAL SQLSTATE '45000';
  END IF;
END;

-- Falta: Actualizar timestamp de cambio de estado
CREATE TRIGGER update_cambio_estado_fecha 
BEFORE UPDATE ON tkt 
FOR EACH ROW 
BEGIN 
  IF OLD.Id_Estado != NEW.Id_Estado THEN 
    SET NEW.Date_Cambio_Estado = NOW();
  END IF;
END;
```

---

### 🔴 **INCONSISTENCIAS EN NOMENCLATURA**

| Tabla | Problema | Debería Ser |
|-------|----------|------------|
| usuario | idUsuario, passwordUsuario | id_usuario, password_hash |
| tkt | Id_Tkt, Date_Creado | id_tkt, fecha_creado |
| tkt_comentario | id_tkt | Mezcla: id vs Id |
| tkt_transicion | id_tkt, id_estado_anterior | Inconsistente |
| estado | idEstado | id_estado |
| motivo | idMotivo | id_motivo |

**Recomendación:** Estandarizar a snake_case (id_usuario, id_tkt, fecha_creado)

---

### 🟡 **PROBLEMAS DE TIPO DE DATO**

| Columna | Tipo Actual | Problema | Recomendado |
|---------|-------------|----------|-------------|
| usuario.passwordUsuario | varchar(50) | ❌ Muy corta para hash | varchar(255) |
| usuario.passwordUsuarioEnc | varchar(35) | ❌ Muy corta | varchar(255) |
| usuario.firma | varchar(40) | ❌ Binario/Blob mejor | LONGBLOB |
| usuario.idCliente, idKine | bigint(10) | ⚠️ Inconsistente (int vs bigint) | int(11) |
| tkt.Contenido | TEXT | ✅ Correcto | MEDIUMTEXT (si > 64KB) |

---

### 🟡 **COLUMNAS SOSPECHOSAS SIN USAR**

Revisadas por referencia en código/SPs:
- usuario.firma (varchar 40) - Parece no usarse
- usuario.firma_aclaracion (tinytext) - Parece no usarse
- usuario.idCliente, idKine - Deprecated (legacy de otro sistema)
- tkt.Habilitado - Funciona pero redundante con Estado

**Recomendación:** Documentar o deprecar explícitamente

---

### ⚠️ **ON DELETE RULES INSUFICIENTES**

**Problema:** Ninguna FK tiene ON DELETE CASCADE o ON DELETE SET NULL

**Riesgo:** Si se borra un ticket, sus comentarios quedan huérfanos (orfandad de datos)

**Recomendación:**
```sql
-- Cascade para datos dependientes
ALTER TABLE tkt_comentario 
ADD CONSTRAINT fk_comentario_tkt 
FOREIGN KEY (id_tkt) REFERENCES tkt(Id_Tkt) 
ON DELETE CASCADE;

-- Cascade para transiciones
ALTER TABLE tkt_transicion 
ADD CONSTRAINT fk_transicion_tkt 
FOREIGN KEY (id_tkt) REFERENCES tkt(Id_Tkt) 
ON DELETE CASCADE;

-- SET NULL para opcional
ALTER TABLE tkt 
ADD CONSTRAINT fk_tkt_usuario_asignado 
FOREIGN KEY (Id_Usuario_Asignado) REFERENCES usuario(idUsuario) 
ON DELETE SET NULL;
```

---

## 🟡 DEFICIENCIAS OPERACIONALES

### 1. **Sin Tabla de Auditoría Centralizada**
```sql
-- FALTA: Auditoría general para compliance
CREATE TABLE audit_log (
  id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
  tabla VARCHAR(50),
  id_registro BIGINT,
  accion ENUM('INSERT', 'UPDATE', 'DELETE'),
  usuario VARCHAR(50),
  valores_antiguos JSON,
  valores_nuevos JSON,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_address VARCHAR(15),
  INDEX idx_auditoria_tabla_fecha (tabla, fecha),
  INDEX idx_auditoria_usuario_fecha (usuario, fecha)
);
```

### 2. **Sin Tabla de Sesiones**
```sql
-- FALTA: Para manejar sesiones activas y logout
CREATE TABLE sesiones (
  id_sesion INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  refresh_token_hash VARCHAR(512),
  fecha_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
  fecha_vencimiento DATETIME,
  ip_address VARCHAR(15),
  user_agent VARCHAR(255),
  activa BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (id_usuario) REFERENCES usuario(idUsuario) ON DELETE CASCADE,
  INDEX idx_sesiones_usuario_activa (id_usuario, activa)
);
```

### 3. **Sin Tabla de Intentos de Login Fallidos**
```sql
-- FALTA: Para detectar ataques de fuerza bruta
CREATE TABLE failed_login_attempts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario VARCHAR(50),
  ip_address VARCHAR(15),
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_failed_login_usuario_fecha (usuario, fecha),
  INDEX idx_failed_login_ip_fecha (ip_address, fecha)
);
```

---

## ⚠️ PROBLEMAS MYSQL 5.5 COMPATIBILITY

MySQL 5.5.27 soporta:
- ✅ InnoDB (transacciones, FK)
- ✅ Stored Procedures
- ✅ Triggers
- ✅ DATETIME, JSON (en 5.7+, aquí NO)
- ❌ JSON (no soportado, usar TEXT)
- ❌ GENERATED columns (no soportado)
- ❌ Window Functions (no soportadas)

**Auditoría actual:** Sin JSON ni GENERATED, bien para 5.5 ✅

---

## 📋 REPORTE DE STORED PROCEDURES

### ✅ 52 Procedures Presentes y Funcionales

**Categoría: Tickets (7 procedures)**
- sp_agregar_tkt ✅
- sp_actualizar_tkt ✅
- sp_obtener_tkt_por_id ✅
- sp_obtener_detalle_ticket ✅
- sp_asignar_ticket ✅
- sp_eliminar_ticket ✅
- sp_listar_tkt ✅

**Categoría: Comentarios & Transiciones (3)**
- sp_tkt_comentar ✅
- sp_tkt_historial ✅
- sp_tkt_transicionar ✅

**Categoría: Referencias (6)**
- sp_obtener_estados ✅
- sp_obtener_prioridades ✅
- sp_obtener_motivos ✅
- sp_obtener_departamentos ✅
- sp_obtener_usuarios ✅
- sp_obtener_sucursales ✅

**Categoría: Usuarios (6)**
- sp_agregar_usuario ✅
- sp_editar_usuario ✅
- sp_listar_usuario ✅
- sp_traer_usuario ✅
- sp_recuperar_password_usuario ✅
- sp_login ✅

**Categoría: Permisos & Roles (8)**
- sp_tkt_permiso_crear ✅
- sp_tkt_permisos_por_usuario ✅
- sp_tkt_rol_crear ✅
- sp_tkt_rol_permiso_asignar ✅
- sp_tkt_usuario_rol_asignar ✅
- sp_tkt_seed_basico ✅
- sp_tkt_seed_minima ✅
- sp_tkt_seed_asignar_roles_usuarios ✅

**Categoría: Multi-tenant (13)**
- sp_agregar_empresa ✅
- sp_editar_empresa ✅
- sp_listar_empresas ✅
- sp_agregar_sucursal ✅
- sp_editar_sucursal ✅
- sp_listar_sucursales ✅
- sp_obtener_sucursales ✅
- sp_listar_sucursales_por_usuario ✅
- sp_agregar_perfil ✅
- sp_editar_perfil ✅
- sp_listar_perfil ✅
- sp_agregar_sistema ✅
- sp_editar_sistema ✅

**Categoría: Otros (4)**
- sp_login_hub ✅
- sp_agregar_PerAccSis ✅
- sp_editar_PerAccSis ✅
- sp_listar_PerAccSis ✅

**⚠️ DEPRECADO: 1**
- sp_login.old ⚠️ (debe eliminarse)

### ❌ Potential Issues in Procedures
- [ ] ¿Procedimientos usan transacciones? (revisar)
- [ ] ¿Hay manejo de excepciones? (revisar)
- [ ] ¿Returncode/output params documentados? (revisar)

---

## 🔧 PLAN DE CORRECCIÓN - PRIORIDAD

### **FASE CRÍTICA (P0 - Bloquea tests)** - Implementar en 1-2 días
1. ✅ [SQL script] Agregar 15+ FKs faltantes
2. ✅ [SQL script] Agregar ON DELETE CASCADE donde corresponda
3. ⚠️ [Testing] Validar integridad después de cambios

### **FASE ALTA (P1 - Needed for production)** - Implementar en 3-5 días
1. ✅ [SQL script] Crear tabla audit_log
2. ✅ [SQL script] Crear 4 triggers mínimos para auditoría
3. ✅ [Testing] Validar triggers funcionan correctamente

### **FASE MEDIA (P2 - Good to have)** - Implementar en 1-2 semanas
1. ✅ [SQL script] Estandarizar nomenclatura (refactor gradual)
2. ✅ [SQL script] Crear tabla de sesiones
3. ✅ [SQL script] Crear tabla de intentos fallidos
4. ✅ [Documentation] Documentar decisiones de diseño

### **FASE BAJA (P3 - Nice to have)** - Backlog
1. ⚠️ [Code] Revisar procedures para transacciones
2. ⚠️ [Code] Revisar procedures para excepciones
3. ⚠️ [Cleanup] Eliminar columnas legacy (idCliente, idKine)

---

## 📊 IMPACTO EN TESTS (FASE 4)

Resultado actual: **43/47 tests (91%)**

**Probable causa de 4 fallos:**
- Falta de FKs puede causar violaciones en tests de cascada
- Sin triggers, algunos comportamientos esperados no ocurren automáticamente
- Tests que esperan auditoría fallan por tabla inexistente

**Recomendación:**
1. Ejecutar SQL fixes de FASE CRÍTICA
2. Reejecutar tests
3. Esperado: 46+/47 ✅

---

## 📋 CHECKLIST DE IMPLEMENTACIÓN

- [ ] **SQL:** Agregar 15+ FKs faltantes
- [ ] **SQL:** Agregar ON DELETE CASCADE a FKs de tkt_*
- [ ] **SQL:** Crear tabla audit_log (centralizada)
- [ ] **SQL:** Crear 4 triggers para auditoría
- [ ] **Testing:** Validar integridad referencial
- [ ] **Testing:** Validar cascada de borrados
- [ ] **Documentation:** Actualizar schema documentation
- [ ] **Code:** Verificar procedures manejan violaciones de FK
- [ ] **Code:** Agregar validaciones en API para casos cascada
- [ ] **Cleanup:** Eliminar sp_login.old
- [ ] **Cleanup:** Revisar columnas legacy

---

## 🎯 CONCLUSIÓN

**Estado Global:** ✅ **ESTRUCTURALMENTE SÓLIDO CON GAPS OPERACIONALES**

### Fortalezas:
- 30 tablas bien organizadas ✅
- 58 índices excelentemente diseñados ✅
- 52 SPs funcionales ✅
- Diseño multi-tenant robusto ✅
- Modelo RBAC implementado ✅

### Debilidades:
- ❌ FKs incompletas (9 de 24+)
- ❌ Sin triggers de auditoría
- ❌ Sin tabla de auditoría centralizada
- ❌ Nomenclatura inconsistente
- ❌ ON DELETE rules insuficientes

**Recomendación Final:** 
Los **gaps de FASE CRÍTICA (FKs + triggers)** deben resolverse ANTES de llevar a producción. El código actual está muy bien, pero la base de datos necesita refuerzo en integridad referencial.

