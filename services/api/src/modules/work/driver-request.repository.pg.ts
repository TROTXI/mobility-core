// Postgres {@link DriverRequestRepository} (#232). Network adapter: excluded
// from unit coverage like the other *.pg.ts files, exercised by the e2e suite.

import type { Pool } from 'pg';
import type {
  DriverRequest,
  DriverRequestRepository,
  NewDriverRequest,
  RequestDecision,
  RequestKind,
  RequestStatus,
} from './driver-request.repository';

interface DriverRequestRow {
  id: string;
  driver_id: string;
  kind: RequestKind;
  status: RequestStatus;
  route_id: string | null;
  from_date: string | null;
  to_date: string | null;
  note: string | null;
  decided_by: string | null;
  decided_at: Date | null;
  decision_note: string | null;
  created_at: Date;
  updated_at: Date;
}

/**
 * Every SELECT goes through this, because of the two `::text` casts.
 *
 * node-postgres parses a `date` column into a JS Date at LOCAL midnight, so a
 * plain `SELECT *` would hand back a Date where the domain type says string, and
 * a server running anywhere but UTC would shift the day. Casting in SQL keeps
 * `YYYY-MM-DD` a string from end to end.
 */
const SELECT_COLUMNS = `id, driver_id, kind, status, route_id,
       from_date::text AS from_date, to_date::text AS to_date,
       note, decided_by, decided_at, decision_note, created_at, updated_at`;

/**
 * Map a row to the domain shape.
 *
 * @param row - the database row.
 * @returns the request.
 */
function toRequest(row: DriverRequestRow): DriverRequest {
  return {
    id: row.id,
    driverId: row.driver_id,
    kind: row.kind,
    status: row.status,
    routeId: row.route_id,
    fromDate: row.from_date,
    toDate: row.to_date,
    note: row.note,
    decidedBy: row.decided_by,
    decidedAt: row.decided_at,
    decisionNote: row.decision_note,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export class PgDriverRequestRepository implements DriverRequestRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewDriverRequest): Promise<DriverRequest> {
    const { rows } = await this.pool.query<DriverRequestRow>(
      `INSERT INTO driver_requests (driver_id, kind, route_id, from_date, to_date, note)
       VALUES ($1, $2, $3, $4::date, $5::date, $6)
       RETURNING ${SELECT_COLUMNS}`,
      [
        input.driverId,
        input.kind,
        input.routeId ?? null,
        input.fromDate ?? null,
        input.toDate ?? null,
        input.note ?? null,
      ],
    );
    return toRequest(rows[0]!);
  }

  async findById(id: string): Promise<DriverRequest | null> {
    const { rows } = await this.pool.query<DriverRequestRow>(
      `SELECT ${SELECT_COLUMNS} FROM driver_requests WHERE id = $1`,
      [id],
    );
    return rows[0] ? toRequest(rows[0]) : null;
  }

  async listForDriver(driverId: string): Promise<DriverRequest[]> {
    const { rows } = await this.pool.query<DriverRequestRow>(
      `SELECT ${SELECT_COLUMNS} FROM driver_requests
        WHERE driver_id = $1 ORDER BY created_at DESC`,
      [driverId],
    );
    return rows.map(toRequest);
  }

  async list(filter?: { status?: RequestStatus }): Promise<DriverRequest[]> {
    const { rows } = await this.pool.query<DriverRequestRow>(
      `SELECT ${SELECT_COLUMNS} FROM driver_requests
        WHERE ($1::text IS NULL OR status = $1)
        ORDER BY created_at DESC`,
      [filter?.status ?? null],
    );
    return rows.map(toRequest);
  }

  async decide(id: string, decision: RequestDecision): Promise<DriverRequest | null> {
    // `AND status = 'pending'` in the statement rather than a read-then-write:
    // two admins opening the same queue would otherwise both decide it, and the
    // second would silently overwrite who answered first.
    const { rows } = await this.pool.query<DriverRequestRow>(
      `UPDATE driver_requests
          SET status = $2, decided_by = $3, decided_at = now(),
              decision_note = $4, updated_at = now()
        WHERE id = $1 AND status = 'pending'
        RETURNING ${SELECT_COLUMNS}`,
      [id, decision.status, decision.decidedBy, decision.decisionNote ?? null],
    );
    return rows[0] ? toRequest(rows[0]) : null;
  }

  async withdraw(id: string, driverId: string): Promise<DriverRequest | null> {
    const { rows } = await this.pool.query<DriverRequestRow>(
      `UPDATE driver_requests
          SET status = 'withdrawn', updated_at = now()
        WHERE id = $1 AND driver_id = $2 AND status = 'pending'
        RETURNING ${SELECT_COLUMNS}`,
      [id, driverId],
    );
    return rows[0] ? toRequest(rows[0]) : null;
  }
}
