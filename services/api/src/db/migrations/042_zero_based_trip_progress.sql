-- Route stops may start at zero. Keep the stored value as route_stops.seq,
-- never the driver's one-based display ordinal. Do not rewrite migration 036:
-- databases which already applied it need this forward-only correction.
ALTER TABLE trips DROP CONSTRAINT IF EXISTS trips_current_stop_seq_check;
ALTER TABLE trips
  ADD CONSTRAINT trips_current_stop_seq_check
  CHECK (current_stop_seq IS NULL OR current_stop_seq >= 0);
