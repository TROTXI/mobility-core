-- 010_scan_events: boarding audit trail (#20). Every pass scan (or photo
-- fallback) records who was scanned, by which driver, on which trip, and the
-- result. Append-only. rider_id is NULL for an invalid/forged pass (unattributable);
-- trip_id has no FK yet (trips arrive in #18).
CREATE TABLE IF NOT EXISTS scan_events (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rider_id   uuid REFERENCES users (id) ON DELETE SET NULL,
  scanned_by uuid REFERENCES users (id) ON DELETE SET NULL,
  trip_id    uuid,
  result     text NOT NULL CHECK (result IN ('valid', 'invalid', 'expired')),
  method     text NOT NULL DEFAULT 'qr' CHECK (method IN ('qr', 'photo')),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_scan_events_rider ON scan_events (rider_id);
CREATE INDEX IF NOT EXISTS idx_scan_events_trip ON scan_events (trip_id);
