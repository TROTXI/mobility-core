import Fastify, { type FastifyInstance } from 'fastify';

/**
 * Dependencies are injected here — services and repositories register as the
 * domain grows (routes → services → repositories, see docs/architecture.md).
 * Tests pass in-memory implementations; production wires the real ones.
 */
export interface AppDeps {
  /** Readiness probe — wire the database ping here once a datastore exists. */
  isReady?: () => Promise<boolean>;
  logger?: boolean;
}

export async function buildApp(deps: AppDeps = {}): Promise<FastifyInstance> {
  const app = Fastify({ logger: deps.logger ?? false });
  const isReady = deps.isReady ?? (async () => true);

  app.get('/', async () => ({
    service: 'trotxi-api',
    version: '0.1.0',
    health: '/healthz',
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
