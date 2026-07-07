import type { Pool } from 'pg';
import { applyPatch } from '../../lib/patch';
import type { NewRoute, Route, RouteRepository, RouteUpdate } from './route.repository';

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

  // Partial update via read-modify-write: merge the patch over the current row,
  // then write the full editable set in one statement. This keeps the SQL static
  // (no dynamic column list) while letting a nullable field be cleared with an
  // explicit null — which COALESCE(col, $n) could not express.
  async update(id: string, patch: RouteUpdate): Promise<Route | null> {
    const existing = await this.findById(id);
    if (!existing) return null;
    const next = applyPatch(existing, patch);
    const { rows } = await this.pool.query<RouteRow>(
      `UPDATE routes SET name = $2, description = $3 WHERE id = $1 RETURNING *`,
      [id, next.name, next.description],
    );
    return rows[0] ? toRoute(rows[0]) : null;
  }
}
