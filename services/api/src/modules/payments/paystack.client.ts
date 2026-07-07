// Paystack integration behind an interface so PaymentsService never touches the
// network directly and tests use the fake. The real HTTP client is in
// paystack.client.live.ts. Webhook signatures are HMAC-SHA512 of the raw body
// keyed by the SECRET key (security.md §7 — mandatory, else anyone mints tokens).

import { createHmac, timingSafeEqual } from 'node:crypto';

/** Inputs to open a Paystack checkout transaction. */
export interface PaystackInitParams {
  /** Customer email — Paystack's customer key. */
  email: string;
  /** Amount in pesewas (GHS * 100) — Paystack's smallest unit. */
  amountPesewas: number;
  /** Our unique payment reference, echoed back on the webhook. */
  reference: string;
}

/** Result of opening a Paystack checkout. */
export interface PaystackInitResult {
  /** Hosted-checkout URL to redirect the user to. */
  authorizationUrl: string;
  /** The reference Paystack recorded (matches the one we sent). */
  reference: string;
}

/** The slice of Paystack we depend on; swap the impl (real/fake) per environment. */
export interface PaystackClient {
  /**
   * Open a checkout transaction.
   *
   * @param params - email, amount (pesewas), and our reference.
   * @returns the hosted `authorizationUrl` and the reference.
   */
  initializeTransaction(params: PaystackInitParams): Promise<PaystackInitResult>;
  /**
   * Verify a webhook's HMAC signature against the raw body.
   *
   * @param rawBody - the exact bytes Paystack POSTed (re-serialized JSON won't match).
   * @param signature - the `x-paystack-signature` header, if present.
   * @returns true only if the signature is valid.
   */
  verifyWebhookSignature(rawBody: string, signature: string | undefined): boolean;
}

/**
 * Compute Paystack's webhook signature: HMAC-SHA512 of the raw body, hex-encoded.
 *
 * @param rawBody - the exact request body bytes.
 * @param secret - the Paystack secret key.
 * @returns the hex signature.
 */
export function paystackSignature(rawBody: string, secret: string): string {
  return createHmac('sha512', secret).update(rawBody).digest('hex');
}

/**
 * Constant-time comparison of a webhook signature against the expected HMAC.
 * Never throws; returns false on a missing signature or length mismatch.
 *
 * @param rawBody - the exact request body bytes.
 * @param signature - the `x-paystack-signature` header, if present.
 * @param secret - the Paystack secret key.
 * @returns true only if the signature matches.
 */
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
  /** @param secret - the shared secret tests sign payloads with. */
  constructor(private readonly secret = 'fake-paystack-secret') {}

  /**
   * Return a deterministic stub checkout URL (no network call).
   *
   * @param params - checkout inputs; only `reference` is used here.
   * @returns a fake `authorizationUrl` derived from the reference.
   */
  async initializeTransaction(params: PaystackInitParams): Promise<PaystackInitResult> {
    return {
      authorizationUrl: `https://checkout.paystack.test/${params.reference}`,
      reference: params.reference,
    };
  }

  /**
   * Verify a signature with real HMAC against the fake secret.
   *
   * @param rawBody - the exact request body bytes.
   * @param signature - the `x-paystack-signature` header, if present.
   * @returns true only if the signature is valid.
   */
  verifyWebhookSignature(rawBody: string, signature: string | undefined): boolean {
    return verifySignature(rawBody, signature, this.secret);
  }
}
