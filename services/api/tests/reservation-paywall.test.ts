// Confirming a seat is the paywall (#security-hardening). Boarding fails open by
// design so a rider is never stranded at the kerb, which means the membership
// has to be checked hours earlier, at the moment the seat is claimed.

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const DATE = '2026-09-14';
const RIDER = '11111111-1111-4111-8111-111111111111';

async function setup() {
  const routes = new InMemoryRouteRepository();
  const trips = new InMemoryTripRepository();
  const reservations = new InMemoryReservationRepository();
  const subscriptions = new InMemorySubscriptionRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();

  const route = await routes.create({ name: 'Circle ⇄ Madina' });
  const other = await routes.create({ name: 'Kaneshie ⇄ Achimota' });
  const trip = await trips.create({
    routeId: route.id,
    scheduledAt: new Date(`${DATE}T06:30:00.000Z`),
  });
  const otherTrip = await trips.create({
    routeId: other.id,
    scheduledAt: new Date(`${DATE}T06:30:00.000Z`),
  });

  const app = await buildApp({ auth, routes, trips, reservations, subscriptions, entitlements });
  return { app, route, trip, otherTrip, subscriptions, entitlements };
}

/**
 * Give a rider a live membership on a corridor with rides on the ledger.
 *
 * @param deps - the stores to seed.
 * @param deps.subscriptions - the membership store.
 * @param deps.entitlements - the ride ledger.
 * @param routeId - the corridor the membership covers.
 * @param rides - how many rides to allocate.
 */
async function giveMembership(
  deps: Pick<Awaited<ReturnType<typeof setup>>, 'subscriptions' | 'entitlements'>,
  routeId: string,
  rides = 44,
): Promise<void> {
  await deps.subscriptions.create({ userId: RIDER, plan: 'monthly', routeId });
  if (rides > 0) {
    await deps.entitlements.record({
      userId: RIDER,
      deltaRides: rides,
      reason: 'allocation',
      idempotencyKey: `alloc:${routeId}`,
    });
  }
}

/**
 * Answer the daily prompt as the rider.
 *
 * @param app - the built app.
 * @param body - the reservation answer.
 * @returns the injected response.
 */
async function respond(
  app: Awaited<ReturnType<typeof buildApp>>,
  body: Record<string, unknown>,
): Promise<{ statusCode: number; json: () => { error?: string } }> {
  const token = await jwt.signAccessToken({ userId: RIDER, role: 'commuter' });
  return app.inject({
    method: 'POST',
    url: '/me/reservations',
    headers: { authorization: `Bearer ${token}` },
    payload: { travelDate: DATE, direction: 'morning', ...body },
  });
}

describe('POST /me/reservations paywall', () => {
  it('refuses a rider with no membership', async () => {
    const { app, trip } = await setup();
    const res = await respond(app, { tripId: trip.id, travelling: true });
    expect(res.statusCode).toBe(402);
    expect(res.json().error).toBe('no_subscription');
  });

  it('refuses a member who has spent the period’s rides', async () => {
    const ctx = await setup();
    await giveMembership(ctx, ctx.route.id, 0);
    const res = await respond(ctx.app, { tripId: ctx.trip.id, travelling: true });
    expect(res.statusCode).toBe(402);
    expect(res.json().error).toBe('no_rides_left');
  });

  it('refuses a run on a corridor the membership does not cover', async () => {
    const ctx = await setup();
    await giveMembership(ctx, ctx.route.id);
    const res = await respond(ctx.app, { tripId: ctx.otherTrip.id, travelling: true });
    expect(res.statusCode).toBe(402);
    expect(res.json().error).toBe('route_not_covered');
  });

  it('lets a paid-up member claim a seat on their own corridor', async () => {
    const ctx = await setup();
    await giveMembership(ctx, ctx.route.id);
    const res = await respond(ctx.app, { tripId: ctx.trip.id, travelling: true });
    expect(res.statusCode).toBe(200);
  });

  it('always lets a rider decline, membership or not', async () => {
    // Declining consumes nothing, and a lapsed rider still needs to be able to
    // tell the driver not to wait for them.
    const { app, trip } = await setup();
    const res = await respond(app, { tripId: trip.id, travelling: false });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ status: 'declined' });
  });

  it('stands down when no membership store is wired', async () => {
    // A bare buildApp() in a unit test must not start refusing every rider on
    // a repository nobody provided.
    const reservations = new InMemoryReservationRepository();
    const app = await buildApp({ auth, reservations });
    const token = await jwt.signAccessToken({ userId: RIDER, role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: '/me/reservations',
      headers: { authorization: `Bearer ${token}` },
      payload: { travelDate: DATE, direction: 'morning', travelling: true },
    });
    expect(res.statusCode).toBe(200);
  });
});
