// RouteStop repository — the join table between routes and stops. Each row
// places a stop on a route at a specific sequence position (seq). The unique
// constraint on (route_id, seq) in the DB prevents duplicate positions.
// findByRoute always returns stops ordered by seq so callers never need to sort.

export interface RouteStop {
  id: string;
  routeId: string;
  stopId: string;
  seq: number;
  createdAt: Date;
}

export interface NewRouteStop {
  routeId: string;
  stopId: string;
  seq: number;
}

export interface RouteStopRepository {
  create(input: NewRouteStop): Promise<RouteStop>;
  /** Returns all stops for a route ordered by seq ascending. */
  findByRoute(routeId: string): Promise<RouteStop[]>;
}

export class InMemoryRouteStopRepository implements RouteStopRepository {
  private readonly routeStops = new Map<string, RouteStop>();

  async create(input: NewRouteStop): Promise<RouteStop> {
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
