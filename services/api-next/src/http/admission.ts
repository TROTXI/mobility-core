// Admission: who may reach a handler, from which app and build, and how often.
// Runs as each route's preValidation hook, after the early per-IP limiter.
import type { FastifyReply, FastifyRequest } from 'fastify';
import type { Actor } from '../transport/service.js';
import { fail } from '../transport/errors.js';
import type { AppOptions } from './app.js';
import type { RouteInfo } from './route.js';

export function createAdmission(
  options: AppOptions,
  limits: { budget: number; ipBudget: number; authBudget: number },
  actors: WeakMap<FastifyRequest, Actor>,
) {
  const { budget, ipBudget, authBudget } = limits;
  const floors = options.minimumBuilds;
  async function spendIp(request: FastifyRequest, reply: FastifyReply, authName?: string) {
    if (!options.admitIp) return;
    const buckets: [string, number][] = [['all', ipBudget]];
    if (authName) buckets.push([`auth:${authName}`, authBudget]);
    for (const [bucket, maximum] of buckets) {
      let spent;
      try {
        spent = await options.admitIp(request.ip, bucket);
      } catch {
        fail(503, 'admission_unavailable', 'Please try again later.');
      }
      if (spent!.count > maximum) {
        reply.header('Retry-After', String(spent!.resetsInSeconds));
        fail(429, 'rate_limited', 'Please wait before trying again.');
      }
    }
  }
  const counters = new Map<string, { count: number; until: number }>();
  async function admit(route: RouteInfo, request: FastifyRequest, reply: FastifyReply) {
    const {
      name,
      anonymous,
      publicAuth,
      publicConfig,
      scheduled,
      avatarEndpoint,
      anyClient,
      authentication,
      ops,
      membershipEndpoint,
      standbyEndpoint,
      inboxEndpoint,
      purchaseEndpoint,
      accountEndpoint,
    } = route;
    reply.header('Cache-Control', 'no-store');
    // The local onRequest limiter already ran. Share the second line
    // across replicas only for anonymous routes. Signed-in operations
    // already have the shared account budget; do not add an IP write
    // to GPS, boarding or Ops polling. Their early local limiter stays.
    if (options.admitIp && anonymous && name !== 'getHealth') {
      await spendIp(request, reply, publicAuth ? name : undefined);
    }
    const authorization = request.headers.authorization;
    if (!anonymous && (!authorization || !/^Bearer [^\s]{1,8192}$/.test(authorization)))
      fail(401, 'unauthenticated', 'Sign in to continue.');
    const actor = anonymous ? null : await options.verifyAccess(authorization!);
    if (!anonymous && !actor) fail(401, 'unauthenticated', 'Sign in to continue.');
    // A liveness probe or a start-up fetch carries no application
    // metadata, and the contract declares none for them.
    if (publicConfig) return;
    const client = request.headers['x-trotxi-client'],
      build = request.headers['x-trotxi-build'],
      platform = request.headers['x-trotxi-platform'];
    if (
      [
        'requestPhoneSignIn',
        'verifyPhoneSignIn',
        'startPhoneVerification',
        'confirmPhoneVerification',
        'getVerification',
      ].includes(name) &&
      client !== 'commuter'
    )
      fail(403, 'wrong_client', 'Phone verification is for commuters only.');
    // Only the maintenance operations admit it, and only there does it
    // stand in for an operations client. Nothing else about the ops
    // client's own rules changes.
    const workerClient = scheduled && client === 'worker';
    const platformless = client === 'ops' || workerClient;
    if (
      // A photo belongs to the person, not to the app they happen to
      // be holding, and the manifest a driver reads shows the rider's.
      // Rename and erase stay commuter-only, which is a separate call
      // and has a test of its own.
      (name === 'registerDevice' || avatarEndpoint
        ? !['driver', 'commuter'].includes(String(client))
        : anyClient || authentication
          ? !['ops', 'driver', 'commuter'].includes(String(client))
          : !(
              workerClient ||
              client ===
                (ops
                  ? 'ops'
                  : membershipEndpoint ||
                      (standbyEndpoint && !ops) ||
                      inboxEndpoint ||
                      purchaseEndpoint ||
                      accountEndpoint ||
                      name === 'previewPurchase' ||
                      name === 'issuePass'
                    ? 'commuter'
                    : 'driver')
            )) ||
      (name === 'signInDriver' && client !== 'driver') ||
      typeof build !== 'string' ||
      !/^[1-9]\d{0,8}$/.test(build) ||
      (platformless ? platform !== undefined : !['ios', 'android'].includes(String(platform)))
    )
      fail(
        400,
        'client_metadata_required',
        'Supply the appropriate client, build and platform metadata.',
      );
    // A scheduled worker has no app build behind it, which is why it
    // sends no platform either. Holding it to the operations console's
    // floor would stop retention and period close the moment somebody
    // raised that floor to push an upgrade.
    const floor = workerClient
      ? 0
      : platformless
        ? floors.ops
        : options.config
          ? await options.config.minimumBuild(
              client as 'driver' | 'commuter',
              platform as 'ios' | 'android',
            )
          : floors[client as 'driver' | 'commuter'][platform as 'ios' | 'android'];
    if (Number(build) < floor)
      fail(426, 'client_upgrade_required', 'Update the application before continuing.');
    if (!actor) return; // Public catalog remains IP-limited; no identity fallback.
    if (options.admit) {
      const spent = await options.admit(actor.userId);
      if (spent.count > budget) {
        reply.header('Retry-After', String(spent.resetsInSeconds));
        fail(429, 'rate_limited', 'Please wait before trying again.');
      }
      actors.set(request, actor);
      return;
    }
    // Bounded process-local fallback. It is a real limit for one process
    // and no limit at all across two, which is why the deployable
    // composition always supplies the shared one.
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
  }
  return { admit, spendIp };
}
