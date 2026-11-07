# Feedback for the backend team (contract questions and mismatches)

Written from the Flutter side after integrating `FLUTTER_BACKEND_CONTRACT.md` and `FIVE_STAGE_LESSON_CONTRACT.md` (Backend-Database `1c7378c`). Nothing here was patched from Flutter; the backend branch was only read.

## Needed to ship

1. **Account deletion.** Google Play and the App Store require an in-app way to delete an account that can be created in the app. No route exists. Please publish one (and what happens to attempts/progress).
2. **Email links.** The confirmation and reset emails need a defined link format. The app can handle `/auth/confirm-email?userId=…&code=…` but registers no OS deep link. Proposal: verified HTTPS App Links / Universal Links on a backend-controlled host, same query names, code URL-encoded.
3. **Speaking pending state.** `GET /me/assessment-attempts/{id}/result` returns 404 both for "evaluation pending" and for "not yours / unknown". The app treats 404 as pending. A distinct `202`/`status:"pending"` would remove the ambiguity.
4. **Provider status.** There is no endpoint saying whether TTS / transcription / AI evaluation are enabled. The app shows "AI practice is not available" statically. A small `GET /api/v1/features` (or fields on stage media) would let the UI switch on without a release.

## Clarifications (the app currently assumes the stated reading)

5. **Objective `passed`.** The contract says it uses an assessment threshold of zero. The app therefore never shows a pass/fail verdict for an attempt, only score/maximum, and shows the lesson verdict from `curriculum-progress.passed`. Please confirm, or add a field making this unmistakable.
6. **Idempotency.** The app reuses the same `idempotencyKey` after timeouts and after an app restart until submit succeeds, assuming the start call then returns the *same* attempt (same id, same questions). Please confirm that holds (a) while the attempt is open, (b) after it was submitted (what is returned?), (c) after the deadline.
7. **Attempt limits.** Exhausted attempts return 409. A machine-readable reason (limit / locked / deadline / closed) would let the UI show a precise message; today all are "not available right now".
8. **Media URLs.** Are signed URLs time-limited? Please document the lifetime and whether `stages/{id}/media` must be re-read before each playback. The app only accepts absolute https URLs without credentials and never displays or logs them.
9. **Reading material.** If `lines` is empty the app falls back to the stage's `ar` text. Please confirm `ar` is the right key and that `tr` is a translation shown beside it, not the exercise prompt.
10. **Registration.** Only `{email,password}` is accepted; there is no way to set `displayName`. Is a profile update route planned?
11. **429.** Which routes are rate limited and is `Retry-After` always sent (delta-seconds)? The app honours the delta-seconds form only.
12. **Passed lessons list.** `GET /me/courses/{id}/lessons/progress?completedOnly=true` is read for the level counters via `items[].isPassed`; please confirm `isPassed` is the lesson-level pass decision for the *latest published version* (the contract text says earlier-version passes still count for sequencing).

## Not yet integrated (contract exists)

`GET/PUT /me/preferences`, vocabulary routes. The app keeps vocabulary/review as clearly labelled local practice data.

## Test data we need for a real end-to-end run

A development environment with email delivery stubbed (or a pre-confirmed test account), one published course with at least lesson 1 containing all five stages: ten reading questions, a speaking prompt, a listening item with `audioUrl`, writing (FillBlank + WordOrder) and translation (MultipleChoice + ExactText), one approved reading PDF, and a teacher account that can record a speaking score.
