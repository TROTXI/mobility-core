import { describe, expect, it } from 'vitest';
import { InMemoryRouteRepository } from '../src/modules/mobility/route.repository';

describe('InMemoryRouteRepository', () => {
  it('creates a route and finds it by id', async () => {
    const repo = new InMemoryRouteRepository();
    const created = await repo.create({ name: 'Circle to Legon', description: 'Main route' });

    expect(created.id).toBeTruthy();
    expect(created.name).toBe('Circle to Legon');
    expect(created.description).toBe('Main route');

    const found = await repo.findById(created.id);
    expect(found?.name).toBe('Circle to Legon');
  });

  it('defaults description to null', async () => {
    const repo = new InMemoryRouteRepository();
    const created = await repo.create({ name: 'Circle to Legon' });
    expect(created.description).toBeNull();
  });

  it('returns all routes', async () => {
    const repo = new InMemoryRouteRepository();
    await repo.create({ name: 'Route A' });
    await repo.create({ name: 'Route B' });

    const all = await repo.findAll();
    expect(all).toHaveLength(2);
  });

  it('returns null for an unknown id', async () => {
    const repo = new InMemoryRouteRepository();
    expect(await repo.findById('does-not-exist')).toBeNull();
  });
});
