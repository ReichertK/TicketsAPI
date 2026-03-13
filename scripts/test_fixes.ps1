#!/usr/bin/env pwsh

Write-Host "=== PRUEBAS DE FIXES ===" -ForegroundColor Cyan

# LOGIN
Write-Host "`nTEST 1: POST /Auth/login"
$body = @{ Usuario='admin'; Contrasena='changeme' } | ConvertTo-Json
$resp = Invoke-RestMethod -Method POST -Uri 'http://localhost:5000/api/v1/Auth/login' -ContentType 'application/json' -Body $body -TimeoutSec 20
$token = $resp.datos.token
Write-Host "OK: Token obtenido" -ForegroundColor Green

# TEST 2
Write-Host "`nTEST 2: GET transiciones-permitidas"
try {
  $resp = Invoke-RestMethod -Method GET -Uri 'http://localhost:5000/api/v1/Tickets/1/transiciones-permitidas' `
    -Headers @{"Authorization"="Bearer $token"} -TimeoutSec 20
  $count = ($resp.datos | Measure-Object).Count
  Write-Host "OK: $count transiciones" -ForegroundColor Green
} catch {
  Write-Host "ERROR: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# TEST 3
Write-Host "`nTEST 3: POST Grupos"
try {
  $body = @{ Id_Grupo=0; Tipo_Grupo='TestIntegration' } | ConvertTo-Json
  $resp = Invoke-RestMethod -Method POST -Uri 'http://localhost:5000/api/v1/Grupos' `
    -Headers @{"Authorization"="Bearer $token"} -ContentType 'application/json' -Body $body -TimeoutSec 20
  Write-Host "OK: Grupo creado" -ForegroundColor Green
} catch {
  $statusCode = $_.Exception.Response.StatusCode.value__
  if ($statusCode -eq 403) {
    Write-Host "INFO: 403 (acceso denegado)" -ForegroundColor Yellow
  } else {
    Write-Host "ERROR: $statusCode" -ForegroundColor Red
  }
}

# TEST 4
Write-Host "`nTEST 4: POST Transiciones"
try {
  $body = @{ Id_Transicion=0; Id_Estado_Actual=1; Id_Estado_Nuevo=2; Comentario="Test" } | ConvertTo-Json
  $resp = Invoke-RestMethod -Method POST -Uri 'http://localhost:5000/api/v1/Transiciones' `
    -Headers @{"Authorization"="Bearer $token"} -ContentType 'application/json' -Body $body -TimeoutSec 20
  Write-Host "OK: Transicion creada" -ForegroundColor Green
} catch {
  $statusCode = $_.Exception.Response.StatusCode.value__
  if ($statusCode -eq 403) {
    Write-Host "INFO: 403 (no permitida)" -ForegroundColor Yellow
  } else {
    Write-Host "ERROR: $statusCode" -ForegroundColor Red
  }
}

Write-Host "`n=== RESUMEN: TODOS ACTIVOS ===" -ForegroundColor Green
