# Proposed API contracts and endpoint redesign

Status: draft for review; no routes, schemas or generated clients changed.
Baseline: `43cdae0`, merged PR #292. This is part of the
[database redesign](database-redesign-proposal.md), not a later cosmetic rename.

## Goals and constraints

- Design around rider, driver and ops tasks, not one endpoint per database table.
- Give callers consistent identity, authorization, errors, pagination, dates,
  retries and lifecycle semantics.
- Preserve reviewed business rules and mark intentional behavior changes.
- Make a clean prelaunch replacement: no legacy endpoint aliases, response
  adapters, dual writes or deprecation window. Update all consumers together.
- Keep provider ingress stable while mobile-facing contracts migrate.
- Deliver actual OpenAPI schemas and generated-client tests before implementing
  each new domain. The tables and examples here are a proposed contract catalog,
  not a complete executable OpenAPI specification.

## Contract conventions

### Namespaces and visibility

Use `/v1` as the first explicitly versioned client/ops API. Existing routes are
unversioned legacy contracts, not an earlier `/v1` implementation.

| Namespace                 | Audience and scope                                                                                             |
| ------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `/v1/me`                  | Authenticated user's account and rider-owned resources; rider workflows additionally require the commuter role |
| `/v1/driver`              | Driver account; every trip, reservation and manifest operation checks current assignment                       |
| `/v1/ops`                 | Authenticated admin/ops role plus resource authorization; does not create a new ops console                    |
| `/v1/routes`, `/v1/trips` | Deliberately limited catalog/trip read models; private trip/location reads require explicit entitlement        |
| `/v1/auth`                | Authentication, refresh and logout; provider-specific credentials handled by the auth contract                 |
| `/webhooks/paystack`      | Existing provider URL and raw-body signature contract retained during migration                                |

Namespace alone is never authorization. Self-service endpoints derive user ID
from the session and do not accept an arbitrary user ID. Driver-role checks do
not authorize every trip. Lists apply scope in the query, before pagination.
Cross-user resource lookup returns the same not-found response as an absent ID;
role denial can return forbidden without disclosing resource contents.

### JSON and field semantics

- JSON uses camelCase and named domain schemas/operation IDs. Avoid generating
  anonymous names based on HTTP status and path segments where named components
  describe the concept clearly.
- Single-resource reads and mutation results use `{ "data": ... }`. Collections
  use `{ "data": [...], "page": { "nextCursor": null } }`. Health, metrics,
  provider callbacks and binary upload/download contracts are explicit exceptions.
- IDs are opaque strings to clients. Commands refer to actual stop-occurrence
  IDs, never list offsets. Foreign keys are not automatically public fields.
- Timestamps are UTC strings with `Z`; service dates use `YYYY-MM-DD` in the
  named service timezone. Recurring departure times use `HH:mm` with
  `timeZone: "Africa/Accra"`. Durations and ETA values use integer seconds,
  distances metres; clients format them for display.
- Monetary values use `{ "amountMinor": 26400, "currency": "GHS" }`.
  `amountMinor` is an integer; for GHS the unit is pesewas. This introduces no
  exchange-rate or multi-currency pricing feature.
- Null means absent/unknown as documented; zero means measured zero. Required
  fields do not disappear according to the caller's role: define separate
  rider/driver/ops read schemas instead of one shape that selectively leaks data.
- Use `coverage.endsAt` and `renewalMode: "manual"`, not a promised automatic
  renewal date. While pause duration is unresolved, expose `endsAt: null` and
  `endStatus: "pending_resume"`, with the last known deadline available in
  period history. Active, paused, disputed and lapsed remain distinguishable.
- PATCH omits unchanged fields; explicit null clears only fields documented as
  nullable. Reject unknown command fields rather than silently accepting typos.

### Errors and response statuses

```json
{
  "error": {
    "code": "period_settlement_pending",
    "message": "Your previous period still has a trip awaiting settlement.",
    "requestId": "request-example",
    "fieldErrors": []
  }
}
```

Codes are stable; text is display guidance and must not be parsed for behavior.
Document the allowed codes per operation. Never expose SQL, internal stack
traces, provider secrets or another rider's details in errors. A request ID
connects a safe client error to restricted server logs.

| Status | Meaning                                                                                                          |
| ------ | ---------------------------------------------------------------------------------------------------------------- |
| 200    | Read or completed action, including an idempotently already-completed action                                     |
| 201    | New resource created, with its canonical URL in `Location`                                                       |
| 202    | Work durably accepted but not complete; return a resource URL for status                                         |
| 204    | Successful removal/revocation where no representation is returned                                                |
| 400    | Malformed or invalid input, with structured field errors where useful                                            |
| 401    | Missing/invalid authentication; definitive refresh rejection remains distinct from transient network failure     |
| 403    | Authenticated caller lacks the required role or allowed operation                                                |
| 404    | Resource absent or outside the caller's visible scope                                                            |
| 409    | State conflict, insufficient entitlement/capacity, stale business selection, or idempotency-key payload mismatch |
| 412    | Supplied `If-Match` no longer matches the resource version                                                       |
| 429    | Rate limit; include `Retry-After`                                                                                |
| 503    | Dependency unavailable or mutation admission paused                                                              |

The new API maps existing 402 entitlement refusals to documented 409 codes such
as `membership_required` or `rides_exhausted`; update client handling in the same
release. Neither HTTP 200 nor a provider return URL means a
payment is fulfilled. A resource may remain awaiting payment or processing.

### Retry, concurrency and list rules

Require an `Idempotency-Key` on create/financial/transition commands that may be
retried by clients. Scope it to caller, operation and target; persist a normalized
payload hash and durable operation identity. The same key with different input
is a 409. Concurrent repeats identify the same operation/resource. Replay never
bypasses current authentication or returns another user's response.

Retain keys for the documented mobile retry horizon, and longer while financial
outcome is unresolved. Uniqueness of durable business events protects against
duplicates beyond response-cache retention. Use the existing per-trip
`clientFixId` for GPS deduplication so replay does not depend on an HTTP cache.
Sensitive response material such as boarding codes has separate, short-lived
storage/redaction rules; do not log it as an idempotency payload.

Return ETags/versions for editable ops records and commute decisions. Require
`If-Match` for edits where stale state would overwrite another action. Check
authorization and completed idempotency records before treating a retry's old
version as a fresh conflicting command. Keep version checks, state transitions
and idempotency ownership in the same transaction.

Collections use opaque cursor pagination with stable tie-breaking by ID and
bounded `limit` (default 50, maximum 200 unless a narrower contract applies).
Each endpoint declares its sort and filters; the cursor binds those filters and
scope. Pagination is not a historical snapshot unless explicitly offered.
Trip/date filters also enforce a bounded range. Driver offline manifests need
an explicit completeness/version strategy; a truncated page cannot masquerade
as the full passenger manifest.

## Rider endpoints

All paths in the following tables are proposed.

| Method and path                                                 | Result or command                                                                                                               |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `GET /v1/me`                                                    | Account/profile; no subscription-table dump                                                                                     |
| `PATCH /v1/me`                                                  | Documented editable profile fields only                                                                                         |
| `PUT /v1/me/avatar`, `DELETE /v1/me/avatar`                     | Preserve avatar upload/removal capability; typed upload/media response                                                          |
| `DELETE /v1/me`                                                 | Existing account-erasure intent, with an explicit completion result and session revocation                                      |
| `GET /v1/me/sessions`, `DELETE /v1/me/sessions/{id}`            | Session visibility and revocation                                                                                               |
| `POST /v1/me/devices`                                           | Register/update the caller's push device idempotently                                                                           |
| `GET /v1/me/membership`                                         | Composed current membership, coverage, access blocks, commute and entitlement summary; distinguish lapsed from never subscribed |
| `GET /v1/me/billing-periods`, `GET /v1/me/billing-periods/{id}` | Paid coverage and purchase history                                                                                              |
| `POST /v1/me/purchases`                                         | Price selected plan/commute, freeze terms, reserve credit and initiate collection                                               |
| `GET /v1/me/purchases`, `GET /v1/me/purchases/{id}`             | Purchase and payment progress, including authoritative fulfilment result                                                        |
| `GET /v1/me/ride-entries`, `GET /v1/me/credit-entries`          | Rider-readable history, typed reasons and amounts; not raw internal accounting metadata                                         |
| `GET /v1/me/commute-assignments`                                | Effective and historical commute choices                                                                                        |
| `POST /v1/me/commute-requests`, `GET /v1/me/commute-requests`   | Submit and list own transfer requests                                                                                           |
| `GET /v1/me/commute-requests/{id}`                              | Own request state, effective date and rider-visible ops decision history                                                        |
| `POST /v1/me/commute-requests/{id}/withdraw`                    | Existing withdrawal rules; no direct rider approval/apply or unconsented resume                                                 |
| `GET /v1/me/reservations`, `GET /v1/me/reservations/{id}`       | Scoped daily intent/seat records and trip summaries                                                                             |
| `POST /v1/me/reservation-decisions`                             | Confirm/decline a date/window; return the affected reservation and permitted boarding proof                                     |
| `POST /v1/me/reservations/{id}/pass`                            | Issue short-lived proof tied to the intended reservation/trip after entitlement checks                                          |

The reservation-decision command retains the existing one-per-day/window
semantics, including decline when entitlement has lapsed. It is not unrestricted
CRUD over reservation status. Assignment, period funding, seat capacity and
boarding outcomes remain server-controlled.

Pass scoping is an intentional improvement over resolving the earliest boardable
reservation from a rider-only proof. Specify token claims and migration behavior
before enabling it. Issuance does not itself consume a ride.

### Membership read model example

Identifiers are illustrative placeholders in these examples.

```json
{
  "data": {
    "membership": { "id": "membership-example", "lifecycle": "open" },
    "access": { "canReserve": true, "blocks": [] },
    "coverage": {
      "periodId": "period-example",
      "startsAt": "2026-09-01T00:00:00Z",
      "endsAt": "2026-10-01T00:00:00Z",
      "endStatus": "fixed",
      "renewalMode": "manual"
    },
    "lastCoverage": null,
    "entitlements": {
      "remainingRides": 24,
      "availableCredit": { "amountMinor": 1980, "currency": "GHS" },
      "heldCredit": { "amountMinor": 0, "currency": "GHS" }
    },
    "commute": {
      "assignmentId": "assignment-example",
      "route": { "id": "route-example", "name": "Adenta – Circle" },
      "legs": [
        {
          "serviceWindow": "morning",
          "patternVersionId": "outbound-version-example",
          "pickupOccurrenceId": "outbound-pickup-example",
          "dropoffOccurrenceId": "outbound-dropoff-example",
          "departureTime": "06:30",
          "timeZone": "Africa/Accra"
        },
        {
          "serviceWindow": "evening",
          "patternVersionId": "return-version-example",
          "pickupOccurrenceId": "return-pickup-example",
          "dropoffOccurrenceId": "return-dropoff-example",
          "departureTime": "17:30",
          "timeZone": "Africa/Accra"
        }
      ]
    }
  }
}
```

An open membership alone does not prove paid eligibility. A lapsed response has
no current coverage and an explicit last-coverage summary; a never-subscribed
response has no membership or last coverage. A paused and disputed rider receives
both safe block reasons. The read schema must enumerate all these cases.
`canReserve` summarizes membership eligibility, not a guarantee of seats on every
trip; the command revalidates capacity and current state.

## Purchases: explicit progress rather than a redirect assumption

`POST /v1/me/purchases` accepts the selected plan and validated commute legs. The
server chooses prices and credit application. It does not accept a client amount,
rider ID, arbitrary payment status or provider environment.

Return a stable purchase ID, agreed price/cash/credit, purchase status and a
nullable hosted-checkout next action. Resource creation can return 201 while the
purchase is still awaiting payment; durable asynchronous processing can return
202 with the same status-resource URL. Only return a checkout URL after provider
initialization has succeeded and the returned reference has been checked.

The app polls `GET /v1/me/purchases/{id}` after returning from checkout. That
response separates collection status from fulfilment status, and links paid
coverage only when fulfilled. Initialization uncertainty stays visible and
recoverable. Repeated creation with the same key returns the same purchase.
Renewal uses this same operation; it is an explicit rider purchase.

Separate attempt records remain internal unless the rider needs a specific retry
action. This proposal introduces no second way to collect an unresolved purchase
and no public endpoint to mark a payment paid. Refund/dispute delivery and Verify
remain authoritative provider-processing paths.

## Catalog and live-trip reads

| Method and path                                    | Purpose                                                                                                          |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `GET /v1/routes`, `GET /v1/routes/{id}`            | Published corridor catalog and available directional patterns                                                    |
| `GET /v1/route-patterns/{id}/versions/{versionId}` | Versioned ordered stop occurrences and published geometry reference                                              |
| `GET /v1/route-geometries/{id}`                    | Immutable geometry revision with its matching stop-distance data                                                 |
| `GET /v1/trips`, `GET /v1/trips/{id}`              | Bounded discoverable trip summaries with explicit direction/window; no passenger list or driver personal profile |
| `GET /v1/trips/{id}/live`                          | Authorized position, freshness, ETA and relevant rider pickup in one response                                    |
| `GET /v1/config`                                   | Typed mobile configuration, minimum versions and basemap metadata                                                |

The driver uses separate trip/manifest schemas below. The rider trip summary
includes enough route/vehicle/stop display data to avoid fetching internal fleet
records. Geometry remains independently cacheable and identified by version.

Live reads check authorization before looking up cached location data. Approved
direction: public route/stops mapping, but live position only for eligible riders
on the relevant corridor and authorized staff, including the assigned driver.
The detailed paused/disputed/lapsed/pre-booking matrix remains a stage 1 contract
deliverable. No successful live response follows merely from knowing a trip UUID.
Historical disputes default to their affected period; an account-wide block needs
an explicit ops decision. Test these as target rules, not assumed baseline behavior.

```json
{
  "data": {
    "tripId": "trip-example",
    "state": "live",
    "patternVersionId": "outbound-version-example",
    "geometryId": "geometry-example",
    "position": {
      "latitude": 5.6037,
      "longitude": -0.187,
      "capturedAt": "2026-09-14T06:45:00Z",
      "receivedAt": "2026-09-14T06:45:02Z",
      "ageSeconds": 4,
      "freshness": "fresh"
    },
    "etaToStops": [
      {
        "stopOccurrenceId": "outbound-dropoff-example",
        "etaSeconds": 360,
        "distanceMeters": 1800,
        "basis": "observed_segments"
      }
    ],
    "riderPickupOccurrenceId": "outbound-pickup-example",
    "serverTime": "2026-09-14T06:45:04Z"
  }
}
```

Document `live`, `stale`, `awaiting_fix` and `inactive` as distinct read states.
Authorized inactive/no-fix reads return 200 with no live position, not misleading
zero coordinates or an unexplained 404. This is an intentional change from the
legacy active-trip-only read behavior. Mutation attempts on an inactive trip
still fail with a state conflict.

Compute freshness using the approved capture-clock policy; clamp only the
displayed age as appropriate, not the evidence timestamps. A driver with a
future clock must not freeze the marker for the accepted skew interval. Do not
claim a complete freshness policy has been designed just because the response
has `ageSeconds`. Location responses are private, with no shared caching; catalog
and immutable geometry may use explicit public cache rules after data review.

The basemap comes from R2. The commuter supplies selected stop IDs, not device
coordinates. No commuter location permission or collection is introduced.

## Driver endpoints

| Method and path                                         | Purpose                                                                                               |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `GET /v1/driver/trips`, `GET /v1/driver/trips/{id}`     | Own assigned schedule and composed run detail                                                         |
| `POST /v1/driver/trips/{id}/start`                      | Idempotent start, current assignment checked atomically                                               |
| `POST /v1/driver/trips/{id}/complete`                   | Valid lifecycle completion                                                                            |
| `POST /v1/driver/trips/{id}/arrivals`                   | Report a stop occurrence; preserve explicit correction behavior with event identity/version ordering  |
| `POST /v1/driver/trips/{id}/positions`                  | Capture timestamp, client fix ID and coordinates; durable receipt for that fix                        |
| `GET /v1/driver/trips/{id}/manifest`                    | Scoped passengers, statuses and bounded avatar access; explicit completeness                          |
| `POST /v1/driver/trips/{id}/boardings`                  | Tagged proof: reservation QR, trip code or manifest selection; all converge on one boarding operation |
| `POST /v1/driver/trips/{id}/no-shows`                   | Reservation-targeted chargeable no-show, idempotent with boarding                                     |
| `GET /v1/driver/trips/{id}/summary`                     | Own completed/run summary                                                                             |
| `POST /v1/driver/incidents`, `GET /v1/driver/incidents` | Own incident reporting/history, including reports before a trip starts                                |
| `GET /v1/driver/requestable-routes`                     | Routes ops permits a driver to request                                                                |
| `POST /v1/driver/requests`, `GET /v1/driver/requests`   | Route-change and leave requests                                                                       |
| `POST /v1/driver/requests/{id}/withdraw`                | Own eligible request withdrawal                                                                       |

Boarding proof is a discriminated union so a request cannot ambiguously combine
QR, PIN and photo-selection fields. The target trip is mandatory. A correct proof
does not bypass assignment, reservation ownership or current eligibility. No-show
followed by boarding cannot charge twice. Existing offline/failure semantics
need explicit invariant review rather than being changed accidentally by this
unification.

Arrival corrections remain possible. Distinguish a deliberate correction from
an old offline arrival replay; sequence/version rules must prevent delayed
events from overwriting newer progress. GPS is naturally high volume: keep its
acknowledgement small and separate it from the rider live-map response.

## Ops and system endpoints

| Endpoint family under `/v1/ops`                                                                   | Operations                                                                                                |
| ------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `/routes`, `/stops`, `/vehicles`, `/drivers`                                                      | List/create and PATCH allowed draft/profile fields; explicit archive operations for historical parents    |
| `/route-patterns/{id}/versions`                                                                   | Create/read draft versions; publish with validation; published stop definitions cannot be edited in place |
| `/service-schedules`                                                                              | Manage versioned recurring service definitions                                                            |
| `/trips`, `/trips/{id}/assignment`                                                                | Create/read scheduled runs and assign/reschedule with version checks                                      |
| `/commute-requests`, `/commute-requests/{id}/events`                                              | Scoped queue and full ops decision history                                                                |
| `/commute-requests/{id}/decisions`                                                                | Append a typed waitlist/pause/resume/approve/apply/reject/cancel decision; return resulting state         |
| `/commute-slots`, `/commute-slots/{id}/retire`                                                    | Manage verified transfer quota                                                                            |
| `/purchases`, `/purchases/{id}`, `/payment-reviews`                                               | Reconciliation evidence and pending ops reviews; no arbitrary paid-state PATCH                            |
| `/incidents`, `/driver-requests`                                                                  | Queues and permitted decisions with actor/time/reason                                                     |
| `/drivers/{id}/credentials`                                                                       | Issue/suspend credentials; explicit PIN reset operation                                                   |
| `/users/{id}/role`                                                                                | Privileged role administration with actor audit                                                           |
| `/routes/{id}/fares`, `/plan-pricing`                                                             | Effective-dated fares and plan configuration with currency/units                                          |
| `/flags`, `/min-versions`                                                                         | Typed operational configuration                                                                           |
| `/maintenance/payments`                                                                           | Bounded inbox → Verify → safe period close, returning stage totals and sanitized failures                 |
| `/maintenance/reservation-dispatch`, `/maintenance/reservation-defaults`, `/maintenance/no-shows` | Existing bounded operational jobs                                                                         |
| `/maintenance/route-learning`                                                                     | Publish compatible geometry/distances/speeds and report outcomes                                          |

This family table still needs exact method/operation schemas in the OpenAPI
inventory; it is not permission for unrestricted CRUD. Published versions,
payments and ledgers require specific domain operations. No new refund-initiation,
dispute-provider submission or automated collection endpoint is implied.

Maintenance can remain synchronous and bounded: 200 means the requested batch
completed, with failed/blocked counts explicit. Do not return 202 unless a durable
job exists and the caller can inspect its status. Cron requests need limited
service authority, never a driver/rider token. Stop old jobs at cutover and deploy
matching replacement jobs; all writers use the single new domain model.

## Authentication and provider ingress

Keep Google, Apple, driver sign-in, refresh and logout capabilities under
`/v1/auth`. Specify token expiry and session outcomes with named schemas. Preserve
the refresh behavior already fixed: transient refresh/retry failures must not
sign a user out, and only a definitive rejection of the matching stored refresh
credential may clear it. Credential rotation/reset stays an explicit operation.

Keep `/webhooks/paystack` as the provider ingress URL, not a legacy API alias.
Verify the true raw body and acknowledge only after durable persistence, then
process through the replacement model. Quarantine unmatched old fixture
references rather than assigning them to new purchases. Test delayed events
across cutover. Health and metrics remain operational endpoints; update their
consumers as needed in the same release.

## Representative current-to-target inventory

This comparison is for review and isolated test adapters, not a deployed
compatibility layer. Removed endpoints are absent from the replacement API.

| Existing contract                                                                            | Proposed replacement                                                   |
| -------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `GET /me/subscription`                                                                       | `GET /v1/me/membership` with explicit coverage/history/block semantics |
| `POST /payments/subscribe`                                                                   | `POST /v1/me/purchases` and polling the owned purchase resource        |
| `GET /me/rides`                                                                              | Entitlement summary in membership plus typed ride/credit histories     |
| Driver `GET /me/trips`                                                                       | `GET /v1/driver/trips`                                                 |
| `GET /trips/{id}/position`                                                                   | Authorized `GET /v1/trips/{id}/live`                                   |
| `POST /trips/{id}/position`                                                                  | `POST /v1/driver/trips/{id}/positions`                                 |
| `POST /trips/{id}/arrive` with `seq`                                                         | `POST /v1/driver/trips/{id}/arrivals` with stop occurrence             |
| `/boarding/scan`, `/boarding/verify-code`, `/boarding/verify-pin`, `/boarding/board`         | Trip-scoped boarding command with typed proof                          |
| `/admin/expire-subscriptions`, `/admin/convert-credits`, `/admin/close-subscription-periods` | One canonical safe period-close stage in payments maintenance          |
| `/me/work/requests`                                                                          | `/v1/driver/requests`                                                  |
| `/admin/*`                                                                                   | Explicit `/v1/ops/*` domain commands and read models                   |

A complete current-method/path inventory must come from the running generated
OpenAPI document in a controlled local build, including dynamically registered
routes. A text grep alone misses loops such as start/complete and me/admin commute
lists. Record an explicit keep/replace/retire decision and consumer for every
operation before implementation begins.

## Contract-first implementation and rollout

1. Extend the invariant inventory with endpoint authorization, failure behavior,
   retry semantics and app expectations. Review this contract catalog alongside
   the target entities; do not design the database first and infer the API later.
2. Produce a versioned OpenAPI contract with named schemas, operation IDs, examples,
   all status/error variants, permissions, limits and idempotency rules. Choose
   one authoritative schema workflow consistent with the existing Zod runtime
   validation; prevent a hand-maintained spec drifting from actual serializers.
3. Generate the Dart client and compile small rider, driver and ops-consumer
   examples against it before implementing each domain. Exercise paused/disputed,
   expired/never-subscribed, pending payment and no-GPS shapes, not just success.
4. Extend the isolated differential harness with old-contract and v1 HTTP test adapters. Compare
   normalized domain behavior where preserved; separately approve intentional
   changes such as tighter live authorization, trip-scoped passes and HTTP status
   changes. Add direct response-schema and cross-user/role tests on v1.
5. Implement only the replacement handlers over canonical domain operations.
   Do not retain old handlers or deploy translation adapters. Generate contract
   artifacts from this build, not whichever
   schema happens to be deployed on staging that day.
6. Update both apps, ops consumers, scripts and scheduled jobs to the replacement
   contract. Complete end-to-end rehearsal before the coordinated staging
   cutover; never release a half-updated stack. No per-record model selection or
   interim endpoint aliases are needed with zero users.
7. Rehearse failure recovery after new writes and delayed provider delivery.
   Install/reseed the clean schema only as an explicitly approved cutover step.
   Regenerate clients cleanly; do not publish the current untracked generation
   leftovers as the new contract.

The API work belongs in stage 1 review and stage 2 harness preparation, with
backend implementation in stage 3 and consumer integration in stage 4. Stage 5
rehearses the whole system; stage 6 cuts over staging. Mobile developers see the
contracts from the first stage, not at the end.

## Review status and remaining contract decisions

This draft deliberately changes API shapes and some HTTP outcomes. It does not
declare those changes implemented. The product owner approved period-scoped
historical disputes by default, restricted live-position access with a public
route/stops map, and explicit reassignment for removed stops while preserving
operated history. Detailed authorization/ops contracts still need review. GPS
retention/skew remains a team decision. Retention periods for idempotency results
and offline manifests also need concrete limits in the executable contract.
Pricing, entitlement counts and automatic renewal policy are unchanged. Follow
the ownership checkpoint and prelaunch tripwire in the database proposal; keep
the review PR in draft until stage 1 is complete and reviewed.
