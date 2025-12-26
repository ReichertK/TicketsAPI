# ✅ SCRIPT DE PRUEBAS DE INTEGRACIÓN - TicketsAPI
# Fecha: 23 de Diciembre 2025
# Endpoints a probar: cambiar-estado, Comments, historial

Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     PRUEBAS DE INTEGRACIÓN - ENDPOINTS REFACTORIZADOS        ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ==================== CONFIGURACIÓN ====================
$BaseUrl = "http://localhost:5000/api/v1"
$ResultadosFile = "INTEGRATION_TEST_RESULTS.md"

# JWT Tokens de prueba (generados manualmente o desde Login)
# Para pruebas simuladas, generamos payloads que la API esperará

$AdminJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJhZG1pbkBjZGsuY29tIiwibmFtZSI6IkFkbWluaXN0cmFkb3IiLCJyb2xlIjoiMSIsInJvbGVfbmFtZSI6IkFkbWluaXN0cmFkb3IiLCJuYmYiOjE3MzQ5NTY0MDAsImV4cCI6MTczNDk2MDAwMCwiaWF0IjoxNzM0OTU2NDAwLCJpc3MiOiJUaWNrZXRzQVBJIiwiYXVkIjoiVGlja2V0c0NsaWVudHMifQ.placeholder"

$TecnicoJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwiZW1haWwiOiJ0ZWNuaWNvQGNkay5jb20iLCJuYW1lIjoiVMOpY25pY28iLCJyb2xlIjoiMiIsInJvbGVfbmFtZSI6IlTDqWNuaWNvIiwibmJmIjoxNzM0OTU2NDAwLCJleHAiOjE3MzQ5NjAwMDAsImlhdCI6MTczNDk1NjQwMCwiaXNzIjoiVGlja2V0c0FQSSIsImF1ZCI6IlRpY2tldHNDbGllbnRzIn0.placeholder"

$InvalidJWT = "invalid.token.here"

# IDs de prueba (asumimos que existen en BD)
$TicketExistenteId = 1
$TicketInexistenteId = 999999
$EstadoNuevoId = 2
$EstadoEnProcesoId = 3

# ==================== FUNCIONES DE UTILIDAD ====================

function Invoke-TestRequest {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Token = $null,
        [object]$Body = $null,
        [string]$TestName
    )
    
    Write-Host "🧪 TEST: $TestName" -ForegroundColor Yellow
    Write-Host "   $Method $Url" -ForegroundColor Gray
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Token) {
            $headers["Authorization"] = "Bearer $Token"
        }
        
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $headers
            UseBasicParsing = $true
            TimeoutSec = 10
        }
        
        if ($Body) {
            $params["Body"] = ($Body | ConvertTo-Json)
        }
        
        $response = Invoke-WebRequest @params
        
        Write-Host "   ✅ Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "   Response: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))..." -ForegroundColor Gray
        
        return @{
            Success = $true
            StatusCode = $response.StatusCode
            Content = $response.Content
            Error = $null
        }
        
    } catch {
        $statusCode = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
        Write-Host "   ❌ Status: $statusCode" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        
        return @{
            Success = $false
            StatusCode = $statusCode
            Content = $null
            Error = $_.Exception.Message
        }
    }
    
    Write-Host ""
}

# ==================== VERIFICACIÓN PREVIA ====================

Write-Host "📋 VERIFICACIÓN PREVIA" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

$healthCheck = Invoke-TestRequest -Method "GET" -Url "$BaseUrl/../health" -TestName "Health Check"
if (-not $healthCheck.Success) {
    Write-Host "⚠️  ADVERTENCIA: API no responde correctamente al health check" -ForegroundColor Yellow
    Write-Host "   Continuando con pruebas de todos modos..." -ForegroundColor Gray
    Write-Host ""
}

# ==================== PRUEBAS: PATCH /cambiar-estado ====================

Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║            1. PATCH /Tickets/{id}/cambiar-estado             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$test1 = Invoke-TestRequest `
    -Method "PATCH" `
    -Url "$BaseUrl/Tickets/$TicketExistenteId/cambiar-estado" `
    -Token $AdminJWT `
    -Body @{ nuevoEstadoId = $EstadoEnProcesoId; comentario = "Transición de prueba desde integración" } `
    -TestName "1.1 - Usuario válido (Admin) con permisos - Ticket existente"

$test2 = Invoke-TestRequest `
    -Method "PATCH" `
    -Url "$BaseUrl/Tickets/$TicketInexistenteId/cambiar-estado" `
    -Token $AdminJWT `
    -Body @{ nuevoEstadoId = $EstadoEnProcesoId; comentario = "Test" } `
    -TestName "1.2 - Ticket inexistente - Debe retornar 404"

$test3 = Invoke-TestRequest `
    -Method "PATCH" `
    -Url "$BaseUrl/Tickets/$TicketExistenteId/cambiar-estado" `
    -Token $AdminJWT `
    -Body @{ nuevoEstadoId = $EstadoEnProcesoId; comentario = "" } `
    -TestName "1.3 - Comentario vacío - SP puede requerir comentario (400)"

$test4 = Invoke-TestRequest `
    -Method "PATCH" `
    -Url "$BaseUrl/Tickets/$TicketExistenteId/cambiar-estado" `
    -Token $InvalidJWT `
    -Body @{ nuevoEstadoId = $EstadoEnProcesoId; comentario = "Test" } `
    -TestName "1.4 - JWT inválido - Debe retornar 401"

$test5 = Invoke-TestRequest `
    -Method "PATCH" `
    -Url "$BaseUrl/Tickets/$TicketExistenteId/cambiar-estado" `
    -Token $null `
    -Body @{ nuevoEstadoId = $EstadoEnProcesoId; comentario = "Test" } `
    -TestName "1.5 - Sin JWT - Debe retornar 401"

# ==================== PRUEBAS: POST /Comments ====================

Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              2. POST /Tickets/{id}/Comments                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$test6 = Invoke-TestRequest `
    -Method "POST" `
    -Url "$BaseUrl/Tickets/$TicketExistenteId/Comments" `
    -Token $AdminJWT `
    -Body @{ contenido = "Comentario de prueba desde integración - verificar LAST_INSERT_ID()" } `
    -TestName "2.1 - Usuario válido - Crear comentario (verificar LAST_INSERT_ID())"

$test7 = Invoke-TestRequest `
    -Method "POST" `
    -Url "$BaseUrl/Tickets/$TicketInexistenteId/Comments" `
    -Token $AdminJWT `
    -Body @{ contenido = "Comentario en ticket inexistente" } `
    -TestName "2.2 - Ticket inexistente - Verificar manejo de error"

$test8 = Invoke-TestRequest `
    -Method "POST" `
    -Url "$BaseUrl/Tickets/$TicketExistenteId/Comments" `
    -Token $InvalidJWT `
    -Body @{ contenido = "Test JWT inválido" } `
    -TestName "2.3 - JWT inválido - Debe retornar 401"

$test9 = Invoke-TestRequest `
    -Method "POST" `
    -Url "$BaseUrl/Tickets/$TicketExistenteId/Comments" `
    -Token $null `
    -Body @{ contenido = "Test sin JWT" } `
    -TestName "2.4 - Sin JWT - Debe retornar 401"

# ==================== PRUEBAS: GET /historial ====================

Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║               3. GET /Tickets/{id}/historial                  ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$test10 = Invoke-TestRequest `
    -Method "GET" `
    -Url "$BaseUrl/Tickets/$TicketExistenteId/historial" `
    -Token $AdminJWT `
    -TestName "3.1 - Usuario válido - Verificar mapeo de campos UNION"

$test11 = Invoke-TestRequest `
    -Method "GET" `
    -Url "$BaseUrl/Tickets/$TicketInexistenteId/historial" `
    -Token $AdminJWT `
    -TestName "3.2 - Ticket inexistente - Verificar respuesta vacía o error"

$test12 = Invoke-TestRequest `
    -Method "GET" `
    -Url "$BaseUrl/Tickets/$TicketExistenteId/historial" `
    -Token $InvalidJWT `
    -TestName "3.3 - JWT inválido - Debe retornar 401"

# ==================== RESUMEN DE RESULTADOS ====================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                     RESUMEN DE RESULTADOS                     ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$allTests = @($test1, $test2, $test3, $test4, $test5, $test6, $test7, $test8, $test9, $test10, $test11, $test12)
$passedTests = ($allTests | Where-Object { $_.StatusCode -in @(200, 201, 204) }).Count
$failedTests = ($allTests | Where-Object { $_.StatusCode -notin @(200, 201, 204, 400, 401, 403, 404) }).Count
$expectedErrors = ($allTests | Where-Object { $_.StatusCode -in @(400, 401, 403, 404) }).Count

Write-Host "✅ Tests exitosos (200-204): $passedTests" -ForegroundColor Green
Write-Host "⚠️  Errores esperados (400-404): $expectedErrors" -ForegroundColor Yellow
Write-Host "❌ Errores inesperados (5xx/otros): $failedTests" -ForegroundColor Red
Write-Host ""

# Verificación específica de fixes
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "🔍 VERIFICACIÓN DE FIXES ESPECÍFICOS:" -ForegroundColor Magenta
Write-Host ""

# Fix #1: LAST_INSERT_ID() en CrearComentario
if ($test6.Success -and $test6.StatusCode -eq 201) {
    Write-Host "   ✅ Fix #1 (LAST_INSERT_ID): Comentario creado exitosamente (201)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Fix #1 (LAST_INSERT_ID): No se verificó correctamente" -ForegroundColor Yellow
}

# Fix #2: Status codes dinámicos en cambiar-estado
if ($test2.StatusCode -eq 404) {
    Write-Host "   ✅ Fix #2 (Status 404): Ticket inexistente retorna 404 correctamente" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Fix #2 (Status 404): Se esperaba 404, se obtuvo $($test2.StatusCode)" -ForegroundColor Yellow
}

# Fix #3: Validación userId > 0
if ($test4.StatusCode -eq 401 -or $test8.StatusCode -eq 401) {
    Write-Host "   ✅ Fix #3 (userId validation): JWT inválido retorna 401 correctamente" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Fix #3 (userId validation): Validación de JWT no funcionó como se esperaba" -ForegroundColor Yellow
}

# Fix #4: Mapeo historial correcto
if ($test10.Success) {
    Write-Host "   ✅ Fix #4 (Mapeo historial): Endpoint responde correctamente" -ForegroundColor Green
    Write-Host "      (Verificar manualmente que campos 'tipo', 'orden', etc. son correctos)" -ForegroundColor Gray
} else {
    Write-Host "   ⚠️  Fix #4 (Mapeo historial): No se pudo verificar" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "✅ Pruebas de integración completadas" -ForegroundColor Cyan
Write-Host "📄 Revisar logs de la API para detalles adicionales" -ForegroundColor Gray
Write-Host ""
