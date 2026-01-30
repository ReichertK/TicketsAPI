# 📊 Tasa de Cumplimiento de Tickets - Análisis Técnico

**Fecha:** 30 de enero de 2026  
**Versión:** FASE 0 → FASE 1  
**Estado:** ⚠️ **PENDIENTE DE IMPLEMENTACIÓN**

---

## 🎯 ¿Qué es la Tasa de Cumplimiento?

La **tasa de cumplimiento de tickets** es una métrica que mide **qué porcentaje de tickets se cierran dentro del tiempo límite establecido (SLA)**.

### Fórmula General
$$\text{Tasa Cumplimiento} = \frac{\text{Tickets cerrados dentro de SLA}}{\text{Total de tickets cerrados}} \times 100\%$$

---

## 📈 Estado Actual del Código

### En ReporteService.cs

**Ubicación:** [ReporteService.cs](../TicketsAPI/Services/Implementations/ReporteService.cs#L77)

```csharp
return new DashboardDTO
{
    TicketsTotal = tickets.TotalRegistros,
    TicketsAbiertos = tickets.Datos.Count(t => t.Date_Cierre == null),
    TicketsCerrados = tickets.Datos.Count(t => t.Date_Cierre != null),
    TicketsEnProceso = tickets.Datos.Count(t => t.Estado?.Nombre_Estado?.Contains("Progreso") ?? false),
    TiempoPromedioResolucion = (decimal)Math.Round(tiempoPromedioHoras, 2),
    TasaCumplimientoSLA = 0  // ⚠️ TODO: Implementar cálculo de SLA
};
```

**Estado:** ❌ Hardcodeado a 0

### En DTOs.cs

**Ubicación:** [DTOs.cs](../TicketsAPI/Models/DTOs.cs#L339)

```csharp
public class DashboardDTO
{
    public int TicketsTotal { get; set; }
    public int TicketsAbiertos { get; set; }
    public int TicketsCerrados { get; set; }
    public int TicketsEnProceso { get; set; }
    public int TicketsAsignadosAMi { get; set; }
    public Dictionary<string, int> TicketsPorEstado { get; set; }
    public Dictionary<string, int> TicketsPorPrioridad { get; set; }
    public Dictionary<string, int> TicketsPorDepartamento { get; set; }
    public decimal TiempoPromedioResolucion { get; set; }
    public decimal TasaCumplimientoSLA { get; set; }  // ⚠️ Siempre = 0
}
```

---

## 🔄 Cómo Debería Calcularse

### Opción 1: SLA por Prioridad (RECOMENDADO)

Cada ticket tiene una **prioridad** que determina su tiempo máximo de resolución:

| Prioridad | Tiempo Máximo (SLA) | Descripción |
|-----------|-------------------|-------------|
| Crítica | 4 horas | Sistema no disponible |
| Alta | 1 día | Funcionalidad importante afectada |
| Media | 3 días | Funcionalidad parcial afectada |
| Baja | 1 semana | Mejora o cambio menor |

**Fórmula:**
$$\text{Tasa Cumplimiento} = \frac{\text{Tickets cerrados en tiempo SLA}}{\text{Total de tickets cerrados}} \times 100\%$$

**En código pseudocódigo:**
```csharp
var ticketsCerrados = tickets.Datos.Where(t => t.Date_Cierre.HasValue).ToList();

var ticketsCumplenSLA = ticketsCerrados.Count(t => 
{
    var tiempoResolucion = t.Date_Cierre.Value - t.Date_Creado.Value;
    var slaHoras = ObtenerSLAHoras(t.Prioridad?.Nombre_Prioridad);
    return tiempoResolucion.TotalHours <= slaHoras;
});

var tasaCumplimiento = ticketsCerrados.Any() 
    ? (decimal)ticketsCumplenSLA / ticketsCerrados.Count() * 100 
    : 0;
```

---

### Opción 2: SLA por Departamento + Prioridad

Algunos sistemas definen SLAs diferentes por departamento:

| Departamento | Prioridad | SLA |
|--------------|-----------|-----|
| Soporte | Crítica | 2 horas |
| Soporte | Alta | 8 horas |
| Desarrollo | Crítica | 6 horas |
| Desarrollo | Alta | 2 días |

**En código:**
```csharp
var slaConfig = new Dictionary<(string departamento, string prioridad), int>
{
    { ("Soporte", "Crítica"), 2 },
    { ("Soporte", "Alta"), 8 },
    { ("Desarrollo", "Crítica"), 6 },
    { ("Desarrollo", "Alta"), 48 },
};

var ticketsCumplenSLA = ticketsCerrados.Count(t => 
{
    var clave = (t.Departamento?.Nombre ?? "Unknown", t.Prioridad?.Nombre_Prioridad ?? "Media");
    var slaHoras = slaConfig.ContainsKey(clave) ? slaConfig[clave] : 72;
    var tiempoResolucion = (t.Date_Cierre.Value - t.Date_Creado.Value).TotalHours;
    return tiempoResolucion <= slaHoras;
});
```

---

### Opción 3: SLA con Tipos de Ticket

Algunos sistemas consideran el tipo de ticket:

| Tipo | SLA | Ejemplo |
|------|-----|---------|
| Incidente | Bajo | 4 horas (Crítica), 8 horas (Alta) |
| Request | Medio | 1-3 días |
| Change | Alto | 5 días |

---

## 📊 Ejemplo Práctico

### Escenario
- **Total tickets cerrados:** 20
- **Tickets que cumplen SLA:** 16
- **Tickets que NO cumplen SLA:** 4

### Cálculo
$$\text{Tasa Cumplimiento} = \frac{16}{20} \times 100\% = 80\%$$

### Desglose por Prioridad

| Prioridad | Cerrados | Cumplen | Tasa |
|-----------|----------|---------|------|
| Crítica | 2 | 1 | 50% |
| Alta | 8 | 7 | 87.5% |
| Media | 7 | 6 | 85.7% |
| Baja | 3 | 2 | 66.7% |
| **TOTAL** | **20** | **16** | **80%** |

---

## 🔧 Implementación Propuesta para FASE 1

### 1. Crear tabla SLA en Base de Datos

```sql
CREATE TABLE tkt_sla (
  idSLA INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255),
  idPrioridad INT,
  idDepartamento INT,
  horasResolucion INT NOT NULL,
  estado TINYINT DEFAULT 1,
  FOREIGN KEY (idPrioridad) REFERENCES tkt_prioridad(idPrioridad),
  FOREIGN KEY (idDepartamento) REFERENCES departamento(idDepartamento)
);

-- Ejemplos de datos
INSERT INTO tkt_sla VALUES 
(1, 'Crítica - 4 horas', 'SLA para tickets críticos', 1, NULL, 4, 1),
(2, 'Alta - 1 día', 'SLA para tickets de alta prioridad', 2, NULL, 24, 1),
(3, 'Media - 3 días', 'SLA para tickets de media prioridad', 3, NULL, 72, 1),
(4, 'Baja - 1 semana', 'SLA para tickets de baja prioridad', 4, NULL, 168, 1);
```

### 2. Crear tabla para registrar cumplimiento

```sql
CREATE TABLE tkt_sla_cumplimiento (
  idCumplimiento INT PRIMARY KEY AUTO_INCREMENT,
  idTicket BIGINT,
  idSLA INT,
  fechaVencimientoSLA DATETIME,
  cumplido TINYINT,
  horasUtilizadas DECIMAL(8,2),
  estado VARCHAR(50),
  FOREIGN KEY (idTicket) REFERENCES ticket(idTicket),
  FOREIGN KEY (idSLA) REFERENCES tkt_sla(idSLA)
);
```

### 3. Crear Service para SLA

```csharp
public interface ISLAService
{
    Task<SLADto> GetSLAAsync(int idPrioridad, int? idDepartamento = null);
    Task<bool> VerificarCumplimientoAsync(int idTicket, DateTime dateCreado, DateTime dateCierre);
    Task<decimal> CalcularTasaCumplimientoAsync(TicketFiltroDTO filtro);
    Task<List<SLACumplimientoDto>> GetHistorialCumplimientoAsync(int idTicket);
}

public class SLAService : ISLAService
{
    public async Task<decimal> CalcularTasaCumplimientoAsync(TicketFiltroDTO filtro)
    {
        var tickets = await _ticketRepository.GetFilteredAsync(filtro);
        
        var ticketsCerrados = tickets.Datos
            .Where(t => t.Date_Cierre.HasValue && t.Date_Creado.HasValue)
            .ToList();
        
        if (!ticketsCerrados.Any())
            return 0;
        
        var ticketsCumplenSLA = 0;
        
        foreach (var ticket in ticketsCerrados)
        {
            var sla = await GetSLAAsync(
                ticket.Id_Prioridad, 
                ticket.Id_Departamento
            );
            
            var tiempoResolucion = 
                (ticket.Date_Cierre.Value - ticket.Date_Creado.Value).TotalHours;
            
            if (tiempoResolucion <= sla.HorasResolucion)
                ticketsCumplenSLA++;
        }
        
        return Math.Round(
            (decimal)ticketsCumplenSLA / ticketsCerrados.Count() * 100, 
            2
        );
    }
}
```

### 4. Actualizar ReporteService

```csharp
public async Task<DashboardDTO> GetDashboardAsync(int? idUsuario = null, int? idDepartamento = null)
{
    // ... código existente ...
    
    // NUEVO: Calcular tasa de cumplimiento SLA
    var filtro = new TicketFiltroDTO
    {
        Id_Usuario = idUsuario,
        Id_Departamento = idDepartamento,
        Pagina = 1,
        TamañoPagina = int.MaxValue
    };
    
    var tasaCumplimiento = await _slaService.CalcularTasaCumplimientoAsync(filtro);
    
    return new DashboardDTO
    {
        // ... propiedades existentes ...
        TasaCumplimientoSLA = tasaCumplimiento  // ✅ ANTES: 0, AHORA: valor real
    };
}
```

---

## 📌 Métricas Adicionales Relacionadas

### Tickets Vencidos
$$\text{Tickets Vencidos} = \text{Tickets abiertos con SLA expirado}$$

```csharp
var ticketsVencidos = tickets.Datos.Count(t => 
    t.Date_Cierre == null &&  // Abierto
    t.FechaVencimientoSLA < DateTime.Now  // Vencido
);
```

### Eficiencia SLA
$$\text{Eficiencia} = \frac{\text{Horas disponibles SLA}}{\text{Horas utilizadas}} \times 100\%$$

### Tiempo de Respuesta Promedio
$$\text{Tiempo Respuesta} = \frac{\sum(\text{Fecha asignación} - \text{Fecha creación})}{\text{Total tickets}}$$

---

## 🎨 Visualización en Dashboard

### Ejemplo JSON Response
```json
{
  "exitoso": true,
  "datos": {
    "ticketsTotal": 150,
    "ticketsAbiertos": 45,
    "ticketsCerrados": 105,
    "ticketsEnProceso": 32,
    "ticketsAsignadosAMi": 18,
    "tiempoPromedioResolucion": 24.5,
    "tasaCumplimientoSLA": 87.62,
    "ticketsVencidos": 3,
    "ticketsPorEstado": {
      "Abierto": 45,
      "En Progreso": 32,
      "Cerrado": 105
    },
    "ticketsPorPrioridad": {
      "Crítica": 12,
      "Alta": 38,
      "Media": 65,
      "Baja": 35
    },
    "tasaCumplimientoPorPrioridad": {
      "Crítica": 75.0,
      "Alta": 89.5,
      "Media": 90.8,
      "Baja": 85.7
    }
  }
}
```

---

## ⏰ Timeline de Implementación

### FASE 0 (Actual)
- ✅ Identificar necesidad
- ✅ Documentar cálculos
- ⏳ **Siguiente:** Implementar en FASE 1

### FASE 1 (1-2 semanas)
- [ ] Crear tablas de SLA en BD
- [ ] Implementar SLAService
- [ ] Actualizar ReporteService
- [ ] Crear endpoints para SLA
- [ ] Testing

### FASE 2+ (Futuro)
- [ ] Alertas automáticas cuando SLA está por vencer
- [ ] Escalaciones automáticas
- [ ] Reportes de cumplimiento por equipo
- [ ] Métricas de performance
- [ ] Análisis de tendencias SLA

---

## 📋 Checklist de Implementación

- [ ] Crear tablas: `tkt_sla`, `tkt_sla_cumplimiento`
- [ ] Crear Entity: `SLA`, `SLACumplimiento`
- [ ] Crear DTOs: `SLADto`, `SLACumplimientoDto`
- [ ] Crear Repositories: `ISLARepository`, `SLARepository`
- [ ] Crear Service: `ISLAService`, `SLAService`
- [ ] Crear Controller: `SLAController`
- [ ] Actualizar `ReporteService` con cálculo de SLA
- [ ] Crear tests unitarios
- [ ] Crear tests de integración
- [ ] Documentar en Swagger
- [ ] Validar en ambiente de testing
- [ ] Deploy a producción

---

## 🔗 Referencias

- [Dashboard DTO](../TicketsAPI/Models/DTOs.cs#L325-L340)
- [ReporteService](../TicketsAPI/Services/Implementations/ReporteService.cs#L72-L80)
- [FASE 3 - Reportes Completo](./FASE_3_COMPLETO.md)

---

## 💡 Notas Importantes

1. **SLA vs. Acuerdo Real:** El SLA es el tiempo *máximo* permitido, no el prometido.
2. **Consideraciones de Horario:** El cálculo ideal debería considerar horarios hábiles (no 24/7).
3. **Impacto Empresarial:** Una tasa > 95% es considerada excelente.
4. **Tendencias:** Monitorear si la tasa baja mes a mes indica problemas.
5. **Compensación:** Algunos SLAs incluyen compensaciones si no se cumple.

---

*Documento creado: 30 de enero de 2026*  
*Para implementación en FASE 1*
