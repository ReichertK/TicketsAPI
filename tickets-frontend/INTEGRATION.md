# Integración Frontend - API

Documentación de cómo el frontend consume la API REST.

## Cliente HTTP

`src/services/api.service.ts` configura un cliente Axios con:

- **Base URL**: tomada de `VITE_API_URL` (variable de entorno) + `/api/v1`
- **Request interceptor**: agrega `Authorization: Bearer {token}` desde `localStorage`
- **Response interceptor**: ante 401 intenta refresh automático; si falla, logout y redirección a `/login`

## Tipos

`src/types/api.types.ts` define las interfaces TypeScript sincronizadas con los DTOs del backend. El formato de respuesta siempre es:

```typescript
interface ApiResponse<T> {
  exitoso: boolean;
  mensaje: string;
  datos: T;
  errores: string[];
}
```

## Estado global

**Zustand** (`src/store/authStore.ts`) maneja:
- `user`, `token`, `refreshToken`, `isAuthenticated`
- Helpers: `isAdmin()`, `hasPermission(code)`
- Persistido en `localStorage` (key: `auth-storage`)

**React Query** maneja estado de servidor con invalidación automática de caché. Cada página/hook usa `useQuery` / `useMutation`.

## SignalR

`src/hooks/useSignalR.ts` establece conexión WebSocket al hub `/hubs/tickets`:

- Autenticación vía query string (`access_token`)
- Reconexión automática con backoff
- Suscripción a grupos: `ticket-{id}`, `user_{id}`, `approvals`
- Eventos: `TicketUpdated`, `NewComment`, `NewNotification`, `ApprovalRequired`

## Endpoints consumidos

| Servicio             | Ruta                                    | Método |
|---------------------|-----------------------------------------|--------|
| Login               | `/Auth/login`                           | POST   |
| Refresh             | `/Auth/refresh`                         | POST   |
| Logout              | `/Auth/logout`                          | POST   |
| Tickets (listar)    | `/Tickets`                              | GET    |
| Ticket (detalle)    | `/Tickets/{id}`                         | GET    |
| Ticket (crear)      | `/Tickets`                              | POST   |
| Ticket (actualizar) | `/Tickets/{id}`                         | PUT    |
| Ticket (eliminar)   | `/Tickets/{id}`                         | DELETE |
| Transicionar        | `/transiciones/tickets/{id}/transicionar` | POST |
| Comentarios         | `/comentarios/ticket/{id}`              | GET/POST|
| Aprobaciones        | `/aprobaciones/pendientes`              | GET    |
| Dashboard           | `/Reportes/dashboard`                   | GET    |
| Usuarios            | `/Usuarios`                             | GET/POST/PUT |
| Departamentos       | `/Departamentos`                        | GET/POST/PUT |
| Referencias         | `/References/estados`, `/prioridades`   | GET    |
| Audit logs          | `/AuditLogs`                            | GET    |
| Búsqueda global     | `/Search`                               | GET    |
| Exportar CSV        | `/Tickets/export/csv`                   | GET    |

Todas las rutas son relativas a la base URL (`/api/v1`).

## CORS

La API configura CORS para permitir el origen del frontend. En desarrollo: `http://localhost:5173`. En producción: configurar en `appsettings.json` → `AllowedOrigins`.
