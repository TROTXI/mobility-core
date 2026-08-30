// PaymentsService — Paystack money-in: initiate a subscription checkout and
// process the charge.success webhook that activates it. Money is in PESEWAS
// (integers, never floats), matching Paystack.
//
// Checkouts are netted against the rider's Ride Credit balance (#128): the
// applied amount is frozen on the payment at initiation, and the ledger is
// debited on charge.success — never at checkout, or an abandoned checkout would
// burn credit the rider never spent.
//
// Deliberately not one DB transaction (system-design §4.2 "idempotent
// webhooks"): each step is individually idempotent — the one-active-per-user
// index guards activation, markPaid only does pending→paid — so a retried or
// partial webhook converges.

import { normaliseGhanaPhone } from '../../lib/phone';
import type { CreditLedgerRepository } from '../entitlements/credit-ledger.repository';
import type { EntitlementLedgerRepository } from '../entitlements/entitlement-ledger.repository';
import type {
  SubscriptionPlan,
  SubscriptionRepository,
} from '../subscriptions/subscription.repository';
import type { UserRepository } from '../users/user.repository';
import { periodFor } from '../subscriptions/period';
import { derivePrice, netCharge, type DerivedPrice } from './pricing';
import type { PricingRepository } from './pricing.repository';
import type { NewPayment, Payment, PaymentRepository } from './payment.repository';
import type { PaystackClient } from './paystack.client';

/**
 * Thrown when a payments operation is attempted but no Paystack client is wired
 * (e.g. production without `PAYSTACK_SECRET_KEY`). Routes map it to HTTP 503.
 */
export class PaymentsNotConfiguredError extends Error {}

/**
 * Thrown when a corridor has no fare in force, or a plan has no pricing row.
 * Routes map it to HTTP 409: the request is well-formed, the corridor simply is
 * not priced yet. Deliberately not a fallback to some default — charging a
 * number nobody chose is exactly what #103 exists to stop.
 */
export class NotPricedError extends Error {}

/**
 * Thrown when an incoming Paystack webhook fails signature verification. Routes
 * map it to HTTP 401.
 */
export class InvalidWebhookError extends Error {}

/**
 * Fallback ride count for payments created before #103, whose rows carry no
 * frozen `ridesGranted`. Live pricing comes from `plan_pricing`; this only
 * exists so replaying an old webhook still allocates something sane.
 */
export const PLACEHOLDER_RIDES_PER_PERIOD = 44;

/** Collaborators for {@link PaymentsService}, injected at app wiring (app.ts). */
export interface PaymentsServiceDeps {
  /** Persists payment records (the pending → paid|failed state machine). */
  payments: PaymentRepository;
  /** Platform memberships — activated on a successful subscription payment. */
  subscriptions: SubscriptionRepository;
  /** Ride entitlement ledger — allocated on a successful subscription payment. */
  entitlements: EntitlementLedgerRepository;
  /** Ride Credit ledger — netted off a checkout and debited on success (#128). */
  credits?: CreditLedgerRepository;
  /** Undefined when payments aren't configured (e.g. prod without a Paystack key). */
  paystack?: PaystackClient;
  /** Users, for capturing the payer's verified phone on charge.success (#182). */
  users: UserRepository;
  /** Corridor fares + plan levers (#103). Prices are derived, never stored. */
  pricing: PricingRepository;
  /** Rides allocated per activated period (placeholder until E1b tiers). */
  ridesPerPeriod: number;
}

/**
 * True when a pg error is a unique-constraint violation (SQLSTATE 23505).
 *
 * @param err - the caught error (unknown shape).
 * @returns whether it is a Postgres unique-violation.
 */
function isUniqueViolation(err: unknown): boolean {
  return (err as { code?: string }).code === '23505';
}

/** The subset of Paystack's webhook payload we read. */
interface PaystackWebhookEvent {
  event?: string;
  data?: {
    reference?: string;
    /** Present on mobile-money charges; the handset that approved the debit. */
    customer?: { phone?: string | null };
    authorization?: { mobile_money_number?: string | null };
  };
}

/** What initiating a checkout returns to the caller (and the route). */
export interface CheckoutResult {
  /** Paystack hosted-checkout URL to redirect the user to. */
  authorizationUrl: string;
  /** Our unique payment reference, echoed back by the webhook for reconciliation. */
  reference: string;
  /** Full period price before credit, so the client can show the saving. */
  pricePesewas: number;
  /** Ride Credit netted off this checkout (#128). */
  appliedCreditPesewas: number;
  /** What Paystack is charging: `pricePesewas - appliedCreditPesewas`. */
  chargePesewas: number;
}

/**
 * Orchestrates the membership money-in flow on top of Paystack: initiates the
 * subscription checkout and processes the `charge.success` webhook that
 * confirms it. See the file header for the idempotency model.
 */
export class PaymentsService {
  /** @param deps - repositories, the Paystack client, and the fee table. */
  constructor(private readonly deps: PaymentsServiceDeps) {}

  /**
   * Start a Paystack checkout for the platform membership fee. Records a
   * `pending` payment and returns a hosted checkout URL; the subscription is
   * activated later, by {@link handleWebhook} on `charge.success` — not here.
   *
   * @param userId - the authenticated user subscribing.
   * @param plan - membership tier (`monthly` | `annual`); selects the fee.
   * @param routeId - the rider's pinned route/corridor (E3), carried to the
   *   subscription on activation.
   * @returns the Paystack `authorizationUrl` and our payment `reference`.
   * @throws PaymentsNotConfiguredError when no Paystack client is wired.
   */
  async initializeSubscription(
    userId: string,
    plan: SubscriptionPlan,
    routeId: string,
  ): Promise<CheckoutResult> {
    const price = await this.priceFor(plan, routeId);
    const balance = this.deps.credits ? await this.deps.credits.balancePesewas(userId) : 0;
    const { appliedCreditPesewas, chargePesewas } = netCharge(price.pricePesewas, balance);
    const checkout = await this.startCheckout({
      userId,
      purpose: 'subscription',
      plan,
      routeId,
      amount: chargePesewas,
      appliedCreditPesewas,
      currency: 'GHS',
      // Frozen here, not at activation: a fare moving between checkout and
      // charge.success would grant rides priced against a fare never paid.
      ridesGranted: price.ridesGranted,
      farePesewas: price.farePesewas,
      creditPesewasPerRide: price.creditPesewasPerRide,
    });
    return { ...checkout, pricePesewas: price.pricePesewas, appliedCreditPesewas, chargePesewas };
  }

  /**
   * Derive what this rider pays for this plan on this corridor.
   *
   * routeId is required, unlike before: the price depends on the corridor's
   * regulated fare, so there is no meaningful price for "some route".
   *
   * @param plan - the plan tier.
   * @param routeId - the corridor being subscribed to.
   * @returns the derived price and everything snapshotted with it.
   * @throws NotPricedError when the corridor has no fare or the plan no levers.
   */
  async priceFor(plan: SubscriptionPlan, routeId: string): Promise<DerivedPrice> {
    const [fare, pricing] = await Promise.all([
      this.deps.pricing.currentFare(routeId),
      this.deps.pricing.planPricing(plan),
    ]);
    if (!fare) throw new NotPricedError(`No fare set for route ${routeId}`);
    if (!pricing) throw new NotPricedError(`No pricing configured for plan ${plan}`);
    return derivePrice(fare.farePesewas, pricing);
  }

  /**
   * Shared checkout path: persist a pending payment and open a Paystack
   * transaction for it.
   *
   * @param input - the new payment minus its `reference` (generated here).
   * @returns the checkout URL and the generated reference.
   * @throws PaymentsNotConfiguredError when no Paystack client is wired.
   */
  private async startCheckout(
    input: Omit<NewPayment, 'reference'>,
  ): Promise<Pick<CheckoutResult, 'authorizationUrl' | 'reference'>> {
    if (!this.deps.paystack) {
      throw new PaymentsNotConfiguredError('Payments are not configured');
    }
    const reference = `trotxi_${crypto.randomUUID()}`;
    await this.deps.payments.create({ ...input, reference });
    const result = await this.deps.paystack.initializeTransaction({
      // We don't store email yet; a stable per-user address is fine as Paystack's
      // customer key (follow-up: capture the real email at sign-in).
      email: `${input.userId}@users.trotxi.app`,
      amountPesewas: input.amount, // amounts are already stored in pesewas
      reference,
    });
    return { authorizationUrl: result.authorizationUrl, reference };
  }

  /**
   * Verify and process a Paystack webhook. On a valid `charge.success` for a
   * subscription payment, activate the membership. Idempotent and safe to
   * replay (guarded activation, pending→paid markPaid); unknown references,
   * non-subscription purposes, and non-`charge.success` events are ignored.
   *
   * @param rawBody - the exact raw request body (required for the HMAC check).
   * @param signature - the `x-paystack-signature` header, if present.
   * @throws PaymentsNotConfiguredError when no Paystack client is wired.
   * @throws InvalidWebhookError when the signature doesn't verify.
   */
  async handleWebhook(rawBody: string, signature: string | undefined): Promise<void> {
    if (!this.deps.paystack) {
      throw new PaymentsNotConfiguredError('Payments are not configured');
    }
    if (!this.deps.paystack.verifyWebhookSignature(rawBody, signature)) {
      throw new InvalidWebhookError('Invalid webhook signature');
    }

    const event = JSON.parse(rawBody) as PaystackWebhookEvent;
    if (event.event !== 'charge.success') return; // ignore everything else
    const reference = event.data?.reference;
    if (!reference) return;

    const payment = await this.deps.payments.findByReference(reference);
    if (!payment) return; // unknown reference — not ours

    if (payment.purpose === 'subscription' && payment.plan) {
      // Debit BEFORE activating: a crash between the two leaves the rider
      // without the subscription their retry will grant, rather than with a
      // subscription they never paid the credit half of.
      await this.applyCredit(payment.userId, reference, payment.appliedCreditPesewas);
      // Membership fee paid — activate the subscription (pinned to the paid
      // route) and allocate the period's rides. Both idempotent → replay-safe.
      await this.activateSubscription(payment.userId, payment.plan, payment.routeId, payment);
      await this.allocateEntitlement(payment.userId, reference, payment.ridesGranted);
    }

    // The charge itself verifies the handset — no OTP needed. Best effort: a
    // non-200 here would cost us the activation above on Paystack's retry.
    await this.capturePayerPhone(payment.userId, event);
    // Legacy 'topup' payments (pre-ADR-0014 staging data) are ignored.

    await this.deps.payments.markPaid(reference);
  }

  /**
   * Allocate the period's ride entitlement for a paid subscription. Keyed by the
   * payment reference, so a re-delivered webhook never double-allocates.
   *
   * @param userId - the subscriber.
   * @param reference - the payment reference (the allocation's idempotency key).
   * @param ridesGranted - the count frozen at checkout; null for pre-#103 rows.
   */
  private async allocateEntitlement(
    userId: string,
    reference: string,
    ridesGranted: number | null,
  ): Promise<void> {
    await this.deps.entitlements.record({
      userId,
      // The count fixed at checkout. Pre-#103 payments have none; those fall
      // back to the configured default so replaying an old webhook still works.
      deltaRides: ridesGranted ?? this.deps.ridesPerPeriod,
      reason: 'allocation',
      refType: 'payment',
      refId: reference,
      idempotencyKey: `alloc:${reference}`,
    });
  }

  /**
   * Record the payer's phone from a successful charge (#182).
   *
   * Swallows failures by design: two accounts paying from one handset trips the
   * UNIQUE constraint, and a 500 here would cost us the activation on retry.
   *
   * @param userId - the paying user.
   * @param event - the verified `charge.success` payload.
   */
  private async capturePayerPhone(userId: string, event: PaystackWebhookEvent): Promise<void> {
    const raw = event.data?.authorization?.mobile_money_number ?? event.data?.customer?.phone;
    const phone = normaliseGhanaPhone(raw);
    if (!phone) return;
    try {
      await this.deps.users.backfillContact(userId, { phone });
    } catch {
      // Already held by another account, or the row vanished. Neither is worth
      // failing a paid subscription over.
    }
  }

  /**
   * Debit the Ride Credit this checkout was netted against.
   *
   * Clamped to the balance actually on the ledger. Two checkouts opened before
   * either settles are both netted against the same balance, so the second
   * would otherwise drive it negative — spending credit that no longer exists.
   * The clamp caps that at the balance; the rider keeps the discount already
   * charged, which is the cheaper side of the error to be on.
   *
   * @param userId - the rider.
   * @param reference - the payment reference; also the idempotency key.
   * @param appliedCreditPesewas - what was netted off at checkout.
   */
  private async applyCredit(
    userId: string,
    reference: string,
    appliedCreditPesewas: number,
  ): Promise<void> {
    if (!this.deps.credits || appliedCreditPesewas <= 0) return;
    const balance = await this.deps.credits.balancePesewas(userId);
    const debit = Math.min(appliedCreditPesewas, balance);
    if (debit <= 0) return;
    await this.deps.credits.record({
      userId,
      deltaPesewas: -debit,
      reason: 'renewal_applied',
      refType: 'payment',
      refId: reference,
      idempotencyKey: `renewal:${reference}`,
    });
  }

  /**
   * Create the user's active subscription, treating the one-active-per-user
   * unique-violation as success (so a replayed webhook is a no-op).
   *
   * @param userId - the subscriber.
   * @param plan - the membership tier to activate.
   * @param routeId - the rider's pinned route/corridor (E3).
   * @param payment - the paid payment, carrying the checkout-time snapshot.
   */
  private async activateSubscription(
    userId: string,
    plan: SubscriptionPlan,
    routeId: string | null,
    payment: Payment,
  ): Promise<void> {
    try {
      const period = periodFor(plan, new Date());
      await this.deps.subscriptions.create({
        userId,
        plan,
        routeId,
        // The billing window this payment buys (#162).
        periodStart: period.start,
        periodEnd: period.end,
        // From the payment, so a fare change cannot move what this rider owes
        // (ADR-0015 §3). New prices apply at renewal.
        pricePesewas: payment.amount,
        ridesGranted: payment.ridesGranted,
        farePesewas: payment.farePesewas,
        creditPesewasPerRide: payment.creditPesewasPerRide,
      });
    } catch (err) {
      // one-active-per-user index fired — already activated, treat as done.
      if (!isUniqueViolation(err)) throw err;
    }
  }
}
