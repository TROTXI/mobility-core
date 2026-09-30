-- Preserve immutable payment facts and links while allowing one-way removal of
-- the much richer provider payload after its reconciliation window closes.
ALTER TABLE app.payment_events
  ALTER COLUMN ciphertext DROP NOT NULL,
  ADD COLUMN purchase_id uuid REFERENCES app.purchases(id) ON DELETE RESTRICT,
  ADD COLUMN redacted_at timestamptz,
  ADD CONSTRAINT payment_event_payload_redaction CHECK
    ((ciphertext IS NULL) = (redacted_at IS NOT NULL) AND
     (ciphertext IS NOT NULL OR state='processed'));

CREATE INDEX payment_events_payload_retention
  ON app.payment_events(processed_at,id)
  WHERE state='processed' AND ciphertext IS NOT NULL AND purchase_id IS NOT NULL;
CREATE INDEX payment_events_purchase ON app.payment_events(purchase_id)
  WHERE purchase_id IS NOT NULL;
CREATE INDEX payment_collections_event ON app.payment_collections(event_id);
CREATE INDEX payment_refunds_event ON app.payment_refunds(event_id);
CREATE INDEX payment_disputes_event ON app.payment_disputes(event_id);
CREATE INDEX payment_reviews_event ON app.payment_reviews(event_id) WHERE event_id IS NOT NULL;

-- Older rows have no immutable association. Recover only an unambiguous link;
-- unlinked legacy payloads stay untouched rather than losing case evidence.
ALTER TABLE app.payment_events DISABLE TRIGGER guard_payment_event;
UPDATE app.payment_events e SET purchase_id=links.purchase_id
FROM (
  SELECT event_id,(array_agg(DISTINCT purchase_id))[1] AS purchase_id FROM (
    SELECT event_id,purchase_id FROM app.payment_collections
    UNION ALL SELECT event_id,purchase_id FROM app.payment_refunds
    UNION ALL SELECT event_id,purchase_id FROM app.payment_disputes
    UNION ALL SELECT event_id,purchase_id FROM app.payment_reviews WHERE event_id IS NOT NULL
  ) associations
  GROUP BY event_id HAVING count(DISTINCT purchase_id)=1
) links WHERE e.id=links.event_id;
ALTER TABLE app.payment_events ENABLE TRIGGER guard_payment_event;

-- Every writer that opens or advances financial work must contend with the
-- purchase row held by the retention worker before it rechecks eligibility.
CREATE FUNCTION app.lock_payment_case_purchase() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM 1 FROM app.purchases WHERE id=NEW.purchase_id FOR UPDATE;
  RETURN NEW;
END $$;
CREATE TRIGGER lock_payment_review_purchase BEFORE INSERT OR UPDATE ON app.payment_reviews
  FOR EACH ROW EXECUTE FUNCTION app.lock_payment_case_purchase();
CREATE TRIGGER lock_payment_refund_purchase BEFORE INSERT OR UPDATE ON app.payment_refunds
  FOR EACH ROW EXECUTE FUNCTION app.lock_payment_case_purchase();
CREATE TRIGGER lock_refund_intent_purchase BEFORE INSERT OR UPDATE ON app.refund_initiations
  FOR EACH ROW EXECUTE FUNCTION app.lock_payment_case_purchase();
CREATE TRIGGER lock_payment_dispute_purchase BEFORE INSERT OR UPDATE ON app.payment_disputes
  FOR EACH ROW EXECUTE FUNCTION app.lock_payment_case_purchase();

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
     OR (OLD.purchase_id IS DISTINCT FROM NEW.purchase_id AND NOT
         (OLD.state='ready' AND OLD.purchase_id IS NULL AND NEW.purchase_id IS NOT NULL
          AND NEW.state IN ('processed','quarantined')))
     OR (OLD.state<>'ready' AND NEW IS DISTINCT FROM OLD) THEN
    RAISE EXCEPTION 'immutable_provider_evidence_or_outcome' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END $$;
