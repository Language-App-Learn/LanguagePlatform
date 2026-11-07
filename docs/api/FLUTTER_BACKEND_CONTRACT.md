# LanguagePlatform Flutter backend contract

This document describes the implemented ASP.NET Core v1 API. The latest Flutter contract review used `origin/Flutter` at `d64c2e342320db721384b57f76f8c6be9d68c2b4`. See the [five-stage lesson contract](FIVE_STAGE_LESSON_CONTRACT.md) for the initial student release, stage states and publication availability.

Use an environment-specific HTTPS API origin with the same `/api/v1` routes. The repository contains the [generated OpenAPI document](openapi.v1.json). The deployed API origin is an operator setting. Keep demo and real environment data separate.

## Transport, identifiers and errors

- JSON uses camelCase. Backend identifiers are UUID strings. Store and pass them as opaque Dart `String` values. Demo slugs and IDs are separate from server UUIDs. Course lookup takes a UUID. Slug is the catalog cursor only.
- Dates use ISO 8601 UTC. Scores and weights are JSON numbers. Keep the server's boolean result and threshold. Do not recalculate pass/fail after display rounding.
- Protected routes require `Authorization: Bearer <accessToken>`. Store tokens in platform secure storage. Keep them out of SharedPreferences, logs and analytics.
- API errors use `application/problem+json` with `status`, `title`, `type`, optional `detail` and `traceId`. Treat English messages as diagnostics. Map status to localized Flutter failure messages. A typical validation response is `{"title":"A business rule was violated.","status":400,"detail":"Limit must be between 1 and 100.","traceId":"example"}`.
- 400 means malformed input or failed validation. 401 means missing/invalid session or rejected sign-in. 403 means an authenticated principal lacks a permission. 404 includes inaccessible private records. 409 means a state or concurrency conflict. 429 means throttling. 500 is a generic error. 503 can mean readiness or email delivery is unavailable.
- On protected 401, perform one coordinated refresh and retry once with the new access token. Concurrent refreshes compete for one session revision. Replace both tokens atomically. A failed or ambiguous refresh may require login. 403 and 409 need action or reload rather than blind retry. Logout invalidates both tickets.
- For Android Emulator, use the host alias `10.0.2.2` with the configured local API port. iOS Simulator can use host localhost when the server runs on its Mac. Physical devices need a reachable LAN host or test deployment. Development certificate trust and hostnames must match. Use TLS for real credentials and tokens.

## Public catalog and lesson reading

All routes in this section are implemented and public. `GET /health` returns 200 with plain text liveness. `GET /health/ready` returns plain text 200/503 for database connectivity. `GET /openapi/v1.json` returns the generated OpenAPI document in Development. The two health middleware routes are described here.

| Method and path | Inputs | Response |
| --- | --- | --- |
| GET `/api/v1/catalog/languages` | None | 200 array of `{id, code, name, nativeName, textDirection, isActive}`. Names and codes are strings, direction is `LeftToRight` or `RightToLeft`, and activity is boolean. |
| GET `/api/v1/catalog/learning-paths` | None | 200 array of `{id, sourceLanguage, targetLanguage, isActive}`. Each language summary contains `id, code, name, nativeName`. A path is directional. |
| GET `/api/v1/catalog/programs` | None | 200 array of `{id, code, name, programType, isActive}`. Type and code are strings. |
| GET `/api/v1/catalog/courses` | Optional `source` and `target` language codes, `learningPathId` and `programId` UUIDs, `locale`, `after` slug, `limit` 1–100 (default 20). Filters combine. | 200 JSON array of courses sorted by slug. Empty means no matches. `X-Next-Cursor` appears only when there are more rows. 400 on invalid filters. |
| GET `/api/v1/catalog/courses/{id}` | UUID and optional `locale` | 200 course. 404 for missing or hidden course. 400 on invalid locale. |
| GET `/api/v1/courses/{courseId}/lessons` | Course UUID, optional `offset` 0–100000 (default 0) and `limit` 1–100 (default 50) | 200 `{items,nextOffset}`. Each item has `id, versionId, versionNumber, title, levelId, levelCode, moduleId, moduleTitle, unitId, unitTitle, order`. Order is level → module → unit → lesson. 404 if course is not public. 400 on invalid paging. |
| GET `/api/v1/courses/{courseId}/lessons/{lessonId}` | Course and lesson UUID | 200 `{id,courseId,versionId,versionNumber,title,targetLanguageCode,order,passingScore,localizations,stages}`. 404 for a hidden or mismatched lesson. |

A course has `id, learningPathId, learningProgramId` (UUID), `slug, title, status, sourceLanguageCode, targetLanguageCode` (strings), `description` (nullable string), `localizations` (array of `{locale,title,description}`), and `levels` (array of `{id,code,order}`). Existing scalar fields remain. For each scalar title/description use requested locale → base language → English → base stored value. Titles and descriptions fall back independently. `localizations` contains explicit translations only. A course must be published and its path, program and both languages active. The default release shows Turkish-to-Arabic five-stage courses in the Modern Language program.

The outline has integer order/version fields and nullable integer `nextOffset`. Lesson translation entries contain `locale,title,description`. Stages are ordered. Each has `id, stageType, order, isRequired, weight, minimumScore, maximumAttempts, estimatedDurationSeconds, texts, assessmentId`. `texts` is an array of `{locale,text}`. `assessmentId` is a nullable UUID for a published assessment. Only the latest published, non-withdrawn lesson version is visible. Drafts and archived lessons are excluded. The outline title uses the stored version title. Lesson detail exposes explicit translations for client-side fallback. Private storage keys, answer keys, arbitrary settings JSON and media URLs are excluded.

Example request: `GET /api/v1/catalog/courses?source=tr&target=ar&locale=tr&limit=10`. An example page without matches is `[]`. Continue a nonempty paged result using the returned header as `after` with the same filters.

## Identity and preferences

| Method and path | Auth | Body and result |
| --- | --- | --- |
| POST `/api/v1/auth/register` | Public | `{email,password}` → 202 generic acceptance. 400 for invalid input/password policy. 503 without configured email delivery. |
| POST `/api/v1/auth/confirm-email` | Public | `{userId,code}` → 204. 400 for invalid or expired code. |
| POST `/api/v1/auth/confirm-email/resend` | Public | `{email}` → 202 generic acceptance or 503 without delivery. |
| POST `/api/v1/auth/login` | Public | `{email,password,authenticatorCode?}` → 200 `{tokenType,accessToken,expiresIn,refreshToken}`. MFA accounts supply a fresh six-digit code. 400 invalid request and 401 rejected credentials or unavailable account. |
| POST `/api/v1/auth/refresh` | Public with valid refresh ticket | `{refreshToken}` → 200 token pair. 401 invalid/expired/replayed ticket. 409 on concurrent state change. |
| POST `/api/v1/auth/logout` | Bearer | Empty body → 204. 401 invalid session, 409 on concurrent update. |
| POST `/api/v1/auth/password-reset/request` | Public | `{email}` → 202 generic acceptance, 400 invalid input or 503 without delivery. |
| POST `/api/v1/auth/password-reset/confirm` | Public | `{email,code,newPassword}` → 204. 400 invalid request, code or password policy. |
| GET `/api/v1/me` | Bearer | 200 `{id,email,displayName}`. Display name is nullable. 401 invalid session. |
| GET `/api/v1/me/preferences` | Bearer | 200 preferences or 404 if not configured. |
| PUT `/api/v1/me/preferences` | Bearer | `{uiLanguageId,learningPathId,dailyGoalMinutes,notificationsEnabled}` → 200 preferences. Invalid or inactive selections return 400. Concurrent creation/update can return 409. |

Account body fields are strings except UUID `userId`. Email is at most 254 characters and passwords at most 256. New passwords follow the Identity policy including length ≥12, mixed case, digit and symbol. Tickets are opaque. `expiresIn` is integer seconds (600) and sessions have an absolute fourteen-day deadline. A coordinated refresh must replace both tickets. On concurrent refresh, one succeeds and the other can receive 401 or 409. Login requires an active confirmed account. Authenticator codes already consumed are rejected. Account endpoints are rate limited. Configured SMTP dispatch is asynchronous, so 202 is generic acceptance. When mail is unavailable, use resend after recovery. No configured adapter returns 503.

| Method and path | Auth | Result |
| --- | --- | --- |
| GET `/api/v1/me/privacy/export?offset=0&limit=25` | Bearer | Paged account, preferences, enrollments, progress, attempts and submitted answers. Limit 1–50. Apply `nextOffset` to continue each collection. Response is private and not cacheable. |
| POST `/api/v1/me/privacy/deletion-request` | Bearer | `{password,authenticatorCode?}` → 202. The account is immediately deactivated and its sessions invalidated. 202 is acceptance for operator review. |

Preferences add `sourceLanguageId` and `targetLanguageId` to the update shape. Both are nullable UUIDs derived from `learningPathId`, which is nullable. `uiLanguageId` is independently required. `dailyGoalMinutes` is an integer from 1–1440. `notificationsEnabled` is boolean. Example response:

```json
{
  "uiLanguageId": "10000000-0000-0000-0000-000000000003",
  "learningPathId": "20000000-0000-0000-0000-000000000001",
  "sourceLanguageId": "10000000-0000-0000-0000-000000000001",
  "targetLanguageId": "10000000-0000-0000-0000-000000000002",
  "dailyGoalMinutes": 15,
  "notificationsEnabled": false
}
```

## Authenticated learning, assessments and vocabulary

All of the following routes require a valid bearer session. The backend derives ownership. A client never sends `studentId`, score or a completion flag.

| Method and path | Body or query | Response and important statuses |
| --- | --- | --- |
| PUT `/api/v1/me/courses/{courseId}/enrollment` | No body | 200 enrollment `{id,courseId,status,enrolledAtUtc}`. A retry returns the existing enrollment. 400 unmet prerequisites, 404 unavailable course. |
| GET `/api/v1/me/courses/{courseId}/progress` | No body | 200 `{enrollment,completedLessons,continueFrom}`. Count is integer. Resume record is nullable. 404 if not enrolled. |
| GET `/api/v1/me/courses/{courseId}/lessons/progress` | Optional `completedOnly` bool, `offset`, `limit` as in outline | 200 `{items,nextOffset}`. 400 invalid paging, 404 absent enrollment. |
| PUT `/api/v1/me/courses/{courseId}/lessons/{lessonId}/start` | No body | 200 lesson progress. Repeats preserve state and record activity once. 400 unmet prerequisites, 404 unavailable lesson/enrollment. |
| GET `/api/v1/me/courses/{courseId}/lessons/{lessonId}/curriculum-progress` | No body | 200 five-stage state and result. 404 unavailable lesson or enrollment. See the [five-stage lesson contract](FIVE_STAGE_LESSON_CONTRACT.md). |
| POST `/api/v1/me/courses/{courseId}/lessons/{lessonId}/assessments/{assessmentId}/attempts` | `{idempotencyKey}` nonempty string, max 128 | 200 attempt. Reuse the same key on retry, use a new key for a deliberate new attempt. 404 for inaccessible assessment, 409 for missing start, conflicting key, unsupported questions or attempt limit. |
| POST `/api/v1/me/courses/{courseId}/lessons/{lessonId}/assessments/{assessmentId}/attempts/{attemptId}/submit` | `{answers:[{questionId,optionId,value}]}` | 200 stored result. 400 invalid or duplicate/missing answers. 404 inaccessible attempt. 409 deadline or concurrent state. Completed replay returns the first stored result. |
| GET `/api/v1/me/assessment-attempts/{attemptId}/result` | No body | 200 stored result or 404 when unavailable to this learner. |
| GET `/api/v1/me/vocabulary` | Optional `targetLanguageId` UUID, `favoritesOnly` bool, `offset`, `limit` as in outline | 200 `{items,nextOffset}`, 400 invalid paging. |
| GET `/api/v1/me/vocabulary/{id}` | Dictionary entry UUID | 200 `{word,senses}` or 404. A sense has `number,definition,translations`, translations have `languageCode,text`. |
| PUT `/api/v1/me/vocabulary/{id}/favorite` | `{isFavorite:true}` or false | 204, 404 unknown/inactive-language entry. Updates only own favorite. |
| POST `/api/v1/admin/lesson-versions/{versionId}/publish` | `{expectedVersion}` uint32 concurrency token | 204 with `content.publish` permission. 400 invalid publication, 401 missing session, 403 missing permission, 404 missing version, 409 stale version. Not a Flutter student operation. |

Lesson progress has `lessonId,lessonVersionId,score,isPassed,updatedAtUtc`. The five-stage `score` is null until all five required stages have graded results. A list/detail GET has no effect on activity. `continueFrom` refers to the most recently updated progress version. Completion is derived from saved server scoring.

An attempt has `id,assessmentId,attemptNumber,startedAtUtc,deadlineUtc,questions`. Question `id` is the attempt snapshot UUID, and fields are `kind,prompt,maximumScore,options`. Options have `id,text`. The baseline kinds are `MultipleChoice` (one correct option) and `TrueFalse` (boolean). The five-stage API adds word banks, exact text, blanks and word ordering, as detailed in the [five-stage lesson contract](FIVE_STAGE_LESSON_CONTRACT.md#assessment-attempts). True/false labels are localized by the UI. Submit exactly one answer for each snapshot. Example:

```json
{"answers":[{"questionId":"52e37e02-64a2-4043-a38c-35e42a649d02","value":true}]}
```

The result is `{attemptId,score,maximumScore,percentage,passingScore,passed,completedAtUtc}`. The server grades from stored snapshot keys and weights, using the assessment pass threshold captured at start. Lesson completion follows its own published stage and score policy. The demo's local 70% threshold is not used. Score, progress and activity changes commit together.

Vocabulary list items are `{id,languageCode,lemma,partOfSpeech,isFavorite}`. Definitions are authored text, with explicit translation languages. The server currently stores favorites. Learned state, due queues, review history and offline reconciliation are pending. Flutter's current scheduler is deterministic boxes 0–5 with intervals 10 minutes and 1/3/7/16/35 days. A later server scheduler needs an explicit reconciliation policy for reordered requests and local calendar days.

## Claude handoff and pending contracts

1. Implement transport and DTO mappers in the Flutter `data/` layer. Start with catalog and lesson reads. For course titles/descriptions, map explicit locales to `LocalizedText` with the server scalar as fallback. Map target language code separately from UI language and source language.
2. The Flutter Course model expects one CEFR enum and a full ordered lesson ID list. Use level codes and the paged outline. For multi-level/non-CEFR courses agree on a UI representation before choosing a level silently.
3. Lesson version and stage IDs are new stable identifiers. Map safe text entries to `TextContent` and unsupported kinds to `UnknownContent`. Convert seconds to displayed minutes. Rich dialogue, grammar, example and media blocks need an agreed schema. Do not manufacture audio/video URLs.
4. Keep demo quiz models separate. They require a correct answer for local scoring. A remote attempt needs a presentation model with no answer key and a submission adapter that uses snapshot IDs. Render the server result instead of injecting fabricated correct IDs into the demo model.
5. Enable auth only when test/production delivery and key storage are provisioned. Then bind the authenticated repositories for preferences, enrollment, progress, assessments and favorites. Never merge `lp.progress` or `lp.vocabulary` demo state into accounts by default.

For offline use, persist only the student's pending submissions and the attempt/version IDs under the account that created them. On reconnect, resume from the server's progress and attempt result, and reuse the original idempotency key. If the server returns 404 or a different version, refresh published content and reconcile without moving answers to a new attempt. Keep offline practice results local. There is no bulk reconciliation API. Pending surfaces include profile edits, fully approved account purge, review scheduling, signed media, subscriptions and automated speech.
