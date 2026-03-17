# Sistema de Tickets - Frontend

Frontend del sistema de gestión de tickets, desarrollado con React 19, TypeScript, Tailwind CSS y Vite.

## Requisitos

- Node.js 18+
- API backend corriendo (ver README raíz)

## Instalación

```bash
cd tickets-frontend
npm install
```

## Variables de entorno

Crear `.env` en la raíz:

```env
VITE_API_URL=http://localhost:5000
```

## Desarrollo

```bash
npm run dev
```

Disponible en `http://localhost:5173`.

## Build producción

```bash
npm run build
```

Genera la carpeta `dist/` con assets optimizados (legacy + modern bundles).

## Stack

| Tecnología        | Propósito                  |
|-------------------|----------------------------|
| React 19          | Framework UI               |
| TypeScript 5.9    | Tipado estático            |
| Vite 7            | Build tool                 |
| Tailwind CSS 4    | Estilos                    |
| Zustand           | Estado global (auth)       |
| React Query       | Estado servidor + caché    |
| Axios             | Cliente HTTP               |
| SignalR           | Notificaciones tiempo real |
| react-router-dom  | Routing                    |
| Recharts          | Gráficos del dashboard     |
| lucide-react      | Iconos                     |

## Estructura

```
src/
├── components/
│   ├── layout/          CommandPalette, Layout, NotificationBadge, ProtectedRoute
│   ├── tickets/         DiffTable, PriorityBadge, SortableHeader, StatusBadge,
│   │                    TicketFilters, TicketHistory
│   └── ui/              ConfirmActionModal, EmptyState, ErrorAlert, Pagination,
│                        UserAvatar
├── hooks/               useSignalR
├── pages/
│   ├── LoginPage        Autenticación
│   ├── DashboardPage    Métricas y gráficos
│   ├── TicketsPage      Listado con filtros y paginación
│   ├── CreateTicketPage Formulario de creación
│   ├── EditTicketPage   Formulario de edición
│   ├── TicketDetailPage Detalle, comentarios, historial, transiciones
│   ├── TodosTicketsPage Vista global de tickets
│   ├── ColaTrabajoPage  Cola de trabajo personal
│   ├── SeguimientoTicketsPage Seguimiento de tickets
│   ├── UsuariosPage     Gestión de usuarios (admin)
│   ├── DepartamentosPage Gestión de departamentos
│   ├── ConfiguracionPage Configuración del sistema
│   ├── SeguridadTab     Gestión RBAC
│   ├── AuditLogsPage    Logs de auditoría
│   └── HelpPage         Ayuda y manual
├── services/            api.service.ts (Axios + interceptores)
├── store/               authStore.ts (Zustand persistido)
├── types/               api.types.ts (DTOs e interfaces)
├── config/              Configuración de API y endpoints
└── docs/                Manual de usuario
```

## Autenticación

- Token JWT almacenado en Zustand (persistido en `localStorage`)
- Interceptor de Axios agrega `Authorization: Bearer {token}` automáticamente
- Respuesta 401 → auto-logout y redirección a `/login`
- Refresh token automático antes de expiración
- Conexión SignalR con token en query string

**Credenciales de prueba** (seed): `admin@demo.com` / `admin123`

## Pruebas

```bash
npm test
```

18 tests en 3 suites: LoginPage, TicketsPage, authStore.

## Scripts

| Script            | Descripción                     |
|-------------------|---------------------------------|
| `npm run dev`     | Servidor de desarrollo          |
| `npm run build`   | Build de producción             |
| `npm run preview` | Previsualizar build             |
| `npm test`        | Ejecutar tests (Vitest)         |
