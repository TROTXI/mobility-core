// Real Paystack HTTP client. Network-bound, so excluded from unit coverage (like
// the *.pg / *.redis / *.google adapters) — exercised against Paystack's sandbox.

import type {
  PaystackClient,
  PaystackInitParams,
  PaystackInitResult,
  PaystackTransaction,
} from './paystack.client';
import { assertValidPaystackInit, verifySignature } from './paystack.client';
import { PaystackTransactionNotFoundError } from './paystack.client';

const PAYSTACK_API = 'https://api.paystack.co';

interface InitializeResponse {
  status: boolean;
  data?: { authorization_url: string; reference: string };
}

interface VerifyResponse {
  status: boolean;
  data?: {
    id: number | string;
    reference: string;
    status: string;
    amount: number;
    currency: string;
    domain: string;
    channel?: string | null;
    fees?: number | null;
    paid_at?: string | null;
  };
}

export class PaystackHttpClient implements PaystackClient {
  constructor(private readonly secretKey: string) {}

  async initializeTransaction(params: PaystackInitParams): Promise<PaystackInitResult> {
    assertValidPaystackInit(params);
    const res = await fetch(`${PAYSTACK_API}/transaction/initialize`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.secretKey}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        email: params.email,
        amount: params.amountPesewas,
        reference: params.reference,
        currency: 'GHS',
      }),
      signal: AbortSignal.timeout(10_000),
    });
    if (!res.ok) {
      throw new Error(`Paystack initialize failed: ${res.status}`);
    }
    const json = (await res.json()) as InitializeResponse;
    if (!json.status || !json.data) {
      throw new Error('Paystack initialize returned no data');
    }
    if (json.data.reference !== params.reference) {
      throw new Error('Paystack initialize returned a different reference');
    }
    return { authorizationUrl: json.data.authorization_url, reference: json.data.reference };
  }

  async verifyTransaction(reference: string): Promise<PaystackTransaction> {
    const res = await fetch(`${PAYSTACK_API}/transaction/verify/${encodeURIComponent(reference)}`, {
      headers: { Authorization: `Bearer ${this.secretKey}` },
      signal: AbortSignal.timeout(10_000),
    });
    if (res.status === 404) {
      throw new PaystackTransactionNotFoundError(`Paystack has no transaction ${reference}`);
    }
    if (!res.ok) throw new Error(`Paystack verify failed: ${res.status}`);
    const json = (await res.json()) as VerifyResponse;
    const data = json.data;
    const providerTransactionId = String(data?.id ?? '');
    const paidAt = data?.paid_at ? new Date(data.paid_at) : null;
    if (
      !json.status ||
      !data ||
      data.reference !== reference ||
      typeof data.status !== 'string' ||
      !Number.isSafeInteger(data.amount) ||
      typeof data.currency !== 'string' ||
      !/^\d+$/.test(providerTransactionId) ||
      (data.domain !== 'test' && data.domain !== 'live') ||
      (paidAt !== null && Number.isNaN(paidAt.getTime())) ||
      (data.fees !== undefined && data.fees !== null && !Number.isSafeInteger(data.fees))
    ) {
      throw new Error('Paystack verify returned invalid transaction data');
    }
    return {
      reference: data.reference,
      status: data.status,
      amountPesewas: data.amount,
      currency: data.currency,
      providerTransactionId,
      providerDomain: data.domain,
      channel: data.channel ?? null,
      feesPesewas: data.fees ?? null,
      paidAt,
    };
  }

  verifyWebhookSignature(rawBody: string, signature: string | undefined): boolean {
    return verifySignature(rawBody, signature, this.secretKey);
  }
}
