-- Keep reviewed migrations unchanged. Push uses existing durable ask intents;
-- it stores no token, route label or message snapshot of its own.
CREATE TABLE app.push_deliveries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_id uuid NOT NULL REFERENCES app.reservations(id) ON DELETE RESTRICT,
  device_id uuid NOT NULL REFERENCES app.push_devices(id) ON DELETE RESTRICT,
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  state text NOT NULL DEFAULT 'pending' CHECK(state IN ('pending','accepted','cancelled','failed')),
  attempts integer NOT NULL DEFAULT 0 CHECK(attempts BETWEEN 0 AND 5),
  next_attempt_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  provider_id text CHECK(provider_id IS NULL OR length(provider_id) BETWEEN 1 AND 512),
  failure_code text CHECK(failure_code IS NULL OR failure_code IN ('provider_unavailable','invalid_token','expired','ineligible','delivery_failed')),
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  UNIQUE(reservation_id,device_id)
);
CREATE INDEX push_deliveries_pending ON app.push_deliveries(next_attempt_at,id) WHERE state='pending';
CREATE FUNCTION app.guard_push_delivery() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' OR OLD.state<>'pending' OR
    (to_jsonb(NEW)-ARRAY['state','attempts','next_attempt_at','provider_id','failure_code']) IS DISTINCT FROM
    (to_jsonb(OLD)-ARRAY['state','attempts','next_attempt_at','provider_id','failure_code']) OR NEW.attempts<OLD.attempts
  THEN RAISE EXCEPTION 'immutable_push_delivery' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_push_delivery BEFORE UPDATE OR DELETE ON app.push_deliveries
  FOR EACH ROW EXECUTE FUNCTION app.guard_push_delivery();
COMMENT ON TABLE app.push_deliveries IS
  'At-least-once FCM requests, not delivery proof. Stable id travels as notificationId for client deduplication. Current device owner and reservation eligibility are checked before each attempt.';

ALTER TABLE app.account_commands DROP CONSTRAINT account_commands_operation_check;
ALTER TABLE app.account_commands ADD CONSTRAINT account_commands_operation_check
  CHECK(operation IN ('updateAccount','eraseAccount','uploadAvatar','registerDevice','deleteAvatar'));
