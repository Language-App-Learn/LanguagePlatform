# Student data inventory

Retention periods require product, operational and applicable Turkish privacy review. This build does not collect student voice.

| Category | Purpose and requirement | Access | Retention and deletion | Processor |
| --- | --- | --- | --- | --- |
| Identity, email and profile | Required for account access and recovery | Owner and authorized operators | Pending retention decision. A deletion request deactivates the account. An operator must approve the eventual purge or anonymization. | App and PostgreSQL, plus configured SMTP relay for email |
| Preferences | Optional personal settings | Owner | Pending retention decision. Included in export and subject to approved deletion. | App and PostgreSQL |
| Enrollment and progress | Required for resume and lesson sequence | Owner and limited operators | Pending retention decision. Included in export and subject to approved deletion. | App and PostgreSQL |
| Attempts and submitted answers | Required for scoring, retries and audit | Owner and minimum authorized evaluator access | Pending retention decision. Export learner submissions and results. Review any holds before purge. | App and PostgreSQL |
| Voice, transcript and AI conversation | Future feature requiring consent | Future owner, authorized evaluator and approved processors | Define bounded capture, retention and deletion before enabling. | No configured processor |
| Activity and access telemetry | Operational support and abuse monitoring | Authorized operators | Pending retention decision. Existing learning activity and download logs are outside the export. | App, PostgreSQL and configured telemetry |

The paged export covers account, preferences, enrollment, progress, attempts and submitted answers. Credentials, answer keys and operator audit records are excluded. `POST /api/v1/me/privacy/deletion-request` requires current credentials and MFA when enabled. It returns 202 after deactivating the account, invalidating tickets and creating an auditable request. Approved purge and request tracking still require an operator workflow.

Backups may retain deleted data until expiry. Approve a backup retention schedule and define how pending deletion requests are reapplied after a restore. Have the controller review notices and applicable obligations before claiming compliance.
