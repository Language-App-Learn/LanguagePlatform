# Mobile security findings register (OWASP MASVS-oriented self-review)

This is an engineering self-review against the MASVS control groups. It is **not** a penetration test or certification. Date: 2026-11-07. Severity: H/M/L. Status: FIXED / OPEN / ACCEPTED.

## Fixed in this iteration

| ID | Group | Finding | Status | Evidence |
|---|---|---|---|---|
| S-01 | NETWORK | Release manifest had no `INTERNET` (functional, forced debug-style workarounds) | FIXED | merged release manifest |
| S-02 | NETWORK | Redirects could carry `Authorization` to another host | FIXED: redirects are never followed; 3xx = unexpected response | `http_transport_test` |
| S-03 | NETWORK | Plain HTTP possible in release | FIXED: platform default blocks cleartext; cleartext allowed only in the debug build for loopback/emulator hosts; `ApiConfig` rejects http to other hosts | manifest + `network_test` |
| S-04 | NETWORK | Non-idempotent POST could be replayed | FIXED: only GET is retried; attempt starts use a persistent idempotency key | `http_transport_test`, `remote_exercises_test` |
| S-05 | NETWORK | Server wording could reach users | FIXED: only status/kind is mapped; ProblemDetails is diagnostic | `http_transport_test`, `auth_flows_test` |
| S-06 | AUTH | Cached learner data could survive an account change | FIXED: account epoch invalidates all learner providers; pending attempt keys and tokens cleared on sign-in/out/demo/reset | `remote_exercises_test`, `secure_session_test` |
| S-07 | AUTH | Logout could leave the user signed in if the server call failed | FIXED: tokens always cleared locally | `remote_data_test` |
| S-08 | AUTH | Demo mode could coexist with a real session | FIXED: entering demo wipes tokens | `secure_session_test` |
| S-09 | PLATFORM | Unneeded data in OS backups | FIXED: `allowBackup=false`, extraction rules exclude all domains | manifest |
| S-10 | CODE | Media URLs from the server trusted blindly | FIXED: only absolute https URLs without credentials accepted; URLs never shown or logged | `remote_phase2_data_test` |
| S-11 | CODE | A JSON/HTML body could be treated as a PDF | FIXED: MIME check + `%PDF-` magic + size cap | `http_transport_test`, `remote_phase2_data_test` |
| S-12 | CODE | PDF file name could come from the server | FIXED: derived `lesson-<id>.pdf`, `[a-z0-9-]` only | `remote_phase2_data_test` |
| S-13 | AUTH | Weak passwords reached the server before feedback | FIXED: client mirrors the server policy for new passwords | `secure_session_test` |
| S-14 | STORAGE | `reset local data` left the real session | FIXED: tokens cleared with it | code |

## Open

| ID | Sev | Group | Finding | Action |
|---|---|---|---|---|
| S-20 | **H** | STORAGE/AUTH | Tokens are **memory-only** until a secure store is approved: no leak, but no restore after restart | approve `flutter_secure_storage` (see dependency requests) |
| S-21 | M | PRIVACY | No account-deletion path (store requirement); no privacy policy/terms links | backend route + owner content |
| S-22 | M | NETWORK | No certificate pinning (not required by MASVS-L1; trade-off with rotation risk) | owner decision, document if accepted |
| S-23 | M | RESILIENCE | No release obfuscation (`--obfuscate --split-debug-info`) in the build recipe, no root/tamper checks | add to release recipe; tamper checks ACCEPTED as out of scope for L1 |
| S-24 | M | PLATFORM | Email-confirmation links are not wired as OS deep links; unverified custom schemes would be unsafe | use verified App Links / Universal Links once the backend defines the link host |
| S-25 | L | CODE | Dependencies not audited by an automated tool in CI | CI template runs `flutter pub outdated` + advisory check; owner to enable |
| S-26 | L | PRIVACY | Microphone/AI flows have no consent screens (flows not built) | design before enabling; permission is requested only on user action |
| S-27 | L | STORAGE | Local demo practice data (SharedPreferences) is not encrypted (non-sensitive by design) | ACCEPTED; excluded from backups |
| S-28 | L | NETWORK | Signed media URLs may expire; expiry behaviour not specified | backend feedback item |

## Checked and clean

No API keys or provider secrets in source (`API_BASE_URL` only, via `--dart-define`); no `badCertificateCallback`; no credentials/tokens in logs (`debugPrint` only prints Flutter framework errors in debug); no tokens in SharedPreferences (tested); microphone/camera/location permissions not declared; no WebView; no custom crypto.
