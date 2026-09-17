-- Additive extension of the same atomic command/receipt boundary. No deployed
-- schema or previously applied replacement migration is edited.
ALTER TABLE app.transport_commands DROP CONSTRAINT transport_commands_operation_check;
ALTER TABLE app.transport_commands ADD CONSTRAINT transport_commands_operation_check CHECK
  (operation IN ('createSchedule','createTrip','assignTrip','rescheduleTrip','cancelTrip',
   'startTrip','completeTrip','recordArrival','createRoute','updateRoute','createStop',
   'updateStop','createPattern','createPatternVersion','publishPatternVersion'));

CREATE TABLE app.catalog_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  command_id uuid NOT NULL UNIQUE,
  route_id uuid REFERENCES app.routes(id) ON DELETE RESTRICT,
  stop_id uuid REFERENCES app.stops(id) ON DELETE RESTRICT,
  pattern_id uuid REFERENCES app.route_patterns(id) ON DELETE RESTRICT,
  pattern_version_id uuid REFERENCES app.route_pattern_versions(id) ON DELETE RESTRICT,
  operation text NOT NULL CHECK (operation IN ('createRoute','updateRoute','createStop',
    'updateStop','createPattern','createPatternVersion','publishPatternVersion')),
  before_state jsonb NOT NULL,
  after_state jsonb NOT NULL,
  reason text,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  CHECK (num_nonnulls(route_id,stop_id,pattern_id,pattern_version_id)=1),
  CHECK ((operation IN ('createRoute','updateRoute') AND route_id IS NOT NULL)
    OR (operation IN ('createStop','updateStop') AND stop_id IS NOT NULL)
    OR (operation='createPattern' AND pattern_id IS NOT NULL)
    OR (operation IN ('createPatternVersion','publishPatternVersion') AND pattern_version_id IS NOT NULL)),
  FOREIGN KEY (command_id,actor_user_id) REFERENCES app.transport_commands(id,actor_user_id)
    ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED
);
CREATE TRIGGER catalog_events_append_only BEFORE UPDATE OR DELETE ON app.catalog_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
COMMENT ON TABLE app.catalog_events IS 'Receipt-backed catalog command history; publication records prior/current effective intervals together. Not a claim that arbitrary owner SQL is audited.';

CREATE INDEX routes_catalog_page ON app.routes(created_at DESC,id DESC);
CREATE INDEX stops_catalog_page ON app.stops(created_at DESC,id DESC);
CREATE INDEX patterns_catalog_page ON app.route_patterns(created_at DESC,id DESC);
CREATE INDEX versions_catalog_page ON app.route_pattern_versions(pattern_id,created_at DESC,id DESC);
CREATE INDEX schedules_catalog_page ON app.service_schedules(created_at DESC,id DESC);
