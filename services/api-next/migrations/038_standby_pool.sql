-- New-rider standby is distinct from paid-member route-change waitlisting.
CREATE TABLE app.standby_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  route_id uuid NOT NULL REFERENCES app.routes(id) ON DELETE RESTRICT,
  selection jsonb NOT NULL CHECK (jsonb_typeof(selection)='object'),
  state text NOT NULL DEFAULT 'submitted'
    CHECK (state IN ('submitted','offered','withdrawn','checkout_open')),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE(id,user_id)
);
CREATE UNIQUE INDEX standby_one_open_per_rider ON app.standby_applications(user_id)
  WHERE state IN ('submitted','offered','checkout_open');
CREATE INDEX standby_board ON app.standby_applications(state,created_at,id);
CREATE TABLE app.standby_offers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id uuid NOT NULL UNIQUE REFERENCES app.standby_applications(id) ON DELETE RESTRICT,
  state text NOT NULL DEFAULT 'offered' CHECK (state IN ('offered','accepting','checkout_open','cancelled')),
  expires_at timestamptz NOT NULL CHECK (isfinite(expires_at)),
  acceptance_key_hash text CHECK (acceptance_key_hash ~ '^[a-f0-9]{64}$'),
  purchase_id uuid UNIQUE REFERENCES app.purchases(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  CHECK ((state IN ('accepting','checkout_open'))=(acceptance_key_hash IS NOT NULL)),
  CHECK ((state='checkout_open')=(purchase_id IS NOT NULL))
);
CREATE INDEX standby_offer_expiry ON app.standby_offers(expires_at) WHERE state='offered';
CREATE TABLE app.standby_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id uuid NOT NULL REFERENCES app.standby_applications(id) ON DELETE RESTRICT,
  actor_user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  action text NOT NULL CHECK (action IN ('join','withdraw','offer','accept')),
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX standby_events_application ON app.standby_events(application_id,occurred_at DESC);
CREATE TRIGGER standby_events_append_only BEFORE UPDATE OR DELETE ON app.standby_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
ALTER TABLE app.rider_notifications
  DROP CONSTRAINT rider_notifications_kind_check,
  ADD CONSTRAINT rider_notifications_kind_check CHECK (kind IN
    ('seat_ask','seat_held','seat_unseated','ride_used','credit_converted',
     'trip_changed','trip_cancelled','standby_offered')),
  DROP CONSTRAINT rider_notifications_target_type_check,
  ADD CONSTRAINT rider_notifications_target_type_check CHECK
    (target_type IN ('reservation','credit','standby'));
COMMENT ON TABLE app.standby_offers IS
  'An offer authorizes a fresh rider-initiated purchase checkout, never a stored mandate or automatic charge.';
CREATE FUNCTION app.erase_standby_application() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
    UPDATE app.standby_offers SET state='cancelled'
      WHERE application_id IN (SELECT id FROM app.standby_applications WHERE user_id=NEW.id)
        AND state='offered';
    UPDATE app.standby_applications SET
      state=CASE WHEN state IN ('submitted','offered') THEN 'withdrawn' ELSE state END,
      selection='{}'::jsonb,updated_at=clock_timestamp()
      WHERE user_id=NEW.id;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER erase_standby AFTER UPDATE ON app.users FOR EACH ROW
  EXECUTE FUNCTION app.erase_standby_application();
