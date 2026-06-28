// Payments — a state machine (pending → paid|failed), never mutated once paid.
// `reference` is unique and dedupes retried webhooks (system-design §4.2). A
// payment has a `purpose`: a subscription membership fee, or a wallet top-up.

import type { SubscriptionPlan } from '../subscriptions/subscription.repository';

export type PaymentStatus = 'pending' | 'paid' | 'failed';
export type PaymentPurpose = 'subscription' | 'topup';

export interface Payment {
  id: string;
  userId: string;
  reference: string;
  purpose: PaymentPurpose;
  /** Set for subscription payments; null for top-ups. */
  plan: SubscriptionPlan | null;
  amount: number; // GHS
  currency: string;
  status: PaymentStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface NewPayment {
  userId: string;
  reference: string;
  purpose: PaymentPurpose;
  plan: SubscriptionPlan | null;
  amount: number;
  currency: string;
}

export interface PaymentRepository {
  create(input: NewPayment): Promise<Payment>;
  findByReference(reference: string): Promise<Payment | null>;
  /** Transition pending → paid. No-op if already paid (never mutate a paid row). */
  markPaid(reference: string): Promise<void>;
}

export class InMemoryPaymentRepository implements PaymentRepository {
  private readonly byReference = new Map<string, Payment>();

  async create(input: NewPayment): Promise<Payment> {
    const now = new Date();
    const payment: Payment = {
      id: crypto.randomUUID(),
      userId: input.userId,
      reference: input.reference,
      purpose: input.purpose,
      plan: input.plan,
      amount: input.amount,
      currency: input.currency,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    };
    this.byReference.set(payment.reference, payment);
    return payment;
  }

  async findByReference(reference: string): Promise<Payment | null> {
    return this.byReference.get(reference) ?? null;
  }

  async markPaid(reference: string): Promise<void> {
    const payment = this.byReference.get(reference);
    if (payment && payment.status === 'pending') {
      payment.status = 'paid';
      payment.updatedAt = new Date();
    }
  }
}
