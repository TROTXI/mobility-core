import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import type { KvStore } from '../src/kv/kv.store';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (token: string) => ({ authorization: `Bearer ${token}` });

describe('rateLimit (per IP)', () => {
  it('allows up to the limit, then returns 429 with Retry-After', async () => {
    const app = await buildApp({ auth });
    await app.register(async (i) => {
      i.get('/limited', { preHandler: [i.rateLimit({ max: 2, windowSeconds: 60 })] }, async () => ({
        ok: true,
      }));
    });

    const r1 = await app.inject({ method: 'GET', url: '/limited' });
    const r2 = await app.inject({ method: 'GET', url: '/limited' });
    const r3 = await app.inject({ method: 'GET', url: '/limited' });

    expect([r1.statusCode, r2.statusCode, r3.statusCode]).toEqual([200, 200, 429]);
    expect(r1.headers['x-ratelimit-limit']).toBe('2');
    expect(r1.headers['x-ratelimit-remaining']).toBe('1');
    expect(r3.headers['x-ratelimit-remaining']).toBe('0');
    expect(r3.headers['retry-after']).toBe('60');
    expect(r3.json()).toMatchObject({ error: 'rate_limited' });
  });

  it('buckets each client IP independently', async () => {
    const app = await buildApp({ auth });
    await app.register(async (i) => {
      i.get('/limited', { preHandler: [i.rateLimit({ max: 1, windowSeconds: 60 })] }, async () => ({
        ok: true,
      }));
    });

    const a1 = await app.inject({ method: 'GET', url: '/limited', remoteAddress: '1.1.1.1' });
    const a2 = await app.inject({ method: 'GET', url: '/limited', remoteAddress: '1.1.1.1' });
    const b1 = await app.inject({ method: 'GET', url: '/limited', remoteAddress: '2.2.2.2' });

    expect([a1.statusCode, a2.statusCode, b1.statusCode]).toEqual([200, 429, 200]);
  });
});

describe('rateLimit (per user)', () => {
  it('buckets each authenticated user independently', async () => {
    const app = await buildApp({ auth });
    await app.register(async (i) => {
      i.get(
        '/u',
        { preHandler: [i.authenticate, i.rateLimit({ max: 1, windowSeconds: 60, by: 'user' })] },
        async () => ({ ok: true }),
      );
    });
    const tokenA = await jwt.signAccessToken({ userId: 'userA', role: 'commuter' });
    const tokenB = await jwt.signAccessToken({ userId: 'userB', role: 'commuter' });

    const a1 = await app.inject({ method: 'GET', url: '/u', headers: bearer(tokenA) });
    const a2 = await app.inject({ method: 'GET', url: '/u', headers: bearer(tokenA) });
    const b1 = await app.inject({ method: 'GET', url: '/u', headers: bearer(tokenB) });

    expect([a1.statusCode, a2.statusCode, b1.statusCode]).toEqual([200, 429, 200]);
  });

  it('falls back to IP when there is no authenticated user', async () => {
    const app = await buildApp({ auth });
    await app.register(async (i) => {
      // by: 'user' but no authenticate in front — must not silently skip.
      i.get(
        '/uf',
        { preHandler: [i.rateLimit({ max: 5, windowSeconds: 60, by: 'user' })] },
        async () => ({
          ok: true,
        }),
      );
    });

    const res = await app.inject({ method: 'GET', url: '/uf' });
    expect(res.statusCode).toBe(200);
  });
});

describe('rateLimit (resilience)', () => {
  it('fails open when the KV store errors', async () => {
    const brokenKv: KvStore = {
      get: async () => null,
      set: async () => {},
      del: async () => {},
      increment: async () => {
        throw new Error('kv down');
      },
      ping: async () => false,
      close: async () => {},
    };
    const app = await buildApp({ auth, kv: brokenKv });
    await app.register(async (i) => {
      i.get('/f', { preHandler: [i.rateLimit({ max: 1, windowSeconds: 60 })] }, async () => ({
        ok: true,
      }));
    });

    const r1 = await app.inject({ method: 'GET', url: '/f' });
    const r2 = await app.inject({ method: 'GET', url: '/f' });
    expect([r1.statusCode, r2.statusCode]).toEqual([200, 200]);
  });
});
