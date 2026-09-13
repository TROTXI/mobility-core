// Payments — a state machine (pending → paid|failed), never mutated once paid.
// `reference` is unique and dedupes retried webhooks (system-design §4.2). A
// payment has a `purpose`: a subscription membership fee, or a wallet top-up.

import type { SubscriptionPlan } from '../subscriptions/subscription.repository';

/** Lifecycle of a payment; only `pending` may transition (never mutate `paid`). */
export type PaymentStatus =
  'pending' | 'processing' | 'paid' | 'fulfilled' | 'failed' | 'refunded' | 'disputed';

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
  /** Membership this payment renews/created; null until known. */
  subscriptionId: string | null;
  /** Exact billing period purchased; set atomically at fulfilment. */
  subscriptionPeriodId: string | null;
  /** Paystack transaction id, used by Verify and reconciliation. */
  providerTransactionId: string | null;
  /** Paystack environment (`test` | `live`). */
  providerDomain: 'test' | 'live' | null;
  /** Provider payment channel, e.g. mobile_money or card. */
  channel: string | null;
  /** Provider fee in pesewas. */
  feesPesewas: number | null;
  paidAt: Date | null;
  fulfilledAt: Date | null;
  refundedPesewas: number;
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
  /** Existing subscription being renewed; null for first purchase. */
  subscriptionId?: string | null;
}

/** Lifecycle metadata written by the atomic fulfilment adapter. */
export interface PaymentLifecyclePatch {
  status?: PaymentStatus;
  subscriptionId?: string | null;
  subscriptionPeriodId?: string | null;
  providerTransactionId?: string | null;
  providerDomain?: 'test' | 'live' | null;
  channel?: string | null;
  feesPesewas?: number | null;
  paidAt?: Date | null;
  fulfilledAt?: Date | null;
  refundedPesewas?: number;
}

/**
 * Raised when a rider already has an unresolved subscription checkout.
 *
 * A second pending payment can reserve the same Ride Credit and later grant a
 * second entitlement. Repositories enforce this at the serialization boundary,
 * not as a racy service-level read.
 */
export class PendingSubscriptionPaymentError extends Error {
  constructor(readonly reference: string) {
    super(`Subscription checkout ${reference} is still pending`);
    this.name = 'PendingSubscriptionPaymentError';
  }
}

/** Persistence for payments. Backed by Postgres in prod, in-memory in dev/tests. */
export interface PaymentRepository {
  /**
   * Insert a new payment in `pending` state.
   *
   * For subscription payments, this must atomically reject creation when the
   * same user already has a pending subscription payment.
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
  /**
   * Transition `pending → failed`. No-op once the row is settled either way, so
   * a webhook arriving out of order can never un-pay a paid subscription.
   *
   * @param reference - the payment to mark failed.
   */
  markFailed(reference: string): Promise<void>;
  /** In-memory lifecycle support; the PostgreSQL unit of work writes directly. */
  updateLifecycle(reference: string, patch: PaymentLifecyclePatch): Promise<Payment | null>;
}

/** In-memory {@link PaymentRepository} for dev and unit tests (no database). */
export class InMemoryPaymentRepository implements PaymentRepository {
  private readonly byReference = new Map<string, Payment>();

  async create(input: NewPayment): Promise<Payment> {
    if (input.purpose === 'subscription') {
      const pending = [...this.byReference.values()].find(
        (payment) =>
          payment.userId === input.userId &&
          payment.purpose === 'subscription' &&
          payment.status === 'pending',
      );
      if (pending) throw new PendingSubscriptionPaymentError(pending.reference);
    }
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
      subscriptionId: input.subscriptionId ?? null,
      subscriptionPeriodId: null,
      providerTransactionId: null,
      providerDomain: null,
      channel: null,
      feesPesewas: null,
      paidAt: null,
      fulfilledAt: null,
      refundedPesewas: 0,
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

  async markFailed(reference: string): Promise<void> {
    const payment = this.byReference.get(reference);
    if (payment && payment.status === 'pending') {
      payment.status = 'failed';
      payment.updatedAt = new Date();
    }
  }

  async updateLifecycle(reference: string, patch: PaymentLifecyclePatch): Promise<Payment | null> {
    const payment = this.byReference.get(reference);
    if (!payment) return null;
    Object.assign(payment, patch, { updatedAt: new Date() });
    return payment;
  }
}
