// Driver work requests (#232) — the self-service hub on design page 19.
//
// One rule runs through all of it, and it is the design's own: "Submitting a
// request never changes the active or published assignment automatically."
// Nothing in this file writes to a trip. Approving a route change records that
// operations agreed; someone still has to move the driver deliberately, through
// the assignment endpoint, and the app tells drivers as much so they do not
// arrive at a corridor nobody rostered them onto.

import type { DriverRepository } from '../mobility/driver.repository';
import type { Route, RouteRepository } from '../mobility/route.repository';
import type { DriverRequest, DriverRequestRepository } from './driver-request.repository';

/** A route-change ask. */
export interface RouteChangeInput {
  userId: string;
  kind: 'route_change';
  routeId: string;
  /** When the driver would like it to take effect (`YYYY-MM-DD`). */
  fromDate?: string | null;
  note?: string | null;
}

/** A leave ask. */
export interface LeaveInput {
  userId: string;
  kind: 'leave';
  fromDate: string;
  toDate: string;
  /** The design also asks who covers; free text until there is a roster. */
  note?: string | null;
}

/** What the driver's app submits. */
export type SubmitRequestInput = RouteChangeInput | LeaveInput;

/**
 * Why a request was refused.
 *
 * `route_closed` is its own reason rather than a 404: the corridor exists and
 * the driver can see it on a map, so "not found" would read as a bug. It is
 * simply not open to requests.
 */
export type WorkRequestRefusal = 'not_a_driver' | 'route_not_found' | 'route_closed';

/** Either the submitted request, or why not. */
export type SubmitRequestResult =
  { ok: true; request: DriverRequest } | { ok: false; reason: WorkRequestRefusal };

/** Collaborators for {@link WorkRequestService}. */
export interface WorkRequestDeps {
  requests: DriverRequestRepository;
  drivers: DriverRepository;
  routes: RouteRepository;
}

/** Driver self-service requests and the routes open to them. */
export class WorkRequestService {
  /** @param deps - the request, driver and route stores. */
  constructor(private readonly deps: WorkRequestDeps) {}

  /**
   * Routes a driver may ask to be moved to.
   *
   * Not every corridor: the design shows routes "only when operations can accept
   * reassignment requests", which is a real constraint rather than a filter —
   * listing a corridor nobody intends to roster for collects requests that can
   * only ever be declined.
   *
   * @returns the routes open to requests.
   */
  async availableRoutes(): Promise<Route[]> {
    const routes = await this.deps.routes.findAll();
    return routes.filter((route) => route.acceptsRequests);
  }

  /**
   * Submit a request on behalf of the signed-in driver.
   *
   * @param input - the kind and the fields that kind carries.
   * @returns the stored `pending` request, or why it was refused.
   */
  async submit(input: SubmitRequestInput): Promise<SubmitRequestResult> {
    const driver = await this.deps.drivers.findByUserId(input.userId);
    if (!driver) return { ok: false, reason: 'not_a_driver' };

    if (input.kind === 'route_change') {
      const route = await this.deps.routes.findById(input.routeId);
      if (!route) return { ok: false, reason: 'route_not_found' };
      // Checked here, not only in the list: the app reads the open set once and
      // a driver can sit on that screen while ops closes the corridor.
      if (!route.acceptsRequests) return { ok: false, reason: 'route_closed' };

      return {
        ok: true,
        request: await this.deps.requests.create({
          driverId: driver.id,
          kind: 'route_change',
          routeId: route.id,
          fromDate: input.fromDate ?? null,
          note: input.note ?? null,
        }),
      };
    }

    return {
      ok: true,
      request: await this.deps.requests.create({
        driverId: driver.id,
        kind: 'leave',
        fromDate: input.fromDate,
        toDate: input.toDate,
        note: input.note ?? null,
      }),
    };
  }

  /**
   * The signed-in driver's own requests, newest first.
   *
   * @param userId - the signed-in user.
   * @returns their requests; empty when they are not a linked driver.
   */
  async listMine(userId: string): Promise<DriverRequest[]> {
    const driver = await this.deps.drivers.findByUserId(userId);
    if (!driver) return [];
    return this.deps.requests.listForDriver(driver.id);
  }

  /**
   * Take a pending request back.
   *
   * Scoped to the driver's own rows by the store, so a request id guessed or
   * copied from another driver withdraws nothing.
   *
   * @param id - the request to withdraw.
   * @param userId - the signed-in user.
   * @returns the withdrawn request, or null when it is missing, not theirs, or
   *   already decided.
   */
  async withdraw(id: string, userId: string): Promise<DriverRequest | null> {
    const driver = await this.deps.drivers.findByUserId(userId);
    if (!driver) return null;
    return this.deps.requests.withdraw(id, driver.id);
  }
}
