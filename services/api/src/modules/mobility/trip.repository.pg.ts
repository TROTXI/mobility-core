import type { Pool } from 'pg';
import { applyPatch } from '../../lib/patch';
import type {
  NewTrip,
  Trip,
  TripFilter,
  TripRepository,
  TripStatus,
  TripUpdate,
} from './trip.repository';

interface TripRow {
  id: string;
  route_id: string;
  vehicle_id: string | null;
  assigned_driver_id: string | null;
  status: TripStatus;
  scheduled_at: Date;
  created_at: Date;
}

function toTrip(row: TripRow): Trip {
  return {
    id: row.id,
    routeId: row.route_id,
    vehicleId: row.vehicle_id,
    assignedDriverId: row.assigned_driver_id,
    status: row.status,
    scheduledAt: row.scheduled_at,
    createdAt: row.created_at,
  };
}

export class PgTripRepository implements TripRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewTrip): Promise<Trip> {
    const { rows } = await this.pool.query<TripRow>(
      `INSERT INTO trips (route_id, vehicle_id, assigned_driver_id, status, scheduled_at)
       VALUES ($1, $2, $3, COALESCE($4, 'scheduled'), $5) RETURNING *`,
      [
        input.routeId,
        input.vehicleId ?? null,
        input.assignedDriverId ?? null,
        input.status ?? null,
        input.scheduledAt,
      ],
    );
    return toTrip(rows[0]!);
  }

  async findById(id: string): Promise<Trip | null> {
    const { rows } = await this.pool.query<TripRow>('SELECT * FROM trips WHERE id = $1', [id]);
    return rows[0] ? toTrip(rows[0]) : null;
  }

  async findAll(filter?: TripFilter): Promise<Trip[]> {
    // routeId is the only filter today (GET /trips?routeId); build the WHERE
    // clause conditionally so the unfiltered list stays a plain scan + sort.
    const { rows } = filter?.routeId
      ? await this.pool.query<TripRow>(
          'SELECT * FROM trips WHERE route_id = $1 ORDER BY scheduled_at',
          [filter.routeId],
        )
      : await this.pool.query<TripRow>('SELECT * FROM trips ORDER BY scheduled_at');
    return rows.map(toTrip);
  }

  async update(id: string, patch: TripUpdate): Promise<Trip | null> {
    const existing = await this.findById(id);
    if (!existing) return null;
    const next = applyPatch(existing, patch);
    const { rows } = await this.pool.query<TripRow>(
      `UPDATE trips
         SET status = $2, scheduled_at = $3, vehicle_id = $4, assigned_driver_id = $5
       WHERE id = $1 RETURNING *`,
      [id, next.status, next.scheduledAt, next.vehicleId, next.assignedDriverId],
    );
    return rows[0] ? toTrip(rows[0]) : null;
  }
}
