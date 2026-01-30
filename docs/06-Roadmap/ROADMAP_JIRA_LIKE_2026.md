# Roadmap Jira-Like & Robustez - TicketsAPI

**Fecha Generación:** 30 de enero de 2026  
**Estado Actual:** API .NET 6 con 30 tablas, 45/47 tests pasando (95.7%)  
**Objetivo:** Evolucionar hacia Jira Service Management enterprise-ready

---

## 1. BRECHAS IDENTIFICADAS

### 1.1 CRÍTICAS - Seguridad & Funcionalidad Básica

#### 1.1.1 Autenticación Incompleta
| Brecha | Impacto | Estado Actual | Solución |
|--------|---------|---------------|----------|
| **RefreshToken** no implementado | Tokens expiran sin opción de renovación | `RefreshTokenAsync()` devuelve `null` | Implementar lógica de refresh con rotación |
| **ValidarPermisoAsync()** siempre retorna `false` | Validación de permisos no funciona | Servicio desactivado | Mapear permisos reales desde tabla `rol_permiso` |
| Endpoints `/api/admin/*` sin autenticación | Datos sensibles expuestos | Anónimo | Requieren rol `Admin` |
| **Usuarios sin CRUD endpoints** | No hay gestión de usuarios via API | Solo login en AuthController | Crear `UsuariosController` |

**Tiempo Estimado:** 3-4 días  
**Dependencias:** Ninguna  
**Prioridad:** 🔴 CRÍTICA

---

#### 1.1.2 Errores de Lógica & Bugs

| Brecha | Impacto | Evidencia | Solución |
|--------|---------|-----------|----------|
| **PoliticaTransicionRepository** referencia tabla inexistente | SP fail en transiciones | Usa `PoliticasTransicion`, existe `tkt_transicion_regla` | Mapear correctamente a `tkt_transicion_regla` |
| **ComentarioRepository workaround LAST_INSERT_ID()** | Retorno incorrecto de ID | Usa SQL injection prone | Usar Dapper output parameters |
| **Búsqueda de tickets** sin sanitización | SQLi potencial en búsqueda | Campo `Term` en `tkt_search` sin validación | Validar entrada y usar parámetros seguros |
| **Logs sin correlación de errores** | Debugging imposible en prod | Serilog sin RequestId | Usar middleware de correlación |

**Tiempo Estimado:** 2-3 días  
**Dependencias:** Auditoría de código completada  
**Prioridad:** 🔴 CRÍTICA

---

### 1.2 IMPORTANTES - Features Jira MVP

#### 1.2.1 Service Catalog (Catálogo de Servicios)

**Descripción:** Estructura de servicios/productos/categorías que usuarios solicitan.

| Componente | Tablas Nuevas | Endpoints | Lógica |
|------------|--------------|-----------|--------|
| **Service Catalog** | `servicios`, `servicios_grupos`, `servicios_campos_custom` | `GET /api/servicios`, `GET /api/servicios/{id}` | Listar servicios disponibles por rol |
| **Request Types** | Extiende `servicios` | `GET /api/servicios/{id}/request-types` | Tipos de solicitud por servicio |
| **Custom Fields** | `servicios_campos_custom` | Dynamic en CRUD de tickets | Campos específicos por tipo de solicitud |

**Mockup BD:**
```sql
CREATE TABLE servicios (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(255),
  descripcion TEXT,
  icon VARCHAR(50),
  color VARCHAR(7),
  activo BOOLEAN,
  orden INT
);

CREATE TABLE servicios_grupos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_servicio INT,
  id_grupo INT,
  acceso_full BOOLEAN,
  FOREIGN KEY (id_servicio) REFERENCES servicios(id),
  FOREIGN KEY (id_grupo) REFERENCES grupo(Id_Grupo)
);
```

**Tiempo Estimado:** 4-5 días  
**Dependencias:** Usuarios CRUD completado  
**Prioridad:** 🟡 ALTA

---

#### 1.2.2 SLAs (Service Level Agreements)

**Descripción:** Tiempos de respuesta y resolución por servicio/prioridad.

| Componente | Tablas Nuevas | Lógica | Validación |
|------------|--------------|--------|-----------|
| **SLA Rules** | `slas`, `sla_horas_laborales` | Calcular vencimiento por servicio+prioridad | Alertas automáticas cuando se aproxime |
| **SLA Breaches** | `sla_history` | Registrar cuando se excede SLA | Escalación automática |
| **Response Time** | Extiende `tkt` | `tiempo_respuesta_promedio` | KPI en reportes |
| **Resolution Time** | Extiende `tkt` | `tiempo_resolucion_promedio` | Métrica principal |

**Mockup BD:**
```sql
CREATE TABLE slas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_servicio INT,
  id_prioridad INT,
  minutos_respuesta INT,
  minutos_resolucion INT,
  lunes_inicio TIME, lunes_fin TIME,
  -- ... martes a domingo
  FOREIGN KEY (id_servicio) REFERENCES servicios(id),
  FOREIGN KEY (id_prioridad) REFERENCES prioridad(Id_Prioridad)
);

CREATE TABLE sla_history (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_tkt INT,
  sla_id INT,
  breached_response BOOLEAN,
  breached_resolution BOOLEAN,
  fecha_brecha TIMESTAMP
);
```

**Endpoints:**
```
GET /api/slas
POST /api/slas (Admin)
GET /api/tickets/{id}/sla-status
GET /api/reportes/sla-compliance
```

**Tiempo Estimado:** 5-6 días  
**Dependencias:** Service Catalog completado  
**Prioridad:** 🟡 ALTA

---

#### 1.2.3 Colas/Líneas de Espera (Queues)

**Descripción:** Organizar tickets por grupo, departamento, prioridad con visualización tipo Jira.

| Componente | Uso Existente | Faltante |
|------------|---------------|---------|
| **Agrupación** | `grupo`, `departamento` | Colas custom (ej: "Critical Issues") |
| **Ordenamiento** | Campo `Order` en algunos | Prioridad + fecha creación + SLA |
| **Filtros** | En `TicketsController.BusquedaAvanzada()` | Persistencia de filtros favoritos |
| **Asignación** | `tkt.Id_Usuario_Asignado` | Cola de no asignados, round-robin |

**Mockup BD:**
```sql
CREATE TABLE colas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(255),
  descripcion TEXT,
  id_grupo INT,
  filtro_json JSON, -- {"estado": 1, "prioridad": [2,3]}
  orden_por VARCHAR(50), -- 'prioridad', 'fecha_creado', 'sla_vencimiento'
  FOREIGN KEY (id_grupo) REFERENCES grupo(Id_Grupo)
);

CREATE TABLE cola_usuarios_favoritos (
  id_usuario INT,
  id_cola INT,
  PRIMARY KEY (id_usuario, id_cola)
);
```

**Tiempo Estimado:** 3-4 días  
**Dependencias:** Service Catalog, SLAs  
**Prioridad:** 🟡 ALTA

---

### 1.3 DESEABLES - Features Avanzados Jira

#### 1.3.1 Automatizaciones (Automations)

**Descripción:** Acciones automáticas cuando se cumplan condiciones (e.g., "Si prioridad=Crítica, asignar a senior").

**Mockup BD:**
```sql
CREATE TABLE automatizaciones (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(255),
  descripcion TEXT,
  activa BOOLEAN,
  condicion_json JSON, -- {"trigger": "ticket_created", "condiciones": [...]}
  acciones_json JSON,  -- [{"tipo": "assign", "usuario_id": 5}, {"tipo": "notify", ...}]
  created_by INT,
  FOREIGN KEY (created_by) REFERENCES usuario(idUsuario)
);

CREATE TABLE automatizaciones_history (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_automatizacion INT,
  id_tkt INT,
  acciones_ejecutadas JSON,
  resultado VARCHAR(50), -- 'success', 'error'
  fecha TIMESTAMP
);
```

**Ejemplos:**
- Ticket Crítica → Asignar a especialista
- Ticket sin asignar + 2 horas → Notificar manager
- Estado = "En Espera" + 7 días → Cerrar automáticamente
- Ticket creada → Enviar confirmación por email

**Tiempo Estimado:** 6-7 días  
**Dependencias:** SLAs, Usuarios CRUD, Email service  
**Prioridad:** 🟢 MEDIA

---

#### 1.3.2 Base de Conocimiento (Knowledge Base)

**Descripción:** Artículos, FAQs, soluciones recomendadas linked a categorías.

**Mockup BD:**
```sql
CREATE TABLE kb_articulos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  titulo VARCHAR(255),
  contenido LONGTEXT,
  id_servicio INT,
  palabras_clave VARCHAR(500),
  vistas INT DEFAULT 0,
  utiles INT DEFAULT 0,
  inutiles INT DEFAULT 0,
  activo BOOLEAN,
  created_by INT,
  created_at TIMESTAMP,
  FULLTEXT KEY ft_titulo (titulo),
  FULLTEXT KEY ft_contenido (contenido)
);

CREATE TABLE kb_relacion_tickets (
  id_tkt INT,
  id_articulo INT,
  tipo VARCHAR(50), -- 'solucion_recomendada', 'relacionado'
  PRIMARY KEY (id_tkt, id_articulo)
);
```

**Funcionalidad:**
- Búsqueda full-text
- Artículos sugeridos al crear ticket
- Ratings (útil/inútil)
- Asociación con soluciones

**Tiempo Estimado:** 5-6 días  
**Dependencias:** Service Catalog  
**Prioridad:** 🟢 MEDIA

---

#### 1.3.3 CMDB (Configuration Management Database)

**Descripción:** Registro de activos/configuraciones/dispositivos del negocio.

**Mockup BD:**
```sql
CREATE TABLE cmdb_activos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(255),
  tipo VARCHAR(50), -- 'servidor', 'software', 'aplicacion', 'dispositivo'
  estado VARCHAR(50), -- 'operativo', 'degradado', 'fuera_servicio'
  propietario INT,
  ubicacion VARCHAR(255),
  fecha_adquisicion DATE,
  notas TEXT,
  FOREIGN KEY (propietario) REFERENCES usuario(idUsuario)
);

CREATE TABLE cmdb_relaciones (
  id_activo_dependiente INT,
  id_activo_dependencia INT,
  tipo VARCHAR(50), -- 'depende_de', 'conecta_a'
  FOREIGN KEY (id_activo_dependiente) REFERENCES cmdb_activos(id),
  FOREIGN KEY (id_activo_dependencia) REFERENCES cmdb_activos(id)
);

CREATE TABLE tkt_cmdb_relacion (
  id_tkt INT,
  id_activo INT,
  PRIMARY KEY (id_tkt, id_activo),
  FOREIGN KEY (id_tkt) REFERENCES tkt(Id_Tkt),
  FOREIGN KEY (id_activo) REFERENCES cmdb_activos(id)
);
```

**Tiempo Estimado:** 7-8 días  
**Dependencias:** Service Catalog, Usuarios CRUD  
**Prioridad:** 🟢 MEDIA

---

#### 1.3.4 Portal de Autoservicio Mejorado

**Descripción:** Landing page tipo Jira para usuarios finales.

**Componentes:**
- Catálogo de servicios visual
- Mis tickets activos
- Búsqueda de KB
- Seguimiento de SLA
- Chat en vivo (integración)

**Endpoints:**
```
GET /api/portal/servicios
GET /api/portal/mis-tickets
GET /api/portal/kb/buscar?q=
GET /api/portal/ticket/{id}/status
```

**Tiempo Estimado:** 4-5 días (Frontend)  
**Dependencias:** Service Catalog, SLAs, KB  
**Prioridad:** 🟢 MEDIA

---

#### 1.3.5 Notificaciones Multi-canal

**Descripción:** Email, Slack, Teams, SMS, Push notifications.

**Tabla Nueva:**
```sql
CREATE TABLE notificacion_canales (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_usuario INT,
  canal VARCHAR(50), -- 'email', 'slack', 'teams', 'sms', 'push'
  destino VARCHAR(255),
  activo BOOLEAN,
  FOREIGN KEY (id_usuario) REFERENCES usuario(idUsuario)
);

CREATE TABLE notificacion_plantillas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  evento VARCHAR(100), -- 'ticket_created', 'ticket_assigned', etc.
  asunto VARCHAR(255),
  plantilla LONGTEXT,
  canal VARCHAR(50)
);
```

**Integraciones:**
- Slack Webhook
- Microsoft Teams API
- SendGrid/Twilio para SMS
- Firebase Cloud Messaging

**Tiempo Estimado:** 5-6 días  
**Dependencias:** Refactor NotificacionService  
**Prioridad:** 🟢 MEDIA

---

#### 1.3.6 Reportes Ejecutivos Avanzados

**Actualmente:** Básicos en `ReportesController`

**Faltante:**
- Trend analysis (12 meses)
- Predictive analytics (ML)
- Comparativa periódica (MoM, YoY)
- Exportación a Power BI/Tableau
- Custom reports builder
- Scheduled reports (email diario/semanal)

**Nuevas vistas SQL:**
```sql
CREATE VIEW reporte_sla_compliance AS
  SELECT 
    DATE_TRUNC('month', tkt.Date_Creado) as periodo,
    COUNT(*) as total_tickets,
    SUM(CASE WHEN tkt.Date_Cierre IS NULL THEN 1 ELSE 0 END) as abiertos,
    COUNT(CASE WHEN sh.breached_response = TRUE THEN 1 END) as sla_violations
  FROM tkt
  LEFT JOIN sla_history sh ON tkt.Id_Tkt = sh.id_tkt
  GROUP BY DATE_TRUNC('month', tkt.Date_Creado);
```

**Tiempo Estimado:** 6-7 días  
**Dependencias:** SLAs, Data warehouse setup  
**Prioridad:** 🟢 MEDIA

---

### 1.4 INFRAESTRUCTURA & DEVOPS

#### 1.4.1 Faltas Operacionales

| Brecha | Impacto | Solución |
|--------|---------|----------|
| Sin Container (Docker) | Deploy manual, no reproducible | Dockerfile + docker-compose.yml |
| Sin CI/CD Pipeline | No auto-tests en PR | GitHub Actions o Azure Pipelines |
| Sin Health Check endpoint | Monitoring imposible | `GET /api/health` |
| Sin API Versioning | Breaking changes sin control | URL scheme `/api/v1`, `/api/v2` |
| Logs sin agregación | Debugging en prod difícil | ELK Stack o Application Insights |
| Sin Rate Limiting global | DoS vulnerable | Redis-based rate limiter |
| Secrets hardcoded | Security risk | Azure Key Vault o Secrets Manager |

**Tiempo Estimado:** 5-7 días (total)  
**Dependencias:** Ninguna (parallelizable)  
**Prioridad:** 🟡 ALTA

---

## 2. PLAN DE IMPLEMENTACIÓN PRIORIZADO

### FASE 0: FIXES CRÍTICOS (Semana 1-2)

**Objetivo:** Producto estable y seguro.

```
┌─────────────────────────────────┐
│ FIXES CRÍTICOS (2 semanas)      │
├─────────────────────────────────┤
│ ✓ RefreshToken                  │ (2 días)
│ ✓ ValidarPermisoAsync           │ (1 día)
│ ✓ Admin Endpoints Auth          │ (0.5 día)
│ ✓ UsuariosController CRUD       │ (2 días)
│ ✓ PoliticaTransicion fix        │ (1 día)
│ ✓ SQL Injection cleanup         │ (1.5 días)
│ ✓ Request correlation logging   │ (1 día)
│ ✓ Input validation framework    │ (1 día)
└─────────────────────────────────┘
     TOTAL: ~10 días
```

#### Detalle Fase 0:

**Tarea 0.1 - RefreshToken (2 días)**
```
- Extender tabla usuario: agregar refresh_token_hash, refresh_token_expires
- Implementar GenerateRefreshToken() en AuthService
- Implementar ValidateRefreshToken()
- Endpoint POST /api/auth/refresh-token
- Rate limiting en refresh (max 5/hora)
- Rotación: nuevo token en cada refresh
- Tests: token expiry, rotation, invalidation
```

**Tarea 0.2 - ValidarPermisoAsync (1 día)**
```
- Mapear tabla tkt_rol_permiso (existe, no usada)
- Refactor: usar actual rol del usuario
- Cache permisos por usuario con invalidación
- Tests: usuario admin, operator, viewer
```

**Tarea 0.3 - Admin Endpoints (0.5 días)**
```
- AdminController.SampleUser() → requiere [Authorize(Roles="Admin")]
- AdminController.DbAudit() → requiere [Authorize(Roles="Admin")]
- Crear role seeder en Program.cs
```

**Tarea 0.4 - UsuariosController (2 días)**
```
Endpoints:
- GET /api/usuarios (Admin+)
- GET /api/usuarios/{id}
- POST /api/usuarios (Admin)
- PUT /api/usuarios/{id} (Admin + Self)
- DELETE /api/usuarios/{id} (Admin)
- PUT /api/usuarios/{id}/password (Self)
- GET /api/usuarios/me (Self)

Entity: Usuario CRUD completo
Tests: CRUD básico, permiso negado para user normal
```

**Tarea 0.5 - PoliticaTransicion (1 día)**
```
Antes:
- Repository: busca tabla "PoliticasTransicion" (no existe)
Después:
- Mapear a "tkt_transicion_regla" correctamente
- Verificar SP sp_validar_transicion_regla
- Test: todas las transiciones válidas funcionan
```

**Tarea 0.6 - SQL Injection (1.5 días)**
```
Auditar:
- ComentarioRepository: LAST_INSERT_ID() workaround
  → Usar Dapper output parameters
- BusquedaAvanzada: validar Term antes de usar en LIKE
- SearchRepository: revisar consulta de full-text search
```

**Tarea 0.7 - Correlation Logging (1 día)**
```
- Middleware: extraer/generar X-Request-Id header
- Inyectar en Serilog como propiedad
- Todos los logs incluyan RequestId
- Reporte mensual de errores con RequestId
```

**Tarea 0.8 - Input Validation (1 día)**
```
- Fluent Validation para DTOs
  - CreateTicketDTO
  - UpdateTicketDTO
  - CreateUserDTO
  - etc.
- Custom validation attributes
- Devolver errores 400 detallados
```

---

### FASE 1: MVP JIRA (Semana 3-6)

**Objetivo:** Core features que hacen el sistema "Jira-like".

```
┌──────────────────────────────────┐
│ FASE 1: MVP JIRA (4 semanas)     │
├──────────────────────────────────┤
│ ✓ Service Catalog                │ (4-5 días)
│ ✓ SLAs básicos                   │ (5-6 días)
│ ✓ Colas/Queues                   │ (3-4 días)
│ ✓ Escalaciones                   │ (2-3 días)
│ ✓ Reportes básicos upgrade       │ (2-3 días)
│ ✓ Docker + CI/CD                 │ (5 días)
└──────────────────────────────────┘
     TOTAL: ~22-26 días (4.5 sem)
```

#### Detalle Fase 1:

**Tarea 1.1 - Service Catalog (4-5 días)**
```
Tablas:
- servicios
- servicios_grupos
- servicios_campos_custom

Endpoints:
- GET /api/servicios
- GET /api/servicios/{id}
- GET /api/servicios/{id}/campos-custom
- POST /api/servicios (Admin)
- PUT /api/servicios/{id} (Admin)
- DELETE /api/servicios/{id} (Admin)
- GET /api/servicios/grupo/{idGrupo}

Controllers:
- ServiciosController

Services:
- ServicioService

Tests:
- Listar servicios por grupo
- Campos custom por tipo solicitud
- Acceso denegado para usuario sin grupo
```

**Tarea 1.2 - SLAs (5-6 días)**
```
Tablas:
- slas
- sla_history
- sla_horas_laborales

Lógica:
- Calcular tiempo hasta vencimiento (excluyendo fines de semana)
- Alertas automáticas (80%, 100% SLA)
- Escalación automática si se incumple

Endpoints:
- GET /api/slas
- GET /api/slas/{idServicio}
- POST /api/slas (Admin)
- PUT /api/slas/{id} (Admin)
- GET /api/tickets/{id}/sla-status
- GET /api/reportes/sla-compliance

Cálculo:
- Crear función SQL: FUNCTION calculate_sla_minutes()
- Considerar: horas laborales, feriados

Tests:
- SLA vencido desencadena escalación
- Alertas generadas correctamente
```

**Tarea 1.3 - Colas/Queues (3-4 días)**
```
Tablas:
- colas
- cola_usuarios_favoritos

Endpoints:
- GET /api/colas
- GET /api/colas/{id}/tickets
- POST /api/colas (Admin)
- PUT /api/colas/{id} (Admin)
- POST /api/colas/{id}/favorito (User)
- DELETE /api/colas/{id}/favorito (User)

Lógica:
- Filtros persistentes
- Ordenamiento por prioridad/SLA/fecha
- Estadísticas: cantidad, edad promedio

UI (frontend):
- Kanban board por cola
- Drag-drop para cambiar estado
```

**Tarea 1.4 - Escalaciones (2-3 días)**
```
Tabla:
- escalaciones (cuando se cumple condición)

Triggers:
- SLA vencido → Notificar manager
- Sin asignar + 4h → Asignar a cola general
- Crítica sin progreso 24h → Escalar a director

Endpoint:
- GET /api/escalaciones (Admin)
- POST /api/escalaciones (Admin) - crear regla
```

**Tarea 1.5 - Reportes Upgrade (2-3 días)**
```
Nuevas vistas:
- Tickets resueltos vs abiertos (por período)
- Tiempo promedio resolución (por departamento, servicio)
- Cumplimiento SLA
- Carga de trabajo (tickets por asignado)
- Tendencias (últimos 12 meses)

Endpoints:
- GET /api/reportes/dashboard (upgrade existente)
- GET /api/reportes/tendencias?meses=12
- GET /api/reportes/distribucion?por=departamento
- POST /api/reportes/custom (generar reporte dinámico)

Export:
- CSV existente OK
- Agregar Excel + PDF
```

**Tarea 1.6 - Docker + CI/CD (5 días)**
```
Docker:
- Dockerfile multi-stage (build + runtime)
- docker-compose.yml con API + MySQL + Redis
- .dockerignore

CI/CD (GitHub Actions):
- Trigger: push a main, PR
- Jobs:
  - Build
  - Unit Tests (MSTest)
  - Integration Tests
  - Code Coverage (mínimo 80%)
  - Security Scan (SAST)
  - Publish Docker image (main solo)
  
Deployment:
- Azure Container Registry o Docker Hub
- Manual deploy a production (requiere approval)
```

---

### FASE 2: AVANZADOS (Semana 7-12)

**Objetivo:** Features que hacen diferencia competitiva.

```
┌─────────────────────────────────────┐
│ FASE 2: AVANZADOS (6 semanas)       │
├─────────────────────────────────────┤
│ ✓ Automatizaciones                  │ (6-7 días)
│ ✓ Knowledge Base                    │ (5-6 días)
│ ✓ CMDB                              │ (7-8 días)
│ ✓ Multi-canal Notificaciones        │ (5-6 días)
│ ✓ Portal Autoservicio Mejorado      │ (4-5 días)
│ ✓ API Versioning & Deprecation      │ (2-3 días)
│ ✓ Observabilidad (APM/Logging)      │ (3-4 días)
└─────────────────────────────────────┘
     TOTAL: ~32-39 días (6.5 sem)
```

---

## 3. DEPENDENCIAS & SECUENCIA

```
FASE 0 (Críticos)
    ↓
    ├─→ Usuarios CRUD
    ├─→ Permission validation
    ├─→ RefreshToken
    ├─→ Security fixes (SQL injection, admin auth)
    └─→ Logging framework
         ↓
FASE 1 (MVP)
    ├─→ Service Catalog
    │    ├─→ Colas (depende de Servicios)
    │    └─→ SLAs (depende de Servicios)
    │         └─→ Escalaciones (depende de SLAs)
    ├─→ Reportes upgrade
    └─→ Docker + CI/CD (parallelizable)
         ↓
FASE 2 (Avanzados)
    ├─→ Automatizaciones (depende de SLAs, permisos)
    ├─→ Knowledge Base (depende de Servicios)
    ├─→ CMDB (independiente)
    ├─→ Notificaciones multi-canal (depende de usuarios)
    ├─→ Portal (depende de Servicios, SLAs, KB)
    └─→ Observabilidad (parallelizable)
```

---

## 4. TIMELINE ESTIMADO

| Fase | Duración | Inicio | Fin | Vel. Equipo |
|------|----------|--------|-----|-------------|
| 0: Fixes | 10 días | Sem 1 | Sem 2 | 1 dev |
| 1: MVP | 23 días | Sem 3 | Sem 6 | 1 dev + QA |
| 2: Avanzados | 35 días | Sem 7 | Sem 13 | 1-2 devs |

**TOTAL: 13 semanas (3 meses) para producto Jira-like enterprise-ready**

Con 2 desarrolladores (parallelizable parte de Fase 1-2): **8-10 semanas**

---

## 5. MÉTRICAS DE ÉXITO

### Fase 0
- [ ] 100% tests pasando
- [ ] 0 security vulnerabilities (OWASP top 10)
- [ ] Todas las APIs autenticadas

### Fase 1
- [ ] 80%+ SLA compliance en demo data
- [ ] <2s latencia en búsqueda de tickets
- [ ] 95%+ users con acceso a Service Catalog

### Fase 2
- [ ] 90%+ tickets solucionados sin escalación
- [ ] 75%+ usuarios usan automizaciones
- [ ] <24h promedio resolución (Crítica)
- [ ] NPS > 8/10

---

## 6. RIESGOS & MITIGACIÓN

| Riesgo | Impacto | Probabilidad | Mitigación |
|--------|---------|--------------|-----------|
| Falta de contexto de reqs | Alto | Media | Documentar casos de uso antes de Fase 1 |
| Performance en SLAs | Medio | Media | Benchmarking temprano, índices DB |
| Integración Slack/Teams | Bajo | Baja | MVP sin 3rd party, adicionar después |
| Cambios en estructura BD | Alto | Baja | Versionamiento DB, migrations |
| Falta de diseño UX | Medio | Media | Wireframes antes de Portal (Fase 2) |

---

## 7. PRÓXIMOS PASOS INMEDIATOS

### Semana 1: Validación & Planning
- [ ] Revisar este roadmap con stakeholders
- [ ] Priorizar qué de Fase 1 es MUST-HAVE vs NICE-TO-HAVE
- [ ] Crear backlog en GitHub Issues/Azure DevOps
- [ ] Setup repositorio con ramas por feature

### Semana 2-3: Desarrollo Fase 0
- [ ] Crear branch `refactor/critical-fixes`
- [ ] Implementar RefreshToken
- [ ] Crear UsuariosController
- [ ] Unit tests para cada fix

---

## 8. DOCUMENTACIÓN ASOCIADA

Consultar también:
- [DB_AUDIT_LATEST.json](docs/20-DB/DB_AUDIT_LATEST.json) - Esquema actual
- [AUDIT_COMPARISON_REPORT.md](docs/20-DB/AUDIT_COMPARISON_REPORT.md) - Cambios DB
- [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md) - Endpoints actuales
- [FASE_0_MAPEO_SPs_ENDPOINTS.md](FASE_0_MAPEO_SPs_ENDPOINTS.md) - SP coverage

---

**Documento generado:** 30 de enero de 2026  
**Versión:** 1.0  
**Revisor recomendado:** Tech Lead + Product Manager  
**Próxima revisión:** Después de Fase 0 (completar Fixes Críticos)
