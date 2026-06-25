import type { Pool } from 'pg';
import { buildApp } from './app';
import { loadDotenv } from './config/dotenv';
import { loadEnv } from './config/env';
import { createPool } from './db/pool';
import { InMemoryKvStore, type KvStore } from './kv/kv.store';
import { RedisKvStore } from './kv/kv.store.redis';
import { DEV_AUTH_CONFIG, type AuthConfig } from './modules/auth/jwt';
import type { RateLimitConfig } from './modules/ratelimit/ratelimit.plugin';
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

  // Repositories: Postgres when DATABASE_URL is set, else in-memory (zero infra).
  let pool: Pool | undefined;
  let users: UserRepository;
  if (env.DATABASE_URL) {
    pool = createPool(env.DATABASE_URL);
    users = new PgUserRepository(pool);
    console.log('Using Postgres repositories');
  } else {
    users = new InMemoryUserRepository();
    console.log('Using in-memory repositories (no DATABASE_URL set)');
  }

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

  const app = await buildApp({ users, kv, isReady, auth, rateLimit, logger: true });

  const shutdown = async (signal: string): Promise<void> => {
    app.log.info(`Received ${signal}, shutting down`);
    await app.close();
    await pool?.end();
    await kv.close();
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
