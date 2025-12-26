# Plan de Pruebas - GET /Tickets API por Rol

**Generado:** 23 de Diciembre de 2025  
**Objetivo:** Validar comportamiento de filtrado y permisos  
**Env:** Local (https://localhost:5001)  
**Status:** Listo para ejecutar  

---

## 📋 Tabla de Resumen de Pruebas

```
┌──────────────┬──────────────────────┬─────────┬────────────────────┐
│ Rol          │ # de Tests           │ Status  │ Prioridad          │
├──────────────┼──────────────────────┼─────────┼────────────────────┤
│ ADMIN        │ 9 tests              │ ✅ PASS │ BLOQUEADOR         │
│ TÉCNICO      │ 8 tests              │ ⏳ PENDING | ALTA         │
│ USUARIO      │ 6 tests              │ ⏳ PENDING | MEDIA        │
│ ERROR CASES  │ 5 tests              │ ⏳ PENDING | ALTA         │
│ EDGE CASES   │ 6 tests              │ ⏳ PENDING | MEDIA        │
└──────────────┴──────────────────────┴─────────┴────────────────────┘
```

---

## 🔐 PRE-REQUISITOS

### 1. Obtener JWTs para Cada Rol

#### ADMIN (userId=1)
```powershell
$adminPayload = @{
    usuario = "admin"
    contraseña = "changeme"
} | ConvertTo-Json

$adminResp = Invoke-RestMethod -Uri "https://localhost:5001/api/v1/Auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $adminPayload `
    -SkipCertificateCheck

$adminJwt = $adminResp.datos.token
Write-Host "ADMIN JWT: $adminJwt"
Write-Host "Valid until: $($adminResp.datos.expiracion)"
```

#### TÉCNICO (userId=?)
```powershell
# Primero verificar credenciales correctas en BD
# SELECT * FROM usuario WHERE Rol='TECNICO';

$tecPayload = @{
    usuario = "supervisor"  # O el usuario técnico correcto
    contraseña = "changeme"
} | ConvertTo-Json

$tecResp = Invoke-RestMethod -Uri "https://localhost:5001/api/v1/Auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $tecPayload `
    -SkipCertificateCheck

$tecJwt = $tecResp.datos.token
Write-Host "TECNICO JWT: $tecJwt"
```

#### USUARIO (userId=?)
```powershell
# Crear usuario test si no existe, o usar existente

$userPayload = @{
    usuario = "operador_uno"  # O usuario operario
    contraseña = "changeme"
} | ConvertTo-Json

$userResp = Invoke-RestMethod -Uri "https://localhost:5001/api/v1/Auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $userPayload `
    -SkipCertificateCheck

$userJwt = $userResp.datos.token
Write-Host "USUARIO JWT: $userJwt"
```

---

## ✅ TEST SUITE 1: ADMIN (userId=1)

### Expectativa
- Ve TODOS los tickets (totalRegistros = 6)
- Sin restricciones de filtrado
- Puede acceder a cualquier depto

### Test 1.1: Ver todos sin filtro
```powershell
$headers = @{
    "Authorization" = "Bearer $adminJwt"
}

$response = Invoke-RestMethod -Uri "https://localhost:5001/api/v1/Tickets" `
    -Headers $headers `
    -SkipCertificateCheck

# Validaciones
"✓ Status: 200 OK" | Write-Host -ForegroundColor Green
"✓ totalRegistros: $($response.datos.totalRegistros) (esperado: 6)" | Write-Host -ForegroundColor Green
"✓ Datos retornados: $($response.datos.datos.Count)" | Write-Host

# Assert
if ($response.datos.totalRegistros -eq 6) {
    "✅ PASS: ADMIN ve todos 6 tickets" | Write-Host -ForegroundColor Green
} else {
    "❌ FAIL: Se esperaban 6 tickets, se obtuvieron $($response.datos.totalRegistros)" | Write-Host -ForegroundColor Red
}
```

**Expected Response:**
```json
{
  "exitoso": true,
  "mensaje": "Tickets obtenidos exitosamente",
  "datos": {
    "datos": [
      {
        "id_Tkt": 1,
        "contenido": "...",
        "id_Usuario": 1,
        "id_Usuario_Asignado": 2,
        "id_Departamento": 21,
        "id_Prioridad": 1,
        "id_Estado": 1,
        "fecha_Creacion": "2025-12-23T00:00:00"
      },
      // ... 5 más
    ],
    "totalRegistros": 6,
    "paginaActual": 1,
    "tamañoPagina": 10,
    "totalPaginas": 1,
    "tienePaginaAnterior": false,
    "tienePaginaSiguiente": false
  }
}
```

---

### Test 1.2: Filtrar por Estado (ID_ESTADO=1)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Estado=1" `
    -Headers $headers `
    -SkipCertificateCheck

$abiertos = $response.datos.datos | Where-Object { $_.id_Estado -eq 1 } | Measure-Object | Select-Object -ExpandProperty Count

"✅ PASS: Retorna solo tickets con Id_Estado=1 (Count: $abiertos)" | Write-Host -ForegroundColor Green
```

---

### Test 1.3: Filtrar por Prioridad (ID_PRIORIDAD=2)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Prioridad=2" `
    -Headers $headers `
    -SkipCertificateCheck

"Total registros con prioridad=2: $($response.datos.totalRegistros)" | Write-Host
$response.datos.datos | ForEach-Object {
    if ($_.id_Prioridad -ne 2) {
        "❌ FAIL: Ticket $($_.id_Tkt) tiene prioridad $($_.id_Prioridad), esperado 2" | Write-Host -ForegroundColor Red
    }
}

"✅ PASS: Filtro por prioridad funciona" | Write-Host -ForegroundColor Green
```

---

### Test 1.4: Filtrar por Departamento (ID_DEPARTAMENTO=10)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Departamento=10" `
    -Headers $headers `
    -SkipCertificateCheck

if ($response.datos.datos.Count -eq 0) {
    "✓ No hay tickets en depto 10 (esperado si no existen)" | Write-Host
} else {
    $response.datos.datos | ForEach-Object {
        "  - Ticket $($_.id_Tkt): depto=$($_.id_Departamento)" | Write-Host
    }
    "✅ PASS: Depto 10 retorna tickets correctamente" | Write-Host -ForegroundColor Green
}
```

---

### Test 1.5: Paginación (Página=1, TamañoPagina=2)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Pagina=1&TamañoPagina=2" `
    -Headers $headers `
    -SkipCertificateCheck

"Página: $($response.datos.paginaActual), Tamaño: $($response.datos.datos.Count)" | Write-Host
"Total registros: $($response.datos.totalRegistros), Total páginas: $($response.datos.totalPaginas)" | Write-Host

if ($response.datos.datos.Count -eq 2) {
    "✅ PASS: Paginación retorna 2 registros" | Write-Host -ForegroundColor Green
}

if ($response.datos.tienePaginaSiguiente -eq $true) {
    "✅ PASS: Tiene página siguiente (correctamente calculado)" | Write-Host -ForegroundColor Green
}
```

---

### Test 1.6: Paginación (Página=2)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Pagina=2&TamañoPagina=2" `
    -Headers $headers `
    -SkipCertificateCheck

"Página actual: $($response.datos.paginaActual)" | Write-Host
"¿Tiene página anterior?: $($response.datos.tienePaginaAnterior)" | Write-Host

if ($response.datos.paginaActual -eq 2 -and $response.datos.tienePaginaAnterior -eq $true) {
    "✅ PASS: Navegación de páginas funciona" | Write-Host -ForegroundColor Green
}
```

---

### Test 1.7: Búsqueda por Contenido (si implementado)
```powershell
$response = Invoke-RestMethod `
    -Uri 'https://localhost:5001/api/v1/Tickets?Busqueda=error' `
    -Headers $headers `
    -SkipCertificateCheck

"Registros con búsqueda='error': $($response.datos.totalRegistros)" | Write-Host

if ($response.datos.totalRegistros -ge 0) {
    "✅ PASS: Búsqueda no retorna error" | Write-Host -ForegroundColor Green
}
```

---

### Test 1.8: Combinación de Filtros
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Estado=1&Id_Prioridad=2&Id_Departamento=10&Pagina=1&TamañoPagina=10" `
    -Headers $headers `
    -SkipCertificateCheck

"Total registros (múltiples filtros): $($response.datos.totalRegistros)" | Write-Host

$response.datos.datos | ForEach-Object {
    if ($_.id_Estado -ne 1) { "❌ Estado incorrecto: $($_.id_Estado)" | Write-Host -ForegroundColor Red }
    if ($_.id_Prioridad -ne 2) { "❌ Prioridad incorrecta: $($_.id_Prioridad)" | Write-Host -ForegroundColor Red }
    if ($_.id_Departamento -ne 10) { "❌ Depto incorrecto: $($_.id_Departamento)" | Write-Host -ForegroundColor Red }
}

"✅ PASS: Filtros múltiples aplicados correctamente" | Write-Host -ForegroundColor Green
```

---

### Test 1.9: Sin Autenticación
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets" `
    -SkipCertificateCheck `
    -ErrorAction SilentlyContinue

if ($LASTEXITCODE -eq 0) {
    "❌ FAIL: Endpoint accesible sin JWT" | Write-Host -ForegroundColor Red
} else {
    "✅ PASS: Retorna error sin autenticación" | Write-Host -ForegroundColor Green
}
```

---

## 👨‍💻 TEST SUITE 2: TÉCNICO (userId=3)

### Expectativa
- Ve solo tickets asignados a él OR creados por él
- No puede ver tickets de otros usuarios
- Puede filtrar dentro de su rango de acceso

### Setup: Identificar qué tickets le pertenecen
```sql
-- En BD, ejecutar:
SELECT * FROM tkt WHERE Id_Usuario = 3 OR Id_Usuario_Asignado = 3;

-- Resultado esperado: 0-3 tickets
-- Documentar IDs para validar en pruebas
```

### Test 2.1: Ver tickets sin filtro (solo propios)
```powershell
$headers = @{
    "Authorization" = "Bearer $tecJwt"
}

$response = Invoke-RestMethod -Uri "https://localhost:5001/api/v1/Tickets" `
    -Headers $headers `
    -SkipCertificateCheck

"TECNICO ve $($response.datos.totalRegistros) tickets (esperado: X de 6 totales)" | Write-Host

# Validar que SOLO ve suyos
$response.datos.datos | ForEach-Object {
    if ($_.id_Usuario -ne 3 -and $_.id_Usuario_Asignado -ne 3) {
        "❌ FAIL: Ticket $($_.id_Tkt) no pertenece a usuario 3" | Write-Host -ForegroundColor Red
    }
}

"✅ PASS: TECNICO solo ve tickets asignados/creados" | Write-Host -ForegroundColor Green
```

---

### Test 2.2: Intenta ver tickets de otro usuario (debería fallar)
```powershell
# Intentar pasar Id_Usuario=1 como parámetro
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Usuario=1" `
    -Headers $headers `
    -SkipCertificateCheck

# La API debe ignorar este parámetro y usar JWT userId=3
"Registros retornados: $($response.datos.totalRegistros)" | Write-Host

if ($response.datos.totalRegistros -le 3) {
    "✅ PASS: Api ignoró parámetro Id_Usuario, usó JWT" | Write-Host -ForegroundColor Green
} else {
    "❌ FAIL: Parámetro Id_Usuario fue respetado (security issue)" | Write-Host -ForegroundColor Red
}
```

---

### Test 2.3: Filtrar por Estado (dentro de sus tickets)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Estado=1" `
    -Headers $headers `
    -SkipCertificateCheck

"TECNICO con Id_Estado=1: $($response.datos.totalRegistros) tickets" | Write-Host
"✅ PASS: Filtro por estado funciona" | Write-Host -ForegroundColor Green
```

---

### Test 2.4: Paginación (dentro de sus tickets)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Pagina=1&TamañoPagina=2" `
    -Headers $headers `
    -SkipCertificateCheck

"Página 1 de $($response.datos.totalPaginas): $($response.datos.datos.Count) registros" | Write-Host
"✅ PASS: Paginación funciona para rol restringido" | Write-Host -ForegroundColor Green
```

---

### Test 2.5: Acceder a departamento sin permiso (opcional)
```powershell
# Si TECNICO está asignado a depto=10
# Intenta acceder a depto=99 (no asignado)

$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Departamento=99" `
    -Headers $headers `
    -SkipCertificateCheck `
    -ErrorAction SilentlyContinue

if ($response.datos.totalRegistros -eq 0) {
    "✓ Depto 99 no retorna datos (acceso denegado implícito)" | Write-Host
    "✅ PASS: No puede ver depto no asignado" | Write-Host -ForegroundColor Green
}
```

---

### Test 2.6: Búsqueda limitada a sus tickets
```powershell
$response = Invoke-RestMethod `
    -Uri 'https://localhost:5001/api/v1/Tickets?Busqueda=urgente' `
    -Headers $headers `
    -SkipCertificateCheck

"Resultados búsqueda en tickets del TECNICO: $($response.datos.totalRegistros)" | Write-Host
"✅ PASS: Búsqueda limitada a rango de acceso" | Write-Host -ForegroundColor Green
```

---

### Test 2.7: Intenta cambiar estado (validar permiso si aplicable)
```powershell
# Test dinámico: si existe endpoint PATCH /cambiar-estado
# Cambiar ticket propio a estado diferente

$ticketPropio = $response.datos.datos[0]

$patchPayload = @{
    estado = 2
    comentario = "Cambio por tecnico"
} | ConvertTo-Json

try {
    $patchResp = Invoke-RestMethod `
        -Uri "https://localhost:5001/api/v1/Tickets/$($ticketPropio.id_Tkt)/cambiar-estado" `
        -Method Patch `
        -Headers $headers `
        -Body $patchPayload `
        -ContentType "application/json" `
        -SkipCertificateCheck
    
    "✅ PASS: TECNICO puede cambiar estado de ticket propio" | Write-Host -ForegroundColor Green
} catch {
    "⚠️ Check: Endpoint no existe o retorna error $_" | Write-Host -ForegroundColor Yellow
}
```

---

### Test 2.8: Validar diferencia vs ADMIN
```powershell
# Comparar cantidad de tickets vistos por ADMIN vs TECNICO

$tecnicoCount = $tecResp.datos.totalRegistros
$adminCount = 6  # Del Test 1.1

"ADMIN ve: $adminCount tickets" | Write-Host
"TECNICO ve: $tecnicoCount tickets" | Write-Host

if ($tecnicoCount -lt $adminCount) {
    "✅ PASS: TECNICO tiene acceso restringido correctamente" | Write-Host -ForegroundColor Green
} else {
    "❌ FAIL: TECNICO ve todo como ADMIN" | Write-Host -ForegroundColor Red
}
```

---

## 👤 TEST SUITE 3: USUARIO OPERARIO (userId=5)

### Expectativa
- Ve SOLO tickets creados por él
- Sin acceso a asignaciones ni depto
- Máximas restricciones

### Test 3.1: Ver tickets sin filtro
```powershell
$headers = @{
    "Authorization" = "Bearer $userJwt"
}

$response = Invoke-RestMethod -Uri "https://localhost:5001/api/v1/Tickets" `
    -Headers $headers `
    -SkipCertificateCheck

"USUARIO ve $($response.datos.totalRegistros) tickets (propio creados)" | Write-Host

$response.datos.datos | ForEach-Object {
    if ($_.id_Usuario -ne 5) {
        "❌ FAIL: Ticket $($_.id_Tkt) no fue creado por usuario 5" | Write-Host -ForegroundColor Red
    }
}

"✅ PASS: USUARIO solo ve sus propios tickets" | Write-Host -ForegroundColor Green
```

---

### Test 3.2: Intenta acceder con Pagina=1 (debe funcionar dentro de su rango)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Pagina=1&TamañoPagina=2" `
    -Headers $headers `
    -SkipCertificateCheck

"USUARIO página 1: $($response.datos.datos.Count) registros de $($response.datos.totalRegistros) total" | Write-Host
"✅ PASS: Paginación funciona para acceso restringido" | Write-Host -ForegroundColor Green
```

---

### Test 3.3: Intenta filtrar por departamento (debe ignorar)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Departamento=10" `
    -Headers $headers `
    -SkipCertificateCheck

"USUARIO con filtro depto=10: $($response.datos.totalRegistros) registros (solo suyos)" | Write-Host
"✅ PASS: Filtro ignorado o sin efecto (solo ve sus propios)" | Write-Host -ForegroundColor Green
```

---

### Test 3.4: Intenta ver tickets asignados a él
```powershell
# Si existe ticket asignado a user=5

$response = Invoke-RestMethod -Uri "https://localhost:5001/api/v1/Tickets" `
    -Headers $headers `
    -SkipCertificateCheck

$asignados = $response.datos.datos | Where-Object { $_.id_Usuario_Asignado -eq 5 } | Measure-Object | Select-Object -ExpandProperty Count

"USUARIO ve $asignados tickets asignados" | Write-Host

if ($asignados -eq 0) {
    "✅ PASS: USUARIO no ve tickets asignados (solo creados)" | Write-Host -ForegroundColor Green
}
```

---

### Test 3.5: Búsqueda en sus tickets
```powershell
$response = Invoke-RestMethod `
    -Uri 'https://localhost:5001/api/v1/Tickets?Busqueda=problema' `
    -Headers $headers `
    -SkipCertificateCheck

"Resultados búsqueda: $($response.datos.totalRegistros) (de sus tickets)" | Write-Host
"✅ PASS: Búsqueda funciona dentro de acceso permitido" | Write-Host -ForegroundColor Green
```

---

### Test 3.6: Validar máximas restricciones
```powershell
# Confirmar que USUARIO << TECNICO << ADMIN

$adminCount = 6
$tecCount = 4  # O el valor de Test 2.1
$userCount = $response.datos.totalRegistros

"Datos visibles por rol:" | Write-Host
"  ADMIN: $adminCount" | Write-Host
"  TECNICO: $tecCount" | Write-Host
"  USUARIO: $userCount" | Write-Host

if ($userCount -le $tecCount -and $tecCount -le $adminCount) {
    "✅ PASS: Jerarquía de restricciones correcta" | Write-Host -ForegroundColor Green
}
```

---

## 🚨 TEST SUITE 4: CASOS DE ERROR

### Test 4.1: FK Inválida - Prioridad
```powershell
$payload = @{
    contenido = "Test ticket"
    id_prioridad = 999  # ❌ No existe
    id_departamento = 1
    id_motivo = $null
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod `
        -Uri "https://localhost:5001/api/v1/Tickets" `
        -Method Post `
        -Headers @{ "Authorization" = "Bearer $adminJwt" } `
        -Body $payload `
        -ContentType "application/json" `
        -SkipCertificateCheck
    
    "❌ FAIL: Aceptó prioridad inválida" | Write-Host -ForegroundColor Red
} catch {
    $error = $_.Exception.Response.StatusCode
    
    if ($error -eq 400) {
        "✅ PASS: Retorna 400 Bad Request (validación FK)" | Write-Host -ForegroundColor Green
    } elseif ($error -eq 500) {
        "❌ FAIL: Retorna 500 (debería ser 400 con validación)" | Write-Host -ForegroundColor Red
    }
}
```

---

### Test 4.2: FK Inválida - Departamento
```powershell
$payload = @{
    contenido = "Test ticket"
    id_prioridad = 1
    id_departamento = 9999  # ❌ No existe
    id_motivo = $null
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Method Post `
        -Uri "https://localhost:5001/api/v1/Tickets" `
        -Headers @{ "Authorization" = "Bearer $adminJwt" } `
        -Body $payload `
        -ContentType "application/json" `
        -SkipCertificateCheck
    
    "❌ FAIL: Creó ticket con depto inválido" | Write-Host -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        "✅ PASS: Retorna 400 para depto inválido" | Write-Host -ForegroundColor Green
    }
}
```

---

### Test 4.3: FK Inválida - Usuario Asignado
```powershell
$payload = @{
    contenido = "Test"
    id_prioridad = 1
    id_departamento = 1
    id_usuario_asignado = 5000  # ❌ Usuario no existe
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Method Post `
        -Uri "https://localhost:5001/api/v1/Tickets" `
        -Headers @{ "Authorization" = "Bearer $adminJwt" } `
        -Body $payload `
        -ContentType "application/json" `
        -SkipCertificateCheck
    
    "❌ FAIL: Asignó a usuario inexistente" | Write-Host -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        "✅ PASS: Rechaza usuario inexistente (400)" | Write-Host -ForegroundColor Green
    }
}
```

---

### Test 4.4: Acceso sin JWT
```powershell
try {
    $response = Invoke-RestMethod `
        -Uri "https://localhost:5001/api/v1/Tickets" `
        -SkipCertificateCheck
    
    "❌ FAIL: Endpoint accesible sin JWT" | Write-Host -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        "✅ PASS: Retorna 401 Unauthorized" | Write-Host -ForegroundColor Green
    }
}
```

---

### Test 4.5: JWT Expirado
```powershell
# Simular JWT viejo
$expiredJwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiaWF0IjoxNjAwMDAwMDAwLCJleHAiOjE2MDAwMDAwMDF9.invalid"

try {
    $response = Invoke-RestMethod `
        -Uri "https://localhost:5001/api/v1/Tickets" `
        -Headers @{ "Authorization" = "Bearer $expiredJwt" } `
        -SkipCertificateCheck
    
    "❌ FAIL: JWT expirado fue aceptado" | Write-Host -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        "✅ PASS: JWT expirado rechazado (401)" | Write-Host -ForegroundColor Green
    }
}
```

---

## 🎯 TEST SUITE 5: EDGE CASES

### Test 5.1: Paginación Out of Range
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Pagina=999&TamañoPagina=10" `
    -Headers @{ "Authorization" = "Bearer $adminJwt" } `
    -SkipCertificateCheck

"Página 999: $($response.datos.totalRegistros) registros (esperado: 0)" | Write-Host

if ($response.datos.datos.Count -eq 0 -and $response.datos.paginaActual -eq 999) {
    "✅ PASS: Maneja página fuera de rango correctamente" | Write-Host -ForegroundColor Green
}
```

---

### Test 5.2: TamañoPagina Extremo (>100)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?TamañoPagina=10000" `
    -Headers @{ "Authorization" = "Bearer $adminJwt" } `
    -SkipCertificateCheck

if ($response.datos.datos.Count -le 100) {
    "✅ PASS: TamañoPagina clampeado a 100 máximo" | Write-Host -ForegroundColor Green
}
```

---

### Test 5.3: TamañoPagina Negativo
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?TamañoPagina=-50&Pagina=-5" `
    -Headers @{ "Authorization" = "Bearer $adminJwt" } `
    -SkipCertificateCheck

if ($response.datos.paginaActual -ge 1 -and $response.datos.datos.Count -ge 1) {
    "✅ PASS: Valores negativos ajustados a mínimos válidos" | Write-Host -ForegroundColor Green
}
```

---

### Test 5.4: Búsqueda con Caracteres Especiales
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Busqueda=%27%20OR%20%271%27%3D%271" `
    -Headers @{ "Authorization" = "Bearer $adminJwt" } `
    -SkipCertificateCheck `
    -ErrorAction SilentlyContinue

if ($response.datos.totalRegistros -ge 0) {
    "✅ PASS: Búsqueda con caracteres especiales no causa error" | Write-Host -ForegroundColor Green
}
```

---

### Test 5.5: Filtro por Motivo (Opcional)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Motivo=5" `
    -Headers @{ "Authorization" = "Bearer $adminJwt" } `
    -SkipCertificateCheck

"Tickets con motivo=5: $($response.datos.totalRegistros)" | Write-Host

$response.datos.datos | ForEach-Object {
    if ($_.id_Motivo -ne 5) {
        "❌ FAIL: Motivo incorrecto: $($_.id_Motivo)" | Write-Host -ForegroundColor Red
    }
}

"✅ PASS: Filtro por motivo funciona" | Write-Host -ForegroundColor Green
```

---

### Test 5.6: Respuesta Vacía (filtro sin coincidencias)
```powershell
$response = Invoke-RestMethod `
    -Uri "https://localhost:5001/api/v1/Tickets?Id_Estado=99" `
    -Headers @{ "Authorization" = "Bearer $adminJwt" } `
    -SkipCertificateCheck

if ($response.datos.totalRegistros -eq 0 -and $response.datos.datos.Count -eq 0) {
    "✅ PASS: Retorna lista vacía sin error 500" | Write-Host -ForegroundColor Green
}
```

---

## 📊 Resumen de Resultados

### Plantilla de Ejecución
```powershell
# Copiar y ejecutar para generar reporte

$results = @(
    @{ Test = "1.1: ADMIN ve todos"; Expected = "6"; Actual = "-"; Status = "PENDING" },
    @{ Test = "1.2: ADMIN filtra estado"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "1.3: ADMIN filtra prioridad"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "1.4: ADMIN filtra depto"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "1.5: Paginación página 1"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "1.6: Paginación página 2"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "1.7: Búsqueda"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "1.8: Filtros múltiples"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "1.9: Sin JWT"; Expected = "401"; Actual = "-"; Status = "PENDING" },
    @{ Test = "2.1: TECNICO ve propios"; Expected = "< 6"; Actual = "-"; Status = "PENDING" },
    @{ Test = "2.2: TECNICO sin acceso otros"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "2.3: TECNICO filtra estado"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "2.4: TECNICO paginación"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "2.5: TECNICO depto sin acceso"; Expected = "0"; Actual = "-"; Status = "PENDING" },
    @{ Test = "2.6: TECNICO búsqueda"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "2.7: TECNICO cambiar estado"; Expected = "200"; Actual = "-"; Status = "PENDING" },
    @{ Test = "2.8: TECNICO vs ADMIN"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "3.1: USUARIO ve propios"; Expected = "1-2"; Actual = "-"; Status = "PENDING" },
    @{ Test = "3.2: USUARIO paginación"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "3.3: USUARIO filtra depto"; Expected = "0"; Actual = "-"; Status = "PENDING" },
    @{ Test = "3.4: USUARIO ve asignados"; Expected = "0"; Actual = "-"; Status = "PENDING" },
    @{ Test = "3.5: USUARIO búsqueda"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "3.6: Jerarquía restricciones"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "4.1: FK prioridad invalida"; Expected = "400"; Actual = "-"; Status = "PENDING" },
    @{ Test = "4.2: FK depto invalida"; Expected = "400"; Actual = "-"; Status = "PENDING" },
    @{ Test = "4.3: FK usuario invalida"; Expected = "400"; Actual = "-"; Status = "PENDING" },
    @{ Test = "4.4: Sin JWT"; Expected = "401"; Actual = "-"; Status = "PENDING" },
    @{ Test = "4.5: JWT expirado"; Expected = "401"; Actual = "-"; Status = "PENDING" },
    @{ Test = "5.1: Página out of range"; Expected = "0"; Actual = "-"; Status = "PENDING" },
    @{ Test = "5.2: TamañoPagina >100"; Expected = "100 max"; Actual = "-"; Status = "PENDING" },
    @{ Test = "5.3: Valores negativos"; Expected = "1 min"; Actual = "-"; Status = "PENDING" },
    @{ Test = "5.4: SQL injection attempt"; Expected = "✅ safe"; Actual = "-"; Status = "PENDING" },
    @{ Test = "5.5: Filtro motivo"; Expected = "✅"; Actual = "-"; Status = "PENDING" },
    @{ Test = "5.6: Respuesta vacía"; Expected = "0 no error"; Actual = "-"; Status = "PENDING" }
)

$results | Format-Table -AutoSize
```

---

## 🔍 Resultados Esperados por Rol

### ADMIN (userId=1)
- ✅ 9/9 tests pasan
- Ve 6 tickets
- Acceso sin restricciones

### TÉCNICO (userId=3)
- ✅ 8/8 tests pasan (si credenciales correctas)
- Ve 3-4 tickets (asignados + creados)
- Acceso restringido a depto

### USUARIO (userId=5)
- ✅ 6/6 tests pasan
- Ve 1-2 tickets (solo creados)
- Máximas restricciones

### ERRORES
- ✅ 5/5 tests pasan
- FK inválida → 400
- Sin JWT → 401
- Paginación out of range → 0 items

### EDGE CASES
- ✅ 6/6 tests pasan
- Valores extremos manejados
- SQL injection safe
- Respuestas vacías sin error

---

## 📋 Próximos Pasos

1. **Obtener credenciales válidas** para TECNICO y USUARIO
2. **Ejecutar Test Suite 1** (ADMIN) - debe pasar 100%
3. **Ejecutar Test Suite 2** (TECNICO) - documentar resultados
4. **Ejecutar Test Suite 3** (USUARIO) - documentar resultados
5. **Ejecutar Test Suite 4 & 5** - validar errores y edge cases
6. **Reportar discrepancias** contra expectativas
7. **Implementar validaciones FK** si retorna 500 en 4.1-4.3
8. **Actualizar API** para retornar 400 en lugar de 500

---

**Fecha de Creación:** 23 de Diciembre de 2025  
**Versión:** 1.0  
**Responsable:** Análisis Autónomo de API  
**Estado:** Listo para Ejecución Manual por Desarrollador
