import { describe, expect, it } from 'vitest';
import { InMemoryTripRepository } from '../src/modules/mobility/trip.repository';

const ROUTE_A = '00000000-0000-0000-0000-0000000000a1';
const ROUTE_B = '00000000-0000-0000-0000-0000000000b2';

describe('InMemoryTripRepository', () => {
  it('creates a trip and finds it by id', async () => {
    const repo = new InMemoryTripRepository();
    const scheduledAt = new Date('2026-07-08T06:30:00Z');
    const created = await repo.create({
      routeId: ROUTE_A,
      vehicleId: 'veh-1',
      assignedDriverId: 'drv-1',
      scheduledAt,
    });

    expect(created.id).toBeTruthy();
    expect(created.routeId).toBe(ROUTE_A);
    expect(created.vehicleId).toBe('veh-1');
    expect(created.assignedDriverId).toBe('drv-1');
    expect(created.scheduledAt).toEqual(scheduledAt);

    const found = await repo.findById(created.id);
    expect(found?.id).toBe(created.id);
  });

  it('defaults status to scheduled and vehicle/driver to null', async () => {
    const repo = new InMemoryTripRepository();
    const trip = await repo.create({ routeId: ROUTE_A, scheduledAt: new Date() });
    expect(trip.status).toBe('scheduled');
    expect(trip.vehicleId).toBeNull();
    expect(trip.assignedDriverId).toBeNull();
  });

  it('returns null for an unknown id', async () => {
    const repo = new InMemoryTripRepository();
    expect(await repo.findById('does-not-exist')).toBeNull();
  });

  it('findAll returns all trips ordered by scheduled_at ascending', async () => {
    const repo = new InMemoryTripRepository();
    await repo.create({ routeId: ROUTE_A, scheduledAt: new Date('2026-07-08T18:00:00Z') });
    await repo.create({ routeId: ROUTE_B, scheduledAt: new Date('2026-07-08T06:00:00Z') });
    await repo.create({ routeId: ROUTE_A, scheduledAt: new Date('2026-07-08T12:00:00Z') });

    const all = await repo.findAll();
    expect(all).toHaveLength(3);
    expect(all.map((t) => t.scheduledAt.toISOString())).toEqual([
      '2026-07-08T06:00:00.000Z',
      '2026-07-08T12:00:00.000Z',
      '2026-07-08T18:00:00.000Z',
    ]);
  });

  it('findAll filters by routeId', async () => {
    const repo = new InMemoryTripRepository();
    await repo.create({ routeId: ROUTE_A, scheduledAt: new Date('2026-07-08T06:00:00Z') });
    await repo.create({ routeId: ROUTE_A, scheduledAt: new Date('2026-07-08T07:00:00Z') });
    await repo.create({ routeId: ROUTE_B, scheduledAt: new Date('2026-07-08T08:00:00Z') });

    const onA = await repo.findAll({ routeId: ROUTE_A });
    expect(onA).toHaveLength(2);
    expect(onA.every((t) => t.routeId === ROUTE_A)).toBe(true);
  });

  it('update changes status and assignment; explicit null unassigns', async () => {
    const repo = new InMemoryTripRepository();
    const trip = await repo.create({
      routeId: ROUTE_A,
      assignedDriverId: 'drv-1',
      scheduledAt: new Date('2026-07-08T06:00:00Z'),
    });

    const activated = await repo.update(trip.id, { status: 'active', vehicleId: 'veh-1' });
    expect(activated).toMatchObject({
      status: 'active',
      vehicleId: 'veh-1',
      assignedDriverId: 'drv-1',
    });

    const unassigned = await repo.update(trip.id, { assignedDriverId: null });
    expect(unassigned?.assignedDriverId).toBeNull();
  });

  it('update returns null for an unknown id', async () => {
    const repo = new InMemoryTripRepository();
    expect(await repo.update('does-not-exist', { status: 'active' })).toBeNull();
  });
});
