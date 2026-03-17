# Arquitectura Técnica

## Vista General

Sistema full-stack de gestión de tickets con control de acceso basado en roles (RBAC), notificaciones en tiempo real y motor de flujo de estados. Diseñado para uso organizacional interno.

```
┌─────────────────────┐     ┌──────────────────────────┐     ┌──────────────┐
│  React 19 SPA       │────▶│  ASP.NET Core 6 API      │────▶│  MySQL 5.5   │
│  Vite · Zustand     │◀────│  Dapper · SignalR         │◀────│  utf8mb4     │
│  React Query · Axios│     │  JWT · BCrypt             │     │              │
└─────────────────────┘     └──────────────────────────┘     └──────────────┘
         ▲                           │
         │         WebSocket         │
         └───────── SignalR ─────────┘
```

---

## Backend

### Stack

| Componente        | Tecnología                  | Versión  |
|-------------------|-----------------------------|----------|
| Framework         | ASP.NET Core                | 6.0      |
| ORM               | Dapper + Dapper.Contrib      | 2.1.1    |
| Driver BD         | MySqlConnector              | 2.2.7    |
| Autenticación     | JWT Bearer                  | 6.0.21   |
| Hashing           | BCrypt.Net-Next             | 4.0.3    |
| Tiempo real       | SignalR + MessagePack       | 6.0.21   |
| Validación        | FluentValidation            | 11.11.0  |
| Mapeo             | AutoMapper                  | 12.0.1   |
| Logging           | Serilog (Console + File)    | 3.1.1    |
| Rate Limiting     | AspNetCoreRateLimit         | 5.0.0    |
| Exportación       | MiniExcel + CsvHelper       | 1.42.0 / 30.0.0 |
| Docs API          | Swashbuckle                 | 6.5.0    |

### Patrón de arquitectura

Repository → Service → Controller, inyección de dependencias.

```
Controller (frontera HTTP)
    └── Service (lógica de negocio, validación de permisos)
         └── Repository (SQL directo con Dapper, compatible MySQL 5.5)
```

Repositories registrados como **Singleton** (stateless, conexión por query vía pooling de MySqlConnector). Services son Singleton excepto `UsuarioService` (Scoped).

### Autenticación y seguridad

**Flujo JWT:**
1. `POST /api/v1/Auth/login` — valida credenciales, retorna access token + refresh token
2. Access token: corta duración (60 min), contiene `sub` (userId), `role`, claims personalizados
3. Refresh token: hasheado (SHA-256) en BD, rotado en cada uso, expira en 7 días
4. Validación: issuer, audience, lifetime, signing key (HS256)

**Manejo de contraseñas:**
- Acepta BCrypt, MD5, SHA256 y texto plano (migración legacy)
- Auto-upgrade a BCrypt en login exitoso
- BCrypt cost factor para todas las contraseñas nuevas

**Protección contra fuerza bruta:**
- Bloqueo por cuenta, registrado en MySQL
- Retorna intentos restantes y expiración del bloqueo
- Registra intentos fallidos incluso para usuarios inexistentes (previene enumeración)

**Rate limiting:**
- Basado en IP vía AspNetCoreRateLimit
- Configurable en `appsettings.json` bajo `IpRateLimiting`

### Máquina de estados

El ciclo de vida del ticket está gobernado por la tabla `tkt_transicion_regla`:

| Columna                | Propósito                                   |
|------------------------|---------------------------------------------|
| `id_estado_origen`     | Estado origen                               |
| `id_estado_destino`    | Estado destino                              |
| `id_rol`               | Rol que puede ejecutar la transición        |
| `requiere_propietario` | Debe ser propietario del ticket             |
| `requiere_aprobacion`  | Lanza flujo de aprobación                   |
| `permiso_requerido`    | Código de permiso granular a verificar      |

Las transiciones se validan en servidor antes de ejecutarse. Transiciones inválidas retornan 403.

### Tiempo real (SignalR)

Endpoint del Hub: `/hubs/tickets`

**Grupos:**
- `ticket-{id}` — actualizaciones por ticket (asignado, observadores)
- `approvals` — notificaciones de cola de aprobación
- `user_{id}` — notificaciones personales y menciones

Autenticación vía parámetro JWT en query string (`access_token`) para el upgrade WebSocket.

### Manejo de errores

Middleware centralizado (`ExceptionHandlingMiddleware`) mapea excepciones a respuestas HTTP:

| Excepción                  | Status | Notas                            |
|----------------------------|--------|----------------------------------|
| `UnauthorizedAccessException` | 401 |                                  |
| `KeyNotFoundException`     | 404    |                                  |
| `ArgumentException`        | 400    |                                  |
| `MySqlException` 1213/1205 | 503    | Deadlock / lock timeout → retry  |
| No manejada                | 500    | Detalles ocultos en Producción   |

Todas las respuestas usan el envelope `ApiResponse<T>`: `{ exitoso, mensaje, datos, errores }`.

### Controllers

| Controller         | Prefijo                   | Auth       | Propósito                           |
|--------------------|---------------------------|------------|-------------------------------------|
| Auth               | `api/v1/Auth`             | Anónimo    | Login, refresh, logout              |
| Tickets            | `api/v1/Tickets`          | Autorizado | CRUD, búsqueda, asignar, transición |
| Comentarios        | `api/v1/comentarios`      | Autorizado | Comentarios (públicos/privados)     |
| Aprobaciones       | `api/v1/aprobaciones`     | Autorizado | Flujo de aprobaciones               |
| Transiciones       | `api/v1/transiciones`     | Autorizado | Historial de transiciones           |
| Departamentos      | `api/v1/Departamentos`    | Autorizado | Gestión de departamentos            |
| Grupos             | `api/v1/Grupos`           | Autorizado | Gestión de grupos                   |
| Motivos            | `api/v1/Motivos`          | Autorizado | Categorías de tickets               |
| References         | `api/v1/References`       | Autorizado | Datos de consulta (estados, prioridades) |
| StoredProcedures   | `api/sp`                  | Admin      | Reportes vía stored procedures      |
| Admin              | `api/admin`               | Admin      | Gestión de usuarios, auditoría      |

---

## Frontend

### Stack

| Componente        | Tecnología                  | Versión    |
|-------------------|-----------------------------|------------|
| Framework         | React                       | 19         |
| Build             | Vite                        | 7          |
| Lenguaje          | TypeScript                  | 5.9        |
| Estado local      | Zustand (persist middleware) | 4          |
| Estado servidor   | @tanstack/react-query       | 5          |
| HTTP              | Axios                       | 1          |
| Tiempo real       | @microsoft/signalr          | 10         |
| Routing           | react-router-dom            | 7          |
| Estilos           | Tailwind CSS                | 4          |
| Gráficos          | Recharts                    | 3          |
| Iconos            | lucide-react                | 0.563      |

### Gestión de estado

**Zustand `authStore`:**
- Persistido en `localStorage` (key: `auth-storage`)
- Almacena: `user`, `token`, `isAuthenticated`
- Helpers de rol: `isAdmin()`, `isTecnico()`, `hasPermission(code)`
- Token almacenado en estado Zustand y `localStorage` para el interceptor de Axios

**React Query** maneja todo el estado de servidor (tickets, departamentos, etc.) con invalidación automática de caché.

### Flujo de autenticación (cliente)

1. Formulario de login → `POST /api/v1/Auth/login`
2. Respuesta almacenada en Zustand (persistida)
3. Interceptor de Axios agrega `Authorization: Bearer {token}` a todas las peticiones
4. Respuesta 401 → auto-logout, redirección a `/login`
5. Conexión SignalR establecida con token en query string

---

## Base de datos

### Motor

MySQL 5.5+ con charset `utf8mb4` (algunas tablas legacy usan `latin1`).

### Tablas RBAC (módulo tickets)

| Tabla                   | Propósito                          |
|-------------------------|------------------------------------|
| `tkt_rol`               | Roles del módulo de tickets        |
| `tkt_permiso`           | Permisos granulares                |
| `tkt_rol_permiso`       | Asignación rol → permiso           |
| `tkt_usuario_rol`       | Asignación usuario → rol           |

### Tablas principales

| Tabla                   | Propósito                          |
|-------------------------|------------------------------------|
| `usuario`               | Usuarios con credenciales          |
| `ticket`                | Entidad principal de ticket        |
| `estado`                | Estados del ciclo de vida          |
| `prioridad`             | Niveles de prioridad (Baja→Crítica)|
| `departamento`          | Departamentos organizacionales     |
| `motivo`                | Categorías de tickets              |
| `comentario`            | Comentarios (públicos/privados)    |
| `historial_ticket`      | Auditoría completa por ticket      |
| `tkt_transicion_regla`  | Reglas de la máquina de estados    |
| `aprobacion`            | Registros de flujo de aprobación   |
| `grupo`                 | Grupos de usuarios                 |

### Patrón de acceso

Todas las queries vía Dapper (SQL directo). Sin EF Core. Compatibilidad MySQL 5.5 — sin CTEs, sin window functions, sin operadores JSON.

Resolución del connection string: `DbTkt` → `DefaultConnection` → `ApiSettings:ConnectionString` → `ConnectionString`.

---

## Pruebas

### Backend (xUnit)

- **Framework:** xUnit + Moq + FluentAssertions
- **Cobertura:** AuthService, TicketService, EstadoService, suites de controllers
- **Resultado:** 92 pasando, 3 omitidos, 0 fallos

### Frontend (Vitest)

- **Framework:** Vitest + @testing-library/react + jsdom
- **Cobertura:** LoginPage, TicketsPage, authStore
- **Resultado:** 18 pasando, 0 fallos

---

## Despliegue

Destino: IIS en Windows Server. Ver [DEPLOY_IIS_GUIDE.md](DEPLOY_IIS_GUIDE.md) para guía paso a paso.

**Requisitos:**
- .NET 6.0 Runtime
- MySQL 5.5+
- Node.js (solo para build del frontend)
- IIS con módulo URL Rewrite
- Certificado HTTPS

**Configuración:** Todos los secretos vía `appsettings.json` o variables de entorno. La clave JWT se valida al arranque — valores vacíos o por defecto causan fallo inmediato.
