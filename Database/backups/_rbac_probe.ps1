$mysql = 'C:\Program Files\MySQL\MySQL Server 5.5\bin\mysql.exe'
$db = 'cdk_tkt_dev'
function Q($t,$sql){ Write-Output "===== $t ====="; & $mysql -u root -p1346 -h localhost $db -e $sql 2>$null; Write-Output "" }

Q "usuario_rol (legacy) - asignaciones" "SELECT ur.idUsuario, u.nombre, ur.idRol, r.nombre AS rol FROM usuario_rol ur LEFT JOIN usuario u ON u.idUsuario=ur.idUsuario LEFT JOIN rol r ON r.idRol=ur.idRol ORDER BY ur.idUsuario;"
Q "tkt_usuario_rol (nuevo) - asignaciones" "SELECT tur.idUsuario, u.nombre, tur.id_rol, tr.nombre AS rol FROM tkt_usuario_rol tur LEFT JOIN usuario u ON u.idUsuario=tur.idUsuario LEFT JOIN tkt_rol tr ON tr.id_rol=tur.id_rol ORDER BY tur.idUsuario;"
Q "conteos" "SELECT (SELECT COUNT(*) FROM usuario_rol) AS usuario_rol, (SELECT COUNT(*) FROM tkt_usuario_rol) AS tkt_usuario_rol, (SELECT COUNT(*) FROM rol) AS rol, (SELECT COUNT(*) FROM tkt_rol) AS tkt_rol, (SELECT COUNT(*) FROM permiso) AS permiso, (SELECT COUNT(*) FROM tkt_permiso) AS tkt_permiso, (SELECT COUNT(*) FROM rol_permiso) AS rol_permiso, (SELECT COUNT(*) FROM tkt_rol_permiso) AS tkt_rol_permiso;"
Q "usuarios" "SELECT idUsuario, nombre, usuario, idRol, fechaBaja FROM usuario ORDER BY idUsuario;"
Q "columna idRol en usuario?" "SHOW COLUMNS FROM usuario LIKE '%rol%';"
Q "matriz rol_permiso legacy" "SELECT r.nombre AS rol, GROUP_CONCAT(p.codigo ORDER BY p.codigo SEPARATOR ', ') AS permisos FROM rol r LEFT JOIN rol_permiso rp ON r.idRol=rp.idRol LEFT JOIN permiso p ON p.idPermiso=rp.idPermiso GROUP BY r.idRol;"
Q "FKs que apuntan a rol/tkt_rol" "SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA='cdk_tkt_dev' AND REFERENCED_TABLE_NAME IN ('rol','tkt_rol','permiso','tkt_permiso');"
