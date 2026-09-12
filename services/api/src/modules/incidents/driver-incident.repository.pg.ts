// Postgres {@link DriverIncidentRepository} (#226). Network adapter: excluded
// from unit coverage like the other *.pg.ts files, exercised by the e2e suite.

import type { Pool } from 'pg';
import type {
  DriverIncident,
  DriverIncidentRepository,
  IncidentCategory,
  IncidentDecision,
  IncidentStatus,
  NewDriverIncident,
} from './driver-incident.repository';

interface DriverIncidentRow {
  id: string;
  driver_id: string;
  trip_id: string | null;
  vehicle_id: string | null;
  category: IncidentCategory;
  note: string | null;
  lat: number | null;
  lng: number | null;
  status: IncidentStatus;
  handled_by: string | null;
  handled_at: Date | null;
  resolution: string | null;
  occurred_at: Date;
  created_at: Date;
  updated_at: Date;
}

/**
 * Map a row to the domain shape.
 *
 * @param row - the database row.
 * @returns the incident.
 */
function toIncident(row: DriverIncidentRow): DriverIncident {
  return {
    id: row.id,
    driverId: row.driver_id,
    tripId: row.trip_id,
    vehicleId: row.vehicle_id,
    category: row.category,
    note: row.note,
    lat: row.lat,
    lng: row.lng,
    status: row.status,
    handledBy: row.handled_by,
    handledAt: row.handled_at,
    resolution: row.resolution,
    occurredAt: row.occurred_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export class PgDriverIncidentRepository implements DriverIncidentRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewDriverIncident): Promise<DriverIncident> {
    const { rows } = await this.pool.query<DriverIncidentRow>(
      `INSERT INTO driver_incidents
         (driver_id, trip_id, vehicle_id, category, note, lat, lng, occurred_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, COALESCE($8, now()))
       RETURNING *`,
      [
        input.driverId,
        input.tripId ?? null,
        input.vehicleId ?? null,
        input.category,
        input.note ?? null,
        input.lat ?? null,
        input.lng ?? null,
        input.occurredAt ?? null,
      ],
    );
    return toIncident(rows[0]!);
  }

  async findById(id: string): Promise<DriverIncident | null> {
    const { rows } = await this.pool.query<DriverIncidentRow>(
      'SELECT * FROM driver_incidents WHERE id = $1',
      [id],
    );
    return rows[0] ? toIncident(rows[0]) : null;
  }

  async listForDriver(driverId: string): Promise<DriverIncident[]> {
    const { rows } = await this.pool.query<DriverIncidentRow>(
      'SELECT * FROM driver_incidents WHERE driver_id = $1 ORDER BY created_at DESC',
      [driverId],
    );
    return rows.map(toIncident);
  }

  async list(filter?: { status?: IncidentStatus }): Promise<DriverIncident[]> {
    const { rows } = await this.pool.query<DriverIncidentRow>(
      `SELECT * FROM driver_incidents
       WHERE ($1::text IS NULL OR status = $1)
       ORDER BY created_at DESC`,
      [filter?.status ?? null],
    );
    return rows.map(toIncident);
  }

  async decide(id: string, decision: IncidentDecision): Promise<DriverIncident | null> {
    // COALESCE on resolution so acknowledging a report does not wipe a note a
    // previous decision left on it.
    const { rows } = await this.pool.query<DriverIncidentRow>(
      `UPDATE driver_incidents
          SET status = $2, handled_by = $3, handled_at = now(),
              resolution = COALESCE($4, resolution), updated_at = now()
        WHERE id = $1
        RETURNING *`,
      [id, decision.status, decision.handledBy, decision.resolution ?? null],
    );
    return rows[0] ? toIncident(rows[0]) : null;
  }
}
