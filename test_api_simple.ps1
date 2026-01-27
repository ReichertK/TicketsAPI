Write-Host "====== INICIANDO TESTS DE API ======" -ForegroundColor Cyan

Write-Host "`n[1] Test Login..." -ForegroundColor Yellow
$loginBody = '{"usuario":"admin","contraseña":"changeme"}'
$loginResponse = Invoke-RestMethod -Uri 'https://localhost:5001/api/v1/Auth/login' -Method POST -Body $loginBody -ContentType 'application/json' -SkipCertificateCheck
$token = $loginResponse.datos.token
Write-Host "✓ Login exitoso" -ForegroundColor Green

Write-Host "`n[2] Test GET /api/v1/Tickets..." -ForegroundColor Yellow
$headers = @{Authorization = "Bearer $token"}
$tickets = Invoke-RestMethod -Uri 'https://localhost:5001/api/v1/Tickets' -Method GET -Headers $headers -SkipCertificateCheck
Write-Host "✓ Tickets obtenidos: $($tickets.datos.Count)" -ForegroundColor Green

Write-Host "`n[3] Test GET /api/v1/Tickets/6..." -ForegroundColor Yellow
$ticket = Invoke-RestMethod -Uri 'https://localhost:5001/api/v1/Tickets/6' -Method GET -Headers $headers -SkipCertificateCheck
Write-Host "✓ Ticket obtenido: $($ticket.datos.titulo)" -ForegroundColor Green

Write-Host "`n[4] Test POST con FK inválida..." -ForegroundColor Yellow
$newTicket = @{
    titulo = "Test FK"
    contenido = "Test"
    id_prioridad = 999
    id_departamento = 1
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri 'https://localhost:5001/api/v1/Tickets' -Method POST -Headers $headers -Body $newTicket -SkipCertificateCheck -ErrorAction SilentlyContinue

if ($?) {
    Write-Host "✗ POST aceptó FK inválida" -ForegroundColor Red
} else {
    Write-Host "✓ POST rechazó FK inválida" -ForegroundColor Green
}

Write-Host "`n====== TESTS COMPLETADOS ======" -ForegroundColor Cyan
