# Informe de Estado del Sistema — TicketsAPI

> **Fecha:** Generado automáticamente a partir de ingeniería inversa del código fuente  
> **Proyecto:** TicketsAPI (Sistema de Gestión de Tickets)  
> **Repositorio:** https://github.com/ReichertK/TicketsAPI  
> **Licencia:** MIT

---

## Índice

1. [Mapeo de Arquitectura y Tecnologías](#1-mapeo-de-arquitectura-y-tecnologías)
2. [Análisis de Base de Datos y Modelos](#2-análisis-de-base-de-datos-y-modelos)
3. [Auditoría de Seguridad e Infraestructura](#3-auditoría-de-seguridad-e-infraestructura)
4. [Evaluación de Calidad de Código](#4-evaluación-de-calidad-de-código)
5. [Análisis de Brechas para SaaS](#5-análisis-de-brechas-para-saas)
6. [Conclusión Técnica](#6-conclusión-técnica)

---

## 1. Mapeo de Arquitectura y Tecnologías

### 1.1 Visión General de la Arquitectura

El sistema sigue una arquitectura **monolítica modular** con las siguientes capas:

```
┌──────────────────────────────────────────────────────────────┐
│                     FRONTEND (SPA)                           │
│   React 19 + TypeScript 5.9 + Vite 7 + TailwindCSS 4       │
│   Zustand (Estado) · React Query (Cache) · SignalR Client   │
├──────────────────────────────────────────────────────────────┤
│                    API Gateway / CORS                         │
│            Rate Limiting (AspNetCoreRateLimit)                │
├──────────────────────────────────────────────────────────────┤
│                  BACKEND (ASP.NET Core 6)                    │
│  ┌──────────┐  ┌──────────┐  ┌─────────────────────────┐    │
│  │Controllers│──│ Services │──│ Repositories (Dapper)   │    │
│  └──────────┘  └──────────┘  └─────────────────────────┘    │
│    Middleware Pipeline · JWT Auth · FluentValidation          │
│    SignalR Hub · AutoMapper · Serilog                         │
├──────────────────────────────────────────────────────────────┤
│               BASE DE DATOS (MySQL 5.5)                      │
│    36 tablas · InnoDB · utf8mb4_unicode_ci                   │
│    Stored Procedures · Triggers de auditoría                 │
└──────────────────────────────────────────────────────────────┘
```

### 1.2 Stack Tecnológico — Backend

| Categoría | Paquete | Versión | Propósito |
|-----------|---------|---------|-----------|
| Framework | ASP.NET Core | 6.0 (LTS) | Runtime y hosting |
| ORM / Data Access | Dapper | 2.1.1 | Micro-ORM SQL puro |
| ORM Helpers | Dapper.Contrib | 2.0.78 | CRUD genérico |
| Driver MySQL | MySqlConnector | 2.2.7 | ADO.NET async para MySQL |
| Hashing | BCrypt.Net-Next | 4.0.3 | Hash de contraseñas |
| Validación | FluentValidation.AspNetCore | 11.3.1 | Validación declarativa de DTOs |
| Auth JWT | Microsoft.AspNetCore.Authentication.JwtBearer | 6.0.21 | Bearer token middleware |
| JWT Tokens | System.IdentityModel.Tokens.Jwt | 7.1.2 | Generación/validación de JWT |
| Real-time | Microsoft.AspNetCore.SignalR | 1.1.0 | WebSockets bidireccionales |
| SignalR Protocol | SignalR.Protocols.MessagePack | 6.0.21 | Serialización binaria eficiente |
| Logging | Serilog | 3.1.1 | Structured logging |
| Logging Integration | Serilog.AspNetCore | 7.0.0 | Integración con pipeline ASP.NET |
| Logging Sink | Serilog.Sinks.File | 5.0.0 | Rotación diaria de archivos |
| Mapping | AutoMapper | 12.0.1 | Mapeo Entity↔DTO |
| API Docs | Swashbuckle.AspNetCore | 6.5.0 | Swagger UI + OpenAPI 3.0 |
| Export | CsvHelper | 30.0.0 | Exportación a CSV |
| Dynamic LINQ | System.Linq.Dynamic.Core | 1.7.1 | Queries dinámicas |
| Rate Limiting | AspNetCoreRateLimit | 5.0.0 | Throttling por IP |

**Target Framework:** `net6.0` con `<Nullable>enable</Nullable>` y `<ImplicitUsings>enable</ImplicitUsings>`

### 1.3 Stack Tecnológico — Frontend

| Categoría | Paquete | Versión | Propósito |
|-----------|---------|---------|-----------|
| UI Framework | React | 19.2.4 | Biblioteca de componentes |
| DOM | React-DOM | 19.2.4 | Renderizado web |
| Lenguaje | TypeScript | ~5.9.3 | Tipado estático |
| Bundler | Vite | 7.2.4 | Dev server + build |
| CSS | TailwindCSS | 4.1.18 | Utility-first CSS |
| Estado Global | Zustand | 4.4.7 | State management ligero |
| Data Fetching | @tanstack/react-query | 5.90.20 | Cache, revalidation, retries |
| HTTP | Axios | 1.13.4 | Cliente HTTP con interceptors |
| Routing | react-router-dom | 7.13.0 | SPA routing |
| Real-time | @microsoft/signalr | 10.0.0 | SignalR client |
| Gráficos | Recharts | 3.7.0 | Visualizaciones Dashboard |
| Iconos | lucide-react | 0.563.0 | Iconografía SVG |

### 1.4 Pipeline de Middleware (orden exacto en Program.cs)

```
Request entrante
    │
    ├─ 1. UseValidationExceptionHandler()     ← Captura errores de FluentValidation
    ├─ 2. UseRequestCorrelation()             ← Agrega X-Correlation-ID a cada request
    ├─ 3. UseMiddleware<ExceptionHandlingMiddleware>()  ← Manejo global de excepciones
    ├─ 4. UseCors("AllowFrontend")            ← CORS con orígenes permitidos
    ├─ 5. UseSwagger() / UseSwaggerUI()       ← Condicional (configurable)
    ├─ 6. UseIpRateLimiting()                 ← Throttling IP antes de auth
    ├─ 7. UseAuthentication()                 ← JWT Bearer validation
    ├─ 8. UseUserActiveValidation()           ← Verifica usuario no deshabilitado
    ├─ 9. UseAuthorization()                  ← RBAC claims-based
    │
    ├─ MapControllers()                       ← API REST endpoints
    ├─ MapHealthChecks("/health")             ← Healthcheck endpoint
    └─ MapHub<TicketHub>("/hubs/tickets")     ← SignalR WebSocket hub
```

### 1.5 Controladores API

| Controlador | Ruta Base | Responsabilidad |
|-------------|-----------|-----------------|
| AuthController | `/api/v1/Auth` | Login, logout, refresh token |
| TicketsController | `/api/v1/Tickets` | CRUD tickets, transiciones, historial, suscripciones, export CSV |
| AdminController | `/api/v1/Admin` | Operaciones administrativas |
| AprobacionesController | `/api/v1/Aprobaciones` | Workflow de aprobaciones |
| ComentariosController | `/api/v1/Comentarios` | Comentarios en tickets |
| DepartamentosController | `/api/v1/Departamentos` | Gestión de departamentos |
| GruposController | `/api/v1/Grupos` | Gestión de grupos |
| MotivosController | `/api/v1/Motivos` | Categorías/motivos de tickets |
| ReferencesController | `/api/v1/References` | Datos de referencia (catálogos) |
| StoredProceduresController | `/api/sp` | Ejecución directa de SPs permitidos |
| TransicionesController | `/api/v1/Transiciones` | Reglas de transición de estados |
| AuditLogsController | `/api/v1/AuditLogs` | Consulta y estadísticas de auditoría |
| BaseApiController | — | Clase base con helpers `Success()`, `Error()` |

### 1.6 Inyección de Dependencias

**Repositorios registrados (Singleton — 16):**

| Repositorio | Interfaz |
|-------------|----------|
| UsuarioRepository | IUsuarioRepository |
| TicketRepository | ITicketRepository |
| ReporteRepository | IReporteRepository |
| EstadoRepository | IEstadoRepository |
| PrioridadRepository | IPrioridadRepository |
| DepartamentoRepository | IDepartamentoRepository |
| PoliticaTransicionRepository | IPoliticaTransicionRepository |
| RolRepository | IRolRepository |
| PermisoRepository | IPermisoRepository |
| MotivoRepository | IMotivoRepository |
| AprobacionRepository | IBaseRepository\<Aprobacion> |
| TransicionRepository | IBaseRepository\<Transicion> |
| GrupoRepository | IBaseRepository\<Grupo> |
| ComentarioRepository | IComentarioRepository + IBaseRepository\<Comentario> |
| NotificacionLecturaRepository | INotificacionLecturaRepository |
| BaseRepository | Clase abstracta base |

**Servicios registrados (14):**

| Servicio | Lifetime | Interfaz |
|----------|----------|----------|
| AuthService | Singleton | IAuthService |
| TicketService | Singleton | ITicketService |
| EstadoService | Singleton | IEstadoService |
| PrioridadService | Singleton | IPrioridadService |
| DepartamentoService | Singleton | IDepartamentoService |
| UsuarioService | **Scoped** | IUsuarioService |
| NotificacionService | Singleton | INotificacionService |
| ExportService | Singleton | IExportService |
| ReporteService | Singleton | IReporteService |
| PasswordService | Singleton | IPasswordService |
| CacheService | Singleton | (Concreto) |
| ConfigAuditService | Singleton | IConfigAuditService |
| BruteForceProtectionService | Singleton | (Concreto) |
| SignalRNotificationProvider | Singleton | INotificationProvider |

> **Nota:** La mayoría de servicios están registrados como **Singleton**. Esto es viable porque Dapper crea una nueva `MySqlConnection` por operación (no mantiene estado en la conexión). `UsuarioService` es **Scoped** (probablemente por dependencias de HttpContext).

---

## 2. Análisis de Base de Datos y Modelos

### 2.1 Motor y Configuración

| Parámetro | Valor |
|-----------|-------|
| Motor | MySQL 5.5 |
| Base de Datos | `cdk_tkt_dev` |
| Host | localhost:3306 |
| Charset | `utf8mb4` (conexión + todas las tablas) |
| Collation | `utf8mb4_unicode_ci` |
| Motor de Storage | InnoDB (todas las tablas) |
| DefaultCommandTimeout | 15 segundos |
| SSL | Deshabilitado (`SslMode=None`) |

### 2.2 Inventario de Tablas (36 tablas)

#### Dominio Principal

| Tabla | Filas (aprox.) | Propósito |
|-------|---------------|-----------|
| `tkt` | 8 | Tickets principales |
| `usuario` | 19 | Usuarios del sistema |
| `estado` | 7 | Estados del ciclo de vida |
| `prioridad` | 4 | Niveles de prioridad (Baja, Media, Alta, Crítica) |
| `departamento` | 83 | Departamentos organizacionales |
| `motivo` | 60 | Categorías/motivos de tickets |
| `empresa` | 2 | Empresas (multi-empresa) |
| `sucursal` | 12 | Sucursales por empresa |

#### Relaciones de Tickets

| Tabla | Filas (aprox.) | Propósito |
|-------|---------------|-----------|
| `tkt_aprobacion` | 2 | Aprobaciones en workflow |
| `tkt_comentario` | 0 | Comentarios en tickets |
| `tkt_transicion` | 13 | Historial de transiciones de estado |
| `tkt_transicion_regla` | 15 | Reglas de la máquina de estados |
| `tkt_suscriptor` | 0 | Suscripciones a tickets |
| `tkt_notificacion_lectura` | 200 | Control de notificaciones leídas |
| `tkt_search` | 0 | Índice de búsqueda full-text |

#### RBAC (Control de Acceso Basado en Roles)

| Tabla | Filas (aprox.) | Propósito |
|-------|---------------|-----------|
| `rol` | 6 | Roles del sistema |
| `permiso` | 17 | Permisos granulares |
| `rol_permiso` | 46 | Asignación rol↔permiso |
| `tkt_rol` | 5 | Roles específicos de tickets |
| `tkt_permiso` | 18 | Permisos específicos de tickets |
| `tkt_rol_permiso` | 47 | Asignación tkt_rol↔tkt_permiso |
| `tkt_usuario_rol` | 203 | Asignación usuario↔tkt_rol |
| `usuario_rol` | 15 | Asignación usuario↔rol general |
| `usuario_tipo` | 2 | Tipos de usuario |
| `perfil` | 12 | Perfiles de acceso |
| `perfil_accion_sistema` | 27 | Acciones por perfil |

#### Auditoría y Logs

| Tabla | Filas (aprox.) | Propósito |
|-------|---------------|-----------|
| `audit_log` | **1,545,056** | Log de auditoría (tabla más grande) |
| `audit_config` | 3 | Configuración del motor de auditoría |
| `error_log` | 0 | Log de errores |
| `failed_login_attempts` | 0 | Intentos de login fallidos |

#### Legacy / Soporte

| Tabla | Filas (aprox.) | Propósito |
|-------|---------------|-----------|
| `accion` | 4 | Acciones del sistema |
| `grupo` | 7 | Grupos de usuarios |
| `sesiones` | 0 | Sesiones activas |
| `sistema` | 12 | Configuración de sistemas |
| `usuario_empresa_sucursal_perfil_sistema` | 6 | Tabla pivote multi-dimensional |
| `notificaciones` | 0 | Notificaciones (legacy) |

### 2.3 Índices de Auditoría (audit_log — 1.5M filas)

| Índice | Columnas | Tipo |
|--------|----------|------|
| PRIMARY | `id_auditoria` | BTREE |
| idx_auditoria_tabla_fecha | `tabla`, `fecha` | BTREE |
| idx_auditoria_usuario_fecha | `usuario_id`, `fecha` | BTREE |
| idx_auditoria_id_registro | `tabla`, `id_registro` | BTREE |
| idx_auditoria_accion | `accion`, `fecha` | BTREE |

> Los 4 índices compuestos cubren los patrones de consulta principales del frontend: filtrado por tabla+fecha, usuario+fecha, registro específico y acción+fecha.

### 2.4 Entidades del Dominio (C#)

| Entidad | Campos Clave | Navegación |
|---------|-------------|------------|
| `Usuario` | Id_Usuario, Nombre, Apellido, Email, Usuario_Correo, Contraseña, Id_Rol, Id_Departamento, Activo, RefreshTokenHash, RefreshTokenExpires | Rol, Departamento |
| `Ticket` | Id_Tkt, Id_Estado, Id_Usuario, Id_Usuario_Asignado, Id_Empresa, Id_Prioridad, Contenido, Id_Departamento, Date_Creado, Date_Cierre | Estado, Prioridad, Departamento, UsuarioCreador, UsuarioAsignado, Historial, Comentarios |
| `Estado` | Id_Estado, Nombre_Estado, Color, Orden, Activo | Tickets |
| `Prioridad` | Id_Prioridad, Nombre_Prioridad, Valor (1-4), Color, Activo | Tickets |
| `Departamento` | Id_Departamento, Nombre, Activo | Usuarios, Tickets |
| `Rol` | Id_Rol, Nombre_Rol, Activo | RolPermisos, Usuarios |
| `Permiso` | Id_Permiso, Codigo, Descripcion, Modulo, Activo | RolPermisos |
| `RolPermiso` | Id_RolPermiso, Id_Rol, Id_Permiso | Rol, Permiso |
| `PoliticaTransicion` | Id_Estado_Origen, Id_Estado_Destino, Id_Rol, Requiere_Aprobacion, Permiso_Requerido | EstadoOrigen, EstadoDestino, Rol |
| `HistorialTicket` | Id_Historial, Id_Ticket, Id_Usuario, Accion, Campo_Modificado, Valor_Anterior, Valor_Nuevo, Ip_Address | Ticket, Usuario |
| `Comentario` | Id_Comentario, Id_Ticket, Id_Usuario, Contenido, Privado | Ticket, Usuario |
| `Motivo` | Id_Motivo, Nombre, Categoria, Activo | — |
| `Aprobacion` | Id_Aprobacion, Id_Tkt, Id_Usuario_Solicitante, Id_Usuario_Aprobador, Estado | — |
| `Transicion` | Id_Transicion, Id_Tkt, Id_Estado_Anterior, Id_Estado_Nuevo, Id_Usuario, Comentario | — |

### 2.5 DTOs y Contratos API (C# → JSON)

| DTO | Campos | Uso |
|-----|--------|-----|
| `LoginRequest` | Usuario, Contraseña | POST /Auth/login |
| `LoginResponse` | Id_Usuario, Nombre, Email, Token, RefreshToken, Rol, Permisos[] | Respuesta de login |
| `TicketDTO` | Id_Tkt, Contenido, Estado, Prioridad, Departamento, Creador, Asignado, Fechas | Vista de ticket |
| `CreateUpdateTicketDTO` | Contenido, Id_Prioridad, Id_Departamento, Id_Usuario_Asignado, Id_Motivo | Crear/editar ticket |
| `TicketFiltroDTO` | Busqueda, TipoBusqueda, Estados[], Prioridades[], Fechas, Pagina, TamañoPagina | Filtros de listado |
| `TransicionHistorialDTO` | 13 campos incl. estados origen/destino con nombre, usuario con nombre, fecha, comentario | Historial de transiciones |
| `AuditLogDTO` | id, tabla, accion, id_registro, datos_anteriores, datos_nuevos, usuario_id, usuario_nombre, fecha, ip | Registros de auditoría |
| `PaginatedResponse<T>` | Datos[], TotalRegistros, TotalPaginas, PaginaActual, TamañoPagina, TieneAnterior, TieneSiguiente | Wrapper paginado genérico |
| `ApiResponse<T>` | Exitoso, Mensaje, Datos, Errores[] | Wrapper de respuesta estándar |
| `DashboardDTO` | Estadísticas agregadas de tickets | Dashboard |

### 2.6 Sincronización DTO ↔ TypeScript

| C# DTO | TypeScript Interface | Estado |
|---------|---------------------|--------|
| LoginRequest | LoginRequest | ✅ Sincronizado |
| LoginResponse | LoginResponse | ✅ Sincronizado |
| TicketDTO | Ticket | ✅ Sincronizado |
| TicketFiltroDTO | TicketFilters | ✅ Sincronizado |
| TransicionHistorialDTO | TransicionHistorialDTO | ✅ Sincronizado |
| AuditLogDTO | AuditLogDTO | ✅ Sincronizado |
| PaginatedResponse<T> | PaginatedResponse<T> | ✅ Sincronizado |
| ApiResponse<T> | ApiResponse<T> | ✅ Sincronizado |

> **Convención de nombrado JSON:** Se usa `CamelCase` en las respuestas via `JsonNamingPolicy.CamelCase` configurado globalmente en Program.cs. Frontend espera camelCase.

---

## 3. Auditoría de Seguridad e Infraestructura

### 3.1 Autenticación JWT

| Aspecto | Implementación | Evaluación |
|---------|---------------|------------|
| Algoritmo | HMAC-SHA256 (SymmetricSecurityKey) | ⚠️ Aceptable para monolito, considerar RSA para microservicios |
| Longitud de clave | 32 caracteres (256 bits) | ✅ Cumple mínimo |
| Expiración de token | 60 minutos | ✅ Razonable |
| Refresh Token | 7 días, almacenado como hash en BD | ✅ Buena práctica |
| Validación de issuer | Sí (`ValidateIssuer = true`) | ✅ |
| Validación de audience | Sí (`ValidateAudience = true`) | ✅ |
| Clock skew | 5 minutos | ✅ Estándar |
| Token en SignalR | Via query string `access_token` | ✅ Patrón estándar para WebSockets |
| Verificación de clave default | Lanza excepción si SecretKey es default o vacía | ✅ Seguro |

### 3.2 Protección contra Fuerza Bruta

Implementado en `BruteForceProtectionService`:

| Parámetro | Valor |
|-----------|-------|
| Máximo intentos fallidos | 5 |
| Tiempo de bloqueo | 15 minutos |
| Almacenamiento | Columnas `intentos_fallidos`, `bloqueado_hasta` en tabla `usuario` |
| Desbloqueo | Automático al expirar el periodo |
| Tracking | Por usuario (no por IP) |

> **Observación:** El tracking es por usuario, no por IP. Un atacante podría probar un password contra múltiples usuarios sin activar el bloqueo. Se recomienda agregar tracking por IP complementario.

### 3.3 CORS

```json
{
  "AllowedOrigins": [
    "http://localhost:3000",
    "http://localhost:5173",
    "http://localhost:5174",
    "http://localhost:5175",
    "https://localhost:3000"
  ],
  "AllowedMethods": ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
  "AllowCredentials": true
}
```

| Aspecto | Evaluación |
|---------|------------|
| Orígenes específicos | ✅ No usa wildcard (`*`) |
| Credenciales permitidas | ✅ Necesario para JWT en cookies/headers |
| Solo localhost | ⚠️ Requiere configuración para producción |
| Métodos explícitos | ✅ Lista definida |
| Headers | ⚠️ Usa `*` para headers permitidos |

### 3.4 Rate Limiting

```json
{
  "EnableEndpointRateLimiting": true,
  "HttpStatusCode": 429,
  "GeneralRules": [
    { "Endpoint": "*:/api/sp/*", "Period": "1m", "Limit": 60 }
  ],
  "IpRules (localhost)": [
    { "Endpoint": "*:/api/sp/*", "Period": "1m", "Limit": 600 }
  ]
}
```

| Aspecto | Evaluación |
|---------|------------|
| Scope | Solo endpoints `/api/sp/*` (Stored Procedures) | 
| Rate general | 60 req/min por IP | ✅ Razonable |
| Rate localhost | 600 req/min | ✅ Desarrollo |
| Rate en Auth/Login | ⚠️ **No configurado** — El endpoint de login no tiene rate limit propio |
| Rate en API REST | ⚠️ **No configurado** — Los endpoints `/api/v1/*` no tienen rate limit |

### 3.5 Sanitización y Validación de Entrada

**FluentValidation (5 validators declarativos):**

| Validator | DTO Target | Reglas Clave |
|-----------|-----------|--------------|
| LoginRequestValidator | LoginRequest | Length(3,100), MinLength(6) |
| RefreshTokenRequestValidator | RefreshTokenRequest | NotEmpty, MinLength(50) |
| CreateUpdateUsuarioDTOValidator | CreateUpdateUsuarioDTO | Regex para nombre (solo letras+acentos), EmailAddress, Regex para usuario (alfanumérico) |
| ChangePasswordDTOValidator | ChangePasswordDTO | MinLength(6), NotEqual a la actual |
| CreateUpdateTicketDTOValidator | CreateUpdateTicketDTO | Length(10,10000), **IsSafeFromSqlInjection()** |
| TicketFiltroDTOValidator | TicketFiltroDTO | MaxLength(500), TipoBusqueda in ["contiene","exacta","comienza","termina"], **IsSafeFromSqlInjection()** |

**SQL Injection — Defensa en profundidad:**
1. **Dapper parametrizado**: Todas las queries usan parámetros `@param` (no concatenación)
2. **Stored Procedures**: Operaciones críticas via SPs (`sp_login`, `sp_crear_ticket`, `sp_transicionar_estado`, etc.)
3. **Whitelist de SPs**: `AllowedStoredProcedures` en appsettings limita qué SPs se pueden ejecutar desde el endpoint genérico
4. **Validator manual**: `IsSafeFromSqlInjection()` detecta patrones como `';`, `--`, `/*`, `*/`, `xp_`, `DROP`, `DELETE` en contenido libre

**XSS:**
- JSON serializer usa `JavaScriptEncoder.Create(UnicodeRanges.All)` — permite Unicode sin escapar, lo cual es correcto para acentos/emojis pero **no sanitiza HTML**
- ⚠️ **No se detectó un middleware de sanitización HTML** en el pipeline. La protección XSS depende del frontend (React auto-escapa por defecto)

**Hashing de Contraseñas:**
- BCrypt.Net-Next 4.0.3 — ✅ Algoritmo seguro con salt automático

### 3.6 Manejo de Errores y Resiliencia

**ExceptionHandlingMiddleware:**

| Excepción | HTTP Status | Comportamiento |
|-----------|-------------|---------------|
| UnauthorizedAccessException | 401 | Mensaje "No autorizado" |
| KeyNotFoundException | 404 | Recurso no encontrado |
| ArgumentException | 400 | Parámetro inválido |
| MySQL Error 1213 (Deadlock) | 503 | Código "TRANSIENT_ERROR", retry sugerido |
| MySQL Error 1205 (Lock Timeout) | 503 | Código "TRANSIENT_ERROR", retry sugerido |
| Cualquier otra | 500 | Detalles solo en Development |

**BaseRepository — Retry Logic:**

| Parámetro | Valor |
|-----------|-------|
| Max reintentos | 3 |
| Backoff | Exponencial: 200ms → 400ms → 800ms |
| Errores transitorios MySQL | 1205 (Lock wait timeout), 1213 (Deadlock), 1040 (Too many connections), 2006 (Server gone), 2013 (Lost connection) |

**Logging:**
- Serilog con sink a archivo rotativo diario
- Retención: 30 archivos (configurable)
- Template: `{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj}{NewLine}{Exception}`
- Request Correlation ID vía middleware custom

### 3.7 Health Checks

| Check | Nombre | Propósito |
|-------|--------|-----------|
| DatabaseHealthCheck | "Database" | Verifica conectividad MySQL |
| DashboardWarmupHealthCheck | "DashboardWarmup" | Precaldeo de InnoDB buffer pool |
| Endpoint | `/health` | Registro de ambos checks |

### 3.8 Comunicación en Tiempo Real (SignalR)

| Aspecto | Implementación |
|---------|---------------|
| Hub URL | `/hubs/tickets` |
| Protocolo | MessagePack (binario, más eficiente que JSON) |
| Autenticación | JWT via query string (`access_token`) |
| Grupos | Suscripción por ticket (`ticket-{id}`) |
| Eventos | NuevoTicket, ActualizacionTicket, TransicionEstado, NuevoComentario |
| Provider Pattern | `INotificationProvider` → `SignalRNotificationProvider` |

---

## 4. Evaluación de Calidad de Código

### 4.1 Patrones de Diseño Identificados

| Patrón | Implementación | Evaluación |
|--------|---------------|------------|
| **Repository Pattern** | 16 repositorios con interfaz + implementación, heredan de `BaseRepository` | ✅ Separación limpia de acceso a datos |
| **Service Layer** | 14 servicios encapsulan lógica de negocio entre Controllers y Repositories | ✅ Responsabilidad única |
| **Provider Pattern** | `INotificationProvider` → `SignalRNotificationProvider` | ✅ Desacoplamiento, facilita testing y cambio de implementación |
| **DTO Pattern** | Entidades separadas de DTOs, no se exponen entidades al API | ✅ Contrato de API limpio |
| **Generic Repository** | `IBaseRepository<T>` con CRUD genérico + especializaciones | ✅ DRY |
| **Middleware Pipeline** | 9 middlewares encadenados en orden correcto | ✅ Separation of Concerns |
| **State Machine** | `PoliticaTransicion` define transiciones permitidas por rol | ✅ Workflow gobernable |
| **Observer Pattern** | SignalR notifica a suscriptores de tickets | ✅ Desacoplamiento UI↔Backend |
| **Retry Pattern** | `ExecuteWithRetryAsync` con backoff exponencial | ✅ Resiliencia en MySQL 5.5 |
| **Cache Warmup** | `CacheService.WarmupCacheAsync()` al inicio | ✅ Reduce latencia primer request |

### 4.2 Componentes Frontend

#### Páginas (13)

| Página | Ruta | Rol Requerido | Características |
|--------|------|---------------|-----------------|
| LoginPage | `/login` | Público | Formulario JWT |
| DashboardPage | `/` | Administrador | Gráficos Recharts, KPIs |
| TicketsPage | `/tickets` | Autenticado | Listado "Mis Tickets" con filtros |
| CreateTicketPage | `/tickets/nuevo` | Autenticado | Formulario de creación |
| TicketDetailPage | `/tickets/:id` | Autenticado | Detalle + timeline + historial + comentarios |
| EditTicketPage | `/tickets/:id/editar` | Administrador | Edición de ticket |
| ColaTrabajoPage | `/cola` | Autenticado | Cola de trabajo por técnico |
| TodosTicketsPage | `/todos-tickets` | Autenticado | Vista global de tickets |
| UsuariosPage | `/usuarios` | Administrador | CRUD usuarios |
| DepartamentosPage | `/departamentos` | Administrador | Gestión de departamentos |
| ConfiguracionPage | `/configuracion` | Administrador | Ajustes del sistema |
| AuditLogsPage | `/admin/logs` | Administrador | Visor de auditoría con DiffTable |
| SeguridadTab | (Sub-tab) | Administrador | Roles y permisos |

#### Componentes Reutilizables (15)

| Componente | Propósito |
|------------|-----------|
| Layout | Shell con sidebar, header, NotificationBadge |
| ProtectedRoute | Guard de ruta con verificación JWT + roles |
| TicketFilters | Dropdown multiselect para estados/prioridades/motivos |
| TicketHistory | Historial de transiciones con lazy loading |
| DiffTable | Comparación campo-a-campo (antes/después) con colores por acción |
| StatusBadge | Badge coloreado por estado |
| PriorityBadge | Badge coloreado por prioridad |
| Pagination | Paginación genérica |
| SortableHeader | Header de tabla con indicador de orden |
| NotificationBadge | Indicador de notificaciones no leídas |
| UserAvatar | Avatar de usuario con iniciales |
| ConfirmActionModal | Modal de confirmación reutilizable |
| ErrorAlert | Alerta de error reutilizable |
| EmptyState | Estado vacío con ilustración |
| ToastContainer | Sistema de notificaciones toast (Zustand) |

#### Stores (Zustand)

| Store | Responsabilidad | Persistencia |
|-------|----------------|-------------|
| `authStore` | Token JWT, usuario, permisos, login/logout | `zustand/persist` → localStorage |
| `toastStore` | Cola de notificaciones toast, auto-dismiss | En memoria |

#### Hooks Personalizados

| Hook | Propósito |
|------|-----------|
| `usePermission(code)` | Verifica un permiso contra el usuario autenticado (Admin bypass) |
| `usePermissions()` | Retorna objeto con `hasPermission()` y `hasAnyPermission()` |
| `useSignalR()` | Conexión SignalR con reconexión automática, invalidación de React Query |

### 4.3 Stored Procedures (Whitelist)

Los siguientes SPs están autorizados para ejecución desde el endpoint genérico `/api/sp`:

| SP | Propósito |
|----|-----------|
| `sp_login` | Autenticación de usuario |
| `sp_crear_ticket` | Creación de ticket con validaciones |
| `sp_transicionar_estado` | Motor de máquina de estados |
| `sp_cerrar_ticket` | Cierre con validaciones de negocio |
| `sp_asignar_ticket` | Asignación con registro de auditoría |
| `sp_crear_comentario` | Comentarios con notificación |
| `sp_dashboard_tickets` | Agregaciones para dashboard |
| `sp_get_tickets_filtrados` | Búsqueda avanzada con filtros |

### 4.4 Métricas de Complejidad

| Métrica | Valor |
|---------|-------|
| Tablas en BD | 36 |
| Entidades C# | 14 |
| DTOs C# | ~30 DTOs en 744 líneas |
| Interfaces de Repositorio | 12 |
| Implementaciones de Repositorio | 16 |
| Interfaces de Servicio | 9 (en IServices.cs) + 5 en archivos separados |
| Implementaciones de Servicio | 14 |
| Controladores | 13 |
| Validators | 5 (FluentValidation) |
| Páginas Frontend | 13 |
| Componentes Frontend | 15 |
| Hooks Custom | 2 |
| Stores Zustand | 2 |
| Endpoints API (constantes en api.ts) | 35+ |

---

## 5. Análisis de Brechas para SaaS

### 5.1 Evaluación de Madurez SaaS

| Dimensión | Estado Actual | Brecha | Prioridad |
|-----------|--------------|--------|-----------|
| **Multi-tenancy** | Tablas `empresa` (2) y `sucursal` (12) existen pero no hay aislamiento por tenant en queries | Se necesita filtro automático por tenant en middleware o repositorios | 🔴 Crítica |
| **Suscripciones / Planes** | No implementado | Requiere modelo de suscripción, límites por plan, billing integration | 🔴 Crítica |
| **Escalabilidad horizontal** | Monolito stateful (MemoryCache, SignalR in-memory) | Redis para cache distribuido + SignalR backplane | 🔴 Crítica |
| **CI/CD** | No se detectan archivos de pipeline (.github/workflows, Dockerfile, docker-compose) | Se necesita pipeline de build/test/deploy | 🔴 Crítica |
| **Containerización** | No hay Dockerfile ni docker-compose | Requiere Docker + orquestador | 🟡 Alta |
| **Migraciones de BD** | No se detecta sistema de migraciones (no hay FluentMigrator, DbUp, ni EF Migrations) | Scripts SQL manuales (`cdk_tkt.sql`) — riesgo en deploy | 🟡 Alta |
| **Environments** | Solo `appsettings.json` + `appsettings.Development.json` | Necesita appsettings.Staging.json, appsettings.Production.json con secrets vault | 🟡 Alta |
| **Secrets Management** | SecretKey hardcodeada en appsettings.json, password de BD en texto plano | Migrar a Azure Key Vault, AWS Secrets Manager, o variables de entorno | 🔴 Crítica |
| **Monitoreo / APM** | Serilog a archivo + Health checks básicos | Se necesita APM (Application Insights, Datadog, New Relic) + alerting | 🟡 Alta |
| **Tests automatizados** | 1 archivo `integration_tests.py` (Python), 1 `IntegrationTests.ps1` | No hay unit tests C#, no hay tests frontend, no hay coverage | 🔴 Crítica |
| **API Versioning** | Prefijo manual `/api/v1/` en rutas | Se recomienda Microsoft.AspNetCore.Mvc.Versioning para evolución formal | 🟢 Media |
| **Documentación API** | Swagger/OpenAPI habilitado con auth JWT | ✅ Aceptable para desarrollo |
| **Internacionalización** | Mensajes de error hardcodeados en español | Se necesita framework i18n si se planea mercado multi-idioma | 🟢 Media |
| **HTTPS** | Deshabilitado en desarrollo (`UseHttpsRedirection` comentado) | Obligatorio HTTPS en producción con certificado TLS | 🟡 Alta |
| **Email / Notificaciones** | Solo SignalR (in-app). No se detecta integración SMTP | Se necesita canal email/SMS para notificaciones fuera de la app | 🟡 Alta |
| **Audit Trail inmutable** | `audit_log` con 1.5M registros, INSERTs via triggers | ✅ Buena base, pero no hay protección contra DELETE en audit_log mismo |
| **Backup / DR** | No se detecta política de backup | Se necesita estrategia de backup automatizado + restore testado | 🔴 Crítica |
| **Rate Limiting completo** | Solo en `/api/sp/*` | Extender a `/api/v1/Auth/login` (anti brute-force por IP) y endpoints públicos | 🟡 Alta |

### 5.2 Deuda Técnica Identificada

| Deuda | Descripción | Impacto |
|-------|-------------|---------|
| **MySQL 5.5** | EOL desde diciembre 2018. Sin CTEs, window functions, JSON nativo, fulltext InnoDB | Limita funcionalidades y tiene vulnerabilidades conocidas |
| **Singleton + Dapper** | La mayoría de servicios y repos son Singleton. Funciona porque Dapper crea conexiones por operación, pero viola el principio de menor sorpresa | Riesgo si algún repo acumula estado |
| **`net6.0` approaching EOL** | .NET 6 LTS termina soporte en noviembre 2024 (ya vencido) | Actualizar a .NET 8 LTS |
| **Doble sistema RBAC** | Existen `rol`/`permiso`/`rol_permiso` Y `tkt_rol`/`tkt_permiso`/`tkt_rol_permiso` | Complejidad innecesaria, posible conflicto |
| **Tablas vacías** | `tkt_comentario`, `tkt_suscriptor`, `tkt_search`, `sesiones`, `error_log`, `notificaciones` vacías | Funcionalidad parcialmente implementada o legacy |
| **AutoMapper registrado pero sin profiles detectados** | Se usa `AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies())` | Si no hay profiles, el mapeo podría ser manual vía DTOs |

### 5.3 Fortalezas Actuales

| Fortaleza | Detalle |
|-----------|---------|
| ✅ Arquitectura en capas clara | Controller → Service → Repository bien separados |
| ✅ RBAC granular | 17 permisos, 6 roles, máquina de estados por rol |
| ✅ Auditoría robusta | 1.5M registros, 4 índices compuestos, datos antes/después en JSON |
| ✅ Resiliencia MySQL | Retry con backoff exponencial para errores transitorios |
| ✅ Real-time funcional | SignalR con MessagePack, grupos por ticket |
| ✅ Validación declarativa | FluentValidation con protección SQL injection |
| ✅ Frontend moderno | React 19 + TypeScript + React Query + Zustand |
| ✅ UX de auditoría | DiffTable con comparación visual campo-a-campo |
| ✅ Cache warming | Pre-carga de catálogos y dashboard al inicio |
| ✅ Logging estructurado | Serilog con correlation ID y rotación diaria |

---

## 6. Conclusión Técnica

### 6.1 Estado de Producción

**Veredicto: 🟡 PRE-PRODUCCIÓN — Funcional para piloto interno, NO listo para producción externa.**

El sistema demuestra una arquitectura bien estructurada con patrones sólidos (Repository, Service Layer, State Machine, Provider) y cobertura funcional completa para el dominio de gestión de tickets. La implementación de RBAC, auditoría, y comunicación en tiempo real es madura.

### 6.2 Bloqueantes para Producción

| # | Bloqueante | Esfuerzo Estimado |
|---|-----------|-------------------|
| 1 | **Secrets fuera de código fuente** (JWT key, DB password en appsettings.json) | 1-2 días |
| 2 | **HTTPS obligatorio** con certificado TLS | 1 día |
| 3 | **Rate limiting en login** y endpoints REST | 1 día |
| 4 | **Actualizar .NET 6 → .NET 8** (LTS vigente) | 2-3 días |
| 5 | **Unit tests mínimos** para servicios críticos (Auth, Tickets, Transiciones) | 3-5 días |
| 6 | **Migración MySQL 5.5 → 8.0** mínimo | 2-3 días |
| 7 | **Pipeline CI/CD** básico (build + test + deploy) | 2-3 días |
| 8 | **Estrategia de backup** para BD | 1 día |

### 6.3 Roadmap Sugerido

```
Fase 1 — Hardening (1-2 semanas)
├── Secrets management (vault o env vars)
├── HTTPS + certificado
├── Rate limiting completo
├── Protección brute-force por IP
└── Unit tests para flujos críticos

Fase 2 — Modernización (2-3 semanas)
├── .NET 6 → .NET 8 LTS
├── MySQL 5.5 → 8.0+
├── Docker + docker-compose
├── CI/CD pipeline (GitHub Actions)
└── APM + alerting

Fase 3 — SaaS Readiness (4-6 semanas)
├── Multi-tenancy (filtro por organización)
├── Redis (cache distribuido + SignalR backplane)
├── Sistema de emails (SMTP/SendGrid)
├── Migraciones de BD automatizadas
└── Environment configs (staging/production)
```

### 6.4 Resumen Ejecutivo

| Dimensión | Calificación |
|-----------|-------------|
| Arquitectura | ⭐⭐⭐⭐ (4/5) — Patrones sólidos, capas bien definidas |
| Seguridad | ⭐⭐⭐ (3/5) — JWT + BCrypt + RBAC correctos, falta hardening |
| Calidad de Código | ⭐⭐⭐⭐ (4/5) — Validación, retry, logging, separation of concerns |
| Base de Datos | ⭐⭐⭐ (3/5) — Modelo completo, pero MySQL 5.5 EOL y doble RBAC |
| Frontend | ⭐⭐⭐⭐ (4/5) — Stack moderno, componentes reutilizables, tipado estricto |
| DevOps | ⭐⭐ (2/5) — Sin CI/CD, sin Docker, sin migraciones |
| Testing | ⭐ (1/5) — Sin tests unitarios, solo scripts de integración manuales |
| Documentación | ⭐⭐⭐⭐ (4/5) — Swagger, XMLdoc, múltiples MDs de análisis |

**Score Global: 3.1 / 5 — Sistema funcional con buena base arquitectónica que requiere hardening de seguridad, modernización de infraestructura y cobertura de tests antes de producción.**

---

*Informe generado mediante ingeniería inversa del código fuente. Todos los datos provienen exclusivamente de los archivos del repositorio.*
