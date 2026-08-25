// Persistence for a route's derived shape and its per-segment observed speeds
// (#179, #181). The pure derivation lives in route-geometry.ts; this is the
// layer that reads traces in and writes results out.
//
// Repository pattern (ADR-0009): interface + InMemory here, Postgres in *.pg.ts.

import type { LatLng } from './eta';

/** A route's derived path plus the provenance stored beside it. */
export interface RouteGeometry {
  routeId: string;
  points: LatLng[];
  /** 'traces' | 'matched' | 'manual' — mirrors the DB CHECK. */
  source: string;
  /** How many completed runs the path was derived from. */
  runCount: number;
  updatedAt: Date;
}

/** What to persist after deriving a route's geometry. */
export interface RouteGeometryUpsert {
  routeId: string;
  points: LatLng[];
  source: string;
  runCount: number;
  /** Metres along the path to each stop, by `route_stops.seq`. */
  stopDistances: Map<number, number>;
}

/** Persistence for `routes.geometry` and `route_stops.distance_m`. */
export interface RouteGeometryRepository {
  /**
   * Read a route's derived path.
   *
   * @param routeId - the route.
   * @returns the geometry, or null when the route has never been run.
   */
  findByRoute(routeId: string): Promise<RouteGeometry | null>;
  /**
   * Persist a derived path and its stop distances.
   *
   * Idempotent — re-deriving the same route overwrites rather than appending,
   * because a route has exactly one current shape.
   *
   * @param input - the derived path, provenance, and per-stop distances.
   */
  save(input: RouteGeometryUpsert): Promise<void>;
}

/** In-memory {@link RouteGeometryRepository} for dev and unit tests. */
export class InMemoryRouteGeometryRepository implements RouteGeometryRepository {
  private readonly geometries = new Map<string, RouteGeometry>();
  /** routeId -> (seq -> metres). Mirrors route_stops.distance_m. */
  readonly stopDistances = new Map<string, Map<number, number>>();

  async findByRoute(routeId: string): Promise<RouteGeometry | null> {
    return this.geometries.get(routeId) ?? null;
  }

  async save(input: RouteGeometryUpsert): Promise<void> {
    this.geometries.set(input.routeId, {
      routeId: input.routeId,
      points: input.points,
      source: input.source,
      runCount: input.runCount,
      updatedAt: new Date(),
    });
    this.stopDistances.set(input.routeId, new Map(input.stopDistances));
  }
}
