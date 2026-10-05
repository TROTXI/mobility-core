// Rider account, inbox, standby and membership.
import type { FastifyReply, FastifyRequest } from 'fastify';
import type { Actor, Body } from '../../transport/service.js';
import { fail } from '../../transport/errors.js';
import type { HandlerContext, HandlerResult } from '../dispatch.js';
import type { RouteInfo } from '../route.js';
import type { AccountOperation } from '../../account/service.js';
import type { MembershipOperation } from '../../membership/service.js';

/** Account details, avatar and erasure. */
export async function account(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  if (name === 'uploadAvatar') {
    const body = request.body as { file?: { toBuffer?: () => Promise<Buffer> } };
    const part = body?.file;
    if (!part || typeof part.toBuffer !== 'function')
      fail(400, 'invalid_request', 'Supply an image to upload.');
    return await options.account!.handle(
      actor!,
      name as AccountOperation,
      await part.toBuffer(),
      (part as { mimetype?: string }).mimetype,
      request.headers['idempotency-key'] as string | undefined,
    );
  } else
    return await options.account!.handle(
      actor!,
      name as AccountOperation,
      (request.body ?? {}) as Body,
      undefined,
      request.headers['idempotency-key'] as string | undefined,
    );
}

/** Rider notifications and their preferences. */
export async function inbox(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  if (!input && request.body !== undefined)
    fail(400, 'invalid_request', 'This operation has no request body.');
  const query = request.query as Record<string, string | undefined>;
  const allowed = new Set(operation.parameters.filter((p) => p.in === 'query').map((p) => p.name));
  if (
    Object.entries(query).some(
      ([k, v]) => !allowed.has(k) || typeof v !== 'string' || v.length > 128,
    )
  )
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  if (name === 'listNotifications') return await options.inbox!.list(actor, query);
  else if (name === 'markNotificationRead')
    return await options.inbox!.markRead(actor, (request.params as { id: string }).id);
  else if (name === 'markAllNotificationsRead') return await options.inbox!.markAllRead(actor);
  else if (name === 'getNotificationPreferences') return await options.inbox!.getPreferences(actor);
  else
    return await options.inbox!.updatePreferences(
      actor,
      request.body as { dailyAskTime: string; optionalUpdatesEnabled: boolean },
      request.headers['if-match'] as string | undefined,
    );
}

/** Standby applications and Ops offers. */
export async function standby(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  const query = request.query as Record<string, string | undefined>;
  const listing = name === 'listMyStandby' || name === 'listOpsStandby';
  if (
    Object.entries(query).some(
      ([k, v]) =>
        !listing || !['cursor', 'limit'].includes(k) || typeof v !== 'string' || v.length > 128,
    )
  )
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  const target = (request.params as { id?: string }).id;
  if (listing) return await options.standby!.list(actor, name === 'listOpsStandby', query);
  else if (name === 'joinStandby') return await options.standby!.join(actor, request.body as Body);
  else if (name === 'withdrawStandby') return await options.standby!.withdraw(actor, target!);
  else if (name === 'offerStandby') {
    const key = request.headers['idempotency-key'];
    if (typeof key !== 'string' || !key || key.length > 128)
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key.');
    return await options.standby!.offer(actor, target!, request.body as Body, key);
  } else {
    const key = request.headers['idempotency-key'];
    if (typeof key !== 'string' || !key || key.length > 128)
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key.');
    return await options.standby!.accept(actor, target!, key);
  }
}

/** Coverage, commute requests, reservations, pauses and restrictions. */
export async function membership(
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
  const params = request.params as { id?: string; restrictionId?: string };
  if (name === 'previewPersonalPause')
    return await options.membership!.previewPersonalPause(actor, (request.body ?? {}) as Body);
  else if (name === 'runPersonalPauseResumes')
    return await options.membership!.resumeDuePersonalPauses(
      actor,
      (request.body as { limit?: number })?.limit,
    );
  else if (name === 'runAskDispatch' || name === 'runReservationDefaults')
    return await options.membership!.maintenance(
      actor,
      name,
      request.body as {
        travelDate: string;
        direction: string;
        limit?: number;
        routeId?: string;
      },
    );
  else if (method === 'get')
    return await options.membership!.read(actor, name as MembershipOperation, query, params.id);
  else {
    const key = request.headers['idempotency-key'],
      match = request.headers['if-match'];
    if (typeof key !== 'string' || (match !== undefined && typeof match !== 'string'))
      fail(400, 'invalid_request', 'Invalid command headers.');
    if (!input && request.body !== undefined)
      fail(400, 'invalid_request', 'This operation has no request body.');
    return await options.membership!.command(
      actor,
      name as MembershipOperation,
      params.restrictionId ?? params.id,
      (request.body ?? {}) as Body,
      key,
      match,
      params.restrictionId ? params.id : undefined,
    );
  }
}
