import { describe, expect, it } from 'vitest';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import {
  AlreadySubscribedError,
  CheckoutInProgressError,
  InvalidStopsError,
  InvalidWebhookError,
  NotPricedError,
  PaymentsNotConfiguredError,
  PaymentsService,
} from '../src/modules/payments/payments.service';
import {
  InMemorySubscriptionRepository,
  type SubscriptionRepository,
} from '../src/modules/subscriptions/subscription.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { InMemoryCreditLedgerRepository } from '../src/modules/entitlements/credit-ledger.repository';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';
import { InMemoryPricingRepository } from '../src/modules/payments/pricing.repository';
import { InMemoryRouteStopRepository } from '../src/modules/mobility/route-stop.repository';
import { MIN_CHARGE_PESEWAS } from '../src/modules/payments/pricing';

const FAKE_SECRET = 'fake-paystack-secret';
const RIDES = 44;
/** GHS 6 a trip — a plausible Accra corridor fare. */
const FARE = 600;
const ROUTE = '11111111-1111-4111-8111-111111111111';

function make(subscriptions: SubscriptionRepository = new InMemorySubscriptionRepository()) {
  const payments = new InMemoryPaymentRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  const pricing = new InMemoryPricingRepository();
  const credits = new InMemoryCreditLedgerRepository();
  const routeStops = new InMemoryRouteStopRepository();
  const paystack = new FakePaystackClient(FAKE_SECRET);
  const service = new PaymentsService({
    payments,
    subscriptions,
    entitlements,
    credits,
    paystack,
    users: new InMemoryUserRepository(),
    pricing,
    routeStops,
    ridesPerPeriod: RIDES,
  });
  return { payments, subscriptions, entitlements, credits, pricing, routeStops, paystack, service };
}

/** A priced corridor: without a fare in force there is no price to charge. */
async function priced(subscriptions?: SubscriptionRepository) {
  const ctx = make(subscriptions);
  await ctx.pricing.setFare(ROUTE, FARE);
  return ctx;
}

function chargeSuccess(
  reference: string,
  amountPesewas = FARE * RIDES,
): { body: string; signature: string } {
  const body = JSON.stringify({
    event: 'charge.success',
    data: {
      id: 123456,
      reference,
      status: 'success',
      amount: amountPesewas,
      currency: 'GHS',
      domain: 'test',
      channel: 'mobile_money',
      fees: 100,
      paid_at: new Date().toISOString(),
    },
  });
  return { body, signature: paystackSignature(body, FAKE_SECRET) };
}

/**
 * A signed `charge.success` carrying whatever Paystack claims it collected.
 *
 * @param reference - the payment reference.
 * @param data - the settlement fields to assert (amount, status, currency).
 * @returns the raw body and its valid signature.
 */
function chargeSuccessWith(
  reference: string,
  data: Record<string, unknown>,
): { body: string; signature: string } {
  const body = JSON.stringify({
    event: 'charge.success',
    data: {
      id: 123456,
      reference,
      status: 'success',
      amount: FARE * RIDES,
      currency: 'GHS',
      domain: 'test',
      channel: 'mobile_money',
      fees: 100,
      paid_at: new Date().toISOString(),
      ...data,
    },
  });
  return { body, signature: paystackSignature(body, FAKE_SECRET) };
}

function signedEvent(event: Record<string, unknown>): { body: string; signature: string } {
  const body = JSON.stringify(event);
  return { body, signature: paystackSignature(body, FAKE_SECRET) };
}

describe('PaymentsService.initializeSubscription', () => {
  it('derives the price from the corridor fare rather than a constant', async () => {
    const { service, payments } = await priced();
    const { reference, authorizationUrl } = await service.initializeSubscription(
      'u1',
      'monthly',
      ROUTE,
    );
    expect(authorizationUrl).toBeTruthy();
    expect(await payments.findByReference(reference)).toMatchObject({
      purpose: 'subscription',
      plan: 'monthly',
      // fare x rides x parity = 600 x 44 = GHS 264, not the old flat GHS 20.
      amount: FARE * RIDES,
      status: 'pending',
    });
  });

  it('freezes the price inputs on the payment at checkout', async () => {
    // Not re-derived at activation: minutes pass before charge.success, and a
    // fare that moved in that window would grant rides priced against a fare
    // the rider never paid.
    const { service, payments } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);

    expect(await payments.findByReference(reference)).toMatchObject({
      ridesGranted: RIDES,
      farePesewas: FARE,
      creditPesewasPerRide: 45,
    });
  });

  it('uses a Paystack-safe reference', async () => {
    const { service } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    expect(reference).toMatch(/^[A-Za-z0-9.=-]+$/);
    expect(reference).not.toContain('_');
  });

  it('rejects a second unresolved checkout for the same rider', async () => {
    const { service } = await priced();
    const first = await service.initializeSubscription('u1', 'monthly', ROUTE);
    await expect(service.initializeSubscription('u1', 'monthly', ROUTE)).rejects.toMatchObject({
      constructor: CheckoutInProgressError,
      reference: first.reference,
    });
  });

  it('rejects checkout while the rider already has an active subscription', async () => {
    const { service } = await priced();
    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const { body, signature } = chargeSuccess(checkout.reference);
    await service.handleWebhook(body, signature);

    await expect(service.initializeSubscription('u1', 'monthly', ROUTE)).rejects.toBeInstanceOf(
      AlreadySubscribedError,
    );
  });

  it('rejects a configured price below the Paystack charge minimum', async () => {
    const { service, pricing } = make();
    await pricing.setFare(ROUTE, 1);
    await expect(service.initializeSubscription('u1', 'monthly', ROUTE)).rejects.toBeInstanceOf(
      NotPricedError,
    );
  });

  it('refuses to price a corridor with no fare rather than inventing one', async () => {
    const { service } = make(); // no fare set
    await expect(service.initializeSubscription('u1', 'monthly', ROUTE)).rejects.toBeInstanceOf(
      NotPricedError,
    );
  });

  it('charges the new fare after a fare change, without touching what is sold', async () => {
    const { service, payments, pricing } = await priced();
    const before = await service.initializeSubscription('u1', 'monthly', ROUTE);

    await pricing.setFare(ROUTE, 700, 'fuel adjustment');
    const after = await service.initializeSubscription('u2', 'monthly', ROUTE);

    expect((await payments.findByReference(before.reference))?.amount).toBe(FARE * RIDES);
    expect((await payments.findByReference(after.reference))?.amount).toBe(700 * RIDES);
  });

  it('throws when payments are not configured', async () => {
    // Priced, so the failure is Paystack being absent rather than the corridor
    // having no fare — those are different errors with different status codes.
    const unpricedButConfigured = new InMemoryPricingRepository();
    await unpricedButConfigured.setFare(ROUTE, FARE);
    const service = new PaymentsService({
      payments: new InMemoryPaymentRepository(),
      subscriptions: new InMemorySubscriptionRepository(),
      entitlements: new InMemoryEntitlementLedgerRepository(),
      users: new InMemoryUserRepository(),
      pricing: unpricedButConfigured,
      ridesPerPeriod: RIDES,
    });
    await expect(service.initializeSubscription('u1', 'monthly', ROUTE)).rejects.toBeInstanceOf(
      PaymentsNotConfiguredError,
    );
  });
});

describe('PaymentsService.handleWebhook', () => {
  it('rejects an invalid signature', async () => {
    const { service } = make();
    await expect(service.handleWebhook('{}', 'bad')).rejects.toBeInstanceOf(InvalidWebhookError);
  });

  it('durably deduplicates the same webhook before processing', async () => {
    const { service } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const { body, signature } = chargeSuccess(reference);

    await service.acceptWebhook(body, signature);
    await service.acceptWebhook(body, signature);
    expect(await service.processWebhookInbox()).toEqual({ processed: 1, failed: 0 });
    expect(await service.processWebhookInbox()).toEqual({ processed: 0, failed: 0 });
  });

  it('subscription paid: activates the subscription, allocates rides, marks paid', async () => {
    const { service, subscriptions, payments, entitlements } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);

    expect(await subscriptions.findActiveByUser('u1')).not.toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(RIDES);
    expect((await payments.findByReference(reference))?.status).toBe('fulfilled');
  });

  it('pins the paid route onto the activated subscription (E3 rider↔route)', async () => {
    const { service, subscriptions, pricing } = make();
    const routeId = crypto.randomUUID();
    await pricing.setFare(routeId, FARE);
    const { reference } = await service.initializeSubscription('u1', 'monthly', routeId);
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);

    expect(await subscriptions.findActiveByUser('u1')).toMatchObject({ routeId });
    expect(await subscriptions.findActiveByRoute(routeId)).toHaveLength(1);
  });

  it('is idempotent — a replayed webhook does not double-activate or double-allocate', async () => {
    const { service, subscriptions, entitlements } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);
    await expect(service.handleWebhook(body, signature)).resolves.toBeUndefined();
    expect(await subscriptions.findActiveByUser('u1')).not.toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(RIDES); // not 2×
  });

  it('grants nothing when the settled amount is not what we charged', async () => {
    // The signature proves Paystack sent it. It does not prove the rider paid
    // what we asked for, and a short collection used to buy a full month.
    const { service, subscriptions, entitlements, payments } = await priced();
    const { reference, chargePesewas } = await service.initializeSubscription(
      'u1',
      'monthly',
      ROUTE,
    );
    const { body, signature } = chargeSuccessWith(reference, { amount: chargePesewas - 1 });

    await service.handleWebhook(body, signature);

    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(0);
    expect((await payments.findByReference(reference))?.status).toBe('pending');
  });

  it('grants nothing when Paystack settled in another currency', async () => {
    const { service, subscriptions } = await priced();
    const { reference, chargePesewas } = await service.initializeSubscription(
      'u1',
      'monthly',
      ROUTE,
    );
    const { body, signature } = chargeSuccessWith(reference, {
      amount: chargePesewas,
      currency: 'NGN',
    });

    await service.handleWebhook(body, signature);
    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
  });

  it("grants nothing when Paystack's own verdict on the charge is not success", async () => {
    const { service, subscriptions } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const { body, signature } = chargeSuccessWith(reference, { status: 'abandoned' });

    await service.handleWebhook(body, signature);
    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
  });

  it('activates when the settlement matches the checkout exactly', async () => {
    const { service, subscriptions, payments } = await priced();
    const { reference, chargePesewas } = await service.initializeSubscription(
      'u1',
      'monthly',
      ROUTE,
    );
    const { body, signature } = chargeSuccessWith(reference, {
      status: 'success',
      amount: chargePesewas,
      currency: 'GHS',
    });

    await service.handleWebhook(body, signature);

    expect(await subscriptions.findActiveByUser('u1')).not.toBeNull();
    expect((await payments.findByReference(reference))?.status).toBe('fulfilled');
  });

  it('fails closed when a signed success omits settlement fields', async () => {
    const { service, subscriptions, entitlements, payments } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const body = JSON.stringify({ event: 'charge.success', data: { reference } });

    await service.handleWebhook(body, paystackSignature(body, FAKE_SECRET));

    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(0);
    expect((await payments.findByReference(reference))?.status).toBe('pending');
  });

  it('never fulfils a payment whose state is already failed', async () => {
    const { service, subscriptions, entitlements, payments } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    await payments.markFailed(reference);
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);

    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(0);
    expect((await payments.findByReference(reference))?.status).toBe('failed');
  });

  it('ignores non charge.success events and unknown references', async () => {
    const { service, subscriptions } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);

    const failed = JSON.stringify({ event: 'charge.failed', data: { reference } });
    await service.handleWebhook(failed, paystackSignature(failed, FAKE_SECRET));
    const unknown = JSON.stringify({ event: 'charge.success', data: { reference: 'nope' } });
    await service.handleWebhook(unknown, paystackSignature(unknown, FAKE_SECRET));

    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
  });

  it('does not treat an unrelated activation conflict as fulfilled', async () => {
    const subscriptions: SubscriptionRepository = {
      findActiveByUser: async () => null,
      findActiveByRoute: async () => [],
      findAllActive: async () => [],
      findEndedPeriods: async () => [],
      rollPeriod: async () => null,
      create: async () => {
        throw Object.assign(new Error('dup'), { code: '23505' });
      },
    };
    const { service } = await priced(subscriptions);
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const { body, signature } = chargeSuccess(reference);
    await expect(service.handleWebhook(body, signature)).resolves.toBeUndefined();
    expect((await service.processWebhookInbox()).failed).toBe(1);
  });

  it('records non-unique activation failures for a durable retry', async () => {
    const subscriptions: SubscriptionRepository = {
      findActiveByUser: async () => null,
      findActiveByRoute: async () => [],
      findAllActive: async () => [],
      findEndedPeriods: async () => [],
      rollPeriod: async () => null,
      create: async () => {
        throw new Error('db down');
      },
    };
    const { service } = await priced(subscriptions);
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const { body, signature } = chargeSuccess(reference);
    await expect(service.handleWebhook(body, signature)).resolves.toBeUndefined();
    expect((await service.processWebhookInbox()).failed).toBe(1);
  });
});

describe('PaymentsService reconciliation', () => {
  it('runs inbox, Verify recovery and period close in dependency order', async () => {
    const { service, paystack, payments } = await priced();
    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);
    paystack.setTransaction(checkout.reference, {
      status: 'success',
      paidAt: new Date(),
      channel: 'mobile_money',
      feesPesewas: 100,
    });

    const result = await service.runMaintenance(new Date(Date.now() + 2 * 60 * 60 * 1_000));

    expect(result.webhooks).toEqual({ processed: 0, failed: 0 });
    expect(result.reconciliation).toMatchObject({ considered: 1, fulfilled: 1, errors: 0 });
    expect(result.periods).toMatchObject({ considered: 0, closed: 0, blocked: 0 });
    expect((await payments.findByReference(checkout.reference))?.status).toBe('fulfilled');
  });

  it('fulfills a successful payment whose webhook never arrived', async () => {
    const { service, paystack, payments, subscriptions, entitlements } = await priced();
    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);
    paystack.setTransaction(checkout.reference, {
      status: 'success',
      paidAt: new Date(),
      channel: 'mobile_money',
      feesPesewas: 100,
    });

    const result = await service.reconcileUnresolved(new Date(Date.now() + 1_000));

    expect(result).toMatchObject({ considered: 1, fulfilled: 1, errors: 0 });
    expect((await payments.findByReference(checkout.reference))?.status).toBe('fulfilled');
    expect(await subscriptions.findActiveByUser('u1')).not.toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(RIDES);
  });

  it('releases held credit after Verify reports a terminal failure', async () => {
    const { service, paystack, payments, credits } = await priced();
    await credits.record({
      userId: 'u1',
      deltaPesewas: 5_000,
      reason: 'loyalty',
      idempotencyKey: 'reconcile-credit',
    });
    const failed = await service.initializeSubscription('u1', 'monthly', ROUTE);
    paystack.setTransaction(failed.reference, { status: 'abandoned' });

    const result = await service.reconcileUnresolved(new Date(Date.now() + 1_000));
    expect(result).toMatchObject({ considered: 1, failed: 1, errors: 0 });
    expect((await payments.findByReference(failed.reference))?.status).toBe('failed');

    const retry = await service.initializeSubscription('u1', 'monthly', ROUTE);
    expect(retry.appliedCreditPesewas).toBe(5_000);
  });

  it('leaves an ongoing provider transaction unresolved', async () => {
    const { service, payments } = await priced();
    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);

    const result = await service.reconcileUnresolved(new Date(Date.now() + 1_000));

    expect(result).toMatchObject({ considered: 1, unresolved: 1, errors: 0 });
    expect((await payments.findByReference(checkout.reference))?.status).toBe('pending');
  });
});

describe('PaymentsService refund and dispute webhooks', () => {
  it('records a partial processed refund without cancelling the purchased period', async () => {
    const { service, payments, subscriptions, entitlements } = await priced();
    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const charge = chargeSuccess(checkout.reference);
    await service.handleWebhook(charge.body, charge.signature);
    const refund = signedEvent({
      event: 'refund.processed',
      data: {
        status: 'processed',
        transaction_reference: checkout.reference,
        refund_reference: 'refund-partial-1',
        amount: '1000',
        currency: 'GHS',
        domain: 'test',
      },
    });

    await service.handleWebhook(refund.body, refund.signature);

    expect(await payments.findByReference(checkout.reference)).toMatchObject({
      status: 'fulfilled',
      refundedPesewas: 1_000,
    });
    expect(await subscriptions.findActiveByUser('u1')).not.toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(RIDES);
  });

  it('reverses unconsumed rides and restores applied Ride Credit after a full cash refund', async () => {
    const { service, payments, subscriptions, entitlements, credits } = await priced();
    await credits.record({
      userId: 'u1',
      deltaPesewas: 5_000,
      reason: 'loyalty',
      idempotencyKey: 'refund-seed',
    });
    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const charge = chargeSuccess(checkout.reference, checkout.chargePesewas);
    await service.handleWebhook(charge.body, charge.signature);
    const refund = signedEvent({
      event: 'refund.processed',
      data: {
        status: 'processed',
        transaction_reference: checkout.reference,
        refund_reference: 'refund-full-1',
        amount: String(checkout.chargePesewas),
        currency: 'GHS',
        domain: 'test',
      },
    });

    await service.handleWebhook(refund.body, refund.signature);
    await service.handleWebhook(refund.body, refund.signature);

    expect(await payments.findByReference(checkout.reference)).toMatchObject({
      status: 'refunded',
      refundedPesewas: checkout.chargePesewas,
    });
    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(0);
    expect(await credits.balancePesewas('u1')).toBe(5_000);
  });

  it('freezes a disputed payment and does not treat resolution as a refund', async () => {
    const { service, payments, entitlements } = await priced();
    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const charge = chargeSuccess(checkout.reference);
    await service.handleWebhook(charge.body, charge.signature);
    const disputed = signedEvent({
      event: 'charge.dispute.create',
      data: {
        id: 991,
        status: 'awaiting-merchant-feedback',
        refund_amount: checkout.chargePesewas,
        currency: 'GHS',
        domain: 'test',
        transaction: {
          reference: checkout.reference,
          amount: checkout.chargePesewas,
          currency: 'GHS',
          domain: 'test',
        },
      },
    });

    await service.handleWebhook(disputed.body, disputed.signature);

    expect((await payments.findByReference(checkout.reference))?.status).toBe('disputed');
    expect(await entitlements.remainingRides('u1')).toBe(RIDES);
    await expect(service.initializeSubscription('u1', 'monthly', ROUTE)).rejects.toBeInstanceOf(
      AlreadySubscribedError,
    );
  });

  it('restores a period after an accepted partial dispute refund is processed', async () => {
    const { service, payments, entitlements } = await priced();
    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const charge = chargeSuccess(checkout.reference);
    await service.handleWebhook(charge.body, charge.signature);
    const resolved = signedEvent({
      event: 'charge.dispute.resolve',
      data: {
        id: 992,
        status: 'resolved',
        resolution: 'merchant-accepted',
        refund_amount: 1_000,
        currency: 'GHS',
        domain: 'test',
        transaction: {
          reference: checkout.reference,
          amount: checkout.chargePesewas,
          currency: 'GHS',
          domain: 'test',
        },
      },
    });
    await service.handleWebhook(resolved.body, resolved.signature);
    expect((await payments.findByReference(checkout.reference))?.status).toBe('disputed');

    const refund = signedEvent({
      event: 'refund.processed',
      data: {
        status: 'processed',
        transaction_reference: checkout.reference,
        refund_reference: 'refund-dispute-partial',
        amount: '1000',
        currency: 'GHS',
        domain: 'test',
      },
    });
    await service.handleWebhook(refund.body, refund.signature);

    expect(await payments.findByReference(checkout.reference)).toMatchObject({
      status: 'fulfilled',
      refundedPesewas: 1_000,
    });
    expect(await entitlements.remainingRides('u1')).toBe(RIDES);
  });
});

describe('credit-netted checkout (#128)', () => {
  /** Grant credit the way month-end conversion does, so the balance is real. */
  async function grant(
    credits: InMemoryCreditLedgerRepository,
    userId: string,
    pesewas: number,
  ): Promise<void> {
    await credits.record({
      userId,
      deltaPesewas: pesewas,
      reason: 'month_end_conversion',
      idempotencyKey: `grant:${userId}:${pesewas}`,
    });
  }

  it('charges the price less the credit balance, and says so', async () => {
    const { service, credits, payments } = await priced();
    await grant(credits, 'u1', 5_000);

    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);

    expect(checkout.pricePesewas).toBe(FARE * RIDES);
    expect(checkout.appliedCreditPesewas).toBe(5_000);
    expect(checkout.chargePesewas).toBe(FARE * RIDES - 5_000);
    expect(await payments.findByReference(checkout.reference)).toMatchObject({
      amount: FARE * RIDES - 5_000,
      appliedCreditPesewas: 5_000,
    });
  });

  it('does not touch the ledger at checkout — an abandoned one must not burn credit', async () => {
    const { service, credits } = await priced();
    await grant(credits, 'u1', 5_000);
    await service.initializeSubscription('u1', 'monthly', ROUTE);
    expect(await credits.balancePesewas('u1')).toBe(5_000);
  });

  it('debits the ledger on charge.success', async () => {
    const { service, credits } = await priced();
    await grant(credits, 'u1', 5_000);
    const { reference, chargePesewas } = await service.initializeSubscription(
      'u1',
      'monthly',
      ROUTE,
    );

    const { body, signature } = chargeSuccess(reference, chargePesewas);
    await service.handleWebhook(body, signature);

    expect(await credits.balancePesewas('u1')).toBe(0);
  });

  it('a replayed webhook does not debit twice', async () => {
    const { service, credits } = await priced();
    await grant(credits, 'u1', 5_000);
    const { reference, chargePesewas } = await service.initializeSubscription(
      'u1',
      'monthly',
      ROUTE,
    );

    const { body, signature } = chargeSuccess(reference, chargePesewas);
    await service.handleWebhook(body, signature);
    await service.handleWebhook(body, signature);

    expect(await credits.balancePesewas('u1')).toBe(0);
  });

  it('leaves the balance alone when the rider has no credit', async () => {
    const { service, credits, payments } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    expect(await payments.findByReference(reference)).toMatchObject({
      amount: FARE * RIDES,
      appliedCreditPesewas: 0,
    });
    expect(await credits.balancePesewas('u1')).toBe(0);
  });

  it('never nets the charge below the Paystack floor; the rest stays on the ledger', async () => {
    const { service, credits } = await priced();
    const price = FARE * RIDES;
    await grant(credits, 'u1', price + 10_000); // more credit than the whole plan

    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);

    expect(checkout.chargePesewas).toBe(MIN_CHARGE_PESEWAS);
    expect(checkout.appliedCreditPesewas).toBe(price - MIN_CHARGE_PESEWAS);

    const { body, signature } = chargeSuccess(checkout.reference, checkout.chargePesewas);
    await service.handleWebhook(body, signature);
    expect(await credits.balancePesewas('u1')).toBe(price + 10_000 - checkout.appliedCreditPesewas);
  });

  it('prevents two checkouts from spending the same credit', async () => {
    const { service, credits } = await priced();
    await grant(credits, 'u1', 5_000);

    await service.initializeSubscription('u1', 'monthly', ROUTE);
    await expect(service.initializeSubscription('u1', 'monthly', ROUTE)).rejects.toBeInstanceOf(
      CheckoutInProgressError,
    );
    expect(await credits.balancePesewas('u1')).toBe(5_000);
  });
});

describe('rider stop pin (#204)', () => {
  const STOP_A = '22222222-2222-4222-8222-222222222222'; // seq 1
  const STOP_B = '33333333-3333-4333-8333-333333333333'; // seq 2
  const OFF_ROUTE = '44444444-4444-4444-8444-444444444444';

  /** A priced corridor with two stops in order, which is what a real route has. */
  async function withStops() {
    const ctx = await priced();
    await ctx.routeStops.create({ routeId: ROUTE, stopId: STOP_A, seq: 1 });
    await ctx.routeStops.create({ routeId: ROUTE, stopId: STOP_B, seq: 2 });
    return ctx;
  }

  it('freezes the chosen stops on the payment', async () => {
    const { service, payments } = await withStops();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE, {
      pickupStopId: STOP_A,
      dropoffStopId: STOP_B,
    });
    expect(await payments.findByReference(reference)).toMatchObject({
      pickupStopId: STOP_A,
      dropoffStopId: STOP_B,
    });
  });

  it('carries them onto the subscription when the webhook activates it', async () => {
    const { service, subscriptions } = await withStops();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE, {
      pickupStopId: STOP_A,
      dropoffStopId: STOP_B,
    });
    const { body, signature } = chargeSuccess(reference);
    await service.handleWebhook(body, signature);

    expect(await subscriptions.findActiveByUser('u1')).toMatchObject({
      pickupStopId: STOP_A,
      dropoffStopId: STOP_B,
    });
  });

  it('rejects a stop that is not on the route', async () => {
    const { service } = await withStops();
    await expect(
      service.initializeSubscription('u1', 'monthly', ROUTE, {
        pickupStopId: STOP_A,
        dropoffStopId: OFF_ROUTE,
      }),
    ).rejects.toBeInstanceOf(InvalidStopsError);
  });

  it('rejects boarding after the destination', async () => {
    const { service } = await withStops();
    await expect(
      service.initializeSubscription('u1', 'monthly', ROUTE, {
        pickupStopId: STOP_B,
        dropoffStopId: STOP_A,
      }),
    ).rejects.toBeInstanceOf(InvalidStopsError);
  });

  it('rejects the same stop for both', async () => {
    const { service } = await withStops();
    await expect(
      service.initializeSubscription('u1', 'monthly', ROUTE, {
        pickupStopId: STOP_A,
        dropoffStopId: STOP_A,
      }),
    ).rejects.toBeInstanceOf(InvalidStopsError);
  });

  it('rejects one stop without the other', async () => {
    const { service } = await withStops();
    await expect(
      service.initializeSubscription('u1', 'monthly', ROUTE, { pickupStopId: STOP_A }),
    ).rejects.toBeInstanceOf(InvalidStopsError);
  });

  it('still works for clients that send no stops at all', async () => {
    const { service, payments, subscriptions } = await withStops();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    expect(await payments.findByReference(reference)).toMatchObject({
      pickupStopId: null,
      dropoffStopId: null,
    });
    const { body, signature } = chargeSuccess(reference);
    await service.handleWebhook(body, signature);
    expect(await subscriptions.findActiveByUser('u1')).toMatchObject({ pickupStopId: null });
  });
});

describe('subscription price records cash plus credit (#128 follow-up)', () => {
  it('records the full period price, not just the cash charged', async () => {
    const { service, subscriptions, credits } = await priced();
    await credits.record({
      userId: 'u1',
      deltaPesewas: 5_000,
      reason: 'month_end_conversion',
      idempotencyKey: 'grant:u1',
    });

    const checkout = await service.initializeSubscription('u1', 'monthly', ROUTE);
    expect(checkout.chargePesewas).toBe(FARE * RIDES - 5_000); // cash is netted

    const { body, signature } = chargeSuccess(checkout.reference, checkout.chargePesewas);
    await service.handleWebhook(body, signature);

    // ...but the period was still worth the full price. Recording only the cash
    // half would make revenue look worse than it was.
    expect(await subscriptions.findActiveByUser('u1')).toMatchObject({
      pricePesewas: FARE * RIDES,
    });
  });
});
