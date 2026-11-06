# Architecture overview

Feature-first Flutter app (Android + iOS). State: Riverpod 3. Navigation: GoRouter. Localization: gen-l10n (tr, ar, en).

```
lib/
  main.dart, app/        bootstrap (storage + ProviderScope), app widget, router, shell
  core/                  shared, feature-independent code
    errors/              AppFailure (typed failures) + exceptions
    network/             ApiClient boundary (no implementation yet)
    storage/             KeyValueStore, GuardedKeyValueStore, AppPreferencesRepository
    l10n/                ARB, AppLanguage (UI), LocalizedText (content)
    theme/, design_system/widgets/, utils/, config/
  features/<name>/       presentation/ application/ domain/ data/ (only the layers needed)
```

Features: splash, onboarding, language_selection, authentication, home, catalog, courses, lessons, assessment, vocabulary, progress, profile, settings.

## Dependency direction

`presentation -> application -> domain <- data`. `core/` never imports a feature. Domain code has no widgets (only value types such as `TextDirection`).

Application-layer imports between features have no cycles:
`vocabulary_providers <- lesson_providers <- progress_providers <- review_session / quiz_providers`.
`language_selection` is imported by many features because it owns the learner's languages.

Accepted cross-feature presentation imports (reuse instead of duplication):
`lessons -> assessment/QuestionView`, `home -> progress/activity_widgets`, `settings -> language_selection/language_settings`.

## Decisions

- Lesson blocks are a `sealed class LessonContent` (compile-time exhaustive `switch`). Unknown future block types are modelled by `UnknownContent` and shown as "not supported". A registry/plugin system was deliberately not added; block ids and versioning are deferred until the content contract exists (see API_INTEGRATION.md).
- Questions are a `sealed class QuizQuestion` with `isCorrect` and `validationIssues`; invalid questions are dropped by the quiz controller. Implemented types: multiple choice, true/false.
- Demo vs real: all data comes through `*Repository` interfaces bound to `Demo*Repository` / `Local*` implementations in providers. Switching to remote implementations only changes those providers.

## Evaluated, not implemented: lesson block ids and versions

Blocks currently have no identity beyond their index in `Lesson.contents`. A backward-compatible way to add it later: give `LessonContent` an optional `id` (default derived as `'<lessonId>#<index>'`) and an optional `contentVersion` on `Lesson`, populated by the remote mapper; existing demo lessons and the sealed `switch` stay unchanged. It is deferred because nothing consumes block ids yet (no per-block progress, no server schema).

## Home dashboard sources (all derived from recorded local data)

Active course: last opened course (if it matches the target language) else next course on the learning path. Weekly activity, streak, daily goal, vocabulary totals and due reviews come from `progressProvider` / `vocabularyRecordsProvider` with the injected clock.
