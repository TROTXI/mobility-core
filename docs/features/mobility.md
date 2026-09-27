# Mobility and fleet operations

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Routes, shared stops, trips, fleet assignment, driver lifecycle,
stop progress, learned geometry and observed segment speeds are live.

## Domain

- Route: a service corridor.
- Stop: a reusable physical pickup/drop-off point.
- Route stop: the ordered `(routeId, stopId, seq)` relationship.
- Trip: one scheduled run with status `scheduled`, `active`, `completed` or
  `cancelled`.
- Vehicle and driver: fleet records assigned to trips by operations.

Subscriptions pin riders to routes and stops. Reservations pin riders to trips.
Boarding, live position, daily dispatch and driver work all build on those IDs.

## Public and authenticated reads

| Endpoint                   | Auth            | Purpose                                               |
| -------------------------- | --------------- | ----------------------------------------------------- |
| `GET /routes`              | public          | List routes                                           |
| `GET /routes/:id`          | public          | Route with stops in sequence                          |
| `GET /routes/:id/geometry` | public          | Learned route path or stop-polyline fallback          |
| `GET /trips`               | bearer          | List trips, optionally by `routeId`                   |
| `GET /trips/:id`           | bearer          | Trip timing, progress and rider-safe vehicle identity |
| `GET /me/trips`            | driver          | Assigned runs by day or date range                    |
| `GET /trips/:id/summary`   | assigned driver | Boarding counts, methods and run timing               |

The trip detail exposes registration, make and colour so a rider can identify
the vehicle. Capacity is included only for the assigned driver.

## Driver lifecycle

| Endpoint                   | Purpose                                              |
| -------------------------- | ---------------------------------------------------- |
| `POST /trips/:id/start`    | Start an assigned scheduled run; retry is idempotent |
| `POST /trips/:id/arrive`   | Record current stop sequence, including corrections  |
| `POST /trips/:id/complete` | Complete an active run                               |

Every operation resolves the caller's driver record and checks the trip's
assignment. Completing an unstarted trip is rejected because it would create a
timing/learning record for a run that did not occur.

## Admin fleet API

| Endpoint                                       | Purpose                                        |
| ---------------------------------------------- | ---------------------------------------------- |
| `POST /admin/routes` · `GET /admin/routes`     | Create and list routes                         |
| `PATCH /admin/routes/:id`                      | Update a route                                 |
| `POST /admin/routes/:id/stops`                 | Attach an existing stop at a sequence position |
| `POST /admin/stops` · `GET /admin/stops`       | Create and list shared stops                   |
| `PATCH /admin/stops/:id`                       | Update a stop                                  |
| `POST /admin/vehicles` · `GET /admin/vehicles` | Create and list vehicles                       |
| `PATCH /admin/vehicles/:id`                    | Update vehicle identity or capacity            |
| `POST /admin/drivers` · `GET /admin/drivers`   | Create and list fleet drivers                  |
| `PATCH /admin/drivers/:id`                     | Update a driver record                         |
| `POST /admin/trips` · `GET /admin/trips`       | Create trips and list by route, status or day  |
| `PATCH /admin/trips/:id`                       | Change schedule or status                      |
| `PUT /admin/trips/:id/assignment`              | Assign or replace a vehicle and/or driver      |
| `PATCH /admin/users/:id/role`                  | Change a user role                             |

Assignment changes are persisted before an FCM notification is sent to the
affected driver.

## Route geometry and learning

`POST /admin/learn-routes` processes completed-trip GPS traces:

1. Collect ordered fixes for qualifying completed runs.
2. Derive and store a route shape.
3. Project route stops onto the shape.
4. Aggregate median speeds per adjacent-stop segment and morning/evening window.

`GET /routes/:id/geometry` returns `source: traces` when learned data exists and
`source: stops` for the cold-start straight-line fallback. Clients should make
that distinction visible rather than implying the fallback follows roads.

## Current limitations

- Trip direction is inferred from scheduled UTC time rather than stored.
- Stop progress is driver-reported, not geofence-derived.
- Route learning is manually triggered while the paid Render cron is disabled.
- The future telemetry service may improve trace filtering and ETA freshness,
  but it does not change these public contracts.

## Code

- `services/api/src/modules/mobility/`
- `services/api/src/modules/admin/`
- migrations `014`, `015`, `016_trip_positions`, `023`–`025`, `028`, `032` and `036`
