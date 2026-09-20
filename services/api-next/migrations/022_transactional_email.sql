-- Email is an external side effect, never part of the payment provider call.
-- Queue writes commit with the business event. No backfill of historical mail.
CREATE TABLE app.email_outbox (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  kind text NOT NULL CHECK (kind IN ('subscription_active','subscription_expiring','erasure_requested')),
  source_id uuid NOT NULL,
  dedupe_key text NOT NULL UNIQUE CHECK (length(dedupe_key) BETWEEN 1 AND 200),
  payload_ciphertext text,
  state text NOT NULL DEFAULT 'pending' CHECK (state IN ('pending','accepted','cancelled','failed','unknown')),
  attempts integer NOT NULL DEFAULT 0 CHECK (attempts BETWEEN 0 AND 20),
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  expires_at timestamptz NOT NULL DEFAULT transaction_timestamp()+interval '7 days',
  first_attempt_at timestamptz,
  next_attempt_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  claim_id uuid,
  lease_until timestamptz,
  provider_id text CHECK (length(provider_id) BETWEEN 1 AND 200),
  failure_code text CHECK (failure_code IN ('expired','account_closed','stale_reminder','provider_rejected','provider_unavailable','retry_window_elapsed','invalid_payload')),
  CHECK (expires_at>created_at AND expires_at<=created_at+interval '7 days'),
  CHECK ((claim_id IS NULL)=(lease_until IS NULL)),
  CHECK ((state='pending')=(payload_ciphertext IS NOT NULL)),
  CHECK (state='pending' OR (claim_id IS NULL AND lease_until IS NULL)),
  CHECK ((state='accepted')=(provider_id IS NOT NULL))
);
CREATE INDEX email_due ON app.email_outbox(next_attempt_at,created_at,id) WHERE state='pending';
CREATE INDEX email_owner ON app.email_outbox(user_id) WHERE state='pending';
CREATE FUNCTION app.guard_email_identity() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'email_identity_immutable' USING ERRCODE='23514'; END IF;
  IF NEW.id<>OLD.id OR NEW.user_id<>OLD.user_id OR NEW.kind<>OLD.kind
    OR NEW.source_id<>OLD.source_id OR NEW.dedupe_key<>OLD.dedupe_key
    OR NEW.created_at<>OLD.created_at OR NEW.expires_at<>OLD.expires_at
    OR (NEW.payload_ciphertext IS NOT NULL AND NEW.payload_ciphertext IS DISTINCT FROM OLD.payload_ciphertext)
    OR (OLD.first_attempt_at IS NOT NULL AND NEW.first_attempt_at IS DISTINCT FROM OLD.first_attempt_at)
    OR (OLD.state<>'pending' AND NEW IS DISTINCT FROM OLD)
  THEN RAISE EXCEPTION 'email_identity_immutable' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER preserve_email_identity BEFORE UPDATE OR DELETE ON app.email_outbox
  FOR EACH ROW EXECUTE FUNCTION app.guard_email_identity();
-- Erasure must scrub queued mail even when email is temporarily unconfigured.
CREATE FUNCTION app.cancel_erased_account_email() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
    UPDATE app.email_outbox SET state='cancelled',payload_ciphertext=NULL,
      claim_id=NULL,lease_until=NULL,failure_code='account_closed'
      WHERE user_id=NEW.id AND state='pending' AND kind<>'erasure_requested';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER erase_queued_email AFTER UPDATE OF deleted_at ON app.users
  FOR EACH ROW EXECUTE FUNCTION app.cancel_erased_account_email();
COMMENT ON TABLE app.email_outbox IS
  'Transactional mail; accepted means provider accepted, NOT delivered. Encrypted recipient/content cleared at terminal state or within seven days by email worker. Stable dedupe identity retained. Unknown sends are not blindly retried past the provider idempotency window.';
