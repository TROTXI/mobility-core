// Refunds, payment review and maintenance, pricing and purchases.
import type { FastifyReply, FastifyRequest } from 'fastify';
import type { Actor, Body } from '../../transport/service.js';
import { fail } from '../../transport/errors.js';
import type { HandlerContext, HandlerResult } from '../dispatch.js';
import type { RouteInfo } from '../route.js';
import type { PricingOperation } from '../../payments/pricing.js';
import type { PurchaseOperation } from '../../payments/purchases.js';

/** Refund initiation and its history. */
export async function refunds(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  if (Object.keys(request.query as object).length)
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  const target = (request.params as { id: string }).id;
  if (name === 'listRefundInitiations') return await options.refunds!.read(actor, target);
  else {
    const key = request.headers['idempotency-key'];
    if (typeof key !== 'string')
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key.');
    return await options.refunds!.initiate(actor, target, (request.body ?? {}) as Body, key);
  }
}

/** Payment reviews and payment maintenance runs. */
export async function payments(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  const query = request.query as Record<string, string | undefined>;
  const allowed = new Set(operation.parameters.filter((p) => p.in === 'query').map((p) => p.name));
  if (
    Object.entries(query).some(
      ([k, v]) => !allowed.has(k) || typeof v !== 'string' || v.length > 128,
    )
  )
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  let data;
  if (name === 'listPaymentReviews') {
    const page = await options.payments!.reviews(
      actor,
      query.limit === undefined ? 50 : Number(query.limit),
      query.cursor,
    );
    return {
      status: 200,
      headers: {},
      body: { data: page.items, page: { nextCursor: page.nextCursor } },
    };
  } else if (name === 'resolvePaymentReview') {
    const key = request.headers['idempotency-key'],
      match = request.headers['if-match'];
    if (typeof key !== 'string' || (match !== undefined && typeof match !== 'string'))
      fail(400, 'invalid_request', 'Invalid command headers.');
    data = await options.payments!.decide(
      actor,
      (request.params as { id: string }).id,
      request.body as { decision: 'resolved' | 'waived'; reason: string },
      key,
      match,
    );
    reply.header('ETag', data.editToken);
  } else {
    const kind = (
      {
        runPaymentInbox: 'inbox',
        runPaymentReconciliation: 'reconciliation',
        runPeriodClose: 'periods',
        runPayments: 'all',
      } as const
    )[name as 'runPayments'];
    data = await options.payments!.maintenance(
      actor,
      kind,
      (request.body as { limit?: number })?.limit ?? 100,
    );
  }
  return { status: 200, headers: {}, body: { data } };
}

/** Prices, previews and purchases. */
export async function pricingAndPurchases(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input, pricingEndpoint }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  const query = request.query as Record<string, string | undefined>;
  const allowed = new Set(operation.parameters.filter((p) => p.in === 'query').map((p) => p.name));
  if (
    Object.entries(query).some(
      ([k, v]) => !allowed.has(k) || typeof v !== 'string' || v.length > 128,
    )
  )
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  const params = request.params as { id?: string; plan?: string };
  if (name === 'previewPurchase')
    return await options.pricing!.preview(actor!, (request.body ?? {}) as Body);
  else if (method === 'get')
    return pricingEndpoint
      ? await options.pricing!.read(actor!, name as PricingOperation, params, query)
      : await options.purchases!.read(actor!, name as PurchaseOperation, params, query);
  else {
    const key = request.headers['idempotency-key'],
      match = request.headers['if-match'];
    if (typeof key !== 'string' || key.length < 1 || key.length > 128)
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key of 1 to 128 characters.');
    if (match !== undefined && (typeof match !== 'string' || match.length > 128))
      fail(400, 'invalid_precondition', 'Invalid If-Match header.');
    return pricingEndpoint
      ? await options.pricing!.command(
          actor!,
          name as PricingOperation,
          params.id ?? params.plan ?? '',
          (request.body ?? {}) as Body,
          key,
          match as string | undefined,
        )
      : await options.purchases!.create(actor!, (request.body ?? {}) as Body, key);
  }
}
