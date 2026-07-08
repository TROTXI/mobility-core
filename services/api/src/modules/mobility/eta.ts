// Deterministic ETA-to-stop (#25, system-design §7). Pure functions — no clock,
// no I/O, no external routing/traffic service — so the same inputs always yield
// the same ETAs and the whole thing is trivially unit-testable.
//
// Model: the route's ordered stops form a polyline. We project the vehicle's
// latest fix onto that polyline to get "distance travelled along the route", then
// for every stop still ahead, remaining distance = cumulative(stop) − travelled,
// and ETA = remaining / a fixed assumed speed. The assumed speed is a pilot
// placeholder; a live speed/traffic model arrives with the telemetry path (ADR-0006).

/** Assumed average vehicle speed for the pilot ETA (urban trotro ~20 km/h). */
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
 * @returns upcoming stops in order, each with remaining distance + ETA seconds.
 *   Empty when there are fewer than two stops or the vehicle is past the last stop.
 */
export function computeEtas(position: LatLng, stops: RouteStopPoint[]): StopEta[] {
  // Need at least one segment to define "progress along the route".
  if (stops.length < 2) return [];

  // Cumulative haversine distance to each stop (cumulative[0] = 0).
  const segLen: number[] = [];
  const cumulative: number[] = [0];
  for (let i = 0; i < stops.length - 1; i++) {
    const len = haversineMeters(stops[i]!, stops[i + 1]!);
    segLen.push(len);
    cumulative.push(cumulative[i]! + len);
  }

  // Project the position onto the nearest segment. cosLatRef anchors the planar
  // approximation at the vehicle's latitude, where the relevant segments sit.
  const cosLatRef = Math.cos(toRad(position.latitude));
  const p = toPlane(position, cosLatRef);
  let bestSeg = 0;
  let bestTRaw = 0;
  let bestDist = Infinity;
  for (let i = 0; i < segLen.length; i++) {
    const a = toPlane(stops[i]!, cosLatRef);
    const b = toPlane(stops[i + 1]!, cosLatRef);
    const abx = b.x - a.x;
    const aby = b.y - a.y;
    const abLenSq = abx * abx + aby * aby;
    // Degenerate (coincident) stops: treat as the segment start.
    const tRaw = abLenSq === 0 ? 0 : ((p.x - a.x) * abx + (p.y - a.y) * aby) / abLenSq;
    const tClamped = Math.max(0, Math.min(1, tRaw));
    const projX = a.x + tClamped * abx;
    const projY = a.y + tClamped * aby;
    const dist = Math.hypot(p.x - projX, p.y - projY);
    if (dist < bestDist) {
      bestDist = dist;
      bestSeg = i;
      bestTRaw = tRaw;
    }
  }

  // Distance travelled along the route to the projection point. Allow the vehicle
  // to sit before the first stop (bestTRaw < 0) or past the last (bestTRaw > 1) so
  // a rider at the origin still sees the bus approaching, and a finished trip
  // yields no upcoming stops. Interior segments clamp to [0, 1].
  const lastSeg = segLen.length - 1;
  let tEff = Math.max(0, Math.min(1, bestTRaw));
  if (bestSeg === 0 && bestTRaw < 0) tEff = bestTRaw;
  if (bestSeg === lastSeg && bestTRaw > 1) tEff = bestTRaw;
  const travelled = cumulative[bestSeg]! + tEff * segLen[bestSeg]!;

  const etas: StopEta[] = [];
  for (let j = 0; j < stops.length; j++) {
    const remaining = cumulative[j]! - travelled;
    if (remaining <= REACHED_EPS_M) continue; // reached or behind → not upcoming
    etas.push({
      stopId: stops[j]!.stopId,
      seq: stops[j]!.seq,
      name: stops[j]!.name,
      distanceMeters: Math.round(remaining),
      etaSeconds: Math.round(remaining / ASSUMED_SPEED_MS),
    });
  }
  return etas;
}
