-- Driver onboarding and PIN recovery by email, through the existing outbox.
--
-- A driver's contact email is where operations sends sign-in instructions. It
-- is not an authentication identity: it never becomes app.users.email, which
-- belongs to a verified Google or Apple sign-in, and knowing it grants nothing.
ALTER TABLE app.drivers ADD COLUMN email text
  CHECK (email IS NULL OR (length(email) BETWEEN 3 AND 320 AND email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'));
COMMENT ON COLUMN app.drivers.email IS
  'Contact address for credential instructions only. Entered by operations, not verified, never used to sign in or to recover an account.';

-- A temporary PIN is one operations issued: at first credential issue or on a
-- reset. It works only until the driver sets a private PIN or this deadline
-- passes, whichever is first. Must-change and the deadline are one fact.
ALTER TABLE app.driver_credentials ADD COLUMN temporary_pin_expires_at timestamptz;
-- Existing temporary PINs get the same window, starting now, rather than
-- expiring on upgrade or living forever.
UPDATE app.driver_credentials SET temporary_pin_expires_at = clock_timestamp() + interval '72 hours'
  WHERE must_change_pin;
ALTER TABLE app.driver_credentials
  ADD CONSTRAINT temporary_pin_has_deadline CHECK (must_change_pin = (temporary_pin_expires_at IS NOT NULL));
-- The column default was true, which would now demand a deadline on every
-- insert. Issue sets both explicitly; anything else starts as a private PIN.
ALTER TABLE app.driver_credentials ALTER COLUMN must_change_pin SET DEFAULT false;
COMMENT ON TABLE app.driver_credentials IS
  'Six-digit keyed PIN hashes, five-attempt/15-minute lockout. must_change_pin marks an operations-issued temporary PIN: the API refuses operational work until the driver sets a private PIN, and refuses the temporary PIN itself after temporary_pin_expires_at.';

-- Credential mail. The encrypted payload holds the temporary PIN; the row does
-- not. The worker checks the credential version, driver and address again
-- before sending, so a delayed message never delivers credentials that a
-- later reset, PIN change or contact edit has made obsolete.
ALTER TABLE app.email_outbox DROP CONSTRAINT email_outbox_kind_check;
ALTER TABLE app.email_outbox ADD CONSTRAINT email_outbox_kind_check CHECK (kind IN (
  'subscription_active','subscription_expiring','erasure_requested',
  'driver_credentials_issued','driver_pin_reset'));
ALTER TABLE app.email_outbox DROP CONSTRAINT email_outbox_failure_code_check;
ALTER TABLE app.email_outbox ADD CONSTRAINT email_outbox_failure_code_check CHECK (failure_code IN (
  'expired','account_closed','stale_reminder','provider_rejected','provider_unavailable',
  'retry_window_elapsed','invalid_payload','stale_credential'));
CREATE INDEX email_driver_credentials ON app.email_outbox(user_id, created_at DESC)
  WHERE kind IN ('driver_credentials_issued','driver_pin_reset');
