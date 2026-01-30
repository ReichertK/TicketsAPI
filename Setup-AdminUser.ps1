$server = "localhost"
$user = "root"
$password = "1346"
$database = "cdk_tkt_dev"

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          CREAR USUARIO ADMIN - FASE 0                          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Array de comandos SQL
$sqlCommands = @(
    "INSERT IGNORE INTO rol (idRol, nombre, descripcion, estado) VALUES (1, 'Administrador', 'Rol de administrador del sistema', 1);",
    "INSERT INTO usuario (nombre, email, passwordUsuario, fechaAlta, tipo, idRol) VALUES ('admin', 'admin@system.com', 'admin123', CURDATE(), 'ADM', 1) ON DUPLICATE KEY UPDATE email='admin@system.com';",
    "SELECT idUsuario, nombre, email, idRol FROM usuario WHERE nombre = 'admin';"
)

foreach ($sql in $sqlCommands) {
    Write-Host ""
    Write-Host "Ejecutando: $sql" -ForegroundColor Yellow
    
    $cmd = "mysql -h $server -u $user -p$password -D $database -e `"$sql`""
    Invoke-Expression $cmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Exitoso" -ForegroundColor Green
    } else {
        Write-Host "❌ Error" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              USUARIO ADMIN CREADO                              ║" -ForegroundColor Cyan
Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║ Nombre de usuario: admin                                        ║" -ForegroundColor Green
Write-Host "║ Contraseña: admin123                                            ║" -ForegroundColor Green
Write-Host "║ Email: admin@system.com                                         ║" -ForegroundColor Green
Write-Host "║ Rol: Administrador                                              ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
