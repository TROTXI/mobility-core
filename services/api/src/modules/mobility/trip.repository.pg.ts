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
  started_at: Date | null;
  completed_at: Date | null;
  current_stop_seq: number | null;
  assignment_changed_at: Date | null;
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
    startedAt: row.started_at,
    completedAt: row.completed_at,
    currentStopSeq: row.current_stop_seq,
    assignmentChangedAt: row.assignment_changed_at,
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
    // Build the WHERE clause from whichever filters are present. `date` compares
    // the UTC calendar day, matching the in-memory adapter's toISOString().
    const where: string[] = [];
    const params: unknown[] = [];
    if (filter?.routeId) {
      params.push(filter.routeId);
      where.push(`route_id = $${params.length}`);
    }
    if (filter?.status) {
      params.push(filter.status);
      where.push(`status = $${params.length}`);
    }
    if (filter?.date) {
      params.push(filter.date);
      where.push(`(scheduled_at AT TIME ZONE 'UTC')::date = $${params.length}::date`);
    }
    // Same cast as `date`, for the same reason: the driver app sends corridor
    // time, and a range compared in the server's local zone would quietly return
    // a different month than the single-day filter does.
    if (filter?.from) {
      params.push(filter.from);
      where.push(`(scheduled_at AT TIME ZONE 'UTC')::date >= $${params.length}::date`);
    }
    if (filter?.to) {
      params.push(filter.to);
      where.push(`(scheduled_at AT TIME ZONE 'UTC')::date <= $${params.length}::date`);
    }
    const { rows } = await this.pool.query<TripRow>(
      `SELECT * FROM trips ${where.length ? `WHERE ${where.join(' AND ')}` : ''} ORDER BY scheduled_at`,
      params,
    );
    return rows.map(toTrip);
  }

  async update(id: string, patch: TripUpdate): Promise<Trip | null> {
    const existing = await this.findById(id);
    if (!existing) return null;
    const next = applyPatch(existing, patch);
    const { rows } = await this.pool.query<TripRow>(
      `UPDATE trips
         SET status = $2, scheduled_at = $3, vehicle_id = $4, assigned_driver_id = $5,
             started_at = $6, completed_at = $7, current_stop_seq = $8,
             assignment_changed_at = $9
       WHERE id = $1 RETURNING *`,
      [
        id,
        next.status,
        next.scheduledAt,
        next.vehicleId,
        next.assignedDriverId,
        next.startedAt,
        next.completedAt,
        next.currentStopSeq,
        next.assignmentChangedAt,
      ],
    );
    return rows[0] ? toTrip(rows[0]) : null;
  }

  async updateIfStatus(id: string, expected: TripStatus, patch: TripUpdate): Promise<Trip | null> {
    // Write only fields present in the patch. Reading the whole row and writing
    // it back would let a concurrent progress or assignment update be replaced
    // with values from the stale read, even though the status transition itself
    // remained atomic.
    const columns: ReadonlyArray<readonly [keyof TripUpdate, string]> = [
      ['status', 'status'],
      ['scheduledAt', 'scheduled_at'],
      ['vehicleId', 'vehicle_id'],
      ['assignedDriverId', 'assigned_driver_id'],
      ['startedAt', 'started_at'],
      ['completedAt', 'completed_at'],
      ['currentStopSeq', 'current_stop_seq'],
      ['assignmentChangedAt', 'assignment_changed_at'],
    ];
    const params: unknown[] = [id, expected];
    const assignments: string[] = [];
    for (const [key, column] of columns) {
      const value = patch[key];
      if (value === undefined) continue;
      params.push(value);
      assignments.push(`${column} = $${params.length}`);
    }

    if (assignments.length === 0) {
      const { rows } = await this.pool.query<TripRow>(
        'SELECT * FROM trips WHERE id = $1 AND status = $2',
        params,
      );
      return rows[0] ? toTrip(rows[0]) : null;
    }

    const { rows } = await this.pool.query<TripRow>(
      `UPDATE trips
          SET ${assignments.join(', ')}
        WHERE id = $1 AND status = $2
        RETURNING *`,
      params,
    );
    return rows[0] ? toTrip(rows[0]) : null;
  }
}
