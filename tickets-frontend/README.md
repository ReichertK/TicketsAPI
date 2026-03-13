# Sistema de Tickets - Frontend

Frontend moderno y funcional para la API REST de Sistema de Tickets, desarrollado con React, TypeScript, Tailwind CSS y Vite.

## 🚀 Características

- ✅ **Autenticación JWT**: Login seguro con tokens y refresh tokens
- ✅ **Dashboard**: Métricas en tiempo real (total, abiertos, cerrados, en proceso)
- ✅ **Gestión de Tickets**: Crear, ver, buscar y filtrar tickets
- ✅ **Comentarios**: Sistema de comentarios para tickets
- ✅ **Historial**: Seguimiento de cambios en cada ticket
- ✅ **Panel Administrativo**: Gestión de usuarios y departamentos
- ✅ **Interfaz Responsiva**: Diseño mobile-first con Tailwind CSS
- ✅ **Estado Global**: Gestión con Zustand
- ✅ **Caché Inteligente**: React Query con caching automático
- ✅ **TypeScript**: Type-safe en todo el proyecto

## 📋 Requisitos Previos

- Node.js 18+ (si no tienes, descarga desde [nodejs.org](https://nodejs.org))
- npm o yarn
- API corriendo en `http://localhost:5000`

## 🛠️ Instalación y Setup

### 1. Clonar/Navegar al proyecto

```bash
cd tickets-frontend
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
VITE_API_URL=http://localhost:5000
```

### 4. Iniciar servidor de desarrollo

```bash
npm run dev
```

El proyecto estará disponible en: **http://localhost:5174**

## 📦 Stack Tecnológico

| Tecnología | Versión | Propósito |
|-----------|---------|----------|
| **React** | 19.2.4 | Framework UI |
| **TypeScript** | 5.x | Type safety |
| **Vite** | 7.3.1 | Build tool |
| **Tailwind CSS** | 4.x | Styling |
| **React Router** | 7.x | Routing |
| **Axios** | 1.x | HTTP client |
| **React Query** | 5.x | Server state management |
| **Zustand** | 4.x | Client state management |
| **Lucide React** | 0.x | Icons |

## 📁 Estructura del Proyecto

```
tickets-frontend/
├── src/
│   ├── components/          # Componentes reutilizables
│   │   ├── Layout.tsx        # Layout principal con sidebar
│   │   └── ProtectedRoute.tsx # Ruta protegida
│   ├── pages/               # Páginas completas
│   │   ├── LoginPage.tsx
│   │   ├── DashboardPage.tsx
│   │   ├── TicketsPage.tsx
│   │   ├── CreateTicketPage.tsx
│   │   ├── TicketDetailPage.tsx
│   │   ├── UsuariosPage.tsx
│   │   └── DepartamentosPage.tsx
│   ├── config/              # Configuración
│   │   └── api.ts           # Endpoints API
│   ├── types/               # Tipos TypeScript
│   │   └── api.types.ts     # DTOs y interfaces
│   ├── services/            # Servicios API
│   │   └── api.service.ts   # Cliente HTTP con Axios
│   ├── store/               # Estado global
│   │   └── authStore.ts     # Store de autenticación
│   ├── index.css            # Estilos globales
│   └── main.tsx             # Entry point
├── public/                  # Archivos estáticos
├── .env                     # Variables de entorno
├── vite.config.ts           # Configuración Vite
├── tsconfig.json            # Configuración TypeScript
├── tailwind.config.js       # Configuración Tailwind
└── package.json             # Dependencias
```

## 🔐 Autenticación

### Usuarios de Prueba

Se proporciona una página de login con sugerencia de credenciales:

- **Usuario Admin**: `admin@ticketsapi.com`
- **Contraseña**: `Admin123!` (si existe, usar la que tengas configurada)

### Token Management

- Los tokens se almacenan en `localStorage`
- Se agregan automáticamente al header `Authorization: Bearer <token>`
- Si el token expira (401), se redirige a login
- Se implementa refresh token para renovación automática

## 📝 Funcionalidades por Página

### 1. Login
- Formulario de autenticación
- Manejo de errores
- Redirección automática si ya está logueado

### 2. Dashboard
- Métricas generales (Total, Abiertos, Cerrados, En Proceso)
- Tiempo promedio de resolución
- Tasa de cumplimiento SLA
- Gráficos de distribución:
  - Por estado
  - Por prioridad
  - Por departamento

### 3. Tickets
- **Listado**: Tabla paginada con búsqueda y filtros
- **Crear**: Formulario con validaciones
- **Detalle**: 
  - Información completa del ticket
  - Comentarios y respuestas
  - Historial de cambios
  - Asignación y transiciones de estado

### 4. Usuarios (Admin)
- Listado con información:
  - Nombre y apellido
  - Email
  - Rol
  - Departamento
  - Estado (Activo/Inactivo)
  - Última sesión

### 5. Departamentos (Admin)
- Listado con información:
  - Nombre
  - Descripción
  - Estado (Activo/Inactivo)

## 🔗 Integración con API

### Endpoints Utilizados

```typescript
// Auth
POST /Auth/login
POST /Auth/refresh-token

// Tickets
GET /Tickets (listado paginado)
GET /Tickets/{id} (detalle)
POST /Tickets (crear)
POST /Tickets/{id}/Comentarios (agregar comentario)
GET /Tickets/{id}/Comentarios (listar comentarios)

// Dashboard
GET /Reportes/Dashboard (métricas)

// Admin
GET /Admin/Usuarios (listado de usuarios)
GET /Departamentos (listado de departamentos)

// Referencias
GET /References/Estados
GET /References/Prioridades
GET /Motivos
```

### Client HTTP (Axios)

```typescript
// Crear cliente con interceptores
import { apiClient } from '@/services/api.service';

// GET request
const response = await apiClient.get('/endpoint');

// POST request
const response = await apiClient.post('/endpoint', { data });

// Autenticación automática
// El token se agrega automáticamente en el header
```

## 🎨 Temas y Estilos

### Tailwind CSS

El proyecto usa Tailwind CSS para todos los estilos:

- **Colores**:
  - Primario: Blue (600)
  - Éxito: Green (500)
  - Advertencia: Yellow/Orange (500)
  - Error: Red (500)
  - Secundario: Gray (600)

- **Componentes predefinidos**:
  - Botones
  - Inputs
  - Cards
  - Modals
  - Tables
  - Badges

## 🚀 Compilación para Producción

```bash
npm run build
```

Esto generará la carpeta `dist/` con los archivos optimizados.

Para previsualizar el build:

```bash
npm run preview
```

## 🐛 Debugging

### Variables de Entorno para Debug

Puedes agregar a `.env`:

```env
VITE_API_URL=http://localhost:5000
VITE_DEBUG=true
```

### Console Logs

Los interceptores de Axios logran la información en consola:

```bash
# Ver en DevTools (F12) → Console
```

### React DevTools

Instala la extensión [React DevTools](https://chrome.google.com/webstore/detail/react-developer-tools/) para Chrome.

## 📦 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `npm run dev` | Inicia servidor de desarrollo |
| `npm run build` | Compila para producción |
| `npm run preview` | Previsualiza build de producción |
| `npm run lint` | Ejecuta linter (si se configura) |

## 🔄 Flujos de Trabajo Principales

### Crear un Ticket

1. Click en "Nuevo Ticket" (Dashboard)
2. Completa el formulario:
   - Descripción (min 10 caracteres)
   - Prioridad (Baja, Media, Alta, Crítica)
   - Departamento
3. Click en "Crear Ticket"
4. Redirección a detalle del ticket

### Comentar en un Ticket

1. Abrir detalle del ticket
2. Scroll a la sección "Comentarios"
3. Escribir comentario en textarea
4. Click en "Agregar Comentario"
5. Se actualiza lista automáticamente

### Filtrar Tickets

1. Ir a sección Tickets
2. Usar barra de búsqueda para texto
3. Click en "Filtros" para opciones avanzadas (futuro)

### Ver Dashboard

- **Dashboard**: Acceso directo desde inicio
- Métricastodas en tiempo real
- Se actualiza automáticamente al cambiar tickets

## 🔑 Gestión de Estado

### Zustand (Cliente)

```typescript
import { useAuthStore } from '@/store/authStore';

// En componente
const { user, isAuthenticated, login, logout } = useAuthStore();

// Métodos disponibles
useAuthStore.getState().hasPermission('ADMIN_ACCESS')
useAuthStore.getState().isAdmin()
```

### React Query (Servidor)

```typescript
import { useQuery, useMutation } from '@tanstack/react-query';

// Query
const { data, isLoading, error } = useQuery({
  queryKey: ['tickets'],
  queryFn: () => fetchTickets()
});

// Mutation
const { mutate, isPending } = useMutation({
  mutationFn: (data) => createTicket(data),
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['tickets'] })
});
```

## 🚨 Manejo de Errores

### Errores de API

Los errores se manejan automáticamente en:

1. **Interceptor Response**: Redirección en 401
2. **Componentes**: Try-catch en queries/mutations
3. **UI**: Mensajes de error en alerts

```typescript
catch (error) {
  setError(error.response?.data?.Mensaje || 'Error general');
}
```

## 📱 Responsividad

El proyecto es totalmente responsive:

- **Mobile**: Sidebar colapsable, touch-friendly
- **Tablet**: Grid de 2 columnas
- **Desktop**: Layout completo con sidebar

## 🔐 Seguridad

- ✅ Token en localStorage
- ✅ CORS habilitado en API
- ✅ Validación de inputs en forms
- ✅ XSS prevention con React
- ✅ CSRF ready (agregar CSRF token si es necesario)

## 📞 Soporte y Contribución

Para problemas o mejoras:

1. Revisa la [API documentation](../README.md)
2. Verifica los logs en DevTools
3. Confirma que API está corriendo en puerto 5000

## 📄 Licencia

Mismo que el proyecto principal (TicketsAPI)

---

**Última actualización**: 3 de febrero de 2026
**Versión**: 1.0.0
**Estado**: ✅ Listo para desarrollo
