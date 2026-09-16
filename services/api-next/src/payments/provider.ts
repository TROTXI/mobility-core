import {
  createHash,
  createHmac,
  timingSafeEqual,
  randomBytes,
  createCipheriv,
  createDecipheriv,
} from 'node:crypto';
import { z } from 'zod';
import type { Settlement } from './foundation.js';

export const refundRank = {
  pending: 0,
  processing: 1,
  needs_attention: 2,
  failed: 3,
  processed: 4,
} as const;
export const disputeRank = { created: 0, reminded: 1, resolved: 2 } as const;
type Common = {
  reference: string;
  environment: 'test' | 'live';
  currency: string;
  amountPesewas: number;
};
export type ProviderFact =
  | ({ kind: 'success' } & Settlement)
  | ({ kind: 'failure'; status: 'failed' | 'abandoned' | 'reversed' } & Common)
  | ({ kind: 'unresolved' } & Common)
  | ({ kind: 'refund'; providerReference: string; state: keyof typeof refundRank } & Common)
  | ({
      kind: 'dispute';
      providerId: string;
      state: keyof typeof disputeRank;
      resolution: string | null;
    } & Common);
const ident = z
  .union([z.string().regex(/^\d+$/), z.number().int().nonnegative().max(Number.MAX_SAFE_INTEGER)])
  .transform(String);
const amount = z
  .union([z.number(), z.string().regex(/^\d+$/).transform(Number)])
  .pipe(z.number().int().min(1).max(2147483647));
const common = z.object({
  reference: z.string().min(1).max(100),
  domain: z.enum(['test', 'live']),
  currency: z.literal('GHS'),
  amount,
});
const record = z.record(z.string(), z.unknown());
export class InvalidProviderFacts extends Error {}
export function parseProviderFact(raw: Buffer, source: 'webhook' | 'verify'): ProviderFact | null {
  try {
    const envelope = z
      .object({ event: z.string().max(100), data: record })
      .parse(JSON.parse(raw.toString('utf8')));
    const d = envelope.data;
    if (
      envelope.event === 'charge.success' ||
      (source === 'verify' && envelope.event === 'transaction.verify')
    ) {
      const c = common.parse(d),
        status = z.string().parse(d.status);
      const fields = {
        reference: c.reference,
        environment: c.domain,
        currency: c.currency,
        amountPesewas: c.amount,
      };
      if (status === 'success') {
        const paid = z.iso.datetime({ offset: true }).parse(d.paid_at),
          paidAt = new Date(paid);
        return {
          kind: 'success',
          ...fields,
          transactionId: ident.parse(d.id),
          paidAt,
          channel: z.string().max(100).nullable().optional().parse(d.channel) ?? null,
          feesPesewas:
            z.number().int().min(0).max(2147483647).nullable().optional().parse(d.fees) ?? null,
        };
      }
      if (source !== 'verify') throw new InvalidProviderFacts();
      if (['failed', 'abandoned', 'reversed'].includes(status))
        return {
          kind: 'failure',
          ...fields,
          status: status as 'failed' | 'abandoned' | 'reversed',
        };
      if (['pending', 'processing', 'ongoing', 'queued'].includes(status))
        return { kind: 'unresolved', ...fields };
      throw new InvalidProviderFacts();
    }
    if (envelope.event.startsWith('refund.')) {
      const state = envelope.event.slice(7).replaceAll('-', '_');
      if (!Object.hasOwn(refundRank, state) || String(d.status).replaceAll('-', '_') !== state)
        throw new InvalidProviderFacts();
      const c = common.parse({ ...d, reference: d.transaction_reference });
      // Missing refund identity cannot be safely deduplicated by amount/event hash.
      const providerReference = z.string().min(1).max(200).parse(d.refund_reference);
      return {
        kind: 'refund',
        reference: c.reference,
        environment: c.domain,
        currency: c.currency,
        amountPesewas: c.amount,
        state: state as keyof typeof refundRank,
        providerReference,
      };
    }
    if (envelope.event.startsWith('charge.dispute.')) {
      const states: Record<string, 'created' | 'reminded' | 'resolved'> = {
        'charge.dispute.create': 'created',
        'charge.dispute.remind': 'reminded',
        'charge.dispute.resolve': 'resolved',
      };
      const state = states[envelope.event];
      if (!state) throw new InvalidProviderFacts();
      const tx = record.parse(d.transaction ?? {});
      const c = common.parse({
        reference: tx.reference ?? d.transaction_reference,
        domain: d.domain ?? tx.domain,
        currency: d.currency ?? tx.currency,
        amount: d.refund_amount ?? d.amount ?? tx.amount,
      });
      const resolution =
        state === 'resolved'
          ? (z.string().min(1).max(100).nullable().optional().parse(d.resolution) ?? null)
          : null;
      return {
        kind: 'dispute',
        reference: c.reference,
        environment: c.domain,
        currency: c.currency,
        amountPesewas: c.amount,
        state,
        providerId: ident.parse(d.id),
        resolution,
      };
    }
    return null;
  } catch {
    throw new InvalidProviderFacts('Invalid or incomplete provider evidence');
  }
}

export class PaystackEvidence {
  readonly environment: 'test' | 'live';
  constructor(
    private readonly secret: string,
    private readonly encryptionKey: Buffer,
    private readonly request: typeof fetch = fetch,
  ) {
    if (!/^sk_(test|live)_[A-Za-z0-9]+$/.test(secret) || encryptionKey.length !== 32)
      throw new Error('Explicit Paystack secret and independent 32-byte evidence key required');
    this.environment = secret.startsWith('sk_test_') ? 'test' : 'live';
  }
  authenticate(raw: Buffer, signature: unknown) {
    if (
      raw.length > 1048576 ||
      typeof signature !== 'string' ||
      !/^[a-fA-F0-9]{128}$/.test(signature)
    )
      return false;
    return timingSafeEqual(
      createHmac('sha512', this.secret).update(raw).digest(),
      Buffer.from(signature, 'hex'),
    );
  }
  hash(raw: Buffer) {
    return createHash('sha256').update(raw).digest('hex');
  }
  seal(raw: Buffer, context: string) {
    const iv = randomBytes(12),
      c = createCipheriv('aes-256-gcm', this.encryptionKey, iv);
    c.setAAD(Buffer.from(context));
    const payload = Buffer.concat([c.update(raw), c.final()]);
    return Buffer.concat([iv, c.getAuthTag(), payload]);
  }
  open(encrypted: Buffer, context: string) {
    const c = createDecipheriv('aes-256-gcm', this.encryptionKey, encrypted.subarray(0, 12));
    c.setAAD(Buffer.from(context));
    c.setAuthTag(encrypted.subarray(12, 28));
    return Buffer.concat([c.update(encrypted.subarray(28)), c.final()]);
  }
  /**
   * Open a hosted checkout for an attempt that is already committed.
   *
   * Ported from the deployed client at `services/api`: same endpoint, same
   * currency, same refusal to accept a response naming a different reference.
   * Called outside every transaction, and a failure leaves the attempt
   * pending for unresolved-payment discovery rather than inventing a target.
   */
  async initialize(request: {
    reference: string;
    amountPesewas: number;
    email: string;
  }): Promise<{ authorizationUrl: string }> {
    if (
      !/^[A-Za-z0-9._=-]{1,100}$/.test(request.reference) ||
      !Number.isSafeInteger(request.amountPesewas) ||
      request.amountPesewas < 1 ||
      request.amountPesewas > 2147483647 ||
      !/^[^\s@]{1,200}@[^\s@]{1,100}$/.test(request.email)
    )
      throw new InvalidProviderFacts('Invalid checkout request');
    const response = await this.request('https://api.paystack.co/transaction/initialize', {
      method: 'POST',
      headers: { Authorization: `Bearer ${this.secret}`, 'content-type': 'application/json' },
      signal: AbortSignal.timeout(10000),
      redirect: 'error',
      body: JSON.stringify({
        email: request.email,
        amount: request.amountPesewas,
        reference: request.reference,
        currency: 'GHS',
      }),
    });
    if (!response.ok) throw new Error('provider_unavailable');
    const body = z
      .object({
        status: z.literal(true),
        data: z.object({
          authorization_url: z.string().max(2048),
          reference: z.string().max(100),
        }),
      })
      .parse(await response.json());
    if (body.data.reference !== request.reference)
      throw new InvalidProviderFacts('Provider opened a different reference');
    const target = new URL(body.data.authorization_url);
    if (target.protocol !== 'https:') throw new InvalidProviderFacts('Insecure checkout target');
    return { authorizationUrl: target.toString() };
  }

  async verify(reference: string): Promise<Buffer> {
    if (!reference || reference.length > 100) throw new InvalidProviderFacts();
    const response = await this.request(
      `https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`,
      {
        headers: { Authorization: `Bearer ${this.secret}` },
        signal: AbortSignal.timeout(10000),
        redirect: 'error',
      },
    );
    // A 404/network error is not permission to free a hold. Keep it unresolved.
    if (!response.ok || !response.body) throw new Error('provider_unavailable');
    const reader = response.body.getReader(),
      chunks: Uint8Array[] = [];
    let size = 0;
    try {
      for (;;) {
        const { value, done } = await reader.read();
        if (done) break;
        size += value.length;
        if (size > 1048576) {
          await reader.cancel();
          throw new InvalidProviderFacts();
        }
        chunks.push(value);
      }
    } finally {
      reader.releaseLock();
    }
    const result = z
      .object({ status: z.literal(true), data: record })
      .parse(JSON.parse(Buffer.concat(chunks).toString('utf8')));
    if (result.data.reference !== reference) throw new InvalidProviderFacts();
    const raw = Buffer.from(JSON.stringify({ event: 'transaction.verify', data: result.data }));
    const fact = parseProviderFact(raw, 'verify');
    if (!fact || fact.environment !== this.environment) throw new InvalidProviderFacts();
    return raw;
  }
}
