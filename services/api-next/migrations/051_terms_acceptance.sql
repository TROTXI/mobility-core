-- Contract acceptance is explicit, versioned and recorded by the server clock.
-- IP addresses and device fingerprints are deliberately excluded as unnecessary
-- personal information. The linked user row is retained in scrubbed form after
-- account erasure, so the acceptance evidence does not need mutable identity data.
CREATE TABLE app.terms_acceptances (
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  terms_version text NOT NULL CHECK (terms_version ~ '^20[0-9]{2}-[0-9]{2}-[0-9]{2}$'),
  accepted_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  channel text NOT NULL CHECK (channel IN (
    'commuter_email_signup','commuter_phone_signup','commuter_google_signup','commuter_apple_signup'
  )),
  PRIMARY KEY (user_id,terms_version)
);

CREATE TRIGGER immutable_terms_acceptance BEFORE UPDATE OR DELETE ON app.terms_acceptances
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
