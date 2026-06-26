-- 004_mobility_routes: routes, stops (PostGIS), and route_stops join table.

CREATE TABLE IF NOT EXISTS routes (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  description text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS stops (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text NOT NULL,
  location   geography(Point, 4326) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_stops_location ON stops USING GIST (location);

CREATE TABLE IF NOT EXISTS route_stops (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id   uuid NOT NULL REFERENCES routes (id) ON DELETE CASCADE,
  stop_id    uuid NOT NULL REFERENCES stops (id) ON DELETE CASCADE,
  seq        integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (route_id, seq)
);
CREATE INDEX IF NOT EXISTS idx_route_stops_route ON route_stops (route_id);
