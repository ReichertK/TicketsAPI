<#
.SYNOPSIS
    Creates the initial admin user and Administrador role in MySQL.
.DESCRIPTION
    Inserts the Administrador role (id=1) and a default admin user.
    Uses INSERT IGNORE / ON DUPLICATE KEY to be idempotent.
.PARAMETER Server
    MySQL host. Default: localhost
.PARAMETER User
    MySQL user. Default: root
.PARAMETER Database
    Target database. Default: cdk_tkt_dev
.PARAMETER Password
    MySQL password. Omit for passwordless local access.
.PARAMETER AdminPassword
    Plaintext password for the admin user. Will be hashed by the API
    on first login (progressive BCrypt upgrade). Default: changeme
.EXAMPLE
    .\db-setup-admin.ps1 -Password "dbpass" -AdminPassword "s3cret"
.NOTES
    Requires mysql.exe in PATH.
#>

param(
    [string]$Server        = "localhost",
    [string]$User          = "root",
    [string]$Database      = "cdk_tkt_dev",
    [string]$Password      = "",
    [string]$AdminPassword = "changeme"
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== Admin User Setup ===" -ForegroundColor Cyan
Write-Host "Database: $Database @ $Server`n"

$sqlCommands = @(
    "INSERT IGNORE INTO rol (idRol, nombre, descripcion, estado) VALUES (1, 'Administrador', 'Rol de administrador del sistema', 1);",
    "INSERT INTO usuario (nombre, email, passwordUsuario, fechaAlta, tipo, idRol) VALUES ('admin', 'admin@system.com', '$AdminPassword', CURDATE(), 'ADM', 1) ON DUPLICATE KEY UPDATE email='admin@system.com';",
    "SELECT idUsuario, nombre, email, idRol FROM usuario WHERE nombre = 'admin';"
)

function Invoke-MySQL {
    param([string]$Query)
    $args = @("-h", $Server, "-u", $User, "-D", $Database, "-e", $Query)
    if ($Password) { $args += "-p$Password" }
    & mysql @args 2>&1
    return $LASTEXITCODE -eq 0
}

foreach ($sql in $sqlCommands) {
    Write-Host "  $sql" -ForegroundColor White
    $ok = Invoke-MySQL -Query $sql
    if ($ok) {
        Write-Host "  OK" -ForegroundColor Green
    } else {
        Write-Host "  FAILED" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "Admin user ready. Change the password after first login.`n" -ForegroundColor Green
