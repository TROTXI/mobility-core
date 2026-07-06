import type { Pool } from 'pg';
import type {
  EntitlementEntry,
  EntitlementLedgerRepository,
} from './entitlement-ledger.repository';

export class PgEntitlementLedgerRepository implements EntitlementLedgerRepository {
  constructor(private readonly pool: Pool) {}

  async record(entry: EntitlementEntry): Promise<void> {
    await this.pool.query(
      `INSERT INTO entitlement_ledger (user_id, delta_rides, reason, ref_type, ref_id, idempotency_key)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (idempotency_key) DO NOTHING`,
      [
        entry.userId,
        entry.deltaRides,
        entry.reason,
        entry.refType ?? null,
        entry.refId ?? null,
        entry.idempotencyKey,
      ],
    );
  }

  async remainingRides(userId: string): Promise<number> {
    const { rows } = await this.pool.query<{ rides: number }>(
      `SELECT COALESCE(SUM(delta_rides), 0)::int AS rides FROM entitlement_ledger WHERE user_id = $1`,
      [userId],
    );
    return rows[0]!.rides;
  }
}
