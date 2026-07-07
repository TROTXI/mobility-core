// Tracing first — must load before the libs it instruments (prod also runs it
// via `node --import ./dist/tracing.live.js`; this import is the dev fallback).
import { stopTracing } from './observability/tracing.live';
import type { Pool } from 'pg';
import { buildApp } from './app';
import { loadDotenv } from './config/dotenv';
import { loadEnv } from './config/env';
import { createPool } from './db/pool';
import { InMemoryKvStore, type KvStore } from './kv/kv.store';
import { RedisKvStore } from './kv/kv.store.redis';
import { FakeObjectStore, type ObjectStore } from './storage/object-store';
import { R2ObjectStore } from './storage/object-store.r2';
import {
  InMemoryAuthIdentityRepository,
  type AuthIdentityRepository,
} from './modules/auth/auth-identity.repository';
import { PgAuthIdentityRepository } from './modules/auth/auth-identity.repository.pg';
import { AuthService } from './modules/auth/auth.service';
import { FakeIdTokenVerifier, type IdTokenVerifier } from './modules/auth/id-token-verifier';
import { GoogleIdTokenVerifier } from './modules/auth/id-token-verifier.google';
import { createJwtService, DEV_AUTH_CONFIG, type AuthConfig } from './modules/auth/jwt';
import {
  InMemorySessionRepository,
  type SessionRepository,
} from './modules/auth/session.repository';
import { PgSessionRepository } from './modules/auth/session.repository.pg';
import type { RateLimitConfig } from './modules/ratelimit/ratelimit.plugin';
import {
  InMemoryRouteStopRepository,
  type RouteStopRepository,
} from './modules/mobility/route-stop.repository';
import { PgRouteStopRepository } from './modules/mobility/route-stop.repository.pg';
import { InMemoryRouteRepository, type RouteRepository } from './modules/mobility/route.repository';
import { PgRouteRepository } from './modules/mobility/route.repository.pg';
import { InMemoryStopRepository, type StopRepository } from './modules/mobility/stop.repository';
import { PgStopRepository } from './modules/mobility/stop.repository.pg';
import { InMemoryTripRepository, type TripRepository } from './modules/mobility/trip.repository';
import { PgTripRepository } from './modules/mobility/trip.repository.pg';
import {
  InMemorySubscriptionRepository,
  type SubscriptionRepository,
} from './modules/subscriptions/subscription.repository';
import { PgSubscriptionRepository } from './modules/subscriptions/subscription.repository.pg';
import {
  InMemoryDeviceTokenRepository,
  type DeviceTokenRepository,
} from './modules/devices/device-token.repository';
import { PgDeviceTokenRepository } from './modules/devices/device-token.repository.pg';
import { BoardingService } from './modules/boarding/boarding.service';
import {
  InMemoryScanEventRepository,
  type ScanEventRepository,
} from './modules/boarding/scan-event.repository';
import { PgScanEventRepository } from './modules/boarding/scan-event.repository.pg';
import {
  InMemoryPaymentRepository,
  type PaymentRepository,
} from './modules/payments/payment.repository';
import { PgPaymentRepository } from './modules/payments/payment.repository.pg';
import { FakePaystackClient, type PaystackClient } from './modules/payments/paystack.client';
import { PaystackHttpClient } from './modules/payments/paystack.client.live';
import {
  PaymentsService,
  PLACEHOLDER_RIDES_PER_PERIOD,
  SUBSCRIPTION_FEES_PESEWAS,
} from './modules/payments/payments.service';
import {
  InMemoryEntitlementLedgerRepository,
  type EntitlementLedgerRepository,
} from './modules/entitlements/entitlement-ledger.repository';
import { PgEntitlementLedgerRepository } from './modules/entitlements/entitlement-ledger.repository.pg';
import {
  InMemoryCreditLedgerRepository,
  type CreditLedgerRepository,
} from './modules/entitlements/credit-ledger.repository';
import { PgCreditLedgerRepository } from './modules/entitlements/credit-ledger.repository.pg';
import {
  InMemoryReservationRepository,
  type ReservationRepository,
} from './modules/reservations/reservation.repository';
import { PgReservationRepository } from './modules/reservations/reservation.repository.pg';
import { InMemoryUserRepository, type UserRepository } from './modules/users/user.repository';
import { PgUserRepository } from './modules/users/user.repository.pg';

async function main(): Promise<void> {
  loadDotenv();
  const env = loadEnv();

  // Auth config from env; fall back to the dev secret when unset (production is
  // forced to provide JWT_SECRET by env validation).
  if (!env.JWT_SECRET) {
    console.warn('JWT_SECRET not set — using insecure dev secret. Do NOT use in production.');
  }
  const auth: AuthConfig = {
    secret: env.JWT_SECRET ?? DEV_AUTH_CONFIG.secret,
    accessTtl: env.JWT_ACCESS_TTL,
    issuer: env.JWT_ISSUER,
    audience: env.JWT_AUDIENCE,
  };

  // KV store: Redis when REDIS_URL is set, else in-memory (zero infra).
  const kv: KvStore = env.REDIS_URL ? new RedisKvStore(env.REDIS_URL) : new InMemoryKvStore();
  console.log(
    env.REDIS_URL ? 'Using Redis KV store' : 'Using in-memory KV store (no REDIS_URL set)',
  );

  // Object store: Cloudflare R2 when all four R2_* vars are set, else in-memory.
  let objectStore: ObjectStore;
  if (env.R2_ACCOUNT_ID && env.R2_ACCESS_KEY_ID && env.R2_SECRET_ACCESS_KEY && env.R2_BUCKET) {
    objectStore = new R2ObjectStore({
      accountId: env.R2_ACCOUNT_ID,
      accessKeyId: env.R2_ACCESS_KEY_ID,
      secretAccessKey: env.R2_SECRET_ACCESS_KEY,
      bucket: env.R2_BUCKET,
    });
    console.log('Using Cloudflare R2 object store');
  } else {
    objectStore = new FakeObjectStore();
    console.log('Using in-memory object store (R2_* not fully set)');
  }

  // Repositories: Postgres when DATABASE_URL is set, else in-memory (zero infra).
  let pool: Pool | undefined;
  let users: UserRepository;
  let subscriptions: SubscriptionRepository;
  let routes: RouteRepository;
  let stops: StopRepository;
  let routeStops: RouteStopRepository;
  let trips: TripRepository;
  let sessions: SessionRepository;
  let authIdentities: AuthIdentityRepository;
  let payments: PaymentRepository;
  let deviceTokens: DeviceTokenRepository;
  let scanEvents: ScanEventRepository;
  let entitlements: EntitlementLedgerRepository;
  let credits: CreditLedgerRepository;
  let reservations: ReservationRepository;
  if (env.DATABASE_URL) {
    pool = createPool(env.DATABASE_URL);
    users = new PgUserRepository(pool);
    subscriptions = new PgSubscriptionRepository(pool);
    routes = new PgRouteRepository(pool);
    stops = new PgStopRepository(pool);
    routeStops = new PgRouteStopRepository(pool);
    trips = new PgTripRepository(pool);
    sessions = new PgSessionRepository(pool);
    authIdentities = new PgAuthIdentityRepository(pool);
    payments = new PgPaymentRepository(pool);
    deviceTokens = new PgDeviceTokenRepository(pool);
    scanEvents = new PgScanEventRepository(pool);
    entitlements = new PgEntitlementLedgerRepository(pool);
    credits = new PgCreditLedgerRepository(pool);
    reservations = new PgReservationRepository(pool);
    console.log('Using Postgres repositories');
  } else {
    users = new InMemoryUserRepository();
    subscriptions = new InMemorySubscriptionRepository();
    routes = new InMemoryRouteRepository();
    stops = new InMemoryStopRepository();
    routeStops = new InMemoryRouteStopRepository();
    trips = new InMemoryTripRepository();
    sessions = new InMemorySessionRepository();
    authIdentities = new InMemoryAuthIdentityRepository();
    payments = new InMemoryPaymentRepository();
    deviceTokens = new InMemoryDeviceTokenRepository();
    scanEvents = new InMemoryScanEventRepository();
    entitlements = new InMemoryEntitlementLedgerRepository();
    credits = new InMemoryCreditLedgerRepository();
    reservations = new InMemoryReservationRepository();
    console.log('Using in-memory repositories (no DATABASE_URL set)');
  }

  // Boarding: short-lived QR passes signed with the server key + a scan audit
  // log; the KV store marks passes consumed (single-use).
  const boardingService = new BoardingService({
    scanEvents,
    kv,
    secret: auth.secret,
    passTtlSeconds: 60,
  });

  // Sign-in verifier: real Google when configured; a dev fake outside production;
  // otherwise undefined (POST /auth/google returns 503 — keeps staging booting).
  let verifier: IdTokenVerifier | undefined;
  if (env.GOOGLE_CLIENT_ID) {
    verifier = new GoogleIdTokenVerifier(env.GOOGLE_CLIENT_ID);
    console.log('Using Google ID-token verifier');
  } else if (env.NODE_ENV !== 'production') {
    verifier = new FakeIdTokenVerifier();
    console.warn('GOOGLE_CLIENT_ID not set — using FAKE sign-in verifier (non-production only).');
  } else {
    console.warn('GOOGLE_CLIENT_ID not set — sign-in disabled (POST /auth/google returns 503).');
  }

  const authService = new AuthService({
    users,
    authIdentities,
    sessions,
    jwt: createJwtService(auth),
    verifier,
    refreshTtlDays: env.JWT_REFRESH_TTL_DAYS,
  });

  // Paystack client: real when the secret key is set; a dev fake outside
  // production; otherwise undefined (payment routes return 503 — keeps staging up).
  let paystack: PaystackClient | undefined;
  if (env.PAYSTACK_SECRET_KEY) {
    paystack = new PaystackHttpClient(env.PAYSTACK_SECRET_KEY);
    console.log('Using Paystack HTTP client');
  } else if (env.NODE_ENV !== 'production') {
    paystack = new FakePaystackClient();
    console.warn('PAYSTACK_SECRET_KEY not set — using FAKE payments client (non-production only).');
  } else {
    console.warn('PAYSTACK_SECRET_KEY not set — payments disabled (POST /payments/* returns 503).');
  }

  const paymentsService = new PaymentsService({
    payments,
    subscriptions,
    entitlements,
    paystack,
    subscriptionFees: SUBSCRIPTION_FEES_PESEWAS,
    ridesPerPeriod: PLACEHOLDER_RIDES_PER_PERIOD,
  });

  // Readiness pings every configured backing service (DB + KV).
  const isReady = async (): Promise<boolean> => {
    if (pool) {
      try {
        await pool.query('SELECT 1');
      } catch {
        return false;
      }
    }
    return kv.ping();
  };

  const rateLimit: RateLimitConfig = {
    max: env.RATE_LIMIT_MAX,
    windowSeconds: env.RATE_LIMIT_WINDOW_SECONDS,
  };

  const app = await buildApp({
    users,
    subscriptions,
    routes,
    stops,
    routeStops,
    trips,
    deviceTokens,
    boardingService,
    authService,
    paymentsService,
    entitlements,
    credits,
    reservations,
    kv,
    objectStore,
    isReady,
    auth,
    rateLimit,
    // /metrics: protected by a token when set; disabled in prod when unset.
    metrics: { token: env.METRICS_TOKEN, allowUnprotected: env.NODE_ENV !== 'production' },
    logger: true,
  });

  const shutdown = async (signal: string): Promise<void> => {
    app.log.info(`Received ${signal}, shutting down`);
    await app.close();
    await pool?.end();
    await kv.close();
    await stopTracing();
    process.exit(0);
  };
  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));

  await app.listen({ port: env.PORT, host: env.HOST });
  app.log.info(`Trotxi API listening on http://${env.HOST}:${env.PORT}`);
  app.log.info(`API docs (Swagger UI) at http://${env.HOST}:${env.PORT}/docs`);
}

main().catch((err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
