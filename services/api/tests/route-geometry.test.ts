import { describe, expect, it } from 'vitest';
import {
  cleanTrace,
  deriveRouteGeometry,
  resampleByDistance,
  stopDistancesAlong,
  type Trace,
} from '../src/modules/mobility/route-geometry';
import { haversineMeters, type LatLng } from '../src/modules/mobility/eta';

/** A straight west-to-east run through Accra, one fix roughly every 40 m. */
function straightRun(count: number, jitter = 0): LatLng[] {
  const points: LatLng[] = [];
  for (let i = 0; i < count; i++) {
    points.push({
      latitude: 5.6 + (i % 2 === 0 ? jitter : -jitter),
      longitude: -0.19 + i * 0.0004,
    });
  }
  return points;
}

describe('cleanTrace', () => {
  it('drops near-duplicate fixes from a stationary bus', () => {
    const parked: LatLng[] = Array.from({ length: 10 }, () => ({
      latitude: 5.6,
      longitude: -0.19,
    }));
    // Ten fixes at one spot describe a bus at a stop, not a route.
    expect(cleanTrace(parked)).toHaveLength(1);
  });

  it('drops implausible jumps rather than bending the route through them', () => {
    const withGlitch: LatLng[] = [
      { latitude: 5.6, longitude: -0.19 },
      { latitude: 5.6, longitude: -0.1894 }, // ~66 m, real movement
      { latitude: 9.4, longitude: -0.85 }, // Tamale — a bad fix
      { latitude: 5.6, longitude: -0.1888 },
    ];
    const cleaned = cleanTrace(withGlitch);
    expect(cleaned).toHaveLength(3);
    expect(cleaned.some((p) => p.latitude > 6)).toBe(false);
  });
});

describe('resampleByDistance', () => {
  it('produces the requested number of evenly spaced vertices', () => {
    const sampled = resampleByDistance(straightRun(50), 10);
    expect(sampled).toHaveLength(10);

    const gaps: number[] = [];
    for (let i = 0; i < sampled.length - 1; i++) {
      gaps.push(haversineMeters(sampled[i]!, sampled[i + 1]!));
    }
    const mean = gaps.reduce((a, b) => a + b, 0) / gaps.length;
    for (const gap of gaps) expect(Math.abs(gap - mean)).toBeLessThan(1);
  });

  it('returns nothing for a trace with no length', () => {
    expect(resampleByDistance([{ latitude: 5.6, longitude: -0.19 }], 10)).toEqual([]);
    expect(resampleByDistance([], 10)).toEqual([]);
  });
});

describe('deriveRouteGeometry', () => {
  it('uses a single run immediately, so a new corridor is usable on day one', () => {
    const result = deriveRouteGeometry([{ tripId: 't1', points: straightRun(40) }], 20);
    expect(result).not.toBeNull();
    expect(result!.runCount).toBe(1);
    expect(result!.source).toBe('traces');
    expect(result!.points).toHaveLength(20);
  });

  it('takes the median so one wrong turn does not redefine the corridor', () => {
    const normal = (): LatLng[] => straightRun(40);
    // One driver detours a long way north for the middle of the run.
    const detour = straightRun(40).map((p, i) =>
      i > 15 && i < 25 ? { ...p, latitude: p.latitude + 0.02 } : p,
    );
    const traces: Trace[] = [
      { tripId: 'a', points: normal() },
      { tripId: 'b', points: normal() },
      { tripId: 'c', points: detour },
      { tripId: 'd', points: normal() },
      { tripId: 'e', points: normal() },
    ];

    const result = deriveRouteGeometry(traces, 40)!;
    expect(result.runCount).toBe(5);
    // The detour reached +0.02 lat; the median should stay on the normal line.
    const maxLat = Math.max(...result.points.map((p) => p.latitude));
    expect(maxLat).toBeLessThan(5.605);
  });

  it('considers only the five most recent runs', () => {
    const traces: Trace[] = Array.from({ length: 9 }, (_, i) => ({
      tripId: `t${i}`,
      points: straightRun(40),
    }));
    expect(deriveRouteGeometry(traces, 20)!.runCount).toBe(5);
  });

  it('returns null when no run carries enough signal', () => {
    // A bus that never moved leaves one vertex after cleaning — no geometry.
    const parked: LatLng[] = Array.from({ length: 20 }, () => ({
      latitude: 5.6,
      longitude: -0.19,
    }));
    expect(deriveRouteGeometry([{ tripId: 't', points: parked }], 20)).toBeNull();
    expect(deriveRouteGeometry([], 20)).toBeNull();
  });
});

describe('stopDistancesAlong', () => {
  it('reports increasing distance for stops in route order', () => {
    const path = straightRun(40);
    const stops = [path[0]!, path[13]!, path[26]!, path[39]!];
    const distances = stopDistancesAlong(path, stops);

    expect(distances[0]).toBe(0);
    for (let i = 0; i < distances.length - 1; i++) {
      expect(distances[i + 1]!).toBeGreaterThan(distances[i]!);
    }
  });
});
