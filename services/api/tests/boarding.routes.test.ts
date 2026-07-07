import { SignJWT } from 'jose';
import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { BoardingService } from '../src/modules/boarding/boarding.service';
import { PASS_AUDIENCE } from '../src/modules/boarding/pass';
import {
  InMemoryScanEventRepository,
  type ScanEventRepository,
} from '../src/modules/boarding/scan-event.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryKvStore, type KvStore } from '../src/kv/kv.store';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const access = (userId: string, role: 'commuter' | 'driver' | 'admin' = 'commuter') =>
  jwt.signAccessToken({ userId, role });

function make(overrides: { scanEvents?: ScanEventRepository; kv?: KvStore } = {}) {
  const scanEvents = overrides.scanEvents ?? new InMemoryScanEventRepository();
  const kv = overrides.kv ?? new InMemoryKvStore();
  const boardingService = new BoardingService({
    scanEvents,
    kv,
    secret: auth.secret,
    passTtlSeconds: 60,
  });
  return { scanEvents, kv, boardingService };
}

const scan = async (app: Awaited<ReturnType<typeof buildApp>>, pass: string, driver = 'driver-1') =>
  app.inject({
    method: 'POST',
    url: '/boarding/scan',
    headers: bearer(await access(driver, 'driver')),
    payload: { pass },
  });

describe('GET /me/pass', () => {
  it('requires authentication', async () => {
    const app = await buildApp({ auth, boardingService: make().boardingService });
    expect((await app.inject({ method: 'GET', url: '/me/pass' })).statusCode).toBe(401);
  });

  it('issues a short-lived pass for the rider', async () => {
    const app = await buildApp({ auth, boardingService: make().boardingService });
    const res = await app.inject({
      method: 'GET',
      url: '/me/pass',
      headers: bearer(await access('rider-1')),
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().pass).toBeTruthy();
    expect(res.json().expiresInSeconds).toBe(60);
  });
});

describe('POST /boarding/scan', () => {
  it('requires the driver role (commuter → 403)', async () => {
    const app = await buildApp({ auth, boardingService: make().boardingService });
    const res = await app.inject({
      method: 'POST',
      url: '/boarding/scan',
      headers: bearer(await access('rider-1', 'commuter')),
      payload: { pass: 'x' },
    });
    expect(res.statusCode).toBe(403);
  });

  it('rate limits before the role check (non-drivers cannot hammer 403s)', async () => {
    const app = await buildApp({
      auth,
      boardingService: make().boardingService,
      rateLimit: { max: 2, windowSeconds: 60 },
    });
    const commuter = await access('rider-1', 'commuter');
    const post = () =>
      app.inject({
        method: 'POST',
        url: '/boarding/scan',
        headers: bearer(commuter),
        payload: { pass: 'x' },
      });
    expect((await post()).statusCode).toBe(403);
    expect((await post()).statusCode).toBe(403);
    expect((await post()).statusCode).toBe(429); // throttled, not another 403
  });

  it('a driver verifies a valid pass; the scan is recorded', async () => {
    const { boardingService, scanEvents } = make();
    const app = await buildApp({ auth, boardingService });
    const { pass } = await boardingService.issuePass('rider-1');

    const res = await scan(app, pass);
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ valid: true, riderId: 'rider-1', reason: 'ok' });

    const events = await scanEvents.listForRider('rider-1');
    expect(events).toHaveLength(1);
    expect(events[0]).toMatchObject({ result: 'valid', scannedBy: 'driver-1', method: 'qr' });
  });

  it('single-use: a second scan of the same pass is rejected as reused', async () => {
    const { boardingService, scanEvents } = make();
    const app = await buildApp({ auth, boardingService });
    const { pass } = await boardingService.issuePass('rider-1');

    expect((await scan(app, pass)).json()).toMatchObject({ valid: true, reason: 'ok' });
    // same QR again (e.g. shared screenshot) within the TTL
    const replay = await scan(app, pass, 'driver-2');
    expect(replay.json()).toMatchObject({ valid: false, riderId: 'rider-1', reason: 'reused' });

    const events = await scanEvents.listForRider('rider-1');
    expect(events.map((e) => e.result).sort()).toEqual(['reused', 'valid']);
  });

  it('an expired pass is rejected as expired (beyond clock tolerance)', async () => {
    const app = await buildApp({ auth, boardingService: make().boardingService });
    const key = new TextEncoder().encode(auth.secret);
    const expired = await new SignJWT({})
      .setProtectedHeader({ alg: 'HS256' })
      .setSubject('rider-1')
      .setJti(crypto.randomUUID())
      .setAudience(PASS_AUDIENCE)
      .setExpirationTime(Math.floor(Date.now() / 1000) - 30) // 30s past, > 5s tolerance
      .sign(key);
    expect((await scan(app, expired)).json()).toMatchObject({ valid: false, reason: 'expired' });
  });

  it('a forged/garbage pass is invalid', async () => {
    const app = await buildApp({ auth, boardingService: make().boardingService });
    const res = await scan(app, 'not-a-real-pass');
    expect(res.json()).toMatchObject({ valid: false, riderId: null, reason: 'invalid' });
  });

  it('an access token cannot be reused as a boarding pass (audience separation)', async () => {
    const app = await buildApp({ auth, boardingService: make().boardingService });
    const riderAccessToken = await access('rider-1'); // aud=trotxi-api, not trotxi-pass
    const res = await scan(app, riderAccessToken);
    expect(res.json()).toMatchObject({ valid: false, reason: 'invalid' });
  });

  it('rejects an oversized pass without touching jwtVerify (400)', async () => {
    const app = await buildApp({ auth, boardingService: make().boardingService });
    const res = await scan(app, 'x'.repeat(600));
    expect(res.statusCode).toBe(400);
  });

  it('an audit-write failure does not block the scan result (fails open)', async () => {
    const failingScanEvents: ScanEventRepository = {
      record: async () => {
        throw new Error('db down');
      },
      listForRider: async () => [],
    };
    const { boardingService } = make({ scanEvents: failingScanEvents });
    const app = await buildApp({ auth, boardingService });
    const { pass } = await boardingService.issuePass('rider-1');

    const res = await scan(app, pass);
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ valid: true, riderId: 'rider-1', reason: 'ok' });
  });

  it('a KV outage does not block boarding (single-use check fails open)', async () => {
    const kv = new InMemoryKvStore();
    const broken: KvStore = {
      ...kv,
      increment: async () => {
        throw new Error('kv down');
      },
      get: kv.get.bind(kv),
      set: kv.set.bind(kv),
      del: kv.del.bind(kv),
      ping: kv.ping.bind(kv),
      close: kv.close.bind(kv),
    };
    const { boardingService } = make({ kv: broken });
    const app = await buildApp({ auth, boardingService });
    const { pass } = await boardingService.issuePass('rider-1');

    const res = await scan(app, pass);
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ valid: true, reason: 'ok' });
  });
});
