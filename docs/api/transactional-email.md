# Transactional email — Resend

Implementation branch: `codex/backend-notifications`. This does not enable a
scheduler or change database credentials. No historical email is backfilled.

## Configuration

The existing staging service uses `RESEND_API_KEY`, a sending-only key scoped to
the verified `notifications.trotxi.com` domain. Sender is
`Trotxi <hello@notifications.trotxi.com>`. Staging subjects start with
`[STAGING TEST]`. No extra encryption secret is required: outbox encryption
derives a purpose-specific key from existing device key material.

If the key is absent, email hooks are not installed and the email worker fails
explicitly. Adding it does not send past receipts. Rotating root encryption
material without draining the queue makes pending ciphertext unreadable.

## Events

| Event                             | Behaviour                                                                                                                                                                                |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Subscription fulfilment           | Queue once in the same transaction as rides/coverage. Shows cash, applied Ride Credit, rides and coverage end. States renewal is manual.                                                 |
| Coverage ending within three days | Worker queues once per period/end date. Rechecks pause, dispute and effective end before sending; obsolete reminders are cancelled.                                                      |
| Account deletion requested        | Cancel other pending mail. Capture an encrypted, bounded acknowledgement before email is scrubbed. Acknowledges disabled access and pending external cleanup, **not** completed erasure. |

Invalid/missing addresses are not guessed. Provider confirmation is not an
application-delivery confirmation. Refund updates will be connected with the
refund-initiation slice; there is no refund email claim in this slice.

## Reliable processing and privacy

`node dist/worker.js emails` uses the existing configured maintenance operator.
It prepares reminders and processes up to 100 queue rows per invocation. Schedule
it only once scheduling is approved; without a scheduler, queued mail waits.

- Claim/first-attempt time commits before sending. Concurrent workers skip held
  claims; expired one-minute leases recover after a crash.
- Stable Resend idempotency key and identical encrypted message snapshot on
  retry. Network timeout, 429 and server failure retry with bounded backoff.
- Resend deduplicates for 24 hours; automatic retries stop at 23 hours. An
  ambiguous old send becomes `unknown`, not a new send with a fresh key.
- `accepted` means Resend accepted the request, **not inbox delivery**. Delivery,
  bounce and complaint webhooks are not yet implemented. Do not label accepted
  as delivered in monitoring or UI.
- Terminal outcomes erase recipient/content ciphertext immediately. Pending
  content expires after seven days and is cleared by the worker. The dedupe
  identity/status remains so a replay cannot recreate the email.
- Account erasure scrubs normal pending email through a database trigger, even
  if the service no longer has an email key. The acknowledgement is an explicit
  limited exception with the same bounded retention.
- Worker holds the user's lock during the bounded provider request. An already
  in-flight send can finish before erasure commits; no normal mail starts after
  erasure commits. External requests cannot be recalled.
- Logs contain counts/status, never addresses, message content, keys or raw
  provider error bodies. Failed/retried/unknown batches exit non-zero.

Check queue health with aggregated counts, not by dumping ciphertext or user
records. Alert on old pending mail, failed/unknown outcomes, and missed runs.
Operational scheduling and alert destinations remain deployment work.

## Verification

`tests/email.test.ts` tests the Resend request, sanitized failures and worker
contract. `tests/email.pg.test.ts` uses the full migration chain and runtime role
for transaction rollback, replay, concurrent delivery, ambiguous retries,
expiry, erasure and stale reminders. Both are wired into normal test scripts and
the Postgres suite is explicitly included in CI.

Local verification for this change: all 11 email Postgres cases, three email
unit cases and the assembly email case passed; type checking and 25 contract
checks passed. The full backend run recorded 353 passes and one overview-suite
teardown failure (a database connection was terminated after its assertions).
All five overview cases passed on an isolated rerun; this is not claimed as a
clean full-suite run. A single labelled staging message was sent through the
real Resend adapter, and the recipient confirmed receipt. The temporary
environment export used for that test was removed afterwards.

Provider references: [send API](https://resend.com/docs/api-reference/emails/send-email),
[24-hour idempotency](https://resend.com/docs/dashboard/emails/idempotency-keys).
