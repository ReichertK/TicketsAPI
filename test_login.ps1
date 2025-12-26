# Script para probar el endpoint de login
# Teste POST /api/v1/Auth/login con credenciales "admin/changeme"

Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              🧪 TEST LOGIN - POST /Auth/login              ║" -ForegroundColor Cyan
Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Endpoint
$url = "http://localhost:5000/api/v1/Auth/login"
Write-Host "URL: $url" -ForegroundColor Gray

# Credenciales
$body = @{
    usuario = "admin"
    contraseña = "changeme"
} | ConvertTo-Json

Write-Host "Body: $body" -ForegroundColor Gray
Write-Host ""

# Realizar request
Write-Host "Enviando solicitud..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $url `
        -Method POST `
        -ContentType "application/json" `
        -Body $body `
        -UseBasicParsing `
        -TimeoutSec 10
    
    Write-Host "✅ STATUS CODE: $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""
    
    # Parsear respuesta
    $responseData = $response.Content | ConvertFrom-Json
    
    Write-Host "📊 RESPUESTA:" -ForegroundColor Yellow
    Write-Host ""
    
    if ($responseData.exitoso -or $responseData.success) {
        Write-Host "✅ Login Exitoso" -ForegroundColor Green
        Write-Host ""
        
        if ($responseData.datos) {
            $user = $responseData.datos
            Write-Host "👤 Usuario:" -ForegroundColor Yellow
            Write-Host "   Id_Usuario: $($user.id_usuario)" -ForegroundColor Gray
            Write-Host "   Nombre: $($user.nombre)" -ForegroundColor Gray
            Write-Host "   Email: $($user.email)" -ForegroundColor Gray
            Write-Host ""
            
            if ($user.rol) {
                Write-Host "🔐 Rol:" -ForegroundColor Yellow
                Write-Host "   Id_Rol: $($user.rol.id_rol)" -ForegroundColor Gray
                Write-Host "   Nombre_Rol: $($user.rol.nombre_rol)" -ForegroundColor Gray
                Write-Host ""
            }
            
            Write-Host "🔑 Token JWT:" -ForegroundColor Yellow
            if ($user.token) {
                $tokenParts = $user.token -split '\.'
                Write-Host "   Header: $($tokenParts[0].Substring(0, 20))..." -ForegroundColor Gray
                Write-Host "   Payload: $($tokenParts[1].Substring(0, 20))..." -ForegroundColor Gray
                Write-Host "   Signature: $($tokenParts[2].Substring(0, 20))..." -ForegroundColor Gray
                Write-Host ""
                
                # Intentar decodificar payload
                try {
                    $paddedPayload = $tokenParts[1]
                    $paddedPayload += "=" * (4 - $paddedPayload.Length % 4)
                    $decodedBytes = [Convert]::FromBase64String($paddedPayload)
                    $decodedString = [System.Text.Encoding]::UTF8.GetString($decodedBytes)
                    $payload = $decodedString | ConvertFrom-Json
                    
                    Write-Host "📋 Claims decodificados:" -ForegroundColor Yellow
                    Write-Host "   sub (userId): $($payload.sub)" -ForegroundColor Gray
                    Write-Host "   role: $($payload.role)" -ForegroundColor Green
                    Write-Host "   email: $($payload.email)" -ForegroundColor Gray
                    Write-Host "   exp (expira): $(Get-Date -UnixTimeSeconds $payload.exp)" -ForegroundColor Gray
                } catch {
                    Write-Host "   (No se pudo decodificar el payload)" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "   Datos: $($responseData | ConvertTo-Json)" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ Login Fallido" -ForegroundColor Red
        Write-Host "Mensaje: $($responseData.mensaje)" -ForegroundColor Yellow
        if ($responseData.errores) {
            Write-Host "Errores:" -ForegroundColor Yellow
            $responseData.errores | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
        }
    }
    
} catch {
    Write-Host "❌ ERROR EN REQUEST:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Intentar parsear respuesta de error
    if ($_.Exception.Response) {
        try {
            $errorResponse = $_.Exception.Response.Content.ReadAsStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $content = $reader.ReadToEnd()
            $reader.Close()
            
            Write-Host ""
            Write-Host "Respuesta del servidor:" -ForegroundColor Yellow
            $errorData = $content | ConvertFrom-Json
            Write-Host ($errorData | ConvertTo-Json -Depth 5) -ForegroundColor Gray
        } catch {
            Write-Host "No se pudo parsear respuesta de error" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
