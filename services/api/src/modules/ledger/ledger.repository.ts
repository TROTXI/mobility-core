// Token ledger — the rider's wallet, in pesewas (system-design §4.1, ADR-0011).
// Append-only: every entry is immutable; the balance is the SUM of deltas, never
// a stored column. Writes are exactly-once via idempotency_key, so a retried
// grant or debit is a no-op rather than a double-spend.

/** Why a ledger entry exists: a wallet top-up, a boarding spend, or a refund. */
export type LedgerReason = 'topup' | 'boarding' | 'refund';

/** What an entry references: the payment that funded it, or the boarding that spent it. */
export type LedgerRefType = 'payment' | 'boarding';

/** One immutable wallet movement. The balance is the SUM of these deltas. */
export interface LedgerEntry {
  id: string;
  userId: string;
  /** Pesewas-denominated (1 GHS = 100 pesewas): + for grants, − for spends. */
  delta: number;
  reason: LedgerReason;
  refType: LedgerRefType;
  /** The id of the referenced payment/boarding, if any. */
  refId: string | null;
  /** Unique key making the append exactly-once (no double grant/spend). */
  idempotencyKey: string;
  createdAt: Date;
}

/** Fields needed to append a ledger entry. */
export interface NewLedgerEntry {
  userId: string;
  /** Pesewas; positive to grant, negative to spend. */
  delta: number;
  reason: LedgerReason;
  refType: LedgerRefType;
  refId?: string | null;
  /** Unique key; a repeated key is a no-op (returns the existing entry). */
  idempotencyKey: string;
}

/** The append-only token wallet. Backed by Postgres in prod, in-memory in dev/tests. */
export interface LedgerRepository {
  /**
   * Append an entry. If the idempotency key already exists, returns the existing
   * row unchanged (idempotent — no second write).
   *
   * @param entry - the movement to record.
   * @returns the persisted (or pre-existing) entry.
   */
  append(entry: NewLedgerEntry): Promise<LedgerEntry>;
  /**
   * Derived balance for a user = SUM(delta).
   *
   * @param userId - the wallet owner.
   * @returns the balance in pesewas (0 when there are no entries).
   */
  balanceOf(userId: string): Promise<number>;
}

/** In-memory {@link LedgerRepository} for dev and unit tests. */
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
