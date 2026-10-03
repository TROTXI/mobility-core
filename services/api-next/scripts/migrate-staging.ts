/** Protected deployment installer. Owner credentials never reach the web service. */
import { fileURLToPath, pathToFileURL } from 'node:url';
import pg from 'pg';
import { grantRuntime, migrate, readMigrations } from '../src/db/migrate.js';
import { stagingDatabase } from '../src/runtime/staging-database.js';
import {
  assertMaintenanceIdentity,
  failureLine,
  guarded,
  maintenanceUserId,
} from './maintenance-safety.js';

export function stagingInstallerConfiguration(env: NodeJS.ProcessEnv) {
  const owner = stagingDatabase(
    env.STAGING_DATABASE_URL,
    env.STAGING_DATABASE_CA_CERT,
    'installer',
  );
  const runtime = stagingDatabase(env.STAGING_RUNTIME_DATABASE_URL, env.STAGING_DATABASE_CA_CERT);
  const worker = stagingDatabase(
    env.STAGING_MAINTENANCE_DATABASE_URL,
    env.STAGING_DATABASE_CA_CERT,
  );
  const roles = [...new Set([runtime, worker].map((db) => new URL(db.connectionString).username))];
  if (roles.length !== 2) throw new Error('API and maintenance require distinct restricted logins');
  return { owner, roles, userId: maintenanceUserId(env) };
}

async function main() {
  const config = await guarded('configuration', async () =>
    stagingInstallerConfiguration(process.env),
  );
  const pool = new pg.Pool({ ...config.owner, max: 1, connectionTimeoutMillis: 10_000 });
  try {
    await assertMaintenanceIdentity(pool, config.userId);
    // Staging is already installed. Refuse missing/unsafe roles before any DDL.
    for (const role of config.roles) await guarded('database', () => grantRuntime(pool, role));
    const files = await readMigrations(fileURLToPath(new URL('../migrations/', import.meta.url)));
    const installed = await guarded('database', () => migrate(pool, files));
    for (const role of config.roles) await guarded('database', () => grantRuntime(pool, role));
    process.stdout.write(`${JSON.stringify({ status: 'installed', count: installed.length })}\n`);
  } finally {
    await pool.end();
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    process.stderr.write(`${failureLine(error)}\n`);
    process.exitCode = 1;
  });
}
