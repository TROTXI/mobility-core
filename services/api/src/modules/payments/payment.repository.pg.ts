import type { Pool } from 'pg';
import type { SubscriptionPlan } from '../subscriptions/subscription.repository';
import type { NewPayment, Payment, PaymentRepository, PaymentStatus } from './payment.repository';

interface PaymentRow {
  id: string;
  user_id: string;
  reference: string;
  plan: SubscriptionPlan;
  amount: number;
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
    plan: row.plan,
    amount: row.amount,
    currency: row.currency,
    status: row.status,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export class PgPaymentRepository implements PaymentRepository {
  constructor(private readonly pool: Pool) {}

  async create(input: NewPayment): Promise<Payment> {
    const { rows } = await this.pool.query<PaymentRow>(
      `INSERT INTO payments (user_id, reference, plan, amount, currency)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [input.userId, input.reference, input.plan, input.amount, input.currency],
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
}
