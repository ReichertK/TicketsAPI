# Script de test completo de API
Write-Host "====== INICIANDO TESTS DE API ======" -ForegroundColor Cyan

# 1. Test de login
Write-Host "`n[1/5] Test Login..." -ForegroundColor Yellow
try {
    $loginBody = '{"usuario":"admin","contraseña":"changeme"}'
    $loginResponse = Invoke-RestMethod -Uri 'https://localhost:5001/api/v1/Auth/login' `
        -Method POST `
        -Body $loginBody `
        -ContentType 'application/json' `
        -SkipCertificateCheck
    
    $token = $loginResponse.datos.token
    Write-Host "✓ Login exitoso. Token obtenido." -ForegroundColor Green
} catch {
    Write-Host "✗ Error en login: $_" -ForegroundColor Red
    exit 1
}

# 2. Test GET /api/v1/Tickets (listar)
Write-Host "`n[2/5] Test GET /api/v1/Tickets..." -ForegroundColor Yellow
try {
    $headers = @{Authorization = "Bearer $token"}
    $tickets = Invoke-RestMethod -Uri 'https://localhost:5001/api/v1/Tickets' `
        -Method GET `
        -Headers $headers `
        -SkipCertificateCheck
    
    Write-Host "✓ GET Tickets exitoso. Total: $($tickets.datos.totalRegistros)" -ForegroundColor Green
} catch {
    Write-Host "✗ Error en GET Tickets: $_" -ForegroundColor Red
}

# 3. Test GET /api/v1/Tickets/{id}
Write-Host "`n[3/5] Test GET /api/v1/Tickets/6..." -ForegroundColor Yellow
try {
    $headers = @{Authorization = "Bearer $token"}
    $ticket = Invoke-RestMethod -Uri 'https://localhost:5001/api/v1/Tickets/6' `
        -Method GET `
        -Headers $headers `
        -SkipCertificateCheck
    
    Write-Host "✓ GET Ticket 6 exitoso." -ForegroundColor Green
    Write-Host "  Título: $($ticket.datos.titulo)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Error en GET Ticket 6: $_" -ForegroundColor Red
}

# 4. Test POST /api/v1/Tickets con FK inválida
Write-Host "`n[4/5] Test POST Ticket con prioridad inválida (debe retornar 400)..." -ForegroundColor Yellow
try {
    $headers = @{
        Authorization = "Bearer $token"
        'Content-Type' = 'application/json'
    }
    $newTicket = @{
        titulo = "Test FK inválida"
        contenido = "Este ticket tiene prioridad inválida"
        id_prioridad = 999
        id_departamento = 1
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri 'https://localhost:5001/api/v1/Tickets' `
        -Method POST `
        -Headers $headers `
        -Body $newTicket `
        -SkipCertificateCheck
    
    Write-Host "✗ POST aceptó FK inválida (esperaba 400)" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✓ POST rechazó FK inválida correctamente (400)" -ForegroundColor Green
    } else {
        Write-Host "✗ Error inesperado: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

# 5. Test GET /api/v1/Referencias/departamentos
Write-Host "`n[5/5] Test GET Departamentos..." -ForegroundColor Yellow
try {
    $headers = @{Authorization = "Bearer $token"}
    $departamentos = Invoke-RestMethod -Uri 'https://localhost:5001/api/v1/Referencias/departamentos' `
        -Method GET `
        -Headers $headers `
        -SkipCertificateCheck
    
    Write-Host "✓ GET Departamentos exitoso. Total: $($departamentos.datos.Count)" -ForegroundColor Green
} catch {
    Write-Host "✗ Error en GET Departamentos: $_" -ForegroundColor Red
}

Write-Host "`n====== TESTS COMPLETADOS ======" -ForegroundColor Cyan
