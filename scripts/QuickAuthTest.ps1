$ErrorActionPreference = 'Stop'
$base = 'http://localhost:5000/api/v1'
$loginBody = @{ Usuario = 'Admin'; Contraseña = 'changeme' } | ConvertTo-Json
Write-Host "POST $base/Auth/login" -ForegroundColor Cyan
$login = Invoke-RestMethod -Method POST -Uri "$base/Auth/login" -ContentType 'application/json' -Body $loginBody
$token = $login.datos.token
if (-not $token) { Write-Error 'No se obtuvo token' }
Write-Host ("Token OK: " + $token.Substring(0,20) + '...') -ForegroundColor Green
$headers = @{ Authorization = "Bearer $token" }
Write-Host "GET $base/Tickets/1/transiciones-permitidas" -ForegroundColor Cyan
$t1 = Invoke-RestMethod -Method GET -Uri "$base/Tickets/1/transiciones-permitidas" -Headers $headers
Write-Host ("Transiciones count=" + ($t1.datos | Measure-Object | Select-Object -ExpandProperty Count)) -ForegroundColor Green
Write-Host "POST $base/Grupos" -ForegroundColor Cyan
try {
  $grpBody = @{ Id_Grupo = 0; Tipo_Grupo = 'QA-Integracion' } | ConvertTo-Json
  $resp = Invoke-WebRequest -Method POST -Uri "$base/Grupos" -Headers $headers -ContentType 'application/json' -Body $grpBody -UseBasicParsing
  Write-Host ("Crear Grupo status: " + [int]$resp.StatusCode) -ForegroundColor Green
} catch {
  $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
  Write-Host ("Crear Grupo fallo con status: $code") -ForegroundColor Yellow
}