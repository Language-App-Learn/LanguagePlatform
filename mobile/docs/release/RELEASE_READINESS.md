# Release readiness — LanguagePlatform student app

Status legend: **DONE** (implemented and verified by the stated evidence) · **PARTIAL** · **BLOCKED** (needs an external decision/approval/dependency) · **NOT VERIFIED** (could not be run in this workspace).

Last updated: 2026-11-07. Branch `Flutter`, base commit `d64c2e3`; all work since is **uncommitted**.

## Verdict: NO-GO for store release

Reasons (each tracked below): no live-backend end-to-end run, tokens are not persisted securely yet (package approval pending), no final application ID / signing keystore / iOS team, no account-deletion path, no media playback, no privacy/data-safety paperwork, no device accessibility test.

## Evidence

| Check | Result |
|---|---|
| `dart format` / `flutter analyze` | clean |
| `flutter test` | **565 passed, 0 failed** (baseline at session start: 458) |
| `flutter build apk --debug` (plain) | fails on this machine in `:shared_preferences_android:compileDebugKotlin` (Kotlin 2.4.0 incremental-cache bug, see ANDROID below); passed once after a clean non-daemon run |
| `flutter build apk --debug -Pkotlin.incremental=false` | passes |
| `flutter build apk --release -Pkotlin.incremental=false` | passes (debug-signed fallback: no keystore provisioned); merged manifest inspected |
| iOS build / archive | NOT VERIFIED (needs macOS + Xcode) |
| Live backend (PostgreSQL) end-to-end | NOT VERIFIED (no reachable backend in this workspace) |

## Remote API endpoints (all from `FLUTTER_BACKEND_CONTRACT.md` / `FIVE_STAGE_LESSON_CONTRACT.md`)

| Endpoint | Status | Tested by |
|---|---|---|
| `POST /auth/register` `/confirm-email` `/confirm-email/resend` `/login` `/refresh` `/logout` `/password-reset/request` `/password-reset/confirm`, `GET /me` | DONE (client + UI except `/me` display) | unit + widget tests, loopback HTTP tests |
| `GET/PUT /me/preferences` | NOT DONE (not needed for the first track) | — |
| `GET /catalog/courses` | DONE (Turkish→Arabic course) | fake + DTO tests |
| `GET /courses/{id}/curriculum/levels`, `.../levels/{levelId}/slots` | DONE (6 levels × 20 positions) | widget tests |
| `GET /courses/{id}/lessons/{lessonId}` | DONE | DTO + widget tests |
| `PUT /me/courses/{id}/enrollment`, `PUT .../lessons/{id}/start` | DONE | flow tests |
| `GET .../curriculum-progress` | DONE (decimal scores, server `passed`/`nextLessonId`) | widget tests |
| `GET .../lessons/progress?completedOnly=true` | DONE (paged) | repository tests |
| `GET .../reading-material`, `.../reading-material/original` | DONE (lines + authenticated PDF bytes); **hand-over to the OS needs a package** | widget + repository tests |
| `GET .../stages/{stageId}/media` | DONE (availability panel; **no playback**) | widget tests |
| `POST .../assessments/{id}/attempts` (+ idempotency key), `.../submit` | DONE for all 6 kinds | widget tests |
| `GET /me/assessment-attempts/{id}/result` | DONE (speaking pending → null) | widget tests |
| `GET /me/vocabulary…`, `PUT …/favorite` | NOT DONE (vocabulary stays local demo data, labeled) | — |
| Admin/authoring routes | out of scope for the student app | — |

## Feature matrix

| Area | Status | Notes |
|---|---|---|
| Real HTTP transport (`dart:io`) | DONE | typed 400/401/403/404/409/413/415/429/5xx, `Retry-After`, ProblemDetails diagnostic-only, binary + MIME check, cancellation, correlation id, no redirects, GET-only retries |
| Secure session | PARTIAL | refresh coordination, logout, expiry, account-epoch cache isolation, restore logic: DONE and tested. **Keychain/Keystore persistence: BLOCKED** on `flutter_secure_storage` approval (adapter seam `SecretStore` ready) |
| Demo/real separation | DONE | content mode, epoch-scoped providers, Courses/Home reduced for real accounts, "local practice" notices; demo scores/ids never sent |
| Catalog / levels / slots | DONE | no stale-cache layer (not built) |
| Five-stage overview, server-driven | DONE | locked stages open nothing and write nothing (remote and demo) |
| Official result model | DONE | fractional, nullable, truncation display, server `passed` only |
| Reading text + PDF | PARTIAL | text DONE; PDF download DONE; open/save/share BLOCKED (`path_provider` + `open_filex`/`share_plus`) |
| Teacher video / listening audio | BLOCKED | metadata shown; `just_audio` / `video_player` approval needed |
| Speaking | PARTIAL | attempt + "waiting for evaluator" + result: DONE. Recording/AI/TTS: no backend endpoints, no controls, no microphone permission |
| Listening / writing / translation exercises | DONE | WordBank, FillBlank, WordOrder, MultipleChoice, ExactText, TrueFalse with tap + drag |
| Attempt lifecycle | DONE | persisted idempotency key, same key on ambiguous failure, new key for retake, resume after restart, 409 handling |
| Android release config | PARTIAL | INTERNET, backup off, debug-only cleartext scope, signing scaffold DONE; **application ID and keystore BLOCKED on owner** |
| iOS config | NOT VERIFIED | static review only |
| Accessibility on devices | NOT VERIFIED | semantics/large-text covered by tests only |
| Account deletion | BLOCKED | no backend route; required by Google Play and App Store when accounts can be created |
| Privacy policy / data-safety / store listing | NOT STARTED | owner content |
| Crash reporting | NOT STARTED | would need a vendor decision; none added |

## ANDROID

* `targetSdk=36`, `compileSdk=36`, `minSdk=24` (resolved from the Flutter Gradle plugin; confirmed in the merged manifest of the real build).
* Fixed: main manifest lacked `INTERNET` (release builds could not reach any server). Backup/device-transfer disabled. Plain HTTP only in the **debug** build and only for `10.0.2.2`, `localhost`, `127.0.0.1`.
* Signing: `android/key.properties` (git-ignored; template `android/key.properties.example`). Without it `assembleRelease` falls back to the debug key for local runs and `bundleRelease` **refuses to run**. Use Play App Signing. No keystore was created.
* Application ID `com.example.musab_hoca_arapca` and app label are placeholders: **owner must approve the final ID before first publication** (immutable afterwards).
* Kotlin build error: stack shows the failure inside Kotlin 2.4.0 (`InMemoryStorage.applyChanges` → "Storage … is already registered") during a non-incremental compile of `:shared_preferences_android`. Tried: pub cache on the project drive (no effect), plain re-runs (fail for debug and release), `--no-android-gradle-daemon` (debug passed once, release failed). Reliable workaround: `-Pkotlin.incremental=false` per invocation. Next: try a Kotlin 2.4.x patch release once the owner approves changing `settings.gradle.kts`.

## iOS (static review, Windows)

Bundle ID `com.example.musabHocaArapca` and display name "Musab Hoca Arapca" are placeholders; no signing team set (not invented); deployment target 15.0; no privacy strings (correct while there is no voice feature); ATS default (HTTPS only). To do on a Mac: set bundle ID/team, add `ITSAppUsesNonExemptEncryption` after owner/legal confirmation, local-network ATS exception for simulator development only, archive, TestFlight, VoiceOver/RTL pass.

## Remaining dependencies

Backend/provider: see `docs/api-feedback/BACKEND_FEEDBACK.md`. Packages: see `docs/architecture/DEPENDENCY_REQUESTS.md`.
