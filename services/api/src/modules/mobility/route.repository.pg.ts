import type { Pool } from 'pg';
import type { NewRoute, Route, RouteRepository } from './route.repository';

interface RouteRow {
  id: string;
  name: string;
  description: string | null;
  created_at: Date;
}

function toRoute(row: RouteRow): Route {
  return {
    id: row.id,
    name: row.name,
    description: row.description,
    createdAt: row.created_at,
  };
}

export class PgRouteRepository implements RouteRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewRoute): Promise<Route> {
    const { rows } = await this.pool.query<RouteRow>(
      `INSERT INTO routes (name, description) VALUES ($1, $2) RETURNING *`,
      [input.name, input.description ?? null],
    );
    return toRoute(rows[0]!);
  }

  async findById(id: string): Promise<Route | null> {
    const { rows } = await this.pool.query<RouteRow>('SELECT * FROM routes WHERE id = $1', [id]);
    return rows[0] ? toRoute(rows[0]) : null;
  }

  async findAll(): Promise<Route[]> {
    const { rows } = await this.pool.query<RouteRow>('SELECT * FROM routes ORDER BY created_at');
    return rows.map(toRoute);
  }
}
