---
name: backend-architecture
description: Review or design LanguagePlatform backend module ownership, dependency direction, and transaction boundaries. Use for cross-module features, new persistence ports, or structural refactors.
---

# LanguagePlatform backend architecture

- Start with the affected module and the relevant decision in [docs/adr](../../../docs/adr). Map current project references and the request path before introducing a new dependency.
- Keep Domain framework-free. Application owns use cases and needed ports. Infrastructure owns EF Core, Identity persistence, and provider adapters. API composes dependencies and maps HTTP contracts. Keep the existing four projects and modular monolith unless the task explicitly calls for a structural change.
- Put behavior with its owning module and call a defined use case for cross-module writes. Prefer focused ports at actual boundaries. Keep the shared DbContext where atomic writes require it. For state plus outbox, commit both together and defer provider calls until after commit. Define concurrency and idempotency around retried writes.
- Describe the smallest justified change, affected modules, verification boundary, and which pieces are wired at runtime versus persistence only. Record durable architectural decisions in an ADR when they change.
