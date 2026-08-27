// Route-learning cron (#179, #181). Mints a short-lived admin token and POSTs
// /admin/learn-routes, which re-derives each corridor from completed runs.
//
// Separate from ask-dispatch-cron: that one is time-critical to the rider loop,
// this is a slow background improvement with no deadline.

import { createJwtService, type AuthConfig } from '../modules/auth/jwt';

interface LearnResult {
  routeId: string;
  runsUsed: number;
  geometryUpdated: boolean;
  segmentsLearned: { morning: number; evening: number };
}

async function main(): Promise<void> {
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
    userId: 'cron-route-learning',
    role: 'admin',
  });

  const url = `${baseUrl.replace(/\/$/, '')}/admin/learn-routes`;
  const res = await fetch(url, {
    method: 'POST',
    headers: { authorization: `Bearer ${token}`, 'content-type': 'application/json' },
    // No routeId — learn every corridor that has completed runs.
    body: JSON.stringify({}),
  });
  const body = await res.text();
  if (!res.ok) {
    throw new Error(`route learning -> HTTP ${res.status}: ${body}`);
  }

  // Log per route rather than a bare 200: "learned 3 routes" hides a corridor
  // that silently found no usable traces for a week.
  const parsed = JSON.parse(body) as { routes: LearnResult[] };
  for (const r of parsed.routes) {
    console.log(
      `route-learning: ${r.routeId} runs=${r.runsUsed} geometry=${r.geometryUpdated} ` +
        `segments=${r.segmentsLearned.morning}m/${r.segmentsLearned.evening}e`,
    );
  }
  console.log(`route-learning: ${parsed.routes.length} route(s) processed`);
}

main().catch((err: unknown) => {
  console.error('route learning cron failed:', err);
  process.exit(1);
});
