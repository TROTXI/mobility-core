import fastifySwagger from '@fastify/swagger';
import fastifySwaggerUi from '@fastify/swagger-ui';
import Fastify, { type FastifyInstance } from 'fastify';
import {
  jsonSchemaTransform,
  serializerCompiler,
  validatorCompiler,
  type ZodTypeProvider,
} from 'fastify-type-provider-zod';
import { z } from 'zod';
import { InMemoryKvStore, type KvStore } from './kv/kv.store';
import { ledgerRoutes } from './modules/ledger/ledger.routes';
import type { LedgerRepository } from './modules/ledger/ledger.repository';
import { metricsPlugin, type MetricsOptions } from './modules/metrics/metrics.plugin';
import { paymentRoutes } from './modules/payments/payments.routes';
import type { PaymentsService } from './modules/payments/payments.service';
import { authPlugin } from './modules/auth/auth.plugin';
import { authRoutes } from './modules/auth/auth.routes';
import type { AuthService } from './modules/auth/auth.service';
import { DEV_AUTH_CONFIG, type AuthConfig } from './modules/auth/jwt';
import {
  DEFAULT_RATE_LIMIT,
  rateLimitPlugin,
  type RateLimitConfig,
} from './modules/ratelimit/ratelimit.plugin';
import type { SubscriptionRepository } from './modules/subscriptions/subscription.repository';
import type { UserRepository } from './modules/users/user.repository';

/**
 * Dependencies are injected here — services and repositories register as the
 * domain grows (routes → services → repositories, see docs/architecture.md).
 * Tests pass in-memory implementations; production wires the real ones.
 */
export interface AppDeps {
  /** Readiness probe — wired to a DB ping when DATABASE_URL is set. */
  isReady?: () => Promise<boolean>;
  /** Selected by DATABASE_URL (in-memory vs Postgres). Consumed by routes/services. */
  users?: UserRepository;
  /** Selected by DATABASE_URL (in-memory vs Postgres). Consumed by routes/services. */
  subscriptions?: SubscriptionRepository;
  /** Token wallet ledger (in-memory vs Postgres). Derived balance + grants/debits. */
  ledger?: LedgerRepository;
  /** Selected by REDIS_URL (in-memory vs Redis). For rate limits, idempotency, cache. */
  kv?: KvStore;
  /** JWT/auth settings. Defaults to a dev-only config when unset (tests, local). */
  auth?: AuthConfig;
  /** Sign-in/refresh/logout orchestrator. Routes return 503 when absent. */
  authService?: AuthService;
  /** Paystack payments orchestrator. Routes return 503 when absent. */
  paymentsService?: PaymentsService;
  /** Rate-limit thresholds (from env). Defaults applied when unset. */
  rateLimit?: RateLimitConfig;
  /** Prometheus /metrics exposure. Defaults to unprotected (dev/tests). */
  metrics?: Partial<MetricsOptions>;
  logger?: boolean;
}

export async function buildApp(deps: AppDeps = {}): Promise<FastifyInstance> {
  const app = Fastify({ logger: deps.logger ?? false });

  // zod is the single source for validation AND the OpenAPI spec (ADR-0008):
  // route schemas are zod, compiled here and rendered into the docs by
  // jsonSchemaTransform below. `r` is the zod-typed view used to define routes.
  app.setValidatorCompiler(validatorCompiler);
  app.setSerializerCompiler(serializerCompiler);
  const r = app.withTypeProvider<ZodTypeProvider>();

  const isReady = deps.isReady ?? (async () => true);

  // OpenAPI docs. Registered before the routes so every route is captured and
  // listed in the interactive explorer at /docs.
  await app.register(fastifySwagger, {
    openapi: {
      info: {
        title: 'Trotxi API',
        description: 'Transactional API — auth, subscriptions, tokens, mobility.',
        version: '0.1.0',
      },
      tags: [
        { name: 'system', description: 'Health, readiness, and service metadata' },
        { name: 'auth', description: 'Authentication and the current user' },
        { name: 'wallet', description: 'Token wallet / GHS balance' },
        { name: 'payments', description: 'Subscriptions checkout (Paystack) + webhook' },
      ],
      components: {
        // Protected routes set `security: [{ bearerAuth: [] }]`; clients send
        // `Authorization: Bearer <access token>` (see ADR-0007).
        securitySchemes: {
          bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
        },
      },
    },
    transform: jsonSchemaTransform,
  });
  await app.register(fastifySwaggerUi, { routePrefix: '/docs' });

  // Metrics early so its onResponse hook observes every route (RED + runtime).
  await app.register(metricsPlugin, {
    token: deps.metrics?.token,
    allowUnprotected: deps.metrics?.allowUnprotected ?? true,
  });

  // Guards first (decorators on the root instance), then routes that use them.
  const kv = deps.kv ?? new InMemoryKvStore();
  await app.register(authPlugin, { config: deps.auth ?? DEV_AUTH_CONFIG });
  await app.register(rateLimitPlugin, { kv });
  await app.register(authRoutes, {
    users: deps.users,
    authService: deps.authService,
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(ledgerRoutes, {
    ledger: deps.ledger,
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(paymentRoutes, {
    paymentsService: deps.paymentsService,
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });

  r.get(
    '/',
    {
      schema: {
        tags: ['system'],
        summary: 'Service metadata and useful links',
        response: {
          200: z.object({
            service: z.string(),
            version: z.string(),
            docs: z.string(),
            health: z.string(),
          }),
        },
      },
    },
    async () => ({ service: 'trotxi-api', version: '0.1.0', docs: '/docs', health: '/healthz' }),
  );

  r.get(
    '/version',
    {
      schema: {
        tags: ['system'],
        summary: 'Build version and commit',
        response: {
          200: z.object({ name: z.string(), version: z.string(), commit: z.string() }),
        },
      },
    },
    async () => ({
      name: 'trotxi-api',
      version: '0.1.0',
      commit: process.env['GIT_SHA'] ?? 'dev',
    }),
  );

  r.get(
    '/healthz',
    {
      schema: {
        tags: ['system'],
        summary: 'Liveness probe',
        response: { 200: z.object({ status: z.literal('ok') }) },
      },
    },
    async () => ({ status: 'ok' as const }),
  );

  r.get(
    '/readyz',
    {
      schema: {
        tags: ['system'],
        summary: 'Readiness probe (pings backing services)',
        response: {
          200: z.object({ status: z.literal('ready') }),
          503: z.object({ status: z.literal('not_ready') }),
        },
      },
    },
    async (_request, reply) => {
      if (await isReady()) {
        return { status: 'ready' as const };
      }
      return reply.code(503).send({ status: 'not_ready' as const });
    },
  );

  return app;
}
