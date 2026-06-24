import { Pool } from 'pg';

/** A shared Postgres connection pool, created from DATABASE_URL. */
export function createPool(connectionString: string): Pool {
  return new Pool({ connectionString });
}

export type { Pool };
