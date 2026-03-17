<div align="center">

# Cediac Tickets

**Plataforma de gestión de tickets de soporte interno**

[![.NET 6](https://img.shields.io/badge/.NET-6.0-512BD4?logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/)
[![React 19](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.9-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-7-646CFF?logo=vite&logoColor=white)](https://vite.dev/)
[![MySQL](https://img.shields.io/badge/MySQL-5.5+-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Sistema full-stack para la gestión de tickets con máquina de estados, RBAC granular, notificaciones en tiempo real vía SignalR y auditoría completa de transiciones.

[Inicio Rápido](#inicio-rápido) · [Funcionalidades](#funcionalidades) · [Tech Stack](#tech-stack) · [Documentación](#documentación)

</div>

---

## Inicio Rápido

**Requisitos:** [.NET 6 SDK](https://dotnet.microsoft.com/download/dotnet/6.0) · [Node.js 18+](https://nodejs.org/) · [MySQL 5.5+](https://dev.mysql.com/downloads/)

### 1. Base de Datos

```sql
mysql -u root -p < Database/schema.sql
mysql -u root -p tickets_db < Database/seed.sql
```

### 2. Backend

```bash
cd TicketsAPI
# Configurar conexión en appsettings.json (ver appsettings.Production.Example.json)
dotnet restore
dotnet run --urls "http://localhost:5000"
```

Verificar: [http://localhost:5000/swagger](http://localhost:5000/swagger) · [http://localhost:5000/health](http://localhost:5000/health)

### 3. Frontend

```bash
cd tickets-frontend
npm install
npm run dev
# → http://localhost:5173
```

### 4. Credenciales de prueba

| Usuario | Contraseña | Rol |
|---------|------------|-----|
| `admin@demo.com` | `admin123` | Administrador |
| `supervisor@demo.com` | `admin123` | Supervisor |
| `operador@demo.com` | `admin123` | Operador |
| `consulta@demo.com` | `admin123` | Consulta |

---

## Funcionalidades

| Módulo | Descripción |
|--------|-------------|
| **Tickets** | Ciclo de vida completo: crear, asignar, comentar, cerrar |
| **Máquina de Estados** | 7 estados + 16 transiciones configurables desde BD |
| **RBAC** | 5 roles, 18 permisos independientes, configurables desde BD |
| **Tiempo Real** | Notificaciones push vía SignalR (WebSockets con fallback) |
| **Seguridad** | JWT + Refresh Tokens, bloqueo tras 5 intentos fallidos, rate limiting |
| **Búsqueda Global** | Paleta de comandos (Ctrl+K) con búsqueda multi-entidad filtrada por permisos |
| **Dashboard** | Gráficas interactivas (Recharts), indicadores KPI, exportación CSV |
| **Aprobaciones** | Flujo de aprobación/rechazo con transiciones dedicadas |
| **Auditoría** | Historial completo de transiciones con IP, usuario y timestamp |

---

## Tech Stack

| Capa | Tecnología |
|------|------------|
| **Backend** | ASP.NET Core 6 · C# · Dapper ORM |
| **Frontend** | React 19 · TypeScript 5.9 · Vite 7 · Tailwind CSS 4 |
| **Base de Datos** | MySQL 5.5+ · 30 tablas · Stored Procedures · State Machine |
| **Tiempo Real** | SignalR 10 (WebSockets con fallback a Long Polling) |
| **Auth** | JWT + Refresh Tokens · BCrypt (migración progresiva desde legado) |
| **Estado (FE)** | Zustand + TanStack React Query |
| **UI** | Lucide Icons · Recharts · Diseño responsivo |
| **Deploy** | IIS (monolito: API sirve SPA desde `wwwroot/`) |

---

## Estructura del Proyecto

```
TicketsAPI/                  # Backend — ASP.NET Core 6 Web API
├── Controllers/             #   22 controllers REST (/api/v1/)
├── Services/                #   14 servicios de negocio
├── Repositories/            #   16 repositorios (Dapper + MySQL)
├── Models/                  #   Entidades y DTOs
├── Middleware/              #   Exception handling global
├── Config/                  #   JWT config, SignalR Hub
└── Program.cs               #   Entry point y DI

tickets-frontend/            # Frontend — React 19 SPA
└── src/
    ├── pages/               #   17 páginas (Dashboard, Tickets, Admin…)
    ├── components/          #   15 componentes (layout, tickets, ui)
    ├── hooks/               #   Custom hooks (SignalR, permisos, filtros)
    ├── services/            #   Cliente API (Axios + interceptores)
    ├── store/               #   Estado global (Zustand: auth + toasts)
    └── types/               #   Tipos TypeScript

Database/                    # Scripts SQL
├── schema.sql               #   Esquema completo (30 tablas)
└── seed.sql                 #   Datos de prueba

docs/                        # Documentación técnica
scripts/                     # Utilidades operacionales
TicketsAPI.Tests/            # Tests unitarios (xUnit)
```

---

## Autenticación y Permisos

RBAC de dos capas:

- **JWT Access Token** (60 min) + **Refresh Token** (7 días)
- **5 roles** con **18 permisos** independientes, configurables desde BD
- **Transiciones de estado** protegidas por rol y propiedad del ticket
- **Rate limiting** y **bloqueo automático** tras intentos fallidos

```
POST /api/v1/auth/login     → { accessToken, refreshToken }
POST /api/v1/auth/refresh   → Renueva tokens
POST /api/v1/auth/logout    → Invalida refresh token
```

Ver [JWT_AUTHENTICATION.md](docs/JWT_AUTHENTICATION.md) y [PERMISSIONS_MATRIX.md](docs/PERMISSIONS_MATRIX.md).

---

## Base de Datos

- **30 tablas** organizadas por dominio (catálogos, RBAC, tickets, auditoría)
- **Máquina de estados** vía `tkt_transicion_regla` (reglas configurables)
- **Stored Procedures** para operaciones críticas

```bash
mysql -u root -p < Database/schema.sql
mysql -u root -p tickets_db < Database/seed.sql
```

---

## Despliegue

Despliegue monolítico en IIS: el backend .NET sirve el SPA desde `wwwroot/`.

```bash
cd tickets-frontend && npm run build
cd ../TicketsAPI && dotnet publish -c Release -o ../publish
cp -r ../tickets-frontend/dist/* ../publish/wwwroot/
```

Alternativa rápida con el script incluido:

```powershell
.\publish.ps1
```

Ver [DEPLOY_IIS_GUIDE.md](docs/DEPLOY_IIS_GUIDE.md) para la guía completa.

---

## Testing

### Backend — xUnit + Moq + FluentAssertions

```bash
cd TicketsAPI.Tests && dotnet test --verbosity normal
```

95 tests (92 passed, 3 omitidos por diseño)

| Suite | Tests | Cobertura |
|-------|------:|-----------|
| AuthServiceTests | 12 | Login, RefreshToken, Logout, BCrypt migration |
| TicketServiceTests | 11 | CRUD, permisos, máquina de estados |
| EstadoServiceTests | 8 | Transiciones, políticas, state machine |
| Controller tests | 64 | Endpoints REST, validaciones HTTP, error codes |

### Frontend — Vitest + React Testing Library

```bash
cd tickets-frontend && npm run test:run
```

18 tests (18 passed)

| Suite | Tests | Cobertura |
|-------|------:|-----------|
| LoginPage | 6 | Render, inputs, toggle password, loading state |
| TicketsPage | 3 | Render, heading, nuevo ticket |
| AuthStore | 9 | login/logout, permisos, roles, localStorage |

### Smoke test (integración)

```bash
python scripts/smoke-test.py
```

---

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [Arquitectura Técnica](docs/Technical-Architecture.md) | Arquitectura del sistema |
| [Guía de Integración API](docs/API_INTEGRATION_GUIDE.md) | Referencia de endpoints |
| [Autenticación JWT](docs/JWT_AUTHENTICATION.md) | Flujo de autenticación |
| [Matriz de Permisos](docs/PERMISSIONS_MATRIX.md) | Roles, permisos y transiciones |
| [Despliegue IIS](docs/DEPLOY_IIS_GUIDE.md) | Guía de despliegue en IIS |

---

## Contribuir

1. Fork del repositorio
2. Crear branch: `git checkout -b feature/mi-feature`
3. Commit con [Conventional Commits](https://www.conventionalcommits.org/): `git commit -m 'feat: descripción'`
4. Push: `git push origin feature/mi-feature`
5. Abrir Pull Request

---

## Licencia

[MIT](LICENSE)