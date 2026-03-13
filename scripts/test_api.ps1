#!/usr/bin/env powershell
# Script de pruebas simple

$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
$ApiUrl = "https://localhost:5001/api/v1"

Write-Host "`n=== PRUEBAS API TICKETSAPI ===" -ForegroundColor Cyan

# Login
Write-Host "`n[LOGIN]" -ForegroundColor Yellow
try {
    $loginBody = @{
        usuario = "Admin"
        "Contraseña" = "changeme"
    } | ConvertTo-Json
    
    $loginResp = Invoke-RestMethod -Uri "$ApiUrl/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResp.datos.token
    $headers = @{"Authorization" = "Bearer $token"}
    Write-Host "[OK] Login exitoso" -ForegroundColor Green
    $passed = 1
} catch {
    Write-Host "[ERROR] Login fallido: $($_)" -ForegroundColor Red
    exit 1
}

# Test 1: GET /Tickets
Write-Host "`n[1] GET /Tickets" -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$ApiUrl/Tickets" -Method Get -Headers $headers
    Write-Host "[OK] GET /Tickets" -ForegroundColor Green
    $passed++
} catch {
    $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "?" }
    Write-Host "[FALLO] GET /Tickets - Status: $status" -ForegroundColor Red
}

# Test 2: GET /References/estados
Write-Host "`n[2] GET /References/estados" -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$ApiUrl/References/estados" -Method Get -Headers $headers
    Write-Host "[OK] GET /References/estados" -ForegroundColor Green
    $passed++
} catch {
    $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "?" }
    Write-Host "[FALLO] GET /References/estados - Status: $status" -ForegroundColor Red
}

# Test 3: GET /References/prioridades
Write-Host "`n[3] GET /References/prioridades" -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$ApiUrl/References/prioridades" -Method Get -Headers $headers
    Write-Host "[OK] GET /References/prioridades" -ForegroundColor Green
    $passed++
} catch {
    $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "?" }
    Write-Host "[FALLO] GET /References/prioridades - Status: $status" -ForegroundColor Red
}

# Test 4: GET /References/departamentos
Write-Host "`n[4] GET /References/departamentos" -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$ApiUrl/References/departamentos" -Method Get -Headers $headers
    Write-Host "[OK] GET /References/departamentos" -ForegroundColor Green
    $passed++
} catch {
    $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "?" }
    Write-Host "[FALLO] GET /References/departamentos - Status: $status" -ForegroundColor Red
}

# Test 5: GET /Motivos
Write-Host "`n[5] GET /Motivos" -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$ApiUrl/Motivos" -Method Get -Headers $headers
    Write-Host "[OK] GET /Motivos" -ForegroundColor Green
    $passed++
} catch {
    $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "?" }
    Write-Host "[FALLO] GET /Motivos - Status: $status" -ForegroundColor Red
}

# Test 6: GET /Usuarios
Write-Host "`n[6] GET /Usuarios" -ForegroundColor Yellow
try {
    $resp = Invoke-RestMethod -Uri "$ApiUrl/Usuarios" -Method Get -Headers $headers
    Write-Host "[OK] GET /Usuarios" -ForegroundColor Green
    $passed++
} catch {
    $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "?" }
    Write-Host "[FALLO] GET /Usuarios - Status: $status" -ForegroundColor Red
}

# Test 7: POST /Tickets
Write-Host "`n[7] POST /Tickets" -ForegroundColor Yellow
try {
    $ticketBody = @{
        contenido = "Test ticket"
        id_Prioridad = 1
        id_Departamento = 1
        id_Usuario_Asignado = 2
        id_Motivo = 1
    } | ConvertTo-Json
    
    $resp = Invoke-RestMethod -Uri "$ApiUrl/Tickets" -Method Post -Headers $headers -Body $ticketBody -ContentType "application/json"
    Write-Host "[OK] POST /Tickets" -ForegroundColor Green
    $passed++
} catch {
    $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "?" }
    Write-Host "[FALLO] POST /Tickets - Status: $status" -ForegroundColor Red
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Pruebas: $passed/7" -ForegroundColor Green
Write-Host ""
