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
