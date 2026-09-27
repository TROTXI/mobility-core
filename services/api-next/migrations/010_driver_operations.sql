-- Driver operations: fleet identification, roadside incident reports and
-- driver work requests. Additive to the unlaunched replacement; 001-009 stay
-- byte-identical. Ported from services/api 037/038 at 43cdae0 with the
-- replacement's conventions: app schema, RESTRICT deletes, row versions for
-- edit tokens, and receipt-backed append-only audit.
--
-- The rule the request design hangs on, carried over verbatim in intent:
-- submitting or approving a request never writes trips.assigned_driver_id.
-- Moving a driver stays a separate, deliberate assignment command.

-- A plate is a real-world identifier with no sound placeholder, so refuse a
-- populated experimental fleet rather than invent one (002 set this precedent).
LOCK TABLE app.vehicles IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM app.vehicles) THEN
    RAISE EXCEPTION 'vehicle_plate_requires_empty_fleet' USING ERRCODE = '23514';
  END IF;
END $$;

ALTER TABLE app.vehicles
  ADD COLUMN plate text NOT NULL
    CHECK (plate = btrim(plate) AND length(plate) BETWEEN 1 AND 32),
  ADD COLUMN make text
    CHECK (make IS NULL OR (make = btrim(make) AND length(make) BETWEEN 1 AND 200)),
  ADD COLUMN colour text
    CHECK (colour IS NULL OR (colour = btrim(colour) AND length(colour) BETWEEN 1 AND 200));
ALTER TABLE app.vehicles ALTER COLUMN label DROP NOT NULL;
ALTER TABLE app.vehicles DROP CONSTRAINT vehicles_label_check;
ALTER TABLE app.vehicles ADD CONSTRAINT vehicles_label_check
  CHECK (label IS NULL OR (label = btrim(label) AND length(label) BETWEEN 1 AND 200));

-- Ghana plates are reassigned when a vehicle leaves the register, so uniqueness
-- covers the operating fleet only. Archived rows keep their plate for history.
CREATE UNIQUE INDEX vehicles_live_plate ON app.vehicles (plate) WHERE archived_at IS NULL;
CREATE INDEX vehicles_catalog_page ON app.vehicles (created_at DESC, id DESC);
COMMENT ON COLUMN app.vehicles.plate IS
  'Registration plate, trimmed and upper-cased by the command layer before storage. Unique across the operating fleet only.';

CREATE TABLE app.driver_incidents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- The fleet driver, not the user: a report outlives the account that filed it.
  driver_id uuid NOT NULL REFERENCES app.drivers(id) ON DELETE RESTRICT,
  -- Both nullable. A driver reports a fault in the yard before any trip starts,
  -- and refusing the report because no run is active is the wrong answer.
  trip_id uuid REFERENCES app.trips(id) ON DELETE RESTRICT,
  vehicle_id uuid REFERENCES app.vehicles(id) ON DELETE RESTRICT,
  category text NOT NULL CHECK (category IN
    ('vehicle', 'collision', 'passenger_safety', 'route_blocked', 'other')),
  note text CHECK (note IS NULL OR length(note) BETWEEN 1 AND 2000),
  latitude double precision CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
  longitude double precision CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
  status text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open', 'acknowledged', 'resolved')),
  resolution text CHECK (resolution IS NULL OR length(resolution) BETWEEN 1 AND 2000),
  handled_by uuid REFERENCES app.users(id) ON DELETE RESTRICT,
  handled_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  -- A position is a pair or it is absent; one coordinate alone locates nothing.
  CONSTRAINT incident_position_is_whole
    CHECK (num_nonnulls(latitude, longitude) IN (0, 2)),
  -- Ops decisions carry their actor and resolution together.
  CONSTRAINT incident_decision_is_attributable
    CHECK ((status = 'open' AND handled_by IS NULL AND handled_at IS NULL AND resolution IS NULL)
      OR (status <> 'open' AND handled_by IS NOT NULL AND handled_at IS NOT NULL
          AND resolution IS NOT NULL))
);
CREATE INDEX driver_incidents_driver_page ON app.driver_incidents (driver_id, created_at DESC, id DESC);
CREATE INDEX driver_incidents_queue ON app.driver_incidents (created_at DESC, id DESC) WHERE status = 'open';
COMMENT ON TABLE app.driver_incidents IS
  'Roadside and yard reports. Emergency help is deliberately not a category here: it dials the operations number from bootstrap config rather than entering a queue somebody reads later.';

CREATE TABLE app.driver_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id uuid NOT NULL REFERENCES app.drivers(id) ON DELETE RESTRICT,
  kind text NOT NULL CHECK (kind IN ('route_change', 'leave')),
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'declined', 'withdrawn')),
  route_id uuid REFERENCES app.routes(id) ON DELETE RESTRICT,
  from_date date,
  to_date date,
  note text CHECK (note IS NULL OR length(note) BETWEEN 1 AND 2000),
  decided_by uuid REFERENCES app.users(id) ON DELETE RESTRICT,
  decided_at timestamptz,
  decision_note text CHECK (decision_note IS NULL OR length(decision_note) BETWEEN 1 AND 2000),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  -- Each kind carries the fields it means and no others.
  CONSTRAINT driver_request_shape CHECK (
    (kind = 'route_change' AND route_id IS NOT NULL AND to_date IS NULL)
    OR (kind = 'leave' AND route_id IS NULL AND from_date IS NOT NULL AND to_date IS NOT NULL)),
  CONSTRAINT driver_request_dates CHECK (to_date IS NULL OR from_date IS NULL OR to_date >= from_date),
  CONSTRAINT driver_request_decision_is_attributable CHECK (
    (status IN ('pending', 'withdrawn') AND decided_by IS NULL AND decided_at IS NULL)
    OR (status IN ('approved', 'declined') AND decided_by IS NOT NULL AND decided_at IS NOT NULL
        AND decision_note IS NOT NULL))
);
-- One open request per driver: an ops queue with three live asks from one driver
-- is a decision problem, not a feature.
CREATE UNIQUE INDEX driver_requests_one_open ON app.driver_requests (driver_id)
  WHERE status = 'pending';
CREATE INDEX driver_requests_driver_page ON app.driver_requests (driver_id, created_at DESC, id DESC);
CREATE INDEX driver_requests_queue ON app.driver_requests (created_at DESC, id DESC) WHERE status = 'pending';
COMMENT ON TABLE app.driver_requests IS
  'Driver proposals to operations. Approving one records that ops agreed; it never writes trips.assigned_driver_id or vehicle_id. Moving a driver stays a separate deliberate assignment command.';

-- These run through the same command boundary as transport and catalog, so they
-- share app.transport_commands rather than forking a second receipt table.
-- Additive ALTER: migration 004's file is not edited.
ALTER TABLE app.transport_commands DROP CONSTRAINT transport_commands_operation_check;
ALTER TABLE app.transport_commands ADD CONSTRAINT transport_commands_operation_check CHECK
  (operation IN ('createSchedule','createTrip','assignTrip','rescheduleTrip','cancelTrip',
   'startTrip','completeTrip','recordArrival','createRoute','updateRoute','createStop',
   'updateStop','createPattern','createPatternVersion','publishPatternVersion',
   'createVehicle','updateVehicle','reportIncident','decideIncident',
   'createDriverRequest','withdrawDriverRequest','decideDriverRequest'));

CREATE TABLE app.fleet_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  command_id uuid NOT NULL UNIQUE,
  vehicle_id uuid REFERENCES app.vehicles(id) ON DELETE RESTRICT,
  incident_id uuid REFERENCES app.driver_incidents(id) ON DELETE RESTRICT,
  request_id uuid REFERENCES app.driver_requests(id) ON DELETE RESTRICT,
  operation text NOT NULL CHECK (operation IN
    ('createVehicle', 'updateVehicle', 'reportIncident', 'decideIncident',
     'createDriverRequest', 'withdrawDriverRequest', 'decideDriverRequest')),
  before_state jsonb NOT NULL,
  after_state jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  CONSTRAINT fleet_event_one_subject
    CHECK (num_nonnulls(vehicle_id, incident_id, request_id) = 1),
  CONSTRAINT fleet_event_subject_matches_operation CHECK (
    (operation IN ('createVehicle', 'updateVehicle') AND vehicle_id IS NOT NULL)
    OR (operation IN ('reportIncident', 'decideIncident') AND incident_id IS NOT NULL)
    OR (operation IN ('createDriverRequest', 'withdrawDriverRequest', 'decideDriverRequest')
        AND request_id IS NOT NULL)),
  FOREIGN KEY (command_id, actor_user_id) REFERENCES app.transport_commands(id, actor_user_id)
    ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED
);
CREATE TRIGGER fleet_events_append_only BEFORE UPDATE OR DELETE ON app.fleet_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
COMMENT ON TABLE app.fleet_events IS
  'Receipt-backed fleet and driver-operations history. Incident notes and positions are the driver''s own words and location; they are not duplicated into any other audit surface.';
