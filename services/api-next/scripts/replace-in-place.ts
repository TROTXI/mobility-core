/**
 * Replace the old model in a database with the reviewed replacement schema.
 *
 * This deletes every application table in `public` and everything in them. It
 * is one way. Run it only against a database whose contents are genuinely
 * disposable, and only with the OWNER connection.
 *
 *   REPLACEMENT_DATABASE_URL=<owner> \
 *   REPLACE_IN_PLACE=i-have-read-this \
 *     node --import tsx scripts/replace-in-place.ts
 *
 * Without REPLACE_IN_PLACE it prints what it would drop and stops, which is
 * the way to look before leaping.
 *
 * It provisions the narrow runtime role itself, so there is no separate psql
 * step, and prints the service configuration to paste into the dashboard. Set
 * REPLACEMENT_RUNTIME_ROLE to use a name other than trotxi_runtime_v1.
 *
 * PostGIS is left alone: extension-owned relations are never dropped, so the
 * extension does not have to be reinstalled and `spatial_ref_sys` survives.
 * After the wipe this hands over to the ordinary installer, so the migrations
 * applied here are the same reviewed files with the same recorded hashes.
 */
import { spawnSync } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const rawUrl = process.env.REPLACEMENT_DATABASE_URL;
if (!rawUrl) throw new Error('REPLACEMENT_DATABASE_URL (the owner connection) is required');
const runtimeRole = process.env.REPLACEMENT_RUNTIME_ROLE ?? 'trotxi_runtime_v1';
const confirmed = process.env.REPLACE_IN_PLACE === 'i-have-read-this';

// A hosted database presents a certificate this client has no root for, and
// pg treats `sslmode=require` as full verification, so the honest default for
// a one-off admin connection is an encrypted channel without chain checking.
// Anything explicit in the URL wins.
const owner = new URL(rawUrl);
const local = owner.hostname === 'localhost' || owner.hostname === '127.0.0.1';
if (!owner.searchParams.has('sslmode') && !local) {
  owner.searchParams.set('sslmode', 'no-verify');
  process.stdout.write(
    'Connecting with sslmode=no-verify (encrypted, certificate not verified).\n',
  );
}
const ownerUrl = owner.href;

const KIND: Record<string, string> = {
  r: 'table',
  v: 'view ',
  m: 'matvw',
  S: 'seq  ',
  f: 'ftbl ',
};

// Quoted from the connection string rather than interpolated raw: this ends up
// in DDL that has no parameter form.
const dbIdent = `"${decodeURIComponent(owner.pathname.slice(1)).replace(/"/g, '""')}"`;
let runtimePassword = '';

const pool = new pg.Pool({ connectionString: ownerUrl, max: 1 });
try {
  const already = (
    await pool.query<{ installed: boolean }>(
      "SELECT to_regnamespace('app') IS NOT NULL AS installed",
    )
  ).rows[0];
  if (already?.installed)
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
              ).rows[0]?.n ?? 0,
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

  // The installer refuses to grant to the owner, so a second role has to exist
  // before it runs. Doing it here rather than in a separate psql step is the
  // difference between one command and four. The password is generated and
  // never read back, so an existing role is reset rather than guessed at.
  const existed = (
    await pool.query<{ n: number }>('SELECT count(*)::int AS n FROM pg_roles WHERE rolname = $1', [
      runtimeRole,
    ])
  ).rows[0];
  const quoted = `"${runtimeRole.replace(/"/g, '""')}"`;
  const password = randomBytes(24).toString('base64url');
  await pool.query(
    `${existed?.n ? 'ALTER' : 'CREATE'} ROLE ${quoted} ${existed?.n ? '' : 'LOGIN '}PASSWORD $1`.replace(
      '$1',
      `'${password.replace(/'/g, "''")}'`,
    ),
  );
  await pool.query(`REVOKE ALL ON DATABASE ${dbIdent} FROM ${quoted}`);
  await pool.query(`GRANT CONNECT ON DATABASE ${dbIdent} TO ${quoted}`);
  process.stdout.write(`${existed?.n ? 'Reset' : 'Created'} runtime role ${runtimeRole}.\n`);
  runtimePassword = password;
} finally {
  await pool.end();
}

// The ordinary installer from here: same files, same hashes, same grants. It
// gets the URL this script actually connected with, not the raw one, or it
// would rediscover the certificate problem on its own.
const cli = fileURLToPath(new URL('../src/db/cli.ts', import.meta.url));
const installed = spawnSync(process.execPath, ['--import', 'tsx', cli], {
  stdio: 'inherit',
  env: {
    ...process.env,
    REPLACEMENT_DATABASE_URL: ownerUrl,
    REPLACEMENT_RUNTIME_ROLE: runtimeRole,
  },
});
if (installed.status !== 0) {
  process.exitCode = installed.status ?? 1;
} else {
  // Everything the service needs that only this run can know, in the format
  // the dashboard's bulk editor accepts. The remaining values are ones this
  // script has no business inventing.
  const runtime = new URL(ownerUrl);
  runtime.username = encodeURIComponent(runtimeRole);
  runtime.password = encodeURIComponent(runtimePassword);
  runtime.searchParams.delete('sslmode');
  // Render's internal hostname is the first label of the external one. Using it
  // keeps the service off the public endpoint and out of the IP allowlist.
  const internal = /^dpg-[a-z0-9-]+\./.test(runtime.hostname)
    ? runtime.hostname.split('.')[0]
    : null;
  if (internal) runtime.hostname = internal;

  const generated: Record<string, string> = {
    REPLACEMENT_RUNTIME_DATABASE_URL: runtime.href,
  };
  for (const k of [
    'ACCESS_SECRET',
    'CURSOR_SECRET',
    'PIN_SECRET',
    'CREDENTIAL_REPLAY_KEY',
    'PROVIDER_ENCRYPTION_KEY',
    'BOARDING_PROOF_KEY',
    'DEVICE_KEY',
    'PAYSTACK_EVIDENCE_KEY',
  ])
    generated[`REPLACEMENT_${k}`] = randomBytes(32).toString('base64');

  // Printing these is right at a terminal the operator is sitting at, and
  // wrong in a CI log that is kept. When a destination is named, the values go
  // there and only the names are printed.
  const out = process.env.REPLACEMENT_CONFIG_OUT;
  if (out) {
    writeFileSync(out, JSON.stringify(generated, null, 2), { mode: 0o600 });
    process.stdout.write(`\nWrote ${Object.keys(generated).length} values to ${out}:\n`);
    for (const name of Object.keys(generated)) process.stdout.write(`  ${name}\n`);
  } else {
    process.stdout.write(
      `\n${'-'.repeat(70)}\n` +
        'Paste into Render > trotxi-api-staging > Environment > bulk edit:\n\n' +
        Object.entries(generated)
          .map(([k, v]) => `${k}=${v}`)
          .join('\n') +
        '\n\nThen add REPLACEMENT_PAYSTACK_SECRET_KEY (the sk_test one) and the four\n' +
        'REPLACEMENT_R2_* values, and deploy. Nothing else is required.\n' +
        `${'-'.repeat(70)}\n`,
    );
  }
  if (!internal)
    process.stdout.write(
      'NOTE: could not derive the internal host; the URL uses the public one.\n',
    );
}
