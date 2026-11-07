[CmdletBinding()]
param([Parameter(Mandatory)][string]$PostgreSqlBin, [Parameter(Mandatory)][string]$MigrationSql)

$ErrorActionPreference = 'Stop'
$sqlFile = (Resolve-Path -LiteralPath $MigrationSql).Path
$toolsDir = (Resolve-Path -LiteralPath $PostgreSqlBin).Path
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
$folder = [IO.Directory]::CreateTempSubdirectory('lp-restore-')
$data = Join-Path $folder.FullName 'data'
$archive = Join-Path $folder.FullName 'backup.dump'
$previousPassword = $env:PGPASSWORD
$started = $false

function Invoke-PgTool {
    param([string]$ToolName, [string[]]$ToolArgs)
    $suffix = if ($IsWindows) { '.exe' } else { '' }
    $executable = Join-Path $toolsDir ($ToolName + $suffix)
    & $executable @ToolArgs
    if ($LASTEXITCODE -ne 0) { throw "$ToolName failed with exit code $LASTEXITCODE." }
}

try {
    $version = Invoke-PgTool -ToolName 'postgres' -ToolArgs @('--version')
    if ($version -notmatch 'PostgreSQL\) 18\.') { throw 'PostgreSQL 18 tools are required.' }
    $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
    $listener.Start()
    try { $port = $listener.LocalEndpoint.Port } finally { $listener.Stop() }
    $portText = $port.ToString([Globalization.CultureInfo]::InvariantCulture)
    $connection = @('-h', '127.0.0.1', '-p', $portText, '-U', 'lp_backup_test', '-w')
    $passwordFile = Join-Path $folder.FullName 'init-password'
    $env:PGPASSWORD = [Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
    try {
        [IO.File]::WriteAllText($passwordFile, $env:PGPASSWORD)
        Invoke-PgTool -ToolName 'initdb' -ToolArgs @('-D', $data, '-U', 'lp_backup_test', '-A', 'scram-sha-256',
            "--pwfile=$passwordFile", '--encoding=UTF8', '--locale=C') | Out-Null
    } finally {
        if (Test-Path -LiteralPath $passwordFile) { Remove-Item -LiteralPath $passwordFile -Force }
    }
    Invoke-PgTool -ToolName 'pg_ctl' -ToolArgs @('-D', $data, '-w', '-t', '20',
        '-l', (Join-Path $folder.FullName 'postgres.log'), '-o', "-h 127.0.0.1 -p $portText", 'start')
    $started = $true
    Invoke-PgTool -ToolName 'createdb' -ToolArgs ($connection + @('language_platform_test'))
    Invoke-PgTool -ToolName 'createdb' -ToolArgs ($connection + @('language_platform_restore_test'))
    $psqlArgs = $connection + @('-X', '-v', 'ON_ERROR_STOP=1')
    Invoke-PgTool -ToolName 'psql' -ToolArgs ($psqlArgs + @('-d', 'language_platform_test', '-f', $sqlFile)) | Out-Null
    $seedSql = "CREATE TABLE restore_rehearsal (id integer PRIMARY KEY, payload text NOT NULL); INSERT INTO restore_rehearsal VALUES (1, U&'\0627\064E\0644\0633\064E\0651\0644\064E\0627\0645');"
    Invoke-PgTool -ToolName 'psql' -ToolArgs ($psqlArgs + @('-d', 'language_platform_test', '-c', $seedSql)) | Out-Null
    Invoke-PgTool -ToolName 'pg_dump' -ToolArgs ($connection + @('-d', 'language_platform_test', '--format=custom', '-f', $archive))
    Invoke-PgTool -ToolName 'pg_restore' -ToolArgs ($connection + @('-d', 'language_platform_restore_test',
        '--no-owner', '--no-privileges', '--exit-on-error', '--single-transaction', $archive))
    $verifySql = 'SELECT (SELECT count(*) FROM "__EFMigrationsHistory")::text || '':'' || (SELECT encode(convert_to(payload, ''UTF8''), ''hex'') FROM restore_rehearsal WHERE id = 1);'
    $source = Invoke-PgTool -ToolName 'psql' -ToolArgs ($psqlArgs + @('-d', 'language_platform_test', '-Atc', $verifySql))
    $restored = Invoke-PgTool -ToolName 'psql' -ToolArgs ($psqlArgs + @('-d', 'language_platform_restore_test', '-Atc', $verifySql))
    if ($source -notmatch '^[1-9][0-9]*:[0-9a-f]+$' -or $restored -cne $source) { throw 'Restore integrity check failed.' }
    Write-Output "PostgreSQL 18 backup restored successfully. Matching migration count and UTF-8 sample: $restored"
} finally {
    $env:PGPASSWORD = $previousPassword
    if ($started) { Invoke-PgTool -ToolName 'pg_ctl' -ToolArgs @('-D', $data, '-w', '-t', '20', '-m', 'fast', 'stop') }
    $resolved = (Resolve-Path -LiteralPath $folder.FullName).Path
    if ($resolved -eq $folder.FullName -and [IO.Path]::GetDirectoryName($resolved) -eq $tempRoot -and
        $folder.Name -match '^lp-restore-[A-Za-z0-9]+$') {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
