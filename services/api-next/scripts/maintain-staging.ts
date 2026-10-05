/**
 * Scheduled staging service maintenance, one group per run.
 *
 *   node --import tsx scripts/maintain-staging.ts <nightly|ask|defaults|no-shows>
 *
 * Same model as payment maintenance: no master key and no owner credential.
 * The run opens a short-lived session for the maintenance operator and calls
 * the staging API's own maintenance routes, so every batch gets the routes'
 * validation, authorization, receipts and audit. Service days are Accra days,
 * which is UTC.
 */
import { pathToFileURL } from 'node:url';
import pg from 'pg';
import { assertRuntimeRole } from '../src/runtime/compose.js';
import { failureLine, guarded, MaintenanceFailure } from './maintenance-safety.js';
import {
  paymentMaintenanceConfiguration,
  runStagingJobs,
  type StagingJob,
} from './maintain-staging-payments.js';

export const GROUPS = ['nightly', 'ask', 'defaults', 'no-shows'] as const;
export type Group = (typeof GROUPS)[number];

/** Trips exist this many days ahead, so asks and bookings always find them. */
const GENERATE_AHEAD_DAYS = 7;

const day = (now: Date, offset: number) =>
  new Date(now.getTime() + offset * 86_400_000).toISOString().slice(0, 10);

const bothDirections = (route: string, travelDate: string): StagingJob[] =>
  (['outbound', 'return'] as const).map((direction) => ({
    name: route,
    route,
    body: { travelDate, direction, limit: 100 },
  }));

export function scheduledJobs(group: Group, now: Date): StagingJob[] {
  switch (group) {
    case 'nightly':
      return [
        ...Array.from({ length: GENERATE_AHEAD_DAYS }, (_, i) => ({
          name: 'trip-generation',
          route: 'trip-generation',
          body: { serviceDate: day(now, i + 1), limit: 100 },
        })),
        ...['personal-pause-resumes', 'route-learning', 'gps-retention'].map((route) => ({
          name: route,
          route,
          body: { limit: 100 },
        })),
      ];
    // Ask tomorrow's riders at 21:00. The cutoff runs at midnight, when that
    // service day has become today: book the riders who did not answer.
    case 'ask':
      return bothDirections('ask-dispatch', day(now, 1));
    case 'defaults':
      return bothDirections('reservation-defaults', day(now, 0));
    // Late evening, after the last departure: settle today's no-shows.
    case 'no-shows':
      return bothDirections('no-shows', day(now, 0));
  }
}

async function main() {
  const group = process.argv[2];
  if (!GROUPS.includes(group as Group)) throw new MaintenanceFailure('configuration');
  const config = await guarded('configuration', async () =>
    paymentMaintenanceConfiguration(process.env),
  );
  const pool = new pg.Pool({
    connectionString: config.connectionString,
    ssl: config.ssl,
    max: 2,
    connectionTimeoutMillis: 10_000,
  });
  try {
    await guarded('database', () => assertRuntimeRole(pool));
    await runStagingJobs(
      pool,
      config.key,
      config.userId,
      scheduledJobs(group as Group, new Date()),
    );
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
