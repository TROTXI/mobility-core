import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemoryScanEventRepository } from '../src/modules/boarding/scan-event.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const MINE = 'aaaaaaaa-0000-4000-8000-000000000001';
const THEIRS = 'aaaaaaaa-0000-4000-8000-000000000002';
const RIDER = 'aaaaaaaa-0000-4000-8000-000000000003';

async function setup() {
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();
  const reservations = new InMemoryReservationRepository();
  const scanEvents = new InMemoryScanEventRepository();
  const routeStops = new InMemoryRouteStopRepository();

  const me = await drivers.create({ fullName: 'Kwame Boateng', userId: MINE });
  await drivers.create({ fullName: 'Yaw Asare', userId: THEIRS });
  const trip = await trips.create({
    routeId: '11111111-1111-4111-8111-111111111111',
    scheduledAt: new Date('2026-08-26T06:30:00.000Z'),
    assignedDriverId: me.id,
  });

  const app = await buildApp({ auth, trips, drivers, reservations, scanEvents, routeStops });
  return { app, trip, trips, routeStops };
}

const asDriver = async (userId: string) => ({
  authorization: `Bearer ${await jwt.signAccessToken({ userId, role: 'driver' })}`,
});

describe('driver lifecycle over HTTP (#163)', () => {
  it('accepts zero-based and gapped arrival sequences, but only on the assigned route', async () => {
    const { app, trip, routeStops } = await setup();
    try {
      for (const seq of [0, 2, 7]) {
        await routeStops.create({ routeId: trip.routeId, stopId: crypto.randomUUID(), seq });
      }
      const headers = await asDriver(MINE);
      await app.inject({ method: 'POST', url: `/trips/${trip.id}/start`, headers });
      for (const seq of [0, 2, 7, 0]) {
        const response = await app.inject({
          method: 'POST',
          url: `/trips/${trip.id}/arrive`,
          headers,
          payload: { seq },
        });
        expect(response.statusCode).toBe(200);
        expect(response.json().currentStopSeq).toBe(seq);
      }
      const missing = await app.inject({
        method: 'POST',
        url: `/trips/${trip.id}/arrive`,
        headers,
        payload: { seq: 3 },
      });
      expect(missing.statusCode).toBe(404);
      const negative = await app.inject({
        method: 'POST',
        url: `/trips/${trip.id}/arrive`,
        headers,
        payload: { seq: -1 },
      });
      expect(negative.statusCode).toBe(400);
      const forbidden = await app.inject({
        method: 'POST',
        url: `/trips/${trip.id}/arrive`,
        headers: await asDriver(THEIRS),
        payload: { seq: 0 },
      });
      expect(forbidden.statusCode).toBe(403);
    } finally {
      await app.close();
    }
  });

  it('starts and completes a run', async () => {
    const { app, trip } = await setup();
    const headers = await asDriver(MINE);

    const started = await app.inject({
      method: 'POST',
      url: `/trips/${trip.id}/start`,
      headers,
    });
    expect(started.statusCode).toBe(200);
    expect(started.json().status).toBe('active');

    const done = await app.inject({
      method: 'POST',
      url: `/trips/${trip.id}/complete`,
      headers,
    });
    expect(done.statusCode).toBe(200);
    expect(done.json().status).toBe('completed');
  });

  it('lists only my runs', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'GET',
      url: '/me/trips',
      headers: await asDriver(MINE),
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().trips).toHaveLength(1);
  });

  it("403s on another driver's run, not 404", async () => {
    // The caller is authenticated and the trip exists — they are simply not
    // driving it. A 404 would leave a driver who tapped the wrong run unable
    // to tell what went wrong.
    const { app, trip } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: `/trips/${trip.id}/start`,
      headers: await asDriver(THEIRS),
    });
    expect(res.statusCode).toBe(403);
  });

  it('409s when completing a run that never started', async () => {
    const { app, trip } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: `/trips/${trip.id}/complete`,
      headers: await asDriver(MINE),
    });
    expect(res.statusCode).toBe(409);
    expect(res.json().error).toBe('illegal_transition');
  });

  it('refuses a commuter outright', async () => {
    const { app, trip } = await setup();
    const token = await jwt.signAccessToken({ userId: RIDER, role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: `/trips/${trip.id}/start`,
      headers: { authorization: `Bearer ${token}` },
    });
    expect(res.statusCode).toBe(403);
  });

  it('rejects an unauthenticated call', async () => {
    const { app, trip } = await setup();
    const res = await app.inject({ method: 'POST', url: `/trips/${trip.id}/start` });
    expect(res.statusCode).toBe(401);
  });

  it('returns the run summary', async () => {
    const { app, trip } = await setup();
    const headers = await asDriver(MINE);
    await app.inject({ method: 'POST', url: `/trips/${trip.id}/start`, headers });

    const res = await app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/summary`,
      headers,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({
      tripId: trip.id,
      boarded: 0,
      byMethod: { qr: 0, pin: 0, photo: 0 },
    });
  });
});
