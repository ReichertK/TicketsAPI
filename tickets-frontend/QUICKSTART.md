# Inicio Rápido

## 1. Verificar que la API esté corriendo

```bash
dotnet run --project TicketsAPI/TicketsAPI.csproj
# API en http://localhost:5000
```

## 2. Instalar e iniciar el frontend

```bash
cd tickets-frontend
npm install
npm run dev
```

Abrir `http://localhost:5173` en el navegador.

## 3. Login

Credenciales de prueba (seed):

| Usuario           | Contraseña | Rol           |
|--------------------|-----------|---------------|
| admin@demo.com     | admin123  | Administrador |
| supervisor@demo.com| admin123  | Supervisor    |
| operador@demo.com  | admin123  | Operador      |
| consulta@demo.com  | admin123  | Consulta      |

## 4. Navegación

| Ruta                   | Página                  | Acceso        |
|------------------------|-------------------------|---------------|
| `/`                    | Dashboard               | Todos          |
| `/tickets`             | Listado de tickets      | Todos          |
| `/tickets/nuevo`       | Crear ticket            | Operadores+    |
| `/tickets/:id`         | Detalle del ticket      | Todos          |
| `/tickets/:id/editar`  | Editar ticket           | Según permisos |
| `/usuarios`            | Gestión de usuarios     | Admin          |
| `/departamentos`       | Gestión departamentos   | Admin          |
| `/configuracion`       | Configuración           | Admin          |
| `/seguridad`           | RBAC (roles/permisos)   | Admin          |
| `/audit-logs`          | Logs de auditoría       | Admin          |
| `/ayuda`               | Manual de usuario       | Todos          |

## Troubleshooting

**No conecta a la API**: verificar que corre en el puerto configurado en `.env` (`VITE_API_URL`).

**Login no funciona**: verificar credenciales en la base de datos. Los usuarios seed se crean con `Database/seed.sql`.

**Puerto en uso**: Vite asigna el siguiente puerto disponible automáticamente.

**Errores en consola**: abrir DevTools (F12 → Console) para diagnóstico.
