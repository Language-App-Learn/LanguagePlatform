---
name: api-contract-review
description: Review or change LanguagePlatform HTTP routes, DTOs, validation, OpenAPI, access rules, and Flutter-facing compatibility. Use when a request or response contract, authentication behavior, or endpoint changes.
---

# LanguagePlatform API contract review

- Trace the affected Minimal API route group in `backend/src/LanguagePlatform.Api/Endpoints/`, its Application DTO, service, and integration tests. Inspect the actual serialized JSON and OpenAPI metadata where available.
- Compare route version, verb, request binding, validation, nullability, enum strings, array/envelope shape, and status codes with the existing contract. Keep EF entities internal. Preserve compatible `/api/v1` behavior or document an agreed versioning plan for breaking changes.
- Check ProblemDetails responses for stable machine-readable behavior and no exception or secret exposure. Distinguish 401, 403, ownership failures, and invalid input. Check access rules at the server boundary before exposing a new route.
- Use HTTP integration tests for representative success, validation, and authorization paths as applicable. Mark tests that replace the service with a stub. Coordinate contract changes for Flutter consumers without modifying `mobile/`.
