# Turkish-to-Arabic five-stage lesson contract

The five-stage API supports authoring, review, publication and server-graded learner attempts. Speaking uses an authorized evaluator who assesses the learner separately. The API includes provider interfaces for future speech synthesis, transcription and AI evaluation.

## Student catalog

The student release exposes the active Turkish-to-Arabic path and published Modern Language courses using the five-stage curriculum. Other catalog records remain in PostgreSQL. The languages lookup still supports interface language selection. Development and Testing can explicitly opt into the legacy catalog using `StudentRelease:IncludeLegacyContent=true`.

| Method and path | Result |
| --- | --- |
| GET `/api/v1/courses/{courseId}/curriculum/levels` | `{courseId,levels:[{id,code,order,capacity}]}`. Codes in order are `A1,A2,B1,B2,C1,C2`. Capacity is 20 per level. |
| GET `/api/v1/courses/{courseId}/curriculum/levels/{levelId}/slots` | 20 ordered `{position,lessonId,publishedVersionId,title,draftVersionId}` objects. An empty or unavailable position has null lesson ID, version IDs and title. The public response always has a null `draftVersionId`. |
| GET `/api/v1/courses/{courseId}/lessons/{lessonId}` | Existing lesson detail with the published version, ordered stage metadata and explicit localized text entries. |

These routes are public and return 404 for unavailable resources. A slot is identified by its level UUID and integer position. Its lesson UUID stays stable across new versions. A version UUID identifies a separate stage and scoring snapshot.

## Student progress and scoring

Enroll and start via the existing authenticated learning endpoints. The first A1 slot is initially eligible. Each later slot requires a pass on the immediately preceding slot, including transitions between CEFR levels. An unavailable preceding slot holds the sequence. A locked lesson start returns 400. Retrying a start preserves progress.

`GET /api/v1/me/courses/{courseId}/lessons/{lessonId}/curriculum-progress` requires a bearer token and a matching enrollment. It returns 404 for a missing enrollment, a hidden lesson or a legacy version. The response is:

```json
{
  "versionId": "50fbbfaa-19d2-4c39-ac14-6889a1a81845",
  "stages": [
    {"id":"2b7c2479-b8d4-4b0e-ab83-1cef602445cb","kind":"reading","order":1,"status":"available","score":null,"attempts":0},
    {"id":"5127b206-7ce4-46ef-b477-333dc83a4e7c","kind":"speaking","order":2,"status":"locked","score":null,"attempts":0},
    {"id":"874dfed1-3139-4a5f-8abb-5d07a9f65685","kind":"listening","order":3,"status":"locked","score":null,"attempts":0},
    {"id":"ea4d55de-dfd4-49a6-a613-7c9743460e73","kind":"writing","order":4,"status":"locked","score":null,"attempts":0},
    {"id":"68d6a13d-1454-4bd4-ae1d-cd7e602142d4","kind":"translation","order":5,"status":"locked","score":null,"attempts":0}
  ],
  "finalScore": null,
  "passingScore": 60,
  "passed": false,
  "nextLessonId": null
}
```

`available` means eligible in the stage sequence. Call lesson start before taking an assessment. `completed` requires a server-recorded result. `attempts` counts recorded graded stage attempts. The objective assessment API also enforces stage order on the server and returns 409 for a locked assessment. Attempt snapshot IDs and option IDs are opaque. Answer keys are private.

All five required stages must have server-graded scores. Before that, the final score and the five-stage `LessonProgressDto.score` are null. The server selects the best or latest graded attempt according to the version's policy and computes the weighted sum. Authors must explicitly approve five weights totaling 100. Scores of 60 and above pass. The decision uses the weighted value before display truncation. The display score uses up to two decimal places. There is no separate passing threshold for these stages. Use `passed` to render the lesson result and `nextLessonId` to navigate to the immediately following published slot, when supplied.

## Authoring and publication

The existing permission policy `content.edit` protects these routes. Use the normal authenticated account and configured permission grants.

| Method and path | Input and result |
| --- | --- |
| POST `/api/v1/admin/five-stage/courses` | `{slug,title,description}` creates a draft on the active Turkish-to-Arabic and Modern Language records, returning the course and six levels. |
| GET `/api/v1/admin/five-stage/courses/{courseId}/levels/{levelId}/slots` | 20 ordered positions. Includes the newest draft or review version ID where present. |
| POST `/api/v1/admin/five-stage/courses/{courseId}/levels/{levelId}/slots/{position}/versions` | Creates a new draft snapshot and returns `{lessonId,versionId,versionNumber,revision,weightsApproved}`. The position is 1–20. |
| POST `/api/v1/admin/five-stage/versions/{versionId}/review` | `{expectedVersion}` uses the draft's revision and returns its updated revision. This action records the authenticated teacher's review of the version's text and questions. Any uploaded PDF must already have approved lines. |
| POST `/api/v1/admin/lesson-versions/{versionId}/publish` | `{expectedVersion}` requires `content.publish`. Returns 204 and publishes the reviewed lesson version and its assessments together. Invalid content returns 400, stale revision returns 409. |
| POST `/api/v1/admin/five-stage/courses/{courseId}/publish` | Requires `content.publish`. Empty body. Returns 204. Publish the first A1 lesson before releasing the course. |

A draft snapshot request has `title`, `approveWeights`, `attemptSelection` (`0` for Best or `1` for Latest), and `stages`. Each stage input has `kind`, nullable `weight`, `maximumAttempts` (1–100), nullable `arabicText`, nullable `turkishText`, and nullable `questions`. Unspecified definitions are empty draft stages. Approving weights requires all five explicit values from 0 through 100 with up to four decimal places. The server assigns stage order and preserves supplied Unicode.

Publication requires Arabic reading text or approved PDF lines, exactly ten reviewed reading questions, an Arabic speaking prompt with an authored `evaluationRubric`, and a teacher-provided listening `audioUrl`. Listening, writing and translation each require 1–100 supported questions. Reading may include `teacherVideo: {url,title}`. Media URLs must be absolute HTTPS URLs without embedded credentials. The API returns this metadata but does not fetch the remote files.

Validation failures return 400, absent sessions return 401, missing permissions return 403, unavailable resources return 404 and stale revisions or conflicting writes return 409. Responses use the shared ProblemDetails format.

## Assessment attempts

Use the following routes with a student bearer token. Start the lesson first. Get each assessment UUID from the published lesson's stage metadata.

| Method and path | Input and result |
| --- | --- |
| POST `/api/v1/me/courses/{courseId}/lessons/{lessonId}/assessments/{assessmentId}/attempts` | `{idempotencyKey}` → attempt, with UUID `id`, `assessmentId`, `attemptNumber`, `startedAtUtc`, nullable `deadlineUtc` and public `questions`. |
| POST `/api/v1/me/courses/{courseId}/lessons/{lessonId}/assessments/{assessmentId}/attempts/{attemptId}/submit` | `{answers:[...]}` → stored result. A retry returns the first recorded grade. Speaking requires the evaluator route. |
| GET `/api/v1/me/assessment-attempts/{attemptId}/result` | Read the signed-in learner's completed result. It returns 404 while evaluation is pending. |

All question drafts contain `kind` and `prompt`. Optional `maximumScore` defaults to 1, with allowed values above 0 through 100 and up to four decimal places. The public snapshot has `id,kind,prompt,maximumScore,options`, where each option has `id,text`. It excludes answer keys. Submit the question snapshot ID as `questionId` and exactly one answer field.

| Kind | Stage | Authoring fields | Student answer |
| --- | --- | --- | --- |
| `TrueFalse` | Reading | `correctValue` | `value` boolean |
| `MultipleChoice` | Reading, translation | `options:[{text,isCorrect}]` with one correct option | `optionId` |
| `WordBank` | Listening | One `{{blank}}` in the prompt and `options:[{text,isCorrect}]` for that blank | `optionId` |
| `FillBlank` | Listening, writing | One `{{blank}}` and `acceptedAnswers` | `text` |
| `WordOrder` | Writing | `options` in display order with `isCorrect:false`, plus `correctOrder` as a permutation of zero-based option indices | `orderedOptionIds` in logical order |
| `ExactText` | Translation | Turkish prompt and Arabic `acceptedAnswers` | `text` |

Represent multiple blanks as multiple ordered questions. Text matching uses exact ordinal equality with the authored variants. It preserves diacritics and spacing. Word ordering requires each option ID exactly once and compares the resulting token text sequence, including repeated words. Each answer earns the configured points or zero. The learner receives score, maximum score and percentage. The objective result's `passed` refers to the assessment threshold of zero. Use curriculum progress for the official lesson pass/fail decision.

Reuse the same idempotency key when retrying a start request. For a deliberate retake, send a new key within the configured attempt limit. Locked stages and exhausted attempt limits return 409. The latest published version has its own attempt/progress records. Completed earlier results remain available at their result URL. A pass on a prior version remains recorded for sequence eligibility.

## Speaking and media

Speaking starts through the same attempt route and returns an empty question list. A teacher evaluates the learner using the authored rubric. The evaluation route is `/api/v1/admin/courses/{courseId}/lessons/{lessonId}/assessments/{assessmentId}/attempts/{attemptId}/speaking-evaluation`. GET returns `{attemptId,rubric,prompt}`. POST accepts `{score}` between 0 and 100 with up to four decimal places. Both require `assessment.evaluate`. Evaluators cannot grade their own attempts. The evaluation, progress and audit entry are committed together. Learners see the score in the normal result and progress routes.

`GET /api/v1/me/courses/{courseId}/lessons/{lessonId}/stages/{stageId}/media` returns `{audioUrl,teacherVideo}` for an eligible stage. The listening transcript stays private. The provider interfaces `IArabicTextToSpeech`, `IArabicSpeechTranscription` and `IArabicSpeakingEvaluation` are integration boundaries. Automated speech and audio capture have no live endpoints in this release.

## Teacher PDF and reading lines

Teacher routes below share `/api/v1/admin/five-stage/versions/{versionId}/reading-pdf` and require `content.edit`. After upload, the uploader owns the file's draft review and author-side download.

| Method and suffix | Input and result |
| --- | --- |
| POST base | Raw `application/pdf` body and query parameters `expectedVersion,title,copyrightNotice`. Returns `{id,revision,approved,pages:[{page,text}]}` with the new version revision and extracted draft text. |
| GET base | Returns the uploader's draft extraction and current version revision. |
| PUT `/review` | `{expectedVersion,pages:[{page,lines:[string]}]}` approves corrected Arabic lines and returns the new revision. |
| GET `/original` | Downloads the unchanged original as a private attachment. |

Upload accepts up to 2 MiB and 30 pages. Oversized uploads return 413, unsupported media type returns 415, invalid or encrypted files return 400, and saturation of the concurrent upload limit returns 429. Files with no embedded text can be reviewed by entering lines manually. One PDF may be attached to a draft version. To replace an approved or published source, create a new version. Extracted text stays in the teacher flow.

Students use `GET /api/v1/me/courses/{courseId}/lessons/{lessonId}/reading-material` for `{lines:[{id,page,order,text}],hasOriginalPdf}`, and append `/original` for the unchanged PDF attachment. Both require enrollment and access to the published reading stage. Missing or inaccessible material returns 404. If the lesson was authored with text only, use its published stage text when the lines list is empty.

## Flutter handoff

- Consume catalog and slot identifiers as strings. In remote mode, adapt `levelPositionsProvider` to render server `position` and preserve empty slots. One server course spans all six levels.
- The Flutter `LessonStage` enum already matches the five backend kinds. Adapt the response to the existing stage UI using server status and version IDs. Set `serverLessonResultProvider` only when `finalScore` exists. Change the official result's integer score fields to accept fractional values, keep stage scores nullable until graded, and use the server's `passed` and `nextLessonId`.
- Reuse the [base Flutter contract](FLUTTER_BACKEND_CONTRACT.md) for authentication, ProblemDetails, lesson detail and objective snapshots. Keep demo `lp.stages` and demo answer-bearing exercise models separate from the remote attempt model. Map stage weights from published lesson metadata. Render Arabic with RTL direction and preserve its Unicode.
- Use the attempt snapshots for the four objective stages. Open reading originals as authenticated attachments, and use the protected media endpoint for playback metadata. For speaking, display a pending result until the evaluator records a score. Automated speech requires a future provider and capture contract.
