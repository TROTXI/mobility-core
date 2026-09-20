# Commuter API integration guide

Start here when connecting commuter screens to the replacement backend. The
staging service uses `services/api-next`; do not build new screens against the
old `services/api` endpoints or their generated model names.

## Contract and evidence

- Base URL: `https://trotxi-api-staging.onrender.com`
- Interactive reference: [staging /docs](https://trotxi-api-staging.onrender.com/docs)
- Deployment specification: [staging /docs/json](https://trotxi-api-staging.onrender.com/docs/json)
- Checked-in client specification: [replacement.openapi.json](../design/contracts/replacement.openapi.json)
- Actual response snapshots: [staging-examples.json](staging-examples.json)
- Schema source: [target-contract.mjs](../design/contracts/target-contract.mjs)
- Shared Flutter transport/domain layer: [trotxi_client](../../apps/trotxi_client/lib)

The snapshots name their backend commit and UTC capture time. Personal fields
are redacted and UUIDs are consistently substituted, preserving relationships.
They are examples, not IDs or credentials to paste into staging. Checkout links
are redacted too. Use IDs returned by your own requests.

Each captured response is checked against both the authoritative Zod schema and
the emitted OpenAPI schema. The generator embeds the same snapshots in the
published specification under `staging_*` examples. Other examples are illustrative
design fixtures, not claimed as live evidence.

This documentation change also corrects `/docs/json`: security definitions,
OpenAPI exclusive-bound syntax, and omission of disabled/unwired operations.
Those corrections reach staging only after this branch is merged and deployed.
The checked-in specification includes implemented optional providers; a particular
deployment may not enable all of them. Apple sign-in is not enabled on the
staging build used for these captures.

## Request basics

For mobile requests, send:

```http
x-trotxi-client: commuter
x-trotxi-platform: android
x-trotxi-build: 1
Authorization: Bearer <your-access-token>
```

Use `ios` on iOS and the app's actual numeric build number, not a hardcoded `1`.
Public catalogue calls do not require the Authorization header. Client metadata
is checked before role authorization; pretending to be the ops client does not
grant ops access. The exact required headers are declared on each operation.

JSON writes also send `Content-Type: application/json`. For a mutation declaring
`Idempotency-Key`, generate a fresh key for a new user intention, persist it with
the exact request body, and reuse both after a timeout. Do not turn a retry into
a new purchase. For edits declaring `If-Match`, send the resource's `editToken`
verbatim, not a collection token. Do not add these requirements to endpoints
that do not declare them.

Most single-resource results are `{ "data": ... }`; lists are
`{ "data": [...], "page": { "nextCursor": null } }`. Bootstrap/health/build
responses have their own schemas: `/flags` and `/version` are not data-enveloped.
An empty list is successful, not an error. Follow a non-null cursor unchanged
with the same filters; discard it when the filters change.

Money is integer pesewas: `{ "amountMinor": 26400, "currency": "GHS" }`
means **GHS 264.00**, not GHS 26,400. Do not send a calculated price at checkout.
UTC timestamps and local service dates are different types. Schedule weekdays
are ISO: Monday = 1, Sunday = 7. Ghana schedules use `Africa/Accra`.

## Screen-to-endpoint map

| Screen/task               | Request                                                         | What to use                                                           |
| ------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------------- |
| App bootstrap             | `GET /flags`                                                    | Minimum build, support contacts, map configuration                    |
| Google sign-in            | `POST /v1/auth/google`                                          | Send `{idToken}` from Google; save the returned API tokens securely   |
| Profile                   | `GET /v1/me`                                                    | `data.displayName`, nullable phone/avatar, account role               |
| Membership / pass summary | `GET /v1/me/membership`                                         | Coverage, access blocks, commute and ride/credit balances             |
| Choose corridor           | `GET /v1/routes` then `GET /v1/routes/{id}`                     | Route identities and patterns, not a list of physical stop IDs to buy |
| Choose departure times    | `GET /v1/routes/{id}/schedules`                                 | Schedule ID, explicit direction/window and exact version owner        |
| Choose stops              | `GET /v1/route-patterns/{id}/versions/{versionId}`              | Occurrences belonging to the selected schedule's version              |
| Prepare payment           | `POST /v1/me/purchases`                                         | `201`, server price and Paystack checkout URL                         |
| Payment recovery/history  | `GET /v1/me/purchases` and `GET /v1/me/purchases/{id}`          | Recover the existing purchase and observe its state                   |
| Daily reservations        | `GET /v1/me/reservations?fromDate=YYYY-MM-DD&toDate=YYYY-MM-DD` | Server reservation states; explicitly choose the screen's date window |
| Route-change requests     | `GET /v1/me/commute-requests`                                   | Submitted/waitlisted/approved/applied/rejected/cancelled history      |
| Departures                | `GET /v1/trips`                                                 | Public departure information, with declared filters                   |
| Bus tracking              | `GET /v1/trips/{id}/live`                                       | Authorized position/ETA; never collect the commuter's GPS             |

Use the specification for complete inputs, status codes and enums. Public trip
visibility is not permission to track that trip: the live endpoint evaluates
current access independently and hides unavailable/unauthorized resources with 404. A stale marker is not a live ETA.

## 1. Sign in, then read membership separately

Google authentication creates/authenticates an account; it does not buy coverage.
`POST /v1/auth/google` accepts the Google **ID token**, not a Google access token.
The response's `data` contains `accessToken`, `refreshToken`, their expiry dates
and `account`. Use the Trotxi access token for subsequent private calls.

Refresh via `POST /v1/auth/refresh` with `{refreshToken}` and replace the token
pair together. Use the shared client rather than reimplementing refresh races.
A timeout or 5xx during refresh is not proof the session is invalid; do not clear
credentials merely because the network is unavailable. Never log tokens or put
them in URLs, screenshots or documentation.

The new staging account returned this **captured** membership response before payment:

```json
{
  "data": {
    "membership": null,
    "coverage": null,
    "lastCoverageEndedAt": null,
    "access": { "canReserve": false, "blocks": [] },
    "commute": null,
    "entitlements": {
      "remainingRides": 0,
      "credit": { "amountMinor": 0, "currency": "GHS" },
      "heldCredit": { "amountMinor": 0, "currency": "GHS" },
      "availableCredit": { "amountMinor": 0, "currency": "GHS" }
    }
  }
}
```

There is no legacy `subscribed` boolean or flattened subscription response here.
Read `access.canReserve` for reservation eligibility, not just whether membership
exists. A membership can survive expired coverage. Blocks and `coverage.paused`
are separate; do not hide a dispute behind a generic paused label.

Use `coverage.endsAt` for the current coverage-end display. Renewal is **manual**,
not a scheduled automatic card charge. A nullable end date must not be replaced
with an invented renewal date; `lastCoverageEndedAt` is history, not future coverage.

## 2. Build a valid two-leg commute

The Circle–Madina staging fixture offers an outbound 06:30 schedule and return
17:30 schedule. These are test data, not guaranteed universal operating times.

| Identity                                    | Meaning                                             | Where it comes from         |
| ------------------------------------------- | --------------------------------------------------- | --------------------------- |
| `routeId`                                   | Stable corridor                                     | Route list/detail           |
| `patternId`                                 | Direction's pattern; needed in the version-read URL | Selected schedule           |
| `patternVersionId`                          | Exact immutable stop/geometry revision              | Selected schedule           |
| `scheduleId`                                | Specific recurring departure revision               | Route schedules             |
| `pickupOccurrenceId`, `dropoffOccurrenceId` | Ordered stops within that version                   | Pattern-version response    |
| `tripId`                                    | One actual run                                      | Trip/reservation responses  |
| `purchaseId`                                | Checkout and payment outcome                        | Purchase response           |
| `billingPeriodId`                           | Funded coverage period                              | Fulfilled purchase/coverage |
| `reservationId`                             | Rider's place/decision for a run                    | Reservations                |

A physical stop may occur twice on a loop. Never substitute its physical ID or
an array index for an occurrence ID. Pickup must precede dropoff in the chosen
direction. Resolve outbound and return independently; do not reverse one leg's
IDs or infer direction from the departure time.

The `PurchaseInput` shape is:

```text
{
  plan: "monthly",
  routeId: <selected corridor>,
  legs: [
    { direction: "outbound", scheduleId, patternVersionId,
      pickupOccurrenceId, dropoffOccurrenceId },
    { direction: "return", scheduleId, patternVersionId,
      pickupOccurrenceId, dropoffOccurrenceId }
  ],
  useCredit: false
}
```

This is a construction template, not a captured POST body. All IDs must come
from current responses. Read the exact version referenced by each schedule,
including older/future eligible versions; a route's currently displayed version
alone is insufficient. The backend still validates effective dates and ownership.

## 3. Prepare, pay, then confirm fulfilment

1. Persist the body and idempotency key; send `POST /v1/me/purchases`.
2. Accept **201**, read `data.price`, `appliedCredit`, `cashDue`, and `checkout`.
   Preparation creates a pending purchase and may hold credit; it does not charge
   the card. There is no standalone commuter quote endpoint in this contract.
3. Show the server's cash amount and open `checkout.url` only when available.
4. On returning, read the existing purchase. If the app restarted, discover it
   through `GET /v1/me/purchases`; do not require an ID kept only in widget state.
5. Treat `state: "fulfilled"` as purchase completion, then reread membership.
   Provider collection success alone does not prove ride allocation completed.

For this walkthrough only, the approved test fare is 600 pesewas per ride and
the monthly grant is 44 rides: price/cash due **26400**, applied credit **0**.
This is a disposable staging fixture, not a recommendation to hardcode pricing.
Only Paystack TEST mode is used; no real payment details belong in the app or docs.

The snapshots include the actual `awaiting_payment` / `pending` purchase with
`billingPeriodId: null`, followed by the fulfilled response below. This walkthrough
observed the real Paystack callback arrive in staging's inbox while the purchase
remained pending. With the user's approval, the existing inbox processor was run
once and applied that callback. No signed replay, fake ledger allocation, second
payment, or recurring job was used. Automatic callback delivery is verified;
automatic background processing is **not** established by this manual run.

This is the **captured fulfilled response**, with consistent substituted IDs:

```json
{
  "data": {
    "id": "3b393f7a-1913-4ceb-a517-524c5bc41715",
    "plan": "monthly",
    "state": "fulfilled",
    "collectionState": "successful",
    "price": { "amountMinor": 26400, "currency": "GHS" },
    "appliedCredit": { "amountMinor": 0, "currency": "GHS" },
    "cashDue": { "amountMinor": 26400, "currency": "GHS" },
    "checkout": {
      "url": "https://checkout.paystack.com/REDACTED",
      "expiresAt": null
    },
    "billingPeriodId": "151ba008-adbd-46e5-a088-8570a2bb389b",
    "failureCode": null,
    "createdAt": "2026-09-20T00:20:49.139Z"
  }
}
```

The checkout URL can remain present after fulfilment: hide the Pay button based
on state, not URL existence. A fresh membership read then returned:

| Field                                 | Captured value             |
| ------------------------------------- | -------------------------- |
| `membership.lifecycle`                | `open`                     |
| `coverage.state` / `coverage.paused`  | `open` / `false`           |
| `coverage.startsAt`                   | `2026-09-20T00:26:24.000Z` |
| `coverage.endsAt`                     | `2026-10-20T00:26:24.000Z` |
| `coverage.renewalMode`                | `manual`                   |
| `access.canReserve` / `access.blocks` | `true` / `[]`              |
| `commute.routeName`                   | `Circle - Madina`          |
| `entitlements.remainingRides`         | `44`                       |
| Credit, held credit, available credit | All `0` pesewas            |

The full membership response, including both legs and linked IDs, is
`getMembership` → `staging_18` in the generated reference and capture file.
The wallet was also verified on Android showing 44 rides and the October end date.

### Captured versus still illustrative

The 19 snapshots cover 12 operations: profile; empty reservations and commute
requests; bootstrap/build; route, schedules and both versions; membership before
checkout, while pending, and after funding; empty/pending/fulfilled purchase
lists; and pending/fulfilled single-purchase reads. They do **not** claim a live
reservation, boarding, route-change decision, refund, erasure, or iOS walkthrough.
Authentication tokens and the checkout POST body were deliberately not published
as captured evidence. The request template above remains schema guidance.

For `awaiting_payment` or `processing`, keep a pending/recovery view. Poll with
bounded backoff while visible and offer refresh; do not spin indefinitely or
submit another purchase. For `failed`, `cancelled`, or `review_required`, show
the server state and available recovery/support action. Never infer success
from the existence of a checkout URL or a return-link query parameter.

## 4. Errors and retries

Errors use `{ "error": { "code", "message", "requestId", "fieldErrors"? } }`.
Use the machine `code` for behavior and preserve `requestId` for support.

| Outcome       | Frontend handling                                                                      |
| ------------- | -------------------------------------------------------------------------------------- |
| 400           | Invalid input/metadata/filter; correct the request, don't retry unchanged forever      |
| 401           | Follow shared session-refresh behavior; don't confuse network failures with revocation |
| 403           | Authenticated but not permitted for this role                                          |
| 404           | Absent or deliberately hidden resource; don't reveal another user's resource           |
| 409           | Domain/idempotency conflict; inspect `error.code`, refresh relevant state              |
| 412 / 428     | Stale / missing edit precondition; refetch the per-resource token                      |
| 426           | Update required; render the update path using bootstrap configuration                  |
| 429           | Respect `Retry-After`, preserve the user's pending action                              |
| Network / 5xx | Recoverable failure, not payment success; preserve mutation key/body                   |

Not every operation declares every status. Use its exact response schema and
do not silently discard successful 201/204 responses because an old call used 200.

## Flutter and documentation maintenance

Use `apps/trotxi_client` over the canonical generated `apps/api_client` package.
Do not revive `_next` packages or old `MeSubscriptionGet...` model names.
`pnpm codegen:replacement` generates from the checked-in replacement OpenAPI,
not from an arbitrary deployed service. Follow with the generated package's
`dart run build_runner build` step when regenerating models.

To build Android against staging without putting server secrets in the app:

```sh
cd apps/trotxi_commuter
flutter build apk --debug \
  --dart-define=API_BASE_URL=https://trotxi-api-staging.onrender.com \
  --dart-define=API_SESSION_REALM=staging-replacement-v1
```

The TEST secret key stays on the backend. Normal Google sign-in supplies the
rider session. The private capture helper used for this walkthrough is temporary
and is not part of the shipped client.

After changing schemas or captured examples, use Node 24 and run:

```sh
node docs/design/scripts/build-contract.mjs
node docs/design/scripts/build-transport-contract.mjs
node --test docs/design/scripts/contract.test.mjs
pnpm --filter @trotxi/api-next typecheck
pnpm --filter @trotxi/api-next test
```

Do not hand-edit generated JSON. Do not label unit-test fixtures as live captures,
publish actual account credentials, or silently change a captured state to the
state the UI expected.
