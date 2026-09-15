-- Command receipts and attributable events share the mutation transaction.
-- No committed pending receipt: a failed command leaves neither state nor key.
CREATE TABLE app.transport_commands (
  id uuid PRIMARY KEY,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  operation text NOT NULL CHECK (operation IN ('createSchedule','createTrip','assignTrip','rescheduleTrip','cancelTrip','startTrip','completeTrip','recordArrival')),
  target text NOT NULL CHECK (length(target) BETWEEN 1 AND 128),
  key_hash text NOT NULL CHECK (key_hash ~ '^[a-f0-9]{64}$'),
  input_hash text NOT NULL CHECK (input_hash ~ '^[a-f0-9]{64}$'),
  response_status smallint NOT NULL CHECK (response_status IN (200,201)),
  response_body jsonb NOT NULL,
  response_headers jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  replay_expires_at timestamptz NOT NULL,
  UNIQUE (actor_user_id,operation,target,key_hash),
  UNIQUE (id,actor_user_id),
  CHECK (replay_expires_at > created_at)
);
CREATE TRIGGER transport_commands_append_only BEFORE UPDATE OR DELETE ON app.transport_commands
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE INDEX transport_commands_expiry ON app.transport_commands(replay_expires_at,id);

ALTER TABLE app.trip_events DROP CONSTRAINT trip_events_operation_check;
ALTER TABLE app.trip_events ADD CONSTRAINT trip_events_operation_check
  CHECK (operation IN ('create','assign','reschedule','start','complete','cancel','arrive','correct_arrival','reassign_version'));
ALTER TABLE app.trip_events ADD COLUMN command_id uuid UNIQUE,
  ADD CONSTRAINT trip_event_command_actor FOREIGN KEY (command_id,actor_user_id)
    REFERENCES app.transport_commands(id,actor_user_id) ON DELETE RESTRICT
    DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE app.schedule_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  schedule_id uuid NOT NULL REFERENCES app.service_schedules(id) ON DELETE RESTRICT,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  command_id uuid NOT NULL UNIQUE,
  operation text NOT NULL CHECK (operation='create'),
  after_state jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  FOREIGN KEY (command_id,actor_user_id) REFERENCES app.transport_commands(id,actor_user_id)
    ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED
);
CREATE TRIGGER schedule_events_append_only BEFORE UPDATE OR DELETE ON app.schedule_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
COMMENT ON TABLE app.transport_commands IS 'Completed non-secret transport command results. Replay authorized from current DB facts before If-Match; logical replay horizon 7 days. Expired keys are refused, never re-executed. Restricted physical expiry/tombstone maintenance remains a pre-deployment requirement.';
COMMENT ON COLUMN app.trip_events.command_id IS 'New command-layer events always link a receipt and actor atomically. Nullable only for direct storage fixtures/pre-command history; this does not authorize unaudited API writes.';
