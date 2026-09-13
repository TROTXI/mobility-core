import { createHash } from 'node:crypto';
import { paystackSignature } from '../src/modules/payments/paystack.client';

/** Build a synthetic settlement ONLY for the development fake checkout. */
export function seedPaymentWebhook(checkout: {
  reference: string;
  chargePesewas: number;
  authorizationUrl: string;
}) {
  const url = new URL(checkout.authorizationUrl);
  if (
    url.origin !== 'https://checkout.paystack.test' ||
    url.pathname !== `/${checkout.reference}`
  ) {
    throw new Error('Refusing synthetic settlement: checkout is not the development fake');
  }
  if (!Number.isSafeInteger(checkout.chargePesewas) || checkout.chargePesewas <= 0) {
    throw new Error('Invalid seed checkout amount');
  }
  // Stable across retries, distinct per reference; decimal text is accepted by
  // the strict provider contract without JS integer precision loss.
  const id = BigInt(
    `0x${createHash('sha256').update(checkout.reference).digest('hex')}`,
  ).toString();
  const body = JSON.stringify({
    event: 'charge.success',
    data: {
      id,
      reference: checkout.reference,
      status: 'success',
      amount: checkout.chargePesewas,
      currency: 'GHS',
      domain: 'test',
      paid_at: new Date().toISOString(),
    },
  });
  return {
    body,
    headers: {
      'content-type': 'application/json',
      'x-paystack-signature': paystackSignature(body, 'fake-paystack-secret'),
    },
  };
}
