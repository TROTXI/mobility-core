// Boarding from the manifest, and marking one rider a no-show (#227). The
// manifest detail frame offers a driver exactly two actions on a rider, and
// before this only one of them existed anywhere in the API.

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const today = () => new Date().toISOString().slice(0, 10);

const RIDER = '22222222-2222-4222-8222-222222222222';
const ASSIGNED_USER = '33333333-3333-4333-8333-333333333333';
const OTHER_USER = '44444444-4444-4444-8444-444444444444';
const STARTING_RIDES = 44;

async function setup() {
  const routes = new InMemoryRouteRepository();
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();
  const reservations = new InMemoryReservationRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  await entitlements.record({
    userId: RIDER,
    deltaRides: STARTING_RIDES,
    reason: 'allocation',
    idempotencyKey: `alloc:${RIDER}`,
  });

  const route = await routes.create({ name: 'Circle to Madina' });
  const assigned = await drivers.create({ fullName: 'Kofi Anum Quartey', userId: ASSIGNED_USER });
  await drivers.create({ fullName: 'Naa Dedei Lartey', userId: OTHER_USER });
  const trip = await trips.create({
    routeId: route.id,
    scheduledAt: new Date(`${today()}T06:30:00.000Z`),
    assignedDriverId: assigned.id,
  });

  const app = await buildApp({ auth, routes, trips, drivers, reservations, entitlements });

  const riderToken = await jwt.signAccessToken({ userId: RIDER, role: 'commuter' });
  const confirmed = await app.inject({
    method: 'POST',
    url: '/me/reservations',
    headers: bearer(riderToken),
    payload: { tripId: trip.id, travelDate: today(), direction: 'morning', travelling: true },
  });

  return {
    app,
    trip,
    reservations,
    entitlements,
    reservationId: confirmed.json().id as string,
  };
}

const asDriver = async (userId: string) => ({
  authorization: `Bearer ${await jwt.signAccessToken({ userId, role: 'driver' })}`,
});

/**
 * The rider's remaining ride balance.
 *
 * @param entitlements - the ledger.
 * @returns how many rides the rider has left.
 */
async function ridesLeft(entitlements: InMemoryEntitlementLedgerRepository): Promise<number> {
  return entitlements.remainingRides(RIDER);
}

describe('boarding from the manifest (#227)', () => {
  it('boards a rider the driver identified by photo, with no code', async () => {
    const { app, reservationId, entitlements } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/boarding/board',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId },
    });

    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ reason: 'ok', riderId: RIDER, deducted: true });
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES - 1);
  });

  it('charges once when the driver taps twice', async () => {
    const { app, reservationId, entitlements } = await setup();
    const board = async () =>
      app.inject({
        method: 'POST',
        url: '/boarding/board',
        headers: await asDriver(ASSIGNED_USER),
        payload: { reservationId },
      });

    await board();
    const again = await board();

    expect(again.json()).toMatchObject({ reason: 'already_boarded', deducted: false });
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES - 1);
  });

  it('refuses a driver who is not on this run', async () => {
    const { app, reservationId, entitlements } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/boarding/board',
      headers: await asDriver(OTHER_USER),
      payload: { reservationId },
    });

    expect(res.statusCode).toBe(403);
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES);
  });

  it('is not reachable with a commuter token', async () => {
    const { app, reservationId } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/boarding/board',
      headers: bearer(await jwt.signAccessToken({ userId: RIDER, role: 'commuter' })),
      payload: { reservationId },
    });

    expect(res.statusCode).toBe(403);
  });
});

describe('marking one rider a no-show (#227)', () => {
  it('deducts the ride there and then, rather than waiting for the cutoff', async () => {
    const { app, reservationId, reservations, entitlements } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/boarding/no-show',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId },
    });

    expect(res.json()).toMatchObject({ reason: 'ok', deducted: true });
    expect((await reservations.findById(reservationId))?.status).toBe('no_show');
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES - 1);
  });

  it('is idempotent', async () => {
    const { app, reservationId, entitlements } = await setup();
    const mark = async () =>
      app.inject({
        method: 'POST',
        url: '/boarding/no-show',
        headers: await asDriver(ASSIGNED_USER),
        payload: { reservationId },
      });

    await mark();
    const again = await mark();

    expect(again.json()).toMatchObject({ reason: 'already_no_show', deducted: false });
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES - 1);
  });

  it('will not un-board a rider who is already on the vehicle', async () => {
    const { app, reservationId, reservations } = await setup();
    await app.inject({
      method: 'POST',
      url: '/boarding/board',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId },
    });

    const res = await app.inject({
      method: 'POST',
      url: '/boarding/no-show',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId },
    });

    expect(res.json()).toMatchObject({ reason: 'already_boarded', deducted: false });
    expect((await reservations.findById(reservationId))?.status).toBe('boarded');
  });

  it('refuses a driver who is not on this run', async () => {
    const { app, reservationId, reservations } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/boarding/no-show',
      headers: await asDriver(OTHER_USER),
      payload: { reservationId },
    });

    expect(res.statusCode).toBe(403);
    expect((await reservations.findById(reservationId))?.status).toBe('reserved');
  });

  it('lets a rider who ran up late still board, at no extra cost', async () => {
    const { app, reservationId, reservations, entitlements } = await setup();
    await app.inject({
      method: 'POST',
      url: '/boarding/no-show',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId },
    });

    const boarded = await app.inject({
      method: 'POST',
      url: '/boarding/board',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId },
    });

    expect(boarded.json()).toMatchObject({ reason: 'ok' });
    expect((await reservations.findById(reservationId))?.status).toBe('boarded');
    // Both paths share `board:<reservationId>`, so the seat is charged once.
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES - 1);
  });

  it('is never charged twice by the cutoff sweep afterwards', async () => {
    const { app, reservationId, entitlements } = await setup();
    await app.inject({
      method: 'POST',
      url: '/boarding/no-show',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId },
    });

    const sweep = await app.inject({
      method: 'POST',
      url: '/admin/resolve-no-shows',
      headers: bearer(await jwt.signAccessToken({ userId: 'ops-1', role: 'admin' })),
      payload: { travelDate: today(), direction: 'morning' },
    });

    // The sweep only looks at still-`reserved` seats, so this one is gone from
    // its view entirely.
    expect(sweep.json()).toMatchObject({ noShows: 0 });
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES - 1);
  });
});

describe('a reservation that is not a seat (#227)', () => {
  it('will not board a rider who declined', async () => {
    const { app, reservations, entitlements } = await setup();
    const declined = await reservations.respond({
      userId: RIDER,
      travelDate: today(),
      direction: 'evening',
      travelling: false,
    });

    const res = await app.inject({
      method: 'POST',
      url: '/boarding/board',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId: declined.id },
    });

    // The manifest never offers this row, but the endpoint takes an id — and
    // boarding it would seat someone in a place capacity had given away.
    expect(res.json()).toMatchObject({ reason: 'not_boardable', deducted: false });
    expect((await reservations.findById(declined.id))?.status).toBe('declined');
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES);
  });

  it('will not charge a no-show to a rider who declined', async () => {
    const { app, reservations, entitlements } = await setup();
    const declined = await reservations.respond({
      userId: RIDER,
      travelDate: today(),
      direction: 'evening',
      travelling: false,
    });

    const res = await app.inject({
      method: 'POST',
      url: '/boarding/no-show',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId: declined.id },
    });

    // The group that must never be charged: they said they were not travelling.
    expect(res.json()).toMatchObject({ reason: 'not_boardable', deducted: false });
    expect((await reservations.findById(declined.id))?.status).toBe('declined');
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES);
  });

  it('will not act on a seat that was never confirmed', async () => {
    const { app, trip, reservations, entitlements } = await setup();
    const pending = await reservations.createPending({
      userId: RIDER,
      tripId: trip.id,
      travelDate: today(),
      direction: 'evening',
    });

    for (const url of ['/boarding/board', '/boarding/no-show']) {
      const res = await app.inject({
        method: 'POST',
        url,
        headers: await asDriver(ASSIGNED_USER),
        payload: { reservationId: pending.id },
      });
      expect(res.json()).toMatchObject({ reason: 'not_boardable', deducted: false });
    }
    expect((await reservations.findById(pending.id))?.status).toBe('pending');
    expect(await ridesLeft(entitlements)).toBe(STARTING_RIDES);
  });
});

describe('the manifest after a no-show (#227, #230)', () => {
  it('keeps the rider visible, flagged, so the driver can undo it', async () => {
    const { app, trip, reservationId } = await setup();
    await app.inject({
      method: 'POST',
      url: '/boarding/no-show',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId },
    });

    const manifest = await app.inject({
      method: 'GET',
      url: `/boarding/manifest?tripId=${trip.id}`,
      headers: await asDriver(ASSIGNED_USER),
    });

    expect(manifest.json().riders).toHaveLength(1);
    expect(manifest.json().riders[0]).toMatchObject({ noShow: true, boarded: false });
  });

  it('says how each seat was taken, so standby can be counted', async () => {
    const { app, trip } = await setup();
    const manifest = await app.inject({
      method: 'GET',
      url: `/boarding/manifest?tripId=${trip.id}`,
      headers: await asDriver(ASSIGNED_USER),
    });

    expect(manifest.json().riders[0]).toMatchObject({ source: 'confirmation' });
  });
});
