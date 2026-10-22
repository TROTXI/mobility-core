import pg from 'pg';
import { bootstrapSuperadmin } from '../src/auth/ops-bootstrap.js';
import { backendEnvironment } from '../src/runtime/environment.js';

const env = backendEnvironment(process.env);
const [userId, databaseName, confirmation] = process.argv.slice(2);
if (!userId || !databaseName || confirmation !== `confirm:${userId}` || !env.MIGRATION_DATABASE_URL)
  throw new Error(
    'Usage: bootstrap-superadmin.ts USER_UUID EXACT_DATABASE_NAME confirm:USER_UUID; requires installer MIGRATION_DATABASE_URL',
  );
const pool = new pg.Pool({ connectionString: env.MIGRATION_DATABASE_URL, max: 1 });
try {
  await bootstrapSuperadmin(pool, userId, databaseName);
  console.log('Superadmin bootstrap completed. Sign out and sign back in to refresh the console.');
} catch {
  console.error(
    'Bootstrap refused. Check the target database, existing admin passkey/session, bootstrap status and installer permissions.',
  );
  process.exitCode = 1;
} finally {
  await pool.end();
}
