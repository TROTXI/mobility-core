-- Separate verified phone identities, never an automatic link through users.phone.
ALTER TABLE app.auth_identities DROP CONSTRAINT auth_identities_provider_check;
ALTER TABLE app.auth_identities ADD CONSTRAINT auth_identities_provider_check
  CHECK (provider IN ('google','apple','phone'));
CREATE TABLE app.phone_otp_challenges (
  id uuid PRIMARY KEY,
  phone_hash text NOT NULL CHECK (phone_hash ~ '^[a-f0-9]{64}$'),
  source_hash text NOT NULL CHECK (source_hash ~ '^[a-f0-9]{64}$'),
  phone_ciphertext text,
  code_hash text CHECK (code_hash ~ '^[a-f0-9]{64}$'),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  expires_at timestamptz NOT NULL,
  attempts smallint NOT NULL DEFAULT 0 CHECK (attempts BETWEEN 0 AND 5),
  state text NOT NULL DEFAULT 'sending' CHECK (state IN ('sending','sent','failed','consumed')),
  CHECK (state <> 'sent' OR (code_hash IS NOT NULL AND phone_ciphertext IS NOT NULL)),
  CHECK (expires_at > created_at AND expires_at <= created_at + interval '5 minutes')
);
CREATE INDEX phone_otp_rate ON app.phone_otp_challenges(phone_hash,created_at DESC);
CREATE INDEX phone_otp_source_rate ON app.phone_otp_challenges(source_hash,created_at DESC);
CREATE FUNCTION app.guard_phone_otp_update() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF ROW(NEW.id,NEW.phone_hash,NEW.source_hash,NEW.created_at,NEW.expires_at)
       IS DISTINCT FROM ROW(OLD.id,OLD.phone_hash,OLD.source_hash,OLD.created_at,OLD.expires_at)
     OR NEW.attempts NOT IN (OLD.attempts,OLD.attempts+1)
     OR (NEW.attempts <> OLD.attempts AND (OLD.state <> 'sent' OR OLD.attempts >= 5))
     OR (NEW.code_hash IS NOT NULL AND NEW.code_hash IS DISTINCT FROM OLD.code_hash)
     OR (NEW.phone_ciphertext IS NOT NULL AND NEW.phone_ciphertext IS DISTINCT FROM OLD.phone_ciphertext)
     OR (OLD.state='sending' AND NEW.state NOT IN ('sending','sent','failed'))
     OR (OLD.state='sent' AND NEW.state NOT IN ('sent','failed','consumed'))
     OR (OLD.state IN ('failed','consumed') AND NEW IS DISTINCT FROM OLD)
     OR (NEW.state IN ('failed','consumed') AND (NEW.code_hash IS NOT NULL OR NEW.phone_ciphertext IS NOT NULL)) THEN
    RAISE EXCEPTION 'phone_otp_immutable' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER phone_otp_write_guard BEFORE UPDATE ON app.phone_otp_challenges
  FOR EACH ROW EXECUTE FUNCTION app.guard_phone_otp_update();
CREATE FUNCTION app.guard_expired_phone_otp() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.created_at > clock_timestamp() - interval '24 hours' THEN
    RAISE EXCEPTION 'phone_otp_window_live' USING ERRCODE='23514';
  END IF;
  RETURN OLD;
END $$;
CREATE TRIGGER expire_phone_otp BEFORE DELETE ON app.phone_otp_challenges
  FOR EACH ROW EXECUTE FUNCTION app.guard_expired_phone_otp();
COMMENT ON TABLE app.phone_otp_challenges IS 'Five-minute phone sign-in challenges. No plaintext OTP or phone. Attempts commit even on refusal. Request-time bounded cleanup after 24h preserves rate budgets.';
