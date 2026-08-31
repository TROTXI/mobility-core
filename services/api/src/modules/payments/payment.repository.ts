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
  /** The route the rider is subscribing to (E3); carried to the subscription on activation. */
  routeId: string | null;
  /** Where the rider boards, frozen at checkout (#204). */
  pickupStopId: string | null;
  /** Where the rider alights, frozen at checkout (#204). */
  dropoffStopId: string | null;
  /** Rides this payment buys, frozen at checkout (#103). Null for pre-#103 rows. */
  ridesGranted: number | null;
  /** The corridor fare the price was derived from, frozen at checkout. */
  farePesewas: number | null;
  /** Ride Credit value per unused ride, frozen at checkout. */
  creditPesewasPerRide: number | null;
  /** Amount CHARGED in pesewas, already net of `appliedCreditPesewas`. */
  amount: number;
  /** Ride Credit netted off this checkout, frozen at initiation (#128). */
  appliedCreditPesewas: number;
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
  routeId?: string | null;
  /** Where the rider boards, frozen at checkout (#204). */
  pickupStopId?: string | null;
  /** Where the rider alights, frozen at checkout (#204). */
  dropoffStopId?: string | null;
  /** Amount CHARGED in pesewas, already net of `appliedCreditPesewas`. */
  amount: number;
  /** Ride Credit netted off this checkout (#128). Defaults to 0. */
  appliedCreditPesewas?: number;
  currency: string;
  /** Rides this payment buys, frozen at checkout (#103). Null pre-#103. */
  ridesGranted?: number | null;
  /** The corridor fare the price was derived from, frozen at checkout. */
  farePesewas?: number | null;
  /** Ride Credit value per unused ride, frozen at checkout. */
  creditPesewasPerRide?: number | null;
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
      routeId: input.routeId ?? null,
      pickupStopId: input.pickupStopId ?? null,
      dropoffStopId: input.dropoffStopId ?? null,
      amount: input.amount,
      appliedCreditPesewas: input.appliedCreditPesewas ?? 0,
      currency: input.currency,
      ridesGranted: input.ridesGranted ?? null,
      farePesewas: input.farePesewas ?? null,
      creditPesewasPerRide: input.creditPesewasPerRide ?? null,
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
