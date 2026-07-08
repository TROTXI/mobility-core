-- 017_scan_method_pin: allow 'pin' as a scan_events method (ADR-0014, E4 layer 2).
-- Boarding a rider via their daily 4-digit PIN is audited the same as a QR scan,
-- so the method CHECK gains 'pin' alongside 'qr' | 'photo'.
ALTER TABLE scan_events DROP CONSTRAINT IF EXISTS scan_events_method_check;
ALTER TABLE scan_events
  ADD CONSTRAINT scan_events_method_check CHECK (method IN ('qr', 'photo', 'pin'));
