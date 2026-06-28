import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryLedgerRepository } from '../src/modules/ledger/ledger.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (token: string) => ({ authorization: `Bearer ${token}` });

describe('GET /me/balance', () => {
  it('rejects an unauthenticated request', async () => {
    const app = await buildApp({ auth, ledger: new InMemoryLedgerRepository() });
    const res = await app.inject({ method: 'GET', url: '/me/balance' });
    expect(res.statusCode).toBe(401);
  });

  it('returns the authenticated rider derived balance', async () => {
    const ledger = new InMemoryLedgerRepository();
    await ledger.append({
      userId: 'rider-1',
      delta: 250,
      reason: 'topup',
      refType: 'payment',
      idempotencyKey: 'k1',
    });
    await ledger.append({
      userId: 'rider-1',
      delta: -10,
      reason: 'boarding',
      refType: 'boarding',
      idempotencyKey: 'k2',
    });
    const app = await buildApp({ auth, ledger });
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });

    const res = await app.inject({ method: 'GET', url: '/me/balance', headers: bearer(token) });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ balanceGhs: 240 });
  });

  it('returns 0 when no ledger is wired', async () => {
    const app = await buildApp({ auth });
    const token = await jwt.signAccessToken({ userId: 'rider-x', role: 'commuter' });
    const res = await app.inject({ method: 'GET', url: '/me/balance', headers: bearer(token) });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ balanceGhs: 0 });
  });
});
