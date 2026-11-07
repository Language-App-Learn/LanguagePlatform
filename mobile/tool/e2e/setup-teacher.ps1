. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'lib.ps1')
$pw = [IO.File]::ReadAllText((Join-Path $script:E2E 'pw.txt'))
$accPath = Join-Path $script:E2E 'accounts.json'
$acc = Get-Content $accPath -Raw -Encoding UTF8 | ConvertFrom-Json

$b = New-Object byte[] 12; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
$teacherPw = 'Aa1!' + [Convert]::ToBase64String($b).Replace('+','x').Replace('/','y').Replace('=','z')
$teacherEmail = 'e2e.teacher.c3@lp-e2e2.invalid'
$id = Register-Confirmed -Email $teacherEmail -Password $teacherPw
$seed = New-Base32Seed
# Persist BEFORE enrolling so the seed can never be lost.
$acc.teacher = [pscustomobject]@{ email = $teacherEmail; password = $teacherPw; totpSeed = $seed; id = $id }
[IO.File]::WriteAllText($accPath, ($acc | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))

function Run-Operator([string[]]$opArgs, [hashtable]$extra = @{}) {
  $env:ASPNETCORE_ENVIRONMENT = 'Development'
  $env:Logging__LogLevel__Default = 'Warning'
  $env:ConnectionStrings__LanguagePlatform = "Host=127.0.0.1;Port=55432;Database=language_platform_dev;Username=lp_e2e_admin;Password=$pw"
  $env:Operator__ExpectedHost = '127.0.0.1'
  $env:Operator__ExpectedDatabase = 'language_platform_dev'
  foreach ($k in $extra.Keys) { Set-Item "Env:$k" $extra[$k] }
  Push-Location $script:Api
  try { & dotnet .\LanguagePlatform.Api.dll operator @opArgs 2>&1 | Where-Object { $_ -notmatch 'Password' } | Select-Object -First 3 }
  finally { Pop-Location; foreach ($k in $extra.Keys) { Remove-Item "Env:$k" -ErrorAction SilentlyContinue } }
}

Run-Operator @('enroll-authenticator', $id) @{ LANGUAGEPLATFORM_OPERATOR_TOTP_KEY = $seed; LANGUAGEPLATFORM_OPERATOR_TOTP_CODE = (Get-Totp $seed) }
foreach ($perm in 'content.edit', 'content.publish', 'assessment.evaluate') { Run-Operator @('grant', $id, $perm) }
& (Join-Path $script:E2E 'pgcheck.ps1') -Db language_platform_dev -Sql "select email, two_factor_enabled from identity_users where email='$teacherEmail'"
& (Join-Path $script:E2E 'pgcheck.ps1') -Db language_platform_dev -Sql "select count(*) from identity_user_claims where user_id='$id'"
