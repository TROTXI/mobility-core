// Driver work requests (#232) — a driver asking operations to move them to
// another corridor, or for days off. Repository pattern (ADR-0009): interface +
// InMemory here, Postgres in *.pg.ts.
//
// The rule the design hangs on: "Submitting a request never changes the active
// or published assignment automatically." A request is its own record with its
// own status, and nothing here is read by the assignment path. Approving one is
// a note that ops agreed; moving the driver is still a separate, deliberate
// PUT /admin/trips/:id/assignment.

/** What is being asked for. */
export const REQUEST_KINDS = ['route_change', 'leave'] as const;
export type RequestKind = (typeof REQUEST_KINDS)[number];

/** Where the ask has got to. */
export const REQUEST_STATUSES = ['pending', 'approved', 'declined', 'withdrawn'] as const;
export type RequestStatus = (typeof REQUEST_STATUSES)[number];

/** One request, as submitted and as operations left it. */
export interface DriverRequest {
  id: string;
  driverId: string;
  kind: RequestKind;
  status: RequestStatus;
  /** route_change: the corridor asked for. Null for leave. */
  routeId: string | null;
  /** leave: the first day off. route_change: when it should take effect. */
  fromDate: string | null;
  /** leave: the last day off. Null for route_change. */
  toDate: string | null;
  note: string | null;
  decidedBy: string | null;
  decidedAt: Date | null;
  decisionNote: string | null;
  createdAt: Date;
  updatedAt: Date;
}

/** Fields to submit a request. */
export interface NewDriverRequest {
  driverId: string;
  kind: RequestKind;
  routeId?: string | null;
  fromDate?: string | null;
  toDate?: string | null;
  note?: string | null;
}

/** How operations answers one. */
export interface RequestDecision {
  status: Exclude<RequestStatus, 'pending' | 'withdrawn'>;
  decidedBy: string;
  decisionNote?: string | null;
}

/** Persistence for driver work requests. */
export interface DriverRequestRepository {
  /**
   * Submit a request.
   *
   * @param input - the driver, the kind, and the fields that kind carries.
   * @returns the stored request, `pending`.
   */
  create(input: NewDriverRequest): Promise<DriverRequest>;
  /**
   * Look up one request.
   *
   * @param id - the request id.
   * @returns the request, or null.
   */
  findById(id: string): Promise<DriverRequest | null>;
  /**
   * A driver's own requests, newest first — the tracking list in the design.
   *
   * @param driverId - the fleet driver.
   * @returns their requests.
   */
  listForDriver(driverId: string): Promise<DriverRequest[]>;
  /**
   * The operations queue, newest first.
   *
   * @param filter - optional status filter; omit for everything.
   * @param filter.status - only requests in this state.
   * @returns the matching requests.
   */
  list(filter?: { status?: RequestStatus }): Promise<DriverRequest[]>;
  /**
   * Record operations' answer. Only a `pending` request can be decided, so a
   * second approval cannot overwrite who decided the first one.
   *
   * @param id - the request id.
   * @param decision - approved or declined, by whom, with any note.
   * @returns the updated request, or null when missing or no longer pending.
   */
  decide(id: string, decision: RequestDecision): Promise<DriverRequest | null>;
  /**
   * The driver taking it back. Scoped to the driver so one cannot withdraw
   * another's, and to `pending` so a decision cannot be erased.
   *
   * @param id - the request id.
   * @param driverId - the driver withdrawing it.
   * @returns the updated request, or null when missing, theirs, or decided.
   */
  withdraw(id: string, driverId: string): Promise<DriverRequest | null>;
}

/** In-memory {@link DriverRequestRepository} for dev and unit tests. */
export class InMemoryDriverRequestRepository implements DriverRequestRepository {
  private readonly rows: DriverRequest[] = [];

  async create(input: NewDriverRequest): Promise<DriverRequest> {
    const now = new Date();
    const request: DriverRequest = {
      id: crypto.randomUUID(),
      driverId: input.driverId,
      kind: input.kind,
      status: 'pending',
      routeId: input.routeId ?? null,
      fromDate: input.fromDate ?? null,
      toDate: input.toDate ?? null,
      note: input.note ?? null,
      decidedBy: null,
      decidedAt: null,
      decisionNote: null,
      createdAt: now,
      updatedAt: now,
    };
    this.rows.push(request);
    return request;
  }

  async findById(id: string): Promise<DriverRequest | null> {
    return this.rows.find((r) => r.id === id) ?? null;
  }

  async listForDriver(driverId: string): Promise<DriverRequest[]> {
    return this.newestFirst(this.rows.filter((r) => r.driverId === driverId));
  }

  async list(filter?: { status?: RequestStatus }): Promise<DriverRequest[]> {
    return this.newestFirst(this.rows.filter((r) => !filter?.status || r.status === filter.status));
  }

  async decide(id: string, decision: RequestDecision): Promise<DriverRequest | null> {
    const i = this.rows.findIndex((r) => r.id === id && r.status === 'pending');
    if (i < 0) return null;
    const now = new Date();
    const updated: DriverRequest = {
      ...this.rows[i]!,
      status: decision.status,
      decidedBy: decision.decidedBy,
      decidedAt: now,
      decisionNote: decision.decisionNote ?? null,
      updatedAt: now,
    };
    this.rows[i] = updated;
    return updated;
  }

  async withdraw(id: string, driverId: string): Promise<DriverRequest | null> {
    const i = this.rows.findIndex(
      (r) => r.id === id && r.driverId === driverId && r.status === 'pending',
    );
    if (i < 0) return null;
    const updated: DriverRequest = { ...this.rows[i]!, status: 'withdrawn', updatedAt: new Date() };
    this.rows[i] = updated;
    return updated;
  }

  /**
   * Newest first, the order both the driver's list and the ops queue read in.
   *
   * @param rows - the requests to order (not mutated).
   * @returns a new array, newest first.
   */
  private newestFirst(rows: DriverRequest[]): DriverRequest[] {
    return [...rows].sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
  }
}
