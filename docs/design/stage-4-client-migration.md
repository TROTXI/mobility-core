# Stage 4: moving an app to the replacement contract

For the current staging integration and captured responses, start with the
[commuter API guide](../api/README.md). The stage notes below are historical
migration context, not the current deployment runbook.

For whoever owns an app. Both apps now use the replacement on the Stage 4
branches; remaining commuter features are tracked separately. This describes the shared
contract changes, not a deployment or permission to mix backend generations.
See `stage-4-progress.md` for implementation and verification status.

## What exists now

| Package              | Contract                                   | Used by            |
| -------------------- | ------------------------------------------ | ------------------ |
| `apps/api_client`    | **The replacement**, 121 operations        | `trotxi_client`    |
| `apps/trotxi_client` | Shared session, transport and domain layer | Both migrated apps |

The temporary `_next` packages and the unused legacy clients have been removed.
Git retains the old implementation; no staging database or service is removed.
Never mix sessions or resource identities across backend generations.
Both `pnpm run codegen` and `pnpm run codegen:replacement` generate the canonical
SDK from the checked-in replacement specification, never the deployed legacy API.
Then run `dart run build_runner build` inside `apps/api_client`, because its
models are `built_value`. The package rename does not change secure-storage
namespaces or import old tokens.

The published contract is `docs/design/contracts/replacement.openapi.json`:
OpenAPI 3.0.3, exactly the implemented surface. The thirteen deferred operations
are absent, so an operation that exists in the client is one the server answers.

## What differs, in the order it will bite

### 1. Every request needs client metadata

The server validates `x-trotxi-client`, `x-trotxi-build` and
`x-trotxi-platform` **before** it authorizes anything. A request without them is
refused whoever sent it, so this is the first thing that breaks and it breaks
everything at once.

`TrotxiClientFactory.create` now takes it once:

```dart
TrotxiClientFactory.create(
  baseUrl: baseUrl,
  tokenStore: store,
  metadata: const ClientMetadata(app: 'commuter', build: 42, platform: 'ios'),
);
```

`app` is `commuter`, `driver`, `ops` or `worker`. A commuter or driver build
ships on a platform and must say which; `ops` has no store build and must not
send one. The build number is compared to a floor the server holds per app and
per platform, so a commuter release being too old says nothing about the driver
app.

### 2. Creations return 201, not 200

Ten operations changed. A client testing `statusCode == 200` reads a successful
creation as a failure:

`createDriver` · `createRoute` · `createStop` · `createVehicle` · `createTrip` ·
`createCommuteSlot` · `createCommuteRequest` · `createPurchase` · `createFare` ·
`updatePlanPricing`

`createCommuteRequest` and `createPurchase` are rider-facing.

### 3. Money is an object

`{ "amountMinor": 26400, "currency": "GHS" }`, never a bare integer. Every
price, fare, credit and refund.

### 4. Errors carry a message written to be shown

```json
{ "error": { "code": "reservation_capacity", "message": "…", "requestId": "…" } }
```

`trotxi_client` reads `error.message` rather than the HTTP status line, and
maps **426** to `UpgradeRequiredException` — an outcome the old contract had no
equivalent for.

### 5. A commute is two legs on published pattern versions

This is the one that is not a rename, and it is why the commuter app's
`submit` cannot be ported mechanically.

The old app sent physical stop ids and two times:

```dart
{ routeId, pickupStopId, dropoffStopId, morningDeparture, eveningReturn, … }
```

The replacement wants, per leg, the identities of a published version:

```dart
{ routeId, legs: [ { direction, scheduleId, patternVersionId,
                     pickupOccurrenceId, dropoffOccurrenceId } ], … }
```

An occurrence is a stop **within one published pattern version**, not a physical
stop. A single physical stop can appear twice in a loop, which is exactly why
the identity is version-scoped: without it, "the stop I board at" is ambiguous
on a route that doubles back.

The app cannot derive these from old selections. The migrated picker lets the rider
picks a schedule, reading `listRouteSchedules` (`GET /v1/routes/{id}/schedules`)
and `getPatternVersion`. This step is implemented on the commuter branch;
see its catalogue limitation and verification scope in `stage-4-progress.md`.

### 6. Reads are paged and enveloped

A list is `{ data: [...], page: { nextCursor } }`. The cursor is signed and
binds the caller, the sort and the filters, so it cannot be edited or reused
against a different query — pass it back unchanged or not at all.

## Type-for-type, for the files that reference generated models

Nine files across the two apps use models generated from the old spec. The
replacement's names are stable rather than derived from a path and status code.

| Old generated type                                        | Replacement                                                                                                                    |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `MeGet200Response`                                        | `AccountResponse` — `getAccount`, `GET /v1/me`                                                                                 |
| `MeSessionsGet200ResponseSessionsInner`                   | `Session` in `SessionPage` — `listSessions`                                                                                    |
| `RoutesGet200ResponseInner`                               | `Route` in `RoutePage` — `listRoutes`                                                                                          |
| `RoutesIdGet200ResponseStopsInner`                        | stop occurrences now come from `getPatternVersion`, not from the route                                                         |
| `MeReservationsGet200ResponseReservationsInner`           | `Reservation` in `ReservationPage` — `listReservations`                                                                        |
| `MeReservationsGet200ResponseReservationsInnerStatusEnum` | `ReservationStatusEnum`, with values `pending`, `reserved`, `declined`, `unseated`, `boarded`, `no_show`, `operator_cancelled` |
| `MeWorkRequestsGet200ResponseRequestsInner`               | `WorkRequest` in `WorkRequestPage` — `listDriverRequests`                                                                      |

Commute request status is also renamed: there is no `pending`. The values are
`submitted`, `waitlisted`, `approved`, `applied`, `rejected`, `cancelled`, and a
request is open while it is one of the first three.

## What has not changed

`GET /`, `/healthz`, `/readyz`, `/version`, `/flags` and `POST /webhooks/paystack`
keep their paths exactly. These stable paths do not make the deployment workflow
replacement-ready: it still invokes the old API migrator. Cutover must explicitly
select the replacement database, migrator, narrow runtime role and service, then
verify the provider webhook points at that service. Do not reuse old database
credentials merely because the URL paths match.

## Completion boundary

Both apps' existing flows now use this client, including explicit departure and
stop-occurrence selection. Schedules and all trip views expose `patternId` as
well as `patternVersionId`; resolve those exact owners rather than searching
`Route.patternIds`, which is a current-time projection. Public pattern reads
allow published future/retired owners on unarchived corridors, never draft-only
patterns. A pattern's `publishedVersionId` may therefore be null.

There is no adapter and no deprecation window. App migration is implemented,
but actual replacement-server/native-provider walkthroughs and coordinated
deployment still gate cutover. New avatar selection/upload, push notification
integration and native Apple sign-in are frontend follow-ups, not regressions
from the old commuter app. See `stage-4-completion.md` for the scoped handoff.
