-- 024_route_geometry: give a route a shape (#179).
--
-- A route has been an ordered list of stops and nothing between them. eta.ts is
-- explicit about the consequence in its own header: it treats the stops as the
-- polyline and assumes a flat ASSUMED_SPEED_KPH = 20. The model believes our
-- buses travel in straight lines at constant speed.
--
-- Three things need the real road-following path: the line on the rider's live
-- map, "STOP 3 of 11 · Shiashie next" on the driver screen, and honest per-stop
-- ETAs (straight-line distance under-reads every curve).
--
-- The geometry is DERIVED FROM OUR OWN GPS TRACES, not from a routing vendor.
-- trip_positions is append-only at a fix every 5s, so one completed run is a
-- dense record of where the bus actually went — including the informal stops and
-- the shortcut a driver takes that no map database knows about. See
-- strategy/docs/geospatial.md §4.

ALTER TABLE routes
  ADD COLUMN IF NOT EXISTS geometry            geography(LineString, 4326),
  ADD COLUMN IF NOT EXISTS geometry_source     text,
  ADD COLUMN IF NOT EXISTS geometry_updated_at timestamptz,
  ADD COLUMN IF NOT EXISTS geometry_run_count  integer NOT NULL DEFAULT 0;

-- Nullable on purpose: a route exists before its first run. Every consumer must
-- fall back to the stop-to-stop polyline while this is null — the map is
-- angular and the ETA approximate, but nothing breaks.
COMMENT ON COLUMN routes.geometry IS
  'Road-following path derived from completed trips'' GPS traces. NULL until the first run; consumers fall back to the stop polyline.';
COMMENT ON COLUMN routes.geometry_source IS
  'traces = raw GPS median, matched = map-matched via Valhalla, manual = drawn by ops. Earns its place the first time someone asks why a route looks wrong.';
COMMENT ON COLUMN routes.geometry_run_count IS
  'How many completed runs the geometry was derived from. First run is used immediately; the median of the last five supersedes it.';

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_routes_geometry_source') THEN
    ALTER TABLE routes
      ADD CONSTRAINT chk_routes_geometry_source
      CHECK (geometry_source IS NULL OR geometry_source IN ('traces', 'matched', 'manual'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_routes_geometry ON routes USING GIST (geometry);

-- Distance along the route to each stop, so "3 of 11 stops" and per-stop ETA
-- stop being recomputed from scratch on every request. Filled by the same job
-- that writes routes.geometry; null while the route has no geometry.
ALTER TABLE route_stops
  ADD COLUMN IF NOT EXISTS distance_m double precision;

COMMENT ON COLUMN route_stops.distance_m IS
  'Metres along routes.geometry to this stop. NULL until the route has geometry.';
