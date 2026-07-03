$mysql = 'C:\Program Files\MySQL\MySQL Server 5.5\bin\mysql.exe'
$db = 'cdk_tkt_dev'
function Q($t,$sql){ Write-Output "===== $t ====="; & $mysql -u root -p1346 -h localhost $db -e $sql 2>$null; Write-Output "" }

Q "permiso legacy (todos)" "SELECT idPermiso, codigo, descripcion, Modulo FROM permiso ORDER BY idPermiso;"
Q "rol legacy" "SELECT idRol, nombre FROM rol ORDER BY idRol;"
Q "rol_permiso legacy (ids)" "SELECT idRol, idPermiso FROM rol_permiso ORDER BY idRol, idPermiso;"
Q "tkt_permiso (todos)" "SELECT id_permiso, codigo, descripcion FROM tkt_permiso ORDER BY codigo;"
Q "columnas tabla rol" "SHOW COLUMNS FROM rol;"
Q "columnas tabla permiso" "SHOW COLUMNS FROM permiso;"
Q "columnas rol_permiso" "SHOW COLUMNS FROM rol_permiso;"
Q "columnas usuario_rol" "SHOW COLUMNS FROM usuario_rol;"
Q "TKT_VIEW_DETAIL en legacy?" "SELECT COUNT(*) AS existe FROM permiso WHERE codigo='TKT_VIEW_DETAIL';"
