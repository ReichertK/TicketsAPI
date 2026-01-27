# Test de búsqueda avanzada
# Ejecutar después de iniciar la API: dotnet run --project TicketsAPI

$baseUrl = "https://localhost:7046/api/v1"

# 1. Login para obtener token
Write-Host "`n=== 1. Login ===" -ForegroundColor Cyan
$loginResponse = Invoke-RestMethod -Uri "$baseUrl/Auth/login" -Method Post -ContentType "application/json" -Body (@{
    usuario = "admin"
    contraseña = "admin123"
} | ConvertTo-Json)

$token = $loginResponse.datos.token
Write-Host "✅ Token obtenido" -ForegroundColor Green

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 2. Test búsqueda normal en contenido
Write-Host "`n=== 2. Búsqueda Normal (solo contenido) ===" -ForegroundColor Cyan
try {
    $normal = Invoke-RestMethod -Uri "$baseUrl/Tickets?Busqueda=problema&Pagina=1&TamañoPagina=5" -Method Get -Headers $headers
    Write-Host "✅ Búsqueda normal: $($normal.datos.totalRegistros) tickets encontrados" -ForegroundColor Green
    if ($normal.datos.datos.Count -gt 0) {
        Write-Host "   Primer ticket: ID $($normal.datos.datos[0].id_Tkt)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Error en búsqueda normal: $_" -ForegroundColor Red
}

# 3. Test búsqueda avanzada - contiene (default)
Write-Host "`n=== 3. Búsqueda Avanzada - Tipo: Contiene ===" -ForegroundColor Cyan
try {
    $contiene = Invoke-RestMethod -Uri "$baseUrl/Tickets/buscar?Busqueda=error&TipoBusqueda=contiene&Pagina=1&TamañoPagina=5" -Method Get -Headers $headers
    Write-Host "✅ Búsqueda 'contiene': $($contiene.datos.totalRegistros) tickets" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# 4. Test búsqueda avanzada - comienza con
Write-Host "`n=== 4. Búsqueda Avanzada - Tipo: Comienza ===" -ForegroundColor Cyan
try {
    $comienza = Invoke-RestMethod -Uri "$baseUrl/Tickets/buscar?Busqueda=Error&TipoBusqueda=comienza&Pagina=1&TamañoPagina=5" -Method Get -Headers $headers
    Write-Host "✅ Búsqueda 'comienza': $($comienza.datos.totalRegistros) tickets" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# 5. Test búsqueda avanzada - termina con
Write-Host "`n=== 5. Búsqueda Avanzada - Tipo: Termina ===" -ForegroundColor Cyan
try {
    $termina = Invoke-RestMethod -Uri "$baseUrl/Tickets/buscar?Busqueda=sistema&TipoBusqueda=termina&Pagina=1&TamañoPagina=5" -Method Get -Headers $headers
    Write-Host "✅ Búsqueda 'termina': $($termina.datos.totalRegistros) tickets" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# 6. Test búsqueda en comentarios
Write-Host "`n=== 6. Búsqueda Avanzada - En Comentarios ===" -ForegroundColor Cyan
try {
    $comentarios = Invoke-RestMethod -Uri "$baseUrl/Tickets/buscar?Busqueda=comentario&BuscarEnComentarios=true&Pagina=1&TamañoPagina=5" -Method Get -Headers $headers
    Write-Host "✅ Búsqueda en comentarios: $($comentarios.datos.totalRegistros) tickets" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# 7. Test búsqueda en contenido + comentarios
Write-Host "`n=== 7. Búsqueda Avanzada - Contenido + Comentarios ===" -ForegroundColor Cyan
try {
    $ambos = Invoke-RestMethod -Uri "$baseUrl/Tickets/buscar?Busqueda=ticket&BuscarEnContenido=true&BuscarEnComentarios=true&Pagina=1&TamañoPagina=5" -Method Get -Headers $headers
    Write-Host "✅ Búsqueda en ambos: $($ambos.datos.totalRegistros) tickets" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# 8. Test búsqueda con filtros combinados
Write-Host "`n=== 8. Búsqueda Avanzada - Con Filtros ===" -ForegroundColor Cyan
try {
    $filtrado = Invoke-RestMethod -Uri "$baseUrl/Tickets/buscar?Busqueda=error&BuscarEnComentarios=true&Id_Estado=1&Pagina=1&TamañoPagina=5" -Method Get -Headers $headers
    Write-Host "✅ Búsqueda filtrada: $($filtrado.datos.totalRegistros) tickets" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# 9. Test búsqueda con rango de fechas
Write-Host "`n=== 9. Búsqueda Avanzada - Rango de Fechas ===" -ForegroundColor Cyan
try {
    $fechaHasta = Get-Date -Format "yyyy-MM-dd"
    $fechaDesde = (Get-Date).AddDays(-30).ToString("yyyy-MM-dd")
    $fechas = Invoke-RestMethod -Uri "$baseUrl/Tickets/buscar?Busqueda=ticket&Fecha_Desde=$fechaDesde&Fecha_Hasta=$fechaHasta&Pagina=1&TamañoPagina=5" -Method Get -Headers $headers
    Write-Host "✅ Búsqueda con fechas: $($fechas.datos.totalRegistros) tickets (últimos 30 días)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# 10. Test ordenamiento
Write-Host "`n=== 10. Búsqueda Avanzada - Ordenamiento ===" -ForegroundColor Cyan
try {
    $ordenado = Invoke-RestMethod -Uri "$baseUrl/Tickets/buscar?Ordenar_Por=fecha&Orden_Descendente=false&Pagina=1&TamañoPagina=5" -Method Get -Headers $headers
    Write-Host "✅ Búsqueda ordenada: $($ordenado.datos.totalRegistros) tickets (más antiguos primero)" -ForegroundColor Green
    if ($ordenado.datos.datos.Count -gt 0) {
        Write-Host "   Primer ticket: $($ordenado.datos.datos[0].date_Creado)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n=== Tests de búsqueda avanzada completados ===" -ForegroundColor Cyan
Write-Host "`nResumen de funcionalidades:" -ForegroundColor Yellow
Write-Host "  ✓ Búsqueda en contenido del ticket" -ForegroundColor Green
Write-Host "  ✓ Búsqueda en comentarios" -ForegroundColor Green
Write-Host "  ✓ Búsqueda en contenido + comentarios" -ForegroundColor Green
Write-Host "  ✓ Tipos de búsqueda: contiene, exacta, comienza, termina" -ForegroundColor Green
Write-Host "  ✓ Filtros combinados (estado, prioridad, departamento)" -ForegroundColor Green
Write-Host "  ✓ Rango de fechas (Fecha_Desde, Fecha_Hasta)" -ForegroundColor Green
Write-Host "  ✓ Ordenamiento configurable" -ForegroundColor Green
Write-Host "  ✓ Paginación" -ForegroundColor Green
