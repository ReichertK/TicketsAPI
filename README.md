<div align="center">

# 🎫 Tickets API

**Sistema empresarial de gestión de tickets de soporte**

[![.NET 6](https://img.shields.io/badge/.NET-6.0-512BD4?logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/)
[![React 19](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.9-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-7-646CFF?logo=vite&logoColor=white)](https://vite.dev/)
[![MySQL](https://img.shields.io/badge/MySQL-5.5+-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Gestión completa de tickets con autenticación JWT, RBAC granular, notificaciones en tiempo real (SignalR) y auditoría de transiciones.

[Inicio Rápido](#-inicio-rápido) •
[Funcionalidades](#-funcionalidades) •
[Tech Stack](#-tech-stack) •
[Documentación](#-documentación)

</div>

---

<!-- SCREENSHOT PLACEHOLDER
<div align="center">
  <img src="docs/screenshots/dashboard.png" alt="Dashboard" width="80%" />
</div>
-->

## ⚡ Inicio Rápido

> **Requisitos:** [.NET 6 SDK](https://dotnet.microsoft.com/download/dotnet/6.0) · [Node.js ≥ 18](https://nodejs.org/) · [MySQL 5.5+](https://dev.mysql.com/downloads/)

### 1. Base de Datos

```sql
-- Crear la base de datos y cargar estructura + datos demo
mysql -u root -p < database/schema.sql
mysql -u root -p tickets_db < database/seed.sql
```

### 2. Backend

```bash
cd TicketsAPI

# Configurar conexión (editar appsettings.json o crear appsettings.Development.json)
# Ver appsettings.Production.Example.json como referencia

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

### 4. Iniciar Sesión

| Usuario | Contraseña | Rol |
|---------|------------|-----|
| `admin@demo.com` | `admin123` | Administrador |
| `supervisor@demo.com` | `admin123` | Supervisor |
| `operador@demo.com` | `admin123` | Operador |
| `consulta@demo.com` | `admin123` | Consulta |

---

## 🚀 Funcionalidades

| Módulo | Descripción |
|--------|-------------|
| **Gestión de Tickets** | Crear, asignar, comentar, cerrar — ciclo completo de vida |
| **Máquina de Estados** | 7 estados + 16 transiciones configurables desde BD |
| **RBAC** | 5 roles (Admin, Supervisor, Operador, Consulta, Aprobador) con 18 permisos granulares |
| **Tiempo Real** | Notificaciones instantáneas vía SignalR (WebSockets) |
| **Seguridad** | JWT + Refresh Tokens, bloqueo anti-fuerza-bruta (5 intentos), rate limiting |
| **Búsqueda Global** | Paleta de comandos (Ctrl+K) con búsqueda multi-entidad filtrada por permisos |
| **Dashboard** | Gráficas interactivas (Recharts), indicadores y exportación CSV |
| **Aprobaciones** | Flujo de aprobación/rechazo con transiciones dedicadas |
| **Auditoría** | Historial completo de transiciones con IP, usuario y timestamp |
| **Help Center** | Centro de ayuda integrado con guías y atajos de teclado |

---

## 🛠️ Tech Stack

| Capa | Tecnología |
|------|------------|
| **Backend** | ASP.NET Core 6 · C# · Dapper ORM |
| **Frontend** | React 19 · TypeScript 5.9 · Vite 7 · Tailwind CSS 4 |
| **Base de Datos** | MySQL 5.5+ (30 tablas, stored procedures, state machine) |
| **Tiempo Real** | SignalR 10 (WebSockets con fallback) |
| **Auth** | JWT + Refresh Tokens + MD5 password hashing |
| **Estado (FE)** | Zustand + TanStack React Query |
| **UI** | Lucide Icons · Recharts · Responsive design |
| **Deploy** | IIS (monolito: API sirve SPA desde `wwwroot/`) |

---

## 📁 Estructura del Proyecto

```
├── TicketsAPI/              # Backend — ASP.NET Core 6 Web API
│   ├── Controllers/         #   22 controllers REST (/api/v1/)
│   ├── Services/            #   14 servicios de negocio
│   ├── Repositories/        #   16 repositorios (Dapper + MySQL)
│   ├── Models/              #   Entidades y DTOs
│   ├── Middleware/          #   Exception handling global
│   ├── Config/              #   JWT config, SignalR Hub
│   └── Program.cs           #   Entry point y DI
│
├── tickets-frontend/        # Frontend — React 19 SPA
│   └── src/
│       ├── pages/           #   15 páginas (Dashboard, Tickets, Admin, HelpCenter…)
│       ├── components/      #   15 componentes (layout, tickets, ui)
│       ├── hooks/           #   Custom hooks (SignalR, permisos, filtros)
│       ├── services/        #   Cliente API (Axios + interceptores)
│       ├── store/           #   Estado global (Zustand: auth + toasts)
│       └── types/           #   Tipos TypeScript
│
├── database/                # Scripts de base de datos
│   ├── schema.sql           #   Esquema completo (30 tablas)
│   └── seed.sql             #   Datos demo (usuarios, tickets, permisos)
│
├── docs/                    # Documentación técnica completa
│   ├── 00-Start/            #   Guías de inicio
│   ├── 10-API/              #   Documentación de endpoints
│   ├── 20-DB/               #   Base de datos y esquema
│   ├── 30-Auth/             #   Autenticación y permisos
│   ├── 40-Testing/          #   Pruebas y reportes
│   └── 90-Reports/          #   Reportes técnicos
│
├── scripts/                 # Scripts de utilidades y testing
├── DbAuditTool/             # Herramienta de auditoría de BD (.NET)
└── TicketsAPI.Tests/        # Tests unitarios
```

---

## 🔐 Autenticación y Permisos

El sistema implementa un RBAC completo con dos capas:

- **JWT Access Token** (15 min) + **Refresh Token** (7 días)
- **5 roles** con **18 permisos** independientes configurables desde BD
- **Transiciones de estado** protegidas por rol y propiedad del ticket
- **Rate limiting** y **bloqueo automático** tras intentos fallidos

```
POST /api/v1/auth/login     → { accessToken, refreshToken }
POST /api/v1/auth/refresh   → Renueva tokens
POST /api/v1/auth/logout    → Invalida refresh token
```

Ver [JWT_AUTHENTICATION.md](docs/30-Auth/JWT_AUTHENTICATION.md) y [PERMISSIONS_MATRIX.md](docs/30-Auth/PERMISSIONS_MATRIX.md) para detalles completos.

---

## 🗄️ Base de Datos

- **30 tablas** organizadas por dominio (catálogos, RBAC, tickets, auditoría)
- **Máquina de estados** con `tkt_transicion_regla` (reglas de transición configurables)
- **Stored Procedures** para operaciones críticas

```bash
# Setup desde cero
mysql -u root -p < database/schema.sql
mysql -u root -p tickets_db < database/seed.sql
```

---

## 🏗️ Despliegue en Producción

El proyecto soporta despliegue **monolítico** en IIS donde el backend .NET sirve el SPA desde `wwwroot/`:

```bash
# Build del frontend
cd tickets-frontend && npm run build

# Publicar backend (incluye wwwroot/)
cd ../TicketsAPI && dotnet publish -c Release -o ../publish

# Copiar build del frontend
cp -r ../tickets-frontend/dist/* ../publish/wwwroot/
```

Ver [DEPLOY_IIS_GUIDE.md](docs/90-Reports/DEPLOY_IIS_GUIDE.md) para la guía completa de despliegue en IIS.

---

## 🧪 Testing

### Backend (xUnit + Moq + FluentAssertions)

```bash
cd TicketsAPI.Tests
dotnet test --verbosity normal
```

**Cobertura actual**: 95 tests (92 ✅ | 3 omitidos por diseño)

| Suite | Tests | Capa testeada |
|-------|------:|---------------|
| AuthServiceTests | 12 | Login, RefreshToken, Logout, Permisos, BCrypt migration |
| TicketServiceTests | 11 | CRUD, permisos, máquina de estados, vista-routing |
| EstadoServiceTests | 8 | Transiciones, políticas, state machine rules |
| Controller tests | 64 | Endpoints REST, validaciones HTTP, error codes |

### Frontend (Vitest + React Testing Library)

```bash
cd tickets-frontend
npm test          # modo watch
npm run test:run  # ejecución única
```

**Cobertura actual**: 18 tests (18 ✅)

| Suite | Tests | Capa testeada |
|-------|------:|---------------|
| LoginPage smoke | 6 | Render, branding, inputs, toggle password, loading state |
| TicketsPage smoke | 3 | Render, heading, nuevo ticket button |
| AuthStore (Zustand) | 9 | login/logout, permisos, roles, localStorage |

### Tests de integración

```bash
python integration_tests.py
```

---

## 📚 Documentación

| Documento | Descripción |
|-----------|-------------|
| [Índice Maestro](docs/00-INDICE_MAESTRO.md) | Navegación completa de la documentación |
| [Guía de Inicio](docs/00-Start/START_AQUI.md) | Primeros pasos |
| [API Integration Guide](docs/10-API/API_INTEGRATION_GUIDE.md) | Referencia completa de endpoints |
| [JWT Authentication](docs/30-Auth/JWT_AUTHENTICATION.md) | Flujo de autenticación |
| [Permissions Matrix](docs/30-Auth/PERMISSIONS_MATRIX.md) | Matriz de roles y permisos |
| [Deploy IIS Guide](docs/90-Reports/DEPLOY_IIS_GUIDE.md) | Despliegue en IIS |

---

## 🤝 Contribuir

1. Fork del repositorio
2. Crear branch: `git checkout -b feature/mi-feature`
3. Commit: `git commit -m 'feat: descripción del cambio'`
4. Push: `git push origin feature/mi-feature`
5. Abrir Pull Request

---

## 📄 Licencia

Este proyecto está bajo la licencia [MIT](LICENSE).

---

<div align="center">
  <sub>Desarrollado con ☕ y 🎵</sub>
</div>