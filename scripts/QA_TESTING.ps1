# ============================================================================
# PLAN DE TESTING QA PROFESIONAL - TicketsAPI
# ============================================================================
# Script para testing sistematico de todos los endpoints

$BaseUrl = "http://localhost:5000/api/v1"
$JwtToken = ""
$RefreshToken = ""
$TestResults = @()

# Colors for output
$Success = "Green"
$ErrorColor = "Red"
$Warning = "Yellow"
$Info = "Cyan"

function Write-Result {
    param(
        [string]$Test,
        [bool]$Passed,
        [string]$Message,
        [object]$Response
    )
    
    $status = if ($Passed) { "[PASS]" } else { "[FAIL]" }
    $color = if ($Passed) { $Success } else { $ErrorColor }
    
    Write-Host "$status $Test" -ForegroundColor $color
    Write-Host "  -> $Message" -ForegroundColor $Info
    
    $TestResults += [PSCustomObject]@{
        Test = $Test
        Passed = $Passed
        Message = $Message
        Response = $Response
    }
}

function Assert-StatusCode {
    param(
        [int]$Actual,
        [int]$Expected,
        [string]$TestName,
        [object]$Response
    )
    
    if ($Actual -eq $Expected) {
        Write-Result "$TestName" $true "Status $Actual (expected $Expected)" $Response
        return $true
    } else {
        Write-Result "$TestName" $false "Status $Actual (expected $Expected)" $Response
        return $false
    }
}

# ============================================================================
# FASE 1: TESTING DE AUTENTICACIÓN
# ============================================================================
Write-Host "`n`n=== FASE 1: AUTENTICACIÓN ===" -ForegroundColor Cyan

Write-Host "`n[1.1] POST /Auth/login - Credenciales válidas" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{
            username = "admin"
            password = "changeme"
        }) `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $JwtToken = $content.data.token
        $RefreshToken = $content.data.refreshToken
        
        Write-Result "Login válido" $true "Status 200, token obtenido: ${JwtToken.Substring(0, 20)}..." $response.StatusCode
    } else {
        Write-Result "Login válido" $false "Unexpected status: $($response.StatusCode)" $response.Content
    }
} catch {
    Write-Result "Login válido" $false "Exception: $($_.Exception.Message)" $_
}

Write-Host "`n[1.2] POST /Auth/login - Credenciales inválidas" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{
            username = "invalid"
            password = "wrongpass"
        }) `
        -ErrorAction SilentlyContinue
    
    Write-Result "Login inválido (esperado 401)" $false "Status $($response.StatusCode)" $response.Content
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Result "Login inválido (esperado 401)" $true "Status 401, rechazado correctamente" $_.Exception.Response.StatusCode
    } else {
        Write-Result "Login inválido (esperado 401)" $false "Unexpected status: $($_.Exception.Response.StatusCode)" $_
    }
}

if ([string]::IsNullOrEmpty($JwtToken)) {
    Write-Host "`n⚠️  PARADA CRÍTICA: No se obtuvo JWT token. Abortando tests restantes." -ForegroundColor Red
    exit
}

$Headers = @{
    "Authorization" = "Bearer $JwtToken"
    "Content-Type" = "application/json"
}

Write-Host "`n[1.3] POST /Auth/refresh-token" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Auth/refresh-token" `
        -Method POST `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{
            refreshToken = $RefreshToken
        }) `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $NewToken = $content.data.token
        Write-Result "Refresh token" $true "Status 200, nuevo token obtenido" $response.StatusCode
        $JwtToken = $NewToken
        $Headers["Authorization"] = "Bearer $JwtToken"
    } else {
        Write-Result "Refresh token" $false "Status $($response.StatusCode)" $response.Content
    }
} catch {
    Write-Result "Refresh token" $false "Exception: $($_.Exception.Message)" $_
}

Write-Host "`n[1.4] GET /Auth/me - Obtener perfil del usuario actual" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Auth/me" `
        -Method GET `
        -Headers $Headers `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $userId = $content.data.id
        Write-Result "GET /Auth/me" $true "Status 200, usuario ID: $userId" $response.StatusCode
    } else {
        Write-Result "GET /Auth/me" $false "Status $($response.StatusCode)" $response.Content
    }
} catch {
    Write-Result "GET /Auth/me" $false "Exception: $($_.Exception.Message)" $_
}

Write-Host "`n[1.5] POST /Auth/logout" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Auth/logout" `
        -Method POST `
        -Headers $Headers `
        -ErrorAction SilentlyContinue
    
    Write-Result "POST /Auth/logout" ($response.StatusCode -eq 200) "Status $($response.StatusCode)" $response.StatusCode
} catch {
    Write-Result "POST /Auth/logout" $false "Exception: $($_.Exception.Message)" $_
}

# Re-login para continuar tests
Write-Host "`n[1.6] Re-login para continuar tests" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body (ConvertTo-Json @{
            username = "admin"
            password = "changeme"
        }) `
        -ErrorAction SilentlyContinue
    
    $content = ConvertFrom-Json $response.Content
    $JwtToken = $content.data.token
    $Headers["Authorization"] = "Bearer $JwtToken"
    Write-Result "Re-login" $true "Status 200" $response.StatusCode
} catch {
    Write-Result "Re-login" $false "Exception: $($_.Exception.Message)" $_
}

# ============================================================================
# FASE 2: TESTING DE REFERENCES (sin auth)
# ============================================================================
Write-Host "`n`n=== FASE 2: REFERENCIAS ===" -ForegroundColor Cyan

$HeadersNoAuth = @{ "Content-Type" = "application/json" }

Write-Host "`n[2.1] GET /References/estados" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/References/estados" `
        -Method GET `
        -Headers $HeadersNoAuth `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $count = $content.data.Count
        Write-Result "GET /References/estados" $true "Status 200, $count estados obtenidos" $count
    }
} catch {
    Write-Result "GET /References/estados" $false "Exception: $($_.Exception.Message)" $_
}

Write-Host "`n[2.2] GET /References/prioridades" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/References/prioridades" `
        -Method GET `
        -Headers $HeadersNoAuth `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $count = $content.data.Count
        Write-Result "GET /References/prioridades" $true "Status 200, $count prioridades obtenidas" $count
    }
} catch {
    Write-Result "GET /References/prioridades" $false "Exception: $($_.Exception.Message)" $_
}

Write-Host "`n[2.3] GET /References/departamentos" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/References/departamentos" `
        -Method GET `
        -Headers $HeadersNoAuth `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $count = $content.data.Count
        Write-Result "GET /References/departamentos" $true "Status 200, $count departamentos obtenidos" $count
    }
} catch {
    Write-Result "GET /References/departamentos" $false "Exception: $($_.Exception.Message)" $_
}

# ============================================================================
# FASE 3: TESTING DE TICKETS - CRUD BÁSICO
# ============================================================================
Write-Host "`n`n=== FASE 3: TICKETS - CRUD BÁSICO ===" -ForegroundColor Cyan

$TicketId = 0

Write-Host "`n[3.1] GET /Tickets - Listar todos los tickets" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Tickets" `
        -Method GET `
        -Headers $Headers `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $count = $content.data.Count
        Write-Result "GET /Tickets" $true "Status 200, $count tickets obtenidos" $count
    }
} catch {
    Write-Result "GET /Tickets" $false "Exception: $($_.Exception.Message)" $_
}

Write-Host "`n[3.2] POST /Tickets - Crear nuevo ticket" -ForegroundColor Yellow
try {
    $newTicket = @{
        Titulo = "TEST TICKET QA $(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Descripcion = "Ticket creado por testing automático QA"
        Id_Prioridad = 2
        Id_Departamento = 1
        Id_Usuario_Reportador = 1
    }
    
    $response = Invoke-WebRequest -Uri "$BaseUrl/Tickets" `
        -Method POST `
        -Headers $Headers `
        -Body (ConvertTo-Json $newTicket) `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 201) {
        $content = ConvertFrom-Json $response.Content
        $TicketId = $content.data.id
        Write-Result "POST /Tickets (crear)" $true "Status 201, ticket creado ID: $TicketId" $TicketId
    }
} catch {
    Write-Result "POST /Tickets (crear)" $false "Exception: $($_.Exception.Message)" $_
}

Write-Host "`n[3.3] GET /Tickets/{id} - Obtener ticket específico" -ForegroundColor Yellow
if ($TicketId -gt 0) {
    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl/Tickets/$TicketId" `
            -Method GET `
            -Headers $Headers `
            -ErrorAction SilentlyContinue
        
        if ($response.StatusCode -eq 200) {
            $content = ConvertFrom-Json $response.Content
            $titulo = $content.data.titulo
            Write-Result "GET /Tickets/{id}" $true "Status 200, ticket encontrado: $titulo" $titulo
        }
    } catch {
        Write-Result "GET /Tickets/{id}" $false "Exception: $($_.Exception.Message)" $_
    }
}

Write-Host "`n[3.4] PUT /Tickets/{id} - Actualizar ticket" -ForegroundColor Yellow
if ($TicketId -gt 0) {
    try {
        $updateTicket = @{
            Titulo = "TEST TICKET ACTUALIZADO $(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Descripcion = "Descripción actualizada por testing"
            Id_Prioridad = 3
            Id_Departamento = 1
        }
        
        $response = Invoke-WebRequest -Uri "$BaseUrl/Tickets/$TicketId" `
            -Method PUT `
            -Headers $Headers `
            -Body (ConvertTo-Json $updateTicket) `
            -ErrorAction SilentlyContinue
        
        Write-Result "PUT /Tickets/{id}" ($response.StatusCode -eq 200) "Status $($response.StatusCode)" $response.StatusCode
    } catch {
        Write-Result "PUT /Tickets/{id}" $false "Exception: $($_.Exception.Message)" $_
    }
}

# ============================================================================
# FASE 4: TESTING DE TRANSICIONES DE ESTADO
# ============================================================================
Write-Host "`n`n=== FASE 4: TRANSICIONES DE ESTADO ===" -ForegroundColor Cyan

Write-Host "`n[4.1] GET /Tickets/{id}/transiciones-permitidas" -ForegroundColor Yellow
if ($TicketId -gt 0) {
    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl/Tickets/$TicketId/transiciones-permitidas" `
            -Method GET `
            -Headers $Headers `
            -ErrorAction SilentlyContinue
        
        if ($response.StatusCode -eq 200) {
            $content = ConvertFrom-Json $response.Content
            $count = $content.data.Count
            Write-Result "GET /transiciones-permitidas" $true "Status 200, $count transiciones disponibles" $count
        }
    } catch {
        Write-Result "GET /transiciones-permitidas" $false "Exception: $($_.Exception.Message)" $_
    }
}

Write-Host "`n[4.2] PATCH /Tickets/{id}/cambiar-estado" -ForegroundColor Yellow
if ($TicketId -gt 0) {
    try {
        $stateChange = @{
            Id_Estado_Nuevo = 2
            Comentario = "Estado cambiado por testing QA"
        }
        
        $response = Invoke-WebRequest -Uri "$BaseUrl/Tickets/$TicketId/cambiar-estado" `
            -Method PATCH `
            -Headers $Headers `
            -Body (ConvertTo-Json $stateChange) `
            -ErrorAction SilentlyContinue
        
        Write-Result "PATCH /cambiar-estado" ($response.StatusCode -eq 200) "Status $($response.StatusCode)" $response.StatusCode
    } catch {
        Write-Result "PATCH /cambiar-estado" $false "Exception: $($_.Exception.Message)" $_
    }
}

Write-Host "`n[4.3] GET /Tickets/{id}/historial" -ForegroundColor Yellow
if ($TicketId -gt 0) {
    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl/Tickets/$TicketId/historial" `
            -Method GET `
            -Headers $Headers `
            -ErrorAction SilentlyContinue
        
        if ($response.StatusCode -eq 200) {
            $content = ConvertFrom-Json $response.Content
            $count = $content.data.Count
            Write-Result "GET /historial" $true "Status 200, $count eventos en historial" $count
        }
    } catch {
        Write-Result "GET /historial" $false "Exception: $($_.Exception.Message)" $_
    }
}

# ============================================================================
# FASE 5: TESTING DE COMENTARIOS
# ============================================================================
Write-Host "`n`n=== FASE 5: COMENTARIOS ===" -ForegroundColor Cyan

$CommentId = 0

Write-Host "`n[5.1] POST /Tickets/{id}/Comments - Agregar comentario" -ForegroundColor Yellow
if ($TicketId -gt 0) {
    try {
        $comment = @{
            Contenido = "Comentario de testing QA $(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Tipo_Comentario = "Observación"
        }
        
        $response = Invoke-WebRequest -Uri "$BaseUrl/Tickets/$TicketId/Comments" `
            -Method POST `
            -Headers $Headers `
            -Body (ConvertTo-Json $comment) `
            -ErrorAction SilentlyContinue
        
        if ($response.StatusCode -eq 201) {
            $content = ConvertFrom-Json $response.Content
            $CommentId = $content.data.id
            Write-Result "POST /Comments" $true "Status 201, comentario creado ID: $CommentId" $CommentId
        }
    } catch {
        Write-Result "POST /Comments" $false "Exception: $($_.Exception.Message)" $_
    }
}

Write-Host "`n[5.2] GET /Tickets/{id}/Comments - Listar comentarios" -ForegroundColor Yellow
if ($TicketId -gt 0) {
    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl/Tickets/$TicketId/Comments" `
            -Method GET `
            -Headers $Headers `
            -ErrorAction SilentlyContinue
        
        if ($response.StatusCode -eq 200) {
            $content = ConvertFrom-Json $response.Content
            $count = $content.data.Count
            Write-Result "GET /Comments" $true "Status 200, $count comentarios obtenidos" $count
        }
    } catch {
        Write-Result "GET /Comments" $false "Exception: $($_.Exception.Message)" $_
    }
}

Write-Host "`n[5.3] PUT /Comments/{id} - Actualizar comentario" -ForegroundColor Yellow
if ($CommentId -gt 0) {
    try {
        $updateComment = @{
            Contenido = "Comentario actualizado por testing $(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Tipo_Comentario = "Observación"
        }
        
        $response = Invoke-WebRequest -Uri "$BaseUrl/Comments/$CommentId" `
            -Method PUT `
            -Headers $Headers `
            -Body (ConvertTo-Json $updateComment) `
            -ErrorAction SilentlyContinue
        
        Write-Result "PUT /Comments/{id}" ($response.StatusCode -eq 200) "Status $($response.StatusCode)" $response.StatusCode
    } catch {
        Write-Result "PUT /Comments/{id}" $false "Exception: $($_.Exception.Message)" $_
    }
}

Write-Host "`n[5.4] DELETE /Comments/{id} - Eliminar comentario" -ForegroundColor Yellow
if ($CommentId -gt 0) {
    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl/Comments/$CommentId" `
            -Method DELETE `
            -Headers $Headers `
            -ErrorAction SilentlyContinue
        
        Write-Result "DELETE /Comments/{id}" ($response.StatusCode -eq 204) "Status $($response.StatusCode)" $response.StatusCode
    } catch {
        Write-Result "DELETE /Comments/{id}" $false "Exception: $($_.Exception.Message)" $_
    }
}

# ============================================================================
# FASE 6: TESTING DE DEPARTAMENTOS, MOTIVOS, GRUPOS
# ============================================================================
Write-Host "`n`n=== FASE 6: CRUD - DEPARTAMENTOS, MOTIVOS, GRUPOS ===" -ForegroundColor Cyan

Write-Host "`n[6.1] GET /Departamentos" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Departamentos" `
        -Method GET `
        -Headers $Headers `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $count = $content.data.Count
        Write-Result "GET /Departamentos" $true "Status 200, $count departamentos" $count
    }
} catch {
    Write-Result "GET /Departamentos" $false "Exception: $($_.Exception.Message)" $_
}

Write-Host "`n[6.2] GET /Motivos" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Motivos" `
        -Method GET `
        -Headers $Headers `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $count = $content.data.Count
        Write-Result "GET /Motivos" $true "Status 200, $count motivos" $count
    }
} catch {
    Write-Result "GET /Motivos" $false "Exception: $($_.Exception.Message)" $_
}

Write-Host "`n[6.3] GET /Grupos" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/Grupos" `
        -Method GET `
        -Headers $Headers `
        -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        $content = ConvertFrom-Json $response.Content
        $count = $content.data.Count
        Write-Result "GET /Grupos" $true "Status 200, $count grupos" $count
    }
} catch {
    Write-Result "GET /Grupos" $false "Exception: $($_.Exception.Message)" $_
}

# ============================================================================
# REPORTE FINAL
# ============================================================================
Write-Host "`n`n=== REPORTE DE TESTING ===" -ForegroundColor Cyan

$PassedTests = ($TestResults | Where-Object { $_.Passed }).Count
$FailedTests = ($TestResults | Where-Object { -not $_.Passed }).Count
$TotalTests = $TestResults.Count

Write-Host "`nResumen de Resultados:" -ForegroundColor Cyan
Write-Host "  Total Tests: $TotalTests" -ForegroundColor Yellow
Write-Host "  ✓ Pasados: $PassedTests" -ForegroundColor Green
Write-Host "  ✗ Fallidos: $FailedTests" -ForegroundColor Red
Write-Host "  Tasa de Éxito: $(([math]::Round(($PassedTests/$TotalTests)*100, 2)))%" -ForegroundColor Cyan

if ($FailedTests -gt 0) {
    Write-Host "`nTests Fallidos:" -ForegroundColor Red
    $TestResults | Where-Object { -not $_.Passed } | ForEach-Object {
        Write-Host "  ✗ $($_.Test)" -ForegroundColor Red
        Write-Host "    └─ $($_.Message)" -ForegroundColor Yellow
    }
}

# Guardar reporte en archivo JSON
$ReportFile = "c:\Users\Admin\Documents\GitHub\TicketsAPI\QA_TEST_REPORT.json"
$TestResults | ConvertTo-Json | Out-File $ReportFile -Encoding UTF8
Write-Host "`n✓ Reporte detallado guardado en: $ReportFile" -ForegroundColor Green

Write-Host "`n=== FIN DE TESTING ===" -ForegroundColor Cyan
