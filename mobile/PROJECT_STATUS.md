# PROJECT_STATUS — Mobile (Flutter)

> Update after every milestone. Keep short. Last update: 2026-11-08 (V8 + Kotlin fix applied and verified on `557b591`)

Release verdict: **NO-GO for store release**, but a real A1 lesson now works end-to-end against the real backend (see `docs/testing/E2E_REAL_BACKEND.md`). Details: `docs/release/RELEASE_READINESS.md`, `docs/security/MASVS_FINDINGS.md`, `docs/api-feedback/BACKEND_FEEDBACK.md`, `docs/architecture/DEPENDENCY_REQUESTS.md`.

## Git state
- Branch `Flutter`; `HEAD` = `origin/Flutter` = `b7ff409`; `origin/Backend-Database` = `dd09853` (read-only). All V8 work is **uncommitted and unpushed** (awaiting owner approval). The 7 `generated_plugin*` files are line-ending noise: keep them out of commits.

## Quality gates (V8)
- `dart format`: clean. `flutter analyze`: **No issues found**. `flutter test` (offline): **596 passed, 0 failed, 2 skipped** (the two real-backend files skip without `E2E_DIR`). Real-backend run (`E2E_DIR` set): **25 repository-level + 3 UI-level tests passed** against local ASP.NET Core + a disposable PostgreSQL 18 cluster.
- Android (re-verified on `557b591` after the Kotlin fix): **plain `flutter build apk --debug` and plain `flutter build apk --release` now both PASS** with incremental Kotlin compilation ON (no `-Pkotlin.incremental=false`); release APK 57.9 MB. `flutter build appbundle --release` still refuses without `android/key.properties`. Release APK signer is still `CN=Android Debug` (not distributable). Details: "Kotlin fix applied" below.
- iOS not built (needs macOS/Xcode). No device/emulator run. TalkBack/VoiceOver untested.

## Dependencies (owner-approved on 2026-11-07, installed incrementally)
`flutter_secure_storage ^11.2.0` (Keychain / Keystore session), `path_provider ^2.1.6`, `share_plus ^13.3.1` (PDF hand-over), `just_audio ^0.10.6` (listening audio), `video_player ^2.14.1` (teacher video). pub.dev listed no advisories for any of them (that feed is not exhaustive; re-check at each upgrade). NOT installed: `record`, `permission_handler`, AI/analytics/crash SDKs.

## V8 — what changed
| Area | Status |
|---|---|
| Secure session: `PlatformSecretStore` (Android Keystore-wrapped AES-GCM / iOS Keychain `first_unlock_this_device`), single-entry atomic pair, corrupt-entry recovery, iOS reinstall guard (install marker), restore at startup | done; unit tests with the plugin's mock + real-backend restart test |
| Account deletion: `POST /me/privacy/deletion-request` with password + optional authenticator code, explicit acknowledgement + final dialog, honest "accepted request / operator completes removal" wording, local session cleared on 202 | done; 9 widget tests + verified on the real backend |
| Login: optional authenticator code (MFA) | done |
| Media: `status` handling (only `available` is shown), lazy `just_audio` / `video_player` players, pause on background, dispose on leave, HTTPS-only, URL-free errors, retry re-reads metadata | done with fake players (8 tests); **real playback NOT verified** (no reachable media host) |
| PDF: authenticated download -> app-private cache -> OS share sheet (`SharePdfDelivery`), stale files purged | done (6 tests); share sheet **not verified on a device** |
| Real end-to-end: 20-step student journey (50/100 fails and locks lesson 2; exactly 60/100 passes and unlocks it; speaking via teacher evaluation; isolation; revocation; deletion) | done; harness in `tool/e2e/`, guide in `docs/testing/E2E_REAL_BACKEND.md` |
| Backend feedback re-based on the newest contract (resolved / unresolved / new) | done |

## Blocked / needs owner
1. Final Android application ID / label, iOS bundle ID / team, upload keystore, Play App Signing (separate release decision).
2. Reachable HTTPS media host + teacher materials to verify audio/video playback; verified link format for email confirmation (U-1).
3. Privacy policy / terms / data-safety content; crash-reporting vendor decision.
4. (done) Kotlin incremental-cache issue: fixed on this machine (see "Kotlin fix applied"). Fresh IDE / terminal sessions must inherit the user variable `PUB_CACHE=D:\PubCache`.
5. Enable CI (template in `docs/ci/`; workflow location is outside `mobile/`).

## Final Android verification (2026-11-07, commit d225b19) - HISTORICAL, before the Kotlin fix; plain builds failed then and pass now (see next section)

| Check | Result |
|---|---|
| `flutter analyze` / `flutter test` | clean / **596 passed, 2 skipped (E2E), 0 failed** |
| `flutter build apk --debug` (plain) | **FAILED** - Kotlin cache error (share_plus, audio_session) |
| `flutter build apk --release` (plain) | **FAILED** - Kotlin cache error (audio_session, video_player_android, shared_preferences_android) |
| `flutter build apk --debug -Pkotlin.incremental=false` | **BUILT** |
| `flutter build apk --release -Pkotlin.incremental=false` | **BUILT**, 57.9 MB, ABIs arm64-v8a / armeabi-v7a / x86_64 |
| `flutter build appbundle --release` | **refused by design** (no `android/key.properties`): "bundleRelease needs android/key.properties ..." |
| Plugins in the build | Android registrant lists FlutterSecureStoragePlugin, SharePlusPlugin, JustAudioPlugin, AudioSessionPlugin, VideoPlayerPlugin, SharedPreferencesPlugin, JniPlugin/JniFlutterPlugin; all five approved plugins' classes are present in R8's mapping.txt (path_provider_android has no Java plugin class on this version - it runs through the JNI plugin) |
| Release merged manifest | `INTERNET`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK` (media plugins); `minSdk=24`, **`targetSdk=36`**; `allowBackup=false`, `fullBackupContent=false`, `dataExtractionRules`; **no** `networkSecurityConfig`, **no** `usesCleartextTraffic`, no `debuggable` (so cleartext is blocked by the platform default); `share_provider` FileProvider for share_plus; application ID unchanged |
| HTTPS restrictions | release: platform blocks cleartext; the localhost/10.0.2.2 cleartext rule exists only in `src/debug`; `ApiConfig` rejects `http://` for any other host; media players refuse non-HTTPS |
| Signing safeguards | no keystore generated; `bundleRelease` refuses without `key.properties`; `assembleRelease` falls back to the debug key (APK signer `CN=Android Debug`) and is for local use only |
| Still NOT verified | installing/running the APK on an emulator or device, real audio/video playback, the OS share sheet, TalkBack, iOS |

## Kotlin fix applied and verified (2026-11-08)

Applied the fix proven by the disposable-copy matrix to the ORIGINAL project, without changing any source, Kotlin or Gradle version, application ID, signing, or backend file:

1. Project (`D:\Projeler\LanguagePlatform-Flutter\mobile`) and Pub Cache are now both on **D:**; plugin sources resolve to `D:\PubCache\hosted\pub.dev\...` (`flutter pub get`).
2. **Persistent user-level environment variable `PUB_CACHE=D:\PubCache`** (current user only; machine level untouched; verified with `reg query HKCU\Environment` and a fresh `cmd`). The old C: Pub Cache was not deleted.
3. After the path fix the plain build still failed with "Storage ... is already registered": the Gradle daemon (and its Kotlin daemons) kept the broken registrations of earlier failed runs at the same paths. They were retired with the **official wrapper command `.\gradlew.bat --stop`** (graceful, no force-kill, no Android Studio was running, no cache deleted). `flutter clean` was not needed.
4. **Normal `flutter build apk --debug` and `flutter build apk --release` both succeeded WITHOUT `-Pkotlin.incremental=false`** (zero Kotlin cache errors).
5. `flutter analyze`: no issues. `flutter test`: **596 passed, 0 failed, 2 skipped** (the two real-backend files, skipped without `E2E_DIR`).
6. The new release APK's own manifest (`aapt2`) is unchanged: package `com.example.musab_hoca_arapca`, `targetSdk 36`, `INTERNET` + `ACCESS_NETWORK_STATE` + `WAKE_LOCK`, `allowBackup=false`, not debuggable, no `networkSecurityConfig`, no `usesCleartextTraffic`, no microphone/camera/location permission.

**Operational rule:** a fresh terminal or IDE session must inherit `PUB_CACHE=D:\PubCache` (terminals and IDEs opened before the change keep the old value until restarted). If `flutter pub get` is ever run without it, plugin paths fall back to C: and the Kotlin error returns (symptom: "this and base files have different roots"; after that, also "already registered" until the Gradle daemon is stopped again with `.\gradlew.bat --stop`). Fallbacks: `-Pkotlin.incremental=false`. CI on Linux is unaffected.

Release verdict is unchanged: **NO-GO** (a real upload keystore is still missing and the release APK is signed with the debug certificate; no physical-device run; real audio/video playback and PDF sharing unverified on devices; iOS build and accessibility checks incomplete).
## Kotlin incremental-cache issue: ROOT CAUSE FOUND (2026-11-07)

**Cause (reproducible, with stack trace): the project and the Pub Cache are on different drives.** Kotlin 2.4.0's incremental cache stores every source file path *relative to the project directory* (`RelocatableFileToPathConverter.toPath` -> `File.relativeTo`). A plugin source file that lives under the Pub Cache on `C:` cannot be made relative to a project on `D:` (and vice versa), so Kotlin throws `IllegalArgumentException: this and base files have different roots: C:\...\Pub\Cache\...\audio_session-0.2.4\...\AndroidAudioManager.kt and D:\...\mobile\android`. Closing the cache then fails with "Could not close incremental caches", which surfaces as the Gradle error. It affects every plugin that contains Kotlin code (`audio_session`, `share_plus`, `shared_preferences_android`, `video_player_android`, ...). It is not a corrupt Gradle cache, not a poisoned daemon, and not specific to one plugin.

Controlled experiment: four **clean disposable copies** (sources only), same Flutter 3.47.9, Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, JDK of Android Studio, same shared Gradle user home, plain commands, one build at a time:

| Project drive | Pub Cache drive | `apk --debug` | `apk --release` |
|---|---|---|---|
| D: | C: (default) | **FAIL** (4 Kotlin modules) | **FAIL** |
| D: | D: | **PASS** | **PASS** |
| C: | C: (default) | **PASS** | **PASS** |
| C: | D: | **FAIL** (same 4 modules) | **FAIL** |

* Failures are identical in both mixed-drive cases (same modules, same exception with the two roots swapped); same-drive cases have zero such errors.
* Control with `-Pkotlin.incremental=false` on clean copies of both failing configurations: **debug PASS, release PASS** in both. So Kotlin's *incremental* mode is the part that breaks; disabling it avoids the path conversion.
* Earlier observation corrected: the scratch copies that "passed with Kotlin 2.4.0 and 2.4.21" were C:+C: (same drive), so they say nothing about the Kotlin version. Whether a newer Kotlin patch handles cross-root paths is **untested** (needs separate approval to change Kotlin).

**Safest permanent fix (no Gradle/Kotlin/version change, no app change):** keep the project and the Pub Cache on the same drive. For this machine (project on `D:`): set the *user* environment variable `PUB_CACHE` to a folder on `D:` (e.g. `D:\PubCache`), restart Android Studio / VS Code / terminals so they inherit it, then run `flutter pub get` in `mobile/`; a stale `mobile/build` from earlier failed runs may need `flutter clean` (not done here). Equivalent alternative: move the project onto `C:`. Fallback when that is not possible: `-Pkotlin.incremental=false` per invocation (slower builds; no source change). CI on Linux is unaffected (single filesystem root); the CI template keeps the workaround only as a safety net.

Not done on purpose: the original project, its `build/` folder, global caches and any daemon were not touched; this was proven only in disposable copies. Copies and logs: `D:\Projeler\kt-lab\` and the session scratch directory (safe to delete when no longer needed; they contain only copies of the sources).

## V7 — what changed
| Area | Status |
|---|---|
| Transport: typed 409/413/415/429 (+`Retry-After`), ProblemDetails diagnostic-only, binary download with MIME + `%PDF-` check and size cap, cancellation, correlation id, no redirects, GET-only retries | done + 17 loopback tests |
| Auth: confirm email (+ route `/auth/confirm-email`), resend, reset-confirm (two-step page), `/me`, password policy (12+, mixed, digit, symbol), best-effort logout | done + widget tests |
| Session: `SecureTokenStore` over a `SecretStore` seam (single-entry atomic pair, corrupt-entry handling), restore at startup, expiry → signed out, account epoch isolating all learner caches, tokens wiped on demo/reset | done + tests; **persistence needs `flutter_secure_storage` approval** (memory-only meanwhile) |
| Exercises from the server: WordBank, FillBlank, WordOrder (token ids), MultipleChoice, ExactText, TrueFalse; tap + drag; exact Arabic text | done + 27 widget tests |
| Attempt lifecycle: persisted idempotency key (same key after ambiguous failure/restart, new key on retake), unsure-submit handling, 409 | done |
| Official result: decimal, truncating display (`59.999` never shows `60`), no per-attempt verdict (contract: objective `passed` uses threshold 0), lesson verdict only from curriculum progress | done |
| Reading: approved lines (stable ids, order, diacritics), PDF download (authenticated) | done; open/save/share needs a package |
| Media: audio/video availability panel (no fake player, URLs never shown) | done; playback needs packages |
| Speaking: attempt → "waiting for evaluator" → server score; no self-completion, no mic permission, AI shown unavailable | done |
| Demo bug: opening a locked stage by URL no longer records "started" (demo and remote) | fixed + tests |
| Courses tab / Home for real accounts: server course only, demo sections hidden, "local practice" notices on Vocabulary/Progress | done + tests |
| Android: `INTERNET` in main manifest, backup off, debug-only localhost cleartext config, signing scaffold (`key.properties`, bundleRelease guard), no IDs changed | done; **owner: final application ID + keystore** |

## V7 list (superseded by the V8 list above)
1. Approve packages (order): `flutter_secure_storage` → `share_plus`/`open_filex` (+`path_provider`) → `just_audio` → `video_player`; `record`+`permission_handler` only when a capture contract exists.
2. Final Android application ID / app label, iOS bundle ID/team, upload keystore, Play App Signing.
3. Backend: account-deletion route, email link format, pending-vs-unknown result signalling, provider status, idempotency confirmations (see feedback doc), a development environment for the real end-to-end run.
4. Privacy policy / terms / data-safety content; crash-reporting vendor decision.
5. Enable CI (template provided; workflow location is outside `mobile/`).

## Not done in V7 (honest list)
Live end-to-end run (phase 21), device accessibility checks, iOS build, preferences/vocabulary endpoints, stale-while-revalidate catalog cache, media playback, PDF open/share, store assets.

## V6 — real backend integration
Contracts (read-only, `origin/Backend-Database`): `FLUTTER_BACKEND_CONTRACT.md`, `docs/api/FIVE_STAGE_LESSON_CONTRACT.md`.

| Area | Status |
|---|---|
| HTTP client `HttpApiClient` on `dart:io` (**no new dependency**): base path, query, UTF-8 JSON, timeouts, typed failures; `problem+json` mapped by status only | done + loopback tests |
| `ApiConfig`: base URL only via `--dart-define=API_BASE_URL`; https required, plain http only for localhost / 10.0.2.2 / 127.0.0.1 / private LAN | done |
| `AuthenticatedApiClient`: bearer only on `requiresAuth` calls, no network call without tokens, single-flight refresh, one retry, session-expiry callback; network error during refresh keeps the session | done + tests |
| Auth: `RemoteAuthRepository` (login, register `{email,password}`, reset request, logout), `SessionStatus {signedOut, demo, authenticated}`, profile sign-out; 401 -> "incorrect credentials", 503 -> "not connected" | done + widget tests |
| Catalog: Turkish -> Arabic course, six CEFR levels, 20 slots per level with server titles, published / passed counts | done + tests |
| Lesson + five stages: published lesson read; stage texts rendered with locale direction (Arabic untouched) | done |
| Learner progress: enrollment, lesson start, `curriculum-progress` (stage statuses, attempts, official scores, final score, pass flag, next lesson); signed-out users get a sign-in prompt and no learner calls | done + tests |
| Objective assessments: attempt start (idempotency key), MultipleChoice / TrueFalse without answer keys, submit enabled only when all answered, official result (score, max, `passed`, threshold) shown exactly as returned, progress reloaded | done + tests |
| Pass mark: server `passingScore` (60/100) displayed; **no stage weights invented** (weights shown only if the server returned all five); fractional scores kept | done |
| Demo vs real: `ContentMode` is remote only when `API_BASE_URL` is set AND the session is not demo; demo ids / scores never reach the server; real accounts never show demo content | done + tests |
| Retry on catalog errors drops cached upstream failures too (`reloadTrackCatalog`) | done (bug found by the new test) |

### Blocked / not done (V6 list, superseded)
The V6 blockers were largely resolved or re-scoped in V7; the current list is **"Blocked / needs owner"** and **"Not done in V7"** above, and `docs/release/RELEASE_READINESS.md`.


## Earlier: five-stage Turkish -> Arabic demo track (V5)

| Area | Status |
|---|---|
| Domain: `LearningTrack`, 6 levels x 20 positions, 5 `LessonStage`s, sequential `stageStatus`, `overallPassMark = 60` | done + unit tests |
| Home -> `/track/tr-ar` -> level selection -> level lessons -> `/stages/:lessonId` -> stage pages | done (demo data in demo mode) |
| Reading / Speaking / Listening / Writing / Translation demo practice, RTL, drag-and-drop + tap alternatives | done (demo content, not official) |
| Persistence `lp.stages` for demo stage records | done |

## V4 work (this session)
| Area | Status |
|---|---|
| Splash: brand + tagline with restrained fade-in; no delay (route applied as soon as decided) | done |
| Onboarding: native-shape illustrations (`StepIllustration`, color role per step) | done |
| Language selection: ISO badges (`LanguageBadge`) on known/target cards; values stay independent | done |
| Auth screens: form inside a card, keyboard dismiss on drag; still no fake success | done (light) |
| Lesson reader: `LessonHeader` (course, "Lesson n of N", minutes, completion, course progress); Arabic content typography in `ContentText` (1.12x size, 1.9 line height, text never modified); completion snackbar | done |
| Quiz: option letter markers (A/B/C or أ/ب/ج); leave-confirmation when abandoning an attempt (`PopScope`) | done |
| Backend adapter | **blocked**: this workspace's backend only has `/weatherforecast`; see API_INTEGRATION.md |
| Other question types | blocked on product decisions (multiple-select scoring, matching, ordering, fill-blank rules) |
| Catalog / vocabulary / progress / settings visual polish | not redone in V4 (V3 state) |
| Device accessibility (TalkBack/VoiceOver), iOS build | unverified |

## V3 work
| Area | Status |
|---|---|
| Theme refinements (dialog/sheet/list-tile shapes, tap-target padding, reading line heights) | done (incremental; no new design system rewrite) |
| Home: "Your course" card with CEFR badge + real progress (`activeCourseProvider`: last opened course matching target language, else next path course; empty state otherwise) | done |
| Word detail favorite toggle (same `vocabularyRecordsProvider` as list; persists) | done |
| Review history page (`/review-history`, from Vocabulary app bar) built from recorded review activity; next-review shown from the current schedule | done |
| Large-text / narrow-screen audit: 15 screens × en/ar × 1.5x/2.0x at 360×640. Found and fixed overflows in Vocabulary (now one lazy `CustomScrollView`) and Course detail header (`Wrap`) | done |
| Cross-screen consistency test (lesson → progress → course → home), resilience tests (invalid persisted language codes, empty catalog, deleted last-opened course, removed words in history) | done |
| Full premium redesign of every screen (onboarding/auth/lesson/quiz visuals) | **not done** — only incremental polish; quiz/lesson visuals unchanged |
| Lesson block ids / content versions | evaluated, **not implemented** (see OVERVIEW decision note) |
| Category filter / locked lessons | not implemented (no category data, no product rule) |
| Dio / real remote repositories / auth redirect | not implemented (no backend contract) |

## Architecture docs
`docs/architecture/`: OVERVIEW, STATE_MANAGEMENT, DATA_AND_PERSISTENCE, API_INTEGRATION, TESTING (kept accurate; unchanged contracts).

## Packages
flutter_riverpod 3.4, go_router 18, flutter_localizations, intl, shared_preferences 2.5, flutter_secure_storage 11.2, path_provider 2.1, share_plus 13.3, just_audio 0.10, video_player 2.14 (all owner-approved; see "Dependencies" above). HTTP uses dart:io (no Dio).

## Known issues / limitations
- Plain Android debug build fails on this machine (above).
- Local demo data only; no account sync. Dashboard values depend on the device clock.
- Review history "next review" reflects the word's current schedule, not the schedule at review time.
- Quiz/lesson screens were not visually redesigned; accessibility on devices unverified.
- linux/macos/windows `generated_plugin*` files show line-ending-only modifications; not touched.

## Backend integration
See `docs/architecture/API_INTEGRATION.md` (V6: catalog, auth, lessons, progress and objective assessments are integrated; blockers listed above).

## iOS validation still required (macOS/Xcode)
Build/run, `shared_preferences` on device, safe areas, keyboard insets, back-swipe, VoiceOver with RTL, text scaling.

## Next steps
0. V6: owner reviews and approves commit + push; approve a secure-storage package; smoke-test against the live Backend-Database server.
1. Review and commit V3 work.
2. Dedicated visual pass on lesson and quiz screens and onboarding/auth (needs design direction/approval).
3. Resolve the Android incremental-Kotlin build issue (try closing Android Studio / same-drive pub cache).
4. Product decisions needed: extra question types and grading, lesson media, locked-lesson rules, categories.
5. Dio adapter + DTOs once the backend contract is confirmed.
