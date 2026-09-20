# Rider services: backend integration guide

This change extends the **replacement API**, not the retired backend. The
published source is `docs/design/contracts/target-contract.mjs`; the implemented
OpenAPI is `docs/design/contracts/replacement.openapi.json`. Examples below are
illustrative, not captured staging responses. Money is in **pesewas**: 26400 is
GHS 264. All calendar rules below use **Africa/Accra**.

## Personal membership pauses — approved policy

- Once per **paid billing period** (including an annual period), not per calendar
  month. This is independent of the consented waitlisted route-change pause.
- Schedule 3–14 consecutive **calendar** days. Start and resume must be service
  days of the current commute. Start is at least tomorrow and before current
  coverage ends. Resume is exclusive: September 21–28 pauses seven days and
  service resumes September 28 at 00:00 Ghana time.
- Active paid membership required. Erasure, disputes, account restrictions,
  active waitlist pauses or unresolved commute changes prevent a new pause.
  Resolve a pending route-change request before creating a personal pause.
- Confirmation releases pending/reserved/unseated reservations within the
  window, recorded as `declined`. Settled boardings/no-shows are never rewritten.
  A run already in progress is not silently cancelled by a personal pause.
- No boarding, no-show debit or new reservation inside the pause. The commute
  assignment stays; an individual seat after resuming still needs availability.
- Only the **actual days paused** extend the paid period. Rides, Ride Credit and
  cash do not increase. Renewal remains **manual**; this is not a recurring debit.
- Early resume selects an earlier **future service day**, after the start date.
  This can make the actual break shorter than three days. No backdating or
  extension beyond the original resume date. Cancelled seats are not restored
  automatically: the rider must confirm again.
- Automatic resume never clears a dispute or account restriction. A refund
  reversal or account erasure terminates an unfinished pause without granting
  additional coverage.

### Frontend sequence

Use normal authenticated commuter headers (`Authorization`, `x-trotxi-client`,
`x-trotxi-build`, `x-trotxi-platform`). Mutation endpoints also require a unique
`Idempotency-Key`, reused only for retries of the same action and payload.

1. `POST /v1/me/membership/pause-preview` with:

   ```json
   { "startDate": "2026-09-21", "resumeDate": "2026-09-28" }
   ```

   Returns `{ "data": { "startDate": "…", "resumeDate": "…",
"projectedEndsAt": "…Z", "cancelledReservationIds": ["…"] } }`.
   Preview uses the same database validation as confirmation but keeps no pause,
   reservation cancellation or receipt. It is **not a guarantee** that the later
   confirmation will still be eligible.

2. Show the dates, affected reservations and projected membership end. On
   confirmation send the same dates to `POST /v1/me/membership/pauses`.
   It returns **201** with `id`, dates, `status`, `projectedEndsAt` and
   `extensionApplied` in `data`. Replay also returns 201 with current state.

3. `GET /v1/me/membership/pause` returns the most recent personal pause, or
   `data: null`. Status is `scheduled`, `paused`, `resumed` or `terminated`.
   A historical resumed pause does not imply the current period is ineligible;
   use preview to validate a new request.

4. Early resume: `POST /v1/me/membership/pauses/{id}/resume` with
   `{ "resumeDate": "2026-09-25" }`. Returns **200**. Never resume another
   rider's pause. Retrying a command cannot shorten the pause twice.

During a pause, the existing membership endpoint reports `coverage.paused: true`
and access blocked. The pause resource supplies the finite resume date and
projected end date. Automatic settlement applies the extension exactly once.
Membership reads and booking/checkout boundaries also settle due pauses, so a
late worker does not leave the rider's membership screen stuck indefinitely.
Other read paths do not independently settle time: schedule the worker.

## Purchase price preview

`POST /v1/me/purchase-quotes` accepts `{ "plan": "monthly", "routeId": "…",
"useCredit": true }`. No legs are needed until actual purchase creation.

`data` includes `routeId`, `plan`, `ridesGranted`, `fare`, `price`,
`availableCredit`, `appliedCredit`, `cashDue`, `minimumCashDue`, `quotedAt`,
`renewalMode: "manual"`, `binding: false`. All amounts use
`{ "amountMinor": 26400, "currency": "GHS" }`.

It uses authoritative current pricing and excludes held credit, but creates no
purchase, hold, membership or Paystack checkout. It is a **price preview**, not
an eligibility/seat promise. Actual checkout checks the commute, restrictions
and existing coverage, then freezes prices and reserves credit atomically.
Minimum cash payment remains GHS 1.

## Recurring trip generation

Ops: `POST /v1/ops/maintenance/trip-generation` with `serviceDate`, optional
`routeId` and `limit` (1–100). It accepts today through 31 days ahead and only
creates future scheduled departures eligible for that day and route version.

Stable departure/date/run identity includes cancelled trips. Repeat runs do
not resurrect cancellations or overwrite reschedules. Ambiguous schedule
revisions produce a visible failure rather than an arbitrary run. Generated
trips are **unassigned**: operations must still assign a vehicle and driver.

## Push delivery

`worker push` consumes existing durable reservation prompts and registered
devices. It uses the already-established `FIREBASE_SERVICE_ACCOUNT` configuration
and Google's HTTP v1 API. Missing configuration fails the push worker rather
than pretending to send; it does not prevent unrelated API startup.

- Message content is generic: no passenger name, route, GPS or financial data.
- Data payload: `type: "reservation_prompt"`, `notificationId`, `reservationId`.
- Device ownership, revocation, account status and reservation eligibility are
  checked again before sending. Explicit `UNREGISTERED` revokes the token;
  generic invalid-argument errors do not.
- Five attempts maximum with backoff. Retries retain `notificationId`. The
  mobile app should deduplicate by that ID and fetch current reservation state.
- **At-least-once requests**, not exactly-once delivery. A crash after provider
  acceptance can lead to retry. `accepted` means FCM accepted it, not that a
  device displayed it. Native notification presentation/tap handling remains
  frontend work; this backend does not prove either.

## Ops-only refunds — TEST environment

`POST /v1/ops/purchases/{id}/refunds`:

```json
{
  "amount": { "amountMinor": 26400, "currency": "GHS" },
  "reason": "Rider contacted operations; approved staging test refund"
}
```

Requires an ops session and `Idempotency-Key`. Returns **202**, **not a completed
refund**. A refund is limited to remaining collected cash, never the gross
price before applied credit. Live keys/collections are explicitly refused.
Existing signed Paystack callbacks/reconciliation remain authoritative for
financial effects and membership reversal.

`GET /v1/ops/purchases/{id}/refunds` returns `data.items`. State is `submitting`,
`accepted` or `unknown`, with the reason and provider refund ID where known.
The intent is committed before the one provider POST. A timeout/process crash
is not evidence that Paystack did nothing: **never automatically submit again**.
Inspect Paystack and the existing callback evidence when the outcome is unknown.

Conservative first-version limit: **one initiation per purchase**, even for a
partial refund. Further partial refunds or retrying a failed/uncertain initiation
need an explicit reconciliation/retry design; this API refuses rather than risk
a second provider refund. There is no rider self-service refund policy here.

## Rider history and avatar removal

- `GET /v1/me/ride-entries` and `/v1/me/credit-entries` use the existing paginated
  `{ data: [...], page: { nextCursor } }` shape, newest first. `limit` is 1–200.
  Cursors bind rider, resource and ordering; they are not interchangeable.
  History is read-only and includes only the authenticated rider's entries.
- `DELETE /v1/me/avatar` requires an `Idempotency-Key`, returns **204**, immediately
  clears the profile reference and queues physical R2 deletion using the existing
  erasure worker. Previously signed URLs can remain usable until deletion or
  their existing short expiry. Retrying the old deletion cannot remove a newer
  replacement avatar. No account deletion is required.

## Scheduling and rollout

Migrations **023–025** are forward-only; 001–022 remain unchanged. No staging
database, credentials, provider dashboard or Render schedule is changed by
these source changes. Do not call this rollout complete until scheduling and
device delivery have been verified separately.

Use the existing worker deployment/configuration and operator identity:

| Command                                      | Suggested UTC cadence / order                                                            |
| -------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `node dist/worker.js trip-generation`        | Before ask-dispatch; defaults to tomorrow. Explicit date supports today/future backfill. |
| `node dist/worker.js personal-pause-resumes` | Every five minutes, and before period-close jobs.                                        |
| `node dist/worker.js push`                   | Every minute, after ask-dispatch where practical.                                        |
| `node dist/worker.js emails`                 | Existing outbox/reminder worker; schedule separately if not already running.             |
| `node dist/worker.js erasures`               | Existing erasure schedule also removes deleted/replaced avatars.                         |

Every batch is bounded. Rerun/drain batches when backlog exceeds its limit and
alert on failures. This does **not** authorize purchasing cron services. No new
secret variable is needed for these features: push uses the existing Firebase
service account; refunds reuse the existing Paystack TEST key.
