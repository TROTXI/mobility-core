-- 025_segment_speeds: what our buses actually do, per stretch of road (#181).
--
-- eta.ts divides remaining distance by a flat ASSUMED_SPEED_KPH = 20. That is
-- wrong exactly where it matters most: Tetteh Quarshie at 07:30 is not 20 km/h,
-- and neither is an empty road at 20:00.
--
-- Every completed run leaves a timestamped trace in trip_positions, so the real
-- answer is already in our own data. This table is the aggregate: how long each
-- stretch between consecutive stops actually takes, by direction and by time of
-- day. Recomputing medians per request would be the slowest thing in the ETA
-- path, so it is materialised here and refreshed by a job.
--
-- TWO time bands, not four or twenty-four: the service only runs a morning and
-- an evening window, so anything finer would be modelling hours we do not
-- operate.
--
-- This is the part a competitor cannot buy. A traffic API models a generic
-- vehicle on a generic road; this measures our vehicles, on our corridors, at
-- the exact times we run them.

CREATE TABLE IF NOT EXISTS segment_speeds (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id       uuid NOT NULL REFERENCES routes (id) ON DELETE CASCADE,
  -- Segment between route_stops.seq = from_seq and from_seq + 1.
  from_seq       integer NOT NULL,
  direction      text NOT NULL CHECK (direction IN ('morning', 'evening')),
  -- Median, not mean: one breakdown should not redefine the corridor.
  median_speed_ms double precision NOT NULL CHECK (median_speed_ms > 0),
  -- Sample size, so consumers can refuse to trust a single observation.
  sample_count   integer NOT NULL CHECK (sample_count > 0),
  computed_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (route_id, from_seq, direction)
);

CREATE INDEX IF NOT EXISTS idx_segment_speeds_route
  ON segment_speeds (route_id, direction);

COMMENT ON TABLE segment_speeds IS
  'Observed median speed per route segment, direction and service window. Refreshed from completed runs; ETA falls back to the fixed assumed speed where absent.';
