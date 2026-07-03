$mysql = 'C:\Program Files\MySQL\MySQL Server 5.5\bin\mysql.exe'
$dir   = 'c:\Users\Admin\Documents\GitHub\TicketsAPI\Database\backups'
$db    = 'cdk_tkt_dev'

# ===== LISTA BLANCA: procedimientos del sistema de TICKETS (se conservan) =====
$keepProcs = @(
    # Core tickets
    'sp_agregar_tkt','sp_actualizar_tkt','sp_eliminar_ticket','sp_asignar_ticket',
    'sp_listar_tkts','sp_obtener_detalle_ticket','sp_tkt_transicionar','sp_tkt_todos',
    'sp_tkt_mis_tickets','sp_tkt_cola_trabajo','sp_tkt_comentar','sp_tkt_comentarios_por_ticket',
    'sp_tkt_historial','sp_tkt_gestionar_suscripcion',
    # Dashboard / stats / search
    'sp_dashboard_tickets','sp_ticket_stats','sp_global_search',
    # Alertas / notificaciones
    'sp_alertas_no_leidas','sp_marcar_alerta_leida','sp_crear_alerta_mencion','sp_obtener_resumen_notificaciones',
    # Catalogos
    'sp_departamento_crear','sp_departamento_actualizar','sp_estado_crear','sp_editar_estado',
    'sp_prioridad_crear','sp_editar_prioridad','sp_motivo_crear','sp_editar_motivo',
    # RBAC
    'sp_rol_guardar','sp_rol_listar','sp_rol_eliminar','sp_rol_permiso_gestionar',
    'sp_permiso_guardar','sp_permiso_listar','sp_tkt_permisos_por_usuario',
    # Usuarios
    'sp_agregar_usuario','sp_editar_usuario','sp_eliminar_usuario','sp_listar_usuario',
    'sp_obtener_usuarios','sp_usuario_reset_password',
    # Seeds de tickets
    'seed_sp_tkt_permiso_crear','seed_sp_tkt_rol_crear','seed_sp_tkt_rol_permiso_asignar',
    'seed_sp_tkt_seed_basico','seed_sp_tkt_usuario_rol_asignar'
)
# Funciones a conservar: NINGUNA (las 48 fun* son del sistema contable CEDIAC)
$keepFuncs = @()

$keepProcsLc = $keepProcs | ForEach-Object { $_.ToLower() }
$keepFuncsLc = $keepFuncs | ForEach-Object { $_.ToLower() }

# Traer todas las routines actuales
$rows = & $mysql -u root -p1346 -h localhost -N -B -e "SELECT ROUTINE_TYPE, ROUTINE_NAME FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='$db';" 2>$null

$dropStatements = @()
$keptCount = 0
$dropList = @()
foreach ($line in $rows) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split "`t"
    $type = $parts[0].Trim()
    $name = $parts[1].Trim()
    $nameLc = $name.ToLower()
    $keep = $false
    if ($type -eq 'PROCEDURE' -and $keepProcsLc -contains $nameLc) { $keep = $true }
    if ($type -eq 'FUNCTION'  -and $keepFuncsLc -contains $nameLc) { $keep = $true }
    if ($keep) {
        $keptCount++
    } else {
        $dropStatements += "DROP $type IF EXISTS `$db`.``$name``;".Replace('$db',$db)
        $dropList += "$type`t$name"
    }
}

# Guardar el script de DROP para registro
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dropFile = Join-Path $dir "_cleanup_drops_$stamp.sql"
$dropStatements -join "`r`n" | Out-File -FilePath $dropFile -Encoding utf8

Write-Output "===== RESUMEN ====="
Write-Output "Routines conservadas (tickets): $keptCount"
Write-Output "Routines a eliminar (basura CEDIAC/test): $($dropList.Count)"
Write-Output "Script de DROP guardado en: $dropFile"
Write-Output ""
Write-Output "===== SE VAN A ELIMINAR ====="
$dropList | Sort-Object | ForEach-Object { Write-Output $_ }
