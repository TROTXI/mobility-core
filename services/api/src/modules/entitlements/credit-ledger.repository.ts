// Credit ledger — the rider's Ride Credit balance (in PESEWAS) as an append-only,
// idempotent ledger (ADR-0014, epic E1). Balance = SUM(delta_pesewas). Credits
// come from month-end conversion of unused rides (E5), operator compensation, or
// loyalty, and are spent against a renewal. This is the store; the conversion
// job lives in E5. Repository pattern (ADR-0009): interface + InMemory here,
// Postgres in *.pg.ts.

/** Why a credit row exists. */
export type CreditReason = 'month_end_conversion' | 'compensation' | 'loyalty' | 'renewal_applied';

/** A single append to the credit ledger. */
export interface CreditEntry {
  /** The rider the credit belongs to. */
  userId: string;
  /** Signed pesewas delta: +N when credit is granted, -N when applied to a renewal. */
  deltaPesewas: number;
  /** Why this row exists. */
  reason: CreditReason;
  /** What the row references (e.g. a subscription period or payment). */
  refType?: string | null;
  /** The referenced id. */
  refId?: string | null;
  /** Unique key making the write exactly-once — a retry with the same key is a no-op. */
  idempotencyKey: string;
}

/** Append-only Ride Credit ledger (Postgres in prod, in-memory in dev/tests). */
export interface CreditLedgerRepository {
  /**
   * Append an entry. A duplicate `idempotencyKey` is a no-op (exactly-once).
   *
   * @param entry - the credit delta to record.
   */
  record(entry: CreditEntry): Promise<void>;
  /**
   * The rider's credit balance in pesewas (the sum of their deltas).
   *
   * @param userId - the rider.
   * @returns balance in pesewas (0 when the ledger is empty).
   */
  balancePesewas(userId: string): Promise<number>;
}

/** In-memory {@link CreditLedgerRepository} for dev and unit tests. */
export class InMemoryCreditLedgerRepository implements CreditLedgerRepository {
  private readonly entries: CreditEntry[] = [];
  private readonly keys = new Set<string>();

  async record(entry: CreditEntry): Promise<void> {
    if (this.keys.has(entry.idempotencyKey)) return;
    this.keys.add(entry.idempotencyKey);
    this.entries.push(entry);
  }

  async balancePesewas(userId: string): Promise<number> {
    return this.entries
      .filter((e) => e.userId === userId)
      .reduce((sum, e) => sum + e.deltaPesewas, 0);
  }
}
