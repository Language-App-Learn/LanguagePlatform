# PostgreSQL 18 development and verification

## Connection targets

Use `language_platform_dev` for development and a separate, disposable `language_platform_test` for tests. The API reads `ConnectionStrings:LanguagePlatform` from configuration (User Secrets in Development or `ConnectionStrings__LanguagePlatform`). The EF design-time factory reads `LANGUAGEPLATFORM_DESIGN_CONNECTION` separately. Configure these outside Git. Avoid printing passwords, connection strings and protected credentials.

Verification used a separate, temporary PostgreSQL 18.6 instance bound to loopback with a generated password. The temporary instance was stopped after verification. The development database was outside the test run.

## Migration review and application

The chain preserves `InitialLearningCatalog`, `AddIdentityAndMediaFoundation`, `AddContentAssessmentAndProgress`, `AddDictionaryReadingAndAI` and `AddBillingNotificationsAndPlatform`. New migrations add:

- `AddLearningPathPreference`: nullable directional path FK, a matching index and EF concurrency mapping to PostgreSQL's existing system `xmin` column.
- `AddObjectiveAssessmentAndFavorites`: nullable attempt deadline and pass threshold snapshots with a check constraint. Existing attempts stay readable to existing stores but lack the snapshot required by the new objective API. Existing saved words are initialized as favorites. The SQL uses a boolean default.
- `AddFiveStageCurriculum`: nullable lesson level and position, with a foreign key, a paired range check and a unique level/position index. Adds course/version curriculum flags and a version weight-approval flag. Existing records default to the legacy policy. The version check requires a threshold of 60 and explicit weight approval when published under the new policy.
- `AddReviewedLessonPdf`: nullable original PDF bytes, extracted page JSON and review time on existing reading materials. Adds a filtered uniqueness index and a 2 MiB check for inline PDFs, plus a lesson version counter used with `xmin` to serialize material edits and review. The migration keeps existing PDF asset references and all prior rows and indexes.

From the repository root, restore/build, then use the following read-only EF checks:

```powershell
dotnet ef migrations has-pending-model-changes --no-build --project backend/src/LanguagePlatform.Infrastructure --startup-project backend/src/LanguagePlatform.Api
dotnet ef migrations script --idempotent --no-build --project backend/src/LanguagePlatform.Infrastructure --startup-project backend/src/LanguagePlatform.Api
```

Verify the server identity, environment, database name, current migration history and backup before applying any migration. Use `dotnet ef database update --project backend/src/LanguagePlatform.Infrastructure --startup-project backend/src/LanguagePlatform.Api` only with an explicitly configured and verified local development connection. Review the generated SQL and use a reviewed forward fix for production. Rolling back the new schema drops the preference/favorite and policy snapshot fields. Startup migration and seeds require Development and a loopback `language_platform_dev` target. Production changes are deployment operations.

## Seed and tests

`Database__SeedOnStartup=true` adds only structural catalog languages, paths and programs to the migrated local development database. Sequential repeats preserve existing rows. CEFR levels and slot capacity still come from the existing course-authoring flow. Startup creates no educational content. The obsolete `Database__SeedDemoContentOnStartup` and `StudentRelease__IncludeLegacyContent` flags are ignored. Synthetic education fixtures are defined and invoked only by the integration-test project.

### Historical fixture inventory

The former development seeder could leave the following records. These are source-level signatures. Existing development and production databases were outside this audit.

| Records | Evidence to correlate |
| --- | --- |
| Published and draft courses | Exact slugs `dev-fixture-arabic-basics` and `dev-fixture-unpublished`, the historical `[DEV]` titles, Turkish-to-Arabic path and legacy course shape |
| Published lesson tree and assessment | A1 lesson slug `greetings`, marked lesson and quiz titles, the linked question codes `dev-greeting-choice` and `dev-greeting-boolean`, and the inactive `dev-fixture-…@example.test` bank owner |
| Dictionary sense | Arabic entry and Turkish translation matching the former seeder plus the exact `[DEV] A greeting.` definition and its single original translation. Runtime responses hide this unchanged sense. A word with another visible sense remains available. |

An ordinary title, shared Arabic text or a partially matching signature is ambiguous. A course or word may also contain material added by a teacher after the seed ran. Enrollments, answers, grades, saved words and other records linked to a fixture are not evidence that their owners or records are disposable. Confirm provenance and dependencies in an authorized read-only inventory before proposing any removal. Deletion requires separate approval.

Set `LANGUAGEPLATFORM_TEST_CONNECTION` locally for a dedicated PostgreSQL 18 `language_platform_test` on localhost, 127.0.0.1 or ::1. The test runner verifies the connected server version and database name before creating an isolated schema with a random name. It migrates only that schema and drops only the schema it created. It never uses the API development connection. Missing test configuration is reported as a skip.

Tests verify the complete migration history, FK/restrict and check violations, unique email/directional paths, rollback, UTC/UUID/JSONB column types, and stale-row detection with `xmin`. HTTP flows cover published visibility, session rotation, two-user access boundaries, snapshot grading, idempotency and publication audit. No substitute database provider is used.

## Production migration and recovery

1. Verify the host, database, current user, PostgreSQL major version and TLS. Use a dedicated, restricted application role without schema ownership or DDL rights. Use a separately authorized migration role for DDL. Grant the application role access only to the tables and sequences needed for runtime and read access to the migration history.
2. Verify a recent encrypted backup and a restore rehearsal. Agree on retention, recovery time and permitted data loss. Monitor backup freshness, WAL, database size, locks and the largest tables. Restrict backup access to operators.
3. Generate and review the idempotent SQL against the exact migration history. Plan for locks and schedule the authorized change. Run the reviewed SQL with error-stop enabled.
4. Compare migration history, run integrity queries, check readiness and verify sign-in and a representative learner read.
5. If integrity fails, stop writes, preserve evidence and select a reviewed forward fix or restore from the verified backup into a separate target. Confirm recovery and pending privacy requests before redirecting traffic.

For a disposable PostgreSQL 18 rehearsal, generate SQL with `dotnet ef migrations script --idempotent --no-build --project backend/src/LanguagePlatform.Infrastructure --startup-project backend/src/LanguagePlatform.Api --output backend/TestResults/production-review.sql`. Run `backend/tools/Test-PostgreSqlBackup.ps1 -PostgreSqlBin <path> -MigrationSql backend/TestResults/production-review.sql` with PowerShell 7. The script creates its own local cluster and compares restored migration history and a synthetic Arabic UTF-8 sample.
