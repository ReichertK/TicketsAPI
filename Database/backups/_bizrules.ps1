$mysql = 'C:\Program Files\MySQL\MySQL Server 5.5\bin\mysql.exe'
Write-Output "===== REGLAS DE TRANSICION (tkt_transicion_regla) ====="
& $mysql -u root -p1346 -h localhost cdk_tkt_dev -e "SELECT r.estado_from, ef.TipoEstado AS from_nom, r.estado_to, et.TipoEstado AS to_nom, r.requiere_propietario AS prop, r.permiso_requerido, r.requiere_aprobacion AS aprob, r.habilitado AS hab FROM tkt_transicion_regla r LEFT JOIN estado ef ON ef.Id_Estado=r.estado_from LEFT JOIN estado et ON et.Id_Estado=r.estado_to ORDER BY r.estado_from, r.estado_to;" 2>$null
Write-Output ""
Write-Output "===== ROLES tkt_rol ====="
& $mysql -u root -p1346 -h localhost cdk_tkt_dev -e "SELECT * FROM tkt_rol ORDER BY id_rol;" 2>$null
Write-Output ""
Write-Output "===== ROLES legacy (rol) ====="
& $mysql -u root -p1346 -h localhost cdk_tkt_dev -e "SELECT * FROM rol ORDER BY idRol;" 2>$null
Write-Output ""
Write-Output "===== PERMISOS tkt_permiso ====="
& $mysql -u root -p1346 -h localhost cdk_tkt_dev -e "SELECT id_permiso, codigo FROM tkt_permiso ORDER BY codigo;" 2>$null
Write-Output ""
Write-Output "===== PERMISOS legacy (permiso) ====="
& $mysql -u root -p1346 -h localhost cdk_tkt_dev -e "SELECT idPermiso, codigo FROM permiso ORDER BY codigo;" 2>$null
Write-Output ""
Write-Output "===== MATRIZ tkt_rol_permiso ====="
& $mysql -u root -p1346 -h localhost cdk_tkt_dev -e "SELECT tr.nombre AS rol, GROUP_CONCAT(tp.codigo ORDER BY tp.codigo SEPARATOR ', ') AS permisos FROM tkt_rol tr LEFT JOIN tkt_rol_permiso trp ON tr.id_rol=trp.id_rol LEFT JOIN tkt_permiso tp ON tp.id_permiso=trp.id_permiso GROUP BY tr.id_rol;" 2>$null
