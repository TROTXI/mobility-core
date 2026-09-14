import { describe, expect, it } from 'vitest';
import { InMemoryCreditLedgerRepository } from '../src/modules/entitlements/credit-ledger.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import {
  ActiveSubscriptionPaymentError,
  InMemoryPaymentLifecycle,
  type SettledCharge,
  type SubscriptionCheckoutInput,
} from '../src/modules/payments/payment-lifecycle';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import {
  InMemorySubscriptionRepository,
  type SubscriptionRepository,
} from '../src/modules/subscriptions/subscription.repository';

const ROUTE = '11111111-1111-4111-8111-111111111111';

function make(subscriptions: SubscriptionRepository = new InMemorySubscriptionRepository()) {
  const payments = new InMemoryPaymentRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  const credits = new InMemoryCreditLedgerRepository();
  const lifecycle = new InMemoryPaymentLifecycle({
    payments,
    subscriptions,
    entitlements,
    credits,
  });
  return { lifecycle, payments, subscriptions, entitlements, credits };
}

function checkout(
  reference: string,
  overrides: Partial<SubscriptionCheckoutInput> = {},
): SubscriptionCheckoutInput {
  return {
    userId: 'rider-1',
    reference,
    purpose: 'subscription',
    plan: 'monthly',
    routeId: ROUTE,
    currency: 'GHS',
    ridesGranted: 44,
    farePesewas: 600,
    creditPesewasPerRide: 45,
    pricePesewas: 26_400,
    ...overrides,
  };
}

function settled(reference: string, paidAt = new Date()): SettledCharge {
  return {
    reference,
    status: 'success',
    amountPesewas: 26_400,
    currency: 'GHS',
    providerTransactionId: '123456',
    providerDomain: 'test',
    channel: 'mobile_money',
    feesPesewas: 100,
    paidAt,
  };
}

describe('atomic subscription payment lifecycle', () => {
  it('serializes concurrent checkout attempts for one rider', async () => {
    const { lifecycle } = make();
    const attempts = await Promise.allSettled([
      lifecycle.createSubscriptionCheckout(checkout('ref-1')),
      lifecycle.createSubscriptionCheckout(checkout('ref-2')),
    ]);

    expect(attempts.filter((attempt) => attempt.status === 'fulfilled')).toHaveLength(1);
    expect(attempts.filter((attempt) => attempt.status === 'rejected')).toHaveLength(1);
  });

  it('keeps fulfillment retryable when subscription creation fails', async () => {
    const base = new InMemorySubscriptionRepository();
    const subscriptions: SubscriptionRepository = {
      findActiveByUser: base.findActiveByUser.bind(base),
      findCurrentByUser: base.findCurrentByUser.bind(base),
      findActiveByRoute: base.findActiveByRoute.bind(base),
      findAllActive: base.findAllActive.bind(base),
      findEndedPeriods: base.findEndedPeriods.bind(base),
      rollPeriod: base.rollPeriod.bind(base),
      create: async () => {
        throw new Error('subscription write failed');
      },
    };
    const { lifecycle, payments, entitlements, credits } = make(subscriptions);
    await lifecycle.createSubscriptionCheckout(checkout('ref-fault'));

    await expect(lifecycle.fulfillSubscriptionCharge(settled('ref-fault'))).rejects.toThrow(
      'subscription write failed',
    );
    expect((await payments.findByReference('ref-fault'))?.status).toBe('pending');
    expect(await entitlements.remainingRides('rider-1')).toBe(0);
    expect(await credits.balancePesewas('rider-1')).toBe(0);
  });

  it('closes one period at its frozen rate and renews the same subscription', async () => {
    const { lifecycle, payments, subscriptions, entitlements, credits } = make();
    const firstPaidAt = new Date('2026-01-01T00:00:00.000Z');
    await lifecycle.createSubscriptionCheckout(
      checkout('ref-first', { now: firstPaidAt, creditPesewasPerRide: 45 }),
    );
    expect(await lifecycle.fulfillSubscriptionCharge(settled('ref-first', firstPaidAt))).toBe(
      'fulfilled',
    );
    const firstPayment = (await payments.findByReference('ref-first'))!;
    const firstSubscription = (await subscriptions.findActiveByUser('rider-1'))!;
    expect(firstPayment.subscriptionPeriodId).toBeTruthy();

    await entitlements.record({
      userId: 'rider-1',
      deltaRides: -4,
      reason: 'boarding',
      refType: 'test',
      refId: 'four-rides',
      idempotencyKey: 'four-rides',
      subscriptionPeriodId: firstPayment.subscriptionPeriodId,
    });
    const close = await lifecycle.closeEndedPeriods(new Date('2026-02-02T00:00:00.000Z'));
    expect(close).toMatchObject({ closed: 1, ridesConverted: 40, creditPesewas: 1_800 });
    expect(await entitlements.remainingRidesForPeriod(firstPayment.subscriptionPeriodId!)).toBe(0);
    expect(await credits.balancePesewas('rider-1')).toBe(1_800);

    const renewal = await lifecycle.createSubscriptionCheckout(
      checkout('ref-renew', {
        now: new Date('2026-02-02T00:00:00.000Z'),
        creditPesewasPerRide: 99,
      }),
    );
    expect(renewal.subscriptionId).toBe(firstSubscription.id);
    expect(renewal.appliedCreditPesewas).toBe(1_800);
    expect(renewal.amount).toBe(24_600);

    const renewalCharge = settled('ref-renew', new Date('2026-02-02T00:00:00.000Z'));
    renewalCharge.amountPesewas = renewal.amount;
    expect(await lifecycle.fulfillSubscriptionCharge(renewalCharge)).toBe('fulfilled');
    expect((await subscriptions.findActiveByUser('rider-1'))?.id).toBe(firstSubscription.id);
    expect(await credits.balancePesewas('rider-1')).toBe(0);
    expect(await entitlements.remainingRides('rider-1')).toBe(44);
  });

  it('rejects checkout while the paid period is still active', async () => {
    const { lifecycle } = make();
    const paidAt = new Date('2026-01-01T00:00:00.000Z');
    await lifecycle.createSubscriptionCheckout(checkout('ref-active', { now: paidAt }));
    await lifecycle.fulfillSubscriptionCharge(settled('ref-active', paidAt));

    await expect(
      lifecycle.createSubscriptionCheckout(
        checkout('ref-too-soon', { now: new Date('2026-01-15T00:00:00.000Z') }),
      ),
    ).rejects.toBeInstanceOf(ActiveSubscriptionPaymentError);
  });

  it('bounds each period-close maintenance batch', async () => {
    const { lifecycle } = make();
    const paidAt = new Date('2026-01-01T00:00:00.000Z');
    for (const userId of ['rider-1', 'rider-2']) {
      const reference = `ref-${userId}`;
      await lifecycle.createSubscriptionCheckout(checkout(reference, { userId, now: paidAt }));
      await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt));
    }

    const first = await lifecycle.closeEndedPeriods(new Date('2026-02-02T00:00:00.000Z'), 1);
    const second = await lifecycle.closeEndedPeriods(new Date('2026-02-02T00:00:00.000Z'), 1);

    expect(first).toMatchObject({ considered: 1, closed: 1 });
    expect(second).toMatchObject({ considered: 1, closed: 1 });
  });
});
