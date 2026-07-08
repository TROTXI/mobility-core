import { describe, expect, it } from 'vitest';
import {
  ASSUMED_SPEED_KPH,
  computeEtas,
  haversineMeters,
  type RouteStopPoint,
} from '../src/modules/mobility/eta';

// A straight south→north route along the prime meridian. One degree of latitude
// is ~111.2 km, so each 0.01° hop between adjacent stops is ~1112 m — round,
// easy-to-reason-about distances for asserting deterministic ETAs.
const METRES_PER_HOP = 1112; // ~ 6371000 * 0.01 * pi/180
const stopAt = (seq: number, latitude: number): RouteStopPoint => ({
  stopId: `00000000-0000-0000-0000-00000000000${seq}`,
  name: `Stop ${seq}`,
  seq,
  latitude,
  longitude: 0,
});
const ROUTE: RouteStopPoint[] = [stopAt(1, 0), stopAt(2, 0.01), stopAt(3, 0.02), stopAt(4, 0.03)];

// Expected ETA seconds for a given remaining distance at the assumed speed.
const etaFor = (metres: number): number => Math.round(metres / ((ASSUMED_SPEED_KPH * 1000) / 3600));

describe('haversineMeters', () => {
  it('is zero for the same point', () => {
    expect(
      haversineMeters({ latitude: 5.6, longitude: -0.2 }, { latitude: 5.6, longitude: -0.2 }),
    ).toBe(0);
  });

  it('measures ~111.2 km for one degree of latitude', () => {
    const d = haversineMeters({ latitude: 0, longitude: 0 }, { latitude: 1, longitude: 0 });
    expect(d).toBeGreaterThan(111_000);
    expect(d).toBeLessThan(111_400);
  });

  it('measures ~111.2 km for one degree of longitude at the equator', () => {
    const d = haversineMeters({ latitude: 0, longitude: 0 }, { latitude: 0, longitude: 1 });
    expect(d).toBeGreaterThan(111_000);
    expect(d).toBeLessThan(111_400);
  });
});

describe('computeEtas', () => {
  it('returns no ETAs for fewer than two stops', () => {
    expect(computeEtas({ latitude: 0, longitude: 0 }, [])).toEqual([]);
    expect(computeEtas({ latitude: 0, longitude: 0 }, [stopAt(1, 0)])).toEqual([]);
  });

  it('at the first stop, lists every stop ahead with increasing distance + ETA', () => {
    const etas = computeEtas({ latitude: 0, longitude: 0 }, ROUTE);
    expect(etas.map((e) => e.seq)).toEqual([2, 3, 4]); // stop 1 (current) excluded

    expect(etas[0]!.distanceMeters).toBeCloseTo(METRES_PER_HOP, -1);
    expect(etas[1]!.distanceMeters).toBeCloseTo(2 * METRES_PER_HOP, -1);
    expect(etas[2]!.distanceMeters).toBeCloseTo(3 * METRES_PER_HOP, -1);

    // Strictly increasing distance and ETA, and ETA tracks distance/speed.
    expect(etas[0]!.distanceMeters).toBeLessThan(etas[1]!.distanceMeters);
    expect(etas[1]!.distanceMeters).toBeLessThan(etas[2]!.distanceMeters);
    expect(etas[0]!.etaSeconds).toBe(etaFor(etas[0]!.distanceMeters));
  });

  it('projects a mid-segment position onto the route (distance measured from the projection)', () => {
    // Halfway between stop 1 and stop 2.
    const etas = computeEtas({ latitude: 0.005, longitude: 0 }, ROUTE);
    expect(etas.map((e) => e.seq)).toEqual([2, 3, 4]);
    expect(etas[0]!.distanceMeters).toBeCloseTo(METRES_PER_HOP / 2, -1);
  });

  it('drops stops already passed', () => {
    // Just past stop 3 (lat 0.02) → only stop 4 remains ahead.
    const etas = computeEtas({ latitude: 0.021, longitude: 0 }, ROUTE);
    expect(etas.map((e) => e.seq)).toEqual([4]);
  });

  it('returns no ETAs once past the last stop', () => {
    expect(computeEtas({ latitude: 0.05, longitude: 0 }, ROUTE)).toEqual([]);
  });

  it('still counts the first stop as upcoming when the vehicle is before the route start', () => {
    const etas = computeEtas({ latitude: -0.005, longitude: 0 }, ROUTE);
    expect(etas.map((e) => e.seq)).toEqual([1, 2, 3, 4]);
    expect(etas[0]!.distanceMeters).toBeCloseTo(METRES_PER_HOP / 2, -1);
  });

  it('ignores perpendicular (off-route) offset — only along-route distance counts', () => {
    // Same along-route position as the mid-segment case, but offset ~1 km east.
    const onRoute = computeEtas({ latitude: 0.005, longitude: 0 }, ROUTE);
    const offRoute = computeEtas({ latitude: 0.005, longitude: 0.01 }, ROUTE);
    expect(offRoute.map((e) => e.seq)).toEqual([2, 3, 4]);
    expect(offRoute[0]!.distanceMeters).toBeCloseTo(onRoute[0]!.distanceMeters, -1);
  });
});
