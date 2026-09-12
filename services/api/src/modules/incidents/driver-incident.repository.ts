// Driver incident reports (#226) — what a driver sends from the roadside, and
// the queue operations works through. Repository pattern (ADR-0009): interface +
// InMemory here, Postgres in *.pg.ts.
//
// Emergency is deliberately absent. The design draws EMERGENCY HELP apart from
// reporting because it needs a person on a phone now, and a row in a queue is
// not that; it dials the operations number from GET /flags (#234).

/** The design's five categories, kept literally — they exist to route a report
 * to whoever can act on it. A generic severity scale would lose that. */
export const INCIDENT_CATEGORIES = [
  'vehicle',
  'collision',
  'passenger_safety',
  'route_blocked',
  'other',
] as const;
export type IncidentCategory = (typeof INCIDENT_CATEGORIES)[number];

/** Where a report has got to in operations. */
export const INCIDENT_STATUSES = ['open', 'acknowledged', 'resolved'] as const;
export type IncidentStatus = (typeof INCIDENT_STATUSES)[number];

/** One report, as filed and as operations left it. */
export interface DriverIncident {
  id: string;
  driverId: string;
  /** The run it happened on; null for a yard report before any trip. */
  tripId: string | null;
  /** Resolved from the trip when it has one, so the driver never picks it. */
  vehicleId: string | null;
  category: IncidentCategory;
  note: string | null;
  /** Current or last-known position, as the screen promises it attaches. */
  lat: number | null;
  lng: number | null;
  status: IncidentStatus;
  handledBy: string | null;
  handledAt: Date | null;
  resolution: string | null;
  /** When it happened — not when the row arrived, which differs in a dead spot. */
  occurredAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

/** Fields to file a report; the rest are set by the repository or by ops. */
export interface NewDriverIncident {
  driverId: string;
  tripId?: string | null;
  vehicleId?: string | null;
  category: IncidentCategory;
  note?: string | null;
  lat?: number | null;
  lng?: number | null;
  occurredAt?: Date;
}

/** How operations closes a report out. */
export interface IncidentDecision {
  status: IncidentStatus;
  handledBy: string;
  resolution?: string | null;
}

/** Persistence for driver incident reports. */
export interface DriverIncidentRepository {
  /**
   * File a report.
   *
   * @param input - the driver, context, category and optional detail.
   * @returns the stored report.
   */
  create(input: NewDriverIncident): Promise<DriverIncident>;
  /**
   * Look up one report.
   *
   * @param id - the report id.
   * @returns the report, or null.
   */
  findById(id: string): Promise<DriverIncident | null>;
  /**
   * A driver's own reports, newest first — their support screen's history.
   *
   * @param driverId - the fleet driver.
   * @returns their reports.
   */
  listForDriver(driverId: string): Promise<DriverIncident[]>;
  /**
   * The operations queue, newest first.
   *
   * @param filter - optional status filter; omit for everything.
   * @param filter.status - only reports in this state.
   * @returns the matching reports.
   */
  list(filter?: { status?: IncidentStatus }): Promise<DriverIncident[]>;
  /**
   * Record what operations did with a report.
   *
   * @param id - the report id.
   * @param decision - the new status, who decided, and any note.
   * @returns the updated report, or null if not found.
   */
  decide(id: string, decision: IncidentDecision): Promise<DriverIncident | null>;
}

/** In-memory {@link DriverIncidentRepository} for dev and unit tests. */
export class InMemoryDriverIncidentRepository implements DriverIncidentRepository {
  private readonly rows: DriverIncident[] = [];

  async create(input: NewDriverIncident): Promise<DriverIncident> {
    const now = new Date();
    const incident: DriverIncident = {
      id: crypto.randomUUID(),
      driverId: input.driverId,
      tripId: input.tripId ?? null,
      vehicleId: input.vehicleId ?? null,
      category: input.category,
      note: input.note ?? null,
      lat: input.lat ?? null,
      lng: input.lng ?? null,
      status: 'open',
      handledBy: null,
      handledAt: null,
      resolution: null,
      occurredAt: input.occurredAt ?? now,
      createdAt: now,
      updatedAt: now,
    };
    this.rows.push(incident);
    return incident;
  }

  async findById(id: string): Promise<DriverIncident | null> {
    return this.rows.find((r) => r.id === id) ?? null;
  }

  async listForDriver(driverId: string): Promise<DriverIncident[]> {
    return this.newestFirst(this.rows.filter((r) => r.driverId === driverId));
  }

  async list(filter?: { status?: IncidentStatus }): Promise<DriverIncident[]> {
    return this.newestFirst(this.rows.filter((r) => !filter?.status || r.status === filter.status));
  }

  async decide(id: string, decision: IncidentDecision): Promise<DriverIncident | null> {
    const i = this.rows.findIndex((r) => r.id === id);
    if (i < 0) return null;
    const now = new Date();
    const updated: DriverIncident = {
      ...this.rows[i]!,
      status: decision.status,
      handledBy: decision.handledBy,
      handledAt: now,
      resolution: decision.resolution ?? this.rows[i]!.resolution,
      updatedAt: now,
    };
    this.rows[i] = updated;
    return updated;
  }

  /**
   * Newest first, the order both the driver's history and the ops queue read in.
   *
   * @param rows - the reports to order (not mutated).
   * @returns a new array, newest first.
   */
  private newestFirst(rows: DriverIncident[]): DriverIncident[] {
    return [...rows].sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }
}
