$e2e = Split-Path -Parent $MyInvocation.MyCommand.Path
$api = Join-Path $e2e '..\backend-src\backend\src\LanguagePlatform.Api\bin\Debug\net10.0'
$pw = [IO.File]::ReadAllText("$e2e\pw.txt")
$cs = "Host=127.0.0.1;Port=55432;Database=language_platform_dev;Username=lp_e2e_admin;Password=$pw"
$envs = @{
  ASPNETCORE_ENVIRONMENT = 'Development'
  ASPNETCORE_URLS = 'http://127.0.0.1:5199'
  ASPNETCORE_HOSTINGSTARTUPASSEMBLIES = 'E2eMailSink'
  DOTNET_ADDITIONAL_DEPS = (Join-Path $api 'E2eMailSink.deps.json')
  E2E_OUTBOX = "$e2e\outbox.jsonl"
  'ConnectionStrings__LanguagePlatform' = $cs
  'Database__ApplyMigrationsOnStartup' = 'true'
  'Database__SeedOnStartup' = 'true'
  'Operator__ExpectedHost' = '127.0.0.1'
  'Operator__ExpectedDatabase' = 'language_platform_dev'
}
foreach ($k in $envs.Keys) { Set-Item -Path "Env:$k" -Value $envs[$k] }
Set-Location $api
& dotnet .\LanguagePlatform.Api.dll *> "$e2e\api.log"
