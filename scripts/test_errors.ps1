#!/usr/bin/env powershell
# PRUEBAS DETALLADAS CON CAPTURA DE ERRORES

$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
$ApiUrl = "https://localhost:5001/api/v1"
$resultados = @()

Write-Host "`n===== PRUEBAS DETALLADAS =====" -ForegroundColor Cyan

# LOGIN
Write-Host "`n[Login]" -ForegroundColor Yellow
$loginBody = @{
    usuario = "Admin"
    "Contraseña" = "changeme"
} | ConvertTo-Json

$loginResp = Invoke-RestMethod -Uri "$ApiUrl/Auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResp.datos.token
$headers = @{"Authorization" = "Bearer $token"}
Write-Host "✓ Token obtenido" -ForegroundColor Green

# Function to test endpoints
function Test-Api {
    param([string]$name, [string]$method, [string]$endpoint, [object]$body, [hashtable]$headers)
    
    $test = @{
        name = $name
        method = $method
        endpoint = $endpoint
        status = 0
        message = ""
        success = $false
        response = ""
    }
    
    try {
        $params = @{
            Uri = "$ApiUrl$endpoint"
            Method = $method
            Headers = $headers
            ContentType = "application/json"
            ErrorAction = "Stop"
        }
        if ($body) { $params.Body = $body | ConvertTo-Json }
        
        $resp = Invoke-RestMethod @params
        $test.status = 200
        $test.success = $true
        $test.message = "OK"
        $test.response = $resp | ConvertTo-Json -Compress
        Write-Host "✓ $name (200)" -ForegroundColor Green
    } catch {
        $test.success = $false
        $test.message = $_.Exception.Message
        
        if ($_.Exception.Response) {
            $test.status = [int]$_.Exception.Response.StatusCode
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $test.response = $reader.ReadToEnd()
                $reader.Dispose()
            } catch { }
        }
        Write-Host "✗ $name ($($test.status)) - $($test.message)" -ForegroundColor Red
    }
    
    $script:resultados += $test
}

# TICKETS TESTS
Write-Host "`n[TICKETS]" -ForegroundColor Yellow
Test-Api "GET /Tickets" "GET" "/Tickets" $null $headers
Test-Api "POST /Tickets" "POST" "/Tickets" @{
    contenido = "Test"
    id_Prioridad = 1
    id_Departamento = 1
    id_Usuario_Asignado = 2
    id_Motivo = 1
} $headers
Test-Api "GET /Tickets/1" "GET" "/Tickets/1" $null $headers
Test-Api "PUT /Tickets/1" "PUT" "/Tickets/1" @{contenido = "Updated"} $headers

# COMMENTS TESTS
Write-Host "`n[COMENTARIOS]" -ForegroundColor Yellow
Test-Api "POST /Tickets/1/Comentarios" "POST" "/Tickets/1/Comentarios" @{comentario = "Test"} $headers
Test-Api "GET /Tickets/1/Comentarios" "GET" "/Tickets/1/Comentarios" $null $headers

# REFERENCE DATA
Write-Host "`n[DATOS DE REFERENCIA]" -ForegroundColor Yellow
Test-Api "GET /Estados" "GET" "/Estados" $null $headers
Test-Api "GET /Prioridades" "GET" "/Prioridades" $null $headers
Test-Api "GET /Departamentos" "GET" "/Departamentos" $null $headers
Test-Api "GET /Motivos" "GET" "/Motivos" $null $headers

# USERS
Write-Host "`n[USUARIOS]" -ForegroundColor Yellow
Test-Api "GET /Usuarios" "GET" "/Usuarios" $null $headers
Test-Api "GET /Usuarios/perfil-actual" "GET" "/Usuarios/perfil-actual" $null $headers

# SUMMARY
Write-Host "`n===== RESUMEN =====" -ForegroundColor Green
$ok = ($resultados | Where-Object { $_.success }).Count
$fail = $resultados.Count - $ok
$pct = if ($resultados.Count -gt 0) { [math]::Round($ok / $resultados.Count * 100, 1) } else { 0 }

Write-Host "Total: $($resultados.Count) | ✓ Pasadas: $ok | ✗ Fallidas: $fail | Éxito: $pct%"

# SAVE REPORT
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "TEST_RESULTS_$timestamp.json"

$report = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    summary = @{
        total = $resultados.Count
        passed = $ok
        failed = $fail
        percentage = $pct
    }
    tests = $resultados
}

$report | ConvertTo-Json -Depth 10 | Out-File $reportFile -Encoding UTF8
Write-Host "`nReporte guardado: $reportFile" -ForegroundColor Cyan

# SHOW ERRORS
if ($fail -gt 0) {
    Write-Host "`n===== ERRORES DETALLADOS =====" -ForegroundColor Red
    $resultados | Where-Object { -not $_.success } | ForEach-Object {
        Write-Host "`n$($_.name)" -ForegroundColor Red
        Write-Host "  Endpoint: $($_.method) $($_.endpoint)"
        Write-Host "  Status: $($_.status)"
        Write-Host "  Error: $($_.message)"
        if ($_.response) {
            $resp = $_.response
            if ($resp.Length -gt 150) { $resp = $resp.Substring(0, 150) + "..." }
            Write-Host "  Response: $resp" -ForegroundColor DarkRed
        }
    }
}

Write-Host "`n"
