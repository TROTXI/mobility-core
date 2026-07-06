// Reservations — the daily ride confirmation (ADR-0014, epic E3). A rider
// confirms or declines each travel day/direction; a still-`pending` row defaults
// to travelling at the cutoff. Repository pattern (ADR-0009): interface +
// InMemory here, Postgres in *.pg.ts.
//
// Scope of E3-core: the reservation lifecycle + the rider's confirm/decline API.
// Deferred to when trips (#18) land: the scheduled ask-dispatch that seeds
// `pending` rows for tomorrow's trips, the FCM push that asks, and capacity /
// seat-release to the standby pool (E6).

/** Which leg of the day a reservation is for. */
export type ReservationDirection = 'morning' | 'evening';

/** Lifecycle state of a reservation. */
export type ReservationStatus =
  | 'pending' // asked, awaiting the rider's response
  | 'reserved' // travelling (confirmed, or defaulted at cutoff)
  | 'declined' // rider said no; the seat is released
  | 'boarded' // verified onto the vehicle (E4)
  | 'no_show' // confirmed but didn't board — deducted (E4)
  | 'released' // freed to the standby pool (E6)
  | 'operator_cancelled'; // Trotxi couldn't run it — no deduction

/** How a reservation reached its current state. */
export type ReservationSource = 'confirmation' | 'default' | 'standby';

/** A rider's reservation for one trip on one day. */
export interface Reservation {
  id: string;
  userId: string;
  /** The trip, when known (no FK yet — trips are #18). */
  tripId: string | null;
  /** The travel day as `YYYY-MM-DD`. */
  travelDate: string;
  direction: ReservationDirection;
  status: ReservationStatus;
  source: ReservationSource;
  /** When the rider (or the default) settled the reservation. */
  confirmedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

/** A rider's confirm/decline response to the daily prompt. */
export interface ReservationResponse {
  userId: string;
  tripId?: string | null;
  travelDate: string;
  direction: ReservationDirection;
  /** true → reserve the seat; false → decline it. */
  travelling: boolean;
}

/** Seed of a `pending` reservation (the ask-dispatch creates these; #18). */
export interface PendingReservation {
  userId: string;
  tripId?: string | null;
  travelDate: string;
  direction: ReservationDirection;
}

/** Persistence for daily reservations (Postgres in prod, in-memory in dev/tests). */
export interface ReservationRepository {
  /**
   * Record a rider's confirm/decline for a day+direction (an upsert — the daily
   * prompt is answered at most once, and a change of mind overwrites).
   *
   * @param input - who, which trip/day/direction, and whether they're travelling.
   * @returns the resulting reservation.
   */
  respond(input: ReservationResponse): Promise<Reservation>;
  /**
   * Seed a `pending` reservation (the scheduled ask-dispatch; #18). A duplicate
   * day+direction for the rider is left untouched.
   *
   * @param input - who, which trip, day, and direction.
   * @returns the pending reservation (existing one if already present).
   */
  createPending(input: PendingReservation): Promise<Reservation>;
  /**
   * Default-yes at the cutoff: flip every still-`pending` reservation for a
   * day+direction to `reserved` (source `default`). Declined/confirmed rows are
   * untouched.
   *
   * @param travelDate - the travel day (`YYYY-MM-DD`).
   * @param direction - morning or evening.
   * @returns how many reservations were defaulted.
   */
  markDefaultTravelling(travelDate: string, direction: ReservationDirection): Promise<number>;
  /**
   * List a rider's reservations, newest travel day first.
   *
   * @param userId - the rider.
   * @param opts - optional filters.
   * @param opts.fromDate - lower bound (`YYYY-MM-DD`); omit for all.
   * @returns the rider's reservations.
   */
  listForUser(userId: string, opts?: { fromDate?: string }): Promise<Reservation[]>;
  /**
   * Find a rider's reservation for a specific day+direction.
   *
   * @param userId - the rider.
   * @param travelDate - the travel day (`YYYY-MM-DD`).
   * @param direction - morning or evening.
   * @returns the reservation, or null.
   */
  find(
    userId: string,
    travelDate: string,
    direction: ReservationDirection,
  ): Promise<Reservation | null>;
}

/** In-memory {@link ReservationRepository} for dev and unit tests. */
export class InMemoryReservationRepository implements ReservationRepository {
  private readonly rows: Reservation[] = [];

  private key(userId: string, travelDate: string, direction: ReservationDirection): string {
    return `${userId}|${travelDate}|${direction}`;
  }

  private index(userId: string, travelDate: string, direction: ReservationDirection): number {
    return this.rows.findIndex(
      (r) =>
        this.key(r.userId, r.travelDate, r.direction) === this.key(userId, travelDate, direction),
    );
  }

  async respond(input: ReservationResponse): Promise<Reservation> {
    const now = new Date();
    const status: ReservationStatus = input.travelling ? 'reserved' : 'declined';
    const i = this.index(input.userId, input.travelDate, input.direction);
    if (i >= 0) {
      const updated: Reservation = {
        ...this.rows[i]!,
        tripId: input.tripId ?? this.rows[i]!.tripId,
        status,
        source: 'confirmation',
        confirmedAt: now,
        updatedAt: now,
      };
      this.rows[i] = updated;
      return updated;
    }
    const created: Reservation = {
      id: crypto.randomUUID(),
      userId: input.userId,
      tripId: input.tripId ?? null,
      travelDate: input.travelDate,
      direction: input.direction,
      status,
      source: 'confirmation',
      confirmedAt: now,
      createdAt: now,
      updatedAt: now,
    };
    this.rows.push(created);
    return created;
  }

  async createPending(input: PendingReservation): Promise<Reservation> {
    const existing = this.index(input.userId, input.travelDate, input.direction);
    if (existing >= 0) return this.rows[existing]!;
    const now = new Date();
    const created: Reservation = {
      id: crypto.randomUUID(),
      userId: input.userId,
      tripId: input.tripId ?? null,
      travelDate: input.travelDate,
      direction: input.direction,
      status: 'pending',
      source: 'confirmation',
      confirmedAt: null,
      createdAt: now,
      updatedAt: now,
    };
    this.rows.push(created);
    return created;
  }

  async markDefaultTravelling(
    travelDate: string,
    direction: ReservationDirection,
  ): Promise<number> {
    let count = 0;
    const now = new Date();
    for (const r of this.rows) {
      if (r.travelDate === travelDate && r.direction === direction && r.status === 'pending') {
        r.status = 'reserved';
        r.source = 'default';
        r.confirmedAt = now;
        r.updatedAt = now;
        count++;
      }
    }
    return count;
  }

  async listForUser(userId: string, opts?: { fromDate?: string }): Promise<Reservation[]> {
    return this.rows
      .filter((r) => r.userId === userId && (!opts?.fromDate || r.travelDate >= opts.fromDate))
      .sort((a, b) => (a.travelDate < b.travelDate ? 1 : -1));
  }

  async find(
    userId: string,
    travelDate: string,
    direction: ReservationDirection,
  ): Promise<Reservation | null> {
    const i = this.index(userId, travelDate, direction);
    return i >= 0 ? this.rows[i]! : null;
  }
}
