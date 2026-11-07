param([string]$Sql, [string]$Db = 'postgres')
$e2e = Split-Path -Parent $MyInvocation.MyCommand.Path
$env:PGPASSWORD = [IO.File]::ReadAllText("$e2e\pw.txt")
try {
  & 'D:\PostgreSQL\18\bin\psql.exe' -h 127.0.0.1 -p 55432 -U lp_e2e_admin -d $Db -At -v ON_ERROR_STOP=1 -c $Sql 2>&1
} finally {
  Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}
