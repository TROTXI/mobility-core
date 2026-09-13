# Live trip positions and ETA

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Live for the pilot through authenticated HTTP reporting and polling.
The MQTT/EMQX/Go/WebSocket path remains deferred.

## API

| Endpoint                   | Auth            | Behaviour                                                               |
| -------------------------- | --------------- | ----------------------------------------------------------------------- |
| `POST /trips/:id/position` | assigned driver | Store a server-timestamped GPS fix and update the latest-position cache |
| `GET /trips/:id/position`  | bearer          | Return latest fix, upcoming-stop ETAs and the caller's pickup stop      |

Reporting requires both the driver role and assignment to the trip. Reading is
available to any authenticated user. Unknown trips and trips with no position
return `404`.

## Storage and cache

Every fix is appended to `trip_positions` as PostGIS geography. PostgreSQL is
the durable source of truth; the latest fix is written through to KV at
`trip:position:<tripId>` with a five-minute TTL. Reads use KV first, then fall
back to PostgreSQL and warm the cache.

The trace history feeds `RouteLearningService`; it is not disposable telemetry.
Retention/pruning remains to be defined.

## ETA

The position is projected onto the route path and the remaining distance to
each upcoming stop is divided by a speed:

- Learned median segment speed for the route and morning/evening window where
  sufficient history exists.
- The 20 km/h cold-start constant everywhere else.

`riderStop` is selected from `etaToStops` using the caller's reservation pickup
stop. It is `null` when the rider has no matching reservation/stop.

Driver clients report roughly every five seconds. Rider clients should poll at
roughly the same rate only while a trip is active, back off otherwise, and stop
in the background; the global authenticated rate limit is shared across routes.

## Deferred telemetry path

When pilot measurements justify it, the driver will publish MQTT QoS 1 to
EMQX, a Go processor will filter/snap positions and write the latest state to
Redis, and a WebSocket gateway will fan out updates. The existing client-facing
position contract is intended to survive that engine replacement.

Still open: offline GPS buffering in the driver app, trip-status rejection for
late reports, trace retention and traffic-aware ETA.

## Code

- `services/api/src/modules/mobility/positions.routes.ts`
- `services/api/src/modules/mobility/eta.ts`
- `services/api/src/modules/mobility/trip-position.repository.*`
- `services/api/src/modules/mobility/segment-speed.*`
- migration `016_trip_positions.sql`
