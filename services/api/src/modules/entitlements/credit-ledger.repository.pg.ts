import type { Pool } from 'pg';
import type { CreditEntry, CreditLedgerRepository } from './credit-ledger.repository';

export class PgCreditLedgerRepository implements CreditLedgerRepository {
  constructor(private readonly pool: Pool) {}

  async record(entry: CreditEntry): Promise<void> {
    await this.pool.query(
      `INSERT INTO credit_ledger (user_id, delta_pesewas, reason, ref_type, ref_id, idempotency_key)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (idempotency_key) DO NOTHING`,
      [
        entry.userId,
        entry.deltaPesewas,
        entry.reason,
        entry.refType ?? null,
        entry.refId ?? null,
        entry.idempotencyKey,
      ],
    );
  }

  async balancePesewas(userId: string): Promise<number> {
    const { rows } = await this.pool.query<{ pesewas: number }>(
      `SELECT COALESCE(SUM(delta_pesewas), 0)::int AS pesewas FROM credit_ledger WHERE user_id = $1`,
      [userId],
    );
    return rows[0]!.pesewas;
  }
}
