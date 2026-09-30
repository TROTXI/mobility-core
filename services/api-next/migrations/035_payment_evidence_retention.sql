-- Preserve immutable payment facts and links while allowing one-way removal of
-- the much richer provider payload after its reconciliation window closes.
ALTER TABLE app.payment_events
  ALTER COLUMN ciphertext DROP NOT NULL,
  ADD COLUMN redacted_at timestamptz,
  ADD CONSTRAINT payment_event_payload_redaction CHECK
    ((ciphertext IS NULL) = (redacted_at IS NOT NULL) AND
     (ciphertext IS NOT NULL OR state='processed'));

CREATE INDEX payment_events_payload_retention
  ON app.payment_events(processed_at,id)
  WHERE state='processed' AND ciphertext IS NOT NULL;
CREATE INDEX payment_collections_event ON app.payment_collections(event_id);
CREATE INDEX payment_refunds_event ON app.payment_refunds(event_id);
CREATE INDEX payment_disputes_event ON app.payment_disputes(event_id);
CREATE INDEX payment_reviews_event ON app.payment_reviews(event_id) WHERE event_id IS NOT NULL;

CREATE OR REPLACE FUNCTION app.guard_payment_event() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.state='processed' AND OLD.ciphertext IS NOT NULL AND
     NEW.ciphertext IS NULL AND OLD.redacted_at IS NULL AND
     NEW.redacted_at IS NOT NULL AND
     (to_jsonb(NEW)-ARRAY['ciphertext','redacted_at']) =
       (to_jsonb(OLD)-ARRAY['ciphertext','redacted_at']) THEN
    RETURN NEW;
  END IF;
  IF (NEW.id,NEW.environment,NEW.source,NEW.payload_hash,NEW.ciphertext,NEW.received_at,NEW.redacted_at)
       IS DISTINCT FROM
     (OLD.id,OLD.environment,OLD.source,OLD.payload_hash,OLD.ciphertext,OLD.received_at,OLD.redacted_at)
     OR (OLD.state<>'ready' AND NEW IS DISTINCT FROM OLD) THEN
    RAISE EXCEPTION 'immutable_provider_evidence_or_outcome' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
