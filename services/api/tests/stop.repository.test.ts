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
});
