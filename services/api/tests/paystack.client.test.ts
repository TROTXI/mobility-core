import { afterEach, describe, expect, it, vi } from 'vitest';
import {
  FakePaystackClient,
  paystackSignature,
  verifySignature,
} from '../src/modules/payments/paystack.client';
import { PaystackHttpClient } from '../src/modules/payments/paystack.client.live';

afterEach(() => vi.unstubAllGlobals());

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

  it('exposes provider state for reconciliation', async () => {
    const client = new FakePaystackClient();
    await client.initializeTransaction({
      email: 'a@b.com',
      amountPesewas: 25_000,
      reference: 'ref-verify',
    });
    client.setTransaction('ref-verify', { status: 'success', paidAt: new Date(0) });
    await expect(client.verifyTransaction('ref-verify')).resolves.toMatchObject({
      reference: 'ref-verify',
      status: 'success',
      amountPesewas: 25_000,
      providerDomain: 'test',
    });
  });

  it('rejects non-positive/fractional amounts and unsupported references', async () => {
    const client = new FakePaystackClient();
    await expect(
      client.initializeTransaction({ email: 'a@b.com', amountPesewas: 0, reference: 'ref-1' }),
    ).rejects.toThrow(/positive integer/);
    await expect(
      client.initializeTransaction({
        email: 'a@b.com',
        amountPesewas: 100.5,
        reference: 'ref-1',
      }),
    ).rejects.toThrow(/positive integer/);
    await expect(
      client.initializeTransaction({ email: 'a@b.com', amountPesewas: 100, reference: 'ref_bad' }),
    ).rejects.toThrow(/unsupported characters/);
  });
});

describe('PaystackHttpClient', () => {
  it('rejects a response that echoes a different reference', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn(async () =>
        Response.json({
          status: true,
          data: { authorization_url: 'https://checkout.paystack.com/x', reference: 'other-ref' },
        }),
      ),
    );
    const client = new PaystackHttpClient('sk_test_example');

    await expect(
      client.initializeTransaction({
        email: 'a@b.com',
        amountPesewas: 100,
        reference: 'expected-ref',
      }),
    ).rejects.toThrow(/different reference/);
  });

  it('normalizes a verified transaction', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn(async () =>
        Response.json({
          status: true,
          data: {
            id: 987654,
            reference: 'expected-ref',
            status: 'success',
            amount: 25_000,
            currency: 'GHS',
            domain: 'test',
            channel: 'mobile_money',
            fees: 100,
            paid_at: '2026-01-01T00:00:00.000Z',
          },
        }),
      ),
    );
    const client = new PaystackHttpClient('sk_test_example');

    await expect(client.verifyTransaction('expected-ref')).resolves.toMatchObject({
      providerTransactionId: '987654',
      amountPesewas: 25_000,
      providerDomain: 'test',
      paidAt: new Date('2026-01-01T00:00:00.000Z'),
    });
  });
});
