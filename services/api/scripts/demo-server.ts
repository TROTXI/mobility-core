// Live investor-demo runner. Boots the real Trotxi API in-process (in-memory)
// and serves the animated walkthrough (demo/index.html) plus a small set of
// /demo/* endpoints. Each endpoint drives ONE beat of the real hybrid-model loop
// through the actual API (via inject) and returns the real numbers — the ride
// entitlement, the daily PIN, the deduction, the credit conversion — so the
// front-end animates live data, not a script. Everything runs locally so a
// pitch never waits on a cold start. Run: `pnpm --filter @trotxi/api demo`.

import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../src/app';
import { InMemoryKvStore } from '../src/kv/kv.store';
import { FakeObjectStore } from '../src/storage/object-store';
import { createJwtService, DEV_AUTH_CONFIG } from '../src/modules/auth/jwt';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryVehicleRepository } from '../src/modules/mobility/vehicle.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryScanEventRepository } from '../src/modules/boarding/scan-event.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { InMemoryCreditLedgerRepository } from '../src/modules/entitlements/credit-ledger.repository';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { BoardingService } from '../src/modules/boarding/boarding.service';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import {
  PaymentsService,
  PLACEHOLDER_RIDES_PER_PERIOD,
  SUBSCRIPTION_FEES_PESEWAS,
} from '../src/modules/payments/payments.service';

const PAYSTACK_SECRET = 'fake-paystack-secret';
const jwt = createJwtService(DEV_AUTH_CONFIG);
const day = (offset: number) => new Date(Date.now() + offset * 864e5).toISOString().slice(0, 10);

interface DemoState {
  app: FastifyInstance;
  riderToken: string;
  driverToken: string;
  adminToken: string;
  riderId: string;
  routeId: string;
  tripId: string;
  reservationId?: string;
  pin?: string;
}

let S: DemoState | undefined;

async function build(): Promise<DemoState> {
  const users = new InMemoryUserRepository();
  const subscriptions = new InMemorySubscriptionRepository();
  const routes = new InMemoryRouteRepository();
  const stops = new InMemoryStopRepository();
  const routeStops = new InMemoryRouteStopRepository();
  const trips = new InMemoryTripRepository();
  const vehicles = new InMemoryVehicleRepository();
  const drivers = new InMemoryDriverRepository();
  const scanEvents = new InMemoryScanEventRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  const credits = new InMemoryCreditLedgerRepository();
  const reservations = new InMemoryReservationRepository();
  const payments = new InMemoryPaymentRepository();
  const kv = new InMemoryKvStore();
  const objectStore = new FakeObjectStore();

  const boardingService = new BoardingService({
    scanEvents,
    kv,
    reservations,
    entitlements,
    secret: DEV_AUTH_CONFIG.secret,
    passTtlSeconds: 60,
  });
  const paymentsService = new PaymentsService({
    payments,
    subscriptions,
    entitlements,
    paystack: new FakePaystackClient(PAYSTACK_SECRET),
    subscriptionFees: SUBSCRIPTION_FEES_PESEWAS,
    ridesPerPeriod: PLACEHOLDER_RIDES_PER_PERIOD,
  });

  const app = await buildApp({
    users,
    subscriptions,
    routes,
    stops,
    routeStops,
    trips,
    vehicles,
    drivers,
    entitlements,
    credits,
    reservations,
    boardingService,
    paymentsService,
    kv,
    objectStore,
    auth: DEV_AUTH_CONFIG,
  });

  const rider = await users.create({ displayName: 'Ama Mensah' });
  const route = await routes.create({ name: 'Circle ⇄ Madina', description: 'Pilot corridor' });
  const driver = await drivers.create({ fullName: 'Kwame Boateng', userId: 'demo-driver' });
  const trip = await trips.create({
    routeId: route.id,
    assignedDriverId: driver.id,
    scheduledAt: new Date(`${day(1)}T06:30:00Z`),
  });

  return {
    app,
    riderToken: await jwt.signAccessToken({ userId: rider.id, role: 'commuter' }),
    driverToken: await jwt.signAccessToken({ userId: 'demo-driver', role: 'driver' }),
    adminToken: await jwt.signAccessToken({ userId: 'demo-admin', role: 'admin' }),
    riderId: rider.id,
    routeId: route.id,
    tripId: trip.id,
  };
}

async function call(
  s: DemoState,
  method: string,
  url: string,
  token: string,
  body?: unknown,
): Promise<{ status: number; json: Record<string, unknown> }> {
  const headers: Record<string, string> = { authorization: `Bearer ${token}` };
  if (body !== undefined) headers['content-type'] = 'application/json';
  const res = await s.app.inject({
    method: method as 'GET',
    url,
    headers,
    ...(body === undefined ? {} : { payload: JSON.stringify(body) }),
  });
  let json: Record<string, unknown> = {};
  try {
    json = res.json();
  } catch {
    json = { raw: res.body };
  }
  return { status: res.statusCode, json };
}

async function rides(s: DemoState): Promise<{ rides: number; credits: number }> {
  const { json } = await call(s, 'GET', '/me/rides', s.riderToken);
  return { rides: Number(json.remainingRides ?? 0), credits: Number(json.creditPesewas ?? 0) };
}

type StepResult = Record<string, unknown>;

const STEPS: Record<string, (s: DemoState) => Promise<StepResult>> = {
  async subscribe(s) {
    const init = await call(s, 'POST', '/payments/subscribe', s.riderToken, {
      plan: 'monthly',
      routeId: s.routeId,
    });
    const reference = String((init.json as { reference?: string }).reference);
    const webhookBody = JSON.stringify({ event: 'charge.success', data: { reference } });
    await s.app.inject({
      method: 'POST',
      url: '/webhooks/paystack',
      headers: {
        'content-type': 'application/json',
        'x-paystack-signature': paystackSignature(webhookBody, PAYSTACK_SECRET),
      },
      payload: webhookBody,
    });
    return { reference, ...(await rides(s)) };
  },
  async confirm(s) {
    const { json } = await call(s, 'POST', '/me/reservations', s.riderToken, {
      tripId: s.tripId,
      travelDate: day(1),
      direction: 'morning',
      travelling: true,
    });
    s.reservationId = String(json.id);
    s.pin = String(json.pin);
    return { pin: s.pin, reservationId: s.reservationId, ...(await rides(s)) };
  },
  async board(s) {
    const { json } = await call(s, 'POST', '/boarding/verify-pin', s.driverToken, {
      reservationId: s.reservationId,
      pin: s.pin,
    });
    return { deducted: json.deducted === true, ...(await rides(s)) };
  },
  async noshow(s) {
    await call(s, 'POST', '/me/reservations', s.riderToken, {
      tripId: s.tripId,
      travelDate: day(2),
      direction: 'morning',
      travelling: true,
    });
    const { json } = await call(s, 'POST', '/admin/resolve-no-shows', s.adminToken, {
      travelDate: day(2),
      direction: 'morning',
    });
    return { noShows: Number(json.noShows ?? 0), ...(await rides(s)) };
  },
  async convert(s) {
    const { json } = await call(s, 'POST', '/admin/convert-credits', s.adminToken);
    return { converted: Number(json.ridesConverted ?? 0), ...(await rides(s)) };
  },
};

const here = dirname(fileURLToPath(import.meta.url));
const INDEX = join(here, '..', '..', '..', 'demo', 'index.html');
const PORT = Number(process.env.DEMO_PORT ?? 4319);

const server = createServer((req, res) => {
  void (async () => {
    const url = (req.url ?? '/').split('?')[0];
    res.setHeader('access-control-allow-origin', '*');
    try {
      if (url === '/' || url === '/index.html') {
        res.setHeader('content-type', 'text/html');
        res.end(await readFile(INDEX, 'utf8'));
        return;
      }
      if (url === '/demo/reset' && req.method === 'POST') {
        S = await build();
        res.setHeader('content-type', 'application/json');
        res.end(JSON.stringify({ ok: true, rides: 0, credits: 0 }));
        return;
      }
      const name = url.startsWith('/demo/') ? url.slice('/demo/'.length) : '';
      if (STEPS[name] && req.method === 'POST') {
        if (!S) S = await build();
        const data = await STEPS[name](S);
        res.setHeader('content-type', 'application/json');
        res.end(JSON.stringify({ ok: true, ...data }));
        return;
      }
      res.statusCode = 404;
      res.end(JSON.stringify({ ok: false, error: 'not found' }));
    } catch (err) {
      res.statusCode = 500;
      res.setHeader('content-type', 'application/json');
      res.end(
        JSON.stringify({ ok: false, error: err instanceof Error ? err.message : String(err) }),
      );
    }
  })();
});

server.listen(PORT, () => {
  console.log(`Trotxi live demo → http://localhost:${PORT}`);
});
