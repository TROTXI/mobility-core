// Turning completed runs into per-segment observed speeds (#181).
//
// Pure functions — no clock, no I/O — so the same traces always produce the
// same medians and this is testable without a database.
//
// The model: for each pair of adjacent stops, find when the vehicle passed the
// first and when it passed the second, and divide the distance between them by
// the time it took. Do that across several runs and take the median.
//
// Median rather than mean throughout. One breakdown, one driver waiting for a
// police check, one run in a downpour — a mean carries all of that into every
// future ETA, a median ignores it.

import { haversineMeters, type LatLng, type RouteStopPoint } from './eta';

/** One timestamped fix from a completed run. */
export interface TimedFix extends LatLng {
  recordedAt: Date;
}

/** One completed run: its fixes in recorded order. */
export interface TimedTrace {
  tripId: string;
  fixes: TimedFix[];
}

/** An aggregated observation, shaped for SegmentSpeedRepository.replace. */
export interface AggregatedSegment {
  fromSeq: number;
  medianSpeedMs: number;
  sampleCount: number;
}

/**
 * A speed this far outside plausible urban travel is a data problem, not
 * traffic — a GPS glitch, a stopped clock, or a bus that never actually left.
 * Observations outside the band are discarded rather than dragging a median.
 */
const MIN_PLAUSIBLE_MS = 0.5; // ~1.8 km/h — slower than walking pace
const MAX_PLAUSIBLE_MS = 33; // ~120 km/h — implausible on an Accra corridor

/**
 * The median of a list. Assumes a non-empty input.
 *
 * @param values - the numbers to reduce.
 * @returns the median value.
 */
function median(values: number[]): number {
  const sorted = [...values].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0 ? (sorted[mid - 1]! + sorted[mid]!) / 2 : sorted[mid]!;
}

/**
 * When the vehicle was closest to a stop, as a timestamp.
 *
 * Nearest-approach rather than a radius test: a radius has to be tuned per stop
 * (a kerbside stop and a terminus are not the same size) and silently returns
 * nothing when a driver passes wide.
 *
 * @param fixes - the run's fixes in order.
 * @param stop - the stop to find.
 * @returns the time of closest approach, or null when there are no fixes.
 */
function passedAt(fixes: readonly TimedFix[], stop: LatLng): Date | null {
  let best: TimedFix | null = null;
  let bestDistance = Infinity;
  for (const fix of fixes) {
    const d = haversineMeters(fix, stop);
    if (d < bestDistance) {
      bestDistance = d;
      best = fix;
    }
  }
  return best?.recordedAt ?? null;
}

/**
 * Observed speed for each segment of a route, from a set of completed runs.
 *
 * @param traces - completed runs for this route and direction.
 * @param stops - the route's stops in seq order.
 * @param minSamples - discard segments with fewer observations than this; a
 *   median of one run is noise, and the ETA falls back to the cold-start speed.
 * @returns one entry per segment that cleared the sample threshold.
 */
export function aggregateSegmentSpeeds(
  traces: readonly TimedTrace[],
  stops: readonly RouteStopPoint[],
  minSamples = 3,
): AggregatedSegment[] {
  if (stops.length < 2) return [];

  const out: AggregatedSegment[] = [];

  for (let i = 0; i < stops.length - 1; i++) {
    const from = stops[i]!;
    const to = stops[i + 1]!;
    const distance = haversineMeters(from, to);
    if (distance <= 0) continue;

    const speeds: number[] = [];
    for (const trace of traces) {
      if (trace.fixes.length < 2) continue;

      const departed = passedAt(trace.fixes, from);
      const arrived = passedAt(trace.fixes, to);
      if (!departed || !arrived) continue;

      const seconds = (arrived.getTime() - departed.getTime()) / 1000;
      // Non-positive means the bus reached the later stop first — a trace
      // recorded in the opposite direction, or fixes out of order. Either way
      // it is not an observation of this segment.
      if (seconds <= 0) continue;

      const speed = distance / seconds;
      if (speed < MIN_PLAUSIBLE_MS || speed > MAX_PLAUSIBLE_MS) continue;
      speeds.push(speed);
    }

    if (speeds.length < minSamples) continue;
    out.push({
      fromSeq: from.seq,
      medianSpeedMs: median(speeds),
      sampleCount: speeds.length,
    });
  }

  return out;
}
