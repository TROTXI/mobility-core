# Mobility

## Overview

Routes, stops and trips: the operational skeleton everything else hangs off.

A **route** is a corridor, like Adenta to Airport City. A **stop** is a physical
place a van can pull in. A **route** has an ordered list of stops. A **trip** is
one scheduled run of a route by a vehicle and a driver on a particular day.

Subscriptions pin a rider to a route. Reservations pin them to a trip. Boarding,
ETAs and the daily ask-dispatch all key off trips.

Status: live. Browsing shipped in #57, trips in #18, the driver lifecycle in
#163, derived geometry in #179 and observed segment speeds in #181.

## Concepts

Stops are shared. Two routes crossing at Circle reference the same stop row
rather than each having their own copy, so a rider on either corridor sees one
Circle.

Order comes from `route_stops.seq`, not from the stops table. `findByRoute`
always returns them sorted, so no caller ever sorts.

Trips carry the operational truth: which vehicle, which driver, when it was
scheduled, when it actually started and finished. A trip's `status` moves
`scheduled` to `active` to `completed`, or to `cancelled`.

Route geometry is derived, not authored. We work out the path a corridor
actually follows from the GPS traces of completed runs rather than anyone
drawing it (#179), and the same traces give us per-segment observed speeds that
replace the cold-start ETA guess (#181).

## API

Browsing is public. Trips need a signed-in user, because a schedule is
app-facing data rather than a public timetable.

| Endpoint                             | Auth            | Returns                                                        |
| ------------------------------------ | --------------- | -------------------------------------------------------------- |
| `GET /routes`                        | public          | all routes                                                     |
| `GET /routes/:id`                    | public          | a route with its stops in seq order                            |
| `GET /routes/:id/geometry`           | public          | the path to draw, learned or stop fallback (#206)              |
| `GET /trips`                         | signed in       | trips, optionally filtered by `routeId`                        |
| `GET /trips/:id`                     | signed in       | a trip, its timing, and the van a rider would recognise (#205) |
| `GET /trips/:id/position`            | signed in       | latest fix, per-stop ETAs, and the caller's own stop (#204)    |
| `GET /trips/:id/summary`             | assigned driver | what the run did: boarded, missed, and by which method         |
| `GET /me/trips`                      | driver          | the runs assigned to me                                        |
| `POST /trips/:id/start`, `/complete` | assigned driver | the run lifecycle (#163)                                       |
| `POST /trips/:id/position`           | assigned driver | report a GPS fix                                               |

Writes to routes, stops, vehicles, drivers and trips are admin-only and live in
the admin module (#26).

### Two things worth knowing about the responses

`GET /trips/:id/geometry` reports a `source`. `traces` means the road-following
path derived from real runs; `stops` means we have not accumulated enough runs
yet and you are getting a straight line through the stops. Render them
differently, because only one of them follows the road.

`GET /trips/:id/position` returns `riderStop`, the caller's own pickup already
picked out of `etaToStops`. Null when they have no reservation on that trip.

## How it works

Driver-owned endpoints check the caller is the driver **assigned to this trip**,
not merely that they hold the driver role. Holding a role is not the same as
being on this run, and position reporting, the manifest and the lifecycle all
enforce the stronger check.

ETAs are pure functions with no clock and no I/O. The route's stops form a
polyline, the vehicle's latest fix is projected onto it, and remaining distance
divided by segment speed gives the ETA. Speeds are the observed medians where
we have them and a cold-start constant everywhere else, so a corridor produces
an ETA on its first day and gets better as it runs.

Latest fixes are cached in KV with the durable store behind, so rider polling
does not hit Postgres for a row that changes every five seconds.

## Configuration

Nothing specific. The repositories are Postgres in production and in-memory in
dev and tests; the routes 503 when a store they need is unwired, which is how
the app boots cleanly without the full stack.

## Security

Browsing routes and stops is public on purpose: it is a bus network.

Trips require auth, and anything that writes to a trip requires being the
assigned driver. That check is the seam that stops one driver reporting
positions on another's run or reading their manifest.

The rider-facing trip view returns a deliberately narrow slice of the vehicle,
`registration`, `make` and `colour`. Riders need to recognise the van at the
kerb; they do not need the fleet record.

## Local development and testing

Everything runs with zero infrastructure. The in-memory repositories mirror the
Postgres ones closely enough to catch real bugs, including the unique
constraints: `InMemoryRouteStopRepository` throws the same SQLSTATE on a
duplicate `(routeId, seq)` that Postgres does.

```bash
pnpm --filter @trotxi/api test
```

The interesting suites are `mobility.routes.test.ts`, `trips.routes.test.ts`,
`positions.routes.test.ts`, `eta.test.ts` and `route-geometry.test.ts`.

## Where the code lives

`services/api/src/modules/mobility/`. Routes, stops and the join live in
`route.repository.ts`, `stop.repository.ts` and `route-stop.repository.ts`.
Trips are `trip.repository.ts` with the lifecycle in
`trip-lifecycle.service.ts`. ETA maths is `eta.ts`, path derivation is
`route-geometry.ts`, and the learning job that drives both is
`route-learning.service.ts`.

## Related

#57 routes and stops, #18 trips, #163 driver lifecycle, #179 geometry, #181
segment speeds, #204 rider stops, #205 rider trip view, #206 geometry endpoint.
[basemap.md](basemap.md) for drawing any of this on a map,
[live-positions.md](live-positions.md) for the position payloads,
[reservations.md](reservations.md) for how riders attach to trips.
