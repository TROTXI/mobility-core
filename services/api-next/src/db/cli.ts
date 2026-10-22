import { fileURLToPath } from 'node:url';
import pg from 'pg';
import { grantRuntime, migrate, readMigrations } from './migrate.js';
import { backendEnvironment } from '../runtime/environment.js';

const env = backendEnvironment(process.env);
if (!env.MIGRATION_DATABASE_URL)
  throw new Error('MIGRATION_DATABASE_URL is required; DATABASE_URL is deliberately ignored');
if (!env.RUNTIME_ROLE)
  throw new Error('RUNTIME_ROLE is required; provision a separate runtime role first');
const pool = new pg.Pool({ connectionString: env.MIGRATION_DATABASE_URL, max: 1 });
try {
  const files = await readMigrations(fileURLToPath(new URL('../../migrations/', import.meta.url)));
  const installed = await migrate(pool, files);
  await grantRuntime(pool, env.RUNTIME_ROLE);
  console.log(
    JSON.stringify({ installed, migrations: files.map(({ name, sha256 }) => ({ name, sha256 })) }),
  );
} finally {
  await pool.end();
}
