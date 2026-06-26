// Route repository — a route is a named journey path (e.g. "Circle to Legon").
// It holds only the metadata; the ordered list of stops it passes through lives
// in route_stops. Two implementations: InMemory for unit tests and zero-infra
// dev, Postgres (route.repository.pg.ts) for real runs.

export interface Route {
  id: string;
  name: string;
  description: string | null;
  createdAt: Date;
}

export interface NewRoute {
  name: string;
  description?: string | null;
}

export interface RouteRepository {
  create(input: NewRoute): Promise<Route>;
  findById(id: string): Promise<Route | null>;
  /** Returns all routes. Used by GET /routes (public browse). */
  findAll(): Promise<Route[]>;
}

export class InMemoryRouteRepository implements RouteRepository {
  private readonly routes = new Map<string, Route>();

  async create(input: NewRoute): Promise<Route> {
    const route: Route = {
      id: crypto.randomUUID(),
      name: input.name,
      description: input.description ?? null,
      createdAt: new Date(),
    };
    this.routes.set(route.id, route);
    return route;
  }

  async findById(id: string): Promise<Route | null> {
    return this.routes.get(id) ?? null;
  }

  async findAll(): Promise<Route[]> {
    return Array.from(this.routes.values());
  }
}
