import Fastify from 'fastify';
import cors from '@fastify/cors';
import rateLimit from '@fastify/rate-limit';
import multipart from '@fastify/multipart';
import type { FastifyRequest } from 'fastify';
import { randomUUID } from 'node:crypto';
import contract from './contract.json' with { type: 'json' };
import { TransportService } from '../transport/service.js';
import type { Actor, Dependencies } from '../transport/service.js';
import { TransportError } from '../transport/errors.js';
import type { AuthService } from '../auth/service.js';
import type { DriverService } from '../auth/driver-service.js';
import type { PaymentRecovery } from '../payments/recovery.js';
import type { RefundInitiation } from '../payments/refunds.js';
import type { ConfigService } from '../config/service.js';
import type { Pricing } from '../payments/pricing.js';
import type { AccountService } from '../account/service.js';
import type { Purchases } from '../payments/purchases.js';
import type { MembershipService } from '../membership/service.js';
import type { StandbyService } from '../membership/standby.js';
import type { BoardingService } from '../boarding/service.js';
import { loggerOptions } from '../observability/logging.js';
import { recordJob } from '../observability/metrics.js';
import type { MaintenanceAudit } from '../runtime/maintenance-audit.js';
import type { RiderInbox } from '../notifications/inbox.js';
import { createAdmission } from './admission.js';
import { dispatch } from './dispatch.js';
import { installDocs } from './docs.js';
import { installErrorHandlers } from './errors.js';
import { describeRoute, type Operation } from './route.js';

declare module 'fastify' {
  interface FastifyInstance {
    /**
     * The one transport service this application dispatches through. The
     * maintenance worker runs the same reviewed handlers the HTTP routes do,
     * rather than a second instance with its own idea of the rules.
     */
    transport: TransportService;
  }
}
export interface AppOptions extends Dependencies {
  maintenanceAudit?: MaintenanceAudit;
  refunds?: RefundInitiation;
  /** Request logs to stdout, which OpenTelemetry ships to Loki. Off in tests. */
  logRequests?: boolean;
  /** Optional destination for request-log tests. Production uses stdout. */
  requestLogStream?: NodeJS.WritableStream;
  // Unlike the independently testable service, the application must not start
  // with booking-aware mutations exposed but their required adapter absent.
  coordinateReservations: NonNullable<Dependencies['coordinateReservations']>;
  // Signature/issuer/audience/expiry verification belongs to identity. No test
  // header fallback and no listener until a real verifier/session adapter lands.
  verifyAccess: (authorization: string) => Promise<Actor | null>;
  /**
   * Which social sign-in routes this application offers. A provider that is
   * not listed has no route, so a client discovers it is unavailable when it
   * reads the surface rather than when a rider taps the button. Absent means
   * both, which is what the per-domain tests supply.
   */
  authProviders?: readonly ('google' | 'apple')[];
  /**
   * A per-rider budget shared across instances. Absent leaves the bounded
   * process-local counter below, which is correct for one process and for the
   * per-domain tests, and is not a limit once the service scales.
   */
  admit?: (subject: string) => Promise<{ count: number; resetsInSeconds: number }>;
  admitIp?: (ip: string, bucket: string) => Promise<{ count: number; resetsInSeconds: number }>;
  minimumBuilds: {
    ops: number;
    driver: { ios: number; android: number };
    commuter: { ios: number; android: number };
  };
  /**
   * Which peers may state the client's address, as an address list Fastify
   * understands. Absent means nobody, so an unconfigured deployment
   * under-trusts rather than letting a caller forge its own address. Every
   * per-IP budget buckets on what this resolves to, so behind a proxy that is
   * not named here the whole internet shares one bucket.
   */
  trustProxy?: string | false;
  /**
   * The one browser origin allowed to call this API: the Ops website. The
   * mobile apps are not browsers and need no CORS. Absent means no browser
   * origin is allowed, which is what the per-domain tests supply.
   */
  corsOrigin?: string;
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
  standby?: StandbyService;
  inbox?: RiderInbox;
  pricing?: Pricing;
  account?: AccountService;
  config?: ConfigService;
  maxAvatarBytes?: number;
  purchases?: Purchases;
  boarding?: BoardingService;
  authRequestsPerMinute?: number;
}
export async function createTransportApp(options: AppOptions) {
  if (typeof options.coordinateReservations !== 'function')
    throw new Error('Transactional reservation coordinator required before application startup');
  /**
   * The caller behind a public route, if they offered a session.
   *
   * Bootstrap never demands one: it answers on the sign-in screen and the
   * cannot-sign-in screen. But it decides flag rollouts per person when it can,
   * so a valid token identifies the caller and anything else, missing,
   * malformed or expired, is simply anonymous. It never fails the request.
   */
  const optionalCaller = async (request: { headers: { authorization?: string } }) => {
    const authorization = request.headers.authorization;
    if (typeof authorization !== 'string' || !/^Bearer [^\s]{1,8192}$/.test(authorization))
      return null;
    try {
      return (await options.verifyAccess(authorization))?.userId ?? null;
    } catch {
      return null;
    }
  };
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
    maxParamLength: 256,
    logger: options.logRequests ? loggerOptions(options.requestLogStream) : false,
    bodyLimit: 65536,
    trustProxy: options.trustProxy ?? false,
    genReqId: () => randomUUID(),
    ajv: { customOptions: { removeAdditional: false, coerceTypes: false, useDefaults: true } },
  });
  app.decorate('transport', service);
  const actors = new WeakMap<FastifyRequest, Actor>();
  const maintenanceRuns = new WeakMap<FastifyRequest, string>();
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
  // Before the limiter and every route hook: a preflight carries no token or
  // client metadata, so it must be answered here or the browser never sends
  // the real request. Bearer tokens, not cookies, so no credentials mode.
  if (options.corsOrigin)
    await app.register(cors, {
      origin: [options.corsOrigin],
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
      allowedHeaders: [
        'Authorization',
        'Content-Type',
        'If-Match',
        'Idempotency-Key',
        'X-Trotxi-Client',
        'X-Trotxi-Build',
        'X-Trotxi-Platform',
      ],
      exposedHeaders: ['ETag', 'Retry-After'],
      maxAge: 600,
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
  const admission = createAdmission(options, { budget, ipBudget, authBudget }, actors);
  const { spendIp } = admission;
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
  installErrorHandlers(app);
  const documentedOperations = installDocs(app);
  const context = { options, service, optionalCaller };

  for (const [path, methods] of Object.entries(contract.paths)) {
    for (const [method, value] of Object.entries(methods)) {
      const operation = value as unknown as Operation;
      const route = describeRoute(path, method, operation);
      const {
        name,
        paymentEndpoint,
        refundEndpoint,
        membershipEndpoint,
        standbyEndpoint,
        inboxEndpoint,
        boardingEndpoint,
        pricingEndpoint,
        purchaseEndpoint,
        accountEndpoint,
        configEndpoint,
        publicConfig,
        authentication,
        driverEndpoint,
        scheduled,
        authLimited,
        input,
      } = route;
      if (refundEndpoint && !options.refunds) continue;
      if ((configEndpoint || publicConfig) && !options.config) continue;
      if (accountEndpoint && !options.account) continue;
      if (boardingEndpoint && !options.boarding) continue;
      if (pricingEndpoint && !options.pricing) continue;
      if (purchaseEndpoint && !options.purchases) continue;
      if (membershipEndpoint && !options.membership) continue;
      if (standbyEndpoint && !options.standby) continue;
      if (inboxEndpoint && !options.inbox) continue;
      if (paymentEndpoint && !options.payments) continue;
      if (name === 'receivePaystackWebhook') {
        documentedOperations.add(name);
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
              // After the early local limiter, before buffering/parsing the
              // signed body. Use the same anonymous "all" bucket as catalogues.
              preParsing: async (request, reply, payload) => {
                await spendIp(request, reply);
                return payload;
              },
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
      if (authentication && !options.auth) continue;
      if (driverEndpoint && !options.drivers) continue;
      const providers = options.authProviders ?? (['google', 'apple'] as const);
      if ((name === 'signInGoogle' || name === 'signInOpsGoogle') && !providers.includes('google'))
        continue;
      if (name === 'signInApple' && !providers.includes('apple')) continue;
      documentedOperations.add(name);
      const response: Record<string, unknown> = {};
      for (const [status, out] of Object.entries(operation.responses)) {
        const schema = out.content?.['application/json']?.schema;
        if (schema && Number(status) < 300) response[status] = rootRef(schema);
      }
      app.route({
        method: method.toUpperCase() as 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE',
        url: path.replaceAll(/\{([^}]+)\}/g, ':$1'),
        // Render probes liveness every few seconds. Keep readiness and normal
        // requests visible, but do not ship successful liveness noise to Loki.
        ...(name === 'getHealth' ? { logLevel: 'silent' as const } : {}),
        ...(name === 'createPatternVersion' ? { bodyLimit: 1048576 } : {}),
        ...(authLimited ? { config: { rateLimit: { max: authBudget, timeWindow: 60000 } } } : {}),
        schema: { ...(input ? { body: rootRef(input) } : {}), response },
        // Every scheduled job reports its outcome here, whichever service ran
        // it. One place, so a job added later is counted without anyone
        // remembering to count it.
        ...(scheduled
          ? {
              onSend: async (
                request: FastifyRequest,
                reply: { statusCode: number },
                payload: unknown,
              ) => {
                const runId = maintenanceRuns.get(request);
                if (runId) {
                  maintenanceRuns.delete(request);
                  await options.maintenanceAudit!.finish(runId, reply.statusCode, payload);
                }
                recordJob(name, reply.statusCode, payload);
                return payload;
              },
            }
          : {}),
        // The plugin's onRequest IP limiter must run before verification.
        // A route-local onRequest auth hook would precede its appended hook.
        preValidation: (request, reply) => admission.admit(route, request, reply),
        handler: async (request, reply) => {
          const actor = actors.get(request)!;
          if (scheduled && options.maintenanceAudit) {
            const runId = await options.maintenanceAudit.startApi(
              actor,
              request.headers['x-trotxi-client'],
              name,
            );
            if (runId) maintenanceRuns.set(request, runId);
          }
          const result = await dispatch(context, route, request, reply, actor);
          for (const [key, value] of Object.entries(result.headers)) reply.header(key, value);
          return reply.code(result.status).send(result.body);
        },
      });
    }
  }
  return app;
}
