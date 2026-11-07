$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'lib.ps1')
$acc = Get-Content (Join-Path $script:E2E 'accounts.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$content = Get-Content (Join-Path $script:E2E 'content.json') -Raw -Encoding UTF8 | ConvertFrom-Json

function Fail($what, $r) { throw "$what -> $($r.Status): $($r.Raw)" }

# --- teacher sign-in with a FRESH authenticator code ------------------------
Wait-NextTotpWindow
$login = Call POST '/api/v1/auth/login' @{ email = $acc.teacher.email; password = $acc.teacher.password; authenticatorCode = (Get-Totp $acc.teacher.totpSeed) }
if ($login.Status -ne 200) { Fail 'teacher login' $login }
$tok = $login.Json.accessToken
'teacher signed in'

# --- minimal valid one-page PDF (no embedded text: lines are entered by hand)
$parts = @("%PDF-1.4`n", "1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj`n", "2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj`n",
           "3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 200 200]>>endobj`n")
$offsets = @(); $pos = $parts[0].Length
for ($i = 1; $i -le 3; $i++) { $offsets += $pos; $pos += $parts[$i].Length }
$nl = [string][char]10
$xref = "xref$nl" + '0 4' + $nl + '0000000000 65535 f ' + $nl + (($offsets | ForEach-Object { $_.ToString().PadLeft(10, '0') + ' 00000 n ' + $nl }) -join '')
$pdfText = ($parts -join '') + $xref + "trailer<</Size 4/Root 1 0 R>>`nstartxref`n$pos`n%%EOF`n"
$pdfBytes = [Text.Encoding]::ASCII.GetBytes($pdfText)

# --- course -----------------------------------------------------------------
$slug = 'e2e-modern-arabic-' + (Get-Date -Format 'HHmmss')
$course = Call POST '/api/v1/admin/five-stage/courses' @{ slug = $slug; title = 'Modern Arapça (E2E sentetik)'; description = 'Yalnızca uçtan uca test.' } $tok
if ($course.Status -notin 200, 201) { Fail 'create course' $course }
$courseId = if ($course.Json.courseId) { $course.Json.courseId } else { $course.Json.id }
$a1 = $course.Json.levels | Where-Object { $_.code -eq 'A1' }
"course $courseId levels=$($course.Json.levels.Count) a1=$($a1.id)"

$weights = @{ Reading = 30; Speaking = 20; Listening = 20; Writing = 15; Translation = 15 }
$key = @()

function Q-Choice($q) {
  $opts = @(); for ($i = 0; $i -lt $q.options.Count; $i++) { $opts += @{ text = $q.options[$i]; isCorrect = ($i -eq $q.correct) } }
  @{ kind = $q.kind; prompt = $q.prompt; options = $opts; correctValue = $null }
}

for ($li = 0; $li -lt $content.lessons.Count; $li++) {
  $L = $content.lessons[$li]; $pos = $li + 1
  $reading = @(); $listening = @(); $writing = @(); $translation = @()
  foreach ($q in $L.reading) {
    if ($q.kind -eq 'TrueFalse') {
      $reading += @{ kind = 'TrueFalse'; prompt = $q.prompt; options = $null; correctValue = [bool]$q.value }
      $key += @{ lesson = $pos; stage = 'reading'; prompt = $q.prompt; type = 'TrueFalse'; value = [bool]$q.value }
    } else {
      $reading += (Q-Choice $q)
      $key += @{ lesson = $pos; stage = 'reading'; prompt = $q.prompt; type = 'MultipleChoice'; optionText = $q.options[$q.correct] }
    }
  }
  foreach ($q in $L.listening) {
    $x = Q-Choice $q; $x.kind = 'WordBank'; $listening += $x
    $key += @{ lesson = $pos; stage = 'listening'; prompt = $q.prompt; type = 'WordBank'; optionText = $q.options[$q.correct] }
  }
  foreach ($q in $L.writing) {
    if ($q.kind -eq 'FillBlank') {
      $writing += @{ kind = 'FillBlank'; prompt = $q.prompt; options = $null; correctValue = $null; acceptedAnswers = @($q.answers) }
      $key += @{ lesson = $pos; stage = 'writing'; prompt = $q.prompt; type = 'FillBlank'; text = $q.answers[0] }
    } else {
      $opts = @($q.tokens | ForEach-Object { @{ text = $_; isCorrect = $false } })
      $writing += @{ kind = 'WordOrder'; prompt = $q.prompt; options = $opts; correctValue = $null; correctOrder = @($q.order) }
      $key += @{ lesson = $pos; stage = 'writing'; prompt = $q.prompt; type = 'WordOrder'; orderTexts = @($q.order | ForEach-Object { $q.tokens[$_] }) }
    }
  }
  foreach ($q in $L.translation) {
    if ($q.kind -eq 'ExactText') {
      $translation += @{ kind = 'ExactText'; prompt = $q.prompt; options = $null; correctValue = $null; acceptedAnswers = @($q.answers) }
      $key += @{ lesson = $pos; stage = 'translation'; prompt = $q.prompt; type = 'ExactText'; text = $q.answers[0] }
    } else {
      $translation += (Q-Choice $q)
      $key += @{ lesson = $pos; stage = 'translation'; prompt = $q.prompt; type = 'MultipleChoice'; optionText = $q.options[$q.correct] }
    }
  }
  $video = if ($pos -eq 1) { @{ url = 'https://media.example.test/a1/l1-intro.mp4'; title = 'Giris videosu (sentetik)' } } else { $null }
  $stages = @(
    @{ kind = 'reading';     weight = $weights.Reading;     maximumAttempts = 5; arabicText = $L.arabicText; turkishText = $L.turkishText; questions = $reading; teacherVideo = $video }
    @{ kind = 'speaking';    weight = $weights.Speaking;    maximumAttempts = 5; arabicText = $L.speakingPrompt; turkishText = $null; questions = $null; evaluationRubric = $L.rubric }
    @{ kind = 'listening';   weight = $weights.Listening;   maximumAttempts = 5; arabicText = $null; turkishText = $null; questions = $listening; audioUrl = 'https://media.example.test/a1/l1-listening.mp3' }
    @{ kind = 'writing';     weight = $weights.Writing;     maximumAttempts = 5; arabicText = $null; turkishText = $null; questions = $writing }
    @{ kind = 'translation'; weight = $weights.Translation; maximumAttempts = 5; arabicText = $null; turkishText = $null; questions = $translation }
  )
  $draft = Call POST "/api/v1/admin/five-stage/courses/$courseId/levels/$($a1.id)/slots/$pos/versions" @{ title = $L.title; approveWeights = $true; attemptSelection = 1; stages = $stages } $tok
  if ($draft.Status -notin 200, 201) { Fail "draft lesson $pos" $draft }
  $versionId = $draft.Json.versionId; $rev = [long]$draft.Json.revision
  "lesson $pos draft: version=$versionId rev=$rev weightsApproved=$($draft.Json.weightsApproved)"

  if ($L.pdfLines.Count -gt 0) {
    $q = "expectedVersion=$rev&title=$([uri]::EscapeDataString('Ders 1 PDF (sentetik)'))&copyrightNotice=$([uri]::EscapeDataString('Sentetik test materyali'))"
    $up = Call POST "/api/v1/admin/five-stage/versions/$versionId/reading-pdf?$q" $null $tok -RawBody $pdfBytes -RawType 'application/pdf'
    if ($up.Status -notin 200, 201) { Fail 'pdf upload' $up }
    $rev = [long]$up.Json.revision
    $rv = Call PUT "/api/v1/admin/five-stage/versions/$versionId/reading-pdf/review" @{ expectedVersion = $rev; pages = @(@{ page = 1; lines = @($L.pdfLines) }) } $tok
    if ($rv.Status -ne 200) { Fail 'pdf review' $rv }
    $rev = if ($rv.Json.revision) { [long]$rv.Json.revision } else { [long]$rv.Json }
    'pdf uploaded and lines approved'
  }

  $rr = Call POST "/api/v1/admin/five-stage/versions/$versionId/review" @{ expectedVersion = $rev } $tok
  if ($rr.Status -ne 200) { Fail "review lesson $pos" $rr }
  $rev = if ($rr.Json.revision) { [long]$rr.Json.revision } else { [long]$rr.Json }
  $pub = Call POST "/api/v1/admin/lesson-versions/$versionId/publish" @{ expectedVersion = $rev } $tok
  if ($pub.Status -ne 204) { Fail "publish lesson $pos" $pub }
  "lesson $pos published"
  if ($pos -eq 1) {
    $cp = Call POST "/api/v1/admin/five-stage/courses/$courseId/publish" $null $tok
    if ($cp.Status -ne 204) { Fail 'publish course' $cp }
    'course published'
  }
}

$out = @{ courseId = $courseId; levelId = $a1.id; key = $key; apiBase = $script:Base }
[IO.File]::WriteAllText((Join-Path $script:E2E 'answerkey.json'), ($out | ConvertTo-Json -Depth 8), (New-Object Text.UTF8Encoding($false)))
'authoring done; answer key saved'
