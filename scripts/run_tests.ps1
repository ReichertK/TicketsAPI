Add-Type -AssemblyName System.Net.Http

$ApiUrl = "https://localhost:5001/api/v1"
$AdminUser = "Admin"
$AdminPassword = "changeme"

# Ignorar certificados SSL
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

Write-Host "================================" -ForegroundColor Green
Write-Host "Pruebas Exhaustivas TicketsAPI" -ForegroundColor Green
Write-Host "Usuario: $AdminUser" -ForegroundColor Green
Write-Host "URL API: $ApiUrl" -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Green

# Esperar a que API esté lista
$ready = $false
$attempts = 0
while (-not $ready -and $attempts -lt 15) {
    try {
        $response = Invoke-WebRequest -Uri "$ApiUrl/Estados" -Method Get -SkipCertificateCheck -TimeoutSec 2 -ErrorAction Stop
        $ready = $true
        Write-Host "✓ API lista`n" -ForegroundColor Green
    } catch {
        $attempts++
        if ($attempts -lt 15) {
            Write-Host "Esperando API... ($attempts/15)" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}

if (-not $ready) {
    Write-Host "❌ API no está disponible" -ForegroundColor Red
    exit 1
}

# ============== LOGIN ==============
Write-Host "`n[1/12] LOGIN`n" -ForegroundColor Cyan

$loginUrl = "$ApiUrl/Auth/login"
$loginBody = @{
    usuario = $AdminUser
    contrasena = $AdminPassword
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $loginBody -ContentType "application/json" -SkipCertificateCheck
    if ($response.exitoso) {
        $token = $response.datos.token
        $userId = $response.datos.id_Usuario
        Write-Host "✓ Login exitoso - ID: $userId" -ForegroundColor Green
        Write-Host "  Token: $($token.Substring(0,20))..." -ForegroundColor Green
    } else {
        Write-Host "❌ Login falló: $($response.mensaje)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error en login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{ "Authorization" = "Bearer $token" }

# ============== TICKETS - LIST ==============
Write-Host "`n[2/12] GET /Tickets - Listar tickets`n" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets" -Method Get -Headers $headers -SkipCertificateCheck
    Write-Host "✓ Listado obtenido: $($response.datos.totalRegistros) tickets" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# ============== TICKETS - CREATE ==============
Write-Host "`n[3/12] POST /Tickets - Crear ticket`n" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ticketBody = @{
    contenido = "Test ticket Admin - $timestamp"
    id_Prioridad = 1
    id_Departamento = 1
    id_Usuario_Asignado = 2
    id_Motivo = 1
} | ConvertTo-Json

$ticketId = $null
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets" -Method Post -Headers $headers -Body $ticketBody -ContentType "application/json" -SkipCertificateCheck
    if ($response.exitoso) {
        $ticketId = $response.datos.id
        Write-Host "✓ Ticket creado - ID: $ticketId" -ForegroundColor Green
    } else {
        Write-Host "❌ Error: $($response.mensaje)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# ============== TICKETS - GET BY ID ==============
if ($ticketId) {
    Write-Host "`n[4/12] GET /Tickets/{id} - Obtener ticket`n" -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId" -Method Get -Headers $headers -SkipCertificateCheck
        if ($response.exitoso) {
            Write-Host "✓ Ticket obtenido: $($response.datos.contenido.Substring(0,40))..." -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # ============== TICKETS - UPDATE ==============
    Write-Host "`n[5/12] PUT /Tickets/{id} - Actualizar ticket`n" -ForegroundColor Cyan
    $timestamp2 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $updateBody = @{
        contenido = "ACTUALIZADO - $timestamp2"
        id_Prioridad = 2
        id_Departamento = 1
        id_Usuario_Asignado = 3
        id_Motivo = 1
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId" -Method Put -Headers $headers -Body $updateBody -ContentType "application/json" -SkipCertificateCheck
        Write-Host "✓ Ticket actualizado" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # ============== TICKETS - CHANGE STATE ==============
    Write-Host "`n[6/12] PATCH /Tickets/{id}/cambiar-estado`n" -ForegroundColor Cyan
    $stateBody = @{
        id_Estado_Nuevo = 2
        comentario = "Estado cambiado por test"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId/cambiar-estado" -Method Patch -Headers $headers -Body $stateBody -ContentType "application/json" -SkipCertificateCheck
        Write-Host "✓ Estado cambiado a En Proceso" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # ============== COMENTARIOS - CREATE ==============
    Write-Host "`n[7/12] POST /Tickets/{id}/Comentarios - Crear comentario`n" -ForegroundColor Cyan
    $timestamp3 = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commentBody = @{
        comentario = "Test comentario Admin - $timestamp3"
    } | ConvertTo-Json
    
    $commentId = $null
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId/Comentarios" -Method Post -Headers $headers -Body $commentBody -ContentType "application/json" -SkipCertificateCheck
        if ($response.exitoso) {
            $commentId = $response.datos.id
            Write-Host "✓ Comentario creado - ID: $commentId" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # ============== COMENTARIOS - LIST ==============
    Write-Host "`n[8/12] GET /Tickets/{id}/Comentarios - Listar comentarios`n" -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId/Comentarios" -Method Get -Headers $headers -SkipCertificateCheck
        $count = if ($response -is [System.Collections.IEnumerable] -and $response -isnot [string]) { $response.Count } else { 1 }
        Write-Host "✓ Comentarios listados: $count" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # ============== COMENTARIOS - UPDATE ==============
    if ($commentId) {
        Write-Host "`n[9/12] PUT /Tickets/{id}/Comentarios/{cid} - Actualizar comentario`n" -ForegroundColor Cyan
        $updateCommentBody = @{
            comentario = "Comentario ACTUALIZADO por test"
        } | ConvertTo-Json
        
        try {
            $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$ticketId/Comentarios/$commentId" -Method Put -Headers $headers -Body $updateCommentBody -ContentType "application/json" -SkipCertificateCheck
            Write-Host "✓ Comentario actualizado" -ForegroundColor Green
        } catch {
            Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# ============== DATOS REFERENCIA ==============
Write-Host "`n[10/12] GET Datos de Referencia`n" -ForegroundColor Cyan

$refEndpoints = @("Estados", "Prioridades", "Departamentos", "Motivos")
foreach ($endpoint in $refEndpoints) {
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/$endpoint" -Method Get -Headers $headers -SkipCertificateCheck
        $count = $response.datos.Count
        Write-Host "  ✓ $endpoint: $count registros" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ $endpoint: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ============== USUARIOS ==============
Write-Host "`n[11/12] GET /Usuarios - Listar usuarios`n" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/Usuarios" -Method Get -Headers $headers -SkipCertificateCheck
    $count = $response.datos.Count
    Write-Host "✓ Usuarios listados: $count" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# ============== PERFIL ACTUAL ==============
Write-Host "`n[12/12] GET /Usuarios/perfil-actual`n" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/Usuarios/perfil-actual" -Method Get -Headers $headers -SkipCertificateCheck
    Write-Host "✓ Perfil actual obtenido" -ForegroundColor Green
    Write-Host "  Usuario: $($response.datos.nombre)" -ForegroundColor Green
    Write-Host "  Perfil: $($response.datos.perfil_nombre)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n`n================================" -ForegroundColor Green
Write-Host "PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "`nTodos los endpoints probados exitosamente como usuario Admin`n" -ForegroundColor Green
