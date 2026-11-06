# PROJECT_STATUS — Mobile (Flutter)

> Update after every milestone. Keep short. Last update: 2026-11-06 (architecture hardening session)

## Status
- Last commit: `d590fe6` (MVP). **V2 work and this session's hardening are uncommitted** on branch `Flutter` (nothing pushed).
- Quality gates (this session): `dart format --set-exit-if-changed lib test` clean · `flutter analyze` clean · `flutter test` **218 passed, 0 failed**.
- Android: plain `flutter build apk --debug` **fails** in `:shared_preferences_android:compileDebugKotlin` ("Could not close incremental caches", Kotlin incremental cache; project on D:, pub cache on C:). `flutter build apk --debug -Pkotlin.incremental=false` **succeeds** (temporary command-line workaround; `gradle.properties` untouched). iOS: not built (needs macOS/Xcode).

## Architecture docs
`docs/architecture/`: OVERVIEW, STATE_MANAGEMENT, DATA_AND_PERSISTENCE, API_INTEGRATION (checklist of unconfirmed contracts), TESTING.

## Done in this session (architecture hardening)
| Area | Result |
|---|---|
| Audit | No import cycles between features; logic outside widgets; findings below were fixed |
| Persistence | `GuardedKeyValueStore`: ordered, coalesced, read-your-writes, failed writes counted (never silently "saved"), Settings warning; `SharedPreferences` adapter now throws when the plugin reports failure; keys/shapes unchanged (backward compatible) |
| Error model | `core/errors/app_failure.dart` (typed failures + `failureOf`), localized messages, retry only when recoverable |
| API readiness | `ApiClient` boundary, `ApiResponse.unwrap`, `failureForStatus`; fake transport in tests; no Dio, no invented endpoints |
| Lesson engine | `UnknownContent` (safe rendering), `LessonValidator` (all demo lessons validated in tests) |
| Assessment | `TrueFalseQuestion` (+ UI via choices), `validationIssues` on all questions; controller drops malformed ones |
| Progress | Passed quiz no longer double-counts activity (quiz event only); metric definitions documented |
| Navigation | Localized not-found page for unknown routes; auth-redirect strategy documented in router (not enabled) |
| Multilingual | `LearningLanguage` decoupled from interface languages; `hasTranslation`; tests for Arabic diacritics, fallback, completeness of course titles |
| Resilience | `semanticColors` no longer crashes without the theme extension |

## Not done / partial (be explicit)
- Not done: premium UI redesign, lesson block ids/versioning, multiple-select / matching / ordering / fill-blank questions (semantics not specified), Dio implementation, auth redirect, accessibility audit on devices (TalkBack/VoiceOver), performance profiling on a real low-end device (code reviewed: lazy lists, `select` rebuild scoping, coalesced writes).
- Partial: Phase 4 dashboard (no selected-course/CEFR card).

## Packages
flutter_riverpod 3.4, go_router 18, flutter_localizations, intl, shared_preferences 2.5. No packages added or removed this session.

## Known issues / risks
- Plain Android debug build fails on this machine (see above); fix path: keep project and pub cache on the same drive or set `kotlin.incremental=false` deliberately (developer decision; not applied).
- Local demo progress/preferences only; no account sync. Device clock drives dashboard/streak.
- Generated plugin files under linux/macos/windows show line-ending-only modifications; not touched.
- Word detail sheet lacks a favorite toggle; review history has no dedicated screen.

## Backend integration pending
See `docs/architecture/API_INTEGRATION.md` (authentication, profile, catalog, lesson blocks, completion events, quiz grading, vocabulary sync, progress reconciliation, media).

## iOS validation still required (on macOS/Xcode)
Build and run; `shared_preferences` persistence on device; safe areas, keyboard insets, back-swipe; VoiceOver with RTL; text scaling.

## Next steps
1. Review and commit the V2 + hardening work.
2. Product input needed before: lesson media/AI blocks, additional question types, grading policy.
3. Dio adapter + DTOs once the backend contract is confirmed.
4. UI/accessibility pass on emulator/device; decide on `kotlin.incremental` / drive layout.
