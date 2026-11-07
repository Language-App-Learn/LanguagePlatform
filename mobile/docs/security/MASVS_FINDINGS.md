# Mobile security findings register (OWASP MASVS-oriented self-review)

This is an engineering self-review (updated 2026-11-07, V8) against the MASVS control groups. It is **not** a penetration test or certification. Date: 2026-11-07. Severity: H/M/L. Status: FIXED / OPEN / ACCEPTED.

## Fixed in V7

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

## Fixed in V8 (2026-11-07)| ID | Group | Finding | Status | Evidence ||---|---|---|---|---|| S-20 | STORAGE/AUTH | Tokens were memory-only (no restore after restart) | FIXED: Keychain / Android Keystore via flutter_secure_storage; one atomic entry for the token pair; corrupt entry -> signed out; failed write keeps the in-memory session; failed delete still clears memory | platform_secret_store_test, secure_session_test, real-backend restart test || S-30 | STORAGE | iOS Keychain items survive uninstall, so a reinstall could resurrect an old session | FIXED: an install marker in ordinary preferences; no marker -> stored session wiped | platform_secret_store_test || S-31 | AUTH | Replayed / revoked refresh tickets | VERIFIED on the real backend: rotation, replay rejected (401/409), logout revokes access + refresh, forged token cleared | real_backend_journey_test || S-32 | PRIVACY | No account deletion path | FIXED (request): re-authentication with password (+ authenticator code), explicit acknowledgement + final dialog, local session cleared on 202, wording says the operator completes the removal | delete_account_test, real-backend deletion test || S-33 | AUTH | MFA accounts could not sign in | FIXED: optional authenticator code on login | delete_account_test, real teacher login || S-34 | STORAGE | Shared PDFs could linger | FIXED: written only to the app-private cache, purged before each share and at startup | share_pdf_delivery_test || S-35 | CODE | Blocked media links could be offered | FIXED: only server status `available` is shown; HTTPS only; URLs never displayed/logged | media_players_test, remote_phase2_data_test || S-36 | AUTH | Cross-account data | VERIFIED on the real backend: another student gets 404 / nothing for A's progress, reading, attempts and results | real_backend_journey_test, real_backend_ui_test |
## Open

| ID | Sev | Group | Finding | Action |
|---|---|---|---|---|
| S-21 | M | PRIVACY | Privacy policy / terms links still missing (the deletion REQUEST path now exists, see S-32) | owner content |
| S-22 | M | NETWORK | No certificate pinning (not required by MASVS-L1; trade-off with rotation risk) | owner decision, document if accepted |
| S-23 | M | RESILIENCE | No release obfuscation (`--obfuscate --split-debug-info`) in the build recipe, no root/tamper checks | add to release recipe; tamper checks ACCEPTED as out of scope for L1 |
| S-24 | M | PLATFORM | Email-confirmation links are not wired as OS deep links; unverified custom schemes would be unsafe | use verified App Links / Universal Links once the backend defines the link host |
| S-25 | L | CODE | Dependencies not audited by an automated tool in CI | CI template runs `flutter pub outdated` + advisory check; owner to enable |
| S-26 | L | PRIVACY | Microphone/AI flows have no consent screens (flows not built) | design before enabling; permission is requested only on user action |
| S-27 | L | STORAGE | Local demo practice data (SharedPreferences) is not encrypted (non-sensitive by design) | ACCEPTED; excluded from backups |
| S-28 | L | NETWORK | Signed media URLs may expire; expiry behaviour not specified | backend feedback item |
| S-37 | M | PLATFORM | Real audio/video playback and the OS share sheet are not verified on a device; Android manifest after the last plugins not re-inspected | device run + merged-manifest check (needs a Gradle build) || S-38 | L | CODE | pub.dev advisory feed is not exhaustive; no automated dependency audit runs yet | enable the CI template; re-check at each upgrade |

## Checked and clean

No API keys or provider secrets in source (`API_BASE_URL` only, via `--dart-define`); no `badCertificateCallback`; no credentials/tokens in logs (`debugPrint` only prints Flutter framework errors in debug); no tokens in SharedPreferences (tested); microphone/camera/location permissions not declared; no WebView; no custom crypto.
