// Boarding, trip generation, configuration and drivers.
import type { FastifyReply, FastifyRequest } from 'fastify';
import type { Actor, Body } from '../../transport/service.js';
import { fail } from '../../transport/errors.js';
import type { HandlerContext, HandlerResult } from '../dispatch.js';
import type { RouteInfo } from '../route.js';
import type { ConfigOperation } from '../../config/service.js';
import type { DriverOperation } from '../../auth/driver-service.js';

/** The scheduled trip generation run. */
export async function tripGeneration(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  if (Object.keys(request.query as object).length)
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  return await service.generateTrips(
    actor,
    request.body as { serviceDate: string; routeId?: string; limit?: number },
  );
}

/** Passes, manifests, boarding and no-shows. */
export async function boarding(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  if (Object.keys(request.query as object).length)
    fail(400, 'invalid_query', 'Unsupported query parameters.');
  if (!input && request.body !== undefined)
    fail(400, 'invalid_request', 'This operation has no request body.');
  const params = request.params as { id: string; reservationId?: string };
  if (name === 'issuePass') return await options.boarding!.issue(actor, params.id);
  else if (name === 'getManifest' || name === 'getOpsManifest' || name === 'getTripSummary')
    return await options.boarding!.read(actor, name, params.id);
  else if (name === 'runNoShows')
    return await options.boarding!.maintenance(
      actor,
      request.body as {
        travelDate: string;
        direction: string;
        routeId?: string;
        limit?: number;
      },
    );
  else {
    const key = request.headers['idempotency-key'];
    if (typeof key !== 'string') fail(400, 'invalid_request', 'Supply an Idempotency-Key.');
    return await options.boarding!.command(
      actor,
      name as 'boardRider' | 'markNoShow',
      params.id,
      (request.body ?? {}) as Body,
      key,
      params.reservationId,
    );
  }
}

/** Root, build, health, readiness and bootstrap. */
export async function publicConfig(
  { options, service, optionalCaller }: HandlerContext,
  { name, method, operation, input }: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  return name === 'getRoot'
    ? options.config!.root()
    : name === 'getBuild'
      ? options.config!.build()
      : name === 'getHealth'
        ? options.config!.health()
        : name === 'getReadiness'
          ? await options.config!.readiness()
          : await options.config!.bootstrap(await optionalCaller(request));
}

/** Flags, minimum builds and other Ops configuration. */
export async function config(
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
  if (method === 'get') return await options.config!.read(actor!, name as ConfigOperation, query);
  else {
    const key = request.headers['idempotency-key'],
      match = request.headers['if-match'];
    if (typeof key !== 'string' || key.length < 1 || key.length > 128)
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key of 1 to 128 characters.');
    if (match !== undefined && (typeof match !== 'string' || match.length > 128))
      fail(400, 'invalid_precondition', 'Invalid If-Match header.');
    return await options.config!.command(
      actor!,
      name as ConfigOperation,
      request.params as { key?: string; app?: string; platform?: string; id?: string },
      (request.body ?? {}) as Body,
      key,
      match as string | undefined,
    );
  }
}

/** Driver records, credentials and the driver self view. */
export async function drivers(
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
  if (name === 'getDriverSelf') return await options.drivers!.self(actor);
  else if (method === 'get') return await options.drivers!.list(actor, query);
  else {
    const key = request.headers['idempotency-key'],
      ifMatch = request.headers['if-match'];
    if (typeof key !== 'string' || !key || key.length > 128)
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key of 1 to 128 characters.');
    if (ifMatch !== undefined && (typeof ifMatch !== 'string' || ifMatch.length > 128))
      fail(400, 'invalid_precondition', 'Invalid If-Match header.');
    return await options.drivers!.command(
      actor,
      name as Exclude<DriverOperation, 'listOpsDrivers'>,
      (request.params as { id?: string }).id,
      (request.body ?? {}) as Body,
      key,
      ifMatch,
    );
  }
}
