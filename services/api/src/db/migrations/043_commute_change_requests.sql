-- Rider intent is separate from the subscription that drives dispatch.
CREATE TABLE commute_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  subscription_id uuid NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
  period_id uuid REFERENCES subscription_periods(id) ON DELETE SET NULL,
  from_route_id uuid REFERENCES routes(id),
  route_id uuid NOT NULL REFERENCES routes(id),
  pickup_stop_id uuid NOT NULL REFERENCES stops(id),
  dropoff_stop_id uuid NOT NULL REFERENCES stops(id),
  morning_departure text NOT NULL CHECK (morning_departure ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'),
  evening_return text NOT NULL CHECK (evening_return ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'),
  requested_date date NOT NULL,
  effective_date date,
  pause_if_waitlisted boolean NOT NULL DEFAULT false,
  note text NOT NULL DEFAULT '' CHECK (length(note) <= 1000),
  decision_note text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','waitlisted','approved','rejected','cancelled','applied')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (pickup_stop_id <> dropoff_stop_id)
);
CREATE UNIQUE INDEX commute_requests_one_open ON commute_requests(user_id)
  WHERE status IN ('pending','waitlisted','approved');
CREATE INDEX commute_requests_queue ON commute_requests(status,created_at);

-- Ops explicitly releases recurring TRANSFER places. This is not an estimate
-- based on one trip's empty seats; normal trip capacity is still enforced.
CREATE TABLE commute_slots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id uuid NOT NULL REFERENCES routes(id),
  morning_departure text NOT NULL CHECK (morning_departure ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'),
  evening_return text NOT NULL CHECK (evening_return ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$'),
  available_from date NOT NULL,
  status text NOT NULL DEFAULT 'available' CHECK (status IN ('available','held','allocated','retired')),
  request_id uuid UNIQUE REFERENCES commute_requests(id) ON DELETE SET NULL,
  subscription_id uuid REFERENCES subscriptions(id) ON DELETE SET NULL,
  created_by uuid NOT NULL REFERENCES users(id),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX commute_slot_one_allocation ON commute_slots(subscription_id)
  WHERE status = 'allocated';

-- Orthogonal to payment suspension: a dispute resolution cannot resume this.
CREATE TABLE subscription_pauses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id uuid NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
  period_id uuid NOT NULL REFERENCES subscription_periods(id) ON DELETE CASCADE,
  request_id uuid NOT NULL REFERENCES commute_requests(id) ON DELETE CASCADE,
  started_at timestamptz NOT NULL DEFAULT now(),
  original_period_end timestamptz NOT NULL,
  resumed_at timestamptz,
  extended_period_end timestamptz,
  CHECK (resumed_at IS NULL OR resumed_at >= started_at)
);
CREATE UNIQUE INDEX subscription_one_pause ON subscription_pauses(subscription_id) WHERE resumed_at IS NULL;

CREATE TABLE commute_request_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL REFERENCES commute_requests(id) ON DELETE CASCADE,
  actor_id uuid NOT NULL REFERENCES users(id),
  action text NOT NULL,
  note text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX commute_request_events_request ON commute_request_events(request_id,created_at);

-- Expiry/refund/cancellation and replacement periods invalidate approvals.
-- Keep their history, release capacity, and never carry a pause to a new bill.
CREATE FUNCTION close_obsolete_commute() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status IN ('expired','cancelled') OR NEW.current_period_id IS DISTINCT FROM OLD.current_period_id THEN
    UPDATE commute_slots SET status='available',request_id=NULL,subscription_id=NULL
      WHERE subscription_id=NEW.id AND status='allocated';
    UPDATE commute_slots SET status='available',request_id=NULL
      WHERE status='held' AND request_id IN (
        SELECT id FROM commute_requests WHERE subscription_id=NEW.id AND status='approved');
    INSERT INTO commute_request_events(request_id,actor_id,action,note)
      SELECT id,user_id,'membership_closed','Membership ended or its billing period changed'
        FROM commute_requests WHERE subscription_id=NEW.id AND status IN ('pending','waitlisted','approved');
    UPDATE commute_requests SET status='cancelled',updated_at=now(),
      decision_note='Membership ended or its billing period changed; submit a new request after renewal'
      WHERE subscription_id=NEW.id AND status IN ('pending','waitlisted','approved');
    UPDATE subscription_pauses SET resumed_at=now() WHERE subscription_id=NEW.id AND resumed_at IS NULL;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER subscriptions_commute_close AFTER UPDATE OF status,current_period_id ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION close_obsolete_commute();

-- Follow the existing soft-erasure boundary. Free text may contain an address;
-- keep only non-free-text accounting history and release operational capacity.
CREATE FUNCTION erase_commute_notes() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL THEN
    UPDATE commute_slots SET status='available',request_id=NULL,subscription_id=NULL
      WHERE request_id IN (SELECT id FROM commute_requests WHERE user_id=NEW.id)
        AND status IN ('held','allocated');
    UPDATE commute_requests SET note='',decision_note=NULL,
      status=CASE WHEN status IN ('pending','waitlisted','approved') THEN 'cancelled' ELSE status END,
      updated_at=now() WHERE user_id=NEW.id;
    UPDATE commute_request_events SET note='' WHERE request_id IN (
      SELECT id FROM commute_requests WHERE user_id=NEW.id);
    UPDATE subscription_pauses SET resumed_at=now() WHERE resumed_at IS NULL AND subscription_id IN (
      SELECT id FROM subscriptions WHERE user_id=NEW.id);
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER users_erase_commute AFTER UPDATE OF deleted_at ON users
  FOR EACH ROW EXECUTE FUNCTION erase_commute_notes();

-- Serializes a late confirmation/dispatch write against pause and transfer.
-- Scope the guard to riders in this workflow; legacy fixture behaviour is not
-- changed. Historical boarded/no-show rows are never rewritten.
CREATE FUNCTION guard_commute_reservation() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE membership subscriptions%ROWTYPE;
BEGIN
  IF NEW.status NOT IN ('pending','reserved') OR NOT EXISTS (
    SELECT 1 FROM commute_requests WHERE user_id=NEW.user_id
  ) THEN RETURN NEW; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended(NEW.user_id::text,0));
  SELECT * INTO membership FROM subscriptions WHERE user_id=NEW.user_id AND status='active';
  IF membership.id IS NULL OR membership.current_period_id IS NULL
    OR membership.period_end IS NULL OR membership.period_end<=now()
    OR NOT EXISTS (SELECT 1 FROM subscription_periods WHERE id=membership.current_period_id AND status='open')
    OR EXISTS (SELECT 1 FROM users WHERE id=NEW.user_id AND deleted_at IS NOT NULL) OR EXISTS (
    SELECT 1 FROM subscription_pauses WHERE subscription_id=membership.id AND resumed_at IS NULL
  ) THEN RAISE EXCEPTION 'Commute membership is not available' USING ERRCODE='P0001'; END IF;
  IF NEW.trip_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM trips WHERE id=NEW.trip_id AND route_id=membership.route_id
  ) THEN RAISE EXCEPTION 'Commute route changed; refresh before booking' USING ERRCODE='P0001'; END IF;
  IF EXISTS (SELECT 1 FROM commute_slots c JOIN trips t ON t.id=NEW.trip_id
    WHERE c.subscription_id=membership.id AND c.status='allocated'
      AND to_char(t.scheduled_at AT TIME ZONE 'Africa/Accra','HH24:MI') <>
        CASE WHEN NEW.direction='morning' THEN c.morning_departure ELSE c.evening_return END
  ) THEN RAISE EXCEPTION 'Trip does not match allocated commute time' USING ERRCODE='P0001'; END IF;
  NEW.subscription_period_id := membership.current_period_id;
  NEW.pickup_stop_id := membership.pickup_stop_id;
  NEW.dropoff_stop_id := membership.dropoff_stop_id;
  RETURN NEW;
END $$;
CREATE TRIGGER reservations_commute_guard BEFORE INSERT OR UPDATE ON reservations
  FOR EACH ROW EXECUTE FUNCTION guard_commute_reservation();
