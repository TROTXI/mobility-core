// What the contract says about one operation, worked out once at start-up:
// which group serves it, who may call it, and how it is admitted.
import { publicCatalogReads } from '../transport/catalog.js';
import { authOperations, publicAuthOperations, passkeyOperations } from '../auth/service.js';
import { driverOperations } from '../auth/driver-service.js';
import { refundOperations } from '../payments/refunds.js';
import { membershipOperations } from '../membership/service.js';
import { tripReads } from '../transport/trips.js';
import { configOperations, publicConfigOperations } from '../config/service.js';
import { pricingOperations } from '../payments/pricing.js';
import { accountOperations, avatarOperations } from '../account/service.js';
import { purchaseOperations } from '../payments/purchases.js';
import { standbyOperations } from '../membership/standby.js';
import { boardingOperations } from '../boarding/service.js';
import { inboxOperations } from '../notifications/inbox.js';

// The contract admits a `worker` client on exactly these, with no platform:
// scheduled maintenance is an operations caller without an app build behind it.
const maintenanceOperations = new Set([
  'runPersonalPauseResumes',
  'runTripGeneration',
  'runPayments',
  'runPaymentInbox',
  'runPaymentReconciliation',
  'runPeriodClose',
  'runAskDispatch',
  'runReservationDefaults',
  'runNoShows',
  'runRouteLearning',
  'runGpsRetention',
]);
const paymentOperations = [
  'receivePaystackWebhook',
  'listPaymentReviews',
  'resolvePaymentReview',
  'runPayments',
  'runPaymentInbox',
  'runPaymentReconciliation',
  'runPeriodClose',
];

export interface Operation {
  operationId: string;
  parameters: { in: string; name: string; schema: Record<string, unknown> }[];
  requestBody?: { content: Record<string, { schema: Record<string, unknown> }> };
  responses: Record<string, { content?: Record<string, { schema: Record<string, unknown> }> }>;
}

const listed = (names: readonly string[], name: string) => names.includes(name);

export function describeRoute(path: string, method: string, operation: Operation) {
  const name = operation.operationId;
  const publicAuth = listed(publicAuthOperations, name);
  const publicRead = listed(publicCatalogReads, name);
  const publicConfig = listed(publicConfigOperations, name);
  const ops = path.startsWith('/v1/ops/');
  return {
    name,
    method,
    operation,
    input: operation.requestBody?.content['application/json']?.schema,
    paymentEndpoint: paymentOperations.includes(name),
    refundEndpoint: listed(refundOperations, name),
    membershipEndpoint: listed(membershipOperations, name),
    standbyEndpoint: listed(standbyOperations, name),
    inboxEndpoint: listed(inboxOperations, name),
    boardingEndpoint: listed(boardingOperations, name),
    pricingEndpoint: listed(pricingOperations, name),
    purchaseEndpoint: listed(purchaseOperations, name),
    accountEndpoint: listed(accountOperations, name),
    avatarEndpoint: listed(avatarOperations, name),
    configEndpoint: listed(configOperations, name),
    publicConfig,
    authentication: listed(authOperations, name),
    driverEndpoint: listed(driverOperations, name),
    publicAuth,
    // Trip reads need a session but not a particular app: a rider watching a
    // bus, a driver checking the board and ops all read the same catalogue.
    anyClient: publicRead || listed(tripReads, name),
    anonymous: publicRead || publicAuth || publicConfig,
    ops,
    scheduled: ops && maintenanceOperations.has(name),
    authLimited:
      publicAuth ||
      name === 'changeDriverPin' ||
      name === 'startPhoneVerification' ||
      name === 'confirmPhoneVerification' ||
      listed(passkeyOperations, name),
  };
}
export type RouteInfo = ReturnType<typeof describeRoute>;
