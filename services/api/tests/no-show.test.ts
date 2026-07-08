// No-show resolution (E4) — the cutoff mirror of boarding: a confirmed seat that
// was never boarded is deducted as a no-show (ADR-0014: deduct on boarding OR
// confirmed no-show).

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { BoardingService } from '../src/modules/boarding/boarding.service';
import { InMemoryScanEventRepository } from '../src/modules/boarding/scan-event.repository';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { InMemoryKvStore } from '../src/kv/kv.store';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const DATE = '2026-07-09';

function make() {
  const reservations = new InMemoryReservationRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  const svc = new BoardingService({
    scanEvents: new InMemoryScanEventRepository(),
    kv: new InMemoryKvStore(),
    reservations,
    entitlements,
    secret: auth.secret,
    passTtlSeconds: 60,
  });
  return { reservations, entitlements, svc };
}

/** Confirm (reserve) a rider for the day+direction and give them `rides`. */
async function reserve(
  reservations: InMemoryReservationRepository,
  entitlements: InMemoryEntitlementLedgerRepository,
  userId: string,
  direction: 'morning' | 'evening' = 'morning',
  rides = 10,
) {
  await entitlements.record({
    userId,
    deltaRides: rides,
    reason: 'allocation',
    idempotencyKey: `seed:${userId}`,
  });
  return reservations.respond({ userId, travelDate: DATE, direction, travelling: true });
}

describe('BoardingService.resolveNoShows', () => {
  it('deducts a ride and marks no_show for each confirmed-but-unboarded seat', async () => {
    const { reservations, entitlements, svc } = make();
    const ama = await reserve(reservations, entitlements, 'ama');
    await reserve(reservations, entitlements, 'kofi');

    expect(await svc.resolveNoShows(DATE, 'morning')).toEqual({ noShows: 2 });
    expect(await entitlements.remainingRides('ama')).toBe(9); // 10 − 1
    expect((await reservations.findById(ama.id))?.status).toBe('no_show');
  });

  it('only touches still-reserved rows of that day+direction', async () => {
    const { reservations, entitlements, svc } = make();
    const reserved = await reserve(reservations, entitlements, 'ama'); // target
    const boarded = await reserve(reservations, entitlements, 'kofi');
    await reservations.markBoarded(boarded.id); // already boarded → skip
    await reservations.respond({
      userId: 'yaw',
      travelDate: DATE,
      direction: 'morning',
      travelling: false,
    }); // declined
    await reservations.createPending({ userId: 'esi', travelDate: DATE, direction: 'morning' }); // pending
    await reserve(reservations, entitlements, 'kwame', 'evening'); // other direction

    expect(await svc.resolveNoShows(DATE, 'morning')).toEqual({ noShows: 1 });
    expect((await reservations.findById(reserved.id))?.status).toBe('no_show');
    expect((await reservations.findById(boarded.id))?.status).toBe('boarded'); // untouched
    expect(await entitlements.remainingRides('kofi')).toBe(10); // boarded row NOT no-show-deducted
  });

  it('is idempotent — a re-run does not double-deduct', async () => {
    const { reservations, entitlements, svc } = make();
    await reserve(reservations, entitlements, 'ama');

    await svc.resolveNoShows(DATE, 'morning');
    expect(await svc.resolveNoShows(DATE, 'morning')).toEqual({ noShows: 0 }); // already no_show
    expect(await entitlements.remainingRides('ama')).toBe(9); // deducted once, not twice
  });

  it('shares the boarding key space — a late board after a no-show cannot double-charge', async () => {
    const { reservations, entitlements, svc } = make();
    const ama = await reserve(reservations, entitlements, 'ama');

    await svc.resolveNoShows(DATE, 'morning'); // deducts on board:<id>, → 9
    // A late board would deduct on the SAME key (`board:<reservationId>`):
    await entitlements.record({
      userId: 'ama',
      deltaRides: -1,
      reason: 'boarding',
      refType: 'reservation',
      refId: ama.id,
      idempotencyKey: `board:${ama.id}`,
    });
    expect(await entitlements.remainingRides('ama')).toBe(9); // charged once, not twice
  });

  it('is a no-op when the ledgers are not wired', async () => {
    const svc = new BoardingService({
      scanEvents: new InMemoryScanEventRepository(),
      kv: new InMemoryKvStore(),
      secret: auth.secret,
      passTtlSeconds: 60,
    });
    expect(await svc.resolveNoShows(DATE, 'morning')).toEqual({ noShows: 0 });
  });
});

describe('POST /admin/resolve-no-shows', () => {
  it('requires the admin role (driver → 403)', async () => {
    const app = await buildApp({ auth });
    const driver = await jwt.signAccessToken({ userId: 'd', role: 'driver' });
    const res = await app.inject({
      method: 'POST',
      url: '/admin/resolve-no-shows',
      headers: bearer(driver),
      payload: { travelDate: DATE, direction: 'morning' },
    });
    expect(res.statusCode).toBe(403);
  });

  it('admin resolves no-shows and deducts the rides', async () => {
    const reservations = new InMemoryReservationRepository();
    const entitlements = new InMemoryEntitlementLedgerRepository();
    await reserve(reservations, entitlements, 'ama');
    const app = await buildApp({ auth, reservations, entitlements });
    const admin = await jwt.signAccessToken({ userId: 'admin', role: 'admin' });

    const res = await app.inject({
      method: 'POST',
      url: '/admin/resolve-no-shows',
      headers: bearer(admin),
      payload: { travelDate: DATE, direction: 'morning' },
    });
    expect(res.json()).toEqual({ noShows: 1 });
    expect(await entitlements.remainingRides('ama')).toBe(9);
  });
});
