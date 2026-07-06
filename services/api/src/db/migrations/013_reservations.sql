-- 013_reservations: the daily ride confirmation (ADR-0014, epic E3). One row per
-- rider per travel day per direction (morning/evening): the rider confirms or
-- declines the trip, and at the cutoff any still-`pending` row defaults to
-- travelling (source 'default'). A verified boarding / no-show / operator-cancel
-- move it to a terminal state (E4/E6). trip_id has no FK yet — trips are #18.
CREATE TABLE IF NOT EXISTS reservations (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  trip_id      uuid,                       -- no FK yet (trips are #18)
  travel_date  date NOT NULL,
  direction    text NOT NULL CHECK (direction IN ('morning', 'evening')),
  status       text NOT NULL CHECK (status IN ('pending', 'reserved', 'declined', 'boarded', 'no_show', 'released', 'operator_cancelled')),
  source       text NOT NULL CHECK (source IN ('confirmation', 'default', 'standby')),
  confirmed_at timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  -- one reservation per rider per day per direction (the confirmation is a upsert)
  UNIQUE (user_id, travel_date, direction)
);
CREATE INDEX IF NOT EXISTS idx_reservations_user ON reservations (user_id);
CREATE INDEX IF NOT EXISTS idx_reservations_trip ON reservations (trip_id);
CREATE INDEX IF NOT EXISTS idx_reservations_date_dir ON reservations (travel_date, direction);
