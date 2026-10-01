-- Successful phone sign-in is evidence of possession; profile/payment phones are not.
CREATE TABLE app.commuter_phone_verifications (
  user_id uuid PRIMARY KEY REFERENCES app.users(id) ON DELETE RESTRICT,
  phone_hash text UNIQUE CHECK (phone_hash ~ '^[a-f0-9]{64}$'),
  last_four text CHECK (last_four ~ '^[0-9]{4}$'),
  verified_at timestamptz NOT NULL,
  method text NOT NULL CHECK (method IN ('phone_sign_in','account_upgrade')),
  revoked_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE app.phone_verification_reviews (
  user_id uuid PRIMARY KEY REFERENCES app.users(id) ON DELETE RESTRICT,
  phone_hash text CHECK (phone_hash ~ '^[a-f0-9]{64}$'),
  closed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
ALTER TABLE app.phone_otp_challenges
  ADD COLUMN purpose text NOT NULL DEFAULT 'sign_in'
    CHECK (purpose IN ('sign_in','standby_verification')),
  ADD COLUMN owner_user_id uuid REFERENCES app.users(id) ON DELETE RESTRICT,
  ADD CONSTRAINT phone_otp_purpose_owner CHECK
    ((purpose='sign_in' AND owner_user_id IS NULL) OR
     (purpose='standby_verification' AND owner_user_id IS NOT NULL));
CREATE INDEX phone_otp_owner_rate ON app.phone_otp_challenges(owner_user_id,created_at DESC)
  WHERE owner_user_id IS NOT NULL;
CREATE FUNCTION app.guard_phone_otp_purpose() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF ROW(NEW.purpose,NEW.owner_user_id) IS DISTINCT FROM ROW(OLD.purpose,OLD.owner_user_id) THEN
    RAISE EXCEPTION 'phone_otp_purpose_immutable' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER phone_otp_purpose_guard BEFORE UPDATE ON app.phone_otp_challenges
  FOR EACH ROW EXECUTE FUNCTION app.guard_phone_otp_purpose();
-- Historical phone identities are only created by a consumed OTP, but the
-- challenge's phone ciphertext is gone. Do not guess the last four digits.
INSERT INTO app.commuter_phone_verifications(user_id,phone_hash,verified_at,method)
SELECT i.user_id,i.subject,i.created_at,'phone_sign_in'
FROM app.auth_identities i JOIN app.users u ON u.id=i.user_id
WHERE i.provider='phone' AND i.subject NOT LIKE 'erased:%' AND u.role='commuter'
  AND u.deleted_at IS NULL;
COMMENT ON TABLE app.commuter_phone_verifications IS
  'Current phone possession only, not Ghana Card identity or SIM subscriber proof.';
