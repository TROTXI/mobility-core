import type { Pool } from 'pg';
import { buildApp, type AppDeps } from './app';
import { loadDotenv } from './config/dotenv';
import { loadEnv } from './config/env';
import { createPool } from './db/pool';
import { InMemoryUserRepository } from './modules/users/user.repository';
import { PgUserRepository } from './modules/users/user.repository.pg';

async function main(): Promise<void> {
  loadDotenv();
  const env = loadEnv();

  // Pick repositories by environment: Postgres when DATABASE_URL is set, else
  // in-memory (zero infra). New modules follow this same pattern.
  let pool: Pool | undefined;
  let deps: Pick<AppDeps, 'users' | 'isReady'>;
  if (env.DATABASE_URL) {
    pool = createPool(env.DATABASE_URL);
    deps = {
      users: new PgUserRepository(pool),
      isReady: async () => {
        try {
          await pool!.query('SELECT 1');
          return true;
        } catch {
          return false;
        }
      },
    };
    console.log('Using Postgres repositories');
  } else {
    deps = { users: new InMemoryUserRepository(), isReady: async () => true };
    console.log('Using in-memory repositories (no DATABASE_URL set)');
  }

  const app = await buildApp({ ...deps, logger: true });

  const shutdown = async (signal: string): Promise<void> => {
    app.log.info(`Received ${signal}, shutting down`);
    await app.close();
    await pool?.end();
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
