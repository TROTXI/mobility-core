# Live vehicle position (HTTP pilot) + deterministic ETA

**Owner:** Foyade · **Last updated:** 2026-07-07 · **Issue:** #25

Makes trips **live**. The trip's **assigned driver** reports GPS fixes over HTTP;
riders poll the latest fix and get a **deterministic ETA** to each upcoming stop
along the route's ordered stops (system-design §7).

> **Scope shipped (HTTP pilot):** driver reporting + rider read + deterministic
> ETA + latest-fix cache. **Deferred:** the **MQTT/EMQX/Go/WS telemetry path**
> (ADR-0006) — this HTTP path exists so the product works before that lands. The
> ETA uses a **fixed assumed speed**; a live speed/traffic model comes with
> telemetry.

---

## Authorization

- **Report** (`POST`) requires the **`driver`** role **and** that the signed-in
  user is _the trip's assigned driver_. We resolve `user.id → drivers.user_id`
  (`driver.findByUserId`) and require it equals `trip.assigned_driver_id`
  (the field #26 sets). A driver role alone is **not** enough → `403`.
- **Read** (`GET`) is any signed-in user (rider) — like `GET /trips`.
- Both throttle **before** the role check (house convention, cf. boarding/admin).

## API

#### `POST /trips/:id/position`

Report a GPS fix for a trip you are assigned to.

- **Auth:** `Bearer` (driver, assigned). **Rate limit:** per user.
- **Body:** `{ "latitude": <-90..90>, "longitude": <-180..180> }`
- **200:** `{ tripId, position: { latitude, longitude, recordedAt } }`
  (`recordedAt` is server-assigned) · **400** bad coords · **401** · **403** not
  the assigned driver · **404** unknown trip · **429** · **503**

#### `GET /trips/:id/position`

The trip's latest position with an ETA to each upcoming stop.

- **Auth:** `Bearer`. **Rate limit:** per user.
- **200:** `{ tripId, position: { latitude, longitude, recordedAt }, etaToStops: [ { stopId, seq, name, distanceMeters, etaSeconds } ] }`
  · **401** · **404** unknown trip / no fix reported yet · **429** · **503**

## Deterministic ETA (`eta.ts`)

Pure functions — no clock, no I/O, no external routing service, so identical
inputs always give identical output.

1. The route's ordered stops form a polyline; cumulative distances are computed
   with **haversine**.
2. The latest fix is **projected onto the nearest segment** to get "distance
   travelled along the route" (off-route perpendicular offset is ignored).
3. For every stop still ahead: `distanceMeters = cumulative(stop) − travelled`,
   `etaSeconds = round(distanceMeters / ASSUMED_SPEED)`.

`ASSUMED_SPEED_KPH = 20` (urban trotro placeholder). Edge cases: `< 2` stops or
past the last stop → empty `etaToStops`; before the first stop → the first stop
still counts as upcoming.

## Data & cache

`trip_positions(id, trip_id → trips ON DELETE CASCADE, location geography(Point,
4326), recorded_at)` — **append-only** (one row per fix), indexed
`(trip_id, recorded_at DESC)` so "latest fix" is a cheap lookup. This durable
store is the **source of truth**; the latest fix is also **written through** to
the KV store (`trip:position:<tripId>`, TTL 300s) so rider polls hit **Redis when
available** instead of the DB. `GET` reads the cache, falling back to the store
(and warming the cache) on a miss.

## Where the code lives

```
services/api/src/modules/mobility/
  positions.routes.ts                   # POST/GET /trips/:id/position + authz + cache
  eta.ts                                # haversine + projection + computeEtas
  trip-position.repository.ts(.pg)      # record + findLatest (append-only)
  driver.repository.ts(.pg)             # + findByUserId (assigned-driver authz)
  mobility.schema.ts                    # report/response schemas
services/api/src/db/migrations/016_trip_positions.sql
```

## Deferred (with the telemetry path)

- **MQTT/EMQX → Go ingestor → WebSocket** fan-out (ADR-0006) — replaces HTTP
  polling; can replay the append-only `trip_positions` log.
- **Live speed / traffic-aware ETA** — the pilot uses a fixed assumed speed.
- **Trip-status guard** on reporting (e.g. reject `completed`/`cancelled`).
- **Retention/pruning** for `trip_positions`.

## Related

- [ADR-0006 — MQTT/EMQX/Go telemetry](../adr/0006-mqtt-emqx-go-telemetry.md) (deferred path)
- [ADR-0005 — Postgres + PostGIS](../adr/0005-postgres-postgis.md) · [ADR-0010 — KV/Redis](../adr/0010-kv-redis.md)
- Depends on trips (#18) and the driver↔trip assignment (#26).
