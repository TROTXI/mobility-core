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
- Trips tied to an exact schedule/version and a matching progress occurrence.
  Coherent transition timestamps and no rewriting operated-trip assignments.
- Restrictive relationships and no trip deletion, plus append-only event storage.
  A separate runtime role has no application DDL, deletion, truncation or migration access.

These are **13 application tables**, primarily transport and identity references,
not 13 payment tables. The migration-history table is separate. No membership,
purchase or ledger tables are introduced in this slice.

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

The Postgres job runs **18 tests**: migration repeat/drift/rollback/contention,
identity uniqueness, publication integrity, ownership, history retention,
direction, timestamps, runtime permissions and a persisted attribution negative
control. Tests run against the entire new migration, not a reduced fixture schema.
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
