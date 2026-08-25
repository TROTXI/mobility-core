import { describe, expect, it } from 'vitest';
import { TripLifecycleService } from '../src/modules/mobility/trip-lifecycle.service';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';
import { InMemoryDriverRepository } from '../src/modules/mobility/driver.repository';
import { InMemoryReservationRepository } from '../src/modules/reservations/reservation.repository';
import { InMemoryScanEventRepository } from '../src/modules/boarding/scan-event.repository';

const ROUTE = '11111111-1111-4111-8111-111111111111';
const MINE = 'aaaaaaaa-0000-4000-8000-000000000001';
const THEIRS = 'aaaaaaaa-0000-4000-8000-000000000002';

async function setup() {
  const trips = new InMemoryTripRepository();
  const drivers = new InMemoryDriverRepository();
  const reservations = new InMemoryReservationRepository();
  const scanEvents = new InMemoryScanEventRepository();

  const me = await drivers.create({ fullName: 'Kwame Boateng', userId: MINE });
  const them = await drivers.create({ fullName: 'Yaw Asare', userId: THEIRS });
  const trip = await trips.create({
    routeId: ROUTE,
    scheduledAt: new Date('2026-08-26T06:30:00.000Z'),
    assignedDriverId: me.id,
  });

  const service = new TripLifecycleService({ trips, drivers, reservations, scanEvents });
  return { service, trips, drivers, reservations, scanEvents, me, them, trip };
}

describe('start / complete', () => {
  it('moves a run scheduled -> active -> completed and stamps both times', async () => {
    const { service, trip } = await setup();

    const started = await service.start(trip.id, MINE);
    expect(started.ok && started.trip.status).toBe('active');
    expect(started.ok && started.trip.startedAt).toBeInstanceOf(Date);

    const done = await service.complete(trip.id, MINE);
    expect(done.ok && done.trip.status).toBe('completed');
    expect(done.ok && done.trip.completedAt).toBeInstanceOf(Date);
  });

  it('is idempotent on start — a retried tap at the roadside must not error', async () => {
    const { service, trip } = await setup();
    await service.start(trip.id, MINE);
    const again = await service.start(trip.id, MINE);
    expect(again.ok).toBe(true);
  });

  it('refuses to complete a run that never started', async () => {
    // Means the wrong run was tapped. A "completed" trip with no GPS trace
    // would poison route learning.
    const { service, trip } = await setup();
    const result = await service.complete(trip.id, MINE);
    expect(result).toEqual({ ok: false, reason: 'illegal_transition' });
  });

  it('refuses to restart a completed run', async () => {
    const { service, trip } = await setup();
    await service.start(trip.id, MINE);
    await service.complete(trip.id, MINE);
    expect(await service.start(trip.id, MINE)).toEqual({
      ok: false,
      reason: 'illegal_transition',
    });
  });
});

describe('assigned-driver authorization', () => {
  it("refuses another driver's run", async () => {
    // Holding the driver role is not enough — this is the same rule that
    // guards position reporting and the manifest.
    const { service, trip } = await setup();
    expect(await service.start(trip.id, THEIRS)).toEqual({
      ok: false,
      reason: 'not_assigned_driver',
    });
  });

  it('refuses a user with no linked driver record', async () => {
    const { service, trip } = await setup();
    expect(await service.start(trip.id, 'aaaaaaaa-0000-4000-8000-000000000009')).toEqual({
      ok: false,
      reason: 'not_assigned_driver',
    });
  });

  it('reports not_found for a trip that does not exist', async () => {
    const { service } = await setup();
    expect(await service.start('99999999-9999-4999-8999-999999999999', MINE)).toEqual({
      ok: false,
      reason: 'not_found',
    });
  });
});

describe('myTrips', () => {
  it('returns only the caller’s runs, earliest first', async () => {
    const { service, trips, them } = await setup();
    await trips.create({
      routeId: ROUTE,
      scheduledAt: new Date('2026-08-26T17:30:00.000Z'),
      assignedDriverId: them.id,
    });

    const mine = await service.myTrips(MINE);
    expect(mine).toHaveLength(1);
    expect(mine[0]!.scheduledAt.getUTCHours()).toBe(6);
  });

  it('returns nothing for a user who is not a driver', async () => {
    const { service } = await setup();
    expect(await service.myTrips('aaaaaaaa-0000-4000-8000-000000000009')).toEqual([]);
  });
});

describe('run summary', () => {
  it('counts boarded and not-boarded, split by verification method', async () => {
    const { service, trip, reservations, scanEvents } = await setup();

    const boarded = await reservations.respond({
      userId: 'r1',
      tripId: trip.id,
      travelDate: '2026-08-26',
      direction: 'morning',
      travelling: true,
      pinHash: null,
    });
    await reservations.markBoarded(boarded.id);
    await reservations.respond({
      userId: 'r2',
      tripId: trip.id,
      travelDate: '2026-08-26',
      direction: 'morning',
      travelling: true,
      pinHash: null,
    });

    await scanEvents.record({
      riderId: 'r1',
      scannedBy: MINE,
      tripId: trip.id,
      result: 'valid',
      method: 'qr',
    });
    await scanEvents.record({
      riderId: 'r3',
      scannedBy: MINE,
      tripId: trip.id,
      result: 'valid',
      method: 'pin',
    });
    // A rejected scan is not a boarding.
    await scanEvents.record({
      riderId: 'r4',
      scannedBy: MINE,
      tripId: trip.id,
      result: 'expired',
      method: 'qr',
    });

    const result = await service.summary(trip.id, MINE);
    expect(result.ok).toBe(true);
    if (!result.ok) return;

    expect(result.summary.boarded).toBe(1);
    expect(result.summary.notBoarded).toBe(1);
    expect(result.summary.byMethod).toEqual({ qr: 1, pin: 1, photo: 0 });
  });

  it("refuses another driver's summary", async () => {
    const { service, trip } = await setup();
    expect(await service.summary(trip.id, THEIRS)).toEqual({
      ok: false,
      reason: 'not_assigned_driver',
    });
  });
});
