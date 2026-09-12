// Two gaps the driver screens hit: a month calendar that would have been
// thirty-one requests (#231), and "Stop 3 of 11", which nothing in the API could
// answer (#230).

import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const MINE = 'aaaaaaaa-0000-4000-8000-000000000001';
const THEIRS = 'aaaaaaaa-0000-4000-8000-000000000002';

const asDriver = async (userId: string) => ({
  authorization: `Bearer ${await jwt.signAccessToken({ userId, role: 'driver' })}`,
});

async function setup({ stopCount = 3 }: { stopCount?: number } = {}) {
  const routes = new InMemoryRouteRepository();
  const stops = new InMemoryStopRepository();
  const routeStops = new InMemoryRouteStopRepository();
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();

  const route = await routes.create({ name: 'Circle to Madina' });
  for (let seq = 1; seq <= stopCount; seq += 1) {
    const stop = await stops.create({ name: `Stop ${seq}`, latitude: 5.6, longitude: -0.18 });
    await routeStops.create({ routeId: route.id, stopId: stop.id, seq });
  }

  const me = await drivers.create({ fullName: 'Kofi Anum Quartey', userId: MINE });
  await drivers.create({ fullName: 'Naa Dedei Lartey', userId: THEIRS });

  const app = await buildApp({ auth, routes, stops, routeStops, trips, drivers });
  return { app, routes, routeStops, trips, route, me };
}

/**
 * Put a run on the driver's schedule.
 *
 * @param ctx - the setup context.
 * @param ctx.trips - the trip store.
 * @param ctx.route - the corridor.
 * @param ctx.me - the signed-in driver's fleet record.
 * @param at - when it departs, as an ISO instant.
 * @returns the created trip.
 */
async function scheduleRun(
  ctx: Awaited<ReturnType<typeof setup>>,
  at: string,
): Promise<{ id: string }> {
  return ctx.trips.create({
    routeId: ctx.route.id,
    assignedDriverId: ctx.me.id,
    scheduledAt: new Date(at),
  });
}

describe('a month of schedule in one request (#231)', () => {
  it('returns every run inside an inclusive range', async () => {
    const ctx = await setup();
    await scheduleRun(ctx, '2026-10-01T06:30:00.000Z');
    await scheduleRun(ctx, '2026-10-15T06:30:00.000Z');
    await scheduleRun(ctx, '2026-10-31T18:00:00.000Z');
    await scheduleRun(ctx, '2026-11-01T06:30:00.000Z');

    const res = await ctx.app.inject({
      method: 'GET',
      url: '/me/trips?from=2026-10-01&to=2026-10-31',
      headers: await asDriver(MINE),
    });

    expect(res.statusCode).toBe(200);
    expect(res.json().trips).toHaveLength(3);
  });

  it('includes both ends of the range', async () => {
    const ctx = await setup();
    await scheduleRun(ctx, '2026-10-01T05:00:00.000Z');
    await scheduleRun(ctx, '2026-10-03T23:30:00.000Z');

    const res = await ctx.app.inject({
      method: 'GET',
      url: '/me/trips?from=2026-10-01&to=2026-10-03',
      headers: await asDriver(MINE),
    });
    expect(res.json().trips).toHaveLength(2);
  });

  it('still shows nobody another driver’s schedule', async () => {
    const ctx = await setup();
    await scheduleRun(ctx, '2026-10-01T06:30:00.000Z');

    const res = await ctx.app.inject({
      method: 'GET',
      url: '/me/trips?from=2026-10-01&to=2026-10-31',
      headers: await asDriver(THEIRS),
    });
    expect(res.json().trips).toEqual([]);
  });

  it('refuses a range that could pull a year', async () => {
    const ctx = await setup();
    const res = await ctx.app.inject({
      method: 'GET',
      url: '/me/trips?from=2026-01-01&to=2026-12-31',
      headers: await asDriver(MINE),
    });
    expect(res.statusCode).toBe(400);
  });

  it('refuses half a range', async () => {
    const ctx = await setup();
    const res = await ctx.app.inject({
      method: 'GET',
      url: '/me/trips?from=2026-10-01',
      headers: await asDriver(MINE),
    });
    expect(res.statusCode).toBe(400);
  });

  it('refuses a range that runs backwards', async () => {
    const ctx = await setup();
    const res = await ctx.app.inject({
      method: 'GET',
      url: '/me/trips?from=2026-10-31&to=2026-10-01',
      headers: await asDriver(MINE),
    });
    expect(res.statusCode).toBe(400);
  });

  it('filters on the UTC day, so a late evening run lands on its own date', async () => {
    const ctx = await setup();
    // 23:30 UTC on the 31st. Ghana is UTC+0, so this is the 31st for everyone
    // who matters, and the range must not push it into November.
    await scheduleRun(ctx, '2026-10-31T23:30:00.000Z');

    const october = await ctx.app.inject({
      method: 'GET',
      url: '/me/trips?from=2026-10-01&to=2026-10-31',
      headers: await asDriver(MINE),
    });
    expect(october.json().trips).toHaveLength(1);

    const november = await ctx.app.inject({
      method: 'GET',
      url: '/me/trips?from=2026-11-01&to=2026-11-30',
      headers: await asDriver(MINE),
    });
    expect(november.json().trips).toEqual([]);
  });

  it('leaves the single-day filter working as it did', async () => {
    const ctx = await setup();
    await scheduleRun(ctx, '2026-10-15T06:30:00.000Z');
    await scheduleRun(ctx, '2026-10-16T06:30:00.000Z');

    const res = await ctx.app.inject({
      method: 'GET',
      url: '/me/trips?date=2026-10-15',
      headers: await asDriver(MINE),
    });
    expect(res.json().trips).toHaveLength(1);
  });
});

describe('stop progress (#230)', () => {
  it('starts null rather than guessing the run is at stop one', async () => {
    const ctx = await setup();
    const trip = await scheduleRun(ctx, '2026-10-01T06:30:00.000Z');

    const res = await ctx.app.inject({
      method: 'GET',
      url: `/trips/${trip.id}`,
      headers: await asDriver(MINE),
    });
    expect(res.json()).toMatchObject({ currentStopSeq: null, stopCount: 3 });
  });

  it('advances when the driver reports an arrival', async () => {
    const ctx = await setup();
    const trip = await scheduleRun(ctx, '2026-10-01T06:30:00.000Z');

    const arrived = await ctx.app.inject({
      method: 'POST',
      url: `/trips/${trip.id}/arrive`,
      headers: await asDriver(MINE),
      payload: { seq: 2 },
    });

    expect(arrived.statusCode).toBe(200);
    expect(arrived.json().currentStopSeq).toBe(2);
  });

  it('lets a driver tap back after overshooting', async () => {
    const ctx = await setup();
    const trip = await scheduleRun(ctx, '2026-10-01T06:30:00.000Z');
    const arrive = async (seq: number) =>
      ctx.app.inject({
        method: 'POST',
        url: `/trips/${trip.id}/arrive`,
        headers: await asDriver(MINE),
        payload: { seq },
      });

    await arrive(3);
    const corrected = await arrive(2);
    expect(corrected.json().currentStopSeq).toBe(2);
  });

  it('refuses a stop that is not on the route', async () => {
    const ctx = await setup();
    const trip = await scheduleRun(ctx, '2026-10-01T06:30:00.000Z');

    const res = await ctx.app.inject({
      method: 'POST',
      url: `/trips/${trip.id}/arrive`,
      headers: await asDriver(MINE),
      payload: { seq: 99 },
    });
    expect(res.statusCode).toBe(404);
  });

  it('refuses a driver who is not on this run', async () => {
    const ctx = await setup();
    const trip = await scheduleRun(ctx, '2026-10-01T06:30:00.000Z');

    const res = await ctx.app.inject({
      method: 'POST',
      url: `/trips/${trip.id}/arrive`,
      headers: await asDriver(THEIRS),
      payload: { seq: 1 },
    });
    expect(res.statusCode).toBe(403);
  });

  it('counts the route’s stops on the run summary', async () => {
    const ctx = await setup({ stopCount: 11 });
    const trip = await scheduleRun(ctx, '2026-10-01T06:30:00.000Z');

    const res = await ctx.app.inject({
      method: 'GET',
      url: `/trips/${trip.id}/summary`,
      headers: await asDriver(MINE),
    });
    expect(res.json().stopCount).toBe(11);
  });
});
