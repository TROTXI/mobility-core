import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { InMemoryCreditLedgerRepository } from '../src/modules/entitlements/credit-ledger.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });

describe('EntitlementLedger (ride counts)', () => {
  it('remaining rides = sum of deltas', async () => {
    const ledger = new InMemoryEntitlementLedgerRepository();
    await ledger.record({
      userId: 'u1',
      deltaRides: 44,
      reason: 'allocation',
      idempotencyKey: 'a',
    });
    await ledger.record({ userId: 'u1', deltaRides: -1, reason: 'boarding', idempotencyKey: 'b' });
    await ledger.record({
      userId: 'u2',
      deltaRides: 10,
      reason: 'allocation',
      idempotencyKey: 'c',
    });
    expect(await ledger.remainingRides('u1')).toBe(43);
    expect(await ledger.remainingRides('u2')).toBe(10);
    expect(await ledger.remainingRides('nobody')).toBe(0);
  });

  it('a duplicate idempotency key is a no-op', async () => {
    const ledger = new InMemoryEntitlementLedgerRepository();
    await ledger.record({
      userId: 'u1',
      deltaRides: 44,
      reason: 'allocation',
      idempotencyKey: 'k',
    });
    await ledger.record({
      userId: 'u1',
      deltaRides: 44,
      reason: 'allocation',
      idempotencyKey: 'k',
    });
    expect(await ledger.remainingRides('u1')).toBe(44);
  });
});

describe('CreditLedger (pesewas)', () => {
  it('balance = sum of deltas; duplicate key is a no-op', async () => {
    const ledger = new InMemoryCreditLedgerRepository();
    await ledger.record({
      userId: 'u1',
      deltaPesewas: 4000,
      reason: 'month_end_conversion',
      idempotencyKey: 'k',
    });
    await ledger.record({
      userId: 'u1',
      deltaPesewas: 4000,
      reason: 'month_end_conversion',
      idempotencyKey: 'k',
    });
    await ledger.record({
      userId: 'u1',
      deltaPesewas: -1000,
      reason: 'renewal_applied',
      idempotencyKey: 'r',
    });
    expect(await ledger.balancePesewas('u1')).toBe(3000);
  });
});

describe('GET /me/rides', () => {
  it('requires authentication', async () => {
    const app = await buildApp({ auth });
    expect((await app.inject({ method: 'GET', url: '/me/rides' })).statusCode).toBe(401);
  });

  it('returns remaining rides + credit balance for the caller', async () => {
    const entitlements = new InMemoryEntitlementLedgerRepository();
    const credits = new InMemoryCreditLedgerRepository();
    await entitlements.record({
      userId: 'rider-1',
      deltaRides: 44,
      reason: 'allocation',
      idempotencyKey: 'a',
    });
    await credits.record({
      userId: 'rider-1',
      deltaPesewas: 4000,
      reason: 'loyalty',
      idempotencyKey: 'c',
    });
    const app = await buildApp({ auth, entitlements, credits });
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });

    const res = await app.inject({ method: 'GET', url: '/me/rides', headers: bearer(token) });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ remainingRides: 44, creditPesewas: 4000 });
  });

  it('defaults to zero for a rider with no ledger entries', async () => {
    const app = await buildApp({ auth });
    const token = await jwt.signAccessToken({ userId: 'newbie', role: 'commuter' });
    const res = await app.inject({ method: 'GET', url: '/me/rides', headers: bearer(token) });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ remainingRides: 0, creditPesewas: 0 });
  });
});
