import { readFile } from 'node:fs/promises';
import { writeArtifact } from './artifact-io.mjs';
import { z } from '../../../services/api-next/node_modules/zod/index.js';
import { registry, operations, schemas, exampleCases } from '../contracts/target-contract.mjs';
import { operationScope } from '../contracts/operation-scope.mjs';

const dir = new URL('../contracts/', import.meta.url);
const baseline = JSON.parse(await readFile(new URL('baseline.operations.json', dir), 'utf8'));
const ref = (name) => ({ $ref: `#/components/schemas/${name}` });
const converted = z.toJSONSchema(registry, { target: 'openapi-3.0' }).schemas;
// Zod registry refs are names, not document pointers. Normalize only refs.
function normalize(value) {
  if (Array.isArray(value)) return value.map(normalize);
  if (!value || typeof value !== 'object') return value;
  // OpenAPI 3.0 nullable needs a type at the same level. Zod emits nullable
  // allOf refs for registered objects; inline this wrapper, preserving null
  // semantics rather than merely satisfying a structural linter.
  if (value.nullable && value.allOf?.length === 1 && converted[value.allOf[0].$ref]) {
    return { ...normalize(converted[value.allOf[0].$ref]), nullable: true };
  }
  // Zod calls every number a number, so a literal whole number arrives as
  // `type: number`. A run number and an API major version are integers, and
  // saying so is both more accurate and what a client generator needs: a
  // numeric enum it believes is fractional produces a client that will not
  // compile.
  if (value.type === 'number' && Array.isArray(value.enum) && value.enum.every(Number.isInteger))
    return { ...normalize({ ...value, type: undefined }), type: 'integer' };
  // A default beside an enum of exactly one value tells a reader nothing the
  // enum has not already told them, and a client generator handed both emits a
  // constructor that does not compile. The Zod schema keeps its default, which
  // is what actually supplies the value; only the published shape drops it.
  if (Array.isArray(value.enum) && value.enum.length === 1 && value.default === value.enum[0]) {
    const { default: _redundant, ...rest } = value;
    return normalize(rest);
  }
  return Object.fromEntries(
    Object.entries(value).map(([k, v]) => [
      k,
      k === '$ref' && converted[v] ? `#/components/schemas/${v}` : normalize(v),
    ]),
  );
}
const spec = {
  openapi: '3.0.3',
  info: {
    title: 'Trotxi replacement API — stage 1 review',
    version: '1.0.0-draft',
    description:
      'DESIGN ONLY; not deployed. Engineering choices awaiting review are identified in stage-1-review.md. Generated from target-contract.mjs; do not edit JSON.',
  },
  servers: [
    {
      url: 'https://api.example.invalid',
      description: 'Placeholder, not a working API. No live credentials.',
    },
  ],
  paths: {},
  components: {
    responses: {},
    securitySchemes: {
      bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      workerAuth: {
        type: 'http',
        scheme: 'bearer',
        description: 'Audience-restricted service token, allowed task only; not a rider token.',
      },
    },
    schemas: normalize(converted),
  },
};
const query = (name, schema, description) => ({
  name,
  in: 'query',
  required: false,
  schema,
  description,
});
const header = (name, schema, required = true, description) => ({
  name,
  in: 'header',
  required,
  schema,
  description,
});
const str = { type: 'string', minLength: 1, maxLength: 128 };
const response = (name, description = 'Success') => ({
  description,
  ...(name ? { content: { 'application/json': { schema: ref(name) } } } : {}),
});
for (const o of operations) {
  const mutation = !['get', 'head', 'options'].includes(o.method);
  const retry = o.retry ?? (mutation ? 'idempotency_key' : 'safe_read');
  const status = String(o.status ?? 200);
  const responses = { [status]: response(o.responseSchema) };
  const failures = [400, 429, 500, 503];
  if (o.path.includes('{')) failures.push(404);
  if (!['public', 'provider_signature'].includes(o.access)) failures.push(401, 403, 404);
  if (mutation && !o.stable) failures.push(409);
  if (o.etag) failures.push(412, 428);
  if (['signInDriver', 'changeDriverPin'].includes(o.operationId)) failures.push(401, 403, 423);
  if (/signIn|refreshSession/.test(o.operationId)) failures.push(401);
  if (o.path.startsWith('/v1/')) failures.push(426);
  if (o.operationId === 'uploadAvatar') failures.push(413, 415);
  if (o.access === 'provider_signature') failures.push(401);
  for (const code of new Set(failures)) {
    spec.components.responses[`Error${code}`] ??= response(
      'ErrorResponse',
      `Error ${code}; bounded code, no internal error text. See stage-1-access-and-gps.md.`,
    );
    responses[code] = { $ref: `#/components/responses/Error${code}` };
  }
  spec.components.responses.Error429.headers = {
    'Retry-After': {
      schema: { type: 'integer', minimum: 1 },
      description: 'Seconds until another attempt.',
    },
  };
  if ((o.method === 'get' && !o.stable) || o.etag)
    responses[status].headers = {
      ETag: {
        schema: { type: 'string' },
        description: 'Opaque resource version; required on protected edits.',
      },
    };
  if (status === '201')
    responses[status].headers = {
      ...responses[status].headers,
      Location: {
        schema: { type: 'string' },
        description: 'Canonical resource URL, even when payment remains pending.',
      },
    };
  const parameters = [...o.path.matchAll(/\{([^}]+)\}/g)].map((m) => ({
    name: m[1],
    in: 'path',
    required: true,
    schema:
      m[1] === 'platform'
        ? { type: 'string', enum: ['ios', 'android'] }
        : m[1] === 'app'
          ? { type: 'string', enum: ['commuter', 'driver'] }
          : m[1] === 'plan'
            ? { type: 'string', enum: ['monthly', 'annual'] }
            : str,
  }));
  if (o.list)
    parameters.push(
      query('cursor', str, 'Opaque cursor bound to caller, sort and filters.'),
      query(
        'limit',
        { type: 'integer', minimum: 1, maximum: 200, default: 50 },
        'Page size. No silent truncation.',
      ),
    );
  // The board's morning/evening toggle. Required, not defaulted: the schema is
  // explicit that the service window is stated and never inferred from a
  // timestamp, and a server guessing it from the clock is exactly that
  // inference wearing a convenience argument.
  if (o.operationId === 'getOpsOverview')
    parameters.push(
      {
        ...query(
          'window',
          { type: 'string', enum: ['morning', 'evening'] },
          'Which service window the board shows. Stated by the caller, never inferred.',
        ),
        required: true,
      },
      query(
        'date',
        { type: 'string', format: 'date' },
        'Service day to show. Defaults to today in Accra; set it to review a past day.',
      ),
    );
  if (o.operationId === 'listOpsRiders')
    parameters.push(
      query(
        'q',
        { type: 'string', minLength: 1, maxLength: 100 },
        'Name, phone or email, partial.',
      ),
    );
  if (o.operationId === 'listOpsDeliveries')
    parameters.push(
      query('channel', { type: 'string', enum: ['email', 'push'] }, 'Delivery channel.'),
      query('state', { type: 'string', maxLength: 50 }, 'Provider delivery state.'),
    );
  if (o.operationId === 'listOpsAuditEvents')
    parameters.push(query('area', { type: 'string', maxLength: 50 }, 'Audit domain.'));
  if (o.operationId === 'getOpsReportSummary')
    parameters.push(
      query('fromDate', { type: 'string', format: 'date' }, 'Inclusive reporting day.'),
      query('toDate', { type: 'string', format: 'date' }, 'Inclusive reporting day.'),
    );
  if (o.list && /trips|reservations|billing-periods|purchases|entries/.test(o.path))
    parameters.push(
      query(
        'fromDate',
        { type: 'string', format: 'date' },
        /purchases/.test(o.path)
          ? 'Optional inclusive Africa/Accra purchase-creation day. With no date filters, returns all purchase history, including unresolved purchases. No default recency cutoff.'
          : 'Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.',
      ),
      query(
        'toDate',
        { type: 'string', format: 'date' },
        /purchases/.test(o.path)
          ? 'Optional inclusive purchase-creation day; if both bounds are supplied, toDate must not precede fromDate.'
          : 'Inclusive; paired with fromDate.',
      ),
    );
  if (o.list && /trips|schedules|commute-slots/.test(o.path))
    parameters.push(
      query('routeId', str, 'Filter within caller scope; never expands authorization.'),
    );
  // A status filter belongs to the resource collection, not nested event
  // history merely because its parent path contains "requests".
  if (o.list && /(?:incidents|requests|reviews)$/.test(o.path))
    parameters.push(
      query(
        'status',
        { type: 'string', maxLength: 50 },
        'Must match the resource state enum; unknown values return 400.',
      ),
    );
  if (o.etag)
    parameters.push(
      header(
        'If-Match',
        str,
        true,
        'Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.',
      ),
    );
  if (['idempotency_key', 'short_lived', 'erasure'].includes(retry))
    parameters.push(
      header(
        'Idempotency-Key',
        str,
        true,
        'Caller + operation + target scoped; payload mismatch = 409. Never log secrets.',
      ),
    );
  if (o.path.startsWith('/v1/')) {
    // The renderer fills a try-it-out field from the parameter's example, not
    // from a schema default, so these three carry one. Which caller an
    // operation is for is already decided by its access, and a reader who has
    // to work that out per endpoint gets it wrong: three of them arriving
    // wrong is the difference between a 400 and a first call that works.
    const client = o.access.startsWith('driver')
      ? 'driver'
      : o.access.startsWith('ops')
        ? 'ops'
        : 'commuter';
    // Parameter-level only: an unknown keyword inside a schema is the kind of
    // thing a strict validator rejects at boot, and the renderer reads this.
    const merge = (base, value) => ({ ...base, example: value });
    parameters.push(
      merge(
        header(
          'X-Trotxi-Client',
          { type: 'string', enum: ['commuter', 'driver', 'ops', 'worker'] },
          true,
          'Compatibility metadata only, never grants a role.',
        ),
        client,
      ),
      merge(
        header(
          'X-Trotxi-Build',
          // Defaulted because Swagger UI seeds an empty integer field with 0,
          // and 0 is refused twice over: below the minimum, and not a positive
          // integer. Every first try-it-out call failed on a value nobody typed.
          { type: 'integer', minimum: 1, default: 1 },
          true,
          'Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.',
        ),
        1,
      ),
      // Optional, and the description says ops and worker must not send it, so
      // only the two app callers get an example to fill.
      client === 'ops'
        ? header(
            'X-Trotxi-Platform',
            { type: 'string', enum: ['ios', 'android'] },
            false,
            'Required for commuter/driver, absent for ops/worker.',
          )
        : merge(
            header(
              'X-Trotxi-Platform',
              { type: 'string', enum: ['ios', 'android'] },
              false,
              'Required for commuter/driver, absent for ops/worker.',
            ),
            'ios',
          ),
    );
  }
  let requestBody;
  if (o.input)
    requestBody = {
      required: true,
      content: { [o.contentType ?? 'application/json']: { schema: ref(o.input) } },
    };
  if (o.access === 'provider_signature') {
    parameters.push(
      header('x-paystack-signature', { type: 'string', pattern: '^[a-fA-F0-9]{128}$' }),
    );
    requestBody = {
      required: true,
      description:
        'Provider-controlled JSON. HMAC exact raw bytes BEFORE parsing. Persist signed unknown events for inspection, not guessed fulfilment.',
      content: {
        'application/json': {
          schema: {
            type: 'object',
            required: ['event', 'data'],
            properties: {
              event: { type: 'string' },
              data: { type: 'object', additionalProperties: true },
            },
            additionalProperties: true,
          },
        },
      },
    };
  }
  const security = ['public', 'provider_signature'].includes(o.access)
    ? []
    : o.access === 'ops_or_scoped_worker'
      ? [{ bearerAuth: [] }, { workerAuth: [] }]
      : [{ bearerAuth: [] }];
  const operation = {
    operationId: o.operationId,
    summary: o.operationId.replace(/([A-Z])/g, ' $1'),
    tags: [o.access],
    security,
    parameters,
    ...(requestBody ? { requestBody } : {}),
    responses,
    'x-authorization': o.access,
    'x-retry': retry,
    'x-sensitive': o.sensitive ?? false,
    'x-list-order': o.list
      ? /trips/.test(o.path)
        ? 'scheduledAt ASC, id ASC'
        : /min-versions/.test(o.path)
          ? 'app ASC, platform ASC'
          : /plan-pricing/.test(o.path)
            ? 'plan ASC'
            : /\/flags$/.test(o.path)
              ? 'key ASC'
              : /billing-periods/.test(o.path)
                ? 'startsAt DESC, id DESC'
                : /commute-assignments/.test(o.path)
                  ? 'effectiveFrom DESC, id DESC'
                  : /reviews/.test(o.path)
                    ? 'updatedAt DESC, id DESC'
                    : /fares/.test(o.path)
                      ? 'effectiveFrom DESC, id DESC'
                      : 'createdAt DESC, id DESC'
      : undefined,
    'x-implementation-status': 'design_only',
  };
  const samples = exampleCases.filter((s) => s.schema === o.responseSchema);
  if (samples.length && responses[status].content)
    responses[status].content['application/json'].examples = Object.fromEntries(
      samples.map((s) => [s.name, { value: s.value }]),
    );
  (spec.paths[o.path] ??= {})[o.method] = operation;
}

const overrides = {
  'POST /admin/close-subscription-periods': 'POST /v1/ops/maintenance/period-close',
  'POST /admin/convert-credits': 'POST /v1/ops/maintenance/period-close',
  'POST /admin/expire-subscriptions': 'POST /v1/ops/maintenance/period-close',
  'POST /admin/ask-dispatch': 'POST /v1/ops/maintenance/ask-dispatch',
  'POST /admin/learn-routes': 'POST /v1/ops/maintenance/route-learning',
  'POST /admin/resolve-defaults': 'POST /v1/ops/maintenance/reservation-defaults',
  'POST /admin/resolve-no-shows': 'POST /v1/ops/maintenance/no-shows',
  'POST /admin/payments/maintenance': 'POST /v1/ops/maintenance/payments',
  'POST /admin/payments/process-webhooks': 'POST /v1/ops/maintenance/payment-inbox',
  'POST /admin/payments/reconcile': 'POST /v1/ops/maintenance/payment-reconciliation',
  'POST /admin/commute-requests/{id}/decision': 'POST /v1/ops/commute-requests/{id}/decisions',
  'PATCH /admin/driver-requests/{id}': 'POST /v1/ops/driver-requests/{id}/decisions',
  'PATCH /admin/incidents/{id}': 'POST /v1/ops/incidents/{id}/decisions',
  'PATCH /admin/drivers/{id}/credentials': 'POST /v1/ops/drivers/{id}/credentials/actions',
  'PUT /admin/min-versions/{platform}': 'PUT /v1/ops/min-versions/{app}/{platform}',
  'PUT /admin/routes/{id}/fare': 'POST /v1/ops/routes/{id}/fares',
  'POST /admin/routes/{id}/stops': 'POST /v1/ops/route-patterns/{id}/versions',
  'GET /boarding/manifest': 'GET /v1/driver/trips/{id}/manifest',
  'POST /boarding/no-show': 'POST /v1/driver/trips/{id}/reservations/{reservationId}/no-show',
  'GET /me/pass': 'POST /v1/me/reservations/{id}/pass',
  'POST /me/avatar': 'PUT /v1/me/avatar',
  'GET /me/subscription': 'GET /v1/me/membership',
  'GET /me/rides': 'GET /v1/me/membership',
  'POST /me/reservations': 'POST /v1/me/reservation-decisions',
  'GET /me/trips': 'GET /v1/driver/trips',
  'GET /me/work/routes': 'GET /v1/driver/available-routes',
  'POST /payments/subscribe': 'POST /v1/me/purchases',
  'GET /routes/{id}/geometry': 'GET /v1/route-geometries/{id}',
  'GET /trips/{id}/position': 'GET /v1/trips/{id}/live',
  'POST /trips/{id}/position': 'POST /v1/driver/trips/{id}/positions',
  'POST /trips/{id}/arrive': 'POST /v1/driver/trips/{id}/arrivals',
};
for (const verb of ['scan', 'board', 'verify-code', 'verify-pin'])
  overrides[`POST /boarding/${verb}`] = 'POST /v1/driver/trips/{id}/boardings';
for (const action of ['start', 'complete', 'summary'])
  overrides[`${action === 'summary' ? 'GET' : 'POST'} /trips/{id}/${action}`] =
    `${action === 'summary' ? 'GET' : 'POST'} /v1/driver/trips/{id}/${action}`;
function mapBaseline(method, path) {
  const key = `${method.toUpperCase()} ${path}`;
  if (overrides[key]) return overrides[key];
  if (['/', '/flags', '/healthz', '/readyz', '/version', '/webhooks/paystack'].includes(path))
    return key;
  const target = path.startsWith('/admin/')
    ? path.replace('/admin/', '/v1/ops/')
    : path.startsWith('/me/work/requests')
      ? path.replace('/me/work/requests', '/v1/driver/requests')
      : path.startsWith('/me/incidents')
        ? path.replace('/me/incidents', '/v1/driver/incidents')
        : '/v1' + path;
  return `${method.toUpperCase()} ${target}`;
}
const known = new Set(operations.map((o) => `${o.method.toUpperCase()} ${o.path}`));
const inventory = [];
for (const [path, item] of Object.entries(baseline.paths))
  for (const [method, operation] of Object.entries(item)) {
    if (!['get', 'post', 'patch', 'put', 'delete', 'head', 'options'].includes(method)) continue;
    const current = `${method.toUpperCase()} ${path}`,
      target = mapBaseline(method, path);
    if (!known.has(target)) throw new Error(`Unmapped endpoint: ${current} -> ${target}`);
    inventory.push({
      current,
      target,
      decision: current === target ? 'keep stable boundary' : 'replace; remove old path',
      consumer: path.startsWith('/admin')
        ? 'ops/scripts'
        : path.startsWith('/boarding') ||
            /\/me\/(work|incidents|trips)/.test(path) ||
            /\/trips\/.+\/(start|complete|arrive|summary)/.test(path)
          ? 'driver'
          : path.startsWith('/webhooks')
            ? 'Paystack'
            : path.startsWith('/auth') ||
                ['/flags', '/me', '/me/devices', '/me/avatar'].includes(path)
              ? 'both apps'
              : path.startsWith('/health') ||
                  path.startsWith('/ready') ||
                  path === '/' ||
                  path === '/version'
                ? 'infrastructure'
                : 'rider/catalog',
      baselineResponses: Object.keys(operation.responses),
    });
  }
inventory.sort((a, b) => a.current.localeCompare(b.current));
const predecessors = new Set(inventory.map((r) => r.target));
const additions = operations.filter(
  (o) => !predecessors.has(`${o.method.toUpperCase()} ${o.path}`),
);
if (
  additions.length !== operationScope.length ||
  new Set(operationScope.map((s) => s.operationId)).size !== operationScope.length
)
  throw new Error('Every predecessor-free operation needs exactly one scope decision');
for (const o of additions) {
  const scope = operationScope.find((s) => s.operationId === o.operationId);
  if (!scope) throw new Error(`Missing operation requirement: ${o.operationId}`);
  Object.assign(spec.paths[o.path][o.method], {
    'x-delivery-stage': scope.delivery,
    'x-requirement': scope.requirement,
    'x-existing-endpoint-assessment': scope.existingEndpointAssessment,
  });
}
for (const sample of exampleCases) schemas[sample.schema].parse(sample.value);
// Ensure every reference resolves, operation ID is unique and no schema is missing.
const ids = new Set();
for (const o of operations) {
  if (ids.has(o.operationId)) throw new Error('Duplicate operation ID');
  ids.add(o.operationId);
}
function checkRefs(value) {
  if (!value || typeof value !== 'object') return;
  if (
    value.$ref &&
    !value.$ref
      .slice(2)
      .split('/')
      .reduce((v, k) => v?.[k], spec)
  )
    throw new Error(`Unresolved ${value.$ref}`);
  for (const v of Object.values(value)) checkRefs(v);
}
checkRefs(spec);
await writeArtifact(
  new URL('../stage-2-operation-scope.md', import.meta.url),
  `# Operation scope after stage-1 review\n\nGenerated from contracts/operation-scope.mjs. ${additions.length} target operations have no direct baseline mapping: ${operationScope.filter((s) => s.delivery === 'cutover').length} are required for cutover and ${operationScope.filter((s) => s.delivery === 'deferred').length} are deferred proposals. The full 132-operation OpenAPI remains a design catalog, **not** a commitment to implement every operation in stage 3. Deferred entries are marked x-delivery-stage: deferred; do not implement or generate a launch client dependency on them. No deployed endpoints change here. An entity or accounting rule remains required even when its optional history UI is deferred.\n\nFor deferred detail GETs, versioned list rows must supply the same per-resource edit token required by If-Match; collection ETags cannot substitute. Review that consumer contract during implementation.\n\n| Operation | Delivery | Requirement | Existing endpoint assessment |\n| --- | --- | --- | --- |\n${additions
    .map((o) => {
      const s = operationScope.find((s) => s.operationId === o.operationId);
      return `| \`${o.method.toUpperCase()} ${o.path}\` | ${s.delivery} | ${s.requirement} | ${s.existingEndpointAssessment} |`;
    })
    .join('\n')}\n`,
);
await writeArtifact(new URL('target.openapi.json', dir), spec);
await writeArtifact(new URL('examples.json', dir), exampleCases);
await writeArtifact(new URL('endpoint-inventory.json', dir), inventory);
const rows = inventory
  .map((r) => `| \`${r.current}\` | \`${r.target}\` | ${r.consumer} | ${r.decision} |`)
  .join('\n');
await writeArtifact(
  new URL('../stage-1-endpoints.md', import.meta.url),
  `# Stage 1: complete baseline endpoint inventory\n\nGenerated by scripts/build-contract.mjs from the locally built API OpenAPI, not staging or grep. Baseline source: 43cdae0. ${inventory.length} documented operations; ${operations.length} proposed target operations. Target-only operations appear in target.openapi.json. Identifier mappings are semantic: a route ID is not a geometry/version ID. Follow the new resource links, never substitute old IDs blindly.\n\n| Current | Replacement | Consumer | Decision |\n| --- | --- | --- | --- |\n${rows}\n\n## Infrastructure outside generated business OpenAPI\n\n- GET /metrics: retain separate operational endpoint with metrics authentication; never expose in mobile client.\n- GET /docs/json and Swagger UI/static asset routes under /docs: retain documentation service; publish only the target spec after cutover.\n- Automatically generated HEAD routes and CORS OPTIONS follow their GET/resource registration; not separate business operations.\n- Public bootstrap GET /flags remains stable and unversioned. Its redesigned shape is a deliberate prelaunch replacement; future evolution is additive with old-client parsing tests.\n- No legacy alias survives cutover. Health/version payload changes must update deployment probes/consumers as part of the release.\n`,
);
console.log(
  `Validated and emitted ${inventory.length} baseline mappings, ${operations.length} target operations, ${Object.keys(converted).length} named schemas and ${exampleCases.length} examples.`,
);
