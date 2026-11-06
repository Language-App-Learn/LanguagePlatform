# PostgreSQL 18 development and verification

## Connection targets

Use `language_platform_dev` for development and a separate, disposable `language_platform_test` for tests. The API reads `ConnectionStrings:LanguagePlatform` from configuration (User Secrets in Development or `ConnectionStrings__LanguagePlatform`). The EF design-time factory reads `LANGUAGEPLATFORM_DESIGN_CONNECTION` separately. Configure these outside Git. Avoid printing passwords, connection strings and protected credentials.

The system PostgreSQL service was stopped during this task and no development credentials were available. The live verification used a separate, temporary PostgreSQL 18.6 instance bound to loopback with a generated password. No changes were applied to `language_platform_dev`. The temporary instance was stopped after verification.

## Migration review and application

The chain preserves `InitialLearningCatalog`, `AddIdentityAndMediaFoundation`, `AddContentAssessmentAndProgress`, `AddDictionaryReadingAndAI` and `AddBillingNotificationsAndPlatform`. New migrations add:

- `AddLearningPathPreference`: nullable directional path FK, a matching index and EF concurrency mapping to PostgreSQL's existing system `xmin` column.
- `AddObjectiveAssessmentAndFavorites`: nullable attempt deadline and pass threshold snapshots with a check constraint. Existing attempts stay readable to existing stores but lack the snapshot required by the new objective API. Existing saved words are initialized as favorites. The SQL uses a boolean default.

From the repository root, restore/build, then use the following read-only EF checks:

```powershell
dotnet ef migrations has-pending-model-changes --no-build --project backend/src/LanguagePlatform.Infrastructure --startup-project backend/src/LanguagePlatform.Api
dotnet ef migrations script --idempotent --no-build --project backend/src/LanguagePlatform.Infrastructure --startup-project backend/src/LanguagePlatform.Api
```

Verify the server identity, environment, database name, current migration history and backup before applying any migration. Use `dotnet ef database update --project backend/src/LanguagePlatform.Infrastructure --startup-project backend/src/LanguagePlatform.Api` only with an explicitly configured and verified local development connection. Review the generated SQL and use a reviewed forward fix for production. Rolling back the new schema drops the preference/favorite and policy snapshot fields. Startup migration and seeds require Development and a loopback `language_platform_dev` target. Production changes are deployment operations.

## Seed and tests

`Database__SeedOnStartup=true` adds catalog languages, paths and programs. `Database__SeedDemoContentOnStartup=true` additionally creates a clearly marked published and draft course, a lesson, an objective assessment and one dictionary entry. The fixture author is inactive and has no password or roles. Run once against a migrated development database and clear the flag afterward. Sequential repeats preserve existing rows. Seed failures surface on startup.

Set `LANGUAGEPLATFORM_TEST_CONNECTION` locally for a dedicated PostgreSQL 18 `language_platform_test` on localhost, 127.0.0.1 or ::1. The test runner verifies the connected server version and database name before creating an isolated schema with a random name. It migrates only that schema and drops only the schema it created. It never uses the API development connection. Missing test configuration is reported as a skip.

Tests verify the complete migration history, FK/restrict and check violations, unique email/directional paths, rollback, UTC/UUID/JSONB column types, and stale-row detection with `xmin`. HTTP flows cover published visibility, session rotation, two-user access boundaries, snapshot grading, idempotency and publication audit. No substitute database provider is used.
