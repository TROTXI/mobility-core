import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { CreditService } from '../src/modules/entitlements/credit.service';
import { InMemoryCreditLedgerRepository } from '../src/modules/entitlements/credit-ledger.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const PER_RIDE = 50; // pesewas, test value

function make() {
  const entitlements = new InMemoryEntitlementLedgerRepository();
  const credits = new InMemoryCreditLedgerRepository();
  const subscriptions = new InMemorySubscriptionRepository();
  const svc = new CreditService({
    entitlements,
    credits,
    subscriptions,
    creditPesewasPerRide: PER_RIDE,
  });
  return { entitlements, credits, subscriptions, svc };
}

/** Seed `rides` allocated entitlement for a user. */
async function allocate(
  entitlements: InMemoryEntitlementLedgerRepository,
  userId: string,
  rides: number,
): Promise<void> {
  await entitlements.record({
    userId,
    deltaRides: rides,
    reason: 'allocation',
    idempotencyKey: `seed:${userId}`,
  });
}

describe('CreditService.convertUnusedRides', () => {
  it('mints credit for the remaining rides and retires them', async () => {
    const { entitlements, credits, svc } = make();
    await allocate(entitlements, 'ama', 10);

    const res = await svc.convertUnusedRides('ama', 'period-1');
    expect(res).toEqual({ userId: 'ama', ridesConverted: 10, creditPesewas: 10 * PER_RIDE });
    expect(await credits.balancePesewas('ama')).toBe(10 * PER_RIDE);
    expect(await entitlements.remainingRides('ama')).toBe(0); // rides retired, don't carry
  });

  it('is a no-op when there are no unused rides', async () => {
    const { entitlements, credits, svc } = make();
    await allocate(entitlements, 'ama', 10);
    await entitlements.record({
      userId: 'ama',
      deltaRides: -10,
      reason: 'boarding',
      idempotencyKey: 'used:ama',
    });

    expect(await svc.convertUnusedRides('ama', 'period-1')).toEqual({
      userId: 'ama',
      ridesConverted: 0,
      creditPesewas: 0,
    });
    expect(await credits.balancePesewas('ama')).toBe(0);
  });

  it('is idempotent per period — re-running does not double-credit', async () => {
    const { entitlements, credits, svc } = make();
    await allocate(entitlements, 'ama', 8);

    await svc.convertUnusedRides('ama', 'period-1');
    await svc.convertUnusedRides('ama', 'period-1'); // replay
    expect(await credits.balancePesewas('ama')).toBe(8 * PER_RIDE); // not 2×
    expect(await entitlements.remainingRides('ama')).toBe(0);
  });

  it('converges after a partial run (credit written, debit not yet)', async () => {
    const { entitlements, credits, svc } = make();
    await allocate(entitlements, 'ama', 6);
    // Simulate a crash after the credit grant but before the ride debit: the
    // credit row already exists under the period key, rides still full.
    await credits.record({
      userId: 'ama',
      deltaPesewas: 6 * PER_RIDE,
      reason: 'month_end_conversion',
      idempotencyKey: 'convert:period-1',
    });

    const res = await svc.convertUnusedRides('ama', 'period-1');
    expect(res.ridesConverted).toBe(6);
    expect(await credits.balancePesewas('ama')).toBe(6 * PER_RIDE); // credit not doubled
    expect(await entitlements.remainingRides('ama')).toBe(0); // debit now applied
  });
});

describe('CreditService.convertAllActive', () => {
  it('converts every active subscriber and sums the totals (skipping empties)', async () => {
    const { entitlements, subscriptions, svc } = make();
    await subscriptions.create({ userId: 'ama', plan: 'monthly' });
    await subscriptions.create({ userId: 'kofi', plan: 'monthly' });
    await subscriptions.create({ userId: 'norides', plan: 'monthly' });
    await allocate(entitlements, 'ama', 10);
    await allocate(entitlements, 'kofi', 4);

    expect(await svc.convertAllActive()).toEqual({
      riders: 2, // 'norides' had nothing → skipped
      ridesConverted: 14,
      creditPesewas: 14 * PER_RIDE,
    });
  });
});

describe('POST /admin/convert-credits', () => {
  it('requires the admin role (commuter → 403)', async () => {
    const app = await buildApp({ auth, subscriptions: new InMemorySubscriptionRepository() });
    const token = await jwt.signAccessToken({ userId: 'u', role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: '/admin/convert-credits',
      headers: bearer(token),
    });
    expect(res.statusCode).toBe(403);
  });

  it('503s when no subscription store is wired', async () => {
    const app = await buildApp({ auth }); // no subscriptions → service unwired
    const admin = await jwt.signAccessToken({ userId: 'admin', role: 'admin' });
    const res = await app.inject({
      method: 'POST',
      url: '/admin/convert-credits',
      headers: bearer(admin),
    });
    expect(res.statusCode).toBe(503);
  });

  it('admin converts all active riders', async () => {
    const entitlements = new InMemoryEntitlementLedgerRepository();
    const credits = new InMemoryCreditLedgerRepository();
    const subscriptions = new InMemorySubscriptionRepository();
    await subscriptions.create({ userId: 'ama', plan: 'monthly' });
    await entitlements.record({
      userId: 'ama',
      deltaRides: 12,
      reason: 'allocation',
      idempotencyKey: 'seed:ama',
    });
    const app = await buildApp({
      auth,
      subscriptions,
      entitlements,
      credits,
      creditPesewasPerRide: PER_RIDE,
    });
    const admin = await jwt.signAccessToken({ userId: 'admin', role: 'admin' });

    const res = await app.inject({
      method: 'POST',
      url: '/admin/convert-credits',
      headers: bearer(admin),
    });
    expect(res.json()).toEqual({ riders: 1, ridesConverted: 12, creditPesewas: 12 * PER_RIDE });
    expect(await credits.balancePesewas('ama')).toBe(12 * PER_RIDE);
  });
});
