# 📈 Tendencias de Tickets por Prioridad - Análisis Técnico

**Fecha:** 30 de enero de 2026  
**Versión:** FASE 3 (Reportes)  
**Estado:** ✅ **IMPLEMENTADO**

---

## 🎯 ¿Qué son las Tendencias?

Las **tendencias de tickets** muestran la **evolución del volumen y estado de los tickets a lo largo del tiempo**, agrupados por períodos (días, semanas o meses).

Se pueden desglosar por:
- **Período temporal** (día, semana, mes)
- **Prioridad** (crítica, alta, media, baja)
- **Estado** (abiertos, cerrados, en progreso)
- **Departamento** (opcional)

---

## 📊 Estructura de Datos

### TendenciaDTO
**Ubicación:** [DTOs.cs](../TicketsAPI/Models/DTOs.cs#L490)

```csharp
public class TendenciaDTO
{
    public string Periodo { get; set; }                    // "2024-01-27", "Semana 4", "2024-01"
    public int TicketsCreados { get; set; }               // Tickets creados en ese período
    public int TicketsCerrados { get; set; }              // Tickets cerrados en ese período
    public int TicketsAbiertos { get; set; }              // Tickets sin cerrar en ese período
    public double TiempoPromedioResolucionHoras { get; set; }  // Promedio de horas para resolver
}
```

### FiltroReporteDTO
**Ubicación:** [DTOs.cs](../TicketsAPI/Models/DTOs.cs#L502)

```csharp
public class FiltroReporteDTO
{
    public DateTime? FechaDesde { get; set; }          // Fecha inicial (default: hace 1 mes)
    public DateTime? FechaHasta { get; set; }          // Fecha final (default: hoy)
    public int? IdDepartamento { get; set; }          // Filtrar por departamento (opcional)
    public int? IdEstado { get; set; }                // Filtrar por estado (opcional)
    public int? IdPrioridad { get; set; }             // Filtrar por PRIORIDAD (opcional)
    public string? AgrupacionPeriodo { get; set; }    // "dia", "semana" o "mes" (default: "dia")
}
```

---

## 🔧 Implementación (ReporteService)

**Ubicación:** [ReporteService.cs](../TicketsAPI/Services/Implementations/ReporteService.cs#L190)

### Flujo General

```
1. GetTendenciasAsync(filtro)
   ↓
2. Obtener tickets del repositorio (con filtros)
   ↓
3. Agrupar por período (día, semana o mes)
   ↓
4. Para cada grupo, calcular:
   - TicketsCreados = cantidad de tickets en ese período
   - TicketsCerrados = cantidad con Date_Cierre != null
   - TicketsAbiertos = cantidad con Date_Cierre == null
   - TiempoPromedio = promedio de (Date_Cierre - Date_Creado)
   ↓
5. Retornar lista ordenada de tendencias
```

### Código Detallado

```csharp
public async Task<List<TendenciaDTO>> GetTendenciasAsync(FiltroReporteDTO filtro)
{
    // 1️⃣ Construir filtro de tickets
    var ticketFiltro = new TicketFiltroDTO
    {
        Fecha_Desde = filtro.FechaDesde ?? DateTime.Now.AddMonths(-1),  // Default: últimos 30 días
        Fecha_Hasta = filtro.FechaHasta ?? DateTime.Now,                 // Default: hoy
        Id_Departamento = filtro.IdDepartamento,
        Id_Estado = filtro.IdEstado,
        Id_Prioridad = filtro.IdPrioridad,                               // ⭐ PRIORIDAD
        Pagina = 1,
        TamañoPagina = int.MaxValue
    };

    // 2️⃣ Obtener tickets de la BD
    var tickets = await _ticketRepository.GetFilteredAsync(ticketFiltro);
    var agrupacion = filtro.AgrupacionPeriodo?.ToLower() ?? "dia";

    var tendencias = new List<TendenciaDTO>();

    // 3️⃣ AGRUPACIÓN POR DÍA
    if (agrupacion == "dia")
    {
        tendencias = tickets.Datos
            .Where(t => t.Date_Creado.HasValue)
            .GroupBy(t => t.Date_Creado!.Value.Date)  // Agrupar por fecha (sin hora)
            .Select(g => new TendenciaDTO
            {
                Periodo = g.Key.ToString("yyyy-MM-dd"),                        // Ej: "2024-01-27"
                TicketsCreados = g.Count(),                                    // Total en ese día
                TicketsCerrados = g.Count(t => t.Date_Cierre?.Date == g.Key), // Cerrados ESE día
                TicketsAbiertos = g.Count(t => t.Date_Cierre == null),         // Sin cerrar
                TiempoPromedioResolucionHoras = CalcularTiempoPromedio(
                    g.Where(t => t.Date_Cierre.HasValue).ToList()
                )
            })
            .OrderBy(t => t.Periodo)
            .ToList();
    }

    // 4️⃣ AGRUPACIÓN POR SEMANA
    else if (agrupacion == "semana")
    {
        tendencias = tickets.Datos
            .Where(t => t.Date_Creado.HasValue)
            .GroupBy(t => GetWeekNumber(t.Date_Creado!.Value))  // Número de semana (1-52)
            .Select(g => new TendenciaDTO
            {
                Periodo = $"Semana {g.Key}",                                   // Ej: "Semana 4"
                TicketsCreados = g.Count(),
                TicketsCerrados = g.Count(t => t.Date_Cierre.HasValue),
                TicketsAbiertos = g.Count(t => t.Date_Cierre == null),
                TiempoPromedioResolucionHoras = CalcularTiempoPromedio(
                    g.Where(t => t.Date_Cierre.HasValue).ToList()
                )
            })
            .OrderBy(t => t.Periodo)
            .ToList();
    }

    // 5️⃣ AGRUPACIÓN POR MES
    else // mes
    {
        tendencias = tickets.Datos
            .Where(t => t.Date_Creado.HasValue)
            .GroupBy(t => t.Date_Creado!.Value.ToString("yyyy-MM"))  // Formato YYYY-MM
            .Select(g => new TendenciaDTO
            {
                Periodo = g.Key,                                               // Ej: "2024-01"
                TicketsCreados = g.Count(),
                TicketsCerrados = g.Count(t => t.Date_Cierre.HasValue),
                TicketsAbiertos = g.Count(t => t.Date_Cierre == null),
                TiempoPromedioResolucionHoras = CalcularTiempoPromedio(
                    g.Where(t => t.Date_Cierre.HasValue).ToList()
                )
            })
            .OrderBy(t => t.Periodo)
            .ToList();
    }

    return tendencias;
}
```

---

## 📐 Funciones Helper

### CalcularTiempoPromedio

```csharp
private static double CalcularTiempoPromedio(List<TicketDTO> tickets)
{
    // Si no hay tickets cerrados, retorna 0
    if (!tickets.Any() || !tickets.Any(t => t.Date_Creado.HasValue && t.Date_Cierre.HasValue))
        return 0;

    // Calcular tiempo de resolución para cada ticket
    var tiempos = tickets
        .Where(t => t.Date_Creado.HasValue && t.Date_Cierre.HasValue)
        .Select(t => (t.Date_Cierre!.Value - t.Date_Creado!.Value).TotalHours);

    // Retornar promedio redondeado a 2 decimales
    return Math.Round(tiempos.Average(), 2);
}

// Ejemplo:
// Ticket 1: Creado 2024-01-27 08:00, Cerrado 2024-01-27 16:00 = 8 horas
// Ticket 2: Creado 2024-01-27 12:00, Cerrado 2024-01-28 12:00 = 24 horas
// Promedio = (8 + 24) / 2 = 16 horas
```

### GetWeekNumber

```csharp
private static int GetWeekNumber(DateTime date)
{
    var culture = System.Globalization.CultureInfo.CurrentCulture;
    return culture.Calendar.GetWeekOfYear(date, 
        System.Globalization.CalendarWeekRule.FirstDay,  // Comienza en lunes
        DayOfWeek.Monday);
}

// Ejemplo:
// GetWeekNumber(2024-01-01) = 1
// GetWeekNumber(2024-01-08) = 2
// GetWeekNumber(2024-12-30) = 52
```

---

## 🌐 Endpoint API

**Ubicación:** [ReportesController.cs](../TicketsAPI/Controllers/ReportesController.cs#L121)

```http
GET /api/v1/Reportes/Tendencias
Authorization: Bearer {token}
```

### Parámetros Query

| Parámetro | Tipo | Obligatorio | Default | Ejemplo |
|-----------|------|-------------|---------|---------|
| `FechaDesde` | DateTime | No | Hace 1 mes | `2024-01-01` |
| `FechaHasta` | DateTime | No | Hoy | `2024-01-31` |
| `IdPrioridad` | int | No | Ninguno | `1` (Crítica) |
| `IdDepartamento` | int | No | Ninguno | `3` (Soporte) |
| `IdEstado` | int | No | Ninguno | `2` (En Progreso) |
| `AgrupacionPeriodo` | string | No | `dia` | `dia`, `semana` o `mes` |

### Ejemplos de Llamadas

#### 1️⃣ Tendencias Diarias (Últimos 7 días)
```bash
curl -X GET "http://localhost:5000/api/v1/Reportes/Tendencias?FechaDesde=2024-01-21&FechaHasta=2024-01-27&AgrupacionPeriodo=dia" \
  -H "Authorization: Bearer {token}"
```

#### 2️⃣ Tendencias Semanales de Prioridad Alta
```bash
curl -X GET "http://localhost:5000/api/v1/Reportes/Tendencias?FechaDesde=2024-01-01&FechaHasta=2024-01-31&IdPrioridad=2&AgrupacionPeriodo=semana" \
  -H "Authorization: Bearer {token}"
```

#### 3️⃣ Tendencias Mensuales del Departamento de Soporte
```bash
curl -X GET "http://localhost:5000/api/v1/Reportes/Tendencias?FechaDesde=2023-01-01&FechaHasta=2024-01-31&IdDepartamento=1&AgrupacionPeriodo=mes" \
  -H "Authorization: Bearer {token}"
```

---

## 📊 Ejemplos de Respuesta

### Tendencias Diarias

```json
{
  "exitoso": true,
  "mensaje": "Tendencias obtenidas correctamente",
  "datos": [
    {
      "periodo": "2024-01-25",
      "ticketsCreados": 12,
      "ticketsCerrados": 8,
      "ticketsAbiertos": 4,
      "tiempoPromedioResolucionHoras": 18.5
    },
    {
      "periodo": "2024-01-26",
      "ticketsCreados": 15,
      "ticketsCerrados": 10,
      "ticketsAbiertos": 5,
      "tiempoPromedioResolucionHoras": 22.3
    },
    {
      "periodo": "2024-01-27",
      "ticketsCreados": 9,
      "ticketsCerrados": 7,
      "ticketsAbiertos": 2,
      "tiempoPromedioResolucionHoras": 16.8
    }
  ]
}
```

### Tendencias Semanales

```json
{
  "exitoso": true,
  "datos": [
    {
      "periodo": "Semana 1",
      "ticketsCreados": 45,
      "ticketsCerrados": 38,
      "ticketsAbiertos": 7,
      "tiempoPromedioResolucionHoras": 19.2
    },
    {
      "periodo": "Semana 2",
      "ticketsCreados": 52,
      "ticketsCerrados": 45,
      "ticketsAbiertos": 7,
      "tiempoPromedioResolucionHoras": 21.5
    },
    {
      "periodo": "Semana 3",
      "ticketsCreados": 38,
      "ticketsCerrados": 35,
      "ticketsAbiertos": 3,
      "tiempoPromedioResolucionHoras": 17.8
    }
  ]
}
```

### Tendencias Mensuales

```json
{
  "exitoso": true,
  "datos": [
    {
      "periodo": "2023-11",
      "ticketsCreados": 156,
      "ticketsCerrados": 142,
      "ticketsAbiertos": 14,
      "tiempoPromedioResolucionHoras": 18.9
    },
    {
      "periodo": "2023-12",
      "ticketsCreados": 198,
      "ticketsCerrados": 185,
      "ticketsAbiertos": 13,
      "tiempoPromedioResolucionHoras": 20.3
    },
    {
      "periodo": "2024-01",
      "ticketsCreados": 142,
      "ticketsCerrados": 128,
      "ticketsAbiertos": 14,
      "tiempoPromedioResolucionHoras": 19.7
    }
  ]
}
```

---

## 🎨 Interpretación de Tendencias

### Métrica: TicketsCreados
**¿Qué significa?** Demanda de tickets en ese período

```
Día 1: 12 tickets
Día 2: 15 tickets  ↑ 25% más demanda
Día 3: 9 tickets   ↓ 40% menos demanda

Tendencia: Volumen variable, pico en Día 2
```

### Métrica: TicketsCerrados
**¿Qué significa?** Productividad del equipo

```
Día 1: Creados=12, Cerrados=8  → Eficiencia=66.7%
Día 2: Creados=15, Cerrados=10 → Eficiencia=66.7%
Día 3: Creados=9,  Cerrados=7  → Eficiencia=77.8%

Tendencia: Equipo mantiene eficiencia consistente
```

### Métrica: TicketsAbiertos
**¿Qué significa?** Acumulación de trabajo pendiente

```
Día 1: Abiertos=4
Día 2: Abiertos=5  ↑ Acumulación creciente
Día 3: Abiertos=2  ↓ Recuperación

Alerta: Si siempre crece → Equipo no da abasto
```

### Métrica: TiempoPromedioResolucionHoras
**¿Qué significa?** Velocidad de resolución

```
Día 1: 18.5 horas
Día 2: 22.3 horas ↑ Tickets más complejos O equipo lento
Día 3: 16.8 horas ↓ Tickets más simples O equipo rápido

Tendencia: Aumento podría indicar problemas de SLA
```

---

## 🔍 Análisis por Prioridad (NUEVO)

Actualmente, las tendencias NO muestran desagregación por prioridad. Para eso, se puede:

### Opción 1: Obtener tendencias y filtrar manualmente
```bash
# Obtener tendencias de tickets de PRIORIDAD ALTA
GET /api/v1/Reportes/Tendencias?IdPrioridad=2&AgrupacionPeriodo=dia
```

Esto retorna tendencias SOLO de prioridad alta.

### Opción 2: Crear endpoint dedicado (FUTURO)
```bash
GET /api/v1/Reportes/Tendencias/PorPrioridad?AgrupacionPeriodo=dia
```

Respuesta esperada:
```json
{
  "exitoso": true,
  "datos": {
    "Crítica": [
      {"periodo": "2024-01-27", "ticketsCreados": 2, "ticketsCerrados": 1, ...},
      {"periodo": "2024-01-28", "ticketsCreados": 3, "ticketsCerrados": 2, ...}
    ],
    "Alta": [
      {"periodo": "2024-01-27", "ticketsCreados": 5, "ticketsCerrados": 4, ...},
      {"periodo": "2024-01-28", "ticketsCreados": 7, "ticketsCerrados": 6, ...}
    ],
    "Media": [...],
    "Baja": [...]
  }
}
```

---

## 📈 Casos de Uso Reales

### 1. Monitoreo Diario
```bash
# Jefe de turno revisa tendencias del día
GET /api/v1/Reportes/Tendencias?FechaDesde={hoy}&FechaHasta={hoy}&AgrupacionPeriodo=dia
```

### 2. Reporte Semanal
```bash
# Manager revisa productividad de la semana
GET /api/v1/Reportes/Tendencias?FechaDesde={hace 7 días}&FechaHasta={hoy}&AgrupacionPeriodo=dia
```

### 3. Análisis Mensual
```bash
# Director revisa tendencias de los últimos 6 meses
GET /api/v1/Reportes/Tendencias?FechaDesde=2023-08-01&FechaHasta=2024-01-31&AgrupacionPeriodo=mes
```

### 4. Análisis por Departamento
```bash
# Gerente de Soporte revisa carga de trabajo
GET /api/v1/Reportes/Tendencias?IdDepartamento=1&AgrupacionPeriodo=semana&FechaDesde=2024-01-01&FechaHasta=2024-01-31
```

---

## 🧮 Fórmulas Clave

### Tasa de Cierre
$$\text{Tasa Cierre} = \frac{\text{Tickets Cerrados}}{\text{Tickets Creados}} \times 100\%$$

**Ejemplo:**
- Día 1: Creados=12, Cerrados=8 → Tasa = 66.7%
- Día 2: Creados=15, Cerrados=10 → Tasa = 66.7%
- Promedio: 66.7% de los tickets se cierran mismo día

### Carga Acumulada
$$\text{Carga} = \sum \text{TicketsAbiertos}$$

**Ejemplo:**
- Fin Día 1: 4 tickets abiertos
- Fin Día 2: 5 tickets abiertos (carga creciente)
- Fin Día 3: 2 tickets abiertos (carga normalizada)

### Eficiencia de Resolución
$$\text{Eficiencia} = \frac{\text{Tickets Cerrados}}{\text{Tickets Abiertos}}$$

**Ejemplo:**
- Día 1: 8 cerrados / 4 abiertos = 2:1 (bueno)
- Día 2: 10 cerrados / 5 abiertos = 2:1 (bueno)
- Día 3: 7 cerrados / 2 abiertos = 3.5:1 (excelente)

---

## 🔧 Mejoras Futuras (FASE 2)

- [ ] Desglose por prioridad en tendencias
- [ ] Desglose por estado (abierto, en progreso, cerrado)
- [ ] Predicción de tendencias (machine learning)
- [ ] Alertas automáticas si carga excede umbral
- [ ] Comparación mes a mes / año a año
- [ ] Exportación a CSV/Excel
- [ ] Visualización en gráficos (Chart.js)

---

## 📋 Checklist de Testing

- [ ] Tendencias diarias últimos 7 días
- [ ] Tendencias semanales último mes
- [ ] Tendencias mensuales último año
- [ ] Filtrar por IdPrioridad=1 (Crítica)
- [ ] Filtrar por IdDepartamento
- [ ] Filtrar por IdEstado
- [ ] Combinación de múltiples filtros
- [ ] Fecha inválida (FechaDesde > FechaHasta)
- [ ] Sin datos en rango de fechas
- [ ] Performance con 1000+ tickets

---

## 🔗 Referencias

- [ReporteService.cs](../TicketsAPI/Services/Implementations/ReporteService.cs#L190)
- [ReportesController.cs](../TicketsAPI/Controllers/ReportesController.cs#L121)
- [TendenciaDTO](../TicketsAPI/Models/DTOs.cs#L490)
- [FASE 3 - Reportes Completo](./FASE_3_COMPLETO.md)

---

*Documento creado: 30 de enero de 2026*  
*Para referencia y análisis de tendencias*
