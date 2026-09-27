-- User-approved scope: expire response snapshots, never receipt identity or audit.
CREATE FUNCTION app.guard_receipt_payload() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE before_row jsonb; after_row jsonb; deadline timestamptz;
BEGIN
  IF TG_OP='INSERT' THEN
    IF NEW.response_body IS NULL THEN RAISE EXCEPTION 'receipt_response_required' USING ERRCODE='23514'; END IF;
    RETURN NEW;
  END IF;
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'append_only_history' USING ERRCODE='23514'; END IF;
  before_row:=to_jsonb(OLD); after_row:=to_jsonb(NEW);
  deadline:=coalesce((before_row->>'replay_expires_at')::timestamptz,OLD.created_at+interval '7 days');
  IF clock_timestamp()<deadline OR NEW.response_body IS NOT NULL
    OR coalesce(after_row->>'response_headers',after_row->>'response_etag') IS NOT NULL
    OR (after_row-ARRAY['response_body','response_headers','response_etag']) IS DISTINCT FROM
       (before_row-ARRAY['response_body','response_headers','response_etag']) THEN
    RAISE EXCEPTION 'immutable_receipt_payload' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
ALTER TABLE app.transport_commands ALTER COLUMN response_body DROP NOT NULL, ALTER COLUMN response_headers DROP NOT NULL;
ALTER TABLE app.boarding_commands ALTER COLUMN response_body DROP NOT NULL;
ALTER TABLE app.payment_review_commands ALTER COLUMN response_body DROP NOT NULL;
ALTER TABLE app.config_commands ALTER COLUMN response_body DROP NOT NULL;
DROP TRIGGER transport_commands_append_only ON app.transport_commands;
DROP TRIGGER immutable_boarding_commands ON app.boarding_commands;
DROP TRIGGER retain_payment_review_commands ON app.payment_review_commands;
DROP TRIGGER immutable_config_commands ON app.config_commands;
CREATE TRIGGER transport_commands_append_only BEFORE INSERT OR UPDATE OR DELETE ON app.transport_commands FOR EACH ROW EXECUTE FUNCTION app.guard_receipt_payload();
CREATE TRIGGER immutable_boarding_commands BEFORE INSERT OR UPDATE OR DELETE ON app.boarding_commands FOR EACH ROW EXECUTE FUNCTION app.guard_receipt_payload();
CREATE TRIGGER retain_payment_review_commands BEFORE INSERT OR UPDATE OR DELETE ON app.payment_review_commands FOR EACH ROW EXECUTE FUNCTION app.guard_receipt_payload();
CREATE TRIGGER immutable_config_commands BEFORE INSERT OR UPDATE OR DELETE ON app.config_commands FOR EACH ROW EXECUTE FUNCTION app.guard_receipt_payload();
CREATE OR REPLACE FUNCTION app.guard_driver_receipt() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='UPDATE' AND NEW.secret_ciphertext IS NULL
    AND (to_jsonb(NEW)-'secret_ciphertext')=(to_jsonb(OLD)-'secret_ciphertext') THEN RETURN NEW; END IF;
  IF TG_OP='UPDATE' AND NEW.secret_ciphertext IS NULL AND NEW.response_body IS NULL
    AND (clock_timestamp()>=OLD.replay_expires_at OR EXISTS (
      SELECT 1 FROM app.drivers d JOIN app.users u ON u.id=d.user_id WHERE d.id=OLD.driver_id AND u.deleted_at IS NOT NULL))
    AND (to_jsonb(NEW)-ARRAY['secret_ciphertext','response_body'])=(to_jsonb(OLD)-ARRAY['secret_ciphertext','response_body']) THEN RETURN NEW; END IF;
  RAISE EXCEPTION 'immutable_driver_receipt' USING ERRCODE='23514';
END $$;
COMMENT ON FUNCTION app.guard_receipt_payload() IS
  'Only expired response erasure, never receipt deletion or identity edits. Financial decisions/reasons remain attributable audit history.';
CREATE INDEX transport_payload_expiry ON app.transport_commands(replay_expires_at,id) WHERE response_body IS NOT NULL;
CREATE INDEX driver_payload_expiry ON app.driver_commands(replay_expires_at,id) WHERE response_body IS NOT NULL;
CREATE INDEX boarding_payload_expiry ON app.boarding_commands(created_at,id) WHERE response_body IS NOT NULL;
CREATE INDEX review_payload_expiry ON app.payment_review_commands(created_at,id) WHERE response_body IS NOT NULL;
CREATE INDEX config_payload_expiry ON app.config_commands(created_at,id) WHERE response_body IS NOT NULL;
