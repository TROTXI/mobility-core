import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryLedgerRepository } from '../src/modules/ledger/ledger.repository';
import { InMemoryPaymentRepository } from '../src/modules/payments/payment.repository';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import { PaymentsService } from '../src/modules/payments/payments.service';
import { InMemorySubscriptionRepository } from '../src/modules/subscriptions/subscription.repository';
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
  const ledger = new InMemoryLedgerRepository();
  const subscriptions = new InMemorySubscriptionRepository();
  const paymentsService = new PaymentsService({
    payments: new InMemoryPaymentRepository(),
    ledger,
    subscriptions,
    paystack: new FakePaystackClient(FAKE_SECRET),
    subscriptionFees: { monthly: 20, annual: 200 },
  });
  return { ledger, subscriptions, build: buildApp({ auth, ledger, paymentsService }) };
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

describe('POST /payments/subscribe + /payments/topup', () => {
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
    expect(
      (
        await app.inject({
          method: 'POST',
          url: '/payments/topup',
          payload: { amountPesewas: 5000 },
        })
      ).statusCode,
    ).toBe(401);
  });

  it('returns a checkout URL for an authenticated user', async () => {
    const app = await appWithPayments().build;
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    const sub = await app.inject({
      method: 'POST',
      url: '/payments/subscribe',
      headers: bearer(token),
      payload: { plan: 'monthly' },
    });
    expect(sub.statusCode).toBe(200);
    expect(sub.json().authorizationUrl).toBeTruthy();
    const top = await app.inject({
      method: 'POST',
      url: '/payments/topup',
      headers: bearer(token),
      payload: { amountPesewas: 5000 },
    });
    expect(top.statusCode).toBe(200);
  });

  it('returns 503 when payments are not configured', async () => {
    const app = await buildApp({ auth });
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    expect(
      (
        await app.inject({
          method: 'POST',
          url: '/payments/topup',
          headers: bearer(token),
          payload: { amountPesewas: 5000 },
        })
      ).statusCode,
    ).toBe(503);
  });
});

describe('POST /webhooks/paystack', () => {
  it('topup: a signed charge.success grants tokens (balance via /me/balance)', async () => {
    const { build } = appWithPayments();
    const app = await build;
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    const { reference } = (
      await app.inject({
        method: 'POST',
        url: '/payments/topup',
        headers: bearer(token),
        payload: { amountPesewas: 5000 },
      })
    ).json();

    expect((await webhookFor(app, reference)).statusCode).toBe(200);

    const balance = await app.inject({ method: 'GET', url: '/me/balance', headers: bearer(token) });
    expect(balance.json()).toEqual({ balancePesewas: 5000 });
  });

  it('subscription: a signed charge.success activates membership without granting tokens', async () => {
    const { build, ledger, subscriptions } = appWithPayments();
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
    expect(await ledger.balanceOf('rider-2')).toBe(0);
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
