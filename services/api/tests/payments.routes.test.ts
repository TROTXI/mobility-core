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
  const paymentsService = new PaymentsService({
    payments: new InMemoryPaymentRepository(),
    ledger,
    subscriptions: new InMemorySubscriptionRepository(),
    paystack: new FakePaystackClient(FAKE_SECRET),
    planPrices: { monthly: 250, annual: 2500 },
  });
  return { ledger, build: buildApp({ auth, ledger, paymentsService }) };
}

describe('POST /payments/initialize', () => {
  it('rejects an unauthenticated request', async () => {
    const { build } = appWithPayments();
    const app = await build;
    const res = await app.inject({
      method: 'POST',
      url: '/payments/initialize',
      payload: { plan: 'monthly' },
    });
    expect(res.statusCode).toBe(401);
  });

  it('returns a checkout URL for an authenticated user', async () => {
    const { build } = appWithPayments();
    const app = await build;
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });
    const res = await app.inject({
      method: 'POST',
      url: '/payments/initialize',
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
    const res = await app.inject({
      method: 'POST',
      url: '/payments/initialize',
      headers: bearer(token),
      payload: { plan: 'monthly' },
    });
    expect(res.statusCode).toBe(503);
  });
});

describe('POST /webhooks/paystack', () => {
  it('grants tokens on a validly-signed charge.success (end-to-end)', async () => {
    const { build } = appWithPayments();
    const app = await build;
    const token = await jwt.signAccessToken({ userId: 'rider-1', role: 'commuter' });

    const init = await app.inject({
      method: 'POST',
      url: '/payments/initialize',
      headers: bearer(token),
      payload: { plan: 'monthly' },
    });
    const { reference } = init.json();

    const body = JSON.stringify({ event: 'charge.success', data: { reference } });
    const res = await app.inject({
      method: 'POST',
      url: '/webhooks/paystack',
      headers: {
        'content-type': 'application/json',
        'x-paystack-signature': paystackSignature(body, FAKE_SECRET),
      },
      payload: body,
    });
    expect(res.statusCode).toBe(200);

    const balance = await app.inject({ method: 'GET', url: '/me/balance', headers: bearer(token) });
    expect(balance.json()).toEqual({ balanceGhs: 250 });
  });

  it('rejects a bad signature with 401', async () => {
    const { build } = appWithPayments();
    const app = await build;
    const body = JSON.stringify({ event: 'charge.success', data: { reference: 'x' } });
    const res = await app.inject({
      method: 'POST',
      url: '/webhooks/paystack',
      headers: { 'content-type': 'application/json', 'x-paystack-signature': 'bad' },
      payload: body,
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
