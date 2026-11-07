# Backend production operations

Deploy the ASP.NET Core API behind an HTTPS reverse proxy, with a dedicated PostgreSQL 18 database, a private key directory, a local ClamAV daemon and an authenticated SMTP relay. Keep deploy, migration and operator credentials outside the repository.

Build with `dotnet publish backend/src/LanguagePlatform.Api -c Release -o backend/TestResults/publish`. Configure the service to run the artifact with `ASPNETCORE_ENVIRONMENT=Production`. Supply these settings through the deployment secret store and service manager.

| Key | Required configuration |
| --- | --- |
| `AllowedHosts` | Exact API DNS names separated by semicolons. |
| `ConnectionStrings__LanguagePlatform` | Dedicated database, restricted application role, `SSL Mode=VerifyFull`, root CA if needed, connection and command timeouts, bounded pool size. |
| `DataProtection__KeyDirectory` | Existing absolute persistent directory, shared by instances of this environment, writable only by the API service identity. |
| `DataProtection__ApplicationName` | Stable name for the environment. Use distinct names and directories in staging and production. |
| `DataProtection__CertificatePath` / `DataProtection__CertificatePassword` | Mounted PKCS#12 file and protected password. The API identity needs read access to the private key. |
| `DataProtection__PreviousCertificatePath` / `DataProtection__PreviousCertificatePassword` | Optional previous certificate during rotation. Keep access to encryption certificates required by unexpired tickets and reset links. |
| `ReverseProxy__KnownProxies__0` | Exact proxy IP as seen by Kestrel. List further trusted IPs with sequential indexes. Bind the API privately and have the proxy replace inbound forwarded headers. |
| `AccountEmail__Smtp__Enabled` | Enable after verifying the relay and sender. Set `Host`, `Port`, `Security` (`StartTls` or `SslOnConnect`), `Username`, `Password` and `From` under this prefix. |
| `Media__AllowedHosts__0` | Exact controlled HTTPS playback host. Verify ownership, redirects, exposure and privacy with that provider. |
| `PdfScanning__Enabled` / `PdfScanning__Port` | Enable `clamd` on IPv4 loopback and use its private port (3310 by default). Maintain current signatures and a stream limit of at least 2 MiB. |

Production startup requires a protected key ring, explicit hosts and a dedicated TLS-verified PostgreSQL target. Forward client IP and HTTPS scheme from the trusted proxy only. The API enables HSTS in Production. Keep clocks synchronized.

The key ring rotates every 90 days. Back up the encrypted ring and its certificates separately from PostgreSQL. Rehearse restoring both before rotating certificates. Verify login and refresh after restarting an instance. The SMTP adapter uses a 100-message in-memory queue and a 15-second relay timeout. A restart or relay failure can lose pending messages. Users can request delivery again after recovery. The API returns generic 202 when a provider is configured and 503 when it is absent.

## Trusted operator

Use the published binary on the trusted host. The CLI verifies `Operator__ExpectedHost`, `Operator__ExpectedDatabase` and the connected database before writing.

1. The teacher creates and verifies a normal account. Use a secure channel to provide a random Base32 TOTP seed to the teacher.
2. Supply the key and current code via `LANGUAGEPLATFORM_OPERATOR_TOTP_KEY` and `LANGUAGEPLATFORM_OPERATOR_TOTP_CODE` in the operator process. Run `dotnet LanguagePlatform.Api.dll operator enroll-authenticator <user-id>` and clear both variables. Keep both values out of shell history and logs.
3. Grant one permission at a time with `dotnet LanguagePlatform.Api.dll operator grant <user-id> content.edit`. Grant publication and evaluation separately. Use `operator revoke <user-id> <permission>` to remove access.
4. Verify that the teacher signs in again with a fresh authenticator code. Enrollment, grant and revocation invalidate existing tickets. Use individually assigned OS operator accounts because the OS identity is recorded in the audit trail.

## Health, logging and change control

- Liveness is `GET /health`. Readiness is `GET /health/ready` and checks connectivity and migration history. Alert on sustained 503, key-ring failures, SMTP failures and unexpected authorization or upload error rates.
- Capture trace IDs and HTTP status in structured logs. Exclude request bodies, auth headers and PDF upload query strings from telemetry. Keep codes, passwords, answers and document bytes out of logs.
- Monitor database and backup storage, WAL, assessment answer tables, PDF latency and process memory. Production parses scanned PDFs in a child process with a scrubbed environment, a 15-second deadline and bounded output. Apply service-manager CPU and memory limits, and restrict filesystem and network access for the deployment identity. Process isolation does not supply an OS sandbox.
- Use the [explicit database procedure](../database/postgresql.md) with an authorized migration identity. Production startup does not apply migrations.
- The [Backend CI workflow](../../.github/workflows/backend-ci.yml) uses an isolated database and no deployment credentials. Once the hosted check has run, require it and review approvals on the backend branch. It exports TRX, NuGet audit results, OpenAPI and review SQL.

References: [ASP.NET Core Data Protection](https://learn.microsoft.com/aspnet/core/security/data-protection/configuration/overview?view=aspnetcore-10.0), [trusted proxy setup](https://learn.microsoft.com/aspnet/core/host-and-deploy/proxy-load-balancer?view=aspnetcore-10.0), [ClamAV protocol](https://docs.clamav.net/manual/Usage/ClamdProtocol.html).
