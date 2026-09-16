import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import test from 'node:test';
import { schemas, operations, exampleCases } from '../contracts/target-contract.mjs';
import { operationScope } from '../contracts/operation-scope.mjs';

const spec = JSON.parse(
  await readFile(new URL('../contracts/target.openapi.json', import.meta.url), 'utf8'),
);
const inventory = JSON.parse(
  await readFile(new URL('../contracts/endpoint-inventory.json', import.meta.url), 'utf8'),
);
// Resolve the validator already installed by Fastify, without changing dependencies.
const require = createRequire(import.meta.url);
const fastifyRequire = createRequire(require.resolve('../../../services/api/node_modules/fastify'));
const compilerRequire = createRequire(fastifyRequire.resolve('@fastify/ajv-compiler'));
const Ajv = compilerRequire('ajv');
const addFormats = compilerRequire('ajv-formats');
const ajv = new Ajv({ strict: false, allErrors: true });
addFormats(ajv);
ajv.addFormat('binary', true);
// OpenAPI 3.0 uses draft-4 boolean exclusive bounds; Ajv uses draft-7 numbers.
// Translate dialect syntax for validation, not the contract's numeric semantics.
function jsonSchema(value) {
  if (Array.isArray(value)) return value.map(jsonSchema);
  if (!value || typeof value !== 'object') return value;
  const result = Object.fromEntries(Object.entries(value).map(([k, v]) => [k, jsonSchema(v)]));
  for (const suffix of ['Minimum', 'Maximum'])
    if (typeof result['exclusive' + suffix] === 'boolean') {
      const inclusive = suffix.toLowerCase();
      if (result['exclusive' + suffix]) {
        result['exclusive' + suffix] = result[inclusive];
        delete result[inclusive];
      } else delete result['exclusive' + suffix];
    }
  return result;
}
ajv.addSchema({ $id: 'urn:trotxi:design', components: jsonSchema(spec.components) });
const validate = (name) => ajv.compile({ $ref: `urn:trotxi:design#/components/schemas/${name}` });

test('commute event history declares pagination only, without its parent status filter', async () => {
  const runtime = JSON.parse(
    await readFile(
      new URL('../../../services/api-next/src/http/contract.json', import.meta.url),
      'utf8',
    ),
  );
  for (const source of [spec, runtime]) {
    const operation = source.paths['/v1/ops/commute-requests/{id}/events'].get;
    assert.deepEqual(
      operation.parameters.filter((p) => p.in === 'query').map((p) => p.name),
      ['cursor', 'limit'],
    );
    for (const path of ['/v1/me/commute-requests', '/v1/ops/commute-requests'])
      assert.ok(
        source.paths[path].get.parameters.some((p) => p.in === 'query' && p.name === 'status'),
      );
  }
});

test('every current operation maps to an explicitly defined replacement', () => {
  assert.equal(inventory.length, 103);
  for (const row of inventory) {
    const [method, path] = row.target.split(' ');
    assert.ok(spec.paths[path]?.[method.toLowerCase()], row.current);
  }
});
test('all 35 predecessor-free operations have a requirement, scope decision and existing-endpoint assessment', () => {
  const predecessors = new Set(inventory.map((r) => r.target));
  const additions = operations.filter(
    (o) => !predecessors.has(`${o.method.toUpperCase()} ${o.path}`),
  );
  assert.equal(additions.length, 35);
  assert.equal(operationScope.length, 35);
  for (const o of additions) {
    const api = spec.paths[o.path][o.method];
    assert.ok(['cutover', 'deferred'].includes(api['x-delivery-stage']));
    assert.ok(api['x-requirement']);
    assert.ok(api['x-existing-endpoint-assessment']);
  }
  assert.equal(operationScope.filter((s) => s.delivery === 'deferred').length, 13);
});
test('operation IDs, method/path pairs and references are unique/resolved', () => {
  assert.equal(new Set(operations.map((o) => o.operationId)).size, operations.length);
  assert.equal(new Set(operations.map((o) => o.method + ' ' + o.path)).size, operations.length);
  for (const name of Object.keys(spec.components.schemas))
    assert.doesNotThrow(() => validate(name), name);
});
test('schedule service window is explicit, required and independent of departure time', () => {
  const input = {
    departure: { kind: 'new' },
    patternVersionId: 'version-1',
    serviceWindow: 'morning',
    localDeparture: '15:00',
    timeZone: 'Africa/Accra',
    weekdays: [1, 2, 3, 4, 5],
    effectiveFrom: '2026-09-15',
    effectiveTo: null,
  };
  assert.equal(schemas.ScheduleInput.safeParse(input).success, true);
  assert.equal(validate('ScheduleInput')(input), true);
  const { serviceWindow, ...missing } = input;
  assert.equal(schemas.ScheduleInput.safeParse(missing).success, false);
  assert.equal(validate('ScheduleInput')(missing), false);
  assert.equal(
    schemas.ScheduleInput.safeParse({ ...input, serviceWindow: 'outbound' }).success,
    false,
  );
});
test('schedule creation explicitly distinguishes a new departure from another revision', () => {
  const base = {
    patternVersionId: 'version-2',
    serviceWindow: 'evening',
    localDeparture: '23:30',
    timeZone: 'Africa/Accra',
    weekdays: [1, 2, 3, 4, 5],
    effectiveFrom: '2026-09-15',
    effectiveTo: null,
  };
  for (const departure of [{ kind: 'new' }, { kind: 'existing', departureId: 'departure-1' }]) {
    assert.equal(schemas.ScheduleInput.safeParse({ ...base, departure }).success, true);
    assert.equal(validate('ScheduleInput')({ ...base, departure }), true);
  }
  for (const input of [
    base,
    { ...base, departure: { kind: 'existing' } },
    { ...base, departure: { kind: 'new', departureId: 'ignored' } },
  ]) {
    assert.equal(schemas.ScheduleInput.safeParse(input).success, false);
    assert.equal(validate('ScheduleInput')(input), false);
  }
});
test('trip business date is explicit and immutable through reschedule; launch only permits run 1', () => {
  const input = {
    scheduleId: 'revision-1',
    serviceDate: '2026-09-15',
    scheduledAt: '2026-09-16T00:15:00Z',
  };
  assert.equal(schemas.TripInput.parse(input).runNumber, 1);
  assert.equal(validate('TripInput')(input), true);
  for (const invalid of [
    { ...input, serviceDate: undefined },
    { ...input, serviceDate: '2026-02-30' },
    { ...input, runNumber: 2 },
  ]) {
    assert.equal(schemas.TripInput.safeParse(invalid).success, false);
    assert.equal(validate('TripInput')(invalid), false);
  }
  const edit = { scheduledAt: '2026-09-16T00:15:00Z' };
  assert.equal(schemas.TripEdit.safeParse(edit).success, true);
  assert.equal(validate('TripEdit')(edit), true);
  for (const extra of [
    { serviceDate: '2026-09-16' },
    { departureId: 'another' },
    { runNumber: 2 },
  ]) {
    assert.equal(schemas.TripEdit.safeParse({ ...edit, ...extra }).success, false);
    assert.equal(validate('TripEdit')({ ...edit, ...extra }), false);
  }
});
test('all examples pass both authoritative Zod and emitted OpenAPI schemas', () => {
  for (const sample of exampleCases) {
    schemas[sample.schema].parse(sample.value);
    const check = validate(sample.schema);
    assert.ok(check(sample.value), `${sample.name}: ${JSON.stringify(check.errors)}`);
  }
});
test('ops trip responses have assignment references; driver responses expose edit tokens but not ops-only IDs', () => {
  assert.ok(schemas.DriverTrip.shape.editToken);
  for (const field of ['scheduleId', 'assignedDriverId', 'vehicleId']) {
    assert.equal(schemas.DriverTrip.shape[field], undefined);
    assert.ok(schemas.OpsTrip.shape[field]);
  }
  for (const op of operations.filter((o) =>
    ['listOpsTrips', 'createTrip', 'assignTrip', 'rescheduleTrip', 'cancelTrip'].includes(
      o.operationId,
    ),
  ))
    assert.equal(op.response, 'OpsTrip');
});
test('nullable named objects remain nullable in generated OpenAPI', () => {
  const sample = exampleCases.find((e) => e.name === 'never-subscribed');
  assert.ok(validate(sample.schema)(sample.value));
  assert.equal(validate('MembershipResponse')({ data: null }), false);
});
test('prose JSON examples match the same executable response schemas', async () => {
  const markdown = await readFile(new URL('../api-redesign-proposal.md', import.meta.url), 'utf8');
  for (const match of markdown.matchAll(/```json\n([\s\S]*?)\n```/g)) {
    const value = JSON.parse(match[1]);
    const name = value.error
      ? 'ErrorResponse'
      : value.data?.membership
        ? 'MembershipResponse'
        : 'LiveTripResponse';
    assert.equal(schemas[name].safeParse(value).success, true, name);
    assert.ok(validate(name)(value), name);
  }
});
test('rider membership cannot carry ops-only identity or provider fields', () => {
  const sample = structuredClone(exampleCases[0].value);
  sample.data.providerReference = 'private';
  assert.equal(schemas.MembershipResponse.safeParse(sample).success, false);
  assert.equal(validate('MembershipResponse')(sample), false);
});
test('monthly/annual plans survive; invented products and caller amounts are refused', () => {
  const input = {
    plan: 'annual',
    routeId: 'route',
    legs: [
      {
        direction: 'outbound',
        scheduleId: 'a',
        patternVersionId: 'b',
        pickupOccurrenceId: 'c',
        dropoffOccurrenceId: 'd',
      },
      {
        direction: 'return',
        scheduleId: 'e',
        patternVersionId: 'f',
        pickupOccurrenceId: 'g',
        dropoffOccurrenceId: 'h',
      },
    ],
    useCredit: true,
  };
  assert.equal(schemas.PurchaseInput.safeParse(input).success, true);
  assert.equal(schemas.PurchaseInput.safeParse({ ...input, plan: 'weekly' }).success, false);
  assert.equal(schemas.PurchaseInput.safeParse({ ...input, amount: 1 }).success, false);
});
test('boarding proof is a bounded discriminated union, not optional fields', () => {
  assert.equal(
    schemas.BoardingInput.safeParse({ kind: 'photo', reservationId: 'r' }).success,
    true,
  );
  assert.equal(
    schemas.BoardingInput.safeParse({ kind: 'code', code: 'AB23', reservationId: 'r' }).success,
    false,
  );
  assert.equal(schemas.BoardingInput.safeParse({ kind: 'qr' }).success, false);
});
test('GPS requires stable fix identity and has no client receipt timestamp', () => {
  const fix = {
    clientFixId: '00000000-0000-4000-8000-000000000001',
    capturedAt: '2026-09-14T12:00:00Z',
    latitude: 5.6,
    longitude: -0.2,
  };
  assert.equal(schemas.PositionInput.safeParse(fix).success, true);
  assert.equal(
    schemas.PositionInput.safeParse({ ...fix, receivedAt: fix.capturedAt }).success,
    false,
  );
  assert.equal(schemas.PositionInput.safeParse({ ...fix, latitude: 100 }).success, false);
});
test('private and ops operations declare authentication; worker access is maintenance-only', () => {
  for (const o of operations) {
    const api = spec.paths[o.path][o.method];
    if (o.access !== 'public' && o.access !== 'provider_signature')
      assert.ok(api.security.length > 0, o.path);
    if (api.security.some((s) => s.workerAuth))
      assert.ok(o.path.startsWith('/v1/ops/maintenance/'));
  }
  assert.deepEqual(spec.paths['/v1/trips/{id}/live'].get.security, [{ bearerAuth: [] }]);
});
test('stable bootstrap is unversioned; build policy distinguishes app and platform', () => {
  assert.deepEqual(spec.paths['/flags'].get.security, []);
  assert.equal(spec.paths['/v1/config'], undefined);
  assert.ok(spec.paths['/v1/ops/min-versions/{app}/{platform}']);
});
test('editable ops commands declare If-Match and replay-safe mutation headers', () => {
  for (const o of operations.filter((o) => o.etag)) {
    const p = spec.paths[o.path][o.method];
    assert.ok(p.parameters.some((x) => x.name === 'If-Match' && x.required));
    assert.ok(p.responses['412']);
    assert.ok(p.responses['428']);
  }
});
test('domain cross-field rules are explicitly not claimed as schema-only proof', () => {
  // A response-schema test must not be reported as proof of access/state logic.
  assert.ok(
    operations.every(
      (o) => spec.paths[o.path][o.method]['x-implementation-status'] === 'design_only',
    ),
  );
});

test('catalog drafts require bounded configured geometry; editable lists expose resource tokens', () => {
  const point = { latitude: 5.6, longitude: -0.2 };
  const input = {
    stops: [
      { stopId: 'one', name: 'Depot', location: point },
      { stopId: 'one', name: 'Second visit', location: point },
    ],
    geometry: {
      points: [point, { ...point, longitude: -0.21 }, point],
      stopDistancesMeters: [0, 2200],
    },
  };
  assert.equal(schemas.PatternVersionInput.safeParse(input).success, true);
  assert.equal(validate('PatternVersionInput')(input), true);
  for (const bad of [
    { ...input, geometry: undefined },
    { ...input, geometry: { ...input.geometry, points: [point] } },
    { ...input, geometry: { ...input.geometry, stopDistancesMeters: [0, -1] } },
    { ...input, geometry: { ...input.geometry, points: Array(10001).fill(point) } },
  ]) {
    assert.equal(schemas.PatternVersionInput.safeParse(bad).success, false);
    // Ajv sees JSON, where undefined properties are absent.
    assert.equal(validate('PatternVersionInput')(JSON.parse(JSON.stringify(bad))), false);
  }
  for (const name of ['Route', 'Stop', 'PatternVersion', 'Driver']) {
    assert.ok(schemas[name].shape.editToken);
    assert.ok(spec.components.schemas[name].required.includes('editToken'));
  }
  for (const field of ['effectiveFrom', 'effectiveTo', 'revision'])
    assert.ok(schemas.PatternVersion.shape[field]);
});

test('runtime subset implements only selected cutover operations and contains no deferred detail GET', async () => {
  const runtime = JSON.parse(
    await readFile(
      new URL('../../../services/api-next/src/http/contract.json', import.meta.url),
      'utf8',
    ),
  );
  let count = 0;
  for (const [path, methods] of Object.entries(runtime.paths))
    for (const [method, operation] of Object.entries(methods)) {
      count++;
      assert.deepEqual(operation, spec.paths[path][method]);
      assert.notEqual(operation['x-delivery-stage'], 'deferred');
    }
  assert.equal(count, 119);
  assert.equal(runtime.paths['/v1/ops/routes/{id}'].get, undefined);
  assert.equal(runtime.paths['/v1/ops/stops/{id}'].get, undefined);
  assert.equal(runtime.paths['/v1/ops/drivers/{id}'].get, undefined);
  // Single-resource vehicle reads stay deferred: the ops list carries the row
  // version, so a detail GET adds surface without answering a requirement.
  assert.equal(runtime.paths['/v1/ops/vehicles/{id}'].get, undefined);
  assert.equal(schemas.CredentialIssue.safeParse({}).success, true);
  assert.equal(schemas.CredentialIssue.safeParse({ code: 'DR-B7K9' }).success, true);
  assert.ok(runtime.paths['/v1/auth/driver/pin'].post.responses['423']);
});
