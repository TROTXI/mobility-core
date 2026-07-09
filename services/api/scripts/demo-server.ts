// Live investor-demo runner. Boots the real Trotxi API in-process (in-memory)
// and serves the animated walkthrough (demo/index.html) plus a set of /demo/*
// endpoints. Each endpoint drives one beat of the hybrid-model loop for a whole
// fleet of riders through the ACTUAL API, then reads back real aggregates — the
// rider journey (Ama) and the operator economics are both computed by the real
// code, not scripted. Everything runs locally so a pitch never waits on a cold
// start. Run: `pnpm --filter @trotxi/api demo`.

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
import {
  InMemorySubscriptionRepository,
  type SubscriptionRepository,
} from '../src/modules/subscriptions/subscription.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryVehicleRepository } from '../src/modules/mobility/vehicle.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryScanEventRepository } from '../src/modules/boarding/scan-event.repository';
import {
  InMemoryEntitlementLedgerRepository,
  type EntitlementLedgerRepository,
} from '../src/modules/entitlements/entitlement-ledger.repository';
import {
  InMemoryCreditLedgerRepository,
  type CreditLedgerRepository,
} from '../src/modules/entitlements/credit-ledger.repository';
import {
  InMemoryReservationRepository,
  type ReservationRepository,
} from '../src/modules/reservations/reservation.repository';
import { BoardingService } from '../src/modules/boarding/boarding.service';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import { PaymentsService } from '../src/modules/payments/payments.service';

// Illustrative pilot pricing (the API's own fees are placeholders too). The
// MECHANICS below are the real API; only these figures are demo-tuned.
const FEE = { monthly: 20000, annual: 200000 }; // GHS 200 / 2000 (pesewas)
const RIDES_PER_PERIOD = 44;
const CREDIT_PER_RIDE = 450; // GHS 4.50 (pesewas)
const FLEET = 40;
const CONFIRM = 34; // of the fleet, confirm the morning; the rest decline
const BOARD = 31; // of the confirmed, actually board; the remaining are no-shows
const CAPACITY = 36; // seats on the corridor's morning run (for occupancy)

const jwt = createJwtService(DEV_AUTH_CONFIG);
const PAYSTACK_SECRET = 'fake-paystack-secret';
const day = (o: number) => new Date(Date.now() + o * 864e5).toISOString().slice(0, 10);

interface Rider {
  id: string;
  token: string;
  reservationId?: string;
  pin?: string;
}
interface DemoState {
  app: FastifyInstance;
  subs: SubscriptionRepository;
  ents: EntitlementLedgerRepository;
  creds: CreditLedgerRepository;
  resv: ReservationRepository;
  riders: Rider[];
  driverToken: string;
  adminToken: string;
  routeId: string;
  tripId: string;
  travelDate: string;
}

let S: DemoState | undefined;

async function build(): Promise<DemoState> {
  const users = new InMemoryUserRepository();
  const subs = new InMemorySubscriptionRepository();
  const routes = new InMemoryRouteRepository();
  const stops = new InMemoryStopRepository();
  const routeStops = new InMemoryRouteStopRepository();
  const trips = new InMemoryTripRepository();
  const vehicles = new InMemoryVehicleRepository();
  const drivers = new InMemoryDriverRepository();
  const scanEvents = new InMemoryScanEventRepository();
  const ents = new InMemoryEntitlementLedgerRepository();
  const creds = new InMemoryCreditLedgerRepository();
  const resv = new InMemoryReservationRepository();
  const payments = new InMemoryPaymentRepository();
  const kv = new InMemoryKvStore();

  const boardingService = new BoardingService({
    scanEvents,
    kv,
    reservations: resv,
    entitlements: ents,
    secret: DEV_AUTH_CONFIG.secret,
    passTtlSeconds: 60,
  });
  const paymentsService = new PaymentsService({
    payments,
    subscriptions: subs,
    entitlements: ents,
    paystack: new FakePaystackClient(PAYSTACK_SECRET),
    subscriptionFees: FEE,
    ridesPerPeriod: RIDES_PER_PERIOD,
  });

  const app = await buildApp({
    users,
    subscriptions: subs,
    routes,
    stops,
    routeStops,
    trips,
    vehicles,
    drivers,
    entitlements: ents,
    credits: creds,
    reservations: resv,
    boardingService,
    paymentsService,
    creditPesewasPerRide: CREDIT_PER_RIDE,
    kv,
    objectStore: new FakeObjectStore(),
    auth: DEV_AUTH_CONFIG,
  });

  const route = await routes.create({ name: 'Circle ⇄ Madina', description: 'Pilot corridor' });
  const driver = await drivers.create({ fullName: 'Kwame Boateng', userId: 'demo-driver' });
  const trip = await trips.create({
    routeId: route.id,
    assignedDriverId: driver.id,
    scheduledAt: new Date(`${day(1)}T06:30:00Z`),
  });
  const names = ['Ama Mensah', 'Kofi Owusu', 'Efua Sarpong', 'Yaw Darko', 'Adjoa Nkrumah'];
  const riders: Rider[] = [];
  for (let n = 0; n < FLEET; n++) {
    const u = await users.create({ displayName: names[n % names.length] });
    riders.push({ id: u.id, token: await jwt.signAccessToken({ userId: u.id, role: 'commuter' }) });
  }

  return {
    app,
    subs,
    ents,
    creds,
    resv,
    riders,
    driverToken: await jwt.signAccessToken({ userId: 'demo-driver', role: 'driver' }),
    adminToken: await jwt.signAccessToken({ userId: 'demo-admin', role: 'admin' }),
    routeId: route.id,
    tripId: trip.id,
    travelDate: day(1),
  };
}

async function call(
  s: DemoState,
  method: string,
  url: string,
  token: string,
  body?: unknown,
): Promise<Record<string, unknown>> {
  const headers: Record<string, string> = { authorization: `Bearer ${token}` };
  if (body !== undefined) headers['content-type'] = 'application/json';
  const res = await s.app.inject({
    method: method as 'GET',
    url,
    headers,
    ...(body === undefined ? {} : { payload: JSON.stringify(body) }),
  });
  try {
    return res.json() as Record<string, unknown>;
  } catch {
    return {};
  }
}

async function subscribeRider(s: DemoState, r: Rider): Promise<void> {
  // Idempotent: the in-memory repo doesn't enforce one-active-per-user, so guard
  // against re-entering the beat (which would double-count members).
  if (await s.subs.findActiveByUser(r.id)) return;
  const init = await call(s, 'POST', '/payments/subscribe', r.token, {
    plan: 'monthly',
    routeId: s.routeId,
  });
  const webhookBody = JSON.stringify({
    event: 'charge.success',
    data: { reference: String(init.reference) },
  });
  await s.app.inject({
    method: 'POST',
    url: '/webhooks/paystack',
    headers: {
      'content-type': 'application/json',
      'x-paystack-signature': paystackSignature(webhookBody, PAYSTACK_SECRET),
    },
    payload: webhookBody,
  });
}

async function metrics(s: DemoState): Promise<Record<string, unknown>> {
  const active = await s.subs.findAllActive();
  let remaining = 0;
  let liability = 0;
  for (const r of s.riders) {
    remaining += await s.ents.remainingRides(r.id);
    liability += await s.creds.balancePesewas(r.id);
  }
  const rows = await s.resv.listForTrip(s.tripId);
  const count = (st: string) => rows.filter((x) => x.status === st).length;
  const boarded = count('boarded');
  const allocated = active.length * RIDES_PER_PERIOD;
  const ama = s.riders[0];
  return {
    subscribers: active.length,
    ridesAllocated: allocated,
    ridesRemaining: remaining,
    ridesConsumed: Math.max(0, allocated - remaining),
    confirmed: count('reserved') + boarded,
    declined: count('declined'),
    boarded,
    noShow: count('no_show'),
    capacity: CAPACITY,
    occupancy: CAPACITY ? Math.round((boarded / CAPACITY) * 100) : 0,
    subRevenue: active.length * FEE.monthly,
    creditLiability: liability,
    ama: {
      rides: await s.ents.remainingRides(ama.id),
      credits: await s.creds.balancePesewas(ama.id),
      pin: ama.pin ?? null,
    },
  };
}

const STEPS: Record<string, (s: DemoState) => Promise<void>> = {
  async subscribe(s) {
    for (const r of s.riders) await subscribeRider(s, r);
  },
  async confirm(s) {
    for (let n = 0; n < s.riders.length; n++) {
      const r = s.riders[n]!;
      const travelling = n < CONFIRM;
      const out = await call(s, 'POST', '/me/reservations', r.token, {
        tripId: s.tripId,
        travelDate: s.travelDate,
        direction: 'morning',
        travelling,
      });
      if (travelling) {
        r.reservationId = String(out.id);
        r.pin = String(out.pin);
      }
    }
  },
  async board(s) {
    for (let n = 0; n < BOARD; n++) {
      const r = s.riders[n]!;
      await call(s, 'POST', '/boarding/verify-pin', s.driverToken, {
        reservationId: r.reservationId,
        pin: r.pin,
      });
    }
  },
  async noshow(s) {
    await call(s, 'POST', '/admin/resolve-no-shows', s.adminToken, {
      travelDate: s.travelDate,
      direction: 'morning',
    });
  },
  async convert(s) {
    await call(s, 'POST', '/admin/convert-credits', s.adminToken);
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
        res.end(JSON.stringify({ ok: true, ...(await metrics(S)) }));
        return;
      }
      const name = url.startsWith('/demo/') ? url.slice('/demo/'.length) : '';
      if (STEPS[name] && req.method === 'POST') {
        if (!S) S = await build();
        await STEPS[name]!(S);
        res.setHeader('content-type', 'application/json');
        res.end(JSON.stringify({ ok: true, ...(await metrics(S)) }));
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
