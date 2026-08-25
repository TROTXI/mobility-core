import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryVehicleRepository } from '../src/modules/mobility/vehicle.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const DATE = '2026-08-26';

async function setup(capacity: number) {
  const routes = new InMemoryRouteRepository();
  const vehicles = new InMemoryVehicleRepository();
  const trips = new InMemoryTripRepository();
  const reservations = new InMemoryReservationRepository();
  // The assignment endpoint needs all three fleet repos or it 503s.
  const drivers = new InMemoryDriverRepository();

  const route = await routes.create({ name: 'Circle ⇄ Madina' });
  const vehicle = await vehicles.create({ registration: 'GR-2417-26', capacity });
  const trip = await trips.create({
    routeId: route.id,
    scheduledAt: new Date(`${DATE}T06:30:00.000Z`),
    vehicleId: vehicle.id,
  });

  const app = await buildApp({ auth, routes, vehicles, trips, drivers, reservations });
  return { app, trip, vehicle, reservations };
}

async function confirmAs(
  app: Awaited<ReturnType<typeof buildApp>>,
  userId: string,
  tripId: string,
) {
  const token = await jwt.signAccessToken({ userId, role: 'commuter' });
  return app.inject({
    method: 'POST',
    url: '/me/reservations',
    headers: { authorization: `Bearer ${token}` },
    payload: { tripId, travelDate: DATE, direction: 'morning', travelling: true },
  });
}

describe('POST /me/reservations capacity (#161)', () => {
  it('returns 409 trip_full once the bus is full', async () => {
    const { app, trip } = await setup(2);

    expect((await confirmAs(app, 'aaaaaaaa-0000-4000-8000-000000000001', trip.id)).statusCode).toBe(
      200,
    );
    expect((await confirmAs(app, 'aaaaaaaa-0000-4000-8000-000000000002', trip.id)).statusCode).toBe(
      200,
    );

    const third = await confirmAs(app, 'aaaaaaaa-0000-4000-8000-000000000003', trip.id);
    expect(third.statusCode).toBe(409);
    // Its own code, not a bare 409: the app must tell "full" from a generic
    // conflict to show the right thing.
    expect(third.json().error).toBe('trip_full');
  });

  it('writes no reservation when it refuses', async () => {
    const { app, trip, reservations } = await setup(1);
    await confirmAs(app, 'aaaaaaaa-0000-4000-8000-000000000001', trip.id);
    await confirmAs(app, 'aaaaaaaa-0000-4000-8000-000000000002', trip.id);

    expect(await reservations.countSeatsTaken(trip.id)).toBe(1);
  });

  it('does not constrain a trip whose capacity is unrecorded', async () => {
    // capacity 0 means "not in the fleet data", not "no seats".
    const { app, trip } = await setup(0);
    for (const n of ['1', '2', '3']) {
      const res = await confirmAs(app, `aaaaaaaa-0000-4000-8000-00000000000${n}`, trip.id);
      expect(res.statusCode).toBe(200);
    }
  });
});

describe('PUT /admin/trips/:id/assignment capacity (#161)', () => {
  it('refuses a bus smaller than the seats already confirmed', async () => {
    const { app, trip } = await setup(10);
    for (const n of ['1', '2', '3']) {
      await confirmAs(app, `aaaaaaaa-0000-4000-8000-00000000000${n}`, trip.id);
    }

    const adminToken = await jwt.signAccessToken({ userId: 'admin-1', role: 'admin' });
    // A 2-seat bus for 3 confirmed riders — silently accepting this would put
    // riders holding a valid reservation on a vehicle with nowhere to sit.
    const small = await app.inject({
      method: 'POST',
      url: '/admin/vehicles',
      headers: { authorization: `Bearer ${adminToken}` },
      payload: { registration: 'GR-0002-26', capacity: 2 },
    });

    const res = await app.inject({
      method: 'PUT',
      url: `/admin/trips/${trip.id}/assignment`,
      headers: { authorization: `Bearer ${adminToken}` },
      payload: { vehicleId: small.json().id },
    });

    expect(res.statusCode).toBe(409);
    expect(res.json().error).toBe('capacity_too_small');
  });

  it('allows reassigning to a bigger bus', async () => {
    const { app, trip } = await setup(3);
    for (const n of ['1', '2']) {
      await confirmAs(app, `aaaaaaaa-0000-4000-8000-00000000000${n}`, trip.id);
    }

    const adminToken = await jwt.signAccessToken({ userId: 'admin-1', role: 'admin' });
    const big = await app.inject({
      method: 'POST',
      url: '/admin/vehicles',
      headers: { authorization: `Bearer ${adminToken}` },
      payload: { registration: 'GR-0003-26', capacity: 30 },
    });

    const res = await app.inject({
      method: 'PUT',
      url: `/admin/trips/${trip.id}/assignment`,
      headers: { authorization: `Bearer ${adminToken}` },
      payload: { vehicleId: big.json().id },
    });
    expect(res.statusCode).toBe(200);
  });
});
