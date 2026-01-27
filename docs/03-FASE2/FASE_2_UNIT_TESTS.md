# FASE 2: Unit Tests con xUnit

**Fecha inicio:** 27 enero 2026  
**Estado:** ⏳ EN PROGRESO  
**Estimación:** 10-12 horas  
**Objetivo:** Cobertura de tests mínima 70%

---

## ✅ Progreso Actual

### Infraestructura Completada

- ✅ Proyecto xUnit creado (TicketsAPI.Tests)
- ✅ Paquetes instalados:
  - xUnit 2.6.2
  - Moq 4.20.70
  - FluentAssertions 6.12.0
  - Microsoft.AspNetCore.Mvc.Testing 6.0.21
  - coverlet.collector 6.0.2
- ✅ Referencia al proyecto principal agregada
- ✅ Estructura de carpetas: Controllers/, Services/, Helpers/
- ✅ Helper class `ControllerTestHelper` (autenticación, logging)

### Controllers con Tests

| Controller | Tests Creados | Estado |
|------------|---------------|--------|
| **DepartamentosController** | 11 tests | ⚠️  Ajustes necesarios |
| **ComentariosController** | 12 tests | ⚠️  Ajustes necesarios |
| GruposController | 0 | ⏳ Pendiente |
| MotivosController | 0 | ⏳ Pendiente |
| AprobacionesController | 0 | ⏳ Pendiente |
| TransicionesController | 0 | ⏳ Pendiente |
| AuthController | 0 | ⏳ Pendiente |

### Tests Ejecutados

```
Total: 26 tests
✅ Correctos: 16 (61.5%)
❌ Fallidos: 10 (38.5%)
```

### Issues Identificados

**Problema Principal:** Tests esperan `OkObjectResult` pero `BaseApiController.Success()` devuelve `ObjectResult` con `StatusCode`.

**Solución:** Ajustar assertions para verificar:
- `ObjectResult` en lugar de `OkObjectResult`
- `StatusCode` property directamente
- Estructura de `ApiResponse<T>` en `Value`

---

## 🎯 Estrategia de Testing

### Patrones de Test

#### 1. Test GET (Lista)
```csharp
[Fact]
public async Task ObtenerRecursos_ConDatos_RetornaSuccess200()
{
    // Arrange
    var recursos = new List<Recurso> { /* datos */ };
    _mockRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(recursos);

    // Act
    var result = await _controller.ObtenerRecursos();

    // Assert
    result.Should().BeOfType<ObjectResult>();
    var objectResult = result as ObjectResult;
    objectResult!.StatusCode.Should().Be(200);
    
    var response = objectResult.Value as ApiResponse<List<RecursoDTO>>;
    response!.Exitoso.Should().BeTrue();
    response.Datos.Should().HaveCount(2);
}
```

#### 2. Test POST (Crear)
```csharp
[Fact]
public async Task CrearRecurso_DatosValidos_RetornaCreated201()
{
    // Arrange
    var dto = new CreateRecursoDTO { Nombre = "Test" };
    _mockRepository.Setup(r => r.CreateAsync(It.IsAny<Recurso>())).ReturnsAsync(1);

    // Act
    var result = await _controller.CrearRecurso(dto);

    // Assert
    result.Should().BeOfType<ObjectResult>();
    var objectResult = result as ObjectResult;
    objectResult!.StatusCode.Should().Be(201);
    
    _mockRepository.Verify(r => r.CreateAsync(It.IsAny<Recurso>()), Times.Once);
}
```

#### 3. Test Error (404)
```csharp
[Fact]
public async Task ObtenerRecursoPorId_NoExiste_RetornaError404()
{
    // Arrange
    _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Recurso?)null);

    // Act
    var result = await _controller.ObtenerRecursoPorId(999);

    // Assert
    result.Should().BeOfType<ObjectResult>();
    var objectResult = result as ObjectResult;
    objectResult!.StatusCode.Should().Be(404);
    
    var response = objectResult.Value as ApiResponse<object>;
    response!.Exitoso.Should().BeFalse();
}
```

#### 4. Test Autenticación (401)
```csharp
[Fact]
public async Task CrearRecurso_UsuarioNoAutenticado_RetornaError401()
{
    // Arrange
    ControllerTestHelper.SetupUnauthenticatedUser(_controller);
    var dto = new CreateRecursoDTO();

    // Act
    var result = await _controller.CrearRecurso(dto);

    // Assert
    result.Should().BeOfType<ObjectResult>();
    var objectResult = result as ObjectResult;
    objectResult!.StatusCode.Should().Be(401);
}
```

#### 5. Test Permisos (403)
```csharp
[Fact]
public async Task ActualizarRecurso_NoEsPropietario_RetornaError403()
{
    // Arrange
    var recurso = new Recurso { Id = 1, Id_Usuario = 5 };
    _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(recurso);
    ControllerTestHelper.SetupAuthenticatedUser(_controller, 99); // Usuario diferente

    var dto = new UpdateRecursoDTO();

    // Act
    var result = await _controller.ActualizarRecurso(1, dto);

    // Assert
    result.Should().BeOfType<ObjectResult>();
    var objectResult = result as ObjectResult;
    objectResult!.StatusCode.Should().Be(403);
}
```

---

## 📋 Checklist por Controller

### DepartamentosController ✅
- [x] ObtenerDepartamentos (success, empty, exception)
- [x] ObtenerDepartamentoPorId (success, not found, exception)
- [x] CrearDepartamento (success, invalid model, exception)
- [x] ActualizarDepartamento (success, not found, invalid model)
- [x] EliminarDepartamento (success, not found)

### ComentariosController ✅
- [x] GetComentariosPorTicket (success, ticket not found, exception)
- [x] CrearComentario (success, unauthorized, invalid model, ticket not found)
- [x] ActualizarComentario (success, not owner, not found, invalid model)
- [x] EliminarComentario (success, not owner, not found)

### Pendientes
- [ ] GruposController (11 tests)
- [ ] MotivosController (11 tests)
- [ ] AprobacionesController (15 tests)
- [ ] TransicionesController (12 tests)
- [ ] AuthController (8 tests - login, register, refresh token)
- [ ] AdminController (3 tests)

---

## 🎯 Próximos Pasos

1. **Ajustar tests existentes** (DepartamentosController, ComentariosController)
   - Cambiar `BeOfType<OkObjectResult>()` → `BeOfType<ObjectResult>()`
   - Verificar `StatusCode` property
   - Ejecutar `dotnet test` hasta tener 0 fallos

2. **Crear tests para GruposController** (similar a Departamentos)
3. **Crear tests para MotivosController** (similar a Departamentos)
4. **Crear tests para AprobacionesController** (con autenticación)
5. **Crear tests para TransicionesController** (con autenticación)
6. **Crear tests para AuthController** (sin autenticación)

---

## 📊 Cobertura Objetivo

| Componente | Cobertura Objetivo | Estado |
|------------|-------------------|--------|
| Controllers | 80% | 10% actual |
| Services | 70% | 0% |
| Repositories | 60% | 0% |
| **Total** | **70%** | **~3%** |

---

## 🔧 Comandos Útiles

```powershell
# Compilar proyecto de tests
dotnet build TicketsAPI.Tests

# Ejecutar todos los tests
dotnet test TicketsAPI.Tests

# Ejecutar tests con cobertura
dotnet test TicketsAPI.Tests /p:CollectCoverage=true /p:CoverletOutputFormat=opencover

# Ejecutar tests específicos
dotnet test --filter "FullyQualifiedName~DepartamentosController"

# Ejecutar con verbosidad
dotnet test --verbosity detailed
```

---

**Última actualización:** 27 enero 2026 21:30
