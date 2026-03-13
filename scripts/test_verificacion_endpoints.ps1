$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
$Api = 'https://localhost:5001/api/v1'
$passed = 0
$failed = 0
$details = @()

Write-Host "`n=== VERIFICACION DE 14 ENDPOINTS FALLIDOS ===" -ForegroundColor Cyan

# Login
$login = Invoke-RestMethod -Uri "$Api/Auth/login" -Method Post -Body (@{usuario='Admin'; 'Contraseña'='changeme'} | ConvertTo-Json) -ContentType application/json
$headers = @{"Authorization" = "Bearer $($login.datos.token)"}

# 1. POST Comentario
Write-Host "`n1. POST /Tickets/1/Comments" -ForegroundColor Yellow
try {
    $body = @{contenido = "Test comment"} | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Tickets/1/Comments" -Method Post -Headers $headers -Body $body -ContentType application/json
    Write-Host "   [OK] ID: $($r.datos.Id_Comentario)" -ForegroundColor Green
    $commentId = $r.datos.Id_Comentario
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "POST Comments necesita validacion - puede ser problema de SP"
    $failed++
    $commentId = 1
}

# 2. PUT Comentario
Write-Host "`n2. PUT /Tickets/1/Comments/$commentId" -ForegroundColor Yellow
try {
    $body = @{contenido = "Updated comment"; privado = $false} | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Tickets/1/Comments/$commentId" -Method Put -Headers $headers -Body $body -ContentType application/json | Out-Null
    Write-Host "   [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "PUT Comments - revisar permisos (solo dueño puede editar)"
    $failed++
}

# 3. DELETE Comentario
Write-Host "`n3. DELETE /Comments/$commentId" -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "$Api/Comments/$commentId" -Method Delete -Headers $headers | Out-Null
    Write-Host "   [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "DELETE Comments - revisar permisos (solo dueño puede eliminar)"
    $failed++
}

# 4. POST Usuario
Write-Host "`n4. POST /Usuarios" -ForegroundColor Yellow
try {
    $body = @{
        nombre = "TestUser_$(Get-Random)"
        email = "test$(Get-Random)@test.com"
        password = "test123"
        id_Departamento = 1
        id_Rol = 3
    } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Usuarios" -Method Post -Headers $headers -Body $body -ContentType application/json
    Write-Host "   [OK] ID: $($r.datos.idUsuario)" -ForegroundColor Green
    $userId = $r.datos.idUsuario
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "POST Usuarios - verificar campos requeridos del DTO"
    $failed++
    $userId = 2
}

# 5. PUT Usuario
Write-Host "`n5. PUT /Usuarios/$userId" -ForegroundColor Yellow
try {
    $body = @{
        nombre = "TestUser_Updated"
        email = "updated$(Get-Random)@test.com"
        id_Departamento = 1
        id_Rol = 3
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Usuarios/$userId" -Method Put -Headers $headers -Body $body -ContentType application/json | Out-Null
    Write-Host "   [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "PUT Usuarios - verificar campos requeridos"
    $failed++
}

# 6. DELETE Usuario
Write-Host "`n6. DELETE /Usuarios/$userId" -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "$Api/Usuarios/$userId" -Method Delete -Headers $headers | Out-Null
    Write-Host "   [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "DELETE Usuarios - implementado"
    $failed++
}

# 7. POST Motivo
Write-Host "`n7. POST /Motivos" -ForegroundColor Yellow
try {
    $body = @{
        descripcion = "Test Motivo $(Get-Random)"
        id_Departamento = 1
    } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Motivos" -Method Post -Headers $headers -Body $body -ContentType application/json
    Write-Host "   [OK] ID: $($r.datos.id)" -ForegroundColor Green
    $motivoId = $r.datos.id
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "POST Motivos - verificar implementacion"
    $failed++
    $motivoId = 1
}

# 8. PUT Motivo
Write-Host "`n8. PUT /Motivos/$motivoId" -ForegroundColor Yellow
try {
    $body = @{
        id = $motivoId
        descripcion = "Updated Motivo $(Get-Random)"
        id_Departamento = 1
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Motivos/$motivoId" -Method Put -Headers $headers -Body $body -ContentType application/json | Out-Null
    Write-Host "   [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "PUT Motivos - verificar implementacion"
    $failed++
}

# 9. POST Departamento
Write-Host "`n9. POST /Departamentos" -ForegroundColor Yellow
try {
    $body = @{
        nombre = "Test Dept $(Get-Random)"
        descripcion = "Test"
    } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Departamentos" -Method Post -Headers $headers -Body $body -ContentType application/json
    Write-Host "   [OK] ID: $($r.datos.id)" -ForegroundColor Green
    $deptId = $r.datos.id
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "POST Departamentos - verificar implementacion"
    $failed++
    $deptId = 1
}

# 10. PUT Departamento
Write-Host "`n10. PUT /Departamentos/$deptId" -ForegroundColor Yellow
try {
    $body = @{
        id = $deptId
        nombre = "Updated Dept $(Get-Random)"
        descripcion = "Updated"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Departamentos/$deptId" -Method Put -Headers $headers -Body $body -ContentType application/json | Out-Null
    Write-Host "   [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "PUT Departamentos - verificar implementacion"
    $failed++
}

# 11. POST Transicion (ruta correcta)
Write-Host "`n11. POST /Tickets/1/Transition" -ForegroundColor Yellow
try {
    $body = @{
        id_Estado_Destino = 2
        comentario = "Test transition"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$Api/Tickets/1/Transition" -Method Post -Headers $headers -Body $body -ContentType application/json | Out-Null
    Write-Host "   [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "POST Transition - verificar validacion de politicas"
    $failed++
}

# 12. GET Aprobaciones (ruta correcta)
Write-Host "`n12. GET /Approvals/Pending" -ForegroundColor Yellow
try {
    $r = Invoke-RestMethod -Uri "$Api/Approvals/Pending" -Headers $headers
    Write-Host "   [OK] $($r.datos.Count) pendientes" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "GET Approvals - implementado"
    $failed++
}

# 13. GET StoredProcedures (ruta correcta)
Write-Host "`n13. GET /api/sp" -ForegroundColor Yellow
try {
    $r = Invoke-RestMethod -Uri "https://localhost:5001/api/sp" -Headers $headers
    Write-Host "   [OK] $($r.datos.Count) SPs" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "GET /api/sp - verificar ruta y autorizacion"
    $failed++
}

# 14. DELETE Ticket
Write-Host "`n14. DELETE /Tickets (crea y elimina)" -ForegroundColor Yellow
try {
    $body = @{
        contenido = "Ticket para eliminar $(Get-Random)"
        id_Prioridad = 1
        id_Departamento = 1
    } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Tickets" -Method Post -Headers $headers -Body $body -ContentType application/json
    $ticketId = $r.datos.id
    Invoke-RestMethod -Uri "$Api/Tickets/$ticketId" -Method Delete -Headers $headers | Out-Null
    Write-Host "   [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "   [FAIL] $($_.Exception.Message)" -ForegroundColor Red
    $details += "DELETE Tickets - verificar implementacion"
    $failed++
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  RESULTADO: $passed/14 funcionan" -ForegroundColor $(if ($passed -ge 10) { "Green" } else { "Yellow" })
Write-Host "============================================`n" -ForegroundColor Cyan

if ($details.Count -gt 0) {
    Write-Host "DETALLES:" -ForegroundColor Yellow
    foreach ($d in $details) {
        Write-Host "  - $d" -ForegroundColor Gray
    }
}
