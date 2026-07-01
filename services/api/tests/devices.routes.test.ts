import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryDeviceTokenRepository } from '../src/modules/devices/device-token.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const body = (fcmToken: string, platform = 'android') => ({ fcmToken, platform });

describe('POST /me/devices', () => {
  it('rejects an unauthenticated request', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({ method: 'POST', url: '/me/devices', payload: body('tok-1') });
    expect(res.statusCode).toBe(401);
  });

  it('registers the FCM token for the authenticated user', async () => {
    const deviceTokens = new InMemoryDeviceTokenRepository();
    const app = await buildApp({ auth, deviceTokens });
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });

    const res = await app.inject({
      method: 'POST',
      url: '/me/devices',
      headers: bearer(token),
      payload: body('fcm-abc', 'ios'),
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ registered: true });

    const tokens = await deviceTokens.listForUser('rider-1');
    expect(tokens).toHaveLength(1);
    expect(tokens[0]).toMatchObject({ fcmToken: 'fcm-abc', platform: 'ios', userId: 'rider-1' });
  });

  it('rejects an invalid platform', async () => {
    const app = await buildApp({ auth, deviceTokens: new InMemoryDeviceTokenRepository() });
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: '/me/devices',
      headers: bearer(token),
      payload: { fcmToken: 'x', platform: 'windows' },
    });
    expect(res.statusCode).toBe(400);
  });

  it('re-registering a token re-points it to the new user (upsert)', async () => {
    const deviceTokens = new InMemoryDeviceTokenRepository();
    const app = await buildApp({ auth, deviceTokens });
    const t1 = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    const t2 = await jwt.signAccessToken({ userId: 'rider-2', role: 'commuter' });

    await app.inject({
      method: 'POST',
      url: '/me/devices',
      headers: bearer(t1),
      payload: body('shared'),
    });
    await app.inject({
      method: 'POST',
      url: '/me/devices',
      headers: bearer(t2),
      payload: body('shared'),
    });

    expect(await deviceTokens.listForUser('rider-1')).toHaveLength(0);
    expect(await deviceTokens.listForUser('rider-2')).toHaveLength(1);
  });
});
