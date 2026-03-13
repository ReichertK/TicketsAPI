# Guía de Despliegue IIS — Cediac (Sistema de Tickets)

> Servidor: **YOUR_SERVER_HOSTNAME** (YOUR_SERVER_IP)  
> Sitio IIS: **YOUR_IIS_SITE_NAME** (Puerto YOUR_PORT)  
> Reemplaza: versión MVC anterior

---

## Arquitectura de Despliegue

**Despliegue monolítico**: La API .NET 6 sirve tanto los endpoints REST como los archivos estáticos del SPA React. Un solo sitio IIS, un solo Application Pool.

```
your-iis-site/              ← Carpeta física del sitio IIS
├── web.config                      ← Handler aspNetCore + WebDAV fix
├── TicketsAPI.dll                  ← Backend .NET 6
├── appsettings.json                ← Config base
├── appsettings.Production.json     ← Config producción (BD, JWT, CORS)
├── logs/                           ← Logs de Serilog + stdout
│   └── stdout_*.log
└── wwwroot/                        ← Frontend React (build de Vite)
    ├── index.html
    ├── favicon.svg
    └── assets/
        ├── index-*.css
        ├── index-*.js
        ├── vendor-base-*.js
        ├── vendor-api-*.js
        ├── vendor-ui-*.js
        └── ...
```

**Rutas resultantes:**
| URL | Manejador |
|---|---|
| `http://YOUR_SERVER_IP:YOUR_PORT/` | SPA (index.html) |
| `http://YOUR_SERVER_IP:YOUR_PORT/tickets` | SPA (React Router) |
| `http://YOUR_SERVER_IP:YOUR_PORT/ayuda` | SPA (React Router) |
| `http://YOUR_SERVER_IP:YOUR_PORT/api/v1/...` | API .NET |
| `http://YOUR_SERVER_IP:YOUR_PORT/hubs/tickets` | SignalR WebSocket |
| `http://YOUR_SERVER_IP:YOUR_PORT/health` | Health Check |
| `http://YOUR_SERVER_IP:YOUR_PORT/swagger` | Swagger (solo si habilitado) |

---

## Prerrequisitos (ya verificados)

- [x] **.NET 6 Hosting Bundle** — instalado (el MVC anterior ya corría en .NET 6)
- [x] **WebSockets** — instalado en IIS
- [ ] **URL Rewrite** — NO necesario (el SPA fallback lo maneja la API con `MapFallbackToFile`)

---

## Paso a Paso: Despliegue

### 1. Generar el artefacto (en tu máquina local)

```powershell
# Desde la raíz del repositorio
.\publish.ps1
```

Esto genera `publish\cediac-tickets_YYYYMMDD_HHmmss.zip` con todo listo.

### 2. En el servidor IIS

```powershell
# 1. Detener el sitio
Import-Module WebAdministration
Stop-Website -Name "YOUR_IIS_SITE_NAME"
Stop-WebAppPool -Name "YOUR_IIS_SITE_NAME"  # o el nombre del App Pool actual

# 2. Respaldar la versión anterior (por si acaso)
$SitePath = "C:\inetpub\wwwroot\YOUR_SITE_FOLDER"  # ← Ajustar a la ruta real
$BackupPath = "C:\Backups\YOUR_SITE_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item -Path $SitePath -Destination $BackupPath -Recurse

# 3. Limpiar carpeta del sitio
Get-ChildItem -Path $SitePath -Exclude "logs" | Remove-Item -Recurse -Force

# 4. Extraer el nuevo build
Expand-Archive -Path "C:\ruta\al\cediac-tickets_*.zip" -DestinationPath $SitePath -Force

# 5. Asegurar que la carpeta logs existe con permisos
if (-not (Test-Path "$SitePath\logs")) {
    New-Item -ItemType Directory -Path "$SitePath\logs" -Force
}

# 6. Iniciar el sitio
Start-WebAppPool -Name "YOUR_IIS_SITE_NAME"
Start-Website -Name "YOUR_IIS_SITE_NAME"
```

### 3. Verificar Application Pool

Si el App Pool actual tiene **.NET CLR version** configurada (ej: v4.0), cambiarla:

1. **IIS Manager** → **Application Pools** → seleccionar el pool del sitio
2. **Basic Settings**:
   - .NET CLR version: **No Managed Code**
   - Managed pipeline: **Integrated**
3. **Advanced Settings**:
   - **Start Mode**: `AlwaysRunning` (opcional, recomendado)

---

## Verificación Post-Despliegue

```powershell
# 1. Frontend carga correctamente
Invoke-WebRequest -Uri "http://YOUR_SERVER_IP:YOUR_PORT/" -UseBasicParsing | Select-Object StatusCode
# Esperado: 200

# 2. SPA routing funciona (no 404 al refrescar)
Invoke-WebRequest -Uri "http://YOUR_SERVER_IP:YOUR_PORT/tickets" -UseBasicParsing | Select-Object StatusCode
# Esperado: 200

# 3. API responde
Invoke-WebRequest -Uri "http://YOUR_SERVER_IP:YOUR_PORT/health" -UseBasicParsing | Select-Object StatusCode
# Esperado: 200

# 4. SignalR negotiate funciona
Invoke-WebRequest -Uri "http://YOUR_SERVER_IP:YOUR_PORT/hubs/tickets/negotiate?negotiateVersion=1" -Method POST -UseBasicParsing | Select-Object StatusCode
# Esperado: 200
```

---

## Configuración Incluida

### web.config (ya incluido en el .zip)

- **aspNetCore handler**: `hostingModel="inprocess"`, DLL: `TicketsAPI.dll`
- **WebDAV desactivado**: handler y módulo removidos (habilita PUT/DELETE)
- **WebSockets**: habilitado con ping interval de 30s para SignalR
- **stdout logging**: habilitado para diagnóstico → `logs\stdout_*.log`
- **Security headers**: `X-Content-Type-Options`, `X-Frame-Options`, HSTS

### appsettings.Production.json (incluido en el .zip)

- Conexión a BD: `YOUR_SERVER_IP:3306` → `tickets_db`
- JWT configurado (SecretKey, Issuer, Audience)
- CORS permite: `http://YOUR_SERVER_IP:YOUR_PORT`
- Swagger deshabilitado en producción
- Rate limiting activo en endpoints de SP

---

## Troubleshooting

| Problema | Causa probable | Solución |
|---|---|---|
| 502.5 Process Failure | Hosting Bundle no instalado o DLL incorrecta | Verificar .NET 6 Hosting Bundle y que `TicketsAPI.dll` existe |
| 500.30 Startup error | Error en config (BD, JWT key) | Revisar `logs\stdout_*.log` |
| 404 en `/tickets` | `MapFallbackToFile` no funciona | Verificar que `wwwroot\index.html` existe |
| 405 Method Not Allowed | WebDAV interceptando PUT/DELETE | Verificar que web.config tiene `<remove name="WebDAV" />` |
| SignalR cae a Long Polling | WebSockets no habilitado en IIS | `Install-WindowsFeature Web-WebSockets` + `iisreset` |
| CORS blocked | Origen no listado | Agregar el origen a `Cors:AllowedOrigins` en appsettings.Production.json |
| Página en blanco | Assets no cargando | F12 → Network → verificar que `/assets/*.js` devuelvan 200 |
| Login no funciona | SecretKey diferente entre sesiones | Reiniciar el App Pool para cargar la nueva config |

---

## Rollback

Si algo falla, restaurar el backup:

```powershell
Stop-Website -Name "YOUR_IIS_SITE_NAME"
$SitePath = "C:\inetpub\wwwroot\YOUR_SITE_FOLDER"
$BackupPath = "C:\Backups\YOUR_SITE_YYYYMMDD_HHMMSS"  # ← el backup más reciente
Remove-Item -Path "$SitePath\*" -Recurse -Force
Copy-Item -Path "$BackupPath\*" -Destination $SitePath -Recurse
Start-Website -Name "YOUR_IIS_SITE_NAME"
```
