// Seed a deployed environment with a realistic pilot corridor, so the apps have
// something to build against. Staging starts empty after a database rebuild,
// which leaves the mobile team unable to develop route browsing, trip lists,
// the live map or the home screen.
//
// Talks to the real admin HTTP API (no direct DB access), so it works against
// any environment and exercises the same endpoints the ops dashboard will.
// Idempotent: it looks for the corridor by name first and reuses it, so
// re-running tops up trips instead of duplicating the fleet.
//
// Usage — JWT_SECRET is the deployed service's secret (Render dashboard):
//   JWT_SECRET=<secret> pnpm --filter @trotxi/api seed:staging
//   JWT_SECRET=<secret> API_BASE_URL=https://... pnpm --filter @trotxi/api seed:staging

import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

/* eslint-disable @typescript-eslint/no-explicit-any -- this script consumes the
   deployed API's JSON responses, which are untyped at this boundary; narrowing
   every field would bury the seeding logic without making it safer. */

const BASE = (process.env.API_BASE_URL ?? 'https://trotxi-api-staging.onrender.com').replace(
  /\/+$/,
  '',
);
const SECRET = process.env.JWT_SECRET;
const DAYS = Number(process.env.SEED_DAYS ?? 7);

if (!SECRET) {
  console.error('JWT_SECRET is required (copy it from the Render dashboard).');
  process.exit(1);
}

const auth: AuthConfig = {
  secret: SECRET,
  accessTtl: '15m',
  issuer: process.env.JWT_ISSUER ?? 'trotxi',
  audience: process.env.JWT_AUDIENCE ?? 'trotxi-api',
};

const ROUTE_NAME = 'Circle ⇄ Madina';

// Real Accra coordinates along the corridor, in boarding order.
const STOPS = [
  { name: 'Circle Interchange', latitude: 5.5717, longitude: -0.2107 },
  { name: 'Nkrumah Circle Overhead', latitude: 5.5771, longitude: -0.2044 },
  { name: 'Achimota Retail Centre', latitude: 5.6205, longitude: -0.2278 },
  { name: 'Legon Main Gate', latitude: 5.6508, longitude: -0.1869 },
  { name: 'Madina Market', latitude: 5.6686, longitude: -0.1665 },
];

let token = '';

/**
 * Call the API with the seeded admin token.
 *
 * @param method - HTTP method.
 * @param path - path beginning with a slash.
 * @param body - optional JSON body.
 * @returns the parsed response and its status.
 */
async function api(
  method: string,
  path: string,
  body?: unknown,
): Promise<{ status: number; json: any }> {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      authorization: `Bearer ${token}`,
      ...(body === undefined ? {} : { 'content-type': 'application/json' }),
    },
    ...(body === undefined ? {} : { body: JSON.stringify(body) }),
  });
  const text = await res.text();
  let json: unknown;
  try {
    json = JSON.parse(text);
  } catch {
    json = text.slice(0, 200);
  }
  return { status: res.status, json };
}

/**
 * Fail loudly with the server's own message — a silent partial seed is worse
 * than none, since the apps would build against half a corridor.
 *
 * @param label - what was being created.
 * @param res - the API response to check.
 * @returns the response body when successful.
 */
function must(label: string, res: { status: number; json: any }): any {
  if (res.status >= 300) {
    throw new Error(`${label} failed (HTTP ${res.status}): ${JSON.stringify(res.json)}`);
  }
  return res.json;
}

async function main(): Promise<void> {
  token = await createJwtService(auth).signAccessToken({
    userId: 'seed-admin',
    role: 'admin',
  });

  const health = await fetch(`${BASE}/readyz`);
  console.log(`${BASE} → readyz ${health.status}`);
  if (!health.ok) throw new Error('environment is not ready; check the database');

  // Route (idempotent: reuse the corridor if it is already there).
  const existing = must('list routes', await api('GET', '/routes'));
  const routes = Array.isArray(existing) ? existing : (existing.routes ?? []);
  let route = routes.find((r: { name: string }) => r.name === ROUTE_NAME);
  if (route) {
    console.log(`route: reusing ${route.name} (${route.id})`);
  } else {
    route = must(
      'create route',
      await api('POST', '/admin/routes', {
        name: ROUTE_NAME,
        description: 'Pilot corridor — morning and evening commuter runs',
      }),
    );
    console.log(`route: created ${route.name} (${route.id})`);
  }

  // Stops, attached in boarding order. Only add what is missing.
  const detail = must('read route', await api('GET', `/routes/${route.id}`));
  const already = new Set((detail.stops ?? []).map((s: { name: string }) => s.name));
  let seq = (detail.stops ?? []).length;
  for (const stop of STOPS) {
    if (already.has(stop.name)) {
      console.log(`  stop: ${stop.name} (already attached)`);
      continue;
    }
    const created = must(`create stop ${stop.name}`, await api('POST', '/admin/stops', stop));
    must(
      `attach ${stop.name}`,
      await api('POST', `/admin/routes/${route.id}/stops`, { stopId: created.id, seq }),
    );
    console.log(`  stop: ${stop.name} attached at seq ${seq}`);
    seq++;
  }

  // A small fleet.
  const vehicles = must('list vehicles', await api('GET', '/admin/vehicles'));
  const vlist = Array.isArray(vehicles) ? vehicles : (vehicles.vehicles ?? []);
  let vehicle = vlist.find((v: { registration: string }) => v.registration === 'GR-2417-26');
  if (!vehicle) {
    vehicle = must(
      'create vehicle',
      await api('POST', '/admin/vehicles', {
        registration: 'GR-2417-26',
        label: 'Blue Bird',
        capacity: 36,
      }),
    );
  }
  console.log(`vehicle: ${vehicle.registration} (${vehicle.id})`);

  const drivers = must('list drivers', await api('GET', '/admin/drivers'));
  const dlist = Array.isArray(drivers) ? drivers : (drivers.drivers ?? []);
  let driver = dlist.find((d: { fullName: string }) => d.fullName === 'Kwame Boateng');
  if (!driver) {
    driver = must(
      'create driver',
      await api('POST', '/admin/drivers', { fullName: 'Kwame Boateng' }),
    );
  }
  console.log(`driver: ${driver.fullName} (${driver.id})`);

  // Trips: a morning and an evening run for the next N days. The API's
  // direction heuristic reads the scheduled hour, so 06:30 and 17:30 UTC give
  // one of each (Ghana is UTC, so these are local times too).
  const today = new Date();
  let created = 0;
  let skipped = 0;
  for (let d = 0; d < DAYS; d++) {
    const day = new Date(today);
    day.setUTCDate(day.getUTCDate() + d);
    const date = day.toISOString().slice(0, 10);
    const onDay = must(
      'list trips',
      await api('GET', `/admin/trips?routeId=${route.id}&date=${date}`),
    );
    const tlist = Array.isArray(onDay) ? onDay : (onDay.trips ?? []);
    for (const hhmm of ['06:30', '17:30']) {
      const scheduledAt = `${date}T${hhmm}:00.000Z`;
      if (
        tlist.some((t: { scheduledAt: string }) => t.scheduledAt?.startsWith(`${date}T${hhmm}`))
      ) {
        skipped++;
        continue;
      }
      const trip = must(
        `create trip ${scheduledAt}`,
        await api('POST', '/admin/trips', {
          routeId: route.id,
          vehicleId: vehicle.id,
          scheduledAt,
        }),
      );
      must(
        'assign trip',
        await api('PUT', `/admin/trips/${trip.id}/assignment`, {
          assignedDriverId: driver.id,
          vehicleId: vehicle.id,
        }),
      );
      created++;
    }
  }
  console.log(`trips: ${created} created, ${skipped} already present (${DAYS} days)`);

  const finalRoutes = must('verify', await api('GET', '/routes'));
  const n = Array.isArray(finalRoutes) ? finalRoutes.length : (finalRoutes.routes?.length ?? 0);
  console.log(`\ndone — ${n} route(s) live at ${BASE}/routes`);
}

main().catch((err: unknown) => {
  console.error('seed failed:', err instanceof Error ? err.message : err);
  process.exit(1);
});
