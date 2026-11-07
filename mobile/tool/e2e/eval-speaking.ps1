param([string]$CourseId, [string]$LessonId, [string]$AssessmentId, [string]$AttemptId, [string]$Score)
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'lib.ps1')
$sessPath = Join-Path $script:E2E 'teacher-session.json'
$acc = Get-Content (Join-Path $script:E2E 'accounts.json') -Raw -Encoding UTF8 | ConvertFrom-Json

$tok = $null
if (Test-Path $sessPath) {
  $s = Get-Content $sessPath -Raw | ConvertFrom-Json
  $r = Call POST '/api/v1/auth/refresh' @{ refreshToken = $s.refreshToken }
  if ($r.Status -eq 200) { $tok = $r.Json.accessToken; $refresh = $r.Json.refreshToken }
}
if (-not $tok) {
  Wait-NextTotpWindow
  $r = Call POST '/api/v1/auth/login' @{ email = $acc.teacher.email; password = $acc.teacher.password; authenticatorCode = (Get-Totp $acc.teacher.totpSeed) }
  if ($r.Status -ne 200) { Write-Error "teacher login failed: $($r.Status)"; exit 3 }
  $tok = $r.Json.accessToken; $refresh = $r.Json.refreshToken
}
[IO.File]::WriteAllText($sessPath, (@{ refreshToken = $refresh } | ConvertTo-Json), (New-Object Text.UTF8Encoding($false)))

$path = "/api/v1/admin/courses/$CourseId/lessons/$LessonId/assessments/$AssessmentId/attempts/$AttemptId/speaking-evaluation"
$ctx = Call GET $path $null $tok
if ($ctx.Status -ne 200) { Write-Error "context -> $($ctx.Status)"; exit 4 }
$ev = Call POST $path "{`"score`":$Score}" $tok
"evaluation status: $($ev.Status)"
if ($ev.Status -notin 200, 204) { Write-Error $ev.Raw; exit 5 }
