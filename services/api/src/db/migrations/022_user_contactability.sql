-- 022_user_contactability: give users an email and make the phone column usable.
--
-- Both were being discarded (#182). The Google/Apple ID token carries a verified
-- email that findOrCreateUser dropped on the floor, and the phone number that
-- Paystack collects for every mobile-money charge never reached us. After signup
-- we knew a display name and nothing we could contact.
--
-- email is deliberately NOT unique: one person can hold a Google identity and an
-- Apple identity on the same address, and provider identity (auth_identity) is
-- the account key, not the mailbox. A unique constraint here would reject the
-- second provider at sign-in.
--
-- phone already exists from 001_init with a UNIQUE constraint; nothing is
-- changed about it here beyond documenting that values are stored E.164
-- normalised (+233…) so the same handset cannot land three ways.

ALTER TABLE users ADD COLUMN IF NOT EXISTS email text;

COMMENT ON COLUMN users.email IS
  'Verified email from the social identity provider. Not unique: one person may hold google + apple identities on one address.';
COMMENT ON COLUMN users.phone IS
  'E.164 normalised (+233...). Captured from the Paystack charge.success webhook; a successful mobile-money charge proves control of the handset.';

-- Case-insensitive lookup without forcing the citext extension on every env.
CREATE INDEX IF NOT EXISTS idx_users_email_lower ON users (lower(email)) WHERE email IS NOT NULL;
