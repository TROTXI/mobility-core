// Daily-loop cron entrypoint (E3/E4). A Render cron job runs this at each point
// in the day: it mints a short-lived admin token from JWT_SECRET (auth is
// stateless — no user row needed) and POSTs the deployed API's admin trigger.
// Three actions x two directions (schedules live in render.yaml):
//   ask     morning (18:00) -> prompt tomorrow-morning riders  cutoff resolve 21:00
//   ask     evening (12:00) -> prompt this-evening riders      cutoff resolve 14:00
//   noshow  morning (10:00) -> debit confirmed-but-absent seats after the run
//   noshow  evening (20:00) -> same, after the evening run
// Ghana runs on UTC (GMT+0), so the cron schedules are plain UTC, no offset.
//
// Deliberately NOT scheduled: /admin/convert-credits. Its conversion is keyed by
// subscription id rather than by billing period, so it can only ever run once per
// subscription and would zero a rider who subscribed days earlier. It stays a
// manual admin action until E5b makes it period-aware (#128).

import { createJwtService, type AuthConfig } from '../modules/auth/jwt';

type Action = 'ask' | 'resolve' | 'noshow';
type Direction = 'morning' | 'evening';

const PATH_FOR: Record<Action, string> = {
  ask: '/admin/ask-dispatch',
  resolve: '/admin/resolve-defaults',
  noshow: '/admin/resolve-no-shows',
};

// Which travel day an action targets.
//
// ask/resolve run BEFORE travel: morning is asked (and defaulted) the evening
// before, for tomorrow; evening is asked midday, for today.
//
// noshow runs AFTER the run has departed, so it always sweeps the day that just
// happened — today for both directions. Getting this wrong would sweep a day
// whose trips have not run yet and debit riders who are not late, they are early.
// (The trip's own scheduled time still decides its direction.)
function travelDateFor(action: Action, direction: Direction, now: Date): string {
  const d = new Date(now);
  if (action !== 'noshow' && direction === 'morning') d.setUTCDate(d.getUTCDate() + 1);
  return d.toISOString().slice(0, 10);
}

const ACTIONS: readonly Action[] = ['ask', 'resolve', 'noshow'];
const DIRECTIONS: readonly Direction[] = ['morning', 'evening'];

function parseArgs(argv: readonly string[]): { action: Action; direction: Direction } {
  const [action, direction] = argv;
  if (!ACTIONS.includes(action as Action) || !DIRECTIONS.includes(direction as Direction)) {
    throw new Error(
      `usage: ask-dispatch-cron <${ACTIONS.join('|')}> <${DIRECTIONS.join('|')}> (got: "${argv.join(' ')}")`,
    );
  }
  return { action: action as Action, direction: direction as Direction };
}

async function main(): Promise<void> {
  const { action, direction } = parseArgs(process.argv.slice(2));

  const secret = process.env.JWT_SECRET;
  const baseUrl = process.env.API_BASE_URL;
  if (!secret) throw new Error('JWT_SECRET is required');
  if (!baseUrl) throw new Error('API_BASE_URL is required');

  const auth: AuthConfig = {
    secret,
    accessTtl: '5m',
    issuer: process.env.JWT_ISSUER ?? 'trotxi',
    audience: process.env.JWT_AUDIENCE ?? 'trotxi-api',
  };
  const token = await createJwtService(auth).signAccessToken({
    userId: 'cron-daily-loop',
    role: 'admin',
  });

  const travelDate = travelDateFor(action, direction, new Date());
  const url = `${baseUrl.replace(/\/$/, '')}${PATH_FOR[action]}`;
  const res = await fetch(url, {
    method: 'POST',
    headers: { authorization: `Bearer ${token}`, 'content-type': 'application/json' },
    body: JSON.stringify({ travelDate, direction }),
  });
  const body = await res.text();
  if (!res.ok) {
    throw new Error(`${action} ${direction} ${travelDate} -> HTTP ${res.status}: ${body}`);
  }
  console.log(`ask-dispatch cron: ${action} ${direction} ${travelDate} -> ${res.status} ${body}`);
}

main().catch((err: unknown) => {
  console.error('ask-dispatch cron failed:', err);
  process.exit(1);
});
