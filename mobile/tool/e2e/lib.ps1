# E2E helper library (scratch only). Targets ONLY the local test API.
$script:E2E = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:Base = 'http://127.0.0.1:5199'
$script:Api = Join-Path $script:E2E '..\backend-src\backend\src\LanguagePlatform.Api\bin\Debug\net10.0'

function Call {
  param([string]$Method, [string]$Path, $Body = $null, [string]$Token = $null,
        [byte[]]$RawBody = $null, [string]$RawType = $null)
  $h = @{ Accept = 'application/json' }
  if ($Token) { $h['Authorization'] = "Bearer $Token" }
  $args2 = @{ Uri = "$script:Base$Path"; Method = $Method; Headers = $h; UseBasicParsing = $true; TimeoutSec = 60 }
  if ($RawBody) { $args2['Body'] = $RawBody; $args2['ContentType'] = $RawType }
  elseif ($null -ne $Body) {
    $json = if ($Body -is [string]) { $Body } else { $Body | ConvertTo-Json -Depth 20 -Compress }
    $args2['Body'] = [Text.Encoding]::UTF8.GetBytes($json)
    $args2['ContentType'] = 'application/json; charset=utf-8'
  }
  try {
    $r = Invoke-WebRequest @args2
    $text = if ($r.Content -is [byte[]]) { [Text.Encoding]::UTF8.GetString($r.Content) } else { [string]$r.Content }
    $obj = $null
    if ($text) { try { $obj = $text | ConvertFrom-Json } catch { } }
    return [pscustomobject]@{ Status = [int]$r.StatusCode; Json = $obj; Raw = $text }
  } catch {
    $resp = $_.Exception.Response
    if ($resp) {
      $sr = New-Object IO.StreamReader($resp.GetResponseStream(), [Text.Encoding]::UTF8)
      $t = $sr.ReadToEnd()
      return [pscustomobject]@{ Status = [int]$resp.StatusCode; Json = $null; Raw = $t }
    }
    throw
  }
}

function New-Base32Seed {
  $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'
  $bytes = New-Object byte[] 32
  [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
  -join ($bytes | ForEach-Object { $alphabet[$_ % 32] })
}

function Get-Totp {
  param([string]$Base32, [long]$Offset = 0)
  $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'
  $bits = ''
  foreach ($c in $Base32.ToCharArray()) { $bits += [Convert]::ToString($alphabet.IndexOf($c), 2).PadLeft(5, '0') }
  $key = for ($i = 0; $i + 8 -le $bits.Length; $i += 8) { [Convert]::ToByte($bits.Substring($i, 8), 2) }
  $counter = [long][math]::Floor([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() / 30) + $Offset
  $cb = [BitConverter]::GetBytes($counter); [Array]::Reverse($cb)
  $hmac = New-Object Security.Cryptography.HMACSHA1(, [byte[]]$key)
  $h = $hmac.ComputeHash($cb)
  $o = [int]$h[$h.Length - 1] -band 0x0f
  $bin = (([int]$h[$o] -band 0x7f) -shl 24) -bor ([int]$h[$o + 1] -shl 16) -bor ([int]$h[$o + 2] -shl 8) -bor [int]$h[$o + 3]
  ($bin % 1000000).ToString().PadLeft(6, '0')
}

function Wait-NextTotpWindow {
  # A consumed code is rejected: wait for the next 30-second step.
  $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  $wait = 31 - ($now % 30)
  Start-Sleep -Seconds $wait
}

function Get-OutboxEntry {
  param([string]$Kind, [string]$Email)
  $path = Join-Path $script:E2E 'outbox.jsonl'
  for ($i = 0; $i -lt 20; $i++) {
    if (Test-Path $path) {
      $lines = Get-Content $path -Encoding UTF8 | ForEach-Object { $_ | ConvertFrom-Json }
      $m = $lines | Where-Object { $_.kind -eq $Kind -and $_.email -eq $Email } | Select-Object -Last 1
      if ($m) { return $m }
    }
    Start-Sleep -Milliseconds 500
  }
  throw "no $Kind email captured for $Email"
}

function Register-Confirmed {
  param([string]$Email, [string]$Password)
  $r = Call POST '/api/v1/auth/register' @{ email = $Email; password = $Password }
  if ($r.Status -ne 202) { throw "register $Email -> $($r.Status)" }
  $mail = Get-OutboxEntry -Kind confirm -Email $Email
  $c = Call POST '/api/v1/auth/confirm-email' @{ userId = $mail.userId; code = $mail.code }
  if ($c.Status -ne 204) { throw "confirm $Email -> $($c.Status)" }
  return [string]$mail.userId
}

function Invoke-Operator {
  param([string[]]$OperatorArgs, [hashtable]$ExtraEnv = @{})
  $pw = [IO.File]::ReadAllText((Join-Path $script:E2E 'pw.txt'))
  $env:ASPNETCORE_ENVIRONMENT = 'Development'
  $env:ConnectionStrings__LanguagePlatform = "Host=127.0.0.1;Port=55432;Database=language_platform_dev;Username=lp_e2e_admin;Password=$pw"
  $env:Operator__ExpectedHost = '127.0.0.1'
  $env:Operator__ExpectedDatabase = 'language_platform_dev'
  foreach ($k in $ExtraEnv.Keys) { Set-Item "Env:$k" $ExtraEnv[$k] }
  Push-Location $script:Api
  try { & dotnet .\LanguagePlatform.Api.dll operator @OperatorArgs 2>&1 | Where-Object { $_ -notmatch 'Password' } }
  finally {
    Pop-Location
    foreach ($k in $ExtraEnv.Keys) { Remove-Item "Env:$k" -ErrorAction SilentlyContinue }
    Remove-Item Env:ConnectionStrings__LanguagePlatform -ErrorAction SilentlyContinue
  }
}
