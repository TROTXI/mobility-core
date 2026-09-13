import { describe, expect, it } from 'vitest';
import { seedPaymentWebhook } from '../scripts/seed-payment';
import { verifySignature } from '../src/modules/payments/paystack.client';

const checkout = {
  reference: 'subscription-seed-123',
  chargePesewas: 26400,
  authorizationUrl: 'https://checkout.paystack.test/subscription-seed-123',
};

describe('development seed payment', () => {
  it('includes signed strict provider facts and stable per-reference IDs', () => {
    const event = seedPaymentWebhook(checkout);
    const data = JSON.parse(event.body).data;
    expect(data).toMatchObject({
      reference: checkout.reference,
      amount: 26400,
      domain: 'test',
      currency: 'GHS',
    });
    expect(data.id).toMatch(/^\d+$/);
    expect(Number.isNaN(Date.parse(data.paid_at))).toBe(false);
    expect(
      verifySignature(event.body, event.headers['x-paystack-signature'], 'fake-paystack-secret'),
    ).toBe(true);
    expect(JSON.parse(seedPaymentWebhook(checkout).body).data.id).toBe(data.id);
    const other = seedPaymentWebhook({
      ...checkout,
      reference: 'another',
      authorizationUrl: 'https://checkout.paystack.test/another',
    });
    expect(JSON.parse(other.body).data.id).not.toBe(data.id);
  });

  it.each([
    'https://checkout.paystack.com/subscription-seed-123',
    'https://checkout.paystack.test.attacker.test/subscription-seed-123',
    'http://checkout.paystack.test/subscription-seed-123',
    'https://checkout.paystack.test/different-reference',
  ])('refuses a non-fake or mismatched checkout: %s', (authorizationUrl) => {
    expect(() => seedPaymentWebhook({ ...checkout, authorizationUrl })).toThrow(
      'not the development fake',
    );
  });

  it.each([0, -1, 0.5, Number.MAX_SAFE_INTEGER + 1])(
    'rejects invalid amount %s',
    (chargePesewas) => {
      expect(() => seedPaymentWebhook({ ...checkout, chargePesewas })).toThrow(
        'Invalid seed checkout amount',
      );
    },
  );
});
