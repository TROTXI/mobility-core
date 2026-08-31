import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';
import { InMemoryRouteGeometryRepository } from '../src/modules/mobility/route-geometry.repository';

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
      url: `/routes/00000000-0000-4000-8000-000000000001`,
    });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toMatchObject({ error: 'not_found' });
  });

  it('returns 404 for an unknown id', async () => {
    const { app } = await appWithRepos();
    const res = await app.inject({
      method: 'GET',
      url: `/routes/00000000-0000-4000-8000-000000000001`,
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

describe('GET /routes/:id/geometry (#206)', () => {
  /** A route with three stops, plus an optional learned path. */
  async function seedRoute(withGeometry: boolean) {
    const routes = new InMemoryRouteRepository();
    const stops = new InMemoryStopRepository();
    const routeStops = new InMemoryRouteStopRepository();
    const routeGeometry = new InMemoryRouteGeometryRepository();

    const route = await routes.create({ name: 'Adenta to Airport City', description: null });
    const a = await stops.create({ name: 'Adenta', latitude: 5.71, longitude: -0.16 });
    const b = await stops.create({ name: 'Shiashie', latitude: 5.63, longitude: -0.18 });
    const c = await stops.create({ name: 'Airport City', latitude: 5.6, longitude: -0.18 });
    await routeStops.create({ routeId: route.id, stopId: a.id, seq: 1 });
    await routeStops.create({ routeId: route.id, stopId: b.id, seq: 2 });
    await routeStops.create({ routeId: route.id, stopId: c.id, seq: 3 });

    if (withGeometry) {
      await routeGeometry.save({
        routeId: route.id,
        // more points than stops: the whole point is that it bends with the road
        points: [
          { latitude: 5.71, longitude: -0.16 },
          { latitude: 5.68, longitude: -0.165 },
          { latitude: 5.65, longitude: -0.172 },
          { latitude: 5.63, longitude: -0.18 },
          { latitude: 5.6, longitude: -0.18 },
        ],
        source: 'traces',
        runCount: 12,
        stopDistances: new Map(),
      });
    }

    const app = await buildApp({ routes, stops, routeStops, routeGeometry });
    return { app, route };
  }

  it('returns the learned path when the corridor has run enough times', async () => {
    const { app, route } = await seedRoute(true);
    const res = await app.inject({ method: 'GET', url: `/routes/${route.id}/geometry` });

    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ routeId: route.id, source: 'traces', runCount: 12 });
    // it bends with the road, so it has more points than the route has stops
    expect(res.json().points.length).toBeGreaterThan(3);
  });

  it('falls back to the stops on a corridor that has never run', async () => {
    const { app, route } = await seedRoute(false);
    const res = await app.inject({ method: 'GET', url: `/routes/${route.id}/geometry` });

    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ source: 'stops', runCount: 0 });
    // a straight line through the three stops, in order
    expect(res.json().points).toEqual([
      { latitude: 5.71, longitude: -0.16 },
      { latitude: 5.63, longitude: -0.18 },
      { latitude: 5.6, longitude: -0.18 },
    ]);
  });

  it('404s for a route that does not exist', async () => {
    const { app } = await seedRoute(false);
    const res = await app.inject({
      method: 'GET',
      url: '/routes/00000000-0000-4000-8000-0000000000ff/geometry',
    });
    expect(res.statusCode).toBe(404);
  });
});
