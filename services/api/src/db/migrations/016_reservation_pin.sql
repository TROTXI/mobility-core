-- 016_reservation_pin: the daily 4-digit boarding PIN (ADR-0014, E4 layer 2).
-- Issued when a rider confirms (status → reserved); the driver types it against
-- the manifest row to board offline when the QR can't be scanned. Stored as a
-- keyed hash (HMAC-SHA256 with the server secret) — never plaintext; the
-- plaintext is returned once, to the rider, in the confirm response.
ALTER TABLE reservations ADD COLUMN IF NOT EXISTS daily_pin_hash text;
