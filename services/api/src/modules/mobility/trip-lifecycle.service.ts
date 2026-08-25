// Driver-owned trip lifecycle (#163). The two buttons that matter most in the
// driver app — "Start trip" and "End trip" — had no endpoint behind them.
// Transitions lived only on PATCH /admin/trips/:id, which is admin-only, so a
// dispatcher would have had to flip every run by hand from Swagger.
//
// Authorization is assigned-driver, not the `driver` role: the signed-in user
// must be linked to the driver THIS trip is assigned to. Same rule that already
// guards position reporting and the manifest, and the same reason — one driver
// must not be able to start, end, or read the manifest of another's run.

import type { ScanEventRepository } from '../boarding/scan-event.repository';
import type { ReservationRepository } from '../reservations/reservation.repository';
import type { DriverRepository } from './driver.repository';
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

/** Either the updated trip, or why not. */
export type LifecycleResult = { ok: true; trip: Trip } | { ok: false; reason: LifecycleRefusal };

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
  stopCount: number;
}

/** Collaborators for {@link TripLifecycleService}. */
export interface TripLifecycleDeps {
  trips: TripRepository;
  drivers: DriverRepository;
  reservations: ReservationRepository;
  scanEvents: ScanEventRepository;
}

/**
 * Legal transitions. A trip moves forward only:
 *   scheduled -> active -> completed
 * Cancellation stays with ops (a driver cancelling their own run is an
 * operational decision, not a driving one).
 */
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
   * Move a trip to `active`.
   *
   * Idempotent: starting an already-active trip succeeds rather than erroring.
   * A driver whose phone lost signal mid-tap will press it again, and a 409 at
   * the roadside is a worse answer than "yes, it is running".
   *
   * @param tripId - the trip to start.
   * @param userId - the signed-in user, resolved to a driver.
   * @returns the updated trip, or why it was refused.
   */
  async start(tripId: string, userId: string): Promise<LifecycleResult> {
    return this.transition(tripId, userId, 'active');
  }

  /**
   * Move a trip to `completed`.
   *
   * Completing a trip that never started is refused: it means the driver tapped
   * the wrong run, and silently accepting it would produce a "completed" trip
   * with no GPS trace, which then poisons route learning (#179).
   *
   * @param tripId - the trip to complete.
   * @param userId - the signed-in user, resolved to a driver.
   * @returns the updated trip, or why it was refused.
   */
  async complete(tripId: string, userId: string): Promise<LifecycleResult> {
    return this.transition(tripId, userId, 'completed');
  }

  /**
   * The runs assigned to this driver, optionally for one UTC day.
   *
   * Scoped to the caller rather than accepting a driver id, so one driver
   * cannot enumerate another's schedule.
   *
   * @param userId - the signed-in user.
   * @param date - optional `YYYY-MM-DD` filter.
   * @returns the driver's trips, earliest first; empty when not a linked driver.
   */
  async myTrips(userId: string, date?: string): Promise<Trip[]> {
    const driver = await this.deps.drivers.findByUserId(userId);
    if (!driver) return [];
    const all = await this.deps.trips.findAll(date ? { date } : undefined);
    return all
      .filter((t) => t.assignedDriverId === driver.id)
      .sort((a, b) => a.scheduledAt.getTime() - b.scheduledAt.getTime());
  }

  /**
   * What a run did: who boarded, who did not, and by which method.
   *
   * Reports `notBoarded` rather than "no-shows deducted". The debit is the
   * cutoff's job, not this screen's — a driver seeing "2 deducted" would be
   * reading a decision that has not been made yet.
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

    const byMethod = { qr: 0, pin: 0, photo: 0 };
    for (const e of events) {
      // Only successful verifications count; a rejected scan is not a boarding.
      if (e.result === 'valid') byMethod[e.method] += 1;
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
        stopCount: 0,
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
    // Already there: report success rather than erroring, so a retried tap is
    // safe (see start()).
    if (trip.status === to) return { ok: true, trip };
    if (!ALLOWED[trip.status].includes(to)) {
      return { ok: false, reason: 'illegal_transition' };
    }

    const stamps = to === 'active' ? { startedAt: new Date() } : { completedAt: new Date() };
    const updated = await this.deps.trips.update(tripId, { status: to, ...stamps });
    return updated ? { ok: true, trip: updated } : { ok: false, reason: 'not_found' };
  }
}
