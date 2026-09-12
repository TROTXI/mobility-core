-- 038_driver_requests: a driver asking operations for something (#232).
--
-- The rule the whole design hangs on, quoted from the file: "Submitting a
-- request never changes the active or published assignment automatically."
-- That has to hold in the schema rather than in the UI, so a request is its own
-- record with its own status and nothing in it is ever read by the assignment
-- path. Approving one is a note that ops agreed; moving the driver is still a
-- separate, deliberate PUT /admin/trips/:id/assignment.
CREATE TABLE IF NOT EXISTS driver_requests (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id     uuid NOT NULL REFERENCES drivers (id) ON DELETE CASCADE,

  kind          text NOT NULL CHECK (kind IN ('route_change', 'leave')),
  status        text NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'approved', 'declined', 'withdrawn')),

  -- route_change: the corridor asked for. Constrained below to the kinds that
  -- use it, so a leave request cannot carry a stray route.
  route_id      uuid REFERENCES routes (id) ON DELETE CASCADE,

  -- leave: the days off. route_change: when the driver wants it to take effect
  -- (from_date alone). Dates, not timestamps — nobody requests leave at 14:30.
  from_date     date,
  to_date       date,

  -- Why. For leave the design also asks who covers, which is the same free text
  -- until there is a roster to point at.
  note          text,

  decided_by    uuid REFERENCES users (id) ON DELETE SET NULL,
  decided_at    timestamptz,
  decision_note text,

  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now(),

  -- Each kind carries the fields it means and no others.
  CONSTRAINT driver_requests_shape CHECK (
    (kind = 'route_change' AND route_id IS NOT NULL) OR
    (kind = 'leave' AND route_id IS NULL AND from_date IS NOT NULL AND to_date IS NOT NULL)
  ),
  CONSTRAINT driver_requests_dates CHECK (
    from_date IS NULL OR to_date IS NULL OR to_date >= from_date
  )
);

-- The driver's own list, and the ops queue.
CREATE INDEX IF NOT EXISTS idx_driver_requests_driver
  ON driver_requests (driver_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_driver_requests_pending
  ON driver_requests (created_at DESC) WHERE status = 'pending';

-- Which corridors a driver may ask to be moved to. The design is explicit that
-- this is not every route: "routes are shown only when operations can accept
-- reassignment requests". Default false, so a new corridor is invisible until
-- ops opens it rather than collecting requests nobody intends to honour.
ALTER TABLE routes ADD COLUMN IF NOT EXISTS accepts_requests boolean NOT NULL DEFAULT false;

COMMENT ON TABLE driver_requests IS
  'Driver proposals to operations (#232). Approving one never writes trips.assigned_driver_id.';
COMMENT ON COLUMN routes.accepts_requests IS
  'Whether drivers may request reassignment to this route. Ops-controlled; default false.';
