#!/usr/bin/env pwsh

# Script de pruebas para TicketsAPI

$ApiBase = "https://localhost:5001/api/v1"
$AdminUser = "Admin"
$AdminPassword = "changeme"

# Ignorar certificado SSL
$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true

# Mostrar progreso
Write-Host "========================================" -ForegroundColor Green
Write-Host "PRUEBAS EXHAUSTIVAS TICKETS API" -ForegroundColor Green
Write-Host "Usuario Admin" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# 1. LOGIN
Write-Host "[1/10] Autenticación..." -ForegroundColor Yellow
try {
    $loginResp = Invoke-RestMethod -Uri "$ApiBase/Auth/login" -Method Post `
        -Body (@{usuario="Admin"; contrasena="changeme"} | ConvertTo-Json) `
        -ContentType "application/json" -ErrorAction Stop
    
    if ($loginResp.exitoso) {
        $token = $loginResp.datos.token
        $userId = $loginResp.datos.id_Usuario
        Write-Host "  OK: Login exitoso (Usuario ID: $userId)`n" -ForegroundColor Green
    } else {
        Write-Error "Login falló: $($loginResp.mensaje)"
        exit 1
    }
} catch {
    Write-Error "Error login: $_"
    exit 1
}

$headers = @{"Authorization" = "Bearer $token"}

# 2. GET Tickets
Write-Host "[2/10] GET /Tickets..." -ForegroundColor Yellow
try {
    $res = Invoke-RestMethod -Uri "$ApiBase/Tickets" -Headers $headers -ErrorAction Stop
    Write-Host "  OK: $($res.datos.totalRegistros) tickets encontrados`n" -ForegroundColor Green
} catch {
    Write-Error "Error: $_`n"
}

# 3. CREATE Ticket
Write-Host "[3/10] POST /Tickets (crear)..." -ForegroundColor Yellow
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$body = @{
    contenido = "Test Admin - $ts"
    id_Prioridad = 1
    id_Departamento = 1
    id_Usuario_Asignado = 2
    id_Motivo = 1
} | ConvertTo-Json

$ticketId = $null
try {
    $res = Invoke-RestMethod -Uri "$ApiBase/Tickets" -Method Post -Headers $headers `
        -Body $body -ContentType "application/json" -ErrorAction Stop
    
    if ($res.exitoso) {
        $ticketId = $res.datos.id
        Write-Host "  OK: Ticket creado (ID: $ticketId)`n" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: $($res.mensaje)`n" -ForegroundColor Red
    }
} catch {
    Write-Host "  ERROR: $_`n" -ForegroundColor Red
}

if ($ticketId) {
    # 4. GET Ticket by ID
    Write-Host "[4/10] GET /Tickets/{id} ..." -ForegroundColor Yellow
    try {
        $res = Invoke-RestMethod -Uri "$ApiBase/Tickets/$ticketId" -Headers $headers -ErrorAction Stop
        if ($res.exitoso) {
            Write-Host "  OK: Ticket recuperado`n" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ERROR: $_`n" -ForegroundColor Red
    }
    
    # 5. UPDATE Ticket
    Write-Host "[5/10] PUT /Tickets/{id} (actualizar)..." -ForegroundColor Yellow
    $ts2 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $body2 = @{
        contenido = "ACTUALIZADO - $ts2"
        id_Prioridad = 2
        id_Departamento = 1
        id_Usuario_Asignado = 3
        id_Motivo = 1
    } | ConvertTo-Json
    
    try {
        $res = Invoke-RestMethod -Uri "$ApiBase/Tickets/$ticketId" -Method Put -Headers $headers `
            -Body $body2 -ContentType "application/json" -ErrorAction Stop
        Write-Host "  OK: Ticket actualizado`n" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: $_`n" -ForegroundColor Red
    }
    
    # 6. CHANGE STATE
    Write-Host "[6/10] PATCH /Tickets/{id}/cambiar-estado..." -ForegroundColor Yellow
    $stateBody = @{
        id_Estado_Nuevo = 2
        comentario = "Estado cambiado por test"
    } | ConvertTo-Json
    
    try {
        $res = Invoke-RestMethod -Uri "$ApiBase/Tickets/$ticketId/cambiar-estado" `
            -Method Patch -Headers $headers -Body $stateBody `
            -ContentType "application/json" -ErrorAction Stop
        Write-Host "  OK: Estado cambiado`n" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: $_`n" -ForegroundColor Red
    }
    
    # 7. ADD COMMENT
    Write-Host "[7/10] POST /Tickets/{id}/Comentarios..." -ForegroundColor Yellow
    $ts3 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $comBody = @{comentario = "Test comentario - $ts3"} | ConvertTo-Json
    
    $comId = $null
    try {
        $res = Invoke-RestMethod -Uri "$ApiBase/Tickets/$ticketId/Comentarios" `
            -Method Post -Headers $headers -Body $comBody `
            -ContentType "application/json" -ErrorAction Stop
        if ($res.exitoso) {
            $comId = $res.datos.id
            Write-Host "  OK: Comentario creado (ID: $comId)`n" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ERROR: $_`n" -ForegroundColor Red
    }
    
    # 8. LIST COMMENTS
    Write-Host "[8/10] GET /Tickets/{id}/Comentarios..." -ForegroundColor Yellow
    try {
        $res = Invoke-RestMethod -Uri "$ApiBase/Tickets/$ticketId/Comentarios" `
            -Headers $headers -ErrorAction Stop
        $cnt = if ($res -is [Array]) { $res.Count } else { 1 }
        Write-Host "  OK: $cnt comentarios encontrados`n" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: $_`n" -ForegroundColor Red
    }
    
    # 9. UPDATE COMMENT
    if ($comId) {
        Write-Host "[9/10] PUT /Tickets/{id}/Comentarios/{cid}..." -ForegroundColor Yellow
        $comUpdate = @{comentario = "Comentario actualizado por test"} | ConvertTo-Json
        
        try {
            $res = Invoke-RestMethod -Uri "$ApiBase/Tickets/$ticketId/Comentarios/$comId" `
                -Method Put -Headers $headers -Body $comUpdate `
                -ContentType "application/json" -ErrorAction Stop
            Write-Host "  OK: Comentario actualizado`n" -ForegroundColor Green
        } catch {
            Write-Host "  ERROR: $_`n" -ForegroundColor Red
        }
    }
}

# 10. GET Reference Data
Write-Host "[10/10] GET Datos de Referencia..." -ForegroundColor Yellow
$refData = @("Estados", "Prioridades", "Departamentos", "Motivos")
foreach ($item in $refData) {
    try {
        $res = Invoke-RestMethod -Uri "$ApiBase/$item" -Headers $headers -ErrorAction Stop
        $cnt = $res.datos.Count
        Write-Host "  OK: $item ($cnt registros)" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR $item`: $_" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green
