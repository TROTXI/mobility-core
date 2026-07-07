import { describe, expect, it } from 'vitest';
import { InMemoryVehicleRepository } from '../src/modules/mobility/vehicle.repository';

describe('InMemoryVehicleRepository', () => {
  it('creates a vehicle and finds it by id', async () => {
    const repo = new InMemoryVehicleRepository();
    const created = await repo.create({
      registration: 'GR-1234-24',
      label: 'Yutong #7',
      capacity: 33,
    });

    expect(created.id).toBeTruthy();
    expect(created.registration).toBe('GR-1234-24');
    expect(created.label).toBe('Yutong #7');
    expect(created.capacity).toBe(33);

    const found = await repo.findById(created.id);
    expect(found?.registration).toBe('GR-1234-24');
  });

  it('defaults label to null and capacity to 0', async () => {
    const repo = new InMemoryVehicleRepository();
    const created = await repo.create({ registration: 'GT-9999-24' });
    expect(created.label).toBeNull();
    expect(created.capacity).toBe(0);
  });

  it('returns null for an unknown id', async () => {
    const repo = new InMemoryVehicleRepository();
    expect(await repo.findById('does-not-exist')).toBeNull();
  });

  it('findAll returns every vehicle', async () => {
    const repo = new InMemoryVehicleRepository();
    await repo.create({ registration: 'GR-1' });
    await repo.create({ registration: 'GR-2' });
    expect(await repo.findAll()).toHaveLength(2);
  });

  it('update merges a partial patch', async () => {
    const repo = new InMemoryVehicleRepository();
    const vehicle = await repo.create({ registration: 'GR-1', label: 'Bus 7', capacity: 33 });
    const updated = await repo.update(vehicle.id, { capacity: 40 });
    expect(updated).toMatchObject({ registration: 'GR-1', label: 'Bus 7', capacity: 40 });
  });

  it('update returns null for an unknown id', async () => {
    const repo = new InMemoryVehicleRepository();
    expect(await repo.update('does-not-exist', { capacity: 1 })).toBeNull();
  });
});
