// Boarding by code carries the same authz as the manifest and GPS reporting
// (#25): only the driver a run is assigned to may board its riders. Without it a
// four-character code was the only thing between any driver account and any
// rider's seat on any trip in the fleet.

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

async function setup() {
  const routes = new InMemoryRouteRepository();
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();
  const reservations = new InMemoryReservationRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  await entitlements.record({
    userId: RIDER,
    deltaRides: 44,
    reason: 'allocation',
    idempotencyKey: `alloc:${RIDER}`,
  });

  const route = await routes.create({ name: 'Circle ⇄ Madina' });
  const assigned = await drivers.create({ fullName: 'Kofi', userId: ASSIGNED_USER });
  await drivers.create({ fullName: 'Yaw', userId: OTHER_USER });
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
  const { id: reservationId, pin } = confirmed.json();

  return { app, reservationId, pin: pin as string };
}

/**
 * Present a boarding code as some driver.
 *
 * @param app - the built app.
 * @param driverUserId - the signed-in driver's user id.
 * @param reservationId - the seat being boarded.
 * @param pin - the code presented.
 * @returns the injected response.
 */
async function verifyAs(
  app: Awaited<ReturnType<typeof buildApp>>,
  driverUserId: string,
  reservationId: string,
  pin: string,
) {
  const token = await jwt.signAccessToken({ userId: driverUserId, role: 'driver' });
  return app.inject({
    method: 'POST',
    url: '/boarding/verify-pin',
    headers: bearer(token),
    payload: { reservationId, pin },
  });
}

describe('POST /boarding/verify-pin authorization', () => {
  it('boards for the driver the run is assigned to', async () => {
    const { app, reservationId, pin } = await setup();
    const res = await verifyAs(app, ASSIGNED_USER, reservationId, pin);
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ valid: true, reason: 'ok', deducted: true });
  });

  it('refuses a driver who is not on this run, even with the right code', async () => {
    const { app, reservationId, pin } = await setup();
    const res = await verifyAs(app, OTHER_USER, reservationId, pin);
    expect(res.statusCode).toBe(403);
  });

  it('refuses a driver account with no driver record at all', async () => {
    const { app, reservationId, pin } = await setup();
    const res = await verifyAs(app, '55555555-5555-4555-8555-555555555555', reservationId, pin);
    expect(res.statusCode).toBe(403);
  });

  it('does not leak the rider or debit a ride when it refuses', async () => {
    const { app, reservationId, pin } = await setup();
    await verifyAs(app, OTHER_USER, reservationId, pin);
    // The seat is untouched, so the assigned driver can still board it.
    const res = await verifyAs(app, ASSIGNED_USER, reservationId, pin);
    expect(res.json()).toMatchObject({ reason: 'ok', deducted: true });
  });

  it('stops reading codes once the reservation’s wrong-guess budget is spent', async () => {
    // 810,000 codes sounds like a lot until you can try thousands an hour
    // against one that stays valid all day.
    const { app, reservationId, pin } = await setup();
    for (let i = 0; i < 10; i++) {
      const res = await verifyAs(app, ASSIGNED_USER, reservationId, 'ZZZZ');
      expect(res.json()).toMatchObject({ valid: false, reason: 'invalid' });
    }
    // Budget spent: even the CORRECT code is refused now, which is what makes
    // the ceiling real rather than an inconvenience.
    const res = await verifyAs(app, ASSIGNED_USER, reservationId, pin);
    expect(res.json()).toMatchObject({ valid: false, reason: 'invalid' });
  });
});
