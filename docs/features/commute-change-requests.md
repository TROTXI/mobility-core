# Commute-change requests

Riders request a change; operations decides whether recurring capacity is
available. Submitting a request does **not** edit the rider's paid assignment.
This implementation owns the commuter app and API contract, **not the ops
console**. The ops team can consume the authenticated endpoints below.

## Rider path

Profile → Commute preferences now sends route/stop IDs, preferred morning and
return times, a requested start date, an optional note, and explicit consent to
pause if waitlisted. Times are Ghana time (GMT). Destinations must be downstream
of pickup on the requested route. Only one open request is allowed per rider.

The screen reloads durable status and the latest operations note. It does not
claim that preferences were saved locally or that a pending request changed the
subscription. Pull-to-update is an explicit **Refresh requests** button; this
slice does not implement push notifications. An unpaused open request can be
withdrawn after confirmation. A paused rider contacts operations to resume
before withdrawing, so cancellation cannot silently restart paid time.

The former local-only Quiet ride toggle is not part of this request form. No
notification preference is represented as persisted by this feature.

## API handoff to operations

All routes appear in the running API's `/docs/json` OpenAPI document. Bearer
tokens are required; `/me/*` requires commuter role and `/admin/*` admin role.
Decisions additionally recheck that the acting admin account is not deleted and
still holds the admin role. Never put an admin token into the commuter app.

| Endpoint                                    | Purpose                                                                                |
| ------------------------------------------- | -------------------------------------------------------------------------------------- |
| `POST /me/commute-requests`                 | Submit a request; returns its ID                                                       |
| `GET /me/commute-requests`                  | Current rider's requests only                                                          |
| `POST /me/commute-requests/:id/withdraw`    | Withdraw own unpaused open request                                                     |
| `GET /admin/commute-requests`               | Ops reads requests with rider, route, stops, status, pause consent and latest decision |
| `GET /admin/commute-requests/:id/events`    | Timestamped decision history and actor IDs                                             |
| `POST /admin/commute-requests/:id/decision` | Record an ops decision atomically                                                      |
| `GET /admin/commute-slots`                  | Read up to 200 latest recurring transfer slots                                         |
| `POST /admin/commute-slots`                 | Publish one verified recurring transfer place                                          |
| `POST /admin/commute-slots/:id/retire`      | Retire an unclaimed slot                                                               |

Request lists accept `status`, `limit` (1–200, default 100), and `offset`
(default 0). For example, pull `?status=pending&limit=100&offset=0`, then advance
the offset until a short page. Sort order is creation time and ID, newest first.
Refresh the queue after decisions; offset pagination is not a point-in-time
snapshot while other users are submitting or deciding requests.

Submission body (IDs must refer to real route/stops):

```json
{
  "routeId": "<route UUID>",
  "pickupStopId": "<pickup UUID>",
  "dropoffStopId": "<destination UUID>",
  "morningDeparture": "06:30",
  "eveningReturn": "17:30",
  "requestedDate": "2026-10-01",
  "pauseIfWaitlisted": false,
  "note": "Moving home"
}
```

A slot body is `routeId`, `morningDeparture`, `eveningReturn`, and
`availableFrom` (`YYYY-MM-DD`). Ops must verify recurring capacity before
publishing it; a spare seat on one trip is not recurring availability. Actual
trip capacity checks remain in place. Slots are a transfer quota, not a new
global capacity model for every subscription purchase.

A decision body contains `action` and a required nonempty `note` (≤1,000
characters). Actions:

- `waitlist`: keep the current subscription running unless separately paused.
- `pause`: allowed only on a waitlisted request with rider consent.
- `resume`: restart a paused subscription, retaining the request for review.
- `approve`: requires `slotId` and `effectiveDate`. The slot must match route
  and both times, be available by that date, and still be unclaimed.
- `apply`: explicitly applies an approved change once its effective date arrives.
- `reject` / `cancel`: closes an unpaused request and releases any held slot.

Approval holds capacity; **it is not an automatic scheduled transfer**. Ops
must call `apply` on/after the effective date. There is no new cron or ops UI
in this change. Applications should ask for confirmation before pause/apply and
display the API's 409 `message` when a decision needs attention.

## Accounting and concurrency

Migration `043_commute_change_requests.sql` is append-only. It adds requests,
transfer slots, an event log and a separate subscription-pause history.

Transactions use the payment lifecycle's per-rider advisory lock. The current
request, subscription and period are locked during decisions. Competing
approvals atomically claim a slot, so only one rider can hold the last place.
Before a pause or transfer, involved trips are locked against concurrent trip
starts. Unsettled/current trips block the action; future scheduled reservations
are cancelled without charging/refunding a ride. New-route dispatch can replace
those cancelled bookings, without reusing an old boarding PIN.

Pauses are orthogonal to payment-dispute suspension. While paused, dispatch,
booking, checkout and period-close exclude the membership. Resume extends the
current subscription and period end by the elapsed pause duration; unused rides,
price, conversion rate and original route pricing snapshot are unchanged. Pause
rows retain the original deadline and resulting extension for audit. A dispute
must be resolved before a commute pause can be resumed.

Apply updates subscription route/stops and the allocated commute times, then
resumes if paused. It never allocates extra rides or mints credit. The existing
period remains the financial attribution for subsequent rides. Allocated times
filter dispatch and booking in Ghana time. Expiry, refund-driven expiry,
cancellation or a replacement period closes obsolete requests/pauses and
releases their capacity, retaining decision history.

Account erasure scrubs free-text request/decision notes, removes the rider from
queue reads, closes open requests and releases held/allocated transfer capacity.

Different/unknown fares are refused with `fare_review_required`; fare-adjustment
policy is not silently invented. A request tied to a changed/frozen period cannot
be applied. Legacy subscriptions without a linked current period cannot submit.

## Verification and rollout

- API contract tests cover validation, role protection, rider isolation and errors.
- Real local Postgres tests apply migration 043 in an isolated schema, race
  duplicate submissions and last-slot approvals, and exercise pause/resume,
  maintenance/checkout guards, replacement bookings, fare refusal and cleanup.
- CI also applies the complete migration chain on PostGIS before PG tests.
- Commuter widget tests cover submission, non-consent default, pending/waitlist
  display, confirmation before withdrawal and offline recovery.

Deploy migration/API before the updated app. Coordinate the ops consumer before
enabling requests for riders: an API queue alone does not guarantee anyone is
reviewing it. No staging deployment, paid service, or scheduled job is enabled
by this implementation.
