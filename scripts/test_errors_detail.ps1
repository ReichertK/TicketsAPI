$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
$Api = 'https://localhost:5001/api/v1'
$passed = 0
$failed = 0
$errors = @()

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  PRUEBAS DETALLADAS - USUARIO ADMIN" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# LOGIN
Write-Host "[AUTH] Login..." -ForegroundColor Yellow
try {
    $login = Invoke-RestMethod -Uri "$Api/Auth/login" -Method Post -Body (@{usuario='Admin'; 'Contraseña'='changeme'} | ConvertTo-Json) -ContentType application/json
    $token = $login.datos.token
    $headers = @{"Authorization" = "Bearer $token"}
    Write-Host "  [OK]" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "  [FAIL] $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n[COMENTARIOS] POST /Tickets/1/Comments" -ForegroundColor Yellow
try {
    $newComment = @{contenido = "Test comment"} | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Tickets/1/Comments" -Method Post -Headers $headers -Body $newComment -ContentType application/json
    Write-Host "  [OK] ID: $($r.datos.id)" -ForegroundColor Green
    $passed++
} catch {
    $err = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "  [FAIL] $($err.mensaje)" -ForegroundColor Red
    $errors += "POST Comments: $($err.errores -join ', ')"
    $failed++
}

Write-Host "`n[USUARIOS] POST /Usuarios" -ForegroundColor Yellow
try {
    $newUser = @{
        nombre = "TestUser"
        email = "test@test.com"
        password = "test123"
        id_Departamento = 1
    } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Usuarios" -Method Post -Headers $headers -Body $newUser -ContentType application/json
    Write-Host "  [OK] ID: $($r.datos.id_Usuario)" -ForegroundColor Green
    $passed++
} catch {
    $err = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "  [FAIL] $($err.mensaje)" -ForegroundColor Red
    $errors += "POST Usuarios: $($err.errores -join ', ')"
    $failed++
}

Write-Host "`n[MOTIVOS] POST /Motivos" -ForegroundColor Yellow
try {
    $newMotivo = @{
        descripcion = "Test Motivo"
        id_Departamento = 1
    } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Motivos" -Method Post -Headers $headers -Body $newMotivo -ContentType application/json
    Write-Host "  [OK] ID: $($r.datos.id)" -ForegroundColor Green
    $passed++
} catch {
    $err = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "  [FAIL] $($err.mensaje)" -ForegroundColor Red
    $errors += "POST Motivos: $($err.errores -join ', ')"
    $failed++
}

Write-Host "`n[DEPARTAMENTOS] POST /Departamentos" -ForegroundColor Yellow
try {
    $newDept = @{
        nombre = "Test Dept"
        descripcion = "Test"
    } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Departamentos" -Method Post -Headers $headers -Body $newDept -ContentType application/json
    Write-Host "  [OK] ID: $($r.datos.id)" -ForegroundColor Green
    $passed++
} catch {
    $err = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "  [FAIL] $($err.mensaje)" -ForegroundColor Red
    $errors += "POST Departamentos: $($err.errores -join ', ')"
    $failed++
}

Write-Host "`n[TRANSICIONES] POST /Transiciones" -ForegroundColor Yellow
try {
    $transition = @{
        id_Ticket = 1
        id_Estado_Destino = 2
        comentario = "Test transition"
    } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$Api/Transiciones" -Method Post -Headers $headers -Body $transition -ContentType application/json
    Write-Host "  [OK]" -ForegroundColor Green
    $passed++
} catch {
    $err = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "  [FAIL] $($err.mensaje)" -ForegroundColor Red
    $errors += "POST Transiciones: $($err.errores -join ', ')"
    $failed++
}

Write-Host "`n[APROBACIONES] GET /Aprobaciones/pendientes" -ForegroundColor Yellow
try {
    $r = Invoke-RestMethod -Uri "$Api/Aprobaciones/pendientes" -Headers $headers
    Write-Host "  [OK]" -ForegroundColor Green
    $passed++
} catch {
    $err = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "  [FAIL] $($err.mensaje)" -ForegroundColor Red
    $errors += "GET Aprobaciones: $($err.errores -join ', ')"
    $failed++
}

Write-Host "`n[STORED PROCEDURES] GET /StoredProcedures" -ForegroundColor Yellow
try {
    $r = Invoke-RestMethod -Uri "$Api/StoredProcedures" -Headers $headers
    Write-Host "  [OK]" -ForegroundColor Green
    $passed++
} catch {
    $err = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "  [FAIL] $($err.mensaje)" -ForegroundColor Red
    $errors += "GET StoredProcedures: $($err.errores -join ', ')"
    $failed++
}

Write-Host "`n[DELETE] DELETE /Tickets/33" -ForegroundColor Yellow
try {
    $r = Invoke-RestMethod -Uri "$Api/Tickets/33" -Method Delete -Headers $headers
    Write-Host "  [OK]" -ForegroundColor Green
    $passed++
} catch {
    $err = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "  [FAIL] $($err.mensaje)" -ForegroundColor Red
    $errors += "DELETE Tickets: $($err.errores -join ', ')"
    $failed++
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  RESUMEN: $passed/$($passed+$failed) exitosas" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
Write-Host "============================================`n" -ForegroundColor Cyan

if ($errors.Count -gt 0) {
    Write-Host "ERRORES ENCONTRADOS:" -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "  - $e" -ForegroundColor Red
    }
    Write-Host ""
}
