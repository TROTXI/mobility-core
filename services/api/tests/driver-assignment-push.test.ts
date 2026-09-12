// Driver-facing push (#233). Before this the only sender was the rider
// ask-dispatch fan-out, so a driver whose run moved at 04:00 found out by
// opening the app and noticing.

import type { LightMyRequestResponse } from 'fastify';
import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryVehicleRepository } from '../src/modules/mobility/vehicle.repository';
import { FakeNotificationSender } from '../src/modules/notifications/notification.sender';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const FIRST = 'aaaaaaaa-0000-4000-8000-000000000001';
const SECOND = 'aaaaaaaa-0000-4000-8000-000000000002';

const asAdmin = async () => ({
  authorization: `Bearer ${await jwt.signAccessToken({ userId: 'ops-1', role: 'admin' })}`,
});

async function setup() {
  const routes = new InMemoryRouteRepository();
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();
  const vehicles = new InMemoryVehicleRepository();
  const notifier = new FakeNotificationSender();

  const route = await routes.create({ name: 'Circle to Madina' });
  const first = await drivers.create({ fullName: 'Kofi Anum Quartey', userId: FIRST });
  const second = await drivers.create({ fullName: 'Naa Dedei Lartey', userId: SECOND });
  const vanA = await vehicles.create({ registration: 'GT 1111-24', capacity: 15 });
  const vanB = await vehicles.create({ registration: 'GT 2222-24', capacity: 15 });
  const trip = await trips.create({
    routeId: route.id,
    scheduledAt: new Date('2026-10-01T06:30:00.000Z'),
  });

  const app = await buildApp({ auth, routes, trips, drivers, vehicles, notifier });
  return { app, trips, trip, first, second, vanA, vanB, notifier };
}

/**
 * Assign a vehicle and/or driver, as ops would.
 *
 * @param ctx - the setup context.
 * @param ctx.app - the built app.
 * @param ctx.trip - the trip being assigned.
 * @param body - the assignment patch.
 * @returns the injected response.
 */
async function assign(
  ctx: Awaited<ReturnType<typeof setup>>,
  body: Record<string, string | null>,
): Promise<LightMyRequestResponse> {
  return ctx.app.inject({
    method: 'PUT',
    url: `/admin/trips/${ctx.trip.id}/assignment`,
    headers: await asAdmin(),
    payload: body,
  });
}

describe('telling a driver their run moved (#233)', () => {
  it('pushes to the driver who gains the run', async () => {
    const ctx = await setup();
    await assign(ctx, { assignedDriverId: ctx.first.id });

    expect(ctx.notifier.sent).toHaveLength(1);
    expect(ctx.notifier.sent[0]).toMatchObject({
      userId: FIRST,
      title: 'New run assigned',
    });
    expect(ctx.notifier.sent[0]?.data).toMatchObject({ tripId: ctx.trip.id, change: 'assigned' });
  });

  it('pushes to the driver who loses it — they are the one who would turn up', async () => {
    const ctx = await setup();
    await assign(ctx, { assignedDriverId: ctx.first.id });
    ctx.notifier.sent.length = 0;

    await assign(ctx, { assignedDriverId: ctx.second.id });

    const titles = ctx.notifier.sent.map((n) => `${n.userId}:${n.title}`);
    expect(titles).toContain(`${SECOND}:New run assigned`);
    expect(titles).toContain(`${FIRST}:Run removed from your schedule`);
  });

  it('says nothing when the assignment did not actually change', async () => {
    const ctx = await setup();
    await assign(ctx, { assignedDriverId: ctx.first.id, vehicleId: ctx.vanA.id });
    ctx.notifier.sent.length = 0;

    await assign(ctx, { assignedDriverId: ctx.first.id, vehicleId: ctx.vanA.id });
    expect(ctx.notifier.sent).toEqual([]);
  });

  it('tells the driver when the bus under them changes', async () => {
    const ctx = await setup();
    await assign(ctx, { assignedDriverId: ctx.first.id, vehicleId: ctx.vanA.id });
    ctx.notifier.sent.length = 0;

    await assign(ctx, { assignedDriverId: ctx.first.id, vehicleId: ctx.vanB.id });

    expect(ctx.notifier.sent).toHaveLength(1);
    expect(ctx.notifier.sent[0]).toMatchObject({ userId: FIRST, title: 'Vehicle changed' });
  });

  it('tells the driver when the departure time moves', async () => {
    const ctx = await setup();
    await assign(ctx, { assignedDriverId: ctx.first.id });
    ctx.notifier.sent.length = 0;

    await ctx.app.inject({
      method: 'PATCH',
      url: `/admin/trips/${ctx.trip.id}`,
      headers: await asAdmin(),
      payload: { scheduledAt: '2026-10-01T07:15:00.000Z' },
    });

    expect(ctx.notifier.sent).toHaveLength(1);
    expect(ctx.notifier.sent[0]).toMatchObject({ title: 'Departure time changed' });
  });

  it('stays quiet when only the status flips', async () => {
    const ctx = await setup();
    await assign(ctx, { assignedDriverId: ctx.first.id });
    ctx.notifier.sent.length = 0;

    await ctx.app.inject({
      method: 'PATCH',
      url: `/admin/trips/${ctx.trip.id}`,
      headers: await asAdmin(),
      payload: { status: 'cancelled' },
    });

    expect(ctx.notifier.sent).toEqual([]);
  });
});

describe('the badge that survives a missed push (#233)', () => {
  it('stamps the trip so the app can mark it CHANGED on its next read', async () => {
    const ctx = await setup();
    await assign(ctx, { assignedDriverId: ctx.first.id });

    const stored = await ctx.trips.findById(ctx.trip.id);
    expect(stored?.assignmentChangedAt).not.toBeNull();
  });

  it('is null on a run nobody has touched', async () => {
    const ctx = await setup();
    const stored = await ctx.trips.findById(ctx.trip.id);
    expect(stored?.assignmentChangedAt).toBeNull();
  });
});
