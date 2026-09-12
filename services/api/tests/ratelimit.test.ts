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

describe('rateLimit behind a reverse proxy', () => {
  /** proxy-addr presets covering RFC1918 and loopback: Render's balancer. */
  const PRIVATE_PEERS = 'loopback, linklocal, uniquelocal';

  /**
   * A one-route app that reports which bucket the limiter chose.
   *
   * @param trustProxy - which peers may set X-Forwarded-For.
   * @returns the built app.
   */
  const appWithHops = async (trustProxy: string) => {
    const app = await buildApp({ auth, trustProxy });
    await app.register(async (i) => {
      i.get('/limited', { preHandler: [i.rateLimit({ max: 1, windowSeconds: 60 })] }, async () => ({
        ok: true,
      }));
    });
    return app;
  };

  const from = (app: Awaited<ReturnType<typeof buildApp>>, clientIp: string) =>
    app.inject({
      method: 'GET',
      url: '/limited',
      headers: { 'x-forwarded-for': clientIp },
      remoteAddress: '10.0.0.1', // the load balancer, on every request
    });

  it('buckets two riders separately when the balancer is trusted', async () => {
    const app = await appWithHops(PRIVATE_PEERS);
    expect((await from(app, '41.66.1.1')).statusCode).toBe(200);
    // A different rider, same load balancer. Their first request must not be
    // spent by someone else's.
    expect((await from(app, '41.66.2.2')).statusCode).toBe(200);
    expect((await from(app, '41.66.1.1')).statusCode).toBe(429);
  });

  it('collapses every caller into one bucket when nothing is trusted', async () => {
    // The bug this setting fixes: behind a load balancer with trustProxy off,
    // request.ip is the balancer for everyone, so one rider's requests exhaust
    // the limit for the whole country.
    const app = await appWithHops('');
    expect((await from(app, '41.66.1.1')).statusCode).toBe(200);
    expect((await from(app, '41.66.2.2')).statusCode).toBe(429);
  });

  it('ignores an X-Forwarded-For the client prepended itself', async () => {
    // Only the entry the trusted balancer appended counts, so a caller cannot
    // pick a fresh bucket per request by forging the header.
    const app = await appWithHops(PRIVATE_PEERS);
    const spoof = (chain: string) =>
      app.inject({
        method: 'GET',
        url: '/limited',
        headers: { 'x-forwarded-for': chain },
        remoteAddress: '10.0.0.1',
      });

    expect((await spoof('1.2.3.4, 41.66.1.1')).statusCode).toBe(200);
    expect((await spoof('9.9.9.9, 41.66.1.1')).statusCode).toBe(429);
  });
  it('trusts nothing when handed a hop count, which is why env refuses one', async () => {
    // Fastify 5.12 made numeric trustProxy fail closed (GHSA X-Forwarded-*
    // spoofing): a count cannot validate the immediate peer, so `1` silently
    // means "trust nobody" — the exact bug this setting exists to fix. This
    // pins that behaviour so the boot-time guard in config/env.ts is never
    // quietly dropped as redundant.
    const app = await buildApp({ auth, trustProxy: 1 as unknown as string });
    await app.register(async (i) => {
      i.get('/limited', { preHandler: [i.rateLimit({ max: 1, windowSeconds: 60 })] }, async () => ({
        ok: true,
      }));
    });

    expect((await from(app, '41.66.1.1')).statusCode).toBe(200);
    // A second, different rider is already rate-limited: everyone shares the
    // balancer's bucket, because the hop count trusted nobody.
    expect((await from(app, '41.66.2.2')).statusCode).toBe(429);
  });
});
