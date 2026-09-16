# Stage 4: moving an app to the replacement contract

For whoever owns an app. The driver now uses the replacement on the Stage 4
branch; the commuter still targets the deployed API. This describes the shared
contract changes, not a deployment or permission to mix backend generations.
See `stage-4-progress.md` for implementation and verification status.

## What exists now

| Package                   | Contract                                 | Used by              |
| ------------------------- | ---------------------------------------- | -------------------- |
| `apps/api_client`         | The deployed API, generated from staging | `trotxi_client`      |
| `apps/trotxi_client`      | Hand-written layer over it               | `trotxi_commuter`    |
| `apps/api_client_next`    | **The replacement**, 119 operations      | `trotxi_client_next` |
| `apps/trotxi_client_next` | Hand-written layer over that             | `trotxi_driver`     |

The `_next` pair temporarily separates the migrated driver from the not-yet-
migrated commuter. Move each app as a coherent build: never mix sessions or
resource identities across contracts while moving screens. Remove the unused
legacy pair and settle canonical names once both apps have moved. Regenerate with
`pnpm run codegen:replacement`, then `dart run build_runner build` inside the
package, because the generated models are `built_value`.

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

`trotxi_client_next` reads `error.message` rather than the HTTP status line, and
maps **426** to `UpgradeRequiredException` — an outcome the old contract had no
equivalent for.

### 5. A commute is two legs on published pattern versions

This is the one that is not a rename, and it is why the commuter app's
`submit` cannot be ported mechanically.

Today the app sends physical stop ids and two times:

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

The app cannot derive these from what it holds. It needs a step where the rider
picks a schedule, reading `listRouteSchedules` (`GET /v1/routes/{id}/schedules`)
and `getPatternVersion`. That step is new work, not a port.

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

## Sequence that works

1. Migrate in an isolated replacement app build using `trotxi_client_next` and
   `ClientMetadata`. Do not mix old and replacement identities/data within one
   signed-in session while moving screens.
2. Move its reads. They are renames plus the page envelope.
3. Move its creations, checking for 201 and reading `error.message`.
4. Leave the commute request until the schedule-selection step exists.

There is no adapter and no deprecation window on the server side, but there is
no rush on the client side either: the replacement is not deployed, and the two
client packages coexist until an app has finished moving.
