import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import { PaymentsService } from '../src/modules/payments/payments.service';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';
import { InMemoryEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const FAKE_SECRET = 'fake-paystack-secret';
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });

function appWithPayments() {
  const subscriptions = new InMemorySubscriptionRepository();
  const entitlements = new InMemoryEntitlementLedgerRepository();
  const paymentsService = new PaymentsService({
    payments: new InMemoryPaymentRepository(),
    subscriptions,
    entitlements,
    paystack: new FakePaystackClient(FAKE_SECRET),
    subscriptionFees: { monthly: 2000, annual: 20000 },
    ridesPerPeriod: 44,
  });
  // Share the entitlements instance with the app so GET /me/rides sees the
  // rides the webhook allocates.
  return { subscriptions, entitlements, build: buildApp({ auth, paymentsService, entitlements }) };
}

async function webhookFor(app: Awaited<ReturnType<typeof buildApp>>, reference: string) {
  const body = JSON.stringify({ event: 'charge.success', data: { reference } });
  return app.inject({
    method: 'POST',
    url: '/webhooks/paystack',
    headers: {
      'content-type': 'application/json',
      'x-paystack-signature': paystackSignature(body, FAKE_SECRET),
    },
    payload: body,
  });
}

describe('POST /payments/subscribe', () => {
  it('rejects unauthenticated requests', async () => {
    const app = await appWithPayments().build;
    expect(
      (
        await app.inject({
          method: 'POST',
          url: '/payments/subscribe',
          payload: { plan: 'monthly' },
        })
      ).statusCode,
    ).toBe(401);
  });

  it('returns a checkout URL for an authenticated user', async () => {
    const app = await appWithPayments().build;
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: '/payments/subscribe',
      headers: bearer(token),
      payload: { plan: 'monthly' },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().authorizationUrl).toBeTruthy();
    expect(res.json().reference).toBeTruthy();
  });

  it('returns 503 when payments are not configured', async () => {
    const app = await buildApp({ auth });
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    expect(
      (
        await app.inject({
          method: 'POST',
          url: '/payments/subscribe',
          headers: bearer(token),
          payload: { plan: 'monthly' },
        })
      ).statusCode,
    ).toBe(503);
  });

  it('the legacy top-up route is gone (404)', async () => {
    const app = await appWithPayments().build;
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: '/payments/topup',
      headers: bearer(token),
      payload: { amountPesewas: 5000 },
    });
    expect(res.statusCode).toBe(404);
  });
});

describe('POST /webhooks/paystack', () => {
  it('subscription: a signed charge.success activates the membership', async () => {
    const { build, subscriptions } = appWithPayments();
    const app = await build;
    const token = await jwt.signAccessToken({ userId: 'rider-2', role: 'commuter' });
    const { reference } = (
      await app.inject({
        method: 'POST',
        url: '/payments/subscribe',
        headers: bearer(token),
        payload: { plan: 'monthly' },
      })
    ).json();

    expect((await webhookFor(app, reference)).statusCode).toBe(200);
    expect(await subscriptions.findActiveByUser('rider-2')).not.toBeNull();

    // …and the rider now has their allocated rides via GET /me/rides.
    const rides = await app.inject({
      method: 'GET',
      url: '/me/rides',
      headers: bearer(token),
    });
    expect(rides.statusCode).toBe(200);
    expect(rides.json()).toMatchObject({ remainingRides: 44, creditPesewas: 0 });
  });

  it('rejects a bad signature with 401', async () => {
    const app = await appWithPayments().build;
    const res = await app.inject({
      method: 'POST',
      url: '/webhooks/paystack',
      headers: { 'content-type': 'application/json', 'x-paystack-signature': 'bad' },
      payload: '{"event":"charge.success","data":{"reference":"x"}}',
    });
    expect(res.statusCode).toBe(401);
  });

  it('returns 503 when payments are not configured', async () => {
    const app = await buildApp({ auth });
    const res = await app.inject({
      method: 'POST',
      url: '/webhooks/paystack',
      headers: { 'content-type': 'application/json', 'x-paystack-signature': 'x' },
      payload: '{}',
    });
    expect(res.statusCode).toBe(503);
  });
});
