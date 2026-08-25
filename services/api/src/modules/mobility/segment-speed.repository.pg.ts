// Postgres segment-speed adapter (#181). Plain rows — no PostGIS here; the
// geometry lives on routes and this only records how fast we travel each
// stretch of it.

import type { Pool } from 'pg';
import type { SegmentSpeed } from './eta';
import type {
  SegmentSpeedRepository,
  SegmentSpeedRow,
  ServiceDirection,
} from './segment-speed.repository';

interface Row {
  from_seq: number;
  median_speed_ms: number;
  sample_count: number;
}

export class PgSegmentSpeedRepository implements SegmentSpeedRepository {
  constructor(private readonly pool: Pool) {}

  async findByRoute(
    routeId: string,
    direction: ServiceDirection,
  ): Promise<Map<number, SegmentSpeed>> {
    const { rows } = await this.pool.query<Row>(
      `SELECT from_seq, median_speed_ms, sample_count
         FROM segment_speeds
        WHERE route_id = $1 AND direction = $2`,
      [routeId, direction],
    );
    return new Map(
      rows.map((r) => [
        r.from_seq,
        {
          fromSeq: r.from_seq,
          metresPerSecond: Number(r.median_speed_ms),
          sampleCount: r.sample_count,
        },
      ]),
    );
  }

  async replace(
    routeId: string,
    direction: ServiceDirection,
    rows: readonly Omit<SegmentSpeedRow, 'routeId' | 'direction' | 'computedAt'>[],
  ): Promise<void> {
    const client = await this.pool.connect();
    try {
      // Delete-then-insert inside one transaction. A reader mid-aggregation
      // must never see a half-populated route: some segments recomputed, others
      // still on the previous window's medians.
      await client.query('BEGIN');
      await client.query('DELETE FROM segment_speeds WHERE route_id = $1 AND direction = $2', [
        routeId,
        direction,
      ]);
      for (const row of rows) {
        await client.query(
          `INSERT INTO segment_speeds (route_id, from_seq, direction, median_speed_ms, sample_count)
           VALUES ($1, $2, $3, $4, $5)`,
          [routeId, row.fromSeq, direction, row.medianSpeedMs, row.sampleCount],
        );
      }
      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }
}
