// Driver manifest (#20, E4) — the "photo pass": the riders expected to board,
// each with a name and short-lived signed avatar URL. The photo comes from the
// SERVER, never the QR (security.md §7), so a faker can't embed their own face.
// Only confirmed seats appear (reserved | boarded).
//
// A rider whose user lookup fails still appears with a null name — the driver
// should see every seat.

import type { ObjectStore } from '../../storage/object-store';
import type { Reservation, ReservationRepository } from '../reservations/reservation.repository';
import type { UserRepository } from '../users/user.repository';

/** One line on a driver's manifest. */
export interface ManifestRider {
  reservationId: string;
  userId: string;
  /** The rider's display name (null if the user record is missing). */
  name: string | null;
  /** Short-lived signed avatar URL, or null when the rider has no photo. */
  avatarUrl: string | null;
  direction: Reservation['direction'];
  /** Whether the rider has already been verified onto the vehicle. */
  boarded: boolean;
}

/** Collaborators for {@link ManifestService}. */
export interface ManifestServiceDeps {
  reservations: ReservationRepository;
  users: UserRepository;
  objectStore: ObjectStore;
}

/** Builds the driver manifest for a trip (see the file header). */
export class ManifestService {
  /** @param deps - the reservation store, user store, and object store. */
  constructor(private readonly deps: ManifestServiceDeps) {}

  /**
   * The manifest for a trip: confirmed riders with name + signed photo.
   *
   * @param tripId - the trip whose riders to list.
   * @returns the manifest riders (morning before evening).
   */
  async getManifest(tripId: string): Promise<ManifestRider[]> {
    const reservations = await this.deps.reservations.listForTrip(tripId);
    const confirmed = reservations.filter(
      (rsv) => rsv.status === 'reserved' || rsv.status === 'boarded',
    );
    return Promise.all(
      confirmed.map(async (rsv) => {
        const user = await this.deps.users.findById(rsv.userId);
        const avatarUrl = user?.avatarUrl
          ? await this.deps.objectStore.signedUrl(user.avatarUrl)
          : null;
        return {
          reservationId: rsv.id,
          userId: rsv.userId,
          name: user?.displayName ?? null,
          avatarUrl,
          direction: rsv.direction,
          boarded: rsv.status === 'boarded',
        };
      }),
    );
  }
}
