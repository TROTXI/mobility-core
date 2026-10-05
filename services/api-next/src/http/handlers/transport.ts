// Sign-in, and the catalogue, trip and transport commands everything else falls through to.
import type { FastifyReply, FastifyRequest } from 'fastify';
import type { Actor, Body } from '../../transport/service.js';
import { fail } from '../../transport/errors.js';
import type { HandlerContext, HandlerResult } from '../dispatch.js';
import type { RouteInfo } from '../route.js';
import type { AuthOperation } from '../../auth/service.js';
import type { Command, Read } from '../../transport/service.js';
import { catalogReads, type CatalogRead } from '../../transport/catalog.js';
import { tripReads, type TripRead } from '../../transport/trips.js';

/** Sign-in, sessions, passkeys and phone verification. */
export async function authentication(
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
      ([key, value]) => !allowed.has(key) || typeof value !== 'string' || value.length > 128,
    )
  )
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  const key = request.headers['idempotency-key'];
  if (key !== undefined && typeof key !== 'string')
    fail(400, 'invalid_request', 'Invalid command key.');
  return await options.auth!.handle(
    name as AuthOperation,
    actor,
    request.body,
    query,
    (request.params as { id?: string }).id,
    key,
    request.ip,
  );
}

/** Catalogue, trip and list reads. */
export async function reads(
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
      ([key, value]) => !allowed.has(key) || typeof value !== 'string' || value.length > 128,
    )
  )
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  return (tripReads as readonly string[]).includes(name)
    ? await service.readTrips(
        actor ?? null,
        name as TripRead,
        request.params as { id?: string },
        query,
      )
    : (catalogReads as readonly string[]).includes(name)
      ? await service.readCatalog(
          actor ?? null,
          name as CatalogRead,
          request.params as { id?: string; versionId?: string },
          query,
        )
      : await service.list(actor, name as Read, query, request.params as { id?: string });
}

/** Transport commands: routes, stops, schedules, trips, fleet and positions. */
export async function commands(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  if (!input && request.body !== undefined)
    fail(400, 'invalid_request', 'This command has no request body.');
  const key = request.headers['idempotency-key'],
    ifMatch = request.headers['if-match'];
  if (name !== 'recordPosition' && (typeof key !== 'string' || key.length < 1 || key.length > 128))
    fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key of 1 to 128 characters.');
  if (ifMatch !== undefined && (typeof ifMatch !== 'string' || ifMatch.length > 128))
    fail(400, 'invalid_precondition', 'Invalid If-Match header.');
  const target = (request.params as { id?: string }).id ?? 'collection';
  return await service.command(
    actor,
    name as Command,
    target,
    (request.body ?? {}) as Body,
    typeof key === 'string' ? key : '',
    ifMatch as string | undefined,
    (request.params as { versionId?: string }).versionId,
  );
}
