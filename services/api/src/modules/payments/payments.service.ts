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

/**
 * Thrown when a payments operation is attempted but no Paystack client is wired
 * (e.g. production without `PAYSTACK_SECRET_KEY`). Routes map it to HTTP 503.
 */
export class PaymentsNotConfiguredError extends Error {}

/**
 * Thrown when an incoming Paystack webhook fails signature verification. Routes
 * map it to HTTP 401.
 */
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

/** Collaborators for {@link PaymentsService}, injected at app wiring (app.ts). */
export interface PaymentsServiceDeps {
  /** Persists payment records (the pending → paid|failed state machine). */
  payments: PaymentRepository;
  /** The token wallet — credited on a successful top-up. */
  ledger: LedgerRepository;
  /** Platform memberships — activated on a successful subscription payment. */
  subscriptions: SubscriptionRepository;
  /** Undefined when payments aren't configured (e.g. prod without a Paystack key). */
  paystack?: PaystackClient;
  /** Plan → membership fee in pesewas (server-authoritative). */
  subscriptionFees: Record<SubscriptionPlan, number>;
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
  data?: { reference?: string };
}

/** What initiating a checkout returns to the caller (and the route). */
export interface CheckoutResult {
  /** Paystack hosted-checkout URL to redirect the user to. */
  authorizationUrl: string;
  /** Our unique payment reference, echoed back by the webhook for reconciliation. */
  reference: string;
}

/**
 * Orchestrates the two money-in flows — subscription membership fees and wallet
 * top-ups — on top of Paystack: it initiates checkouts and processes the
 * `charge.success` webhook that confirms them. See the file header for the
 * idempotency model.
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
   * @returns the Paystack `authorizationUrl` and our payment `reference`.
   * @throws PaymentsNotConfiguredError when no Paystack client is wired.
   */
  async initializeSubscription(userId: string, plan: SubscriptionPlan): Promise<CheckoutResult> {
    return this.startCheckout({
      userId,
      purpose: 'subscription',
      plan,
      amount: this.deps.subscriptionFees[plan],
      currency: 'GHS',
    });
  }

  /**
   * Start a Paystack checkout to load ride tokens into the wallet. Records a
   * `pending` top-up; tokens are granted later by {@link handleWebhook}.
   *
   * @param userId - the authenticated user topping up.
   * @param amountPesewas - amount to load, in pesewas (1 GHS = 100 pesewas).
   * @returns the Paystack `authorizationUrl` and our payment `reference`.
   * @throws PaymentsNotConfiguredError when no Paystack client is wired.
   */
  async initializeTopup(userId: string, amountPesewas: number): Promise<CheckoutResult> {
    return this.startCheckout({
      userId,
      purpose: 'topup',
      plan: null,
      amount: amountPesewas,
      currency: 'GHS',
    });
  }

  /**
   * Shared checkout path: persist a pending payment and open a Paystack
   * transaction for it.
   *
   * @param input - the new payment minus its `reference` (generated here).
   * @returns the checkout URL and the generated reference.
   * @throws PaymentsNotConfiguredError when no Paystack client is wired.
   */
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

  /**
   * Verify and process a Paystack webhook. On a valid `charge.success`: a
   * top-up credits the ledger; a subscription activates membership. Idempotent
   * and safe to replay (keyed ledger grant, guarded activation, pending→paid
   * markPaid); unknown references and non-`charge.success` events are ignored.
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

  /**
   * Create the user's active subscription, treating the one-active-per-user
   * unique-violation as success (so a replayed webhook is a no-op).
   *
   * @param userId - the subscriber.
   * @param plan - the membership tier to activate.
   */
  private async activateSubscription(userId: string, plan: SubscriptionPlan): Promise<void> {
    try {
      await this.deps.subscriptions.create({ userId, plan });
    } catch (err) {
      // one-active-per-user index fired — already activated, treat as done.
      if (!isUniqueViolation(err)) throw err;
    }
  }
}
