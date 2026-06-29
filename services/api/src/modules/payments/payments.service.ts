// PaymentsService — two distinct money flows, both via Paystack:
//   subscription = a membership fee to be on the platform → ACTIVATES the
//                  subscription on success (grants NO tokens).
//   topup        = loading pesewas into the wallet → GRANTS tokens on success.
// The webhook (charge.success) branches on the payment's purpose.
//
// Money unit: PESEWAS everywhere (1 GHS = 100 pesewas), matching Paystack — the
// client converts to/from GHS for display. Integers only; never floats.
//
// Not wrapped in one DB transaction by design (system-design §4.2: "idempotent
// webhooks") — each step is individually idempotent (ledger grant keyed; the
// one-active-per-user index guards activation; markPaid only does pending→paid),
// so a retried/partial webhook converges. Paystack retries; reconciliation
// (future) backstops the rest.

import type { LedgerRepository } from '../ledger/ledger.repository';
import type {
  SubscriptionPlan,
  SubscriptionRepository,
} from '../subscriptions/subscription.repository';
import type { NewPayment, PaymentRepository } from './payment.repository';
import type { PaystackClient } from './paystack.client';

export class PaymentsNotConfiguredError extends Error {}
export class InvalidWebhookError extends Error {}

/**
 * Membership fee in PESEWAS to be on the platform — this is NOT ride money
 * (top-ups fund rides). Server-authoritative (security.md §7). PLACEHOLDERS —
 * set real values here.
 */
export const SUBSCRIPTION_FEES_PESEWAS: Record<SubscriptionPlan, number> = {
  monthly: 2000, // GHS 20
  annual: 20000, // GHS 200
};

export interface PaymentsServiceDeps {
  payments: PaymentRepository;
  ledger: LedgerRepository;
  subscriptions: SubscriptionRepository;
  /** Undefined when payments aren't configured (e.g. prod without a Paystack key). */
  paystack?: PaystackClient;
  /** Plan → membership fee in pesewas (server-authoritative). */
  subscriptionFees: Record<SubscriptionPlan, number>;
}

function isUniqueViolation(err: unknown): boolean {
  return (err as { code?: string }).code === '23505';
}

interface PaystackWebhookEvent {
  event?: string;
  data?: { reference?: string };
}

export interface CheckoutResult {
  authorizationUrl: string;
  reference: string;
}

export class PaymentsService {
  constructor(private readonly deps: PaymentsServiceDeps) {}

  /** Start a checkout for the platform membership fee (activates on success). */
  async initializeSubscription(userId: string, plan: SubscriptionPlan): Promise<CheckoutResult> {
    return this.startCheckout({
      userId,
      purpose: 'subscription',
      plan,
      amount: this.deps.subscriptionFees[plan],
      currency: 'GHS',
    });
  }

  /** Start a checkout to load `amountPesewas` of ride tokens into the wallet. */
  async initializeTopup(userId: string, amountPesewas: number): Promise<CheckoutResult> {
    return this.startCheckout({
      userId,
      purpose: 'topup',
      plan: null,
      amount: amountPesewas,
      currency: 'GHS',
    });
  }

  private async startCheckout(input: Omit<NewPayment, 'reference'>): Promise<CheckoutResult> {
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

    if (payment.purpose === 'topup') {
      // Load ride money into the wallet (keyed → no double grant).
      await this.deps.ledger.append({
        userId: payment.userId,
        delta: payment.amount,
        reason: 'topup',
        refType: 'payment',
        refId: payment.id,
        idempotencyKey: `topup:${reference}`,
      });
    } else if (payment.plan) {
      // Membership fee paid — activate the subscription (no tokens).
      await this.activateSubscription(payment.userId, payment.plan);
    }

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
