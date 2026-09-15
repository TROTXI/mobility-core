-- Preserve reviewed migration bytes and existing owner-written fixture history.
-- Apply to every non-owner writer, not a mutable role-name convention.
CREATE FUNCTION app.require_trip_event_receipt() RETURNS trigger
LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.command_id IS NULL AND NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_class
    WHERE oid = TG_RELID AND relowner = current_user::regrole
  ) THEN
    RAISE EXCEPTION 'trip_event_receipt_required' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER require_trip_event_receipt BEFORE INSERT ON app.trip_events
  FOR EACH ROW EXECUTE FUNCTION app.require_trip_event_receipt();

COMMENT ON FUNCTION app.require_trip_event_receipt() IS
  'Invoker-rights insert guard: every non-table-owner must supply command_id. The table owner may load explicit storage fixtures/pre-command history. Runtime roles must never own this table, inherit the owner or reach an owner-rights event writer. This does not require every trip mutation to emit an event.';
COMMENT ON COLUMN app.trip_events.command_id IS
  'Required for non-owner inserts by require_trip_event_receipt; owner-only fixture/history exception. Receipt existence and actor ownership remain enforced by the deferred trip_event_command_actor FK, including owner inserts with a non-null command_id. Events and receipts commit together.';
