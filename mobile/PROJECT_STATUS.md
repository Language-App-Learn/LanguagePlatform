# PROJECT_STATUS — Mobile (Flutter)

> Update after every milestone. Keep short. Last update: 2026-11-06 (V3 session 1)

## Git state (verified at session start)
- Branch `Flutter`; local HEAD = `origin/Flutter` = `4981d3e` ("add local persistence, flashcard review and architecture hardening"). Earlier commits: `d590fe6` (MVP), `4058ccc`.
- V3 changes below are **uncommitted** (nothing pushed by this session).

## Quality gates (this session)
- `flutter analyze`: clean. `flutter test`: **291 passed, 0 failed** (baseline was 218).
- Android: plain `flutter build apk --debug` still **fails** in `:shared_preferences_android:compileDebugKotlin`. Innermost cause in the log: Kotlin `IllegalStateException: Storage for [...\build\shared_preferences_android\...\class-fq-name-to-source.tab] is already registered` → "Could not close incremental caches". Not fixed by: clearing that plugin's build dir; `-Pkotlin.compiler.execution.strategy=in-process`. Gradle/Kotlin daemons were not killed (they run under Android Studio's JBR). **Works:** `flutter build apk --debug -Pkotlin.incremental=false` (per invocation only; no Gradle files changed). Open question for the developer: path-spelling/drive layout (project on D:, pub cache on C:) or a stale daemon; try after closing Android Studio.
- iOS: not built (needs macOS/Xcode). TalkBack / VoiceOver: not tested on devices.

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
flutter_riverpod 3.4, go_router 18, flutter_localizations, intl, shared_preferences 2.5. No dependency changes in V3.

## Known issues / limitations
- Plain Android debug build fails on this machine (above).
- Local demo data only; no account sync. Dashboard values depend on the device clock.
- Review history "next review" reflects the word's current schedule, not the schedule at review time.
- Quiz/lesson screens were not visually redesigned; accessibility on devices unverified.
- linux/macos/windows `generated_plugin*` files show line-ending-only modifications; not touched.

## Backend integration pending
See `docs/architecture/API_INTEGRATION.md`.

## iOS validation still required (macOS/Xcode)
Build/run, `shared_preferences` on device, safe areas, keyboard insets, back-swipe, VoiceOver with RTL, text scaling.

## Next steps
1. Review and commit V3 work.
2. Dedicated visual pass on lesson and quiz screens and onboarding/auth (needs design direction/approval).
3. Resolve the Android incremental-Kotlin build issue (try closing Android Studio / same-drive pub cache).
4. Product decisions needed: extra question types and grading, lesson media, locked-lesson rules, categories.
5. Dio adapter + DTOs once the backend contract is confirmed.
