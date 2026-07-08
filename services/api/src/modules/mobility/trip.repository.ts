// Trip repository — a trip is one scheduled run of a route by a vehicle and a
// driver. vehicleId/assignedDriverId are nullable: a trip can be scheduled
// before ops assigns a bus and driver (#26). assignedDriverId is the field that
// later authorizes GPS position reporting — only the assigned driver may report
// a trip's live position (system-design §7, #25). Two implementations: InMemory
// for dev/tests, Postgres (trip.repository.pg.ts) for real runs.

import { applyPatch } from '../../lib/patch';

/** Valid trip lifecycle states — the source of truth for the DB CHECK, the
 * domain type, and the response enum (imported by mobility.schema.ts). */
export const TRIP_STATUSES = ['scheduled', 'active', 'completed', 'cancelled'] as const;
export type TripStatus = (typeof TRIP_STATUSES)[number];

/** One scheduled run of a route by a vehicle and a driver. */
export interface Trip {
  id: string;
  routeId: string;
  vehicleId: string | null;
  assignedDriverId: string | null;
  status: TripStatus;
  scheduledAt: Date;
  createdAt: Date;
}

/** Fields needed to create a {@link Trip}. status defaults to 'scheduled'. */
export interface NewTrip {
  routeId: string;
  vehicleId?: string | null;
  assignedDriverId?: string | null;
  status?: TripStatus;
  scheduledAt: Date;
}

/** Optional filters for {@link TripRepository.findAll}. */
export interface TripFilter {
  routeId?: string;
  status?: TripStatus;
  /** UTC calendar day (`YYYY-MM-DD`) the trip is scheduled on — what the
   * ask-dispatch will use for "tomorrow's trips" (E3). */
  date?: string;
}

/** Editable {@link Trip} fields for a partial update (admin, #26). routeId is
 * intentionally not editable — a trip belongs to the route it was created for.
 * vehicleId/assignedDriverId cover the driver↔trip assignment (set null to
 * unassign); the assignment endpoint validates they exist before writing. */
export interface TripUpdate {
  status?: TripStatus;
  scheduledAt?: Date;
  vehicleId?: string | null;
  assignedDriverId?: string | null;
}

/** Persistence for trips (Postgres in prod, in-memory in dev/tests). */
export interface TripRepository {
  /**
   * Create a trip.
   *
   * @param input - the route, optional vehicle/driver, status, and schedule.
   * @returns the created trip.
   */
  create(input: NewTrip): Promise<Trip>;
  /**
   * Look up a trip by id.
   *
   * @param id - the trip id.
   * @returns the trip, or null if it doesn't exist.
   */
  findById(id: string): Promise<Trip | null>;
  /**
   * List trips, optionally filtered by route, ordered by scheduled_at ascending.
   *
   * @param filter - optional filters (e.g. routeId).
   * @returns the matching trips.
   */
  findAll(filter?: TripFilter): Promise<Trip[]>;
  /**
   * Update a trip's editable fields (partial — omitted fields are unchanged).
   * Covers status/schedule changes and driver↔vehicle assignment.
   *
   * @param id - the trip id.
   * @param patch - the fields to change.
   * @returns the updated trip, or null if not found.
   */
  update(id: string, patch: TripUpdate): Promise<Trip | null>;
}

/** In-memory {@link TripRepository} for dev and unit tests. */
export class InMemoryTripRepository implements TripRepository {
  private readonly trips = new Map<string, Trip>();

  async create(input: NewTrip): Promise<Trip> {
    const trip: Trip = {
      id: crypto.randomUUID(),
      routeId: input.routeId,
      vehicleId: input.vehicleId ?? null,
      assignedDriverId: input.assignedDriverId ?? null,
      status: input.status ?? 'scheduled',
      scheduledAt: input.scheduledAt,
      createdAt: new Date(),
    };
    this.trips.set(trip.id, trip);
    return trip;
  }

  async findById(id: string): Promise<Trip | null> {
    return this.trips.get(id) ?? null;
  }

  async findAll(filter?: TripFilter): Promise<Trip[]> {
    return Array.from(this.trips.values())
      .filter((t) => !filter?.routeId || t.routeId === filter.routeId)
      .filter((t) => !filter?.status || t.status === filter.status)
      .filter((t) => !filter?.date || t.scheduledAt.toISOString().slice(0, 10) === filter.date)
      .sort((a, b) => a.scheduledAt.getTime() - b.scheduledAt.getTime());
  }

  async update(id: string, patch: TripUpdate): Promise<Trip | null> {
    const existing = this.trips.get(id);
    if (!existing) return null;
    const updated = applyPatch(existing, patch);
    this.trips.set(id, updated);
    return updated;
  }
}
