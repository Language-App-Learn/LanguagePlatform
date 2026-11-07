# Backend foundation

LanguagePlatform serves Android and iOS through one ASP.NET Core 10 Minimal API. Flutter has a separate branch and owns presentation, local caches and transport adapters. A future administration frontend can consume protected APIs. The backend retains the Clean Architecture modular monolith and a shared PostgreSQL 18 DbContext. See the [ADRs](../adr) for dependency direction, persistence and versioning decisions.

## Runtime boundaries

- Catalog and published content query EF projections without entity tracking. Catalog preserves the v1 array response with keyset pagination. Lesson outlines and vocabulary pages have stable bounded ordering. Published course and latest lesson version filters are applied at the storage boundary.
- Identity manages password hashes, confirmation and reset tokens, and lockout. ASP.NET Core bearer tokens are opaque. A session row stores a hash of the nonce carried in the protected tickets. Refresh replaces that nonce with an optimistic concurrency check. Access validation verifies the session and Identity security stamp. The API derives student IDs from the validated principal.
- Objective assessments snapshot server-side answer keys, options, passing score and deadline. The public question projection excludes keys. One transaction persists answers, the graded attempt, stage and lesson progress, and the activity event. The assessment threshold and the lesson scoring policy are independent.
- Enrollment and lesson start use PostgreSQL conflict handling for retry safety. Starting a lesson records activity once. Reading published content has no effect on progress. The lesson result derives from server-validated stage history.
- Vocabulary content is shared. Favorites belong to the authenticated user and update without erasing notes. Offline review state and server review reconciliation are separate future work.
- Administration reuses the lesson publication use case and requires `content.publish`. The authorized transaction records publication, audit and outbox. Privilege grant/revocation is an operator concern until the dedicated management surface exists. Update the user security stamp on permission revocation to invalidate previously issued claims.

## Operational boundary

Liveness and database readiness are separate. Development OpenAPI uses actual endpoint metadata, including bearer requirements. ProblemDetails includes a trace identifier. Client errors exclude SQL and infrastructure exception details. Account routes are throttled per IP and Identity also locks out repeated password failures. Host the API behind trusted TLS. Configure forwarded headers for trusted proxies before relying on per-client IP rate limiting in production. Persist and protect the ASP.NET Data Protection key ring across instances.

No email provider is configured. Registration and email dispatch endpoints return 503 without one. Production deployment, offline sync, scheduling, course authoring, non-objective grading and provider workflows need separate implementation. See the [Flutter handoff](../api/FLUTTER_BACKEND_CONTRACT.md) and [project status](../../backend/PROJECT_STATUS.md) for verified behavior.
