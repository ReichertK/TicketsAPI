# Testing Exhaustivo TicketsAPI - Usuario Admin
# =============================================

param()

$ErrorActionPreference = "Continue"
$ApiUrl = "https://localhost:5001/api/v1"
$AdminUser = "Admin"
$AdminPassword = "changeme"

# Ignorar certificado SSL
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

$results = @()
$token = $null

function Log-Test {
    param(
        [string]$Method,
        [string]$Endpoint,
        [int]$Status,
        [bool]$Success,
        [string]$Message,
        [object]$Response
    )
    
    $result = @{
        Method = $Method
        Endpoint = $Endpoint
        Status = $Status
        Success = $Success
        Message = $Message
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    $script:results += $result
    $icon = if ($Success) { "✅" } else { "❌" }
    Write-Host "$icon [$Method] $Endpoint - $Status - $Message" -ForegroundColor $(if($Success) {"Green"} else {"Red"})
}

# ============================================================================
# 1. AUTENTICACIÓN
# ============================================================================
Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "🔐 AUTENTICACIÓN" -ForegroundColor Cyan
Write-Host ("="*70) -ForegroundColor Cyan

$loginUrl = "$ApiUrl/Auth/login"
$loginBody = @{
    usuario = $AdminUser
    contraseña = $AdminPassword
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($response.exitoso) {
        $script:token = $response.datos.token
        $userId = $response.datos.id_Usuario
        Log-Test "POST" "/Auth/login" 200 $true "Login exitoso - Usuario ID: $userId"
        Write-Host "✓ Token obtenido" -ForegroundColor Green
    } else {
        Log-Test "POST" "/Auth/login" 200 $false $response.mensaje
    }
} catch {
    Log-Test "POST" "/Auth/login" 0 $false $_.Exception.Message
}

if (-not $script:token) {
    Write-Host "❌ No se pudo obtener token. Abortando..." -ForegroundColor Red
    exit 1
}

$headers = @{ "Authorization" = "Bearer $script:token" }

# ============================================================================
# 2. DATOS DE REFERENCIA
# ============================================================================
Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "📚 TESTING DATOS DE REFERENCIA" -ForegroundColor Cyan
Write-Host ("="*70) -ForegroundColor Cyan

$endpoints = @(
    @{ Endpoint = "/Estados"; Name = "Estados" }
    @{ Endpoint = "/Prioridades"; Name = "Prioridades" }
    @{ Endpoint = "/Departamentos"; Name = "Departamentos" }
    @{ Endpoint = "/Motivos"; Name = "Motivos" }
)

foreach ($item in $endpoints) {
    Write-Host "`n[GET] $($item.Endpoint)"
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl$($item.Endpoint)" -Method Get -Headers $headers
        $count = $response.datos.Count
        Log-Test "GET" $item.Endpoint 200 $true "$($item.Name) obtenidos ($count registros)"
    } catch {
        Log-Test "GET" $item.Endpoint 0 $false $_.Exception.Message
    }
}

# ============================================================================
# 3. TICKETS - CREAR
# ============================================================================
Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "🎫 TESTING TICKETS" -ForegroundColor Cyan
Write-Host ("="*70) -ForegroundColor Cyan

Write-Host "`n[1] POST /Tickets - Crear nuevo ticket"
$ticketBody = @{
    contenido = "Test ticket Admin - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    id_Prioridad = 1
    id_Departamento = 1
    id_Usuario_Asignado = 2
    id_Motivo = 1
} | ConvertTo-Json

$createdTicketId = $null
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets" -Method Post -Headers $headers -Body $ticketBody -ContentType "application/json"
    if ($response.exitoso) {
        $createdTicketId = $response.datos.id
        Log-Test "POST" "/Tickets" 201 $true "Ticket creado - ID: $createdTicketId"
    } else {
        Log-Test "POST" "/Tickets" 200 $false $response.mensaje
    }
} catch {
    Log-Test "POST" "/Tickets" 0 $false $_.Exception.Message
}

# ============================================================================
# 4. TICKETS - LISTAR
# ============================================================================
Write-Host "`n[2] GET /Tickets - Listar todos los tickets"
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets" -Method Get -Headers $headers
    $total = $response.datos.totalRegistros
    Log-Test "GET" "/Tickets" 200 $true "Listado obtenido ($total tickets)"
} catch {
    Log-Test "GET" "/Tickets" 0 $false $_.Exception.Message
}

# ============================================================================
# 5. TICKETS - OBTENER DETALLE
# ============================================================================
if ($createdTicketId) {
    Write-Host "`n[3] GET /Tickets/{id} - Obtener detalle del ticket"
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$createdTicketId" -Method Get -Headers $headers
        if ($response.exitoso) {
            Log-Test "GET" "/Tickets/$createdTicketId" 200 $true "Ticket obtenido"
        }
    } catch {
        Log-Test "GET" "/Tickets/$createdTicketId" 0 $false $_.Exception.Message
    }
    
    # ========================================================================
    # 6. TICKETS - ACTUALIZAR
    # ========================================================================
    Write-Host "`n[4] PUT /Tickets/{id} - Actualizar ticket"
    $updateBody = @{
        contenido = "Test ticket ACTUALIZADO - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        id_Prioridad = 2
        id_Departamento = 1
        id_Usuario_Asignado = 3
        id_Motivo = 1
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$createdTicketId" -Method Put -Headers $headers -Body $updateBody -ContentType "application/json"
        Log-Test "PUT" "/Tickets/$createdTicketId" 200 $true "Ticket actualizado"
    } catch {
        Log-Test "PUT" "/Tickets/$createdTicketId" 0 $false $_.Exception.Message
    }
    
    # ========================================================================
    # 7. TICKETS - CAMBIAR ESTADO
    # ========================================================================
    Write-Host "`n[5] PATCH /Tickets/{id}/cambiar-estado - Cambiar estado"
    $stateBody = @{
        id_Estado_Nuevo = 2
        comentario = "Test cambio de estado - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$createdTicketId/cambiar-estado" -Method Patch -Headers $headers -Body $stateBody -ContentType "application/json"
        Log-Test "PATCH" "/Tickets/$createdTicketId/cambiar-estado" 200 $true "Estado cambiado"
    } catch {
        Log-Test "PATCH" "/Tickets/$createdTicketId/cambiar-estado" 0 $false $_.Exception.Message
    }
    
    # ========================================================================
    # 8. COMENTARIOS - CREAR
    # ========================================================================
    Write-Host "`n" + ("="*70) -ForegroundColor Cyan
    Write-Host "💬 TESTING COMENTARIOS" -ForegroundColor Cyan
    Write-Host ("="*70) -ForegroundColor Cyan
    
    Write-Host "`n[1] POST /Tickets/{id}/Comentarios - Crear comentario"
    $commentBody = @{
        comentario = "Test comentario Admin - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    } | ConvertTo-Json
    
    $createdCommentId = $null
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$createdTicketId/Comentarios" -Method Post -Headers $headers -Body $commentBody -ContentType "application/json"
        if ($response.exitoso) {
            $createdCommentId = $response.datos.id
            Log-Test "POST" "/Tickets/$createdTicketId/Comentarios" 201 $true "Comentario creado - ID: $createdCommentId"
        }
    } catch {
        Log-Test "POST" "/Tickets/$createdTicketId/Comentarios" 0 $false $_.Exception.Message
    }
    
    # ========================================================================
    # 9. COMENTARIOS - LISTAR
    # ========================================================================
    Write-Host "`n[2] GET /Tickets/{id}/Comentarios - Listar comentarios"
    try {
        $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$createdTicketId/Comentarios" -Method Get -Headers $headers
        $count = $response.Count
        Log-Test "GET" "/Tickets/$createdTicketId/Comentarios" 200 $true "Comentarios listados ($count)"
    } catch {
        Log-Test "GET" "/Tickets/$createdTicketId/Comentarios" 0 $false $_.Exception.Message
    }
    
    # ========================================================================
    # 10. COMENTARIOS - ACTUALIZAR
    # ========================================================================
    if ($createdCommentId) {
        Write-Host "`n[3] PUT /Tickets/{id}/Comentarios/{cid} - Actualizar comentario"
        $updateCommentBody = @{
            comentario = "Test comentario ACTUALIZADO - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        } | ConvertTo-Json
        
        try {
            $response = Invoke-RestMethod -Uri "$ApiUrl/Tickets/$createdTicketId/Comentarios/$createdCommentId" -Method Put -Headers $headers -Body $updateCommentBody -ContentType "application/json"
            Log-Test "PUT" "/Tickets/$createdTicketId/Comentarios/$createdCommentId" 200 $true "Comentario actualizado"
        } catch {
            Log-Test "PUT" "/Tickets/$createdTicketId/Comentarios/$createdCommentId" 0 $false $_.Exception.Message
        }
    }
}

# ============================================================================
# 11. USUARIOS
# ============================================================================
Write-Host "`n" + ("="*70) -ForegroundColor Cyan
Write-Host "👥 TESTING USUARIOS" -ForegroundColor Cyan
Write-Host ("="*70) -ForegroundColor Cyan

Write-Host "`n[1] GET /Usuarios - Listar usuarios"
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/Usuarios" -Method Get -Headers $headers
    $count = $response.datos.Count
    Log-Test "GET" "/Usuarios" 200 $true "Usuarios listados ($count)"
} catch {
    Log-Test "GET" "/Usuarios" 0 $false $_.Exception.Message
}

Write-Host "`n[2] GET /Usuarios/perfil-actual - Obtener perfil actual"
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/Usuarios/perfil-actual" -Method Get -Headers $headers
    Log-Test "GET" "/Usuarios/perfil-actual" 200 $true "Perfil actual obtenido"
} catch {
    Log-Test "GET" "/Usuarios/perfil-actual" 0 $false $_.Exception.Message
}

# ============================================================================
# RESUMEN
# ============================================================================
Write-Host "`n" + ("="*70) -ForegroundColor Green
Write-Host "📊 RESUMEN DE PRUEBAS" -ForegroundColor Green
Write-Host ("="*70) -ForegroundColor Green

$total = $script:results.Count
$passed = ($script:results | Where-Object { $_.Success }).Count
$failed = $total - $passed

Write-Host "`nTotal de pruebas: $total"
Write-Host "✅ Exitosas: $passed"
Write-Host "❌ Fallidas: $failed"
$percentage = if ($total -gt 0) { [math]::Round($passed/$total*100, 1) } else { 0 }
Write-Host "Tasa de éxito: $percentage%"

# Guardar resultados
$resultsFile = "TEST_RESULTS_ADMIN_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$script:results | ConvertTo-Json | Out-File $resultsFile -Encoding UTF8

Write-Host "`n📁 Resultados guardados en: $resultsFile"
Write-Host "`nFin: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
