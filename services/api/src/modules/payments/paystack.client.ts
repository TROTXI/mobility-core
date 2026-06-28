// Paystack integration behind an interface so PaymentsService never touches the
// network directly and tests use the fake. The real HTTP client is in
// paystack.client.live.ts. Webhook signatures are HMAC-SHA512 of the raw body
// keyed by the SECRET key (security.md §7 — mandatory, else anyone mints tokens).

import { createHmac, timingSafeEqual } from 'node:crypto';

export interface PaystackInitParams {
  email: string;
  /** Amount in pesewas (GHS * 100) — Paystack's smallest unit. */
  amountPesewas: number;
  reference: string;
}

export interface PaystackInitResult {
  authorizationUrl: string;
  reference: string;
}

export interface PaystackClient {
  initializeTransaction(params: PaystackInitParams): Promise<PaystackInitResult>;
  verifyWebhookSignature(rawBody: string, signature: string | undefined): boolean;
}

/** HMAC-SHA512(rawBody, secret) as hex — how Paystack signs webhooks. */
export function paystackSignature(rawBody: string, secret: string): string {
  return createHmac('sha512', secret).update(rawBody).digest('hex');
}

/** Constant-time hex compare; false on length mismatch (never throws). */
export function verifySignature(
  rawBody: string,
  signature: string | undefined,
  secret: string,
): boolean {
  if (!signature) return false;
  const expected = paystackSignature(rawBody, secret);
  if (expected.length !== signature.length) return false;
  return timingSafeEqual(Buffer.from(expected), Buffer.from(signature));
}

/**
 * Dev/test client: no network. `initializeTransaction` returns a stub URL;
 * `verifyWebhookSignature` does real HMAC against a known secret so tests can
 * sign a payload. Never wired in production (see server.ts).
 */
export class FakePaystackClient implements PaystackClient {
  constructor(private readonly secret = 'fake-paystack-secret') {}

  async initializeTransaction(params: PaystackInitParams): Promise<PaystackInitResult> {
    return {
      authorizationUrl: `https://checkout.paystack.test/${params.reference}`,
      reference: params.reference,
    };
  }

  verifyWebhookSignature(rawBody: string, signature: string | undefined): boolean {
    return verifySignature(rawBody, signature, this.secret);
  }
}
