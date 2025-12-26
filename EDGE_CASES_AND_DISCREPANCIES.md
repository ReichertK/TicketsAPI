# Discrepancias y Casos Borde Identificados

**Generado:** 23 de Diciembre de 2025 (Análisis Autónomo)  
**Objetivo:** Documentar diferencias esperadas vs. comportamiento actual  
**Importancia:** CRÍTICA para validación pre-producción  

---

## 🔴 CRÍTICAS (Bloqueadores)

### 1. FK Inválida Retorna 500 en lugar de 400

**Problema:**
```
POST /api/v1/Tickets
{
  "contenido": "Test",
  "id_prioridad": 999,  // NO EXISTE
  "id_departamento": 1
}

Actual:   HTTP 500 + "Foreign key constraint fails"
Esperado: HTTP 400 + "Prioridad 999 no existe"
```

**Causa:** Service no valida FK antes de llamar SP  
**Impacto:** 
- UX confusa para cliente API
- Registros 500 innecesarios en logs
- No sigue especificación REST (400 = client error, 500 = server error)

**Solución:**
```csharp
// Agregar en TicketService.CreateAsync()
if (!await _prioridadRepository.ExistsAsync(dto.Id_Prioridad))
    throw new ValidationException("Prioridad no existe");

// Capturar en Controller
catch (ValidationException ex)
    return BadRequest(new ApiResponse<object>(null, ex.Message));
```

**Severidad:** 🔴 HIGH - Afecta todos POST /Tickets con FK inválida

---

### 2. HTTP 500 Para Todas las Excepciones (No Discrimina)

**Problema:**
```csharp
// Código actual simplificado
catch (Exception ex)
{
    return StatusCode(500, new ApiResponse<object>(null, "Error al crear ticket"));
}

// Resultados:
- Exception genérica → 500
- ValidationException → 500 (debería 400)
- PermissionException → 500 (debería 403)
- NotFoundException → 500 (debería 404)
```

**Impacto:** Cliente no puede distinguir errores

**Solución:**
```csharp
catch (ValidationException ex)
    return BadRequest(new ApiResponse(null, ex.Message));

catch (PermissionException ex)
    return Forbid(new ApiResponse(null, ex.Message));

catch (NotFoundException ex)
    return NotFound(new ApiResponse(null, ex.Message));

catch (Exception ex)
{
    _logger.LogError(ex, "Unhandled exception");
    return StatusCode(500, new ApiResponse(null, "Error interno del servidor"));
}
```

**Severidad:** 🔴 HIGH - Degrada experiencia cliente

---

### 3. Usuario Puede Pasar Id_Usuario en Request (Security Risk)

**Problema:**
```csharp
// Usuario 3 (TECNICO) envía:
GET /api/v1/Tickets?Id_Usuario=1

// API actualmente:
Sobrescribe correctamente: filtro.Id_Usuario = userId (del JWT)

// Pero riesgo: Si algo falla, cliente puede ver datos ajenos
```

**Riesgo:**
- Impersonation attack si lógica de sobrescritura se elimina accidentalmente
- No hay documentación explícita que es ignorado

**Validación Actual:** ✅ CORRECTA  
```csharp
// TicketsController.GetTickets()
var userId = GetCurrentUserId();
filtro.Id_Usuario = userId;  // ← Fuerza userId del JWT
```

**Recomendación:**
- Mantener como está (correcto)
- Considerar NOT aceptar Id_Usuario en parámetros de DTO
- O validar explícitamente: `if (filtro.Id_Usuario != userId) return Forbid(...)`

**Severidad:** 🟠 MEDIUM (Ya mitigado, pero documentar)

---

## 🟠 IMPORTANTES (Impactan Comportamiento)

### 4. SP `sp_listar_tkts` - Lógica de Filtrado Interna Desconocida

**Problema:**
```sql
-- Llamada desde API:
CALL sp_listar_tkts(
    w_Id_Usuario = 3,           -- Usuario solicitante
    w_Id_Departamento = 10,     -- Filtro del cliente
    w_Id_Estado = 1,             -- Filtro del cliente
    ... otros filtros ...
)

-- ¿Qué valida SP internamente?
-- - ¿Verifica que usuario 3 tiene acceso a depto 10?
-- - ¿Retorna error 403 en SP si permisos insuficientes?
-- - ¿Filtra silenciosamente (retorna lista vacía)?

RESPUESTA ACTUAL: Desconocida (no documentada en código)
```

**Impacto:** No se sabe si seguridad está en SP o API

**Investigación Necesaria:**
```sql
-- Conectarse a BD y analizar:
SELECT ROUTINE_DEFINITION FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_NAME = 'sp_listar_tkts';

-- Ver si contiene:
-- 1. Validaciones de FK
-- 2. Lógica de permisos por rol
-- 3. Soft delete check (Habilitado = 1)
-- 4. Cálculo de totalRecords
```

**Recomendación:** Documentar SP en SPECDOC.md incluidas validaciones internas

**Severidad:** 🟠 MEDIUM (Funciona pero riesgoso no saber lógica)

---

### 5. Roles de Usuario: ¿Dónde se Define Permisos?

**Problema:**
```csharp
// En API obtenemos del JWT:
var role = User.FindFirst(ClaimTypes.Role)?.Value;

// Pero ¿qué roles existen?
// - ADMIN, ADMIN_RO, TECNICO, USUARIO, SUPERVISOR?
// - ¿Dónde está mapeado 0 → "ADMIN"?
// - ¿Qué permiso tiene cada rol?

Respuesta: Desconocido (probablemente en tabla usuario_rol o usuario.Rol)
```

**Impacto:** Imposible implementar validación de roles en API

**Investigación Necesaria:**
```sql
-- Revisar BD
SELECT DISTINCT Rol FROM usuario;
SELECT * FROM usuario_rol;
SELECT * FROM rol_permiso;

-- En cdk_tkt.sql (linea ~):
-- Buscar definiciones de roles
```

**Recomendación:** Crear documento ROLES_PERMISSIONS.md con matriz

**Severidad:** 🟠 MEDIUM (Necesario antes de implementar permisos)

---

### 6. Soft Delete: ¿Se Valida Habilitado en Todos Lados?

**Problema:**
```sql
-- Crear ticket con departamento inactivo (Habilitado=0)

-- En tkt tabla:
ALTER TABLE tkt ADD COLUMN Habilitado TINYINT DEFAULT 1;

-- ¿SP sp_listar_tkts filtra Habilitado=1?
-- ¿SP sp_agregar_tkt valida depto.Habilitado=1?
-- ¿Usuario ve tickets eliminados (Habilitado=0)?

Actual: Desconocido (asumir SP lo maneja)
```

**Impacto:** Datos fantasma si no se valida

**Validación Necesaria:**
```csharp
// Confirmar en TicketRepository que SP retorna solo Habilitado=1
// O agregar validación en filtro
var tickets = await conn.QueryAsync<TicketDTO>(
    "sp_listar_tkts",
    parameters,
    CommandType.StoredProcedure
);

// POST validar:
if (!departamento.Habilitado)
    throw new ValidationException("Departamento inactivo");
```

**Severidad:** 🟠 MEDIUM (Probablemente manejado en SP)

---

### 7. Transiciones de Estado: ¿Cuáles son Válidas?

**Problema:**
```
Tabla tkt_transicion_regla tiene reglas, pero ¿cuáles son exactamente?

Supuesto:
  Abierto (1) → En Proceso (2) ✅
  Abierto (1) → Cerrado (3) ❌
  Cerrado (3) → Abierto (1) ❌
  Reabierto (7) → En Proceso (2) ✅

¿Se valida en SP o API debería hacerlo?
```

**Impacto:** Usuario podría cambiar estado a transición inválida

**Solución:** SP `sp_tkt_transicionar` valida, pero API debería también capturar error

**Severity:** 🟠 MEDIUM (Probablemente OK en SP)

---

## 🟡 CONSIDERABLES (Mejoras Opcionales)

### 8. Paginación: ¿Qué Sucede en Límites?

**Test Scenarios:**
```
GET /api/v1/Tickets?Pagina=0&TamañoPagina=10
  Actual: Ajusta a página=1 ✅
  
GET /api/v1/Tickets?Pagina=-5&TamañoPagina=10
  Actual: Ajusta a página=1 ✅
  
GET /api/v1/Tickets?TamañoPagina=0
  Actual: Ajusta a tamaño=1 ✅
  
GET /api/v1/Tickets?TamañoPagina=-999
  Actual: Ajusta a tamaño=1 ✅
  
GET /api/v1/Tickets?TamañoPagina=10000
  Actual: Ajusta a tamaño=100 ✅
  
GET /api/v1/Tickets?Pagina=999 (no existe)
  Actual: 200 OK, datos vacío ✅
  Esperado: 200 OK, datos vacío ✅
```

**Status:** ✅ Todos los casos manejados correctamente

**Validación:**
```csharp
// En TicketRepository.GetFilteredAsync()
var page = Math.Max(1, filtro.Pagina);
var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);

// CORRECTO - no hay cambios necesarios
```

**Severidad:** 🟢 LOW (Ya implementado correctamente)

---

### 9. SQL Injection en Búsqueda

**Escenario:**
```
GET /api/v1/Tickets?Busqueda='; DROP TABLE tkt; --

Payload en SP:
  LIKE CONCAT('%', '%'; DROP TABLE tkt; --%', '%')
  
Resultado: Las comillas se escapan, no hay inyección
```

**Status:** ✅ SEGURO

**Protección:** Parametrización via Dapper
```csharp
var parameters = new { w_Busqueda = $"%{filtro.Busqueda}%" };
// Dapper escapa automáticamente
```

**Recomendación:** Agregar [StringLength(1000)] en DTO para defensa en profundidad

**Severidad:** 🟢 LOW (Ya protegido, mejorar defensas)

---

### 10. Performance: ¿Índices en Tablas Clave?

**Pregunta:**
```sql
-- ¿Existen índices en:
- tkt (Id_Usuario) para filtrar rápido
- tkt (Id_Usuario_Asignado)
- tkt (Id_Departamento)
- tkt (Id_Estado)
- tkt (Habilitado, Fecha_Creacion DESC)
- usuario (Id_Usuario) [PK, asumido]
- usuario (Habilitado)

-- Sin índices, sp_listar_tkts hace tabla scan en 6 registros
-- En producción con 1M registros, sería lento
```

**Impacto:** Performance en producción

**Recomendación:** Revisar índices en BD después de las primeras pruebas

**Severidad:** 🟡 MEDIUM (Importante en producción, no bloquea dev)

---

## 🟢 VALIDACIONES OK

### 11. JWT Expiración
```
✅ JWT rechazado si expirado
✅ Sin JWT retorna 401
✅ JWT inválida rechazada
```

### 12. Paginación
```
✅ Límites correctos
✅ Cálculo de totalPáginas correcto
✅ Banderas tienePaginaAnterior/Siguiente correctas
```

### 13. User ID Injection
```
✅ User ID SIEMPRE del JWT, nunca del request
✅ Imposible impersonación vía parámetros
```

### 14. Estructura de Respuesta
```
✅ ApiResponse<T> consistente
✅ Campos requeridos presentes
✅ Serialización JSON correcta
```

---

## 📋 Matriz de Impacto vs. Esfuerzo

```
┌─────────────────────────────────┬──────────┬──────────┬────────┐
│ Issue                           │ Impacto  │ Esfuerzo │ Hacer? │
├─────────────────────────────────┼──────────┼──────────┼────────┤
│ 1. FK retorna 500 en lugar 400  │ 🔴 HIGH  │ 2 horas  │ SÍ     │
│ 2. HTTP 500 para todo error     │ 🔴 HIGH  │ 1 hora   │ SÍ     │
│ 3. User impersonation risk      │ 🟡 LOW   │ 0 horas  │ NO     │
│ 4. SP lógica desconocida        │ 🟠 MED   │ 2 horas  │ SÍ     │
│ 5. Roles/Permisos desconocidos  │ 🟠 MED   │ 1 hora   │ SÍ     │
│ 6. Soft delete no validado      │ 🟠 MED   │ 1 hora   │ SÍ     │
│ 7. Transiciones desconocidas    │ 🟠 MED   │ 1 hora   │ SÍ     │
│ 8. Paginación límites           │ 🟢 LOW   │ 0 horas  │ NO     │
│ 9. SQL injection                │ 🟢 LOW   │ 0.5 h    │ NO     │
│ 10. Performance índices         │ 🟡 LOW   │ 2 horas  │ DESPUÉS│
│ 11-14. Validaciones OK          │ 🟢 LOW   │ 0 horas  │ NO     │
└─────────────────────────────────┴──────────┴──────────┴────────┘
```

---

## ✅ CHECKLIST PRE-PRODUCCIÓN

### Antes de Deploy
- [ ] Ejecutar Test Suite 1 (ADMIN) - debe pasar 100%
- [ ] Ejecutar Test Suite 2 (TECNICO) - documentar diferencias
- [ ] Ejecutar Test Suite 3 (USUARIO) - documentar diferencias
- [ ] Ejecutar Test Suite 4 (Errores) - validar códigos HTTP
- [ ] Implementar validación FK (Issue #1)
- [ ] Implementar discriminación de excepciones (Issue #2)
- [ ] Documentar SP `sp_listar_tkts` (Issue #4)
- [ ] Documentar matriz de roles/permisos (Issue #5)
- [ ] Validar soft delete (Issue #6)
- [ ] Documentar transiciones de estado (Issue #7)

### En Producción (Próximo Sprint)
- [ ] Revisar índices de BD (Issue #10)
- [ ] Implementar búsqueda avanzada si necesario
- [ ] Agregar logging de auditoría
- [ ] Implementar rate limiting
- [ ] Implementar caching de búsquedas frecuentes

---

## 📝 Documentación Pendiente

### Crear
1. **SPECDOC.md** - Especificación de SPs usadas
   - sp_listar_tkts (parámetros, validaciones, errores)
   - sp_agregar_tkt (parámetros, validaciones, errores)
   - sp_tkt_transicionar (parámetros, validaciones, errores)
   - sp_tkt_historial (parámetros)

2. **ROLES_PERMISSIONS.md** - Matriz de roles
   - Roles existentes en sistema
   - Permisos por operación
   - Flujos de transición permitidos

3. **ERROR_CODES.md** - Códigos de error esperados
   - 200 OK
   - 400 Bad Request (validación)
   - 401 Unauthorized (JWT)
   - 403 Forbidden (permisos)
   - 404 Not Found
   - 500 Internal Server Error (imprevistos)

4. **DATA_DICTIONARY.md** - Diccionario de datos
   - Campos de Ticket DTO
   - Valores válidos por campo
   - Restricciones de longitud

---

## 🎯 Recomendaciones Finales

### Corto Plazo (Esta Semana)
1. Implementar validación FK → HTTP 400
2. Discriminar excepciones por tipo
3. Ejecutar Test Suite 1 (ADMIN)
4. Documentar SP

### Mediano Plazo (Este Mes)
1. Ejecutar Test Suite 2-3 (TECNICO/USUARIO)
2. Implementar validación de roles
3. Revisar índices de producción
4. Crear documentación completa

### Largo Plazo (Próximo Sprint)
1. Implementar búsqueda avanzada
2. Agregar caching
3. Implementar auditoría
4. Performance testing

---

## 📞 Contacto para Preguntas

- **Sobre Validaciones:** Ver VALIDATION_SUGGESTIONS.md
- **Sobre Permisos:** Ver PERMISSIONS_MATRIX.md
- **Sobre Tests:** Ver TEST_PLAN_BY_ROLE.md
- **Sobre Análisis:** Ver TICKETS_API_ANALYSIS.md
- **Sobre BD:** Ver cdk_tkt.sql

---

**Documento Generado Por:** Análisis Autónomo del Agente  
**Fecha:** 23 de Diciembre de 2025  
**Versión:** 1.0  
**Estado:** Completo - Listo para Desarrollador
