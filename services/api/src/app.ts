import fastifySwagger from '@fastify/swagger';
import fastifySwaggerUi from '@fastify/swagger-ui';
import Fastify, { type FastifyInstance } from 'fastify';
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
  subscriptions?: SubscriptionRepository;
  logger?: boolean;
}

export async function buildApp(deps: AppDeps = {}): Promise<FastifyInstance> {
  const app = Fastify({ logger: deps.logger ?? false });
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
    },
  });
  await app.register(fastifySwaggerUi, { routePrefix: '/docs' });

  app.get('/', async () => ({
    service: 'trotxi-api',
    version: '0.1.0',
    docs: '/docs',
    health: '/healthz',
  }));
  app.get('/version', async () => ({
    name: 'trotxi-api',
    version: '0.1.0',
    commit: process.env['GIT_SHA'] ?? 'dev',
  }));

  app.get('/healthz', async () => ({ status: 'ok' }));

  app.get('/readyz', async (_request, reply) => {
    if (await isReady()) {
      return { status: 'ready' };
    }
    return reply.code(503).send({ status: 'not_ready' });
  });

  return app;
}
