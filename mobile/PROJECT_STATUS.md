# PROJECT_STATUS — Mobile (Flutter)

> Update after every milestone. Keep short. Last update: 2026-11-06 (V4 session 1)

## Git state (verified at session start)
- Branch `Flutter`; local HEAD = `origin/Flutter` = `11b7e96` (V3 pushed). V4 changes below are **uncommitted**.
- Earlier: `4981d3e` (persistence/architecture), `d590fe6` (MVP).

## Quality gates (this session)
- `flutter analyze`: clean. `flutter test`: **303 passed, 0 failed** (V3 baseline 291; V4 added 12 tests and the large-text suite re-ran against the redesigned screens).
- Android (V4 re-check): plain `flutter build apk --debug` still **fails** in `:shared_preferences_android:compileDebugKotlin` (Kotlin "Could not close incremental caches"; innermost: storage "is already registered"). `flutter build apk --debug -Pkotlin.incremental=false` **succeeds**. Earlier attempts that did not help: clearing the plugin build dir, in-process Kotlin compilation. Daemons not killed (Android Studio).
- iOS: not built (needs macOS/Xcode). TalkBack / VoiceOver: not tested on devices.

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
