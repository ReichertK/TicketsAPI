# TicketsAPI - Análisis Completo de Permisos, Validaciones y Casos Borde

**Fecha:** 23 de Diciembre de 2025  
**Estado:** Análisis Preparado para Implementación  
**Desarrollador Ausente:** Análisis Autónomo

---

## 📋 Resumen Ejecutivo

### Estado Actual
- ✅ POST /Tickets usa `sp_agregar_tkt` correctamente (sp_driven)
- ✅ GET /Tickets usa `sp_listar_tkts` con filtros y paginación (sp_driven)
- ✅ JWT + claim extracción (`sub`/NameIdentifier) funcionando
- ✅ Build limpio (0 errores)
- ❌ **Validaciones de FK (Depto, Prioridad, Motivo) ausentes**
- ❌ **Códigos HTTP inconsistentes** (500 donde debería ser 400)
- ⚠️ **Flujo de permisos por rol NO documentado**

### Problemas Identificados

| # | Severidad | Tipo | Descripción |
|---|-----------|------|-------------|
| 1 | 🔴 ALTA | Validación | FK inválida en POST /Tickets (Id_Prioridad, Id_Departamento, Id_Motivo) → HTTP 500 |
| 2 | 🔴 ALTA | Validación | FK inválida en PUT /Tickets → HTTP 500 |
| 3 | 🟠 MEDIA | Permisos | No valida si usuario puede acceder a tickets de otros (SP-driven pero sin lógica clara) |
| 4 | 🟠 MEDIA | HTTP | Errores de FK retornan 500 (interno) en lugar de 400 (cliente) |
| 5 | 🟡 BAJA | Docs | Flujo de permisos por rol (ADMIN/TECNICO/USUARIO) no documentado |

---

## 🔐 Flujo de Permisos (Basado en Sistema Original)

### Extracción de Usuario desde JWT

**Ubicación:** `BaseApiController.GetCurrentUserId()`

```csharp
protected int GetCurrentUserId()
{
    // Prefer standard NameIdentifier (mapped from 'sub' by JWT handler)
    var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                       ?? User.FindFirst("sub")?.Value;
    return int.TryParse(userIdClaim, out var userId) ? userId : 0;
}
```

**Claim JWT (AuthService.cs:118):**
```csharp
new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()),
```

**Estado:** ✅ Funciona correctamente con ambas formas de claim.

---

### Modelo de Permisos Actual

#### Base de Datos - Tablas de Rol/Permiso

```
usuario (idUsuario, nombre, tipo='INT'|'CLI', ...)
         ↓ (relación N:M vía usuario_rol)
rol (idRol, nombre_rol, descripcion)
         ↓ (relación N:M vía rol_permiso)
permiso (idPermiso, codigo, descripcion)
```

#### Usuarios de Prueba en BD

```sql
INSERT INTO usuario VALUES:
- idUsuario=1, nombre='Admin', tipo='INT' (Usuario administrativo)
- idUsuario=2, nombre='Supervisor', tipo='INT' (Supervisory role)
- idUsuario=3, nombre='Operador Uno', tipo='INT' (Operator role)
```

**⚠️ NOTA:** No hay relación explícita usuario→rol en inserts. Asumir que rol viene de tabla `usuario_rol`.

#### Ticket - Columnas Relevantes para Permisos

```sql
tkt table:
- Id_Tkt (PK)
- Id_Usuario (FK usuario.idUsuario) ← CREADOR
- Id_Usuario_Asignado (FK usuario.idUsuario) ← ASIGNADO
- Id_Estado (FK estado.Id_Estado) ← Controla transiciones
- Id_Departamento (FK departamento.Id_Departamento) ← FILTER por rol
- Habilitado (INT) ← Flag logico de eliminación
```

---

## 🎯 Comportamiento Esperado por Rol

### 1. ADMIN (Tipo='INT' + Rol Admin)

**Visibilidad:**
- ✅ VE TODOS los tickets (sin filtro por usuario/departamento)
- ✅ Puede crear tickets (con cualquier Id_Usuario válido)
- ✅ Puede asignar/reasignar tickets
- ✅ Puede transicionar a cualquier estado válido

**GET /Tickets Esperado:**
```
Query: GET /Tickets?Id_Estado=1&Id_Prioridad=2&Id_Departamento=10&Id_Motivo=5
SP: sp_listar_tkts(
  w_Id_Tkt=null,
  w_Id_Estado=1,
  w_Date_Creado=null,
  w_Date_Cierre=null,
  w_Date_Asignado=null,
  w_Date_Cambio_Estado=null,
  w_Id_Usuario=<ADMIN_ID>,       ← JWT userId, NO solicitud
  w_Nombre_Usuario=null,
  w_Id_Empresa=null,
  w_Id_Perfil=null,
  w_Id_Motivo=5,
  w_Id_Sucursal=null,
  w_Habilitado=1,
  w_Id_Prioridad=2,
  w_Contenido=null,
  w_Id_Departamento=10,
  w_Page=1,
  w_Page_Size=10,
  @totalRecords=OUT
)
Resultado: Tickets creados por Admin + asignados + otros (según SP logic)
```

**Restricción:** Admin NO puede forzar ver tickets de otro usuario (userId viene del JWT, no del request).

---

### 2. TECNICO (Tipo='INT' + Rol Técnico)

**Visibilidad (Según Sistema Original):**
- ✅ VE tickets asignados a él (Id_Usuario_Asignado = userId)
- ✅ VE tickets creados por él (Id_Usuario = userId)
- ⚠️ VE tickets del departamento si está asignado a ese depto
- ❌ NO VE tickets de otros usuarios/deptos (a menos que sea asignado)

**GET /Tickets Esperado:**
```
Query: GET /Tickets?Id_Departamento=10
SP: w_Id_Usuario=<TECNICO_ID> ← Misma extracción JWT
   w_Id_Departamento=10

Resultado: Solo tickets donde:
  - Id_Usuario = TECNICO_ID, O
  - Id_Usuario_Asignado = TECNICO_ID, O
  - Id_Departamento = 10 AND usuario tiene acceso
```

**Restricción:** El SP es la fuente de verdad; la API NO filtra en memoria.

---

### 3. USUARIO (Tipo='CLI' o Rol Usuario)

**Visibilidad:**
- ✅ VE solo tickets creados por él
- ❌ NO VE tickets asignados a otros
- ❌ NO VE tickets de otros usuarios

**GET /Tickets Esperado:**
```
Query: GET /Tickets
SP: w_Id_Usuario=<USER_ID> ← JWT userId
   (sin otros filtros)

Resultado: Solo tickets donde Id_Usuario = USER_ID
```

---

## 🔍 Análisis Técnico del SP `sp_listar_tkts`

### Firma del SP

```sql
CREATE PROCEDURE sp_listar_tkts(
    IN w_Id_Tkt BIGINT(20),
    IN w_Id_Estado INT(10),
    IN w_Date_Creado DATE,
    IN w_Date_Cierre DATETIME,
    IN w_Date_Asignado DATETIME,
    IN w_Date_Cambio_Estado DATETIME,
    IN w_Id_Usuario INT(20),          ← ⭐ CLAVE: Usuario actual
    IN w_Nombre_Usuario VARCHAR(150),
    IN w_Id_Empresa INT(20),
    IN w_Id_Perfil INT(20),
    IN w_Id_Motivo INT(20),
    IN w_Id_Sucursal INT(20),
    IN w_Habilitado INT(20),
    IN w_Id_Prioridad INT(20),
    IN w_Contenido VARCHAR(150),
    IN w_Id_Departamento INT(20),
    IN w_Page INT,
    IN w_Page_Size INT,
    OUT totalRecords INT
)
```

### Comportamiento del SP

1. **Filtrado Dinámico:** Todos los parámetros son opcionales (NULL-safe)
2. **Joins con tablas de datos:**
   ```sql
   FROM tkt t
   LEFT JOIN usuario u ON t.Id_Usuario = u.idUsuario
   LEFT JOIN departamento d ON t.Id_Departamento = d.Id_Departamento
   LEFT JOIN prioridad p ON t.Id_Prioridad = p.Id_Prioridad
   LEFT JOIN estado e ON t.Id_Estado = e.Id_Estado
   ```
3. **Paginación:** LIMIT/OFFSET basado en w_Page + w_Page_Size
4. **Total:** FOUND_ROWS() → `@totalRecords`

**⚠️ LIMITACIÓN:** El SP recibe `w_Id_Usuario` pero la API siempre lo sobrescribe con userId del JWT. Esto es CORRECTO para seguridad.

---

## 📊 Análisis de Validaciones Actuales

### POST /Tickets - CreateUpdateTicketDTO

**Validaciones Presentes:**

```csharp
public class CreateUpdateTicketDTO
{
    [Required] [StringLength(10000, MinimumLength=10)]
    public string Contenido { get; set; }        // ✅ Validado
    
    [Required]
    public int Id_Prioridad { get; set; }        // ❌ NO valida FK
    
    [Required]
    public int Id_Departamento { get; set; }     // ❌ NO valida FK
    
    public int? Id_Usuario_Asignado { get; set; } // ❌ NO valida FK
    public int? Id_Motivo { get; set; }          // ❌ NO valida FK
}
```

**Validaciones Ausentes:**

| Campo | Tabla Ref | Validación Necesaria | Ubicación Ideal |
|-------|-----------|----------------------|-----------------|
| Id_Prioridad | prioridad | SELECT EXISTS | Service layer |
| Id_Departamento | departamento | SELECT EXISTS | Service layer |
| Id_Motivo | motivo | SELECT EXISTS | Service layer |
| Id_Usuario_Asignado | usuario | SELECT EXISTS | Service layer |

**Impacto:** FK constraint violation → HTTP 500, debería ser HTTP 400.

---

## 🐛 Casos Borde Identificados

### 1. FK Inválida en POST /Tickets

**Escenario:**
```
POST /api/v1/Tickets
Authorization: Bearer <admin_jwt>
Content-Type: application/json

{
  "contenido": "Test",
  "id_prioridad": 999,    ← NO existe
  "id_departamento": 1,
  "id_motivo": null
}
```

**Resultado Actual:** HTTP 500 (Constraint violation)
```json
{
  "exitoso": false,
  "mensaje": "Error interno del servidor",
  "errores": ["Foreign key constraint violation..."]
}
```

**Resultado Esperado:** HTTP 400
```json
{
  "exitoso": false,
  "mensaje": "Datos inválidos",
  "errores": ["Id_Prioridad '999' no existe en tabla prioridad"]
}
```

---

### 2. Usuario Intenta Crear Ticket Asignándose a Otro Usuario

**Escenario:**
```
POST /api/v1/Tickets
Authorization: Bearer <user1_jwt>  (userId=5)
{
  "contenido": "Test",
  "id_prioridad": 1,
  "id_departamento": 1,
  "id_usuario_asignado": 10  ← Otro usuario
}
```

**Comportamiento Actual:** ✅ Permitido (pero el SP puede validar en transiciones)
**Comportamiento Esperado:** Según reglas de negocio MVC original (permitir o no)

---

### 3. GET /Tickets sin Permisos a Departamento

**Escenario:**
```
GET /api/v1/Tickets?Id_Departamento=50  ← Depto sin acceso
Authorization: Bearer <tecnico_jwt>     (userId=3, depto asignado=10)
```

**Resultado:** Retorna tickets vacíos (SP filtra correctamente)
**Consideración:** ¿Debería retornar 403 o lista vacía? Sistema original → lista vacía.

---

### 4. Paginación en Límites

**Escenario:**
```
GET /api/v1/Tickets?Pagina=0&TamañoPagina=0
GET /api/v1/Tickets?Pagina=-5&TamañoPagina=1000
```

**Validación Actual:**
```csharp
var page = Math.Max(1, filtro.Pagina);                    // ✅ Min page=1
var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);   // ✅ Rango 1-100
```

**Estado:** ✅ Ya protegido en TicketRepository.GetFilteredAsync()

---

## 🛠️ Mejoras Recomendadas (Sin Tocar BD/SP)

### 1. Agregar Validación de FK en Service Layer

**Ubicación:** `TicketService.CreateAsync()` y `TicketService.UpdateAsync()`

**Pseudocódigo:**

```csharp
public async Task<int> CreateAsync(CreateUpdateTicketDTO dto, int idUsuarioCreador)
{
    // NUEVA: Validar referencias
    var validationErrors = new List<string>();
    
    // Validar Id_Prioridad
    if (!await _prioridadRepository.ExistsAsync(dto.Id_Prioridad))
        validationErrors.Add($"Id_Prioridad '{dto.Id_Prioridad}' no existe");
    
    // Validar Id_Departamento
    if (!await _departamentoRepository.ExistsAsync(dto.Id_Departamento))
        validationErrors.Add($"Id_Departamento '{dto.Id_Departamento}' no existe");
    
    // Validar Id_Motivo (opcional pero si presente, validar)
    if (dto.Id_Motivo.HasValue && 
        !await _motivoRepository.ExistsAsync(dto.Id_Motivo.Value))
        validationErrors.Add($"Id_Motivo '{dto.Id_Motivo}' no existe");
    
    // Validar Id_Usuario_Asignado si está presente
    if (dto.Id_Usuario_Asignado.HasValue &&
        !await _usuarioRepository.ExistsAsync(dto.Id_Usuario_Asignado.Value))
        validationErrors.Add($"Id_Usuario_Asignado '{dto.Id_Usuario_Asignado}' no existe");
    
    if (validationErrors.Count > 0)
        throw new ValidationException(validationErrors);  // ← Lanzar excepción
    
    // Resto del flujo...
    var ticket = new Models.Entities.Ticket { ... };
    return await _ticketRepository.CreateAsync(ticket);
}
```

**En Controller (TicketsController.CreateTicket):**

```csharp
[HttpPost]
public async Task<IActionResult> CreateTicket([FromBody] CreateUpdateTicketDTO dto)
{
    try
    {
        if (!ModelState.IsValid)
            return Error<object>("Datos inválidos", statusCode: 400);

        var userId = GetCurrentUserId();
        var id = await _ticketService.CreateAsync(dto, userId);
        
        await _notificacionService.NotificarNuevoTicketAsync(id);
        return Success(new { id }, "Ticket creado exitosamente", 201);
    }
    catch (ValidationException vex)  // ← NUEVA: Capturar validación
    {
        return Error<object>(
            "Datos inválidos",
            vex.Errors,  // Lista de mensajes
            statusCode: 400);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error al crear ticket");
        return Error<object>(
            "Error interno del servidor",
            new List<string> { ex.Message },
            statusCode: 500);
    }
}
```

**Beneficios:**
- ✅ HTTP 400 (cliente) en lugar de 500 (servidor) para datos inválidos
- ✅ Mensajes de error claros (FK específico que falló)
- ✅ Compatible con MVC original (valida antes de SP)

---

### 2. Agregar Validación de Permisos en GET /Tickets

**Ubicación:** `TicketsController.GetTickets()`

**Pseudocódigo:**

```csharp
[HttpGet]
public async Task<IActionResult> GetTickets([FromQuery] TicketFiltroDTO filtro)
{
    try
    {
        var userId = GetCurrentUserId();
        if (userId <= 0)
            return Unauthorized(new { message = "Usuario no autenticado" });

        // NUEVA: Obtener rol del usuario
        var userRole = GetCurrentUserRole();  // Implementado en BaseApiController
        
        // NUEVA: Validar filtros según permisos
        if (filtro.Id_Departamento.HasValue && !CanAccessDepartment(userId, filtro.Id_Departamento.Value))
        {
            return Error<object>(
                "No tiene permisos para acceder a este departamento",
                statusCode: 403);  // ← HTTP 403 Forbidden
        }

        filtro ??= new TicketFiltroDTO();
        filtro.Id_Usuario = userId;

        var result = await _ticketService.GetFilteredAsync(filtro);
        return Success(result, "Tickets obtenidos exitosamente");
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error al obtener tickets");
        return Error<object>("Error interno del servidor", ..., 500);
    }
}

// Método auxiliar
private bool CanAccessDepartment(int userId, int departmentId)
{
    // Implementar lógica según sistema original
    // Ej: verificar si usuario está asignado a ese depto
    // Por ahora: retornar true (dejar que SP maneje)
    return true;
}
```

**Nota:** Esta validación es OPCIONAL si el SP ya maneja permisos internamente.

---

### 3. Mejorar Manejo de Errores en BaseApiController

**Ubicación:** `BaseApiController` (nuevo método)

```csharp
/// <summary>
/// Captura ValidationException y retorna 400
/// </summary>
protected IActionResult HandleValidationError(List<string> errors)
{
    return Error<object>(
        "Validación fallida",
        errors,
        statusCode: 400);
}

/// <summary>
/// Captura PermissionException y retorna 403
/// </summary>
protected IActionResult HandlePermissionError(string message)
{
    return Error<object>(
        message ?? "Acceso denegado",
        statusCode: 403);
}
```

---

## 📋 Plan de Testing por Rol

### Test 1: ADMIN - Visibilidad Completa

**Precondiciones:**
- JWT válido para userId=1 (Admin)
- Datos en BD: 6 tickets (según cdk_tkt.sql insert)

**Test Cases:**

| # | Endpoint | Query | Esperado | Validar |
|---|----------|-------|----------|---------|
| 1.1 | GET /Tickets | (sin filtros) | 200 OK, lista de todos | totalRegistros > 0 |
| 1.2 | GET /Tickets | ?Id_Estado=2 | 200 OK, 4 tickets (estado=2) | estado_to.Id_Estado = 2 |
| 1.3 | GET /Tickets | ?Pagina=1&TamañoPagina=2 | 200 OK, 2 registros | paginaActual=1, tienePaginaSiguiente=true |
| 1.4 | GET /Tickets | ?Pagina=2&TamañoPagina=2 | 200 OK, 2 registros | paginaActual=2 |
| 1.5 | GET /Tickets | ?Id_Prioridad=999 | 200 OK, lista vacía | totalRegistros = 0 |
| 1.6 | POST /Tickets | contenido, prioridad=1, depto=1 | 201, id > 0 | id_Tkt creado |
| 1.7 | POST /Tickets | id_prioridad=999 | 400 Bad Request | "Id_Prioridad no existe" |
| 1.8 | POST /Tickets | id_departamento=999 | 400 Bad Request | "Id_Departamento no existe" |

**Salida Esperada (1.1):**
```json
{
  "exitoso": true,
  "mensaje": "Tickets obtenidos exitosamente",
  "datos": {
    "datos": [
      {"id_Tkt": 1, "contenido": "esto es una prueba", ...},
      {"id_Tkt": 2, "contenido": "Esto es una prueba Beta", ...},
      ...
    ],
    "totalRegistros": 6,
    "totalPaginas": 1,
    "paginaActual": 1,
    "tamañoPagina": 20
  }
}
```

---

### Test 2: TECNICO - Visibilidad Restringida

**Precondiciones:**
- JWT válido para userId=3 (Operador Uno / Técnico)
- Datos en BD: Usuario 3 es asignado en tickets 2, 3, 4

**Test Cases:**

| # | Endpoint | Query | Esperado | Validar |
|---|----------|-------|----------|---------|
| 2.1 | GET /Tickets | (sin filtros) | 200 OK, solo mis tickets | totalRegistros ≤ 3 |
| 2.2 | GET /Tickets | ?Id_Estado=1 | 200 OK, filtrado | todos con estado=1 |
| 2.3 | GET /Tickets | ?Id_Departamento=59 | 200 OK, si tiene acceso | tickets del depto |
| 2.4 | GET /Tickets | ?Id_Departamento=20 | 200 OK, vacío | totalRegistros = 0 (sin acceso) |
| 2.5 | POST /Tickets | contenido, prioridad=1, depto=10 | 201, id > 0 | creado como Id_Usuario=3 |
| 2.6 | POST /Tickets | asignado_a=5 | 201 | puede asignar si permisos |

**Salida Esperada (2.1):**
```json
{
  "exitoso": true,
  "datos": {
    "datos": [
      {"id_Tkt": 2, "id_Usuario_Asignado": 3, ...},
      {"id_Tkt": 3, "id_Usuario_Asignado": 3, ...},
      {"id_Tkt": 4, "id_Usuario_Asignado": 3, ...}
    ],
    "totalRegistros": 3,
    ...
  }
}
```

---

### Test 3: Validación de Códigos HTTP

**Test Cases:**

| # | Escenario | Endpoint | Esperado | Código |
|---|-----------|----------|----------|--------|
| 3.1 | Sin JWT | GET /Tickets | No autenticado | 401 |
| 3.2 | JWT inválido | GET /Tickets | Token malformado | 401 |
| 3.3 | Sin permisos | GET /Tickets?Id_Dept=50 | Acceso denegado | 403 |
| 3.4 | FK inválida | POST /Tickets | Datos inválidos | 400 |
| 3.5 | DTO inválido | POST /Tickets (sin contenido) | Validación fallida | 400 |
| 3.6 | No encontrado | GET /Tickets/999 | Ticket no existe | 404 |
| 3.7 | Error BD | (simular error) | Error interno | 500 |

---

## 📝 Lista de Pendientes para Implementación

### 🔴 ALTA PRIORIDAD

- [ ] **Agregar validación de FK en TicketService.CreateAsync()**
  - Validar Id_Prioridad existe
  - Validar Id_Departamento existe
  - Validar Id_Motivo existe (si present)
  - Validar Id_Usuario_Asignado existe (si present)
  - Lanzar ValidationException con lista de errores

- [ ] **Crear excepción personalizada ValidationException**
  - Properties: Errors (List<string>)
  - Capturar en TicketsController

- [ ] **Actualizar TicketsController.CreateTicket()**
  - Capturar ValidationException
  - Retornar HTTP 400 con lista de errores

- [ ] **Actualizar TicketsController.UpdateTicket()**
  - Aplicar mismas validaciones que CreateAsync
  - Capturar ValidationException
  - Retornar HTTP 400

### 🟠 MEDIA PRIORIDAD

- [ ] **Documentar flujo de permisos por rol**
  - Crear PERMISSIONS.md
  - Listar qué ve cada rol (ADMIN/TECNICO/USUARIO)
  - Documentar transiciones permitidas

- [ ] **Implementar CanAccessDepartment() en TicketsController**
  - Validar usuario tiene acceso al depto
  - Retornar HTTP 403 si no

- [ ] **Extender GetCurrentUserRole() en BaseApiController**
  - Extraer role claim del JWT
  - Cached en memoria si es posible

- [ ] **Crear método ExistsAsync() en repositorios**
  - PrioridadRepository.ExistsAsync(id)
  - DepartamentoRepository.ExistsAsync(id)
  - MotivoRepository.ExistsAsync(id)
  - UsuarioRepository.ExistsAsync(id)

### 🟡 BAJA PRIORIDAD

- [ ] **Mejorar logging de errores**
  - Log validación FK fallida
  - Log acceso denegado
  - Log transición estado no permitida

- [ ] **Crear suite de tests automatizados**
  - Unit tests para validaciones
  - Integration tests para endpoints
  - Tests por rol (Admin, Tecnico, Usuario)

- [ ] **Documentar casos borde**
  - Crear EDGE_CASES.md
  - Listar comportamiento esperado

---

## 🔗 Referencias en Codebase

### Tablas Relevantes
- `tkt` (tickets)
- `departamento`
- `prioridad`
- `motivo`
- `estado`
- `usuario`

### Stored Procedures
- `sp_agregar_tkt` - Crear ticket
- `sp_listar_tkts` - Listar tickets filtrados
- `sp_tkt_transicionar` - Cambiar estado
- `sp_tkt_historial` - Obtener historial

### Clases Clave
- `TicketsController` - Endpoints HTTP
- `TicketService` - Lógica de negocio
- `TicketRepository` - Acceso a datos
- `BaseApiController` - Base para controles
- `CreateUpdateTicketDTO` - DTO entrada
- `TicketDTO` - DTO salida

---

## 📚 Documentación Adicional Necesaria

- [ ] **PERMISSIONS.md** - Matriz de permisos por rol
- [ ] **EDGE_CASES.md** - Casos borde y comportamiento esperado
- [ ] **API_RESPONSES.md** - Códigos HTTP y formatos de respuesta
- [ ] **VALIDATION_RULES.md** - Reglas de validación por endpoint

---

## ✅ Checklist de Validación

- [x] Analizar flujo actual de permisos
- [x] Identificar validaciones faltantes
- [x] Mapear códigos HTTP correctos
- [x] Documentar casos borde
- [x] Crear plan de testing
- [ ] **Implementar validaciones FK**
- [ ] **Crear tests automatizados**
- [ ] **Ejecutar pruebas por rol**
- [ ] **Validar sistema MVC original**

---

**Próximos Pasos:**
1. Implementar validaciones FK según "🔴 ALTA PRIORIDAD"
2. Crear tests automatizados
3. Validar con sistema MVC original
4. Documentar discrepancias
