import { describe, expect, it } from 'vitest';
import { InMemoryLedgerRepository } from '../src/modules/ledger/ledger.repository';
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

const FAKE_SECRET = 'fake-paystack-secret';
const subscriptionFees = { monthly: 2000, annual: 20000 }; // pesewas (GHS 20 / 200)

function make(subscriptions: SubscriptionRepository = new InMemorySubscriptionRepository()) {
  const payments = new InMemoryPaymentRepository();
  const ledger = new InMemoryLedgerRepository();
  const service = new PaymentsService({
    payments,
    ledger,
    subscriptions,
    paystack: new FakePaystackClient(FAKE_SECRET),
    subscriptionFees,
  });
  return { payments, ledger, subscriptions, service };
}

function chargeSuccess(reference: string): { body: string; signature: string } {
  const body = JSON.stringify({ event: 'charge.success', data: { reference } });
  return { body, signature: paystackSignature(body, FAKE_SECRET) };
}

describe('PaymentsService.initialize*', () => {
  it('subscription: pending payment with the membership fee + a checkout URL', async () => {
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

  it('topup: pending payment with no plan and the chosen amount', async () => {
    const { service, payments } = make();
    const { reference } = await service.initializeTopup('u1', 5000);
    expect(await payments.findByReference(reference)).toMatchObject({
      purpose: 'topup',
      plan: null,
      amount: 5000,
      status: 'pending',
    });
  });

  it('throws when payments are not configured', async () => {
    const service = new PaymentsService({
      payments: new InMemoryPaymentRepository(),
      ledger: new InMemoryLedgerRepository(),
      subscriptions: new InMemorySubscriptionRepository(),
      subscriptionFees,
    });
    await expect(service.initializeTopup('u1', 5000)).rejects.toBeInstanceOf(
      PaymentsNotConfiguredError,
    );
  });
});

describe('PaymentsService.handleWebhook', () => {
  it('rejects an invalid signature', async () => {
    const { service } = make();
    await expect(service.handleWebhook('{}', 'bad')).rejects.toBeInstanceOf(InvalidWebhookError);
  });

  it('subscription paid: activates the subscription and grants NO tokens', async () => {
    const { service, ledger, subscriptions, payments } = make();
    const { reference } = await service.initializeSubscription('u1', 'monthly');
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);

    expect(await subscriptions.findActiveByUser('u1')).not.toBeNull();
    expect(await ledger.balanceOf('u1')).toBe(0); // membership fee is not ride money
    expect((await payments.findByReference(reference))?.status).toBe('paid');
  });

  it('topup paid: grants tokens and does NOT activate a subscription', async () => {
    const { service, ledger, subscriptions, payments } = make();
    const { reference } = await service.initializeTopup('u1', 5000);
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);

    expect(await ledger.balanceOf('u1')).toBe(5000);
    expect(await subscriptions.findActiveByUser('u1')).toBeNull();
    expect((await payments.findByReference(reference))?.status).toBe('paid');
  });

  it('topup is idempotent — replay does not double-grant', async () => {
    const { service, ledger } = make();
    const { reference } = await service.initializeTopup('u1', 5000);
    const { body, signature } = chargeSuccess(reference);

    await service.handleWebhook(body, signature);
    await service.handleWebhook(body, signature);

    expect(await ledger.balanceOf('u1')).toBe(5000);
  });

  it('ignores non charge.success events and unknown references', async () => {
    const { service, ledger } = make();
    const { reference } = await service.initializeTopup('u1', 5000);

    const failed = JSON.stringify({ event: 'charge.failed', data: { reference } });
    await service.handleWebhook(failed, paystackSignature(failed, FAKE_SECRET));
    const unknown = JSON.stringify({ event: 'charge.success', data: { reference: 'nope' } });
    await service.handleWebhook(unknown, paystackSignature(unknown, FAKE_SECRET));

    expect(await ledger.balanceOf('u1')).toBe(0);
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
