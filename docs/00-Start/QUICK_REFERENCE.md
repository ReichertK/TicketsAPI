# QUICK REFERENCE - FASE 1
## Guía rápida mientras implementas

**Imprímelo o ten abierto en otra ventana mientras codificas**

---

## 🎯 RESUMEN RÁPIDO

**¿Qué hago?** Refactorizar 12 controllers para usar `ApiResponse<T>`

**¿Cuánto tiempo?** 10-11 horas

**¿Qué copiar?** Código de FASE_1_ESTANDARIZACION_API.md

**¿Cómo validar?** `python qa_test_suite.py` debe pasar 100%

---

## 📋 CHECKLIST RÁPIDO

### Paso 1: Crear ApiResponse<T>
- [ ] Crear: `Models/ApiResponse.cs`
- [ ] Copiar clase `ApiResponse<T>` desde FASE_1_ESTANDARIZACION_API.md
- [ ] Compilar: `dotnet build` ✓

### Paso 2: Refactorizar BaseApiController
- [ ] Abrir: `Controllers/BaseApiController.cs`
- [ ] Copiar 10 métodos helper desde FASE_1_ESTANDARIZACION_API.md
- [ ] Compilar: `dotnet build` ✓

### Paso 3: Actualizar 12 Controllers
Usar EJEMPLOS_PRACTICOS_FASE_1.md como referencia para cada patrón

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

### Paso 4: Validar
- [ ] Compilar: `dotnet build` (0 errores)
- [ ] Test: `python qa_test_suite.py` (100% PASS)
- [ ] Code review
- [ ] Mergear a main

---

## 🔀 PATRONES RÁPIDOS

### GET (Listar)
```csharp
[HttpGet]
public IActionResult GetAll()
{
    try
    {
        var items = _repository.GetAll();
        return OkResponse(items, "Elementos obtenidos");
    }
    catch (Exception ex)
    {
        return InternalServerErrorResponse<List<ItemDTO>>("Error", ex);
    }
}
```

### GET by ID
```csharp
[HttpGet("{id}")]
public IActionResult GetById(int id)
{
    var item = _repository.GetById(id);
    if (item == null)
        return NotFoundResponse<ItemDTO>($"No encontrado");
    return OkResponse(item);
}
```

### POST (Crear)
```csharp
[HttpPost]
public IActionResult Create([FromBody] CreateItemDTO dto)
{
    var error = ValidateModel(dto, "Item");
    if (error != null) return error;
    
    var item = _repository.Create(dto);
    return CreatedResponse("GetById", "Items", new { id = item.Id }, item);
}
```

### PUT (Actualizar)
```csharp
[HttpPut("{id}")]
public IActionResult Update(int id, [FromBody] UpdateItemDTO dto)
{
    var error = ValidateModel(dto, "Item");
    if (error != null) return error;
    
    var item = _repository.Update(id, dto);
    if (item == null)
        return NotFoundResponse<ItemDTO>("No encontrado");
    return OkResponse(item);
}
```

### DELETE
```csharp
[HttpDelete("{id}")]
public IActionResult Delete(int id)
{
    var success = _repository.Delete(id);
    if (!success)
        return NotFoundResponse<object>("No encontrado");
    return NoContentResponse(); // 204
}
```

---

## 📊 STATUS CODES A USAR

| Código | Cuándo | Método |
|--------|--------|--------|
| **200** | GET exitoso | `OkResponse<T>()` |
| **201** | POST exitoso | `CreatedResponse<T>()` |
| **204** | DELETE exitoso | `NoContentResponse()` |
| **400** | Validación falla | `BadRequest<T>()` |
| **401** | No autenticado | `UnauthorizedResponse<T>()` |
| **403** | No autorizado | `ForbiddenResponse<T>()` |
| **404** | No encontrado | `NotFoundResponse<T>()` |
| **409** | Conflicto | `ConflictResponse<T>()` |
| **500** | Error servidor | `InternalServerErrorResponse<T>()` |

---

## 🆘 PROBLEMAS COMUNES

### "Class doesn't exist: ApiResponse"
**Solución:** Verificar que creaste `Models/ApiResponse.cs`

### "BaseApiController doesn't have OkResponse"
**Solución:** Verificar que copiaste todos los métodos en BaseApiController

### "Method not found: GetCurrentUserId"
**Solución:** Verificar que BaseApiController tiene estos métodos helper

### Test falla con 500
**Solución:** Verificar que ApiResponse<T> tiene estructura correcta

### Compilación falla
**Solución:** `dotnet clean` luego `dotnet build`

---

## 📖 ¿DÓNDE ENCONTRAR?

**Estructura de ApiResponse<T>**
→ FASE_1_ESTANDARIZACION_API.md, Paso 1

**Código de BaseApiController**
→ FASE_1_ESTANDARIZACION_API.md, Paso 2

**Patrones de cada endpoint**
→ EJEMPLOS_PRACTICOS_FASE_1.md, sección "Patrones a usar"

**Qué es cada método**
→ FASE_1_ESTANDARIZACION_API.md, sección "Refactorizar BaseApiController"

---

## ⚡ VELOCIDAD DE ENTRADA

### Si tienes 30 min
- [ ] Lee FASE_0_CONSOLIDADO.md
- [ ] Entiende los 3 problemas críticos

### Si tienes 1 hora
- [ ] Lee FASE_0_CONSOLIDADO.md
- [ ] Lee FASE_1_ESTANDARIZACION_API.md
- [ ] Abre EJEMPLOS_PRACTICOS_FASE_1.md

### Si tienes 2 horas
- [ ] Lee FASE_0_CONSOLIDADO.md
- [ ] Lee FASE_0_MAPEO_SPs_ENDPOINTS.md
- [ ] Lee FASE_1_ESTANDARIZACION_API.md
- [ ] Crea ApiResponse.cs

### Si tienes 4 horas
- [ ] Lee todo arriba
- [ ] Comienza refactorización de AuthController
- [ ] Verifica que compila
- [ ] Prueba con un endpoint

---

## 🎯 PROGRESO POR HORA

**Hora 1-2:** Crear ApiResponse<T> + BaseApiController  
**Hora 2-4:** Refactorizar AuthController + TicketsController  
**Hora 4-6:** Refactorizar AdminController (es el más grande)  
**Hora 6-8:** Refactorizar controllers de referencias (Departamentos, Motivos, etc.)  
**Hora 8-10:** Refactorizar controllers restantes  
**Hora 10-11:** Testing + validación + fixes finales  

---

## ✅ ANTES DE CADA COMPILACIÓN

1. Guardar archivo: `Ctrl+S`
2. Compilar: `dotnet build`
3. Si error: Ver error específico, arreglar, repetir

---

## ✅ ANTES DE MERGEAR

1. [ ] `dotnet build` sin errores
2. [ ] `python qa_test_suite.py` PASS 100%
3. [ ] Code review aprobado
4. [ ] Commits con mensaje claro
5. [ ] Push + crear PR

---

## 📌 NO OLVIDES

- ✅ Heredar `BaseApiController` en cada controller
- ✅ Usar `OkResponse<T>()` en GET exitosos
- ✅ Usar `CreatedResponse<T>()` en POST exitosos
- ✅ Usar `NoContentResponse()` en DELETE exitosos
- ✅ Usar `NotFoundResponse<T>()` cuando no existe
- ✅ Usar `BadRequest<T>()` en validación falla
- ✅ Usar `InternalServerErrorResponse<T>()` en exceptions

---

## 🚀 ¿LISTO?

1. Abre FASE_1_ESTANDARIZACION_API.md
2. Comienza Paso 1 (Crear ApiResponse.cs)
3. Copia código
4. Compila
5. Continúa con Paso 2

---

**Imprime esto o ten abierto mientras codificas**  
**Referencia rápida = menos errores**

Good luck! 🚀
