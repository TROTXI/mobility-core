-- 045_capture_timestamped_trip_positions: distinguish when a driver captured a
-- GPS fix from when the API received it, and make offline replay idempotent.
--
-- Existing rows already carry their server receipt time in recorded_at. For
-- those rows capture and receipt are necessarily the same. New clients may
-- supply a stable UUID so retrying a queued fix cannot append it twice.

ALTER TABLE trip_positions
  ADD COLUMN IF NOT EXISTS received_at timestamptz;

UPDATE trip_positions
   SET received_at = recorded_at
 WHERE received_at IS NULL;

ALTER TABLE trip_positions
  ALTER COLUMN received_at SET DEFAULT now(),
  ALTER COLUMN received_at SET NOT NULL;

ALTER TABLE trip_positions
  ADD COLUMN IF NOT EXISTS client_fix_id uuid;

CREATE UNIQUE INDEX IF NOT EXISTS idx_trip_positions_trip_client_fix
  ON trip_positions (trip_id, client_fix_id);

COMMENT ON COLUMN trip_positions.recorded_at IS
  'When the driver device captured the fix; server receipt time for legacy rows.';
COMMENT ON COLUMN trip_positions.received_at IS
  'When the API received the fix.';
COMMENT ON COLUMN trip_positions.client_fix_id IS
  'Client-generated idempotency key, unique within a trip; NULL for legacy fixes.';
