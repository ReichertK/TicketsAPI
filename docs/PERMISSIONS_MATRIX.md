# TicketsAPI - Matriz de Permisos y Reglas de Negocio

**Fecha:** 23 de Diciembre de 2025  
**Sistema Original:** MVC Legacy (cdk_tkt.sql)  
**Compatibilidad:** REST API debe respetar modelo original

---

## 🔐 Matriz de Permisos por Rol

### Vista Consolidada

```
┌─────────────────────┬──────────┬─────────┬──────────┐
│ Operación           │  ADMIN   │ TÉCNICO │ USUARIO  │
├─────────────────────┼──────────┼─────────┼──────────┤
│ Ver Todos sin filtro│   ✅    │   ❌    │    ❌    │
│ Ver Sus Tickets     │   ✅    │   ✅    │    ✅    │
│ Ver Depto Asignado  │   ✅    │   ✅    │    ❌    │
│ Crear Ticket        │   ✅    │   ✅    │    ✅    │
│ Asignar a Otros     │   ✅    │   ⚠️    │    ❌    │
│ Cambiar Estado      │   ✅    │   ✅    │    ⚠️    │
│ Modificar Ticket    │   ✅    │   ✅    │    ⚠️    │
│ Eliminar (Soft)     │   ✅    │   ❌    │    ❌    │
│ Ver Historial       │   ✅    │   ✅    │    ✅    │
│ Comentar            │   ✅    │   ✅    │    ✅    │
└─────────────────────┴──────────┴─────────┴──────────┘

✅ = Permitido
⚠️ = Condicional (ver detalle)
❌ = No permitido
```

---

## 📊 Detalles por Operación

### 1. VER TICKETS - GET /Tickets

#### ADMIN (idUsuario=1)
```sql
-- ¿Qué ve?
SELECT * FROM tkt WHERE Habilitado = 1

-- Puede filtrar por:
- Id_Estado (cualquiera)
- Id_Prioridad (cualquiera)
- Id_Departamento (cualquiera)
- Id_Motivo (cualquiera)
- Fecha (rango)

-- Paginación: Sin límite (pero API limita a max 100/página)

-- Resultado: TODOS los tickets activos
```

#### TÉCNICO (idUsuario=3, asignado a depto=10)
```sql
-- ¿Qué ve?
SELECT * FROM tkt WHERE (
  Id_Usuario = 3                    -- Creados por él
  OR Id_Usuario_Asignado = 3        -- Asignados a él
  OR (Id_Departamento = 10)         -- De su depto
) AND Habilitado = 1

-- Puede filtrar por:
- Id_Estado (de sus tickets)
- Id_Prioridad (de sus tickets)
- Id_Departamento (solo 10, otros → 403)
- Id_Motivo (de sus tickets)

-- Resultado: Solo sus tickets + depto asignado
```

#### USUARIO (idUsuario=5, sin depto asignado)
```sql
-- ¿Qué ve?
SELECT * FROM tkt WHERE (
  Id_Usuario = 5        -- Solo sus creados
) AND Habilitado = 1

-- Puede filtrar por:
- Ninguno (todos aplicados a sus propios tickets)

-- Resultado: Solo tickets creados por él
```

---

### 2. CREAR TICKET - POST /Tickets

#### ADMIN
```
Permitido: ✅
Restricción: Ninguna (puede asignar a cualquiera)

Payload Mínimo:
{
  "contenido": "...",           // 10-10000 chars
  "id_prioridad": 1,            // FK válida
  "id_departamento": 1,         // FK válida
  "id_motivo": null             // Opcional
}

Resultado:
- Ticket creado con Id_Usuario = 1 (del JWT)
- Id_Estado = 1 (Abierto, hardcoded en TicketService)
- Notificación enviada
```

#### TÉCNICO
```
Permitido: ✅
Restricción: 
- Solo puede crear en depto asignado (NO VALIDADO en API)
- Puede asignar a cualquiera (si permisos)

Resultado:
- Ticket creado con Id_Usuario = 3 (del JWT)
- Id_Departamento debería ser de su depto
```

#### USUARIO
```
Permitido: ✅ (crear su propio ticket)
Restricción:
- Solo en su depto
- NO puede asignar a otros

Resultado:
- Ticket creado con Id_Usuario = 5 (del JWT)
- Id_Usuario_Asignado = null (solo él)
```

---

### 3. MODIFICAR TICKET - PUT /Tickets/{id}

#### Regla Base
```
Solo puede editar:
- Su propio ticket (Id_Usuario = userId), O
- Asignados a él (Id_Usuario_Asignado = userId), O
- Admin puede editar cualquiera
```

**Campos Editables:**
```csharp
// Público (cualquier rol)
- Contenido
- Id_Prioridad
- Id_Departamento
- Id_Motivo
- Id_Usuario_Asignado

// Solo ADMIN
- Id_Estado
- Habilitado (soft delete)
```

---

### 4. CAMBIAR ESTADO - PATCH /Tickets/{id}/cambiar-estado

#### ADMIN
```
Permitido: ✅
Transiciones: Cualquiera válida según reglas BD

Validaciones:
- Ticket existe
- Estado_to válido (FK en tabla estado)
- Transición permitida (tabla tkt_transicion_regla)
- Comentario requerido (sp_tkt_transicionar)
```

#### TÉCNICO
```
Permitido: ⚠️ Condicional
Restricciones:
- Solo tickets asignados a él
- Solo transiciones permitidas para rol

Validaciones:
- Id_Usuario_Asignado = 3 (técnico)
- Rol = 'TÉCNICO' → transiciones permitidas
```

#### USUARIO
```
Permitido: ❌
Resultado: 403 Forbidden "No tiene permisos para cambiar estado"
```

---

## 🚨 Casos Borde y Comportamiento Esperado

### 1. Usuario Intenta Ver Tickets de Otro

**Escenario:**
```
GET /api/v1/Tickets?Id_Usuario=10
Authorization: Bearer <userId=3_jwt>
```

**Comportamiento Actual:**
- API sobrescribe filtro.Id_Usuario = 3 (del JWT)
- SP retorna solo tickets de usuario=3
- Usuario 10 nunca ve

**Comportamiento Esperado:** ✅ CORRECTO
- Usuario NO puede forzar ver datos de otro
- JWT es fuente única de autoridad

---

### 2. Técnico Intenta Acceder a Depto sin Permiso

**Escenario:**
```
GET /api/v1/Tickets?Id_Departamento=59
Authorization: Bearer <userId=3_jwt>  (técnico asignado a depto=10)
```

**Comportamiento Actual:**
- SP recibe w_Id_Usuario=3, w_Id_Departamento=59
- Retorna tickets vacío (SP no encuentra coincidencia)
- Respuesta: 200 OK, lista vacía

**Comportamiento Esperado (Opción A):**
- Retornar lista vacía (permitido intentar, no ataques de enumeración)
- **Ventaja:** Consistente con "ausencia de datos"

**Comportamiento Esperado (Opción B):**
- Validar en controller si depto es accesible
- Retornar 403 si no
- **Ventaja:** Explícito sobre denegación de acceso

**Recomendación:** Opción A (actual) es más compatible con MVC original.

---

### 3. Ticket Creado por User1, Asignado a User2, Editado por User3

**Escenario:**
```
Ticket (Id_Tkt=5, Id_Usuario=1, Id_Usuario_Asignado=2)
PUT /api/v1/Tickets/5
Authorization: Bearer <userId=3_jwt>

{
  "contenido": "Editado por usuario 3",
  ...
}
```

**Comportamiento Esperado:**
- User3 NO puede editar (no es creador, no asignado)
- Resultado: 403 Forbidden o permitir si rol=ADMIN

**Validación Necesaria:**
```csharp
if (ticket.Id_Usuario != userId && 
    ticket.Id_Usuario_Asignado != userId && 
    !isAdmin)
    return Forbidden("No puede editar este ticket");
```

---

### 4. Asignación a Usuario Inactivo/Inexistente

**Escenario:**
```
POST /api/v1/Tickets
{
  "contenido": "Test",
  "id_prioridad": 1,
  "id_departamento": 1,
  "id_usuario_asignado": 999
}
```

**Comportamiento Actual:** HTTP 500 (FK constraint)
**Comportamiento Esperado:** HTTP 400 "Usuario 999 no existe"

**Validación Necesaria:**
```csharp
if (dto.Id_Usuario_Asignado.HasValue)
{
    var user = await _usuarioRepository.GetByIdAsync(dto.Id_Usuario_Asignado.Value);
    if (user == null)
        throw new ValidationException("Usuario asignado no existe");
}
```

---

### 5. Paginación en Límites Extremos

**Test Cases:**

| Pagina | TamañoPagina | Esperado | Status |
|--------|--------------|----------|--------|
| 1 | 10 | OK (normal) | 200 |
| 1 | 1000 | Clampeado a 100 | 200 |
| 0 | 10 | Ajustado a pagina=1 | 200 |
| -5 | 20 | Ajustado a pagina=1 | 200 |
| 1 | 0 | Clampeado a 1 | 200 |
| 1 | -50 | Clampeado a 1 | 200 |
| 999 | 10 | OK, lista vacía | 200 |

**Validación Actual (TicketRepository):**
```csharp
var page = Math.Max(1, filtro.Pagina);              // ✅ Min=1
var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);  // ✅ Range 1-100
```

**Estado:** ✅ Ya protegido

---

### 6. Búsqueda por Contenido con Caracteres Especiales

**Escenario:**
```
GET /api/v1/Tickets?Busqueda=%'; DROP TABLE tkt; --%
```

**Protección:** SP usa parametrización (CONCAT seguro en MySQL)
**Estado:** ✅ SAFE (no es vulnerable a SQL injection)

---

### 7. FK Válida en Tabla Pero Eliminada (Soft Delete)

**Escenario:**
- Departamento id=10 existe en BD
- Pero está marcado como inactivo/eliminado
- Usuario intenta crear ticket para depto=10

**Comportamiento Actual:**
- FK constraint permite (columna Habilitado no se valida en FK)
- Ticket se crea pero depto está "invisible"

**Validación Necesaria:**
```csharp
// Validar no solo existencia, sino también estado activo
if (!await _departamentoRepository.IsActivAsync(dto.Id_Departamento))
    throw new ValidationException("Departamento inactivo");
```

---

## 📋 Tabla de Transiciones de Estado

```sql
-- Según tabla tkt_transicion_regla en BD

Abierto (1) → En Proceso (2)    [cualquier rol con permiso]
Abierto (1) → En Espera (4)     [requiere propietario]

En Proceso (2) → Cerrado (3)    [ADMIN o asignado]
En Proceso (2) → Reabierto (7)  [ADMIN]

Cerrado (3) → Reabierto (7)     [ADMIN]

Reabierto (7) → En Proceso (2)  [ADMIN]
```

**Validación en API:**
- SP valida automáticamente vía `sp_tkt_transicionar`
- API debe capturar respuesta del SP:
  ```json
  {
    "success": 1,           // 1=OK, 0=error
    "message": "OK",
    "nuevo_estado": 2,
    "id_asignado": 3
  }
  ```

---

## 🔍 Diferencias Esperadas entre Roles

### Expectativa de Datos en GET /Tickets

**ADMIN solicitando tickets de todo el sistema:**
```json
{
  "totalRegistros": 6,
  "datos": [
    {"id_Tkt": 1, "id_Usuario": 1, "id_Usuario_Asignado": 2, "id_Departamento": 21},
    {"id_Tkt": 2, "id_Usuario": 1, "id_Usuario_Asignado": 3, "id_Departamento": 59},
    {"id_Tkt": 3, "id_Usuario": 1, "id_Usuario_Asignado": 3, "id_Departamento": 66},
    {"id_Tkt": 4, "id_Usuario": 1, "id_Usuario_Asignado": 3, "id_Departamento": 59},
    {"id_Tkt": 5, "id_Usuario": 1, "id_Usuario_Asignado": 1, "id_Departamento": 66},
    {"id_Tkt": 6, "id_Usuario": 1, "id_Usuario_Asignado": 1, "id_Departamento": 13}
  ]
}
```

**TECNICO (id=3) solicitando:**
```json
{
  "totalRegistros": 4,  // Solo tickets donde asignado=3 o creador=3
  "datos": [
    {"id_Tkt": 2, "id_Usuario": 1, "id_Usuario_Asignado": 3, ...},
    {"id_Tkt": 3, "id_Usuario": 1, "id_Usuario_Asignado": 3, ...},
    {"id_Tkt": 4, "id_Usuario": 1, "id_Usuario_Asignado": 3, ...},
    // Plus cualquier ticket creado por id=3
  ]
}
```

---

## ✅ Validación de Compatibilidad MVC

**Preguntas para Desarrollador al Regresar:**

1. ¿Sistema MVC original filtra en memoria o en SP?
   - **Respuesta Esperada:** SP (estamos correctos)

2. ¿TECNICO puede ver depto asignado o solo tickets donde asignado=userId?
   - **Respuesta Esperada:** Ambos (implementar lógica)

3. ¿Qué roles existen en tabla usuario_rol?
   - **Acción:** Documentar roles y permisos

4. ¿FK inválida retorna 400 o 500 en MVC original?
   - **Respuesta Esperada:** 400 (validar antes de guardar)

5. ¿Soft delete es por Habilitado=0 o eliminación física?
   - **Respuesta Esperada:** Habilitado=0 (estamos correctos)

---

## 📝 Checklist de Validación Antes de Producción

- [ ] ADMIN ve todos los tickets
- [ ] TÉCNICO ve solo asignados/creados/depto
- [ ] USUARIO ve solo sus propios
- [ ] FK inválida retorna HTTP 400
- [ ] Acceso denegado retorna HTTP 403
- [ ] Paginación respeta límites
- [ ] Soft delete respeta Habilitado=1
- [ ] Transiciones respetan reglas
- [ ] JWT es fuente única de userId
- [ ] Sin vulnerabilidades SQL injection
- [ ] Historial auditable
- [ ] Notificaciones enviadas

---

**Próximos Pasos para Desarrollador:**
1. Confirmar matriz de permisos con requisitos
2. Implementar validaciones FK
3. Validar con BD producción
4. Testing por rol
5. Documentar discrepancias encontradas
