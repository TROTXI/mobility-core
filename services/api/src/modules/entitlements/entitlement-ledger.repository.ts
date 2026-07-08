// Entitlement ledger — the rider's ride balance as an append-only, idempotent
// ledger (ADR-0014, epic E1). Remaining rides = SUM(delta_rides); there is no
// mutable count column (system-design §4.1 — the same no-lost-update reasoning
// as the old token wallet). Repository pattern (ADR-0009): interface + InMemory
// here, Postgres in *.pg.ts.

/** Why an entitlement row exists. */
export type EntitlementReason =
  | 'allocation'
  | 'boarding'
  | 'no_show'
  | 'returned'
  | 'refund'
  /** Month-end conversion of unused rides to Ride Credits (E5) — the ride debit. */
  | 'converted';

/** A single append to the entitlement ledger. */
export interface EntitlementEntry {
  /** The rider the rides belong to. */
  userId: string;
  /** Signed ride delta: +N on allocation, -1 on boarding/no_show, +1 on return. */
  deltaRides: number;
  /** Why this row exists. */
  reason: EntitlementReason;
  /** What the row references, e.g. `payment` or `reservation` (no FK yet). */
  refType?: string | null;
  /** The referenced id (a payment reference, reservation id, …). */
  refId?: string | null;
  /** Unique key making the write exactly-once — a retry with the same key is a no-op. */
  idempotencyKey: string;
}

/** Append-only ride-entitlement ledger (Postgres in prod, in-memory in dev/tests). */
export interface EntitlementLedgerRepository {
  /**
   * Append an entry. A duplicate `idempotencyKey` is a no-op (exactly-once).
   *
   * @param entry - the ride delta to record.
   */
  record(entry: EntitlementEntry): Promise<void>;
  /**
   * The rider's remaining rides (the sum of their deltas).
   *
   * @param userId - the rider.
   * @returns remaining rides (0 when the ledger is empty).
   */
  remainingRides(userId: string): Promise<number>;
}

/** In-memory {@link EntitlementLedgerRepository} for dev and unit tests. */
export class InMemoryEntitlementLedgerRepository implements EntitlementLedgerRepository {
  private readonly entries: EntitlementEntry[] = [];
  private readonly keys = new Set<string>();

  async record(entry: EntitlementEntry): Promise<void> {
    if (this.keys.has(entry.idempotencyKey)) return;
    this.keys.add(entry.idempotencyKey);
    this.entries.push(entry);
  }

  async remainingRides(userId: string): Promise<number> {
    return this.entries
      .filter((e) => e.userId === userId)
      .reduce((sum, e) => sum + e.deltaRides, 0);
  }
}
