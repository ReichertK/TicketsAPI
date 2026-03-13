# Auditoría Completa de Stored Procedures
**Fecha:** 3 de Febrero de 2026
**Total SPs en BD:** 64

---

## 📊 Resumen Ejecutivo

| Categoría | Cantidad | % |
|-----------|----------|---|
| ✅ **En uso activo** | 16 | 25% |
| 🔄 **Candidatos para implementar** | 8 | 12.5% |
| 📦 **Respaldos (old_)** | 4 | 6.25% |
| 🔧 **Funcionalidad legacy/externa** | 23 | 36% |
| ⚠️ **Probablemente obsoletos** | 13 | 20% |

---

## ✅ CATEGORÍA 1: SPs EN USO ACTIVO (16)

### Tickets (7)
| SP | Ubicación en código | Estado |
|----|---------------------|--------|
| `sp_agregar_tkt` | TicketRepository.CreateAsync | ✅ Activo |
| `sp_actualizar_tkt` | TicketRepository.UpdateViaStoredProcedureAsync | ✅ Activo |
| `sp_eliminar_ticket` | TicketRepository.DeleteAsync | ✅ Activo |
| `sp_listar_tkts` | TicketRepository.GetFilteredAsync | ✅ Activo |
| `sp_tkt_transicionar` | TicketRepository.TransicionarEstadoViaStoredProcedureAsync | ✅ Activo |
| `sp_tkt_historial` | TicketRepository.GetHistorialViaStoredProcedureAsync | ✅ Activo |
| `sp_tkt_comentar` | ComentarioRepository.CrearComentarioViaStoredProcedureAsync | ✅ Activo |

### Departamentos (4)
| SP | Ubicación en código | Estado |
|----|---------------------|--------|
| `sp_listar_departamento` | DepartamentoRepository.GetAllAsync/GetByIdAsync | ✅ Activo |
| `sp_departamento_crear` | DepartamentoRepository.CreateAsync | ✅ Activo |
| `sp_departamento_actualizar` | DepartamentoRepository.UpdateAsync | ✅ Activo |
| `sp_departamento_eliminar` | DepartamentoRepository.DeleteAsync | ✅ Activo |

### Motivos (4)
| SP | Ubicación en código | Estado |
|----|---------------------|--------|
| `sp_obtener_motivos` | MotivoRepository.GetAllAsync | ✅ Activo |
| `sp_motivo_crear` | MotivoRepository.CreateAsync | ✅ Activo |
| `sp_motivo_actualizar` | MotivoRepository.UpdateAsync | ✅ Activo |
| `sp_motivo_eliminar` | MotivoRepository.DeleteAsync | ✅ Activo |

### Usuarios (1)
| SP | Ubicación en código | Estado |
|----|---------------------|--------|
| `sp_obtener_usuarios` | UsuarioRepository.GetAllAsync | ✅ Activo |
| `sp_agregar_usuario` | UsuarioRepository.CreateAsync | ✅ Activo |
| `sp_editar_usuario` | UsuarioRepository.UpdateAsync | ✅ Activo |
| `sp_eliminar_usuario` | UsuarioRepository.DeleteAsync | ✅ Activo |

---

## 🔄 CATEGORÍA 2: CANDIDATOS PARA IMPLEMENTAR (8)

### 🎯 Alta prioridad - Uso simple READ

#### 1. `sp_obtener_estados`
```sql
SELECT Id_Estado, TipoEstado FROM estado ORDER BY Id_Estado;
```
- **Uso actual:** EstadoRepository usa SQL directo
- **Estado:** ✅ **Migrado** (GetAll/GetAllActive + CRUD por SP)
- **Impacto:** Centraliza queries de estados, facilita auditoría

#### 2. `sp_obtener_prioridades`
```sql
SELECT Id_Prioridad, NombrePrioridad FROM prioridad ORDER BY Id_Prioridad;
```
- **Uso actual:** PrioridadRepository usa SQL directo
- **Estado:** ✅ **Migrado** (GetAll/GetAllActive + CRUD por SP)
- **Impacto:** Centraliza queries de prioridades

### 🟡 Media prioridad - Requieren CRUD completo

#### 3. `sp_obtener_detalle_ticket`
```sql
-- JOIN completo de ticket con todas sus relaciones
SELECT t.*, u.nombre, ua.nombre, d.Nombre, p.NombrePrioridad, e.TipoEstado, m.Nombre
FROM tkt t LEFT JOIN usuario u ... LEFT JOIN departamento d ...
```
- **Uso actual:** TicketRepository.GetTicketDetailDTOAsync usa SQL directo con múltiples queries
- **Estado:** ✅ **Implementado** (GetDetailAsync usa SP para datos base)
- **Impacto:** Reducción significativa de roundtrips a BD

#### 4. `sp_asignar_ticket`
```sql
-- Asigna ticket a usuario con validaciones
UPDATE tkt SET Id_Usuario_Asignado = w_Id_Usuario_Asignado, Date_Asignado = NOW()
-- Incluye validación de ticket y usuario existen
```
- **Estado:** ✅ **Implementado** (Asignación usa `sp_asignar_ticket`)
- **Impacto:** Validación centralizada y endpoint dedicado

#### 5. `sp_obtener_tkt_por_id`
- **Estado:** ❌ **Eliminado** (duplicado de `sp_obtener_detalle_ticket`, con backup `old_sp_obtener_tkt_por_id`)
- **Impacto:** Reducción de redundancia

#### 6. `sp_tkt_permisos_por_usuario`
```sql
-- Obtiene permisos de usuario via rol_permiso
SELECT p.codigo FROM usuario_rol ur
JOIN rol_permiso rp ON rp.idRol = ur.idRol
JOIN permiso p ON p.idPermiso = rp.idPermiso
WHERE ur.idUsuario = w_idUsuario;
```
- **Uso actual:** No implementado (AuthService usa SQL directo en `GetPermisosUsuarioAsync`)
- **Recomendación:** ✅ **Migrar** - Ya existe la lógica, centralizar en SP
- **Impacto:** Mejora seguridad, centraliza lógica de permisos

### 🔵 Baja prioridad - Funcionalidad específica

#### 7. `sp_recuperar_password_usuario`
```sql
-- Reset password con validación email
UPDATE usuario SET email = w_email, passwordUsuario = w_newPassword ...
```
- **Uso actual:** No implementado (no hay endpoint de password recovery)
- **Recomendación:** 🔵 **Futuro** - Si se implementa recuperación de contraseña
- **Impacto:** Feature completo de password recovery

#### 8. `sp_listar_usuario`
```sql
-- Lista usuarios con filtros (nombre, username, tipo, habilitado)
-- Usa prepared statements dinámicos
```
- **Estado:** ✅ **Implementado** (endpoint de búsqueda avanzada de usuarios)
- **Impacto:** Búsqueda avanzada de usuarios

---

## 📦 CATEGORÍA 3: RESPALDOS (4)

| SP | Motivo | Acción |
|----|--------|--------|
| `old_sp_listar_departamento` | Backup antes de corrección (3 Feb 2026) | ✅ Mantener 30 días |
| `old_sp_obtener_usuarios` | Backup antes de modernización (3 Feb 2026) | ✅ Mantener 30 días |
| `old_sp_agregar_usuario` | Backup legacy (3 Feb 2026) | ✅ Mantener 30 días |
| `old_sp_editar_usuario` | Backup legacy (3 Feb 2026) | ✅ Mantener 30 días |

**Recomendación:** Eliminar después de 30 días sin incidentes.

---

## 🔧 CATEGORÍA 4: FUNCIONALIDAD LEGACY/EXTERNA (23)

Estas SPs están relacionadas con un sistema de multiempresa/sucursales/perfiles que **NO se usa en la API actual**:

### Empresas (3)
- `sp_agregar_empresa`
- `sp_editar_empresa`
- `sp_listar_empresas`

### Sucursales (3)
- `sp_agregar_sucursal`
- `sp_editar_sucursal`
- `sp_listar_sucursales`
- `sp_listar_sucursales_por_usuario`
- `sp_obtener_sucursales`

### Perfiles (3)
- `sp_agregar_perfil`
- `sp_editar_perfil`
- `sp_listar_perfil`

### Sistemas (3)
- `sp_agregar_sistema`
- `sp_editar_sistema`
- `sp_listar_sistema`

### PerAccSis (Permisos-Acceso-Sistema) (3)
- `sp_agregar_PerAccSis`
- `sp_editar_PerAccSis`
- `sp_listar_PerAccSis`

### UsuEmpSucPerSis (Usuario-Empresa-Sucursal-Perfil-Sistema) (3)
- `sp_agregar_UsuEmpSucPerSis`
- `sp_editar_UsuEmpSucPerSis`
- `sp_listar_UsuEmpSucPerSis`

### Roles y permisos avanzados (5)
- `sp_tkt_rol_crear`
- `sp_tkt_permiso_crear`
- `sp_tkt_rol_permiso_asignar`
- `sp_tkt_usuario_rol_asignar`
- `sp_traer_usuario` (función específica no clara)

**Análisis:**
- Estas SPs implementan un sistema multiempresa/multiprofile complejo
- La tabla `usuario_empresa_sucursal_perfil_sistema` existe pero **solo se usa en `GetUsuarioContextoAsync`** (1 método)
- La API actual usa un modelo simple: Usuario → Rol → Permisos
- **NO hay endpoints que expongan empresas, sucursales, perfiles o sistemas**

**Recomendación:**
- ⚠️ **NO ELIMINAR** - Pueden ser usados por otro sistema/aplicación
- 📋 **DOCUMENTAR** - Indicar que son para uso externo a esta API
- 🔍 **INVESTIGAR** - Verificar con equipo si hay otras apps usando estas tablas

---

## ⚠️ CATEGORÍA 5: PROBABLEMENTE OBSOLETOS (13)

### Seeds/Inicialización (3)
| SP | Motivo probable obsolescencia |
|----|-------------------------------|
| `sp_tkt_seed_basico` | Seed manual vs migrations automáticos |
| `sp_tkt_seed_minima` | Seed manual vs migrations automáticos |
| `sp_tkt_seed_asignar_roles_usuarios` | Seed manual vs migrations automáticos |

**Recomendación:** ⚠️ Verificar si se usan en scripts de deployment/setup. Si no, **eliminar**.

### Login legacy (2)
| SP | Motivo probable obsolescencia |
|----|-------------------------------|
| `sp_login` | AuthService usa lógica C# con JWT, no SPs |
| `sp_login.old` | Backup explícito de versión antigua |
| `sp_login_hub` | No se usa, probablemente versión anterior |

**Recomendación:** ⚠️ **Eliminar `sp_login.old`** (backup explícito). Verificar otros con equipo antes de eliminar.

### Listado simple (1)
| SP | Motivo probable obsolescencia |
|----|-------------------------------|
| `sp_listar_tkt` | Reemplazado por `sp_listar_tkts` (con filtros y permisos) |

**Recomendación:** ⚠️ Verificar que no se use en scripts externos, luego **eliminar**.

### Departamentos legacy (1)
| SP | Motivo probable obsolescencia |
|----|-------------------------------|
| `sp_obtener_departamentos` | Reemplazado por `sp_listar_departamento` |

**Recomendación:** ⚠️ Verificar código legacy, luego **eliminar** o marcar deprecated.

---

## 📋 PLAN DE ACCIÓN RECOMENDADO

### ✅ Fase 1: Implementaciones rápidas (Sprint actual)

1. **Estados** - Migrar `EstadoRepository.GetAllAsync()` a `sp_obtener_estados`
   - Impacto: Bajo riesgo, alta consistencia
   - Esfuerzo: 30 min
   
2. **Prioridades** - Migrar `PrioridadRepository.GetAllAsync()` a `sp_obtener_prioridades`
   - Impacto: Bajo riesgo, alta consistencia
   - Esfuerzo: 30 min

3. **Permisos** - Integrar `sp_tkt_permisos_por_usuario` en `AuthService`
   - Impacto: Mejora seguridad
   - Esfuerzo: 1 hora

### 🔄 Fase 2: Optimizaciones (Próximo sprint)

4. **Detalle ticket** - ✅ Implementado `sp_obtener_detalle_ticket`
   - Impacto: Performance (7 queries → 1 query para datos base)
   - Esfuerzo: 2-3 horas (incluye testing)

5. **CRUD Estados** - ✅ Implementado `sp_estado_crear/actualizar/eliminar`
   - Impacto: Consistencia arquitectura
   - Esfuerzo: 2 horas

6. **CRUD Prioridades** - ✅ Implementado `sp_prioridad_crear/actualizar/eliminar`
   - Impacto: Consistencia arquitectura
   - Esfuerzo: 2 horas

7. **Asignación tickets** - ✅ Implementado `sp_asignar_ticket`
   - Impacto: Validación centralizada de asignaciones
   - Esfuerzo: 1 hora

8. **Búsqueda usuarios** - ✅ Implementado `sp_listar_usuario`
   - Impacto: Filtros avanzados de usuarios
   - Esfuerzo: 1 hora

### ⚠️ Fase 3: Limpieza (Después de validación)

7. **Eliminar backups** - Eliminar `old_*` después de 30 días sin incidentes
   - Fecha tentativa: 5 de Marzo 2026
   
8. **Investigar legacy** - Verificar con equipo uso de SPs empresa/sucursal/perfil
   - Documentar hallazgos
   
9. **Deprecar obsoletos** - Marcar como deprecated:
   - `sp_login.old` → Eliminar inmediato
   - `sp_listar_tkt` → Verificar y eliminar
   - `sp_obtener_departamentos` → Verificar y eliminar
   - Seeds → Verificar uso en CI/CD

---

## 📈 MÉTRICAS POST-MIGRACIÓN

### Estado actual (3 Feb 2026)
- Repositorios 100% con SPs: **Tickets, Departamentos, Motivos, Usuarios** (4/10)
- Repositorios parciales: **Comentarios** (1 método con SP)
- Repositorios SQL directo: **Estados, Prioridades, Roles, Permisos, Grupos, Aprobaciones, Transiciones** (7/10)

### Objetivo corto plazo (15 Feb 2026)
- Repositorios 100% con SPs: **7/10** (agregar Estados, Prioridades, Permisos)
- Eliminación de SPs obsoletos confirmados
- Documentación de SPs legacy/externos

### Objetivo largo plazo (Marzo 2026)
- Repositorios 100% con SPs: **10/10**
- Consolidación de SPs duplicados
- Auditoría completa y documentación actualizada

---

## 🔍 DECISIONES PENDIENTES

1. **sp_asignar_ticket vs sp_actualizar_tkt:** ¿Mantener ambos o unificar?
2. **sp_obtener_tkt_por_id vs sp_obtener_detalle_ticket:** ¿Cuál es el estándar?
3. **SPs empresa/sucursal/perfil:** ¿Usados por otra aplicación? ¿Deprecar o mantener?
4. **sp_recuperar_password_usuario:** ¿Implementar feature completo?
5. **sp_listar_usuario:** ¿Implementar filtros avanzados en API?

---

## 📝 NOTAS IMPORTANTES

- **MySQL 5.5:** Todas las SPs deben mantener compatibilidad
- **OUT parameters:** Patrón establecido para validaciones (`p_resultado`)
- **Naming:** Mantener convención `sp_<entidad>_<accion>` para nuevas SPs
- **Backups:** Siempre crear `old_*` antes de modificar SPs existentes
- **Testing:** Ejecutar `test_verificacion_endpoints.ps1` después de cada migración

