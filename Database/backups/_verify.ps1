$mysql='C:\Program Files\MySQL\MySQL Server 5.5\bin\mysql.exe'
Write-Output "=== FKs rotas (apuntan a tablas eliminadas; debe estar vacio) ==="
& $mysql -u root -p1346 -h localhost -N -B -e "SELECT CONSTRAINT_NAME, TABLE_NAME, REFERENCED_TABLE_NAME FROM information_schema.KEY_COLUMN_USAGE k WHERE k.CONSTRAINT_SCHEMA='cdk_tkt_dev' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND k.REFERENCED_TABLE_NAME NOT IN (SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA='cdk_tkt_dev');" 2>$null
Write-Output "=== Triggers restantes ==="
& $mysql -u root -p1346 -h localhost -N -B -e "SELECT TRIGGER_NAME FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='cdk_tkt_dev' ORDER BY TRIGGER_NAME;" 2>$null
Write-Output "=== Conteo final routines ==="
& $mysql -u root -p1346 -h localhost -N -B -e "SELECT ROUTINE_TYPE, COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='cdk_tkt_dev' GROUP BY ROUTINE_TYPE;" 2>$null
