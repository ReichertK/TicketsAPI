$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
$Api = 'https://localhost:5001/api/v1'
$passed = 0
$failed = 0

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  PRUEBAS EXHAUSTIVAS - USUARIO ADMIN" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# LOGIN
Write-Host "[AUTH] Login como Admin..." -ForegroundColor Yellow
try {
    $login = Invoke-RestMethod -Uri "$Api/Auth/login" -Method Post -Body (@{usuario='Admin'; 'Contraseña'='changeme'} | ConvertTo-Json) -ContentType application/json
    $token = $login.datos.token
    $headers = @{"Authorization" = "Bearer $token"}
    Write-Host "  [OK] Token obtenido" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "  [FAIL] No se pudo autenticar" -ForegroundColor Red
    exit 1
}

# ========== TICKETS ==========
Write-Host "`n[TICKETS] Operaciones CRUD" -ForegroundColor Yellow

# GET All Tickets
Write-Host "  1. GET /Tickets (listar todos)..." -NoNewline
try {
    $tickets = Invoke-RestMethod -Uri "$Api/Tickets" -Headers $headers
    Write-Host " [OK] $($tickets.datos.Count) tickets" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# POST Create Ticket
Write-Host "  2. POST /Tickets (crear)..." -NoNewline
try {
    $newTicket = @{
        contenido = "Ticket de prueba CRUD completo"
        id_Prioridad = 2
        id_Departamento = 1
        id_Usuario_Asignado = 2
        id_Motivo = 1
    } | ConvertTo-Json
    $created = Invoke-RestMethod -Uri "$Api/Tickets" -Method Post -Headers $headers -Body $newTicket -ContentType application/json
    $ticketId = $created.datos.id
    Write-Host " [OK] ID: $ticketId" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
    $ticketId = 1
}

# GET Ticket by ID
Write-Host "  3. GET /Tickets/$ticketId (obtener uno)..." -NoNewline
try {
    $ticket = Invoke-RestMethod -Uri "$Api/Tickets/$ticketId" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# PUT Update Ticket
Write-Host "  4. PUT /Tickets/$ticketId (actualizar)..." -NoNewline
try {
    $updateTicket = @{
        id = $ticketId
        contenido = "Ticket actualizado via test"
        id_Prioridad = 3
        id_Departamento = 1
        id_Usuario_Asignado = 2
        id_Motivo = 1
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Tickets/$ticketId" -Method Put -Headers $headers -Body $updateTicket -ContentType application/json | Out-Null
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# GET Tickets con filtros
Write-Host "  5. GET /Tickets?estado=1 (filtro estado)..." -NoNewline
try {
    $filtered = Invoke-RestMethod -Uri "$Api/Tickets?estado=1" -Headers $headers
    Write-Host " [OK] $($filtered.datos.Count) tickets" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

Write-Host "  6. GET /Tickets?prioridad=2 (filtro prioridad)..." -NoNewline
try {
    $filtered = Invoke-RestMethod -Uri "$Api/Tickets?prioridad=2" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== COMENTARIOS ==========
Write-Host "`n[COMENTARIOS] Operaciones CRUD" -ForegroundColor Yellow

# POST Create Comment
Write-Host "  7. POST /Tickets/$ticketId/Comments (crear)..." -NoNewline
try {
    $newComment = @{contenido = "Comentario de prueba"} | ConvertTo-Json
    $commentCreated = Invoke-RestMethod -Uri "$Api/Tickets/$ticketId/Comments" -Method Post -Headers $headers -Body $newComment -ContentType application/json
    $commentId = $commentCreated.datos.id
    Write-Host " [OK] ID: $commentId" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
    $commentId = 1
}

# GET Comments by Ticket
Write-Host "  8. GET /Tickets/$ticketId/Comments (listar)..." -NoNewline
try {
    $comments = Invoke-RestMethod -Uri "$Api/Tickets/$ticketId/Comments" -Headers $headers
    Write-Host " [OK] $($comments.datos.Count) comentarios" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# PUT Update Comment
Write-Host "  9. PUT /Tickets/$ticketId/Comments/$commentId (actualizar)..." -NoNewline
try {
    $updateComment = @{
        id = $commentId
        id_Ticket = $ticketId
        contenido = "Comentario actualizado"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Tickets/$ticketId/Comments/$commentId" -Method Put -Headers $headers -Body $updateComment -ContentType application/json | Out-Null
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# DELETE Comment
Write-Host " 10. DELETE /Comments/$commentId (eliminar)..." -NoNewline
try {
    Invoke-RestMethod -Uri "$Api/Comments/$commentId" -Method Delete -Headers $headers | Out-Null
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== USUARIOS ==========
Write-Host "`n[USUARIOS] Operaciones CRUD" -ForegroundColor Yellow

# GET All Users
Write-Host " 11. GET /Usuarios (listar todos)..." -NoNewline
try {
    $users = Invoke-RestMethod -Uri "$Api/Usuarios" -Headers $headers
    Write-Host " [OK] $($users.datos.Count) usuarios" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# GET User by ID
Write-Host " 12. GET /Usuarios/1 (obtener uno)..." -NoNewline
try {
    $user = Invoke-RestMethod -Uri "$Api/Usuarios/1" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# POST Create User
Write-Host " 13. POST /Usuarios (crear)..." -NoNewline
try {
    $newUser = @{
        nombre = "TestUser_$(Get-Random)"
        email = "test$(Get-Random)@test.com"
        password = "test123"
        id_Departamento = 1
        id_Rol = 3
    } | ConvertTo-Json
    $userCreated = Invoke-RestMethod -Uri "$Api/Usuarios" -Method Post -Headers $headers -Body $newUser -ContentType application/json
    $userId = $userCreated.datos.id_Usuario
    Write-Host " [OK] ID: $userId" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
    $userId = 2
}

# PUT Update User
Write-Host " 14. PUT /Usuarios/$userId (actualizar)..." -NoNewline
try {
    $updateUser = @{
        id_Usuario = $userId
        nombre = "TestUser_Updated"
        email = "updated@test.com"
        id_Departamento = 1
        id_Rol = 3
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Usuarios/$userId" -Method Put -Headers $headers -Body $updateUser -ContentType application/json | Out-Null
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== GRUPOS ==========
Write-Host "`n[GRUPOS] Operaciones CRUD" -ForegroundColor Yellow

# GET All Groups
Write-Host " 15. GET /Grupos (listar todos)..." -NoNewline
try {
    $groups = Invoke-RestMethod -Uri "$Api/Grupos" -Headers $headers
    Write-Host " [OK] $($groups.datos.Count) grupos" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# GET Groups by IDs
Write-Host " 16. GET /Grupos/1,2,3 (filtro multiple)..." -NoNewline
try {
    $groupsFiltered = Invoke-RestMethod -Uri "$Api/Grupos/1,2,3" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# POST Create Group
Write-Host " 17. POST /Grupos (crear)..." -NoNewline
try {
    $newGroup = @{
        nombre = "Grupo Test $(Get-Random)"
        descripcion = "Grupo de prueba"
        activo = $true
    } | ConvertTo-Json
    $groupCreated = Invoke-RestMethod -Uri "$Api/Grupos" -Method Post -Headers $headers -Body $newGroup -ContentType application/json
    $groupId = $groupCreated.datos.id
    Write-Host " [OK] ID: $groupId" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
    $groupId = 1
}

# PUT Update Group
Write-Host " 18. PUT /Grupos/$groupId (actualizar)..." -NoNewline
try {
    $updateGroup = @{
        id = $groupId
        nombre = "Grupo Test Updated"
        descripcion = "Descripcion actualizada"
        activo = $true
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Grupos/$groupId" -Method Put -Headers $headers -Body $updateGroup -ContentType application/json | Out-Null
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== MOTIVOS ==========
Write-Host "`n[MOTIVOS] Operaciones CRUD" -ForegroundColor Yellow

# GET All Motivos
Write-Host " 19. GET /Motivos (listar todos)..." -NoNewline
try {
    $motivos = Invoke-RestMethod -Uri "$Api/Motivos" -Headers $headers
    Write-Host " [OK] $($motivos.datos.Count) motivos" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# GET Motivos by Departamento
Write-Host " 20. GET /Motivos/1 (por departamento)..." -NoNewline
try {
    $motivosByDept = Invoke-RestMethod -Uri "$Api/Motivos/1" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# POST Create Motivo
Write-Host " 21. POST /Motivos (crear)..." -NoNewline
try {
    $newMotivo = @{
        descripcion = "Motivo Test $(Get-Random)"
        id_Departamento = 1
        activo = $true
    } | ConvertTo-Json
    $motivoCreated = Invoke-RestMethod -Uri "$Api/Motivos" -Method Post -Headers $headers -Body $newMotivo -ContentType application/json
    $motivoId = $motivoCreated.datos.id
    Write-Host " [OK] ID: $motivoId" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
    $motivoId = 1
}

# PUT Update Motivo
Write-Host " 22. PUT /Motivos/$motivoId (actualizar)..." -NoNewline
try {
    $updateMotivo = @{
        id = $motivoId
        descripcion = "Motivo Test Updated"
        id_Departamento = 1
        activo = $true
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Motivos/$motivoId" -Method Put -Headers $headers -Body $updateMotivo -ContentType application/json | Out-Null
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== DEPARTAMENTOS ==========
Write-Host "`n[DEPARTAMENTOS] Operaciones CRUD" -ForegroundColor Yellow

# GET All Departamentos
Write-Host " 23. GET /Departamentos (listar todos)..." -NoNewline
try {
    $depts = Invoke-RestMethod -Uri "$Api/Departamentos" -Headers $headers
    Write-Host " [OK] $($depts.datos.Count) departamentos" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# GET Departamento by ID
Write-Host " 24. GET /Departamentos/1 (obtener uno)..." -NoNewline
try {
    $dept = Invoke-RestMethod -Uri "$Api/Departamentos/1" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# POST Create Departamento
Write-Host " 25. POST /Departamentos (crear)..." -NoNewline
try {
    $newDept = @{
        nombre = "Dept Test $(Get-Random)"
        descripcion = "Departamento de prueba"
    } | ConvertTo-Json
    $deptCreated = Invoke-RestMethod -Uri "$Api/Departamentos" -Method Post -Headers $headers -Body $newDept -ContentType application/json
    $deptId = $deptCreated.datos.id
    Write-Host " [OK] ID: $deptId" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
    $deptId = 1
}

# PUT Update Departamento
Write-Host " 26. PUT /Departamentos/$deptId (actualizar)..." -NoNewline
try {
    $updateDept = @{
        id = $deptId
        nombre = "Dept Test Updated"
        descripcion = "Descripcion actualizada"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Departamentos/$deptId" -Method Put -Headers $headers -Body $updateDept -ContentType application/json | Out-Null
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== TRANSICIONES ==========
Write-Host "`n[TRANSICIONES] Operaciones" -ForegroundColor Yellow

# POST Transition
Write-Host " 27. POST /Transiciones (cambiar estado)..." -NoNewline
try {
    $transition = @{
        id_Ticket = $ticketId
        id_Estado_Destino = 2
        comentario = "Transicion de prueba"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Transiciones" -Method Post -Headers $headers -Body $transition -ContentType application/json | Out-Null
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== APROBACIONES ==========
Write-Host "`n[APROBACIONES] Operaciones" -ForegroundColor Yellow

# GET Aprobaciones Pendientes
Write-Host " 28. GET /Aprobaciones/pendientes (listar)..." -NoNewline
try {
    $pending = Invoke-RestMethod -Uri "$Api/Aprobaciones/pendientes" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== BUSQUEDAS AVANZADAS ==========
Write-Host "`n[BUSQUEDAS] Filtros avanzados" -ForegroundColor Yellow

# Search Tickets
Write-Host " 29. GET /Tickets?search=test (busqueda texto)..." -NoNewline
try {
    $search = Invoke-RestMethod -Uri "$Api/Tickets?search=test" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# Tickets by User
Write-Host " 30. GET /Tickets?usuario=1 (por usuario)..." -NoNewline
try {
    $byUser = Invoke-RestMethod -Uri "$Api/Tickets?usuario=1" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# Tickets by Date Range
Write-Host " 31. GET /Tickets?fechaDesde=2024-01-01 (rango fechas)..." -NoNewline
try {
    $byDate = Invoke-RestMethod -Uri "$Api/Tickets?fechaDesde=2024-01-01&fechaHasta=2026-12-31" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== STORED PROCEDURES ==========
Write-Host "`n[STORED PROCEDURES] Operaciones" -ForegroundColor Yellow

# GET StoredProcedures
Write-Host " 32. GET /StoredProcedures (listar)..." -NoNewline
try {
    $sps = Invoke-RestMethod -Uri "$Api/StoredProcedures" -Headers $headers
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# ========== CLEANUP - DELETE ==========
Write-Host "`n[CLEANUP] Eliminando recursos de prueba" -ForegroundColor Yellow

# DELETE Ticket
Write-Host " 33. DELETE /Tickets/$ticketId (eliminar ticket)..." -NoNewline
try {
    Invoke-RestMethod -Uri "$Api/Tickets/$ticketId" -Method Delete -Headers $headers | Out-Null
    Write-Host " [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host " [FAIL]" -ForegroundColor Red
    $failed++
}

# DELETE User (si se creó)
if ($userId -gt 3) {
    Write-Host " 34. DELETE /Usuarios/$userId (eliminar usuario)..." -NoNewline
    try {
        Invoke-RestMethod -Uri "$Api/Usuarios/$userId" -Method Delete -Headers $headers | Out-Null
        Write-Host " [OK]" -ForegroundColor Green
        $passed++
    } catch {
        Write-Host " [FAIL]" -ForegroundColor Red
        $failed++
    }
}

# ========== RESUMEN ==========
$total = $passed + $failed
$percentage = [math]::Round(($passed / $total) * 100, 2)

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "             RESUMEN FINAL" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Total pruebas: $total" -ForegroundColor White
Write-Host "  Exitosas:      $passed" -ForegroundColor Green
Write-Host "  Fallidas:      $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host "  Porcentaje:    $percentage%" -ForegroundColor $(if ($percentage -ge 90) { "Green" } elseif ($percentage -ge 70) { "Yellow" } else { "Red" })
Write-Host "============================================`n" -ForegroundColor Cyan

if ($failed -eq 0) {
    Write-Host "TODAS LAS PRUEBAS EXITOSAS!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Algunas pruebas fallaron. Revisar logs." -ForegroundColor Yellow
    exit 1
}
