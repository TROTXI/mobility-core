# Replacement backend — stage 3

Not deployed. The package now has a real entry point (`src/server.ts`) and a real
maintenance worker (`src/worker.ts`), but no environment runs them: the blueprint
entries in `render.yaml` are prepared and commented out, and no schedule is
enabled. The running API, its 45 migrations, apps, jobs and staging database are
unchanged. Review into `codex/backend-replacement`, not `main`. Do not point
existing API binaries at this schema or point this installer at the existing
staging database.

Current implementation: **001–018**, **119 operations** in the executable
contract, which is the full reviewed cutover surface. The thirteen deferred
operations remain deferred and are not implemented. Route groups still require
their configured dependencies, and the deployable composition supplies all of
them: it refuses to start rather than serving a reviewed operation without the
capability behind it. See [the current checkpoint](../../docs/design/stage-3-progress.md)
for evidence and remaining work. Historical counts and slice descriptions below
record earlier checkpoints; they are not current totals.
This does not enable checkout, workers or provider traffic on staging.

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
  A separate runtime role has no application DDL, truncation or migration access.
  014 permits DELETE only on the two guarded raw-trace tables for retention.

The initial transport/auth/driver slices comprised **24 application tables**.
010 added three fleet-operation sources, 011 ten financial sources and 012 eight
payment-recovery sources. The migration-history table is separate.

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
schedule is atomic in this command layer. A new revision of an existing
departure reuses that ID; a genuinely additional departure gets a new one.
Trip creation supplies `scheduleId`, business `serviceDate`, `scheduledAt`, and
optional `runNumber` (default/only value 1); the command derives `departureId`
from the schedule. Trip reads expose all three identity fields. Reschedule PATCH
accepts only `scheduledAt`, never those fields. No new endpoint is introduced.

## Command and HTTP slice

The original transport/catalog command layer implemented 29 cutover operations;
later auth/driver/fleet/payment groups bring the executable subset to 54. The source is still
`docs/design/contracts/target-contract.mjs`; `build-transport-contract.mjs` emits
the runtime subset, and CI regenerates/diffs both artifacts. No deferred detail
GET is quietly implemented. New contract refinements are `DriverTrip.editToken`
(copy directly into If-Match) and an `OpsTrip` shape containing schedule/driver/
vehicle references that driver responses do not expose.

- Ops: create/list schedules; create/list trips; assignment, reschedule, cancel.
- Driver: list own trips; start, complete, report/correct an occurrence arrival.
- Catalog: 12 ops and six public operations described below. Deferred detail
  GETs are still absent; mutations return their result and lists supply edit tokens.
- Application creation **refuses an absent or non-callable transactional
  reservation coordinator**, before building the HTTP app. There is no bypass
  option. Tests supply explicit failing or transaction-marker adapters, **not a
  real reservation adapter**. The independently testable service still fails
  closed on omission; a wired adapter can also reject work without any commit.
- Token verification and current-session validation are required injected ports.
  No unsigned user-ID/role header fallback exists. Tests use opaque verified test
  credentials and a test-session table; this is authorization evidence, **not**
  production authentication, refresh, PIN or session revocation delivery.
- Current user/driver/session checks precede completed replay; caller/operation/
  target-scoped advisory locks serialize retries across processes. The input hash
  uses normalized JSON. State, audit event and response receipt commit together.
  A failed transaction leaves no occupied retry key. A replay's old If-Match is
  allowed only after authorization and matching input; new stale edits get 412.
- Receipt replay expires after seven days and expired keys return 409, never
  re-execute. Restricted physical cleanup/tombstone maintenance is **not yet
  implemented**; logical expiry is not a claim of seven-day physical deletion.
  No secret-bearing credential, boarding-code or payment response uses this store.
- Trip edits cannot change business identity or bypass the existing revision
  reassignment guard. Start/complete duplicates are harmless without a second
  state change; backward arrival needs explicit correction and a current token.
- Cursor pagination scopes in SQL before LIMIT, binds caller/filters/order and
  preserves PostgreSQL microseconds. Driver rows carry the exact edit token;
  collection-level ETags are not used as row edit tokens.
- Explicit build floors reject missing/wrong metadata and unsupported clients
  before mutation. Metadata does not grant authority. The official Fastify
  rate-limit plugin applies a bounded process-local IP budget **before token
  verification**, alongside the verified-user budget before database work.
  Forwarded headers are not trusted; deployment must configure its known proxy
  boundary and distributed admission. Database pools must set a connection timeout.

Migration `004` adds completed receipts, their actor-linked event references and
schedule creation events. Earlier migration bytes remain unchanged. Audit/receipt
history is append-only and the runtime login lacks UPDATE on these tables as
well as DDL/DELETE/TRUNCATE rights. Only fixed operation/column choices are used
in dynamic SQL, and request values are parameterized.

Review migration `005` requires `trip_events.command_id` on every non-owner
insert. Its invoker-rights trigger checks actual table ownership, not a role-name
prefix. Only the table owner retains the fixture/history exception; the runtime
cannot assume that role or disable the trigger. Non-null references still obey
the deferred receipt/actor FK for all writers, including the owner. Migrations
`001` through `004` remain byte-identical.

**Audit boundary decision:** this guard enforces receipt-backed event inserts,
not an event for every direct SQL trip mutation. Command-layer state/event/receipt
atomicity remains service-enforced and rollback-tested. No per-trip cross-table
constraint trigger is added here. Before introducing another runtime trip writer,
review which mutations require audit and how an event is matched to that exact
mutation; merely finding an old event for a trip would not prove it was audited.

## Route setup and publication

The executable setup flow is create route → create physical stops → create
outbound/return pattern → create draft version with configured geometry → publish
→ create service schedule → create trip. CAT-01 exercises it through HTTP without
inserting any transport/catalog fixtures. CAT tests still use explicitly labelled
identity fixtures. The authentication slice separately exercises real signed-token/
session integration; trip booking coordination still requires its real adapter.

| Boundary             | Implemented operations                                                                                              |
| -------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Ops routes and stops | List, create, PATCH editable fields (including the reviewed `archived` flag); no DELETE                             |
| Ops patterns         | List and create; route and direction cannot be changed                                                              |
| Ops versions         | Create draft, list, read a nested version, publish                                                                  |
| Public catalog       | List/read current routes, read current patterns, read published/retired versions and geometry, list route schedules |

`PatternVersionInput.geometry` supplies **configured road geometry**, not a path
guessed from straight lines between stops. It contains `points` (2–10,000 lat/lon
points) and `stopDistancesMeters` (one finite, nondecreasing distance for each
input occurrence, inside the line's geodesic length plus the existing 1 m tolerance).
The distance array uses request order because occurrence UUIDs do not exist yet.
Creation is one transaction for the version, 2–500 occurrences, draft geometry,
distances, audit event and receipt. This does not prove that a configured line
follows real roads or that manually supplied distance/location pairs are accurate;
ops reviews that configuration. GPS learning and traversal-aware projection remain
separate work. Only this bounded input gets a 1 MiB body limit; other operations
keep the existing 64 KiB limit.

Drafts are complete review candidates, not editable published definitions. To
correct one, create another draft through the existing endpoint; no unreviewed
draft PATCH or geometry-upload endpoint is added. Physical-stop edits never
rewrite occurrence snapshots. An unavailable physical stop prevents a new draft
or publication, without rewriting existing published history.

Publication locks the pattern and at most the target/latest published version,
then the route and referenced stops. It publishes geometry/distances and version
together, closing an overlapping previous interval atomically. Publication must
follow existing effective starts; it cannot rewrite later scheduled publications.
The deferred trip guard refuses any closure that would orphan a non-cancelled
trip (`409 reassignment_required`). No trip is implicitly moved or cancelled.
Archiving a corridor similarly refuses while it has scheduled/active trips.
Future commute/reservation writes must join this coordination boundary before
those domains are enabled; this is not evidence of membership-aware archival.

`Route`, `Stop` and `PatternVersion` expose `editToken`. Copy it to `If-Match`,
never construct it from a collection ETag. Missing/foreign nested resources are
404 before 428/412. Publication replay scopes include **both** pattern and version
IDs. Audit rows link receipts/actors with a deferred FK; a publication audit also
records the previous effective interval. `006_catalog_commands.sql` leaves
`001`–`005` unchanged; the runtime login cannot update catalog history.

Public reads expose no drafts, archived corridors, users, drivers, trip positions
or audit data. Current route/pattern discovery uses effective intervals at database
transaction time (not simply `state='published'`, since a future retirement can
still be today's version). Explicit published/retired version links remain readable
on unarchived corridors, including future published versions needed by schedules.
Public route schedules exclude ended schedules/versions. Each composed read uses
one database snapshot, with bounded cursor pagination and no shared caching.
Build/platform metadata is required even without authentication; the app factory
now requires explicit commuter floors alongside driver and ops floors. Public
reads are IP-limited and never use an unverified identity header as authority.

## Authentication port

Eight more reviewed operations bring the composed factory to **37 operations**:
`POST /v1/auth/{google,apple,driver,refresh,logout}`, `GET /v1/me`,
`GET /v1/me/sessions`, and `DELETE /v1/me/sessions/{id}`. The transport-only
factory remains independently testable with explicit identity adapters; the
composed factory cannot substitute header claims for signature/session checks.

Read [the auth port decisions and evidence](../../docs/design/stage-3-auth-port.md).
Migration `007` adds provider identities, stable device sessions, hash-only
refresh generations, existing-format driver credentials and fixed-204 revocation
receipts. `001`–`006` are unchanged. Provider/PIN primitives are ported from the
existing implementation, not invented replacement authentication rules.

## Driver credential port

Seven additional reviewed operations bring the composed factory to **44**:
driver list/create/edit, credential issue/reset/status actions and self PIN
change. Read [the driver port decisions and evidence](../../docs/design/stage-3-driver-port.md).
Migration 008 leaves 001–007 unchanged. Credential issue provisions the principal
atomically; reset/suspension/PIN change revoke sessions transactionally. A separate
32-byte credential replay key is now required at composition. No driver screen
or staging change is included, and no booking coordinator is faked for deployment.

## Deployable assembly

`src/server.ts` reads and validates the environment, composes the whole backend
and only then opens a listener. `src/runtime/config.ts` is the single list of
what a deployment must supply; every name is `REPLACEMENT_*` so a service sharing
an account with the deployed API cannot inherit its database, signing key or
provider credentials. A missing variable is refused **by name** before anything
is built, and the eight key purposes must all be different keys.

Nothing degrades. There is no in-memory object store, no recording push sender,
no permissive session callback and no adapter parameter a caller could pass a
test double through: `composeBackend` takes configuration and nothing else. The
adapters are the real ones — Google and Apple ID-token verification, Apple's
token and revocation endpoints, Paystack initialize/verify/webhook evidence, and
Cloudflare R2 for avatars, signed locally with SigV4 so URL signing never makes a
network call while a lock is held.

Startup additionally asks the database to prove the connection is the narrow
runtime role: it refuses to serve if that connection can create objects in the
`app` schema or update append-only history. Pointing the service at the migration
owner is a configuration mistake that would otherwise work perfectly and be
quietly unauditable.

`/healthz` answers for the process; `/readyz` reads a row and reports 503 when it
cannot. `SIGTERM`/`SIGINT` close the server and the pool once, with a bounded
deadline; an uncaught exception or unhandled rejection exits non-zero rather than
continuing to serve money and audit writes in a state we cannot vouch for.

### Maintenance worker

`node dist/worker.js <job> [travel-date] [outbound|return]` runs exactly one job
and exits non-zero if it was refused, because a scheduler that reports success
for a sweep that failed is how retention quietly stops happening.

| Job                    | What it does                                          |
| ---------------------- | ----------------------------------------------------- |
| `gps-retention`        | Deletes raw traces past the retention window          |
| `route-learning`       | Learns corridor shape and segment speeds from the day |
| `payments`             | Webhook inbox, provider reconciliation, period close  |
| `ask-dispatch`         | Asks riders about a service day                       |
| `reservation-defaults` | Resolves the still-pending at the cutoff              |
| `no-shows`             | Debits confirmed seats nobody took                    |
| `erasures`             | Retries erasure's external half                       |
| `driver-secrets`       | Physically clears expired credential ciphertext       |

The first six go through the application's own routes, so they get the same
schema validation, authorization, receipts and idempotency as an operator
pressing the same button. The contract admits a `worker` client on exactly those
maintenance operations and the app now accepts it there and nowhere else. The
worker is not exempt from authorization: it opens a real session for a named
operations account, every receipt names that user, and the session is revoked
when the run ends whether or not the run succeeded.

The last two have no reviewed HTTP operation and are called directly, which is
why they live in the worker. `driver-secrets` is the physical half of credential
expiry: logical expiry already refuses replay, but the recoverable ciphertext
stays on disk until this runs. `erasures` is the external half of account
closure — withdrawing the Apple grant and removing the stored avatar object.
Neither reports success it did not achieve: an unreachable store leaves the task
outstanding with its failure recorded, and the next sweep tries again.

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

The Postgres job runs **97 tests**: 29 storage, 20 transport command, 15 catalog,
17 auth and 16 driver HTTP/transaction tests, none skipped. Catalog tests cover full HTTP setup, visibility,
snapshot preservation, publication rollback, three observed database races,
parent/child replay scope, revocation, row edit tokens, microsecond pagination,
runtime audit privileges and a 6,000-point geometry above the default body limit.
Review regressions cover receiptless runtime rejection, owner-only fixtures,
deferred receipt existence/actor validation and all four conditional mutations'
404-before-428/412 behavior (including foreign driver trips).
UUID spelling is normalized before scope/hash/comparison; a regression test
reproduces the uppercase-occurrence rejection before the fix, then proves replay
across uppercase/lowercase path and body IDs after it.
The storage checks cover migration repeat/drift/rollback/contention,
identity uniqueness, publication integrity, ownership, history retention,
direction, timestamps, runtime permissions and a persisted attribution negative
control, duplicate departure generation under actual contention, midnight delays,
cancellation, cross-revision identity and schedule/departure ownership. Additional
checks cover direct repointing to incompatible and compatible revisions, plus
the catalog weekday convention and Sunday/Monday behavior. Tests run
against the entire migration chain, not a reduced fixture schema (except the
explicit `001` upgrade-refusal test, which verifies failure without mutation).
Fifteen pure/preflight tests run in the workspace job, including startup refusal
with a missing/malformed coordinator before any DB connection and a pre-auth limit
test that asserts the rejected request never reaches verification and cannot
bypass the limit with a forged forwarded address. Source and migration hashes,
verified blocking PIDs, cleanup targets and JUnit results are retained as CI
artifacts. A revision label alone is not represented as a byte-level source pin;
the metadata records actual source hashes and checks they stay unchanged in-run.

The race tests prove distinct PostgreSQL connections are blocked before allowing
them to proceed. The negative control drops exactly one FK in its own disposable
database and writes a real cross-version progress link. Detection must be an
assertion at `trip.currentStopVersion`, with the actual wrong/right version IDs;
a SQL/import/connection error does not count.

This is category B/C **storage and command evidence**, not a claim that transport
has already replaced the old service or that payment comparison mode has passed.
The stage-2 baseline and its expectations remain unchanged.

## Still required within stage 3

1. The full preservation harness against the pinned baseline and this candidate:
   PAY-01 to PAY-16 and the mapped non-payment scenario groups, with documented
   substitutions, negative controls and demonstrated contention.
2. Distributed admission. The per-user budget here is process-local, and a
   deployment behind more than one instance needs a shared one; forwarded
   headers are still not trusted and the proxy boundary is still a deployment
   decision.
3. Physical receipt expiry for the command stores other than driver credentials.
   Logical expiry already refuses replay; deletion of the expired rows is not
   claimed.
4. Apple provisioning. The Services ID, team id and `.p8` do not exist yet, and
   the service refuses to start without them, which is one reason the blueprint
   entries stay commented out.

### On future-version reassignment

The version guard on an existing trip still fails closed: `guard_trip()` refuses
a direct schedule or pattern-version change with `explicit_reassignment_required`,
and publication refuses a closure that would orphan a non-cancelled trip with
`409 reassignment_required`. That is unchanged, and the guard must not be
disabled to publish over affected runs.

What has changed is that ops now has an attributable way through it. The
reservation coordinator is composed in the deployable backend, so cancelling or
rescheduling an affected run releases or revalidates the funded seats in the same
transaction, and publication then succeeds. `ASM-16` walks that whole path with a
real funded reservation; `ASM-17` is its control, showing the same decision
returning `503 reservation_coordinator_unavailable` when the coordinator is not
composed.

A single-command bulk reassignment is a different thing, and the approved
contract has no operation for it — not even a deferred one. That is a contract
decision to review rather than an endpoint to invent here.

No staging cutover is delivered. The endpoints exist in a service nothing runs,
and no deployed endpoint has been replaced or changed.
