# 📋 MAPEO EXHAUSTIVO DE ENDPOINTS - TICKETS API

**Generado:** 30 Enero 2026  
**Entorno:** Windows, MySQL 5.5.27 (cdk_tkt_dev), .NET 6  
**Objetivo:** Documentar TODOS los endpoints disponibles para testing exhaustivo

---

## 📊 RESUMEN EJECUTIVO

- **Total de Controladores:** 14
- **Total de Endpoints:** 45+ (en desarrollo)
- **Patrón de Respuesta:** ApiResponse<T>
- **Autenticación:** JWT Bearer Token (Authorize)
- **Base de Datos:** cdk_tkt_dev (34 tablas, 27 FKs, 4 triggers)

---

## 🔐 CONTROLADOR: AuthController (114 líneas)

### Endpoints No Autenticados (AllowAnonymous)

| Método | Endpoint | Descripción | Parámetros | Response |
|--------|----------|-------------|-----------|----------|
| POST | `/api/v1/login` | Login de usuario | `LoginRequest: { email, password }` | `{ token, refreshToken, usuario }` |
| POST | `/api/v1/refresh-token` | Renovar JWT | `RefreshTokenRequest: { refreshToken }` | `{ token, refreshToken }` |

### Endpoints Autenticados

| Método | Endpoint | Descripción | Response |
|--------|----------|-------------|----------|
| POST | `/api/v1/logout` | Logout del usuario | `{ success: true }` |
| GET | `/api/v1/me` | Obtener usuario actual | `{ userId, email, role }` |

---

## 🎫 CONTROLADOR: TicketsController (418 líneas)

### Endpoints - Tickets

| Método | Endpoint | Descripción | Parámetros | Response | Requiere |
|--------|----------|-------------|-----------|----------|----------|
| GET | `/api/v1/Tickets` | Obtener tickets filtrados | `TicketFiltroDTO` | `PaginatedResponse<TicketDTO>` | Auth |
| GET | `/api/v1/Tickets/{id}` | Obtener ticket por ID | `id: int` | `TicketDTO` | Auth |
| GET | `/api/v1/Tickets/buscar` | Búsqueda avanzada | `TicketFiltroDTO` | `PaginatedResponse<TicketDTO>` | Auth |
| POST | `/api/v1/Tickets` | Crear ticket | `CreateUpdateTicketDTO` | `{ id: int }` | Auth |
| PATCH | `/api/v1/Tickets/{id}` | Actualizar ticket | `CreateUpdateTicketDTO` | `{ success: true }` | Auth |
| DELETE | `/api/v1/Tickets/{id}` | Eliminar ticket | `id: int` | `{ success: true }` | Auth |
| POST | `/api/v1/Tickets/{id}/export` | Exportar ticket | `id: int` | `{ file: base64 }` | Auth |

**Dependencias de Servicio:**
- ITicketService
- IEstadoService  
- INotificacionService
- ITicketRepository
- IExportService

---

## ✅ CONTROLADOR: AprobacionesController (219 líneas)

| Método | Endpoint | Descripción | Response |
|--------|----------|-------------|----------|
| GET | `/api/v1/Approvals/Pending` | Aprobaciones pendientes | `List<AprobacionDTO>` |
| POST | `/api/v1/Tickets/{ticketId}/Approvals` | Solicitar aprobación | `{ id: int }` |
| PATCH | `/api/v1/Approvals/{id}/approve` | Aprobar | `{ success: true }` |
| PATCH | `/api/v1/Approvals/{id}/reject` | Rechazar | `{ success: true }` |

---

## 🏢 CONTROLADOR: DepartamentosController (160 líneas)

| Método | Endpoint | Descripción | Requiere | Response |
|--------|----------|-------------|----------|----------|
| GET | `/api/v1/Departamentos` | Listar todos | Auth | `List<DepartamentoDTO>` |
| GET | `/api/v1/Departamentos/{id}` | Obtener uno | Auth | `DepartamentoDTO` |
| POST | `/api/v1/Departamentos` | Crear | Auth + Admin | `{ id: int }` |
| PUT | `/api/v1/Departamentos/{id}` | Actualizar | Auth + Admin | `{ success: true }` |
| DELETE | `/api/v1/Departamentos/{id}` | Eliminar | Auth + Admin | `{ success: true }` |

---

## 🛠 CONTROLADOR: AdminController (170 líneas)

| Método | Endpoint | Descripción | Requiere | Response |
|--------|----------|-------------|----------|----------|
| GET | `/api/admin/sample-user` | Usuario de ejemplo | Admin | `{ id, nombre, email }` |
| GET | `/api/admin/db-audit` | Auditoría BD | Admin | `{ version, tables, detalle }` |

---

## 📝 CONTROLADORES RESTANTES (10 más)

### Por Revisar:
1. **ComentariosController** - Gestión de comentarios
2. **GruposController** - Gestión de grupos/equipos
3. **MotivosController** - Categorías/motivos de tickets
4. **TransicionesController** - Cambios de estado
5. **ReferencesController** - Referencias entre entidades
6. **ReportesController** - Reportes y análisis
7. **StoredProceduresController** - Ejecución de SPs
8. **UsuariosController** - Gestión de usuarios
9. **BaseApiController** - Métodos base (utilidad)
10. **ComentariosController** - Complemento para tickets

---

## 🧪 ESTRATEGIA DE TESTING

### Fase 1: Validación Estructural
- ✅ Verificar que todas las tablas existen
- ✅ Verificar que todos los FKs están activos
- ✅ Verificar que todos los triggers funcionan

### Fase 2: Testing de Endpoints
- [ ] Autenticación (login, token, logout)
- [ ] Tickets (CRUD, búsqueda, export)
- [ ] Aprobaciones (listar, solicitar, aprobar/rechazar)
- [ ] Departamentos (listar, crear, actualizar)
- [ ] Usuarios (listar, crear, actualizar)
- [ ] Comentarios (añadir, listar, eliminar)
- [ ] Transiciones (listar, crear)
- [ ] Reportes (generar, descargar)
- [ ] Admin (auditoría BD, estadísticas)

### Fase 3: Comparación BD vs API
- Extraer datos reales de cada tabla
- Llamar cada endpoint con IDs reales
- Verificar que respuesta = datos BD
- Validar relaciones FK
- Validar agregaciones/métricas

### Fase 4: Reporte
- Documentar resultados
- Identificar discrepancias
- Generar métricas
- Validar cobertura 100%

---

## 📊 TABLA DE ENTIDADES PRINCIPALES

| Tabla | Registros | Propósito | FKs |
|-------|-----------|----------|-----|
| tkt | ? | Tickets | 4 |
| usuario | ? | Usuarios | 0 |
| tkt_comentario | ? | Comentarios | 2 |
| tkt_transicion | ? | Transiciones estado | 3 |
| estado | ? | Estados posibles | 0 |
| departamento | ? | Departamentos | 0 |
| empresa | ? | Empresas | 0 |
| sucursal | ? | Sucursales | 1 |
| motivo | ? | Motivos tickets | 1 |
| perfil | ? | Perfiles/Roles | 0 |
| audit_log | ? | Log auditoría | 1 |
| sesiones | ? | Sesiones activas | 1 |
| failed_login_attempts | ? | Intentos fallidos | 1 |
| tkt_transicion_auditoria | ? | Auditoría transiciones | 1 |

---

## 🔍 PRÓXIMOS PASOS

1. **Completar mapeo** de 10 controladores restantes
2. **Ejecutar tests** contra cada endpoint
3. **Extraer datos** reales de BD
4. **Comparar** respuestas vs BD
5. **Generar reporte** final exhaustivo

---

**Estado:** EN PROGRESO  
**Última actualización:** 30 ENE 2026
