# Backend project status

The 2026-11-07 production-hardening work started on `Backend-Database` at `1c7378c6c2c4aa8ee45bf746eed75e609e3ccdbc`, verified against `origin/Backend-Database`. The mobile contract was checked against the fetched `origin/Flutter` at `d64c2e342320db721384b57f76f8c6be9d68c2b4`.

## Working backend slices

- Published, directional catalog with locale fallback, slug cursor pagination and details.
- Identity login, optional authenticator MFA, opaque bearer rotation and revocation, account reads, preferences and password recovery. A configurable TLS SMTP adapter is available. The audited operator command enrolls MFA and grants or revokes individual permissions. Production privilege policies require an MFA-authenticated session.
- Published course outline and lesson stages. Enrollment, explicit lesson start, resume and completion queries. Objective assessment snapshots, server grading and atomic lesson progress updates.
- Authenticated dictionary reads and private favorites. Permission-protected lesson publication writes the publication, audit and outbox together.
- Liveness, PostgreSQL readiness, sanitized ProblemDetails and Development OpenAPI. See the [Flutter contract](../docs/api/FLUTTER_BACKEND_CONTRACT.md) for paths and payloads.
- Turkish-to-Arabic student release filtering, six CEFR levels with 20 addressable positions each, and permission-protected course and version drafts. Lesson versions enforce five ordered required stages and explicit approved weights totaling 100. An incomplete lesson has a null final score. A graded final result of at least 60 permits the next published slot.
- Five-stage authors can create, review and publish lessons and release a course after publishing A1 slot 1. Publication validates exactly ten reviewed reading questions, speaking prompt and rubric, listening audio, supported question sets, and approved scoring weights. Lesson publication, assessment flags, audit and outbox commit together.
- The learner API grades reading, listening word banks and blanks, writing blanks and word ordering, and Turkish-to-Arabic choice and exact text. Speaking is scored by an authorized evaluator using the lesson rubric. Stage results, retries and overall progress use the same server-side persistence path.
- Teachers can upload a private PDF, review the extracted pages, and approve corrected reading lines. Enrolled students can fetch approved lines and download the unchanged original from the published version. Teacher video and listening audio are authored HTTPS metadata. See the [five-stage contract](../docs/api/FIVE_STAGE_LESSON_CONTRACT.md).
- Production requires a certificate-encrypted persistent key ring, explicit hosts, verified PostgreSQL TLS and HTTPS transport. PDF intake requires malware scanning and uses an isolated parser subprocess. Reading and speaking video metadata uses the production host allowlist. Published lesson versions can be withdrawn with an audit record and outbox event.
- Authenticated students can export their account, preferences, progress and attempts and request deletion with current credentials. A deletion request deactivates the account and invalidates tickets. Physical purge and retention policy remain operational gates.

## Verification

PostgreSQL 18.6 was verified in a temporary loopback cluster with isolated schemas under `language_platform_test`. All nine migrations applied. `20261106213735_AddReviewedLessonPdf` adds four columns, one filtered unique index and one check while preserving earlier tables, rows and indexes. EF reports no pending model changes. Development and production databases were outside this run. See the [database guide](../docs/database/postgresql.md).

Final build completed with zero warnings and errors. The PostgreSQL-backed suite passed 43 tests, with zero failures and zero skips (21 API/model, 1 Application, 21 Domain). It covers real Identity, concurrent refresh, MFA replay and privilege revocation, certificate-encrypted key-ring restart, privacy requests, ClamAV protocol doubles, isolated PDF extraction, media policy and withdrawal. The synthetic learner flow keeps the next lesson locked at 50/100 and unlocks it at 60/100. The Development host exports the [OpenAPI 3.1.1 document](../docs/api/openapi.v1.json). Release publish succeeded and the published binary rejected unsafe key-ring configuration before reaching the database. EF CLI 10.0.9 reports a tooling-version warning against EF runtime 10.0.14.

The PostgreSQL 18 backup rehearsal applied all nine migrations, exported a custom archive and restored it into a second database in the same disposable cluster. Migration count and the Arabic UTF-8 sample matched. Local transitive NuGet audit found zero affected dependencies across seven projects. Gitleaks reported no findings in the backend source tree. The GitHub Actions workflow has not run on a hosted runner.

## Next checkpoint

1. Configure staging SMTP, ClamAV, HTTPS, PostgreSQL TLS and service resource isolation. Verify live delivery and scanning, the operator command, and deployment restart behavior. See the [deployment runbook](../docs/deployment/BACKEND_PRODUCTION.md).
2. Load teacher-provided A1 materials and approved weights, rubric and media. Complete retention, purge and controlled media delivery before public access. See the [security register](../docs/security/PRODUCTION_REGISTER.md).
3. Keep instructor evaluation until automated speech providers, consent, budgets and retention are approved. Integrate the published endpoints in Flutter using the [client handoff](../docs/api/FIVE_STAGE_LESSON_CONTRACT.md#flutter-handoff).

PDF ingestion extracts embedded text. Scans need teacher-entered lines. A production ClamAV daemon and signed media provider have not been verified. Public release remains NO-GO.
