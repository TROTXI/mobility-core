import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { BoardingService } from '../src/modules/boarding/boarding.service';
import { InMemoryScanEventRepository } from '../src/modules/boarding/scan-event.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

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

function make() {
  const scanEvents = new InMemoryScanEventRepository();
  const boardingService = new BoardingService({
    scanEvents,
    secret: auth.secret,
    passTtlSeconds: 60,
  });
  return { scanEvents, boardingService };
}

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

  it('a driver verifies a valid pass; the scan is recorded', async () => {
    const { boardingService, scanEvents } = make();
    const app = await buildApp({ auth, boardingService });
    const { pass } = await boardingService.issuePass('rider-1');

    const res = await app.inject({
      method: 'POST',
      url: '/boarding/scan',
      headers: bearer(await access('driver-1', 'driver')),
      payload: { pass },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ valid: true, riderId: 'rider-1', reason: 'ok' });

    const events = await scanEvents.listForRider('rider-1');
    expect(events).toHaveLength(1);
    expect(events[0]).toMatchObject({ result: 'valid', scannedBy: 'driver-1', method: 'qr' });
  });

  it('a forged/garbage pass is invalid', async () => {
    const app = await buildApp({ auth, boardingService: make().boardingService });
    const res = await app.inject({
      method: 'POST',
      url: '/boarding/scan',
      headers: bearer(await access('driver-1', 'driver')),
      payload: { pass: 'not-a-real-pass' },
    });
    expect(res.json()).toMatchObject({ valid: false, riderId: null, reason: 'invalid' });
  });

  it('an access token cannot be reused as a boarding pass (audience separation)', async () => {
    const app = await buildApp({ auth, boardingService: make().boardingService });
    const riderAccessToken = await access('rider-1'); // aud=trotxi-api, not trotxi-pass
    const res = await app.inject({
      method: 'POST',
      url: '/boarding/scan',
      headers: bearer(await access('driver-1', 'driver')),
      payload: { pass: riderAccessToken },
    });
    expect(res.json()).toMatchObject({ valid: false, reason: 'invalid' });
  });
});
