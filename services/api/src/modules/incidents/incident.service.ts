// Incident reporting (#226). A driver picks a category, and the server attaches
// the context the screen promises: the trip, the vehicle, the time, and the
// position the app last knew.
//
// The driver names the trip; the server resolves the vehicle from it. That is
// not a convenience — a report is evidence, and letting the reporter type which
// bus it happened in would make the one field ops most needs to trust the one
// field the app could get wrong.

import type { DriverRepository } from '../mobility/driver.repository';
import type { TripRepository } from '../mobility/trip.repository';
import type {
  DriverIncident,
  DriverIncidentRepository,
  IncidentCategory,
} from './driver-incident.repository';

/** What the driver's app sends. */
export interface FileIncidentInput {
  /** The signed-in user, resolved here to their fleet driver record. */
  userId: string;
  /** The run it happened on, when there is one. */
  tripId?: string | null;
  category: IncidentCategory;
  note?: string | null;
  lat?: number | null;
  lng?: number | null;
}

/**
 * Why a report was refused.
 *
 * `not_a_driver` covers a token with the driver role but no fleet row — rare,
 * but it is the difference between "we lost your report" and "your account is
 * not finished being set up", and ops needs to hear the second one.
 */
export type IncidentRefusal = 'not_a_driver' | 'trip_not_found' | 'not_assigned_driver';

/** Either the filed report, or why not. */
export type FileIncidentResult =
  { ok: true; incident: DriverIncident } | { ok: false; reason: IncidentRefusal };

/** Collaborators for {@link IncidentService}. */
export interface IncidentServiceDeps {
  incidents: DriverIncidentRepository;
  drivers: DriverRepository;
  /** Resolves the vehicle and checks the reporter is on the run they name. */
  trips: TripRepository;
}

/** Files driver incident reports and reads them back (see the file header). */
export class IncidentService {
  /** @param deps - the incident, driver and trip stores. */
  constructor(private readonly deps: IncidentServiceDeps) {}

  /**
   * File a report for the signed-in driver.
   *
   * A trip is optional: a broken door found in the yard at 05:20 is exactly the
   * report you want filed, and refusing it for want of an active run would mean
   * the van leaves anyway.
   *
   * @param input - the driver, the run, the category and any detail.
   * @returns the filed report, or why it was refused.
   */
  async file(input: FileIncidentInput): Promise<FileIncidentResult> {
    const driver = await this.deps.drivers.findByUserId(input.userId);
    if (!driver) return { ok: false, reason: 'not_a_driver' };

    let vehicleId: string | null = null;
    if (input.tripId) {
      const trip = await this.deps.trips.findById(input.tripId);
      if (!trip) return { ok: false, reason: 'trip_not_found' };
      // Same rule as the manifest and GPS reporting: a driver may only speak for
      // the run they are on. Without it, one account could attach a collision to
      // any trip in the fleet.
      if (trip.assignedDriverId !== driver.id) {
        return { ok: false, reason: 'not_assigned_driver' };
      }
      vehicleId = trip.vehicleId;
    }

    const incident = await this.deps.incidents.create({
      driverId: driver.id,
      tripId: input.tripId ?? null,
      vehicleId,
      category: input.category,
      note: input.note ?? null,
      lat: input.lat ?? null,
      lng: input.lng ?? null,
    });
    return { ok: true, incident };
  }

  /**
   * The signed-in driver's own reports, newest first.
   *
   * @param userId - the signed-in user.
   * @returns their reports; empty when they are not a linked driver.
   */
  async listMine(userId: string): Promise<DriverIncident[]> {
    const driver = await this.deps.drivers.findByUserId(userId);
    if (!driver) return [];
    return this.deps.incidents.listForDriver(driver.id);
  }
}
