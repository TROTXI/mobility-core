-- Driver GPS, the live projection riders read, learned speeds and trace
-- retention. Additive; 001-013 stay byte-identical.
--
-- Two clocks, deliberately separate. captured_at is the driver device's own
-- word and is preserved exactly. effective_captured_at is that value clamped to
-- what the server will believe, and it alone orders fixes and decides freshness.
-- received_at is the server's, and retention is measured from it so a wrong
-- device clock can neither extend nor shorten how long a trace is kept.
--
-- A trace is deleted when it expires, not hidden. The retention promise lives
-- here rather than in a service constant, because the guard that refuses an
-- early delete and the sweep that performs it have to agree on one number.

-- Learning carries (trip, pattern version) together, the same way schedules
-- already do, so a run cannot be attributed to a version it never ran.
ALTER TABLE app.trips ADD CONSTRAINT trips_pattern_version_identity
  UNIQUE (id, pattern_version_id);

CREATE FUNCTION app.trace_retention_days() RETURNS integer
  LANGUAGE sql IMMUTABLE PARALLEL SAFE AS $$ SELECT 30 $$;
COMMENT ON FUNCTION app.trace_retention_days() IS
  'How long a raw driver trace is kept. A promise to drivers, not a tuning knob: only an active trace hold extends it, and only over the receipt interval that hold names.';

CREATE TABLE app.trip_positions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL REFERENCES app.trips(id) ON DELETE RESTRICT,
  -- Required, not nullable: the replacement has no legacy fixes to accommodate,
  -- so every fix carries the identity that makes an offline replay idempotent.
  client_fix_id uuid NOT NULL,
  captured_at timestamptz NOT NULL CHECK (isfinite(captured_at)),
  effective_captured_at timestamptz NOT NULL CHECK (isfinite(effective_captured_at)),
  received_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  clock_adjusted boolean NOT NULL DEFAULT false,
  -- Reported horizontal accuracy. Learning discards fixes too coarse to
  -- place on a road; the live marker still shows them.
  accuracy_meters double precision CHECK (accuracy_meters IS NULL OR
    (accuracy_meters >= 0 AND accuracy_meters < 'Infinity'::float8)),
  location geometry(Point, 4326) NOT NULL,
  -- Canonical digest of the immutable payload, so a replayed client_fix_id can
  -- be told apart from a different fix wearing the same identity.
  payload_digest text NOT NULL CHECK (payload_digest ~ '^[a-f0-9]{64}$'),
  CHECK (ST_X(location) BETWEEN -180 AND 180 AND ST_Y(location) BETWEEN -90 AND 90),
  -- The server never believes a capture from the future, so clamping only ever
  -- pulls one back.
  CHECK (effective_captured_at <= captured_at OR NOT clock_adjusted),
  CHECK (clock_adjusted = (effective_captured_at <> captured_at)),
  UNIQUE (trip_id, client_fix_id)
);
CREATE INDEX trip_positions_trace
  ON app.trip_positions (trip_id, effective_captured_at, received_at, id);
-- A fix is written once and never revised. Without this the runtime role could
-- move received_at, which is the value both the retention deadline and a hold's
-- receipt interval are measured against: backdate, then delete on time.
CREATE TRIGGER immutable_trace BEFORE UPDATE ON app.trip_positions
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
-- Retention sweeps by server receipt, so this is the index the purge walks.
CREATE INDEX trip_positions_retention ON app.trip_positions (received_at, id);
COMMENT ON COLUMN app.trip_positions.captured_at IS
  'The driver device''s own clock, preserved as reported and never used for ordering or retention.';
COMMENT ON COLUMN app.trip_positions.effective_captured_at IS
  'Capture time clamped to the server clock. Orders fixes and decides freshness.';
COMMENT ON COLUMN app.trip_positions.received_at IS
  'Server receipt. Retention is measured from this so a wrong device clock cannot extend it.';

-- One row per trip, advanced only by a strictly newer effective capture. A
-- delayed upload therefore cannot drag the rider's marker backwards.
CREATE TABLE app.trip_live_positions (
  trip_id uuid PRIMARY KEY REFERENCES app.trips(id) ON DELETE RESTRICT,
  position_id uuid NOT NULL REFERENCES app.trip_positions(id) ON DELETE RESTRICT,
  effective_captured_at timestamptz NOT NULL,
  received_at timestamptz NOT NULL,
  location geometry(Point, 4326) NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE FUNCTION app.guard_live_position() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.effective_captured_at <= OLD.effective_captured_at THEN
    RAISE EXCEPTION 'live_position_must_advance' USING ERRCODE = '23514';
  END IF;
  -- The projection carries no facts of its own. Every value it shows is the
  -- fix's, so it cannot be used to restate a receipt the trace table refuses
  -- to change.
  IF NOT EXISTS (SELECT 1 FROM app.trip_positions p
    WHERE p.id = NEW.position_id AND p.trip_id = NEW.trip_id
      AND p.effective_captured_at = NEW.effective_captured_at
      AND p.received_at = NEW.received_at
      AND ST_OrderingEquals(p.location, NEW.location)) THEN
    RAISE EXCEPTION 'live_position_must_match_fix' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER live_position_advances BEFORE INSERT OR UPDATE ON app.trip_live_positions
  FOR EACH ROW EXECUTE FUNCTION app.guard_live_position();
COMMENT ON TABLE app.trip_live_positions IS
  'Durable latest-fix projection. Redis mirrors this and is rebuildable from it; the database is the source of truth.';

-- Observed speed per segment of one published pattern version and service
-- window. Keyed to the version so a republished route never inherits speeds
-- learned on a different stop order.
CREATE TABLE app.segment_speeds (
  pattern_version_id uuid NOT NULL REFERENCES app.route_pattern_versions(id) ON DELETE RESTRICT,
  service_window text NOT NULL CHECK (service_window IN ('morning', 'evening')),
  from_ordinal integer NOT NULL CHECK (from_ordinal BETWEEN 0 AND 498),
  metres_per_second double precision NOT NULL
    CHECK (metres_per_second > 0 AND metres_per_second <= 40),
  sample_count integer NOT NULL CHECK (sample_count > 0),
  geometry_id uuid NOT NULL,
  computed_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  PRIMARY KEY (pattern_version_id, service_window, from_ordinal),
  FOREIGN KEY (geometry_id, pattern_version_id)
    REFERENCES app.route_geometries(id, pattern_version_id) ON DELETE RESTRICT
);
COMMENT ON TABLE app.segment_speeds IS
  'from_ordinal is a route_pattern_stops.ordinal, zero-based, naming the segment that starts at that occurrence. Never an array index.';

-- A trip is folded into the learned speeds exactly once. The marker is written
-- even when the run taught us nothing, so the sweep drains instead of
-- reconsidering the same barren trips on every pass. It records that a run was
-- processed, and nothing about where the bus was or how it drove.
CREATE TABLE app.trip_learning (
  trip_id uuid PRIMARY KEY REFERENCES app.trips(id) ON DELETE RESTRICT,
  pattern_version_id uuid NOT NULL,
  geometry_id uuid NOT NULL,
  service_window text NOT NULL CHECK (service_window IN ('morning', 'evening')),
  segments_learned integer NOT NULL CHECK (segments_learned >= 0),
  learned_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  FOREIGN KEY (trip_id, pattern_version_id)
    REFERENCES app.trips(id, pattern_version_id) ON DELETE RESTRICT,
  FOREIGN KEY (geometry_id, pattern_version_id)
    REFERENCES app.route_geometries(id, pattern_version_id) ON DELETE RESTRICT
);
CREATE TRIGGER trip_learning_append_only BEFORE UPDATE OR DELETE ON app.trip_learning
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

-- Observed segment speeds, kept so segment_speeds can be recomputed rather
-- than accumulated. Deliberately not linked to a trip or a driver, and dated
-- to the day rather than the run: these outlive the trace they came from, so
-- they must not be a way to reconstruct who drove where and when.
CREATE TABLE app.segment_samples (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pattern_version_id uuid NOT NULL REFERENCES app.route_pattern_versions(id) ON DELETE RESTRICT,
  service_window text NOT NULL CHECK (service_window IN ('morning', 'evening')),
  from_ordinal integer NOT NULL CHECK (from_ordinal BETWEEN 0 AND 498),
  metres_per_second double precision NOT NULL
    CHECK (metres_per_second > 0 AND metres_per_second <= 40),
  observed_on date NOT NULL CHECK (isfinite(observed_on))
);
CREATE INDEX segment_samples_recent
  ON app.segment_samples (pattern_version_id, service_window, from_ordinal, observed_on DESC, id DESC);
CREATE TRIGGER segment_samples_append_only BEFORE UPDATE OR DELETE ON app.segment_samples
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

CREATE TABLE app.trace_holds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id uuid NOT NULL REFERENCES app.driver_incidents(id) ON DELETE RESTRICT,
  trip_id uuid NOT NULL REFERENCES app.trips(id) ON DELETE RESTRICT,
  -- A bounded receipt window: a hold retains the traces it needs, never a
  -- driver's whole history.
  received_from timestamptz NOT NULL CHECK (isfinite(received_from)),
  received_to timestamptz NOT NULL CHECK (isfinite(received_to)),
  reason text NOT NULL CHECK (length(btrim(reason)) BETWEEN 1 AND 2000),
  review_at timestamptz NOT NULL CHECK (isfinite(review_at)),
  state text NOT NULL DEFAULT 'active' CHECK (state IN ('active', 'released')),
  created_by uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  released_by uuid REFERENCES app.users(id) ON DELETE RESTRICT,
  release_reason text CHECK (release_reason IS NULL OR length(btrim(release_reason)) BETWEEN 1 AND 2000),
  released_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  CHECK (received_to > received_from),
  CONSTRAINT trace_hold_release_is_attributable CHECK (
    (state = 'active' AND released_by IS NULL AND released_at IS NULL AND release_reason IS NULL)
    OR (state = 'released' AND released_by IS NOT NULL AND released_at IS NOT NULL
        AND release_reason IS NOT NULL))
);
CREATE INDEX trace_holds_active ON app.trace_holds (trip_id, received_from, received_to)
  WHERE state = 'active';
CREATE INDEX trace_holds_queue ON app.trace_holds (created_at DESC, id DESC);
COMMENT ON TABLE app.trace_holds IS
  'Retains specific incident evidence past the default window. Bounded to one trip and one receipt interval, with an accountable owner, reason and review date. Releasing one does not itself delete anything; the next purge collects whatever is now past its deadline.';

-- Deletion is allowed only where it is owed: past the retention deadline and
-- outside every active hold. Invoker rights, so a runtime role granted DELETE
-- on these two tables still cannot destroy a trace early or destroy evidence
-- someone is holding, and no owner-rights writer is reachable from runtime.
CREATE FUNCTION app.guard_trace_deletion() RETURNS trigger
LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog AS $$
BEGIN
  IF OLD.received_at >= clock_timestamp()
    - make_interval(days => app.trace_retention_days()) THEN
    RAISE EXCEPTION 'trace_not_expired' USING ERRCODE = '23514';
  END IF;
  IF EXISTS (SELECT 1 FROM app.trace_holds h
    WHERE h.trip_id = OLD.trip_id AND h.state = 'active'
      AND OLD.received_at >= h.received_from AND OLD.received_at < h.received_to) THEN
    RAISE EXCEPTION 'trace_under_hold' USING ERRCODE = '23514';
  END IF;
  RETURN OLD;
END $$;
CREATE TRIGGER expired_traces_only BEFORE DELETE ON app.trip_positions
  FOR EACH ROW EXECUTE FUNCTION app.guard_trace_deletion();
CREATE TRIGGER expired_traces_only BEFORE DELETE ON app.trip_live_positions
  FOR EACH ROW EXECUTE FUNCTION app.guard_trace_deletion();
COMMENT ON FUNCTION app.guard_trace_deletion() IS
  'The only tables a runtime role may delete from are the two carrying this trigger, and only for rows past app.trace_retention_days() that no active hold names. grantRuntime reads the trigger to decide where DELETE is granted.';

CREATE TABLE app.gps_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  command_id uuid NOT NULL UNIQUE,
  hold_id uuid NOT NULL REFERENCES app.trace_holds(id) ON DELETE RESTRICT,
  operation text NOT NULL CHECK (operation IN ('createTraceHold', 'releaseTraceHold')),
  before_state jsonb NOT NULL,
  after_state jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  FOREIGN KEY (command_id, actor_user_id) REFERENCES app.transport_commands(id, actor_user_id)
    ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED
);
CREATE TRIGGER gps_events_append_only BEFORE UPDATE OR DELETE ON app.gps_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();

ALTER TABLE app.transport_commands DROP CONSTRAINT transport_commands_operation_check;
ALTER TABLE app.transport_commands ADD CONSTRAINT transport_commands_operation_check CHECK
  (operation IN ('createSchedule','createTrip','assignTrip','rescheduleTrip','cancelTrip',
   'startTrip','completeTrip','recordArrival','createRoute','updateRoute','createStop',
   'updateStop','createPattern','createPatternVersion','publishPatternVersion',
   'createVehicle','updateVehicle','reportIncident','decideIncident',
   'createDriverRequest','withdrawDriverRequest','decideDriverRequest',
   'recordPosition','createTraceHold','releaseTraceHold',
   'runRouteLearning','runGpsRetention'));
