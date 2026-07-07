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

  it('update merges a partial patch and leaves omitted fields unchanged', async () => {
    const repo = new InMemoryRouteRepository();
    const route = await repo.create({ name: 'Old', description: 'keep me' });

    const updated = await repo.update(route.id, { name: 'New' });
    expect(updated).toMatchObject({ name: 'New', description: 'keep me' });
  });

  it('update clears a nullable field with an explicit null', async () => {
    const repo = new InMemoryRouteRepository();
    const route = await repo.create({ name: 'R', description: 'has desc' });
    const updated = await repo.update(route.id, { description: null });
    expect(updated?.description).toBeNull();
  });

  it('update returns null for an unknown id', async () => {
    const repo = new InMemoryRouteRepository();
    expect(await repo.update('does-not-exist', { name: 'x' })).toBeNull();
  });
});
