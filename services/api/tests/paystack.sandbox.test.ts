import { randomUUID } from 'node:crypto';
import { describe, expect, it } from 'vitest';
import { PaystackHttpClient } from '../src/modules/payments/paystack.client.live';

const enabled = process.env.RUN_PAYSTACK_SANDBOX === '1';

describe.runIf(enabled)('Paystack sandbox contract', () => {
  it('initializes and verifies a GHS transaction with the exact reference and amount', async () => {
    const key = process.env.PAYSTACK_SECRET_KEY;
    if (!key?.startsWith('sk_test_')) {
      throw new Error('Sandbox contract test requires PAYSTACK_SECRET_KEY=sk_test_..., never live');
    }
    const client = new PaystackHttpClient(key);
    const reference = `trotxi-sandbox-${Date.now()}-${randomUUID()}`;
    const initialized = await client.initializeTransaction({
      email: 'payments-sandbox@trotxi.app',
      amountPesewas: 100,
      reference,
    });

    expect(initialized.reference).toBe(reference);
    expect(initialized.authorizationUrl).toMatch(/^https:\/\//);

    const verified = await client.verifyTransaction(reference);
    expect(verified).toMatchObject({
      reference,
      amountPesewas: 100,
      currency: 'GHS',
      providerDomain: 'test',
    });
    expect(verified.providerTransactionId).toMatch(/^\d+$/);
  });
});
