// Driver-facing push (#233). Until now the only sender was the rider
// ask-dispatch fan-out, so a driver whose run was moved at 04:00 found out by
// opening the app and noticing.
//
// Scope is deliberately one event: the assignment changed. Rider confirmations
// and cancellations move the manifest count all the way to the first stop, and
// pushing each of them would train drivers to ignore the channel that has to
// work when the run itself moves. The app pulls the manifest on focus instead.
//
// Nothing here throws. A push that fails must not fail the admin write that
// caused it — the change is real whether or not the phone heard about it, and
// `trips.assignment_changed_at` is what the app reads back either way.

import type { DriverRepository } from '../mobility/driver.repository';
import type { Trip } from '../mobility/trip.repository';
import type { NotificationSender } from './notification.sender';

/** Collaborators for {@link DriverNotifier}. */
export interface DriverNotifierDeps {
  notifier: NotificationSender;
  /** Resolves a fleet driver to the user account their devices are registered to. */
  drivers: DriverRepository;
}

/** What actually changed about a run, in the words a driver would use. */
type ChangeKind = 'assigned' | 'unassigned' | 'vehicle' | 'retimed';

/** Announces assignment changes to the drivers they affect. */
export class DriverNotifier {
  /** @param deps - the push sender and the driver store. */
  constructor(private readonly deps: DriverNotifierDeps) {}

  /**
   * Tell whoever is affected that a run moved.
   *
   * Compares the trip before and after the admin write rather than taking the
   * patch, because the patch says what was submitted and this needs what
   * actually changed: reassigning a trip to the driver already on it should
   * notify nobody.
   *
   * At most two drivers are involved in any one change, so the sequential loop
   * here is not the unbatched fan-out #160 flags on ask-dispatch — that one
   * iterates a corridor's whole subscriber list.
   *
   * @param before - the trip as it was.
   * @param after - the trip as it now is.
   */
  async assignmentChanged(before: Trip, after: Trip): Promise<void> {
    const driverChanged = before.assignedDriverId !== after.assignedDriverId;

    if (driverChanged) {
      if (after.assignedDriverId) {
        await this.tell(after.assignedDriverId, after, 'assigned');
      }
      // The driver who lost the run needs to hear it more than the one who
      // gained it: they are the one who would otherwise turn up for it.
      if (before.assignedDriverId) {
        await this.tell(before.assignedDriverId, after, 'unassigned');
      }
      return;
    }

    // Same driver. Tell them what moved under them, and only if something did.
    if (!after.assignedDriverId) return;
    if (before.scheduledAt.getTime() !== after.scheduledAt.getTime()) {
      await this.tell(after.assignedDriverId, after, 'retimed');
    } else if (before.vehicleId !== after.vehicleId) {
      await this.tell(after.assignedDriverId, after, 'vehicle');
    }
  }

  /**
   * Send one driver one message, swallowing anything that goes wrong.
   *
   * @param driverId - the fleet driver to reach.
   * @param trip - the trip as it now stands.
   * @param kind - what changed.
   */
  private async tell(driverId: string, trip: Trip, kind: ChangeKind): Promise<void> {
    try {
      const driver = await this.deps.drivers.findById(driverId);
      // A fleet row with no linked user has no device to push to. Expected
      // rather than exceptional: `drivers.user_id` has been nullable since 015.
      if (!driver?.userId) return;

      await this.deps.notifier.send({
        userId: driver.userId,
        title: TITLES[kind],
        body: BODIES[kind],
        // The app opens straight onto the run. `changedAt` lets it decide
        // whether this is news or the push it already acted on.
        data: {
          tripId: trip.id,
          change: kind,
          scheduledAt: trip.scheduledAt.toISOString(),
          ...(trip.assignmentChangedAt
            ? { changedAt: trip.assignmentChangedAt.toISOString() }
            : {}),
        },
      });
    } catch (err) {
      console.error('driver-notify: assignment change push failed', err);
    }
  }
}

/**
 * Titles a driver reads on a lock screen, in the dark, holding a wheel. Short,
 * and specific enough that the notification alone is sometimes the whole
 * message.
 */
const TITLES: Record<ChangeKind, string> = {
  assigned: 'New run assigned',
  unassigned: 'Run removed from your schedule',
  vehicle: 'Vehicle changed',
  retimed: 'Departure time changed',
};

const BODIES: Record<ChangeKind, string> = {
  assigned: 'Open Trotxi Driver to see the route and departure time.',
  unassigned: 'You are no longer driving this run. Check your schedule.',
  vehicle: 'A different bus has been assigned to your run.',
  retimed: 'Your run now departs at a different time. Open it to check.',
};
