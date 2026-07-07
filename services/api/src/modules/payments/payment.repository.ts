// Payments — a state machine (pending → paid|failed), never mutated once paid.
// `reference` is unique and dedupes retried webhooks (system-design §4.2). A
// payment has a `purpose`: a subscription membership fee, or a wallet top-up.

import type { SubscriptionPlan } from '../subscriptions/subscription.repository';

/** Lifecycle of a payment; only `pending` may transition (never mutate `paid`). */
export type PaymentStatus = 'pending' | 'paid' | 'failed';

/** Why the payment exists: a platform membership fee, or a wallet top-up. */
export type PaymentPurpose = 'subscription' | 'topup';

/** A persisted payment record. */
export interface Payment {
  /** Server-generated id. */
  id: string;
  /** The user who initiated the payment. */
  userId: string;
  /** Unique reference shared with Paystack; dedupes retried webhooks. */
  reference: string;
  /** Subscription fee or wallet top-up. */
  purpose: PaymentPurpose;
  /** Set for subscription payments; null for top-ups. */
  plan: SubscriptionPlan | null;
  /** Amount in pesewas (1 GHS = 100 pesewas). */
  amount: number;
  /** ISO 4217 currency code (currently always `GHS`). */
  currency: string;
  /** Current lifecycle state. */
  status: PaymentStatus;
  createdAt: Date;
  updatedAt: Date;
}

/** Fields needed to create a payment; the rest (id, status, timestamps) are set by the repo. */
export interface NewPayment {
  userId: string;
  reference: string;
  purpose: PaymentPurpose;
  plan: SubscriptionPlan | null;
  /** Amount in pesewas (1 GHS = 100 pesewas). */
  amount: number;
  currency: string;
}

/** Persistence for payments. Backed by Postgres in prod, in-memory in dev/tests. */
export interface PaymentRepository {
  /**
   * Insert a new payment in `pending` state.
   *
   * @param input - the payment to create (reference must be unique).
   * @returns the persisted payment, including its generated id and timestamps.
   */
  create(input: NewPayment): Promise<Payment>;
  /**
   * Look up a payment by its unique reference.
   *
   * @param reference - the reference shared with Paystack.
   * @returns the payment, or null if no payment has that reference.
   */
  findByReference(reference: string): Promise<Payment | null>;
  /**
   * Transition `pending → paid`. No-op if already paid (never mutate a paid row).
   *
   * @param reference - the payment to mark paid.
   */
  markPaid(reference: string): Promise<void>;
}

/** In-memory {@link PaymentRepository} for dev and unit tests (no database). */
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
