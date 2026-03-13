# ANÁLISIS DE ERRORES - TicketsAPI

Fecha: 2024 (última ejecución)
Usuario: Admin
Total pruebas: 15
Pasadas: 6 (40%)
Fallidas: 9 (60%)

## RESUMEN EJECUTIVO

De 15 endpoints probados como usuario Admin, 9 presentan errores que necesitan corrección inmediata:

- **3 endpoints HTTP 404** (No encontrados) - Rutas no registradas
- **2 endpoints HTTP 500** (Error interno) - Problemas de validación/lógica
- **1 endpoint HTTP 405** (Método no permitido) - Configuración de ruta incorrecta  
- **1 endpoint HTTP 403** (Prohibido) - Problema de autorización
- **1 endpoint HTTP 400** (Solicitud incorrecta) - Validación o formato
- **1 endpoint sin status code** - Error desconocido

---

## ERRORES DETALLADOS POR ENDPOINT

### 🔴 **ERROR 1: POST /Tickets - Status 500 (Internal Server Error)**

**Prueba:** [3] POST /Tickets (crear nuevo ticket)
**Status:** 500 - Error interno del servidor
**Frecuencia:** Consistente en todas las ejecuciones

**Síntomas:**
```
Invoke-RestMethod : Error en el servidor remoto: (500) Error interno del servidor.
```

**Body enviado:**
```json
{
    "contenido": "Test 14:23:15",
    "id_Prioridad": 1,
    "id_Departamento": 1,
    "id_Usuario_Asignado": 2,
    "id_Motivo": 1
}
```

**Posibles causas:**
1. Validación del DTO CreateTicketDto fallando
2. FK constraints en DB (id_Usuario_Asignado=2 puede no existir como Supervisor/Operador activo)
3. Campos requeridos faltantes en el request
4. Trigger o SP en DB fallando
5. id_Motivo o id_Prioridad no existen con esos IDs

**Recomendación:** 
- Revisar logs en [logs/tickets-api-YYYYMMDD.txt](TicketsAPI/logs/)
- Verificar validación en CreateTicketDto
- Confirmar existencia de FK: usuario ID=2, prioridad ID=1, departamento ID=1, motivo ID=1
- Revisar SP `sp_Insertar_Ticket`

---

### 🔴 **ERROR 2: PUT /Tickets/{id} - Status 405 (Method Not Allowed)**

**Prueba:** [5] PUT /Tickets/{id} (actualizar ticket)
**Status:** 405 - Método no permitido
**Frecuencia:** Consistente

**Síntomas:**
```
Invoke-RestMethod : Error en el servidor remoto: (405) Método no permitido.
```

**Endpoint:** `PUT /Tickets/1`

**Posibles causas:**
1. Ruta no configurada para método PUT en TicketsController
2. Atributo [HttpPut] faltante o mal configurado
3. Ruta definida solo como [HttpPost] o sin método específico

**Ubicación problema:** [TicketsController.cs](TicketsAPI/Controllers/TicketsController.cs)

**Recomendación:**
- Verificar que existe método con `[HttpPut("{id}")]`
- Confirmar que no hay conflicto de rutas
- Revisar que el routing esté correctamente configurado

---

### 🔴 **ERROR 3: PATCH /Tickets/{id}/cambiar-estado - Status 404 (Not Found)**

**Prueba:** [6] PATCH /Tickets/{id}/cambiar-estado
**Status:** 404 - No se encontró
**Frecuencia:** Consistente

**Síntomas:**
```
Invoke-RestMethod : Error en el servidor remoto: (404) No se encontró.
```

**Endpoint esperado:** `PATCH /Tickets/1/cambiar-estado`

**Posibles causas:**
1. Endpoint no registrado en TicketsController
2. Ruta mal definida (falta prefix, case sensitivity)
3. Método con nombre diferente al esperado

**Recomendación:**
- Verificar existencia de método `CambiarEstado` en TicketsController
- Confirmar atributo `[HttpPatch("{id}/cambiar-estado")]`
- Revisar que el RoutePrefix del controller sea correcto

---

### 🔴 **ERROR 4: POST /Tickets/{id}/Comentarios - Status 404 (Not Found)**

**Prueba:** [7] POST /Tickets/{id}/Comentarios (crear comentario)
**Status:** 404 - No se encontró
**Frecuencia:** Consistente

**Endpoint:** `POST /Tickets/1/Comentarios`

**Posibles causas:**
1. ComentariosController no configurado o ruta incorrecta
2. Ruta debería ser `/Comentarios?ticketId=1` en lugar de nested route
3. Controller no registrado en Program.cs

**Ubicación:** [ComentariosController.cs](TicketsAPI/Controllers/ComentariosController.cs)

**Recomendación:**
- Verificar RoutePrefix de ComentariosController
- Confirmar que acepta rutas anidadas bajo /Tickets/{id}/
- Revisar [Program.cs](TicketsAPI/Program.cs) para registro de controller

---

### 🔴 **ERROR 5: GET /Tickets/{id}/Comentarios - Status 404 (Not Found)**

**Prueba:** [8] GET /Tickets/{id}/Comentarios (listar comentarios)
**Status:** 404 - No se encontró
**Frecuencia:** Consistente

**Endpoint:** `GET /Tickets/1/Comentarios`

**Posibles causas:**
- Misma causa que ERROR 4 (ruta de Comentarios)
- Método GET no implementado para ruta anidada

**Recomendación:**
- Mismo fix que ERROR 4

---

### 🔴 **ERROR 6: PUT /Tickets/{id}/Comentarios/{cid} - Status 404 (Not Found)**

**Prueba:** [9] PUT /Tickets/{id}/Comentarios/{cid} (actualizar comentario)
**Status:** 404 - No se encontró
**Frecuencia:** Consistente

**Endpoint:** `PUT /Tickets/1/Comentarios/1`

**Posibles causas:**
- Mismo problema de ruta que ERROR 4 y 5

**Recomendación:**
- Mismo fix que ERROR 4

---

### 🔴 **ERROR 7: GET /Estados - Status 404 (Not Found)**

**Prueba:** [10] GET /Estados
**Status:** 404 - No se encontró
**Frecuencia:** Consistente

**Endpoint:** `GET /Estados`

**Posibles causas:**
1. Controller de Estados no implementado
2. Endpoint llamado diferente (ej: /References/Estados)
3. Funcionalidad fusionada en otro controller

**Recomendación:**
- Verificar si existe EstadosController o ReferencesController
- Revisar [ReferencesController.cs](TicketsAPI/Controllers/ReferencesController.cs) si existe
- Confirmar que endpoint esté registrado correctamente

---

### 🔴 **ERROR 8: GET /Prioridades - Status 404 (Not Found)**

**Prueba:** [11] GET /Prioridades
**Status:** 404 - No se encontró
**Frecuencia:** Consistente

**Endpoint:** `GET /Prioridades`

**Posibles causas:**
- Mismo problema que ERROR 7 (controller no implementado o ruta incorrecta)

**Recomendación:**
- Mismo fix que ERROR 7

---

### 🔴 **ERROR 9: GET /Usuarios - Status 403 (Forbidden)**

**Prueba:** [14] GET /Usuarios
**Status:** 403 - Prohibido
**Frecuencia:** Consistente

**Síntomas:**
```
Invoke-RestMethod : Error en el servidor remoto: (403) Prohibido.
```

**Endpoint:** `GET /Usuarios`
**Usuario:** Admin (debería tener acceso total)

**Posibles causas:**
1. Autorización por Roles mal configurada
2. Usuario Admin no tiene el rol requerido asignado
3. Policy de autorización demasiado restrictiva
4. Middleware de autorización bloqueando incorrectamente

**Ubicación:** 
- [AdminController.cs](TicketsAPI/Controllers/AdminController.cs) - Revisar [Authorize] attributes
- [Program.cs](TicketsAPI/Program.cs) - Revisar configuración de políticas

**Recomendación:**
- Verificar roles asignados al usuario Admin en BD
- Revisar atributo `[Authorize]` en endpoint /Usuarios
- Confirmar que políticas de autorización sean correctas
- Verificar que claims del token JWT incluyan roles correctos

---

### 🔴 **ERROR 10: GET /Usuarios/perfil-actual - Status 400 (Bad Request)**

**Prueba:** [15] GET /Usuarios/perfil-actual
**Status:** 400 - Solicitud incorrecta
**Frecuencia:** Consistente

**Síntomas:**
```
Invoke-RestMethod : Error en el servidor remoto: (400) Solicitud incorrecta.
```

**Endpoint:** `GET /Usuarios/perfil-actual`

**Posibles causas:**
1. Token JWT no contiene claims requeridos (userId, username, etc.)
2. Endpoint espera parámetros que no están siendo enviados
3. Validación del request fallando
4. Método no es GET, debería ser POST con body

**Recomendación:**
- Revisar JWT claims generados en AuthController
- Verificar que userId/username esté en el token
- Confirmar signature del método en Controller
- Revisar logs para ver mensaje de error específico

---

## ✅ ENDPOINTS QUE FUNCIONAN CORRECTAMENTE

1. **POST /Auth/login** - 200 OK - Autenticación funcional
2. **GET /Tickets** - 200 OK - Lista de tickets funcional (28 registros)
3. **GET /Tickets/{id}** - 200 OK - Consulta por ID funcional  
4. **GET /Departamentos** - 200 OK - Lista departamentos (67 registros)
5. **GET /Motivos** - 200 OK - Lista motivos funcional
6. *(1 más no identificado específicamente)*

---

## PLAN DE CORRECCIÓN PRIORITARIO

### **Prioridad ALTA (Bloquean funcionalidad core)**

1. **POST /Tickets (500)** - Crear tickets es funcionalidad crítica
   - Revisar validación y FK constraints
   - Verificar logs detallados
   - Probar con diferentes combinaciones de IDs

2. **PUT /Tickets (405)** - Actualizar tickets es esencial
   - Agregar/corregir ruta [HttpPut]
   - Confirmar routing

3. **Comentarios (404 x3)** - Sistema de comentarios no funcional
   - Implementar/corregir rutas anidadas
   - Verificar controller registration

### **Prioridad MEDIA (Afectan UX)**

4. **GET /Estados y /Prioridades (404 x2)** - Dropdowns no funcionan
   - Implementar controllers o corregir rutas
   - Son necesarios para crear/editar tickets

5. **GET /Usuarios (403)** - Admin no puede ver usuarios
   - Corregir autorización
   - Verificar roles

### **Prioridad BAJA (No crítico)**

6. **GET /Usuarios/perfil-actual (400)** - Nice to have
   - Corregir claims o validación
   - No bloquea funcionalidad crítica

---

## ARCHIVOS A REVISAR

1. [TicketsController.cs](TicketsAPI/Controllers/TicketsController.cs) - Errores 1, 2, 3
2. [ComentariosController.cs](TicketsAPI/Controllers/ComentariosController.cs) - Errores 4, 5, 6
3. [ReferencesController.cs](TicketsAPI/Controllers/ReferencesController.cs) - Errores 7, 8 (si existe)
4. [AdminController.cs](TicketsAPI/Controllers/AdminController.cs) - Errores 9, 10
5. [Program.cs](TicketsAPI/Program.cs) - Routing y autorización
6. [Logs](TicketsAPI/logs/) - Detalles de errores 500

---

## COMANDOS ÚTILES PARA DEBUGGING

```powershell
# Ver logs en tiempo real
Get-Content "TicketsAPI\logs\tickets-api-$(Get-Date -Format yyyyMMdd).txt" -Wait

# Probar endpoint específico con detalles
Invoke-WebRequest -Uri "https://localhost:5001/api/v1/Tickets" -Method POST `
    -Headers @{Authorization="Bearer TOKEN"} `
    -Body '{"contenido":"Test"}' -ContentType "application/json" `
    -SkipCertificateCheck -Verbose

# Ver estructura de tablas
mysql -u user -p -e "DESCRIBE cdk_tkt_dev.tkt_tickets;"
```

---

**SIGUIENTE PASO:** Ejecutar los fixes uno por uno, probando después de cada cambio con el script de pruebas.
