-- A separate credential transport, not an email pretending to be an SMS.
CREATE TABLE app.driver_sms_outbox (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app.users(id),
  driver_id uuid NOT NULL REFERENCES app.drivers(id),
  command_id uuid NOT NULL UNIQUE,
  pin_version integer NOT NULL CHECK (pin_version>0),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  expires_at timestamptz NOT NULL,
  payload_ciphertext text,
  state text NOT NULL DEFAULT 'pending' CHECK (state IN ('pending','sending','accepted','cancelled','failed','unknown')),
  claimed_at timestamptz,
  provider_id text,
  CHECK (expires_at>created_at),
  CHECK ((state IN ('pending','sending')) = (payload_ciphertext IS NOT NULL))
);
CREATE INDEX driver_sms_pending ON app.driver_sms_outbox(created_at) WHERE state IN ('pending','sending');
CREATE FUNCTION app.guard_driver_sms_update() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF ROW(NEW.id,NEW.user_id,NEW.driver_id,NEW.command_id,NEW.pin_version,NEW.created_at,NEW.expires_at)
       IS DISTINCT FROM ROW(OLD.id,OLD.user_id,OLD.driver_id,OLD.command_id,OLD.pin_version,OLD.created_at,OLD.expires_at)
     OR (NEW.payload_ciphertext IS NOT NULL AND NEW.payload_ciphertext IS DISTINCT FROM OLD.payload_ciphertext)
     OR (OLD.claimed_at IS NOT NULL AND NEW.claimed_at IS DISTINCT FROM OLD.claimed_at)
     OR (OLD.state='pending' AND NEW.state NOT IN ('sending','cancelled'))
     OR (OLD.state='sending' AND NEW.state NOT IN ('accepted','cancelled','failed','unknown'))
     OR (OLD.state IN ('accepted','cancelled','failed','unknown') AND NEW IS DISTINCT FROM OLD)
     OR (NEW.state='sending' AND NEW.claimed_at IS NULL)
     OR (NEW.provider_id IS NOT NULL AND NEW.state <> 'accepted') THEN
    RAISE EXCEPTION 'driver_sms_immutable' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER driver_sms_write_guard BEFORE UPDATE ON app.driver_sms_outbox
  FOR EACH ROW EXECUTE FUNCTION app.guard_driver_sms_update();
COMMENT ON TABLE app.driver_sms_outbox IS 'Encrypted temporary credentials bound to a PIN version. Durable sending state prevents uncertain mNotify deliveries being resent. Terminal rows contain no payload.';

CREATE FUNCTION app.cancel_erased_driver_sms() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
    UPDATE app.driver_sms_outbox SET state='cancelled',payload_ciphertext=NULL
      WHERE user_id=NEW.id AND state IN ('pending','sending');
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER cancel_erased_driver_sms AFTER UPDATE OF deleted_at ON app.users
  FOR EACH ROW EXECUTE FUNCTION app.cancel_erased_driver_sms();
