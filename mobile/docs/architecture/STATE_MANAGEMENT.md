# State management (Riverpod 3)

## Ownership

| State | Provider | Persisted |
|---|---|---|
| Interface language (null = follow device) | `appLanguageProvider` | `lp.preferences` |
| Theme mode | `themeModeProvider` | `lp.preferences` |
| Known / target language | `learningPreferencesProvider` | `lp.preferences` |
| Onboarding completed | `onboardingCompletedProvider` | `lp.preferences` |
| Local progress (lessons, quiz, last opened, activity, goal) | `progressProvider` | `lp.progress` |
| Vocabulary records (status, favorite, review schedule) | `vocabularyRecordsProvider` | `lp.vocabulary` |
| Demo/session status | `sessionProvider` | no (demo is never a real session) |
| Catalog filter | `catalogFilterProvider` | no |
| Quiz session | `quizControllerProvider(lessonId)` (autoDispose) | result goes to progress |
| Review session | `reviewSessionProvider` (autoDispose, snapshot queue) | each rating goes to vocabulary + progress |

Derived (never stored): `contentLanguageProvider`, `targetLanguageCodeProvider`, `filteredCoursesProvider`, `targetCoursesProvider`, `learningPathProvider`, `dueReviewCountProvider`, `persistenceFailuresProvider`.

## Rules

- One mutable owner per fact; everything else is derived with `ref.watch` / `select`.
- Notifiers load their initial state from storage in `build()`; an explicit constructor argument (tests) overrides it. Every mutation updates `state` first, then writes through the repository.
- Async data uses `FutureProvider` / `AsyncNotifier`; screens render it with `AsyncValueView` (loading, error + retry, empty, data). Automatic provider retry is disabled in `bootstrap` (manual "Try again").
- Time comes from `clockProvider`; logic never calls `DateTime.now()` directly.
- Tests override `keyValueStoreProvider` (a restart is a new container over the same store), `clockProvider`, repositories, or single notifiers.
