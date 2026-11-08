# Production security register

Scope is the ASP.NET Core API, PostgreSQL, authoring and mobile contracts. The review uses OWASP ASVS authentication, access control, validation, file handling and secure configuration criteria. [OWASP ASVS](https://asvs.owasp.org/)

| ID | Finding | Evidence | Severity | Fix | Verification | Status |
| --- | --- | --- | --- | --- | --- | --- |
| AUTH-01 | Email provider was absent and a delivery exception could produce different HTTP responses for known accounts. | Identity send paths. | High | TLS SMTP, bounded queue and generic response on delivery failure. | HTTP failure, unknown address and resend. | PASS for API, BLOCKED for live relay |
| AUTH-02 | Production could use ephemeral or unencrypted Data Protection defaults. | API startup defaults. | High | Persistent certificate-encrypted ring and rotation support. | Cross-host HTTP regression and unsafe Production startup rejection. | PASS locally |
| AUTH-03 | Privilege lifecycle depended on manual claims. | Existing Identity policies. | High | OS-only audited CLI, mandatory production MFA, live claim check and security stamp invalidation. | PostgreSQL MFA and revocation HTTP tests. | PASS for service, NOT VERIFIED on production host |
| DEP-01 | SMTP dependency introduced affected PKCS versions. | Restore audit identified two advisories. | High | Pin PKCS 10.0.14. | Restore and transitive audit. | PASS |
| DB-01 | Production could fall back to development database configuration. | Prior connection fallback. | High | Dedicated target, VerifyFull TLS, explicit hosts and schema-aware readiness. | Local PG18 tests and configuration checks. | NOT VERIFIED on production target |
| PUB-01 | No withdrawal workflow. | Existing publication model. | High | Permissioned withdrawal with audit and outbox. | HTTP withdrawal, retry and hidden lesson. | PASS |
| PDF-01 | Uploads lacked antivirus controls. | Prior validation checked size, signature and parser only. | High | Local ClamAV adapter and production fail-closed behavior. | HTTP scanner failure and rejection use a test adapter. | BLOCKED for live scanner |
| PDF-02 | Complex PDFs could exhaust the API process. | Previous extraction ran inside the API. | High | Isolated production parser process with a deadline, bounded output and scrubbed environment. | Worker regression and malformed PDF handling. | BLOCKED for production OS limits and sandbox verification |
| MEDIA-01 | Speaking video was rejected and any HTTPS host was accepted. | Prior stage settings. | Medium | Speaking/reading video and exact approved hosts at authoring, publish and read. | HTTP speaking metadata and internal IP rejection. | PASS for policy, BLOCKED for signed playback |
| PRIV-01 | No self-service privacy endpoints. | Prior routes. | High | Owned paged export and reauthenticated deletion request with deactivation. | HTTP export and session invalidation. | BLOCKED for approved purge and complete export |
| OPS-01 | No backend CI or production rehearsal evidence. | No workflow on base commit. | High | Backup rehearsal script and pinned CI. | See project status. | NOT VERIFIED on hosted runner or production |
| AI-01 | Automated speech services are unavailable. | Provider ports and instructor score workflow. | High for automated speaking | Instructor mode remains. | Instructor workflow and exact 60/100 exercised with synthetic material. | BLOCKED for automated speaking |

Dependency references: [CVE-2026-70162](https://github.com/advisories/GHSA-2fmv-rv2c-59x7), [CVE-2026-84008](https://github.com/advisories/GHSA-846f-f764-76mx).

## Release checklist

| Gate | State |
| --- | --- |
| Five-stage learning, authorization and 60/100 with synthetic fixtures | PASS |
| Build, real PostgreSQL, migrations and generated API contracts | PASS locally. See [verification results](../../backend/PROJECT_STATUS.md). |
| SMTP end-to-end and production credentials | BLOCKED |
| Live ClamAV, isolated parser and approved authoring intake | BLOCKED |
| Real teacher A1 content, approved weights, rubric and media | BLOCKED |
| Retention policy, purge and privacy operational review | BLOCKED |
| Signed media delivery and production AI provider acceptance | BLOCKED |
| Hosted CI and deployment target rehearsal | NOT VERIFIED |

**Public release decision: NO-GO.** Close the blocked operational gates and run the real pilot with teacher materials before public access.

Existing original PDFs stay in PostgreSQL. If importing an existing database for a pilot, inventory and rescan previously uploaded documents before exposing them. Older rows lack scan provenance.
