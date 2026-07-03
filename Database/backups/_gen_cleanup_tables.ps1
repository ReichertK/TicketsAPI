$mysql = 'C:\Program Files\MySQL\MySQL Server 5.5\bin\mysql.exe'
$dir   = 'c:\Users\Admin\Documents\GitHub\TicketsAPI\Database\backups'
$db    = 'cdk_tkt_dev'

# ===== LISTA BLANCA: tablas del sistema de TICKETS (se conservan) =====
$keepTables = @(
    'accion','audit_config','audit_log','departamento','empresa','error_log','estado',
    'failed_login_attempts','grupo','motivo','notificaciones','notificacion_alerta',
    'perfil','perfil_accion_sistema','permiso','prioridad','rol','rol_permiso','sistema','sucursal',
    'tkt','tkt_aprobacion','tkt_comentario','tkt_notificacion_lectura','tkt_permiso','tkt_rol',
    'tkt_rol_permiso','tkt_search','tkt_suscriptor','tkt_transicion','tkt_transicion_regla','tkt_usuario_rol',
    'usuario','usuario_empresa_sucursal_perfil_sistema','usuario_rol','usuario_tipo'
)
$keepLc = $keepTables | ForEach-Object { $_.ToLower() }

# Traer todas las tablas con su conteo de filas
$rows = & $mysql -u root -p1346 -h localhost -N -B -e "SELECT TABLE_NAME, IFNULL(TABLE_ROWS,0) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$db' AND TABLE_TYPE='BASE TABLE';" 2>$null

$dropList = @()
$dropWithData = @()
$keptCount = 0
foreach ($line in $rows) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split "`t"
    $name = $parts[0].Trim()
    $rowsN = [int]$parts[1].Trim()
    if ($keepLc -contains $name.ToLower()) {
        $keptCount++
    } else {
        $dropList += $name
        if ($rowsN -gt 0) { $dropWithData += "$name ($rowsN filas)" }
    }
}

# Generar script de DROP (con FK checks off) para registro
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dropFile = Join-Path $dir "_cleanup_tables_$stamp.sql"
$sb = @()
$sb += 'SET FOREIGN_KEY_CHECKS = 0;'
foreach ($t in $dropList) { $sb += "DROP TABLE IF EXISTS ``$t``;" }
$sb += 'SET FOREIGN_KEY_CHECKS = 1;'
$sb -join "`r`n" | Out-File -FilePath $dropFile -Encoding utf8

Write-Output "===== RESUMEN TABLAS ====="
Write-Output "Tablas conservadas (tickets): $keptCount"
Write-Output "Tablas a eliminar (basura): $($dropList.Count)"
Write-Output "Script guardado en: $dropFile"
Write-Output ""
if ($dropWithData.Count -gt 0) {
    Write-Output "*** ATENCION: tablas a eliminar CON DATOS ***"
    $dropWithData | ForEach-Object { Write-Output "  $_" }
} else {
    Write-Output "Todas las tablas a eliminar estan VACIAS (0 filas). Sin perdida de datos."
}
Write-Output ""
Write-Output "===== SE VAN A ELIMINAR ====="
$dropList | Sort-Object | ForEach-Object { Write-Output "  $_" }
