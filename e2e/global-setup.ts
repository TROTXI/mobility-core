// Runs once before the e2e suite. When DATABASE_URL is set (CI, or local after
// `pnpm infra:up`), it migrates a real Postgres and seeds a known user so the
// DB-backed specs can exercise the Postgres path. With no DATABASE_URL it's a
// no-op and those specs skip — local runs stay zero-infra.

import { execSync } from 'node:child_process';
import { Client } from 'pg';
import { SEED_USER } from './fixtures';

export default async function globalSetup(): Promise<void> {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    console.log('[e2e] No DATABASE_URL — running in-memory; DB-backed specs will skip.');
    return;
  }

  console.log('[e2e] Migrating e2e database…');
  execSync('pnpm --filter @trotxi/api run migrate', { stdio: 'inherit' });

  console.log('[e2e] Seeding fixture user…');
  const client = new Client({ connectionString });
  await client.connect();
  try {
    await client.query(
      `INSERT INTO users (id, display_name, role)
       VALUES ($1, $2, $3)
       ON CONFLICT (id) DO NOTHING`,
      [SEED_USER.id, SEED_USER.displayName, SEED_USER.role],
    );
  } finally {
    await client.end();
  }
}
