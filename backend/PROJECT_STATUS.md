# Backend project status

Verified 2026-11-06 on local `Backend-Database` at `24f0ea66a811547afc151743f91aa5c1671d4bb0`, matching the fetched `origin/Backend-Database`. The curriculum changes are local working-tree changes. The mobile contract review used `origin/Flutter` at `d64c2e342320db721384b57f76f8c6be9d68c2b4`.

## Working backend slices

- Published, directional catalog with locale fallback, slug cursor pagination and details.
- Identity password login, confirmation, opaque bearer rotation and revocation, account reads, preference updates and password reset. A registered delivery adapter is required for registration and email dispatch. No outbound provider is registered.
- Published course outline and lesson stages. Enrollment, explicit lesson start, resume and completion queries. Objective assessment snapshots, server grading and atomic lesson progress updates.
- Authenticated dictionary reads and private favorites. Permission-protected lesson publication writes the publication, audit and outbox together.
- Liveness, PostgreSQL readiness, sanitized ProblemDetails and Development OpenAPI. See the [Flutter contract](../docs/api/FLUTTER_BACKEND_CONTRACT.md) for paths and payloads.
- Turkish-to-Arabic student release filtering, six CEFR levels with 20 addressable positions each, and permission-protected course and version drafts. Lesson versions enforce five ordered required stages and explicit approved weights totaling 100. An incomplete lesson has a null final score. A graded final result of at least 60 permits the next published slot.
- The five-stage student contract covers curriculum reads, enrollment, sequential start and stage progress. The synthetic PostgreSQL fixture verifies these surfaces. The authoring API can create draft text and reading/translation objective questions. The publication handler rejects five-stage drafts before they reach students because the remaining stage workflows are unavailable. See the [five-stage contract](../docs/api/FIVE_STAGE_LESSON_CONTRACT.md).

## Verification

Baseline restore/build passed with zero warnings/errors. The baseline test run passed 24 and skipped eight PostgreSQL tests before configuring the disposable test instance.

PostgreSQL 18.6 was verified in a temporary loopback cluster, with real migrations in isolated schemas under `language_platform_test`. All eight migrations applied. `20261106173323_AddFiveStageCurriculum` adds five columns, one unique index, one restricted foreign key and two checks. The reviewed forward SQL preserves earlier tables and data. EF reports no pending model changes. Development and production databases were outside this run. See the [database guide](../docs/database/postgresql.md).

The final build had zero warnings and zero errors. The PostgreSQL-backed suite passed 37 tests with zero failures or skips (21 Domain, 1 Application, 15 API/model, including 9 PostgreSQL tests). HTTP tests use real Identity and PostgreSQL. With a synthetic published lesson, the learner submitted ten reading questions through the API and earned a stage score of 60 while the final score remained null. The integration test also checked the locked translation assessment, authorization, Arabic text integrity and the next-slot read after a synthetic completed result. Account email uses a test delivery adapter. OpenAPI is parsed from the Development test host and checked for public and bearer-protected operations. EF CLI 10.0.9 reported a tooling-version warning against EF runtime 10.0.14.

## Next checkpoint

1. Resume with P2 of the five-stage task. Complete the approved reading-content contract and the ten-question reading assessment publication path. Add typed listening blanks and word-bank items, writing fill and word ordering, and translation multiple choice or exact authored alternatives. Extend snapshot grading and test all supported interactions against PostgreSQL, including retakes and a version change.
2. Complete P3 for teachers. Add private PDF intake with validation and limits, extracted-text review and approval, protected original downloads, and approved lesson video metadata. Tie material and question revisions to the version's publication transaction.
3. Complete P4 with TTS, secure speaking session upload and transcription/evaluation abstractions. Test unconfigured and failed providers. A deployed speaking pipeline needs real providers and approved evaluation rules.
4. Complete the publication workflow and end-to-end A1 fixture once the required stage contracts and provider handling are ready. Verify version immutability, score and unlock behavior through public APIs, then hand off the full contract to Claude. The current [Flutter handoff](../docs/api/FIVE_STAGE_LESSON_CONTRACT.md#flutter-handoff) identifies which surfaces can be integrated now.

Production email, privileged account management, full course authoring, assessment question localization, non-objective grading, review scheduling, and media/payment/AI workflows remain pending. Existing entities for these features are persistence groundwork.

## Files changed at this checkpoint

Paths under `backend/src` are grouped by project:

- `LanguagePlatform.Api`: `Program.cs`, `Endpoints/FiveStageEndpoints.cs`, `Endpoints/StudentLearningEndpoints.cs`.
- `LanguagePlatform.Application`: `CourseContent/FiveStageContracts.cs`, `StudentProgress/StudentLearningContracts.cs`.
- `LanguagePlatform.Domain`: `Catalog/Course.cs`, `CourseContent/Lesson.cs`, `CourseContent/LessonVersion.cs`, `LessonEngine/FiveStageCurriculum.cs`, `LessonEngine/LessonScoringPolicy.cs`.
- `LanguagePlatform.Infrastructure`: `Assessment/ObjectiveAssessmentService.cs`, `Catalog/EfLearningCatalogRepository.cs`, `Catalog/PublishedCatalogQuery.cs`, `Catalog/StudentReleaseOptions.cs`, `CourseContent/CurriculumAuthoringService.cs`, `CourseContent/CurriculumQueries.cs`, `CourseContent/PublishedContentQueries.cs`, `Identity/AccountPreferencesService.cs`, `StudentProgress/StudentLearningService.cs`.
- `LanguagePlatform.Infrastructure/Persistence`: `LanguagePlatformDbContext.cs`, `LessonPublicationStore.cs`, `ProgressStore.cs`, `Configurations/CourseConfiguration.cs`, `Configurations/CourseContent/LessonConfiguration.cs`, `Configurations/CourseContent/LessonVersionConfiguration.cs`, `Migrations/20261106173323_AddFiveStageCurriculum.cs`, `Migrations/20261106173323_AddFiveStageCurriculum.Designer.cs`, `Migrations/LanguagePlatformDbContextModelSnapshot.cs`.

Paths under `backend/tests` are grouped by project:

- `LanguagePlatform.Api.IntegrationTests`: `PostgreSqlCatalogApiTests.cs`, `PostgreSqlPublishedContentTests.cs`, `PostgreSqlStudentLearningTests.cs`, `PostgreSqlTestSchema.cs`.
- `LanguagePlatform.Domain.Tests`: `LessonWorkflowTests.cs`.

Documentation: `backend/PROJECT_STATUS.md`, `docs/api/FIVE_STAGE_LESSON_CONTRACT.md`, `docs/api/FLUTTER_BACKEND_CONTRACT.md`, `docs/database/postgresql.md`.
