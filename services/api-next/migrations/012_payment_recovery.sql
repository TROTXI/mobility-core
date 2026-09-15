-- Provider evidence, recovery and compensating reversals. 001-011 are immutable.
CREATE TABLE app.payment_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 environment text NOT NULL CHECK(environment IN ('test','live')),
 source text NOT NULL CHECK(source IN ('webhook','verify')),
 payload_hash text NOT NULL CHECK(payload_hash ~ '^[a-f0-9]{64}$'),
 ciphertext bytea NOT NULL CHECK(octet_length(ciphertext) BETWEEN 29 AND 1048604),
 state text NOT NULL DEFAULT 'ready' CHECK(state IN ('ready','processed','quarantined')),
 attempts integer NOT NULL DEFAULT 0 CHECK(attempts BETWEEN 0 AND 10),
 reason text CHECK(reason IS NULL OR reason IN ('unsupported_event','invalid_facts','unknown_reference','provider_conflict','late_success','account_unavailable','unexpected_error','retry_exhausted')),
 received_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 available_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 processed_at timestamptz,
 UNIQUE(environment,source,payload_hash),
 CHECK((state='ready' AND processed_at IS NULL) OR (state<>'ready' AND processed_at IS NOT NULL))
);
CREATE INDEX payment_events_ready ON app.payment_events(available_at,id) WHERE state='ready';
ALTER TABLE app.payment_attempts ADD CONSTRAINT attempt_environment_owner UNIQUE(id,purchase_id,user_id,environment);
CREATE TABLE app.payment_collections (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 attempt_id uuid NOT NULL UNIQUE,
 purchase_id uuid NOT NULL,
 user_id uuid NOT NULL,
 environment text NOT NULL,
 provider_transaction_id text NOT NULL CHECK(provider_transaction_id ~ '^[0-9]+$'),
 amount_pesewas integer NOT NULL CHECK(amount_pesewas>=100),
 currency text NOT NULL CHECK(currency='GHS'),
 paid_at timestamptz NOT NULL CHECK(isfinite(paid_at)),
 event_id uuid NOT NULL REFERENCES app.payment_events(id) ON DELETE RESTRICT,
 FOREIGN KEY(attempt_id,purchase_id,user_id,environment) REFERENCES app.payment_attempts(id,purchase_id,user_id,environment) ON DELETE RESTRICT,
 UNIQUE(environment,provider_transaction_id)
);
CREATE TABLE app.payment_refunds (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 attempt_id uuid NOT NULL,
 purchase_id uuid NOT NULL,
 user_id uuid NOT NULL,
 environment text NOT NULL,
 provider_reference text NOT NULL CHECK(length(provider_reference) BETWEEN 1 AND 200),
 amount_pesewas integer NOT NULL CHECK(amount_pesewas>0),
 state text NOT NULL CHECK(state IN ('pending','processing','needs_attention','failed','processed')),
 event_id uuid NOT NULL REFERENCES app.payment_events(id) ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 FOREIGN KEY(attempt_id,purchase_id,user_id,environment) REFERENCES app.payment_attempts(id,purchase_id,user_id,environment) ON DELETE RESTRICT,
 UNIQUE(environment,provider_reference), UNIQUE(id,purchase_id,user_id)
);
CREATE INDEX payment_refunds_purchase ON app.payment_refunds(purchase_id);
CREATE TABLE app.payment_disputes (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 attempt_id uuid NOT NULL,
 purchase_id uuid NOT NULL,
 user_id uuid NOT NULL,
 environment text NOT NULL,
 provider_id text NOT NULL CHECK(provider_id ~ '^[0-9]+$'),
 amount_pesewas integer NOT NULL CHECK(amount_pesewas>0),
 state text NOT NULL CHECK(state IN ('created','reminded','resolved')),
 resolution text CHECK(resolution IS NULL OR length(resolution) BETWEEN 1 AND 100),
 event_id uuid NOT NULL REFERENCES app.payment_events(id) ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 FOREIGN KEY(attempt_id,purchase_id,user_id,environment) REFERENCES app.payment_attempts(id,purchase_id,user_id,environment) ON DELETE RESTRICT,
 UNIQUE(environment,provider_id), UNIQUE(id,purchase_id,user_id),
 CHECK(state='resolved' OR resolution IS NULL)
);
CREATE INDEX payment_disputes_purchase ON app.payment_disputes(purchase_id);
CREATE TABLE app.payment_access_blocks (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 period_id uuid NOT NULL,
 purchase_id uuid NOT NULL,
 user_id uuid NOT NULL,
 dispute_id uuid NOT NULL UNIQUE,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 released_at timestamptz,
 FOREIGN KEY(period_id,purchase_id,user_id) REFERENCES app.billing_periods(id,purchase_id,user_id) ON DELETE RESTRICT,
 FOREIGN KEY(dispute_id,purchase_id,user_id) REFERENCES app.payment_disputes(id,purchase_id,user_id) ON DELETE RESTRICT
);
CREATE INDEX payment_access_blocks_period ON app.payment_access_blocks(period_id) WHERE released_at IS NULL;
CREATE TABLE app.payment_reversals (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 purchase_id uuid NOT NULL UNIQUE,
 user_id uuid NOT NULL,
 period_id uuid NOT NULL UNIQUE,
 refund_id uuid NOT NULL,
 rides_removed integer NOT NULL CHECK(rides_removed>=0),
 consumed_rides integer NOT NULL CHECK(consumed_rides>=0),
 conversion_credit_pesewas integer NOT NULL CHECK(conversion_credit_pesewas>=0),
 recovered_credit_pesewas integer NOT NULL CHECK(recovered_credit_pesewas BETWEEN 0 AND conversion_credit_pesewas),
 restored_credit_pesewas integer NOT NULL CHECK(restored_credit_pesewas>=0),
 estimated_debt_pesewas bigint NOT NULL CHECK(estimated_debt_pesewas BETWEEN 0 AND 9007199254740991),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 FOREIGN KEY(period_id,purchase_id,user_id) REFERENCES app.billing_periods(id,purchase_id,user_id) ON DELETE RESTRICT,
 FOREIGN KEY(refund_id,purchase_id,user_id) REFERENCES app.payment_refunds(id,purchase_id,user_id) ON DELETE RESTRICT,
 UNIQUE(id,period_id,user_id), UNIQUE(id,user_id)
);
CREATE TABLE app.payment_reviews (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 purchase_id uuid NOT NULL REFERENCES app.purchases(id) ON DELETE RESTRICT,
 kind text NOT NULL CHECK(kind IN ('refund','dispute','manual_review')),
 reason text NOT NULL CHECK(reason IN ('late_success','provider_conflict','account_unavailable','consumed_value_after_refund','refund_progress','dispute_progress')),
 amount_pesewas bigint NOT NULL CHECK(amount_pesewas BETWEEN 0 AND 9007199254740991),
 event_id uuid REFERENCES app.payment_events(id) ON DELETE RESTRICT,
 reversal_id uuid UNIQUE REFERENCES app.payment_reversals(id) ON DELETE RESTRICT,
 refund_id uuid UNIQUE REFERENCES app.payment_refunds(id) ON DELETE RESTRICT,
 dispute_id uuid UNIQUE REFERENCES app.payment_disputes(id) ON DELETE RESTRICT,
 state text NOT NULL DEFAULT 'open' CHECK(state IN ('open','resolved','waived')),
 decided_by uuid REFERENCES app.users(id) ON DELETE RESTRICT,
 decision_reason text CHECK(decision_reason IS NULL OR length(btrim(decision_reason)) BETWEEN 1 AND 2000),
 version integer NOT NULL DEFAULT 1 CHECK(version>0),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 UNIQUE(event_id,reason),
 CHECK(num_nonnulls(event_id,reversal_id,refund_id,dispute_id)=1)
);
CREATE TRIGGER payment_review_version BEFORE UPDATE ON app.payment_reviews FOR EACH ROW EXECUTE FUNCTION app.touch_version();
CREATE INDEX payment_reviews_queue ON app.payment_reviews(created_at DESC,id DESC) WHERE state='open';
CREATE TABLE app.payment_review_commands (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
 review_id uuid NOT NULL REFERENCES app.payment_reviews(id) ON DELETE RESTRICT,
 key_hash text NOT NULL CHECK(key_hash ~ '^[a-f0-9]{64}$'),
 input_hash text NOT NULL CHECK(input_hash ~ '^[a-f0-9]{64}$'),
 decision text NOT NULL CHECK(decision IN ('resolved','waived')),
 reason text NOT NULL CHECK(length(btrim(reason)) BETWEEN 1 AND 2000),
 response_body jsonb NOT NULL,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 UNIQUE(actor_user_id,review_id,key_hash)
);
ALTER TABLE app.ride_entries ADD COLUMN reversal_id uuid;
ALTER TABLE app.ride_entries ADD FOREIGN KEY(reversal_id,period_id,user_id) REFERENCES app.payment_reversals(id,period_id,user_id) ON DELETE RESTRICT;
ALTER TABLE app.ride_entries DROP CONSTRAINT ride_entries_reason_check, DROP CONSTRAINT ride_entries_check;
ALTER TABLE app.ride_entries ADD CHECK(reason IN ('allocation','converted','refund'));
ALTER TABLE app.ride_entries ADD CHECK(
 (reason='allocation' AND delta_rides>0 AND closure_id IS NULL AND reversal_id IS NULL) OR
 (reason='converted' AND delta_rides<0 AND closure_id IS NOT NULL AND reversal_id IS NULL) OR
 (reason='refund' AND delta_rides<0 AND closure_id IS NULL AND reversal_id IS NOT NULL));
CREATE UNIQUE INDEX one_reversal_ride_effect ON app.ride_entries(reversal_id) WHERE reversal_id IS NOT NULL;
ALTER TABLE app.credit_entries ADD COLUMN reversal_id uuid;
ALTER TABLE app.credit_entries ADD FOREIGN KEY(reversal_id,user_id) REFERENCES app.payment_reversals(id,user_id) ON DELETE RESTRICT;
ALTER TABLE app.credit_entries DROP CONSTRAINT credit_entries_reason_check, DROP CONSTRAINT credit_entries_check;
ALTER TABLE app.credit_entries ADD CHECK(reason IN ('adjustment','purchase_applied','month_end_conversion','refund_restored','refund_conversion_recovered'));
ALTER TABLE app.credit_entries ADD CHECK(
 (reason='adjustment' AND adjustment_id IS NOT NULL AND purchase_id IS NULL AND closure_id IS NULL AND reversal_id IS NULL) OR
 (reason='purchase_applied' AND purchase_id IS NOT NULL AND delta_pesewas<0 AND adjustment_id IS NULL AND closure_id IS NULL AND reversal_id IS NULL) OR
 (reason='month_end_conversion' AND closure_id IS NOT NULL AND delta_pesewas>0 AND adjustment_id IS NULL AND purchase_id IS NULL AND reversal_id IS NULL) OR
 (reason IN ('refund_restored','refund_conversion_recovered') AND reversal_id IS NOT NULL AND adjustment_id IS NULL AND purchase_id IS NULL AND closure_id IS NULL));
CREATE UNIQUE INDEX one_reversal_credit_effect ON app.credit_entries(reversal_id,reason) WHERE reversal_id IS NOT NULL;
-- Keep 011's validator on its original source types; refund sources have their
-- own immediate validator. No broad replacement/copy of the old function.
DROP TRIGGER guard_credit_source ON app.credit_entries;
CREATE TRIGGER guard_credit_source BEFORE INSERT ON app.credit_entries FOR EACH ROW
 WHEN (NEW.reversal_id IS NULL) EXECUTE FUNCTION app.guard_financial_sources();
DROP TRIGGER guard_ride_source ON app.ride_entries;
CREATE TRIGGER guard_ride_source BEFORE INSERT ON app.ride_entries FOR EACH ROW
 WHEN (NEW.reversal_id IS NULL) EXECUTE FUNCTION app.guard_financial_sources();
CREATE FUNCTION app.guard_reversal_entry() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE r app.payment_reversals; expected integer; available bigint;
BEGIN
 SELECT * INTO r FROM app.payment_reversals WHERE id=NEW.reversal_id;
 IF TG_TABLE_NAME='ride_entries' THEN
  IF NEW.delta_rides IS DISTINCT FROM -r.rides_removed THEN RAISE EXCEPTION 'refund_ride_source_mismatch' USING ERRCODE='23514'; END IF;
 ELSE
  PERFORM id FROM app.users WHERE id=NEW.user_id FOR UPDATE;
  expected:=CASE WHEN NEW.reason='refund_restored' THEN r.restored_credit_pesewas ELSE -r.recovered_credit_pesewas END;
  IF NEW.delta_pesewas IS DISTINCT FROM expected THEN RAISE EXCEPTION 'refund_credit_source_mismatch' USING ERRCODE='23514'; END IF;
  SELECT COALESCE((SELECT SUM(delta_pesewas) FROM app.credit_entries WHERE user_id=NEW.user_id),0)+NEW.delta_pesewas-
   COALESCE((SELECT SUM(amount_pesewas) FROM app.credit_holds WHERE user_id=NEW.user_id AND state='held'),0) INTO available;
  IF available<0 THEN RAISE EXCEPTION 'credit_entry_consumes_held_or_missing_value' USING ERRCODE='23514'; END IF;
 END IF; RETURN NEW;
END $$;
CREATE TRIGGER guard_refund_credit BEFORE INSERT ON app.credit_entries FOR EACH ROW WHEN(NEW.reversal_id IS NOT NULL) EXECUTE FUNCTION app.guard_reversal_entry();
CREATE TRIGGER guard_refund_rides BEFORE INSERT ON app.ride_entries FOR EACH ROW WHEN(NEW.reversal_id IS NOT NULL) EXECUTE FUNCTION app.guard_reversal_entry();
CREATE FUNCTION app.refund_rank(s text) RETURNS integer LANGUAGE sql IMMUTABLE AS $$
 SELECT CASE s WHEN 'pending' THEN 0 WHEN 'processing' THEN 1 WHEN 'needs_attention' THEN 2 WHEN 'failed' THEN 3 WHEN 'processed' THEN 4 ELSE -1 END $$;
CREATE FUNCTION app.dispute_rank(s text) RETURNS integer LANGUAGE sql IMMUTABLE AS $$
 SELECT CASE s WHEN 'created' THEN 0 WHEN 'reminded' THEN 1 WHEN 'resolved' THEN 2 ELSE -1 END $$;
CREATE FUNCTION app.guard_provider_progress() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE old_rank integer; new_rank integer;
BEGIN
 IF TG_TABLE_NAME='payment_refunds' THEN
  old_rank:=app.refund_rank(OLD.state); new_rank:=app.refund_rank(NEW.state);
  IF (to_jsonb(NEW)-ARRAY['state','event_id','updated_at']) IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['state','event_id','updated_at']) THEN
   RAISE EXCEPTION 'immutable_refund_identity' USING ERRCODE='23514'; END IF;
 ELSE
  old_rank:=app.dispute_rank(OLD.state); new_rank:=app.dispute_rank(NEW.state);
  IF (to_jsonb(NEW)-ARRAY['state','resolution','amount_pesewas','event_id','updated_at']) IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['state','resolution','amount_pesewas','event_id','updated_at']) OR
    (old_rank=new_rank AND (NEW.amount_pesewas,NEW.resolution) IS DISTINCT FROM (OLD.amount_pesewas,OLD.resolution)) THEN
   RAISE EXCEPTION 'immutable_dispute_identity_or_verdict' USING ERRCODE='23514'; END IF;
 END IF;
 IF new_rank<old_rank THEN RAISE EXCEPTION 'nonmonotonic_provider_progress' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER guard_refund_progress BEFORE UPDATE ON app.payment_refunds FOR EACH ROW EXECUTE FUNCTION app.guard_provider_progress();
CREATE TRIGGER guard_dispute_progress BEFORE UPDATE ON app.payment_disputes FOR EACH ROW EXECUTE FUNCTION app.guard_provider_progress();
CREATE FUNCTION app.guard_payment_event() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF (NEW.id,NEW.environment,NEW.source,NEW.payload_hash,NEW.ciphertext,NEW.received_at) IS DISTINCT FROM
    (OLD.id,OLD.environment,OLD.source,OLD.payload_hash,OLD.ciphertext,OLD.received_at) OR
    (OLD.state<>'ready' AND NEW IS DISTINCT FROM OLD) THEN
  RAISE EXCEPTION 'immutable_provider_evidence_or_outcome' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER guard_payment_event BEFORE UPDATE ON app.payment_events FOR EACH ROW EXECUTE FUNCTION app.guard_payment_event();
CREATE FUNCTION app.guard_payment_block() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF (to_jsonb(NEW)-'released_at') IS DISTINCT FROM (to_jsonb(OLD)-'released_at') OR
 (OLD.released_at IS NOT NULL AND NEW.released_at IS DISTINCT FROM OLD.released_at) THEN
  RAISE EXCEPTION 'immutable_payment_block_source' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER guard_payment_block BEFORE UPDATE ON app.payment_access_blocks FOR EACH ROW EXECUTE FUNCTION app.guard_payment_block();
CREATE TRIGGER retain_payment_reversals BEFORE UPDATE OR DELETE ON app.payment_reversals FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TRIGGER retain_payment_collections BEFORE UPDATE OR DELETE ON app.payment_collections FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE TRIGGER retain_payment_review_commands BEFORE UPDATE OR DELETE ON app.payment_review_commands FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE FUNCTION app.guard_recovery_source() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE a app.payment_attempts; env text; total bigint;
BEGIN
 SELECT * INTO a FROM app.payment_attempts WHERE id=NEW.attempt_id;
 PERFORM id FROM app.users WHERE id=a.user_id FOR UPDATE;
 SELECT environment INTO env FROM app.payment_events WHERE id=NEW.event_id;
 IF env IS DISTINCT FROM NEW.environment OR NEW.amount_pesewas>a.amount_pesewas THEN
  RAISE EXCEPTION 'provider_source_mismatch' USING ERRCODE='23514'; END IF;
 IF TG_TABLE_NAME='payment_collections' AND NEW.amount_pesewas<>a.amount_pesewas THEN
  RAISE EXCEPTION 'collection_amount_mismatch' USING ERRCODE='23514'; END IF;
 IF TG_TABLE_NAME='payment_refunds' THEN
 IF NEW.state='processed' THEN
  SELECT COALESCE(SUM(amount_pesewas),0)+NEW.amount_pesewas INTO total FROM app.payment_refunds
   WHERE purchase_id=NEW.purchase_id AND state='processed' AND id<>NEW.id;
  IF total>a.amount_pesewas THEN RAISE EXCEPTION 'refund_exceeds_cash' USING ERRCODE='23514'; END IF;
 END IF;
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER validate_collection BEFORE INSERT ON app.payment_collections FOR EACH ROW EXECUTE FUNCTION app.guard_recovery_source();
CREATE TRIGGER validate_refund BEFORE INSERT OR UPDATE ON app.payment_refunds FOR EACH ROW EXECUTE FUNCTION app.guard_recovery_source();
CREATE TRIGGER validate_dispute BEFORE INSERT OR UPDATE ON app.payment_disputes FOR EACH ROW EXECUTE FUNCTION app.guard_recovery_source();
CREATE FUNCTION app.guard_reversal_source() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE p app.purchases; b app.billing_periods; cash bigint; rides bigint; consumed bigint; converted bigint; available bigint; debt bigint;
BEGIN
 PERFORM id FROM app.users WHERE id=NEW.user_id FOR UPDATE;
 SELECT * INTO p FROM app.purchases WHERE id=NEW.purchase_id;
 SELECT * INTO b FROM app.billing_periods WHERE id=NEW.period_id FOR UPDATE;
 SELECT COALESCE(SUM(amount_pesewas),0) INTO cash FROM app.payment_refunds WHERE purchase_id=p.id AND state='processed';
 SELECT COALESCE(SUM(delta_rides),0),GREATEST(0,-COALESCE(SUM(delta_rides) FILTER(WHERE reason IN ('boarding','no_show','returned')),0))
  INTO rides,consumed FROM app.ride_entries WHERE period_id=b.id;
 SELECT COALESCE(SUM(credit_granted_pesewas),0) INTO converted FROM app.period_closures WHERE period_id=b.id;
 SELECT COALESCE((SELECT SUM(delta_pesewas) FROM app.credit_entries WHERE user_id=NEW.user_id),0)-
  COALESCE((SELECT SUM(amount_pesewas) FROM app.credit_holds WHERE user_id=NEW.user_id AND state='held'),0) INTO available;
 debt:=round(p.price_pesewas::numeric*consumed/p.rides_granted)::bigint+converted-LEAST(converted,available);
 IF p.state<>'fulfilled' OR b.state='reversed' OR cash<>p.cash_due_pesewas OR
  NOT EXISTS(SELECT 1 FROM app.payment_refunds WHERE id=NEW.refund_id AND state='processed') OR
  NEW.rides_removed IS DISTINCT FROM rides OR NEW.consumed_rides IS DISTINCT FROM consumed OR
  NEW.conversion_credit_pesewas IS DISTINCT FROM converted OR
  NEW.recovered_credit_pesewas IS DISTINCT FROM LEAST(converted,available) OR
  NEW.restored_credit_pesewas IS DISTINCT FROM p.applied_credit_pesewas OR NEW.estimated_debt_pesewas IS DISTINCT FROM debt OR
  (p.applied_credit_pesewas>0 AND NOT EXISTS(SELECT 1 FROM app.credit_holds WHERE purchase_id=p.id AND state='captured' AND amount_pesewas=p.applied_credit_pesewas)) THEN
  RAISE EXCEPTION 'reversal_source_mismatch' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER validate_reversal BEFORE INSERT ON app.payment_reversals FOR EACH ROW EXECUTE FUNCTION app.guard_reversal_source();
CREATE FUNCTION app.require_reversal_effects() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF (NEW.rides_removed>0 AND NOT EXISTS(SELECT 1 FROM app.ride_entries WHERE reversal_id=NEW.id AND delta_rides=-NEW.rides_removed)) OR
 (NEW.restored_credit_pesewas>0 AND NOT EXISTS(SELECT 1 FROM app.credit_entries WHERE reversal_id=NEW.id AND reason='refund_restored' AND delta_pesewas=NEW.restored_credit_pesewas)) OR
 (NEW.recovered_credit_pesewas>0 AND NOT EXISTS(SELECT 1 FROM app.credit_entries WHERE reversal_id=NEW.id AND reason='refund_conversion_recovered' AND delta_pesewas=-NEW.recovered_credit_pesewas)) OR
 NOT EXISTS(SELECT 1 FROM app.billing_periods WHERE id=NEW.period_id AND state='reversed') THEN
  RAISE EXCEPTION 'incomplete_reversal' USING ERRCODE='23514'; END IF;
 RETURN NULL;
END $$;
CREATE CONSTRAINT TRIGGER reversal_requires_effects AFTER INSERT ON app.payment_reversals DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION app.require_reversal_effects();
CREATE FUNCTION app.guard_payment_review() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE purchase uuid;
BEGIN
 IF NEW.refund_id IS NOT NULL THEN SELECT purchase_id INTO purchase FROM app.payment_refunds WHERE id=NEW.refund_id;
 ELSIF NEW.dispute_id IS NOT NULL THEN SELECT purchase_id INTO purchase FROM app.payment_disputes WHERE id=NEW.dispute_id;
 ELSIF NEW.reversal_id IS NOT NULL THEN SELECT purchase_id INTO purchase FROM app.payment_reversals WHERE id=NEW.reversal_id;
 ELSE purchase:=NEW.purchase_id; END IF;
 IF purchase IS DISTINCT FROM NEW.purchase_id THEN RAISE EXCEPTION 'review_source_mismatch' USING ERRCODE='23514'; END IF;
 IF TG_OP='UPDATE' AND ((NEW.purchase_id,NEW.kind,NEW.reason,NEW.event_id,NEW.refund_id,NEW.dispute_id,NEW.reversal_id,NEW.created_at)
  IS DISTINCT FROM (OLD.purchase_id,OLD.kind,OLD.reason,OLD.event_id,OLD.refund_id,OLD.dispute_id,OLD.reversal_id,OLD.created_at) OR
  (OLD.state<>'open' AND (to_jsonb(NEW)-ARRAY['version','updated_at']) IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['version','updated_at']))) THEN
  RAISE EXCEPTION 'immutable_review_source_or_decision' USING ERRCODE='23514'; END IF;
 IF (NEW.decided_by IS NULL)<>(NEW.decision_reason IS NULL) OR (NEW.state='open' AND NEW.decided_by IS NOT NULL) THEN
  RAISE EXCEPTION 'invalid_review_attribution' USING ERRCODE='23514'; END IF;
 IF NEW.state<>'open' AND NEW.decided_by IS NULL AND NOT
  (NEW.state='resolved' AND (
   (NEW.kind='refund' AND EXISTS(SELECT 1 FROM app.payment_refunds WHERE id=NEW.refund_id AND state='processed')) OR
   (NEW.kind='dispute' AND EXISTS(SELECT 1 FROM app.payment_disputes WHERE id=NEW.dispute_id AND state='resolved') AND
    NOT EXISTS(SELECT 1 FROM app.payment_access_blocks WHERE dispute_id=NEW.dispute_id AND released_at IS NULL)))) THEN
  RAISE EXCEPTION 'review_decision_requires_actor' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER validate_payment_review BEFORE INSERT OR UPDATE ON app.payment_reviews FOR EACH ROW EXECUTE FUNCTION app.guard_payment_review();
CREATE FUNCTION app.guard_disputed_close() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF EXISTS(SELECT 1 FROM app.payment_access_blocks WHERE period_id=NEW.period_id AND released_at IS NULL) THEN
  RAISE EXCEPTION 'period_payment_blocked' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER reject_disputed_close BEFORE INSERT ON app.period_closures FOR EACH ROW EXECUTE FUNCTION app.guard_disputed_close();
COMMENT ON TABLE app.payment_events IS 'Authenticated webhook or Verify evidence, encrypted at rest. Commit acknowledgement with financial effects. Quarantined unknown references are never guessed into new purchases. Retention/key rotation must be configured before deployment.';
COMMENT ON TABLE app.payment_collections IS 'Immutable observed cash success, including late success after local failure. Not synonymous with purchase fulfilment.';
COMMENT ON TABLE app.payment_access_blocks IS 'Independent purchased-period dispute blocks. Releasing one never changes period state or releases other blocks/pauses. No automatic account-wide restriction.';
COMMENT ON TABLE app.payment_review_commands IS 'Attributable local review disposition only. Does not create a provider refund, erase cash evidence, clear a dispute block or charge debt.';
DO $$ DECLARE item record; BEGIN
 FOR item IN SELECT table_name,column_name FROM information_schema.columns WHERE table_schema='app' AND column_name LIKE '%pesewas'
 AND table_name IN ('payment_collections','payment_refunds','payment_disputes','payment_reversals','payment_reviews') LOOP
  EXECUTE format('COMMENT ON COLUMN app.%I.%I IS %L',item.table_name,item.column_name,'Integer pesewas; never GHS major units.');
 END LOOP;
END $$;
