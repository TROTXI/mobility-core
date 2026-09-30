-- A notification is a durable, account-scoped fact, not evidence that a push
-- reached a handset. Keep only a type and a first-party target: never copy
-- names, phone numbers, provider payloads or device tokens into the inbox.
CREATE TABLE app.rider_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  kind text NOT NULL CHECK (kind IN
    ('seat_ask','seat_held','seat_unseated','ride_used','credit_converted','trip_changed','trip_cancelled')),
  source_id uuid NOT NULL,
  target_type text NOT NULL CHECK (target_type IN ('reservation','credit')),
  target_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  read_at timestamptz,
  UNIQUE (user_id,kind,source_id)
);
CREATE INDEX rider_notifications_page ON app.rider_notifications(user_id,created_at DESC,id DESC);
CREATE INDEX rider_notifications_unread ON app.rider_notifications(user_id,created_at DESC,id DESC)
  WHERE read_at IS NULL;

-- The inbox's read transition is the only editable field. This also protects
-- source attribution from an accidentally broad runtime UPDATE grant.
CREATE FUNCTION app.guard_rider_notification() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' OR OLD.read_at IS NOT NULL OR NEW.read_at IS NULL OR
     (to_jsonb(NEW)-'read_at') IS DISTINCT FROM (to_jsonb(OLD)-'read_at')
  THEN RAISE EXCEPTION 'immutable_rider_notification' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER protect_rider_notification BEFORE UPDATE OR DELETE ON app.rider_notifications
  FOR EACH ROW EXECUTE FUNCTION app.guard_rider_notification();

CREATE TABLE app.rider_notification_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_id uuid NOT NULL REFERENCES app.rider_notifications(id) ON DELETE RESTRICT,
  user_id uuid NOT NULL REFERENCES app.users(id) ON DELETE RESTRICT,
  action text NOT NULL CHECK (action IN ('created','read')),
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX rider_notification_events_owner ON app.rider_notification_events(user_id,occurred_at DESC);
CREATE TRIGGER rider_notification_events_append_only BEFORE UPDATE OR DELETE ON app.rider_notification_events
  FOR EACH ROW EXECUTE FUNCTION app.append_only();
CREATE FUNCTION app.audit_rider_notification() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO app.rider_notification_events(notification_id,user_id,action)
  VALUES (NEW.id,NEW.user_id,CASE WHEN TG_OP='INSERT' THEN 'created' ELSE 'read' END);
  RETURN NEW;
END $$;
CREATE TRIGGER audit_rider_notification_insert AFTER INSERT ON app.rider_notifications
  FOR EACH ROW EXECUTE FUNCTION app.audit_rider_notification();
CREATE TRIGGER audit_rider_notification_read AFTER UPDATE OF read_at ON app.rider_notifications
  FOR EACH ROW EXECUTE FUNCTION app.audit_rider_notification();

CREATE TABLE app.rider_notification_preferences (
  user_id uuid PRIMARY KEY REFERENCES app.users(id) ON DELETE RESTRICT,
  -- Africa/Accra local clock. Mandatory service notifications cannot be muted.
  daily_ask_time time NOT NULL DEFAULT '17:00',
  optional_updates_enabled boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  version integer NOT NULL DEFAULT 1 CHECK (version>0),
  CHECK (daily_ask_time BETWEEN '06:00'::time AND '21:00'::time)
);

CREATE FUNCTION app.notify_reservation_change() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE notification_kind text;
BEGIN
  IF TG_OP='INSERT' THEN RETURN NEW; END IF;
  notification_kind := CASE
    WHEN NEW.status='reserved' AND OLD.status='pending' THEN 'seat_held'
    WHEN NEW.status='unseated' AND OLD.status<>'unseated' THEN 'seat_unseated'
    WHEN NEW.status='boarded' AND OLD.status<>'boarded' THEN 'ride_used'
    ELSE NULL END;
  IF notification_kind IS NOT NULL THEN
    INSERT INTO app.rider_notifications(user_id,kind,source_id,target_type,target_id)
    SELECT NEW.user_id,notification_kind,NEW.id,'reservation',NEW.id
    FROM app.users u WHERE u.id=NEW.user_id AND u.deleted_at IS NULL
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER notify_reservation_change AFTER UPDATE OF status ON app.reservations
  FOR EACH ROW EXECUTE FUNCTION app.notify_reservation_change();

CREATE FUNCTION app.notify_reservation_prompt() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO app.rider_notifications(user_id,kind,source_id,target_type,target_id)
  SELECT r.user_id,'seat_ask',NEW.reservation_id,'reservation',NEW.reservation_id
  FROM app.reservations r JOIN app.users u ON u.id=r.user_id AND u.deleted_at IS NULL
  WHERE r.id=NEW.reservation_id
  ON CONFLICT DO NOTHING;
  RETURN NEW;
END $$;
CREATE TRIGGER notify_reservation_prompt AFTER INSERT ON app.reservation_prompts
  FOR EACH ROW EXECUTE FUNCTION app.notify_reservation_prompt();

CREATE FUNCTION app.notify_credit_conversion() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.reason='month_end_conversion' THEN
    INSERT INTO app.rider_notifications(user_id,kind,source_id,target_type,target_id)
    SELECT NEW.user_id,'credit_converted',NEW.id,'credit',NEW.id
    FROM app.users u WHERE u.id=NEW.user_id AND u.deleted_at IS NULL
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER notify_credit_conversion AFTER INSERT ON app.credit_entries
  FOR EACH ROW EXECUTE FUNCTION app.notify_credit_conversion();

CREATE FUNCTION app.notify_trip_change() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.operation IN ('assign','reschedule','reassign_version','cancel') AND
     NEW.before_state IS DISTINCT FROM NEW.after_state THEN
    INSERT INTO app.rider_notifications(user_id,kind,source_id,target_type,target_id)
    SELECT DISTINCT ON (r.user_id) r.user_id,
      CASE WHEN NEW.operation='cancel' THEN 'trip_cancelled' ELSE 'trip_changed' END,
      NEW.id,'reservation',r.id
    FROM app.reservations r JOIN app.users u ON u.id=r.user_id AND u.deleted_at IS NULL
    WHERE r.trip_id=NEW.trip_id AND r.status IN ('pending','reserved','boarded','operator_cancelled')
    ORDER BY r.user_id,r.created_at DESC,r.id DESC
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER notify_trip_change AFTER INSERT ON app.trip_events
  FOR EACH ROW EXECUTE FUNCTION app.notify_trip_change();
