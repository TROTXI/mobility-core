// Executable subset of the reviewed contract, not a second schema source.
import { readFile } from 'node:fs/promises';
import { writeArtifact } from './artifact-io.mjs';
const source = JSON.parse(
  await readFile(new URL('../contracts/target.openapi.json', import.meta.url), 'utf8'),
);
const selected = new Set([
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
const schemas = Object.fromEntries(
  [...needed].sort().map((name) => [name, source.components.schemas[name]]),
);
await writeArtifact(
  new URL('../../../services/api-next/src/http/contract.json', import.meta.url),
  JSON.stringify(
    { paths, components: { schemas, responses: source.components.responses } },
    null,
    2,
  ) + '\n',
);
console.log(`Emitted ${count} reviewed transport/catalog operations, ${needed.size} schemas.`);
