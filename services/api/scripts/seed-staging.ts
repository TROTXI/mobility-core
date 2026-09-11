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
import { paystackSignature } from '../src/modules/payments/paystack.client';

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

// Corridor fare in pesewas. Since #103 a route without a fare in force cannot be
// subscribed to at all — POST /payments/subscribe returns 409 not_priced — so a
// seeded environment without one looks complete right up until checkout.
//
// A PLACEHOLDER, like everything else this script creates. GHS 6 is a plausible
// Accra trotro fare; the real number comes from the union rate for the corridor
// and is ops' to set. Override with SEED_FARE_PESEWAS.
const FARE_PESEWAS = Number(process.env.SEED_FARE_PESEWAS ?? 600);

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
 * Call the API as somebody other than the seeded admin.
 *
 * @param bearer - the caller's access token.
 * @param method - HTTP method.
 * @param path - path beginning with a slash.
 * @param body - optional JSON body.
 * @returns the parsed response and its status.
 */
async function apiAs(
  bearer: string,
  method: string,
  path: string,
  body?: unknown,
): Promise<{ status: number; json: any }> {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      authorization: `Bearer ${bearer}`,
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

/**
 * Give the seeded driver a code and PIN so the driver app can actually be
 * signed into (#223).
 *
 * Printed to this console and nowhere else: the API returns the PIN exactly
 * once and stores only a keyed hash, so there is no reading it back later.
 *
 * A driver who already has a credential answers 409, in which case the PIN is
 * reset instead. That has to target the SAME driver: they are the one the
 * seeded runs are assigned to, and handing back a fresh throwaway driver would
 * print a pair that signs in to an empty day.
 *
 * @param driver - the corridor's assigned driver.
 */
async function issueDriverCredential(driver: any): Promise<void> {
  let issued = await api('POST', `/admin/drivers/${driver.id}/credentials`, undefined);
  let reset = false;

  if (issued.status === 409) {
    issued = await api('POST', `/admin/drivers/${driver.id}/credentials/reset-pin`, undefined);
    reset = true;
  }

  const credential = must('issue driver credential', issued);
  console.log('');
  console.log('driver sign-in — type these into the driver app:');
  console.log(`  name        ${driver.fullName}`);
  console.log(`  driver code ${credential.driverCode}`);
  console.log(`  PIN         ${credential.pin}`);
  console.log('  (the PIN is shown ONCE; the API keeps only a keyed hash)');
  if (reset) {
    console.log('  NB: this driver already had a credential, so the PIN was RESET.');
    console.log('      Any session signed in on the old one has been revoked.');
  }
  console.log('  First sign-in forces a PIN change, which is the flow to test.');
  console.log('');
}

/** How many riders to put on each seeded run. */
const RIDERS_PER_TRIP = Number(process.env.SEED_RIDERS ?? 4);

/** The fake Paystack client's shared secret (paystack.client.ts). */
const FAKE_PAYSTACK_SECRET = 'fake-paystack-secret';

/**
 * Put confirmed riders on a run, so the manifest and boarding have something
 * to act on.
 *
 * Only possible outside production, and deliberately so: it signs riders in
 * through the DEV FAKE id-token verifier and settles their subscription through
 * the FAKE Paystack client. Both are absent when NODE_ENV=production, which is
 * why this degrades with a message rather than failing the seed — staging is
 * production-mode and has real verifiers, so riders there have to come from
 * real sign-ins.
 *
 * The whole chain is walked rather than shortcut, because the paywall added in
 * #221 means a reservation is only possible for a rider who actually holds an
 * active membership with rides left on the corridor being travelled. Faking a
 * reservation row straight into the database would seed a state the API itself
 * would never produce.
 *
 * @param route - the corridor.
 * @param stops - the corridor's stops in seq order.
 * @param trips - the runs to fill.
 * @returns the confirmed seats, with the boarding code each rider would read
 *   out. The API returns that code exactly once, on the confirming response,
 *   and stores only a keyed hash, so capturing it here is the only way the
 *   board-by-code screen can be exercised.
 */
async function seedRiders(
  route: any,
  stops: any[],
  trips: { id: string; scheduledAt: string }[],
): Promise<{ name: string; code: string }[]> {
  if (trips.length === 0 || stops.length < 2) return [];

  const confirmed: { name: string; code: string }[] = [];
  for (const [tripIndex, trip] of trips.entries()) {
    const scheduled = new Date(trip.scheduledAt);
    const travelDate = trip.scheduledAt.slice(0, 10);
    // The API reads the scheduled hour to pick a direction; match it here or the
    // reservation lands on the other half of the day and the manifest is empty.
    const direction = scheduled.getUTCHours() < 12 ? 'morning' : 'evening';

    for (let i = 0; i < RIDERS_PER_TRIP; i++) {
      const sub = `seed-rider-${tripIndex}-${i}`;
      const name = `Seed Rider ${tripIndex + 1}.${i + 1}`;

      // 1. Sign in through the dev fake verifier.
      const signIn = await api('POST', '/auth/google', {
        idToken: JSON.stringify({ sub, email: `${sub}@example.test`, name }),
      });
      if (signIn.status === 503 || signIn.status === 401) {
        console.log(
          `riders: skipped — ${BASE} has no dev sign-in verifier ` +
            '(production mode). Seed riders only work against a local or dev API.',
        );
        return confirmed;
      }
      const token = must('rider sign-in', signIn).accessToken as string;

      // 2. Buy a membership on this corridor.
      const checkout = await apiAs(token, 'POST', '/payments/subscribe', {
        plan: 'monthly',
        routeId: route.id,
        pickupStopId: stops[0].id,
        dropoffStopId: stops[stops.length - 1].id,
      });
      if (checkout.status === 503) {
        console.log('riders: skipped — payments are not configured on this environment.');
        return confirmed;
      }
      // 409 means this rider already has an active membership from a previous
      // run of the seed, which is fine: they can still confirm a seat.
      if (checkout.status < 300) {
        const { reference, chargePesewas } = must('checkout', checkout);

        // 3. Settle it. Amount and currency have to match the checkout exactly
        //    or the webhook refuses to grant anything (#221).
        const payload = JSON.stringify({
          event: 'charge.success',
          data: { reference, status: 'success', amount: chargePesewas, currency: 'GHS' },
        });
        const webhook = await fetch(`${BASE}/webhooks/paystack`, {
          method: 'POST',
          headers: {
            'content-type': 'application/json',
            'x-paystack-signature': paystackSignature(payload, FAKE_PAYSTACK_SECRET),
          },
          body: payload,
        });
        if (webhook.status === 401) {
          console.log(
            'riders: skipped — the webhook signature was rejected, so this ' +
              'environment is running a REAL Paystack key rather than the dev fake.',
          );
          return confirmed;
        }
      }

      // 4. Confirm the seat.
      const reservation = await apiAs(token, 'POST', '/me/reservations', {
        tripId: trip.id,
        travelDate,
        direction,
        travelling: true,
      });
      if (reservation.status === 402) {
        console.log(`riders: ${name} refused (${reservation.json?.error}) — skipping the rest.`);
        return confirmed;
      }
      if (reservation.status === 409) continue; // run is full
      const seat = must('confirm reservation', reservation);
      if (seat.pin) confirmed.push({ name, code: seat.pin as string });
    }
  }
  return confirmed;
}

async function main(): Promise<void> {
  token = await createJwtService(auth).signAccessToken({
    userId: 'seed-admin',
    role: 'admin',
  });

  const health = await fetch(`${BASE}/readyz`);
  console.log(`${BASE} → readyz ${health.status}`);
  if (!health.ok) throw new Error('environment is not ready; check the database');

  // Check the minted token BEFORE doing any work. Route and stop reads are
  // public, so without this the first six lines of output look like a healthy
  // run and the failure lands on "list vehicles failed (HTTP 401)" — which
  // reads as a broken endpoint rather than the one thing it actually is.
  const preflight = await api('GET', '/admin/vehicles');
  if (preflight.status === 401) {
    throw new Error(
      `the admin token was rejected, so JWT_SECRET does not match ${BASE}.\n` +
        '  - Copy it from Render → trotxi-api-staging → Environment → JWT_SECRET.\n' +
        '  - Check for a trailing newline or space: shells keep them, the HMAC does not forgive them.\n' +
        '  - trotxi-ops-staging has its own JWT_SECRET that must EQUAL this one; ' +
        'if they have drifted, one of the two is the wrong value to be using here.',
    );
  }
  must('preflight', preflight);

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

  await issueDriverCredential(driver);

  // Trips: a morning and an evening run for the next N days. The API's
  // direction heuristic reads the scheduled hour, so 06:30 and 17:30 UTC give
  // one of each (Ghana is UTC, so these are local times too).
  const today = new Date();
  let created = 0;
  let skipped = 0;
  // Today's runs, collected so riders can be put on them below. Reusing the
  // ones already present matters: a re-run must fill the SAME trips the driver
  // sees rather than a fresh set nobody is assigned to.
  const todaysTrips: { id: string; scheduledAt: string }[] = [];
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
      const existing = tlist.find((t: { scheduledAt: string }) =>
        t.scheduledAt?.startsWith(`${date}T${hhmm}`),
      );
      if (existing) {
        skipped++;
        if (d === 0) todaysTrips.push({ id: existing.id, scheduledAt: existing.scheduledAt });
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
      if (d === 0) todaysTrips.push({ id: trip.id, scheduledAt });
    }
  }
  console.log(`trips: ${created} created, ${skipped} already present (${DAYS} days)`);

  // Re-read the corridor so the stops are in seq order with their ids, which is
  // what a rider's pickup and drop-off have to be chosen from.
  const seeded = must('read route stops', await api('GET', `/routes/${route.id}`));
  const confirmed = await seedRiders(route, seeded.stops ?? [], todaysTrips);
  if (confirmed.length > 0) {
    console.log(`riders: ${confirmed.length} confirmed seat(s) across today's runs`);
    console.log('');
    console.log('boarding codes — what a rider reads out at the door:');
    for (const seat of confirmed) {
      console.log(`  ${seat.code}  ${seat.name}`);
    }
    console.log('');
  }

  // Price the corridor. Idempotent by intent rather than by accident: setting an
  // identical fare would close the current row and open a new one, growing the
  // history with changes that never happened, so re-running only writes when the
  // fare actually differs.
  const fares = must('read fares', await api('GET', `/admin/routes/${route.id}/fares`));
  const current = (fares.fares ?? []).find((f: { effectiveTo: string | null }) => !f.effectiveTo);
  if (current?.farePesewas === FARE_PESEWAS) {
    console.log(`fare: unchanged at ${FARE_PESEWAS} pesewas`);
  } else {
    must(
      'set fare',
      await api('PUT', `/admin/routes/${route.id}/fare`, {
        farePesewas: FARE_PESEWAS,
        note: 'seed placeholder — replace with the corridor’s union rate',
      }),
    );
    console.log(`fare: set to ${FARE_PESEWAS} pesewas (GHS ${(FARE_PESEWAS / 100).toFixed(2)})`);
  }

  const finalRoutes = must('verify', await api('GET', '/routes'));
  const n = Array.isArray(finalRoutes) ? finalRoutes.length : (finalRoutes.routes?.length ?? 0);
  console.log(`\ndone — ${n} route(s) live at ${BASE}/routes`);
  console.log(
    'NB: the fare is a placeholder. Set the real corridor rate via ' +
      `PUT ${BASE}/admin/routes/${route.id}/fare`,
  );
}

main().catch((err: unknown) => {
  console.error('seed failed:', err instanceof Error ? err.message : err);
  process.exit(1);
});
