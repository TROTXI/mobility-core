# Stage 3 implementation checkpoint

Stage 2 is approved and merged as PR #294, merge `1a46ad0`. The source/lockfile
baseline remains pinned to `43cdae0`; it is not advanced to the merge commit.
Stage 3 is **in progress**, not complete and not ready for a staging cutover.

## First review slice: transport storage

Integration branch: `codex/backend-replacement`, initially at the stage-2 merge.
First implementation branch: `codex/stage-3-transport-foundation`.
The integration branch is not connected to the staging deployment. Its PRs
receive CI without merging an incomplete replacement onto deploying `main`.
The security workflow's `main`-only PR filter is removed too: integration PRs
must run CodeQL, secret scanning and dependency audit, not only ordinary CI.

Read [the replacement package](../../services/api-next/README.md), then its
[new migration](../../services/api-next/migrations/001_transport_foundation.sql),
[installer](../../services/api-next/src/db/migrate.ts) and
[real Postgres tests](../../services/api-next/tests/transport.pg.test.ts).

Review follow-up adds [migration 002](../../services/api-next/migrations/002_departure_identity.sql)
without changing the reviewed bytes/checksum of `001`. A populated experimental
schedule/trip database is refused without mutation; no identity backfill is guessed.

| Requirement               | Evidence in this slice                                                                                       | Not yet claimed                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| Clean migration baseline  | Hash inventory, two serialized installers, repeat no-op, drift refusal, rollback, old-model refusal          | Rehearsed staging reset/cutover                                      |
| Unique driver linkage     | Direct duplicate-link rejection, null provisioning allowed                                                   | Sign-in, PIN, session or erasure replacement                         |
| VER-01 immutable versions | Complete geometry/stops, zero-based occurrence identities, overlap rejection, editing/publication contention | Publish/reassignment API and its actor/consent workflow              |
| VER-01 ownership/history  | Composite stop/geometry/schedule/trip FKs, archival restrictions, actual attribution negative control        | Full commute/reservation ownership graph                             |
| VER-02 direction          | Reschedule a return trip across noon; direction and explicit window unchanged                                | Commute leg pairing or replacement ETA learning                      |
| TRP-01 coherent states    | Direct SQL rejects illegal transitions, missing/rewritten timestamps and terminal rewrites                   | Preserved driver-service behavior, authorization or HTTP idempotency |
| Narrow runtime role       | No owner membership, DDL, DELETE, TRUNCATE, history UPDATE or migration access                               | Final deployment credential provisioning                             |

The expected proof remains unchanged: each replaced domain gets preservation
scenarios plus storage/target-only checks. This first storage slice does not
claim a two-database payment comparison or mark any of the 50 non-payment
scenario groups fully ported merely because a related CHECK constraint passes.

## Contract correction found during implementation

The approved model requires an explicit service window independent of direction
and clock time. `Schedule` and `ScheduleInput` omitted it. Both now require
`serviceWindow: morning | evening`, with a Zod/OpenAPI regression test. The
generated spec changes with its source; no deployed endpoint/client is changed.
This is fulfilling VER-02, not introducing a new departure inference or product.

## Approved departure identity follow-up

`service_departures` is stable within a directional pattern; schedule revisions
carry their own pattern version, clock time and operating dates. Composite FKs
prevent a schedule from pairing a departure with another pattern's revision,
and prevent a trip from borrowing a different departure's schedule.

The persisted natural key is `(departure_id, service_date, run_number)`. All
statuses, including cancelled, occupy it; launch enforces `run_number = 1`.
`service_date` is a stored business attribute and immutable, **not** a date
derived from `scheduled_at`. A 23:30 service delayed to next-day 00:15 keeps its
identity. A different business date requires an explicit replacement workflow,
not PATCH. `scheduled_at` still drives operational timing and pattern-version
eligibility; no existing history/eligibility guard is weakened.

Direct Postgres checks now cover duplicate insertion, actual concurrent
generation, same-day reschedule, midnight delay, cancellation, and publication
of a second pattern version followed by an attempted duplicate on the same
business date. The latter uses eligible timestamps in **both** revisions and
requires the named identity unique constraint to reject it. Schedule weekday
checks use the business date, not the delayed timestamp's calendar day.

The target `ScheduleInput` requires an explicit `departure` choice (`new` or
`existing` with its ID). Schedule reads include `departureId`. Trip creation
requires `serviceDate`, accepts only run 1, and derives the departure from its
schedule; trip reads expose the identity. `TripEdit` still accepts only
`scheduledAt`. Generated OpenAPI and contract checks change together; there are
no additional endpoints or deployed client changes. The future command layer
must create a new departure plus schedule atomically and reuse the existing
identity when revising that departure. These storage tests do not claim that
the command handlers or trip generator have been implemented.

## Schedule-repointing review clarification

Departure review follow-up: `guard_trip_identity()` is not the only UPDATE
guard. `protect_trip` also invokes `guard_trip()` from `001`, rejecting any
schedule or pattern-version change with `explicit_reassignment_required`.
DEP-09 attempts to repoint a Monday trip within the **same departure and pattern
version** at Tuesday-only, not-yet-effective, ended and compatible schedule
revisions. Every attempt must raise that exact error and leave the full trip row
unchanged. No behavioral fix or new cancel-and-replace product rule is needed.
The eventual attributable reassignment command is still **stage 3** work and
must revalidate the stored business date against the selected revision and
handle reservation consequences; stage 4 is consumer integration.

Documentation-only migration `003` names ISO weekdays (Monday 1, Sunday 7) in
the database catalog and records the two-guard interaction. DEP-10 tests both
the comment and Sunday acceptance/Monday rejection for a Sunday-only schedule.
Reviewed migrations `001` and `002` remain unchanged.

## Second review slice: transactional transport commands

PR #295 merged into the non-deploying integration branch at `48cdfeb`.
Branch `codex/stage-3-transport-commands` builds on that merge, not deploying main.

Migration `004` adds transport command receipts and schedule events, with actor
ownership on command/event references. Eleven reviewed operations have handlers
through an injectable HTTP factory: schedule create/list, trip create/ops list,
driver list/start/complete/arrival, and booking-coordinated ops assignment,
reschedule/cancel. There is no listener, deployment, real auth implementation or
default permissive booking coordinator. Unwired booking edits return 503.

New tests cover actual HTTP plus a restricted Postgres login: state + event +
receipt atomicity, exact retry replay, changed-payload conflicts, fresh-key
duplicate transitions, stale If-Match/correction handling, real connection
contention, audit-write rollback, driver/session isolation, caller-bound cursors,
ISO dates, current-role checks and build-floor admission. Test session/booking
adapters are explicitly labelled; no reservation or identity scenario group is
claimed complete because these test ports pass. The existing 29 storage tests
remain, plus 16 command tests and six pure/preflight checks.

Contract corrections fulfill the stage-2 list-first requirement: driver trip
rows expose an opaque `editToken`, equal to the returned ETag, and ops uses an
`OpsTrip` response with schedule/driver/vehicle IDs. Driver output excludes those
ops references. The runtime schemas are generated from the authoritative design,
not hand-maintained copies; CI regenerates and diffs them. No new/deferred
operation is added. These remain prelaunch contracts, not a deployed API change.

Seven-day command replay expiry is enforced on access; physical receipt cleanup
is still required before deployment. There is no financial/secret-bearing replay
claim. State/command tests are not a baseline/candidate comparison: the immutable
payment harness and the remaining full transport preservation observers still
must run before stage exit.

## Remaining slices / stage exit

Continue with catalog/publication commands, real identity/booking adapters and
baseline/candidate transport observers,
then the membership/accounting candidate and cross-domain commute/boarding.
Payments may proceed independently once shared identities are fixed, but its
16 preserved scenarios and four recovery cases still must pass unchanged except
for explicitly approved representation/fixture substitutions. GPS provenance,
retention and learning, auth/privacy, all cutover endpoint handlers and their
authorization/replay rules remain stage-3 work.

Stage 4 is consumer integration; stages 5–6 are rehearsal and explicitly approved
cutover. No staging DB was inspected, modified or declared empty by this local
work. The zero-real-user/non-disposable-data tripwire still must be rechecked at
stage exit and before any reset; this review does not authorize a reset.
