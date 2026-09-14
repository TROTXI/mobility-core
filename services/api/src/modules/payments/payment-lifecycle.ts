import type { CreditLedgerRepository } from '../entitlements/credit-ledger.repository';
import type { EntitlementLedgerRepository } from '../entitlements/entitlement-ledger.repository';
import { periodFor } from '../subscriptions/period';
import type {
  NewSubscription,
  Subscription,
  SubscriptionRepository,
} from '../subscriptions/subscription.repository';
import type { NewPayment, Payment, PaymentRepository } from './payment.repository';
import { MIN_CHARGE_PESEWAS } from './pricing';

/** Checkout is refused while a paid period is still active. */
export class ActiveSubscriptionPaymentError extends Error {}

/** An old period without an accounting boundary must be reconciled by hand. */
export class UnscopedSubscriptionPeriodError extends Error {}

/** Period close waits until every funded reservation has a terminal outcome. */
export class PeriodCloseBlockedError extends Error {}

/** Frozen checkout facts plus the full price that credit may offset. */
export interface SubscriptionCheckoutInput extends Omit<
  NewPayment,
  'amount' | 'appliedCreditPesewas' | 'subscriptionId'
> {
  /** Full period price before Ride Credit. */
  pricePesewas: number;
  /** Injectable business clock. */
  now?: Date;
}

/** Provider facts required before a payment may grant value. */
export interface SettledCharge {
  reference: string;
  status: 'success';
  amountPesewas: number;
  currency: string;
  providerTransactionId: string;
  providerDomain: 'test' | 'live';
  channel: string | null;
  feesPesewas: number | null;
  paidAt: Date;
}

export type RefundStatus = 'pending' | 'processing' | 'needs_attention' | 'failed' | 'processed';

/** Signature-verified Paystack refund facts. */
export interface ProviderRefund {
  eventKey: string;
  reference: string;
  refundReference: string | null;
  amountPesewas: number;
  currency: string;
  providerDomain: 'test' | 'live';
  status: RefundStatus;
  payload: unknown;
}

/** Signature-verified Paystack dispute facts. */
export interface ProviderDispute {
  reference: string;
  providerDisputeId: string;
  amountPesewas: number;
  currency: string;
  providerDomain: 'test' | 'live';
  status: 'created' | 'reminded' | 'resolved';
  resolution: string | null;
  payload: unknown;
}

export type FulfillmentResult = 'fulfilled' | 'already_fulfilled' | 'not_pending' | 'mismatch';

/** Aggregate accounting result for a due-period sweep. */
export interface PeriodCloseResult {
  considered: number;
  closed: number;
  blocked: number;
  riders: number;
  ridesConverted: number;
  creditPesewas: number;
}

/** One unresolved provider or accounting item for operations review. */
export interface PaymentOperationsReview {
  id: string;
  kind: 'refund' | 'dispute' | 'manual_review';
  paymentReference: string;
  userId: string;
  paymentStatus: string;
  status: string;
  amountPesewas: number;
  resolution: string | null;
  consumedRides: number | null;
  unrecoveredCreditPesewas: number | null;
  estimatedDebtPesewas: number | null;
  createdAt: Date;
  updatedAt: Date;
}

/** Atomic money lifecycle boundary (PostgreSQL implementation in the sibling adapter). */
export interface PaymentLifecycle {
  /** Atomically close any ended period, reserve credit, and create the payment. */
  createSubscriptionCheckout(input: SubscriptionCheckoutInput): Promise<Payment>;
  /** Atomically turn a verified provider charge into membership value. */
  fulfillSubscriptionCharge(charge: SettledCharge): Promise<FulfillmentResult>;
  /** Atomically release a hold and terminally fail an unresolved payment. */
  failPendingPayment(reference: string, code: string, message: string): Promise<boolean>;
  /** Record refund progress; reverse unconsumed value only once cash is processed. */
  recordRefund(refund: ProviderRefund): Promise<boolean>;
  /** Freeze, remind, or resolve a provider dispute without guessing a cash reversal. */
  recordDispute(dispute: ProviderDispute): Promise<boolean>;
  /** Read unresolved provider and consumed-value items for operations. */
  listOperationsReviews(limit?: number): Promise<PaymentOperationsReview[]>;
  /** Atomically convert and close a bounded batch of periods due at the supplied instant. */
  closeEndedPeriods(now?: Date, limit?: number): Promise<PeriodCloseResult>;
}

interface InMemoryPeriod {
  id: string;
  subscriptionId: string;
  userId: string;
  start: Date;
  end: Date;
  creditPesewasPerRide: number;
  creditGrantedPesewas: number;
  status: 'open' | 'frozen' | 'closed' | 'reversed';
}

interface InMemoryPaymentLifecycleDeps {
  payments: PaymentRepository;
  subscriptions: SubscriptionRepository;
  entitlements: EntitlementLedgerRepository;
  credits: CreditLedgerRepository;
}

/**
 * In-memory implementation for local development and unit tests.
 *
 * Operations are serialized per rider. PostgreSQL provides rollback semantics;
 * this adapter keeps the same decisions and ordering without pretending an
 * in-memory collection is a database transaction.
 */
export class InMemoryPaymentLifecycle implements PaymentLifecycle {
  private readonly heldCredit = new Map<string, { userId: string; amount: number }>();
  private readonly periods = new Map<string, InMemoryPeriod>();
  private readonly renewableByUser = new Map<string, string>();
  private readonly disputedUsers = new Set<string>();
  private readonly refunds = new Map<string, ProviderRefund>();
  private readonly disputes = new Map<string, ProviderDispute>();
  private readonly manualReviews = new Map<string, PaymentOperationsReview>();
  private readonly tails = new Map<string, Promise<void>>();

  constructor(private readonly deps: InMemoryPaymentLifecycleDeps) {}

  async createSubscriptionCheckout(input: SubscriptionCheckoutInput): Promise<Payment> {
    return this.withUserLock(input.userId, async () => {
      if (this.disputedUsers.has(input.userId)) {
        throw new ActiveSubscriptionPaymentError('A disputed subscription is still unresolved');
      }
      const now = input.now ?? new Date();
      let renewableSubscriptionId = this.renewableByUser.get(input.userId) ?? null;
      const active = await this.deps.subscriptions.findActiveByUser(input.userId);
      if (active) {
        if (!active.periodEnd || active.periodEnd.getTime() > now.getTime()) {
          throw new ActiveSubscriptionPaymentError('An active subscription already exists');
        }
        await this.closeOne(active);
        renewableSubscriptionId = active.id;
      }

      const balance = await this.deps.credits.balancePesewas(input.userId);
      const held = [...this.heldCredit.values()]
        .filter((hold) => hold.userId === input.userId)
        .reduce((sum, hold) => sum + hold.amount, 0);
      const available = Math.max(0, balance - held);
      const appliedCreditPesewas = Math.max(
        0,
        Math.min(available, input.pricePesewas - MIN_CHARGE_PESEWAS),
      );
      const payment = await this.deps.payments.create({
        ...input,
        amount: input.pricePesewas - appliedCreditPesewas,
        appliedCreditPesewas,
        subscriptionId: renewableSubscriptionId,
      });
      if (appliedCreditPesewas > 0) {
        this.heldCredit.set(payment.reference, {
          userId: payment.userId,
          amount: appliedCreditPesewas,
        });
      }
      return payment;
    });
  }

  async fulfillSubscriptionCharge(charge: SettledCharge): Promise<FulfillmentResult> {
    const found = await this.deps.payments.findByReference(charge.reference);
    if (!found) return 'not_pending';
    return this.withUserLock(found.userId, async () => {
      const payment = await this.deps.payments.findByReference(charge.reference);
      if (!payment) return 'not_pending';
      if (payment.status === 'fulfilled' || payment.status === 'paid') return 'already_fulfilled';
      if (payment.status !== 'pending') return 'not_pending';
      if (
        charge.status !== 'success' ||
        charge.amountPesewas !== payment.amount ||
        charge.currency.toUpperCase() !== payment.currency.toUpperCase()
      ) {
        return 'mismatch';
      }
      if (!payment.plan) return 'mismatch';

      const hold = this.heldCredit.get(payment.reference);
      if ((hold?.amount ?? 0) !== payment.appliedCreditPesewas) {
        throw new Error('Payment credit hold does not match its applied credit');
      }
      if (hold) {
        const balance = await this.deps.credits.balancePesewas(payment.userId);
        if (balance < hold.amount) throw new Error('Reserved Ride Credit is no longer available');
      }

      const start = charge.paidAt;
      const period = periodFor(payment.plan, start);
      const periodId = crypto.randomUUID();
      const subscriptionInput: NewSubscription = {
        userId: payment.userId,
        plan: payment.plan,
        routeId: payment.routeId,
        pickupStopId: payment.pickupStopId,
        dropoffStopId: payment.dropoffStopId,
        pricePesewas: payment.amount + payment.appliedCreditPesewas,
        ridesGranted: payment.ridesGranted,
        farePesewas: payment.farePesewas,
        creditPesewasPerRide: payment.creditPesewasPerRide,
        periodStart: period.start,
        periodEnd: period.end,
      };

      let subscription: Subscription;
      if (payment.subscriptionId && this.deps.subscriptions.activatePeriod) {
        const renewed = await this.deps.subscriptions.activatePeriod(payment.subscriptionId, {
          ...subscriptionInput,
          currentPeriodId: periodId,
        });
        if (!renewed) throw new Error('Renewal subscription no longer exists');
        subscription = renewed;
      } else {
        subscription = await this.deps.subscriptions.create(subscriptionInput);
        if (this.deps.subscriptions.activatePeriod) {
          subscription =
            (await this.deps.subscriptions.activatePeriod(subscription.id, {
              ...subscriptionInput,
              currentPeriodId: periodId,
            })) ?? subscription;
        }
      }

      this.periods.set(periodId, {
        id: periodId,
        subscriptionId: subscription.id,
        userId: payment.userId,
        start: period.start,
        end: period.end,
        creditPesewasPerRide: payment.creditPesewasPerRide ?? 0,
        creditGrantedPesewas: 0,
        status: 'open',
      });
      if (hold) {
        await this.deps.credits.record({
          userId: payment.userId,
          deltaPesewas: -hold.amount,
          reason: 'renewal_applied',
          refType: 'payment',
          refId: payment.reference,
          idempotencyKey: `renewal:${payment.reference}`,
        });
        this.heldCredit.delete(payment.reference);
      }
      await this.deps.entitlements.record({
        userId: payment.userId,
        deltaRides: payment.ridesGranted ?? 0,
        reason: 'allocation',
        refType: 'payment',
        refId: payment.reference,
        idempotencyKey: `alloc:${payment.reference}`,
        subscriptionPeriodId: periodId,
      });
      await this.deps.payments.updateLifecycle(payment.reference, {
        status: 'fulfilled',
        subscriptionId: subscription.id,
        subscriptionPeriodId: periodId,
        providerTransactionId: charge.providerTransactionId,
        providerDomain: charge.providerDomain,
        channel: charge.channel,
        feesPesewas: charge.feesPesewas,
        paidAt: charge.paidAt,
        fulfilledAt: new Date(),
      });
      this.renewableByUser.delete(payment.userId);
      return 'fulfilled';
    });
  }

  async failPendingPayment(reference: string, _code: string, _message: string): Promise<boolean> {
    const found = await this.deps.payments.findByReference(reference);
    if (!found) return false;
    return this.withUserLock(found.userId, async () => {
      const payment = await this.deps.payments.findByReference(reference);
      if (!payment || (payment.status !== 'pending' && payment.status !== 'processing'))
        return false;
      this.heldCredit.delete(reference);
      await this.deps.payments.updateLifecycle(reference, { status: 'failed' });
      return true;
    });
  }

  async recordRefund(refund: ProviderRefund): Promise<boolean> {
    const payment = await this.deps.payments.findByReference(refund.reference);
    if (!payment || payment.currency.toUpperCase() !== refund.currency.toUpperCase()) return false;
    if (refund.amountPesewas <= 0 || refund.amountPesewas > payment.amount) return false;
    const key = refund.refundReference ?? `event:${refund.eventKey}`;
    const prior = this.refunds.get(key);
    const rank: Record<RefundStatus, number> = {
      pending: 0,
      processing: 1,
      needs_attention: 2,
      failed: 3,
      processed: 4,
    };
    const effective = prior && rank[prior.status] >= rank[refund.status] ? prior : refund;
    this.refunds.set(key, effective);
    if (effective.status !== 'processed' || !effective.refundReference) return true;

    return this.withUserLock(payment.userId, async () => {
      const processed = [...this.refunds.values()].filter(
        (item) =>
          item.reference === refund.reference &&
          item.status === 'processed' &&
          item.refundReference !== null,
      );
      const refunded = processed.reduce((sum, item) => sum + item.amountPesewas, 0);
      if (refunded > payment.amount) throw new Error('Processed refunds exceed the cash payment');
      await this.deps.payments.updateLifecycle(payment.reference, {
        refundedPesewas: refunded,
        ...(refunded === payment.amount ? { status: 'refunded' as const } : {}),
      });
      if (refunded !== payment.amount) {
        const disputes = [...this.disputes.values()].filter(
          (item) => item.reference === payment.reference,
        );
        const accepted = disputes
          .filter((item) => item.status === 'resolved' && item.resolution === 'merchant-accepted')
          .reduce((sum, item) => sum + item.amountPesewas, 0);
        if (
          accepted > 0 &&
          refunded >= accepted &&
          disputes.every((item) => item.status === 'resolved' && item.resolution !== null)
        ) {
          this.disputedUsers.delete(payment.userId);
          const period = payment.subscriptionPeriodId
            ? this.periods.get(payment.subscriptionPeriodId)
            : null;
          if (period?.status === 'frozen') period.status = 'open';
          await this.deps.payments.updateLifecycle(payment.reference, { status: 'fulfilled' });
        }
        return true;
      }
      if (!payment.subscriptionPeriodId) return true;
      const period = this.periods.get(payment.subscriptionPeriodId);
      if (!period || period.status === 'reversed') return true;
      const remaining = Math.max(
        0,
        await this.deps.entitlements.remainingRidesForPeriod(payment.subscriptionPeriodId),
      );
      const granted = Math.max(0, payment.ridesGranted ?? 0);
      const consumed = await this.deps.entitlements.consumedRidesForPeriod(
        payment.subscriptionPeriodId,
      );
      const held = [...this.heldCredit.values()]
        .filter((hold) => hold.userId === payment.userId)
        .reduce((sum, hold) => sum + hold.amount, 0);
      const availableCredit = Math.max(
        0,
        (await this.deps.credits.balancePesewas(payment.userId)) - held,
      );
      const recoveredConversionCredit = Math.min(period.creditGrantedPesewas, availableCredit);
      const unrecoveredConversionCredit = period.creditGrantedPesewas - recoveredConversionCredit;
      if (recoveredConversionCredit > 0) {
        await this.deps.credits.record({
          userId: payment.userId,
          deltaPesewas: -recoveredConversionCredit,
          reason: 'refund',
          refType: 'payment',
          refId: payment.reference,
          idempotencyKey: `refund-conversion-credit:${payment.reference}`,
        });
      }
      if (consumed > 0 || unrecoveredConversionCredit > 0) {
        const now = new Date();
        const rideDebtPesewas =
          consumed > 0
            ? Math.max(
                1,
                granted > 0
                  ? Math.round((payment.grossAmountPesewas * consumed) / granted)
                  : payment.grossAmountPesewas,
              )
            : 0;
        const estimatedDebtPesewas = rideDebtPesewas + unrecoveredConversionCredit;
        this.manualReviews.set(payment.id, {
          id: `manual:${payment.id}`,
          kind: 'manual_review',
          paymentReference: payment.reference,
          userId: payment.userId,
          paymentStatus: 'refunded',
          status: 'open',
          amountPesewas: estimatedDebtPesewas,
          resolution: null,
          consumedRides: consumed,
          unrecoveredCreditPesewas: unrecoveredConversionCredit,
          estimatedDebtPesewas,
          createdAt: this.manualReviews.get(payment.id)?.createdAt ?? now,
          updatedAt: now,
        });
      }
      if (remaining > 0) {
        await this.deps.entitlements.record({
          userId: payment.userId,
          deltaRides: -remaining,
          reason: 'refund',
          refType: 'payment',
          refId: payment.reference,
          idempotencyKey: `refund-rides:${payment.reference}`,
          subscriptionPeriodId: payment.subscriptionPeriodId,
        });
      }
      if (payment.appliedCreditPesewas > 0) {
        await this.deps.credits.record({
          userId: payment.userId,
          deltaPesewas: payment.appliedCreditPesewas,
          reason: 'refund',
          refType: 'payment',
          refId: payment.reference,
          idempotencyKey: `refund-credit:${payment.reference}`,
        });
      }
      period.status = 'reversed';
      if (payment.subscriptionId) {
        await this.deps.subscriptions.rollPeriod(payment.subscriptionId, { status: 'expired' });
      }
      this.disputedUsers.delete(payment.userId);
      return true;
    });
  }

  async recordDispute(dispute: ProviderDispute): Promise<boolean> {
    const payment = await this.deps.payments.findByReference(dispute.reference);
    if (!payment || payment.currency.toUpperCase() !== dispute.currency.toUpperCase()) return false;
    if (dispute.amountPesewas <= 0 || dispute.amountPesewas > payment.amount) return false;
    const prior = this.disputes.get(dispute.providerDisputeId);
    const rank = { created: 0, reminded: 1, resolved: 2 } as const;
    const effective = prior && rank[prior.status] >= rank[dispute.status] ? prior : dispute;
    this.disputes.set(dispute.providerDisputeId, effective);
    if (effective.status === 'resolved' && effective.resolution === 'declined') {
      this.disputedUsers.delete(payment.userId);
      const period = payment.subscriptionPeriodId
        ? this.periods.get(payment.subscriptionPeriodId)
        : null;
      if (period?.status === 'frozen') period.status = 'open';
      await this.deps.payments.updateLifecycle(payment.reference, { status: 'fulfilled' });
      return true;
    }
    this.disputedUsers.add(payment.userId);
    const period = payment.subscriptionPeriodId
      ? this.periods.get(payment.subscriptionPeriodId)
      : null;
    if (period?.status === 'open') period.status = 'frozen';
    await this.deps.payments.updateLifecycle(payment.reference, { status: 'disputed' });
    return true;
  }

  async listOperationsReviews(limit = 100): Promise<PaymentOperationsReview[]> {
    const reviews: PaymentOperationsReview[] = [...this.manualReviews.values()];
    for (const [id, refund] of this.refunds) {
      if (refund.status === 'processed') continue;
      const payment = await this.deps.payments.findByReference(refund.reference);
      if (!payment) continue;
      reviews.push({
        id: `refund:${id}`,
        kind: 'refund',
        paymentReference: payment.reference,
        userId: payment.userId,
        paymentStatus: payment.status,
        status: refund.status,
        amountPesewas: refund.amountPesewas,
        resolution: null,
        consumedRides: null,
        unrecoveredCreditPesewas: null,
        estimatedDebtPesewas: null,
        createdAt: payment.createdAt,
        updatedAt: payment.updatedAt,
      });
    }
    for (const [id, dispute] of this.disputes) {
      const refunded = [...this.refunds.values()]
        .filter((item) => item.reference === dispute.reference && item.status === 'processed')
        .reduce((sum, item) => sum + item.amountPesewas, 0);
      if (
        dispute.status === 'resolved' &&
        (dispute.resolution === 'declined' ||
          (dispute.resolution === 'merchant-accepted' && refunded >= dispute.amountPesewas))
      ) {
        continue;
      }
      const payment = await this.deps.payments.findByReference(dispute.reference);
      if (!payment) continue;
      reviews.push({
        id: `dispute:${id}`,
        kind: 'dispute',
        paymentReference: payment.reference,
        userId: payment.userId,
        paymentStatus: payment.status,
        status: dispute.status,
        amountPesewas: dispute.amountPesewas,
        resolution: dispute.resolution,
        consumedRides: null,
        unrecoveredCreditPesewas: null,
        estimatedDebtPesewas: null,
        createdAt: payment.createdAt,
        updatedAt: payment.updatedAt,
      });
    }
    return reviews
      .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())
      .slice(0, Math.max(0, Math.floor(limit)));
  }

  async closeEndedPeriods(now: Date = new Date(), limit = 100): Promise<PeriodCloseResult> {
    const boundedLimit = Math.max(0, Math.floor(limit));
    const due = (await this.deps.subscriptions.findEndedPeriods(now)).slice(0, boundedLimit);
    const totals: PeriodCloseResult = {
      considered: due.length,
      closed: 0,
      blocked: 0,
      riders: 0,
      ridesConverted: 0,
      creditPesewas: 0,
    };
    for (const subscription of due) {
      await this.withUserLock(subscription.userId, async () => {
        const result = await this.closeOne(subscription);
        totals.closed++;
        if (result.rides > 0) totals.riders++;
        totals.ridesConverted += result.rides;
        totals.creditPesewas += result.credit;
      });
    }
    return totals;
  }

  private async closeOne(subscription: Subscription): Promise<{ rides: number; credit: number }> {
    if (!subscription.currentPeriodId) {
      throw new UnscopedSubscriptionPeriodError(
        `Subscription ${subscription.id} has no current period accounting row`,
      );
    }
    const period = this.periods.get(subscription.currentPeriodId);
    if (!period) {
      throw new UnscopedSubscriptionPeriodError(
        `Subscription period ${subscription.currentPeriodId} is not loaded`,
      );
    }
    if (period.status === 'closed') return { rides: 0, credit: 0 };
    const remaining = Math.max(0, await this.deps.entitlements.remainingRidesForPeriod(period.id));
    const credit = remaining * period.creditPesewasPerRide;
    period.creditGrantedPesewas = credit;
    if (remaining > 0) {
      await this.deps.credits.record({
        userId: subscription.userId,
        deltaPesewas: credit,
        reason: 'month_end_conversion',
        refType: 'period',
        refId: period.id,
        idempotencyKey: `close-credit:${period.id}`,
      });
      await this.deps.entitlements.record({
        userId: subscription.userId,
        deltaRides: -remaining,
        reason: 'converted',
        refType: 'period',
        refId: period.id,
        idempotencyKey: `close-rides:${period.id}`,
        subscriptionPeriodId: period.id,
      });
    }
    await this.deps.subscriptions.rollPeriod(subscription.id, { status: 'expired' });
    period.status = 'closed';
    this.renewableByUser.set(subscription.userId, subscription.id);
    return { rides: remaining, credit };
  }

  private async withUserLock<T>(userId: string, operation: () => Promise<T>): Promise<T> {
    const previous = this.tails.get(userId) ?? Promise.resolve();
    let release!: () => void;
    const current = new Promise<void>((resolve) => {
      release = resolve;
    });
    const tail = previous.catch(() => undefined).then(() => current);
    this.tails.set(userId, tail);
    await previous.catch(() => undefined);
    try {
      return await operation();
    } finally {
      release();
      if (this.tails.get(userId) === tail) this.tails.delete(userId);
    }
  }
}
