import { describe, expect, it } from 'vitest';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import { PaymentsService } from '../src/modules/payments/payments.service';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { InMemoryUserRepository, type User } from '../src/modules/users/user.repository';

const FAKE_SECRET = 'fake-paystack-secret';
const FEES = { monthly: 2000, annual: 20000 } as const;

async function make(users = new InMemoryUserRepository()) {
  const payments = new InMemoryPaymentRepository();
  const subscriptions = new InMemorySubscriptionRepository();
  const service = new PaymentsService({
    payments,
    subscriptions,
    entitlements: new InMemoryEntitlementLedgerRepository(),
    users,
    paystack: new FakePaystackClient(FAKE_SECRET),
    subscriptionFees: FEES,
    ridesPerPeriod: 44,
  });
  return { service, payments, subscriptions, users };
}

/** A charge.success payload carrying the payer's mobile-money number. */
function chargeSuccess(reference: string, phone?: string, customerPhone?: string) {
  const body = JSON.stringify({
    event: 'charge.success',
    data: {
      reference,
      ...(phone ? { authorization: { mobile_money_number: phone } } : {}),
      ...(customerPhone ? { customer: { phone: customerPhone } } : {}),
    },
  });
  return { body, signature: paystackSignature(body, FAKE_SECRET) };
}

describe('phone capture on charge.success (#182)', () => {
  it('stores the payer number, normalised, without asking the rider for it', async () => {
    const users = new InMemoryUserRepository();
    const user = await users.create({ displayName: 'Ama' });
    const { service } = await make(users);

    const { reference } = await service.initializeSubscription(user.id, 'monthly');
    const { body, signature } = chargeSuccess(reference, '0244123456');
    await service.handleWebhook(body, signature);

    // A successful mobile-money charge proves control of the handset, so the
    // number is verified without an OTP round trip.
    expect((await users.findById(user.id))!.phone).toBe('+233244123456');
  });

  it('falls back to the customer block when authorization has no number', async () => {
    const users = new InMemoryUserRepository();
    const user = await users.create({ displayName: 'Ama' });
    const { service } = await make(users);

    const { reference } = await service.initializeSubscription(user.id, 'monthly');
    const { body, signature } = chargeSuccess(reference, undefined, '+233 244 999 888');
    await service.handleWebhook(body, signature);

    expect((await users.findById(user.id))!.phone).toBe('+233244999888');
  });

  it('never overwrites a number the rider already set', async () => {
    const users = new InMemoryUserRepository();
    const user = await users.create({ displayName: 'Ama', phone: '+233201111111' });
    const { service } = await make(users);

    const { reference } = await service.initializeSubscription(user.id, 'monthly');
    const { body, signature } = chargeSuccess(reference, '0244123456');
    await service.handleWebhook(body, signature);

    expect((await users.findById(user.id))!.phone).toBe('+233201111111');
  });

  it('still activates the subscription when the phone write blows up', async () => {
    // users.phone is UNIQUE and two family members can legitimately pay from one
    // handset. If that collision failed the webhook, Paystack would retry and we
    // would lose the activation over a phone number.
    const users = new InMemoryUserRepository();
    const user = await users.create({ displayName: 'Ama' });
    const exploding = Object.assign(Object.create(Object.getPrototypeOf(users)), users, {
      backfillContact: async (): Promise<User | null> => {
        throw Object.assign(new Error('duplicate key'), { code: '23505' });
      },
    }) as InMemoryUserRepository;

    const { service, subscriptions, payments } = await make(exploding);
    const { reference } = await service.initializeSubscription(user.id, 'monthly');
    const { body, signature } = chargeSuccess(reference, '0244123456');

    await expect(service.handleWebhook(body, signature)).resolves.toBeUndefined();
    expect(await subscriptions.findActiveByUser(user.id)).not.toBeNull();
    expect((await payments.findByReference(reference))?.status).toBe('paid');
  });

  it('ignores an unusable number rather than storing a guess', async () => {
    const users = new InMemoryUserRepository();
    const user = await users.create({ displayName: 'Ama' });
    const { service } = await make(users);

    const { reference } = await service.initializeSubscription(user.id, 'monthly');
    const { body, signature } = chargeSuccess(reference, 'not-a-number');
    await service.handleWebhook(body, signature);

    expect((await users.findById(user.id))!.phone).toBeNull();
  });
});
