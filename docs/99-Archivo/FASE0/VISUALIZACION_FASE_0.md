# VISUALIZACIÓN FASE 0 - MAPEO DE ENDPOINTS
## Diagrama interactivo de cobertura de SPs

**Actualizado:** 23 Enero 2026

---

## 🎯 COBERTURA GLOBAL: 62%

```
TOTAL SPs: 50 ═══════════════════════════════════════════════════
Implementados: 31 ███████████████████████████░░░░░░░░░░░░░░░░░░░ 62%
Faltantes: 19 ░░░░░░░░░░░░░░░░░░░ 38%
```

---

## 📊 COBERTURA POR CATEGORÍA

### 1. AUTENTICACIÓN Y USUARIOS
```
SPs: 6 ═══════════════════════════════════════════════════
Implementados: 1 ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 17%
Faltantes: 5

SPs disponibles:
├── ✅ sp_login → POST /Auth/Login
├── ⚠️ sp_login_hub → (Duplicado, no usar)
├── ❌ sp_agregar_usuario → POST /Usuarios
├── ❌ sp_listar_usuario → GET /Usuarios
├── ❌ sp_editar_usuario → PUT /Usuarios/{id}
└── ❌ sp_recuperar_password_usuario → POST /Auth/RecoverPassword
```

### 2. TICKETS - CRUD
```
SPs: 12 ═══════════════════════════════════════════════════
Implementados: 12 ████████████████████████████████████████████░░░░ 100%
Faltantes: 0

SPs disponibles:
├── ✅ sp_agregar_tkt → POST /Tickets
├── ✅ sp_listar_tkt → GET /Tickets
├── ✅ sp_listar_tkts → GET /Tickets (variante)
├── ✅ sp_obtener_tkt_por_id → GET /Tickets/{id}
├── ✅ sp_actualizar_tkt → PUT /Tickets/{id}
├── ✅ sp_eliminar_ticket → DELETE /Tickets/{id}
├── ✅ sp_obtener_detalle_ticket → GET /Tickets/{id}/Detail
├── ✅ sp_obtener_departamentos → GET /References/Departamentos
├── ✅ sp_obtener_estados → GET /References/Estados
├── ✅ sp_obtener_motivos → GET /References/Motivos
├── ✅ sp_obtener_prioridades → GET /References/Prioridades
└── ✅ sp_obtener_sucursales → GET /References/Sucursales
```

### 3. TICKETS - AVANZADO
```
SPs: 3 ═══════════════════════════════════════════════════
Implementados: 3 ████████████████████████████████████████████░░░░ 100%
Faltantes: 0

SPs disponibles:
├── ✅ sp_asignar_ticket → PUT /Tickets/{id}/Assign
├── ✅ sp_tkt_comentar → POST /Comentarios
└── ✅ sp_tkt_historial → GET /Tickets/{id}/History
```

### 4. APROBACIONES
```
SPs: 0 (NO EXISTEN SPs) ═══════════════════════════════════════════════════
Implementados: 0 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0%
Faltantes: 0 (pero tablas existen)

❌ CRÍTICO: Las tablas existen pero no hay SPs
Necesario: Crear nuevos SPs en FASE 3

Tablas relacionadas:
├── tkt_aprobacion (existe)
├── tkt_solicitud_aprobacion (existe)
└── tkt_respuesta_aprobacion (existe)
```

### 5. COMENTARIOS
```
SPs: 1 ═══════════════════════════════════════════════════
Implementados: 1 ████████████████████████████████████████████░░░░ 100%
Faltantes: 0

SPs disponibles:
└── ✅ sp_tkt_comentar → POST /Comentarios

⚠️ INCOMPLETO: Falta GET/PUT/DELETE
Endpoints faltantes:
├── GET /Tickets/{id}/Comentarios
├── PUT /Comentarios/{id}
└── DELETE /Comentarios/{id}
```

### 6. TRANSICIONES
```
SPs: 0 (NO EXISTEN SPs) ═══════════════════════════════════════════════════
Implementados: 0 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0%
Faltantes: 0 (pero tablas existen)

❌ CRÍTICO: Las tablas existen pero sin validación/lógica
Necesario: Crear nuevos SPs en FASE 3

Tablas relacionadas:
├── tkt_transicion (existe)
├── tkt_transicion_regla (existe)
└── tkt_estado (relacionada)

Endpoints requeridos:
├── GET /Tickets/{id}/TransicionesPermitidas
└── POST /Transiciones/Ejecutar
```

### 7. SUSCRIPTORES (WATCHERS)
```
SPs: 0 (NO EXISTEN SPs) ═══════════════════════════════════════════════════
Implementados: 0 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0%
Faltantes: 0 (pero tabla existe)

⚠️ SECUNDARIO: Tabla existe pero sin endpoints
Tabla: tkt_suscriptor

Endpoints requeridos:
├── GET /Tickets/{id}/Suscriptores
├── POST /Tickets/{id}/Suscriptores
└── DELETE /Tickets/{id}/Suscriptores/{userId}
```

### 8. PERMISOS Y ROLES
```
SPs: 4 ═══════════════════════════════════════════════════
Implementados: 4 ████████████████████████████████████████████░░░░ 100%
Faltantes: 0

SPs disponibles:
├── ✅ sp_tkt_rol_crear → POST /Admin/Roles
├── ✅ sp_tkt_permiso_crear → POST /Admin/Permisos
├── ✅ sp_tkt_rol_permiso_asignar → POST /Admin/Roles/{id}/Permisos
└── ✅ sp_tkt_permisos_por_usuario → GET /Admin/Usuarios/{id}/Permisos
```

### 9. ADMINISTRACIÓN (EMPRESAS, SUCURSALES, ETC)
```
SPs: 20 ═══════════════════════════════════════════════════
Implementados: 20 ████████████████████████████████████████████░░░░ 100%
Faltantes: 0

SPs disponibles:
├── ✅ sp_agregar_empresa → POST /Admin/Empresas
├── ✅ sp_listar_empresas → GET /Admin/Empresas
├── ✅ sp_editar_empresa → PUT /Admin/Empresas/{id}
├── ✅ sp_agregar_sucursal → POST /Admin/Sucursales
├── ✅ sp_listar_sucursales → GET /Admin/Sucursales
├── ✅ sp_editar_sucursal → PUT /Admin/Sucursales/{id}
├── ✅ sp_agregar_perfil → POST /Admin/Perfiles
├── ✅ sp_listar_perfil → GET /Admin/Perfiles
├── ✅ sp_editar_perfil → PUT /Admin/Perfiles/{id}
├── ✅ sp_agregar_sistema → POST /Admin/Sistemas
├── ✅ sp_listar_sistema → GET /Admin/Sistemas
├── ✅ sp_editar_sistema → PUT /Admin/Sistemas/{id}
├── ✅ sp_agregar_PerAccSis → POST /Admin/PerfilSistema
├── ✅ sp_listar_PerAccSis → GET /Admin/PerfilSistema
├── ✅ sp_editar_PerAccSis → PUT /Admin/PerfilSistema/{id}
├── ✅ sp_agregar_UsuEmpSucPerSis → POST /Admin/UsuariosAsignacion
├── ✅ sp_editar_UsuEmpSucPerSis → PUT /Admin/UsuariosAsignacion/{id}
├── ✅ sp_listar_UsuEmpSucPerSis → GET /Admin/UsuariosAsignacion
├── ✅ sp_listar_sucursales_por_usuario → GET /Admin/MisSucursales
└── ✅ sp_obtener_usuarios → GET /Admin/Usuarios
```

### 10. FUNCIONES (HELPER)
```
Funciones: 3 ═══════════════════════════════════════════════════
Implementadas: 3 ████████████████████████████████████████████░░░░ 100%
Sin usar: 0

Funciones disponibles:
├── ✅ fc_get_empresa → (Helper interno)
├── ✅ fc_get_sucursal → (Helper interno)
└── ✅ fc_get_perfil_sistema_con_sucursal → (Helper interno)
```

### 11. BÚSQUEDA Y REPORTES
```
SPs: 0 (NO EXISTEN SPs) ═══════════════════════════════════════════════════
Implementados: 0 ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0%
Faltantes: 0 (pero tabla existe)

⚠️ FEATURE: Bajo prioridad, pero tabla existe
Tabla: tkt_search

Endpoints requeridos:
├── GET /Tickets/Search?q=...
├── GET /Admin/Reportes/Tickets
├── GET /Admin/Reportes/PorEstado
└── GET /Admin/Reportes/PorUsuario
```

---

## 🎯 RESUMEN VISUAL

```
CATEGORÍA              COBERTURA        STATUS
═════════════════════════════════════════════════════════════
✅ Tickets CRUD        100% ████████████ COMPLETO
✅ Admin               100% ████████████ COMPLETO
✅ Comentarios         100% ████████████ COMPLETO (parcial)
✅ Permisos/Roles      100% ████████████ COMPLETO
✅ Funciones Helper    100% ████████████ COMPLETO
───────────────────────────────────────────────────────────
⚠️ Autenticación       17%  ██░░░░░░░░░░ INCOMPLETO
⚠️ Comentarios (CRUD)  25%  ███░░░░░░░░░ INCOMPLETO
───────────────────────────────────────────────────────────
🔴 Aprobaciones        0%   ░░░░░░░░░░░░ SIN LÓGICA
🔴 Transiciones        0%   ░░░░░░░░░░░░ SIN VALIDACIÓN
🔴 Suscriptores        0%   ░░░░░░░░░░░░ SIN ENDPOINTS
🔴 Búsqueda/Reportes   0%   ░░░░░░░░░░░░ NO EXISTE
═════════════════════════════════════════════════════════════
   TOTAL COBERTURA    62%  ████████░░░░ PARCIAL
```

---

## 🚨 PRIORIDADES DE IMPLEMENTACIÓN

### CRÍTICO - SEMANA 1 (FASE 1-3)
```
┌─────────────────────────────────────────────┐
│ FASE 1: Estandarización (3/4 completada)    │
├─────────────────────────────────────────────┤
│ ✅ Análisis completado                      │
│ ⏳ Implementar ApiResponse<T>               │
│ ⏳ Refactorizar 12 controllers              │
│ ⏳ Testing validación                       │
│ Estimado: 10 horas                          │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ FASE 2: Tests Unitarios                     │
├─────────────────────────────────────────────┤
│ ⏳ Setup xUnit + Moq                        │
│ ⏳ Tests repositories                       │
│ ⏳ Tests services                           │
│ ⏳ Tests controllers                        │
│ Estimado: 12 horas                          │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ FASE 3: Endpoints Críticos                  │
├─────────────────────────────────────────────┤
│ ❌ UsuariosController (CRUD)               │
│ ❌ AprobacionesController (lógica)         │
│ ❌ TransicionesController (validación)     │
│ ❌ RefreshToken endpoint                   │
│ Estimado: 12 horas                          │
└─────────────────────────────────────────────┘
```

### SECUNDARIO - SEMANA 2 (FASE 4)
```
┌─────────────────────────────────────────────┐
│ FASE 4: Funcionalidades Avanzadas          │
├─────────────────────────────────────────────┤
│ ❌ Búsqueda full-text                      │
│ ❌ Reportes analíticos                     │
│ ❌ Paginación                              │
│ ❌ Swagger documentation                   │
│ Estimado: 15+ horas                         │
└─────────────────────────────────────────────┘
```

---

## 📋 CHECKLIST DE IMPLEMENTACIÓN

```
FASE 1 - Estandarización
══════════════════════════════════════════════════════════
[ ] Crear ApiResponse.cs
[ ] Actualizar BaseApiController.cs
[ ] Refactorizar AuthController.cs
[ ] Refactorizar TicketsController.cs
[ ] Refactorizar AdminController.cs
[ ] Refactorizar DepartamentosController.cs
[ ] Refactorizar MotivosController.cs
[ ] Refactorizar GruposController.cs
[ ] Refactorizar ComentariosController.cs
[ ] Refactorizar AprobacionesController.cs
[ ] Refactorizar TransicionesController.cs
[ ] Refactorizar ReferencesController.cs
[ ] Compilar sin errores
[ ] Ejecutar test suite (100% PASS)
[ ] Code review
[ ] Merge a main

FASE 2 - Tests
══════════════════════════════════════════════════════════
[ ] Setup xUnit
[ ] Setup Moq
[ ] Tests repositories
[ ] Tests services
[ ] Tests controllers
[ ] Cobertura >= 80%
[ ] Merge a main

FASE 3 - Endpoints
══════════════════════════════════════════════════════════
[ ] UsuariosController (CRUD)
[ ] AprobacionesController (lógica)
[ ] TransicionesController (validación)
[ ] RefreshToken endpoint
[ ] Tests para nuevos endpoints
[ ] Merge a main

FASE 4 - Avanzado
══════════════════════════════════════════════════════════
[ ] Búsqueda
[ ] Reportes
[ ] Paginación
[ ] Swagger
[ ] Merge a main
```

---

## 🔗 RELACIONES ENTRE CONTROLLERS

```
AuthController
    ├── Usa: UsuariosController (para validar usuario)
    └── Genera: JWT token

TicketsController
    ├── Usa: DepartamentosController (referencias)
    ├── Usa: MotivosController (referencias)
    ├── Usa: GruposController (referencias)
    ├── Usa: ComentariosController (comentarios)
    ├── Usa: TransicionesController (historial)
    └── Usa: AprobacionesController (si requiere aprobación)

AdminController
    ├── Gestiona: Usuarios
    ├── Gestiona: Roles
    ├── Gestiona: Permisos
    ├── Gestiona: Empresas
    ├── Gestiona: Sucursales
    ├── Gestiona: Perfiles
    └── Gestiona: Sistemas

ReferencesController
    ├── Lee de: Estados
    ├── Lee de: Prioridades
    ├── Lee de: Motivos
    ├── Lee de: Departamentos
    └── Lee de: Sucursales
```

---

## 💾 DEPENDENCIAS DE BASE DE DATOS

```
Usuario (core)
    ├── tkt_usuario (tabla)
    ├── tkt_usuario_rol (mapeo a roles)
    └── tkt_usuario_empresa_sucursal_perfil_sistema

Ticket (entidad principal)
    ├── tkt (tabla)
    ├── tkt_comentario (comentarios)
    ├── tkt_aprobacion (aprobaciones)
    ├── tkt_transicion (historial de cambios)
    ├── tkt_suscriptor (watchers)
    └── tkt_estado (referencia)

Seguridad
    ├── tkt_rol (roles)
    ├── tkt_permiso (permisos)
    ├── tkt_rol_permiso (mapeo)
    ├── tkt_transicion_regla (qué transiciones son permitidas)
    └── tkt_usuario_rol (usuario-rol)

Administración
    ├── empresa
    ├── sucursal
    ├── departamento
    ├── perfil
    └── sistema
```

---

## 📊 ESTADÍSTICAS FINALES

| Métrica | Valor |
|---------|-------|
| **Total SPs** | 50 |
| **Implementados** | 31 |
| **Faltantes** | 19 |
| **Cobertura** | 62% |
| **Controllers** | 12 |
| **Endpoints** | ~42 |
| **Tablas DB** | 30 |
| **Funciones** | 3 |
| **FASE 1 estimada** | 10 horas |
| **FASE 2 estimada** | 12 horas |
| **FASE 3 estimada** | 12 horas |
| **FASE 4 estimada** | 15+ horas |
| **Total estimado** | 49+ horas |

---

**Generado:** 23 Enero 2026  
**Status:** LISTO PARA FASE 1 ✅
