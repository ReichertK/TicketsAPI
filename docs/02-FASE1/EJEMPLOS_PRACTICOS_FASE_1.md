# EJEMPLOS PRÁCTICOS - FASE 1 REFACTORIZACIÓN
## Cómo refactorizar cada tipo de endpoint

**Referencia:** Para usar mientras implementas FASE 1

---

## 📌 PATRONES A USAR

### Patrón 1: GET (Listar)

**ANTES (Inconsistente)**
```csharp
[HttpGet]
public IActionResult GetAll()
{
    try
    {
        var items = _repository.GetAll();
        return Ok(items); // Retorna array directo ❌
    }
    catch (Exception ex)
    {
        return StatusCode(500, new { error = ex.Message });
    }
}
```

**DESPUÉS (Consistente)**
```csharp
[HttpGet]
public IActionResult GetAll()
{
    try
    {
        var items = _repository.GetAll();
        return OkResponse(items, "Elementos obtenidos exitosamente");
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<List<ItemDTO>>(
            "Error al obtener elementos", ex);
    }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Elementos obtenidos exitosamente",
  "data": [
    { "id": 1, "nombre": "Item 1" },
    { "id": 2, "nombre": "Item 2" }
  ],
  "timestamp": "2026-01-24T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000001"
}
```

---

### Patrón 2: GET by ID

**ANTES**
```csharp
[HttpGet("{id}")]
public IActionResult GetById(int id)
{
    var item = _repository.GetById(id);
    if (item == null)
        return NotFound(new { message = "No encontrado" }); // Formato custom
    return Ok(item);
}
```

**DESPUÉS**
```csharp
[HttpGet("{id}")]
public IActionResult GetById(int id)
{
    try
    {
        var item = _repository.GetById(id);
        if (item == null)
            return NotFoundResponse<ItemDTO>($"Elemento con ID {id} no encontrado");
        
        return OkResponse(item, "Elemento obtenido exitosamente");
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<ItemDTO>(
            "Error al obtener elemento", ex);
    }
}
```

**Response (404 Not Found):**
```json
{
  "success": false,
  "statusCode": 404,
  "message": "Elemento con ID 999 no encontrado",
  "data": null,
  "errors": [],
  "timestamp": "2026-01-24T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000002"
}
```

---

### Patrón 3: POST (Crear)

**ANTES**
```csharp
[HttpPost]
public IActionResult Create([FromBody] CreateItemDTO dto)
{
    if (dto == null)
        return BadRequest("DTO nulo");
    
    var item = _repository.Create(dto);
    return Ok(new { id = item.Id, mensaje = "Creado" }); // Formato custom
}
```

**DESPUÉS**
```csharp
[HttpPost]
public IActionResult Create([FromBody] CreateItemDTO dto)
{
    var validationError = ValidateModel(dto, "Item");
    if (validationError != null) return validationError;

    try
    {
        var item = _repository.Create(dto);
        return CreatedResponse("GetById", "Items", 
            new { id = item.Id }, 
            item, 
            "Item creado exitosamente");
    }
    catch (ValidationException ex)
    {
        return BadRequest<ItemDTO>(ex.Message);
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<ItemDTO>(
            "Error al crear item", ex);
    }
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "statusCode": 201,
  "message": "Item creado exitosamente",
  "data": {
    "id": 5,
    "nombre": "Nuevo Item",
    "descripcion": "Descripción"
  },
  "timestamp": "2026-01-24T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000003"
}
```

---

### Patrón 4: PUT (Actualizar)

**ANTES**
```csharp
[HttpPut("{id}")]
public IActionResult Update(int id, [FromBody] UpdateItemDTO dto)
{
    var item = _repository.Update(id, dto);
    if (item == null)
        return NotFound();
    return Ok(item);
}
```

**DESPUÉS**
```csharp
[HttpPut("{id}")]
public IActionResult Update(int id, [FromBody] UpdateItemDTO dto)
{
    var validationError = ValidateModel(dto, "Item");
    if (validationError != null) return validationError;

    try
    {
        var item = _repository.Update(id, dto);
        if (item == null)
            return NotFoundResponse<ItemDTO>($"Item con ID {id} no encontrado");
        
        return OkResponse(item, "Item actualizado exitosamente");
    }
    catch (ValidationException ex)
    {
        return BadRequest<ItemDTO>(ex.Message);
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<ItemDTO>(
            "Error al actualizar item", ex);
    }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Item actualizado exitosamente",
  "data": {
    "id": 5,
    "nombre": "Item Actualizado",
    "descripcion": "Nueva descripción"
  },
  "timestamp": "2026-01-24T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000004"
}
```

---

### Patrón 5: DELETE

**ANTES**
```csharp
[HttpDelete("{id}")]
public IActionResult Delete(int id)
{
    _repository.Delete(id);
    return Ok(new { mensaje = "Eliminado" });
}
```

**DESPUÉS**
```csharp
[HttpDelete("{id}")]
public IActionResult Delete(int id)
{
    try
    {
        var success = _repository.Delete(id);
        if (!success)
            return NotFoundResponse<object>($"Item con ID {id} no encontrado");
        
        return NoContentResponse(); // 204 No Content
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<object>(
            "Error al eliminar item", ex);
    }
}
```

**Response (204 No Content):**
```
(vacío - solo status code)
```

---

### Patrón 6: Error de Validación (400)

**Endpoint:**
```csharp
[HttpPost]
public IActionResult Create([FromBody] CreateItemDTO dto)
{
    var validationError = ValidateModel(dto, "Item");
    if (validationError != null) return validationError;
    
    // ... resto del código
}
```

**Response (400 Bad Request):**
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Validación fallida",
  "data": null,
  "errors": [
    { "field": "validation", "message": "Nombre es requerido" },
    { "field": "validation", "message": "Email inválido" }
  ],
  "timestamp": "2026-01-24T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000005"
}
```

---

### Patrón 7: Error de Autenticación (401)

**Endpoint:**
```csharp
[HttpGet("perfil")]
public IActionResult GetPerfil()
{
    // Si no tiene token válido, el [Authorize] intercepta
    // Pero si queremos validación adicional:
    
    var userId = GetCurrentUserId();
    if (userId == 0)
        return UnauthorizedResponse<object>("Token inválido");
    
    // ... resto
}
```

**Response (401 Unauthorized):**
```json
{
  "success": false,
  "statusCode": 401,
  "message": "No autorizado",
  "data": null,
  "errors": [],
  "timestamp": "2026-01-24T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000006"
}
```

---

### Patrón 8: Error de Permiso (403)

**Endpoint:**
```csharp
[HttpDelete("{id}")]
public IActionResult Delete(int id)
{
    var userId = GetCurrentUserId();
    var userRole = GetCurrentUserRole();
    
    if (userRole != "Admin")
        return ForbiddenResponse<object>("Solo administradores pueden eliminar");
    
    // ... resto
}
```

**Response (403 Forbidden):**
```json
{
  "success": false,
  "statusCode": 403,
  "message": "Acceso denegado",
  "data": null,
  "errors": [],
  "timestamp": "2026-01-24T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000007"
}
```

---

### Patrón 9: Conflicto (409)

**Endpoint:**
```csharp
[HttpPost]
public IActionResult Create([FromBody] CreateItemDTO dto)
{
    // Verificar si ya existe
    var existing = _repository.GetByName(dto.Nombre);
    if (existing != null)
        return ConflictResponse<ItemDTO>(
            "Un item con este nombre ya existe");
    
    // ... resto
}
```

**Response (409 Conflict):**
```json
{
  "success": false,
  "statusCode": 409,
  "message": "Un item con este nombre ya existe",
  "data": null,
  "errors": [],
  "timestamp": "2026-01-24T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000008"
}
```

---

### Patrón 10: Error Interno (500)

**Endpoint:**
```csharp
[HttpGet]
public IActionResult GetAll()
{
    try
    {
        var items = _repository.GetAll();
        return OkResponse(items);
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<List<ItemDTO>>(
            "Error al obtener items", ex);
    }
}
```

**Response (500 Internal Server Error):**
```json
{
  "success": false,
  "statusCode": 500,
  "message": "Error interno del servidor",
  "data": null,
  "errors": [
    { "field": "exception", "message": "Connection timeout" }
  ],
  "timestamp": "2026-01-24T10:30:45Z",
  "traceId": "0HN1GJ7B4QC20:00000009"
}
```

---

## 🔄 REFACTORIZACIÓN PASO A PASO

### Ejemplo completo: AdminController.cs

**Archivo:** `Controllers/AdminController.cs`

**ANTES (Actual):**
```csharp
[ApiController]
[Route("api/[controller]")]
public class AdminController : ControllerBase
{
    private readonly IAdminService _adminService;
    
    public AdminController(IAdminService adminService)
    {
        _adminService = adminService;
    }
    
    [HttpGet("usuarios")]
    public IActionResult GetUsuarios()
    {
        try
        {
            var usuarios = _adminService.GetUsuarios();
            return Ok(usuarios); // ❌ Array directo
        }
        catch
        {
            return StatusCode(500);
        }
    }
    
    [HttpPost("usuarios")]
    public IActionResult CreateUsuario([FromBody] CreateUsuarioDTO dto)
    {
        try
        {
            var usuario = _adminService.CreateUsuario(dto);
            return Ok(new { id = usuario.Id }); // ❌ Formato custom
        }
        catch
        {
            return BadRequest("Error");
        }
    }
}
```

**DESPUÉS (Refactorizado):**
```csharp
[ApiController]
[Route("api/[controller]")]
public class AdminController : BaseApiController // ✅ Hereda de Base
{
    private readonly IAdminService _adminService;
    
    public AdminController(IAdminService adminService)
    {
        _adminService = adminService;
    }
    
    [HttpGet("usuarios")]
    public IActionResult GetUsuarios()
    {
        try
        {
            var usuarios = _adminService.GetUsuarios();
            return OkResponse(usuarios, "Usuarios obtenidos exitosamente"); // ✅
        }
        catch (Exception ex)
        {
            return InternalServerErrorResponse<List<UsuarioDTO>>(
                "Error al obtener usuarios", ex); // ✅
        }
    }
    
    [HttpPost("usuarios")]
    public IActionResult CreateUsuario([FromBody] CreateUsuarioDTO dto)
    {
        var validationError = ValidateModel(dto, "Usuario"); // ✅
        if (validationError != null) return validationError;

        try
        {
            var usuario = _adminService.CreateUsuario(dto);
            return CreatedResponse("GetById", "Admin",
                new { id = usuario.Id }, usuario,
                "Usuario creado exitosamente"); // ✅
        }
        catch (ValidationException ex)
        {
            return BadRequest<UsuarioDTO>(ex.Message); // ✅
        }
        catch (Exception ex)
        {
            return InternalServerErrorResponse<UsuarioDTO>(
                "Error al crear usuario", ex); // ✅
        }
    }
    
    [HttpGet("usuarios/{id}")]
    public IActionResult GetUsuario(int id)
    {
        try
        {
            var usuario = _adminService.GetUsuario(id);
            if (usuario == null)
                return NotFoundResponse<UsuarioDTO>(
                    $"Usuario con ID {id} no encontrado"); // ✅
            
            return OkResponse(usuario, "Usuario obtenido exitosamente"); // ✅
        }
        catch (Exception ex)
        {
            return InternalServerErrorResponse<UsuarioDTO>(
                "Error al obtener usuario", ex); // ✅
        }
    }
    
    [HttpPut("usuarios/{id}")]
    public IActionResult UpdateUsuario(int id, [FromBody] UpdateUsuarioDTO dto)
    {
        var validationError = ValidateModel(dto, "Usuario"); // ✅
        if (validationError != null) return validationError;

        try
        {
            var usuario = _adminService.UpdateUsuario(id, dto);
            if (usuario == null)
                return NotFoundResponse<UsuarioDTO>(
                    $"Usuario con ID {id} no encontrado"); // ✅
            
            return OkResponse(usuario, "Usuario actualizado exitosamente"); // ✅
        }
        catch (ValidationException ex)
        {
            return BadRequest<UsuarioDTO>(ex.Message); // ✅
        }
        catch (Exception ex)
        {
            return InternalServerErrorResponse<UsuarioDTO>(
                "Error al actualizar usuario", ex); // ✅
        }
    }
    
    [HttpDelete("usuarios/{id}")]
    public IActionResult DeleteUsuario(int id)
    {
        try
        {
            var success = _adminService.DeleteUsuario(id);
            if (!success)
                return NotFoundResponse<object>(
                    $"Usuario con ID {id} no encontrado"); // ✅
            
            return NoContentResponse(); // ✅ 204
        }
        catch (Exception ex)
        {
            return InternalServerErrorResponse<object>(
                "Error al eliminar usuario", ex); // ✅
        }
    }
}
```

---

## ✅ CHECKLIST DE REFACTORIZACIÓN POR CONTROLLER

### AuthController (2 métodos)
- [ ] Login
- [ ] RefreshToken (NUEVO)

### TicketsController (8+ métodos)
- [ ] GetAll
- [ ] GetById
- [ ] Create
- [ ] Update
- [ ] Delete
- [ ] GetDetail
- [ ] Assign
- [ ] (más métodos si existen)

### AdminController (15+ métodos)
- [ ] GetEmpresas, CreateEmpresa, UpdateEmpresa, DeleteEmpresa
- [ ] GetSucursales, CreateSucursal, UpdateSucursal, DeleteSucursal
- [ ] GetPerfiles, CreatePerfil, UpdatePerfil, DeletePerfil
- [ ] GetSistemas, CreateSistema, UpdateSistema, DeleteSistema
- [ ] (más si existen)

### DepartamentosController (2 métodos)
- [ ] GetAll
- [ ] GetById

### MotivosController (2 métodos)
- [ ] GetAll
- [ ] GetById

### GruposController (3 métodos)
- [ ] GetAll
- [ ] Create
- [ ] Update

### ComentariosController (2 métodos)
- [ ] Create
- [ ] GetByTicketId

### AprobacionesController (3 métodos)
- [ ] GetPendientes
- [ ] Responder
- [ ] GetHistorial

### TransicionesController (3 métodos)
- [ ] ValidarPermitida
- [ ] Ejecutar
- [ ] GetHistorial

### ReferencesController (5 métodos)
- [ ] GetEstados
- [ ] GetMotivos
- [ ] GetPrioridades
- [ ] GetDepartamentos
- [ ] GetSucursales

### StoredProceduresController (?)
- [ ] Verificar qué métodos tiene

---

## 🧪 CÓMO TESTEAR CAMBIOS

### Test 1: Estructura de respuesta

```csharp
[Fact]
public void GetAll_ReturnsValidApiResponse()
{
    // Arrange
    var mockRepository = new Mock<IRepository>();
    mockRepository.Setup(r => r.GetAll()).Returns(new List<Item>());
    var controller = new ItemController(mockRepository.Object);

    // Act
    var result = controller.GetAll() as OkObjectResult;

    // Assert
    Assert.NotNull(result);
    Assert.Equal(200, result.StatusCode);
    var response = result.Value as ApiResponse<List<Item>>;
    Assert.NotNull(response);
    Assert.True(response.Success);
    Assert.NotNull(response.Data);
    Assert.NotNull(response.Timestamp);
    Assert.NotNull(response.TraceId);
}
```

### Test 2: Status codes correctos

```csharp
[Fact]
public void Create_Returns201Created()
{
    // Arrange
    var dto = new CreateItemDTO { Name = "Test" };
    var controller = new ItemController(mockService);

    // Act
    var result = controller.Create(dto) as CreatedAtActionResult;

    // Assert
    Assert.NotNull(result);
    Assert.Equal(201, result.StatusCode);
}

[Fact]
public void Delete_Returns204NoContent()
{
    // Arrange
    var controller = new ItemController(mockService);

    // Act
    var result = controller.Delete(1) as NoContentResult;

    // Assert
    Assert.NotNull(result);
    Assert.Equal(204, result.StatusCode);
}
```

---

## 📝 TEMPLATE DE CLASE NUEVA

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using TicketsAPI.Models;
using TicketsAPI.Services;

namespace TicketsAPI.Controllers
{
    [Authorize]
    public class ItemController : BaseApiController
    {
        private readonly IItemService _itemService;

        public ItemController(IItemService itemService)
        {
            _itemService = itemService;
        }

        /// <summary>
        /// Obtiene todos los items
        /// </summary>
        [HttpGet]
        public IActionResult GetAll()
        {
            try
            {
                var items = _itemService.GetAll();
                return OkResponse(items, "Items obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                return InternalServerErrorResponse<List<ItemDTO>>(
                    "Error al obtener items", ex);
            }
        }

        /// <summary>
        /// Obtiene un item por ID
        /// </summary>
        [HttpGet("{id}")]
        public IActionResult GetById(int id)
        {
            try
            {
                var item = _itemService.GetById(id);
                if (item == null)
                    return NotFoundResponse<ItemDTO>($"Item con ID {id} no encontrado");
                
                return OkResponse(item, "Item obtenido exitosamente");
            }
            catch (Exception ex)
            {
                return InternalServerErrorResponse<ItemDTO>(
                    "Error al obtener item", ex);
            }
        }

        /// <summary>
        /// Crea un nuevo item
        /// </summary>
        [HttpPost]
        public IActionResult Create([FromBody] CreateItemDTO dto)
        {
            var validationError = ValidateModel(dto, "Item");
            if (validationError != null) return validationError;

            try
            {
                var item = _itemService.Create(dto);
                return CreatedResponse("GetById", "Items", 
                    new { id = item.Id }, item, 
                    "Item creado exitosamente");
            }
            catch (Exception ex)
            {
                return InternalServerErrorResponse<ItemDTO>(
                    "Error al crear item", ex);
            }
        }

        /// <summary>
        /// Actualiza un item existente
        /// </summary>
        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] UpdateItemDTO dto)
        {
            var validationError = ValidateModel(dto, "Item");
            if (validationError != null) return validationError;

            try
            {
                var item = _itemService.Update(id, dto);
                if (item == null)
                    return NotFoundResponse<ItemDTO>($"Item con ID {id} no encontrado");
                
                return OkResponse(item, "Item actualizado exitosamente");
            }
            catch (Exception ex)
            {
                return InternalServerErrorResponse<ItemDTO>(
                    "Error al actualizar item", ex);
            }
        }

        /// <summary>
        /// Elimina un item
        /// </summary>
        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            try
            {
                var success = _itemService.Delete(id);
                if (!success)
                    return NotFoundResponse<object>($"Item con ID {id} no encontrado");
                
                return NoContentResponse();
            }
            catch (Exception ex)
            {
                return InternalServerErrorResponse<object>(
                    "Error al eliminar item", ex);
            }
        }
    }
}
```

---

**Generado:** 23 Enero 2026  
**Propósito:** Guía de implementación práctica FASE 1  
**Versión:** 1.0
