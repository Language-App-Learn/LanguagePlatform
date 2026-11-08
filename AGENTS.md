# LanguagePlatform

- Backend is ASP.NET Core 10, C#, EF Core 10 and PostgreSQL 18. Start with [backend/PROJECT_STATUS.md](backend/PROJECT_STATUS.md) for current evidence and the next task.
- `backend/src/` contains Domain (business rules), Application (use cases and contracts), Infrastructure (persistence and providers), and API (HTTP and composition). Use the existing modular monolith and module ownership. See [ADRs](docs/adr) for design decisions.
- `backend/tests/` holds xUnit and API/PostgreSQL integration tests. Prefer relevant tests first. Use the full solution for shared changes and state exactly which tests ran. Keep nullable types and warnings-as-errors.
- Use targeted `rg` searches and inspect the current diff before reading adjacent files. Load the matching repo skill only when needed. Limit command output to actionable results. Update PROJECT_STATUS when verified milestones or blockers change.
- Preserve existing migrations. Check the target host/database and review SQL before applying changes. Use dedicated local dev/test databases with secrets outside Git. Never run production or destructive database operations without explicit authorization.
- `mobile/` is the Android/iOS Flutter app maintained separately by Claude Code. Keep backend work out of that directory and document client contract changes.
- Check the current branch and worktree before editing. Always send authorized backend pushes to `origin/Backend-Database`. Preserve existing changes and confirm branch changes with the user. Do not commit, merge or push without authorization. No direct writes to main or Develop.
