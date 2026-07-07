import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const token = () => jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });

const ROUTE_A = '00000000-0000-0000-0000-0000000000a1';
const ROUTE_B = '00000000-0000-0000-0000-0000000000b2';

async function appWithTrips() {
  const trips = new InMemoryTripRepository();
  const app = await buildApp({ auth, trips });
  return { app, trips };
}

describe('GET /trips', () => {
  it('requires authentication', async () => {
    const { app } = await appWithTrips();
    const res = await app.inject({ method: 'GET', url: '/trips' });
    expect(res.statusCode).toBe(401);
  });

  it('returns 503 when the repository is not wired', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({ method: 'GET', url: '/trips', headers: bearer(await token()) });
    expect(res.statusCode).toBe(503);
    expect(res.json()).toMatchObject({ error: 'unavailable' });
  });

  it('returns an empty list when no trips exist', async () => {
    const { app } = await appWithTrips();
    const res = await app.inject({ method: 'GET', url: '/trips', headers: bearer(await token()) });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ trips: [] });
  });

  it('returns seeded trips ordered by scheduled_at', async () => {
    const { app, trips } = await appWithTrips();
    await trips.create({ routeId: ROUTE_A, scheduledAt: new Date('2026-07-08T18:00:00Z') });
    await trips.create({ routeId: ROUTE_A, scheduledAt: new Date('2026-07-08T06:00:00Z') });

    const res = await app.inject({ method: 'GET', url: '/trips', headers: bearer(await token()) });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.trips).toHaveLength(2);
    expect(body.trips[0].scheduledAt).toBe('2026-07-08T06:00:00.000Z');
    expect(body.trips[0]).toMatchObject({ routeId: ROUTE_A, status: 'scheduled' });
  });

  it('filters by routeId', async () => {
    const { app, trips } = await appWithTrips();
    await trips.create({ routeId: ROUTE_A, scheduledAt: new Date('2026-07-08T06:00:00Z') });
    await trips.create({ routeId: ROUTE_B, scheduledAt: new Date('2026-07-08T07:00:00Z') });

    const res = await app.inject({
      method: 'GET',
      url: `/trips?routeId=${ROUTE_A}`,
      headers: bearer(await token()),
    });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.trips).toHaveLength(1);
    expect(body.trips[0].routeId).toBe(ROUTE_A);
  });

  it('returns 400 for a non-UUID routeId', async () => {
    const { app } = await appWithTrips();
    const res = await app.inject({
      method: 'GET',
      url: '/trips?routeId=not-a-uuid',
      headers: bearer(await token()),
    });
    expect(res.statusCode).toBe(400);
  });
});

describe('GET /trips/:id', () => {
  it('requires authentication', async () => {
    const { app } = await appWithTrips();
    const res = await app.inject({
      method: 'GET',
      url: '/trips/00000000-0000-0000-0000-000000000001',
    });
    expect(res.statusCode).toBe(401);
  });

  it('returns 404 for an unknown id', async () => {
    const { app } = await appWithTrips();
    const res = await app.inject({
      method: 'GET',
      url: '/trips/00000000-0000-0000-0000-000000000001',
      headers: bearer(await token()),
    });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toMatchObject({ error: 'not_found' });
  });

  it('returns 400 for a non-UUID id', async () => {
    const { app } = await appWithTrips();
    const res = await app.inject({
      method: 'GET',
      url: '/trips/not-a-uuid',
      headers: bearer(await token()),
    });
    expect(res.statusCode).toBe(400);
  });

  it('returns the trip with its assignment fields', async () => {
    const { app, trips } = await appWithTrips();
    const trip = await trips.create({
      routeId: ROUTE_A,
      vehicleId: '00000000-0000-0000-0000-0000000000f1',
      assignedDriverId: '00000000-0000-0000-0000-0000000000f2',
      status: 'active',
      scheduledAt: new Date('2026-07-08T06:00:00Z'),
    });

    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}`,
      headers: bearer(await token()),
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({
      id: trip.id,
      routeId: ROUTE_A,
      vehicleId: '00000000-0000-0000-0000-0000000000f1',
      assignedDriverId: '00000000-0000-0000-0000-0000000000f2',
      status: 'active',
    });
  });
});
