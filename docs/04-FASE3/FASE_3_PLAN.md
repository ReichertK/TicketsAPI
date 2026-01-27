# FASE 3: ENDPOINTS CRÍTICOS Y FUNCIONALIDADES CORE

**Fecha inicio:** 27 enero 2026  
**Estado:** 🚀 EN PROGRESO  
**Estimación:** 12-14 horas  
**Objetivo:** Completar funcionalidades críticas para MVP funcional

---

## 🎯 Objetivos de FASE 3

Según el análisis de FASE 0, la API tiene **62% de cobertura**. FASE 3 se enfoca en:

1. ✅ **Mejorar búsqueda y filtrado** (ya implementado parcialmente)
2. 🔧 **Optimizar paginación** (ya funciona, mejorar respuesta)
3. 📊 **Implementar reportes básicos**
4. 📤 **Exportar datos a CSV/Excel**
5. 🔍 **Búsqueda avanzada full-text**

---

## 📊 Estado Actual (Post-FASE 2)

| Componente | Estado | Cobertura |
|------------|--------|-----------|
| **TicketsController** | ✅ Completo | 100% |
| **Búsqueda básica** | ✅ Implementado | TicketFiltroDTO funcional |
| **Paginación** | ✅ Implementado | PaginatedResponse<T> existe |
| **Exportar CSV** | ⏭️ Placeholder | Endpoint 501 (Not Implemented) |
| **Reportes** | ❌ No existe | 0% |
| **Búsqueda full-text** | ❌ No existe | 0% |
| **Dashboard analytics** | ❌ No existe | 0% |

---

## 🎯 Análisis de Gaps

### ✅ Lo que YA funciona

**TicketFiltroDTO** (implementado en FASE 0/1):
```csharp
public class TicketFiltroDTO
{
    public int? Id_Estado { get; set; }
    public int? Id_Prioridad { get; set; }
    public int? Id_Departamento { get; set; }
    public int? Id_Usuario_Asignado { get; set; }
    public int? Id_Motivo { get; set; }
    public int? Id_Usuario { get; set; }
    public DateTime? Fecha_Desde { get; set; }
    public DateTime? Fecha_Hasta { get; set; }
    public string? Busqueda { get; set; }           // ✅ Basic search
    public string? Ordenar_Por { get; set; }         // ✅ Sorting
    public bool? Orden_Descendente { get; set; }     // ✅ Sort direction
    public int Pagina { get; set; } = 1;            // ✅ Pagination
    public int TamañoPagina { get; set; } = 20;     // ✅ Page size
}
```

**PaginatedResponse<T>** (implementado):
```csharp
public class PaginatedResponse<T>
{
    public List<T> Datos { get; set; } = new();
    public int TotalRegistros { get; set; }
    public int TotalPaginas { get; set; }
    public int PaginaActual { get; set; }
    public int TamañoPagina { get; set; }
    public bool TienePaginaAnterior { get; set; }
    public bool TienePaginaSiguiente { get; set; }
}
```

**Endpoints existentes**:
- ✅ `GET /api/v1/Tickets` - Con filtros, búsqueda, paginación
- ✅ `GET /api/v1/Tickets/{id}` - Detalle de ticket
- ✅ `GET /api/v1/Tickets/{id}/historial` - Historial completo
- ✅ `GET /api/v1/Tickets/{id}/transiciones-permitidas` - Estados válidos
- ⏭️ `GET /api/v1/Tickets/exportar-csv` - 501 Not Implemented

### 🔧 Lo que necesita mejoras

1. **Respuesta de búsqueda** - Actualmente retorna `ApiResponse<T>` pero debería retornar `ApiResponse<PaginatedResponse<T>>`
2. **Exportar CSV** - Endpoint existe pero retorna 501
3. **Búsqueda full-text** - Solo busca en `Contenido`, falta buscar en comentarios

### ❌ Lo que falta completamente

1. **Reportes** - Endpoints para analytics y estadísticas
2. **Dashboard** - Métricas agregadas (tickets por estado, prioridad, etc.)
3. **Búsqueda avanzada** - Full-text en múltiples campos

---

## 🗺️ Plan de Implementación

### PRIORIDAD 1: Mejorar respuesta de búsqueda (1 hora)

**Objetivo**: Retornar metadata de paginación en búsquedas

**Task 1.1**: Modificar TicketService.GetFilteredAsync
- [x] Verificar implementación actual
- [ ] Modificar para retornar PaginatedResponse<TicketDTO>
- [ ] Actualizar TicketsController.GetTickets() para retornar paginación

**Archivos**:
- `Services/Interfaces/IServices.cs`
- `Services/Implementations/TicketService.cs`
- `Controllers/TicketsController.cs`

---

### PRIORIDAD 2: Implementar exportación CSV (2-3 horas)

**Objetivo**: Permitir exportar tickets filtrados a CSV

**Task 2.1**: Crear servicio de exportación
- [ ] Crear `IExportService` interface
- [ ] Implementar `ExportService` con método `ExportTicketsToCsvAsync`
- [ ] Usar CsvHelper o StringBuilder para generar CSV

**Task 2.2**: Implementar endpoint
- [ ] Actualizar `TicketsController.ExportCsv()`
- [ ] Retornar `FileContentResult` con CSV
- [ ] Headers: `Content-Type: text/csv`, `Content-Disposition: attachment`

**Archivos nuevos**:
- `Services/Interfaces/IExportService.cs`
- `Services/Implementations/ExportService.cs`

**Archivos modificados**:
- `Controllers/TicketsController.cs`
- `Program.cs` (registrar servicio)

**Ejemplo de uso**:
```bash
GET /api/v1/Tickets/exportar-csv?Id_Estado=1&Fecha_Desde=2024-01-01
→ Descarga tickets_20240127.csv
```

---

### PRIORIDAD 3: Dashboard y reportes básicos (3-4 horas)

**Objetivo**: Endpoints para métricas y estadísticas

**Task 3.1**: Crear DTOs para reportes
- [ ] `DashboardDTO` - Métricas generales
- [ ] `ReporteEstadoDTO` - Tickets por estado
- [ ] `ReportePrioridadDTO` - Tickets por prioridad
- [ ] `ReporteDepartamentoDTO` - Tickets por departamento

**Task 3.2**: Crear servicio de reportes
- [ ] Crear `IReporteService` interface
- [ ] Implementar `ReporteService` con métodos de agregación

**Task 3.3**: Crear ReportesController
- [ ] `GET /api/v1/Reportes/Dashboard` - Métricas generales
- [ ] `GET /api/v1/Reportes/PorEstado` - Tickets agrupados por estado
- [ ] `GET /api/v1/Reportes/PorPrioridad` - Tickets agrupados por prioridad
- [ ] `GET /api/v1/Reportes/PorDepartamento` - Tickets agrupados por departamento
- [ ] `GET /api/v1/Reportes/Tendencias` - Tickets por periodo (día/semana/mes)

**Archivos nuevos**:
- `Models/DTOs.cs` (agregar ReporteDTOs)
- `Services/Interfaces/IReporteService.cs`
- `Services/Implementations/ReporteService.cs`
- `Controllers/ReportesController.cs`

**Ejemplo Dashboard**:
```json
{
  "exitoso": true,
  "mensaje": "Dashboard obtenido exitosamente",
  "datos": {
    "totalTickets": 156,
    "ticketsAbiertos": 45,
    "ticketsCerrados": 111,
    "ticketsPorEstado": {
      "Nuevo": 12,
      "En Progreso": 28,
      "Resuelto": 111,
      "Cerrado": 5
    },
    "ticketsPorPrioridad": {
      "Alta": 8,
      "Media": 32,
      "Baja": 116
    },
    "tiempoPromedioResolucion": "2.5 días"
  }
}
```

---

### PRIORIDAD 4: Búsqueda avanzada (2-3 horas)

**Objetivo**: Mejorar búsqueda para incluir comentarios y múltiples campos

**Task 4.1**: Extender búsqueda en TicketRepository
- [ ] Modificar query de búsqueda en `sp_listar_tkts` (o en código)
- [ ] Buscar en: Contenido, Comentarios, Nombre de usuario creador
- [ ] Implementar búsqueda full-text (MySQL MATCH AGAINST o LIKE)

**Task 4.2**: Agregar filtros avanzados
- [ ] Filtro por rango de fechas de creación
- [ ] Filtro por rango de fechas de actualización
- [ ] Filtro por usuario creador
- [ ] Filtro combinado (múltiples estados, múltiples prioridades)

**Archivos modificados**:
- `Repositories/Implementations/TicketRepository.cs`
- `Models/DTOs.cs` (extender TicketFiltroDTO si necesario)

---

### PRIORIDAD 5: Optimizaciones y mejoras (2 horas)

**Task 5.1**: Mejorar performance de queries
- [ ] Revisar índices en BD
- [ ] Agregar índices en campos de búsqueda
- [ ] Optimizar queries N+1 (eager loading)

**Task 5.2**: Agregar caching básico
- [ ] Cachear referencias (departamentos, estados, prioridades)
- [ ] Implementar IMemoryCache en referenceController
- [ ] TTL: 5 minutos para referencias

**Task 5.3**: Documentación Swagger mejorada
- [ ] Agregar ejemplos de request/response
- [ ] Documentar códigos de error
- [ ] Agregar descripción de filtros

**Archivos modificados**:
- `Program.cs` (configurar caching)
- `Controllers/*.cs` (agregar XML comments mejores)

---

## 📋 Checklist de Implementación

### Setup
- [ ] Crear rama `feature/fase3-endpoints-criticos`
- [ ] Verificar que FASE 2 tests pasan (68/75 ✅)

### Implementación
- [ ] Mejorar respuesta de búsqueda con paginación
- [ ] Implementar exportación CSV
- [ ] Crear DTOs de reportes
- [ ] Crear ReporteService
- [ ] Crear ReportesController
- [ ] Implementar búsqueda avanzada
- [ ] Agregar caching de referencias
- [ ] Optimizar queries

### Testing
- [ ] Tests unitarios para ReportesController
- [ ] Tests unitarios para ExportService
- [ ] Tests de integración para búsqueda avanzada
- [ ] Validar performance con 1000+ tickets

### Documentación
- [ ] Actualizar Swagger
- [ ] Crear ejemplos de API
- [ ] Documentar formato CSV
- [ ] Documentar estructura de reportes

---

## 🎯 Criterios de Éxito

### Funcionales
✅ Búsqueda retorna metadata de paginación  
✅ Exportar CSV descarga archivo válido  
✅ Dashboard retorna métricas correctas  
✅ Reportes agrupan datos correctamente  
✅ Búsqueda avanzada encuentra en múltiples campos  

### No Funcionales
✅ Búsqueda responde en <500ms con 1000 tickets  
✅ Exportación genera CSV válido (compatible Excel)  
✅ Reportes usan queries optimizadas (no N+1)  
✅ Caching reduce latencia de referencias en 80%  

### Calidad
✅ Tests unitarios para nuevas funcionalidades  
✅ Documentación Swagger completa  
✅ Código siguiendo patrones de FASE 1  
✅ 0 warnings de compilación  

---

## 📊 Estimación de Tiempo

| Tarea | Tiempo Estimado |
|-------|----------------|
| Mejorar respuesta búsqueda | 1 hora |
| Implementar CSV export | 2-3 horas |
| Dashboard y reportes | 3-4 horas |
| Búsqueda avanzada | 2-3 horas |
| Optimizaciones | 2 horas |
| Testing | 2 horas |
| Documentación | 1 hora |
| **TOTAL** | **13-16 horas** |

---

## 📚 Referencias

- [FASE_0_CONSOLIDADO.md](../01-FASE0/FASE_0_CONSOLIDADO.md) - Estado actual y gaps
- [FASE_0_MAPEO_SPs_ENDPOINTS.md](../01-FASE0/FASE_0_MAPEO_SPs_ENDPOINTS.md) - SPs disponibles
- [FASE_1_COMPLETO.md](../02-FASE1/FASE_1_COMPLETO.md) - Patrones implementados
- [FASE_2_COMPLETO.md](./FASE_2_COMPLETO.md) - Tests de referencia

---

## 🚀 Siguiente Paso

**AHORA**: Iniciar con PRIORIDAD 1 - Mejorar respuesta de búsqueda

```bash
# Crear rama
git checkout -b feature/fase3-endpoints-criticos

# Verificar tests actuales
dotnet test TicketsAPI.Tests

# Iniciar con Task 1.1
# → Revisar TicketService.GetFilteredAsync()
```

---

**Última actualización:** 27 enero 2026
