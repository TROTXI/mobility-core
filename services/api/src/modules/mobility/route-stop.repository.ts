// RouteStop repository — the join table between routes and stops. Each row
// places a stop on a route at a specific sequence position (seq). The unique
// constraint on (route_id, seq) in the DB prevents duplicate positions.
// findByRoute always returns stops ordered by seq so callers never need to sort.

/** A stop's position on a route. The (routeId, seq) pair is unique in the DB. */
export interface RouteStop {
  id: string;
  routeId: string;
  stopId: string;
  seq: number;
  createdAt: Date;
}

/** Fields needed to create a {@link RouteStop}. */
export interface NewRouteStop {
  routeId: string;
  stopId: string;
  seq: number;
}

/** Persistence for route/stop placements (Postgres in prod, in-memory in dev/tests). */
export interface RouteStopRepository {
  /**
   * Place a stop on a route at a sequence position.
   *
   * @param input - the route, stop, and sequence position.
   * @returns the created route-stop.
   */
  create(input: NewRouteStop): Promise<RouteStop>;
  /** Returns all stops for a route ordered by seq ascending. */
  findByRoute(routeId: string): Promise<RouteStop[]>;
}

/** In-memory {@link RouteStopRepository} for dev and unit tests. */
export class InMemoryRouteStopRepository implements RouteStopRepository {
  private readonly routeStops = new Map<string, RouteStop>();

  async create(input: NewRouteStop): Promise<RouteStop> {
    // Mirror the DB's UNIQUE (route_id, seq): throw the same shape as a Postgres
    // unique violation (SQLSTATE 23505) so handlers behave identically on both
    // adapters — the admin attach-stop route maps this to a 409.
    const duplicate = Array.from(this.routeStops.values()).some(
      (rs) => rs.routeId === input.routeId && rs.seq === input.seq,
    );
    if (duplicate) {
      throw Object.assign(new Error('duplicate (route_id, seq)'), { code: '23505' });
    }
    const routeStop: RouteStop = {
      id: crypto.randomUUID(),
      routeId: input.routeId,
      stopId: input.stopId,
      seq: input.seq,
      createdAt: new Date(),
    };
    this.routeStops.set(routeStop.id, routeStop);
    return routeStop;
  }

  async findByRoute(routeId: string): Promise<RouteStop[]> {
    return Array.from(this.routeStops.values())
      .filter((rs) => rs.routeId === routeId)
      .sort((a, b) => a.seq - b.seq);
  }
}
