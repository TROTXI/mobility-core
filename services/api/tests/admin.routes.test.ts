import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryVehicleRepository } from '../src/modules/mobility/vehicle.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });
const adminToken = () => jwt.signAccessToken({ userId: 'admin-1', role: 'admin' });
const commuterToken = () => jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
const UNKNOWN = '00000000-0000-0000-0000-0000000000ff';
const SCHEDULED_AT = '2026-07-08T06:00:00.000Z';

async function adminApp() {
  const routes = new InMemoryRouteRepository();
  const stops = new InMemoryStopRepository();
  const routeStops = new InMemoryRouteStopRepository();
  const vehicles = new InMemoryVehicleRepository();
  const drivers = new InMemoryDriverRepository();
  const trips = new InMemoryTripRepository();
  const app = await buildApp({ auth, routes, stops, routeStops, vehicles, drivers, trips });
  return { app, routes, stops, routeStops, vehicles, drivers, trips };
}

describe('admin authz', () => {
  it('401 without a token', async () => {
    const { app } = await adminApp();
    const res = await app.inject({ method: 'GET', url: '/admin/routes' });
    expect(res.statusCode).toBe(401);
  });

  it('403 for a non-admin (commuter) on a read', async () => {
    const { app } = await adminApp();
    const res = await app.inject({
      method: 'GET',
      url: '/admin/routes',
      headers: bearer(await commuterToken()),
    });
    expect(res.statusCode).toBe(403);
  });

  it('403 for a non-admin on a write', async () => {
    const { app } = await adminApp();
    const res = await app.inject({
      method: 'POST',
      url: '/admin/vehicles',
      headers: bearer(await commuterToken()),
      payload: { registration: 'GR-1' },
    });
    expect(res.statusCode).toBe(403);
  });

  it('503 when repos are not wired', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({
      method: 'GET',
      url: '/admin/routes',
      headers: bearer(await adminToken()),
    });
    expect(res.statusCode).toBe(503);
  });
});

describe('admin routes CRUD', () => {
  it('creates, lists, and updates a route', async () => {
    const { app } = await adminApp();
    const token = await adminToken();

    const created = await app.inject({
      method: 'POST',
      url: '/admin/routes',
      headers: bearer(token),
      payload: { name: 'Circle to Legon', description: 'Main' },
    });
    expect(created.statusCode).toBe(200);
    const routeId = created.json().id;

    const list = await app.inject({ method: 'GET', url: '/admin/routes', headers: bearer(token) });
    expect(list.json()).toHaveLength(1);

    const patched = await app.inject({
      method: 'PATCH',
      url: `/admin/routes/${routeId}`,
      headers: bearer(token),
      payload: { name: 'Circle to Madina' },
    });
    expect(patched.statusCode).toBe(200);
    expect(patched.json()).toMatchObject({ name: 'Circle to Madina', description: 'Main' });
  });

  it('clears a nullable field with an explicit null', async () => {
    const { app } = await adminApp();
    const token = await adminToken();
    const created = await app.inject({
      method: 'POST',
      url: '/admin/routes',
      headers: bearer(token),
      payload: { name: 'R', description: 'has desc' },
    });
    const patched = await app.inject({
      method: 'PATCH',
      url: `/admin/routes/${created.json().id}`,
      headers: bearer(token),
      payload: { description: null },
    });
    expect(patched.json().description).toBeNull();
  });

  it('404 updating an unknown route', async () => {
    const { app } = await adminApp();
    const res = await app.inject({
      method: 'PATCH',
      url: `/admin/routes/${UNKNOWN}`,
      headers: bearer(await adminToken()),
      payload: { name: 'x' },
    });
    expect(res.statusCode).toBe(404);
  });
});

describe('admin stops + attach', () => {
  it('creates a stop and attaches it to a route at a seq', async () => {
    const { app, routes } = await adminApp();
    const token = await adminToken();
    const route = await routes.create({ name: 'R' });

    const stop = await app.inject({
      method: 'POST',
      url: '/admin/stops',
      headers: bearer(token),
      payload: { name: 'Circle', latitude: 5.5502, longitude: -0.2174 },
    });
    expect(stop.statusCode).toBe(200);
    expect(stop.json()).toMatchObject({ name: 'Circle', latitude: 5.5502 });

    const attached = await app.inject({
      method: 'POST',
      url: `/admin/routes/${route.id}/stops`,
      headers: bearer(token),
      payload: { stopId: stop.json().id, seq: 1 },
    });
    expect(attached.statusCode).toBe(200);
    expect(attached.json()).toMatchObject({ routeId: route.id, stopId: stop.json().id, seq: 1 });
  });

  it('404 attaching to an unknown route', async () => {
    const { app, stops } = await adminApp();
    const stop = await stops.create({ name: 'S', latitude: 1, longitude: 2 });
    const res = await app.inject({
      method: 'POST',
      url: `/admin/routes/${UNKNOWN}/stops`,
      headers: bearer(await adminToken()),
      payload: { stopId: stop.id, seq: 1 },
    });
    expect(res.statusCode).toBe(404);
    expect(res.json().message).toMatch(/route/i);
  });

  it('404 attaching an unknown stop', async () => {
    const { app, routes } = await adminApp();
    const route = await routes.create({ name: 'R' });
    const res = await app.inject({
      method: 'POST',
      url: `/admin/routes/${route.id}/stops`,
      headers: bearer(await adminToken()),
      payload: { stopId: UNKNOWN, seq: 1 },
    });
    expect(res.statusCode).toBe(404);
    expect(res.json().message).toMatch(/stop/i);
  });
});

describe('admin vehicles + drivers', () => {
  it('creates, lists, and updates a vehicle', async () => {
    const { app } = await adminApp();
    const token = await adminToken();
    const created = await app.inject({
      method: 'POST',
      url: '/admin/vehicles',
      headers: bearer(token),
      payload: { registration: 'GR-1234-24', label: 'Bus 7', capacity: 33 },
    });
    expect(created.statusCode).toBe(200);

    const list = await app.inject({
      method: 'GET',
      url: '/admin/vehicles',
      headers: bearer(token),
    });
    expect(list.json()).toHaveLength(1);

    const patched = await app.inject({
      method: 'PATCH',
      url: `/admin/vehicles/${created.json().id}`,
      headers: bearer(token),
      payload: { capacity: 40 },
    });
    expect(patched.json()).toMatchObject({ registration: 'GR-1234-24', capacity: 40 });
  });

  it('creates and updates a driver', async () => {
    const { app } = await adminApp();
    const token = await adminToken();
    const created = await app.inject({
      method: 'POST',
      url: '/admin/drivers',
      headers: bearer(token),
      payload: { fullName: 'Kwame Mensah', phone: '+233200000000' },
    });
    expect(created.statusCode).toBe(200);
    const patched = await app.inject({
      method: 'PATCH',
      url: `/admin/drivers/${created.json().id}`,
      headers: bearer(token),
      payload: { licenseNumber: 'DL-1' },
    });
    expect(patched.json()).toMatchObject({ fullName: 'Kwame Mensah', licenseNumber: 'DL-1' });
  });
});

describe('admin trips + assignment', () => {
  it('creates a trip on an existing route', async () => {
    const { app, routes } = await adminApp();
    const route = await routes.create({ name: 'R' });
    const res = await app.inject({
      method: 'POST',
      url: '/admin/trips',
      headers: bearer(await adminToken()),
      payload: { routeId: route.id, scheduledAt: SCHEDULED_AT },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ routeId: route.id, status: 'scheduled' });
  });

  it('404 creating a trip on an unknown route', async () => {
    const { app } = await adminApp();
    const res = await app.inject({
      method: 'POST',
      url: '/admin/trips',
      headers: bearer(await adminToken()),
      payload: { routeId: UNKNOWN, scheduledAt: SCHEDULED_AT },
    });
    expect(res.statusCode).toBe(404);
    expect(res.json().message).toMatch(/route/i);
  });

  it('404 creating a trip with an unknown vehicle', async () => {
    const { app, routes } = await adminApp();
    const route = await routes.create({ name: 'R' });
    const res = await app.inject({
      method: 'POST',
      url: '/admin/trips',
      headers: bearer(await adminToken()),
      payload: { routeId: route.id, vehicleId: UNKNOWN, scheduledAt: SCHEDULED_AT },
    });
    expect(res.statusCode).toBe(404);
    expect(res.json().message).toMatch(/vehicle/i);
  });

  it('updates trip status', async () => {
    const { app, routes, trips } = await adminApp();
    const route = await routes.create({ name: 'R' });
    const trip = await trips.create({ routeId: route.id, scheduledAt: new Date(SCHEDULED_AT) });
    const res = await app.inject({
      method: 'PATCH',
      url: `/admin/trips/${trip.id}`,
      headers: bearer(await adminToken()),
      payload: { status: 'active' },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().status).toBe('active');
  });

  it('assigns a vehicle and driver to a trip', async () => {
    const { app, routes, vehicles, drivers, trips } = await adminApp();
    const route = await routes.create({ name: 'R' });
    const vehicle = await vehicles.create({ registration: 'GR-1' });
    const driver = await drivers.create({ fullName: 'Ama' });
    const trip = await trips.create({ routeId: route.id, scheduledAt: new Date(SCHEDULED_AT) });

    const res = await app.inject({
      method: 'PUT',
      url: `/admin/trips/${trip.id}/assignment`,
      headers: bearer(await adminToken()),
      payload: { vehicleId: vehicle.id, assignedDriverId: driver.id },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ vehicleId: vehicle.id, assignedDriverId: driver.id });
  });

  it('unassigns a driver with an explicit null', async () => {
    const { app, routes, drivers, trips } = await adminApp();
    const route = await routes.create({ name: 'R' });
    const driver = await drivers.create({ fullName: 'Ama' });
    const trip = await trips.create({
      routeId: route.id,
      assignedDriverId: driver.id,
      scheduledAt: new Date(SCHEDULED_AT),
    });
    const res = await app.inject({
      method: 'PUT',
      url: `/admin/trips/${trip.id}/assignment`,
      headers: bearer(await adminToken()),
      payload: { assignedDriverId: null },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().assignedDriverId).toBeNull();
  });

  it('404 assigning an unknown driver', async () => {
    const { app, routes, trips } = await adminApp();
    const route = await routes.create({ name: 'R' });
    const trip = await trips.create({ routeId: route.id, scheduledAt: new Date(SCHEDULED_AT) });
    const res = await app.inject({
      method: 'PUT',
      url: `/admin/trips/${trip.id}/assignment`,
      headers: bearer(await adminToken()),
      payload: { assignedDriverId: UNKNOWN },
    });
    expect(res.statusCode).toBe(404);
    expect(res.json().message).toMatch(/driver/i);
  });

  it('404 assigning to an unknown trip', async () => {
    const { app } = await adminApp();
    const res = await app.inject({
      method: 'PUT',
      url: `/admin/trips/${UNKNOWN}/assignment`,
      headers: bearer(await adminToken()),
      payload: {},
    });
    expect(res.statusCode).toBe(404);
    expect(res.json().message).toMatch(/trip/i);
  });
});
