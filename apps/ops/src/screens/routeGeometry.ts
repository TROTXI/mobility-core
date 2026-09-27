export type RoutePoint = { latitude: number; longitude: number };

const radians = (value: number) => (value * Math.PI) / 180;

function distance(a: RoutePoint, b: RoutePoint) {
  // PostGIS geography measures WGS84 spheroid length, not spherical Haversine.
  // Match it so the final stop distance never exceeds the server's line length.
  const major = 6_378_137;
  const flattening = 1 / 298.257223563;
  const minor = major * (1 - flattening);
  const u1 = Math.atan((1 - flattening) * Math.tan(radians(a.latitude)));
  const u2 = Math.atan((1 - flattening) * Math.tan(radians(b.latitude)));
  const sinU1 = Math.sin(u1);
  const cosU1 = Math.cos(u1);
  const sinU2 = Math.sin(u2);
  const cosU2 = Math.cos(u2);
  const longitudeGap = radians(b.longitude - a.longitude);
  let lambda = longitudeGap;
  let sinSigma = 0;
  let cosSigma = 0;
  let sigma = 0;
  let sinAlpha = 0;
  let cos2Alpha = 0;
  let cos2SigmaM = 0;
  let converged = false;
  for (let iteration = 0; iteration < 100; iteration += 1) {
    const sinLambda = Math.sin(lambda);
    const cosLambda = Math.cos(lambda);
    sinSigma = Math.hypot(cosU2 * sinLambda, cosU1 * sinU2 - sinU1 * cosU2 * cosLambda);
    if (sinSigma === 0) return 0;
    cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
    sigma = Math.atan2(sinSigma, cosSigma);
    sinAlpha = (cosU1 * cosU2 * sinLambda) / sinSigma;
    cos2Alpha = 1 - sinAlpha * sinAlpha;
    cos2SigmaM = cos2Alpha === 0 ? 0 : cosSigma - (2 * sinU1 * sinU2) / cos2Alpha;
    const c = (flattening / 16) * cos2Alpha * (4 + flattening * (4 - 3 * cos2Alpha));
    const previous = lambda;
    lambda =
      longitudeGap +
      (1 - c) *
        flattening *
        sinAlpha *
        (sigma + c * sinSigma * (cos2SigmaM + c * cosSigma * (-1 + 2 * cos2SigmaM ** 2)));
    if (Math.abs(lambda - previous) < 1e-12) {
      converged = true;
      break;
    }
  }
  if (!converged) throw new Error('The route leg could not be measured. Add a nearer waypoint.');
  const uSquared = (cos2Alpha * (major ** 2 - minor ** 2)) / minor ** 2;
  const coefficientA =
    1 + (uSquared / 16384) * (4096 + uSquared * (-768 + uSquared * (320 - 175 * uSquared)));
  const coefficientB =
    (uSquared / 1024) * (256 + uSquared * (-128 + uSquared * (74 - 47 * uSquared)));
  const deltaSigma =
    coefficientB *
    sinSigma *
    (cos2SigmaM +
      (coefficientB / 4) *
        (cosSigma * (-1 + 2 * cos2SigmaM ** 2) -
          (coefficientB / 6) * cos2SigmaM * (-3 + 4 * sinSigma ** 2) * (-3 + 4 * cos2SigmaM ** 2)));
  return minor * coefficientA * (sigma - deltaSigma);
}

// Each occurrence stays in the line, including a physical stop visited twice on a loop.
export function buildRouteGeometry(
  stops: { location: RoutePoint }[],
  waypoints: Record<number, RoutePoint[]>,
) {
  if (stops.length < 2) throw new Error('Add at least two stop occurrences.');
  if (stops.length > 500) throw new Error('A route may have at most 500 stop occurrences.');
  const validPoint = (point: RoutePoint) =>
    Number.isFinite(point.latitude) &&
    Number.isFinite(point.longitude) &&
    Math.abs(point.latitude) <= 90 &&
    Math.abs(point.longitude) <= 180;
  if (!validPoint(stops[0].location)) throw new Error('A route stop has invalid coordinates.');
  const points: RoutePoint[] = [stops[0].location];
  const stopDistancesMeters = [0];
  let travelled = 0;
  for (let segment = 0; segment < stops.length - 1; segment += 1) {
    for (const point of [...(waypoints[segment] ?? []), stops[segment + 1].location]) {
      if (!validPoint(point)) throw new Error('A route waypoint has invalid coordinates.');
      travelled += distance(points[points.length - 1], point);
      points.push(point);
      if (points.length > 10_000) throw new Error('A route may have at most 10,000 path points.');
    }
    if (travelled <= stopDistancesMeters[segment])
      throw new Error(`Stop ${segment + 2} must be farther along the drawn route.`);
    stopDistancesMeters.push(travelled);
  }
  return { points, stopDistancesMeters };
}
