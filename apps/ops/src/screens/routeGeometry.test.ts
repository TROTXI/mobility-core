import { describe, expect, it } from 'vitest';
import { buildRouteGeometry } from './routeGeometry';

const a = { latitude: 5.6, longitude: -0.2 };
const b = { latitude: 5.61, longitude: -0.19 };
const turn = { latitude: 5.605, longitude: -0.205 };

describe('manually configured route geometry', () => {
  it('keeps waypoints in travel order and measures stop distance along the drawn path', () => {
    const geometry = buildRouteGeometry([{ location: a }, { location: b }], { 0: [turn] });
    expect(geometry.points).toEqual([a, turn, b]);
    expect(geometry.stopDistancesMeters[1]).toBeGreaterThan(2000);
  });

  it('keeps repeated stop occurrences on a loop', () => {
    const geometry = buildRouteGeometry([{ location: a }, { location: b }, { location: a }], {});
    expect(geometry.points).toEqual([a, b, a]);
    expect(geometry.stopDistancesMeters[2]).toBeGreaterThan(geometry.stopDistancesMeters[1]);
  });

  it('rejects an untraversable leg between identical consecutive stops', () => {
    expect(() => buildRouteGeometry([{ location: a }, { location: a }], {})).toThrow(
      'must be farther',
    );
  });

  it('uses WGS84 spheroid distances compatible with PostGIS geography', () => {
    const geometry = buildRouteGeometry(
      [{ location: { latitude: 0, longitude: 0 } }, { location: { latitude: 0, longitude: 1 } }],
      {},
    );
    expect(geometry.stopDistancesMeters[1]).toBeCloseTo(111_319.491, 2);
  });
});
