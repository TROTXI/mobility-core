-- #204: record where a rider actually boards and alights.
--
-- Until now a rider was pinned to a route and nothing finer. GET
-- /trips/:id/position returns an ETA to every stop on that route, and the
-- client had no way to know which one was theirs, so "your van is 6 minutes
-- from Adenta" could not be built at all.
--
-- Nullable throughout. Riders who subscribed before this have no stops, and
-- the endpoints fall back to route-level behaviour rather than failing.

ALTER TABLE subscriptions
  ADD COLUMN IF NOT EXISTS pickup_stop_id  uuid REFERENCES stops (id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS dropoff_stop_id uuid REFERENCES stops (id) ON DELETE SET NULL;

-- Frozen on the payment at checkout for the same reason as the #103 price
-- snapshot: minutes pass before charge.success, and the subscription should be
-- activated with exactly what the rider chose and paid against.
ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS pickup_stop_id  uuid,
  ADD COLUMN IF NOT EXISTS dropoff_stop_id uuid;

-- Copied onto each reservation so a travel day keeps the stops that were in
-- force when it was seeded. A rider who edits their subscription mid-month
-- does not retroactively change where yesterday's van was supposed to meet
-- them, which matters when a no-show is disputed.
ALTER TABLE reservations
  ADD COLUMN IF NOT EXISTS pickup_stop_id  uuid REFERENCES stops (id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS dropoff_stop_id uuid REFERENCES stops (id) ON DELETE SET NULL;

COMMENT ON COLUMN subscriptions.pickup_stop_id IS
  'Where this rider boards. NULL for subscriptions created before #204.';
COMMENT ON COLUMN reservations.pickup_stop_id IS
  'Frozen from the subscription when the reservation was seeded (#204).';
