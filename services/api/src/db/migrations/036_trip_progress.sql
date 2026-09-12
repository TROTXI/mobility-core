-- 036_trip_progress: where a run has reached, and when its assignment last
-- moved (#230, #233).
--
-- Every trip frame in the driver design carries "Stop 3 of 11", and the Schedule
-- agenda marks a trip CHANGED. Neither was answerable: `trip_positions` records
-- raw GPS fixes with no notion of stops passed, and nothing recorded that ops
-- had touched an assignment.

-- Which stop on the route the driver has reached, as a route_stops.seq. NULL
-- means the run has not reported an arrival yet, which is the honest answer
-- before departure and after a restart.
--
-- Driver-advanced rather than derived from GPS. Deriving it would mean guessing
-- at a stop radius on a corridor where vans halt wherever a hand goes up, and
-- the guess would be wrong in exactly the places that matter — a van stuck in
-- traffic 40 metres short of a stop is not at that stop. The driver tapping
-- "arrived" is the one signal that is actually true.
ALTER TABLE trips ADD COLUMN IF NOT EXISTS current_stop_seq integer;

ALTER TABLE trips DROP CONSTRAINT IF EXISTS trips_current_stop_seq_check;
ALTER TABLE trips
  ADD CONSTRAINT trips_current_stop_seq_check
  CHECK (current_stop_seq IS NULL OR current_stop_seq >= 1);

-- When ops last changed the driver, the vehicle or the departure time. The app
-- compares it against what it last showed to mark a run CHANGED; a push goes out
-- at the same moment (#233), and this is what survives a push the phone missed.
--
-- Deliberately not `updated_at`: trips have no such column, and if they did it
-- would move on every status flip, so a run would read as "changed" merely for
-- having started.
ALTER TABLE trips ADD COLUMN IF NOT EXISTS assignment_changed_at timestamptz;

COMMENT ON COLUMN trips.current_stop_seq IS
  'route_stops.seq the driver has reported arriving at. NULL before the first arrival.';
COMMENT ON COLUMN trips.assignment_changed_at IS
  'When ops last changed driver, vehicle or departure time. Drives the CHANGED badge and the push.';
