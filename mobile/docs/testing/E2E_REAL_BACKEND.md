# Real-backend end-to-end testing (disposable environment)

Goal: exercise the Flutter app's own transport, repositories and UI against the **real ASP.NET Core API and PostgreSQL**, never against production, never with real student data.

## Safety rules (all enforced by the procedure below)

* A **brand-new PostgreSQL cluster** is created with `initdb` in a scratch directory, bound to `127.0.0.1` on a spare port (55432) with a generated password stored only in a scratch file. The installed PostgreSQL service, its data directory and its databases (including `language_platform_dev` there) are never connected to.
* Verify the target before any migration: `select inet_server_addr(), inet_server_port(), current_database(), current_user, current_setting('data_directory')` must show `127.0.0.1/32`, `55432`, the scratch data directory and the scratch user.
* The backend is **exported** from the fetched ref with `git archive origin/Backend-Database` into the scratch directory and built there. The Flutter branch and the backend source are untouched.
* The API listens only on `http://127.0.0.1:5199` (`ASPNETCORE_ENVIRONMENT=Development`). Nothing is published to a network.
* All accounts and content are synthetic (`*@lp-e2e2.invalid`, "sentetik" lesson texts). Passwords and the teacher's authenticator seed are generated per run and written only to scratch files.
* Cleanup removes only what this procedure created (see the end); an existing database is never dropped.

## One-time layout (scratch directory `<work>`)

```
<work>/backend-src/        git archive of origin/Backend-Database
<work>/e2e/                copy of mobile/tool/e2e/* (scripts, content.json)
<work>/e2e/mailsink/       E2eMailSink.csproj + Sink.cs (build it, copy dll + deps.json next to the API dll)
<work>/e2e/pgdata/         initdb cluster      <work>/e2e/pw.txt   generated password
```

1. `dotnet build backend/src/LanguagePlatform.Api -c Debug` in `backend-src`.
2. `initdb -D e2e\pgdata -U lp_e2e_admin --pwfile=e2e\pw.txt -A scram-sha-256 -E UTF8 --locale=C`; start with `postgres.exe -D e2e\pgdata -p 55432 -c listen_addresses=127.0.0.1` (detached; do not use `pg_ctl start` in a captured shell, it keeps the pipe open).
3. `CREATE DATABASE language_platform_dev` **inside this cluster**. The backend's own startup guard only allows that exact name on localhost; the port is not checked, which is why step "verify the target" above matters.
4. Build `mailsink` and copy `E2eMailSink.dll` and `E2eMailSink.deps.json` next to `LanguagePlatform.Api.dll`. `run-api.ps1` sets `ASPNETCORE_HOSTINGSTARTUPASSEMBLIES`, `DOTNET_ADDITIONAL_DEPS` and `E2E_OUTBOX`; the sink adds an `IAccountEmailDelivery` that appends confirmation / reset codes to `outbox.jsonl` (the backend returns 503 for registration without one).
5. `run-api.ps1` (applies the repository's migrations and the catalog seed at startup, Development only).
6. `setup-accounts.ps1` (student A/B), `setup-teacher.ps1` (teacher: authenticator enrolment and `content.edit`, `content.publish`, `assessment.evaluate` through the backend's own operator command), `author.ps1` (course, two A1 lessons with ten reading questions and five questions in every other stage, manually approved PDF lines, `answerkey.json`).

## Running the tests

```powershell
$env:E2E_DIR = '<work>\e2e'
flutter test test/e2e/real_backend_journey_test.dart --timeout 15m   # repositories over real HTTP
flutter test test/e2e/real_backend_ui_test.dart --timeout 10m        # real widgets over real HTTP (run after the first)
```

Both files are skipped when `E2E_DIR` is unset, so `flutter test` stays offline by default.

## What the journey proves (last run: 25 + 3 tests, all passed)

Health/readiness; login, `/me`, secure-store persistence and restart restore; refresh rotation with 3 concurrent 401s -> one refresh, replayed refresh rejected; Turkish->Arabic course; six levels; 20 positions with 2 published; five ordered stages with teacher weights 30/20/20/15/15; 404 before enrolment; enrol/start; approved Arabic lines in order with diacritics; authenticated PDF download (`%PDF-` ... `%%EOF`); ten reading questions with idempotent start; out-of-order attempt -> 409; speaking pending then teacher score; listening / writing (FillBlank + WordOrder) / translation (ExactText + MultipleChoice) graded by the server; **final 50.0 -> not passed, next lesson locked (400)**; retake to **exactly 60.0 -> passed, `nextLessonId` set, lesson 2 opens**; results after restart; another student sees nothing of A's data; logout revokes access and refresh tickets; register -> email code -> confirm -> sign-in; unconfirmed sign-in refused; weak password refused; account deletion request (wrong password refused, correct -> 202, sessions invalid, sign-in refused); forged token and admin route (403) refused.

## Not proven here

Real audio/video **playback** (the authored media host does not exist), the OS share sheet, TalkBack/VoiceOver, an emulator/device run, iOS, SMTP delivery, malware scanning, TLS to PostgreSQL.

## Cleanup (only what was created above)

Stop the API process and the scratch `postgres` by their own PID / data directory (`pg_ctl -D <work>\e2e\pgdata stop -m fast`), then delete `<work>`. Do not touch the installed PostgreSQL service. The data-protection key ring the Development API writes under `%LOCALAPPDATA%\ASP.NET\DataProtection-Keys` is outside `<work>`; remove it manually if desired.
