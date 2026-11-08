# Data and persistence

## Storage stack

`KeyValueStore` (synchronous read, asynchronous write):

- `SharedPreferencesKeyValueStore`: throws `StorageException` when the plugin reports a failed write.
- `MemoryKeyValueStore`: test default, and fallback when platform storage cannot be opened.
- `GuardedKeyValueStore` (wraps the real store in `bootstrap`): per-key ordered writes, coalescing of rapid writes (newest wins), read-your-writes, and failure accounting. A failed write never throws into UI code; it increments `failedWrites` (shown as a warning in Settings through `persistenceFailuresProvider`). The value stays in memory and is retried by the next write of that key.

## Documents (JSON, versioned with `"v"`)

| Key | Repository | Content |
|---|---|---|
| `lp.preferences` | `AppPreferencesRepository` | languages, theme, onboarding flag |
| `lp.progress` | `LocalProgressRepository` | completed lessons, best quiz scores, last opened, daily goal, activity log (max 500) |
| `lp.vocabulary` | `LocalVocabularyStore` | per word: status, favorite, review state (box, due, last, count, lapses) |

Keys and v1 shapes are unchanged since the first persistence release, so data written by earlier builds still loads.

Rules: missing or corrupted JSON gives defaults; a version newer than the app knows is ignored; bad entries are skipped individually; numbers are clamped. When bumping a version, add a migration step in the repository loader.

## Reset

`resetLocalData` waits for pending writes, clears all `lp.*` keys and invalidates the notifiers. Settings asks for confirmation, then navigates to splash, which leads to onboarding.

## Local vs server data

Everything above is LOCAL DEMO state, not account data. Passwords and tokens must never be stored here (use platform secure storage when real authentication exists). Server-authoritative progress needs a reconciliation design (see API_INTEGRATION.md); no synchronisation is implemented.

## Metric definitions

- Lesson completed: explicit "Mark as complete" or a passed quiz (70% or more). Opening a lesson never completes it.
- Activity event: one per learner action (lesson completed manually, quiz finished, vocabulary reviewed). A passed quiz that completes a lesson records only the quiz event.
- Streak: consecutive local calendar days with at least one activity event, ending today (or yesterday if nothing happened yet today).
- Daily goal: lessons completed on the current local day divided by the goal.
- Spaced repetition: deterministic Leitner scheduler, boxes 0-5 with 10 min, 1, 3, 7, 16 and 35 days; time is injected.
