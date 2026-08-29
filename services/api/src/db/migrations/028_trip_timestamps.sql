-- 028_trip_timestamps: when a run actually started and finished (#163).
--
-- trips has scheduled_at — when it was MEANT to leave — and nothing recording
-- when it did. The driver's end-of-run screen shows "48 minutes · 11 stops",
-- which needs both ends, and route learning (#179) needs to know a trip really
-- ran rather than merely being marked completed.
--
-- Both nullable: a scheduled trip has neither, an active one has only a start.
-- The gap between scheduled_at and started_at is also the only place lateness
-- can ever be measured from.

ALTER TABLE trips
  ADD COLUMN IF NOT EXISTS started_at   timestamptz,
  ADD COLUMN IF NOT EXISTS completed_at timestamptz;

COMMENT ON COLUMN trips.started_at IS
  'When the assigned driver started the run. NULL while scheduled. Lateness = started_at - scheduled_at.';
COMMENT ON COLUMN trips.completed_at IS
  'When the assigned driver ended the run. NULL until completed.';
