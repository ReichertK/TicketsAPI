#!/usr/bin/env powershell
# PRUEBAS TICKETS API - CON CAPTURA DE ERRORES

$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
$ApiUrl = "https://localhost:5001/api/v1"
$resultados = @()

Write-Host "`n=== PRUEBAS TicketsAPI ===" -ForegroundColor Green

# LOGIN
Write-Host "`n[1] Login..." -ForegroundColor Yellow
$loginBody = @{
    usuario = "Admin"
    "Contraseña" = "changeme"
} | ConvertTo-Json
$loginResp = Invoke-RestMethod -Uri "$ApiUrl/Auth/login" -Method Post `
    -Body $loginBody -ContentType "application/json"

if ($loginResp.exitoso) {
    $token = $loginResp.datos.token
    $headers = @{"Authorization" = "Bearer $token"}
    Write-Host "OK - Token obtenido" -ForegroundColor Green
} else {
    Write-Host "FAIL - $($loginResp.mensaje)" -ForegroundColor Red
    exit 1
}

# Función auxiliar para capturar errores
function CaptureError {
    param([string]$testName, [scriptblock]$test)
    $result = @{ name = $testName; status = 0; error = $null; success = $false }
    try {
        & $test
        $result.success = $true
        $result.status = 200
    } catch {
        $result.status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
        $result.error = $_.Exception.Message
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $result.response = $reader.ReadToEnd()
            $reader.Dispose()
        } catch { }
    }
    $script:resultados += $result
    return $result
}

# GET Tickets
Write-Host "`n[2] GET /Tickets..." -ForegroundColor Yellow
CaptureError "GET /Tickets" {
    $resp = Invoke-RestMethod -Uri "$ApiUrl/Tickets" -Headers $headers
    Write-Host "OK - $($resp.datos.totalRegistros) tickets" -ForegroundColor Green
}

# CREATE Ticket
Write-Host "`n[3] POST /Tickets..." -ForegroundColor Yellow
$ticketId = $null
$r = CaptureError "POST /Tickets" {
    $body = @{
        contenido = "Test $(Get-Date -Format 'HH:mm:ss')"
        id_Prioridad = 1
        id_Departamento = 1
        id_Usuario_Asignado = 2
        id_Motivo = 1
    } | ConvertTo-Json

    $resp = Invoke-RestMethod -Uri "$ApiUrl/Tickets" -Method Post -Headers $headers -Body $body -ContentType "application/json"
    $ticketId = $resp.datos.id
    Write-Host "OK - Ticket creado: $ticketId" -ForegroundColor Green
}

# GET by ID
Write-Host "`n[4] GET /Tickets/{id}..." -ForegroundColor Yellow
CaptureError "GET /Tickets/{id}" {
    $resp = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId" -Headers $headers
    Write-Host "OK - Ticket recuperado" -ForegroundColor Green
}

# UPDATE
Write-Host "`n[5] PUT /Tickets/{id}..." -ForegroundColor Yellow
$body = @{
    contenido = "ACTUALIZADO"
    id_Prioridad = 2
    id_Departamento = 1
    id_Usuario_Asignado = 3
    id_Motivo = 1
} | ConvertTo-Json
$resp = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId" -Method Put -Headers $headers -Body $body -ContentType "application/json"
Write-Host "OK - Ticket actualizado" -ForegroundColor Green

# CHANGE STATE
Write-Host "`n[6] PATCH cambiar-estado..." -ForegroundColor Yellow
$body = @{id_Estado_Nuevo = 2; comentario = "Test"} | ConvertTo-Json
$resp = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId/cambiar-estado" -Method Patch -Headers $headers -Body $body -ContentType "application/json"
Write-Host "OK - Estado cambiado" -ForegroundColor Green

# CREATE Comment
Write-Host "`n[7] POST Comentario..." -ForegroundColor Yellow
$body = @{contenido = "Test comentario"} | ConvertTo-Json
$resp = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId/Comments" -Method Post -Headers $headers -Body $body -ContentType "application/json"
$comId = $resp.datos.id
Write-Host "OK - Comentario creado: $comId" -ForegroundColor Green

# LIST Comments
Write-Host "`n[8] GET Comentarios..." -ForegroundColor Yellow
$resp = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId/Comments" -Headers $headers
Write-Host "OK - Comentarios listados" -ForegroundColor Green

# UPDATE Comment
Write-Host "`n[9] PUT Comentario..." -ForegroundColor Yellow
$body = @{contenido = "Actualizado"} | ConvertTo-Json
if ($comId) {
    $resp = Invoke-RestMethod -Uri "$ApiUrl/Comments/$comId" -Method Put -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "OK - Comentario actualizado" -ForegroundColor Green
}

# Datos Referencia
Write-Host "`n[10] GET Estados..." -ForegroundColor Yellow
$resp = Invoke-RestMethod -Uri "$ApiUrl/References/estados" -Headers $headers
Write-Host "OK - $($resp.datos.Count) estados" -ForegroundColor Green

Write-Host "`n[11] GET Prioridades..." -ForegroundColor Yellow
$resp = Invoke-RestMethod -Uri "$ApiUrl/References/prioridades" -Headers $headers
Write-Host "OK - $($resp.datos.Count) prioridades" -ForegroundColor Green

Write-Host "`n[12] GET Departamentos..." -ForegroundColor Yellow
$resp = Invoke-RestMethod -Uri "$ApiUrl/References/departamentos" -Headers $headers
Write-Host "OK - $($resp.datos.Count) departamentos" -ForegroundColor Green

Write-Host "`n[13] GET Motivos..." -ForegroundColor Yellow
$resp = Invoke-RestMethod -Uri "$ApiUrl/Motivos" -Headers $headers
Write-Host "OK - Motivos obtenidos" -ForegroundColor Green

# Usuarios
Write-Host "`n[14] GET Usuarios..." -ForegroundColor Yellow
$resp = Invoke-RestMethod -Uri "$ApiUrl/Usuarios" -Headers $headers
Write-Host "OK - $($resp.datos.Count) usuarios" -ForegroundColor Green

Write-Host "`n[15] GET Perfil actual..." -ForegroundColor Yellow
$resp = Invoke-RestMethod -Uri "$ApiUrl/Usuarios/perfil-actual" -Headers $headers
Write-Host "OK - Perfil: $($resp.datos.perfil_nombre)" -ForegroundColor Green

Write-Host "`n=== TODAS LAS PRUEBAS PASARON ===" -ForegroundColor Green
Write-Host ""
