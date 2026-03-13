# Script para ejecutar migración de refresh_token en MySQL 5.5
# Compatible: Windows PowerShell 5.0+
# Requisitos: mysql.exe debe estar en PATH

param(
    [string]$Server = "localhost",
    [string]$User = "root",
    [string]$Database = "cdk_tkt_dev",
    [string]$Password = ""
)

Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                   MIGRACIÓN REFRESH TOKEN - FASE 0                             ║" -ForegroundColor Cyan
Write-Host "║                    Base de datos: $Database" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "[1] Conectando a MySQL ($Server)..." -ForegroundColor Yellow

# SQL statements a ejecutar
$sql_statements = @(
    "ALTER TABLE usuario ADD COLUMN refresh_token_hash VARCHAR(512) DEFAULT NULL;",
    "ALTER TABLE usuario ADD COLUMN refresh_token_expires DATETIME DEFAULT NULL;",
    "ALTER TABLE usuario ADD COLUMN last_login DATETIME DEFAULT NULL;"
)

# Función para ejecutar query
function Execute-MySQLQuery {
    param(
        [string]$Query,
        [string]$Server,
        [string]$User,
        [string]$Database,
        [string]$Password
    )
    
    if ($Password) {
        $password_arg = "-p$Password"
    } else {
        $password_arg = ""
    }
    
    try {
        # Ejecutar query
        $result = mysql -h $Server -u $User $password_arg -D $Database -e $Query 2>&1
        return $true, $result
    }
    catch {
        return $false, $_.Exception.Message
    }
}

# Ejecutar cada statement
$success_count = 0
$error_count = 0

foreach ($stmt in $sql_statements) {
    Write-Host ""
    Write-Host "Ejecutando: $stmt" -ForegroundColor White
    
    $success, $result = Execute-MySQLQuery -Query $stmt -Server $Server -User $User -Database $Database -Password $Password
    
    if ($success -and -not ($result -match "Error")) {
        Write-Host "✅ Exitoso" -ForegroundColor Green
        $success_count++
    }
    else {
        Write-Host "❌ Error: $result" -ForegroundColor Red
        $error_count++
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                           RESULTADO DE MIGRACIÓN                              ║" -ForegroundColor Cyan
Write-Host "╠════════════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║ Exitosos: $success_count/3" -ForegroundColor Green
Write-Host "║ Errores:  $error_count/3" -ForegroundColor Yellow
Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Verificar si las columnas fueron creadas
Write-Host ""
Write-Host "[2] Verificando columnas en tabla 'usuario'..." -ForegroundColor Yellow

$verify_sql = "SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='usuario' AND COLUMN_NAME IN ('refresh_token_hash', 'refresh_token_expires', 'last_login') ORDER BY ORDINAL_POSITION DESC LIMIT 3;"

$verify_success, $verify_result = Execute-MySQLQuery -Query $verify_sql -Server $Server -User $User -Database $Database -Password $Password

if ($verify_success) {
    Write-Host ""
    Write-Host "Columnas en tabla 'usuario':" -ForegroundColor Green
    Write-Host $verify_result
}
else {
    Write-Host "Error en verificación: $verify_result" -ForegroundColor Red
}

Write-Host ""
Write-Host "[3] Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Compilar API: dotnet build" -ForegroundColor Gray
Write-Host "  2. Ejecutar tests: dotnet test" -ForegroundColor Gray
Write-Host "  3. Correr API: dotnet run" -ForegroundColor Gray
Write-Host "  4. Probar en Swagger: http://localhost:5000/swagger" -ForegroundColor Gray

if ($success_count -eq 3) {
    Write-Host ""
    Write-Host "✅ MIGRACIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
    exit 0
}
else {
    Write-Host ""
    Write-Host "⚠️  HUBO ERRORES EN LA MIGRACIÓN" -ForegroundColor Yellow
    exit 1
}
