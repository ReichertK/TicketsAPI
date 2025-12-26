# Sugerencias de Validación - GET /Tickets API

**Objetivo:** Mejorar robustez sin modificar SPs ni estructura de BD  
**Compatibilidad:** 100% con MVC original  
**Impacto:** Previene errores HTTP 500, mejora UX  

---

## 1️⃣ Validación de FK Antes de Crear/Actualizar

### Problema Actual
```
POST /Tickets
{
  "contenido": "Test",
  "id_prioridad": 999,      // ❌ No existe
  "id_departamento": 1,
  "id_motivo": 5
}

Resultado: HTTP 500 "Foreign key constraint fails"
```

### Solución Propuesta

#### A. Crear Método en Cada Repository
```csharp
// PrioridadRepository.cs
public async Task<bool> ExistsAsync(int id)
{
    const string sql = "SELECT COUNT(*) FROM prioridad WHERE Id_Prioridad = @Id AND Habilitado = 1";
    var count = await conn.ExecuteScalarAsync<int>(sql, new { Id = id });
    return count > 0;
}

// Aplicar a: prioridad, departamento, motivo, usuario
```

#### B. Validar en Service Layer
```csharp
// TicketService.cs
public async Task<TicketDTO> CreateAsync(CreateUpdateTicketDTO dto, int userId)
{
    // Validaciones FK
    var prioridadExists = await _prioridadRepository.ExistsAsync(dto.Id_Prioridad);
    if (!prioridadExists)
        throw new ValidationException("Prioridad no existe");
    
    var deptoExists = await _departamentoRepository.ExistsAsync(dto.Id_Departamento);
    if (!deptoExists)
        throw new ValidationException("Departamento no existe");
    
    if (dto.Id_Motivo.HasValue)
    {
        var motivoExists = await _motivoRepository.ExistsAsync(dto.Id_Motivo.Value);
        if (!motivoExists)
            throw new ValidationException("Motivo no existe");
    }
    
    if (dto.Id_Usuario_Asignado.HasValue)
    {
        var userExists = await _usuarioRepository.ExistsAsync(dto.Id_Usuario_Asignado.Value);
        if (!userExists)
            throw new ValidationException("Usuario asignado no existe");
    }
    
    // Continuar con SP...
}
```

#### C. Crear Custom Exception
```csharp
// Exceptions/ValidationException.cs
public class ValidationException : Exception
{
    public ValidationException(string message) : base(message) { }
}
```

#### D. Manejar en Controller
```csharp
// TicketsController.cs
try
{
    var nuevoTicket = await _ticketService.CreateAsync(dto, userId);
    return Ok(new ApiResponse<TicketDTO>(nuevoTicket, "Ticket creado exitosamente"));
}
catch (ValidationException ex)
{
    return BadRequest(new ApiResponse<object>(null, ex.Message));  // ✅ 400 instead 500
}
catch (Exception ex)
{
    // Log error
    return StatusCode(500, new ApiResponse<object>(null, "Error al crear ticket"));
}
```

---

## 2️⃣ Validación de Permisos de Usuario Asignado

### Problema Actual
```csharp
// Nunca validamos si usuario asignado está activo/habilitado
POST /Tickets
{
  "id_usuario_asignado": 1000  // Usuario inactivo/inexistente
}

// SP ejecuta, FK constraint viola, retorna 500
```

### Solución Propuesta
```csharp
// En TicketService.CreateAsync()
if (dto.Id_Usuario_Asignado.HasValue)
{
    var usuario = await _usuarioRepository.GetByIdAsync(dto.Id_Usuario_Asignado.Value);
    
    if (usuario == null)
        throw new ValidationException("Usuario asignado no existe");
    
    if (!usuario.Habilitado)  // Si tabla usuario tiene esta columna
        throw new ValidationException("Usuario asignado está inactivo");
}
```

---

## 3️⃣ Validación de Departamento Activo

### Problema Actual
```
Departamento id=10 existe pero está deshabilitado (Habilitado=0)
Usuario crea ticket con id_departamento=10
Se crea exitosamente pero pertenece a depto "invisible"
```

### Solución Propuesta
```csharp
// En TicketService.CreateAsync()
private async Task ValidateDepartamentoAsync(int id)
{
    const string sql = 
        "SELECT Habilitado FROM departamento WHERE Id_Departamento = @Id";
    
    var habilitado = await conn.ExecuteScalarAsync<int?>(sql, new { Id = id });
    
    if (habilitado == null)
        throw new ValidationException("Departamento no existe");
    
    if (habilitado == 0)
        throw new ValidationException("Departamento está inactivo");
}
```

---

## 4️⃣ Validación de Transiciones de Estado

### Problema Actual
```
Ticket en estado Cerrado (3)
Usuario intenta cambiar a estado Abierto (1)
Transición no existe en tabla tkt_transicion_regla
Pero API no valida... (SP debería rechazar)
```

### Solución Propuesta
```csharp
// TicketService.cs
public async Task<bool> TransicionValidaAsync(int estadoActual, int estadoNuevo)
{
    const string sql = @"
        SELECT COUNT(*) FROM tkt_transicion_regla 
        WHERE Id_Estado_From = @From 
        AND Id_Estado_To = @To";
    
    var exists = await conn.ExecuteScalarAsync<int>(sql, 
        new { From = estadoActual, To = estadoNuevo });
    
    return exists > 0;
}

// En cambiar estado:
if (!await TransicionValidaAsync(ticket.Id_Estado, estadoNuevo))
    throw new ValidationException(
        $"No se puede cambiar de estado {ticket.Id_Estado} a {estadoNuevo}");
```

---

## 5️⃣ Validación de Permiso en Depto (TECNICO)

### Problema Actual
```csharp
// TECNICO (id=3) asignado a depto=10
// Intenta ver tickets de depto=59 (no asignado)

GET /api/v1/Tickets?Id_Departamento=59
Authorization: Bearer <jwt_tecnico>

Comportamiento: SP retorna lista vacía (200 OK)
Análisis: Transparente pero no valida acceso explícitamente
```

### Solución Propuesta (Opcional)
```csharp
// En TicketsController.GetTickets()
if (!string.IsNullOrEmpty(filtro.Departamento) && !isAdmin)
{
    var deptoAsignado = await GetTechnicianAssignedDepartment(userId);
    
    if (deptoAsignado != int.Parse(filtro.Departamento))
        return Forbid("No tiene permiso para este departamento");
}
```

**Nota:** Validación transparente actual (lista vacía) es más compatible con MVC.

---

## 6️⃣ Validación de Longitud de Contenido

### Problema Actual
```csharp
// DTO tiene [MaxLength(10000)]
// Pero ¿se valida antes de llegar al SP?
public string Contenido { get; set; }
```

### Solución Propuesta
```csharp
// CreateUpdateTicketDTO.cs
[Required(ErrorMessage = "Contenido requerido")]
[MinLength(10, ErrorMessage = "Contenido mínimo 10 caracteres")]
[MaxLength(10000, ErrorMessage = "Contenido máximo 10000 caracteres")]
public string Contenido { get; set; }
```

**Validación Actual:** ✅ Ya en DTO (ModelState.IsValid lo rechaza si viola)

---

## 7️⃣ Manejo de Estados Nulos/Inválidos

### Problema Actual
```
Ticket.Id_Estado = NULL (imposible pero BP defensiva)
GET /api/v1/Tickets
Retorna ticket con estado nulo → UI se quiebra
```

### Solución Propuesta
```csharp
// En TicketService.GetFilteredAsync()
var tickets = await _ticketRepository.GetFilteredAsync(filtro);

// Validar integridad antes de retornar
foreach (var ticket in tickets)
{
    if (string.IsNullOrEmpty(ticket.Estado))
        throw new InvalidOperationException(
            $"Ticket {ticket.Id_Tkt} sin estado válido");
}

return tickets;
```

---

## 8️⃣ Validación de Paginación

### Validaciones Actuales
```csharp
// En TicketRepository
var page = Math.Max(1, filtro.Pagina);
var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);
```

**Estado:** ✅ Ya implementado correctamente

### Tests de Boundary
```csharp
[Fact]
public async Task GetFiltered_PagenacionNegativa_RetornaPage1()
{
    var filtro = new TicketFiltroDTO { Pagina = -5, TamañoPagina = 10 };
    var result = await _repository.GetFilteredAsync(filtro);
    
    Assert.Equal(1, result.PaginaActual);  // Ajustado a 1
}

[Fact]
public async Task GetFiltered_PageSizeOver100_ClampTo100()
{
    var filtro = new TicketFiltroDTO { Pagina = 1, TamañoPagina = 1000 };
    var result = await _repository.GetFilteredAsync(filtro);
    
    Assert.Equal(100, result.Items.Count);  // Máximo 100
}
```

---

## 9️⃣ Protección contra Inyección SQL

### Status Actual
```csharp
// TicketRepository.cs
var parameters = new
{
    w_Busqueda = $"%{filtro.Busqueda}%",  // ⚠️ Concatenación
    ...
};

// SP usa: CONCAT('%', _entrada, '%')
```

### Riesgo
```sql
-- Si Busqueda = "'; DROP TABLE tkt; --"
SELECT ... WHERE Contenido LIKE CONCAT('%', '%'; DROP TABLE tkt; --%', '%')

-- En MySQL con parametrización, esto es seguro
-- Pero CONCAT siempre es mejor que concatenación en C#
```

**Status:** ✅ Ya protegido vía parametrización de Dapper

### Recomendación
```csharp
// Agregar validación defensiva en DTOs
[StringLength(1000)]  // Limitar búsqueda
public string Busqueda { get; set; }
```

---

## 🔟 Validación de Fechas

### Problema Potencial
```csharp
// Filtro de rango de fecha
if (!string.IsNullOrEmpty(filtro.FechaDesde))
{
    if (!DateTime.TryParse(filtro.FechaDesde, out var fecha))
        throw new ValidationException("Formato de fecha inválido");
}
```

### Solución Propuesta
```csharp
// TicketFiltroDTO.cs
[DataType(DataType.DateTime)]
public DateTime? FechaDesde { get; set; }

[DataType(DataType.DateTime)]
public DateTime? FechaHasta { get; set; }

// Validación post-binding
[CustomValidation(typeof(TicketFiltroDTO), nameof(ValidarFechas))]
public static ValidationResult ValidarFechas(
    TicketFiltroDTO dto, 
    ValidationContext context)
{
    if (dto.FechaDesde.HasValue && dto.FechaHasta.HasValue 
        && dto.FechaDesde > dto.FechaHasta)
        return new ValidationResult("FechaDesde no puede ser posterior a FechaHasta");
    
    return ValidationResult.Success;
}
```

---

## Prioridad de Implementación

| Prioridad | Validación | Esfuerzo | Impacto |
|-----------|------------|----------|---------|
| 🔴 HIGH | FK (Prioridad, Depto, Motivo, Usuario) | 2h | Alto (500→400) |
| 🔴 HIGH | Custom ValidationException + HTTP 400 | 1h | Alto (UX) |
| 🟠 MEDIUM | Estado activo del depto | 1h | Medio |
| 🟠 MEDIUM | Transición válida estado | 1h | Medio |
| 🟡 LOW | Validaciones fechas | 1h | Bajo |
| 🟡 LOW | Tests de boundary paginación | 1h | Bajo |

---

## Código Template para Agregar a ServiceBase

```csharp
// Services/BaseTicketService.cs (NEW)
public abstract class BaseTicketService
{
    protected readonly ITicketRepository _ticketRepository;
    protected readonly IPrioridadRepository _prioridadRepository;
    protected readonly IDepartamentoRepository _departamentoRepository;
    protected readonly IMotivoRepository _motivoRepository;
    protected readonly IUsuarioRepository _usuarioRepository;

    protected async Task ValidateForeignKeysAsync(CreateUpdateTicketDTO dto)
    {
        if (!await _prioridadRepository.ExistsAsync(dto.Id_Prioridad))
            throw new ValidationException($"Prioridad {dto.Id_Prioridad} no existe");
        
        if (!await _departamentoRepository.ExistsAsync(dto.Id_Departamento))
            throw new ValidationException($"Departamento {dto.Id_Departamento} no existe");
        
        if (dto.Id_Motivo.HasValue && 
            !await _motivoRepository.ExistsAsync(dto.Id_Motivo.Value))
            throw new ValidationException($"Motivo {dto.Id_Motivo} no existe");
        
        if (dto.Id_Usuario_Asignado.HasValue && 
            !await _usuarioRepository.ExistsAsync(dto.Id_Usuario_Asignado.Value))
            throw new ValidationException($"Usuario {dto.Id_Usuario_Asignado} no existe");
    }
}
```

---

## Testing Strategy

```csharp
// Tests/TicketsServiceTests.cs
[Fact]
public async Task CreateTicket_FKInvalida_TiraValidationException()
{
    var dto = new CreateUpdateTicketDTO 
    { 
        Contenido = "Test",
        Id_Prioridad = 999  // No existe
    };
    
    var exception = await Assert.ThrowsAsync<ValidationException>(
        () => _service.CreateAsync(dto, userId: 1)
    );
    
    Assert.Contains("Prioridad", exception.Message);
}

[Fact]
public async Task CreateTicket_FKValida_CreaTiquet()
{
    var dto = new CreateUpdateTicketDTO 
    { 
        Contenido = "Test válido",
        Id_Prioridad = 1,      // Existe
        Id_Departamento = 10   // Existe
    };
    
    var result = await _service.CreateAsync(dto, userId: 1);
    
    Assert.NotNull(result);
    Assert.True(result.Id_Tkt > 0);
}
```

---

**Nota Final:** Todas estas validaciones se pueden agregar en Service/Controller sin tocar SPs ni tablas. El MVC original probablemente ya tiene estas validaciones en su capa de servicio.
