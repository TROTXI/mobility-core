// PaymentsService — Paystack money-in: initiate a subscription checkout and
// process the charge.success webhook that activates it. Money is in PESEWAS
// (integers, never floats), matching Paystack.
//
// Checkouts reserve Ride Credit without spending it. Settlement, membership,
// period history, credit capture, ride allocation, and payment fulfilment share
// one lifecycle transaction, so a crash cannot leave half of the value posted.

import { createHash } from 'node:crypto';
import { normaliseGhanaPhone } from '../../lib/phone';
import { InMemoryCreditLedgerRepository } from '../entitlements/credit-ledger.repository';
import type { CreditLedgerRepository } from '../entitlements/credit-ledger.repository';
import type { EntitlementLedgerRepository } from '../entitlements/entitlement-ledger.repository';
import type {
  SubscriptionPlan,
  SubscriptionRepository,
} from '../subscriptions/subscription.repository';
import type { UserRepository } from '../users/user.repository';
import { derivePrice, MIN_CHARGE_PESEWAS, type DerivedPrice } from './pricing';
import type { RouteStopRepository } from '../mobility/route-stop.repository';
import type { PricingRepository } from './pricing.repository';
import {
  PendingSubscriptionPaymentError,
  type NewPayment,
  type Payment,
  type PaymentRepository,
} from './payment.repository';
import type { PaystackClient } from './paystack.client';
import {
  ActiveSubscriptionPaymentError,
  InMemoryPaymentLifecycle,
  type PaymentLifecycle,
  type PeriodCloseResult,
  type SettledCharge,
} from './payment-lifecycle';
import {
  InMemoryPaymentWebhookRepository,
  type PaymentWebhookRepository,
} from './payment-webhook.repository';

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
 * Thrown when the chosen pickup/drop-off stops are not both on the subscribed
 * route, or are the wrong way round. Routes map it to HTTP 400: this is a
 * malformed choice rather than a server problem.
 */
export class InvalidStopsError extends Error {}

/** Thrown when the rider already has an active membership. Routes map it to 409. */
export class AlreadySubscribedError extends Error {}

/** Thrown when a previous checkout has not settled yet. Routes map it to 409. */
export class CheckoutInProgressError extends Error {
  constructor(readonly reference: string) {
    super(`Subscription checkout ${reference} is still pending`);
    this.name = 'CheckoutInProgressError';
  }
}

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
  /** Route/stop placements, for validating the rider's chosen stops (#204). */
  routeStops?: RouteStopRepository;
  /** Rides allocated per activated period (placeholder until E1b tiers). */
  ridesPerPeriod: number;
  /** Atomic checkout/fulfilment/period-close boundary. */
  lifecycle?: PaymentLifecycle;
  /** Durable provider-event inbox. */
  webhooks?: PaymentWebhookRepository;
}

/**
 * Whether the settled charge is the one we opened this checkout for.
 *
 * Amount is compared exactly rather than as a floor: Paystack settles in
 * pesewas, we charge in pesewas, and an overpayment is as much a sign of a
 * mismatched reference as a shortfall is. All settlement fields are required:
 * a signed but incomplete payload is not proof that the expected charge settled.
 *
 * @param event - the signature-verified webhook payload.
 * @returns normalized provider facts, or null when required evidence is absent.
 */
function settledCharge(event: PaystackWebhookEvent): SettledCharge | null {
  const data = event.data;
  if (!data) return null;
  const providerTransactionId = String(data.id ?? '');
  const paidAt = new Date(data.paid_at ?? '');
  if (
    data.status !== 'success' ||
    typeof data.reference !== 'string' ||
    typeof data.amount !== 'number' ||
    !Number.isSafeInteger(data.amount) ||
    typeof data.currency !== 'string' ||
    !/^\d+$/.test(providerTransactionId) ||
    (data.domain !== 'test' && data.domain !== 'live') ||
    Number.isNaN(paidAt.getTime()) ||
    (data.fees !== undefined && data.fees !== null && !Number.isSafeInteger(data.fees))
  ) {
    return null;
  }
  return {
    reference: data.reference,
    status: 'success',
    amountPesewas: data.amount,
    currency: data.currency,
    providerTransactionId,
    providerDomain: data.domain,
    channel: typeof data.channel === 'string' ? data.channel : null,
    feesPesewas: data.fees ?? null,
    paidAt,
  };
}

/** The subset of Paystack's webhook payload we read. */
interface PaystackWebhookEvent {
  event?: string;
  data?: {
    id?: number | string;
    reference?: string;
    /** Paystack's own verdict on the charge. Only `success` grants anything. */
    status?: string;
    /** What was actually collected, in pesewas. Compared to what we asked for. */
    amount?: number;
    /** ISO 4217 code Paystack settled in. */
    currency?: string;
    domain?: string;
    channel?: string | null;
    fees?: number | null;
    paid_at?: string;
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
  private readonly lifecycle: PaymentLifecycle;
  private readonly webhooks: PaymentWebhookRepository;

  /** @param deps - repositories, the Paystack client, and the fee table. */
  constructor(private readonly deps: PaymentsServiceDeps) {
    this.lifecycle =
      deps.lifecycle ??
      new InMemoryPaymentLifecycle({
        payments: deps.payments,
        subscriptions: deps.subscriptions,
        entitlements: deps.entitlements,
        credits: deps.credits ?? new InMemoryCreditLedgerRepository(),
      });
    this.webhooks = deps.webhooks ?? new InMemoryPaymentWebhookRepository();
  }

  /**
   * Close every due period through the same atomic accounting boundary.
   *
   * @param now - instant used to select ended periods.
   * @returns aggregate conversion and closure totals.
   */
  async closeEndedPeriods(now: Date = new Date()): Promise<PeriodCloseResult> {
    return this.lifecycle.closeEndedPeriods(now);
  }

  /**
   * Start a Paystack checkout for the platform membership fee. Records a
   * `pending` payment and returns a hosted checkout URL; the subscription is
   * activated later, by {@link handleWebhook} on `charge.success` — not here.
   *
   * @param userId - the authenticated user subscribing.
   * @param plan - membership tier (`monthly` | `annual`); selects the fee.
   * @param routeId - the rider's pinned route/corridor (E3), carried to the
   *   subscription on activation.
   * @param stops - the rider's chosen boarding and alighting stops (#204).
   * @param stops.pickupStopId - where they board; omit both to skip stop pinning.
   * @param stops.dropoffStopId - where they alight.
   * @returns the Paystack `authorizationUrl` and our payment `reference`.
   * @throws PaymentsNotConfiguredError when no Paystack client is wired.
   */
  async initializeSubscription(
    userId: string,
    plan: SubscriptionPlan,
    routeId: string,
    stops: { pickupStopId?: string; dropoffStopId?: string } = {},
  ): Promise<CheckoutResult> {
    await this.assertStopsOnRoute(routeId, stops);
    const price = await this.priceFor(plan, routeId);
    const checkout = await this.startCheckout(
      {
        userId,
        purpose: 'subscription',
        plan,
        routeId,
        currency: 'GHS',
        // Frozen here, not at activation: a fare moving between checkout and
        // charge.success would grant rides priced against a fare never paid.
        ridesGranted: price.ridesGranted,
        farePesewas: price.farePesewas,
        creditPesewasPerRide: price.creditPesewasPerRide,
        pickupStopId: stops.pickupStopId ?? null,
        dropoffStopId: stops.dropoffStopId ?? null,
      },
      price.pricePesewas,
    );
    return {
      authorizationUrl: checkout.authorizationUrl,
      reference: checkout.payment.reference,
      pricePesewas: price.pricePesewas,
      appliedCreditPesewas: checkout.payment.appliedCreditPesewas,
      chargePesewas: checkout.payment.amount,
    };
  }

  /**
   * Check the rider's chosen stops before taking any money.
   *
   * Both must sit on the route they are subscribing to, and pickup must come
   * before drop-off in stop order. Boarding after your destination is not a
   * thing, and catching it here beats discovering it when the van arrives.
   *
   * A no-op when neither stop was supplied, so clients predating #204 are
   * unaffected, and when no route-stop store is wired.
   *
   * @param routeId - the corridor being subscribed to.
   * @param stops - the rider's chosen pickup and drop-off.
   * @param stops.pickupStopId - where they board.
   * @param stops.dropoffStopId - where they alight.
   * @throws InvalidStopsError when a stop is off-route or the pair is reversed.
   */
  private async assertStopsOnRoute(
    routeId: string,
    stops: { pickupStopId?: string; dropoffStopId?: string },
  ): Promise<void> {
    const { pickupStopId, dropoffStopId } = stops;
    if (!pickupStopId && !dropoffStopId) return;
    if (!this.deps.routeStops) return;
    if (!pickupStopId || !dropoffStopId) {
      throw new InvalidStopsError('Provide both pickupStopId and dropoffStopId, or neither');
    }
    if (pickupStopId === dropoffStopId) {
      throw new InvalidStopsError('Pickup and drop-off cannot be the same stop');
    }

    const placements = await this.deps.routeStops.findByRoute(routeId);
    const seqOf = (stopId: string) => placements.find((p) => p.stopId === stopId)?.seq;
    const pickupSeq = seqOf(pickupStopId);
    const dropoffSeq = seqOf(dropoffStopId);
    if (pickupSeq === undefined) {
      throw new InvalidStopsError(`Stop ${pickupStopId} is not on route ${routeId}`);
    }
    if (dropoffSeq === undefined) {
      throw new InvalidStopsError(`Stop ${dropoffStopId} is not on route ${routeId}`);
    }
    if (pickupSeq >= dropoffSeq) {
      throw new InvalidStopsError('Pickup must come before drop-off on the route');
    }
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
    const derived = derivePrice(fare.farePesewas, pricing);
    if (derived.pricePesewas < MIN_CHARGE_PESEWAS) {
      throw new NotPricedError(
        `Configured price is below the ${MIN_CHARGE_PESEWAS} pesewa payment minimum`,
      );
    }
    return derived;
  }

  /**
   * Shared checkout path: persist a pending payment and open a Paystack
   * transaction for it.
   *
   * @param input - the new payment minus its `reference` (generated here).
   * @param pricePesewas - full price before a transactional credit hold.
   * @returns the checkout URL and the generated reference.
   * @throws PaymentsNotConfiguredError when no Paystack client is wired.
   */
  private async startCheckout(
    input: Omit<NewPayment, 'reference' | 'amount' | 'appliedCreditPesewas'>,
    pricePesewas: number,
  ): Promise<{ authorizationUrl: string; payment: Payment }> {
    if (!this.deps.paystack) {
      throw new PaymentsNotConfiguredError('Payments are not configured');
    }
    const reference = `trotxi-${crypto.randomUUID()}`;
    let payment: Payment;
    try {
      payment = await this.lifecycle.createSubscriptionCheckout({
        ...input,
        reference,
        pricePesewas,
      });
    } catch (err) {
      if (err instanceof PendingSubscriptionPaymentError) {
        throw new CheckoutInProgressError(err.reference);
      }
      if (err instanceof ActiveSubscriptionPaymentError) {
        throw new AlreadySubscribedError(err.message);
      }
      throw err;
    }
    const result = await this.deps.paystack.initializeTransaction({
      // The rider's verified address when we hold one (#182), so Paystack's
      // receipt reaches a real inbox. The synthesised address is the fallback
      // for accounts predating email capture: Paystack needs a stable customer
      // key, and an unroutable one beats refusing the checkout.
      email: (await this.deps.users.findById(input.userId))?.email ?? this.fallbackEmail(input),
      amountPesewas: payment.amount, // amounts are already stored in pesewas
      reference,
    });
    return { authorizationUrl: result.authorizationUrl, payment };
  }

  /**
   * A stable, unroutable customer key for a rider whose email we do not hold.
   *
   * @param input - the payment being opened.
   * @returns an address derived from the user id.
   */
  private fallbackEmail(
    input: Omit<NewPayment, 'reference' | 'amount' | 'appliedCreditPesewas'>,
  ): string {
    return `${input.userId}@users.trotxi.app`;
  }

  /**
   * Verify and process a Paystack webhook. On a valid `charge.success` for a
   * subscription payment, activate the membership. Idempotent and safe to
   * replay (one atomic pending→fulfilled transaction); unknown references,
   * non-subscription purposes, and non-`charge.success` events are ignored.
   *
   * @param rawBody - the exact raw request body (required for the HMAC check).
   * @param signature - the `x-paystack-signature` header, if present.
   * @throws PaymentsNotConfiguredError when no Paystack client is wired.
   * @throws InvalidWebhookError when the signature doesn't verify.
   */
  async handleWebhook(rawBody: string, signature: string | undefined): Promise<void> {
    await this.acceptWebhook(rawBody, signature);
    await this.processWebhookInbox();
  }

  /**
   * Verify and durably enqueue a provider webhook before it is acknowledged.
   *
   * @param rawBody - exact bytes signed by Paystack.
   * @param signature - x-paystack-signature header.
   */
  async acceptWebhook(rawBody: string, signature: string | undefined): Promise<void> {
    if (!this.deps.paystack) {
      throw new PaymentsNotConfiguredError('Payments are not configured');
    }
    if (!this.deps.paystack.verifyWebhookSignature(rawBody, signature)) {
      throw new InvalidWebhookError('Invalid webhook signature');
    }

    const event = JSON.parse(rawBody) as PaystackWebhookEvent;
    await this.webhooks.enqueue({
      payloadSha256: createHash('sha256').update(rawBody).digest('hex'),
      eventType: typeof event.event === 'string' ? event.event : 'unknown',
      reference: typeof event.data?.reference === 'string' ? event.data.reference : null,
      rawBody,
      payload: event,
    });
  }

  /**
   * Claim and process durable provider events; safe for concurrent workers.
   *
   * @param limit - maximum work items to claim.
   * @returns processed/failed counts for observability.
   */
  async processWebhookInbox(limit = 25): Promise<{ processed: number; failed: number }> {
    const staleBefore = new Date(Date.now() - 5 * 60 * 1_000);
    const events = await this.webhooks.claimBatch(limit, staleBefore);
    let processed = 0;
    let failed = 0;
    for (const item of events) {
      try {
        await this.processWebhookEvent(item.payload as PaystackWebhookEvent);
        await this.webhooks.markProcessed(item.id);
        processed++;
      } catch (err) {
        await this.webhooks.markFailed(
          item.id,
          err instanceof Error ? err.message : 'Unknown webhook processing error',
        );
        failed++;
      }
    }
    return { processed, failed };
  }

  /**
   * Verify stale unresolved rows directly with Paystack.
   *
   * @param cutoff - only payments created at/before this instant.
   * @param limit - maximum rows to verify in one run.
   * @returns reconciliation outcome counts.
   */
  async reconcileUnresolved(
    cutoff: Date = new Date(Date.now() - 60 * 60 * 1_000),
    limit = 100,
  ): Promise<{
    considered: number;
    fulfilled: number;
    failed: number;
    unresolved: number;
    errors: number;
  }> {
    if (!this.deps.paystack) throw new PaymentsNotConfiguredError('Payments are not configured');
    const payments = await this.deps.payments.listUnresolvedBefore(cutoff, limit);
    const result = {
      considered: payments.length,
      fulfilled: 0,
      failed: 0,
      unresolved: 0,
      errors: 0,
    };
    for (const payment of payments) {
      try {
        const transaction = await this.deps.paystack.verifyTransaction(payment.reference);
        if (transaction.status === 'success' && transaction.paidAt) {
          const fulfilled = await this.lifecycle.fulfillSubscriptionCharge({
            reference: transaction.reference,
            status: 'success',
            amountPesewas: transaction.amountPesewas,
            currency: transaction.currency,
            providerTransactionId: transaction.providerTransactionId,
            providerDomain: transaction.providerDomain,
            channel: transaction.channel,
            feesPesewas: transaction.feesPesewas,
            paidAt: transaction.paidAt,
          });
          if (fulfilled === 'fulfilled' || fulfilled === 'already_fulfilled') result.fulfilled++;
          else result.unresolved++;
        } else if (['failed', 'abandoned', 'reversed'].includes(transaction.status)) {
          if (
            await this.lifecycle.failPendingPayment(
              payment.reference,
              transaction.status,
              `Paystack Verify returned ${transaction.status}`,
            )
          ) {
            result.failed++;
          }
        } else {
          result.unresolved++;
        }
      } catch {
        result.errors++;
      }
    }
    return result;
  }

  private async processWebhookEvent(event: PaystackWebhookEvent): Promise<void> {
    if (event.event !== 'charge.success') return;
    const reference = event.data?.reference;
    if (!reference) return;

    const charge = settledCharge(event);
    if (!charge || charge.reference !== reference) return;
    const payment = await this.deps.payments.findByReference(reference);
    if (!payment) return;
    const result = await this.lifecycle.fulfillSubscriptionCharge(charge);
    if (result === 'fulfilled') {
      await this.capturePayerPhone(payment.userId, event);
    }
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
}
