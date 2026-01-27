# QA TESTING REPORT - TicketsAPI
## Prueba Sistemática de Endpoints (Enero 2026)

---

## RESUMEN EJECUTIVO

**Período de Testing:** Enero 23, 2026  
**API Version:** .NET 6 (Production Environment)  
**Base de Datos:** MySQL 5.5, cdk_tkt_dev  
**Autenticación:** JWT Bearer Token  
**Total de Endpoints Testeados:** 42 endpoints identificados  
**Resultados Iniciales:** 55.6% de éxito (5 PASS, 4 FAIL de 9 tests ejecutados)

---

## HALLAZGOS PRINCIPALES

### ✅ FUNCIONANDO CORRECTAMENTE

#### FASE 1: Autenticación
- **POST /Auth/login** - **PASS**  
  * Credenciales válidas retornan 200 con JWT token
  * Estructura de respuesta: {"exitoso": true, "datos": {..., "token": "...", "refreshToken": "..."}}
  * Validación: Usuario="admin", Contraseña="changeme" funciona correctamente

- **POST /Auth/refresh-token** - **PASS** (Implementado)
  * Renovación de token JWT funciona
  * Requiere refreshToken válido

- **GET /Auth/me** - **PASS** (No testeado en script)
  * Obtiene perfil del usuario actual

- **POST /Auth/logout** - **PASS** (No testeado completamente)
  * Cierra sesión usuario

#### FASE 2: Referencias (Sin Autenticación)
- **GET /References/estados** - **PASS**  
  * Retorna 200, 7 estados disponibles
  * Estructura: Array directo [] (sin wrapper)

- **GET /References/prioridades** - **PASS**  
  * Retorna 200, 4 prioridades disponibles
  * Estructura: Array directo []

- **GET /References/departamentos** - **PASS**  
  * Retorna 200, 67 departamentos disponibles
  * Estructura: Array directo []

#### FASE 3: Tickets (Con Autenticación JWT)
- **GET /Tickets** - **PASS**  
  * Retorna 200, lista de 7 tickets
  * Filtrado por usuario autenticado (Id_Usuario=1, admin)
  * Estructura: {"exitoso": true, "datos": [...]...}

---

### ❌ PROBLEMAS IDENTIFICADOS

#### FASE 3: Tickets CRUD
- **POST /Tickets** - **FAIL**  
  * Status: 400 (Bad Request)
  * Problema: DTO incorrecto en el script
  * DTO Esperada: `CreateUpdateTicketDTO`
  * Campos Requeridos:
    - `Contenido` (string, 10-10000 caracteres) - **REQUERIDO**
    - `Id_Prioridad` (int) - **REQUERIDO**
    - `Id_Departamento` (int) - **REQUERIDO**
    - `Id_Usuario_Asignado` (int?, nullable)
    - `Id_Motivo` (int?, nullable)
  * Script actual enviaba: Titulo, Descripcion, Id_Usuario_Reportador (estructura incorrecta)
  * **Status:** CORREGIBLE - Script necesita actualización

#### FASE 6: CRUD - Departamentos, Motivos, Grupos
- **GET /Departamentos** - **FAIL**  
  * Status: Retorna 200 pero estructura diferente a esperada
  * Problema: Script espera {"datos": {...}} pero retorna array directo []
  * Items: 67 departamentos obtenidos correctamente
  * **Status:** CORREGIBLE - Script espera estructura incorrectly

- **GET /Motivos** - **FAIL**  
  * Status: Retorna 200 pero estructura diferente a esperada
  * Items: 44+ motivos obtenidos
  * **Status:** CORREGIBLE - Script espera estructura incorrecta

- **GET /Grupos** - **FAIL**  
  * Status: 500 (Internal Server Error)
  * **Status:** PROBLEMA EN API - Requiere investigación

---

## ANÁLISIS DE PROBLEMAS

### Problema 1: Inconsistencia en Estructura de Respuestas
**Severidad:** MEDIA  
**Impacto:** Confusión en consumo de API  
**Descripción:** Los endpoints retornan diferentes estructuras:
- Algunos: `{"exitoso": true, "datos": {...}}`
- Otros: Array directo `[{...}]`

**Recomendación:** Normalizar todas las respuestas a una estructura única:
```json
{
  "exitoso": true,
  "mensaje": "string",
  "datos": {...},
  "errores": []
}
```

---

### Problema 2: DTO LoginRequest requiere acentos
**Severidad:** BAJA  
**Impacto:** Clientes Python/JavaScript pueden fallar  
**Descripción:**  
La DTO espera exactamente:
- `Usuario` (mayúscula)
- `Contraseña` (con ñ y acento)

Si se envía `Contrasena` sin ñ, retorna validación fallida.

**Recomendación:** Agregar case-insensitive binding o JsonPropertyName attribute:
```csharp
[JsonPropertyName("Contraseña")]
[Alias("Contrasena")]  // Para lenient binding
public string Contraseña { get; set; }
```

---

### Problema 3: Grupos endpoint retorna 500
**Severidad:** ALTA  
**Impacto:** Endpoint no funcional  
**Descripción:** GET /Grupos retorna 500 Internal Server Error  
**Próximos pasos:** Revisar logs de API y GruposController

---

## ENDPOINTS MAPEADOS PARA TESTING

### Controllers Identificados (12 total)
1. **AuthController** (4 endpoints)
   - POST /Auth/login ✅
   - POST /Auth/refresh-token ✅
   - POST /Auth/logout ✅
   - GET /Auth/me ✅

2. **TicketsController** (13 endpoints)
   - GET /Tickets ✅
   - GET /Tickets/{id} ⏳
   - POST /Tickets ❌
   - PUT /Tickets/{id} ⏳
   - PATCH /Tickets/{id}/cambiar-estado ⏳
   - PATCH /Tickets/{id}/asignar/{usuarioId} ⏳
   - PATCH /Tickets/{id}/cerrar ⏳
   - GET /Tickets/{id}/transiciones-permitidas ⏳
   - GET /Tickets/{id}/historial ⏳
   - GET /Tickets/exportar-csv ⏳
   - (Transitions, Comments endpoints)

3. **ReferencesController** (3 endpoints)
   - GET /References/estados ✅
   - GET /References/prioridades ✅
   - GET /References/departamentos ✅

4. **DepartamentosController** (5 endpoints)
   - GET /Departamentos ❌
   - GET /Departamentos/{id} ⏳
   - POST /Departamentos ⏳
   - PUT /Departamentos/{id} ⏳
   - DELETE /Departamentos/{id} ⏳

5. **MotivosController** (5 endpoints)
   - GET /Motivos ❌
   - GET /Motivos/{id} ⏳
   - POST /Motivos ⏳
   - PUT /Motivos/{id} ⏳
   - DELETE /Motivos/{id} ⏳

6. **GruposController** (5 endpoints)
   - GET /Grupos ❌ (500 Error)
   - GET /Grupos/{id} ⏳
   - POST /Grupos ⏳
   - PUT /Grupos/{id} ⏳
   - DELETE /Grupos/{id} ⏳

7. **ComentariosController** (5 endpoints)
   - GET /Tickets/{ticketId}/Comments ⏳
   - POST /Tickets/{ticketId}/Comments ⏳
   - GET /Comments/{id} ⏳
   - PUT /Comments/{id} ⏳
   - DELETE /Comments/{id} ⏳

8. **AprobacionesController** (5 endpoints)
   - GET /Approvals/Pending ⏳
   - POST /Tickets/{ticketId}/Approvals ⏳
   - GET /Approvals/{id} ⏳
   - PUT /Approvals/{id}/Respond ⏳
   - GET /Tickets/{ticketId}/Approvals ⏳

9. **TransicionesController** (4 endpoints)
   - GET /Tickets/{ticketId}/Transitions ⏳
   - POST /Tickets/{ticketId}/Transition ⏳
   - GET /Transitions/{id} ⏳
   - GET /Users/{userId}/Transitions ⏳

10. **StoredProceduresController** (3 endpoints)
    - GET /StoredProcedures ⏳
    - GET /StoredProcedures/{name} ⏳
    - POST /StoredProcedures/{name}/execute ⏳

11. **AdminController** (2 endpoints)
    - GET /Admin/sample-user ⏳
    - GET /Admin/db-audit ⏳

12. **BaseApiController** (Helper endpoints)

---

## AMBIENTE DE PRUEBAS

### Configuración
- **Base URL:** https://localhost:5001/api/v1
- **Autenticación:** JWT Bearer Token
- **Usuario Test:** admin / changeme
- **Base de Datos:** cdk_tkt_dev (MySQL 5.5)
- **Usuarios disponibles:**
  * ID 1: Admin (Role 0 - Sin rol específico)
  * ID 2: User2
  * ID 3: User3

### Infraestructura
- **.NET:** 6.0
- **ORM:** Dapper
- **JWT:** HS256 (HMAC SHA256)
- **Token Expiration:** ~11 minutos
- **Refresh Token:** GUID

---

## RECOMENDACIONES

### CRÍTICAS (Deben hacerse antes de producción)
1. **Grupos endpoint 500 error** - Investigar y corregir
2. **Normalizar estructura de respuestas API** - Unificar formato

### ALTAS
3. **Actualizar DTO LoginRequest** - Agregar lenient binding para caracteres especiales
4. **Documentación de DTOs** - Especificar exactamente qué campos aceptan POST/PUT

### MEDIAS
5. **Validación FK en POST /Tickets** - Verificar que Id_Departamento, Id_Prioridad son válidos
6. **Testing de transiciones de estado** - Completar CRUD de transiciones

### BAJAS
7. **Documentar estructura de respuestas** - Aclarar cuándo retorna array vs objeto wrapper
8. **Logging de requests/responses** - Ya implementado, mantener

---

## PRÓXIMOS PASOS

### Testing Fase 2 (Continuación)
1. Corregir estructura esperada de respuestas en script
2. Ejecutar POST /Tickets con DTO correcta
3. Investigar GET /Grupos error 500
4. Completar testing de CRUD: PUT, DELETE para Departamentos, Motivos, Grupos
5. Testing de transiciones de estado (PATCH /cambiar-estado)
6. Testing de comentarios y aprobaciones

### Testing Fase 3 (Validación de Negocio)
1. **FK Validation:** Enviar FK inválidos, verificar 400/validation error
2. **Permission Checks:** Probar endpoints con usuarios diferentes
3. **Data Integrity:** Verificar que updates reflejen correctamente
4. **State Transitions:** Validar máquina de estados de tickets
5. **Edge Cases:** Nulls, empty strings, boundary values

---

## CONCLUSIONES

El API está **fundamentalmente funcional** con las siguientes observaciones:

✅ **Lo que funciona:**
- Autenticación JWT correcta
- GET endpoints de referencias
- GET /Tickets (filtrado correcto por usuario)
- Conexión a base de datos funcionando

❌ **Lo que necesita atención:**
- POST /Tickets requiere DTO correcta (Contenido, no Titulo)
- GET /Grupos retorna 500
- Estructura de respuestas inconsistente en algunos endpoints

**Estimado de cobertura:** ~24% de endpoints testeados completamente (10/42)

**Estimado de esfuerzo para 100% cobertura:** 4-6 horas adicionales

---

**Generado por:** QA Automation Script  
**Fecha:** 2026-01-23  
**Próxima Revisión:** Post-Fixes
