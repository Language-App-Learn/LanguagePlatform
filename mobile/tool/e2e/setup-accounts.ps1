$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'lib.ps1')

function New-Pw { $b = New-Object byte[] 12; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b); 'Aa1!' + [Convert]::ToBase64String($b).Replace('+','x').Replace('/','y').Replace('=','z') }

$studentEmail = 'e2e.student.a1@lp-e2e2.invalid'
$studentOther = 'e2e.student.b1@lp-e2e2.invalid'
$teacherEmail = 'e2e.teacher.a1@lp-e2e2.invalid'
$accounts = @{
  student  = @{ email = $studentEmail; password = (New-Pw) }
  student2 = @{ email = $studentOther; password = (New-Pw) }
  teacher  = @{ email = $teacherEmail; password = (New-Pw) }
}
$ids = @{}
foreach ($k in 'student','student2','teacher') {
  $ids[$k] = Register-Confirmed -Email $accounts[$k].email -Password $accounts[$k].password
  "registered+confirmed: $k"
}

[IO.File]::WriteAllText((Join-Path $script:E2E 'accounts.json'), (@{ student = $accounts.student; student2 = $accounts.student2; teacher = $accounts.teacher; ids = $ids } | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))
# Teacher: authenticator enrollment + individual permission grants (operator CLI).
$seed = New-Base32Seed
$code = Get-Totp $seed
Invoke-Operator -OperatorArgs @('enroll-authenticator', $ids.teacher) -ExtraEnv @{
  LANGUAGEPLATFORM_OPERATOR_TOTP_KEY = $seed; LANGUAGEPLATFORM_OPERATOR_TOTP_CODE = $code }
foreach ($perm in 'content.edit','content.publish','assessment.evaluate') {
  Invoke-Operator -OperatorArgs @('grant', $ids.teacher, $perm)
}

$accounts.teacher['totpSeed'] = $seed
$accounts['ids'] = $ids
[IO.File]::WriteAllText((Join-Path $script:E2E 'accounts.json'), ($accounts | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))
'accounts saved (not printed)'
