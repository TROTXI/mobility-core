import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryKvStore } from '../src/kv/kv.store';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';
import { InMemoryTripPositionRepository } from '../src/modules/mobility/trip-position.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';

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

const UNKNOWN_TRIP = '00000000-0000-0000-0000-0000000000ff';
const DRIVER_USER = 'user-of-assigned-driver';

// A route of three stops on the prime meridian (~1.1 km apart) with a trip
// assigned to a driver linked to DRIVER_USER. Returns the app + seeded ids.
async function seed() {
  const routes = new InMemoryRouteRepository();
  const stops = new InMemoryStopRepository();
  const routeStops = new InMemoryRouteStopRepository();
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();
  const tripPositions = new InMemoryTripPositionRepository();
  const kv = new InMemoryKvStore();

  const route = await routes.create({ name: 'Circle → Kaneshie', description: null });
  const s1 = await stops.create({ name: 'Circle', latitude: 0, longitude: 0 });
  const s2 = await stops.create({ name: 'Kwame Nkrumah', latitude: 0.01, longitude: 0 });
  const s3 = await stops.create({ name: 'Kaneshie', latitude: 0.02, longitude: 0 });
  await routeStops.create({ routeId: route.id, stopId: s1.id, seq: 1 });
  await routeStops.create({ routeId: route.id, stopId: s2.id, seq: 2 });
  await routeStops.create({ routeId: route.id, stopId: s3.id, seq: 3 });

  const driver = await drivers.create({ fullName: 'Kwame Mensah', userId: DRIVER_USER });
  const trip = await trips.create({
    routeId: route.id,
    assignedDriverId: driver.id,
    status: 'active',
    scheduledAt: new Date('2026-07-08T06:00:00Z'),
  });

  const app = await buildApp({
    auth,
    routes,
    stops,
    routeStops,
    trips,
    drivers,
    tripPositions,
    kv,
  });
  return { app, trips, drivers, tripPositions, trip, driver };
}

const report = async (
  app: Awaited<ReturnType<typeof buildApp>>,
  tripId: string,
  token: string,
  body: Record<string, number> = { latitude: 0, longitude: 0 },
) =>
  app.inject({
    method: 'POST',
    url: `/trips/${tripId}/position`,
    headers: bearer(token),
    payload: body,
  });

describe('POST /trips/:id/position (report a fix)', () => {
  it('requires authentication', async () => {
    const { app, trip } = await seed();
    const res = await app.inject({
      method: 'POST',
      url: `/trips/${trip.id}/position`,
      payload: { latitude: 0, longitude: 0 },
    });
    expect(res.statusCode).toBe(401);
  });

  it('rejects a non-driver role with 403', async () => {
    const { app, trip } = await seed();
    const res = await report(app, trip.id, await access('rider-1', 'commuter'));
    expect(res.statusCode).toBe(403);
  });

  it('rejects a driver who is not the assigned driver with 403', async () => {
    const { app, trip, drivers } = await seed();
    // A real driver, linked to a user, but assigned to no trip.
    await drivers.create({ fullName: 'Ama Owusu', userId: 'other-driver-user' });
    const res = await report(app, trip.id, await access('other-driver-user', 'driver'));
    expect(res.statusCode).toBe(403);
  });

  it('rejects a driver-role token with no linked driver record with 403', async () => {
    const { app, trip } = await seed();
    const res = await report(app, trip.id, await access('unlinked-user', 'driver'));
    expect(res.statusCode).toBe(403);
  });

  it('records a fix for the assigned driver (200) and persists it', async () => {
    const { app, trip, tripPositions } = await seed();
    const res = await report(app, trip.id, await access(DRIVER_USER, 'driver'), {
      latitude: 0.005,
      longitude: 0.001,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({
      tripId: trip.id,
      position: { latitude: 0.005, longitude: 0.001 },
    });
    expect(res.json().position.recordedAt).toBeTruthy();

    const stored = await tripPositions.findLatest(trip.id);
    expect(stored).toMatchObject({ latitude: 0.005, longitude: 0.001 });
  });

  it('returns 404 for an unknown trip (even for a driver)', async () => {
    const { app } = await seed();
    const res = await report(app, UNKNOWN_TRIP, await access(DRIVER_USER, 'driver'));
    expect(res.statusCode).toBe(404);
  });

  it('validates coordinate ranges (400)', async () => {
    const { app, trip } = await seed();
    const res = await report(app, trip.id, await access(DRIVER_USER, 'driver'), {
      latitude: 200,
      longitude: 0,
    });
    expect(res.statusCode).toBe(400);
  });

  it('returns 503 when the repositories are unwired', async () => {
    const app = await buildApp({ auth });
    const res = await report(app, UNKNOWN_TRIP, await access(DRIVER_USER, 'driver'));
    expect(res.statusCode).toBe(503);
  });
});

describe('GET /trips/:id/position (latest position + ETA)', () => {
  it('requires authentication', async () => {
    const { app, trip } = await seed();
    const res = await app.inject({ method: 'GET', url: `/trips/${trip.id}/position` });
    expect(res.statusCode).toBe(401);
  });

  it('returns 404 for an unknown trip', async () => {
    const { app } = await seed();
    const res = await app.inject({
      method: 'GET',
      url: `/trips/${UNKNOWN_TRIP}/position`,
      headers: bearer(await access('rider-1')),
    });
    expect(res.statusCode).toBe(404);
  });

  it('returns 404 when no fix has been reported yet', async () => {
    const { app, trip } = await seed();
    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/position`,
      headers: bearer(await access('rider-1')),
    });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toMatchObject({ error: 'not_found' });
  });

  it('returns the latest fix with deterministic ETAs to upcoming stops', async () => {
    const { app, trip } = await seed();
    // Driver reports the bus at the first stop (Circle).
    await report(app, trip.id, await access(DRIVER_USER, 'driver'), { latitude: 0, longitude: 0 });

    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/position`,
      headers: bearer(await access('rider-1')),
    });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body).toMatchObject({ tripId: trip.id, position: { latitude: 0, longitude: 0 } });

    // At stop 1 → stops 2 and 3 are upcoming, in order, with increasing ETA.
    expect(body.etaToStops.map((e: { seq: number }) => e.seq)).toEqual([2, 3]);
    expect(body.etaToStops[0].distanceMeters).toBeGreaterThan(0);
    expect(body.etaToStops[0].etaSeconds).toBeGreaterThan(0);
    expect(body.etaToStops[1].distanceMeters).toBeGreaterThan(body.etaToStops[0].distanceMeters);
  });

  it('falls back to the durable store when the fix is not cached', async () => {
    const { app, trip, tripPositions } = await seed();
    // Seed the store directly (bypassing POST) so the KV cache is cold.
    await tripPositions.record({ tripId: trip.id, latitude: 0.02, longitude: 0 });

    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/position`,
      headers: bearer(await access('rider-1')),
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().position).toMatchObject({ latitude: 0.02, longitude: 0 });
    // At the last stop → nothing upcoming.
    expect(res.json().etaToStops).toEqual([]);
  });

  it('returns 503 when the repositories are unwired', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({
      method: 'GET',
      url: `/trips/${UNKNOWN_TRIP}/position`,
      headers: bearer(await access('rider-1')),
    });
    expect(res.statusCode).toBe(503);
  });
});
