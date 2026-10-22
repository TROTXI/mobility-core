-- Drivers accept their own app terms, and every published version of either
-- set of terms is accepted again in the app. Existing rows are rider sign-ups.
-- Adding a column with a default rewrites no row, so the append-only trigger
-- is not involved.
ALTER TABLE app.terms_acceptances
  ADD COLUMN audience text NOT NULL DEFAULT 'commuter' CHECK (audience IN ('commuter','driver'));
ALTER TABLE app.terms_acceptances ALTER COLUMN audience DROP DEFAULT;
ALTER TABLE app.terms_acceptances
  DROP CONSTRAINT terms_acceptances_pkey,
  ADD PRIMARY KEY (user_id,audience,terms_version);
ALTER TABLE app.terms_acceptances
  DROP CONSTRAINT terms_acceptances_channel_check,
  ADD CONSTRAINT terms_acceptances_channel_check CHECK (channel IN (
    'commuter_email_signup','commuter_phone_signup','commuter_google_signup','commuter_apple_signup',
    'commuter_app','driver_app'
  )),
  ADD CONSTRAINT terms_acceptances_channel_audience CHECK (
    (audience = 'driver') = (channel = 'driver_app')
  );
