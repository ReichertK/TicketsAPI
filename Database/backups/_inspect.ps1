$mysql = 'C:\Program Files\MySQL\MySQL Server 5.5\bin\mysql.exe'
$sps = @('sp_control_usuario','validar_usuario','sp_listar_UsuEmpSucPerSis','test_sp_fill_audit_log','test_sp_fill_audit_fast')
foreach ($sp in $sps) {
    Write-Output "======================== $sp ========================"
    $sql = "SELECT ROUTINE_DEFINITION FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='cdk_tkt_dev' AND ROUTINE_NAME='$sp';"
    & $mysql -u root -p1346 -h localhost -N -B -e $sql 2>$null
    Write-Output ""
}
