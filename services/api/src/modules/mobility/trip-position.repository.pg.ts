// Postgres trip-position adapter (#25). Fixes are stored as PostGIS
// geography(Point, 4326); the domain model exposes plain lat/lng numbers, so
// ST_MakePoint / ST_X / ST_Y convert at the boundary (same as stops).
// Note: ST_MakePoint takes (longitude, latitude) — X is longitude, Y is latitude.

import type { Pool } from 'pg';
import type {
  NewTripPosition,
  TripPosition,
  TripPositionRepository,
} from './trip-position.repository';

interface TripPositionRow {
  id: string;
  trip_id: string;
  latitude: number;
  longitude: number;
  recorded_at: Date;
}

function toTripPosition(row: TripPositionRow): TripPosition {
  return {
    id: row.id,
    tripId: row.trip_id,
    latitude: row.latitude,
    longitude: row.longitude,
    recordedAt: row.recorded_at,
  };
}

export class PgTripPositionRepository implements TripPositionRepository {
  constructor(private readonly pool: Pool) {}

  async record(input: NewTripPosition): Promise<TripPosition> {
    const { rows } = await this.pool.query<TripPositionRow>(
      `INSERT INTO trip_positions (trip_id, location)
       VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326)::geography)
       RETURNING id, trip_id, recorded_at,
         ST_Y(location::geometry) AS latitude,
         ST_X(location::geometry) AS longitude`,
      [input.tripId, input.longitude, input.latitude],
    );
    return toTripPosition(rows[0]!);
  }

  async findLatest(tripId: string): Promise<TripPosition | null> {
    const { rows } = await this.pool.query<TripPositionRow>(
      `SELECT id, trip_id, recorded_at,
         ST_Y(location::geometry) AS latitude,
         ST_X(location::geometry) AS longitude
       FROM trip_positions
       WHERE trip_id = $1
       ORDER BY recorded_at DESC
       LIMIT 1`,
      [tripId],
    );
    return rows[0] ? toTripPosition(rows[0]) : null;
  }
}
