# Integración Frontend-API - Guía Completa

## 📡 Cómo el Frontend Consume la API

### 1. Configuración Base

**Archivo**: `src/config/api.ts`

```typescript
export const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1';

export const API_ENDPOINTS = {
  LOGIN: '/Auth/login',
  TICKETS: '/Tickets',
  DASHBOARD: '/Reportes/Dashboard',
  // ... más endpoints
};
```

### 2. Cliente HTTP con Interceptores

**Archivo**: `src/services/api.service.ts`

```typescript
import axios from 'axios';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' }
});

// Request Interceptor: Agregar token
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response Interceptor: Manejar errores
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expirado → redirigir a login
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### 3. Tipos TypeScript

**Archivo**: `src/types/api.types.ts`

Todas las interfaces DTOs están sincronizadas con la API:

```typescript
export interface LoginRequest {
  Usuario: string;
  Contraseña: string;
}

export interface LoginResponse {
  Id_Usuario: number;
  Token: string;
  Rol: RolDTO;
  Permisos: string[];
}

export interface TicketDTO {
  Id_Tkt: number;
  Contenido: string;
  Estado?: EstadoDTO;
  // ... más campos
}

export interface ApiResponse<T> {
  Exitoso: boolean;
  Mensaje: string;
  Datos?: T;
  Errores: string[];
}
```

## 🔄 Flujo de Una Petición

### Ejemplo: Login

```typescript
// 1. Usuario escribe credenciales en formulario
const [credentials, setCredentials] = useState({
  Usuario: 'admin@example.com',
  Contraseña: 'password123'
});

// 2. Click en "Iniciar Sesión"
const handleLogin = async () => {
  try {
    // 3. Hacer petición POST
    const response = await apiClient.post(
      API_ENDPOINTS.LOGIN,
      credentials
    );

    // 4. Response con token
    const { Datos } = response.data;
    // Datos = {
    //   Id_Usuario: 1,
    //   Token: "eyJhbGc...",
    //   Rol: { Id_Rol: 1, Nombre_Rol: "Admin" },
    //   ...
    // }

    // 5. Guardar token en localStorage
    localStorage.setItem('token', Datos.Token);

    // 6. Guardar en estado global
    login(Datos);

    // 7. Redirigir a dashboard
    navigate('/');

  } catch (error) {
    // 8. Mostrar error si hay problema
    setError(error.response?.data?.Mensaje);
  }
};
```

## 🎯 Endpoints Consumidos y Cómo

### 1. Autenticación

```typescript
// LOGIN
POST /Auth/login
{
  "Usuario": "admin@example.com",
  "Contraseña": "Admin123!"
}
→ Response: { Exitoso: true, Datos: LoginResponse }

// Usado en: src/pages/LoginPage.tsx
const response = await apiClient.post(API_ENDPOINTS.LOGIN, credentials);
```

### 2. Dashboard / Reportes

```typescript
// GET DASHBOARD
GET /Reportes/Dashboard?id_usuario=&id_departamento=
→ Response: { Exitoso: true, Datos: DashboardDTO }

// Usado en: src/pages/DashboardPage.tsx
const { data: dashboard } = useQuery({
  queryKey: ['dashboard'],
  queryFn: async () => {
    const response = await apiClient.get(API_ENDPOINTS.DASHBOARD);
    return response.data.Datos;
  }
});
```

### 3. Tickets - Listado

```typescript
// GET TICKETS (Paginado)
GET /Tickets?Pagina=1&TamañoPagina=10&Busqueda=?
→ Response: { Exitoso: true, Datos: PaginatedResponse<TicketDTO> }

// Usado en: src/pages/TicketsPage.tsx
const { data } = useQuery({
  queryKey: ['tickets', page, searchTerm],
  queryFn: async () => {
    const response = await apiClient.get(API_ENDPOINTS.TICKETS, {
      params: { Pagina: page, TamañoPagina: 10, Busqueda: searchTerm }
    });
    return response.data.Datos;
  }
});
```

### 4. Tickets - Detalle

```typescript
// GET TICKET DETAIL
GET /Tickets/{id}
→ Response: { Exitoso: true, Datos: TicketDTO }

// Usado en: src/pages/TicketDetailPage.tsx
const { data: ticket } = useQuery({
  queryKey: ['ticket', id],
  queryFn: async () => {
    const response = await apiClient.get(API_ENDPOINTS.TICKETS_BY_ID(id));
    return response.data.Datos;
  }
});
```

### 5. Tickets - Crear

```typescript
// POST CREATE TICKET
POST /Tickets
{
  "Contenido": "Descripción del problema...",
  "Id_Prioridad": 2,
  "Id_Departamento": 3
}
→ Response: { Exitoso: true, Datos: TicketDTO }

// Usado en: src/pages/CreateTicketPage.tsx
const createMutation = useMutation({
  mutationFn: async (data) => {
    const response = await apiClient.post(API_ENDPOINTS.TICKETS, data);
    return response.data;
  },
  onSuccess: () => navigate('/tickets')
});
```

### 6. Comentarios

```typescript
// POST AGREGAR COMENTARIO
POST /Tickets/{id}/Comentarios
{
  "Contenido": "Esto es un comentario",
  "Privado": false
}
→ Response: { Exitoso: true, Datos: ComentarioDTO }

// GET COMENTARIOS (Incluidos en TicketDTO)
// Los comentarios vienen dentro del objeto Ticket

// Usado en: src/pages/TicketDetailPage.tsx
const comentarioMutation = useMutation({
  mutationFn: async (contenido) => {
    const response = await apiClient.post(
      API_ENDPOINTS.TICKETS_COMMENTS(ticketId),
      { Contenido: contenido, Privado: false }
    );
    return response.data;
  }
});
```

### 7. Referencias (Estados, Prioridades, etc.)

```typescript
// GET PRIORIDADES
GET /References/Prioridades
→ Response: { Exitoso: true, Datos: PrioridadDTO[] }

// GET ESTADOS
GET /References/Estados
→ Response: { Exitoso: true, Datos: EstadoDTO[] }

// GET DEPARTAMENTOS
GET /Departamentos
→ Response: { Exitoso: true, Datos: DepartamentoDTO[] }

// Usado en: src/pages/CreateTicketPage.tsx
const { data: prioridades } = useQuery({
  queryKey: ['prioridades'],
  queryFn: async () => {
    const response = await apiClient.get(API_ENDPOINTS.PRIORIDADES);
    return response.data.Datos;
  }
});
```

### 8. Admin - Usuarios

```typescript
// GET USUARIOS
GET /Admin/Usuarios
→ Response: { Exitoso: true, Datos: UsuarioDTO[] }

// Usado en: src/pages/UsuariosPage.tsx
const { data: usuarios } = useQuery({
  queryKey: ['usuarios'],
  queryFn: async () => {
    const response = await apiClient.get(API_ENDPOINTS.USUARIOS);
    return response.data.Datos || [];
  }
});
```

## 🔐 Manejo de Autenticación

### Token Storage

```typescript
// Guardar token
localStorage.setItem('token', loginResponse.Token);

// Recuperar token
const token = localStorage.getItem('token');

// Eliminar token (logout)
localStorage.removeItem('token');
```

### Headers Automáticos

```typescript
// El interceptor automáticamente agrega:
Authorization: Bearer <token_aqui>

// En cada petición si el token existe
```

### Refresh Token (Configurado pero no usado aún)

```typescript
// Podrías implementar:
apiClient.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      // Intentar refresh
      const newToken = await refreshToken();
      localStorage.setItem('token', newToken);
      // Reintentar petición con nuevo token
    }
  }
);
```

## 📊 Estado Global (Zustand)

### Auth Store

```typescript
import { useAuthStore } from '@/store/authStore';

// En componentes
const { user, token, isAuthenticated, login, logout } = useAuthStore();

// Métodos útiles
const hasAdmin = useAuthStore(state => state.isAdmin());
const hasPerm = useAuthStore(state => state.hasPermission('TICKET_CREATE'));
```

## 🚀 React Query - Server State

### Características Automáticas

```typescript
// 1. Caché automático (5 minutos por defecto)
// 2. Revalidación en foco de ventana
// 3. Background refetching
// 4. Retry automático en errores

// Personalizar:
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,        // 5 minutos
      gcTime: 1000 * 60 * 10,          // 10 minutos (antes cacheTime)
      retry: 3,                        // 3 intentos
      retryDelay: 1000                 // 1 segundo entre intentos
    }
  }
});
```

### Invalidar Caché

```typescript
// Después de crear/actualizar/eliminar, refrescar datos
const queryClient = useQueryClient();

const createMutation = useMutation({
  mutationFn: (data) => createTicket(data),
  onSuccess: () => {
    // Opción 1: Invalidar todo
    queryClient.invalidateQueries({ queryKey: ['tickets'] });
    
    // Opción 2: Invalidar específico
    queryClient.invalidateQueries({ queryKey: ['tickets', page] });
  }
});
```

## 🔗 CORS Configuration (API Side)

El frontend ya está configurado para CORS. En la API asegúrate de:

```csharp
// En Program.cs
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:5173", "http://localhost:5174")
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

app.UseCors("AllowFrontend");
```

## 🎨 Manejo de Errores Comunes

### 401 Unauthorized

```typescript
// Autom máticaticamente redirige a /login
// Token inválido o expirado
```

### 400 Bad Request

```typescript
// El servidor rechaza los datos
// Validar inputs en frontend
```

### 403 Forbidden

```typescript
// Sin permisos para hacer esa acción
// Verificar roles/permisos
```

### 500 Internal Server Error

```typescript
// Error en el servidor API
// Revisar logs de la API
```

## 🧪 Testing de Endpoints (Postman/Insomnia)

### Ejemplo Login
```
POST http://localhost:5000/api/v1/Auth/login
Content-Type: application/json

{
  "Usuario": "admin@ticketsapi.com",
  "Contraseña": "Admin123!"
}
```

### Ejemplo Get Tickets
```
GET http://localhost:5000/Tickets?Pagina=1&TamañoPagina=10
Authorization: Bearer <token_aqui>
```

## 📝 Notas Importantes

1. **API URL**: Configurable en `.env` (VITE_API_URL)
2. **Token**: Se guarda en localStorage
3. **Auto-logout**: En 401 (token expirado)
4. **Caché**: React Query maneja automáticamente
5. **Tipos**: Sincronizados con API - editarlos aquí cuando API cambie

## 🚀 Próximas Mejoras

- [ ] Refresh token automático
- [ ] Offline support con localStorage
- [ ] Optimistic updates (actualizar UI antes de response)
- [ ] WebSocket para updates en tiempo real
- [ ] Pagination cursor-based
- [ ] File upload para attachments

---

**Última actualización**: 3 de febrero de 2026
