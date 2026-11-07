# PROJECT_STATUS — Mobile (Flutter)

> Update after every milestone. Keep short. Last update: 2026-11-07 (V8: approved packages, secure storage, account deletion, real end-to-end run)

Release verdict: **NO-GO for store release**, but a real A1 lesson now works end-to-end against the real backend (see `docs/testing/E2E_REAL_BACKEND.md`). Details: `docs/release/RELEASE_READINESS.md`, `docs/security/MASVS_FINDINGS.md`, `docs/api-feedback/BACKEND_FEEDBACK.md`, `docs/architecture/DEPENDENCY_REQUESTS.md`.

## Git state
- Branch `Flutter`; `HEAD` = `origin/Flutter` = `b7ff409`; `origin/Backend-Database` = `dd09853` (read-only). All V8 work is **uncommitted and unpushed** (awaiting owner approval). The 7 `generated_plugin*` files are line-ending noise: keep them out of commits.

## Quality gates (V8)
- `dart format`: clean. `flutter analyze`: **No issues found**. `flutter test` (offline): **596 passed, 0 failed, 2 skipped** (the two real-backend files skip without `E2E_DIR`). Real-backend run (`E2E_DIR` set): **25 repository-level + 3 UI-level tests passed** against local ASP.NET Core + a disposable PostgreSQL 18 cluster.
- Android: builds with the new plugins were verified only in scratch copies of the project (see below); **no Gradle build was run after `just_audio` / `video_player` were added** - pending.
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
4. Android: confirm the full build after the last two plugins; Kotlin cache issue (below).
5. Enable CI (template in `docs/ci/`; workflow location is outside `mobile/`).

## Kotlin incremental-cache issue (investigation log)
Plain `flutter build apk --debug` in `D:\Projeler\...\mobile` fails the first time any Kotlin module is compiled (`:shared_preferences_android`, later `:share_plus`) with Kotlin 2.4.0 "Storage ... is already registered". In **scratch copies of the same project on drive C:** (same drive as the pub cache) a completely clean plain build succeeds with Kotlin 2.4.0 *and* 2.4.21. A pub cache moved to D: did not fix the D: project (but that run started from already-poisoned build output). Leading hypothesis: cross-drive path handling in Kotlin's incremental caches (project on D:, plugin sources on C:). Not yet proven: needs one clean build of a copy on D: with the pub cache on D: (and one with the default cache). Safe workarounds: `-Pkotlin.incremental=false`, or move the project/pub cache onto one drive. No daemon was killed and no caches were deleted in the real project.

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
