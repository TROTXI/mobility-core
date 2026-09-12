import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryVehicleRepository } from '../src/modules/mobility/vehicle.repository';
import { InMemoryDriverIncidentRepository } from '../src/modules/incidents/driver-incident.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const ROUTE = '11111111-1111-4111-8111-111111111111';
const MINE = 'aaaaaaaa-0000-4000-8000-000000000001';
const THEIRS = 'aaaaaaaa-0000-4000-8000-000000000002';
const ADMIN = 'aaaaaaaa-0000-4000-8000-000000000009';

const asDriver = async (userId: string) => ({
  authorization: `Bearer ${await jwt.signAccessToken({ userId, role: 'driver' })}`,
});
const asAdmin = async () => ({
  authorization: `Bearer ${await jwt.signAccessToken({ userId: ADMIN, role: 'admin' })}`,
});

async function setup() {
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();
  const vehicles = new InMemoryVehicleRepository();
  const driverIncidents = new InMemoryDriverIncidentRepository();

  const me = await drivers.create({ fullName: 'Kofi Anum Quartey', userId: MINE });
  await drivers.create({ fullName: 'Naa Dedei Lartey', userId: THEIRS });
  const van = await vehicles.create({ registration: 'GT 4417-24', capacity: 15 });
  const trip = await trips.create({
    routeId: ROUTE,
    vehicleId: van.id,
    assignedDriverId: me.id,
    scheduledAt: new Date('2026-08-26T06:30:00.000Z'),
  });

  const app = await buildApp({ auth, trips, drivers, vehicles, driverIncidents });
  return { app, trip, van, driverIncidents };
}

describe('driver incident reporting (#226)', () => {
  it('attaches the vehicle from the trip rather than trusting the app to send it', async () => {
    const { app, trip, van } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { tripId: trip.id, category: 'vehicle', note: 'Nearside door will not latch' },
    });

    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({
      tripId: trip.id,
      vehicleId: van.id,
      category: 'vehicle',
      status: 'open',
    });
  });

  it('accepts a report with no trip — a fault found in the yard still matters', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { category: 'vehicle', note: 'Brake warning light on before the first run' },
    });

    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({ tripId: null, vehicleId: null });
  });

  it('records the position the screen promises it attaches', async () => {
    const { app, trip } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { tripId: trip.id, category: 'route_blocked', lat: 5.6037, lng: -0.187 },
    });

    expect(res.json()).toMatchObject({ lat: 5.6037, lng: -0.187 });
  });

  it('refuses a driver attaching a report to a run that is not theirs', async () => {
    const { app, trip } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(THEIRS),
      payload: { tripId: trip.id, category: 'collision' },
    });

    expect(res.statusCode).toBe(403);
    expect(res.json()).toMatchObject({ error: 'forbidden' });
  });

  it('404s a report against a trip that does not exist', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { tripId: '99999999-9999-4999-8999-999999999999', category: 'other' },
    });

    expect(res.statusCode).toBe(404);
  });

  it('rejects a category the design does not have', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { category: 'emergency' },
    });

    // Emergency is not a category on purpose — it dials operations (#234).
    expect(res.statusCode).toBe(400);
  });

  it('shows a driver their own reports and not another driver’s', async () => {
    const { app, trip } = await setup();
    await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { tripId: trip.id, category: 'passenger_safety' },
    });

    const mine = await app.inject({
      method: 'GET',
      url: '/me/incidents',
      headers: await asDriver(MINE),
    });
    expect(mine.json().incidents).toHaveLength(1);

    const theirs = await app.inject({
      method: 'GET',
      url: '/me/incidents',
      headers: await asDriver(THEIRS),
    });
    expect(theirs.json().incidents).toEqual([]);
  });

  it('is not reachable with a commuter token', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: {
        authorization: `Bearer ${await jwt.signAccessToken({
          userId: 'rider-1',
          role: 'commuter',
        })}`,
      },
      payload: { category: 'other' },
    });

    expect(res.statusCode).toBe(403);
  });
});

describe('the operations queue (#226)', () => {
  it('lists open reports and filters by status', async () => {
    const { app, trip } = await setup();
    await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { tripId: trip.id, category: 'route_blocked' },
    });

    const open = await app.inject({
      method: 'GET',
      url: '/admin/incidents?status=open',
      headers: await asAdmin(),
    });
    expect(open.json().incidents).toHaveLength(1);

    const resolved = await app.inject({
      method: 'GET',
      url: '/admin/incidents?status=resolved',
      headers: await asAdmin(),
    });
    expect(resolved.json().incidents).toEqual([]);
  });

  it('records who acknowledged a report, and what they said', async () => {
    const { app, trip } = await setup();
    const filed = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { tripId: trip.id, category: 'collision' },
    });

    const decided = await app.inject({
      method: 'PATCH',
      url: `/admin/incidents/${filed.json().id}`,
      headers: await asAdmin(),
      payload: { status: 'resolved', resolution: 'Recovery dispatched; van swapped at 07:10' },
    });

    expect(decided.statusCode).toBe(200);
    expect(decided.json()).toMatchObject({
      status: 'resolved',
      handledBy: ADMIN,
      resolution: 'Recovery dispatched; van swapped at 07:10',
    });
    expect(decided.json().handledAt).not.toBeNull();
  });

  it('404s a decision on a report that does not exist', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'PATCH',
      url: '/admin/incidents/99999999-9999-4999-8999-999999999999',
      headers: await asAdmin(),
      payload: { status: 'acknowledged' },
    });

    expect(res.statusCode).toBe(404);
  });

  it('is not reachable with a driver token', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'GET',
      url: '/admin/incidents',
      headers: await asDriver(MINE),
    });

    expect(res.statusCode).toBe(403);
  });

  it('lets the driver read operations’ answer back', async () => {
    const { app, trip } = await setup();
    const filed = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { tripId: trip.id, category: 'vehicle' },
    });
    await app.inject({
      method: 'PATCH',
      url: `/admin/incidents/${filed.json().id}`,
      headers: await asAdmin(),
      payload: { status: 'acknowledged', resolution: 'Booked into the depot for Thursday' },
    });

    const mine = await app.inject({
      method: 'GET',
      url: '/me/incidents',
      headers: await asDriver(MINE),
    });
    expect(mine.json().incidents[0]).toMatchObject({
      status: 'acknowledged',
      resolution: 'Booked into the depot for Thursday',
    });
  });
});

describe('when the incident store is unwired', () => {
  it('503s rather than pretending the report was filed', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({
      method: 'POST',
      url: '/me/incidents',
      headers: await asDriver(MINE),
      payload: { category: 'other' },
    });

    expect(res.statusCode).toBe(503);
  });
});
