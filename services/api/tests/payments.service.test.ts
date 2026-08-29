import { describe, expect, it } from 'vitest';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import {
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
import { InMemoryUserRepository } from '../src/modules/users/user.repository';
import { InMemoryPricingRepository } from '../src/modules/payments/pricing.repository';

const FAKE_SECRET = 'fake-paystack-secret';
const RIDES = 44;
/** GHS 6 a trip — a plausible Accra corridor fare. */
const FARE = 600;
const ROUTE = '11111111-1111-4111-8111-111111111111';

function make(subscriptions: SubscriptionRepository = new InMemorySubscriptionRepository()) {
  const payments = new InMemoryPaymentRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  const pricing = new InMemoryPricingRepository();
  const service = new PaymentsService({
    payments,
    subscriptions,
    entitlements,
    paystack: new FakePaystackClient(FAKE_SECRET),
    users: new InMemoryUserRepository(),
    pricing,
    ridesPerPeriod: RIDES,
  });
  return { payments, subscriptions, entitlements, pricing, service };
}

/** A priced corridor: without a fare in force there is no price to charge. */
async function priced(subscriptions?: SubscriptionRepository) {
  const ctx = make(subscriptions);
  await ctx.pricing.setFare(ROUTE, FARE);
  return ctx;
}

function chargeSuccess(reference: string): { body: string; signature: string } {
  const body = JSON.stringify({ event: 'charge.success', data: { reference } });
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

  it('subscription paid: activates the subscription, allocates rides, marks paid', async () => {
    const { service, subscriptions, payments, entitlements } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);

    expect(await subscriptions.findActiveByUser('u1')).not.toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(RIDES);
    expect((await payments.findByReference(reference))?.status).toBe('paid');
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

  it('ignores non charge.success events and unknown references', async () => {
    const { service, subscriptions } = await priced();
    const { reference } = await service.initializeSubscription('u1', 'monthly', ROUTE);

    const failed = JSON.stringify({ event: 'charge.failed', data: { reference } });
    await service.handleWebhook(failed, paystackSignature(failed, FAKE_SECRET));
    const unknown = JSON.stringify({ event: 'charge.success', data: { reference: 'nope' } });
    await service.handleWebhook(unknown, paystackSignature(unknown, FAKE_SECRET));

    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
  });

  it('treats a unique-violation on activation as already-active', async () => {
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
  });

  it('propagates non-unique errors from activation', async () => {
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
    await expect(service.handleWebhook(body, signature)).rejects.toThrow('db down');
  });
});
