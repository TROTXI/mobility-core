// Stop repository — a stop is a physical location where passengers board or
// alight. Coordinates are stored as latitude/longitude in the domain model.
// In Postgres the location column is a PostGIS geography(Point, 4326) — the
// Pg adapter handles the conversion (see stop.repository.pg.ts).

/** A physical location where passengers board or alight. */
export interface Stop {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  createdAt: Date;
}

/** Fields needed to create a {@link Stop}. */
export interface NewStop {
  name: string;
  latitude: number;
  longitude: number;
}

/** Persistence for stops (Postgres in prod, in-memory in dev/tests). */
export interface StopRepository {
  /**
   * Create a stop.
   *
   * @param input - the stop's name and coordinates.
   * @returns the created stop.
   */
  create(input: NewStop): Promise<Stop>;
  /**
   * Look up a stop by id.
   *
   * @param id - the stop id.
   * @returns the stop, or null if it doesn't exist.
   */
  findById(id: string): Promise<Stop | null>;
}

/** In-memory {@link StopRepository} for dev and unit tests. */
export class InMemoryStopRepository implements StopRepository {
  private readonly stops = new Map<string, Stop>();

  async create(input: NewStop): Promise<Stop> {
    const stop: Stop = {
      id: crypto.randomUUID(),
      name: input.name,
      latitude: input.latitude,
      longitude: input.longitude,
      createdAt: new Date(),
    };
    this.stops.set(stop.id, stop);
    return stop;
  }

  async findById(id: string): Promise<Stop | null> {
    return this.stops.get(id) ?? null;
  }
}
