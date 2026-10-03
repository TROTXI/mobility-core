import pg from 'pg';
import { readErasureJournalConfiguration } from './runtime/config.js';
import { R2ErasureJournalStore } from './runtime/erasure-journal-store.js';
import { ErasureJournal } from './account/erasure-journal.js';
import { ErasureRecovery } from './account/erasure-recovery.js';

// No migration, restore, credential creation, HTTP server or normal worker.
// Provision/isolate out of band. Exact-name confirmation catches swapped URLs.
const [command, confirmDatabase, ...extra] = process.argv.slice(2);
const commands = ['initialize', 'fence', 'prepare', 'replay', 'promote'] as const;
if (
  !commands.includes(command as any) ||
  extra.length ||
  !confirmDatabase ||
  process.env.ERASURE_RECOVERY_APPROVED !== '1'
)
  throw new Error(
    'Usage: approved erasure-recovery-cli <initialize|fence|prepare|replay|promote> <exact-database-name>',
  );
const config = readErasureJournalConfiguration(process.env);
if (!config) throw new Error('Erasure journal configuration required');
const connectionString = process.env.ERASURE_RECOVERY_DATABASE_URL;
if (!connectionString) throw new Error('ERASURE_RECOVERY_DATABASE_URL required');
const deviceText = process.env.ERASURE_RECOVERY_DEVICE_KEY ?? '';
const deviceKey = /^[a-fA-F0-9]{64}$/.test(deviceText)
  ? Buffer.from(deviceText, 'hex')
  : Buffer.from(deviceText, 'base64');
if (deviceKey.length !== 32)
  throw new Error('ERASURE_RECOVERY_DEVICE_KEY must be the original 32-byte device key');
if (
  ['prepare', 'replay', 'promote'].includes(command!) &&
  process.env.ERASURE_RECOVERY_ISOLATED !== '1'
)
  throw new Error('Isolated restore acknowledgement required');
const pool = new pg.Pool({
  connectionString,
  max: 2,
  connectionTimeoutMillis: 5000,
  application_name: 'trotxi-erasure-recovery',
});
try {
  const row = (
    await pool.query(
      "SELECT current_database() AS name,pg_has_role(current_user,(SELECT nspowner FROM pg_namespace WHERE nspname='app'),'USAGE') AS owns_schema",
    )
  ).rows[0];
  if (row.name !== confirmDatabase || !row.owns_schema)
    throw new Error('Exact database name and owner role required');
  const tool = new ErasureRecovery(
    pool,
    new ErasureJournal(new R2ErasureJournalStore(config), config.namespace, config.key),
    deviceKey,
  );
  const result = await tool[command as (typeof commands)[number]]();
  process.stdout.write(JSON.stringify({ command, ...result }) + '\n');
} catch {
  // Never echo database/provider URLs, error details or personal identifiers.
  process.stderr.write(
    'Erasure recovery refused or failed. Keep source fenced and target isolated; review configuration and protected evidence.\n',
  );
  process.exitCode = 1;
} finally {
  await pool.end();
}
