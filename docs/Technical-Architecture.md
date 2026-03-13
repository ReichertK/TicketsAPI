# Technical Architecture

## System Overview

Full-stack ticket management system with role-based access control, real-time notifications, and a state-machine workflow engine. Designed for internal organizational use.

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

| Component         | Technology                  | Version  |
|-------------------|-----------------------------|----------|
| Framework         | ASP.NET Core                | 6.0      |
| ORM               | Dapper + Dapper.Contrib      | 2.1.1    |
| Database Driver   | MySqlConnector              | 2.2.7    |
| Auth              | JWT Bearer                  | 6.0.21   |
| Password Hashing  | BCrypt.Net-Next             | 4.0.3    |
| Real-time         | SignalR + MessagePack       | 6.0.21   |
| Validation        | FluentValidation            | 11.11.0  |
| Mapping           | AutoMapper                  | 12.0.1   |
| Logging           | Serilog (Console + File)    | 3.1.1    |
| Rate Limiting     | AspNetCoreRateLimit         | 5.0.0    |
| Export            | MiniExcel + CsvHelper       | 1.42.0 / 30.0.0 |
| API Docs          | Swashbuckle                 | 6.5.0    |

### Architecture Pattern

Repository → Service → Controller, all wired through DI.

```
Controller (HTTP boundary)
    └── Service (business logic, authorization checks)
         └── Repository (Dapper raw SQL, MySQL 5.5 compatible)
```

Repositories registered as **Singleton** (stateless, connection-per-query via MySqlConnector pooling). Services are Singleton except `UsuarioService` (Scoped).

### Authentication & Security

**JWT flow:**
1. `POST /api/auth/login` — validates credentials, returns access token + refresh token
2. Access token: short-lived, contains `sub` (userId), `role`, custom claims
3. Refresh token: hashed (SHA-256) in DB, rotated on use
4. Token validation: issuer, audience, lifetime, signing key (HS256)

**Password handling:**
- Accepts BCrypt, MD5, SHA256, and plaintext (legacy migration)
- Auto-upgrades old hashes to BCrypt on successful login
- BCrypt cost factor for all new passwords

**Brute force protection:**
- Per-account lockout tracked in MySQL
- Returns remaining attempts and lockout expiry
- Failed attempts logged even for non-existent users (prevents enumeration)

**Rate limiting:**
- IP-based via AspNetCoreRateLimit
- Configurable in `appsettings.json` under `IpRateLimiting`

### State Machine

Ticket lifecycle governed by `PoliticaTransicion` table:

| Column               | Purpose                                     |
|----------------------|---------------------------------------------|
| `Id_Estado_Origen`   | Source state                                |
| `Id_Estado_Destino`  | Target state                                |
| `Id_Rol`             | Which role can execute this transition      |
| `Requiere_Propietario` | Must be ticket owner                     |
| `Requiere_Aprobacion`  | Triggers approval workflow                |
| `Permiso_Requerido`    | Granular permission code check            |

Transitions are validated server-side before execution. Invalid transitions return 403.

### Real-time (SignalR)

Hub endpoint: `/hubs/tickets`

**Groups:**
- `ticket-{id}` — per-ticket updates (assigned user, watchers)
- `approvals` — approval queue notifications
- `user_{id}` — personal notifications and mentions

Authentication via JWT query string parameter (`access_token`) for WebSocket upgrade.

### Error Handling

Centralized middleware (`ExceptionHandlingMiddleware`) maps exceptions to HTTP responses:

| Exception                  | Status | Notes                            |
|----------------------------|--------|----------------------------------|
| `UnauthorizedAccessException` | 401 |                                  |
| `KeyNotFoundException`     | 404    |                                  |
| `ArgumentException`        | 400    |                                  |
| `MySqlException` 1213/1205 | 503    | Deadlock / lock timeout → retry  |
| Unhandled                  | 500    | Details hidden in Production     |

All responses use `ApiResponse<T>` envelope: `{ exitoso, mensaje, datos, errores }`.

### Controllers

| Controller         | Prefix                    | Auth       | Purpose                          |
|--------------------|---------------------------|------------|----------------------------------|
| Auth               | `/api/auth`               | Anonymous  | Login, refresh, logout           |
| Tickets            | `/api/tickets`            | Authorized | CRUD, search, assign, transition |
| Comentarios        | `/api/comentarios`        | Authorized | Ticket comments (public/private) |
| Aprobaciones       | `/api/aprobaciones`       | Authorized | Approval workflow                |
| Transiciones       | `/api/transiciones`       | Authorized | State transition history         |
| Departamentos      | `/api/departamentos`      | Authorized | Department management            |
| Grupos             | `/api/grupos`             | Authorized | User group management            |
| Motivos            | `/api/motivos`            | Authorized | Ticket categories/reasons        |
| References         | `/api/references`         | Authorized | Lookup data (estados, prioridades) |
| StoredProcedures   | `/api/stored-procedures`  | Authorized | Report generation via SPs        |
| Admin              | `/api/admin`              | Admin only | User management, config audit    |

---

## Frontend

### Stack

| Component         | Technology                  | Version    |
|-------------------|-----------------------------|------------|
| Framework         | React                       | 19.2.4     |
| Build             | Vite                        | 7.2.4      |
| Language          | TypeScript                  | 5.9.3      |
| State             | Zustand (persist middleware) | 4.4.7      |
| Server State      | @tanstack/react-query       | 5.90.20    |
| HTTP              | Axios                       | 1.13.4     |
| Real-time         | @microsoft/signalr          | 10.0.0     |
| Routing           | react-router-dom            | 7.13.0     |
| Styling           | Tailwind CSS                | 4.1.18     |
| Charts            | Recharts                    | 3.7.0      |
| Icons             | lucide-react                | 0.563.0    |

### State Management

**Zustand `authStore`:**
- Persisted to `localStorage` (key: `auth-storage`)
- Stores: `user`, `token`, `isAuthenticated`
- Role helpers: `isAdmin()`, `isTecnico()`, `hasPermission(code)`
- Token stored in both Zustand state and `localStorage` for Axios interceptor access

**React Query** handles all server state (tickets, departments, etc.) with automatic cache invalidation.

### Authentication Flow (Client)

1. Login form → `POST /api/auth/login`
2. Response stored in Zustand (persisted)
3. Axios interceptor attaches `Authorization: Bearer {token}` to all requests
4. 401 response → auto-logout, redirect to `/login`
5. SignalR connection established with token in query string

---

## Database

### Engine

MySQL 5.5+ with `utf8mb4` charset (mixed `latin1` in some legacy tables).

### Core Tables

| Table                | Purpose                              |
|----------------------|--------------------------------------|
| `usuario`            | Users with auth credentials          |
| `rol` / `permiso` / `rol_permiso` | RBAC permission system  |
| `ticket`             | Main ticket entity                   |
| `estado`             | Ticket lifecycle states              |
| `prioridad`          | Priority levels (Baja→Crítica)       |
| `departamento`       | Organizational departments           |
| `motivo`             | Ticket categories                    |
| `comentario`         | Ticket comments (public/private)     |
| `historial_ticket`   | Full audit trail per ticket          |
| `politica_transicion`| State machine rules                  |
| `aprobacion`         | Approval workflow records            |
| `grupo`              | User groups                          |

### Access Pattern

All queries via Dapper (raw SQL). No EF Core. MySQL 5.5 compatibility enforced — no CTEs, no window functions, no JSON operators.

Connection string resolution order: `DbTkt` → `DefaultConnection` → `ApiSettings:ConnectionString` → `ConnectionString`.

---

## Testing

### Backend (xUnit)

- **Framework:** xUnit 2.6.2 + Moq 4.20.70 + FluentAssertions 6.12.0
- **Coverage:** AuthService (12), TicketService (11), EstadoService (8), Controller tests (5 suites)
- **Result:** 92 passing, 3 skipped, 0 failures

### Frontend (Vitest)

- **Framework:** Vitest + @testing-library/react + jsdom
- **Coverage:** LoginPage (6), TicketsPage (3), authStore (9)
- **Result:** 18 passing, 0 failures

---

## Deployment

Target: IIS on Windows Server. See [DEPLOY_IIS_GUIDE.md](DEPLOY_IIS_GUIDE.md) for step-by-step instructions.

**Requirements:**
- .NET 6.0 Runtime
- MySQL 5.5+ instance
- Node.js (for frontend build only)
- IIS with URL Rewrite module
- HTTPS certificate

**Configuration:** All secrets via `appsettings.json` or environment variables. JWT secret key validated at startup — default/empty values cause immediate failure.
