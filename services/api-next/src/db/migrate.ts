import { createHash } from 'node:crypto';
import { readFile, readdir } from 'node:fs/promises';
import { resolve } from 'node:path';
import type { Pool } from 'pg';

export interface Migration {
  name: string;
  sql: string;
  sha256: string;
}

export function migration(name: string, sql: string): Migration {
  return { name, sql, sha256: createHash('sha256').update(sql).digest('hex') };
}

export function validateMigrations(files: readonly Migration[]): void {
  if (!files.length) throw new Error('Replacement migration inventory must not be empty');
  for (const [index, file] of files.entries()) {
    if (!/^\d{3}_[a-z0-9_]+\.sql$/.test(file.name) || Number(file.name.slice(0, 3)) !== index + 1)
      throw new Error('Replacement migrations must be ordered, contiguous and uniquely numbered');
    if (!file.sql.trim() || file.sha256 !== migration(file.name, file.sql).sha256)
      throw new Error(`Invalid migration content: ${file.name}`);
  }
}

export async function readMigrations(directory: string): Promise<Migration[]> {
  const names = (await readdir(directory)).filter((name) => name.endsWith('.sql')).sort();
  const files = await Promise.all(
    names.map(async (name) => migration(name, await readFile(resolve(directory, name), 'utf8'))),
  );
  validateMigrations(files);
  return files;
}

// No dotenv, legacy chain, reset or down migration. Callers must pass the clean
// replacement DB explicitly. The session lock serializes installers, not traffic.
export async function migrate(pool: Pool, files: readonly Migration[]): Promise<string[]> {
  validateMigrations(files);
  const client = await pool.connect();
  let locked = false;
  try {
    await client.query(
      "SELECT pg_advisory_lock(hashtextextended('trotxi:replacement:migrations', 0))",
    );
    locked = true;
    await client.query('BEGIN');
    const marker = await client.query(
      "SELECT to_regclass('public._replacement_migrations') AS table_name",
    );
    if (!marker.rows[0].table_name) {
      // A namespace is not isolation: refuse an existing old or unknown model,
      // including objects outside public. Extension-owned PostGIS objects are OK.
      const objects = await client.query(`
        SELECT c.oid FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
          AND n.nspname NOT LIKE 'pg_toast%' AND n.nspname NOT LIKE 'pg_temp%'
          AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
          AND NOT EXISTS (SELECT 1 FROM pg_depend d WHERE d.classid = 'pg_class'::regclass
            AND d.objid = c.oid AND d.deptype = 'e') LIMIT 1`);
      if (objects.rowCount)
        throw new Error(
          'Clean installation refused: database already contains application objects',
        );
      await client.query(`CREATE TABLE public._replacement_migrations (
        name text PRIMARY KEY, sha256 text NOT NULL CHECK (sha256 ~ '^[a-f0-9]{64}$'),
        applied_at timestamptz NOT NULL DEFAULT clock_timestamp()
      )`);
    }
    const applied = await client.query<{ name: string; sha256: string }>(
      'SELECT name, sha256 FROM public._replacement_migrations ORDER BY name',
    );
    // Refuse changed, missing or reordered history before any new DDL.
    for (const [index, row] of applied.rows.entries()) {
      if (files[index]?.name !== row.name || files[index]?.sha256 !== row.sha256)
        throw new Error(`Applied replacement migration differs: ${row.name}`);
    }
    await client.query('COMMIT');
    const installed: string[] = [];
    for (const file of files.slice(applied.rows.length)) {
      await client.query('BEGIN');
      await client.query(file.sql);
      await client.query(
        'INSERT INTO public._replacement_migrations(name, sha256) VALUES ($1, $2)',
        [file.name, file.sha256],
      );
      await client.query('COMMIT');
      installed.push(file.name);
    }
    return installed;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    try {
      if (locked)
        await client.query(
          "SELECT pg_advisory_unlock(hashtextextended('trotxi:replacement:migrations', 0))",
        );
    } finally {
      client.release();
    }
  }
}

export function runtimeRoleIdentifier(name: string): string {
  if (!/^trotxi_runtime_[a-z0-9_]{1,40}$/.test(name))
    throw new Error('Use a dedicated trotxi_runtime_* role');
  return `"${name}"`;
}

// Provision credentials out of band. Never grant to the installer/owner or a
// role that can SET ROLE to it. No DELETE, TRUNCATE, DDL or migration-table access.
export async function grantRuntime(pool: Pool, role: string): Promise<void> {
  const quoted = runtimeRoleIdentifier(role);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const check = await client.query(
      `SELECT r.rolsuper OR r.rolcreatedb OR r.rolcreaterole
      OR r.rolreplication OR r.rolbypassrls OR pg_has_role(r.oid, current_user, 'MEMBER')
      OR pg_has_role(r.oid, d.datdba, 'MEMBER')
      OR has_database_privilege(r.oid, d.oid, 'CREATE')
      OR pg_has_role(r.oid, n.nspowner, 'MEMBER')
      OR EXISTS (SELECT 1 FROM pg_roles parent WHERE parent.oid <> r.oid
        AND pg_has_role(r.oid, parent.oid, 'MEMBER'))
      OR has_schema_privilege(r.oid, 'app', 'CREATE')
      OR has_schema_privilege(r.oid, 'public', 'CREATE')
      OR EXISTS (SELECT 1 FROM pg_class c WHERE c.relnamespace = n.oid AND c.relkind = 'r'
        AND (has_table_privilege(r.oid, c.oid, 'DELETE') OR has_table_privilege(r.oid, c.oid, 'TRUNCATE')
          OR pg_has_role(r.oid, c.relowner, 'MEMBER'))) AS unsafe
      FROM pg_roles r CROSS JOIN pg_database d CROSS JOIN pg_namespace n
      WHERE r.rolname = $1 AND d.datname = current_database() AND n.nspname = 'app'`,
      [role],
    );
    if (check.rows.length !== 1 || check.rows[0].unsafe)
      throw new Error('Runtime role must exist and be independent of the owner/installer');
    await client.query(`GRANT USAGE ON SCHEMA app TO ${quoted}`);
    await client.query(`GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA app TO ${quoted}`);
    // UPDATE is revoked on every append-only table, and the set is read from
    // the schema's own triggers rather than kept by hand here: a new event
    // table cannot ship with UPDATE still granted, and a table from a
    // migration that has not been installed yet is simply absent instead of
    // failing the grant. Two guards count: append_only refuses every rewrite,
    // and guard_driver_receipt refuses all but one-way ciphertext erasure,
    // which the column grant below re-opens. The list is a floor, not the
    // source: if one of these exists without that protection, the grant
    // refuses rather than leaving the runtime able to rewrite history.
    const required = [
      'trip_events',
      'schedule_events',
      'catalog_events',
      'transport_commands',
      'auth_commands',
      'driver_commands',
      'driver_events',
      'fleet_events',
      'purchase_legs',
      'credit_entries',
      'ride_entries',
      'credit_adjustments',
      'period_closures',
      'payment_collections',
      'payment_reversals',
      'payment_review_commands',
      'gps_events',
    ];
    const tables = await client.query<{ name: string; append_only: boolean }>(
      `SELECT c.relname AS name, EXISTS (
        SELECT 1 FROM pg_trigger g WHERE g.tgrelid = c.oid AND NOT g.tgisinternal
          AND g.tgfoid = ANY (ARRAY['app.append_only()', 'app.guard_driver_receipt()']::regprocedure[])
          AND (g.tgtype & 16) <> 0
      ) AS append_only
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'app' AND c.relkind = 'r' ORDER BY c.relname`,
    );
    // A required table that is simply not installed yet is absent from the
    // query, so only an installed one without its guard is an error.
    const unprotected = tables.rows.find((t) => required.includes(t.name) && !t.append_only);
    if (unprotected)
      throw new Error(`Append-only table without an UPDATE guard: ${unprotected.name}`);
    const appendOnly = tables.rows.filter((t) => t.append_only).map((t) => t.name);
    if (!appendOnly.length) throw new Error('Refusing to grant: no append-only history found');
    if (appendOnly.some((name) => !/^[a-z][a-z0-9_]*$/.test(name)))
      throw new Error('Unexpected table name in the app schema');
    await client.query(
      `REVOKE UPDATE ON ${appendOnly.map((name) => `app."${name}"`).join(', ')} FROM ${quoted}`,
    );
    await client.query(`GRANT UPDATE (secret_ciphertext) ON app.driver_commands TO ${quoted}`);
    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}
