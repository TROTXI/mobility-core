-- 015_mobility_trips: the operational layer over routes (#18). A trip is one
-- scheduled run of a route by a vehicle and a driver. `assigned_driver_id` is
-- modelled now because it later authorizes GPS position reporting — only the
-- assigned driver may report a trip's live position (system-design §7, #25).
--
-- vehicle_id / assigned_driver_id are nullable: a trip can be scheduled before
-- ops assigns a bus and driver (#26). They ON DELETE SET NULL rather than
-- cascade so retiring a vehicle/driver never deletes historical trips; route_id
-- cascades to mirror route_stops (a route and its runs live and die together).

CREATE TABLE IF NOT EXISTS vehicles (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  registration text NOT NULL UNIQUE,          -- plate number (e.g. "GR-1234-24")
  label        text,                          -- human name (e.g. "Yutong #7")
  capacity     integer NOT NULL DEFAULT 0 CHECK (capacity >= 0),
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS drivers (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name      text NOT NULL,
  phone          text,
  license_number text,
  -- optional link to an auth principal; GPS authz (#25) resolves the signed-in
  -- user to a driver through this. Nullable until driver sign-in lands.
  user_id        uuid REFERENCES users (id) ON DELETE SET NULL,
  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS trips (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id           uuid NOT NULL REFERENCES routes (id) ON DELETE CASCADE,
  vehicle_id         uuid REFERENCES vehicles (id) ON DELETE SET NULL,
  assigned_driver_id uuid REFERENCES drivers (id) ON DELETE SET NULL,
  status             text NOT NULL DEFAULT 'scheduled'
                       CHECK (status IN ('scheduled', 'active', 'completed', 'cancelled')),
  scheduled_at       timestamptz NOT NULL,
  created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_trips_route ON trips (route_id);
-- driver index backs the GPS-authz lookup (#25): "trips assigned to this driver".
CREATE INDEX IF NOT EXISTS idx_trips_driver ON trips (assigned_driver_id);
CREATE INDEX IF NOT EXISTS idx_trips_scheduled ON trips (scheduled_at);
