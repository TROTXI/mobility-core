-- Reuse the bounded push worker; no new scheduler, credential or endpoint.
ALTER TABLE app.push_deliveries ALTER COLUMN reservation_id DROP NOT NULL;
ALTER TABLE app.push_deliveries ADD COLUMN trip_event_id uuid REFERENCES app.trip_events(id) ON DELETE RESTRICT;
ALTER TABLE app.push_deliveries ADD CONSTRAINT push_delivery_source
  CHECK ((reservation_id IS NOT NULL)::integer + (trip_event_id IS NOT NULL)::integer = 1);
CREATE UNIQUE INDEX one_driver_event_delivery ON app.push_deliveries(trip_event_id,device_id,user_id)
  WHERE trip_event_id IS NOT NULL;
CREATE INDEX trip_assignment_events ON app.trip_events(trip_id,created_at DESC)
  WHERE operation IN ('assign','reschedule','cancel');
COMMENT ON COLUMN app.push_deliveries.trip_event_id IS
  'Generic driver schedule-change alert backed by committed trip history. No route, rider or driver details appear in push payloads. Current device ownership and driver eligibility are checked before send.';
