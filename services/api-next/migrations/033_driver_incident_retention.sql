-- Incident details have a finite operational lifetime. Audit events retain only
-- category/state changes, not a second permanent copy of free text or GPS.
CREATE FUNCTION app.incident_retention_days(category text) RETURNS integer
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN category IN ('collision','passenger_safety') THEN 365 ELSE 90 END
$$;

CREATE FUNCTION app.minimal_incident_event(state jsonb) RETURNS jsonb
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN state = '{}'::jsonb THEN state ELSE jsonb_strip_nulls(jsonb_build_object(
    'id', state->'id', 'category', state->'category', 'status', state->'status',
    'version', state->'version', 'createdAt', state->'createdAt',
    'updatedAt', state->'updatedAt', 'handledAt', state->'handledAt')) END
$$;
CREATE FUNCTION app.minimal_hold_event(state jsonb) RETURNS jsonb
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE WHEN state = '{}'::jsonb THEN state ELSE jsonb_strip_nulls(jsonb_build_object(
    'id', state->'id', 'state', state->'state', 'version', state->'version')) END
$$;

-- The installer is the only principal allowed to transform pre-existing audit
-- snapshots. The new triggers then prevent any runtime rewrite or raw insert.
DROP TRIGGER fleet_events_append_only ON app.fleet_events;
UPDATE app.fleet_events SET
  before_state=app.minimal_incident_event(before_state),
  after_state=app.minimal_incident_event(after_state)
WHERE incident_id IS NOT NULL;
CREATE FUNCTION app.guard_fleet_event_privacy() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='INSERT' THEN
    IF NEW.incident_id IS NOT NULL THEN
      NEW.before_state:=app.minimal_incident_event(NEW.before_state);
      NEW.after_state:=app.minimal_incident_event(NEW.after_state);
    END IF;
    RETURN NEW;
  END IF;
  RAISE EXCEPTION 'append_only_history' USING ERRCODE='23514';
END $$;
CREATE TRIGGER fleet_events_append_only BEFORE INSERT OR UPDATE OR DELETE ON app.fleet_events
  FOR EACH ROW EXECUTE FUNCTION app.guard_fleet_event_privacy();

DROP TRIGGER gps_events_append_only ON app.gps_events;
UPDATE app.gps_events SET
  before_state=app.minimal_hold_event(before_state),
  after_state=app.minimal_hold_event(after_state);
CREATE FUNCTION app.guard_gps_event_privacy() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='INSERT' THEN
    NEW.before_state:=app.minimal_hold_event(NEW.before_state);
    NEW.after_state:=app.minimal_hold_event(NEW.after_state);
    RETURN NEW;
  END IF;
  RAISE EXCEPTION 'append_only_history' USING ERRCODE='23514';
END $$;
CREATE TRIGGER gps_events_append_only BEFORE INSERT OR UPDATE OR DELETE ON app.gps_events
  FOR EACH ROW EXECUTE FUNCTION app.guard_gps_event_privacy();

ALTER TABLE app.driver_incidents ALTER COLUMN driver_id DROP NOT NULL;
ALTER TABLE app.driver_incidents ADD COLUMN redacted_at timestamptz;
ALTER TABLE app.driver_incidents DROP CONSTRAINT incident_decision_is_attributable;
ALTER TABLE app.driver_incidents ADD CONSTRAINT incident_decision_is_attributable CHECK (
  (status='open' AND handled_by IS NULL AND handled_at IS NULL AND resolution IS NULL)
  OR (status<>'open' AND handled_at IS NOT NULL AND
    (redacted_at IS NOT NULL OR (handled_by IS NOT NULL AND resolution IS NOT NULL)))
);
ALTER TABLE app.driver_incidents ADD CONSTRAINT incident_redaction_is_complete CHECK (
  redacted_at IS NULL OR (status='resolved' AND driver_id IS NULL AND trip_id IS NULL
    AND vehicle_id IS NULL AND note IS NULL AND latitude IS NULL AND longitude IS NULL
    AND resolution IS NULL AND handled_by IS NULL)
);
CREATE INDEX driver_incidents_retention_due ON app.driver_incidents(handled_at,id)
  WHERE status='resolved' AND redacted_at IS NULL;

-- Once a hold has been released, the incident-to-trip link is no longer needed.
-- Active holds always retain the link and block incident redaction.
ALTER TABLE app.trace_holds ALTER COLUMN incident_id DROP NOT NULL;
ALTER TABLE app.trace_holds ADD CONSTRAINT active_hold_needs_incident
  CHECK (state<>'active' OR incident_id IS NOT NULL);
ALTER TABLE app.trace_holds ADD CONSTRAINT unlinked_hold_is_redacted CHECK (
  incident_id IS NOT NULL OR (state='released' AND reason='Redacted after release'
    AND release_reason='Redacted after release')
);
CREATE FUNCTION app.guard_trace_hold_privacy() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.incident_id IS NULL THEN
    RAISE EXCEPTION 'hold_already_redacted' USING ERRCODE='23514';
  END IF;
  IF NEW.incident_id IS NOT NULL AND NEW.incident_id<>OLD.incident_id THEN
    RAISE EXCEPTION 'hold_incident_immutable' USING ERRCODE='23514';
  END IF;
  IF NEW.incident_id IS NULL AND (OLD.state<>'released' OR NEW.state<>'released'
    OR NOT EXISTS (SELECT 1 FROM app.driver_incidents i
      WHERE i.id=OLD.incident_id AND i.redacted_at IS NOT NULL)
    OR NEW.version<>OLD.version+1
    OR (to_jsonb(NEW)-ARRAY['incident_id','reason','release_reason','updated_at','version'])
       IS DISTINCT FROM
       (to_jsonb(OLD)-ARRAY['incident_id','reason','release_reason','updated_at','version'])) THEN
    RAISE EXCEPTION 'invalid_hold_redaction' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER trace_hold_privacy BEFORE UPDATE ON app.trace_holds
  FOR EACH ROW EXECUTE FUNCTION app.guard_trace_hold_privacy();

CREATE FUNCTION app.guard_incident_redaction() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.redacted_at IS NOT NULL THEN
    RAISE EXCEPTION 'incident_already_redacted' USING ERRCODE='23514';
  END IF;
  IF NEW.redacted_at IS NULL THEN RETURN NEW; END IF;
  IF OLD.status<>'resolved' OR clock_timestamp()<OLD.handled_at+
      make_interval(days=>app.incident_retention_days(OLD.category))
    OR EXISTS (SELECT 1 FROM app.trace_holds h WHERE h.incident_id=OLD.id AND h.state='active')
    OR NEW.redacted_at>clock_timestamp() OR NEW.redacted_at<OLD.handled_at
    OR (to_jsonb(NEW)-ARRAY['driver_id','trip_id','vehicle_id','note','latitude','longitude',
        'resolution','handled_by','redacted_at','version','updated_at']) IS DISTINCT FROM
       (to_jsonb(OLD)-ARRAY['driver_id','trip_id','vehicle_id','note','latitude','longitude',
        'resolution','handled_by','redacted_at','version','updated_at'])
    OR NEW.version<>OLD.version+1 OR NEW.updated_at<OLD.updated_at THEN
    RAISE EXCEPTION 'invalid_incident_redaction' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER driver_incident_redaction BEFORE UPDATE ON app.driver_incidents
  FOR EACH ROW EXECUTE FUNCTION app.guard_incident_redaction();

CREATE TABLE app.incident_redactions (
  incident_id uuid PRIMARY KEY REFERENCES app.driver_incidents(id) ON DELETE RESTRICT,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  category text NOT NULL,
  redacted_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TRIGGER incident_redactions_append_only BEFORE UPDATE OR DELETE ON app.incident_redactions
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE FUNCTION app.validate_incident_redaction_event() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM app.driver_incidents i WHERE i.id=NEW.incident_id
      AND i.redacted_at IS NOT NULL AND i.category=NEW.category) THEN
    RAISE EXCEPTION 'unverified_incident_redaction' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER incident_redactions_verify BEFORE INSERT ON app.incident_redactions
  FOR EACH ROW EXECUTE FUNCTION app.validate_incident_redaction_event();
COMMENT ON TABLE app.incident_redactions IS
  'Attributable one-way incident redaction. No report text, coordinates, driver, trip or handler identity is copied here.';

-- A freshly released hold can make an old incident eligible before its own
-- seven-day replay snapshot expires. Clear that snapshot in the same redaction
-- transaction; the receipt identity, hash, actor and event remain immutable.
CREATE FUNCTION app.incident_receipt_redactable(command_id uuid) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM app.fleet_events e JOIN app.driver_incidents i ON i.id=e.incident_id
    WHERE e.command_id=$1 AND i.redacted_at IS NOT NULL
  ) OR EXISTS (
    SELECT 1 FROM app.gps_events e JOIN app.trace_holds h ON h.id=e.hold_id
      JOIN app.driver_incidents i ON i.id=h.incident_id
    WHERE e.command_id=$1 AND i.redacted_at IS NOT NULL
  )
$$;
CREATE OR REPLACE FUNCTION app.guard_receipt_payload() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE before_row jsonb; after_row jsonb; deadline timestamptz;
BEGIN
  IF TG_OP='INSERT' THEN
    IF NEW.response_body IS NULL THEN RAISE EXCEPTION 'receipt_response_required' USING ERRCODE='23514'; END IF;
    RETURN NEW;
  END IF;
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'append_only_history' USING ERRCODE='23514'; END IF;
  before_row:=to_jsonb(OLD); after_row:=to_jsonb(NEW);
  deadline:=coalesce((before_row->>'replay_expires_at')::timestamptz,OLD.created_at+interval '7 days');
  IF (clock_timestamp()<deadline AND NOT
      (TG_TABLE_NAME='transport_commands' AND app.incident_receipt_redactable(OLD.id)))
    OR NEW.response_body IS NOT NULL
    OR coalesce(after_row->>'response_headers',after_row->>'response_etag') IS NOT NULL
    OR (after_row-ARRAY['response_body','response_headers','response_etag']) IS DISTINCT FROM
       (before_row-ARRAY['response_body','response_headers','response_etag']) THEN
    RAISE EXCEPTION 'immutable_receipt_payload' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
