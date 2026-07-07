// Route repository — a route is a named journey path (e.g. "Circle to Legon").
// It holds only the metadata; the ordered list of stops it passes through lives
// in route_stops. Two implementations: InMemory for unit tests and zero-infra
// dev, Postgres (route.repository.pg.ts) for real runs.

import { applyPatch } from '../../lib/patch';

/** A named journey path (e.g. "Circle to Legon"). Metadata only — the ordered
 * stops it passes through live in route_stops. */
export interface Route {
  id: string;
  name: string;
  description: string | null;
  createdAt: Date;
}

/** Fields needed to create a {@link Route}. */
export interface NewRoute {
  name: string;
  description?: string | null;
}

/** Editable {@link Route} fields for a partial update (admin, #26). */
export interface RouteUpdate {
  name?: string;
  description?: string | null;
}

/** Persistence for routes (Postgres in prod, in-memory in dev/tests). */
export interface RouteRepository {
  /**
   * Create a route.
   *
   * @param input - the route's name and optional description.
   * @returns the created route.
   */
  create(input: NewRoute): Promise<Route>;
  /**
   * Look up a route by id.
   *
   * @param id - the route id.
   * @returns the route, or null if it doesn't exist.
   */
  findById(id: string): Promise<Route | null>;
  /** Returns all routes. Used by GET /routes (public browse). */
  findAll(): Promise<Route[]>;
  /**
   * Update a route's editable fields (partial — omitted fields are unchanged).
   *
   * @param id - the route id.
   * @param patch - the fields to change.
   * @returns the updated route, or null if not found.
   */
  update(id: string, patch: RouteUpdate): Promise<Route | null>;
}

/** In-memory {@link RouteRepository} for dev and unit tests. */
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

  async update(id: string, patch: RouteUpdate): Promise<Route | null> {
    const existing = this.routes.get(id);
    if (!existing) return null;
    const updated = applyPatch(existing, patch);
    this.routes.set(id, updated);
    return updated;
  }
}
