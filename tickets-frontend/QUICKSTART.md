# Quick Start - Sistema de Tickets Frontend

## 🚀 Inicio Rápido (5 minutos)

### Paso 1: Asegúrate que la API está corriendo

```bash
# En otra terminal, en la carpeta TicketsAPI/
dotnet run --project TicketsAPI.csproj
# Debe estar en: http://localhost:5000
```

### Paso 2: Inicia el Frontend

```bash
cd tickets-frontend
npm run dev
```

### Paso 3: Abre en el navegador

```
http://localhost:5174
```

## 🔐 Login

### Datos de prueba (si existen)

```
Usuario: admin@ticketsapi.com
Contraseña: Admin123!
```

Si no funcionan, usa tus credenciales del sistema API.

## 📍 Páginas Disponibles

Una vez logueado:

| URL | Descripción |
|-----|------------|
| `/` | Dashboard con métricas |
| `/tickets` | Listado de todos los tickets |
| `/tickets/nuevo` | Crear nuevo ticket |
| `/tickets/:id` | Ver detalle del ticket |
| `/usuarios` | Gestión de usuarios (Admin) |
| `/departamentos` | Gestión de departamentos (Admin) |

## ⚡ Funcionalidades Clave Rápidas

### Dashboard
- Ver todas las métricas en tiempo real
- Gráficos de tickets por estado/prioridad/departamento

### Crear Ticket
1. Ir a "Tickets" → "Nuevo Ticket"
2. Completar formulario
3. Click "Crear Ticket"

### Ver Ticket
1. Ir a "Tickets"
2. Click en la fila del ticket
3. Ver detalles, comentarios, historial

### Comentar
1. En detalle del ticket
2. Scroll a "Comentarios"
3. Escribir y click "Agregar Comentario"

## 🔧 Troubleshooting Rápido

### "No puedo conectarme a la API"
```
❌ Error: CORS, conexión rechazada
✅ Solución: Verifica que API está corriendo en http://localhost:5000
```

### "El login no funciona"
```
❌ Error: Credenciales inválidas
✅ Solución: Verifica usuario en base de datos API
```

### "El front no carga"
```
❌ Error: Página en blanco
✅ Solución: Abre DevTools (F12) y revisa Console para errores
```

### "Port 5173 está en uso"
```
✅ El sistema usa automáticamente puerto 5174
```

## 📦 Estructura Minimalista

```
tickets-frontend/
├── src/
│   ├── pages/          ← Páginas principales
│   ├── components/     ← Componentes UI
│   ├── services/       ← HTTP requests
│   ├── store/          ← Estado global
│   ├── types/          ← TypeScript types
│   └── main.tsx        ← Inicio de app
├── .env                ← Config (API URL)
└── package.json        ← Dependencias
```

## 💡 Tips de Desarrollo

### Recargar sin perder estado
```bash
Ctrl+Shift+R (Windows)
Cmd+Shift+R (Mac)
```

### Ver estado global (Zustand)
```javascript
// En DevTools Console:
import { useAuthStore } from './store/authStore';
useAuthStore.getState()
```

### Inspeccionar queries (React Query)
```bash
# Instala React Query DevTools:
npm install @tanstack/react-query-devtools

# Se mostrará panel en esquina inferior derecha
```

## 🎓 Próximos Pasos

1. **Explorar Dashboard**: Ver todas las métricas
2. **Crear un Ticket**: Probar formulario de creación
3. **Comentar**: Agregar comentarios a tickets
4. **Admin Panel**: Ver usuarios y departamentos (si eres admin)

## 📞 Soporte

Si algo no funciona:

1. Revisa console (F12)
2. Verifica que API está corriendo (http://localhost:5000)
3. Revisa `.env` tenga `VITE_API_URL=http://localhost:5000`
4. Limpia cache browser (Ctrl+Shift+Del)

---

**¡Listo para empezar!** 🎉
