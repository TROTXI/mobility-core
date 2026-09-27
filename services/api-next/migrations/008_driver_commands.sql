-- Append-only review slice: keep 001-007 byte-identical.
ALTER TABLE app.drivers ADD COLUMN phone text, ADD COLUMN license_number text;
ALTER TABLE app.driver_credentials ADD COLUMN pin_version integer NOT NULL DEFAULT 1 CHECK (pin_version>0);

CREATE TABLE app.driver_commands (
  id uuid PRIMARY KEY,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  driver_id uuid NOT NULL REFERENCES app.drivers(id) ON DELETE RESTRICT,
  operation text NOT NULL CHECK(operation IN ('createDriver','updateDriver','issueDriverCredential','resetDriverPin','changeCredentialState','changeDriverPin')),
  target text NOT NULL,
  key_hash text NOT NULL CHECK(key_hash ~ '^[a-f0-9]{64}$'),
  input_hash text NOT NULL CHECK(input_hash ~ '^[a-f0-9]{64}$'),
  response_status integer NOT NULL CHECK(response_status IN (200,201,204)),
  response_body jsonb,
  response_headers jsonb NOT NULL,
  secret_ciphertext text,
  pin_version integer,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  replay_expires_at timestamptz NOT NULL,
  UNIQUE(actor_user_id,operation,target,key_hash),
  UNIQUE(id,actor_user_id,driver_id),
  CHECK(replay_expires_at>created_at),
  CHECK((operation IN ('issueDriverCredential','resetDriverPin') AND response_body IS NULL
    AND pin_version>0 AND pin_version IS NOT NULL AND replay_expires_at<=created_at+interval '5 minutes')
    OR (operation NOT IN ('issueDriverCredential','resetDriverPin') AND secret_ciphertext IS NULL AND pin_version IS NULL))
);
-- Receipts are immutable except one-way ciphertext erasure. A TTL is enforced
-- on every read; this narrow update also supports physical expiry maintenance.
CREATE FUNCTION app.guard_driver_receipt() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='UPDATE' AND NEW.secret_ciphertext IS NULL
    AND (to_jsonb(NEW)-'secret_ciphertext')=(to_jsonb(OLD)-'secret_ciphertext') THEN RETURN NEW; END IF;
  RAISE EXCEPTION 'immutable_driver_receipt' USING ERRCODE='23514';
END $$;
CREATE TRIGGER protect_driver_receipt BEFORE UPDATE OR DELETE ON app.driver_commands
  FOR EACH ROW EXECUTE FUNCTION app.guard_driver_receipt();
CREATE INDEX driver_commands_secret_expiry ON app.driver_commands(replay_expires_at,id) WHERE secret_ciphertext IS NOT NULL;

CREATE TABLE app.driver_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id uuid NOT NULL REFERENCES app.drivers(id) ON DELETE RESTRICT,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  command_id uuid NOT NULL UNIQUE,
  operation text NOT NULL CHECK(operation IN ('createDriver','updateDriver','issueDriverCredential','resetDriverPin','changeCredentialState','changeDriverPin')),
  reason text,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  FOREIGN KEY(command_id,actor_user_id,driver_id) REFERENCES app.driver_commands(id,actor_user_id,driver_id)
    ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED
);
CREATE TRIGGER retain_driver_events BEFORE UPDATE OR DELETE ON app.driver_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE INDEX drivers_created_page ON app.drivers(created_at,id);

CREATE FUNCTION app.guard_driver_link() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.user_id IS NOT NULL AND NEW.user_id IS DISTINCT FROM OLD.user_id AND
    (EXISTS(SELECT 1 FROM app.driver_credentials WHERE driver_id=OLD.id)
      OR EXISTS(SELECT 1 FROM app.trips WHERE assigned_driver_id=OLD.id)) THEN
    RAISE EXCEPTION 'explicit_driver_reassignment_required' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_driver_link BEFORE UPDATE ON app.drivers
  FOR EACH ROW EXECUTE FUNCTION app.guard_driver_link();
COMMENT ON TABLE app.driver_commands IS 'Authorized caller/operation/target/key receipts. Input digests are keyed, including low-entropy PIN inputs. Only issue/reset responses are encrypted; never stored as JSON. Secret replay additionally checks current PIN generation and non-archived driver, and expires after five minutes. Suspension blocks sign-in, not authorized ops reset/replay. Tombstones never rerun an old command.';
COMMENT ON TABLE app.driver_events IS 'Attributable operations, no PINs, hashes, tokens, phone or licence snapshots. Reason is ops-authored text, not request-body logging.';
COMMENT ON COLUMN app.driver_credentials.pin_version IS 'Increment on each PIN replacement; invalidates earlier encrypted replay even inside the five-minute horizon.';
