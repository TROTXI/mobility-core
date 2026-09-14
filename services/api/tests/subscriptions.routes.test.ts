import { randomUUID } from 'node:crypto';
import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import {
  InMemorySubscriptionRepository,
  type CurrentSubscription,
} from '../src/modules/subscriptions/subscription.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (token: string) => ({ authorization: `Bearer ${token}` });

class PausedSubscriptionRepository extends InMemorySubscriptionRepository {
  constructor(private readonly currentStatus: CurrentSubscription['status'] = 'active') {
    super();
  }

  override async findCurrentByUser(userId: string): Promise<CurrentSubscription | null> {
    const current = await super.findCurrentByUser(userId);
    return current ? { ...current, status: this.currentStatus, paused: true } : null;
  }
}

describe('GET /me/subscription', () => {
  it('requires authentication', async () => {
    const app = await buildApp({ auth, subscriptions: new InMemorySubscriptionRepository() });

    expect((await app.inject({ method: 'GET', url: '/me/subscription' })).statusCode).toBe(401);
  });

  it('returns no current subscription without exposing historical rows', async () => {
    const subscriptions = new InMemorySubscriptionRepository();
    const app = await buildApp({ auth, subscriptions });
    const token = await jwt.signAccessToken({ userId: 'rider-no-subscription', role: 'commuter' });

    const response = await app.inject({
      method: 'GET',
      url: '/me/subscription',
      headers: bearer(token),
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({ subscribed: false, subscription: null });
  });

  it('returns the rider route, stops and next renewal date', async () => {
    const subscriptions = new InMemorySubscriptionRepository();
    const routeId = randomUUID();
    const pickupStopId = randomUUID();
    const dropoffStopId = randomUUID();
    const periodStart = new Date('2026-09-01T00:00:00.000Z');
    const periodEnd = new Date('2026-10-01T00:00:00.000Z');
    const created = await subscriptions.create({
      userId: 'rider-active',
      plan: 'monthly',
      routeId,
      pickupStopId,
      dropoffStopId,
      periodStart,
      periodEnd,
    });
    const app = await buildApp({ auth, subscriptions });
    const token = await jwt.signAccessToken({ userId: 'rider-active', role: 'commuter' });

    const response = await app.inject({
      method: 'GET',
      url: '/me/subscription',
      headers: bearer(token),
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({
      subscribed: true,
      subscription: {
        id: created.id,
        plan: 'monthly',
        status: 'active',
        paused: false,
        routeId,
        pickupStopId,
        dropoffStopId,
        periodStart: periodStart.toISOString(),
        renewsAt: periodEnd.toISOString(),
      },
    });
  });

  it('keeps a paused membership visible without promising an unknown renewal date', async () => {
    const subscriptions = new PausedSubscriptionRepository();
    const routeId = randomUUID();
    await subscriptions.create({
      userId: 'rider-paused',
      plan: 'monthly',
      routeId,
      periodStart: new Date('2026-09-01T00:00:00.000Z'),
      periodEnd: new Date('2026-10-01T00:00:00.000Z'),
    });
    const app = await buildApp({ auth, subscriptions });
    const token = await jwt.signAccessToken({ userId: 'rider-paused', role: 'commuter' });

    const response = await app.inject({
      method: 'GET',
      url: '/me/subscription',
      headers: bearer(token),
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toMatchObject({
      subscribed: true,
      subscription: { status: 'active', paused: true, routeId, renewsAt: null },
    });
  });

  it('represents a suspended subscription and an open pause independently', async () => {
    const subscriptions = new PausedSubscriptionRepository('suspended');
    await subscriptions.create({
      userId: 'rider-suspended-paused',
      plan: 'monthly',
      routeId: randomUUID(),
      periodEnd: new Date('2026-10-01T00:00:00.000Z'),
    });
    const app = await buildApp({ auth, subscriptions });
    const token = await jwt.signAccessToken({
      userId: 'rider-suspended-paused',
      role: 'commuter',
    });

    const response = await app.inject({
      method: 'GET',
      url: '/me/subscription',
      headers: bearer(token),
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toMatchObject({
      subscribed: true,
      subscription: { status: 'suspended', paused: true, renewsAt: null },
    });
  });
});
