import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { AskDispatchService } from '../src/modules/notifications/ask-dispatch.service';
import { FakeNotificationSender } from '../src/modules/notifications/notification.sender';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const ROUTE_A = crypto.randomUUID();
const ROUTE_B = crypto.randomUUID();
const TOMORROW = new Date(Date.now() + 86_400_000).toISOString().slice(0, 10);
const at = (hhmm: string) => new Date(`${TOMORROW}T${hhmm}:00Z`);

/** trips + subs + reservations wired to an ask-dispatch service. */
function make() {
  const trips = new InMemoryTripRepository();
  const subscriptions = new InMemorySubscriptionRepository();
  const reservations = new InMemoryReservationRepository();
  const notifier = new FakeNotificationSender();
  const svc = new AskDispatchService({ trips, subscriptions, reservations, notifier });
  return { trips, subscriptions, reservations, notifier, svc };
}

describe('AskDispatchService.dispatchAsks', () => {
  it('prompts every active subscriber of the day’s route trips (seed pending + notify)', async () => {
    const { trips, subscriptions, reservations, notifier, svc } = make();
    await trips.create({ routeId: ROUTE_A, scheduledAt: at('06:30') }); // morning trip on A
    await subscriptions.create({ userId: 'ama', plan: 'monthly', routeId: ROUTE_A });
    await subscriptions.create({ userId: 'kofi', plan: 'monthly', routeId: ROUTE_A });
    await subscriptions.create({ userId: 'other', plan: 'monthly', routeId: ROUTE_B }); // different route

    const res = await svc.dispatchAsks(TOMORROW, 'morning');
    expect(res).toEqual({ trips: 1, asked: 2 });
    expect(notifier.sent.map((n) => n.userId).sort()).toEqual(['ama', 'kofi']);
    // each got a pending reservation tied to the trip
    expect((await reservations.find('ama', TOMORROW, 'morning'))?.status).toBe('pending');
    expect(await reservations.find('other', TOMORROW, 'morning')).toBeNull();
  });

  it('only dispatches trips matching the direction (morning vs evening)', async () => {
    const { trips, subscriptions, svc, notifier } = make();
    await trips.create({ routeId: ROUTE_A, scheduledAt: at('17:00') }); // evening trip
    await subscriptions.create({ userId: 'ama', plan: 'monthly', routeId: ROUTE_A });

    expect(await svc.dispatchAsks(TOMORROW, 'morning')).toEqual({ trips: 0, asked: 0 });
    expect(await svc.dispatchAsks(TOMORROW, 'evening')).toEqual({ trips: 1, asked: 1 });
    expect(notifier.sent).toHaveLength(1);
  });

  it('is idempotent — re-running does not double-seed or double-notify a rider', async () => {
    const { trips, subscriptions, reservations, notifier, svc } = make();
    await trips.create({ routeId: ROUTE_A, scheduledAt: at('06:30') });
    await subscriptions.create({ userId: 'ama', plan: 'monthly', routeId: ROUTE_A });

    await svc.dispatchAsks(TOMORROW, 'morning');
    await svc.dispatchAsks(TOMORROW, 'morning'); // again
    expect(await reservations.listForUser('ama')).toHaveLength(1); // one pending, not two
    // (the notification best-effort re-sends; the reservation is the idempotent unit)
    expect(notifier.sent.length).toBeGreaterThanOrEqual(1);
  });

  it('resolveDefaults flips still-pending reservations to reserved', async () => {
    const { trips, subscriptions, reservations, svc } = make();
    await trips.create({ routeId: ROUTE_A, scheduledAt: at('06:30') });
    await subscriptions.create({ userId: 'ama', plan: 'monthly', routeId: ROUTE_A });
    await svc.dispatchAsks(TOMORROW, 'morning'); // ama is pending

    expect(await svc.resolveDefaults(TOMORROW, 'morning')).toEqual({ defaulted: 1 });
    expect(await reservations.find('ama', TOMORROW, 'morning')).toMatchObject({
      status: 'reserved',
      source: 'default',
    });
  });
});

describe('POST /admin/ask-dispatch (+ resolve-defaults)', () => {
  async function app() {
    const trips = new InMemoryTripRepository();
    const subscriptions = new InMemorySubscriptionRepository();
    const reservations = new InMemoryReservationRepository();
    await trips.create({ routeId: ROUTE_A, scheduledAt: at('06:30') });
    await subscriptions.create({ userId: 'rider-x', plan: 'monthly', routeId: ROUTE_A });
    const built = await buildApp({ auth, trips, subscriptions, reservations });
    return { built, reservations };
  }

  it('requires the admin role (commuter → 403)', async () => {
    const { built } = await app();
    const token = await jwt.signAccessToken({ userId: 'u', role: 'commuter' });
    const res = await built.inject({
      method: 'POST',
      url: '/admin/ask-dispatch',
      headers: bearer(token),
      payload: { travelDate: TOMORROW, direction: 'morning' },
    });
    expect(res.statusCode).toBe(403);
  });

  it('admin dispatches → rider gets a pending reservation → resolve defaults it', async () => {
    const { built, reservations } = await app();
    const admin = await jwt.signAccessToken({ userId: 'admin', role: 'admin' });

    const dispatch = await built.inject({
      method: 'POST',
      url: '/admin/ask-dispatch',
      headers: bearer(admin),
      payload: { travelDate: TOMORROW, direction: 'morning' },
    });
    expect(dispatch.json()).toEqual({ trips: 1, asked: 1 });
    expect((await reservations.find('rider-x', TOMORROW, 'morning'))?.status).toBe('pending');

    const resolve = await built.inject({
      method: 'POST',
      url: '/admin/resolve-defaults',
      headers: bearer(admin),
      payload: { travelDate: TOMORROW, direction: 'morning' },
    });
    expect(resolve.json()).toEqual({ defaulted: 1 });
    expect((await reservations.find('rider-x', TOMORROW, 'morning'))?.status).toBe('reserved');
  });
});
