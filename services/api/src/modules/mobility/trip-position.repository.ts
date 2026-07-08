// TripPosition repository — live GPS fixes for a trip (#25, system-design §7).
// Append-only: `record` inserts one fix, `findLatest` returns the most recent for
// a trip (the position a rider reads). The assigned driver reports fixes over
// HTTP for the pilot; the durable store is the source of truth and Redis caches
// the latest fix (see positions.routes.ts). Two implementations: InMemory for
// dev/tests, Postgres (trip-position.repository.pg.ts) for real runs.

/** One reported GPS fix for a trip. recordedAt is server-assigned at record time. */
export interface TripPosition {
  id: string;
  tripId: string;
  latitude: number;
  longitude: number;
  recordedAt: Date;
}

/** Fields needed to record a {@link TripPosition}. recordedAt is set by the store. */
export interface NewTripPosition {
  tripId: string;
  latitude: number;
  longitude: number;
}

/** Persistence for trip position fixes (Postgres in prod, in-memory in dev/tests). */
export interface TripPositionRepository {
  /**
   * Append a GPS fix for a trip.
   *
   * @param input - the trip and its coordinates.
   * @returns the recorded fix (with its server-assigned id + recordedAt).
   */
  record(input: NewTripPosition): Promise<TripPosition>;
  /**
   * The most recent fix for a trip — the trip's current live position.
   *
   * @param tripId - the trip id.
   * @returns the latest fix, or null if none has been reported.
   */
  findLatest(tripId: string): Promise<TripPosition | null>;
}

/** In-memory {@link TripPositionRepository} for dev and unit tests. */
export class InMemoryTripPositionRepository implements TripPositionRepository {
  private readonly positions: TripPosition[] = [];

  async record(input: NewTripPosition): Promise<TripPosition> {
    const position: TripPosition = {
      id: crypto.randomUUID(),
      tripId: input.tripId,
      latitude: input.latitude,
      longitude: input.longitude,
      recordedAt: new Date(),
    };
    this.positions.push(position);
    return position;
  }

  async findLatest(tripId: string): Promise<TripPosition | null> {
    // Latest = highest recordedAt for the trip; ties broken by insertion order
    // (later push wins), matching the Postgres ORDER BY recorded_at DESC.
    let latest: TripPosition | null = null;
    for (const p of this.positions) {
      if (p.tripId !== tripId) continue;
      if (!latest || p.recordedAt.getTime() >= latest.recordedAt.getTime()) latest = p;
    }
    return latest;
  }
}
