import { buildApp } from './app';
import { loadEnv } from './config/env';

async function main(): Promise<void> {
  const env = loadEnv();
  const app = await buildApp({ logger: true });

  const shutdown = async (signal: string): Promise<void> => {
    app.log.info(`Received ${signal}, shutting down`);
    await app.close();
    process.exit(0);
  };
  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));

  await app.listen({ port: env.PORT, host: env.HOST });
  app.log.info(`Trotxi API listening on http://${env.HOST}:${env.PORT}`);
}

main().catch((err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
