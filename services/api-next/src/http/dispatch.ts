// Routes a verified request to the handler for its operation group. Order
// matters where groups overlap: a maintenance run is matched before its group.
import type { FastifyReply, FastifyRequest } from 'fastify';
import type { Actor, TransportService } from '../transport/service.js';
import type { AppOptions } from './app.js';
import type { RouteInfo } from './route.js';
import { payments, pricingAndPurchases, refunds } from './handlers/finance.js';
import { account, inbox, membership, standby } from './handlers/rider.js';
import { boarding, config, drivers, publicConfig, tripGeneration } from './handlers/operations.js';
import { authentication, commands, reads } from './handlers/transport.js';

/** What a handler answers: each service returns its own outcome shape. */
export interface HandlerResult {
  status: number;
  headers: object;
  body: unknown;
}

export interface HandlerContext {
  options: AppOptions;
  service: TransportService;
  optionalCaller: (request: { headers: { authorization?: string } }) => Promise<string | null>;
}

export function dispatch(
  context: HandlerContext,
  route: RouteInfo,
  request: FastifyRequest,
  reply: FastifyReply,
  actor: Actor,
): Promise<HandlerResult> {
  const handler = route.refundEndpoint
    ? refunds
    : route.name === 'runTripGeneration'
      ? tripGeneration
      : route.boardingEndpoint
        ? boarding
        : route.paymentEndpoint
          ? payments
          : route.publicConfig
            ? publicConfig
            : route.configEndpoint
              ? config
              : route.accountEndpoint
                ? account
                : route.pricingEndpoint || route.purchaseEndpoint
                  ? pricingAndPurchases
                  : route.inboxEndpoint
                    ? inbox
                    : route.standbyEndpoint
                      ? standby
                      : route.membershipEndpoint
                        ? membership
                        : route.driverEndpoint
                          ? drivers
                          : route.authentication
                            ? authentication
                            : route.method === 'get'
                              ? reads
                              : commands;
  return handler(context, route, request, reply, actor);
}
