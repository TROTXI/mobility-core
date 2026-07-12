// Endpoint test console — a live, visual API walkthrough for the team.
//
// Boots the REAL API (buildApp, in-memory repos, dev auth, fake Paystack) and
// runs comprehensive test cases against it suite by suite: platform, sign-in +
// RBAC, fleet setup, payments + entitlements, reservations + ask-dispatch,
// boarding, no-show + credits, live positions, and guardrails (validation +
// rate limiting). Every case records the real request, the real response, and
// a pass/fail verdict against the documented contract.
//
// The same app instance also LISTENS on :3001, so Swagger UI at
// http://localhost:3001/docs works against the live in-memory state using the
// pre-minted tokens shown on the dashboard.
//
// Run: pnpm --filter @trotxi/api demo:endpoints  →  http://localhost:4400

import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../src/app';
import { InMemoryKvStore } from '../src/kv/kv.store';
import { FakeObjectStore } from '../src/storage/object-store';
import { createJwtService, DEV_AUTH_CONFIG } from '../src/modules/auth/jwt';
import { AuthService } from '../src/modules/auth/auth.service';
import { FakeIdTokenVerifier } from '../src/modules/auth/id-token-verifier';
import { InMemoryAuthIdentityRepository } from '../src/modules/auth/auth-identity.repository';
import { InMemorySessionRepository } from '../src/modules/auth/session.repository';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryTripPositionRepository } from '../src/modules/mobility/trip-position.repository';
import { InMemoryVehicleRepository } from '../src/modules/mobility/vehicle.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryScanEventRepository } from '../src/modules/boarding/scan-event.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { InMemoryCreditLedgerRepository } from '../src/modules/entitlements/credit-ledger.repository';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemoryFeatureFlagRepository } from '../src/modules/flags/feature-flag.repository';
import { InMemoryMinVersionRepository } from '../src/modules/flags/min-version.repository';
import { InMemoryDeviceTokenRepository } from '../src/modules/devices/device-token.repository';
import { BoardingService } from '../src/modules/boarding/boarding.service';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import {
  PaymentsService,
  PLACEHOLDER_RIDES_PER_PERIOD,
  SUBSCRIPTION_FEES_PESEWAS,
} from '../src/modules/payments/payments.service';

const PAYSTACK_SECRET = 'fake-paystack-secret';
const API_PORT = Number(process.env.DEMO_API_PORT ?? 3001);
const UI_PORT = Number(process.env.DEMO_PORT ?? 4400);
const jwt = createJwtService(DEV_AUTH_CONFIG);
const today = () => new Date().toISOString().slice(0, 10);

/* eslint-disable @typescript-eslint/no-explicit-any -- responses are asserted
   dynamically against the live contract; `any` keeps the case table readable */

/** One executed case: the real request, the real response, the verdict. */
interface CaseResult {
  name: string;
  method: string;
  path: string;
  /** Normalised endpoint pattern, e.g. GET /trips/:id/position. */
  endpoint: string;
  /** One-line description of what this endpoint does (for the dashboard). */
  doc: string;
  requestBody?: unknown;
  as?: string;
  status: number;
  ms: number;
  expected: string;
  pass: boolean;
  response: unknown;
}

/** What each endpoint is for — shown under every case on the dashboard. */
const ENDPOINT_DOCS: Record<string, string> = {
  'GET /version': 'Build metadata: service name, version and deployed commit.',
  'GET /healthz': 'Liveness probe — is the process up. Used by Render health checks.',
  'GET /readyz': 'Readiness probe — pings Postgres and the KV store before traffic is routed.',
  'GET /flags': 'Public feature flags + minimum supported app version (drives force-update).',
  'GET /docs/json':
    'The machine-readable OpenAPI 3 contract — powers Swagger UI and client codegen.',
  'POST /auth/google':
    'Social sign-in: verifies a Google ID token, upserts the user, returns access + refresh tokens.',
  'POST /auth/refresh':
    'Rotates the refresh token and issues a fresh access token — role changes take effect here.',
  'GET /me': "The authenticated user's own profile (id, name, role).",
  'GET /admin/routes': 'Admin: list all corridors (role admin required).',
  'PATCH /admin/users/:id/role':
    'Admin: grant a role — turns a signed-in account into a driver or admin.',
  'POST /admin/routes': 'Admin: create a corridor (route).',
  'POST /admin/stops': 'Admin: create a geo-located stop (PostGIS point in production).',
  'POST /admin/routes/:id/stops':
    'Admin: attach a stop to a route at a boarding-order position (seq).',
  'POST /admin/vehicles': 'Admin: register a vehicle — capacity feeds occupancy planning.',
  'POST /admin/drivers': 'Admin: register a driver, linked to their signed-in user account.',
  'POST /admin/trips': 'Admin: schedule a run of a route; the time decides morning vs evening.',
  'PUT /admin/trips/:id/assignment':
    'Admin: assign driver + vehicle — this is what authorises GPS reporting and manifest access.',
  'GET /routes/:id': 'Public route detail with stops in boarding order — browsable before sign-in.',
  'GET /trips': 'Rider-facing trip list, filterable by route.',
  'GET /trips/:id': 'Trip detail (status, schedule, route).',
  'POST /payments/subscribe':
    'Start a Paystack checkout for the membership plan; returns the hosted checkout URL.',
  'POST /webhooks/paystack':
    'Paystack calls back here on payment events — HMAC-verified; activates the subscription and allocates rides.',
  'GET /me/rides': "The rider's ledger balances: remaining rides + Ride Credits (pesewas).",
  'POST /admin/ask-dispatch':
    'The daily "travelling?" fan-out: seeds a pending reservation + push for every subscriber (cron-driven).',
  'POST /me/reservations':
    'Rider confirms or declines a leg; confirming issues the daily 4-digit boarding PIN.',
  'POST /admin/resolve-defaults': 'Cutoff sweep: riders who never replied default to travelling.',
  'GET /me/reservations': "The rider's reservations, newest travel day first.",
  'GET /me/pass':
    'Issues the rotating, single-use QR boarding pass (60 s TTL, signed, one scan only).',
  'POST /boarding/scan':
    "Driver verifies a rider's QR pass — boards the reservation and debits one ride.",
  'GET /boarding/manifest':
    "The trip's confirmed riders with photos — the assigned driver's checklist.",
  'POST /boarding/verify-pin':
    'Boards a rider by their daily PIN against the manifest — no camera needed.',
  'POST /admin/resolve-no-shows':
    'Cutoff sweep: confirmed-but-absent seats are debited (the seat was held).',
  'POST /admin/convert-credits':
    'Month-end conversion: every unused ride becomes Ride Credits toward renewal.',
  'POST /trips/:id/position': 'Assigned driver publishes a GPS fix (hot KV cache + history).',
  'GET /trips/:id/position': 'Latest live fix + deterministic ETA to each upcoming stop.',
};

const UUID_RE = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi;

/** Normalise a concrete path to its documented pattern (uuids → :id, no query). */
function endpointPattern(method: string, path: string): string {
  const clean = (path.split('?')[0] ?? path).replace(UUID_RE, ':id').replace('/not-a-uuid', '/:id');
  return `${method} ${clean}`;
}

/** Declarative case. Lazy thunks resolve at run time, after earlier cases. */
interface CaseSpec {
  name: string;
  method: string;
  path: string | (() => string);
  /** Which pre-minted/captured token to send (thunk — resolved lazily). */
  token?: () => string | undefined;
  /** Display label for who is calling. */
  as?: string;
  body?: unknown | (() => unknown);
  /** Fully raw request (headers+payload) for signature/malformed-JSON cases. */
  raw?: () => { headers: Record<string, string>; payload: string };
  expected: string;
  check: (status: number, json: any) => boolean;
  after?: (json: any) => void;
  redactBody?: string;
  /** Repeat the request until `check` passes or `repeat` attempts are made. */
  repeat?: number;
}

interface Ctx {
  app: FastifyInstance;
  tokens: Record<string, string>;
  ids: Record<string, string>;
  vals: Record<string, any>;
}

let C: Ctx | undefined;

async function build(): Promise<Ctx> {
  const users = new InMemoryUserRepository();
  const reservations = new InMemoryReservationRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  const subscriptions = new InMemorySubscriptionRepository();
  const kv = new InMemoryKvStore();

  const authService = new AuthService({
    users,
    authIdentities: new InMemoryAuthIdentityRepository(),
    sessions: new InMemorySessionRepository(),
    jwt,
    verifier: new FakeIdTokenVerifier(),
    refreshTtlDays: 30,
  });
  const paymentsService = new PaymentsService({
    payments: new InMemoryPaymentRepository(),
    subscriptions,
    entitlements,
    paystack: new FakePaystackClient(PAYSTACK_SECRET),
    subscriptionFees: SUBSCRIPTION_FEES_PESEWAS,
    ridesPerPeriod: PLACEHOLDER_RIDES_PER_PERIOD,
  });
  const boardingService = new BoardingService({
    scanEvents: new InMemoryScanEventRepository(),
    kv,
    reservations,
    entitlements,
    secret: DEV_AUTH_CONFIG.secret,
    passTtlSeconds: 60,
  });

  const app = await buildApp({
    users,
    subscriptions,
    routes: new InMemoryRouteRepository(),
    stops: new InMemoryStopRepository(),
    routeStops: new InMemoryRouteStopRepository(),
    trips: new InMemoryTripRepository(),
    tripPositions: new InMemoryTripPositionRepository(),
    vehicles: new InMemoryVehicleRepository(),
    drivers: new InMemoryDriverRepository(),
    deviceTokens: new InMemoryDeviceTokenRepository(),
    entitlements,
    credits: new InMemoryCreditLedgerRepository(),
    reservations,
    featureFlags: new InMemoryFeatureFlagRepository(),
    minVersions: new InMemoryMinVersionRepository(),
    boardingService,
    authService,
    paymentsService,
    kv,
    objectStore: new FakeObjectStore(),
    auth: DEV_AUTH_CONFIG,
  });

  return {
    app,
    tokens: { admin: await jwt.signAccessToken({ userId: 'ops-admin', role: 'admin' }) },
    ids: {},
    vals: {},
  };
}

async function inject(
  c: Ctx,
  method: string,
  path: string,
  headers: Record<string, string>,
  payload?: string,
): Promise<{ status: number; json: any; ms: number }> {
  const t0 = performance.now();
  const res = await c.app.inject({
    method: method as 'GET',
    url: path,
    headers,
    ...(payload === undefined ? {} : { payload }),
  });
  let json: unknown;
  try {
    json = res.json();
  } catch {
    json = res.body.slice(0, 300);
  }
  return { status: res.statusCode, json, ms: Math.round((performance.now() - t0) * 10) / 10 };
}

async function runCase(c: Ctx, spec: CaseSpec): Promise<CaseResult> {
  const path = typeof spec.path === 'function' ? spec.path() : spec.path;
  const headers: Record<string, string> = {};
  let payload: string | undefined;
  let shownBody: unknown;
  if (spec.raw) {
    const raw = spec.raw();
    Object.assign(headers, raw.headers);
    payload = raw.payload;
    shownBody = spec.redactBody ?? raw.payload.slice(0, 120);
  } else {
    const token = spec.token?.();
    if (token) headers.authorization = `Bearer ${token}`;
    const body = typeof spec.body === 'function' ? (spec.body as () => unknown)() : spec.body;
    if (body !== undefined) {
      headers['content-type'] = 'application/json';
      payload = JSON.stringify(body);
      shownBody = spec.redactBody ?? body;
    }
  }

  const attempts = spec.repeat ?? 1;
  let out = { status: 0, json: null as any, ms: 0 };
  let total = 0;
  let usedAttempts = 0;
  for (let i = 1; i <= attempts; i++) {
    out = await inject(c, spec.method, path, headers, payload);
    total += out.ms;
    usedAttempts = i;
    if (spec.check(out.status, out.json)) break;
  }
  const pass = spec.check(out.status, out.json);
  if (pass && spec.after) spec.after(out.json);
  const pattern = endpointPattern(spec.method, path);
  return {
    name: spec.name,
    method: spec.method,
    path: attempts > 1 ? `${path} (×${usedAttempts})` : path,
    endpoint: pattern,
    doc: ENDPOINT_DOCS[pattern] ?? '',
    requestBody: shownBody,
    as: spec.as,
    status: out.status,
    ms: Math.round(total * 10) / 10,
    expected: spec.expected,
    pass,
    response: out.json,
  };
}

/** The ordered suites. State (ids, tokens, values) flows forward. */
function suites(c: Ctx): Record<string, { title: string; cases: CaseSpec[] }> {
  const t = c.tokens;
  const id = c.ids;
  const v = c.vals;
  const D = today();

  const signedWebhook = (ref: () => string) => () => {
    const payload = JSON.stringify({ event: 'charge.success', data: { reference: ref() } });
    return {
      headers: {
        'content-type': 'application/json',
        'x-paystack-signature': paystackSignature(payload, PAYSTACK_SECRET),
      },
      payload,
    };
  };

  return {
    platform: {
      title: 'Platform & contract',
      cases: [
        {
          name: 'service identity',
          method: 'GET',
          path: '/version',
          expected: '200 {name, version, commit}',
          check: (s, j) => s === 200 && !!j.name && !!j.version,
        },
        {
          name: 'liveness probe',
          method: 'GET',
          path: '/healthz',
          expected: '200 {status:ok}',
          check: (s, j) => s === 200 && j.status === 'ok',
        },
        {
          name: 'readiness probe (DB + KV)',
          method: 'GET',
          path: '/readyz',
          expected: '200 {status:ready}',
          check: (s, j) => s === 200 && j.status === 'ready',
        },
        {
          name: 'public feature flags',
          method: 'GET',
          path: '/flags',
          expected: '200 with flags payload',
          check: (s) => s === 200,
        },
        {
          name: 'OpenAPI contract is served',
          method: 'GET',
          path: '/docs/json',
          expected: '200; spec titled "Trotxi API", 20+ documented paths',
          check: (s, j) =>
            s === 200 && j?.info?.title === 'Trotxi API' && Object.keys(j.paths ?? {}).length > 20,
          after: (j) => (v.endpointCount = Object.keys(j.paths).length),
        },
      ],
    },

    auth: {
      title: 'Sign-in, sessions & RBAC',
      cases: [
        {
          name: 'no token → 401',
          method: 'GET',
          path: '/me',
          expected: '401 unauthorized',
          check: (s) => s === 401,
        },
        {
          name: 'garbage token → 401',
          method: 'GET',
          path: '/me',
          token: () => 'not-a-jwt',
          as: 'intruder',
          expected: '401 unauthorized',
          check: (s) => s === 401,
        },
        {
          name: 'rider signs in (Google, dev verifier)',
          method: 'POST',
          path: '/auth/google',
          body: {
            idToken: JSON.stringify({ sub: 'g-ama', name: 'Ama Mensah', email: 'ama@trotxi.test' }),
          },
          expected: '200 {accessToken, refreshToken, user}',
          check: (s, j) => s === 200 && !!j.accessToken && !!j.refreshToken && !!j.user?.id,
          after: (j) => {
            t.rider = j.accessToken;
            id.riderUserId = j.user.id;
          },
        },
        {
          name: 'second rider signs in',
          method: 'POST',
          path: '/auth/google',
          body: { idToken: JSON.stringify({ sub: 'g-kofi', name: 'Kofi Owusu' }) },
          expected: '200; a distinct user id',
          check: (s, j) => s === 200 && j.user.id !== id.riderUserId,
          after: (j) => {
            t.rider2 = j.accessToken;
            id.rider2UserId = j.user.id;
          },
        },
        {
          name: 'driver-to-be signs in (starts as commuter)',
          method: 'POST',
          path: '/auth/google',
          body: { idToken: JSON.stringify({ sub: 'g-kwame', name: 'Kwame Boateng' }) },
          expected: '200; role commuter',
          check: (s, j) => s === 200 && j.user.role === 'commuter',
          after: (j) => {
            v.driverRefresh = j.refreshToken;
            id.driverUserId = j.user.id;
            t.driverStale = j.accessToken;
          },
        },
        {
          name: 'rider reads own profile',
          method: 'GET',
          path: '/me',
          token: () => t.rider,
          as: 'rider',
          expected: '200 {displayName: "Ama Mensah", role: commuter}',
          check: (s, j) => s === 200 && j.displayName === 'Ama Mensah' && j.role === 'commuter',
        },
        {
          name: 'commuter hits admin surface → 403',
          method: 'GET',
          path: '/admin/routes',
          token: () => t.rider,
          as: 'rider',
          expected: '403 forbidden (RBAC)',
          check: (s) => s === 403,
        },
        {
          name: 'admin grants the driver role',
          method: 'PATCH',
          path: () => `/admin/users/${id.driverUserId}/role`,
          token: () => t.admin,
          as: 'admin',
          body: { role: 'driver' },
          expected: '200; role now driver',
          check: (s, j) => s === 200 && j.role === 'driver',
        },
        {
          name: 'stale access token is still commuter',
          method: 'POST',
          path: '/boarding/scan',
          token: () => t.driverStale,
          as: 'driver (stale token)',
          body: { pass: 'x' },
          expected: '403 — JWT is stateless; the role lands on refresh',
          check: (s) => s === 403,
        },
        {
          name: 'refresh rotates the driver role in',
          method: 'POST',
          path: '/auth/refresh',
          body: () => ({ refreshToken: v.driverRefresh }),
          expected: '200; fresh access token carries role driver',
          check: (s, j) => s === 200 && !!j.accessToken,
          after: (j) => (t.driver = j.accessToken),
        },
      ],
    },

    fleet: {
      title: 'Fleet & mobility (admin ops)',
      cases: [
        {
          name: 'create the pilot route',
          method: 'POST',
          path: '/admin/routes',
          token: () => t.admin,
          as: 'admin',
          body: { name: 'Circle ⇄ Madina', description: 'Pilot corridor' },
          expected: '200 with route id',
          check: (s, j) => s === 200 && !!j.id,
          after: (j) => (id.routeId = j.id),
        },
        {
          name: 'create stop: Circle Interchange',
          method: 'POST',
          path: '/admin/stops',
          token: () => t.admin,
          as: 'admin',
          body: { name: 'Circle Interchange', latitude: 5.5717, longitude: -0.2107 },
          expected: '200 with stop id',
          check: (s, j) => s === 200 && !!j.id,
          after: (j) => (id.stopA = j.id),
        },
        {
          name: 'create stop: Madina Market',
          method: 'POST',
          path: '/admin/stops',
          token: () => t.admin,
          as: 'admin',
          body: { name: 'Madina Market', latitude: 5.6686, longitude: -0.1665 },
          expected: '200 with stop id',
          check: (s, j) => s === 200 && !!j.id,
          after: (j) => (id.stopB = j.id),
        },
        {
          name: 'attach Circle at seq 0',
          method: 'POST',
          path: () => `/admin/routes/${id.routeId}/stops`,
          token: () => t.admin,
          as: 'admin',
          body: () => ({ stopId: id.stopA, seq: 0 }),
          expected: '200 ordered attachment',
          check: (s) => s === 200,
        },
        {
          name: 'attach Madina at seq 1',
          method: 'POST',
          path: () => `/admin/routes/${id.routeId}/stops`,
          token: () => t.admin,
          as: 'admin',
          body: () => ({ stopId: id.stopB, seq: 1 }),
          expected: '200 ordered attachment',
          check: (s) => s === 200,
        },
        {
          name: 'register a vehicle',
          method: 'POST',
          path: '/admin/vehicles',
          token: () => t.admin,
          as: 'admin',
          body: { registration: 'GR-2417-26', label: 'Blue Bird', capacity: 36 },
          expected: '200 with vehicle id',
          check: (s, j) => s === 200 && !!j.id,
          after: (j) => (id.vehicleId = j.id),
        },
        {
          name: 'register the driver (linked to his account)',
          method: 'POST',
          path: '/admin/drivers',
          token: () => t.admin,
          as: 'admin',
          body: () => ({ fullName: 'Kwame Boateng', userId: id.driverUserId }),
          expected: '200 with driver id',
          check: (s, j) => s === 200 && !!j.id,
          after: (j) => (id.driverId = j.id),
        },
        {
          name: 'schedule the 06:30 morning trip',
          method: 'POST',
          path: '/admin/trips',
          token: () => t.admin,
          as: 'admin',
          body: () => ({
            routeId: id.routeId,
            vehicleId: id.vehicleId,
            scheduledAt: `${D}T06:30:00.000Z`,
          }),
          expected: '200 with trip id',
          check: (s, j) => s === 200 && !!j.id,
          after: (j) => (id.tripId = j.id),
        },
        {
          name: 'assign driver + vehicle to the trip',
          method: 'PUT',
          path: () => `/admin/trips/${id.tripId}/assignment`,
          token: () => t.admin,
          as: 'admin',
          body: () => ({ assignedDriverId: id.driverId, vehicleId: id.vehicleId }),
          expected: '200; assignedDriverId set (authorises GPS + manifest)',
          check: (s, j) => s === 200 && j.assignedDriverId === id.driverId,
        },
        {
          name: 'public route browse shows ordered stops',
          method: 'GET',
          path: () => `/routes/${id.routeId}`,
          expected: '200, no auth; stops in boarding order',
          check: (s, j) =>
            s === 200 && (j.stops ?? []).length === 2 && j.stops[0].name === 'Circle Interchange',
        },
        {
          name: 'rider lists trips on the route',
          method: 'GET',
          path: () => `/trips?routeId=${id.routeId}`,
          token: () => t.rider,
          as: 'rider',
          expected: '200 {trips:[…]} — the scheduled run is visible',
          check: (s, j) => s === 200 && (j.trips ?? []).length >= 1,
        },
      ],
    },

    payments: {
      title: 'Payments & ride entitlement (E1)',
      cases: [
        {
          name: 'rider starts a subscription checkout',
          method: 'POST',
          path: '/payments/subscribe',
          token: () => t.rider,
          as: 'rider',
          body: () => ({ plan: 'monthly', routeId: id.routeId }),
          expected: '200 {authorizationUrl, reference} — payment pending',
          check: (s, j) => s === 200 && !!j.authorizationUrl && !!j.reference,
          after: (j) => (v.reference = j.reference),
        },
        {
          name: 'webhook with a FORGED signature → 401',
          method: 'POST',
          path: '/webhooks/paystack',
          raw: () => ({
            headers: { 'content-type': 'application/json', 'x-paystack-signature': 'deadbeef' },
            payload: JSON.stringify({ event: 'charge.success', data: { reference: v.reference } }),
          }),
          redactBody: 'charge.success + bad HMAC',
          expected: '401 — signature verification rejects it',
          check: (s) => s === 401,
        },
        {
          name: 'signed charge.success activates the plan',
          method: 'POST',
          path: '/webhooks/paystack',
          raw: signedWebhook(() => v.reference),
          redactBody: 'charge.success + valid HMAC (sha512)',
          expected: '200 — subscription active, rides allocated',
          check: (s) => s === 200,
        },
        {
          name: 'entitlement ledger shows 44 rides',
          method: 'GET',
          path: '/me/rides',
          token: () => t.rider,
          as: 'rider',
          expected: '200 {remainingRides:44}',
          check: (s, j) => s === 200 && j.remainingRides === 44,
        },
        {
          name: 'webhook REPLAY is a no-op',
          method: 'POST',
          path: '/webhooks/paystack',
          raw: signedWebhook(() => v.reference),
          redactBody: 'same signed payload, delivered again',
          expected: '200 idempotent — Paystack retries safely',
          check: (s) => s === 200,
        },
        {
          name: 'still exactly 44 rides after the replay',
          method: 'GET',
          path: '/me/rides',
          token: () => t.rider,
          as: 'rider',
          expected: '200 {remainingRides:44} — no double allocation',
          check: (s, j) => s === 200 && j.remainingRides === 44,
        },
        {
          name: 'second rider subscribes on the corridor',
          method: 'POST',
          path: '/payments/subscribe',
          token: () => t.rider2,
          as: 'rider2',
          body: () => ({ plan: 'monthly', routeId: id.routeId }),
          expected: '200 with a fresh reference',
          check: (s, j) => s === 200 && !!j.reference,
          after: (j) => (v.reference2 = j.reference),
        },
        {
          name: "second rider's payment lands",
          method: 'POST',
          path: '/webhooks/paystack',
          raw: signedWebhook(() => v.reference2),
          redactBody: 'charge.success + valid HMAC',
          expected: '200 — two active subscribers on the route',
          check: (s) => s === 200,
        },
      ],
    },

    reservations: {
      title: 'Daily confirmation loop (E3)',
      cases: [
        {
          name: 'ask-dispatch prompts the whole corridor',
          method: 'POST',
          path: '/admin/ask-dispatch',
          token: () => t.admin,
          as: 'admin',
          body: { travelDate: D, direction: 'morning' },
          expected: '200 {trips:1, asked:2} — both subscribers seeded pending',
          check: (s, j) => s === 200 && j.trips === 1 && j.asked === 2,
        },
        {
          name: 'malformed travel date → 400',
          method: 'POST',
          path: '/me/reservations',
          token: () => t.rider,
          as: 'rider',
          body: { travelDate: 'tomorrow', direction: 'morning', travelling: true },
          expected: '400 zod validation error',
          check: (s) => s === 400,
        },
        {
          name: 'rider confirms the morning seat → daily PIN',
          method: 'POST',
          path: '/me/reservations',
          token: () => t.rider,
          as: 'rider',
          body: () => ({
            tripId: id.tripId,
            travelDate: D,
            direction: 'morning',
            travelling: true,
          }),
          expected: '200 reserved + one-time 4-digit boarding PIN',
          check: (s, j) => s === 200 && j.status === 'reserved' && /^\d{4}$/.test(j.pin ?? ''),
          after: (j) => {
            id.reservationId = j.id;
            v.pin = j.pin;
          },
        },
        {
          name: 'cutoff default-yes sweeps the silent rider',
          method: 'POST',
          path: '/admin/resolve-defaults',
          token: () => t.admin,
          as: 'admin',
          body: { travelDate: D, direction: 'morning' },
          expected: '200 {defaulted:1} — no-reply means travelling',
          check: (s, j) => s === 200 && j.defaulted === 1,
        },
        {
          name: 'rider lists own reservations',
          method: 'GET',
          path: `/me/reservations`,
          token: () => t.rider,
          as: 'rider',
          expected: '200; the morning seat shows as reserved',
          check: (s, j) =>
            s === 200 &&
            (j.reservations ?? []).some(
              (r: any) => r.direction === 'morning' && r.status === 'reserved',
            ),
        },
      ],
    },

    boarding: {
      title: 'Boarding & verification (E4)',
      cases: [
        {
          name: 'rider gets the rotating QR pass',
          method: 'GET',
          path: '/me/pass',
          token: () => t.rider,
          as: 'rider',
          expected: '200 {pass, expiresInSeconds:60} — single-use, 60s TTL',
          check: (s, j) => s === 200 && !!j.pass && j.expiresInSeconds === 60,
          after: (j) => (v.pass = j.pass),
        },
        {
          name: 'driver scans the pass → boards + debits',
          method: 'POST',
          path: '/boarding/scan',
          token: () => t.driver,
          as: 'driver',
          body: () => ({ pass: v.pass, tripId: id.tripId }),
          expected: '200 {valid:true, deducted:true}',
          check: (s, j) => s === 200 && j.valid === true && j.deducted === true,
        },
        {
          name: 'one ride debited: 44 → 43',
          method: 'GET',
          path: '/me/rides',
          token: () => t.rider,
          as: 'rider',
          expected: '200 {remainingRides:43}',
          check: (s, j) => s === 200 && j.remainingRides === 43,
        },
        {
          name: 'screenshot replay: same pass again → reused',
          method: 'POST',
          path: '/boarding/scan',
          token: () => t.driver,
          as: 'driver',
          body: () => ({ pass: v.pass, tripId: id.tripId }),
          expected: '200 {valid:false, reason:reused, deducted:false}',
          check: (s, j) =>
            s === 200 && j.valid === false && j.reason === 'reused' && j.deducted === false,
        },
        {
          name: 'an ACCESS token is not a pass',
          method: 'POST',
          path: '/boarding/scan',
          token: () => t.driver,
          as: 'driver',
          body: () => ({ pass: t.rider, tripId: id.tripId }),
          expected: '200 {valid:false} — JWT audience separation',
          check: (s, j) => s === 200 && j.valid === false,
        },
        {
          name: 'a rider cannot scan (driver-only) → 403',
          method: 'POST',
          path: '/boarding/scan',
          token: () => t.rider,
          as: 'rider',
          body: () => ({ pass: v.pass }),
          expected: '403 forbidden',
          check: (s) => s === 403,
        },
        {
          name: 'assigned driver reads the trip manifest',
          method: 'GET',
          path: () => `/boarding/manifest?tripId=${id.tripId}`,
          token: () => t.driver,
          as: 'driver',
          expected: '200; both riders listed, Ama shows boarded',
          check: (s, j) =>
            s === 200 &&
            (j.riders ?? []).length === 2 &&
            (j.riders ?? []).some((r: any) => r.name === 'Ama Mensah' && r.boarded === true),
        },
        {
          name: 'wrong PIN → invalid',
          method: 'POST',
          path: '/boarding/verify-pin',
          token: () => t.driver,
          as: 'driver',
          body: () => ({
            reservationId: id.reservationId,
            pin: v.pin === '0000' ? '1111' : '0000',
          }),
          expected: '200 {valid:false} — keyed-hash check fails',
          check: (s, j) => s === 200 && j.valid === false,
        },
        {
          name: 'right PIN on a boarded seat → no double charge',
          method: 'POST',
          path: '/boarding/verify-pin',
          token: () => t.driver,
          as: 'driver',
          body: () => ({ reservationId: id.reservationId, pin: v.pin }),
          expected: '200 {reason:already_boarded, deducted:false} — idempotent',
          check: (s, j) => s === 200 && j.reason === 'already_boarded' && j.deducted === false,
        },
      ],
    },

    settlement: {
      title: 'No-show & Ride Credits (E4b / E5)',
      cases: [
        {
          name: 'rider confirms the evening leg too',
          method: 'POST',
          path: '/me/reservations',
          token: () => t.rider,
          as: 'rider',
          body: () => ({ travelDate: D, direction: 'evening', travelling: true }),
          expected: '200 reserved (a fresh PIN for the evening)',
          check: (s, j) => s === 200 && j.status === 'reserved',
        },
        {
          name: 'cutoff: confirmed-but-absent → no-show',
          method: 'POST',
          path: '/admin/resolve-no-shows',
          token: () => t.admin,
          as: 'admin',
          body: { travelDate: D, direction: 'evening' },
          expected: '200 {noShows:1} — a held seat is honoured',
          check: (s, j) => s === 200 && j.noShows === 1,
        },
        {
          name: 'the no-show debits a ride: 43 → 42',
          method: 'GET',
          path: '/me/rides',
          token: () => t.rider,
          as: 'rider',
          expected: '200 {remainingRides:42}',
          check: (s, j) => s === 200 && j.remainingRides === 42,
        },
        {
          name: 'month-end: unused rides → Ride Credits',
          method: 'POST',
          path: '/admin/convert-credits',
          token: () => t.admin,
          as: 'admin',
          expected: '200 {ridesConverted:86} — 42 (Ama) + 44 (Kofi)',
          check: (s, j) => s === 200 && j.ridesConverted === 86,
        },
        {
          name: 'balance: 0 rides, credits in pesewas',
          method: 'GET',
          path: '/me/rides',
          token: () => t.rider,
          as: 'rider',
          expected: '200 {remainingRides:0, creditPesewas > 0}',
          check: (s, j) => s === 200 && j.remainingRides === 0 && j.creditPesewas > 0,
        },
        {
          name: 'conversion re-run converts nothing',
          method: 'POST',
          path: '/admin/convert-credits',
          token: () => t.admin,
          as: 'admin',
          expected: '200 {ridesConverted:0} — idempotent, keyed per period',
          check: (s, j) => s === 200 && j.ridesConverted === 0,
        },
      ],
    },

    positions: {
      title: 'Live positions & ETA (#25)',
      cases: [
        {
          name: 'assigned driver publishes a GPS fix',
          method: 'POST',
          path: () => `/trips/${id.tripId}/position`,
          token: () => t.driver,
          as: 'driver',
          body: { latitude: 5.6037, longitude: -0.187 },
          expected: '200 {position:{latitude, longitude, recordedAt}}',
          check: (s, j) => s === 200 && j.position?.latitude === 5.6037,
        },
        {
          name: 'anyone else cannot publish → 403',
          method: 'POST',
          path: () => `/trips/${id.tripId}/position`,
          token: () => t.rider,
          as: 'rider',
          body: { latitude: 0, longitude: 0 },
          expected: '403 — only the assigned driver reports GPS',
          check: (s) => s === 403,
        },
        {
          name: 'rider reads live position + ETAs',
          method: 'GET',
          path: () => `/trips/${id.tripId}/position`,
          token: () => t.rider,
          as: 'rider',
          expected: '200 {position, etaToStops} — ETA to the upcoming stop (Madina)',
          check: (s, j) =>
            s === 200 &&
            !!j.position &&
            (j.etaToStops ?? []).length >= 1 &&
            j.etaToStops[0].name === 'Madina Market' &&
            j.etaToStops[0].etaSeconds > 0,
        },
      ],
    },

    guardrails: {
      title: 'Guardrails: validation & rate limiting',
      cases: [
        {
          name: 'unknown endpoint → 404',
          method: 'GET',
          path: '/definitely/not/a/route',
          expected: '404 not found',
          check: (s) => s === 404,
        },
        {
          name: 'malformed JSON body → 400',
          method: 'POST',
          path: '/payments/subscribe',
          raw: () => ({
            headers: { 'content-type': 'application/json', authorization: `Bearer ${t.rider}` },
            payload: '{"plan": mon',
          }),
          redactBody: '{"plan": mon   ← truncated JSON',
          expected: '400 bad request',
          check: (s) => s === 400,
        },
        {
          name: 'invalid enum value → 400',
          method: 'POST',
          path: '/payments/subscribe',
          token: () => t.rider,
          as: 'rider',
          body: { plan: 'lifetime' },
          expected: '400 zod validation (plan must be monthly|annual)',
          check: (s) => s === 400,
        },
        {
          name: 'malformed uuid in path → 400',
          method: 'GET',
          path: '/trips/not-a-uuid',
          token: () => t.rider,
          as: 'rider',
          expected: '400 validation error',
          check: (s) => s === 400,
        },
        {
          name: 'a 120-call burst trips the rate limiter',
          method: 'GET',
          path: '/me/rides',
          token: () => t.rider2,
          as: 'rider2 (burst)',
          repeat: 120,
          expected: 'first ~100 pass, then 429 Too Many Requests',
          check: (s) => s === 429,
        },
      ],
    },
  };
}

const SUITE_ORDER = [
  'platform',
  'auth',
  'fleet',
  'payments',
  'reservations',
  'boarding',
  'settlement',
  'positions',
  'guardrails',
];

const here = dirname(fileURLToPath(import.meta.url));
const INDEX = join(here, '..', '..', '..', 'demo', 'endpoints.html');

const server = createServer((req, res) => {
  void (async () => {
    const url = (req.url ?? '/').split('?')[0] ?? '/';
    res.setHeader('access-control-allow-origin', '*');
    const send = (code: number, body: unknown) => {
      res.statusCode = code;
      res.setHeader('content-type', 'application/json');
      res.end(JSON.stringify(body));
    };
    try {
      if (url === '/' || url === '/index.html') {
        res.setHeader('content-type', 'text/html');
        res.end(await readFile(INDEX, 'utf8'));
        return;
      }
      if (url === '/reset' && req.method === 'POST') {
        C = await build();
        send(200, { ok: true });
        return;
      }
      if (url === '/info') {
        if (!C) C = await build();
        send(200, {
          ok: true,
          apiPort: API_PORT,
          suites: SUITE_ORDER.map((key) => ({
            key,
            title: suites(C!)[key]!.title,
            count: suites(C!)[key]!.cases.length,
          })),
          endpointCount: C.vals.endpointCount ?? null,
          tokens: C.tokens,
          ids: C.ids,
        });
        return;
      }
      if (url.startsWith('/run/') && req.method === 'POST') {
        if (!C) C = await build();
        const key = url.slice('/run/'.length);
        const suite = suites(C)[key];
        if (!suite) {
          send(404, { ok: false, error: `unknown suite ${key}` });
          return;
        }
        const results: CaseResult[] = [];
        for (const spec of suite.cases) results.push(await runCase(C, spec));
        send(200, { ok: true, results });
        return;
      }
      send(404, { ok: false, error: 'not found' });
    } catch (err) {
      send(500, {
        ok: false,
        error: err instanceof Error ? (err.stack ?? err.message) : String(err),
      });
    }
  })();
});

void (async () => {
  C = await build();
  await C.app.listen({ port: API_PORT, host: '127.0.0.1' });
  server.listen(UI_PORT, () => {
    console.log(`Endpoint test console → http://localhost:${UI_PORT}`);
    console.log(`Live API + Swagger UI → http://localhost:${API_PORT}/docs`);
  });
})();
