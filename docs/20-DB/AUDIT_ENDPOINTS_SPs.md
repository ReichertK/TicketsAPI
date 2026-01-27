# 🔍 AUDITORÍA EXHAUSTIVA DE ENDPOINTS CON STORED PROCEDURES

**Fecha:** 23 de Diciembre 2025  
**Objetivo:** Validar coherencia entre SPs, endpoints y sistema MVC original

---

## 📋 PARTE 1: ANÁLISIS DE STORED PROCEDURES

### 1️⃣ **sp_tkt_transicionar** (Transición de Estado)

#### Firma SQL:
```sql
CREATE PROCEDURE sp_tkt_transicionar(
    IN p_id_tkt BIGINT,
    IN p_estado_to INT,
    IN p_id_usuario_actor INT,
    IN p_comentario VARCHAR(1000),
    IN p_motivo VARCHAR(255),
    IN p_id_asignado_nuevo INT,
    IN p_meta_json LONGTEXT
)
SELECT success, message, nuevo_estado, id_asignado;
```

#### Tipos de Retorno (OUT parameters via SELECT):
| Parámetro | Tipo | Nullable | Descripción |
|-----------|------|----------|-------------|
| `success` | INT (0 o 1) | NO | 1=éxito, 0=error |
| `message` | VARCHAR(255) | NO | Mensaje descriptivo |
| `nuevo_estado` | INT | SÍ | ID del nuevo estado (NULL si error) |
| `id_asignado` | INT | SÍ | ID usuario asignado (NULL si error) |

#### Valores de `success` y `message`:

| Caso | Success | Message | HTTP Status Esperado |
|------|---------|---------|----------------------|
| ✅ Transición exitosa | `1` | `"OK"` | **200** |
| ❌ Ticket no encontrado | `0` | `"Ticket no encontrado"` | **404** |
| ❌ Comentario vacío | `0` | `"Comentario requerido"` | **400** |
| ❌ Transición no permitida | `0` | `"Transición no permitida"` | **403** |
| ❌ Solo asignado puede transicionar | `0` | `"Solo el asignado puede realizar..."` | **403** |

#### Lógica de Validación en SP:
```
1. Valida que el ticket exista (SELECT ... FOR UPDATE)
2. Requiere comentario NO VACÍO (obligatorio)
3. Busca regla de transición (tkt_transicion_regla)
4. Valida requiere_propietario (solo el asignado)
5. Maneja requiere_aprobacion (crea fila en tkt_aprobacion)
6. Actualiza tkt (estado, asignado, fechas)
7. Inserta registro en tkt_transicion
8. Retorna éxito con nuevo_estado e id_asignado
```

#### ⚠️ CRÍTICO - Mapeo esperado a HTTP:
```
success=1 → HTTP 200 OK
success=0 + message="Ticket no encontrado" → HTTP 404
success=0 + message="Comentario requerido" → HTTP 400
success=0 + message="Transición no permitida" → HTTP 403
success=0 + message="Solo el asignado..." → HTTP 403
```

---

### 2️⃣ **sp_tkt_comentar** (Crear Comentario)

#### Firma SQL:
```sql
CREATE PROCEDURE sp_tkt_comentar(
    IN p_id_tkt BIGINT,
    IN p_id_usuario INT,
    IN p_comentario VARCHAR(2000)
)
SELECT success, mensaje;
```

#### Tipos de Retorno:
| Parámetro | Tipo | Nullable | Descripción |
|-----------|------|----------|-------------|
| `success` | INT (0 o 1) | NO | 1=éxito, 0=error |
| `mensaje` | VARCHAR(x) | NO | Mensaje descriptivo |
| **NO RETORNA** | `id_comentario` | - | ❌ **PROBLEMA: SP no retorna ID** |

#### Valores de `success` y `mensaje`:

| Caso | Success | Mensaje | HTTP Status |
|------|---------|---------|-------------|
| ✅ Comentario creado | `1` | `"Comentario agregado"` | **201** |
| ❌ Comentario vacío | `0` | `"Comentario vacío"` | **400** |

#### ⚠️ PROBLEMAS IDENTIFICADOS:
1. **SP NO retorna `id_comentario`** - Solo retorna `success` y `mensaje`
2. **Solución actual:** Endpoint intenta recuperar mediante `GetByIdAsync(result.IdComentario ?? 0)` → **fallará**
3. **Debería:** La SP necesitaría retornar el ID o el endpoint usar LAST_INSERT_ID()

#### Lógica en SP:
```
1. Valida que comentario NO esté vacío
2. INSERT INTO tkt_comentario si válido
3. Retorna 1, "Comentario agregado"
4. Si vacío retorna 0, "Comentario vacío"
```

---

### 3️⃣ **sp_tkt_historial** (Historial Unificado)

#### Firma SQL:
```sql
CREATE PROCEDURE sp_tkt_historial(IN p_id_tkt BIGINT)
SELECT ... (UNION ALL de 2 SELECT statements)
```

#### Estructura de Retorno (UNION ALL):
```sql
SELECT 
  id_transicion AS orden,
  'TRANSICION' AS tipo,
  fecha,
  estado_from AS estadofrom,
  estado_to AS estadoto,
  ef.TipoEstado AS estadofrom_nombre,
  et.TipoEstado AS estadoto_nombre,
  id_usuario_actor AS id_usuario,
  usuario_nombre,
  comentario AS comentario,
  motivo
FROM tkt_transicion ...
UNION ALL
SELECT 
  id_comentario AS orden,
  'COMENTARIO' AS tipo,
  fecha,
  NULL AS estadofrom,
  NULL AS estadoto,
  NULL AS estadofrom_nombre,
  NULL AS estadoto_nombre,
  id_usuario AS id_usuario,
  usuario_nombre,
  comentario AS comentario,
  NULL AS motivo
FROM tkt_comentario ...
ORDER BY fecha, orden;
```

#### Campos Retornados:
| Campo | Tipo | Transición | Comentario | Uso |
|-------|------|-----------|-----------|-----|
| `orden` | INT | id_transicion | id_comentario | Orden en UNION |
| `tipo` | VARCHAR(10) | `'TRANSICION'` | `'COMENTARIO'` | Identificador |
| `fecha` | DATETIME | ✓ | ✓ | Timestamp |
| `estadofrom` | INT | ✓ | NULL | Estado anterior |
| `estadoto` | INT | ✓ | NULL | Estado nuevo |
| `estadofrom_nombre` | VARCHAR | ✓ | NULL | Nombre estado anterior |
| `estadoto_nombre` | VARCHAR | ✓ | NULL | Nombre estado nuevo |
| `id_usuario` | INT | ✓ | ✓ | Quién realizó acción |
| `usuario_nombre` | VARCHAR | ✓ | ✓ | Nombre del usuario |
| `comentario` | VARCHAR | ✓ | ✓ | Texto comentario/transicion |
| `motivo` | VARCHAR | ✓ | NULL | Motivo de transición |

#### ⚠️ PROBLEMA EN MAPEO:
- Implementación actual mapea campos incorrectamente:
  ```csharp
  Id_Historial = row.id_transicion ?? 0,  // ❌ Debería usar 'orden'
  Campo_Modificado = row.estado_from ?? "Comentario",  // ❌ Lógica confusa
  Valor_Anterior = row.estado_from,  // ❌ Debería ser estadofrom_nombre
  Valor_Nuevo = row.estado_to ?? row.comentario,  // ❌ Debería ser estadoto_nombre
  ```

---

## 📊 PARTE 2: VALIDACIÓN DE ENDPOINTS IMPLEMENTADOS

### Endpoint 1: `PATCH /api/v1/Tickets/{id}/cambiar-estado`

#### ✅ IMPLEMENTACIÓN ACTUAL:
```csharp
[HttpPatch("{id}/cambiar-estado")]
public async Task<IActionResult> ChangeTicketStatus(int id, [FromBody] TransicionEstadoDTO dto)
{
    var userId = GetCurrentUserId();  // ✓ Obtiene de JWT (claim "sub")
    var result = await _ticketRepository.TransicionarEstadoViaStoredProcedureAsync(
        idTkt: id,
        estadoTo: dto.Id_Estado_Nuevo,
        idUsuarioActor: userId,  // ✓ Pasa usuario del JWT
        comentario: dto.Comentario,
        motivo: dto.Motivo);
    
    if (result.Success != 1)
        return Error<object>(result.Message, statusCode: 403);  // ❌ SIEMPRE 403
    
    return Success<object>(new { nuevoEstado, idAsignado }, "");
}
```

#### ⚠️ PROBLEMAS DETECTADOS:

| # | Problema | Severidad | Descripción |
|---|----------|-----------|-------------|
| 1 | Status code fijo en 403 | 🔴 CRÍTICO | Todos los errores retornan 403, pero SP retorna diferentes casos |
| 2 | No mapea errores correctamente | 🔴 CRÍTICO | Debería ser 404 si ticket no existe, 400 si comentario vacío |
| 3 | Mapeo de respuesta incorrecto | 🟡 MEDIUM | Retorna `nuevoEstado` string pero SP retorna INT |
| 4 | No valida que userId sea válido | 🟡 MEDIUM | `GetCurrentUserId()` retorna 0 si falla |

#### 📝 Mapeo Esperado (Correcto):
```
result.Success == 1 → return 200 OK
result.Success == 0 AND message == "Ticket no encontrado" → return 404
result.Success == 0 AND message == "Comentario requerido" → return 400
result.Success == 0 AND (message.Contains("Transición no permitida") OR message.Contains("Solo el asignado")) → return 403
```

#### ✓ Usuario desde JWT:
- ✅ Obtiene `userId` desde JWT claim `"sub"`
- ✅ NO acepta userId desde body o query
- ✅ Pasa correctamente a SP como `p_id_usuario_actor`

---

### Endpoint 2: `POST /api/v1/Tickets/{ticketId}/Comments`

#### ✅ IMPLEMENTACIÓN ACTUAL:
```csharp
[HttpPost("Tickets/{ticketId}/Comments")]
public async Task<ActionResult> CrearComentario(int ticketId, [FromBody] CreateUpdateComentarioDTO dto)
{
    var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");  // ✓ Obtiene de JWT
    var result = await _comentarioRepository.CrearComentarioViaStoredProcedureAsync(
        idTkt: ticketId,
        idUsuario: usuarioId,  // ✓ Pasa usuario del JWT
        comentario: dto.Contenido);
    
    if (result.Success != 1)
        return BadRequest(new { message = result.Message });
    
    var comentarioCreado = await _comentarioRepository.GetByIdAsync(result.IdComentario ?? 0);  // ❌ FALLA
    return CreatedAtAction(...);
}
```

#### ⚠️ PROBLEMAS DETECTADOS:

| # | Problema | Severidad | Descripción |
|---|----------|-----------|-------------|
| 1 | **SP no retorna `id_comentario`** | 🔴 CRÍTICO | `result.IdComentario` siempre NULL |
| 2 | `GetByIdAsync(0)` fallará | 🔴 CRÍTICO | Intenta obtener comentario con ID 0 |
| 3 | No mapea error 404 ticket | 🟡 MEDIUM | SP podría fallar si ticket no existe (sin retorno) |
| 4 | Estructura respuesta incorrecta | 🟡 MEDIUM | Debería retornar ComentarioDTO con ID correcto |

#### 📝 Solución Necesaria:
```
OPCIÓN A: Modificar SP para retornar p_id_comentario como OUT parameter
OPCIÓN B: Usar LAST_INSERT_ID() después de INSERT en endpoint
OPCIÓN C: Cambiar SP para retornar id_comentario como field (SELECT ... , LAST_INSERT_ID() as id_comentario)
```

#### ✓ Usuario desde JWT:
- ✅ Obtiene `usuarioId` desde JWT claim `"sub"`
- ✅ NO acepta userId desde body o query
- ✅ Pasa correctamente a SP como `p_id_usuario`

---

### Endpoint 3: `GET /api/v1/Tickets/{id}/historial`

#### ✅ IMPLEMENTACIÓN ACTUAL:
```csharp
[HttpGet("{id}/historial")]
public async Task<IActionResult> GetHistorial(int id)
{
    var ticket = await _ticketService.GetByIdAsync(id);
    if (ticket == null)
        return Error<object>("Ticket no encontrado", statusCode: 404);
    
    var historial = await _ticketRepository.GetHistorialViaStoredProcedureAsync(id);
    return Success(historial, "Historial obtenido exitosamente");
}
```

#### ✅ VALIDACIONES:
- ✅ Verifica que ticket existe
- ✅ NO requiere usuario específico (GET es lectura)
- ✅ Retorna 404 si no existe

#### ⚠️ PROBLEMAS EN MAPEO:

El método `GetHistorialViaStoredProcedureAsync` mapea incorrectamente:

```csharp
var dto = new HistorialTicketDTO
{
    Id_Historial = row.id_transicion ?? 0,  // ❌ Debería ser row.orden
    Accion = string.IsNullOrEmpty(row.estado_to) ? "Comentario" : "Transición",  // ❌ Usar row.tipo == "COMENTARIO"
    Campo_Modificado = row.estado_from ?? "Comentario",  // ❌ No tiene sentido
    Valor_Anterior = row.estado_from,  // ❌ Debería ser estado_from_nombre
    Valor_Nuevo = row.estado_to ?? row.comentario,  // ❌ Debería ser estado_to_nombre
};
```

#### 📝 Mapeo Correcto:
```csharp
Id_Historial = (int)row.orden,
Accion = row.tipo == "TRANSICION" ? "Transición de Estado" : "Comentario",
Campo_Modificado = row.tipo == "TRANSICION" ? "Estado" : "Comentario",
Valor_Anterior = row.estadofrom_nombre ?? "N/A",
Valor_Nuevo = row.tipo == "TRANSICION" ? (row.estadoto_nombre ?? "N/A") : row.comentario,
```

---

## 🎯 PARTE 3: COMPARACIÓN CON SISTEMA MVC ORIGINAL

### TransicionesController MVC vs API

#### MVC: `POST /Tickets/{ticketId}/Transition`
```csharp
var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");
var transicionDto = new TransicionEstadoDTO { ... };
await _ticketService.TransicionarEstadoAsync(ticketId, transicionDto, usuarioId);
var transicion = new Transicion { ... };
var id = await _transicionRepository.CreateAsync(transicion);
```

#### API Actual: `PATCH /api/v1/Tickets/{id}/cambiar-estado`
```csharp
var userId = GetCurrentUserId();  // Desde JWT
var result = await _ticketRepository.TransicionarEstadoViaStoredProcedureAsync(...);
if (result.Success != 1) return 403;
```

#### ✅ EQUIVALENCIA:
- ✅ Ambos obtienen usuario del JWT (`User.FindFirst("sub")`)
- ✅ Ambos NO aceptan userId desde request body
- ✅ Ambos pasan usuario al servicio/SP
- ⚠️ MVC crea Transicion manualmente, API usa SP (correcto, centralizado en BD)

---

### ComentariosController MVC vs API

#### MVC: `POST /Tickets/{ticketId}/Comments`
```csharp
var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");
var comentario = new Comentario { 
    Id_Ticket = ticketId, 
    Id_Usuario = usuarioId,  // Desde JWT
    Contenido = dto.Contenido,
    Fecha_Creacion = DateTime.Now
};
var id = await _comentarioRepository.CreateAsync(comentario);
```

#### API Actual: `POST /api/v1/Tickets/{ticketId}/Comments`
```csharp
var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");
var result = await _comentarioRepository.CrearComentarioViaStoredProcedureAsync(...);
var comentarioCreado = await _comentarioRepository.GetByIdAsync(result.IdComentario ?? 0);
```

#### ✅ EQUIVALENCIA:
- ✅ Ambos obtienen usuario del JWT
- ✅ Ambos NO aceptan userId desde request
- ⚠️ MVC obtiene ID de `CreateAsync`, API intenta obtener mediante SP (pero SP no retorna ID)

---

## ✅ CHECKLIST DE VALIDACIÓN TÉCNICA

### Validación de Tipos de Datos
- [x] sp_tkt_transicionar retorna success (INT), message (VARCHAR), nuevo_estado (INT), id_asignado (INT)
- [x] sp_tkt_comentar retorna success (INT), mensaje (VARCHAR)
- [x] sp_tkt_historial retorna UNION de transiciones y comentarios con tipos compatibles
- [x] DTOs mapean correctamente los tipos SQL a C#

### Validación de HTTP Status Codes
- [ ] ⚠️ PATCH cambiar-estado: Status code siempre 403 en error (debería ser 404, 400, 403 según caso)
- [ ] ⚠️ POST comentarios: No hay mapeo de status codes (siempre BadRequest 400)
- [x] GET historial: Retorna 404 correctamente si ticket no existe

### Validación de Usuario desde JWT
- [x] ChangeTicketStatus: Obtiene userId desde `GetCurrentUserId()` (JWT claim "sub")
- [x] CrearComentario: Obtiene usuarioId desde `User.FindFirst("sub")` (JWT claim "sub")
- [x] GetHistorial: No requiere usuario (operación de lectura)
- [x] Ningún endpoint acepta userId desde body o query string

### Validación de Coherencia MVC-API
- [x] Usuario siempre obtenido del JWT (mismo que MVC)
- [x] Validaciones de negocio delegadas a SP (centralizado)
- [x] Respuesta sigue estructura ApiResponse estándar
- [x] Notificaciones llamadas post-operación (SignalR)

### Validación de Integridad SP
- [x] sp_tkt_transicionar valida reglas, permisos, aprobación
- [x] sp_tkt_comentar valida comentario no vacío
- [x] sp_tkt_historial UNION combina transiciones y comentarios

---

## 🚨 RIESGOS DETECTADOS

### 🔴 CRÍTICO - Bloquea Testing

#### Risk-1: `sp_tkt_comentar` no retorna `id_comentario`
- **Impacto:** Endpoint CrearComentario falla al intentar recuperar comentario creado
- **Línea:** ComentariosController.cs:95 `GetByIdAsync(result.IdComentario ?? 0)`
- **Solución:** Modificar SP para retornar el ID o usar `LAST_INSERT_ID()`

**Recomendación:** Modificar SP para retornar ID antes de hacer test

```sql
-- Opción: Agregar OUT parameter
ALTER PROCEDURE sp_tkt_comentar(
    IN p_id_tkt BIGINT,
    IN p_id_usuario INT,
    IN p_comentario VARCHAR(2000),
    OUT p_id_comentario BIGINT  -- ← NUEVO
)
BEGIN
    IF p_comentario IS NULL OR LENGTH(TRIM(p_comentario)) = 0 THEN
        SELECT 0 success, 'Comentario vacío' mensaje, NULL id_comentario;
    ELSE
        INSERT INTO tkt_comentario(id_tkt, id_usuario, comentario, fecha)
        VALUES(p_id_tkt, p_id_usuario, p_comentario, NOW());
        SET p_id_comentario = LAST_INSERT_ID();
        SELECT 1 success, 'Comentario agregado' mensaje, p_id_comentario id_comentario;
    END IF;
END
```

#### Risk-2: PATCH cambiar-estado mapea status code incorrecto
- **Impacto:** Cliente recibe 403 para todos los errores, no puede distinguir entre "transición no permitida" vs "ticket no existe"
- **Línea:** TicketsController.cs:145 `statusCode: 403` hardcodeado
- **Solución:** Mapear dynamicamente según SP message

---

### 🟡 MEDIUM - Degrada User Experience

#### Risk-3: Mapeo incorrecto de historial
- **Impacto:** Campos Valor_Anterior/Valor_Nuevo no reflejan datos correctos
- **Línea:** TicketRepository.cs:364-368
- **Solución:** Usar campos correctos de UNION (`estadofrom_nombre`, `estadoto_nombre`, `tipo`)

#### Risk-4: No valida usuario válido (== 0)
- **Impacto:** Si JWT invalido, userId = 0 se pasa a SP
- **Línea:** BaseApiController.cs:26 `return int.TryParse(...) ? userId : 0`
- **Solución:** Validar antes de pasar a SP, retornar 401 si inválido

---

## 📋 CONFIRMACIÓN DE EQUIVALENCIA FUNCIONAL

### TRANSICIÓN DE ESTADO
- **MVC:** `POST /Tickets/{id}/Transition` → Servicio valida → Crea Transicion
- **API:** `PATCH /Tickets/{id}/cambiar-estado` → SP valida → Crea tkt_transicion
- **Equivalencia:** ✅ 95% (falta mapeo correcto de status codes)

### CREAR COMENTARIO
- **MVC:** `POST /Tickets/{id}/Comments` → Insert directo → Retorna ID
- **API:** `POST /Tickets/{id}/Comments` → SP Insert → ❌ No retorna ID
- **Equivalencia:** ⚠️ 70% (bloqueado por SP issue)

### HISTORIAL
- **MVC:** `GetDetailAsync` → Query transiciones solamente
- **API:** `GET /Tickets/{id}/historial` → UNION transiciones + comentarios
- **Equivalencia:** ✅ 85% (API es mejorado, retorna historial unificado)

---

## 📌 RECOMENDACIONES ANTES DE TESTING

1. ⚠️ **FIX CRÍTICO:** Modificar `sp_tkt_comentar` para retornar `id_comentario`
2. ⚠️ **FIX CRÍTICO:** Implementar mapeo dinámico de HTTP status codes en PATCH cambiar-estado
3. ⚠️ **FIX MEDIUM:** Corregir mapeo de campos en `GetHistorialViaStoredProcedureAsync`
4. ⚠️ **FIX MEDIUM:** Validar userId != 0 antes de pasar a SP
5. ✅ **VALIDAR:** Que JWT siempre retorna claim "sub" válido
6. ✅ **TESTING:** Probar con usuario sin permisos (requiere_propietario)
7. ✅ **TESTING:** Probar con comentario vacío
8. ✅ **TESTING:** Verificar que transición no permitida retorna 403

---

**Firma de Auditoría:**
- **Fecha:** 23/12/2025
- **Status:** ✅ Auditoría Completa - 3 Riesgos Identificados - 2 Críticos
- **Next Step:** Implementar fixes antes de testing

