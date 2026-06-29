// Token ledger — the rider's wallet, in pesewas (system-design §4.1, ADR-0011).
// Append-only: every entry is immutable; the balance is the SUM of deltas, never
// a stored column. Writes are exactly-once via idempotency_key, so a retried
// grant or debit is a no-op rather than a double-spend.

export type LedgerReason = 'topup' | 'boarding' | 'refund';
export type LedgerRefType = 'payment' | 'boarding';

export interface LedgerEntry {
  id: string;
  userId: string;
  /** Pesewas-denominated (1 GHS = 100 pesewas): + for grants, − for spends. */
  delta: number;
  reason: LedgerReason;
  refType: LedgerRefType;
  refId: string | null;
  idempotencyKey: string;
  createdAt: Date;
}

export interface NewLedgerEntry {
  userId: string;
  delta: number;
  reason: LedgerReason;
  refType: LedgerRefType;
  refId?: string | null;
  idempotencyKey: string;
}

export interface LedgerRepository {
  /** Append an entry; if the idempotency key already exists, return the existing
   *  row unchanged (idempotent — no second write). */
  append(entry: NewLedgerEntry): Promise<LedgerEntry>;
  /** Derived balance for a user = SUM(delta). 0 when there are no entries. */
  balanceOf(userId: string): Promise<number>;
}

export class InMemoryLedgerRepository implements LedgerRepository {
  private readonly entries: LedgerEntry[] = [];
  private readonly byKey = new Map<string, LedgerEntry>();

  async append(input: NewLedgerEntry): Promise<LedgerEntry> {
    const existing = this.byKey.get(input.idempotencyKey);
    if (existing) return existing;

    const entry: LedgerEntry = {
      id: crypto.randomUUID(),
      userId: input.userId,
      delta: input.delta,
      reason: input.reason,
      refType: input.refType,
      refId: input.refId ?? null,
      idempotencyKey: input.idempotencyKey,
      createdAt: new Date(),
    };
    this.entries.push(entry);
    this.byKey.set(entry.idempotencyKey, entry);
    return entry;
  }

  async balanceOf(userId: string): Promise<number> {
    return this.entries.filter((e) => e.userId === userId).reduce((sum, e) => sum + e.delta, 0);
  }
}
