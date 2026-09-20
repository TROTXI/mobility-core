-- Initiation is not provider settlement. A durable once-only intent prevents a
-- timeout, process death or a new caller key from issuing a second refund.
CREATE TABLE app.refund_initiations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL UNIQUE REFERENCES app.purchases(id) ON DELETE RESTRICT,
  collection_id uuid NOT NULL UNIQUE REFERENCES app.payment_collections(id) ON DELETE RESTRICT,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  amount_pesewas integer NOT NULL CHECK(amount_pesewas>0),
  reason text NOT NULL CHECK(length(reason) BETWEEN 1 AND 500),
  key_hash text NOT NULL CHECK(key_hash ~ '^[a-f0-9]{64}$'),
  input_hash text NOT NULL CHECK(input_hash ~ '^[a-f0-9]{64}$'),
  state text NOT NULL DEFAULT 'submitting' CHECK(state IN ('submitting','accepted','unknown')),
  provider_refund_id text CHECK(provider_refund_id IS NULL OR provider_refund_id ~ '^[0-9]{1,30}$'),
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  CHECK((state='accepted')=(provider_refund_id IS NOT NULL)),
  UNIQUE(actor_user_id,purchase_id,key_hash)
);
CREATE FUNCTION app.guard_refund_initiation() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE c app.payment_collections;
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'immutable_refund_intent' USING ERRCODE='23514'; END IF;
  IF TG_OP='INSERT' THEN
    SELECT * INTO c FROM app.payment_collections WHERE id=NEW.collection_id;
    IF c.purchase_id IS DISTINCT FROM NEW.purchase_id OR c.environment<>'test' OR NEW.amount_pesewas>c.amount_pesewas
      THEN RAISE EXCEPTION 'invalid_refund_intent' USING ERRCODE='23514'; END IF;
  ELSE
    IF OLD.state<>'submitting' OR NEW.state NOT IN ('accepted','unknown') OR
       (to_jsonb(NEW)-ARRAY['state','provider_refund_id','updated_at']) IS DISTINCT FROM
       (to_jsonb(OLD)-ARRAY['state','provider_refund_id','updated_at'])
      THEN RAISE EXCEPTION 'immutable_refund_intent' USING ERRCODE='23514'; END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_refund_initiation BEFORE INSERT OR UPDATE OR DELETE ON app.refund_initiations
  FOR EACH ROW EXECUTE FUNCTION app.guard_refund_initiation();
COMMENT ON COLUMN app.refund_initiations.amount_pesewas IS 'GHS pesewas requested as cash; not gross price or restored Ride Credit.';
COMMENT ON TABLE app.refund_initiations IS
  'TEST-only ops initiation, one per purchase. Never automatically repeat an uncertain provider POST. Additional partial refunds or failed/unknown attempts require provider reconciliation before a future retry design; no endpoint clears this identity.';
