import type { Pool } from 'pg';
import type { NewRouteStop, RouteStop, RouteStopRepository } from './route-stop.repository';

interface RouteStopRow {
  id: string;
  route_id: string;
  stop_id: string;
  seq: number;
  created_at: Date;
}

function toRouteStop(row: RouteStopRow): RouteStop {
  return {
    id: row.id,
    routeId: row.route_id,
    stopId: row.stop_id,
    seq: row.seq,
    createdAt: row.created_at,
  };
}

export class PgRouteStopRepository implements RouteStopRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewRouteStop): Promise<RouteStop> {
    const { rows } = await this.pool.query<RouteStopRow>(
      `INSERT INTO route_stops (route_id, stop_id, seq) VALUES ($1, $2, $3) RETURNING *`,
      [input.routeId, input.stopId, input.seq],
    );
    return toRouteStop(rows[0]!);
  }

  async findByRoute(routeId: string): Promise<RouteStop[]> {
    const { rows } = await this.pool.query<RouteStopRow>(
      `SELECT * FROM route_stops WHERE route_id = $1 ORDER BY seq`,
      [routeId],
    );
    return rows.map(toRouteStop);
  }
}
