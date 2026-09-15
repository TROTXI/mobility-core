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
import { InMemoryRouteGeometryRepository } from '../src/modules/mobility/route-geometry.repository';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';

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

const UNKNOWN_TRIP = '00000000-0000-4000-8000-0000000000ff';
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
  const reservations = new InMemoryReservationRepository();
  const routeGeometry = new InMemoryRouteGeometryRepository();
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
  await trips.update(trip.id, { startedAt: new Date('2026-07-08T06:00:00Z') });

  const app = await buildApp({
    auth,
    routes,
    stops,
    routeStops,
    trips,
    drivers,
    tripPositions,
    reservations,
    routeGeometry,
    kv,
  });
  return {
    app,
    trips,
    drivers,
    tripPositions,
    reservations,
    routeGeometry,
    route,
    trip,
    driver,
    stops: [s1, s2, s3],
  };
}

const report = async (
  app: Awaited<ReturnType<typeof buildApp>>,
  tripId: string,
  token: string,
  body: Record<string, unknown> = { latitude: 0, longitude: 0 },
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

  it.each(['scheduled', 'completed', 'cancelled'] as const)(
    'rejects a %s trip without persisting a fix',
    async (status) => {
      const { app, trip, trips, tripPositions } = await seed();
      await trips.update(trip.id, { status });
      const res = await report(app, trip.id, await access(DRIVER_USER, 'driver'));
      expect(res.statusCode).toBe(409);
      expect(res.json()).toMatchObject({ error: 'trip_not_active' });
      expect(await tripPositions.findLatest(trip.id)).toBeNull();
    },
  );

  it('stores device capture time and deduplicates a replayed client fix', async () => {
    const { app, trip, tripPositions } = await seed();
    const token = await access(DRIVER_USER, 'driver');
    const body = {
      latitude: 0.005,
      longitude: 0.001,
      recordedAt: '2026-07-08T06:01:00.000Z',
      clientFixId: '11111111-1111-4111-8111-111111111111',
    };
    const first = await report(app, trip.id, token, body);
    const replay = await report(app, trip.id, token, { ...body, latitude: 9 });

    expect(first.statusCode).toBe(200);
    expect(replay.statusCode).toBe(200);
    expect(replay.json()).toEqual(first.json());
    expect(await tripPositions.findAllForTrip(trip.id)).toHaveLength(1);
    expect((await tripPositions.findLatest(trip.id))!.recordedAt.toISOString()).toBe(
      body.recordedAt,
    );
  });

  it('rejects pre-start and future capture timestamps without writing', async () => {
    const { app, trip, tripPositions } = await seed();
    const token = await access(DRIVER_USER, 'driver');
    for (const recordedAt of ['2026-07-08T05:59:59.000Z', '2999-01-01T00:00:00.000Z']) {
      const res = await report(app, trip.id, token, {
        latitude: 0,
        longitude: 0,
        recordedAt,
      });
      expect(res.statusCode).toBe(409);
      expect(res.json()).toMatchObject({ error: 'invalid_capture_time' });
    }
    expect(await tripPositions.findAllForTrip(trip.id)).toEqual([]);
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

  it('does not expose a cached fix after a trip completes', async () => {
    const { app, trip, trips } = await seed();
    await report(app, trip.id, await access(DRIVER_USER, 'driver'));
    await trips.update(trip.id, { status: 'completed', completedAt: new Date() });

    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/position`,
      headers: bearer(await access('rider-1')),
    });
    expect(res.statusCode).toBe(409);
    expect(res.json()).toMatchObject({ error: 'trip_not_active' });
  });

  it('computes ETA on the learned route geometry', async () => {
    const { app, trip, route, routeGeometry } = await seed();
    const oneHop = 1112;
    await routeGeometry.save({
      routeId: route.id,
      points: [
        { latitude: 0, longitude: 0 },
        { latitude: 0, longitude: 0.01 },
        { latitude: 0.01, longitude: 0.01 },
        { latitude: 0.01, longitude: 0 },
        { latitude: 0.02, longitude: 0 },
      ],
      source: 'traces',
      runCount: 3,
      stopDistances: new Map([
        [1, 0],
        [2, 3 * oneHop],
        [3, 4 * oneHop],
      ]),
    });
    await report(app, trip.id, await access(DRIVER_USER, 'driver'));

    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/position`,
      headers: bearer(await access('rider-1')),
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().etaToStops[0].distanceMeters).toBeGreaterThan(3_000);
  });
});

describe("GET /trips/:id/position — the rider's own stop (#204)", () => {
  it("picks out the caller's pickup stop from the ETA list", async () => {
    const { app, trip, reservations, stops } = await seed();
    await reservations.createPending({
      userId: 'rider-1',
      tripId: trip.id,
      travelDate: '2026-07-08',
      direction: 'morning',
      pickupStopId: stops[1]!.id, // the middle stop, not the first
      dropoffStopId: stops[2]!.id,
    });
    await report(app, trip.id, await access(DRIVER_USER, 'driver'));

    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/position`,
      headers: bearer(await access('rider-1')),
    });

    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.riderStop).toMatchObject({ stopId: stops[1]!.id, name: 'Kwame Nkrumah' });
    // and it is genuinely one of the entries, not a recomputation
    expect(body.etaToStops).toContainEqual(body.riderStop);
  });

  it('is null for a rider with no reservation on this trip', async () => {
    const { app, trip } = await seed();
    await report(app, trip.id, await access(DRIVER_USER, 'driver'));

    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/position`,
      headers: bearer(await access('someone-else')),
    });
    expect(res.json().riderStop).toBeNull();
  });

  it('is null when the reservation predates stops being recorded', async () => {
    const { app, trip, reservations } = await seed();
    await reservations.createPending({
      userId: 'rider-2',
      tripId: trip.id,
      travelDate: '2026-07-08',
      direction: 'morning',
    });
    await report(app, trip.id, await access(DRIVER_USER, 'driver'));

    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/position`,
      headers: bearer(await access('rider-2')),
    });
    expect(res.json().riderStop).toBeNull();
  });
});
