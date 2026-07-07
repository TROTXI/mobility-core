import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';

async function appWithRepos() {
  const routes = new InMemoryRouteRepository();
  const stops = new InMemoryStopRepository();
  const routeStops = new InMemoryRouteStopRepository();
  const app = await buildApp({ routes, stops, routeStops });
  return { app, routes, stops, routeStops };
}

describe('GET /routes', () => {
  it('returns an empty array when no routes exist', async () => {
    const { app } = await appWithRepos();
    const res = await app.inject({ method: 'GET', url: '/routes' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual([]);
  });

  it('returns all routes', async () => {
    const { app, routes } = await appWithRepos();
    await routes.create({ name: 'Circle to Legon', description: 'Main route' });
    await routes.create({ name: 'Accra Mall Loop', description: null });

    const res = await app.inject({ method: 'GET', url: '/routes' });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body).toHaveLength(2);
    expect(body.map((r: { name: string }) => r.name)).toEqual(
      expect.arrayContaining(['Circle to Legon', 'Accra Mall Loop']),
    );
  });

  it('returns an empty array when repositories are not wired', async () => {
    const app = await buildApp();
    const res = await app.inject({ method: 'GET', url: '/routes' });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual([]);
  });
});

describe('GET /routes/:id', () => {
  it('returns 404 when repositories are not wired', async () => {
    const app = await buildApp();
    const res = await app.inject({
      method: 'GET',
      url: `/routes/00000000-0000-0000-0000-000000000001`,
    });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toMatchObject({ error: 'not_found' });
  });

  it('returns 404 for an unknown id', async () => {
    const { app } = await appWithRepos();
    const res = await app.inject({
      method: 'GET',
      url: `/routes/00000000-0000-0000-0000-000000000001`,
    });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toMatchObject({ error: 'not_found' });
  });

  it('returns 400 for a non-UUID id', async () => {
    const { app } = await appWithRepos();
    const res = await app.inject({ method: 'GET', url: '/routes/not-a-uuid' });
    expect(res.statusCode).toBe(400);
  });

  it('returns the route with stops ordered by seq', async () => {
    const { app, routes, stops, routeStops } = await appWithRepos();

    const route = await routes.create({ name: 'Circle to Legon' });
    const circle = await stops.create({ name: 'Circle', latitude: 5.5502, longitude: -0.2174 });
    const university = await stops.create({
      name: 'University of Ghana',
      latitude: 5.6502,
      longitude: -0.1869,
    });

    // Insert out-of-order to verify seq sorting.
    await routeStops.create({ routeId: route.id, stopId: university.id, seq: 2 });
    await routeStops.create({ routeId: route.id, stopId: circle.id, seq: 1 });

    const res = await app.inject({ method: 'GET', url: `/routes/${route.id}` });
    expect(res.statusCode).toBe(200);

    const body = res.json();
    expect(body).toMatchObject({ id: route.id, name: 'Circle to Legon' });
    expect(body.stops).toHaveLength(2);
    expect(body.stops[0]).toMatchObject({ name: 'Circle', seq: 1 });
    expect(body.stops[1]).toMatchObject({ name: 'University of Ghana', seq: 2 });
  });

  it('returns a route with no stops', async () => {
    const { app, routes } = await appWithRepos();
    const route = await routes.create({ name: 'Empty Route' });

    const res = await app.inject({ method: 'GET', url: `/routes/${route.id}` });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ id: route.id, stops: [] });
  });

  it('includes stop coordinates in the response', async () => {
    const { app, routes, stops, routeStops } = await appWithRepos();

    const route = await routes.create({ name: 'Coordinate Test Route' });
    const stop = await stops.create({ name: 'Accra Mall', latitude: 5.6369, longitude: -0.1614 });
    await routeStops.create({ routeId: route.id, stopId: stop.id, seq: 1 });

    const res = await app.inject({ method: 'GET', url: `/routes/${route.id}` });
    expect(res.statusCode).toBe(200);
    expect(res.json().stops[0]).toMatchObject({
      name: 'Accra Mall',
      latitude: 5.6369,
      longitude: -0.1614,
    });
  });
});
