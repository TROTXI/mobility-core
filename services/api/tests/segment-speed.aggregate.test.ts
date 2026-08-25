import { describe, expect, it } from 'vitest';
import {
  aggregateSegmentSpeeds,
  type TimedTrace,
} from '../src/modules/mobility/segment-speed.aggregate';
import { haversineMeters, type RouteStopPoint } from '../src/modules/mobility/eta';

/** Three stops on a straight line, roughly 1 km apart. */
const STOPS: RouteStopPoint[] = [
  { stopId: 's0', name: 'Madina', seq: 0, latitude: 5.6, longitude: -0.19 },
  { stopId: 's1', name: 'Shiashie', seq: 1, latitude: 5.6, longitude: -0.181 },
  { stopId: 's2', name: '37 Station', seq: 2, latitude: 5.6, longitude: -0.172 },
];

const SEG_LEN = haversineMeters(STOPS[0]!, STOPS[1]!);

/**
 * A run passing each stop at a given number of seconds from the start.
 * One fix per stop is enough — the aggregator finds nearest approach.
 */
function run(tripId: string, secondsAtStop: number[]): TimedTrace {
  const t0 = Date.parse('2026-08-24T07:00:00Z');
  return {
    tripId,
    fixes: STOPS.map((s, i) => ({
      latitude: s.latitude,
      longitude: s.longitude,
      recordedAt: new Date(t0 + secondsAtStop[i]! * 1000),
    })),
  };
}

describe('aggregateSegmentSpeeds', () => {
  it('derives speed from how long the bus actually took between stops', () => {
    // 200s to cover ~1km => ~5 m/s
    const traces = [run('a', [0, 200, 400]), run('b', [0, 200, 400]), run('c', [0, 200, 400])];
    const out = aggregateSegmentSpeeds(traces, STOPS);

    expect(out).toHaveLength(2);
    expect(out[0]!.fromSeq).toBe(0);
    expect(out[0]!.sampleCount).toBe(3);
    expect(out[0]!.medianSpeedMs).toBeCloseTo(SEG_LEN / 200, 2);
  });

  it('takes the median so one breakdown does not redefine the corridor', () => {
    // Four normal runs and one that took ten times as long.
    const traces = [
      run('a', [0, 200, 400]),
      run('b', [0, 200, 400]),
      run('c', [0, 2000, 4000]), // stuck
      run('d', [0, 200, 400]),
      run('e', [0, 200, 400]),
    ];
    const out = aggregateSegmentSpeeds(traces, STOPS);
    // A mean would be dragged well below the normal speed; the median holds.
    expect(out[0]!.medianSpeedMs).toBeCloseTo(SEG_LEN / 200, 2);
  });

  it('ignores segments with too few observations', () => {
    // Two runs, threshold of three: a median of two is noise, and the ETA
    // should keep the cold-start speed rather than trust it.
    const out = aggregateSegmentSpeeds([run('a', [0, 200, 400]), run('b', [0, 200, 400])], STOPS);
    expect(out).toHaveLength(0);
  });

  it('discards implausible speeds rather than letting them skew a median', () => {
    // 1 km in 2 seconds is ~500 m/s — a GPS glitch or a stopped clock.
    const traces = [
      run('a', [0, 200, 400]),
      run('b', [0, 200, 400]),
      run('c', [0, 2, 4]),
      run('d', [0, 200, 400]),
    ];
    const out = aggregateSegmentSpeeds(traces, STOPS);
    expect(out[0]!.sampleCount).toBe(3); // the glitch was dropped
    expect(out[0]!.medianSpeedMs).toBeCloseTo(SEG_LEN / 200, 2);
  });

  it('skips a run recorded in the opposite direction', () => {
    // Reaching the later stop first means negative elapsed time — not an
    // observation of this segment.
    const backwards = run('rev', [400, 200, 0]);
    const out = aggregateSegmentSpeeds(
      [run('a', [0, 200, 400]), run('b', [0, 200, 400]), run('c', [0, 200, 400]), backwards],
      STOPS,
    );
    expect(out[0]!.sampleCount).toBe(3);
  });

  it('returns nothing for a route with fewer than two stops', () => {
    expect(aggregateSegmentSpeeds([run('a', [0])], [STOPS[0]!])).toEqual([]);
  });
});
