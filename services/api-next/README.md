# Replacement backend — stage 3, transport storage foundation

Not deployed. This package has **no HTTP server or production entry point** yet.
The running API, its 45 migrations, apps, jobs and staging database are unchanged.
Review into `codex/backend-replacement`, not `main`. Do not point existing API
binaries at this schema or point this installer at the existing staging database.

## Implemented here

- A new migration chain starting at `001_transport_foundation.sql`, content-hash
  history, installer serialization, transactional DDL and refusal of an existing
  old/unknown application database. No reset/down migration or `.env` loading.
- Identity anchors (`users`, `drivers`), vehicles, physical stops and corridors.
  Driver linkage is unique when present; provisioning can leave it null.
- Explicit directional patterns and immutable published stop occurrences. A
  physical stop can appear more than once in a loop; ordinals start at zero.
- Geometry revisions with version-owned, complete, ordered stop distances.
  Published geometry/distances cannot be edited in place. A geometry update is a
  new revision, not mutation of the old polyline.
- Immutable service schedule revisions carrying an **explicit service window**.
  Neither direction nor service window is inferred from a rescheduled departure.
- Stable `service_departures` identities shared across schedule/pattern revisions,
  with composite ownership constraints. A trip is unique by
  `(departure_id, service_date, run_number)`, including cancelled trips. Launch
  permits only run 1. Rescheduling cannot free an identity for a generator retry.
- `service_date` is a stored, immutable business attribute, not the calendar date
  of `scheduled_at`. A 23:30 service delayed to next-day 00:15 retains its date.
  `scheduled_at` remains operational and must fit the selected pattern version;
  this does not authorize a delay across an ineligible version boundary.
- Trips tied to an exact schedule/version and a matching progress occurrence.
  Coherent transition timestamps and no rewriting operated-trip assignments.
- Restrictive relationships and no trip deletion, plus append-only event storage.
  A separate runtime role has no application DDL, deletion, truncation or migration access.

These are **14 application tables**, primarily transport and identity references,
not 14 payment tables. The migration-history table is separate. No membership,
purchase or ledger tables are introduced in this slice.

`002_departure_identity.sql` is append-only; reviewed migration `001` is unchanged.
It supports a fresh database or an empty transport installation of `001`. It
refuses existing experimental schedules/trips rather than guessing which
revisions represent the same departure or discarding fixtures. A populated
experimental database requires an explicit mapping/migration decision outside
this installer; no staging reset or automatic backfill is included.

Documentation-only `003_schedule_conventions.sql` leaves `001` and `002`
unchanged. Schedule weekdays are ISO: **1 = Monday through 7 = Sunday**, not
JavaScript's Sunday-zero convention, and use the stored business service date.
Direct `schedule_id` changes already fail in `001`'s `guard_trip()` with
`explicit_reassignment_required`, including a revision of the same departure
and pattern version. Both trip triggers apply; the INSERT-only eligibility
branch in `guard_trip_identity()` is not a bypass. The later reassignment command
must revalidate date/weekday eligibility and reservation consequences before
any deliberate relaxation. This does not impose a new cancel-and-replace policy
for same-identity revision changes.

The target contract requires schedule creation to explicitly choose a **new**
departure or an **existing** `departureId`. Creating a new identity and its first
schedule must be atomic in the later command layer. A new revision of an existing
departure reuses that ID; a genuinely additional departure gets a new one.
Trip creation supplies `scheduleId`, business `serviceDate`, `scheduledAt`, and
optional `runNumber` (default/only value 1); the command derives `departureId`
from the schedule. Trip reads expose all three identity fields. Reschedule PATCH
accepts only `scheduledAt`, never those fields. No new endpoint is introduced.

## Run locally

Use Node 24 and the repository's pinned pnpm. The tests create uniquely named
databases on an **explicitly disposable loopback PostGIS 16 instance** and drop
only the databases/roles they created. No shared-database truncation or fixtures.

```sh
pnpm --filter @trotxi/api-next run typecheck
pnpm --filter @trotxi/api-next test
HARNESS_ADMIN_DATABASE_URL=postgres://harness:harness-local-only@127.0.0.1:5432/postgres \
HARNESS_ALLOW_CREATE_DATABASES=1 \
pnpm --filter @trotxi/api-next run test:postgres
```

The URL is an example; supply the actual disposable instance's port/credentials.
Missing or non-local DB configuration fails; these tests do not silently skip.
After an abnormal process kill, remove the specifically labelled test container
to clean up leftover synthetic databases, not an arbitrary shared server.

For a separately provisioned, empty replacement DB, the installer is:

```sh
REPLACEMENT_DATABASE_URL=... REPLACEMENT_RUNTIME_ROLE=trotxi_runtime_api \
pnpm --filter @trotxi/api-next run migrate
```

Provision the owner/migration login and a distinct runtime role out of band. The
installer never creates credentials and deliberately ignores `DATABASE_URL`.
It refuses elevated/inherited runtime roles or existing delete/truncate rights.
Run the grants again after new migrations; this first slice deliberately has no
blanket default privileges that silently grant access to future sensitive tables.

## Evidence and limits

The Postgres job runs **29 tests**: migration repeat/drift/rollback/contention,
identity uniqueness, publication integrity, ownership, history retention,
direction, timestamps, runtime permissions and a persisted attribution negative
control, duplicate departure generation under actual contention, midnight delays,
cancellation, cross-revision identity and schedule/departure ownership. Additional
checks cover direct repointing to incompatible and compatible revisions, plus
the catalog weekday convention and Sunday/Monday behavior. Tests run
against the entire migration chain, not a reduced fixture schema (except the
explicit `001` upgrade-refusal test, which verifies failure without mutation).
Three pure/preflight tests run in the workspace job. Source and migration hashes,
verified blocking PIDs, cleanup targets and JUnit results are retained as CI
artifacts. A revision label alone is not represented as a byte-level source pin;
the metadata records actual source hashes and checks they stay unchanged in-run.

The race tests prove distinct PostgreSQL connections are blocked before allowing
them to proceed. The negative control drops exactly one FK in its own disposable
database and writes a real cross-version progress link. Detection must be an
assertion at `trip.currentStopVersion`, with the actual wrong/right version IDs;
a SQL/import/connection error does not count.

This is category B/C **storage-integrity evidence**, not a claim that transport
has already replaced the old service or that payment comparison mode has passed.
The stage-2 baseline and its expectations remain unchanged.

## Still required within stage 3

1. Transactional transport commands, current-user authorization, operation replay,
   If-Match, atomic event creation, projections and `/v1` route registration.
   Direct SQL fixtures here are not an API or authorization implementation.
2. Attributable future-version reassignment coordinated with commute assignments
   and reservations. Until that command exists, version changes on an existing
   trip fail closed; do not disable the guard to publish over affected trips.
3. Full transport preservation scenarios against the pinned baseline and the
   candidate, plus candidate-source pinning. State/timestamp SQL checks are not
   substituted for driver-service/auth tests or HTTP replay coverage.
4. Membership, purchases, attempts, periods, typed accounting, payment candidate
   adapter and all preserved PAY/REC scenarios; approved target-only ownership
   rules and the PAY-08 fixture substitution.
5. Commute/boarding, identity/erasure, GPS ingestion/projection/retention/learning,
   remaining cutover operations and full cross-domain tests.

No allocation, charging, ETA algorithm, raw-GPS retention job, auth endpoint,
consumer upgrade or staging cutover is delivered by this foundation.
