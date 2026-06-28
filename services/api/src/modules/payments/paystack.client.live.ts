// Real Paystack HTTP client. Network-bound, so excluded from unit coverage (like
// the *.pg / *.redis / *.google adapters) — exercised against Paystack's sandbox.

import type { PaystackClient, PaystackInitParams, PaystackInitResult } from './paystack.client';
import { verifySignature } from './paystack.client';

const PAYSTACK_API = 'https://api.paystack.co';

interface InitializeResponse {
  status: boolean;
  data?: { authorization_url: string; reference: string };
}

export class PaystackHttpClient implements PaystackClient {
  constructor(private readonly secretKey: string) {}

  async initializeTransaction(params: PaystackInitParams): Promise<PaystackInitResult> {
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
    });
    if (!res.ok) {
      throw new Error(`Paystack initialize failed: ${res.status}`);
    }
    const json = (await res.json()) as InitializeResponse;
    if (!json.status || !json.data) {
      throw new Error('Paystack initialize returned no data');
    }
    return { authorizationUrl: json.data.authorization_url, reference: json.data.reference };
  }

  verifyWebhookSignature(rawBody: string, signature: string | undefined): boolean {
    return verifySignature(rawBody, signature, this.secretKey);
  }
}
