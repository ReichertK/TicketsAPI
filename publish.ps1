<#
.SYNOPSIS
    Script de publicación para Cediac (Frontend + Backend) — Despliegue IIS Monolítico.
.DESCRIPTION
    1. Ejecuta npm run build en el frontend (con .env.production)
    2. Ejecuta dotnet publish -c Release en el backend
    3. Copia el frontend (dist/) dentro de wwwroot/ de la API publicada
    4. Comprime todo en un único .zip listo para desplegar en IIS
.NOTES
    Ejecutar desde la raíz del repositorio: .\publish.ps1
    El .zip resultante se extrae directamente en la carpeta física del sitio IIS.
#>

param(
    [string]$OutputDir = ".\publish"
)

$ErrorActionPreference = "Stop"
$RepoRoot = $PSScriptRoot
if (-not $RepoRoot) { $RepoRoot = Get-Location }

$FrontendDir = Join-Path $RepoRoot "tickets-frontend"
$BackendDir  = Join-Path $RepoRoot "TicketsAPI"
$OutputDir   = Join-Path $RepoRoot $OutputDir
$Timestamp   = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Cediac — Build de Publicacion (IIS)" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ── Limpiar directorio de publicación ──
if (Test-Path $OutputDir) {
    Remove-Item $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$SiteDir = Join-Path $OutputDir "site"

# ══════════════════════════════════════════════
# 1. FRONTEND BUILD
# ══════════════════════════════════════════════
Write-Host "[1/4] Building Frontend (npm run build)..." -ForegroundColor Yellow
Push-Location $FrontendDir
try {
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "Frontend build failed with exit code $LASTEXITCODE" }
    Write-Host "      Frontend build exitoso" -ForegroundColor Green
}
finally {
    Pop-Location
}

# ══════════════════════════════════════════════
# 2. BACKEND PUBLISH
# ══════════════════════════════════════════════
Write-Host "[2/4] Publishing Backend (dotnet publish -c Release)..." -ForegroundColor Yellow
Push-Location $BackendDir
try {
    dotnet publish -c Release -o $SiteDir --no-self-contained
    if ($LASTEXITCODE -ne 0) { throw "Backend publish failed with exit code $LASTEXITCODE" }
    Write-Host "      Backend publish exitoso" -ForegroundColor Green
}
finally {
    Pop-Location
}

# ══════════════════════════════════════════════
# 3. COPIAR FRONTEND EN wwwroot/ DE LA API
# ══════════════════════════════════════════════
Write-Host "[3/4] Copiando frontend en wwwroot/..." -ForegroundColor Yellow
$WwwRoot = Join-Path $SiteDir "wwwroot"
New-Item -ItemType Directory -Path $WwwRoot -Force | Out-Null
Copy-Item -Path (Join-Path $FrontendDir "dist\*") -Destination $WwwRoot -Recurse -Force

# Crear carpeta de logs si no existe
$LogsDir = Join-Path $SiteDir "logs"
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}

Write-Host "      Frontend copiado en wwwroot/" -ForegroundColor Green

# ══════════════════════════════════════════════
# 4. COMPRIMIR Y RESUMEN
# ══════════════════════════════════════════════
Write-Host "[4/4] Comprimiendo artefacto final..." -ForegroundColor Yellow

$ZipFile = Join-Path $OutputDir "cediac-tickets_$Timestamp.zip"
Compress-Archive -Path "$SiteDir\*" -DestinationPath $ZipFile -Force

$zipSize = (Get-Item $ZipFile).Length / 1MB

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Publicacion completada exitosamente" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Artefacto : $ZipFile" -ForegroundColor White
Write-Host "  Tamano    : $([math]::Round($zipSize, 2)) MB" -ForegroundColor White
Write-Host ""
Write-Host "  Despliegue en IIS:" -ForegroundColor Yellow
Write-Host "    1. Detener el sitio en IIS Manager" -ForegroundColor DarkGray
Write-Host "    2. Borrar el contenido actual de la carpeta del sitio" -ForegroundColor DarkGray
Write-Host "    3. Extraer el .zip en la carpeta fisica del sitio" -ForegroundColor DarkGray
Write-Host "    4. Verificar que appsettings.Production.json esta presente" -ForegroundColor DarkGray
Write-Host "    5. Iniciar el sitio desde IIS Manager" -ForegroundColor DarkGray
Write-Host "    6. Probar: http://YOUR_SERVER:YOUR_PORT/" -ForegroundColor DarkGray
Write-Host ""
