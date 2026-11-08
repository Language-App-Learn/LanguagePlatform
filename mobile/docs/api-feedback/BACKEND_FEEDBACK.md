# Feedback for the backend team

Status after re-reading the newest contracts (`Backend-Database` `dd09853`, including `docs/api/openapi.v1.json`) and after a real end-to-end run of the Flutter client against that backend (local API + disposable PostgreSQL 18; see `docs/testing/E2E_REAL_BACKEND.md`). Nothing was patched from Flutter; the backend branch was only read and built from a temporary export.

## RESOLVED (contract now covers it, or verified end-to-end)

| # | Earlier item | Resolution |
|---|---|---|
| 1 | Account deletion route | `POST /api/v1/me/privacy/deletion-request` `{password, authenticatorCode?}` -> 202. Implemented in the app (confirmation + re-authentication). **Verified:** wrong password refused with no change; correct password -> 202, old access token returns 401, sign-in afterwards fails. The app says "request accepted", never "data erased". `GET /me/privacy/export` also exists (not used by the app yet). |
| 2 | Pending vs unknown speaking result | Documented: `GET /me/assessment-attempts/{id}/result` returns 404 while evaluation is pending. The app treats 404 as pending. (Still shared with "not yours"; acceptable, see U-3.) |
| 3 | Media status / blocked links | Contract: `status` = `available` / `unavailable` / `unconfigured`; "suppress blocked links". Implemented: the app shows media only for `available`. |
| 4 | Idempotent attempt start | **Verified:** same `idempotencyKey` while the attempt is open returns the same attempt id and the same question ids. |
| 5 | Passed lessons list | **Verified:** `lessons/progress?completedOnly=true` contains the lesson only after the server decision `passed=true`. |
| 6 | Stage ordering | **Verified:** starting a later stage's attempt early -> 409; next lesson start before a pass -> 400. |
| 7 | MFA login | `authenticatorCode?` on login: implemented (optional field). **Verified** for teacher accounts. |
| 8 | Media expiry | Contract states there is no signed-media issuer or expiry yet, so the app re-reads metadata on a playback failure. |
| 9 | Rate limiting / email delivery | Contract: account routes are rate limited; email dispatch is asynchronous (202 is generic). Handled (429 -> own message, `Retry-After` honoured when it is delta-seconds). |

## UNRESOLVED

| # | Item | Why it matters / proposal |
|---|---|---|
| U-1 | **Email link format.** Nothing defines what the confirmation / reset emails contain or where they point. | The app handles `/auth/confirm-email?userId=...&code=...` but registers no OS link. Proposal: verified HTTPS App Links / Universal Links on a backend-controlled host with the same query names. |
| U-2 | **Provider status.** No endpoint says whether TTS / transcription / AI evaluation are enabled. | The app shows "AI practice is not available" statically. A small `GET /api/v1/features` would let the UI switch on without a release. |
| U-3 | `404` is used for pending, for "not enrolled" and for "not yours". | A `202` or a `status:"pending"` body for pending evaluation would remove the ambiguity. |
| U-4 | `409` has several causes (locked stage, attempt limit, deadline, conflicting key). | A machine-readable reason would allow precise messages. Today all show "not available right now". |
| U-5 | Registration cannot set `displayName`; no profile update route. | Profile shows the email only. |
| U-6 | Reading fallback key. If `lines` is empty the app shows the stage text for locale `ar`. | Please confirm `ar` is the right key and that other locales are translations, not exercise prompts. |
| U-7 | Objective result `passed` uses a zero threshold. | Correct per the contract; the app therefore never shows a pass/fail verdict for an attempt. An explicit field name would make this unmistakable. |
| U-8 | Idempotent start after the attempt was submitted: what is returned? | The app clears the key on submit; behaviour after submit was not asserted. |
| U-9 | Media host policy for development. | In the E2E run the authored host `media.example.test` was accepted; production requires an approved host. A development allow-list note would help testers. |

## NEWLY DISCOVERED (during the real run)

| # | Observation | Impact |
|---|---|---|
| N-1 | Stage codes in authoring must be lowercase (`reading`, `speaking`, ...); PascalCase returns 400 "unique supported stage codes". | Documentation: the draft table says `kind` but not the casing. |
| N-2 | `operator enroll-authenticator` requires a Base32 key of 32-64 characters (not 16/20). The CLI error is intentionally generic. | Operator runbook should state the length. |
| N-3 | The startup migrate/seed guard accepts only a database literally named `language_platform_dev` on localhost (port is not checked). | Safe by design, but a throwaway cluster must reuse that name; documented in the E2E guide. |
| N-4 | Development API writes ASP.NET data-protection keys to the user profile (`%LOCALAPPDATA%\ASP.NET\DataProtection-Keys`). | Harmless for testing; mention in the dev guide. |
| N-5 | A hand-built PDF with a malformed xref is rejected with a clear 400; a minimal valid PDF without text is accepted and lines can be entered manually. | Works as documented. |
| N-6 | Account creation in Development returns 503 unless an `IAccountEmailDelivery` is registered. | Testers need a mail sink (the E2E guide uses an out-of-tree `HostingStartup`). |

## Test data still needed from the backend team

Teacher-provided real A1 materials (approved weights, rubric, an HTTPS media host that is actually reachable) so audio/video **playback** can be verified end-to-end; the synthetic run only proves metadata, link hiding and the failure path.
