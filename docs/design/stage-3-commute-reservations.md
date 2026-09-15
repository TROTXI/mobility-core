# Stage 3 — migration 013: commute and funded reservations

Integration target: `codex/backend-replacement`. This is not a deployment or a
cutover of `services/api`. Migrations 001–012 are unchanged; 014 remains Claude's
GPS allocation and 015 remains boarding/settlement.

## Implemented boundary

Sixteen reviewed operations join the executable contract (64 → 80): membership,
rider requests/withdrawal/list, ops request queue/decision/events, commute slot
creation/list/retirement, reservation decisions/list, account restriction
creation/release, ask dispatch and reservation defaults. Deferred history/detail
operations remain deferred.

`OpsCommuteRequest`, `CommuteSlot` and `Restriction` expose `editToken`: their
mutations need a resource If-Match, not a collection ETag. No new operation was
invented to retrieve that token. Paused coverage exposes no renewal deadline;
pause and dispute/account restrictions remain independent access blocks.

## Model and transaction rules

- Immutable paired selections hold explicit outbound/return schedules and stop
  **occurrences**. An assignment records either its purchase or approved request.
  Composite foreign keys bind reservation rider, period, assignment, selection,
  trip revision and both occurrences. Loop stops are not identified by position.
- One open request per rider. Approval holds an exact paired transfer quota; it
  does not change the assignment. Apply is explicit, cannot precede the approved
  date, and starts the new assignment on the actual application day. It does not
  backdate over operated service or mutate a purchase's frozen terms.
- Unknown/different fare refuses application with `fare_review_required`. The
  pricing lookup is an explicit transaction-local dependency, not a guessed
  default. No proration policy is invented.
- Pause requires waitlisting, recorded rider consent and usable coverage. Current
  unsettled service blocks pause/apply. Future reservations are cancelled without
  writing ride credits. Resume extends only the effective period deadline by
  elapsed pause time; independent disputes/restrictions still block resumption.
- Rider locking is shared with checkout/refund/close. Seat acquisition takes the
  period before trip lock, then updates the reservation. Trip commands already
  own the trip lock: their coordinator never acquires a rider/period lock in the
  reverse order. A removed/undersized vehicle cannot strand committed seats;
  rescheduling cannot move a funded departure outside paid coverage.
- Funded, unsettled service and active pauses block close. Period termination
  cleans pending requests, live quota claims, pauses and future reservations in
  the same transaction. Historical applied requests cannot release a slot that
  has since been reused. Erasure additionally clears request/decision notes and
  hides the rider from ops queues; financial history is not deleted.
  Automatic invalidations record a bounded system cause; they do not invent a
  rider or ops actor for a decision that person never made.
- Receipt and event commit with the domain mutation. Authorization/ownership
  precede replay. Receipts persist resource identity, digest and actor, **not**
  notes or stale response snapshots. Replays return the current representation
  of the same resource; they never repeat the side effect. Explicit expiry is
  seven days. This differs from transport's historical snapshot replay and is
  intentional for erasable rider notes and evolving access state.
  First execution and replay share the same response builder: creates return
  201 on both paths and expose the current ETag wherever the resource has an
  edit token, including after a later resource edit. No response snapshot or
  additional migration is needed to preserve that HTTP contract.
- Command authorization is unconditional and precedes target-rider lookup;
  it does not depend on the supplied UUID or whether a target row exists.
  A non-admin receives the same refusal for existing, missing and
  non-rider targets. Rider commands retain the exclusive own-user lock before
  session authorization to preserve the financial/auth lock order.
- Lists implement the declared request-status, slot-route and reservation-date
  filters. Cursors bind their normalized values (UUID case is immaterial).
  Reservation dates use inclusive Africa/Accra calendar days, require both
  endpoints, allow at most 31 days and default to today plus the prior six days.
  Unknown statuses and invalid ranges/route IDs fail with 400. Lists honor the
  contract's 200-row maximum rather than imposing a hidden 100-row limit.
  Commute event history declares pagination only: its parent request-status
  filter is not inherited, and supplying it returns 400. Contract generation
  and COM-22 both pin this distinction.
- Bounded dispatch rechecks current eligibility under the rider lock and writes
  one durable prompt intent per reservation. Defaults preserve explicit answers,
  allocate only available seats/rides, and mark overflow `unseated`, never
  chargeable. Maintenance reports bounded failures; concurrent repeats converge
  on the same rider/day/direction intent.

## Composition and remaining boundaries

Use **the same** `MembershipService` for:

1. `FinancialFoundation.assertCheckoutAllowed`, `assertPeriodCanClose`, and
   `materializeAssignment`;
2. `PaymentRecovery.reversePeriod`;
3. `TransportService.coordinateReservations`;
4. `createTransportApp({ membership: service, ... })`.

All callbacks use the caller's transaction client. No provider request, nested
commit, or separately committed reservation update is allowed inside them.

The service is not production-ready composition on its own:

- 015 supplies boarding proof issuance, boarding/no-show/return settlement and
  manifests. Confirmed reservations honestly return `pass: null` until that
  integration; this slice does not mint placeholder QR codes.
- `reservation_prompts` proves durable **intent**, not notification delivery. A
  notification delivery worker still needs composition and must recheck current
  eligibility before sending. No cron/worker has been enabled here.
- Route pricing must supply the transaction-local fare lookup before commute
  application is usable. Missing lookup fails closed.
- The full baseline/candidate payment harness comparison is still outstanding;
  these cross-domain tests are not labelled as completion of all PAY scenarios.

The 012→013 upgrade derives initial assignments from already fulfilled frozen
purchase legs under table locks. It does not infer a commute from mutable routes
or delete existing fixtures. New fulfilments materialize the same shape in the
payment transaction.

## Verification

`tests/membership.pg.test.ts` runs through `test:postgres` and explicitly in the
Financial foundation CI job; missing database configuration is a hard failure.
Tests use fresh PostGIS databases, real narrow runtime roles and observed
Postgres lock waiters for the last-slot and last-seat races. They cover HTTP
response serialization/edit tokens, authorization before replay, cursor scoping,
exact pause arithmetic, immutable purchase terms, event-write rollback, upgrade,
erasure, bounds/defaulting, and Paystack signed test-event refund coordination.
No test credentials are real Paystack account keys or contact live Paystack.

Review regressions COM-18–21 cover declared filters and normalized cursor
binding, paired/inclusive/default date windows, restriction existence hiding
including revoked sessions, and all three create operations' replay status and
current ETag. All four fail at the intended assertion against the original
implementation. Independently removing only filter binding also makes both
pagination regressions fail with 200 rather than the required 400.
