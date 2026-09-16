import Fastify from 'fastify';
import rateLimit from '@fastify/rate-limit';
import multipart from '@fastify/multipart';
import type { FastifyRequest } from 'fastify';
import { randomUUID } from 'node:crypto';
import contract from './contract.json' with { type: 'json' };
import { TransportService } from '../transport/service.js';
import type { Actor, Body, Command, Read, Dependencies } from '../transport/service.js';
import { TransportError, fail, mapDatabaseError } from '../transport/errors.js';
import { catalogReads, publicCatalogReads } from '../transport/catalog.js';
import type { CatalogRead } from '../transport/catalog.js';
import { authOperations, publicAuthOperations, DriverLockedError } from '../auth/service.js';
import type { AuthService, AuthOperation } from '../auth/service.js';
import { driverOperations } from '../auth/driver-service.js';
import type { DriverService, DriverOperation } from '../auth/driver-service.js';
import type { PaymentRecovery } from '../payments/recovery.js';
import { membershipOperations } from '../membership/service.js';
import { tripReads } from '../transport/trips.js';
import { pricingOperations } from '../payments/pricing.js';
import type { Pricing, PricingOperation } from '../payments/pricing.js';
import { accountOperations } from '../account/service.js';
import type { AccountService, AccountOperation } from '../account/service.js';
import { purchaseOperations } from '../payments/purchases.js';
import type { Purchases, PurchaseOperation } from '../payments/purchases.js';
import type { TripRead } from '../transport/trips.js';
import type { MembershipService, MembershipOperation } from '../membership/service.js';
import { boardingOperations } from '../boarding/service.js';
import type { BoardingService } from '../boarding/service.js';
const paymentOperations = [
  'receivePaystackWebhook',
  'listPaymentReviews',
  'resolvePaymentReview',
  'runPayments',
  'runPaymentInbox',
  'runPaymentReconciliation',
  'runPeriodClose',
];

interface Operation {
  operationId: string;
  parameters: { in: string; name: string; schema: Record<string, unknown> }[];
  requestBody?: { content: Record<string, { schema: Record<string, unknown> }> };
  responses: Record<string, { content?: Record<string, { schema: Record<string, unknown> }> }>;
}
export interface AppOptions extends Dependencies {
  // Unlike the independently testable service, the application must not start
  // with booking-aware mutations exposed but their required adapter absent.
  coordinateReservations: NonNullable<Dependencies['coordinateReservations']>;
  // Signature/issuer/audience/expiry verification belongs to identity. No test
  // header fallback and no listener until a real verifier/session adapter lands.
  verifyAccess: (authorization: string) => Promise<Actor | null>;
  minimumBuilds: {
    ops: number;
    driver: { ios: number; android: number };
    commuter: { ios: number; android: number };
  };
  requestsPerMinute?: number;
  requestsPerIpPerMinute?: number;
  // Optional only for isolated transport tests. createReplacementApp wires the
  // real service and both access/session adapters as one indivisible dependency.
  auth?: AuthService;
  drivers?: DriverService;
  // Only expose the group when evidence keys and transactional reversal /
  // fulfilment coordinators have been explicitly supplied. No silent no-ops.
  payments?: PaymentRecovery;
  membership?: MembershipService;
  pricing?: Pricing;
  account?: AccountService;
  maxAvatarBytes?: number;
  purchases?: Purchases;
  boarding?: BoardingService;
  authRequestsPerMinute?: number;
}
export async function createTransportApp(options: AppOptions) {
  if (typeof options.coordinateReservations !== 'function')
    throw new Error('Transactional reservation coordinator required before application startup');
  if (typeof options.verifyAccess !== 'function')
    throw new Error('Verified access-token adapter required');
  const floors = options.minimumBuilds;
  if (
    !floors ||
    ![
      floors.ops,
      floors.driver?.ios,
      floors.driver?.android,
      floors.commuter?.ios,
      floors.commuter?.android,
    ].every((n) => Number.isInteger(n) && n > 0)
  )
    throw new Error('Explicit ops/iOS/Android build floors required');
  const service = new TransportService(options);
  const app = Fastify({
    logger: false,
    bodyLimit: 65536,
    trustProxy: false,
    genReqId: () => randomUUID(),
    ajv: { customOptions: { removeAdditional: false, coerceTypes: false, useDefaults: true } },
  });
  const actors = new WeakMap<FastifyRequest, Actor>();
  const budget = options.requestsPerMinute ?? 120;
  if (!Number.isInteger(budget) || budget < 1) throw new Error('Invalid request budget');
  const ipBudget = options.requestsPerIpPerMinute ?? 600;
  if (!Number.isInteger(ipBudget) || ipBudget < 1) throw new Error('Invalid IP request budget');
  const authBudget = options.authRequestsPerMinute ?? 10;
  if (!Number.isInteger(authBudget) || authBudget < 1) throw new Error('Invalid auth budget');
  // Runs before token verification, in addition to the verified-user budget.
  // No trust in forwarded headers; deployment must explicitly configure its
  // ingress/proxy policy before exposing the service behind a shared proxy.
  if (options.account)
    await app.register(multipart, {
      attachFieldsToBody: true,
      limits: { files: 1, fields: 0, fileSize: options.maxAvatarBytes ?? 2 * 1024 * 1024 },
    });
  await app.register(rateLimit, {
    global: true,
    hook: 'onRequest',
    max: ipBudget,
    timeWindow: 60000,
    cache: 10000,
    skipOnError: false,
    errorResponseBuilder: () =>
      new TransportError(429, 'rate_limited', 'Please wait before trying again.'),
  });
  const counters = new Map<string, { count: number; until: number }>();
  // OpenAPI components are not a JSON-Schema keyword. Adapt only reference
  // locations, retaining strict validation and every reviewed field rule.
  const reference = (ref: string) =>
    ref.replace('#/components/schemas/', 'transport#/definitions/');
  function jsonSchema(value: unknown): unknown {
    if (Array.isArray(value)) return value.map(jsonSchema);
    if (!value || typeof value !== 'object') return value;
    return Object.fromEntries(
      Object.entries(value).map(([key, child]) => [
        key,
        key === '$ref' ? reference(String(child)) : jsonSchema(child),
      ]),
    );
  }
  app.addSchema({ $id: 'transport', definitions: jsonSchema(contract.components.schemas) });
  const rootRef = (schema: Record<string, unknown>) => ({ $ref: reference(String(schema.$ref)) });
  app.setErrorHandler((error, request, reply) => {
    // Busboy aborts a body it cannot parse with a stream error that carries no
    // status. That is the client's envelope, not our failure.
    const stream = (error as { code?: string }).code;
    if (stream === 'ERR_STREAM_PREMATURE_CLOSE' || stream?.startsWith('FST_REQ_FILE'))
      return reply.code(400).send({
        error: {
          code: 'invalid_request',
          message: 'Supply exactly one image part.',
          requestId: request.id,
        },
      });
    if (error instanceof DriverLockedError)
      reply.header('Retry-After', String(error.retryAfterSeconds));
    const typed = error as { validation?: unknown; statusCode?: number };
    let safe: TransportError;
    if (error instanceof TransportError) safe = error;
    else if (typed.validation || [400, 413, 415].includes(typed.statusCode ?? 0))
      safe = new TransportError(
        typed.statusCode ?? 400,
        'invalid_request',
        'The request is invalid.',
      );
    else safe = mapDatabaseError(error);
    reply
      .header('Cache-Control', 'no-store')
      .code(safe.status)
      .send({ error: { code: safe.code, message: safe.message, requestId: request.id } });
  });
  app.setNotFoundHandler((request, reply) =>
    reply.code(404).send({
      error: { code: 'not_found', message: 'Resource not found.', requestId: request.id },
    }),
  );
  for (const [path, methods] of Object.entries(contract.paths)) {
    for (const [method, value] of Object.entries(methods)) {
      const operation = value as unknown as Operation;
      const name = operation.operationId;
      const paymentEndpoint = paymentOperations.includes(name);
      const membershipEndpoint = (membershipOperations as readonly string[]).includes(name);
      const boardingEndpoint = (boardingOperations as readonly string[]).includes(name);
      const pricingEndpoint = (pricingOperations as readonly string[]).includes(name);
      const purchaseEndpoint = (purchaseOperations as readonly string[]).includes(name);
      const accountEndpoint = (accountOperations as readonly string[]).includes(name);
      if (accountEndpoint && !options.account) continue;
      if (boardingEndpoint && !options.boarding) continue;
      if (pricingEndpoint && !options.pricing) continue;
      if (purchaseEndpoint && !options.purchases) continue;
      if (membershipEndpoint && !options.membership) continue;
      if (paymentEndpoint && !options.payments) continue;
      if (name === 'receivePaystackWebhook') {
        // Encapsulated parser preserves the exact bytes for HMAC. It must not
        // replace normal JSON validation on any rider or ops route.
        await app.register(async (hook) => {
          hook.removeContentTypeParser('application/json');
          hook.addContentTypeParser('application/json', { parseAs: 'buffer' }, (_req, body, done) =>
            done(null, body),
          );
          hook.post(
            path,
            {
              bodyLimit: 1048576,
              schema: { response: { 200: { $ref: 'transport#/definitions/WebhookAck' } } },
            },
            async (request, reply) => {
              reply.header('Cache-Control', 'no-store');
              return options.payments!.acceptWebhook(
                request.body as Buffer,
                request.headers['x-paystack-signature'],
              );
            },
          );
        });
        continue;
      }
      const authentication = (authOperations as readonly string[]).includes(name);
      const driverEndpoint = (driverOperations as readonly string[]).includes(name);
      if (authentication && !options.auth) continue;
      if (driverEndpoint && !options.drivers) continue;
      const publicAuth = (publicAuthOperations as readonly string[]).includes(name);
      const publicRead = (publicCatalogReads as readonly string[]).includes(name);
      // Trip reads need a session but not a particular app: a rider watching a
      // bus, a driver checking the board and ops all read the same catalogue.
      const anyClient = publicRead || (tripReads as readonly string[]).includes(name);
      const anonymous = publicRead || publicAuth;
      const ops = path.startsWith('/v1/ops/');
      const response: Record<string, unknown> = {};
      for (const [status, out] of Object.entries(operation.responses)) {
        const schema = out.content?.['application/json']?.schema;
        if (schema && Number(status) < 300) response[status] = rootRef(schema);
      }
      const input = operation.requestBody?.content['application/json']?.schema;
      app.route({
        method: method.toUpperCase() as 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE',
        url: path.replaceAll(/\{([^}]+)\}/g, ':$1'),
        ...(name === 'createPatternVersion' ? { bodyLimit: 1048576 } : {}),
        ...(publicAuth || name === 'changeDriverPin'
          ? { config: { rateLimit: { max: authBudget, timeWindow: 60000 } } }
          : {}),
        schema: { ...(input ? { body: rootRef(input) } : {}), response },
        // The plugin's onRequest IP limiter must run before verification.
        // A route-local onRequest auth hook would precede its appended hook.
        preValidation: async (request, reply) => {
          reply.header('Cache-Control', 'no-store');
          const authorization = request.headers.authorization;
          if (!anonymous && (!authorization || !/^Bearer [^\s]{1,8192}$/.test(authorization)))
            fail(401, 'unauthenticated', 'Sign in to continue.');
          const actor = anonymous ? null : await options.verifyAccess(authorization!);
          if (!anonymous && !actor) fail(401, 'unauthenticated', 'Sign in to continue.');
          const client = request.headers['x-trotxi-client'],
            build = request.headers['x-trotxi-build'],
            platform = request.headers['x-trotxi-platform'];
          if (
            (anyClient || authentication
              ? !['ops', 'driver', 'commuter'].includes(String(client))
              : client !==
                (ops
                  ? 'ops'
                  : membershipEndpoint ||
                      purchaseEndpoint ||
                      accountEndpoint ||
                      name === 'issuePass'
                    ? 'commuter'
                    : 'driver')) ||
            (name === 'signInDriver' && client !== 'driver') ||
            typeof build !== 'string' ||
            !/^[1-9]\d{0,8}$/.test(build) ||
            (client === 'ops'
              ? platform !== undefined
              : !['ios', 'android'].includes(String(platform)))
          )
            fail(
              400,
              'client_metadata_required',
              'Supply the appropriate client, build and platform metadata.',
            );
          const floor =
            client === 'ops'
              ? floors.ops
              : floors[client as 'driver' | 'commuter'][platform as 'ios' | 'android'];
          if (Number(build) < floor)
            fail(426, 'client_upgrade_required', 'Update the application before continuing.');
          if (!actor) return; // Public catalog remains IP-limited; no identity fallback.
          // Bounded process-local protection only. Distributed admission remains
          // a deployment concern; untrusted metadata never supplies authority.
          const now = Date.now();
          if (counters.size >= 10000)
            for (const [key, row] of counters) if (row.until <= now) counters.delete(key);
          let row = counters.get(actor.userId);
          if (!row || row.until <= now) {
            if (!row && counters.size >= 10000)
              fail(503, 'admission_unavailable', 'Please try again later.');
            row = { count: 0, until: now + 60000 };
            counters.set(actor.userId, row);
          }
          if (++row.count > budget) {
            reply.header('Retry-After', String(Math.max(1, Math.ceil((row.until - now) / 1000))));
            fail(429, 'rate_limited', 'Please wait before trying again.');
          }
          actors.set(request, actor);
        },
        handler: async (request, reply) => {
          const actor = actors.get(request)!;
          let result;
          if (boardingEndpoint) {
            if (Object.keys(request.query as object).length)
              fail(400, 'invalid_query', 'Unsupported query parameters.');
            if (!input && request.body !== undefined)
              fail(400, 'invalid_request', 'This operation has no request body.');
            const params = request.params as { id: string; reservationId?: string };
            if (name === 'issuePass') result = await options.boarding!.issue(actor, params.id);
            else if (name === 'getManifest' || name === 'getTripSummary')
              result = await options.boarding!.read(actor, name, params.id);
            else if (name === 'runNoShows')
              result = await options.boarding!.maintenance(
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
              if (typeof key !== 'string')
                fail(400, 'invalid_request', 'Supply an Idempotency-Key.');
              result = await options.boarding!.command(
                actor,
                name as 'boardRider' | 'markNoShow',
                params.id,
                (request.body ?? {}) as Body,
                key,
                params.reservationId,
              );
            }
          } else if (paymentEndpoint) {
            const query = request.query as Record<string, string | undefined>;
            const allowed = new Set(
              operation.parameters.filter((p) => p.in === 'query').map((p) => p.name),
            );
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
              return reply.send({ data: page.items, page: { nextCursor: page.nextCursor } });
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
            return reply.send({ data });
          } else if (accountEndpoint) {
            if (name === 'uploadAvatar') {
              const body = request.body as { file?: { toBuffer?: () => Promise<Buffer> } };
              const part = body?.file;
              if (!part || typeof part.toBuffer !== 'function')
                fail(400, 'invalid_request', 'Supply an image to upload.');
              result = await options.account!.handle(
                actor!,
                name as AccountOperation,
                await part.toBuffer(),
                (part as { mimetype?: string }).mimetype,
                request.headers['idempotency-key'] as string | undefined,
              );
            } else
              result = await options.account!.handle(
                actor!,
                name as AccountOperation,
                (request.body ?? {}) as Body,
                undefined,
                request.headers['idempotency-key'] as string | undefined,
              );
          } else if (pricingEndpoint || purchaseEndpoint) {
            const query = request.query as Record<string, string | undefined>;
            const allowed = new Set(
              operation.parameters.filter((p) => p.in === 'query').map((p) => p.name),
            );
            if (
              Object.entries(query).some(
                ([k, v]) => !allowed.has(k) || typeof v !== 'string' || v.length > 128,
              )
            )
              fail(400, 'invalid_query', 'Unsupported query parameters.');
            const params = request.params as { id?: string; plan?: string };
            if (method === 'get')
              result = pricingEndpoint
                ? await options.pricing!.read(actor!, name as PricingOperation, params, query)
                : await options.purchases!.read(actor!, name as PurchaseOperation, params, query);
            else {
              const key = request.headers['idempotency-key'],
                match = request.headers['if-match'];
              if (typeof key !== 'string' || key.length < 1 || key.length > 128)
                fail(
                  400,
                  'idempotency_key_required',
                  'Supply an Idempotency-Key of 1 to 128 characters.',
                );
              if (match !== undefined && (typeof match !== 'string' || match.length > 128))
                fail(400, 'invalid_precondition', 'Invalid If-Match header.');
              result = pricingEndpoint
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
          } else if (membershipEndpoint) {
            const query = request.query as Record<string, string | undefined>;
            const allowed = new Set(
              operation.parameters.filter((p) => p.in === 'query').map((p) => p.name),
            );
            if (
              Object.entries(query).some(
                ([k, v]) => !allowed.has(k) || typeof v !== 'string' || v.length > 128,
              )
            )
              fail(400, 'invalid_query', 'Unsupported query parameters.');
            const params = request.params as { id?: string; restrictionId?: string };
            if (name === 'runAskDispatch' || name === 'runReservationDefaults')
              result = await options.membership!.maintenance(
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
              result = await options.membership!.read(
                actor,
                name as MembershipOperation,
                query,
                params.id,
              );
            else {
              const key = request.headers['idempotency-key'],
                match = request.headers['if-match'];
              if (typeof key !== 'string' || (match !== undefined && typeof match !== 'string'))
                fail(400, 'invalid_request', 'Invalid command headers.');
              if (!input && request.body !== undefined)
                fail(400, 'invalid_request', 'This operation has no request body.');
              result = await options.membership!.command(
                actor,
                name as MembershipOperation,
                params.restrictionId ?? params.id,
                (request.body ?? {}) as Body,
                key,
                match,
                params.restrictionId ? params.id : undefined,
              );
            }
          } else if (driverEndpoint) {
            const query = request.query as Record<string, string | undefined>;
            const allowed = new Set(
              operation.parameters.filter((p) => p.in === 'query').map((p) => p.name),
            );
            if (
              Object.entries(query).some(
                ([k, v]) => !allowed.has(k) || typeof v !== 'string' || v.length > 128,
              )
            )
              fail(400, 'invalid_query', 'Unsupported query parameters.');
            if (method === 'get') result = await options.drivers!.list(actor, query);
            else {
              const key = request.headers['idempotency-key'],
                ifMatch = request.headers['if-match'];
              if (typeof key !== 'string' || !key || key.length > 128)
                fail(
                  400,
                  'idempotency_key_required',
                  'Supply an Idempotency-Key of 1 to 128 characters.',
                );
              if (ifMatch !== undefined && (typeof ifMatch !== 'string' || ifMatch.length > 128))
                fail(400, 'invalid_precondition', 'Invalid If-Match header.');
              result = await options.drivers!.command(
                actor,
                name as Exclude<DriverOperation, 'listOpsDrivers'>,
                (request.params as { id?: string }).id,
                (request.body ?? {}) as Body,
                key,
                ifMatch,
              );
            }
          } else if (authentication) {
            if (!input && request.body !== undefined)
              fail(400, 'invalid_request', 'This operation has no request body.');
            const query = request.query as Record<string, string | undefined>;
            const allowed = new Set(
              operation.parameters.filter((p) => p.in === 'query').map((p) => p.name),
            );
            if (
              Object.entries(query).some(
                ([key, value]) =>
                  !allowed.has(key) || typeof value !== 'string' || value.length > 128,
              )
            )
              fail(400, 'invalid_query', 'Unsupported query parameters.');
            const key = request.headers['idempotency-key'];
            if (key !== undefined && typeof key !== 'string')
              fail(400, 'invalid_request', 'Invalid command key.');
            result = await options.auth!.handle(
              name as AuthOperation,
              actor,
              request.body,
              query,
              (request.params as { id?: string }).id,
              key,
            );
          } else if (method === 'get') {
            const query = request.query as Record<string, string | undefined>;
            const allowed = new Set(
              operation.parameters.filter((p) => p.in === 'query').map((p) => p.name),
            );
            if (
              Object.entries(query).some(
                ([key, value]) =>
                  !allowed.has(key) || typeof value !== 'string' || value.length > 128,
              )
            )
              fail(400, 'invalid_query', 'Unsupported query parameters.');
            result = (tripReads as readonly string[]).includes(name)
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
                : await service.list(actor, name as Read, query);
          } else {
            if (!input && request.body !== undefined)
              fail(400, 'invalid_request', 'This command has no request body.');
            const key = request.headers['idempotency-key'],
              ifMatch = request.headers['if-match'];
            if (typeof key !== 'string' || key.length < 1 || key.length > 128)
              fail(
                400,
                'idempotency_key_required',
                'Supply an Idempotency-Key of 1 to 128 characters.',
              );
            if (ifMatch !== undefined && (typeof ifMatch !== 'string' || ifMatch.length > 128))
              fail(400, 'invalid_precondition', 'Invalid If-Match header.');
            const target = (request.params as { id?: string }).id ?? 'collection';
            result = await service.command(
              actor,
              name as Command,
              target,
              (request.body ?? {}) as Body,
              key,
              ifMatch as string | undefined,
              (request.params as { versionId?: string }).versionId,
            );
          }
          for (const [key, value] of Object.entries(result.headers)) reply.header(key, value);
          return reply.code(result.status).send(result.body);
        },
      });
    }
  }
  return app;
}
