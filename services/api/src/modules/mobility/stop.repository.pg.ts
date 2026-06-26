// Postgres stop adapter. Stops use PostGIS geography(Point, 4326) for the
// location column so spatial queries (nearest stop, route corridor) can run
// efficiently via the GiST index. The domain model exposes plain lat/lng
// numbers — ST_MakePoint and ST_X/ST_Y handle the conversion at the boundary.
// Note: ST_MakePoint takes (longitude, latitude) — X is longitude, Y is latitude.

import type { Pool } from 'pg';
import type { NewStop, Stop, StopRepository } from './stop.repository';

interface StopRow {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  created_at: Date;
}

function toStop(row: StopRow): Stop {
  return {
    id: row.id,
    name: row.name,
    latitude: row.latitude,
    longitude: row.longitude,
    createdAt: row.created_at,
  };
}

export class PgStopRepository implements StopRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewStop): Promise<Stop> {
    const { rows } = await this.pool.query<StopRow>(
      `INSERT INTO stops (name, location)
       VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326)::geography)
       RETURNING id, name, created_at,
         ST_Y(location::geometry) AS latitude,
         ST_X(location::geometry) AS longitude`,
      [input.name, input.longitude, input.latitude],
    );
    return toStop(rows[0]!);
  }

  async findById(id: string): Promise<Stop | null> {
    const { rows } = await this.pool.query<StopRow>(
      `SELECT id, name, created_at,
         ST_Y(location::geometry) AS latitude,
         ST_X(location::geometry) AS longitude
       FROM stops WHERE id = $1`,
      [id],
    );
    return rows[0] ? toStop(rows[0]) : null;
  }
}
