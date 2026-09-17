/**
 * Replace the old model in a database with the reviewed replacement schema.
 *
 * This deletes every application table in `public` and everything in them. It
 * is one way. Run it only against a database whose contents are genuinely
 * disposable, and only with the OWNER connection.
 *
 *   REPLACEMENT_DATABASE_URL=<owner>  \
 *   REPLACEMENT_RUNTIME_ROLE=trotxi_runtime_v1 \
 *   REPLACE_IN_PLACE=i-have-read-this \
 *     node --import tsx scripts/replace-in-place.ts
 *
 * Without REPLACE_IN_PLACE it prints what it would drop and stops, which is
 * the way to look before leaping.
 *
 * PostGIS is left alone: extension-owned relations are never dropped, so the
 * extension does not have to be reinstalled and `spatial_ref_sys` survives.
 * After the wipe this hands over to the ordinary installer, so the migrations
 * applied here are the same reviewed files with the same recorded hashes.
 */
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const ownerUrl = process.env.REPLACEMENT_DATABASE_URL;
const runtimeRole = process.env.REPLACEMENT_RUNTIME_ROLE;
if (!ownerUrl) throw new Error('REPLACEMENT_DATABASE_URL (the owner connection) is required');
if (!runtimeRole) throw new Error('REPLACEMENT_RUNTIME_ROLE is required');
const confirmed = process.env.REPLACE_IN_PLACE === 'i-have-read-this';

const KIND: Record<string, string> = {
  r: 'table',
  v: 'view ',
  m: 'matvw',
  S: 'seq  ',
  f: 'ftbl ',
};

const pool = new pg.Pool({ connectionString: ownerUrl, max: 1 });
try {
  const already = (await pool.query("SELECT to_regnamespace('app') IS NOT NULL AS installed"))
    .rows[0];
  if (already.installed)
    throw new Error('This database already has the app schema. Nothing to replace.');

  // Everything in public that no extension owns. An extension's own tables are
  // its business, not the old application model's.
  const doomed = (
    await pool.query<{ name: string; kind: string }>(`
      SELECT c.relname AS name, c.relkind AS kind
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'public' AND c.relkind IN ('r', 'v', 'm', 'S', 'f')
        AND NOT EXISTS (
          SELECT 1 FROM pg_depend d
          WHERE d.classid = 'pg_class'::regclass AND d.objid = c.oid AND d.deptype = 'e')
      ORDER BY c.relname`)
  ).rows;

  if (!doomed.length) {
    process.stdout.write('Nothing to drop: public holds no application relations.\n');
  } else {
    // Counted, not estimated: reltuples is -1 until a table has been analyzed,
    // and "~-1 rows" is not what anyone wants to read before deleting something.
    let total = 0;
    process.stdout.write(`${doomed.length} relations will be DROPPED from public:\n`);
    for (const r of doomed) {
      const rows =
        r.kind === 'r' || r.kind === 'm'
          ? Number(
              (
                await pool.query<{ n: string }>(
                  `SELECT count(*)::text AS n FROM public."${r.name.replace(/"/g, '""')}"`,
                )
              ).rows[0].n,
            )
          : null;
      if (rows !== null) total += rows;
      process.stdout.write(
        `  ${KIND[r.kind] ?? r.kind}  ${r.name.padEnd(34)}${rows === null ? '' : `${rows} rows`}\n`,
      );
    }
    process.stdout.write(`\n${total} rows in total will be deleted. This cannot be undone.\n`);
  }

  if (!confirmed) {
    process.stdout.write(
      '\nNothing was changed. Set REPLACE_IN_PLACE=i-have-read-this to proceed.\n',
    );
    process.exit(0);
  }

  // Drops every kind the preview listed, not just ordinary tables, so what the
  // preview promises is what actually happens. Views first, then the tables they
  // read; IF EXISTS because a CASCADE may already have taken a later entry.
  await pool.query(`DO $$ DECLARE r record; BEGIN
    FOR r IN SELECT c.relname, c.relkind FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'public' AND c.relkind IN ('v', 'm', 'f', 'r', 'S')
        AND NOT EXISTS (SELECT 1 FROM pg_depend d
          WHERE d.classid = 'pg_class'::regclass AND d.objid = c.oid AND d.deptype = 'e')
      ORDER BY CASE c.relkind WHEN 'v' THEN 1 WHEN 'm' THEN 2 WHEN 'f' THEN 3
                              WHEN 'r' THEN 4 ELSE 5 END
    LOOP EXECUTE format('DROP %s IF EXISTS public.%I CASCADE',
      CASE r.relkind WHEN 'v' THEN 'VIEW' WHEN 'm' THEN 'MATERIALIZED VIEW'
                     WHEN 'f' THEN 'FOREIGN TABLE' WHEN 'S' THEN 'SEQUENCE' ELSE 'TABLE' END,
      r.relname); END LOOP; END $$;`);
  process.stdout.write(`\nDropped ${doomed.length} relations.\n`);
} finally {
  await pool.end();
}

// The ordinary installer from here: same files, same hashes, same grants.
const cli = fileURLToPath(new URL('../src/db/cli.ts', import.meta.url));
const installed = spawnSync(process.execPath, ['--import', 'tsx', cli], {
  stdio: 'inherit',
  env: process.env,
});
process.exitCode = installed.status ?? 1;
