# Turkish-to-Arabic five-stage lesson contract

The current backend checkpoint implements curriculum structure, permission-protected drafts, and learner progress rules. Student endpoints were exercised with synthetic published records in a disposable PostgreSQL test database. Five-stage publication through the API currently rejects lessons because the remaining stage workflows are unavailable.

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
| POST `/api/v1/admin/five-stage/versions/{versionId}/review` | `{expectedVersion}` uses the draft's revision and returns its updated revision. |
| POST `/api/v1/admin/lesson-versions/{versionId}/publish` | `{expectedVersion}` requires `content.publish`. Five-stage validation checks structure, explicit approved weights, Arabic reading text and ten comprehension questions. The current gate returns 400 before committing a five-stage publication. |

A draft snapshot request has `title`, `approveWeights`, `attemptSelection` (`0` for Best or `1` for Latest), and `stages`. Each stage input has `kind`, nullable `weight`, `maximumAttempts` (1–100), nullable `arabicText`, nullable `turkishText`, and nullable `questions`. Unspecified stage definitions are empty draft stages. Approving weights requires all five explicit values, each from 0 through 100 with up to four decimal places. The server creates stage order. Reading accepts up to ten `{kind:"TrueFalse",prompt,correctValue}` or `{kind:"MultipleChoice",prompt,options:[{text,isCorrect}]}` draft questions. Translation draft questions use multiple choice. The draft endpoint preserves supplied Arabic Unicode text in the stage body.

Validation failures return 400, absent sessions return 401, missing permissions return 403, unavailable resources return 404 and stale revisions or conflicting writes return 409. Responses use the shared ProblemDetails format.

## Flutter handoff

- Consume catalog and slot identifiers as strings. In remote mode, adapt `levelPositionsProvider` to render server `position` and preserve empty slots. One server course spans all six levels.
- The Flutter `LessonStage` enum already matches the five backend kinds. Adapt the response to the existing stage UI using server status and version IDs. Set `serverLessonResultProvider` only when `finalScore` exists. Change the official result's integer score fields to accept fractional values, keep stage scores nullable until graded, and use the server's `passed` and `nextLessonId`.
- Reuse the [base Flutter contract](FLUTTER_BACKEND_CONTRACT.md) for authentication, ProblemDetails, lesson detail and objective snapshots. Keep demo `lp.stages` and demo answer-bearing exercise models separate from the remote attempt model. Map stage weights from published lesson metadata. Render Arabic with RTL direction and preserve its Unicode.
- Keep end-to-end five-stage access behind fixture/test configuration until publication is enabled. Secure PDF ingestion, approved reading segments and originals, video playback, deterministic listening and writing interactions, authored exact translation variants, TTS, and speaking capture/transcription/evaluation remain pending. The current API has no production media or AI provider attached to these stage workflows.
