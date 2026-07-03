$ErrorActionPreference = 'Stop'
$dump  = 'C:\Program Files\MySQL\MySQL Server 5.5\bin\mysqldump.exe'
$dir   = 'c:\Users\Admin\Documents\GitHub\TicketsAPI\Database\backups'
$repoDb = 'c:\Users\Admin\Documents\GitHub\TicketsAPI\Database'
$db    = 'cdk_tkt_dev'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# 1) Backup limpio completo (estructura + datos + routines + triggers) para emergencias
$clean = Join-Path $dir "cdk_tkt_dev_CLEAN_$stamp.sql"
& $dump -u root -p1346 -h localhost --routines --triggers --events --single-transaction --databases $db --result-file=$clean 2>$null
Write-Output ("Backup limpio: {0} ({1:N0} bytes)" -f $clean, (Get-Item $clean).Length)

# 2) Solo procedimientos/funciones (versionable en repo, sin datos)
$routines = Join-Path $repoDb 'routines.sql'
& $dump -u root -p1346 -h localhost $db --routines --skip-triggers --no-create-info --no-data --no-create-db --skip-comments --result-file=$routines 2>$null
Write-Output ("Routines repo: {0} ({1:N0} bytes)" -f $routines, (Get-Item $routines).Length)

# 3) Solo triggers (versionable en repo, sin datos)
$triggers = Join-Path $repoDb 'triggers.sql'
& $dump -u root -p1346 -h localhost $db --triggers --skip-routines --no-create-info --no-data --no-create-db --skip-comments --result-file=$triggers 2>$null
Write-Output ("Triggers repo: {0} ({1:N0} bytes)" -f $triggers, (Get-Item $triggers).Length)
