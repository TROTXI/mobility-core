// Driver-owned trip lifecycle (#163). Start/end a run and report what it did.
//
// Authorization is assigned-driver, not the `driver` role: the caller must be
// linked to the driver THIS trip is assigned to, matching position reporting
// and the manifest.

import type { ScanEventRepository } from '../boarding/scan-event.repository';
import type { ReservationRepository } from '../reservations/reservation.repository';
import type { DriverRepository } from './driver.repository';
import type { RouteStopRepository } from './route-stop.repository';
import type { Trip, TripRepository, TripStatus } from './trip.repository';

/**
 * Why a lifecycle call was refused, so routes can map it to a status code.
 *
 * Split deliberately: reads can only fail on existence or authorization, and a
 * transition error is impossible for them. Saying so in the type stops routes
 * declaring a 409 they can never return.
 */
export type AccessRefusal = 'not_found' | 'not_assigned_driver';
export type LifecycleRefusal = AccessRefusal | 'illegal_transition';
/** Reporting an arrival adds one more way to be wrong: a stop off the route. */
export type ArrivalRefusal = AccessRefusal | 'no_such_stop';

/** Either the updated trip, or why not. */
export type LifecycleResult = { ok: true; trip: Trip } | { ok: false; reason: LifecycleRefusal };

/** Either the trip with its progress advanced, or why not. */
export type ArrivalResult = { ok: true; trip: Trip } | { ok: false; reason: ArrivalRefusal };

/** Which day (or span of days) of a driver's schedule to return (#231). */
export interface MyTripsFilter {
  /** One UTC calendar day. */
  date?: string | undefined;
  /** Inclusive UTC day range — the month calendar, in one request. */
  from?: string | undefined;
  to?: string | undefined;
}

/** What a finished run actually did — the driver's end-of-trip screen. */
export interface RunSummary {
  tripId: string;
  boarded: number;
  /** Confirmed a seat and never boarded. NOT yet charged — see below. */
  notBoarded: number;
  /** Boardings by verification method, so we can see if QR works in the field. */
  byMethod: { qr: number; pin: number; photo: number };
  startedAt: Date | null;
  completedAt: Date | null;
  /** Stops on the run's route. Zero when no stops are attached to it yet. */
  stopCount: number;
}

/** Collaborators for {@link TripLifecycleService}. */
export interface TripLifecycleDeps {
  trips: TripRepository;
  drivers: DriverRepository;
  reservations: ReservationRepository;
  scanEvents: ScanEventRepository;
  /**
   * The route's ordered stops (#230) — the "of 11" in the stop counter, and the
   * bound an arrival is checked against. Optional: without it the summary
   * reports a stop count of zero, as it always has, and arrivals are refused
   * rather than written unchecked.
   */
  routeStops?: RouteStopRepository;
}

/** Forward only: scheduled -> active -> completed. Cancellation stays with ops. */
const ALLOWED: Record<TripStatus, readonly TripStatus[]> = {
  scheduled: ['active'],
  active: ['completed'],
  completed: [],
  cancelled: [],
};

/** Start/end a run and report what it did, for the trip's assigned driver. */
export class TripLifecycleService {
  /** @param deps - trip, driver, reservation and scan-event stores. */
  constructor(private readonly deps: TripLifecycleDeps) {}

  /**
   * Move a trip to `active`. Idempotent — a driver whose phone dropped mid-tap
   * will press it again, and an error at the roadside is the worse answer.
   *
   * @param tripId - the trip to start.
   * @param userId - the signed-in user, resolved to a driver.
   * @returns the updated trip, or why it was refused.
   */
  async start(tripId: string, userId: string): Promise<LifecycleResult> {
    return this.transition(tripId, userId, 'active');
  }

  /**
   * Move a trip to `completed`. Refuses one that never started — that means the
   * wrong run was tapped, and a completed trip with no trace poisons #179.
   *
   * @param tripId - the trip to complete.
   * @param userId - the signed-in user, resolved to a driver.
   * @returns the updated trip, or why it was refused.
   */
  async complete(tripId: string, userId: string): Promise<LifecycleResult> {
    return this.transition(tripId, userId, 'completed');
  }

  /**
   * The runs assigned to this driver — one UTC day, an inclusive range, or all
   * of them. Scoped to the caller so nobody can enumerate another driver's
   * schedule.
   *
   * @param userId - the signed-in user.
   * @param filter - one day (`date`) or a span (`from`/`to`); omit for all.
   * @returns the driver's trips, earliest first; empty when not a linked driver.
   */
  async myTrips(userId: string, filter: MyTripsFilter = {}): Promise<Trip[]> {
    const driver = await this.deps.drivers.findByUserId(userId);
    if (!driver) return [];
    const all = await this.deps.trips.findAll({
      date: filter.date,
      from: filter.from,
      to: filter.to,
    });
    return all
      .filter((t) => t.assignedDriverId === driver.id)
      .sort((a, b) => a.scheduledAt.getTime() - b.scheduledAt.getTime());
  }

  /**
   * Record that the driver has reached a stop, as a `route_stops.seq` (#230).
   *
   * Idempotent, and deliberately not monotonic. A driver who taps one stop too
   * far needs a way back, and refusing to go backwards would leave the counter
   * wrong for the rest of the run with no way to correct it. The seq is checked
   * against the route's real stops so it can only ever name one of them.
   *
   * @param tripId - the trip.
   * @param userId - the signed-in user, resolved to a driver.
   * @param seq - the stop reached.
   * @returns the updated trip, or why it was refused.
   */
  async arrive(tripId: string, userId: string, seq: number): Promise<ArrivalResult> {
    const guard = await this.authorize(tripId, userId);
    if (!guard.ok) return guard;

    const stops = this.deps.routeStops
      ? await this.deps.routeStops.findByRoute(guard.trip.routeId)
      : [];
    if (!stops.some((stop) => stop.seq === seq)) {
      return { ok: false, reason: 'no_such_stop' };
    }

    const updated = await this.deps.trips.update(tripId, { currentStopSeq: seq });
    return updated ? { ok: true, trip: updated } : { ok: false, reason: 'not_found' };
  }

  /**
   * What a run did. Reports `notBoarded`, not "deducted" — the debit is the
   * cutoff's decision, not this screen's.
   *
   * @param tripId - the trip.
   * @param userId - the signed-in user, resolved to a driver.
   * @returns the summary, or why it was refused.
   */
  async summary(
    tripId: string,
    userId: string,
  ): Promise<{ ok: true; summary: RunSummary } | { ok: false; reason: AccessRefusal }> {
    const guard = await this.authorize(tripId, userId);
    if (!guard.ok) return guard;

    const reservations = await this.deps.reservations.listForTrip(tripId);
    const events = await this.deps.scanEvents.listForTrip(tripId);
    const stops = this.deps.routeStops
      ? await this.deps.routeStops.findByRoute(guard.trip.routeId)
      : [];

    const byMethod = { qr: 0, pin: 0, photo: 0 };
    for (const e of events) {
      if (e.result === 'valid') byMethod[e.method] += 1; // a rejected scan is not a boarding
    }

    return {
      ok: true,
      summary: {
        tripId,
        boarded: reservations.filter((r) => r.status === 'boarded').length,
        notBoarded: reservations.filter((r) => r.status === 'reserved').length,
        byMethod,
        startedAt: guard.trip.startedAt,
        completedAt: guard.trip.completedAt,
        stopCount: stops.length,
      },
    };
  }

  /**
   * Resolve the caller to the trip's assigned driver.
   *
   * @param tripId - the trip.
   * @param userId - the signed-in user.
   * @returns the trip when authorized, or why not.
   */
  private async authorize(
    tripId: string,
    userId: string,
  ): Promise<{ ok: true; trip: Trip } | { ok: false; reason: AccessRefusal }> {
    const trip = await this.deps.trips.findById(tripId);
    if (!trip) return { ok: false, reason: 'not_found' };

    const driver = await this.deps.drivers.findByUserId(userId);
    if (!driver || trip.assignedDriverId !== driver.id) {
      return { ok: false, reason: 'not_assigned_driver' };
    }
    return { ok: true, trip };
  }

  /**
   * Apply a status change if the caller may and the transition is legal.
   *
   * @param tripId - the trip.
   * @param userId - the signed-in user.
   * @param to - the target status.
   * @returns the updated trip, or why it was refused.
   */
  private async transition(
    tripId: string,
    userId: string,
    to: TripStatus,
  ): Promise<LifecycleResult> {
    const guard = await this.authorize(tripId, userId);
    if (!guard.ok) return guard;

    const { trip } = guard;
    if (trip.status === to) return { ok: true, trip };
    if (!ALLOWED[trip.status].includes(to)) {
      return { ok: false, reason: 'illegal_transition' };
    }

    const stamps = to === 'active' ? { startedAt: new Date() } : { completedAt: new Date() };
    const updated = await this.deps.trips.update(tripId, { status: to, ...stamps });
    return updated ? { ok: true, trip: updated } : { ok: false, reason: 'not_found' };
  }
}
