-- 016_trip_positions: live GPS fixes reported by the assigned driver of a trip
-- (#25, system-design §7). Append-only — one row per reported fix — so the HTTP
-- pilot keeps a history for free and the deferred MQTT/Go/WS telemetry path
-- (ADR-0006) can replay it later. The "latest position" a rider reads is the most
-- recent row for the trip; Redis caches that latest fix when available.
--
-- location mirrors stops: geography(Point, 4326), lat/lng via ST_MakePoint
-- (lng, lat) / ST_X / ST_Y at the adapter boundary. ON DELETE CASCADE so a trip's
-- fixes die with the trip.

CREATE TABLE IF NOT EXISTS trip_positions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id     uuid NOT NULL REFERENCES trips (id) ON DELETE CASCADE,
  location    geography(Point, 4326) NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now()
);
-- Backs "latest fix for a trip": ORDER BY recorded_at DESC LIMIT 1 within a trip.
CREATE INDEX IF NOT EXISTS idx_trip_positions_trip_recorded
  ON trip_positions (trip_id, recorded_at DESC);
