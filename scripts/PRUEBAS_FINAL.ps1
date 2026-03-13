#!/usr/bin/env powershell
# Script para ejecutar tests en terminal separada

# Esperar un poco para que la API inicie
Start-Sleep -Seconds 2

$ApiUrl = "https://localhost:5001/api/v1"
$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true

Write-Host "`n=== EJECUTANDO PRUEBAS ===" -ForegroundColor Cyan

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
    Write-Host "✓ Login exitoso" -ForegroundColor Green
} catch {
    Write-Host "✗ Login fallido: $_" -ForegroundColor Red
    exit 1
}

# Test endpoints
$tests = @(
    @{name="GET /Tickets"; method="GET"; endpoint="/Tickets"},
    @{name="POST /Tickets"; method="POST"; endpoint="/Tickets"; body=@{contenido="Test nuevo ticket"; id_Prioridad=1; id_Departamento=1; id_Usuario_Asignado=2; id_Motivo=1}},
    @{name="GET /Tickets/1"; method="GET"; endpoint="/Tickets/1"},
    @{name="PUT /Tickets/1"; method="PUT"; endpoint="/Tickets/1"; body=@{contenido="Updated"; id_Prioridad=2; id_Departamento=1; id_Usuario_Asignado=3; id_Motivo=1}},
    @{name="GET /Tickets/1/Comments"; method="GET"; endpoint="/Tickets/1/Comments"},
    @{name="POST /Tickets/1/Comments"; method="POST"; endpoint="/Tickets/1/Comments"; body=@{contenido="Test comentario"}},
    @{name="GET /References/estados"; method="GET"; endpoint="/References/estados"},
    @{name="GET /References/prioridades"; method="GET"; endpoint="/References/prioridades"},
    @{name="GET /References/departamentos"; method="GET"; endpoint="/References/departamentos"},
    @{name="GET /Motivos"; method="GET"; endpoint="/Motivos"},
    @{name="GET /Usuarios"; method="GET"; endpoint="/Usuarios"},
)

$passed = 0
$failed = 0

foreach ($test in $tests) {
    try {
        $params = @{
            Uri = "$ApiUrl$($test.endpoint)"
            Method = $test.method
            Headers = $headers
            ContentType = "application/json"
            ErrorAction = "Stop"
        }
        
        if ($test.body) {
            $params.Body = $test.body | ConvertTo-Json
        }
        
        $resp = Invoke-RestMethod @params
        Write-Host "✓ $($test.name)" -ForegroundColor Green
        $passed++
    } catch {
        $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "?" }
        Write-Host "✗ $($test.name) (Status: $status)" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Pasadas: $passed" -ForegroundColor Green
Write-Host "Fallidas: $failed" -ForegroundColor Red
$total = $passed + $failed
$pct = if ($total -gt 0) { [math]::Round($passed/$total*100, 1) } else { 0 }
Write-Host "Éxito: $pct%`n" -ForegroundColor Yellow

if ($failed -eq 0) {
    Write-Host "✓ TODAS LAS PRUEBAS PASARON" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ ALGUNAS PRUEBAS FALLARON" -ForegroundColor Red
    exit 1
}
# PRUEBAS EXHAUSTIVAS TICKETS API
# Version: 1.0

$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
$ApiUrl = "https://localhost:5001/api/v1"

Write-Host "`n" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host "  PRUEBAS EXHAUSTIVAS - TICKETSAPI" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

$totalTests = 0
$passedTests = 0
$failedTests = 0

function Test-Endpoint {
    param($Name, $Method, $Uri, $Body)
    
    $script:totalTests++
    Write-Host "[$($script:totalTests)] $Name" -ForegroundColor Yellow -NoNewline
    
    try {
        if ($Body) {
            $resp = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers -Body ($Body | ConvertTo-Json) -ContentType "application/json" -ErrorAction Stop
        } else {
            $resp = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers -ErrorAction Stop
        }
        Write-Host " ... OK" -ForegroundColor Green
        $script:passedTests++
        return $resp
    } catch {
        Write-Host " ... ERROR: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        $script:failedTests++
        return $null
    }
}

# ===== LOGIN =====
Write-Host "`n[AUTENTICACIÓN]" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────`n" -ForegroundColor Cyan

Write-Host "[1] Login" -ForegroundColor Yellow -NoNewline
try {
    $loginBody = @{
        usuario = "Admin"
        "Contraseña" = "changeme"
    } | ConvertTo-Json
    
    $loginResp = Invoke-RestMethod -Uri "$ApiUrl/Auth/login" -Method Post -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    
    if ($loginResp.exitoso) {
        $token = $loginResp.datos.token
        $headers = @{"Authorization" = "Bearer $token"}
        $totalTests++
        $passedTests++
        Write-Host " ... OK" -ForegroundColor Green
    } else {
        Write-Host " ... FAIL" -ForegroundColor Red
        $totalTests++
        $failedTests++
        exit 1
    }
} catch {
    Write-Host " ... ERROR: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    exit 1
}

# ===== TICKETS =====
Write-Host "`n[TICKETS]" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────`n" -ForegroundColor Cyan

# GET all
Test-Endpoint "GET /Tickets (listar)" "Get" "$ApiUrl/Tickets" $null | Out-Null

# CREATE
$ticketBody = @{
    contenido = "Test $(Get-Date -Format 'HH:mm:ss')"
    id_Prioridad = 1
    id_Departamento = 1
    id_Usuario_Asignado = 2
    id_Motivo = 1
}
$resp = Test-Endpoint "POST /Tickets (crear)" "Post" "$ApiUrl/Tickets" $ticketBody
$ticketId = $resp.datos.id

if ($ticketId) {
    # GET by ID
    Test-Endpoint "GET /Tickets/{id}" "Get" "$ApiUrl/Tickets/$ticketId" $null | Out-Null
    
    # UPDATE
    $updateBody = @{
        contenido = "ACTUALIZADO"
        id_Prioridad = 2
        id_Departamento = 1
        id_Usuario_Asignado = 3
        id_Motivo = 1
    }
    Test-Endpoint "PUT /Tickets/{id}" "Put" "$ApiUrl/Tickets/$ticketId" $updateBody | Out-Null
    
    # CHANGE STATE
    $stateBody = @{
        id_Estado_Nuevo = 2
        comentario = "Test"
    }
    Test-Endpoint "PATCH cambiar-estado" "Patch" "$ApiUrl/Tickets/$ticketId/cambiar-estado" $stateBody | Out-Null
    
    # ===== COMENTARIOS =====
    Write-Host "`n[COMENTARIOS]" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────`n" -ForegroundColor Cyan
    
    # CREATE
    $comBody = @{comentario = "Test comentario"}
    $resp = Test-Endpoint "POST Comentario" "Post" "$ApiUrl/Tickets/$ticketId/Comentarios" $comBody
    $comId = $resp.datos.id
    
    # LIST
    Test-Endpoint "GET Comentarios" "Get" "$ApiUrl/Tickets/$ticketId/Comentarios" $null | Out-Null
    
    # UPDATE
    if ($comId) {
        $updateComBody = @{comentario = "Actualizado"}
        Test-Endpoint "PUT Comentario" "Put" "$ApiUrl/Tickets/$ticketId/Comentarios/$comId" $updateComBody | Out-Null
    }
}

# ===== DATOS REFERENCIA =====
Write-Host "`n[DATOS DE REFERENCIA]" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────`n" -ForegroundColor Cyan

Test-Endpoint "GET /Estados" "Get" "$ApiUrl/Estados" $null | Out-Null
Test-Endpoint "GET /Prioridades" "Get" "$ApiUrl/Prioridades" $null | Out-Null
Test-Endpoint "GET /Departamentos" "Get" "$ApiUrl/Departamentos" $null | Out-Null
Test-Endpoint "GET /Motivos" "Get" "$ApiUrl/Motivos" $null | Out-Null

# ===== USUARIOS =====
Write-Host "`n[USUARIOS]" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────`n" -ForegroundColor Cyan

Test-Endpoint "GET /Usuarios" "Get" "$ApiUrl/Usuarios" $null | Out-Null
Test-Endpoint "GET perfil-actual" "Get" "$ApiUrl/Usuarios/perfil-actual" $null | Out-Null

# ===== RESUMEN =====
Write-Host "`n════════════════════════════════════════" -ForegroundColor Green
Write-Host "  RESUMEN DE PRUEBAS" -ForegroundColor Green
Write-Host "════════════════════════════════════════`n" -ForegroundColor Green

Write-Host "Total de pruebas: $totalTests" -ForegroundColor White
Write-Host "Exitosas: $passedTests" -ForegroundColor Green
Write-Host "Fallidas: $failedTests" -ForegroundColor $(if($failedTests -eq 0) {"Green"} else {"Red"})

$percentage = if ($totalTests -gt 0) { [math]::Round($passedTests/$totalTests*100, 1) } else { 0 }
Write-Host "Tasa de éxito: $percentage%`n" -ForegroundColor $(if($percentage -eq 100) {"Green"} else {"Yellow"})

if ($failedTests -eq 0) {
    Write-Host "✓ TODAS LAS PRUEBAS PASARON" -ForegroundColor Green
} else {
    Write-Host "✓ LA MAYORIA DE PRUEBAS PASARON" -ForegroundColor Yellow
}

Write-Host "`nFecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "Usuario: Admin (ID: 1)" -ForegroundColor Gray
Write-Host "Sistema: CDK_TKT`n" -ForegroundColor Gray
