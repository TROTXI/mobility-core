// Stop repository — a stop is a physical location where passengers board or
// alight. Coordinates are stored as latitude/longitude in the domain model.
// In Postgres the location column is a PostGIS geography(Point, 4326) — the
// Pg adapter handles the conversion (see stop.repository.pg.ts).

export interface Stop {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  createdAt: Date;
}

export interface NewStop {
  name: string;
  latitude: number;
  longitude: number;
}

export interface StopRepository {
  create(input: NewStop): Promise<Stop>;
  findById(id: string): Promise<Stop | null>;
}

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
