# Backend project status

Verified 2026-11-06 on local `Backend-Database`, tracking `origin/Backend-Database` at `a9bb7e349aad02a6338bbf771cbf1f7926c56379`. Flutter was read through the fetched `origin/Flutter` ref at `4981d3eb3f109d98d644010ecc455b30e4a13e2d`. Local setup documents and skills were preserved when switching between branches at the same commit.

## Working backend slices

- Published, directional catalog with locale fallback, slug cursor pagination and details.
- Identity password login, confirmation, opaque bearer rotation and revocation, account reads, preference updates and password reset. A registered delivery adapter is required for registration and email dispatch. No outbound provider is registered.
- Published course outline and lesson stages. Enrollment, explicit lesson start, resume and completion queries. Objective assessment snapshots, server grading and atomic lesson progress updates.
- Authenticated dictionary reads and private favorites. Permission-protected lesson publication writes the publication, audit and outbox together.
- Liveness, PostgreSQL readiness, sanitized ProblemDetails and Development OpenAPI. See the [Flutter contract](../docs/api/FLUTTER_BACKEND_CONTRACT.md) for paths and payloads.

## Verification

Baseline restore/build passed with zero warnings/errors. Baseline tests passed 22 and skipped one PostgreSQL test before configuring the disposable database. The baseline EF model matched the snapshot.

PostgreSQL 18.6 was verified in a temporary loopback cluster, with real migrations in isolated schemas under `language_platform_test`. The five original migrations and two additive migrations (`AddLearningPathPreference`, `AddObjectiveAssessmentAndFavorites`) applied successfully. EF reports no pending model changes. The original 105 table-creation operations are preserved. Delta SQL review showed additive columns, an index, FK and check constraint. No development or production database was changed. The installed system service was stopped and there was no configured development connection. See the [database guide](../docs/database/postgresql.md).

The final PostgreSQL-backed run passed all 32 tests with zero failures/skips: 17 Domain, 1 Application and 14 API/model tests, including 8 real PostgreSQL tests. HTTP tests use real Identity and PostgreSQL for the learner workflow. Account email uses a test delivery adapter. OpenAPI is parsed from the running test host and the tests check public and bearer-protected operation metadata. EF CLI 10.0.9 reported a tooling-version warning against EF runtime 10.0.14.

## Next checkpoint

1. Configure a verified local `language_platform_dev` connection, review the additive SQL, apply the migration chain and seed fixtures explicitly. Run the database-backed tests against a separate loopback PostgreSQL 18 test database.
2. Give Claude the Flutter contract. Start with real catalog and lesson-read repositories. Keep remote auth behind the available test/production email configuration. Do not copy demo identifiers or local completion state into server data.
3. Wire a durable email delivery provider and protected shared Data Protection key storage for deployment. Finish account administration and permission grant lifecycle with a trusted operator workflow. Confirm grading and authoring rules before expanding question types, media and assessment localization.
4. Confirm offline reconciliation and review scheduling authority before implementing review history, due queues, learned status and automatic sync. Document device-local time-zone behavior. Profile the new queries against realistic volume before adding caching or extra indexes.

Production email, privileged account management, full course authoring, assessment question localization, non-objective grading, review scheduling, and media/payment/AI workflows remain pending. Existing entities for these features are persistence groundwork.
