# Stage 1: access, retry and GPS storage decisions

Review proposal, not deployed behavior. Product-approved directions: one clean
replacement, period-scoped historical disputes by default, public route/stops
mapping with restricted live position, explicit removed-stop reassignment and
30-day raw GPS retention from server receipt. Engineering numbers and the
eligibility matrix below are concrete proposals for review, not past approvals.

## Live access matrix

Authorization runs before cache lookup and before returning even a no-fix state.
All decisions use current database facts, not token claims about membership.

| Caller/state                                                 | Public map/catalog                   | Live position for this trip                                                               | Private manifests/commands                                      |
| ------------------------------------------------------------ | ------------------------------------ | ----------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| Signed out                                                   | Published routes/stops/geometry only | 401                                                                                       | 401                                                             |
| Signed in, never subscribed or lapsed                        | Yes                                  | 404 unless an eligible funded reservation below applies                                   | Own account/history only                                        |
| Active unpaused paid coverage, effective commute on corridor | Yes                                  | Yes, for active trips matching the commute leg; booking not required                      | Own reservation/commute commands only                           |
| Paused or dispute-blocked funding period                     | Yes                                  | No on that period; 404                                                                    | Own history, withdraw/decline where allowed; no bypass of block |
| Historical dispute, new unblocked coverage                   | Yes                                  | Yes on the new eligible commute                                                           | Old dispute does not freeze unrelated new value                 |
| Account-wide ops restriction                                 | Yes                                  | No; 404                                                                                   | Own history/support; no restricted service commands             |
| Eligible reserved/boarded rider on active trip               | Yes                                  | Yes if funding was valid for scheduled departure and remains unreversed/unfrozen/unpaused | Own reservation only                                            |
| Driver assigned to this trip                                 | Yes                                  | Yes                                                                                       | Assigned trip manifest/progress/boarding; no other trip         |
| Other driver                                                 | Yes                                  | No; 404                                                                                   | No private trip scope                                           |
| Admin                                                        | Yes                                  | Yes with current admin authority                                                          | Attributable ops actions; no user-role shortcut                 |

An eligible reservation permits a trip crossing a coverage deadline to finish;
the financial close stays blocked by unsettled service. A declined, unseated,
cancelled or unrelated reservation confers no location entitlement. Catalogue
trip summaries do not contain driver identity, riders or raw coordinates.
Inactive trips return `not_started`/`ended` and no position only to a caller
whose trip scope is independently authorized; revocation returns 404, not an
explanatory payload that leaks the trip. Staff raw-history access is not implied
by permission to read the latest position.

## Other authorization boundaries

- `self`: authenticated current, non-erased account; IDs come from the session.
- `rider_own`: commuter role plus user ownership through membership/purchase.
  Owning history is independent of being currently eligible to travel.
- `driver_own`: linked, active driver credential/account and own resource.
- `driver_assigned_or_own`: the above plus current assignment to the addressed
  trip; nested reservation belongs to that trip. Check after path resolution.
- `ops`: current admin role, resource existence, audit actor/reason; customer
  consent remains mandatory for pause. No role flag bypasses transaction rules.
- `ops_or_scoped_worker`: admin or a separate audience-bound worker token whose
  task allowlist matches the exact maintenance endpoint. A worker cannot edit
  roles, prices, holds or memberships. Human-owned credentials are not cron auth.
- `provider_signature`: verify HMAC over raw bytes; persist before success;
  reconcile authoritative provider facts. An event reference alone grants no
  payment state mutation. Unmatched retired fixtures go to quarantine.

Query predicates enforce owner/assignment before pagination. Use separate ops
schemas carrying rider/driver/actor IDs; never serialize those into self-service
responses. Authorization applies again on every cached/idempotent response.
All list filters must use whitelisted fields; opaque cursor binds owner, sort
and normalized filters. Public geometry only contains published route data.

## Command semantics that schema validation cannot prove

| Command                           | Transaction/domain checks                                                                                                                                                         | Result/failure                                                                                  |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Purchase                          | Price server-side; plan monthly/annual; two opposite commute legs on corridor/version; stop order; no unresolved purchase/current paid coverage; reserve available credit exactly | 201 purchase may await provider; 409 conflict; never trust caller amounts                       |
| Reservation confirm               | Owner, effective assignment/schedule, funded period, capacity and unique date/direction                                                                                           | Reservation + short-lived proof; no immediate ride debit                                        |
| Reservation decline               | Own intended date/direction; boarded/no-show terminal rules                                                                                                                       | Must not require positive balance or free capacity                                              |
| Boarding/no-show                  | Assigned driver, intended trip/reservation, valid proof, funded eligibility; one charge identity shared by both attendance outcomes                                               | Exactly one ride charge; late board after no-show changes attendance only                       |
| Commute request/decision          | One open request; reverse/past stops refused; slot lock; equal fare or explicit review; no unsettled old trip; pause consent                                                      | Approval holds slot; apply once updates effective assignment, not original purchase terms       |
| Driver request approval           | Own request and one ops decision                                                                                                                                                  | Does not automatically reassign a driver/vehicle                                                |
| Trip reschedule/assignment/cancel | Expected version; status-dependent operation; release/cancel affected reservations transactionally                                                                                | No arbitrary PATCH status; cannot rewrite operated history                                      |
| Arrival                           | Occurrence belongs to trip version; stale If-Match rejected; explicit correction flag for backward movement                                                                       | Replay returns original applied operation; new correction is auditable                          |
| Version publish                   | At least two ordered occurrences; full valid geometry reference; affected future assignments/trips have explicit reassignment decisions                                           | 409 `reassignment_required`; no implicit stop substitution                                      |
| Account erasure                   | Revoke sessions/devices, scrub identity, remove object, provider revocation retry recorded; retain justified accountable records                                                  | 204 only after required local completion; provider failure recorded for recovery, not forgotten |
| Incident hold                     | Admin reason, incident, trip and bounded receipt interval; lock against concurrent expiry; only available records can be retained                                                 | 409 if already purged; never claim unavailable evidence recovered                               |

Where a PATCH permits all optional fields, empty bodies are rejected with 400.
Calendar dates must be real, paired list ranges ordered and at most 31 days.
Schedule weekdays unique; commute legs exactly one outbound and one return.
Foreign keys/composite constraints enforce owner and version alignment even
when direct SQL bypasses HTTP. Zod does not replace these database checks.

## HTTP retry and compatibility contract

Named OpenAPI operations and schemas are in `contracts/target.openapi.json`.
One supported business API `/v1`; no `/v2` commitment. `/flags`, health, version,
metrics, docs and provider ingress stay unversioned operational boundaries.
The new bootstrap shape is itself a prelaunch replacement, not a compatibility
adapter. Thereafter test older bootstrap parsers on additive changes.

- Idempotency key: 1–128 characters, caller+operation+target scope, normalized
  input hash. Store 7 days for ordinary commands; retain unresolved financial
  operations until resolved and preserve durable business uniqueness afterwards.
  Proposed limits require review. Keys never grant access; mismatched input 409.
- Complete replay is authorized before If-Match evaluation. A fresh stale
  version is 412; missing required If-Match is 428. Create-via-PUT config uses
  `If-Match: "0"` for absence; any existing record then conflicts. Successful
  writes return an ETag from the committed version, not the request's version.
- Secret-bearing responses use encrypted, tightly scoped replay storage with a
  TTL no longer than their validity. QR TTL 60 seconds; boarding code follows
  reservation validity. Expired pass replay is 409 `proof_expired`; request a
  fresh pass with a new key. Credential issue/reset replay at most 5 minutes;
  after expiry return `secret_no_longer_available`, never rotate again by replay.
- Refresh/logout use their credential state machine, not generic HTTP replay
  storage. Preserve rotated-token family revocation; a lost refresh response
  remains a baseline limitation to test explicitly, not silently change here.
  Network/5xx failures and failed retried requests must not clear valid app tokens.
- Erasure replay is narrowly exceptional: after sessions are revoked, the exact
  completed delete key may return 204 only with a still-cryptographically-valid
  original access credential bound to that deletion's session/account tombstone.
  Retain no plaintext token, and grant no other endpoint or refresh permission.
  Invalid/expired credentials still return 401. Stage 2 must test lost-response
  deletion separately from ordinary authenticated response replay.
- Boarding availability: preserve the existing fail-open auxiliary KV/audit
  behavior, but only after durable authorization/charge succeeds. Database loss
  returns 503; offline manifest is read-only reference, not offline authority to
  invent boarding success. No offline settlement protocol is added by this PR.
- QR claims bind issuer, boarding audience, jti, user, reservation, trip,
  funding-period identity, issued-at and 60-second expiry. A pass from another
  reservation/trip or an API access token is rejected before any charge. Issuing
  a new pass does not debit a ride. Short-code checks remain trip-scoped and
  bounded by per-trip/per-driver attempt limits; codes/hashes are never in the
  general manifest. Return the same durable charge result on an authorized
  retry, not a second charge merely because the new proof has a different jti.
- Full driver manifest: one complete revision, maximum 500 rows. Above this
  limit fail explicitly (409 `manifest_too_large`), never silently truncate.
  Proposed cache TTL 15 minutes; no codes, phone or email in manifest. Invalidate
  on logout/assignment change; hide after expiry; signed avatars expire too.
- List defaults: 50/max200; trips ascending scheduledAt+id, most histories
  descending createdAt+id. Configuration collections without createdAt sort by
  stable natural key, documented in OpenAPI. All cursors bind these sort choices.
- Maintenance returns 200 for a bounded completed batch, with failures; cron
  exits nonzero on failures after logging bounded detail. Unwired services return
  503, never a successful zero tally. One malformed period cannot abort others.

Before real-user onboarding, #40 must be implemented and tested in both apps.
Bootstrap minimum builds are per **app and platform**, not one version shared by
rider and driver. `/v1` requests provide client kind/build and mobile platform;
unsupported builds get 426 `client_upgrade_required` before mutation. Missing
metadata gets 400. These untrusted headers cannot grant role/eligibility. Ops and
workers use separately managed compatibility floors; do not apply mobile floors
to them. Cache/offline startup and store availability need app E2E tests. A
force-update screen cannot guarantee installation, and does not justify erasing
data if the zero-real-user cutover precondition has changed.

## GPS write, freshness and sample policy

Engineering defaults proposed for review:

- Assigned active trip only. Each upload requires stable `clientFixId`, capture
  time and coordinates. No commuter location. Duplicate ID with identical
  payload returns original receipt; changed payload returns 409
  `fix_payload_conflict` (target-only improvement over baseline first-write-wins).
- Server receipt is immutable and controls the 30-day expiry. At ingestion,
  captures more than 120 seconds ahead are rejected; smaller positive skew is
  stored as original capture plus `effectiveCapturedAt = receivedAt` and marked
  clock-adjusted. Never use a future time to pin latest or compute freshness.
  Exclude clock-adjusted observations from speed learning until suitable data
  exists; don't pretend the device clock has been corrected.
- Captures before trip start or older than 24 hours are rejected. A collection
  session older than 24 hours from trip start requires ops intervention; it
  cannot create indefinitely retained fixes on a forgotten active trip.
  This bounds retry-after-expiry ambiguity without retaining dedup keys forever.
- Latest projection compares effective capture then receipt then ID atomically
  under the trip lock. Redis writes use the same ordering/CAS and cannot regress
  PostgreSQL. Delayed upload receipt does not make old capture fresh.
- `ageSeconds` uses effective capture, clamped nonnegative. Live <=30 seconds;
  older is stale. At >120 seconds withhold numeric ETAs, expose stale state and
  timestamp; do not silently show a predicted arrival as current. Scheduled and
  ended trips have no live position. These are target defaults, not measured SLOs.
- Learning reads at most five eligible completed runs per explicit direction,
  filtering valid segment observations. Three are required for observed speed.
  Readiness: span of three valid observations plus processing margin <30 days;
  regular intervals I imply 2I+margin<30 days, not a ten-day threshold. Insufficient
  observations use labelled fallback speed. Route-version changes require fresh
  compatible observations. Never extend raw retention because learning failed.

## Storage choice for review: indexed, bounded expiry first

Choose one unpartitioned `trip_positions` table initially, with explicit retention
indexes/maintenance and a **prelaunch load gate**. This is a physical-design
decision, not permission to postpone retention or collect unbounded data.

Required fields: ID, trip/assignment provenance, `client_fix_id NOT NULL`,
capture/effective-capture/receipt timestamps, geography point, optional accuracy,
clock-adjusted flag and canonical payload digest. Indexes:

1. Unique `(trip_id, client_fix_id)` for durable deduplication.
2. `(trip_id, effective_captured_at, received_at, id)` for ordered trace reads.
3. `(received_at, id)` for oldest-first expiry.

No spatial GiST index until a measured spatial query requires one. Latest
position is a separate small projection, not a repeated full-history maximum.
Financial/operated history references trip identities, not raw-fix rows; raw
expiry must not cascade into trip history.

Logical access expires exactly at receipt+30 days. Proposed purge runs every
minute in <=1,000-row transactions with time/lock limits and backoff, targeting
physical primary-store deletion within one hour of expiry. That operational
lag must be documented, not described as exact-time physical deletion. Alert
on oldest expired row age, backlog, worker failures and storage/dead-tuple growth.
The one-hour target is proposed, not a new legal retention entitlement.

Use an indexed candidate CTE with `FOR UPDATE SKIP LOCKED`, then delete by primary
key in the same transaction. Do not scan/delete a whole day's 432,000 fixes in
one transaction. Autovacuum and WAL still matter; short transactions reduce
locking but do not make deletes free. Holds take the same row locks, copy only
selected evidence to separately restricted incident storage transactionally,
and record immutable source identity/digest. Purge can then remove ordinary
copies without retaining a whole route/day. A losing hold race reports partial
availability or 409, never invents evidence. Release/expiry of holds purges held
copies under the same accountable job. Incident coordinates and duplicate logs
are included in this data inventory, not an undeclared second raw history.

Sizing fixture: 50 buses × 12 h/day × 720 fixes/h × 30 days = 12,960,000 rows;
432,000/day ingress and expiry, about 5/s averaged over the day (10/s over the
12-hour collection window). Test realistic bursts/retries, not just averages.
Measure on the intended paid DB tier: storage+indexes, WAL, dead tuples/vacuum,
p95 ingestion/live reads, five-trip trace read time, purge drain rate and lock
waits. Require expiry drain rate > peak sustained arrival and backlog recovery
after an outage, without violating agreed API latency. Proposed latency targets
to ratify: p95 ingestion/live read <250 ms server-side, five-trip learning read
<2 s. No measured capacity claim is made in stage 1.

If that gate fails, adopt daily receipt partitions **before launch**, not after
real history accumulates. The alternative must prove: cross-partition fix-ID
uniqueness (a separate receipt/dedup registry or equivalent transactional design),
bounded registry retention, exact boundary cleanup, incident hold extraction,
partition precreation and detach locking, plus time-bounded trace queries.
Adding receipt to the unique key alone breaks dedup across retries; filtering
only by trip ID does not prune receipt partitions. The registry itself still
needs expiry and measurement. Partitioning is not cost-free metadata magic.

These trade-offs follow PostgreSQL's [partition constraints and pruning](https://www.postgresql.org/docs/16/ddl-partitioning.html)
and [DELETE behavior](https://www.postgresql.org/docs/16/sql-delete.html). The
decision to benchmark bounded deletion first is ours, not a PostgreSQL guarantee.

## Retention purpose and recovery boundary

Confirmed purpose is route/ETA learning. Thirty days is an approved initial
window to validate, not a measured minimum. “Recent operational diagnosis” was
assistant-proposed and is **not a separately confirmed purpose**; it cannot be
used to justify longer retention. Specific incidents use the approved scoped
hold with reason/owner/review date. Derived geometry/speeds require reidentification
review, especially a single-driver corridor; removing IDs alone is insufficient.

No raw coordinates in routine logs. Latest Redis entries expire within 120 seconds
and are invalidated on trip end/revocation; raw data is not exported to R2 as a
retention bypass. Backup expiry and provider deletion capability must be verified
against the selected service before claiming complete physical deletion. Any
restore is isolated: run expiry, hold reconciliation and revoked-session cleanup
before exposing it. Keep this operational verification on the launch checklist;
this PR does not change backup configuration or erase data.
