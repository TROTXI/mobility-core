import { describe, expect, it } from 'vitest';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import {
  InvalidWebhookError,
  PaymentsNotConfiguredError,
  PaymentsService,
} from '../src/modules/payments/payments.service';
import {
  InMemorySubscriptionRepository,
  type SubscriptionRepository,
} from '../src/modules/subscriptions/subscription.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';

const FAKE_SECRET = 'fake-paystack-secret';
const subscriptionFees = { monthly: 2000, annual: 20000 }; // pesewas (GHS 20 / 200)
const RIDES = 44;

function make(subscriptions: SubscriptionRepository = new InMemorySubscriptionRepository()) {
  const payments = new InMemoryPaymentRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  const service = new PaymentsService({
    payments,
    subscriptions,
    entitlements,
    paystack: new FakePaystackClient(FAKE_SECRET),
    subscriptionFees,
    ridesPerPeriod: RIDES,
  });
  return { payments, subscriptions, entitlements, service };
}

function chargeSuccess(reference: string): { body: string; signature: string } {
  const body = JSON.stringify({ event: 'charge.success', data: { reference } });
  return { body, signature: paystackSignature(body, FAKE_SECRET) };
}

describe('PaymentsService.initializeSubscription', () => {
  it('creates a pending payment with the membership fee + a checkout URL', async () => {
    const { service, payments } = make();
    const { reference, authorizationUrl } = await service.initializeSubscription('u1', 'monthly');
    expect(authorizationUrl).toBeTruthy();
    expect(await payments.findByReference(reference)).toMatchObject({
      purpose: 'subscription',
      plan: 'monthly',
      amount: 2000,
      status: 'pending',
    });
  });

  it('throws when payments are not configured', async () => {
    const service = new PaymentsService({
      payments: new InMemoryPaymentRepository(),
      subscriptions: new InMemorySubscriptionRepository(),
      entitlements: new InMemoryEntitlementLedgerRepository(),
      subscriptionFees,
      ridesPerPeriod: RIDES,
    });
    await expect(service.initializeSubscription('u1', 'monthly')).rejects.toBeInstanceOf(
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
    const { service, subscriptions, payments, entitlements } = make();
    const { reference } = await service.initializeSubscription('u1', 'monthly');
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);

    expect(await subscriptions.findActiveByUser('u1')).not.toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(RIDES);
    expect((await payments.findByReference(reference))?.status).toBe('paid');
  });

  it('is idempotent — a replayed webhook does not double-activate or double-allocate', async () => {
    const { service, subscriptions, entitlements } = make();
    const { reference } = await service.initializeSubscription('u1', 'monthly');
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);
    await expect(service.handleWebhook(body, signature)).resolves.toBeUndefined();
    expect(await subscriptions.findActiveByUser('u1')).not.toBeNull();
    expect(await entitlements.remainingRides('u1')).toBe(RIDES); // not 2×
  });

  it('ignores non charge.success events and unknown references', async () => {
    const { service, subscriptions } = make();
    const { reference } = await service.initializeSubscription('u1', 'monthly');

    const failed = JSON.stringify({ event: 'charge.failed', data: { reference } });
    await service.handleWebhook(failed, paystackSignature(failed, FAKE_SECRET));
    const unknown = JSON.stringify({ event: 'charge.success', data: { reference: 'nope' } });
    await service.handleWebhook(unknown, paystackSignature(unknown, FAKE_SECRET));

    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
  });

  it('treats a unique-violation on activation as already-active', async () => {
    const subscriptions: SubscriptionRepository = {
      findActiveByUser: async () => null,
      create: async () => {
        throw Object.assign(new Error('dup'), { code: '23505' });
      },
    };
    const { service } = make(subscriptions);
    const { reference } = await service.initializeSubscription('u1', 'monthly');
    const { body, signature } = chargeSuccess(reference);
    await expect(service.handleWebhook(body, signature)).resolves.toBeUndefined();
  });

  it('propagates non-unique errors from activation', async () => {
    const subscriptions: SubscriptionRepository = {
      findActiveByUser: async () => null,
      create: async () => {
        throw new Error('db down');
      },
    };
    const { service } = make(subscriptions);
    const { reference } = await service.initializeSubscription('u1', 'monthly');
    const { body, signature } = chargeSuccess(reference);
    await expect(service.handleWebhook(body, signature)).rejects.toThrow('db down');
  });
});
