$mysql = 'C:\Program Files\MySQL\MySQL Server 5.5\bin\mysql.exe'
$db = 'cdk_tkt_dev'
function Q($t,$sql){ Write-Output "===== $t ====="; & $mysql -u root -p1346 -h localhost $db -e $sql 2>$null; Write-Output "" }

Q "Tablas tkt_* RBAC (deben ser 0)" "SELECT COUNT(*) AS quedan FROM information_schema.TABLES WHERE TABLE_SCHEMA='cdk_tkt_dev' AND TABLE_NAME IN ('tkt_rol','tkt_permiso','tkt_rol_permiso','tkt_usuario_rol');"
Q "Seed procs (deben ser 0)" "SELECT COUNT(*) AS quedan FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='cdk_tkt_dev' AND ROUTINE_NAME LIKE 'seed_sp_tkt%';"
Q "Total procedures" "SELECT COUNT(*) AS procedures FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='cdk_tkt_dev' AND ROUTINE_TYPE='PROCEDURE';"
Q "Transicion 2->6 habilitada" "SELECT estado_from, estado_to, permiso_requerido, requiere_propietario, habilitado FROM tkt_transicion_regla WHERE estado_from=2 AND estado_to=6;"
Q "Permiso TKT_VIEW_DETAIL existe" "SELECT idPermiso, codigo FROM permiso WHERE codigo='TKT_VIEW_DETAIL';"
Q "Matriz rol_permiso final" "SELECT r.nombre AS rol, COUNT(rp.idPermiso) AS n_permisos, GROUP_CONCAT(p.codigo ORDER BY p.codigo SEPARATOR ',') AS permisos FROM rol r LEFT JOIN rol_permiso rp ON r.idRol=rp.idRol LEFT JOIN permiso p ON p.idPermiso=rp.idPermiso GROUP BY r.idRol ORDER BY r.idRol;"
Q "usuario_rol (admin intacto)" "SELECT ur.idUsuario, u.nombre, ur.idRol, r.nombre AS rol FROM usuario_rol ur JOIN usuario u ON u.idUsuario=ur.idUsuario JOIN rol r ON r.idRol=ur.idRol;"
Q "SPs siguen referenciando tkt_* RBAC? (debe 0)" "SELECT ROUTINE_NAME FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='cdk_tkt_dev' AND (ROUTINE_DEFINITION LIKE '%tkt_usuario_rol%' OR ROUTINE_DEFINITION LIKE '%tkt_rol_permiso%' OR ROUTINE_DEFINITION LIKE '%tkt_permiso%' OR ROUTINE_DEFINITION LIKE '%tkt_rol %');"
