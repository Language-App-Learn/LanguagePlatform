# API integration readiness (ASP.NET Core backend)

Status (V6): the documented contracts (`FLUTTER_BACKEND_CONTRACT.md`, `FIVE_STAGE_LESSON_CONTRACT.md` on `origin/Backend-Database`) are integrated for catalog, auth, lessons, learner progress and objective assessments. Only documented routes are used; none is assumed. Transport is `dart:io` (`HttpApiClient`), so no HTTP package was added. The checklist below is the older pre-integration readiness table; the V6 section at the end is current.

## Failure model (`core/errors/app_failure.dart`)

NetworkUnavailable, Timeout, Unauthorized, Forbidden, Validation, NotFound, Server, UnexpectedResponse, ServiceUnavailable (integration pending), Unknown. Widgets show localized messages by kind (`AppFailure.message`); retry is offered only for recoverable kinds. Raw exceptions never reach the UI.

## Integration checklist

Legend: LOCAL = model exists in the app; BOUNDARY = proposed client boundary; OPEN = backend contract unconfirmed; NONE = not implemented.

| Area | Local model / boundary | Needs confirmation |
|---|---|---|
| Authentication | LOCAL `AuthRepository`, `UnavailableAuthRepository` (always fails honestly), `SessionStatus` | OPEN endpoints, token and refresh strategy, error format, email verification; secure storage choice (NONE) |
| User profile | NONE (profile shows demo placeholders) | OPEN profile DTO, editable fields |
| Learning language preferences | LOCAL `LearningPreferences` | OPEN server storage, supported-language catalog |
| Course catalog / details | LOCAL `Course`, `CourseRepository` (demo) | OPEN id type, paging, level and category fields, multilingual field format |
| Lesson content | LOCAL `Lesson`, sealed `LessonContent`, `LessonValidator` | OPEN block schema, type discriminator, block ids and versions, media metadata (NONE) |
| Lesson completion | LOCAL `ProgressNotifier.completeLesson` | OPEN event endpoint, idempotency, offline queue |
| Assessment / quiz results | LOCAL `QuizQuestion` types, local scoring | OPEN question DTO per type; grading must be server-side for anything official (client score is not authoritative) |
| Vocabulary records | LOCAL `VocabularyRecord`, `ReviewState` | OPEN dictionary API, sync of review state |
| Learning progress | LOCAL activity log | OPEN reconciliation of local vs server progress |
| Content localization | LOCAL `LocalizedText`, `LearningLanguage` | OPEN translation payload shape, fallback policy |
| Media metadata | NONE | OPEN everything |

## When a contract is confirmed

1. Add DTOs and mappers in the feature's `data/` layer (DTO to domain; DTOs never reach the UI).
2. Implement the repository over `ApiClient` (a Dio adapter), mapping errors with `failureOf`.
3. Bind it in the repository provider (demo implementations stay for tests and development).
4. Enable an auth `redirect` in `app_router.dart` (strategy is documented there). Demo mode must never count as signed in.

## Backend verification note (V4 session)

The backend project present in this workspace (`backend/`, branch `Flutter`) contains only the template route `GET /weatherforecast`; none of the catalog routes (`/api/v1/catalog/languages|learning-paths|programs|courses`) mentioned by the backend team could be verified here, so no API adapter or DTO was written. To implement the first adapter, the mobile team needs from the backend branch: the OpenAPI/route list, JSON field names and types for languages, learning paths, programs and courses, the id type, pagination and error body format, and how a course relates to lessons. The stable language identifiers used on the client are ISO 639-1 codes (`en`, `tr`, `ar`).

## Real backend integration (V6)

Layers (under `mobile/lib`):
- `core/config/api_config.dart`: `API_BASE_URL` via `--dart-define`; https, or http only for local / private hosts. Unset means demo mode only.
- `core/network/`: `ApiClient` boundary (`requiresAuth`, `headers`, `ensureSuccess`), `HttpApiClient`, `AuthenticatedApiClient` (bearer, single-flight refresh `POST /api/v1/auth/refresh`, one retry, session-expiry callback), `TokenStore` (in memory; secure storage pending approval).
- `features/authentication/data/remote_auth_repository.dart`: `/api/v1/auth/{login,register,password-reset/request,logout}`.
- `features/learning_track/data/`: `five_stage_dto.dart` (strict on ids, tolerant on optional fields, unknown CEFR codes skipped, unknown stage status becomes locked) and `ApiFiveStageRepository`:

| Purpose | Route |
|---|---|
| Course | `GET /api/v1/catalog/courses` (optional `locale`) |
| Levels / slots | `GET /api/v1/courses/{id}/curriculum/levels`, `.../levels/{levelId}/slots` |
| Lesson | `GET /api/v1/courses/{id}/lessons/{lessonId}` |
| Passed lessons | `GET /api/v1/me/courses/{id}/lessons/progress?completedOnly=true` (paged) |
| Enrol / start | `PUT /api/v1/me/courses/{id}/enrollment`, `PUT .../lessons/{lessonId}/start` |
| Stage progress + official result | `GET /api/v1/me/courses/{id}/lessons/{lessonId}/curriculum-progress` |
| Attempt start / submit | `POST .../lessons/{lessonId}/assessments/{assessmentId}/attempts`, `.../attempts/{attemptId}/submit` (idempotency key on start) |

Learner routes send `requiresAuth: true`. `contentModeProvider` is remote only when the API is configured and the session is not demo; demo ids and practice scores are never sent and never shown for real accounts.

Rules kept: pass decision, final score, per-stage scores and weights come from the server; the client never recomputes pass/fail and never invents weights; questions carry no answer keys.

Open items: secure token storage, media (audio / PDF / video), server content for listening / writing / translation / speaking, display name at registration, live-server smoke test (see PROJECT_STATUS.md).

## V7 additions (2026-11-07)

Additional documented routes now used by `ApiFiveStageRepository` / `RemoteAuthRepository`:

| Purpose | Route |
|---|---|
| Reading lines | `GET /api/v1/me/courses/{id}/lessons/{lessonId}/reading-material` (404 = none) |
| Original PDF | `GET .../reading-material/original` (binary, `Content-Type: application/pdf` enforced, `%PDF-` checked, 10 MiB cap) |
| Stage media metadata | `GET .../stages/{stageId}/media` (https URLs only) |
| Attempt result | `GET /api/v1/me/assessment-attempts/{attemptId}/result` (404 = pending) |
| Account | `POST /auth/confirm-email`, `/auth/confirm-email/resend`, `/auth/password-reset/confirm`, `GET /api/v1/me` |

Transport rules (`HttpApiClient`): redirects are never followed; only GET is retried (network/timeout/502/503/504, 2 retries); 409 → `ConflictFailure`, 413 → `PayloadTooLargeFailure`, 415 → `UnsupportedMediaFailure`, 429 → `RateLimitedFailure(retryAfter)`; `X-Correlation-Id` on every request; ProblemDetails is parsed for diagnostics but never shown.

Result semantics: the objective result's `passed` uses a zero threshold, so the app shows only score/maximum for an attempt. The lesson pass/fail, final score, stage scores, attempts and `nextLessonId` come from `curriculum-progress` and are displayed truncated to two decimals (like the server) - never rounded.

Attempt lifecycle: `PendingAttemptStore` (`lp.attempts`, random 128-bit keys, no account data) keeps the idempotency key from start until submit succeeds; ambiguous failures and app restarts reuse it; a retake renews it; definitive rejections (400/401/403/404/409) release it; every identity change clears it.

Open questions for the backend are in `docs/api-feedback/BACKEND_FEEDBACK.md`.

## V8 additions (2026-11-07)

* `POST /api/v1/me/privacy/deletion-request` `{password, authenticatorCode?}` - 202 only. Anything else (including 200) is not treated as a deletion. On 202 the local session is cleared. `GET /me/privacy/export` exists on the backend and is not used by the app.
* `POST /auth/login` accepts an optional `authenticatorCode` (sent only when entered).
* Stage media `status` (`available` / `unavailable` / `unconfigured`): only `available` produces players; blocked links are dropped. The API has no signed-media issuer or expiry contract; the app re-reads the metadata on a playback failure.
* Verified end-to-end against the real backend; see `docs/testing/E2E_REAL_BACKEND.md` and `docs/api-feedback/BACKEND_FEEDBACK.md` (resolved / unresolved / new).
