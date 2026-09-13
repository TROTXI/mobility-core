import type { Pool, PoolClient } from 'pg';
import type { SubscriptionPlan } from '../subscriptions/subscription.repository';
import type {
  NewPayment,
  Payment,
  PaymentPurpose,
  PaymentRepository,
  PaymentStatus,
  PaymentLifecyclePatch,
} from './payment.repository';
import { PendingSubscriptionPaymentError } from './payment.repository';

export interface PaymentRow {
  id: string;
  user_id: string;
  reference: string;
  purpose: PaymentPurpose;
  plan: SubscriptionPlan | null;
  route_id: string | null;
  pickup_stop_id: string | null;
  dropoff_stop_id: string | null;
  amount: number;
  applied_credit_pesewas: number;
  rides_granted: number | null;
  fare_pesewas: number | null;
  credit_pesewas_per_ride: number | null;
  currency: string;
  status: PaymentStatus;
  subscription_id: string | null;
  subscription_period_id: string | null;
  provider_transaction_id: string | null;
  provider_domain: 'test' | 'live' | null;
  channel: string | null;
  fees_pesewas: number | null;
  paid_at: Date | null;
  fulfilled_at: Date | null;
  refunded_pesewas: number;
  created_at: Date;
  updated_at: Date;
}

export function toPayment(row: PaymentRow): Payment {
  return {
    id: row.id,
    userId: row.user_id,
    reference: row.reference,
    purpose: row.purpose,
    plan: row.plan,
    routeId: row.route_id,
    pickupStopId: row.pickup_stop_id,
    dropoffStopId: row.dropoff_stop_id,
    amount: row.amount,
    appliedCreditPesewas: row.applied_credit_pesewas,
    ridesGranted: row.rides_granted,
    farePesewas: row.fare_pesewas,
    creditPesewasPerRide: row.credit_pesewas_per_ride,
    currency: row.currency,
    status: row.status,
    subscriptionId: row.subscription_id,
    subscriptionPeriodId: row.subscription_period_id,
    providerTransactionId: row.provider_transaction_id,
    providerDomain: row.provider_domain,
    channel: row.channel,
    feesPesewas: row.fees_pesewas,
    paidAt: row.paid_at,
    fulfilledAt: row.fulfilled_at,
    refundedPesewas: row.refunded_pesewas,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export class PgPaymentRepository implements PaymentRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewPayment): Promise<Payment> {
    if (input.purpose !== 'subscription') return this.insert(this.pool, input);

    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      // Serialize checkout creation per rider without introducing a permanent
      // uniqueness constraint that would reject historical staging rows.
      await client.query(`SELECT pg_advisory_xact_lock(hashtextextended($1, 0))`, [input.userId]);
      const { rows: pending } = await client.query<{ reference: string }>(
        `SELECT reference
           FROM payments
          WHERE user_id = $1 AND purpose = 'subscription' AND status = 'pending'
          LIMIT 1`,
        [input.userId],
      );
      if (pending[0]) throw new PendingSubscriptionPaymentError(pending[0].reference);

      const payment = await this.insert(client, input);
      await client.query('COMMIT');
      return payment;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  private async insert(client: Pick<Pool, 'query'> | Pick<PoolClient, 'query'>, input: NewPayment) {
    const { rows } = await client.query<PaymentRow>(
      `INSERT INTO payments (user_id, reference, purpose, plan, route_id, amount, currency,
                             rides_granted, fare_pesewas, credit_pesewas_per_ride,
                             applied_credit_pesewas, pickup_stop_id, dropoff_stop_id,
                             subscription_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING *`,
      [
        input.userId,
        input.reference,
        input.purpose,
        input.plan,
        input.routeId ?? null,
        input.amount,
        input.currency,
        input.ridesGranted ?? null,
        input.farePesewas ?? null,
        input.creditPesewasPerRide ?? null,
        input.appliedCreditPesewas ?? 0,
        input.pickupStopId ?? null,
        input.dropoffStopId ?? null,
        input.subscriptionId ?? null,
      ],
    );
    return toPayment(rows[0]!);
  }

  async findByReference(reference: string): Promise<Payment | null> {
    const { rows } = await this.pool.query<PaymentRow>(
      `SELECT * FROM payments WHERE reference = $1`,
      [reference],
    );
    return rows[0] ? toPayment(rows[0]) : null;
  }

  async listUnresolvedBefore(cutoff: Date, limit: number): Promise<Payment[]> {
    const { rows } = await this.pool.query<PaymentRow>(
      `SELECT * FROM payments
        WHERE status IN ('pending', 'processing') AND created_at <= $1
        ORDER BY created_at
        LIMIT $2`,
      [cutoff, Math.max(0, limit)],
    );
    return rows.map(toPayment);
  }

  async markPaid(reference: string): Promise<void> {
    // Only pending → paid; a paid row is never mutated again.
    await this.pool.query(
      `UPDATE payments SET status = 'paid', updated_at = now()
       WHERE reference = $1 AND status = 'pending'`,
      [reference],
    );
  }

  async markFailed(reference: string): Promise<void> {
    // Only pending → failed, for the same reason markPaid is one-way: a settled
    // row is the accounting record and a late webhook must not rewrite it.
    await this.pool.query(
      `UPDATE payments SET status = 'failed', updated_at = now()
       WHERE reference = $1 AND status = 'pending'`,
      [reference],
    );
  }

  async updateLifecycle(reference: string, patch: PaymentLifecyclePatch): Promise<Payment | null> {
    const { rows } = await this.pool.query<PaymentRow>(
      `UPDATE payments
          SET status = COALESCE($2, status),
              subscription_id = COALESCE($3, subscription_id),
              subscription_period_id = COALESCE($4, subscription_period_id),
              provider_transaction_id = COALESCE($5::bigint, provider_transaction_id),
              provider_domain = COALESCE($6, provider_domain),
              channel = COALESCE($7, channel),
              fees_pesewas = COALESCE($8, fees_pesewas),
              paid_at = COALESCE($9, paid_at),
              fulfilled_at = COALESCE($10, fulfilled_at),
              refunded_pesewas = COALESCE($11, refunded_pesewas),
              updated_at = now()
        WHERE reference = $1
        RETURNING *`,
      [
        reference,
        patch.status ?? null,
        patch.subscriptionId ?? null,
        patch.subscriptionPeriodId ?? null,
        patch.providerTransactionId ?? null,
        patch.providerDomain ?? null,
        patch.channel ?? null,
        patch.feesPesewas ?? null,
        patch.paidAt ?? null,
        patch.fulfilledAt ?? null,
        patch.refundedPesewas ?? null,
      ],
    );
    return rows[0] ? toPayment(rows[0]) : null;
  }
}
