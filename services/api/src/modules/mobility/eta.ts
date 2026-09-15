// Deterministic ETA-to-stop (#25, system-design §7). Pure functions — no clock,
// no I/O, no routing vendor — so the same inputs always yield the same ETAs.
//
// The route's stops form a polyline. Project the vehicle's latest fix onto it to
// get distance travelled, then for each stop ahead:
// remaining = cumulative(stop) − travelled, ETA = remaining / segment speed.

/**
 * Cold-start speed, used for any segment we have not observed yet (urban trotro
 * ~20 km/h). Every segment starts here and is superseded by its own measured
 * median as runs accumulate (#181) — so a brand-new corridor still produces an
 * ETA on day one, and gets more accurate without anyone doing anything.
 */
export const ASSUMED_SPEED_KPH = 20;
const ASSUMED_SPEED_MS = (ASSUMED_SPEED_KPH * 1000) / 3600;

const EARTH_RADIUS_M = 6_371_000;
/** Tolerance (metres) below which a stop counts as "reached", not upcoming. */
const REACHED_EPS_M = 1e-6;

const toRad = (deg: number): number => (deg * Math.PI) / 180;

/** A geographic point. */
export interface LatLng {
  latitude: number;
  longitude: number;
}

/** A stop placed on a route, in seq order, with its coordinates. */
export interface RouteStopPoint extends LatLng {
  stopId: string;
  name: string;
  seq: number;
}

/**
 * Observed median speed for one segment of a route, from completed runs.
 * Keyed by the seq of the segment's FIRST stop: `fromSeq` 0 is the stretch
 * between stop 0 and stop 1.
 */
export interface SegmentSpeed {
  fromSeq: number;
  metresPerSecond: number;
  /** How many runs the median came from; low counts are ignored (see below). */
  sampleCount: number;
}

/** Learned road-following path and the distance of each stop along it. */
export interface EtaRouteGeometry {
  points: readonly LatLng[];
  stopDistances: ReadonlyMap<number, number>;
}

/**
 * Below this many observations a median is noise, not signal — one unusual run
 * would swing the ETA. Segments under it keep the cold-start speed.
 */
export const MIN_SAMPLES_FOR_OBSERVED_SPEED = 3;

/** A stop still ahead of the vehicle, with distance + ETA along the route. */
export interface StopEta {
  stopId: string;
  seq: number;
  name: string;
  /** Remaining distance along the route to this stop, in metres. */
  distanceMeters: number;
  /** ETA to this stop in seconds, at the assumed speed. */
  etaSeconds: number;
}

/**
 * Great-circle distance between two points in metres (haversine).
 *
 * @param a - the first point.
 * @param b - the second point.
 * @returns the distance between them in metres.
 */
export function haversineMeters(a: LatLng, b: LatLng): number {
  const dLat = toRad(b.latitude - a.latitude);
  const dLng = toRad(b.longitude - a.longitude);
  const lat1 = toRad(a.latitude);
  const lat2 = toRad(b.latitude);
  const h = Math.sin(dLat / 2) ** 2 + Math.sin(dLng / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
  return 2 * EARTH_RADIUS_M * Math.asin(Math.min(1, Math.sqrt(h)));
}

/**
 * Local planar (equirectangular) coordinates of `p` in metres. Good enough for
 * the short segments between adjacent stops — used only to pick the nearest
 * segment and its projection fraction, never for reported distances.
 *
 * @param p - the point to project.
 * @param cosLatRef - cosine of the reference latitude that anchors the projection.
 * @returns the planar `{ x, y }` in metres.
 */
function toPlane(p: LatLng, cosLatRef: number): { x: number; y: number } {
  return {
    x: EARTH_RADIUS_M * toRad(p.longitude) * cosLatRef,
    y: EARTH_RADIUS_M * toRad(p.latitude),
  };
}

/**
 * Deterministic ETA from the vehicle's position to every upcoming stop.
 *
 * @param position - the vehicle's latest fix.
 * @param stops - the route's stops in seq order (as returned by the route-stop repo).
 * @param speeds - observed median speeds by starting stop seq (#181). Omit, or leave
 *   a segment out, to charge that stretch the cold-start speed.
 * @param geometry - learned road-following path. Falls back to stop chords until learned.
 * @returns upcoming stops in order, each with remaining distance + ETA seconds.
 *   Empty when there are fewer than two stops or the vehicle is past the last stop.
 */
export function computeEtas(
  position: LatLng,
  stops: RouteStopPoint[],
  speeds?: Map<number, SegmentSpeed>,
  geometry?: EtaRouteGeometry,
): StopEta[] {
  // Need at least one segment to define "progress along the route".
  if (stops.length < 2) return [];

  const usesLearnedGeometry = Boolean(geometry && geometry.points.length >= 2);
  const path: readonly LatLng[] = usesLearnedGeometry ? geometry!.points : stops;
  const pathMetrics = cumulativeDistances(path);

  // The vehicle is projected onto the learned path when it exists. Before the
  // first and after the last point we preserve extrapolation: riders can see an
  // approaching vehicle and a finished route has no upcoming stops.
  const travelled = distanceAlongPath(position, path, pathMetrics, true);

  // Route learning persists authoritative stop distances. If an older learned
  // row has none, derive them from the same path rather than reverting ETA to
  // straight stop chords. Enforce monotonicity defensively for loop-like roads.
  const storedDistances = usesLearnedGeometry
    ? stops.map((stop) => geometry!.stopDistances.get(stop.seq))
    : [];
  const hasAllStoredDistances =
    storedDistances.length === stops.length &&
    storedDistances.every((distance) => distance !== undefined && Number.isFinite(distance));
  const stopDistances = hasAllStoredDistances
    ? (storedDistances as number[])
    : usesLearnedGeometry
      ? stops.map((stop) => distanceAlongPath(stop, path, pathMetrics, false))
      : cumulativeDistances(stops).cumulative;
  for (let index = 1; index < stopDistances.length; index++) {
    stopDistances[index] = Math.max(stopDistances[index]!, stopDistances[index - 1]!);
  }

  // Speed per segment: the observed median where we have enough runs, the
  // cold-start constant everywhere else. Building the lookup once keeps the
  // per-stop loop linear.
  const speedForSegment = (index: number): number => {
    const observed = speeds?.get(stops[index]!.seq);
    if (observed && observed.sampleCount >= MIN_SAMPLES_FOR_OBSERVED_SPEED) {
      return observed.metresPerSecond;
    }
    return ASSUMED_SPEED_MS;
  };

  const etas: StopEta[] = [];
  for (let j = 0; j < stops.length; j++) {
    const targetDistance = stopDistances[j]!;
    const remaining = targetDistance - travelled;
    if (remaining <= REACHED_EPS_M) continue; // reached or behind → not upcoming

    // Walk the segments between the vehicle and this stop, charging each its own
    // speed. Summing per segment rather than dividing the total distance by one
    // number is the whole point: a run is fast on the highway and slow through
    // the junction, and an average of the two is wrong for both.
    let seconds = 0;
    let cursor = travelled;

    // Approach to the first stop uses the first route segment's speed.
    if (cursor < stopDistances[0]!) {
      const approachEnd = Math.min(targetDistance, stopDistances[0]!);
      seconds += (approachEnd - cursor) / speedForSegment(0);
      cursor = approachEnd;
    }

    for (let seg = 0; seg < j; seg++) {
      const segmentStart = stopDistances[seg]!;
      const segmentEnd = stopDistances[seg + 1]!;
      const overlapStart = Math.max(cursor, segmentStart);
      const overlapEnd = Math.min(targetDistance, segmentEnd);
      if (overlapEnd <= overlapStart) continue;
      seconds += (overlapEnd - overlapStart) / speedForSegment(seg);
    }

    etas.push({
      stopId: stops[j]!.stopId,
      seq: stops[j]!.seq,
      name: stops[j]!.name,
      distanceMeters: Math.round(remaining),
      etaSeconds: Math.round(seconds),
    });
  }
  return etas;
}

/**
 * Segment lengths and cumulative distances for a polyline.
 *
 * @param path - ordered points in the route path.
 * @returns each segment length and the cumulative distance at every point.
 */
function cumulativeDistances(path: readonly LatLng[]): {
  segmentLengths: number[];
  cumulative: number[];
} {
  const segmentLengths: number[] = [];
  const cumulative = [0];
  for (let index = 0; index < path.length - 1; index++) {
    const length = haversineMeters(path[index]!, path[index + 1]!);
    segmentLengths.push(length);
    cumulative.push(cumulative[index]! + length);
  }
  return { segmentLengths, cumulative };
}

/**
 * Project a point onto a path and return metres travelled along that path.
 *
 * @param point - vehicle or stop to project.
 * @param path - ordered route path.
 * @param metrics - precomputed lengths for the path.
 * @param extendEndpoints - whether positions beyond the first/last point extrapolate.
 * @returns metres from the path origin to the projection.
 */
function distanceAlongPath(
  point: LatLng,
  path: readonly LatLng[],
  metrics: ReturnType<typeof cumulativeDistances>,
  extendEndpoints: boolean,
): number {
  const cosLatRef = Math.cos(toRad(point.latitude));
  const p = toPlane(point, cosLatRef);
  let bestSegment = 0;
  let bestRawFraction = 0;
  let bestDistance = Infinity;

  for (let index = 0; index < metrics.segmentLengths.length; index++) {
    const a = toPlane(path[index]!, cosLatRef);
    const b = toPlane(path[index + 1]!, cosLatRef);
    const abx = b.x - a.x;
    const aby = b.y - a.y;
    const lengthSquared = abx * abx + aby * aby;
    const rawFraction =
      lengthSquared === 0 ? 0 : ((p.x - a.x) * abx + (p.y - a.y) * aby) / lengthSquared;
    const fraction = Math.max(0, Math.min(1, rawFraction));
    const distance = Math.hypot(p.x - (a.x + fraction * abx), p.y - (a.y + fraction * aby));
    if (distance < bestDistance) {
      bestDistance = distance;
      bestSegment = index;
      bestRawFraction = rawFraction;
    }
  }

  let effectiveFraction = Math.max(0, Math.min(1, bestRawFraction));
  if (extendEndpoints && bestSegment === 0 && bestRawFraction < 0) {
    effectiveFraction = bestRawFraction;
  }
  if (extendEndpoints && bestSegment === metrics.segmentLengths.length - 1 && bestRawFraction > 1) {
    effectiveFraction = bestRawFraction;
  }
  return (
    metrics.cumulative[bestSegment]! + effectiveFraction * metrics.segmentLengths[bestSegment]!
  );
}
