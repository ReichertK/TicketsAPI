# Reporte de Misión: Testeo de Casos Extraordinarios y Escalabilidad

**Fecha:** 2026-02-20  
**Versión API:** 1.0 — ASP.NET Core 6 + Dapper + MySQL 5.5  
**Frontend:** React 19 + TypeScript + Vite 7 + TailwindCSS 4

---

## Resumen Ejecutivo

| Test | Resultado | Acción |
|------|-----------|--------|
| T1: Resiliencia Notificaciones | ✅ PASS (845ms / 676ms) | No requiere Background Service |
| T2: Sanitización XSS/UTF-8 | ⚠️ PARCIAL | XSS inerte, pero emoji/kanji falla (latin1) |
| T3: Brute Force | ✅ IMPLEMENTADO | 5 intentos → bloqueo 15 min |
| T4: Escalabilidad Auditoría | ⚠️ LENTO en COUNT | Recomendar particionamiento por año |
| Frontend AuditLogsPage | ✅ COMPLETADO | Timeline semántica + filtros + paginación |
| INotificationProvider | ✅ IMPLEMENTADO | SignalR desacoplado vía interfaz |
| DTOs Versionados /api/v1/ | ✅ CONFIRMADO | Ya existía en BaseApiController |

---

## T1: Test de Resiliencia de Notificaciones

### Procedimiento
- Creación de 200 usuarios de prueba (IDs 1000-1199)
- Suscripción de los 200 al ticket #1 vía `tkt_suscriptor`
- Transición de estado del ticket (estado 1→2) con medición de tiempo

### Resultados
| Métrica | Valor |
|---------|-------|
| Transición 1 (estado 1→2) | **845ms** |
| Transición 2 (reset + re-transición) | **676ms** |
| Suscriptores verificados | 200 |
| Threshold aceptable | < 1000ms |

### Hallazgo Clave
`NotificacionService` usa `Clients.All.SendAsync()` (broadcast a TODOS los clientes SignalR conectados), **no** itera por suscriptor en la DB. El conteo de suscriptores en `tkt_suscriptor` no impacta el tiempo de notificación.

### Veredicto
**No requiere Background Service** a la escala actual. El cuello de botella sería si hubiera miles de conexiones WebSocket simultáneas, no miles de suscriptores en DB.

---

## T2: Test de Sanitización XSS/UTF-8

### Procedimiento
- Intento de crear departamento con: `<script>alert('xss')</script> 😊 漢字`

### Resultados

| Prueba | Resultado |
|--------|-----------|
| XSS `<script>alert(123)</script>` | ✅ Almacenado como texto plano (inerte) |
| Emojis (😊) | ❌ **FALLA** — latin1 no soporta UTF-8 4-byte |
| Kanji (漢字) | ❌ **FALLA** — latin1 no soporta caracteres CJK |

### Hallazgo Crítico
La tabla `departamento.Nombre` usa charset **latin1** con collation **latin1_swedish_ci**. MySQL 5.5 silenciosamente descarta o corrompe caracteres fuera del rango latin1.

### Recomendación
```sql
-- Migración futura (requiere ventana de mantenimiento)
ALTER DATABASE cdk_tkt_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE departamento CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- Repetir para todas las tablas
```

---

## T3: Test de Seguridad Brute Force

### Diagnóstico Inicial
- La tabla `failed_login_attempts` existía pero **NO ERA UTILIZADA** por `AuthService`
- 10 intentos fallidos → 0 registros en la tabla
- Sin campos `intentos_fallidos` ni `bloqueado_hasta` en `usuario`

### Implementación

#### Migración SQL: `migrations/001_brute_force_protection.sql`
- `ALTER TABLE usuario ADD intentos_fallidos INT DEFAULT 0`
- `ALTER TABLE usuario ADD bloqueado_hasta DATETIME NULL`
- `ADD INDEX idx_fla_usuario_fecha` en `failed_login_attempts`

#### Servicio: `BruteForceProtectionService.cs`
| Método | Función |
|--------|---------|
| `VerificarBloqueoAsync(usuario)` | Verifica si la cuenta está bloqueada; auto-desbloquea si expiró |
| `RegistrarIntentoFallidoAsync(usuario, ip)` | Incrementa contador; bloquea después de 5 intentos |
| `LimpiarIntentosAsync(usuario)` | Resetea contador y desbloquea tras login exitoso |

#### Configuración
| Parámetro | Valor |
|-----------|-------|
| MaxIntentosFallidos | 5 |
| MinutosBloqueo | 15 |

### Validación
```
Intento 1-5: Status 401 (contraseña incorrecta)
Intento 6:   Status 401 (cuenta bloqueada)
Login correcto durante bloqueo: Status 401 (rechazado)
DB: intentos_fallidos=5, bloqueado_hasta=+15min
failed_login_attempts: 5 registros con IP y timestamp
```

---

## T4: Escalabilidad de Auditoría (1M+ registros)

### Setup
- audit_log poblado con **~1.73M registros** (202 MB data + 236 MB indexes)
- Rango de fechas: 2024-02-22 → 2026-02-21
- 4 índices compuestos existentes

### Benchmarks

| Query | Tiempo | Evaluación |
|-------|--------|------------|
| COUNT(*) con WHERE tabla+fecha (1 mes) | **24s** | ❌ Inaceptable |
| COUNT(*) con WHERE usuario+fecha (1 mes) | **8s** | ⚠️ Lento |
| SELECT con LIMIT 20 + WHERE tabla+fecha | **2.1s** | ✅ Aceptable |
| EXPLAIN SELECT con WHERE tabla+fecha | index scan, rows=1 | ✅ Usa índice |
| SELECT desde information_schema.TABLES | **<0.5s** | ✅ Instantáneo |

### Recomendación: Particionamiento por Año

MySQL 5.5 soporta particionamiento RANGE. Se recomienda para la siguiente fase:

```sql
ALTER TABLE audit_log PARTITION BY RANGE (YEAR(fecha)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
);
```

**Nota:** MySQL 5.5 requiere que la columna de partición sea parte de TODOS los unique keys. Si `id_auditoria` es PK auto_increment, se necesitaría cambiar a `PRIMARY KEY (id_auditoria, fecha)`.

### Estrategia Adoptada para el Frontend
- Se usa `information_schema.TABLES.TABLE_ROWS` para el conteo estimado (instantáneo)
- Conteo exacto limitado a 10,001 resultados max (`SELECT 1 ... LIMIT 10001`)
- Paginación con `LIMIT/OFFSET` (2s por página — aceptable)
- Frontend usa `staleTime: 5min` para cache de stats

---

## Frontend: Dashboard de Auditoría

### Ruta: `/admin/logs` (solo Administrador)

### Componentes Implementados

| Componente | Descripción |
|------------|-------------|
| **StatCards** | 4 tarjetas: Total estimado, Tablas auditadas, Tipos de acción, Rango de fechas |
| **Action Badges** | Botones filtrables por acción con colores semánticos |
| **Timeline** | Entradas expandibles con diff de valores (JSON) |
| **Filtros** | Tabla, Acción, Fecha desde/hasta, Búsqueda global |
| **Paginación** | Navegación por páginas con quick-buttons |

### Colores Semánticos

| Acción | Color |
|--------|-------|
| INSERT | 🟢 Emerald (verde) |
| UPDATE | 🔵 Blue (azul) |
| DELETE | 🔴 Red (rojo) |
| TOGGLE | 🟡 Amber (ámbar) |
| LOGIN | 🟣 Violet |
| LOGOUT | ⚪ Slate |

### Endpoints Backend

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `GET /api/v1/AuditLogs` | GET | Listado paginado con filtros |
| `GET /api/v1/AuditLogs/stats` | GET | Estadísticas resumidas |
| `GET /api/v1/AuditLogs/filters` | GET | Opciones de filtro (tablas/acciones) |

---

## Arquitectura: INotificationProvider

### Problema
`NotificacionService` estaba hardcodeado a SignalR (`IHubContext<TicketHub>`).

### Solución
```
INotificationProvider (interfaz)
    ├── SignalRNotificationProvider (implementación actual)
    ├── WhatsAppNotificationProvider (futuro)
    ├── EmailNotificationProvider (futuro)
    └── SlackNotificationProvider (futuro)
```

### Archivos Creados/Modificados

| Archivo | Cambio |
|---------|--------|
| `Services/Interfaces/INotificationProvider.cs` | **NUEVO** — Interfaz con BroadcastAsync, SendToUserAsync, SendToGroupAsync |
| `Services/Implementations/SignalRNotificationProvider.cs` | **NUEVO** — Implementación SignalR |
| `Services/Implementations/NotificacionService.cs` | **REFACTORIZADO** — Usa `INotificationProvider` en lugar de `IHubContext` directo |
| `Program.cs` | Registra `INotificationProvider → SignalRNotificationProvider` |

### Para cambiar de proveedor
Solo se necesita crear una nueva implementación (e.g., `SlackNotificationProvider`) y cambiar una línea en `Program.cs`:
```csharp
builder.Services.AddSingleton<INotificationProvider, SlackNotificationProvider>();
```

---

## DTOs Versionados: /api/v1/

**Estado:** ✅ Ya implementado desde el diseño original.

`BaseApiController` tiene `[Route("api/v1/[controller]")]` como atributo de clase. Todos los controllers heredan de `BaseApiController`, por lo que **todos los endpoints ya están bajo `/api/v1/`**.

El nuevo `AuditLogsController` también hereda de `BaseApiController`, quedando automáticamente en `/api/v1/AuditLogs`.

---

## Archivos Creados/Modificados en Esta Sesión

### Nuevos
| Archivo | Propósito |
|---------|-----------|
| `migrations/001_brute_force_protection.sql` | Migración: campos brute force en usuario |
| `TicketsAPI/Services/Implementations/BruteForceProtectionService.cs` | Servicio de protección brute force |
| `TicketsAPI/Services/Interfaces/INotificationProvider.cs` | Interfaz de abstracción de notificaciones |
| `TicketsAPI/Services/Implementations/SignalRNotificationProvider.cs` | Implementación SignalR del provider |
| `TicketsAPI/Controllers/AuditLogsController.cs` | Controller REST para audit_log |
| `tickets-frontend/src/pages/AuditLogsPage.tsx` | Página React de auditoría |

### Modificados
| Archivo | Cambio |
|---------|--------|
| `TicketsAPI/Services/Implementations/AuthService.cs` | +BruteForceProtectionService integration |
| `TicketsAPI/Services/Implementations/NotificacionService.cs` | Refactorizado a INotificationProvider |
| `TicketsAPI/Program.cs` | +BruteForceProtectionService, +INotificationProvider DI |
| `TicketsAPI/Models/DTOs.cs` | +AuditLogDTO, +AuditLogFiltroDTO, +AuditLogStatsDTO |
| `tickets-frontend/src/config/api.ts` | +AUDIT_LOGS endpoints |
| `tickets-frontend/src/types/api.types.ts` | +AuditLog types |
| `tickets-frontend/src/main.tsx` | +Ruta /admin/logs |
| `tickets-frontend/src/components/Layout.tsx` | +Navegación "Auditoría" |

---

## Datos de Prueba (Cleanup)

| Dato | Estado |
|------|--------|
| 200 usuarios test (IDs 1000-1199) | ✅ Eliminados |
| 200 suscripciones test | ✅ Eliminadas |
| Departamento XSS (ID 86) | ✅ Eliminado |
| Intentos fallidos de Admin | ✅ Limpiados |
| audit_log ~1.73M registros | ⚠️ **CONSERVADOS** para benchmarks futuros |
| SP `sp_fill_audit_fast` | ⚠️ En DB (puede eliminarse con `DROP PROCEDURE`) |
