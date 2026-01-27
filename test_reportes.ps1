# Test de endpoints de reportes
# Ejecutar después de iniciar la API: dotnet run --project TicketsAPI

$baseUrl = "https://localhost:7046/api/v1"

# 1. Login para obtener token
Write-Host "`n=== 1. Login ===" -ForegroundColor Cyan
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/Auth/login" -Method Post -ContentType "application/json" -Body (@{
    usuario = "admin"
    contraseña = "admin123"
} | ConvertTo-Json)

$token = $loginResponse.datos.token
Write-Host "Token obtenido: $($token.Substring(0, 20))..." -ForegroundColor Green

$headers = @{
    "Authorization" = "Bearer $token"
}

# 2. Test Dashboard
Write-Host "`n=== 2. Dashboard ===" -ForegroundColor Cyan
try {
    $dashboard = Invoke-RestMethod -Uri "$baseUrl/Reportes/Dashboard" -Method Get -Headers $headers
    Write-Host "✅ Dashboard obtenido:" -ForegroundColor Green
    Write-Host "   Total tickets: $($dashboard.datos.ticketsTotal)"
    Write-Host "   Tickets abiertos: $($dashboard.datos.ticketsAbiertos)"
    Write-Host "   Tickets cerrados: $($dashboard.datos.ticketsCerrados)"
    Write-Host "   Tiempo promedio: $($dashboard.datos.tiempoPromedioResolucion)h"
} catch {
    Write-Host "❌ Error en Dashboard: $_" -ForegroundColor Red
}

# 3. Test Reporte Por Estado
Write-Host "`n=== 3. Reporte Por Estado ===" -ForegroundColor Cyan
try {
    $porEstado = Invoke-RestMethod -Uri "$baseUrl/Reportes/PorEstado" -Method Get -Headers $headers
    Write-Host "✅ Reporte por estado obtenido:" -ForegroundColor Green
    foreach ($estado in $porEstado.datos) {
        Write-Host "   - $($estado.nombreEstado): $($estado.cantidad) ($($estado.porcentaje)%)"
    }
} catch {
    Write-Host "❌ Error en Por Estado: $_" -ForegroundColor Red
}

# 4. Test Reporte Por Prioridad
Write-Host "`n=== 4. Reporte Por Prioridad ===" -ForegroundColor Cyan
try {
    $porPrioridad = Invoke-RestMethod -Uri "$baseUrl/Reportes/PorPrioridad" -Method Get -Headers $headers
    Write-Host "✅ Reporte por prioridad obtenido:" -ForegroundColor Green
    foreach ($prioridad in $porPrioridad.datos) {
        Write-Host "   - $($prioridad.nombrePrioridad): $($prioridad.cantidad) ($($prioridad.porcentaje)%)"
    }
} catch {
    Write-Host "❌ Error en Por Prioridad: $_" -ForegroundColor Red
}

# 5. Test Reporte Por Departamento
Write-Host "`n=== 5. Reporte Por Departamento ===" -ForegroundColor Cyan
try {
    $porDepartamento = Invoke-RestMethod -Uri "$baseUrl/Reportes/PorDepartamento" -Method Get -Headers $headers
    Write-Host "✅ Reporte por departamento obtenido:" -ForegroundColor Green
    foreach ($depto in $porDepartamento.datos) {
        Write-Host "   - $($depto.nombreDepartamento): $($depto.cantidad) (A: $($depto.ticketsAbiertos), C: $($depto.ticketsCerrados))"
    }
} catch {
    Write-Host "❌ Error en Por Departamento: $_" -ForegroundColor Red
}

# 6. Test Tendencias (últimos 7 días)
Write-Host "`n=== 6. Tendencias (últimos 7 días) ===" -ForegroundColor Cyan
try {
    $fechaHasta = Get-Date -Format "yyyy-MM-dd"
    $fechaDesde = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
    $tendencias = Invoke-RestMethod -Uri "$baseUrl/Reportes/Tendencias?FechaDesde=$fechaDesde&FechaHasta=$fechaHasta&AgrupacionPeriodo=dia" -Method Get -Headers $headers
    Write-Host "✅ Tendencias obtenidas:" -ForegroundColor Green
    foreach ($tendencia in $tendencias.datos | Select-Object -First 3) {
        Write-Host "   - $($tendencia.periodo): Creados=$($tendencia.ticketsCreados), Cerrados=$($tendencia.ticketsCerrados)"
    }
} catch {
    Write-Host "❌ Error en Tendencias: $_" -ForegroundColor Red
}

Write-Host "`n=== Tests completados ===" -ForegroundColor Cyan
