#!/usr/bin/env powershell
# PRUEBAS EXHAUSTIVAS TICKETSAPI - USUARIO ADMIN
# ================================================
# Ejecutar: powershell -ExecutionPolicy Bypass -File run_all_tests.ps1

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "PRUEBAS EXHAUSTIVAS - TicketsAPI Admin" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true

# Configuración
$ApiUrl = "https://localhost:5001/api/v1"
$admin_user = "Admin"
$admin_pass = "changeme"

# Contador de pruebas
$total_tests = 0
$passed_tests = 0
$failed_tests = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Body,
        [hashtable]$Headers
    )
    
    $script:total_tests++
    Write-Host "[Test $($script:total_tests)] $Name" -ForegroundColor Yellow
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri "$ApiUrl$Endpoint" -Method $Method -Headers $Headers `
                -Body ($Body | ConvertTo-Json) -ContentType "application/json" -ErrorAction Stop
        } else {
            $response = Invoke-RestMethod -Uri "$ApiUrl$Endpoint" -Method $Method -Headers $Headers `
                -ErrorAction Stop
        }
        
        Write-Host "  ✓ OK - Respuesta recibida" -ForegroundColor Green
        $script:passed_tests++
        return $response
    } catch {
        Write-Host "  ✗ FAILED - $($_.Exception.Message)" -ForegroundColor Red
        $script:failed_tests++
        return $null
    }
}

# ===== AUTENTICACIÓN =====
Write-Host "`n[FASE 1] AUTENTICACIÓN" -ForegroundColor Cyan
Write-Host "─────────────────────────`n" -ForegroundColor Cyan

$loginBody = @{
    usuario = $admin_user
    contrasena = $admin_pass
}

$response = Test-Endpoint "Login" "POST" "/Auth/login" $loginBody @{}

if (-not $response -or -not $response.exitoso) {
    Write-Host "Error: No se pudo obtener token. Abortando..." -ForegroundColor Red
    exit 1
}

$token = $response.datos.token
$userId = $response.datos.id_Usuario
$headers = @{"Authorization" = "Bearer $token"}

Write-Host "  Token obtenido para usuario ID: $userId`n" -ForegroundColor Green

# ===== TICKETS =====
Write-Host "`n[FASE 2] TICKETS - OPERACIONES CRUD" -ForegroundColor Cyan
Write-Host "────────────────────────────────────`n" -ForegroundColor Cyan

# GET all tickets
$response = Test-Endpoint "GET /Tickets" "GET" "/Tickets" $null $headers
if ($response) {
    Write-Host "  Total de tickets: $($response.datos.totalRegistros)`n" -ForegroundColor Green
}

# CREATE ticket
$ticketBody = @{
    contenido = "Test ticket Admin - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    id_Prioridad = 1
    id_Departamento = 1
    id_Usuario_Asignado = 2
    id_Motivo = 1
}

$response = Test-Endpoint "POST /Tickets (crear)" "POST" "/Tickets" $ticketBody $headers
$ticketId = if ($response -and $response.exitoso) { $response.datos.id } else { $null }
if ($ticketId) {
    Write-Host "  Ticket creado con ID: $ticketId`n" -ForegroundColor Green
}

if ($ticketId) {
    # GET by ID
    Test-Endpoint "GET /Tickets/{id}" "GET" "/Tickets/$ticketId" $null $headers | Out-Null
    Write-Host ""
    
    # UPDATE
    $updateBody = @{
        contenido = "ACTUALIZADO - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        id_Prioridad = 2
        id_Departamento = 1
        id_Usuario_Asignado = 3
        id_Motivo = 1
    }
    Test-Endpoint "PUT /Tickets/{id} (actualizar)" "PUT" "/Tickets/$ticketId" $updateBody $headers | Out-Null
    Write-Host ""
    
    # CHANGE STATE
    $stateBody = @{
        id_Estado_Nuevo = 2
        comentario = "Estado cambiado por test"
    }
    Test-Endpoint "PATCH /Tickets/{id}/cambiar-estado" "PATCH" "/Tickets/$ticketId/cambiar-estado" $stateBody $headers | Out-Null
    Write-Host ""
    
    # ===== COMENTARIOS =====
    Write-Host "`n[FASE 3] COMENTARIOS - OPERACIONES CRUD" -ForegroundColor Cyan
    Write-Host "───────────────────────────────────────`n" -ForegroundColor Cyan
    
    # CREATE comment
    $commentBody = @{
        comentario = "Test comentario Admin - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }
    
    $response = Test-Endpoint "POST /Tickets/{id}/Comentarios" "POST" "/Tickets/$ticketId/Comentarios" $commentBody $headers
    $commentId = if ($response -and $response.exitoso) { $response.datos.id } else { $null }
    if ($commentId) {
        Write-Host "  Comentario creado con ID: $commentId`n" -ForegroundColor Green
    }
    
    # LIST comments
    Test-Endpoint "GET /Tickets/{id}/Comentarios" "GET" "/Tickets/$ticketId/Comentarios" $null $headers | Out-Null
    Write-Host ""
    
    # UPDATE comment
    if ($commentId) {
        $updateCommentBody = @{
            comentario = "Comentario ACTUALIZADO por test"
        }
        Test-Endpoint "PUT /Tickets/{id}/Comentarios/{cid}" "PUT" "/Tickets/$ticketId/Comentarios/$commentId" $updateCommentBody $headers | Out-Null
        Write-Host ""
    }
}

# ===== DATOS DE REFERENCIA =====
Write-Host "`n[FASE 4] DATOS DE REFERENCIA" -ForegroundColor Cyan
Write-Host "──────────────────────────────`n" -ForegroundColor Cyan

$refData = @("Estados", "Prioridades", "Departamentos", "Motivos")
foreach ($item in $refData) {
    Test-Endpoint "GET /$item" "GET" "/$item" $null $headers | Out-Null
}
Write-Host ""

# ===== USUARIOS =====
Write-Host "`n[FASE 5] USUARIOS" -ForegroundColor Cyan
Write-Host "──────────────────`n" -ForegroundColor Cyan

Test-Endpoint "GET /Usuarios" "GET" "/Usuarios" $null $headers | Out-Null
Write-Host ""

Test-Endpoint "GET /Usuarios/perfil-actual" "GET" "/Usuarios/perfil-actual" $null $headers | Out-Null
Write-Host ""

# ===== RESUMEN =====
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "RESUMEN DE PRUEBAS" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Total de pruebas: $script:total_tests" -ForegroundColor White
Write-Host "Exitosas: $script:passed_tests" -ForegroundColor Green
Write-Host "Fallidas: $script:failed_tests" -ForegroundColor $(if($script:failed_tests -eq 0) {"Green"} else {"Red"})

$percentage = if ($script:total_tests -gt 0) { [math]::Round($script:passed_tests/$script:total_tests*100, 1) } else { 0 }
Write-Host "Tasa de éxito: $percentage%`n" -ForegroundColor $(if($percentage -eq 100) {"Green"} else {"Yellow"})

if ($script:failed_tests -eq 0) {
    Write-Host "✓ TODAS LAS PRUEBAS PASARON EXITOSAMENTE" -ForegroundColor Green
} else {
    Write-Host "✗ Algunas pruebas fallaron. Revise los errores arriba." -ForegroundColor Red
}

Write-Host "`nFecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "Usuario: Admin (ID: 1)" -ForegroundColor Gray
Write-Host "Sistema: CDK_TKT`n" -ForegroundColor Gray
