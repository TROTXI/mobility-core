// Postgres route-geometry adapter (#179). The path is stored as PostGIS
// geography(LineString, 4326); the domain model exposes plain lat/lng points,
// so conversion happens here at the boundary — same pattern as stops and
// trip positions.
//
// Note the coordinate order: PostGIS is (longitude, latitude), X is longitude
// and Y is latitude. Getting that backwards puts Accra in the Indian Ocean and
// the code still runs, so it is worth stating rather than remembering.

import type { Pool } from 'pg';
import type { LatLng } from './eta';
import type {
  RouteGeometry,
  RouteGeometryRepository,
  RouteGeometryUpsert,
} from './route-geometry.repository';

interface RouteGeometryRow {
  route_id: string;
  /** GeoJSON string from ST_AsGeoJSON — parsed below. */
  geojson: string | null;
  geometry_source: string | null;
  geometry_run_count: number;
  geometry_updated_at: Date | null;
}

/**
 * Convert a GeoJSON LineString into domain points.
 *
 * @param geojson - the ST_AsGeoJSON output.
 * @returns the ordered points, or an empty array when unparseable.
 */
function toPoints(geojson: string): LatLng[] {
  const parsed = JSON.parse(geojson) as { coordinates?: [number, number][] };
  return (parsed.coordinates ?? []).map(([lng, lat]) => ({ latitude: lat, longitude: lng }));
}

export class PgRouteGeometryRepository implements RouteGeometryRepository {
  constructor(private readonly pool: Pool) {}

  async findByRoute(routeId: string): Promise<RouteGeometry | null> {
    const { rows } = await this.pool.query<RouteGeometryRow>(
      `SELECT id AS route_id,
              ST_AsGeoJSON(geometry::geometry) AS geojson,
              geometry_source,
              geometry_run_count,
              geometry_updated_at
         FROM routes
        WHERE id = $1`,
      [routeId],
    );
    const row = rows[0];
    if (!row?.geojson) return null;
    return {
      routeId: row.route_id,
      points: toPoints(row.geojson),
      source: row.geometry_source ?? 'traces',
      runCount: row.geometry_run_count,
      updatedAt: row.geometry_updated_at ?? new Date(),
    };
  }

  async save(input: RouteGeometryUpsert): Promise<void> {
    const client = await this.pool.connect();
    try {
      // One transaction: a path written without its stop distances would leave
      // "3 of 11 stops" reading against a shape it does not match.
      await client.query('BEGIN');

      // Build the LineString from a coordinate array rather than string
      // concatenation — WKT assembled by hand is an injection surface and a
      // precision loss for no benefit.
      const lngs = input.points.map((p) => p.longitude);
      const lats = input.points.map((p) => p.latitude);
      await client.query(
        `UPDATE routes
            SET geometry = (
                  SELECT ST_MakeLine(ST_MakePoint(lng, lat)::geography::geometry ORDER BY ord)::geography
                    FROM unnest($2::float8[], $3::float8[]) WITH ORDINALITY AS t(lng, lat, ord)
                ),
                geometry_source     = $4,
                geometry_run_count  = $5,
                geometry_updated_at = now()
          WHERE id = $1`,
        [input.routeId, lngs, lats, input.source, input.runCount],
      );

      for (const [seq, metres] of input.stopDistances) {
        await client.query(
          `UPDATE route_stops SET distance_m = $3 WHERE route_id = $1 AND seq = $2`,
          [input.routeId, seq, metres],
        );
      }

      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }
}
