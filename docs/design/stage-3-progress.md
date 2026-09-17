# Stage 3 implementation checkpoint

Stage 2 is approved and merged as PR #294, merge `1a46ad0`. The source/lockfile
baseline remains pinned to `43cdae0`; it is not advanced to the merge commit.

**Stage 3 implementation is complete. Nothing is deployed.** The executable
contract is the full reviewed cutover surface of **119 operations**, the
contiguous schema is **001–018**, and the replacement passes the preservation
harness against the pinned baseline in compare mode.

Read [the stage-3 completion report](stage-3-completion.md) for the operation
and invariant mapping, the preservation result, and the gaps that are flagged
rather than filled. The thirteen deferred operations remain deferred and are
listed separately there.

The sections below are historical slice checkpoints, not current totals. A
generated operation count was never a deployed-service claim, and still is not:
the blueprint entries are commented out, no schedule is enabled, no staging
database has been touched, and the service refuses to start until Apple
provisioning exists. Stage 4 remains client integration.

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
default permissive booking coordinator. Application creation now refuses an
absent or non-callable coordinator; the lower-level service retains its isolated
fail-closed guard. HTTP tests supply explicit failing or marker-writing adapters.

New tests cover actual HTTP plus a restricted Postgres login: state + event +
receipt atomicity, exact retry replay, changed-payload conflicts, fresh-key
duplicate transitions, stale If-Match/correction handling, real connection
contention, audit-write rollback, driver/session isolation, caller-bound cursors,
ISO dates, current-role checks and build-floor admission. Test session/booking
adapters are explicitly labelled; no reservation or identity scenario group is
claimed complete because these test ports pass. The existing 29 storage tests
remain, plus 20 command tests and eight pure/preflight checks. UUID case folding
matches database identity in comparisons and retry scopes; the new case test
was first verified failing at the intended arrival assertion before the fix.
The official Fastify rate limiter enforces a pre-authentication IP limit as well
as the verified-user budget. CI's security gate is retained without suppression.

Review migration `005` requires a receipt for non-owner trip-event inserts,
leaving the existing owner-only fixture/history exception. The invoker-rights
check uses table ownership, not role-name matching. Tests prove runtime rejection,
owner fixture allowance, inability to assume the owner or disable the guard,
and deferred receipt/actor integrity even when the event is inserted first.
Migrations `001`–`004` are unchanged. This does not enforce an audit event on every
direct trip UPDATE; that remains an explicit service boundary to revisit before
another runtime writer is introduced. Missing-trip tests cover all four
conditional mutations and foreign driver access before precondition checks.

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

## Third review slice: route catalog and publication APIs

PR #296 merged into the non-deploying integration branch at `3da8064`. Branch
`codex/stage-3-catalog-publication` builds on it. The HTTP factory now implements
29 cutover operations (the existing 11 plus 12 ops catalog and six public reads).
The full catalog setup, publication, schedule and trip creation path no longer
depends on transport fixtures in its HTTP test. It still depends on test identity
adapters; there is no listener, deployed endpoint or real reservation coordinator.

Two missing contract details surfaced during implementation and are supplied in
the authoritative Zod source plus generated OpenAPI/runtime schemas:

- A draft must supply configured `geometry.points` and `stopDistancesMeters` in
  occurrence order. Otherwise the reviewed complete-geometry publication rule
  cannot be satisfied without manual SQL. Bounds are 10,000 points, 500 stops,
  ordered finite distances within the line length, and a 1 MiB request limit.
  No straight-line route is invented and no new geometry-upload endpoint is added.
- Catalog lists carry per-resource `editToken` values; version reads also carry
  revision and effective dates so ops can review the publication it will affect.

Migration `006` adds receipt-linked catalog events and page indexes, leaving
`001`–`005` unchanged. Publication atomically publishes geometry and version and
closes the previous overlapping interval. It refuses to orphan existing trips;
future-version reassignment remains fail-closed until commute/reservation
coordination is implemented. Corridor archival also refuses open trips. Neither
behavior is a substitute for the later membership-aware coordination rules.

Public catalog reads use one snapshot, omit drafts/archived corridors, choose
the current link by effective interval, retain explicit published-history reads
and enforce client build floors without requiring sign-in. No raw GPS, driver
or private operational records enter these public projections. No deferred
operation is promoted into runtime.

Evidence: **64** full-chain Postgres tests, **8** pure/preflight checks, and **27**
contract/harness checks. CAT-08/09/15 observe blocked distinct PostgreSQL workers
before releasing publication/publication, publication/trip and same-key draft
races. The existing transport and pinned payment expectations are unchanged;
this remains category B/C evidence, not a two-database transport preservation run.

## Remaining slices / stage exit

013's commute/reservation implementation and its explicit delivery/boarding
boundaries are recorded in [stage-3-commute-reservations.md](stage-3-commute-reservations.md).
It supplies real transactional membership coordinators and 16 more reviewed
operations; it does not enable a deployment, notification worker or boarding.

Identity, credentials, financial/recovery foundations, membership coordinators,
GPS and the 015 boarding implementation now exist in the replacement package.
Do not reimplement them from this older checklist. Remaining work is composition,
the pending endpoint groups named above, and baseline/candidate preservation
observers. The 16 payment scenarios and four recovery cases still must pass the
comparison harness with only explicitly approved substitutions. Local domain
tests alone do not satisfy that gate. Worker scheduling and physical cleanup
remain prelaunch obligations; no worker is enabled by these PRs.

Stage 4 is consumer integration; stages 5–6 are rehearsal and explicitly approved
cutover. No staging DB was inspected, modified or declared empty by this local
work. The zero-real-user/non-disposable-data tripwire still must be rechecked at
stage exit and before any reset; this review does not authorize a reset.
