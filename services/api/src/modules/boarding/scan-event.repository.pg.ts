import type { Pool } from 'pg';
import type {
  NewScanEvent,
  ScanEvent,
  ScanEventRepository,
  ScanMethod,
  ScanResult,
} from './scan-event.repository';

interface ScanEventRow {
  id: string;
  rider_id: string | null;
  scanned_by: string | null;
  trip_id: string | null;
  result: ScanResult;
  method: ScanMethod;
  created_at: Date;
}

function toScanEvent(row: ScanEventRow): ScanEvent {
  return {
    id: row.id,
    riderId: row.rider_id,
    scannedBy: row.scanned_by,
    tripId: row.trip_id,
    result: row.result,
    method: row.method,
    createdAt: row.created_at,
  };
}

export class PgScanEventRepository implements ScanEventRepository {
  constructor(private readonly pool: Pool) {}

  async record(input: NewScanEvent): Promise<ScanEvent> {
    const { rows } = await this.pool.query<ScanEventRow>(
      `INSERT INTO scan_events (rider_id, scanned_by, trip_id, result, method)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [input.riderId, input.scannedBy, input.tripId, input.result, input.method],
    );
    return toScanEvent(rows[0]!);
  }

  async listForRider(riderId: string): Promise<ScanEvent[]> {
    const { rows } = await this.pool.query<ScanEventRow>(
      `SELECT * FROM scan_events WHERE rider_id = $1 ORDER BY created_at DESC`,
      [riderId],
    );
    return rows.map(toScanEvent);
  }
}
