import type { Pool, PoolClient } from 'pg';
import type { SubscriptionPlan } from '../subscriptions/subscription.repository';
import type {
  NewPayment,
  Payment,
  PaymentPurpose,
  PaymentRepository,
  PaymentStatus,
} from './payment.repository';
import { PendingSubscriptionPaymentError } from './payment.repository';

interface PaymentRow {
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
  created_at: Date;
  updated_at: Date;
}

function toPayment(row: PaymentRow): Payment {
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
                             applied_credit_pesewas, pickup_stop_id, dropoff_stop_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
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
}
