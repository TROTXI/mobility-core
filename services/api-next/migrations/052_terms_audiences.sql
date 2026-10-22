-- Drivers accept their own app terms, and every published version of either
-- set of terms is accepted again in the app. Existing rows are rider sign-ups.
--
-- Expand only: migrations run before the new API is deployed, so the previous
-- release must keep working against this schema. It inserts without an
-- audience (the default records a rider, which is all it ever records) and
-- conflicts on (user_id,terms_version), so both the default and that key stay.
-- A user has one role, so one acceptance per user and version is enough.
-- Adding a column with a default rewrites no row, so the append-only trigger
-- is not involved.
ALTER TABLE app.terms_acceptances
  ADD COLUMN audience text NOT NULL DEFAULT 'commuter' CHECK (audience IN ('commuter','driver'));
ALTER TABLE app.terms_acceptances
  DROP CONSTRAINT terms_acceptances_channel_check,
  ADD CONSTRAINT terms_acceptances_channel_check CHECK (channel IN (
    'commuter_email_signup','commuter_phone_signup','commuter_google_signup','commuter_apple_signup',
    'commuter_app','driver_app'
  )),
  ADD CONSTRAINT terms_acceptances_channel_audience CHECK (
    (audience = 'driver') = (channel = 'driver_app')
  );
