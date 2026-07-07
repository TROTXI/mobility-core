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
import { FakeObjectStore, type ObjectStore } from './storage/object-store';
import { userRoutes } from './modules/users/users.routes';
import {
  InMemoryDeviceTokenRepository,
  type DeviceTokenRepository,
} from './modules/devices/device-token.repository';
import { deviceRoutes } from './modules/devices/devices.routes';
import { BoardingService } from './modules/boarding/boarding.service';
import { ManifestService } from './modules/boarding/manifest.service';
import { boardingRoutes } from './modules/boarding/boarding.routes';
import { InMemoryScanEventRepository } from './modules/boarding/scan-event.repository';
import { metricsPlugin, type MetricsOptions } from './modules/metrics/metrics.plugin';
import { entitlementRoutes } from './modules/entitlements/entitlements.routes';
import {
  InMemoryEntitlementLedgerRepository,
  type EntitlementLedgerRepository,
} from './modules/entitlements/entitlement-ledger.repository';
import {
  InMemoryCreditLedgerRepository,
  type CreditLedgerRepository,
} from './modules/entitlements/credit-ledger.repository';
import { reservationRoutes } from './modules/reservations/reservations.routes';
import {
  InMemoryReservationRepository,
  type ReservationRepository,
} from './modules/reservations/reservation.repository';
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
import type { RouteStopRepository } from './modules/mobility/route-stop.repository';
import { mobilityRoutes } from './modules/mobility/mobility.routes';
import { tripRoutes } from './modules/mobility/trips.routes';
import { adminRoutes } from './modules/admin/admin.routes';
import type { RouteRepository } from './modules/mobility/route.repository';
import type { StopRepository } from './modules/mobility/stop.repository';
import type { TripRepository } from './modules/mobility/trip.repository';
import type { VehicleRepository } from './modules/mobility/vehicle.repository';
import type { DriverRepository } from './modules/mobility/driver.repository';
import type { SubscriptionRepository } from './modules/subscriptions/subscription.repository';
import { InMemoryUserRepository, type UserRepository } from './modules/users/user.repository';

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
  /** Selected by DATABASE_URL (in-memory vs Postgres). Mobility domain. */
  routes?: RouteRepository;
  stops?: StopRepository;
  routeStops?: RouteStopRepository;
  /** Trips (scheduled route runs). Reads require auth; routes return 503 when absent. */
  trips?: TripRepository;
  /** Fleet vehicles + drivers. Managed via the admin/ops endpoints (#26). */
  vehicles?: VehicleRepository;
  drivers?: DriverRepository;
  /** Device push-token registry (in-memory vs Postgres). Defaults to in-memory. */
  deviceTokens?: DeviceTokenRepository;
  /** Boarding pass issuance + scan verification. Defaults to an in-memory scan store. */
  boardingService?: BoardingService;
  /** Ride entitlement ledger (in-memory vs Postgres). Defaults to in-memory. */
  entitlements?: EntitlementLedgerRepository;
  /** Ride Credit ledger (in-memory vs Postgres). Defaults to in-memory. */
  credits?: CreditLedgerRepository;
  /** Daily reservation store (in-memory vs Postgres). Defaults to in-memory. */
  reservations?: ReservationRepository;
  /** Selected by REDIS_URL (in-memory vs Redis). For rate limits, idempotency, cache. */
  kv?: KvStore;
  /** Avatar/media storage (R2 in prod, in-memory Fake in dev/tests). */
  objectStore?: ObjectStore;
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

/**
 * Build the Fastify app — registers OpenAPI docs, metrics, guards, and all
 * routes. Dependencies are injected so tests pass in-memory implementations and
 * production wires the real ones.
 *
 * @param deps - repositories, services, and config; sensible defaults applied.
 * @returns the configured Fastify instance (not yet listening).
 */
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
        { name: 'payments', description: 'Subscriptions checkout (Paystack) + webhook' },
        { name: 'rides', description: 'Ride entitlement + Ride Credit balance' },
        { name: 'reservations', description: 'Daily ride confirmation (confirm/decline)' },
        { name: 'mobility', description: 'Routes and stops' },
        {
          name: 'admin',
          description: 'Admin/ops: manage fleet (routes/stops/vehicles/drivers/trips) + assignment',
        },
        { name: 'boarding', description: 'QR boarding passes + scan verification' },
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
  const objectStore = deps.objectStore ?? new FakeObjectStore();
  // Shared so a boarding scan boards the same reservation the rider confirmed
  // and debits the same entitlement ledger GET /me/rides reads (E4); the manifest
  // reads the same users auth writes.
  const users = deps.users ?? new InMemoryUserRepository();
  const entitlements = deps.entitlements ?? new InMemoryEntitlementLedgerRepository();
  const credits = deps.credits ?? new InMemoryCreditLedgerRepository();
  const reservations = deps.reservations ?? new InMemoryReservationRepository();
  const authConfig = deps.auth ?? DEV_AUTH_CONFIG;
  await app.register(authPlugin, { config: authConfig });
  await app.register(rateLimitPlugin, { kv });
  await app.register(authRoutes, {
    users,
    objectStore,
    authService: deps.authService,
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(userRoutes, {
    users,
    objectStore,
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(deviceRoutes, {
    deviceTokens: deps.deviceTokens ?? new InMemoryDeviceTokenRepository(),
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(paymentRoutes, {
    paymentsService: deps.paymentsService,
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(entitlementRoutes, {
    entitlements,
    credits,
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(reservationRoutes, {
    reservations,
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(boardingRoutes, {
    boardingService:
      deps.boardingService ??
      new BoardingService({
        scanEvents: new InMemoryScanEventRepository(),
        kv,
        reservations,
        entitlements,
        secret: authConfig.secret,
        passTtlSeconds: 60,
      }),
    manifestService: new ManifestService({ reservations, users, objectStore }),
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(mobilityRoutes, {
    routes: deps.routes,
    stops: deps.stops,
    routeStops: deps.routeStops,
  });
  await app.register(tripRoutes, {
    trips: deps.trips,
    rateLimit: deps.rateLimit ?? DEFAULT_RATE_LIMIT,
  });
  await app.register(adminRoutes, {
    routes: deps.routes,
    stops: deps.stops,
    routeStops: deps.routeStops,
    vehicles: deps.vehicles,
    drivers: deps.drivers,
    trips: deps.trips,
    users: deps.users,
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
