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

/** Provider transaction facts returned by Paystack Verify. */
export interface PaystackTransaction {
  reference: string;
  status: string;
  amountPesewas: number;
  currency: string;
  providerTransactionId: string;
  providerDomain: 'test' | 'live';
  channel: string | null;
  feesPesewas: number | null;
  paidAt: Date | null;
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
  /** Independently read the provider's current transaction state. */
  verifyTransaction(reference: string): Promise<PaystackTransaction>;
  /**
   * Verify a webhook's HMAC signature against the raw body.
   *
   * @param rawBody - the exact bytes Paystack POSTed (re-serialized JSON won't match).
   * @param signature - the `x-paystack-signature` header, if present.
   * @returns true only if the signature is valid.
   */
  verifyWebhookSignature(rawBody: string, signature: string | undefined): boolean;
}

/** Verify could not find the reference in Paystack's environment. */
export class PaystackTransactionNotFoundError extends Error {}

/** Paystack accepts only alphanumerics plus `-`, `.`, and `=` in references. */
export const PAYSTACK_REFERENCE_PATTERN = /^[A-Za-z0-9.=-]+$/;

/**
 * Validate the contract at the adapter boundary so fakes and live HTTP fail in
 * the same way.
 *
 * @param params - checkout inputs to validate before any provider call.
 */
export function assertValidPaystackInit(params: PaystackInitParams): void {
  if (!Number.isSafeInteger(params.amountPesewas) || params.amountPesewas <= 0) {
    throw new TypeError('Paystack amount must be a positive integer number of pesewas');
  }
  if (!PAYSTACK_REFERENCE_PATTERN.test(params.reference)) {
    throw new TypeError('Paystack reference contains unsupported characters');
  }
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
  private readonly transactions = new Map<string, PaystackTransaction>();
  /** @param secret - the shared secret tests sign payloads with. */
  constructor(private readonly secret = 'fake-paystack-secret') {}

  /**
   * Return a deterministic stub checkout URL (no network call).
   *
   * @param params - checkout inputs; only `reference` is used here.
   * @returns a fake `authorizationUrl` derived from the reference.
   */
  async initializeTransaction(params: PaystackInitParams): Promise<PaystackInitResult> {
    assertValidPaystackInit(params);
    this.transactions.set(params.reference, {
      reference: params.reference,
      status: 'ongoing',
      amountPesewas: params.amountPesewas,
      currency: 'GHS',
      providerTransactionId: String(this.transactions.size + 1),
      providerDomain: 'test',
      channel: null,
      feesPesewas: null,
      paidAt: null,
    });
    return {
      authorizationUrl: `https://checkout.paystack.test/${params.reference}`,
      reference: params.reference,
    };
  }

  async verifyTransaction(reference: string): Promise<PaystackTransaction> {
    const transaction = this.transactions.get(reference);
    if (!transaction) {
      throw new PaystackTransactionNotFoundError(
        `Fake Paystack transaction ${reference} not found`,
      );
    }
    return { ...transaction };
  }

  /**
   * Simulate an initialization that never reached Paystack.
   *
   * @param reference - initialized fake reference to remove.
   */
  removeTransaction(reference: string): void {
    this.transactions.delete(reference);
  }

  /**
   * Set a fake provider outcome for reconciliation tests.
   *
   * @param reference - initialized fake transaction.
   * @param patch - provider fields to replace.
   */
  setTransaction(reference: string, patch: Partial<PaystackTransaction>): void {
    const existing = this.transactions.get(reference);
    if (!existing) throw new Error(`Fake Paystack transaction ${reference} not found`);
    this.transactions.set(reference, { ...existing, ...patch, reference });
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
