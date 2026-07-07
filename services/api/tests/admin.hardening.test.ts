// Hardening fixes on the admin/ops endpoints (follow-up to #115): the role
// grant that makes the driver app usable, throttle-before-role ordering, 409 on
// duplicate stop seq, driver user_id validation, and trip list filters.

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const admin = () => jwt.signAccessToken({ userId: 'admin-1', role: 'admin' });

describe('PATCH /admin/users/:id/role', () => {
  it('requires the admin role (commuter → 403)', async () => {
    const users = new InMemoryUserRepository();
    const user = await users.create({ displayName: 'Ama' });
    const app = await buildApp({ auth, users });
    const res = await app.inject({
      method: 'PATCH',
      url: `/admin/users/${user.id}/role`,
      headers: bearer(await jwt.signAccessToken({ userId: 'u1', role: 'commuter' })),
      payload: { role: 'driver' },
    });
    expect(res.statusCode).toBe(403);
  });

  it('promotes a commuter to driver — and their next token can scan', async () => {
    const users = new InMemoryUserRepository();
    const rider = await users.create({ displayName: 'Kofi' });
    expect(rider.role).toBe('commuter');
    const app = await buildApp({ auth, users });

    const res = await app.inject({
      method: 'PATCH',
      url: `/admin/users/${rider.id}/role`,
      headers: bearer(await admin()),
      payload: { role: 'driver' },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ id: rider.id, role: 'driver' });
    expect((await users.findById(rider.id))?.role).toBe('driver');

    // The point of the endpoint: a token minted with the new role clears the
    // driver guard on the scan route (403 before, non-403 after).
    const promotedToken = await jwt.signAccessToken({ userId: rider.id, role: 'driver' });
    const scan = await app.inject({
      method: 'POST',
      url: '/boarding/scan',
      headers: bearer(promotedToken),
      payload: { pass: 'garbage' },
    });
    expect(scan.statusCode).toBe(200); // authorized; pass itself is just invalid
    expect(scan.json()).toMatchObject({ valid: false, reason: 'invalid' });
  });

  it('404 for an unknown user; 400 for an unknown role', async () => {
    const users = new InMemoryUserRepository();
    const app = await buildApp({ auth, users });
    const missing = await app.inject({
      method: 'PATCH',
      url: `/admin/users/${crypto.randomUUID()}/role`,
      headers: bearer(await admin()),
      payload: { role: 'driver' },
    });
    expect(missing.statusCode).toBe(404);

    const badRole = await app.inject({
      method: 'PATCH',
      url: `/admin/users/${crypto.randomUUID()}/role`,
      headers: bearer(await admin()),
      payload: { role: 'superuser' },
    });
    expect(badRole.statusCode).toBe(400);
  });
});

describe('admin rate limiting', () => {
  it('throttles before the role check (non-admins cannot hammer 403s)', async () => {
    const app = await buildApp({
      auth,
      routes: new InMemoryRouteRepository(),
      rateLimit: { max: 2, windowSeconds: 60 },
    });
    const commuter = await jwt.signAccessToken({ userId: 'u1', role: 'commuter' });
    const get = () =>
      app.inject({ method: 'GET', url: '/admin/routes', headers: bearer(commuter) });
    expect((await get()).statusCode).toBe(403);
    expect((await get()).statusCode).toBe(403);
    expect((await get()).statusCode).toBe(429); // throttled, not another 403
  });
});

describe('POST /admin/routes/:id/stops', () => {
  it('409 when the sequence position is already taken on the route', async () => {
    const routes = new InMemoryRouteRepository();
    const stops = new InMemoryStopRepository();
    const routeStops = new InMemoryRouteStopRepository();
    const route = await routes.create({ name: 'Circle → Legon' });
    const a = await stops.create({ name: 'Circle', latitude: 5.57, longitude: -0.21 });
    const b = await stops.create({ name: 'Legon', latitude: 5.65, longitude: -0.18 });
    const app = await buildApp({ auth, routes, stops, routeStops });
    const token = await admin();
    const attach = (stopId: string) =>
      app.inject({
        method: 'POST',
        url: `/admin/routes/${route.id}/stops`,
        headers: bearer(token),
        payload: { stopId, seq: 1 },
      });

    expect((await attach(a.id)).statusCode).toBe(200);

    const dup = await attach(b.id);
    expect(dup.statusCode).toBe(409);
    expect(dup.json().error).toBe('conflict');
  });
});

describe('POST /admin/drivers', () => {
  it('404 for a userId that does not exist (clean error, not a DB 500)', async () => {
    const app = await buildApp({
      auth,
      drivers: new InMemoryDriverRepository(),
      users: new InMemoryUserRepository(),
    });
    const res = await app.inject({
      method: 'POST',
      url: '/admin/drivers',
      headers: bearer(await admin()),
      payload: { fullName: 'Yaw Driver', userId: crypto.randomUUID() },
    });
    expect(res.statusCode).toBe(404);
    expect(res.json().message).toBe('User not found');
  });

  it('creates a driver linked to a real user', async () => {
    const users = new InMemoryUserRepository();
    const user = await users.create({ displayName: 'Yaw' });
    const app = await buildApp({ auth, drivers: new InMemoryDriverRepository(), users });
    const res = await app.inject({
      method: 'POST',
      url: '/admin/drivers',
      headers: bearer(await admin()),
      payload: { fullName: 'Yaw Driver', userId: user.id },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().userId).toBe(user.id);
  });
});

describe('GET /admin/trips filters', () => {
  it('filters by status and UTC day', async () => {
    const trips = new InMemoryTripRepository();
    const routeId = crypto.randomUUID();
    await trips.create({ routeId, scheduledAt: new Date('2026-07-08T06:30:00Z') });
    await trips.create({
      routeId,
      scheduledAt: new Date('2026-07-08T17:00:00Z'),
      status: 'cancelled',
    });
    await trips.create({ routeId, scheduledAt: new Date('2026-07-09T06:30:00Z') });
    const app = await buildApp({ auth, trips });
    const token = await admin();

    const day = await app.inject({
      method: 'GET',
      url: '/admin/trips?date=2026-07-08',
      headers: bearer(token),
    });
    expect(day.json()).toHaveLength(2);

    const dayScheduled = await app.inject({
      method: 'GET',
      url: '/admin/trips?date=2026-07-08&status=scheduled',
      headers: bearer(token),
    });
    expect(dayScheduled.json()).toHaveLength(1);

    const badDate = await app.inject({
      method: 'GET',
      url: '/admin/trips?date=08-07-2026',
      headers: bearer(token),
    });
    expect(badDate.statusCode).toBe(400);
  });
});
