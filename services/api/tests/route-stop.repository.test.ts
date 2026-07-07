import { describe, expect, it } from 'vitest';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';

describe('InMemoryRouteStopRepository', () => {
  it('creates route stops and finds them ordered by seq', async () => {
    const repo = new InMemoryRouteStopRepository();
    await repo.create({ routeId: 'route-1', stopId: 'stop-b', seq: 2 });
    await repo.create({ routeId: 'route-1', stopId: 'stop-a', seq: 1 });

    const stops = await repo.findByRoute('route-1');
    expect(stops).toHaveLength(2);
    expect(stops[0]!.stopId).toBe('stop-a');
    expect(stops[1]!.stopId).toBe('stop-b');
  });

  it('returns empty array for an unknown route', async () => {
    const repo = new InMemoryRouteStopRepository();
    expect(await repo.findByRoute('does-not-exist')).toEqual([]);
  });

  it('only returns stops for the requested route', async () => {
    const repo = new InMemoryRouteStopRepository();
    await repo.create({ routeId: 'route-1', stopId: 'stop-1', seq: 1 });
    await repo.create({ routeId: 'route-2', stopId: 'stop-2', seq: 1 });

    const stops = await repo.findByRoute('route-1');
    expect(stops).toHaveLength(1);
    expect(stops[0]!.stopId).toBe('stop-1');
  });
});
