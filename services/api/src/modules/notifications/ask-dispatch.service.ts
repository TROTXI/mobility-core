// Daily ask-dispatch (E3) — the scheduled heart of the confirmation loop. For a
// travel day + direction, it finds tomorrow's trips, seeds a `pending`
// reservation for every active subscriber of each trip's route, and pushes the
// "travelling?" prompt. At the cutoff, resolveDefaults flips the still-`pending`
// rows to reserved (default-yes). These are the operations a Render cron invokes
// (via the admin endpoints); the cron schedule itself is infra.
//
// A rider is linked to a route by their subscription (ADR-0014 / the pilot
// rider↔route model): confirm at subscribe → the route pins the subscription →
// this targets those subscribers.

import { directionOf } from '../mobility/direction';
import type { VehicleRepository } from '../mobility/vehicle.repository';
import type { TripRepository } from '../mobility/trip.repository';
import type {
  ReservationDirection,
  ReservationRepository,
} from '../reservations/reservation.repository';
import type { SubscriptionRepository } from '../subscriptions/subscription.repository';
import type { NotificationSender } from './notification.sender';

/** Collaborators for {@link AskDispatchService}. */
export interface AskDispatchDeps {
  trips: TripRepository;
  subscriptions: SubscriptionRepository;
  reservations: ReservationRepository;
  notifier: NotificationSender;
  /**
   * Seat ceiling per trip (#161). Absent -> the cutoff defaults everyone, as
   * before. Present -> riders are never defaulted into a seat that does not
   * exist, which is how an overfull trip used to get worse at 21:00.
   */
  vehicles?: VehicleRepository;
}

/** How many riders were prompted, across how many trips. */
export interface AskDispatchResult {
  trips: number;
  asked: number;
}

/** The daily ask-dispatch + cutoff default-yes (see the file header). */
export class AskDispatchService {
  /** @param deps - the trip, subscription, reservation stores + the notifier. */
  constructor(private readonly deps: AskDispatchDeps) {}

  /**
   * Prompt every active subscriber of each of the day's trips (for the given
   * direction): seed a `pending` reservation and push the "travelling?" ask.
   * Idempotent — re-running leaves existing reservations untouched (createPending
   * no-ops a duplicate day+direction).
   *
   * @param travelDate - the travel day (`YYYY-MM-DD`).
   * @param direction - morning or evening (matches the trip's scheduled time).
   * @returns how many trips were dispatched and riders prompted.
   */
  async dispatchAsks(
    travelDate: string,
    direction: ReservationDirection,
  ): Promise<AskDispatchResult> {
    const trips = (await this.deps.trips.findAll({ date: travelDate, status: 'scheduled' })).filter(
      (t) => directionOf(t.scheduledAt) === direction,
    );
    const label = direction === 'morning' ? 'tomorrow morning' : 'this evening';
    let asked = 0;
    for (const trip of trips) {
      const subs = await this.deps.subscriptions.findActiveByRoute(trip.routeId);
      for (const sub of subs) {
        await this.deps.reservations.createPending({
          userId: sub.userId,
          tripId: trip.id,
          travelDate,
          direction,
        });
        await this.deps.notifier.send({
          userId: sub.userId,
          title: `Travelling ${label}?`,
          body: 'Tap to confirm your seat, or decline to release it.',
          data: { tripId: trip.id, travelDate, direction },
        });
        asked++;
      }
    }
    return { trips: trips.length, asked };
  }

  /**
   * Cutoff default-yes: flip every still-`pending` reservation for the
   * day+direction to `reserved` (a no-response is treated as travelling).
   *
   * @param travelDate - the travel day (`YYYY-MM-DD`).
   * @param direction - morning or evening.
   * @returns how many were defaulted, and how many were skipped because their
   *   trip was already full.
   */
  async resolveDefaults(
    travelDate: string,
    direction: ReservationDirection,
  ): Promise<{ defaulted: number; skippedFull: number }> {
    return this.deps.reservations.markDefaultTravelling(
      travelDate,
      direction,
      this.deps.vehicles ? (tripId) => this.capacityOf(tripId) : undefined,
    );
  }

  /**
   * The seat ceiling for a trip, or null when it has none.
   *
   * A trip with no vehicle assigned is unlimited, not zero: ops routinely
   * creates trips before assigning a bus, and treating that as zero would stop
   * anyone reserving on a run that has not been crewed yet.
   *
   * @param tripId - the trip.
   * @returns the vehicle's capacity, or null for unlimited.
   */
  private async capacityOf(tripId: string): Promise<number | null> {
    const trip = await this.deps.trips.findById(tripId);
    if (!trip?.vehicleId) return null;
    const vehicle = await this.deps.vehicles!.findById(trip.vehicleId);
    // capacity 0 means "not recorded" in the fleet data, not "no seats".
    return vehicle && vehicle.capacity > 0 ? vehicle.capacity : null;
  }
}
