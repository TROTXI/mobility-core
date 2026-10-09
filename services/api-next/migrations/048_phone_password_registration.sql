-- Phone possession completes registration; the email is a separate contact
-- and recovery address. Setting a password must not assert email ownership.
ALTER TABLE app.users ADD COLUMN phone_registration_pending boolean NOT NULL DEFAULT false;
ALTER TABLE app.users ADD CONSTRAINT phone_registration_pending_commuter
  CHECK (NOT phone_registration_pending OR role='commuter');

-- Older staging phone-only riders can finish the new signup with another SMS
-- instead of being stranded at a password prompt with no password to enter.
UPDATE app.users u SET phone_registration_pending=true
WHERE u.role='commuter' AND u.deleted_at IS NULL
  AND EXISTS (SELECT 1 FROM app.auth_identities i
              WHERE i.user_id=u.id AND i.provider='phone')
  AND NOT EXISTS (SELECT 1 FROM app.email_credentials e
                  WHERE e.user_id=u.id AND e.password_hash IS NOT NULL);

ALTER TABLE app.email_credentials DROP CONSTRAINT email_credentials_check;
ALTER TABLE app.email_credentials ADD CONSTRAINT verified_email_has_password
  CHECK (verified_at IS NULL OR password_hash IS NOT NULL);

ALTER TABLE app.email_auth_challenges DROP CONSTRAINT email_auth_challenges_purpose_check;
ALTER TABLE app.email_auth_challenges ADD CONSTRAINT email_auth_challenges_purpose_check
  CHECK (purpose IN ('signup','link','reset','contact'));
