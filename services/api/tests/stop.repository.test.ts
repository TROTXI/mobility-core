import { describe, expect, it } from 'vitest';
import { InMemoryStopRepository } from '../src/modules/mobility/stop.repository';

describe('InMemoryStopRepository', () => {
  it('creates a stop and finds it by id', async () => {
    const repo = new InMemoryStopRepository();
    const created = await repo.create({ name: 'Circle', latitude: 5.5502, longitude: -0.2174 });

    expect(created.id).toBeTruthy();
    expect(created.name).toBe('Circle');
    expect(created.latitude).toBe(5.5502);
    expect(created.longitude).toBe(-0.2174);

    const found = await repo.findById(created.id);
    expect(found?.name).toBe('Circle');
  });

  it('returns null for an unknown id', async () => {
    const repo = new InMemoryStopRepository();
    expect(await repo.findById('does-not-exist')).toBeNull();
  });

  it('findAll returns every stop', async () => {
    const repo = new InMemoryStopRepository();
    await repo.create({ name: 'A', latitude: 1, longitude: 2 });
    await repo.create({ name: 'B', latitude: 3, longitude: 4 });
    expect(await repo.findAll()).toHaveLength(2);
  });

  it('update changes coordinates and leaves the name unchanged', async () => {
    const repo = new InMemoryStopRepository();
    const stop = await repo.create({ name: 'Circle', latitude: 5.55, longitude: -0.21 });
    const updated = await repo.update(stop.id, { latitude: 5.65, longitude: -0.18 });
    expect(updated).toMatchObject({ name: 'Circle', latitude: 5.65, longitude: -0.18 });
  });

  it('update returns null for an unknown id', async () => {
    const repo = new InMemoryStopRepository();
    expect(await repo.update('does-not-exist', { name: 'x' })).toBeNull();
  });
});
