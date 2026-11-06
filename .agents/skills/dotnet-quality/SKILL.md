---
name: dotnet-quality
description: Review or verify LanguagePlatform C# changes, DI lifetimes, asynchronous behavior, security-sensitive code, performance, and targeted regression tests. Use for .NET build or test failures and backend code review.
---

# LanguagePlatform .NET quality

- Locate the changed project and its matching tests with `rg`. Use `backend/PROJECT_STATUS.md` for the latest verification baseline.
- Preserve nullable annotations and warnings-as-errors in `backend/Directory.Build.props`. Propagate cancellation from endpoints to EF Core. Check for sync-over-async, accidental per-row queries, and scoped DbContext captured by a singleton. Keep credentials and persistence exceptions out of client responses and logs.
- From the repository root, use `dotnet build backend/LanguagePlatform.slnx --no-restore -m:1` after a successful restore. For narrow changes, use `dotnet test <test-project> --no-restore -m:1 --filter 'FullyQualifiedName~<class>'`. For cross-layer changes, restore and test `backend/LanguagePlatform.slnx` with `-m:1`. Omit `--no-restore` when dependencies have not been restored.
- Test the changed behavior at the smallest meaningful boundary. For a database-free run, exclude `PostgreSqlPersistenceTests` explicitly and report the exclusion. Report pass, fail, skip, and environment blockers separately. A Windows testhost timeout warrants checking the runner permissions before changing code.
