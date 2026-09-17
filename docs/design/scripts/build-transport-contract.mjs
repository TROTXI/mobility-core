// Executable subset of the reviewed contract, not a second schema source.
import { readFile } from 'node:fs/promises';
import { writeArtifact } from './artifact-io.mjs';
const source = JSON.parse(
  await readFile(new URL('../contracts/target.openapi.json', import.meta.url), 'utf8'),
);
const selected = new Set([
  'issuePass',
  'getManifest',
  'getTripSummary',
  'boardRider',
  'markNoShow',
  'runNoShows',
  'runAskDispatch',
  'runReservationDefaults',
  'getMembership',
  'listCommuteRequests',
  'createCommuteRequest',
  'withdrawCommuteRequest',
  'listOpsCommuteRequests',
  'decideCommuteRequest',
  'listCommuteEvents',
  'listCommuteSlots',
  'createCommuteSlot',
  'retireCommuteSlot',
  'listReservations',
  'decideReservation',
  'createAccountRestriction',
  'releaseAccountRestriction',
  'receivePaystackWebhook',
  'listPaymentReviews',
  'resolvePaymentReview',
  'runPayments',
  'runPaymentInbox',
  'runPaymentReconciliation',
  'runPeriodClose',
  'listOpsDrivers',
  'createDriver',
  'updateDriver',
  'issueDriverCredential',
  'resetDriverPin',
  'changeCredentialState',
  'changeDriverPin',
  'signInGoogle',
  'signInApple',
  'signInDriver',
  'refreshSession',
  'logoutSession',
  'getAccount',
  'listSessions',
  'revokeSession',
  'createSchedule',
  'listSchedules',
  'createTrip',
  'listOpsTrips',
  'listDriverTrips',
  'startTrip',
  'completeTrip',
  'recordArrival',
  'rescheduleTrip',
  'assignTrip',
  'cancelTrip',
  'listOpsRoutes',
  'createRoute',
  'updateRoute',
  'listOpsStops',
  'createStop',
  'updateStop',
  'listOpsVehicles',
  'createVehicle',
  'updateVehicle',
  'listDriverIncidents',
  'reportIncident',
  'listOpsIncidents',
  'decideIncident',
  'listDriverRequests',
  'createDriverRequest',
  'withdrawDriverRequest',
  'listOpsDriverRequests',
  'decideDriverRequest',
  'listDriverAvailableRoutes',
  'recordPosition',
  'createTraceHold',
  'listTraceHolds',
  'releaseTraceHold',
  'runRouteLearning',
  'runGpsRetention',
  'listPatterns',
  'createPattern',
  'createPatternVersion',
  'listPatternVersions',
  'getOpsPatternVersion',
  'publishPatternVersion',
  'listRoutes',
  'getRoute',
  'getPattern',
  'getPatternVersion',
  'getGeometry',
  'listRouteSchedules',
  'listTrips',
  'getTrip',
  'getLiveTrip',
  'listPurchases',
  'createPurchase',
  'getPurchase',
  'listOpsPurchases',
  'getOpsPurchase',
  'listFares',
  'createFare',
  'listPlanPricing',
  'updatePlanPricing',
  'updateAccount',
  'eraseAccount',
  'getAvatar',
  'uploadAvatar',
  'registerDevice',
  'getRoot',
  'getHealth',
  'getReadiness',
  'getBuild',
  'getBootstrap',
  'listFlags',
  'setFlag',
  'listMinimumVersions',
  'setMinimumVersion',
  'changeRole',
  'getOpsOverview',
  'getDriverSelf',
]);
const count = selected.size;
const paths = {};
const needed = new Set();
function references(value) {
  if (!value || typeof value !== 'object') return;
  if (typeof value.$ref === 'string' && value.$ref.startsWith('#/components/schemas/')) {
    const name = value.$ref.split('/').at(-1);
    if (!needed.has(name)) {
      needed.add(name);
      references(source.components.schemas[name]);
    }
  }
  for (const child of Object.values(value)) references(child);
}
for (const [path, methods] of Object.entries(source.paths)) {
  for (const [method, operation] of Object.entries(methods)) {
    if (!selected.has(operation.operationId)) continue;
    if (operation['x-delivery-stage'] === 'deferred')
      throw new Error('Do not implement deferred operations accidentally');
    paths[path] ??= {};
    paths[path][method] = operation;
    references(operation);
    selected.delete(operation.operationId);
  }
}
if (selected.size) throw new Error(`Missing operations: ${[...selected]}`);
references({ $ref: '#/components/schemas/ErrorResponse' });
// The reviewed spec is OpenAPI 3.0, where an exclusive bound is a flag beside
// the bound it modifies. The runtime validates against 2020-12, where it is
// the bound. Rewriting it here keeps one authoritative source instead of a
// second hand-maintained copy, and refuses anything it does not understand.
function modern(value) {
  if (Array.isArray(value)) return value.map(modern);
  if (!value || typeof value !== 'object') return value;
  const out = {};
  for (const [key, child] of Object.entries(value)) {
    if (key === 'exclusiveMinimum' || key === 'exclusiveMaximum') {
      if (typeof child === 'number') {
        out[key] = child;
        continue;
      }
      if (child !== true) throw new Error(`Unsupported ${key}: ${JSON.stringify(child)}`);
      const bound = key === 'exclusiveMinimum' ? 'minimum' : 'maximum';
      if (typeof value[bound] !== 'number')
        throw new Error(`Exclusive ${bound} without a bound to exclude`);
      out[key] = value[bound];
      delete out[bound];
      continue;
    }
    if ((key === 'minimum' || key === 'maximum') && out[key] === undefined) {
      const flag = key === 'minimum' ? 'exclusiveMinimum' : 'exclusiveMaximum';
      if (value[flag] === true) continue;
    }
    out[key] = modern(child);
  }
  return out;
}
const schemas = Object.fromEntries(
  [...needed].sort().map((name) => [name, modern(source.components.schemas[name])]),
);
await writeArtifact(
  new URL('../../../services/api-next/src/http/contract.json', import.meta.url),
  JSON.stringify(
    {
      paths: modern(paths),
      components: { schemas, responses: modern(source.components.responses) },
    },
    null,
    2,
  ) + '\n',
);

// The same subset as a document a client generator and a Swagger viewer can
// read. The runtime copy above is rewritten to 2020-12 for the validator; this
// one keeps the reviewed OpenAPI 3.0 spelling, because that is what consumers
// parse. It carries only what is implemented: a client offering the thirteen
// deferred operations would invite calls that 404.
const published = {
  openapi: source.openapi,
  info: {
    title: 'Trotxi replacement API',
    version: '1.0.0',
    description: [
      'The implemented replacement surface: every reviewed cutover operation and',
      'nothing else. The thirteen deferred operations are deliberately absent.',
      'Generated from target-contract.mjs by build-transport-contract.mjs; do not',
      'edit this JSON. NOT DEPLOYED: no environment serves this contract yet, and',
      'the server entry below is a placeholder rather than a working host.',
    ].join(' '),
  },
  servers: source.servers,
  paths: Object.fromEntries(
    Object.entries(paths).map(([path, methods]) => [
      path,
      Object.fromEntries(
        Object.entries(methods).map(([method, operation]) => [
          method,
          // x-delivery-stage said which operations to build. Inside a document
          // that contains only the built ones it says nothing, so it goes.
          Object.fromEntries(
            Object.entries(operation).filter(([key]) => key !== 'x-delivery-stage'),
          ),
        ]),
      ),
    ]),
  ),
  components: {
    securitySchemes: source.components.securitySchemes,
    responses: source.components.responses,
    schemas: Object.fromEntries(
      [...needed].sort().map((name) => [name, source.components.schemas[name]]),
    ),
  },
};
await writeArtifact(
  new URL('../contracts/replacement.openapi.json', import.meta.url),
  JSON.stringify(published, null, 2) + '\n',
);
console.log(`Emitted ${count} reviewed replacement operations, ${needed.size} schemas.`);
