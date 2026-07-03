$ErrorActionPreference = 'Stop'
$mysqldump = 'C:\Program Files\MySQL\MySQL Server 5.5\bin\mysqldump.exe'
$dir = 'c:\Users\Admin\Documents\GitHub\TicketsAPI\Database\backups'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$out = Join-Path $dir "cdk_tkt_dev_FULL_$stamp.sql"
& $mysqldump -u root -p1346 -h localhost --routines --triggers --events --single-transaction --databases cdk_tkt_dev --result-file=$out 2>$null
if (Test-Path $out) {
    Write-Output "OK BACKUP -> $out"
    Write-Output ("Tamano: {0:N0} bytes" -f (Get-Item $out).Length)
} else {
    Write-Output 'FALLO EL BACKUP'
}
