// PaymentsService — initialize a Paystack checkout, and handle the webhook that
// confirms it. The webhook is the money-in event: on charge.success it GRANTS
// tokens to the ledger and ACTIVATES the subscription.
//
// Not wrapped in one DB transaction by design (system-design §4.2: "idempotent
// webhooks"): each step is individually idempotent, so a retried/partial webhook
// converges — the ledger grant is keyed (no double grant), the subscription is
// guarded by the one-active-per-user index (no double activate), and markPaid
// only transitions pending → paid. Paystack retries; a nightly reconciliation
// (future) backstops anything it gives up on.

import type { LedgerRepository } from '../ledger/ledger.repository';
import type {
  SubscriptionPlan,
  SubscriptionRepository,
} from '../subscriptions/subscription.repository';
import type { PaymentRepository } from './payment.repository';
import type { PaystackClient } from './paystack.client';

export class PaymentsNotConfiguredError extends Error {}
export class InvalidWebhookError extends Error {}

/**
 * Plan prices in GHS (1 token = 1 GHS, so the price is also the token grant).
 * Server-authoritative (security.md §7) — PLACEHOLDERS; set the real numbers here.
 */
export const PLAN_PRICES_GHS: Record<SubscriptionPlan, number> = {
  monthly: 250,
  annual: 2500,
};

export interface PaymentsServiceDeps {
  payments: PaymentRepository;
  ledger: LedgerRepository;
  subscriptions: SubscriptionRepository;
  /** Undefined when payments aren't configured (e.g. prod without a Paystack key). */
  paystack?: PaystackClient;
  /** Plan → price in GHS (server-authoritative; 1 token = 1 GHS). */
  planPrices: Record<SubscriptionPlan, number>;
}

function isUniqueViolation(err: unknown): boolean {
  return (err as { code?: string }).code === '23505';
}

interface PaystackWebhookEvent {
  event?: string;
  data?: { reference?: string };
}

export class PaymentsService {
  constructor(private readonly deps: PaymentsServiceDeps) {}

  /** Create a pending payment and start a Paystack checkout for the plan. */
  async initialize(
    userId: string,
    plan: SubscriptionPlan,
  ): Promise<{ authorizationUrl: string; reference: string }> {
    if (!this.deps.paystack) {
      throw new PaymentsNotConfiguredError('Payments are not configured');
    }
    const amount = this.deps.planPrices[plan]; // GHS, server-side
    const reference = `trotxi_${crypto.randomUUID()}`;
    await this.deps.payments.create({ userId, reference, plan, amount, currency: 'GHS' });
    const result = await this.deps.paystack.initializeTransaction({
      // We don't store email yet; a stable per-user address is fine as Paystack's
      // customer key (follow-up: capture the real email at sign-in).
      email: `${userId}@users.trotxi.app`,
      amountPesewas: amount * 100,
      reference,
    });
    return { authorizationUrl: result.authorizationUrl, reference };
  }

  /** Verify + process a Paystack webhook. Idempotent; safe to replay. */
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

    // Idempotent steps (order doesn't matter for correctness; each is safe to retry):
    await this.deps.ledger.append({
      userId: payment.userId,
      delta: payment.amount,
      reason: 'subscription_grant',
      refType: 'payment',
      refId: payment.id,
      idempotencyKey: `grant:${reference}`,
    });
    await this.activateSubscription(payment.userId, payment.plan);
    await this.deps.payments.markPaid(reference);
  }

  private async activateSubscription(userId: string, plan: SubscriptionPlan): Promise<void> {
    try {
      await this.deps.subscriptions.create({ userId, plan });
    } catch (err) {
      // one-active-per-user index fired — already activated, treat as done.
      if (!isUniqueViolation(err)) throw err;
    }
  }
}
