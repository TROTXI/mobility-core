import { describe, expect, it } from 'vitest';
import {
  ASSUMED_SPEED_KPH,
  computeEtas,
  MIN_SAMPLES_FOR_OBSERVED_SPEED,
  type RouteStopPoint,
  type SegmentSpeed,
} from '../src/modules/mobility/eta';

/** Four stops on a straight east-west line, roughly 1 km apart. */
const STOPS: RouteStopPoint[] = [
  { stopId: 's0', name: 'Madina', seq: 0, latitude: 5.6, longitude: -0.19 },
  { stopId: 's1', name: 'Shiashie', seq: 1, latitude: 5.6, longitude: -0.181 },
  { stopId: 's2', name: '37 Station', seq: 2, latitude: 5.6, longitude: -0.172 },
  { stopId: 's3', name: 'Circle', seq: 3, latitude: 5.6, longitude: -0.163 },
];

const AT_START = { latitude: 5.6, longitude: -0.19 };

describe('computeEtas with observed segment speeds (#181)', () => {
  it('falls back to the cold-start speed when nothing has been observed', () => {
    // A brand-new corridor still produces an ETA on day one.
    const withoutSpeeds = computeEtas(AT_START, STOPS);
    const withEmptySpeeds = computeEtas(AT_START, STOPS, new Map());
    expect(withEmptySpeeds).toEqual(withoutSpeeds);
    expect(withoutSpeeds.length).toBe(3);
  });

  it('uses an observed median where one exists, in place of the constant', () => {
    const assumedMs = (ASSUMED_SPEED_KPH * 1000) / 3600;
    // First segment observed at half the assumed speed: rush-hour crawl.
    const speeds = new Map<number, SegmentSpeed>([
      [0, { fromSeq: 0, metresPerSecond: assumedMs / 2, sampleCount: 10 }],
    ]);

    const baseline = computeEtas(AT_START, STOPS)[0]!;
    const observed = computeEtas(AT_START, STOPS, speeds)[0]!;

    expect(observed.distanceMeters).toBe(baseline.distanceMeters); // distance unchanged
    expect(observed.etaSeconds).toBeGreaterThan(baseline.etaSeconds * 1.9);
  });

  it('ignores a median built from too few runs', () => {
    const speeds = new Map<number, SegmentSpeed>([
      [
        0,
        {
          fromSeq: 0,
          metresPerSecond: 0.5, // absurdly slow, would blow up the ETA
          sampleCount: MIN_SAMPLES_FOR_OBSERVED_SPEED - 1,
        },
      ],
    ]);
    // One unusual run must not swing a rider's ETA.
    expect(computeEtas(AT_START, STOPS, speeds)).toEqual(computeEtas(AT_START, STOPS));
  });

  it('charges each segment its own speed rather than averaging the whole trip', () => {
    const assumedMs = (ASSUMED_SPEED_KPH * 1000) / 3600;
    // Slow first leg, fast second: the far stop must reflect both, not a blend
    // applied uniformly across the distance.
    const speeds = new Map<number, SegmentSpeed>([
      [0, { fromSeq: 0, metresPerSecond: assumedMs / 4, sampleCount: 8 }],
      [1, { fromSeq: 1, metresPerSecond: assumedMs * 2, sampleCount: 8 }],
    ]);

    const etas = computeEtas(AT_START, STOPS, speeds);
    const [first, second] = [etas[0]!, etas[1]!];

    // Leg one takes 4x as long as baseline; leg two takes half. The second stop
    // is therefore only a little later than the first, despite being 2x further.
    const legOne = first.etaSeconds;
    const legTwo = second.etaSeconds - first.etaSeconds;
    expect(legTwo).toBeLessThan(legOne / 4);
  });

  it('keeps ETAs monotonically increasing along the route', () => {
    const assumedMs = (ASSUMED_SPEED_KPH * 1000) / 3600;
    const speeds = new Map<number, SegmentSpeed>([
      [0, { fromSeq: 0, metresPerSecond: assumedMs * 3, sampleCount: 5 }],
      [1, { fromSeq: 1, metresPerSecond: assumedMs / 3, sampleCount: 5 }],
      [2, { fromSeq: 2, metresPerSecond: assumedMs, sampleCount: 5 }],
    ]);
    const etas = computeEtas(AT_START, STOPS, speeds);
    for (let i = 0; i < etas.length - 1; i++) {
      expect(etas[i + 1]!.etaSeconds).toBeGreaterThan(etas[i]!.etaSeconds);
    }
  });
});
