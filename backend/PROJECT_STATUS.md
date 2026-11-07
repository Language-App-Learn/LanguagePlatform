# Backend project status

The 2026-11-07 implementation started on `Backend-Database` at `f3655048b42d88daf300108b475492cd2d41f6b1`, verified against `origin/Backend-Database`.

## Working backend slices

- Published, directional catalog with locale fallback, slug cursor pagination and details.
- Identity password login, confirmation, opaque bearer rotation and revocation, account reads, preference updates and password reset. A registered delivery adapter is required for registration and email dispatch. No outbound provider is registered.
- Published course outline and lesson stages. Enrollment, explicit lesson start, resume and completion queries. Objective assessment snapshots, server grading and atomic lesson progress updates.
- Authenticated dictionary reads and private favorites. Permission-protected lesson publication writes the publication, audit and outbox together.
- Liveness, PostgreSQL readiness, sanitized ProblemDetails and Development OpenAPI. See the [Flutter contract](../docs/api/FLUTTER_BACKEND_CONTRACT.md) for paths and payloads.
- Turkish-to-Arabic student release filtering, six CEFR levels with 20 addressable positions each, and permission-protected course and version drafts. Lesson versions enforce five ordered required stages and explicit approved weights totaling 100. An incomplete lesson has a null final score. A graded final result of at least 60 permits the next published slot.
- Five-stage authors can create, review and publish lessons and release a course after publishing A1 slot 1. Publication validates exactly ten reviewed reading questions, speaking prompt and rubric, listening audio, supported question sets, and approved scoring weights. Lesson publication, assessment flags, audit and outbox commit together.
- The learner API grades reading, listening word banks and blanks, writing blanks and word ordering, and Turkish-to-Arabic choice and exact text. Speaking is scored by an authorized evaluator using the lesson rubric. Stage results, retries and overall progress use the same server-side persistence path.
- Teachers can upload a private PDF, review the extracted pages, and approve corrected reading lines. Enrolled students can fetch approved lines and download the unchanged original from the published version. Teacher video and listening audio are authored HTTPS metadata. See the [five-stage contract](../docs/api/FIVE_STAGE_LESSON_CONTRACT.md).

## Verification

PostgreSQL 18.6 was verified in a temporary loopback cluster with isolated schemas under `language_platform_test`. All nine migrations applied. `20261106213735_AddReviewedLessonPdf` adds four columns, one filtered unique index and one check while preserving earlier tables, rows and indexes. EF reports no pending model changes. Development and production databases were outside this run. See the [database guide](../docs/database/postgresql.md).

The build had zero warnings and zero errors. The PostgreSQL-backed suite passed 37 tests (21 Domain, 1 Application, 15 API/model, including 9 PostgreSQL tests). The end-to-end HTTP test uses real Identity, PDF extraction and PostgreSQL with synthetic content. It publishes through the API, grades five stages, keeps the next lesson locked after a 50/100 result, and unlocks it after a retake raises the result to 60/100. OpenAPI is parsed from the Development test host. EF CLI 10.0.9 reports a tooling-version warning against EF runtime 10.0.14.

## Next checkpoint

1. Load teacher-provided A1 content, including the reviewed Arabic passage, ten questions, explicit weights, speaking rubric and listening audio. The test fixture is synthetic.
2. Wire production speech providers and an audio capture/session workflow when available. The current API supports instructor evaluation and contains TTS, transcription and AI evaluation interfaces.
3. Integrate the published endpoints in Flutter using the [client handoff](../docs/api/FIVE_STAGE_LESSON_CONTRACT.md#flutter-handoff). Keep the remote assessment payload separate from local practice data.

Production email, privileged account management, assessment localization, review scheduling, payments and automated speech remain separate work. PDF ingestion extracts embedded text. Scans need teacher-entered lines. The current PDF workflow has no OCR or malware-scanning service.
