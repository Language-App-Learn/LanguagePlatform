# PROJECT_STATUS — Mobile (Flutter)

> Update after every milestone. Keep short. Last update: 2026-11-06 (V5 session 1)

## Git state (verified at session start)
- Branch `Flutter`; local HEAD = `origin/Flutter` = `57d71c8` at session start (V4 pushed). V5 changes are **uncommitted**.
- Earlier: `11b7e96` (V3), `4981d3e`, `d590fe6`.

## Quality gates (this session)
- `flutter analyze`: clean. `flutter test`: **404 passed, 0 failed** (V4 baseline 303; +101 new: domain, flow and a 108-case narrow-screen/2x-text/en-ar-tr smoke suite).
- Android (V4 re-check): plain `flutter build apk --debug` still **fails** in `:shared_preferences_android:compileDebugKotlin` (Kotlin "Could not close incremental caches"; innermost: storage "is already registered"). `flutter build apk --debug -Pkotlin.incremental=false` **succeeds**. Earlier attempts that did not help: clearing the plugin build dir, in-process Kotlin compilation. Daemons not killed (Android Studio).
- iOS: not built (needs macOS/Xcode). TalkBack / VoiceOver: not tested on devices.

## Five-stage Turkish -> Arabic track (V5 session 1)

Source of truth for scope: product task "five-stage Arabic learning". Only Turkish -> Arabic is exposed on Home; the generic Courses tab and the en/tr/ar UI localization are unchanged (restricting the Courses tab was deliberately not done: it would invalidate the existing catalog tests; decide later).

| Area | Status |
|---|---|
| Domain: `LearningTrack`, 6 levels x 20 positions (`buildLevelPositions`), 5 `LessonStage`s, sequential `stageStatus`, `lessonOutcome`, `overallPassMark = 60` | done + 18 unit tests |
| Home "Learn Arabic from Turkish" card -> `/track/tr-ar` -> level selection (A1-C2 with real published/completed counts) -> `/track/tr-ar/level/:level` (20 positions; published openable, rest "In preparation") -> `/stages/:lessonId` (five stage cards, overall panel) | done + flow tests |
| Reading stage: logical lines with stable ids, per-line audio control (disabled, "unavailable"), PDF and teacher video slots (unavailable), comprehension questions with check/result | done (UI); content is a DEMO fixture (3 questions, not the required 10) |
| Speaking stage: structured dialogue (speaker bubbles, RTL); AI conversation and microphone shown as unavailable; nothing recorded, no permission requested | done (UI only) |
| Listening stage: word bank + blanks, drag-and-drop AND tap-to-place, repeated words, reset, check | done (demo content, no audio) |
| Writing stage: fill-in (Arabic input) + word arrangement (tap, undo, reset, duplicates) | done (demo content) |
| Translation stage (Turkish -> Arabic): choose translation + write translation with accepted alternatives | done (demo content) |
| Scoring: overall pass mark 60 shown; NO equal weights, NO per-stage minimum; overall result only from a `ServerLessonResult` (`serverLessonResultProvider`, currently always `null`) -> UI shows "Awaiting official assessment" after five practiced stages, never "Passed"; demo practice scores carry a "not an official score" notice | done |
| Persistence: `lp.stages` (versioned, corruption tolerant) for DEMO stage records | done |
| Real backend (catalog, auth, lesson reads, enrollment, assessments) | **not integrated** |
| Five-stage endpoints, PDF download, line TTS audio, teacher video, speaking/AI, secure token storage | **blocked** (see below) |

### Blockers / decisions needed
- `docs/api/FIVE_STAGE_LESSON_CONTRACT.md` does not exist yet on `origin/Backend-Database` (only `FLUTTER_BACKEND_CONTRACT.md`, which has catalog, auth, lesson reads, enrollment, assessment attempts, vocabulary). No five-stage route was assumed.
- New dependencies required (need approval per CLAUDE.md; none installed): secure token storage (e.g. `flutter_secure_storage`), audio playback (e.g. `just_audio`), video (e.g. `video_player`), microphone recording + permission (e.g. `record` + `permission_handler`), file download/open for the original PDF (e.g. `dio` for download or `path_provider` + `open_file`/`share_plus`). A plain HTTP `ApiClient` can be written on `dart:io HttpClient` without a new package if preferred over Dio.
- Product decisions: stage weights (owner has not approved), reading question count source (10 per lesson from server), retry policy, next-lesson unlock rule (server).
- Real vs demo identifiers: demo lesson ids (`ar-a1-l1`) are not backend UUIDs; a remote repository must be selected explicitly per session mode, never mixed.

### Next steps
1. Approve dependencies above; implement `HttpApiClient` + DTO mappers for the existing contract (catalog, lessons) behind the repository interfaces, selected by session mode.
2. When the five-stage contract lands: map stage content/results DTOs; fill `serverLessonResultProvider`; remove demo fixtures from real mode.
3. Secure auth/session (refresh coordination), then enrollment/progress.
4. Audio/PDF/video/microphone adapters with permissions requested only when a feature is used.
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
