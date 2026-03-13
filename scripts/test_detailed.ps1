# PRUEBAS DETALLADAS CON CAPTURA DE ERRORES

$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
$ApiUrl = "https://localhost:5001/api/v1"
$resultados = @()
$testNum = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [object]$Body,
        [hashtable]$Headers
    )
    
    $script:testNum++
    Write-Host "`n[$($script:testNum)] $Name" -ForegroundColor Cyan
    
    $resultado = @{
        Numero = $script:testNum
        Nombre = $Name
        Metodo = $Method
        Endpoint = $Endpoint
        StatusCode = 0
        Exitoso = $false
        Error = ""
        Detalle = ""
    }
    
    try {
        $params = @{
            Uri = "$ApiUrl$Endpoint"
            Method = $Method
            Headers = $Headers
            ContentType = "application/json"
            ErrorAction = "Stop"
        }
        
        if ($Body) {
            $params.Body = if ($Body -is [string]) { $Body } else { $Body | ConvertTo-Json }
        }
        
        $response = Invoke-RestMethod @params
        $resultado.StatusCode = 200
        $resultado.Exitoso = $true
        Write-Host "   ✅ EXITOSO (200)" -ForegroundColor Green
    }
    catch {
        $resultado.Exitoso = $false
        $resultado.Error = $_.Exception.Message
        
        if ($_.Exception.Response) {
            $resultado.StatusCode = [int]$_.Exception.Response.StatusCode
            
            try {
                $errorStream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($errorStream)
                $resultado.Detalle = $reader.ReadToEnd()
                $reader.Dispose()
            } catch { }
        }
        
        Write-Host "   ❌ ERROR $($resultado.StatusCode): $($resultado.Error)" -ForegroundColor Red
        if ($resultado.Detalle) {
            Write-Host "      Detalle: $($resultado.Detalle.Substring(0, [Math]::Min(150, $resultado.Detalle.Length)))" -ForegroundColor DarkRed
        }
    }
    
    $script:resultados += $resultado
}

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "PRUEBAS DETALLADAS - TicketsAPI" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# LOGIN
Write-Host "FASE 1: AUTENTICACIÓN" -ForegroundColor Yellow
$loginBody = @{ usuario = "Admin"; "Contraseña" = "changeme" } | ConvertTo-Json
Test-Endpoint "POST /Auth/login" "POST" "/Auth/login" $loginBody @{}

$token = $null
if ($resultados[-1].Exitoso) {
    try {
        $loginResp = Invoke-RestMethod -Uri "$ApiUrl/Auth/login" -Method POST -Body $loginBody -ContentType "application/json" -SkipCertificateCheck
        $token = $loginResp.datos.token
        Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Green
    } catch { }
}

if (-not $token) {
    Write-Host "`n❌ AUTENTICACION FALLIDA. Abortando." -ForegroundColor Red
    exit 1
}

$headers = @{ Authorization = "Bearer $token" }

# TICKETS
Write-Host "`nFASE 2: TICKETS" -ForegroundColor Yellow
Test-Endpoint "GET /Tickets" "GET" "/Tickets" $null $headers
Test-Endpoint "POST /Tickets" "POST" "/Tickets" (@{contenido="Test";id_Prioridad=1;id_Departamento=1;id_Usuario_Asignado=2;id_Motivo=1}|ConvertTo-Json) $headers
Test-Endpoint "GET /Tickets/1" "GET" "/Tickets/1" $null $headers
Test-Endpoint "PUT /Tickets/1" "PUT" "/Tickets/1" (@{contenido="Updated"}|ConvertTo-Json) $headers

# COMENTARIOS
Write-Host "`nFASE 3: COMENTARIOS" -ForegroundColor Yellow
Test-Endpoint "POST /Tickets/1/Comentarios" "POST" "/Tickets/1/Comentarios" (@{comentario="Test"}|ConvertTo-Json) $headers
Test-Endpoint "GET /Tickets/1/Comentarios" "GET" "/Tickets/1/Comentarios" $null $headers

# REFERENCIAS
Write-Host "`nFASE 4: DATOS DE REFERENCIA" -ForegroundColor Yellow
Test-Endpoint "GET /Estados" "GET" "/Estados" $null $headers
Test-Endpoint "GET /Prioridades" "GET" "/Prioridades" $null $headers
Test-Endpoint "GET /Departamentos" "GET" "/Departamentos" $null $headers
Test-Endpoint "GET /Motivos" "GET" "/Motivos" $null $headers

# USUARIOS
Write-Host "`nFASE 5: USUARIOS" -ForegroundColor Yellow
Test-Endpoint "GET /Usuarios" "GET" "/Usuarios" $null $headers

# RESUMEN
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "RESUMEN" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$pasadas = ($resultados | Where-Object { $_.Exitoso }).Count
$fallidas = $resultados.Count - $pasadas
$porcentaje = if ($resultados.Count -gt 0) { [math]::Round($pasadas/$resultados.Count*100, 1) } else { 0 }

Write-Host "`nTotal: $($resultados.Count) pruebas"
Write-Host "✅ Pasadas: $pasadas" -ForegroundColor Green
Write-Host "❌ Fallidas: $fallidas" -ForegroundColor Red
Write-Host "📊 Éxito: $porcentaje%`n" -ForegroundColor Yellow

# ERRORES
if ($fallidas -gt 0) {
    Write-Host "ERRORES DETALLADOS:" -ForegroundColor Red
    $resultados | Where-Object { -not $_.Exitoso } | ForEach-Object {
        Write-Host "`n[$($_.Numero)] $($_.Nombre)"
        Write-Host "    Endpoint: $($_.Metodo) $($_.Endpoint)"
        Write-Host "    Status: $($_.StatusCode)"
        Write-Host "    Error: $($_.Error)"
        if ($_.Detalle) {
            Write-Host "    Response: $($_.Detalle.Substring(0, [Math]::Min(200, $_.Detalle.Length)))"
        }
    }
}

# REPORTE
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "TEST_RESULTS_$timestamp.json"
@{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Total = $resultados.Count
    Pasadas = $pasadas
    Fallidas = $fallidas
    Porcentaje = $porcentaje
    Pruebas = $resultados
} | ConvertTo-Json -Depth 5 | Out-File $reportFile -Encoding UTF8

Write-Host "`n📁 Reporte: $reportFile`n" -ForegroundColor Cyan
