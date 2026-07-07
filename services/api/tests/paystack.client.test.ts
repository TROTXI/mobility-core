import { describe, expect, it } from 'vitest';
import {
  FakePaystackClient,
  paystackSignature,
  verifySignature,
} from '../src/modules/payments/paystack.client';

describe('paystack signatures', () => {
  it('paystackSignature is a deterministic HMAC-SHA512 hex digest', () => {
    const a = paystackSignature('{"x":1}', 'secret');
    expect(a).toBe(paystackSignature('{"x":1}', 'secret'));
    expect(a).toMatch(/^[0-9a-f]{128}$/);
    expect(a).not.toBe(paystackSignature('{"x":1}', 'other-secret'));
  });

  it('verifySignature accepts a valid signature and rejects bad/missing/wrong-key', () => {
    const body = '{"event":"charge.success"}';
    const sig = paystackSignature(body, 's');
    expect(verifySignature(body, sig, 's')).toBe(true);
    expect(verifySignature(body, 'deadbeef', 's')).toBe(false);
    expect(verifySignature(body, undefined, 's')).toBe(false);
    expect(verifySignature(body, sig, 'wrong-key')).toBe(false);
  });
});

describe('FakePaystackClient', () => {
  it('initializeTransaction returns a stub URL carrying the reference', async () => {
    const client = new FakePaystackClient();
    const result = await client.initializeTransaction({
      email: 'a@b.com',
      amountPesewas: 25000,
      reference: 'ref-1',
    });
    expect(result.reference).toBe('ref-1');
    expect(result.authorizationUrl).toContain('ref-1');
  });

  it('verifyWebhookSignature validates against its configured secret', () => {
    const client = new FakePaystackClient('sek');
    const body = '{"a":1}';
    expect(client.verifyWebhookSignature(body, paystackSignature(body, 'sek'))).toBe(true);
    expect(client.verifyWebhookSignature(body, 'nope')).toBe(false);
  });
});
