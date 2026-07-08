// Ask-dispatch cron entrypoint (E3). A Render cron job runs this at each
// confirmation window: it mints a short-lived admin token from JWT_SECRET (auth
// is stateless — no user row needed) and POSTs the deployed API's admin trigger.
// Two actions x two directions (schedules live in render.yaml):
//   ask morning  (18:00) -> prompt tomorrow-morning riders   cutoff resolve 21:00
//   ask evening  (12:00) -> prompt this-evening riders        cutoff resolve 14:00
// Ghana runs on UTC (GMT+0), so the cron schedules are plain UTC, no offset.

import { createJwtService, type AuthConfig } from '../modules/auth/jwt';

type Action = 'ask' | 'resolve';
type Direction = 'morning' | 'evening';

const PATH_FOR: Record<Action, string> = {
  ask: '/admin/ask-dispatch',
  resolve: '/admin/resolve-defaults',
};

// Morning is asked (and defaulted) the evening BEFORE, for tomorrow; evening is
// asked midday, for today. So the target travel day is tomorrow for morning and
// today for evening — the trip's own scheduled time still decides its direction.
function travelDateFor(direction: Direction, now: Date): string {
  const d = new Date(now);
  if (direction === 'morning') d.setUTCDate(d.getUTCDate() + 1);
  return d.toISOString().slice(0, 10);
}

function parseArgs(argv: readonly string[]): { action: Action; direction: Direction } {
  const [action, direction] = argv;
  if (
    (action !== 'ask' && action !== 'resolve') ||
    (direction !== 'morning' && direction !== 'evening')
  ) {
    throw new Error(
      `usage: ask-dispatch-cron <ask|resolve> <morning|evening> (got: "${argv.join(' ')}")`,
    );
  }
  return { action, direction };
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
    userId: 'cron-ask-dispatch',
    role: 'admin',
  });

  const travelDate = travelDateFor(direction, new Date());
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
