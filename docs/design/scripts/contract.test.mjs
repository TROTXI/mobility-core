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
test('all examples pass both authoritative Zod and emitted OpenAPI schemas', () => {
  for (const sample of exampleCases) {
    schemas[sample.schema].parse(sample.value);
    const check = validate(sample.schema);
    assert.ok(check(sample.value), `${sample.name}: ${JSON.stringify(check.errors)}`);
  }
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
