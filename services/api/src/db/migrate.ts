import { readdir, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { Pool } from 'pg';
import { loadDotenv } from '../config/dotenv';

const __dirname = dirname(fileURLToPath(import.meta.url));
const MIGRATIONS_DIR = join(__dirname, 'migrations');

/**
 * Idempotent SQL migration runner. Applies every `*.sql` in `migrations/` in
 * filename order, once, inside a transaction, tracking applied files in a
 * `_migrations` table. Safe to run repeatedly (and on every deploy).
 */
async function migrate(): Promise<void> {
  loadDotenv();
  const connectionString = process.env['DATABASE_URL'];
  if (!connectionString) {
    throw new Error('DATABASE_URL is required to run migrations');
  }

  // Deploy-time migrations connect to the managed DB over the public network,
  // which requires TLS. Render's server cert isn't in Node's default CA bundle,
  // so we encrypt without verifying the chain. Local/CI runs against an internal
  // or container DB leave DATABASE_SSL unset and connect without TLS.
  const ssl = process.env['DATABASE_SSL'] === 'true' ? { rejectUnauthorized: false } : undefined;
  const pool = new Pool({ connectionString, ssl });
  try {
    await pool.query(
      `CREATE TABLE IF NOT EXISTS _migrations (
         name TEXT PRIMARY KEY,
         applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
       )`,
    );

    const { rows } = await pool.query<{ name: string }>('SELECT name FROM _migrations');
    const applied = new Set(rows.map((r) => r.name));

    const files = (await readdir(MIGRATIONS_DIR)).filter((f) => f.endsWith('.sql')).sort();

    for (const file of files) {
      if (applied.has(file)) {
        console.log(`= ${file} (already applied)`);
        continue;
      }
      const sql = await readFile(join(MIGRATIONS_DIR, file), 'utf8');
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        await client.query(sql);
        await client.query('INSERT INTO _migrations (name) VALUES ($1)', [file]);
        await client.query('COMMIT');
        console.log(`+ ${file} (applied)`);
      } catch (err) {
        await client.query('ROLLBACK');
        throw err;
      } finally {
        client.release();
      }
    }
    console.log('Migrations complete.');
  } finally {
    await pool.end();
  }
}

migrate().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
