import type { Pool } from 'pg';
import type {
  LedgerEntry,
  LedgerReason,
  LedgerRefType,
  LedgerRepository,
  NewLedgerEntry,
} from './ledger.repository';

interface LedgerRow {
  id: string;
  user_id: string;
  delta: number;
  reason: LedgerReason;
  ref_type: LedgerRefType;
  ref_id: string | null;
  idempotency_key: string;
  created_at: Date;
}

function toEntry(row: LedgerRow): LedgerEntry {
  return {
    id: row.id,
    userId: row.user_id,
    delta: row.delta,
    reason: row.reason,
    refType: row.ref_type,
    refId: row.ref_id,
    idempotencyKey: row.idempotency_key,
    createdAt: row.created_at,
  };
}

export class PgLedgerRepository implements LedgerRepository {
  constructor(private readonly pool: Pool) {}

  async append(input: NewLedgerEntry): Promise<LedgerEntry> {
    // Exactly-once: the unique idempotency_key makes a retried write a no-op.
    const { rows } = await this.pool.query<LedgerRow>(
      `INSERT INTO token_ledger (user_id, delta, reason, ref_type, ref_id, idempotency_key)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (idempotency_key) DO NOTHING
       RETURNING *`,
      [
        input.userId,
        input.delta,
        input.reason,
        input.refType,
        input.refId ?? null,
        input.idempotencyKey,
      ],
    );
    if (rows[0]) return toEntry(rows[0]);

    const existing = await this.pool.query<LedgerRow>(
      `SELECT * FROM token_ledger WHERE idempotency_key = $1`,
      [input.idempotencyKey],
    );
    return toEntry(existing.rows[0]!);
  }

  async balanceOf(userId: string): Promise<number> {
    const { rows } = await this.pool.query<{ balance: number }>(
      `SELECT COALESCE(SUM(delta), 0)::int AS balance FROM token_ledger WHERE user_id = $1`,
      [userId],
    );
    return rows[0]!.balance;
  }
}
