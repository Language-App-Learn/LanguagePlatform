---
name: efcore-migrations
description: Review or change LanguagePlatform EF Core mappings, PostgreSQL constraints, indexes, and migrations. Use when a task changes the model or explicitly requests schema or database verification.
---

# LanguagePlatform EF Core migrations

- Check the affected Domain types, module configurations, DbContext, current migration snapshot and [database guide](../../../docs/database/postgresql.md). The shared context inherits IdentityDbContext. Preserve existing migration history and catalog table locations.
- Verify FK ownership, cardinality, uniqueness, delete behavior, PostgreSQL types, and concurrency where relevant. Match composite indexes to actual query predicates. Check whether existing rows can satisfy any new constraints.
- From the repository root, use the following design-time command pattern after building:
  `dotnet ef migrations has-pending-model-changes --no-build --project backend/src/LanguagePlatform.Infrastructure --startup-project backend/src/LanguagePlatform.Api`.
  For an authorized schema change use `migrations add <Name>` with those project arguments and `--output-dir Persistence/Migrations`. Review Up, Down, model snapshot, and generated idempotent SQL before application. Check locks and data-loss risk. Prefer a reviewed forward fix when a rollback would drop data.
- Verify the intended PostgreSQL host and database before any write. For actual integration tests use the dedicated test database and `LANGUAGEPLATFORM_TEST_CONNECTION`. The CLI factory currently uses `LANGUAGEPLATFORM_DESIGN_CONNECTION`; API User Secrets alone do not configure it. Follow database safety rules in AGENTS.md.
