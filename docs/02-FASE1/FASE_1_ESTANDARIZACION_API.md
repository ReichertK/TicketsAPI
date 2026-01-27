# FASE 1: ESTANDARIZACIÓN API
## Plan Detallado de Implementación

**Fecha:** 23 de Enero 2026  
**Duración Estimada:** 1 día  
**Objetivo:** Crear estructura consistente en todos los endpoints antes de agregar funcionalidad nueva

---

## 🎯 OBJETIVOS DE FASE 1

1. ✅ Crear `ApiResponse<T>` genérico para respuestas consistentes
2. ✅ Refactorizar `BaseApiController` con métodos helper
3. ✅ Actualizar todos los 12 controllers para usar nuevas response methods
4. ✅ Establecer estándares de error handling
5. ✅ Documentar convenciones de API

---

## 📐 ESTRUCTURA DE RESPUESTA ESTÁNDAR

### Formato Actual (Inconsistente)
```csharp
// Algunos endpoints retornan esto:
{
  "exitoso": true,
  "datos": [ { "id": 1, "nombre": "Test" } ]
}

// Otros retornan arrays directamente:
[ { "id": 1, "nombre": "Test" } ]

// Algunos retornan objetos custom:
{
  "message": "Success",
  "data": { }
}
```

### Formato Objetivo (Consistente)
```csharp
// Success con datos (200 OK)
{
  "success": true,
  "statusCode": 200,
  "message": "Operación exitosa",
  "data": [ 
    { "id": 1, "nombre": "Test" },
    { "id": 2, "nombre": "Test2" }
  ],
  "timestamp": "2026-01-23T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000001"
}

// Error (400/401/403/500)
{
  "success": false,
  "statusCode": 400,
  "message": "Solicitud inválida",
  "errors": [
    {
      "field": "email",
      "message": "Email no válido"
    }
  ],
  "timestamp": "2026-01-23T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000002"
}

// Error 404
{
  "success": false,
  "statusCode": 404,
  "message": "Recurso no encontrado",
  "errors": [ ],
  "timestamp": "2026-01-23T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000003"
}
```

---

## 🔧 IMPLEMENTACIÓN

### PASO 1: Crear ApiResponse<T>

**Archivo:** `Models/ApiResponse.cs` (NUEVO)

```csharp
using System;
using System.Collections.Generic;

namespace TicketsAPI.Models
{
    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public int StatusCode { get; set; }
        public string Message { get; set; }
        public T Data { get; set; }
        public List<ApiError> Errors { get; set; }
        public DateTime Timestamp { get; set; }
        public string TraceId { get; set; }

        public ApiResponse()
        {
            Errors = new List<ApiError>();
            Timestamp = DateTime.UtcNow;
        }

        public static ApiResponse<T> SuccessResponse(T data, string message = "Operación exitosa")
        {
            return new ApiResponse<T>
            {
                Success = true,
                StatusCode = 200,
                Message = message,
                Data = data,
                Errors = new List<ApiError>()
            };
        }

        public static ApiResponse<T> CreatedResponse(T data, string message = "Recurso creado exitosamente")
        {
            return new ApiResponse<T>
            {
                Success = true,
                StatusCode = 201,
                Message = message,
                Data = data,
                Errors = new List<ApiError>()
            };
        }

        public static ApiResponse<T> ErrorResponse(int statusCode, string message, List<ApiError> errors = null)
        {
            return new ApiResponse<T>
            {
                Success = false,
                StatusCode = statusCode,
                Message = message,
                Data = default(T),
                Errors = errors ?? new List<ApiError>()
            };
        }

        public static ApiResponse<T> BadRequestResponse(string message, List<ApiError> errors = null)
        {
            return ErrorResponse(400, message, errors);
        }

        public static ApiResponse<T> UnauthorizedResponse(string message = "No autorizado")
        {
            return ErrorResponse(401, message);
        }

        public static ApiResponse<T> ForbiddenResponse(string message = "Acceso denegado")
        {
            return ErrorResponse(403, message);
        }

        public static ApiResponse<T> NotFoundResponse(string message = "Recurso no encontrado")
        {
            return ErrorResponse(404, message);
        }

        public static ApiResponse<T> ConflictResponse(string message = "Conflicto en la operación")
        {
            return ErrorResponse(409, message);
        }

        public static ApiResponse<T> InternalServerErrorResponse(string message = "Error interno del servidor")
        {
            return ErrorResponse(500, message);
        }
    }

    public class ApiError
    {
        public string Field { get; set; }
        public string Message { get; set; }

        public ApiError() { }

        public ApiError(string field, string message)
        {
            Field = field;
            Message = message;
        }
    }

    // Para casos donde T no se conoce al compilar
    public class ApiResponse
    {
        public bool Success { get; set; }
        public int StatusCode { get; set; }
        public string Message { get; set; }
        public object Data { get; set; }
        public List<ApiError> Errors { get; set; }
        public DateTime Timestamp { get; set; }
        public string TraceId { get; set; }

        public ApiResponse()
        {
            Errors = new List<ApiError>();
            Timestamp = DateTime.UtcNow;
        }
    }
}
```

---

### PASO 2: Refactorizar BaseApiController

**Archivo:** `Controllers/BaseApiController.cs` (ACTUALIZAR)

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using TicketsAPI.Models;

namespace TicketsAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class BaseApiController : ControllerBase
    {
        protected string TraceId => HttpContext?.TraceIdentifier ?? Guid.NewGuid().ToString();

        // ==================== SUCCESS RESPONSES ====================

        /// <summary>
        /// Retorna 200 OK con datos
        /// </summary>
        protected OkObjectResult OkResponse<T>(T data, string message = "Operación exitosa")
        {
            var response = new ApiResponse<T>
            {
                Success = true,
                StatusCode = 200,
                Message = message,
                Data = data,
                Errors = new List<ApiError>(),
                Timestamp = DateTime.UtcNow,
                TraceId = TraceId
            };
            return Ok(response);
        }

        /// <summary>
        /// Retorna 201 Created cuando se crea un recurso
        /// </summary>
        protected CreatedAtActionResult CreatedResponse<T>(string actionName, string controllerName, object routeValues, T data, string message = "Recurso creado exitosamente")
        {
            var response = new ApiResponse<T>
            {
                Success = true,
                StatusCode = 201,
                Message = message,
                Data = data,
                Errors = new List<ApiError>(),
                Timestamp = DateTime.UtcNow,
                TraceId = TraceId
            };
            return CreatedAtAction(actionName, new { controller = controllerName, id = routeValues }, response);
        }

        /// <summary>
        /// Retorna 204 No Content (para DELETE exitoso)
        /// </summary>
        protected NoContentResult NoContentResponse()
        {
            return NoContent();
        }

        // ==================== ERROR RESPONSES ====================

        /// <summary>
        /// Retorna 400 Bad Request
        /// </summary>
        protected BadRequestObjectResult BadRequest<T>(string message, List<ApiError> errors = null)
        {
            var response = new ApiResponse<T>
            {
                Success = false,
                StatusCode = 400,
                Message = message,
                Data = default(T),
                Errors = errors ?? new List<ApiError>(),
                Timestamp = DateTime.UtcNow,
                TraceId = TraceId
            };
            return BadRequest((object)response);
        }

        /// <summary>
        /// Retorna 401 Unauthorized
        /// </summary>
        protected UnauthorizedObjectResult UnauthorizedResponse<T>(string message = "No autorizado")
        {
            var response = new ApiResponse<T>
            {
                Success = false,
                StatusCode = 401,
                Message = message,
                Data = default(T),
                Errors = new List<ApiError>(),
                Timestamp = DateTime.UtcNow,
                TraceId = TraceId
            };
            return Unauthorized((object)response);
        }

        /// <summary>
        /// Retorna 403 Forbidden
        /// </summary>
        protected ObjectResult ForbiddenResponse<T>(string message = "Acceso denegado")
        {
            var response = new ApiResponse<T>
            {
                Success = false,
                StatusCode = 403,
                Message = message,
                Data = default(T),
                Errors = new List<ApiError>(),
                Timestamp = DateTime.UtcNow,
                TraceId = TraceId
            };
            return StatusCode(403, response);
        }

        /// <summary>
        /// Retorna 404 Not Found
        /// </summary>
        protected NotFoundObjectResult NotFoundResponse<T>(string message = "Recurso no encontrado")
        {
            var response = new ApiResponse<T>
            {
                Success = false,
                StatusCode = 404,
                Message = message,
                Data = default(T),
                Errors = new List<ApiError>(),
                Timestamp = DateTime.UtcNow,
                TraceId = TraceId
            };
            return NotFound((object)response);
        }

        /// <summary>
        /// Retorna 409 Conflict
        /// </summary>
        protected ObjectResult ConflictResponse<T>(string message = "Conflicto en la operación")
        {
            var response = new ApiResponse<T>
            {
                Success = false,
                StatusCode = 409,
                Message = message,
                Data = default(T),
                Errors = new List<ApiError>(),
                Timestamp = DateTime.UtcNow,
                TraceId = TraceId
            };
            return StatusCode(409, response);
        }

        /// <summary>
        /// Retorna 500 Internal Server Error
        /// </summary>
        protected ObjectResult InternalServerErrorResponse<T>(string message = "Error interno del servidor", Exception ex = null)
        {
            var errors = new List<ApiError>();
            if (ex != null)
            {
                errors.Add(new ApiError("exception", ex.Message));
            }

            var response = new ApiResponse<T>
            {
                Success = false,
                StatusCode = 500,
                Message = message,
                Data = default(T),
                Errors = errors,
                Timestamp = DateTime.UtcNow,
                TraceId = TraceId
            };
            return StatusCode(500, response);
        }

        // ==================== VALIDATION HELPERS ====================

        /// <summary>
        /// Valida modelo y retorna error si no es válido
        /// </summary>
        protected IActionResult ValidateModel<T>(T model, string resourceName = "Recurso")
        {
            if (model == null)
            {
                return BadRequest<T>($"{resourceName} no puede ser nulo");
            }

            if (!ModelState.IsValid)
            {
                var errors = new List<ApiError>();
                foreach (var modelState in ModelState.Values)
                {
                    foreach (var error in modelState.Errors)
                    {
                        errors.Add(new ApiError("validation", error.ErrorMessage));
                    }
                }
                return BadRequest<T>("Validación fallida", errors);
            }

            return null; // Valid
        }

        /// <summary>
        /// Obtiene el ID del usuario actual del JWT
        /// </summary>
        protected int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("id") ?? User.FindFirst("sub");
            if (int.TryParse(userIdClaim?.Value, out int userId))
            {
                return userId;
            }
            return 0;
        }

        /// <summary>
        /// Obtiene el nombre del usuario actual del JWT
        /// </summary>
        protected string GetCurrentUsername()
        {
            return User.FindFirst("usuario")?.Value ?? User.Identity?.Name ?? "Unknown";
        }

        /// <summary>
        /// Obtiene el rol del usuario actual
        /// </summary>
        protected string GetCurrentUserRole()
        {
            return User.FindFirst("rol")?.Value ?? User.FindFirst("http://schemas.microsoft.com/ws/2008/06/identity/claims/role")?.Value ?? "User";
        }
    }
}
```

---

### PASO 3: Controllers a Refactorizar

**Total: 12 controladores**

| # | Controlador | Líneas Estimadas | Métodos | Prioridad |
|---|------------|------------------|---------|-----------|
| 1 | AuthController | 80 | 2 (Login, RefreshToken) | 🔴 ALTA |
| 2 | TicketsController | 200+ | 8+ | 🔴 ALTA |
| 3 | AdminController | 300+ | 15+ | 🔴 ALTA |
| 4 | DepartamentosController | 40 | 2 | 🟡 MEDIA |
| 5 | MotivosController | 40 | 2 | 🟡 MEDIA |
| 6 | ComentariosController | 40 | 2 | 🟡 MEDIA |
| 7 | GruposController | 60 | 3 | 🟡 MEDIA |
| 8 | AprobacionesController | 60 | 3 | 🟡 MEDIA |
| 9 | TransicionesController | 60 | 3 | 🟡 MEDIA |
| 10 | ReferencesController | 80 | 5 | 🟡 MEDIA |
| 11 | StoredProceduresController | (?) | ? | 🟢 BAJA |
| 12 | BaseApiController | 150 | 10 | ✅ CREAR |

**Total: ~1100 líneas de código a refactorizar**

---

## 📝 PLANTILLA DE REFACTORIZACIÓN

### Antes (Inconsistente)
```csharp
[HttpGet]
public IActionResult GetAll()
{
    try
    {
        var tickets = _ticketsService.GetAll();
        return Ok(tickets); // Retorna array directamente
    }
    catch (Exception ex)
    {
        return StatusCode(500, new { error = ex.Message }); // Formato custom
    }
}
```

### Después (Consistente)
```csharp
[HttpGet]
public IActionResult GetAll()
{
    try
    {
        var tickets = _ticketsService.GetAll();
        return OkResponse(tickets, "Tickets obtenidos exitosamente");
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<List<TicketDTO>>(
            "Error al obtener tickets", ex);
    }
}
```

---

## 🎯 CAMBIOS ESPECÍFICOS POR CONTROLLER

### 1. AuthController (CRÍTICO)

**Métodos a actualizar:**
- `POST /Auth/Login` - Cambiar respuesta de token
- `POST /Auth/RefreshToken` - **NUEVO** (actualmente retorna 404)
- `POST /Auth/Logout` - **NUEVO** (actualmente no existe)

**Cambios en Response:**

```csharp
// ANTES
[HttpPost("Login")]
public IActionResult Login([FromBody] LoginRequest request)
{
    var result = _authService.Login(request.usuario, request.password);
    if (result == null)
        return Unauthorized(new { mensaje = "Credenciales inválidas" });
    
    return Ok(new { token = result.Token });
}

// DESPUÉS
[HttpPost("Login")]
public IActionResult Login([FromBody] LoginRequest request)
{
    var result = _authService.Login(request.usuario, request.password);
    if (result == null)
        return UnauthorizedResponse<LoginResponseDTO>("Credenciales inválidas");
    
    var loginResponse = new LoginResponseDTO
    {
        Token = result.Token,
        ExpiresIn = 660, // 11 minutos
        TokenType = "Bearer"
    };
    return OkResponse(loginResponse, "Login exitoso");
}
```

---

### 2. TicketsController (CRÍTICO)

**Métodos a actualizar:** Todos (8+)

```csharp
// GET /api/tickets
[HttpGet]
public IActionResult GetAll([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10)
{
    try
    {
        var tickets = _ticketsRepository.GetAll();
        return OkResponse(tickets, "Tickets obtenidos exitosamente");
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<List<TicketDTO>>(
            "Error al obtener tickets", ex);
    }
}

// GET /api/tickets/{id}
[HttpGet("{id}")]
public IActionResult GetById(int id)
{
    try
    {
        var ticket = _ticketsRepository.GetById(id);
        if (ticket == null)
            return NotFoundResponse<TicketDTO>($"Ticket con ID {id} no encontrado");
        
        return OkResponse(ticket, "Ticket obtenido exitosamente");
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<TicketDTO>(
            "Error al obtener ticket", ex);
    }
}

// POST /api/tickets
[HttpPost]
public IActionResult Create([FromBody] CreateTicketDTO dto)
{
    var validationError = ValidateModel(dto, "Ticket");
    if (validationError != null) return validationError;

    try
    {
        var ticket = _ticketsService.CreateTicket(dto);
        return CreatedResponse("GetById", "Tickets", new { id = ticket.Id }, ticket, 
            "Ticket creado exitosamente");
    }
    catch (ValidationException ex)
    {
        return BadRequest<TicketDTO>(ex.Message);
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<TicketDTO>(
            "Error al crear ticket", ex);
    }
}

// PUT /api/tickets/{id}
[HttpPut("{id}")]
public IActionResult Update(int id, [FromBody] UpdateTicketDTO dto)
{
    var validationError = ValidateModel(dto, "Ticket");
    if (validationError != null) return validationError;

    try
    {
        var ticket = _ticketsService.UpdateTicket(id, dto);
        return OkResponse(ticket, "Ticket actualizado exitosamente");
    }
    catch (NotFoundException ex)
    {
        return NotFoundResponse<TicketDTO>(ex.Message);
    }
    catch (ValidationException ex)
    {
        return BadRequest<TicketDTO>(ex.Message);
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<TicketDTO>(
            "Error al actualizar ticket", ex);
    }
}

// DELETE /api/tickets/{id}
[HttpDelete("{id}")]
public IActionResult Delete(int id)
{
    try
    {
        _ticketsService.DeleteTicket(id);
        return NoContentResponse();
    }
    catch (NotFoundException ex)
    {
        return NotFoundResponse<object>(ex.Message);
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<object>(
            "Error al eliminar ticket", ex);
    }
}
```

---

### 3. AdminController (CRÍTICO)

**Métodos:** ~15 endpoints

Mismo patrón que TicketsController

---

### 4. Otros Controllers (Aplicar mismo patrón)

- DepartamentosController
- MotivosController
- GruposController
- ComentariosController
- AprobacionesController
- TransicionesController
- ReferencesController
- StoredProceduresController

---

## ✅ VERIFICACIÓN POST-IMPLEMENTACIÓN

### Tests a ejecutar

```python
# test_response_format.py
def test_all_endpoints_return_standard_format():
    """Verifica que TODOS los endpoints retornen ApiResponse<T>"""
    endpoints = [
        ('GET', '/api/tickets'),
        ('GET', '/api/tickets/1'),
        ('GET', '/api/departamentos'),
        ('GET', '/api/motivos'),
        ('GET', '/api/grupos'),
        # ... 40+ endpoints más
    ]
    
    for method, url in endpoints:
        response = requests.request(method, f"http://localhost:5000{url}")
        data = response.json()
        
        # Verificar estructura
        assert 'success' in data
        assert 'statusCode' in data
        assert 'message' in data
        assert 'data' in data
        assert 'timestamp' in data
        assert 'traceId' in data
```

---

## 📋 CHECKLIST DE IMPLEMENTACIÓN

### Creación de clases
- [ ] Crear `ApiResponse<T>` en `Models/ApiResponse.cs`
- [ ] Crear clase `ApiError`

### Actualización de BaseApiController
- [ ] Crear 10 métodos de response (OkResponse, CreatedResponse, etc.)
- [ ] Crear helpers para validación
- [ ] Crear helpers para obtener datos del JWT

### Refactorización de Controllers (Orden de prioridad)
- [ ] AuthController (2 métodos)
- [ ] TicketsController (8+ métodos)
- [ ] AdminController (15+ métodos)
- [ ] DepartamentosController (2 métodos)
- [ ] MotivosController (2 métodos)
- [ ] GruposController (3 métodos)
- [ ] ComentariosController (2 métodos)
- [ ] AprobacionesController (3 métodos)
- [ ] TransicionesController (3 métodos)
- [ ] ReferencesController (5 métodos)
- [ ] StoredProceduresController (? métodos)

### Testing
- [ ] Ejecutar test suite original (debe pasar 100%)
- [ ] Agregar tests de formato de respuesta
- [ ] Verificar que todos los status codes sean correctos

### Documentación
- [ ] Actualizar README con nuevos status codes
- [ ] Documentar estructura de ApiResponse<T>
- [ ] Crear guía de error handling

---

## 📊 IMPACTO ESPERADO

**Antes:**
- ❌ Respuestas inconsistentes (array, objeto, custom)
- ❌ Manejo de errores variable
- ❌ Dificultad para hacer client code

**Después:**
- ✅ Todas las respuestas siguen patrón consistente
- ✅ Manejo de errores estándar
- ✅ Client code puede asumir estructura conocida
- ✅ Facilita documentación de Swagger
- ✅ Mejora testabilidad

---

## ⏱️ ESTIMACIÓN DE TIEMPO

| Tarea | Tiempo Estimado |
|-------|-----------------|
| Crear ApiResponse<T> | 30 min |
| Actualizar BaseApiController | 1 hora |
| Refactorizar AuthController | 30 min |
| Refactorizar TicketsController | 1.5 horas |
| Refactorizar AdminController | 2 horas |
| Refactorizar otros 6 controllers | 2 horas |
| Testing y validación | 1.5 horas |
| **TOTAL** | **~9 horas** |

---

## 🚀 SIGUIENTE PASO

Una vez completada FASE 1:
- ✅ Compilar sin errores
- ✅ Ejecutar test suite (debe pasar 100%)
- ✅ Verificar formato de respuestas con Postman/Insomnia

Luego → **FASE 2: Tests Unitarios** con xUnit

---

**Documento generado:** 2026-01-23  
**Versión:** 1.0
