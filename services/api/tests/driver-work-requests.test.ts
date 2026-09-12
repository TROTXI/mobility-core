import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryDriverRequestRepository } from '../src/modules/work/driver-request.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
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
  const routes = new InMemoryRouteRepository();
  const drivers = new InMemoryDriverRepository();
  const trips = new InMemoryTripRepository();
  const driverRequests = new InMemoryDriverRequestRepository();

  const me = await drivers.create({ fullName: 'Kofi Anum Quartey', userId: MINE });
  await drivers.create({ fullName: 'Naa Dedei Lartey', userId: THEIRS });
  const open = await routes.create({ name: 'Madina to Circle', acceptsRequests: true });
  const closed = await routes.create({ name: 'Kasoa to Kaneshie' });

  const app = await buildApp({ auth, routes, drivers, trips, driverRequests });
  return { app, routes, trips, open, closed, me };
}

describe('routes a driver may ask for (#232)', () => {
  it('shows only the corridors operations has opened', async () => {
    const { app, open } = await setup();
    const res = await app.inject({
      method: 'GET',
      url: '/me/work/routes',
      headers: await asDriver(MINE),
    });

    expect(res.statusCode).toBe(200);
    expect(res.json().routes).toHaveLength(1);
    expect(res.json().routes[0]).toMatchObject({ id: open.id, name: 'Madina to Circle' });
  });

  it('opens and closes with the ops flag rather than a code change', async () => {
    const { app, routes, closed } = await setup();
    await routes.update(closed.id, { acceptsRequests: true });

    const res = await app.inject({
      method: 'GET',
      url: '/me/work/routes',
      headers: await asDriver(MINE),
    });
    expect(res.json().routes).toHaveLength(2);
  });
});

describe('submitting a request (#232)', () => {
  it('accepts a route change for an open corridor', async () => {
    const { app, open } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'route_change', routeId: open.id, fromDate: '2026-10-01' },
    });

    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({
      kind: 'route_change',
      status: 'pending',
      routeId: open.id,
      fromDate: '2026-10-01',
    });
  });

  it('refuses a corridor operations has not opened, and says why', async () => {
    const { app, closed } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'route_change', routeId: closed.id },
    });

    // 409 rather than 404: the route exists and the driver can see it on a map.
    expect(res.statusCode).toBe(409);
    expect(res.json()).toMatchObject({ error: 'route_closed' });
  });

  it('accepts leave with a span of dates', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'leave', fromDate: '2026-12-24', toDate: '2026-12-27', note: 'Ada Foah' },
    });

    expect(res.statusCode).toBe(201);
    expect(res.json()).toMatchObject({
      kind: 'leave',
      fromDate: '2026-12-24',
      toDate: '2026-12-27',
    });
  });

  it('refuses leave with no end date at the edge, not at the constraint', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'leave', fromDate: '2026-12-24' },
    });

    expect(res.statusCode).toBe(400);
  });
});

describe('the rule the design hangs on (#232)', () => {
  it('approving a route change does not reassign anything', async () => {
    const { app, open, trips, me } = await setup();
    const trip = await trips.create({
      routeId: '11111111-1111-4111-8111-111111111111',
      assignedDriverId: me.id,
      scheduledAt: new Date('2026-10-02T06:30:00.000Z'),
    });

    const submitted = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'route_change', routeId: open.id },
    });
    const approved = await app.inject({
      method: 'PATCH',
      url: `/admin/driver-requests/${submitted.json().id}`,
      headers: await asAdmin(),
      payload: { status: 'approved', decisionNote: 'Yes, from the 5th' },
    });

    expect(approved.json()).toMatchObject({ status: 'approved', decidedBy: ADMIN });

    // The published assignment is untouched: someone still has to move the
    // driver deliberately, through the endpoint that checks capacity.
    const after = await trips.findById(trip.id);
    expect(after?.routeId).toBe('11111111-1111-4111-8111-111111111111');
    expect(after?.assignedDriverId).toBe(me.id);
  });

  it('lets the driver read the decision and its note', async () => {
    const { app, open } = await setup();
    const submitted = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'route_change', routeId: open.id },
    });
    await app.inject({
      method: 'PATCH',
      url: `/admin/driver-requests/${submitted.json().id}`,
      headers: await asAdmin(),
      payload: { status: 'declined', decisionNote: 'No cover on that corridor until January' },
    });

    const mine = await app.inject({
      method: 'GET',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
    });
    expect(mine.json().requests[0]).toMatchObject({
      status: 'declined',
      decisionNote: 'No cover on that corridor until January',
    });
  });

  it('refuses a second decision rather than overwriting the first', async () => {
    const { app, open } = await setup();
    const submitted = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'route_change', routeId: open.id },
    });
    const url = `/admin/driver-requests/${submitted.json().id}`;

    const first = await app.inject({
      method: 'PATCH',
      url,
      headers: await asAdmin(),
      payload: { status: 'approved' },
    });
    expect(first.statusCode).toBe(200);

    const second = await app.inject({
      method: 'PATCH',
      url,
      headers: await asAdmin(),
      payload: { status: 'declined' },
    });
    expect(second.statusCode).toBe(404);
  });
});

describe('withdrawing (#232)', () => {
  it('takes back a request operations has not answered', async () => {
    const { app, open } = await setup();
    const submitted = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'route_change', routeId: open.id },
    });

    const res = await app.inject({
      method: 'POST',
      url: `/me/work/requests/${submitted.json().id}/withdraw`,
      headers: await asDriver(MINE),
    });
    expect(res.json()).toMatchObject({ status: 'withdrawn' });
  });

  it('does not let one driver withdraw another’s, or tell them it exists', async () => {
    const { app, open } = await setup();
    const submitted = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'route_change', routeId: open.id },
    });

    const res = await app.inject({
      method: 'POST',
      url: `/me/work/requests/${submitted.json().id}/withdraw`,
      headers: await asDriver(THEIRS),
    });
    // The same 404 a made-up id gets, so the endpoint cannot be used to probe.
    expect(res.statusCode).toBe(404);
  });

  it('cannot erase a decision', async () => {
    const { app, open } = await setup();
    const submitted = await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'route_change', routeId: open.id },
    });
    await app.inject({
      method: 'PATCH',
      url: `/admin/driver-requests/${submitted.json().id}`,
      headers: await asAdmin(),
      payload: { status: 'approved' },
    });

    const res = await app.inject({
      method: 'POST',
      url: `/me/work/requests/${submitted.json().id}/withdraw`,
      headers: await asDriver(MINE),
    });
    expect(res.statusCode).toBe(404);
  });
});

describe('the operations queue (#232)', () => {
  it('filters by status', async () => {
    const { app, open } = await setup();
    await app.inject({
      method: 'POST',
      url: '/me/work/requests',
      headers: await asDriver(MINE),
      payload: { kind: 'route_change', routeId: open.id },
    });

    const pending = await app.inject({
      method: 'GET',
      url: '/admin/driver-requests?status=pending',
      headers: await asAdmin(),
    });
    expect(pending.json().requests).toHaveLength(1);

    const approved = await app.inject({
      method: 'GET',
      url: '/admin/driver-requests?status=approved',
      headers: await asAdmin(),
    });
    expect(approved.json().requests).toEqual([]);
  });

  it('is not reachable with a driver token', async () => {
    const { app } = await setup();
    const res = await app.inject({
      method: 'GET',
      url: '/admin/driver-requests',
      headers: await asDriver(MINE),
    });
    expect(res.statusCode).toBe(403);
  });
});
