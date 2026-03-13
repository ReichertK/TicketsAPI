# 📊 RESUMEN DE PRUEBAS - TicketsAPI

## 📈 Estadísticas Generales

| Métrica | Valor | Estado |
|---------|-------|--------|
| **Total Pruebas** | 15 | ⚪ |
| **✅ Pasadas** | 6 | 🟢 40% |
| **❌ Fallidas** | 9 | 🔴 60% |

---

## 🔍 Errores por Status Code

| Status | Cantidad | Endpoints Afectados |
|--------|----------|---------------------|
| 🔴 **500** | 1 | POST /Tickets |
| 🔴 **405** | 1 | PUT /Tickets/{id} |
| 🟠 **404** | 6 | Comentarios (3), Estados, Prioridades, cambiar-estado |
| 🟡 **403** | 1 | GET /Usuarios |
| 🟡 **400** | 1 | GET /Usuarios/perfil-actual |

---

## 📋 Lista de Errores

### 🔴 CRÍTICOS (Bloquean funcionalidad principal)

1. **POST /Tickets** → `500` Internal Server Error
   - ❌ No se pueden crear tickets
   - Causa probable: Validación o FK constraint
   
2. **PUT /Tickets/{id}** → `405` Method Not Allowed
   - ❌ No se pueden actualizar tickets
   - Causa: Ruta no configurada para PUT

3. **POST/GET/PUT /Tickets/{id}/Comentarios** → `404` Not Found (×3)
   - ❌ Sistema de comentarios no funcional
   - Causa: Rutas no registradas

---

### 🟠 IMPORTANTES (Afectan UX)

4. **GET /Estados** → `404` Not Found
   - ⚠️ Dropdown estados no funciona
   - Necesario para crear/editar tickets

5. **GET /Prioridades** → `404` Not Found
   - ⚠️ Dropdown prioridades no funciona
   - Necesario para crear/editar tickets

6. **PATCH /Tickets/{id}/cambiar-estado** → `404` Not Found
   - ⚠️ No se puede cambiar estado de tickets
   - Funcionalidad clave del workflow

---

### 🟡 MENORES (No bloquean core)

7. **GET /Usuarios** → `403` Forbidden
   - ⚠️ Admin no puede ver lista de usuarios
   - Problema de autorización/roles

8. **GET /Usuarios/perfil-actual** → `400` Bad Request
   - ⚠️ No se puede consultar perfil
   - Claims del token incorrectos

---

## ✅ Endpoints Funcionales

| # | Endpoint | Método | Status | Resultado |
|---|----------|--------|--------|-----------|
| 1 | /Auth/login | POST | ✅ 200 | Token generado OK |
| 2 | /Tickets | GET | ✅ 200 | 28 tickets listados |
| 4 | /Tickets/{id} | GET | ✅ 200 | Ticket consultado OK |
| 12 | /Departamentos | GET | ✅ 200 | 67 departamentos |
| 13 | /Motivos | GET | ✅ 200 | Motivos listados OK |
| ? | *(1 más no especificado)* | ? | ✅ 200 | OK |

---

## 🛠️ Plan de Acción

### Fase 1: Críticos (1-2 días)
- [ ] Fix POST /Tickets (500)
  - Revisar logs
  - Validar FK constraints
  - Probar CreateTicketDto
  
- [ ] Fix PUT /Tickets (405)
  - Agregar [HttpPut("{id}")]
  - Verificar routing

- [ ] Fix Comentarios (404 ×3)
  - Implementar rutas anidadas
  - Registrar ComentariosController

### Fase 2: Importantes (1 día)
- [ ] Fix GET /Estados (404)
  - Implementar endpoint o corregir ruta
  
- [ ] Fix GET /Prioridades (404)
  - Implementar endpoint o corregir ruta
  
- [ ] Fix PATCH cambiar-estado (404)
  - Agregar método al controller

### Fase 3: Menores (medio día)
- [ ] Fix GET /Usuarios (403)
  - Revisar autorización
  - Verificar roles del usuario Admin
  
- [ ] Fix GET /Usuarios/perfil-actual (400)
  - Corregir claims en token JWT

---

## 📂 Archivos a Revisar

```
TicketsAPI/
├── Controllers/
│   ├── TicketsController.cs       ← POST, PUT, PATCH (Errores 1, 2, 6)
│   ├── ComentariosController.cs   ← Rutas anidadas (Errores 3, 4, 5)
│   ├── ReferencesController.cs    ← Estados, Prioridades (Errores 7, 8)
│   └── AdminController.cs         ← Usuarios (Errores 9, 10)
├── Program.cs                     ← Routing y autorización
├── Models/DTOs.cs                 ← Validación de CreateTicketDto
└── logs/tickets-api-*.txt         ← Logs de error 500
```

---

## 🔬 Testing

Ejecutar pruebas después de cada fix:

```powershell
# Ejecutar todas las pruebas
powershell -ExecutionPolicy Bypass -File "pruebas_simples.ps1"

# Probar un endpoint específico
$headers = @{Authorization = "Bearer TOKEN_AQUI"}
Invoke-RestMethod -Uri "https://localhost:5001/api/v1/Tickets" `
    -Headers $headers -SkipCertificateCheck
```

---

## 📊 Meta

**Objetivo:** 100% de pruebas pasando (15/15)  
**Actual:** 40% (6/15)  
**Por corregir:** 60% (9/15)

```
Progreso: [████░░░░░░] 40%
```

---

**Ver detalles completos:** [ERRORES_DETALLADOS.md](ERRORES_DETALLADOS.md)
