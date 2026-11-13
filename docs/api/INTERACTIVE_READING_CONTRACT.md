# Interactive Arabic reading

Teacher PDFs use the existing upload, review and publication flow. The extraction is visible to the PDF owner. Only the lines submitted in the review are published. The backend preserves the exact approved text and orders lines by PDF page, then by their position on that page. The teacher is responsible for vocalization and correctness.

| Method | Path | Behavior |
| --- | --- | --- |
| GET | `/api/v1/admin/five-stage/versions/{versionId}/reading-pdf` | The PDF owner with `content.edit` gets the draft revision, extracted pages and reviewed `lines`, each with `id`, `page`, `order`, `text` and `hasReferenceAudio`. |
| PUT | `/api/v1/admin/five-stage/versions/{versionId}/reading-pdf/review` | Approves the teacher-supplied lines and returns the same extended draft metadata. |
| PUT | `/api/v1/admin/five-stage/versions/{versionId}/reading-pdf/lines/{lineId}/reference-audio?expectedVersion={revision}` | The PDF owner with `content.edit` uploads or replaces an optional WAV on an approved line while the version is still a draft. Returns a new revision for the next edit. |

Student routes below start with `/api/v1/me/courses/{courseId}/lessons/{lessonId}/reading-progress`. They use the same bearer authentication, enrollment, released version and stage access as the existing PDF routes.

| Method | Suffix | Behavior |
| --- | --- | --- |
| GET | empty | Returns `versionId`, `totalLines`, `currentLineId`, `completed`, `automaticProgressionEnabled` and ordered `availableLines` through the first unfinished line. Each line also carries `hasReferenceAudio` and `approved`. |
| GET | `/lines/{lineId}/reference-audio` | Streams the teacher WAV for the current or a previous approved line. Replay is allowed. Access requires the bearer token and uses `private, no-store`. |
| POST | `/lines/{lineId}/evaluations` | Submits a WAV for the current line after the student has started the lesson. Send `Idempotency-Key` as a nonempty UUID. |
| GET | `/evaluations/{evaluationId}` | Returns an evaluation for the authenticated student and the current published version. |

Uploads use a raw `audio/wav` body, 16 kHz mono signed 16-bit PCM, 0.25 to 20 seconds, at most 640,044 bytes. Write a 44-byte RIFF header with only the PCM `fmt ` and `data` chunks. No multipart body or third-party upload is needed. A malformed WAV returns 400, excessive size returns 413, and an unsupported media type returns 415. Concurrent upload saturation returns 429.

An evaluation returns `id`, `lineId`, `status` and nullable `reason`. Reuse the same UUID and identical bytes for a network retry. A pending replay returns 202 with a `Location` to poll. A key reused with different audio or a different line, a concurrent attempt with a new key, and a request to submit a line out of order return 409. An inaccessible lesson or a foreign result returns 404. For a fresh recording, generate a new UUID.

- `APPROVED` advances the server to the next line. Refresh progress after receiving this result. Previous approved lines remain visible and playable.
- `RETRY_REQUIRED` indicates that a confident transcription did not match the full sequence of words. Prompt for a new recording.
- `INCONCLUSIVE` covers silence, insufficient confidence and disabled automatic progression. Keep the current line and do not treat the result as a wrong answer.
- `TECHNICAL_ERROR` covers a failed, unavailable or expired recognition request. Keep the current line and allow retry. A crashed request releases its pending reservation on the next poll or submission after the deadline.

An accessible lesson without reviewed PDF lines returns an empty list, `totalLines: 0`, a null `currentLineId` and `completed: false`. After all lines are approved, the current line is null and `completed` is true. Refresh on resume and use the current server version. Do not send a client-side pass or progress value.

When automatic progression is enabled, the server requires all approved PDF lines before starting or submitting the existing reading quiz. Lessons without PDF lines continue through the existing quiz. The five scored stages still use their approved weights and the 60/100 passing threshold. The original PDF and existing read-only material routes keep their current contracts.

## Privacy and deployment

The backend stores reference audio on the reviewed segment of the immutable published version. Student voice and recognition text are processed in memory. Only the authenticated student ID, line ID, UUID, SHA-256 of the submitted bytes for idempotency, timestamps, outcome and reason are persisted. Treat those records as student data. Successful results are kept with lesson progress. Failed and expired attempts should be purged after a 30-day idempotency window using an approved maintenance policy. The purge is an operational release requirement. The feature includes no automatic deletion against existing databases.

See [private worker setup and benchmark](../../backend/speech/README.md) for worker configuration. Lexical approval checks the normalized sequence of words and does not certify pronunciation, vowels, makhraj or i'rab.
