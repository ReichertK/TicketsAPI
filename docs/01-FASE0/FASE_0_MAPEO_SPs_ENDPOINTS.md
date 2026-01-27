# FASE 0: MAPEO SPs → ENDPOINTS
## Análisis Completo de Stored Procedures vs Endpoints Actuales

**Fecha:** 23 de Enero 2026  
**Status:** Análisis en progreso

---

## 📊 RESUMEN EJECUTIVO

### Estadísticas
- **Total de SPs:** 44 procedimientos almacenados
- **Total de Funciones:** 3 funciones
- **Controllers Actuales:** 12
- **Endpoints Implementados:** ~42
- **Cobertura SP:** 65% (28 de 44 SPs mapeadas a endpoints)
- **Gaps Identificados:** 16 SPs sin endpoints

---

## 🗺️ MAPEO DETALLADO: SP → ENDPOINTS

### 1. AUTENTICACIÓN Y USUARIOS

#### ✅ IMPLEMENTADOS

| SP | Función | Endpoint | Controller | Status |
|-----|---------|----------|-----------|--------|
| `sp_login` | Login usuario | `POST /Auth/Login` | AuthController | ✅ ACTIVO |
| `sp_login_hub` | Login con datos HUB | `POST /Auth/Login` | AuthController | ⚠️ Alternativa |
| `sp_agregar_usuario` | Crear usuario | `POST /Usuarios` | (Falta) | ❌ NO IMPLEMENTADO |
| `sp_listar_usuario` | Listar usuarios | `GET /Usuarios` | (Falta) | ❌ NO IMPLEMENTADO |
| `sp_editar_usuario` | Editar usuario | `PUT /Usuarios/{id}` | (Falta) | ❌ NO IMPLEMENTADO |
| `sp_recuperar_password_usuario` | Reset password | `POST /Auth/RecoverPassword` | (Falta) | ❌ NO IMPLEMENTADO |

#### 🚩 PROBLEMAS ENCONTRADOS
- `sp_login_hub` nunca se usa (duplicado de sp_login)
- No hay endpoint para CRUD de usuarios
- No hay endpoint para recovery de contraseña

**Recomendación:** Crear `UsuariosController` con endpoints básicos

---

### 2. TICKETS - CRUD

#### ✅ IMPLEMENTADOS

| SP | Función | Endpoint | Controller | Status |
|-----|---------|----------|-----------|--------|
| `sp_agregar_tkt` | Crear ticket | `POST /Tickets` | TicketsController | ✅ ACTIVO |
| `sp_listar_tkt` | Listar tickets (detallado) | `GET /Tickets` | TicketsController | ✅ ACTIVO |
| `sp_listar_tkts` | Listar tickets (múltiples filtros) | `GET /Tickets` | TicketsController | ✅ ACTIVO (variante) |
| `sp_obtener_tkt_por_id` | Get ticket por ID | `GET /Tickets/{id}` | TicketsController | ✅ ACTIVO |
| `sp_actualizar_tkt` | Actualizar ticket | `PUT /Tickets/{id}` | TicketsController | ✅ ACTIVO |
| `sp_eliminar_ticket` | Eliminar/desactivar | `DELETE /Tickets/{id}` | TicketsController | ✅ ACTIVO |
| `sp_obtener_detalle_ticket` | Get detalle completo | `GET /Tickets/{id}/Detail` | TicketsController | ✅ ACTIVO |
| `sp_obtener_departamentos` | GET departamentos | `GET /References/Departamentos` | ReferencesController | ✅ ACTIVO |
| `sp_obtener_estados` | GET estados | `GET /References/Estados` | ReferencesController | ✅ ACTIVO |
| `sp_obtener_motivos` | GET motivos | `GET /References/Motivos` | ReferencesController | ✅ ACTIVO |
| `sp_obtener_prioridades` | GET prioridades | `GET /References/Prioridades` | ReferencesController | ✅ ACTIVO |
| `sp_obtener_sucursales` | GET sucursales | `GET /References/Sucursales` | ReferencesController | ✅ ACTIVO |

**Coverage: 100%** ✅

---

### 3. TICKETS - FUNCIONALIDADES AVANZADAS

#### ✅ IMPLEMENTADOS

| SP | Función | Endpoint | Controller | Status |
|-----|---------|----------|-----------|--------|
| `sp_asignar_ticket` | Asignar ticket | `PUT /Tickets/{id}/Assign` | TicketsController | ✅ ACTIVO |
| `sp_tkt_comentar` | Agregar comentario | `POST /Comentarios` | ComentariosController | ✅ ACTIVO |
| `sp_tkt_historial` | Historial/transiciones | `GET /Tickets/{id}/History` | TransicionesController | ✅ ACTIVO |

#### ❌ NO IMPLEMENTADOS

| SP | Función | Endpoint Requerido | Controller | Status |
|-----|---------|----------|-----------|--------|
| (Falta) | Cambiar estado ticket | `PUT /Tickets/{id}/State` | TicketsController | ⚠️ Implementar |
| (Falta) | Cerrar ticket | `PUT /Tickets/{id}/Close` | TicketsController | ⚠️ Implementar |
| (Falta) | Reabrir ticket | `PUT /Tickets/{id}/Reopen` | TicketsController | ⚠️ Implementar |
| (Falta) | Marcar como Espera | `PUT /Tickets/{id}/Wait` | TicketsController | ⚠️ Implementar |

**Coverage: 75%** ⚠️

---

### 4. APROBACIONES

#### ✅ PARCIALMENTE IMPLEMENTADO

| SP/Tabla | Función | Endpoint | Controller | Status |
|-----|---------|----------|-----------|--------|
| `tkt_aprobacion` table | Solicitar aprobación | `POST /Aprobaciones/Solicitar` | AprobacionesController | ✅ Existe tabla |
| (Falta SP) | Listar aprobaciones pendientes | `GET /Aprobaciones/Pendientes` | AprobacionesController | ⚠️ Falta SP |
| (Falta SP) | Aprobar/rechazar | `POST /Aprobaciones/{id}/Responder` | AprobacionesController | ⚠️ Falta SP |
| (Falta SP) | Historial aprobaciones | `GET /Aprobaciones/{id}/Historial` | AprobacionesController | ⚠️ Falta SP |

**Coverage: 25%** 🔴

**Problemas:**
- La tabla `tkt_aprobacion` existe pero NO hay SPs para operarla
- El controlador `AprobacionesController` existe pero está vacío
- Necesita lógica de transiciones

---

### 5. COMENTARIOS

#### ✅ IMPLEMENTADOS

| SP | Función | Endpoint | Controller | Status |
|-----|---------|----------|-----------|--------|
| `sp_tkt_comentar` | Crear comentario | `POST /Comentarios` | ComentariosController | ✅ ACTIVO |

#### ❌ FALTANTES

| SP | Función | Endpoint Requerido | Controller | Status |
|-----|---------|----------|-----------|--------|
| (Falta) | Listar comentarios | `GET /Tickets/{id}/Comentarios` | ComentariosController | ❌ FALTA |
| (Falta) | Editar comentario | `PUT /Comentarios/{id}` | ComentariosController | ❌ FALTA |
| (Falta) | Eliminar comentario | `DELETE /Comentarios/{id}` | ComentariosController | ❌ FALTA |

**Coverage: 25%** 🔴

---

### 6. TRANSICIONES (CAMBIOS DE ESTADO)

#### ✅ IMPLEMENTADOS

| SP/Tabla | Función | Endpoint | Controller | Status |
|-----|---------|----------|-----------|--------|
| `tkt_transicion` table | Registrar transición | (Automático) | TicketsController | ✅ Existe tabla |
| `tkt_transicion_regla` table | Validar reglas | (Automático) | TicketsController | ✅ Existe tabla |

#### ❌ NO IMPLEMENTADOS - SPs

| SP | Función | Endpoint Requerido | Status |
|-----|---------|----------|--------|
| (Falta SP) | Validar transición permitida | `GET /Transiciones/Validar` | ❌ FALTA |
| (Falta SP) | Listar transiciones posibles | `GET /Tickets/{id}/TransicionesPermitidas` | ❌ FALTA |
| (Falta SP) | Ejecutar transición | `POST /Transiciones/Ejecutar` | ❌ FALTA |

**Coverage: 0%** 🔴

**Nota:** Las tablas existen pero no hay SPs ni endpoints para validar/ejecutar transiciones

---

### 7. SUSCRIPTORES (WATCHERS)

#### ❌ NO IMPLEMENTADO

| Tabla | Función | Endpoint Requerido | Status |
|-----|---------|----------|--------|
| `tkt_suscriptor` | Suscribir a ticket | `POST /Tickets/{id}/Suscriptores` | ❌ NO |
| `tkt_suscriptor` | Desuscribir | `DELETE /Tickets/{id}/Suscriptores/{userId}` | ❌ NO |
| `tkt_suscriptor` | Listar suscriptores | `GET /Tickets/{id}/Suscriptores` | ❌ NO |

**Coverage: 0%** 🔴

---

### 8. PERMISOS Y ROLES

#### ✅ IMPLEMENTADOS

| SP | Función | Endpoint | Controller | Status |
|-----|---------|----------|-----------|--------|
| `sp_tkt_rol_crear` | Crear rol | `POST /Admin/Roles` | AdminController | ✅ Existe tabla |
| `sp_tkt_permiso_crear` | Crear permiso | `POST /Admin/Permisos` | AdminController | ✅ Existe tabla |
| `sp_tkt_rol_permiso_asignar` | Asignar permiso a rol | `POST /Admin/Roles/{id}/Permisos` | AdminController | ✅ Existe tabla |
| `sp_tkt_permisos_por_usuario` | Get permisos usuario | `GET /Admin/Usuarios/{id}/Permisos` | AdminController | ✅ ACTIVO |

#### ❌ PARCIALMENTE IMPLEMENTADOS

| SP/Tabla | Función | Endpoint | Controller | Status |
|-----|---------|----------|-----------|--------|
| `tkt_rol` table | CRUD Roles | `GET/POST/PUT/DELETE /Admin/Roles` | AdminController | ⚠️ Parcial |
| `tkt_permiso` table | CRUD Permisos | `GET/POST/PUT/DELETE /Admin/Permisos` | AdminController | ⚠️ Parcial |
| `tkt_rol_permiso` table | Mapeo rol-permiso | `GET/POST/DELETE /Admin/Roles/{id}/Permisos` | AdminController | ⚠️ Parcial |
| `tkt_usuario_rol` table | Usuario-rol | `GET/POST/DELETE /Admin/Usuarios/{id}/Roles` | AdminController | ⚠️ Parcial |

**Coverage: 50%** ⚠️

---

### 9. BÚSQUEDA Y REPORTES

#### ⚠️ TABLAS SIN SPs

| Tabla | Función | SP Requerido | Endpoint | Status |
|-----|---------|----------|--------|--------|
| `tkt_search` | Búsqueda full-text | `sp_buscar_tickets` | `GET /Tickets/Search` | ❌ FALTA |
| (Falta) | Reportes tickets | `sp_reporte_tickets` | `GET /Admin/Reportes/Tickets` | ❌ FALTA |
| (Falta) | Reportes por estado | `sp_reporte_estado` | `GET /Admin/Reportes/PorEstado` | ❌ FALTA |

**Coverage: 0%** 🔴

---

### 10. ADMINISTRACIÓN (EMPRESAS, SUCURSALES, PERFILES, SISTEMAS)

#### ✅ IMPLEMENTADOS

| SP | Función | Endpoint | Controller | Status |
|-----|---------|----------|-----------|--------|
| `sp_agregar_empresa` | Crear empresa | `POST /Admin/Empresas` | AdminController | ✅ ACTIVO |
| `sp_listar_empresas` | Listar empresas | `GET /Admin/Empresas` | AdminController | ✅ ACTIVO |
| `sp_editar_empresa` | Editar empresa | `PUT /Admin/Empresas/{id}` | AdminController | ✅ ACTIVO |
| `sp_agregar_sucursal` | Crear sucursal | `POST /Admin/Sucursales` | AdminController | ✅ ACTIVO |
| `sp_listar_sucursales` | Listar sucursales | `GET /Admin/Sucursales` | AdminController | ✅ ACTIVO |
| `sp_editar_sucursal` | Editar sucursal | `PUT /Admin/Sucursales/{id}` | AdminController | ✅ ACTIVO |
| `sp_agregar_perfil` | Crear perfil | `POST /Admin/Perfiles` | AdminController | ✅ ACTIVO |
| `sp_listar_perfil` | Listar perfiles | `GET /Admin/Perfiles` | AdminController | ✅ ACTIVO |
| `sp_editar_perfil` | Editar perfil | `PUT /Admin/Perfiles/{id}` | AdminController | ✅ ACTIVO |
| `sp_agregar_sistema` | Crear sistema | `POST /Admin/Sistemas` | AdminController | ✅ ACTIVO |
| `sp_listar_sistema` | Listar sistemas | `GET /Admin/Sistemas` | AdminController | ✅ ACTIVO |
| `sp_editar_sistema` | Editar sistema | `PUT /Admin/Sistemas/{id}` | AdminController | ✅ ACTIVO |
| `sp_agregar_PerAccSis` | Asignar perfil-acción-sistema | `POST /Admin/PerfilSistema` | AdminController | ✅ ACTIVO |
| `sp_listar_PerAccSis` | Listar permisos sistema | `GET /Admin/PerfilSistema` | AdminController | ✅ ACTIVO |
| `sp_editar_PerAccSis` | Editar permiso sistema | `PUT /Admin/PerfilSistema/{id}` | AdminController | ✅ ACTIVO |
| `sp_agregar_UsuEmpSucPerSis` | Asignar usuario-empresa-sucursal | `POST /Admin/UsuariosAsignacion` | AdminController | ✅ ACTIVO |
| `sp_editar_UsuEmpSucPerSis` | Editar asignación usuario | `PUT /Admin/UsuariosAsignacion/{id}` | AdminController | ✅ ACTIVO |
| `sp_listar_UsuEmpSucPerSis` | Listar asignaciones usuario | `GET /Admin/UsuariosAsignacion` | AdminController | ✅ ACTIVO |
| `sp_listar_sucursales_por_usuario` | Sucursales del usuario | `GET /Admin/MisSucursales` | AdminController | ✅ ACTIVO |
| `sp_obtener_usuarios` | Listar usuarios (simple) | `GET /Admin/Usuarios` | AdminController | ✅ ACTIVO |

**Coverage: 100%** ✅

---

### 11. FUNCIONES (NO SPs)

#### ✅ IMPLEMENTADAS

| Función | Uso | Endpoint | Status |
|---------|-----|----------|--------|
| `fc_get_empresa` | Info empresa | (Interno) | ✅ Usada en SPs |
| `fc_get_sucursal` | Info sucursal | (Interno) | ✅ Usada en SPs |
| `fc_get_perfil_sistema_con_sucursal` | Validar perfil | (Interno) | ✅ Usada en SPs |

**Coverage: 100%** ✅ (Son funciones helper)

---

### 12. SEED/INICIALIZACIÓN

#### ⚠️ SOLO EN SP

| SP | Función | Endpoint | Status |
|-----|---------|----------|--------|
| `sp_tkt_seed_asignar_roles_usuarios` | Seed datos iniciales | (Solo admin) | ⚠️ Sin endpoint |

---

## 📊 RESUMEN POR CATEGORÍA

| Categoría | Total SPs | Implementados | % Cobertura | Estado |
|-----------|-----------|----------------|-------------|--------|
| **Autenticación** | 6 | 1 | 17% | 🔴 CRÍTICO |
| **Tickets CRUD** | 12 | 12 | 100% | ✅ COMPLETO |
| **Funcionalidades Avanzadas** | 3 | 3 | 100% | ✅ COMPLETO |
| **Aprobaciones** | 0 SPs | 0 | 0% | 🔴 CRÍTICO |
| **Comentarios** | 1 | 1 | 100% | ✅ COMPLETO |
| **Transiciones** | 0 SPs | 0 | 0% | 🔴 CRÍTICO |
| **Suscriptores** | 0 SPs | 0 | 0% | 🔴 CRÍTICO |
| **Permisos/Roles** | 4 | 4 | 100% | ✅ COMPLETO |
| **Admin (Empresas/Sucursales/etc)** | 20 | 20 | 100% | ✅ COMPLETO |
| **Búsqueda/Reportes** | 0 SPs | 0 | 0% | 🔴 CRÍTICO |
| **Funciones Helper** | 3 | 3 | 100% | ✅ COMPLETO |
| **TOTAL** | **50** | **31** | **62%** | ⚠️ PARCIAL |

---

## 🚨 BRECHA IDENTIFICADA: 19 SPs SIN ENDPOINTS

### CRÍTICOS (Deben implementarse YA)

1. **Autenticación y Usuarios**
   - [ ] `sp_agregar_usuario` → `POST /Usuarios`
   - [ ] `sp_listar_usuario` → `GET /Usuarios`
   - [ ] `sp_editar_usuario` → `PUT /Usuarios/{id}`
   - [ ] `sp_recuperar_password_usuario` → `POST /Auth/RecoverPassword`

2. **Aprobaciones (Falta lógica)**
   - [ ] Crear SP para listar aprobaciones pendientes
   - [ ] Crear SP para responder aprobación
   - [ ] Crear endpoints en AprobacionesController

3. **Transiciones (Falta lógica)**
   - [ ] Crear SP para validar transición
   - [ ] Crear SP para ejecutar transición
   - [ ] Crear endpoints en TransicionesController

4. **Comentarios Completo**
   - [ ] `GET /Tickets/{id}/Comentarios`
   - [ ] `PUT /Comentarios/{id}`
   - [ ] `DELETE /Comentarios/{id}`

### SECUNDARIOS (Mejorar funcionalidad)

5. **Suscriptores (Watchers)**
   - [ ] Crear SPs para suscriptores
   - [ ] Endpoints en TicketsController

6. **Búsqueda y Reportes**
   - [ ] SP de búsqueda full-text
   - [ ] SPs de reportes
   - [ ] Endpoints en AdminController

---

## 🔄 DEPENDENCIAS Y RELACIONES

```
Tickets (tkt)
├── Estado (estado) ✅
├── Prioridad (prioridad) ✅
├── Departamento (departamento) ✅
├── Motivo (motivo) ✅
├── Usuario (usuario) ⚠️ (Sin CRUD completo)
├── Comentarios (tkt_comentario) ✅ (Parcial)
├── Aprobaciones (tkt_aprobacion) ❌ (Sin lógica)
├── Transiciones (tkt_transicion) ❌ (Sin validación)
└── Suscriptores (tkt_suscriptor) ❌ (Sin endpoints)

Administración
├── Empresas (empresa) ✅
├── Sucursales (sucursal) ✅
├── Perfiles (perfil) ✅
├── Sistemas (sistema) ✅
├── Usuarios (usuario) ⚠️
└── Roles/Permisos
    ├── tkt_rol ✅
    ├── tkt_permiso ✅
    ├── tkt_rol_permiso ✅
    └── tkt_usuario_rol ✅
```

---

## 💡 RECOMENDACIONES DE IMPLEMENTACIÓN

### Orden de Prioridad

#### FASE 1 (Hoy - Estandarización)
- Implementar `ApiResponse<T>` wrapper
- Estandarizar todos los controllers
- Ya que **no agregamos endpoints nuevos**

#### FASE 2 (Esta semana - Endpoints críticos)
1. **UsuariosController** (CRUD)
   - POST /Usuarios (crear)
   - GET /Usuarios (listar)
   - GET /Usuarios/{id} (obtener)
   - PUT /Usuarios/{id} (editar)
   - DELETE /Usuarios/{id} (eliminar)
   - POST /Auth/RecoverPassword

2. **AprobacionesController** (Funcionalidad)
   - GET /Aprobaciones/Pendientes
   - POST /Aprobaciones/{id}/Responder
   - GET /Aprobaciones/Historial/{id}

3. **TransicionesController** (Lógica de estados)
   - GET /Tickets/{id}/TransicionesPermitidas
   - POST /Transiciones/Ejecutar

#### FASE 3 (Próximas semanas)
4. **ComentariosController** (Completar CRUD)
5. **SuscriptoresController** (Watchers)
6. **ReportesController** (Búsqueda y análisis)

---

## 📋 CHECKLIST DE COBERTURA

### Tickets
- [x] GET /Tickets (listar)
- [x] POST /Tickets (crear)
- [x] GET /Tickets/{id} (obtener)
- [x] PUT /Tickets/{id} (actualizar)
- [x] DELETE /Tickets/{id} (eliminar)
- [x] GET /Tickets/{id}/Detail
- [x] PUT /Tickets/{id}/Assign
- [ ] PUT /Tickets/{id}/State
- [ ] PUT /Tickets/{id}/Close
- [ ] PUT /Tickets/{id}/Reopen
- [ ] PUT /Tickets/{id}/Wait
- [x] GET /Tickets/{id}/History

### Usuarios
- [ ] GET /Usuarios
- [ ] POST /Usuarios
- [ ] GET /Usuarios/{id}
- [ ] PUT /Usuarios/{id}
- [ ] DELETE /Usuarios/{id}
- [ ] POST /Auth/RecoverPassword

### Aprobaciones
- [ ] GET /Aprobaciones/Pendientes
- [ ] POST /Aprobaciones/Solicitar
- [ ] POST /Aprobaciones/{id}/Responder
- [ ] GET /Aprobaciones/{id}/Historial

### Comentarios
- [x] POST /Comentarios (crear)
- [ ] GET /Tickets/{id}/Comentarios (listar)
- [ ] PUT /Comentarios/{id} (editar)
- [ ] DELETE /Comentarios/{id} (eliminar)

### Transiciones
- [ ] GET /Tickets/{id}/TransicionesPermitidas
- [ ] POST /Transiciones/Ejecutar
- [x] GET /Tickets/{id}/Transiciones (como History)

### Suscriptores
- [ ] GET /Tickets/{id}/Suscriptores
- [ ] POST /Tickets/{id}/Suscriptores
- [ ] DELETE /Tickets/{id}/Suscriptores/{userId}

### Referencias
- [x] GET /References/Estados
- [x] GET /References/Prioridades
- [x] GET /References/Motivos
- [x] GET /References/Departamentos
- [x] GET /References/Sucursales
- [ ] GET /References/Tipos (FALTA)

### Admin
- [x] GET/POST/PUT /Admin/Empresas
- [x] GET/POST/PUT /Admin/Sucursales
- [x] GET/POST/PUT /Admin/Perfiles
- [x] GET/POST/PUT /Admin/Sistemas
- [x] GET/POST/PUT /Admin/Roles
- [x] GET/POST/PUT /Admin/Permisos
- [x] GET/PUT/DELETE /Admin/Usuarios/{id}/Roles
- [x] GET /Admin/Usuarios/{id}/Permisos
- [ ] GET/POST/PUT/DELETE /Admin/Usuarios (CRUD)

---

## 🎯 CONCLUSIÓN

**Cobertura actual: 62% (31/50 SPs)**

### Fortalezas ✅
- Tickets CRUD completamente implementado
- Admin completamente implementado
- Roles y permisos bien estructurados

### Debilidades 🔴
- **Sin CRUD de usuarios** (crítico para multi-tenant)
- **Sin lógica de aprobaciones** (tablas existen pero sin SPs)
- **Sin validación de transiciones** (tablas existen pero sin lógica)
- **Sin búsqueda/reportes** (tabla existe pero sin SPs)
- **Suscriptores no implementados** (tabla existe pero sin endpoints)

### Siguiente Paso: FASE 1 (Estandarización de API)
Una vez completada la estandarización, procedemos a FASE 2 (Endpoints críticos).

---

**Documento generado:** 2026-01-23  
**Versión:** 1.0 - Análisis Completo
