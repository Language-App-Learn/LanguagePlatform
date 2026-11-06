# API integration readiness (ASP.NET Core backend)

No endpoint is assumed to exist. `core/network/api_client.dart` only defines the transport boundary (`ApiClient`, `ApiRequest`, `ApiResponse.unwrap`, `failureForStatus`). Dio will be added together with the first confirmed contract.

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

## Five-stage lesson track (V5)

Existing backend contract (`FLUTTER_BACKEND_CONTRACT.md` on `origin/Backend-Database`, read-only): catalog (languages, learning paths, programs, courses), published lesson outline/read, auth (register/login/refresh/logout/reset), preferences, enrollment, lesson start, assessment attempts + result, progress, vocabulary + favorites. The five-stage contract (`FIVE_STAGE_LESSON_CONTRACT.md`) is NOT published yet.

Client side already prepared: `ServerLessonResult` (final score, server pass flag, stage scores, optional weights) and `serverLessonResultProvider` are the only entry points for official results; the UI never recomputes pass/fail. Demo stage content (`demoStageContent`, one lesson) and local practice scores (`lp.stages`) are clearly labeled and never uploaded.

Needed from the five-stage contract: stage content DTOs (reading segments with stable ids + audio references, questions without answer keys, dialogue, listening blanks + word bank, writing items, translation items + accepted alternatives), attempt/submit endpoints per stage, final result shape (score, pass flag, weights, retry/next-lesson eligibility), media/PDF download URL lifetime, TTS/STT/AI provider availability signalling.
