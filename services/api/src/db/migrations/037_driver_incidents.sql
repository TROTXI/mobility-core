-- 037_driver_incidents: what a driver reports from the roadside (#226).
--
-- The design's "Incident & support" screen attaches the trip, the vehicle, the
-- time and the current or last-known location to every report, and tells the
-- driver so in as many words. All four are stored here because the screen
-- promises them.
--
-- What is NOT here: emergency. The file draws EMERGENCY HELP as a filled danger
-- control standing alone, above and apart from reporting, and the reason is
-- operational rather than visual — an emergency needs a person on a phone now,
-- not a row in a queue someone reads later. It dials the operations number from
-- GET /flags (#234). Giving it a category in this table would put a crash
-- behind the same polling loop as a broken wiper.
CREATE TABLE IF NOT EXISTS driver_incidents (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- The fleet driver, not the user. A report outlives the user account that
  -- filed it: erasure anonymises a user row, and an incident that named a
  -- collision must still be answerable to afterwards.
  driver_id    uuid NOT NULL REFERENCES drivers (id) ON DELETE CASCADE,

  -- The run it happened on, and the bus it happened in. Both nullable: a driver
  -- can report a vehicle fault in the yard before any trip starts, and refusing
  -- the report because no trip is active is exactly the wrong answer.
  trip_id      uuid REFERENCES trips (id) ON DELETE SET NULL,
  vehicle_id   uuid REFERENCES vehicles (id) ON DELETE SET NULL,

  -- The design's five categories, kept literally. They exist to route the report
  -- to whoever can act on it, so a generic severity scale would lose the only
  -- thing that makes them useful.
  category     text NOT NULL CHECK (category IN (
                 'vehicle', 'collision', 'passenger_safety', 'route_blocked', 'other'
               )),

  -- Free text from the driver. Sometimes typed one-handed at a kerb, so treat it
  -- as a hint rather than a record: the category is the routable part.
  note         text,

  -- Current or last-known position, as the screen says it attaches. Plain
  -- columns rather than the PostGIS geography `stops` uses — nothing queries
  -- these by proximity, they are read back on one report at a time.
  lat          double precision,
  lng          double precision,

  status       text NOT NULL DEFAULT 'open'
               CHECK (status IN ('open', 'acknowledged', 'resolved')),
  -- Set when ops moves it off `open`; who and what they said.
  handled_by   uuid REFERENCES users (id) ON DELETE SET NULL,
  handled_at   timestamptz,
  resolution   text,

  -- When it happened, which is not when the row arrived: a report written in a
  -- dead spot uploads when signal returns.
  occurred_at  timestamptz NOT NULL DEFAULT now(),
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- The ops queue reads open reports newest first; that is the only hot path.
CREATE INDEX IF NOT EXISTS idx_driver_incidents_open
  ON driver_incidents (created_at DESC) WHERE status = 'open';

-- A driver's own history on their support screen.
CREATE INDEX IF NOT EXISTS idx_driver_incidents_driver
  ON driver_incidents (driver_id, created_at DESC);

COMMENT ON TABLE driver_incidents IS
  'Driver-filed incident reports (#226). Emergency is deliberately not modelled here — it dials operations.';
COMMENT ON COLUMN driver_incidents.note IS
  'Free text. May name a passenger, so it is personal data that account erasure does not reach — see #226.';
COMMENT ON COLUMN driver_incidents.occurred_at IS
  'When the incident happened. A report filed in a dead spot uploads later, so this is not created_at.';
