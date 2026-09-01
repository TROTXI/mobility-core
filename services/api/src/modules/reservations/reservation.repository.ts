// Reservations — the daily ride confirmation (ADR-0014, epic E3). A rider
// confirms or declines each travel day/direction; a still-`pending` row defaults
// to travelling at the cutoff. Repository pattern (ADR-0009): interface +
// InMemory here, Postgres in *.pg.ts.
//
// Seat-release to the standby pool is still deferred (E6).

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
  | 'operator_cancelled' // Trotxi couldn't run it — no deduction
  | 'unseated'; // the van filled up before we reached them (#210) — no deduction

/**
 * The statuses that occupy a seat (#161). A `no_show` deliberately does not:
 * the rider has already been charged for it, and the vehicle no longer needs to
 * hold it. `released` frees the seat to the standby pool (E6).
 */
export const SEAT_CONSUMING_STATUSES = ['reserved', 'boarded'] as const;

/** How a reservation reached its current state. */
export type ReservationSource = 'confirmation' | 'default' | 'standby';

/** A rider's reservation for one trip on one day. */
export interface Reservation {
  id: string;
  userId: string;
  /** The trip, when known (no FK yet — trips are #18). */
  tripId: string | null;
  /** Where the rider boards, frozen from the subscription when seeded (#204). */
  pickupStopId: string | null;
  /** Where the rider alights (#204). */
  dropoffStopId: string | null;
  /** The travel day as `YYYY-MM-DD`. */
  travelDate: string;
  direction: ReservationDirection;
  status: ReservationStatus;
  source: ReservationSource;
  /** Keyed hash of the rider's daily boarding PIN (null until confirmed / when
   * declined). Never exposed in a response — verified server-side only (E4). */
  pinHash: string | null;
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
  /** Keyed PIN hash to store on confirm (null when declining). */
  pinHash?: string | null;
}

/** Seed of a `pending` reservation (the ask-dispatch creates these; #18). */
export interface PendingReservation {
  userId: string;
  tripId?: string | null;
  travelDate: string;
  direction: ReservationDirection;
  /** Copied from the rider's subscription when the row is seeded (#204). */
  pickupStopId?: string | null;
  dropoffStopId?: string | null;
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
   * Confirm a seat, refusing when the trip is full (#161).
   *
   * Enforced here, not by the caller: a check-then-write races. The 18:00 push
   * lands a corridor's answers within seconds, so two riders would both read
   * "one free". Only the store can make count and write atomic.
   *
   * @param input - the rider's response.
   * @param capacity - the assigned vehicle's seat count.
   * @returns the reservation, or null when the trip is at capacity.
   */
  respondWithinCapacity(input: ReservationResponse, capacity: number): Promise<Reservation | null>;
  /**
   * Seats taken on a trip. Only `reserved` and `boarded` consume one — a
   * no-show has already been charged for a seat the vehicle no longer holds.
   *
   * @param tripId - the trip.
   * @returns how many seats are taken.
   */
  countSeatsTaken(tripId: string): Promise<number>;
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
   * Riders the trip has no room for become `unseated` rather than staying
   * `pending` (#210), so the app can say the van filled up instead of asking
   * them again. Oldest first, so the ceiling falls on whoever was asked last.
   *
   * @param travelDate - the travel day (`YYYY-MM-DD`).
   * @param direction - morning or evening.
   * @param capacityOf - resolves a trip's seat ceiling; omit to skip the check.
   * @returns how many were defaulted, and how many were left unseated.
   */
  markDefaultTravelling(
    travelDate: string,
    direction: ReservationDirection,
    capacityOf?: (tripId: string) => Promise<number | null>,
  ): Promise<{ defaulted: number; skippedFull: number }>;
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
  /**
   * The rider's next boardable reservation for a day — the earliest still-open
   * `reserved` seat (morning before evening), or null. This is what a boarding
   * scan consumes; already-`boarded` seats are skipped so a re-scan can't
   * double-deduct.
   *
   * @param userId - the rider.
   * @param travelDate - the travel day (`YYYY-MM-DD`).
   * @returns the reservation to board, or null.
   */
  findBoardable(userId: string, travelDate: string): Promise<Reservation | null>;
  /**
   * Mark a reservation `boarded` (the rider verified onto the vehicle).
   *
   * @param id - the reservation id.
   * @returns the updated reservation, or null if not found.
   */
  markBoarded(id: string): Promise<Reservation | null>;
  /**
   * Confirmed-but-not-boarded reservations for a day+direction — the no-show
   * candidates the cutoff resolves (still `reserved`, so a boarded seat is
   * never a no-show). E4.
   *
   * @param travelDate - the travel day (`YYYY-MM-DD`).
   * @param direction - morning or evening.
   * @returns the still-`reserved` reservations for that day+direction.
   */
  listReserved(travelDate: string, direction: ReservationDirection): Promise<Reservation[]>;
  /**
   * Mark a reservation `no_show` (confirmed but didn't board — a ride is
   * deducted by the caller). E4.
   *
   * @param id - the reservation id.
   * @returns the updated reservation, or null if not found.
   */
  markNoShow(id: string): Promise<Reservation | null>;
  /**
   * All reservations attached to a trip — the raw rows behind a driver's
   * manifest (the handler filters to the confirmed ones and enriches with rider
   * name/photo).
   *
   * @param tripId - the trip.
   * @returns the trip's reservations (any status).
   */
  listForTrip(tripId: string): Promise<Reservation[]>;
  /**
   * Look up a reservation by id — used to board it via the daily PIN (E4).
   *
   * @param id - the reservation id.
   * @returns the reservation, or null.
   */
  findById(id: string): Promise<Reservation | null>;
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
        pinHash: input.pinHash ?? null,
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
      pickupStopId: null,
      dropoffStopId: null,
      travelDate: input.travelDate,
      direction: input.direction,
      status,
      source: 'confirmation',
      pinHash: input.pinHash ?? null,
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
      pickupStopId: input.pickupStopId ?? null,
      dropoffStopId: input.dropoffStopId ?? null,
      travelDate: input.travelDate,
      direction: input.direction,
      status: 'pending',
      source: 'confirmation',
      pinHash: null,
      confirmedAt: null,
      createdAt: now,
      updatedAt: now,
    };
    this.rows.push(created);
    return created;
  }

  async countSeatsTaken(tripId: string): Promise<number> {
    return this.rows.filter(
      (r) =>
        r.tripId === tripId && (SEAT_CONSUMING_STATUSES as readonly string[]).includes(r.status),
    ).length;
  }

  async respondWithinCapacity(
    input: ReservationResponse,
    capacity: number,
  ): Promise<Reservation | null> {
    // Declining never needs a seat, so it is never refused.
    if (input.travelling && input.tripId) {
      const taken = await this.countSeatsTaken(input.tripId);
      const existing = this.rows[this.index(input.userId, input.travelDate, input.direction)];
      const alreadyHolds =
        existing?.tripId === input.tripId &&
        (SEAT_CONSUMING_STATUSES as readonly string[]).includes(existing.status);
      // A rider re-confirming a seat they already hold is not a new seat.
      if (!alreadyHolds && taken >= capacity) return null;
    }
    return this.respond(input);
  }

  async markDefaultTravelling(
    travelDate: string,
    direction: ReservationDirection,
    capacityOf?: (tripId: string) => Promise<number | null>,
  ): Promise<{ defaulted: number; skippedFull: number }> {
    let defaulted = 0;
    let skippedFull = 0;
    const now = new Date();
    for (const r of this.rows) {
      if (r.travelDate === travelDate && r.direction === direction && r.status === 'pending') {
        // The cutoff must not default a rider into a seat that does not exist.
        // Without this the default-yes makes an overfull trip worse, silently,
        // at 21:00 when nobody is looking.
        if (capacityOf && r.tripId) {
          const capacity = await capacityOf(r.tripId);
          if (capacity !== null && (await this.countSeatsTaken(r.tripId)) >= capacity) {
            // Leaving this `pending` was #210: the rider kept being asked to
            // confirm a seat that no longer existed, and nothing ever told them
            // why. Terminal, and no ride is deducted.
            r.status = 'unseated';
            r.source = 'default';
            r.updatedAt = now;
            skippedFull++;
            continue;
          }
        }
        r.status = 'reserved';
        r.source = 'default';
        r.confirmedAt = now;
        r.updatedAt = now;
        defaulted++;
      }
    }
    return { defaulted, skippedFull };
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

  async findBoardable(userId: string, travelDate: string): Promise<Reservation | null> {
    // Earliest open leg first — morning before evening (not alphabetical:
    // 'evening' < 'morning', so we rank explicitly).
    const rank = (d: ReservationDirection): number => (d === 'morning' ? 0 : 1);
    const open = this.rows
      .filter((r) => r.userId === userId && r.travelDate === travelDate && r.status === 'reserved')
      .sort((a, b) => rank(a.direction) - rank(b.direction));
    return open[0] ?? null;
  }

  async markBoarded(id: string): Promise<Reservation | null> {
    const row = this.rows.find((r) => r.id === id);
    if (!row) return null;
    row.status = 'boarded';
    row.updatedAt = new Date();
    return row;
  }

  async listReserved(travelDate: string, direction: ReservationDirection): Promise<Reservation[]> {
    return this.rows.filter(
      (r) => r.travelDate === travelDate && r.direction === direction && r.status === 'reserved',
    );
  }

  async markNoShow(id: string): Promise<Reservation | null> {
    const row = this.rows.find((r) => r.id === id);
    if (!row) return null;
    row.status = 'no_show';
    row.updatedAt = new Date();
    return row;
  }

  async listForTrip(tripId: string): Promise<Reservation[]> {
    // Morning before evening — explicit rank (NOT alphabetical: 'evening' <
    // 'morning'), matching the Pg CASE ordering and findBoardable above.
    const rank = (d: ReservationDirection): number => (d === 'morning' ? 0 : 1);
    return this.rows
      .filter((r) => r.tripId === tripId)
      .sort((a, b) => rank(a.direction) - rank(b.direction));
  }

  async findById(id: string): Promise<Reservation | null> {
    return this.rows.find((r) => r.id === id) ?? null;
  }
}
