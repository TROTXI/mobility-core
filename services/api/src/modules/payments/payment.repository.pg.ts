import type { Pool } from 'pg';
import type { SubscriptionPlan } from '../subscriptions/subscription.repository';
import type {
  NewPayment,
  Payment,
  PaymentPurpose,
  PaymentRepository,
  PaymentStatus,
} from './payment.repository';

interface PaymentRow {
  id: string;
  user_id: string;
  reference: string;
  purpose: PaymentPurpose;
  plan: SubscriptionPlan | null;
  route_id: string | null;
  amount: number;
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
    amount: row.amount,
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
    const { rows } = await this.pool.query<PaymentRow>(
      `INSERT INTO payments (user_id, reference, purpose, plan, route_id, amount, currency,
                             rides_granted, fare_pesewas, credit_pesewas_per_ride)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
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
}
