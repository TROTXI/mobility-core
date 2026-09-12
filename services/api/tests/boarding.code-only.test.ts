// Boarding by code with nobody picked first (#241) — the door flow.
//
// The old shape made a driver find the rider on the manifest and only then type
// the code they had just been read. That is two steps where the job has one,
// and the queue is the thing that pays for it.

import type { LightMyRequestResponse } from 'fastify';
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

const RIDER_A = '22222222-2222-4222-8222-222222222222';
const RIDER_B = '22222222-2222-4222-8222-222222222223';
const ASSIGNED_USER = '33333333-3333-4333-8333-333333333333';
const OTHER_USER = '44444444-4444-4444-8444-444444444444';
const STARTING_RIDES = 44;

const asDriver = async (userId: string) => ({
  authorization: `Bearer ${await jwt.signAccessToken({ userId, role: 'driver' })}`,
});

async function setup() {
  const routes = new InMemoryRouteRepository();
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();
  const reservations = new InMemoryReservationRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  for (const rider of [RIDER_A, RIDER_B]) {
    await entitlements.record({
      userId: rider,
      deltaRides: STARTING_RIDES,
      reason: 'allocation',
      idempotencyKey: `alloc:${rider}`,
    });
  }

  const route = await routes.create({ name: 'Circle to Madina' });
  const assigned = await drivers.create({ fullName: 'Kofi Anum Quartey', userId: ASSIGNED_USER });
  await drivers.create({ fullName: 'Naa Dedei Lartey', userId: OTHER_USER });
  const trip = await trips.create({
    routeId: route.id,
    scheduledAt: new Date(`${today()}T06:30:00.000Z`),
    assignedDriverId: assigned.id,
  });

  const app = await buildApp({ auth, routes, trips, drivers, reservations, entitlements });

  /**
   * Confirm a seat and hand back the code the rider would read out.
   *
   * @param userId - the rider.
   * @param direction - morning or evening, so two riders can share a trip.
   * @returns the reservation id and its plaintext code.
   */
  const confirm = async (
    userId: string,
    direction: 'morning' | 'evening',
  ): Promise<{ id: string; code: string }> => {
    const token = await jwt.signAccessToken({ userId, role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: '/me/reservations',
      headers: bearer(token),
      payload: { tripId: trip.id, travelDate: today(), direction, travelling: true },
    });
    return { id: res.json().id, code: res.json().pin };
  };

  return { app, trip, reservations, entitlements, confirm };
}

/**
 * Present a code to the run, with nobody selected.
 *
 * @param app - the built app.
 * @param tripId - the run.
 * @param code - the code as typed.
 * @param userId - the signed-in driver.
 * @returns the injected response.
 */
async function board(
  app: Awaited<ReturnType<typeof setup>>['app'],
  tripId: string,
  code: string,
  userId: string = ASSIGNED_USER,
): Promise<LightMyRequestResponse> {
  return app.inject({
    method: 'POST',
    url: '/boarding/verify-code',
    headers: await asDriver(userId),
    payload: { tripId, code },
  });
}

describe('a code alone boards the right rider (#241)', () => {
  it('finds the seat without being told which one', async () => {
    const { app, trip, confirm, entitlements } = await setup();
    const ama = await confirm(RIDER_A, 'morning');

    const res = await board(app, trip.id, ama.code);

    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ reason: 'ok', riderId: RIDER_A, deducted: true });
    expect(await entitlements.remainingRides(RIDER_A)).toBe(STARTING_RIDES - 1);
  });

  it('picks the right one of two riders on the same run', async () => {
    const { app, trip, confirm, entitlements } = await setup();
    await confirm(RIDER_A, 'morning');
    const kwabena = await confirm(RIDER_B, 'evening');

    const res = await board(app, trip.id, kwabena.code);

    expect(res.json()).toMatchObject({ reason: 'ok', riderId: RIDER_B });
    // The other rider is untouched — the whole risk of searching by code.
    expect(await entitlements.remainingRides(RIDER_A)).toBe(STARTING_RIDES);
  });

  it('takes the code in any case, as a driver would type it', async () => {
    const { app, trip, confirm } = await setup();
    const ama = await confirm(RIDER_A, 'morning');

    const res = await board(app, trip.id, ama.code.toLowerCase());
    expect(res.json()).toMatchObject({ reason: 'ok', riderId: RIDER_A });
  });

  it('says invalid for a code nobody on this run holds', async () => {
    const { app, trip, confirm, entitlements } = await setup();
    await confirm(RIDER_A, 'morning');

    // 'ZZZZ' is in the alphabet but astronomically unlikely to be issued.
    const res = await board(app, trip.id, 'ZZZZ');
    expect(res.json()).toMatchObject({ reason: 'invalid', riderId: null, deducted: false });
    expect(await entitlements.remainingRides(RIDER_A)).toBe(STARTING_RIDES);
  });

  it('charges once when the driver types the same code twice', async () => {
    const { app, trip, confirm, entitlements } = await setup();
    const ama = await confirm(RIDER_A, 'morning');

    await board(app, trip.id, ama.code);
    const again = await board(app, trip.id, ama.code);

    expect(again.json()).toMatchObject({ reason: 'already_boarded', deducted: false });
    expect(await entitlements.remainingRides(RIDER_A)).toBe(STARTING_RIDES - 1);
  });

  it('boards a rider previously marked a no-show, at no extra cost', async () => {
    const { app, trip, confirm, entitlements } = await setup();
    const ama = await confirm(RIDER_A, 'morning');
    await app.inject({
      method: 'POST',
      url: '/boarding/no-show',
      headers: await asDriver(ASSIGNED_USER),
      payload: { reservationId: ama.id },
    });

    const res = await board(app, trip.id, ama.code);

    expect(res.json()).toMatchObject({ reason: 'ok', riderId: RIDER_A });
    expect(await entitlements.remainingRides(RIDER_A)).toBe(STARTING_RIDES - 1);
  });
});

describe('what a code must not reach (#241)', () => {
  it('refuses a driver who is not on this run', async () => {
    const { app, trip, confirm, entitlements } = await setup();
    const ama = await confirm(RIDER_A, 'morning');

    const res = await board(app, trip.id, ama.code, OTHER_USER);

    expect(res.statusCode).toBe(403);
    expect(await entitlements.remainingRides(RIDER_A)).toBe(STARTING_RIDES);
  });

  it('will not find a seat the rider declined', async () => {
    const { app, trip, reservations, confirm, entitlements } = await setup();
    const ama = await confirm(RIDER_A, 'morning');
    // The rider changes their mind; the seat is no longer a seat.
    await reservations.respond({
      userId: RIDER_A,
      tripId: trip.id,
      travelDate: today(),
      direction: 'morning',
      travelling: false,
    });

    const res = await board(app, trip.id, ama.code);

    expect(res.json()).toMatchObject({ reason: 'invalid', deducted: false });
    expect(await entitlements.remainingRides(RIDER_A)).toBe(STARTING_RIDES);
  });

  it('will not reach a seat on another run', async () => {
    const { app, confirm } = await setup();
    const ama = await confirm(RIDER_A, 'morning');

    const res = await board(app, '99999999-9999-4999-8999-999999999999', ama.code);

    // No such trip means no assignment to check, and no seats to search.
    expect(res.json()).toMatchObject({ reason: 'invalid', riderId: null });
  });

  it('is not reachable with a commuter token', async () => {
    const { app, trip, confirm } = await setup();
    const ama = await confirm(RIDER_A, 'morning');

    const res = await app.inject({
      method: 'POST',
      url: '/boarding/verify-code',
      headers: bearer(await jwt.signAccessToken({ userId: RIDER_A, role: 'commuter' })),
      payload: { tripId: trip.id, code: ama.code },
    });

    expect(res.statusCode).toBe(403);
  });

  it('rejects a malformed code at the edge', async () => {
    const { app, trip } = await setup();
    const res = await board(app, trip.id, 'AB');
    expect(res.statusCode).toBe(400);
  });

  it('stops answering after enough wrong guesses on one run', async () => {
    const { app, trip, confirm } = await setup();
    const ama = await confirm(RIDER_A, 'morning');

    // Budget is 30 wrong codes per run per driver per window.
    for (let i = 0; i < 30; i += 1) {
      await board(app, trip.id, 'ZZZZ');
    }

    // Even the RIGHT code is refused once the budget is spent, which is the
    // point: the ceiling is on the attempt, not on the guess being wrong.
    const res = await board(app, trip.id, ama.code);
    expect(res.json()).toMatchObject({ reason: 'invalid', deducted: false });
  });
});
