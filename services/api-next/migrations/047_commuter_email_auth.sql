ALTER TABLE app.users ADD COLUMN first_name text, ADD COLUMN last_name text, ADD COLUMN other_names text;
ALTER TABLE app.users ADD CONSTRAINT complete_name_parts CHECK (
  (first_name IS NULL AND last_name IS NULL AND other_names IS NULL) OR
  (first_name IS NOT NULL AND last_name IS NOT NULL AND length(first_name) BETWEEN 1 AND 60 AND length(last_name) BETWEEN 1 AND 60
   AND (other_names IS NULL OR length(other_names) BETWEEN 1 AND 80)));
ALTER TABLE app.users ADD CONSTRAINT erased_name_parts CHECK (deleted_at IS NULL OR
  (first_name IS NULL AND last_name IS NULL AND other_names IS NULL));
CREATE INDEX users_contact_email ON app.users(lower(email)) WHERE deleted_at IS NULL;

-- Contact emails are not credentials. Only this verified, unique address can
-- authenticate a commuter. Pending signup cannot create a usable session.
CREATE TABLE app.email_credentials (
  user_id uuid PRIMARY KEY REFERENCES app.users(id),
  email text CHECK(email IS NULL OR (email=lower(btrim(email)) AND length(email)<=320)),
  password_hash text,
  signup_pending boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  verified_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK(version>0),
  CHECK ((password_hash IS NULL) = (verified_at IS NULL)),
  CHECK (email IS NOT NULL OR password_hash IS NULL)
);
-- Tentative links are not ownership claims. They must not reserve a mailbox
-- against its owner enrolling separately with verified email or Google.
CREATE UNIQUE INDEX email_credentials_verified ON app.email_credentials(email) WHERE verified_at IS NOT NULL;
CREATE UNIQUE INDEX email_credentials_signup ON app.email_credentials(email) WHERE signup_pending;
CREATE TABLE app.email_auth_challenges (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app.users(id),
  purpose text NOT NULL CHECK(purpose IN ('signup','link','reset')),
  token_hash text UNIQUE,
  credential_version integer NOT NULL,
  session_id uuid REFERENCES app.auth_sessions(id),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  expires_at timestamptz NOT NULL,
  consumed_at timestamptz,
  CHECK(expires_at>created_at),
  CHECK((purpose='link') = (session_id IS NOT NULL))
);
CREATE INDEX email_credentials_pending ON app.email_credentials(created_at)
  WHERE password_hash IS NULL AND email IS NOT NULL;
CREATE INDEX email_auth_challenges_user ON app.email_auth_challenges(user_id,created_at);
CREATE INDEX email_auth_challenges_expiry ON app.email_auth_challenges(expires_at) WHERE token_hash IS NOT NULL;

ALTER TABLE app.email_outbox DROP CONSTRAINT email_outbox_kind_check;
ALTER TABLE app.email_outbox ADD CONSTRAINT email_outbox_kind_check CHECK(kind IN (
 'ops_invitation','subscription_active','subscription_expiring','erasure_requested',
 'driver_credentials_issued','driver_pin_reset','renewal_upcoming','renewal_failed','renewal_needs_offer',
 'commuter_email_access','commuter_password_changed'));

CREATE FUNCTION app.erase_email_credentials() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL THEN
    NEW.first_name=NULL; NEW.last_name=NULL; NEW.other_names=NULL;
    UPDATE app.email_credentials SET email=NULL,password_hash=NULL,verified_at=NULL,signup_pending=false,version=version+1 WHERE user_id=NEW.id;
    UPDATE app.email_auth_challenges SET token_hash=NULL,consumed_at=COALESCE(consumed_at,clock_timestamp()) WHERE user_id=NEW.id;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER erase_email_credentials BEFORE UPDATE OF deleted_at ON app.users
  FOR EACH ROW EXECUTE FUNCTION app.erase_email_credentials();
