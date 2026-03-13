<#
.SYNOPSIS
    Adds refresh-token columns to the usuario table (MySQL 5.5+).
.DESCRIPTION
    Idempotent migration that adds refresh_token_hash, refresh_token_expires,
    and last_login columns. Safe to re-run — MySQL will report "Duplicate column"
    for columns that already exist.
.PARAMETER Server
    MySQL host. Default: localhost
.PARAMETER User
    MySQL user. Default: root
.PARAMETER Database
    Target database. Default: cdk_tkt_dev
.PARAMETER Password
    MySQL password. Omit for passwordless local access.
.EXAMPLE
    .\db-migrate-refresh-token.ps1 -Password "s3cret"
.NOTES
    Requires mysql.exe in PATH.
#>

param(
    [string]$Server   = "localhost",
    [string]$User     = "root",
    [string]$Database = "cdk_tkt_dev",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== Refresh Token Migration ===" -ForegroundColor Cyan
Write-Host "Database: $Database @ $Server`n"

$sql_statements = @(
    "ALTER TABLE usuario ADD COLUMN refresh_token_hash VARCHAR(512) DEFAULT NULL;",
    "ALTER TABLE usuario ADD COLUMN refresh_token_expires DATETIME DEFAULT NULL;",
    "ALTER TABLE usuario ADD COLUMN last_login DATETIME DEFAULT NULL;"
)

function Invoke-MySQL {
    param([string]$Query)
    $args = @("-h", $Server, "-u", $User, "-D", $Database, "-e", $Query)
    if ($Password) { $args += "-p$Password" }
    $result = & mysql @args 2>&1
    return $LASTEXITCODE -eq 0, $result
}

$success = 0
$errors  = 0

foreach ($stmt in $sql_statements) {
    Write-Host "  $stmt" -ForegroundColor White -NoNewline
    $ok, $out = Invoke-MySQL -Query $stmt
    if ($ok -and -not ($out -match "Error")) {
        Write-Host " OK" -ForegroundColor Green
        $success++
    } else {
        Write-Host " SKIP ($out)" -ForegroundColor Yellow
        $errors++
    }
}

# Verify
Write-Host "`nVerifying columns..." -ForegroundColor Cyan
$verifySql = "SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='usuario' AND COLUMN_NAME IN ('refresh_token_hash','refresh_token_expires','last_login');"
$ok, $out = Invoke-MySQL -Query $verifySql
if ($ok) { Write-Host $out }

Write-Host "`nResult: $success applied, $errors skipped`n" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Yellow" })
