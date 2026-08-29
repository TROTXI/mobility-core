// Deriving a route's shape from our own GPS traces (#179). Pure functions.
//
// A router describes where a generic vehicle could go; our traces record where
// our bus does go, including shortcuts OSM has never heard of.

import { haversineMeters, type LatLng } from './eta';

/** How a route's geometry was produced. Mirrors the DB CHECK constraint. */
export const GEOMETRY_SOURCES = ['traces', 'matched', 'manual'] as const;
export type GeometrySource = (typeof GEOMETRY_SOURCES)[number];

/** First run is used immediately; the median of five stops one diversion defining the corridor. */
export const RUNS_FOR_STABLE_GEOMETRY = 5;

/** Below this, fixes are a stationary bus jittering, not movement. */
const MIN_VERTEX_SPACING_M = 15;

/** Further than this between 5s fixes implies >250 km/h — a glitch. */
const MAX_PLAUSIBLE_JUMP_M = 350;

/** One completed run's fixes, in recorded order. */
export interface Trace {
  tripId: string;
  points: LatLng[];
}

/** A derived polyline plus the provenance we store alongside it. */
export interface DerivedGeometry {
  /** Ordered vertices of the route path. */
  points: LatLng[];
  source: GeometrySource;
  /** How many runs contributed. Written to routes.geometry_run_count. */
  runCount: number;
}

/**
 * Drop fixes that add no information: near-duplicates from a stationary bus,
 * and implausible jumps from a bad fix.
 *
 * @param points - one run's fixes in recorded order.
 * @returns the cleaned points, in order.
 */
export function cleanTrace(points: LatLng[]): LatLng[] {
  const cleaned: LatLng[] = [];
  for (const point of points) {
    const previous = cleaned[cleaned.length - 1];
    if (!previous) {
      cleaned.push(point);
      continue;
    }
    const gap = haversineMeters(previous, point);
    if (gap < MIN_VERTEX_SPACING_M) continue; // parked
    if (gap > MAX_PLAUSIBLE_JUMP_M) continue; // glitch
    cleaned.push(point);
  }
  return cleaned;
}

/**
 * Resample a trace to evenly spaced vertices along its own length.
 *
 * Runs cannot be averaged fix-by-fix — two drivers hit different traffic, so
 * their nth fix is elsewhere. Resampling by distance makes a median meaningful.
 *
 * @param points - a cleaned trace.
 * @param sampleCount - how many vertices to produce (at least 2).
 * @returns evenly spaced points, or an empty array when the trace is too short.
 */
export function resampleByDistance(points: LatLng[], sampleCount: number): LatLng[] {
  if (points.length < 2 || sampleCount < 2) return [];

  const cumulative: number[] = [0];
  for (let i = 0; i < points.length - 1; i++) {
    cumulative.push(cumulative[i]! + haversineMeters(points[i]!, points[i + 1]!));
  }
  const total = cumulative[cumulative.length - 1]!;
  if (total === 0) return [];

  const samples: LatLng[] = [];
  for (let s = 0; s < sampleCount; s++) {
    const target = (total * s) / (sampleCount - 1);

    let seg = 0;
    while (seg < cumulative.length - 2 && cumulative[seg + 1]! < target) seg++;

    const segStart = cumulative[seg]!;
    const segLen = cumulative[seg + 1]! - segStart;
    const t = segLen === 0 ? 0 : (target - segStart) / segLen;
    const a = points[seg]!;
    const b = points[seg + 1]!;
    samples.push({
      latitude: a.latitude + (b.latitude - a.latitude) * t,
      longitude: a.longitude + (b.longitude - a.longitude) * t,
    });
  }
  return samples;
}

/**
 * Element-wise median of equal-length resampled traces.
 *
 * Median, not mean: one wrong turn should not bend the corridor.
 *
 * @param traces - resampled traces, all of the same length.
 * @returns the median path.
 */
function medianPath(traces: LatLng[][]): LatLng[] {
  const length = traces[0]?.length ?? 0;
  const median = (values: number[]): number => {
    const sorted = [...values].sort((a, b) => a - b);
    const mid = Math.floor(sorted.length / 2);
    return sorted.length % 2 === 0 ? (sorted[mid - 1]! + sorted[mid]!) / 2 : sorted[mid]!;
  };

  const out: LatLng[] = [];
  for (let i = 0; i < length; i++) {
    out.push({
      latitude: median(traces.map((t) => t[i]!.latitude)),
      longitude: median(traces.map((t) => t[i]!.longitude)),
    });
  }
  return out;
}

/**
 * Derive a route's geometry from completed runs.
 *
 * One run is used as-is so a corridor becomes usable the day it first runs.
 * Once several exist, the median supersedes it and diversions stop counting.
 *
 * @param traces - completed runs, newest first; only the most recent
 *   {@link RUNS_FOR_STABLE_GEOMETRY} are considered.
 * @param sampleCount - vertices in the output path.
 * @returns the derived geometry, or null when no run carries enough signal.
 */
export function deriveRouteGeometry(traces: Trace[], sampleCount = 200): DerivedGeometry | null {
  const usable = traces
    .slice(0, RUNS_FOR_STABLE_GEOMETRY)
    .map((trace) => resampleByDistance(cleanTrace(trace.points), sampleCount))
    .filter((path) => path.length === sampleCount);

  if (usable.length === 0) return null;

  return {
    points: usable.length === 1 ? usable[0]! : medianPath(usable),
    source: 'traces',
    runCount: usable.length,
  };
}

/**
 * Distance along a derived path to each stop, for `route_stops.distance_m`.
 *
 * Nearest-vertex projection: stops sit metres from the road, so it is accurate
 * enough and simpler than projecting onto every segment.
 *
 * @param path - the derived route path.
 * @param stops - the route's stops in seq order.
 * @returns metres along the path for each stop, in the same order.
 */
export function stopDistancesAlong(path: LatLng[], stops: LatLng[]): number[] {
  const cumulative: number[] = [0];
  for (let i = 0; i < path.length - 1; i++) {
    cumulative.push(cumulative[i]! + haversineMeters(path[i]!, path[i + 1]!));
  }

  return stops.map((stop) => {
    let best = 0;
    let bestDistance = Infinity;
    for (let i = 0; i < path.length; i++) {
      const d = haversineMeters(stop, path[i]!);
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    return cumulative[best]!;
  });
}
