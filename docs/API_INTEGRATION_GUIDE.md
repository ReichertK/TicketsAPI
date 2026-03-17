# Guía de Integración API

## Información general

| Dato            | Valor                          |
|-----------------|--------------------------------|
| Base URL        | `https://{host}/api/v1`        |
| Content-Type    | `application/json`             |
| Autenticación   | JWT Bearer                     |
| Encoding        | UTF-8                          |

Todos los endpoints (excepto login) requieren header `Authorization: Bearer {token}`.

## Formato de respuesta

Todas las respuestas usan el envelope `ApiResponse<T>`:

```json
{
  "exitoso": true,
  "mensaje": "Operación exitosa",
  "datos": { ... },
  "errores": []
}
```

| Campo     | Tipo       | Descripción                   |
|-----------|------------|-------------------------------|
| `exitoso` | `boolean`  | Indica si la operación fue exitosa |
| `mensaje` | `string`   | Descripción del resultado     |
| `datos`   | `T | null` | Payload de la respuesta       |
| `errores` | `string[]` | Lista de errores (si aplica)  |

## Autenticación

### Login

```
POST /api/v1/Auth/login
```

**Request:**
```json
{
  "usuario": "admin@demo.com",
  "contraseña": "admin123"
}
```

**Response (200):**
```json
{
  "exitoso": true,
  "mensaje": "Login exitoso",
  "datos": {
    "id_Usuario": 1,
    "nombre": "Admin",
    "email": "admin@demo.com",
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2g...",
    "rol": {
      "id_Rol": 1,
      "nombre_Rol": "Administrador"
    },
    "permisos": ["TKT_LIST_ALL", "TKT_CREATE", "TKT_EDIT_ANY", "..."]
  },
  "errores": []
}
```

### Refresh token

```
POST /api/v1/Auth/refresh
```

```json
{ "refreshToken": "token_anterior" }
```

Retorna un nuevo par access + refresh token. El refresh token anterior queda invalidado.

### Logout

```
POST /api/v1/Auth/logout
```

Revoca el refresh token activo.

## Endpoints principales

### Tickets

| Método | Ruta                          | Descripción                |
|--------|-------------------------------|----------------------------|
| GET    | `/api/v1/Tickets`             | Listar tickets (paginado)  |
| GET    | `/api/v1/Tickets/{id}`        | Detalle de ticket          |
| POST   | `/api/v1/Tickets`             | Crear ticket               |
| PUT    | `/api/v1/Tickets/{id}`        | Actualizar ticket          |
| DELETE | `/api/v1/Tickets/{id}`        | Eliminar ticket (soft)     |
| POST   | `/api/v1/Tickets/{id}/asignar`| Asignar ticket             |
| GET    | `/api/v1/Tickets/export/csv`  | Exportar a CSV             |

**Filtros de listado** (query params):

| Parámetro          | Tipo   | Descripción                    |
|--------------------|--------|--------------------------------|
| `Id_Estado`        | int    | Filtrar por estado             |
| `Id_Prioridad`     | int    | Filtrar por prioridad          |
| `Id_Departamento`  | int    | Filtrar por departamento       |
| `Id_Motivo`        | int    | Filtrar por motivo             |
| `Fecha_Desde`      | date   | Desde fecha (YYYY-MM-DD)       |
| `Fecha_Hasta`      | date   | Hasta fecha (YYYY-MM-DD)       |
| `Busqueda`         | string | Búsqueda en contenido          |
| `Pagina`           | int    | Página (default: 1)            |
| `TamañoPagina`     | int    | Registros por página (max: 100)|

**Crear ticket:**
```json
{
  "contenido": "Descripción del problema",
  "id_Prioridad": 2,
  "id_Departamento": 1,
  "id_Motivo": 3,
  "id_Usuario_Asignado": null
}
```

### Transiciones de estado

```
POST /api/v1/transiciones/tickets/{id}/transicionar
```

```json
{
  "idEstadoDestino": 2,
  "comentario": "Iniciando trabajo"
}
```

Las transiciones válidas dependen del estado actual, rol del usuario y permisos. Ver [PERMISSIONS_MATRIX.md](PERMISSIONS_MATRIX.md).

### Comentarios

| Método | Ruta                                       | Descripción       |
|--------|--------------------------------------------|--------------------|
| GET    | `/api/v1/comentarios/ticket/{ticketId}`    | Listar comentarios |
| POST   | `/api/v1/comentarios/ticket/{ticketId}`    | Crear comentario   |

```json
{
  "contenido": "Texto del comentario. Soporta @menciones.",
  "esInterno": false
}
```

### Aprobaciones

| Método | Ruta                                       | Descripción        |
|--------|--------------------------------------------|--------------------|
| GET    | `/api/v1/aprobaciones/pendientes`          | Mis pendientes     |
| POST   | `/api/v1/aprobaciones/{id}/aprobar`        | Aprobar            |
| POST   | `/api/v1/aprobaciones/{id}/rechazar`       | Rechazar           |

### Catálogos

| Método | Ruta                        | Descripción          |
|--------|-----------------------------|----------------------|
| GET    | `/api/v1/References/estados`     | Estados disponibles  |
| GET    | `/api/v1/References/prioridades` | Prioridades          |
| GET    | `/api/v1/Departamentos`     | Departamentos        |
| GET    | `/api/v1/Motivos`           | Motivos/categorías   |
| GET    | `/api/v1/Grupos`            | Grupos de usuarios   |
| GET    | `/api/v1/Roles`             | Roles del sistema    |

### Administración

| Método | Ruta                              | Descripción              |
|--------|-----------------------------------|--------------------------|
| GET    | `/api/v1/Usuarios`                | Listar usuarios          |
| POST   | `/api/v1/Usuarios`                | Crear usuario            |
| PUT    | `/api/v1/Usuarios/{id}`           | Actualizar usuario       |
| GET    | `/api/v1/AuditLogs`               | Logs de auditoría        |
| GET    | `/api/v1/Reportes/dashboard`      | Estadísticas dashboard   |
| GET    | `/api/sp/{procedureName}`         | Ejecutar stored procedure|

## Códigos HTTP

| Código | Significado                                      |
|--------|--------------------------------------------------|
| 200    | Operación exitosa                                |
| 201    | Recurso creado                                   |
| 400    | Datos inválidos (ver `errores`)                  |
| 401    | Token ausente, expirado o inválido               |
| 403    | Sin permiso para la operación                    |
| 404    | Recurso no encontrado                            |
| 429    | Rate limit excedido                              |
| 503    | Error temporal de BD (deadlock) — reintentar     |
| 500    | Error interno del servidor                       |

## Rate limiting

Basado en IP vía AspNetCoreRateLimit. Regla por defecto: 60 req/min en `/api/sp/*`. HTTP 429 si se excede.

## Ejemplos cURL

```bash
# Login
curl -s -X POST https://localhost:5001/api/v1/Auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"admin@demo.com","contraseña":"admin123"}'

# Listar tickets (requiere token)
curl -s https://localhost:5001/api/v1/Tickets?Pagina=1 \
  -H "Authorization: Bearer {token}"

# Crear ticket
curl -s -X POST https://localhost:5001/api/v1/Tickets \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"contenido":"Problema reportado","id_Prioridad":2,"id_Departamento":1}'

# Transicionar estado
curl -s -X POST https://localhost:5001/api/v1/transiciones/tickets/1/transicionar \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"idEstadoDestino":2,"comentario":"En proceso"}'
```

## Ejemplo PowerShell

```powershell
$base = "https://localhost:5001/api/v1"

# Login
$login = Invoke-RestMethod "$base/Auth/login" -Method Post `
  -ContentType "application/json" `
  -Body '{"usuario":"admin@demo.com","contraseña":"admin123"}'

$headers = @{ Authorization = "Bearer $($login.datos.token)" }

# Listar tickets
$tickets = Invoke-RestMethod "$base/Tickets?Pagina=1" -Headers $headers

# Crear ticket
$nuevo = Invoke-RestMethod "$base/Tickets" -Method Post -Headers $headers `
  -ContentType "application/json" `
  -Body '{"contenido":"Nuevo ticket","id_Prioridad":2,"id_Departamento":1}'
```
