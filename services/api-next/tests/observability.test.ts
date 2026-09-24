import assert from 'node:assert/strict';
import test from 'node:test';
import { Writable } from 'node:stream';
import Fastify from 'fastify';
import { loggerOptions } from '../src/observability/logging.js';
import { batchFailed } from '../src/observability/metrics.js';
import { startTelemetry } from '../src/observability/telemetry.js';

test('OBS-01 no collector configured means no telemetry, not an error', () => {
  assert.equal(startTelemetry({}), false);
});

test('OBS-02 a job only succeeded if nothing inside it failed', () => {
  const clean = { data: { considered: 3, succeeded: 3, blocked: 0, failed: 0, failures: [] } };
  assert.equal(batchFailed(200, clean), false);
  // A 200 means the batch ran, not that every item in it did.
  assert.equal(batchFailed(200, { data: { ...clean.data, failed: 1 } }), true);
  assert.equal(
    batchFailed(200, { data: { ...clean.data, failures: [{ resourceId: 'x', reason: 'y' }] } }),
    true,
  );
  // The combined payments job nests its three batches.
  assert.equal(
    batchFailed(200, {
      data: {
        inbox: clean.data,
        reconciliation: clean.data,
        periods: { ...clean.data, failed: 2 },
      },
    }),
    true,
  );
  assert.equal(batchFailed(500, clean), true, 'a refused run failed');
  assert.equal(batchFailed(403, null), true);
});

test('OBS-03 request logs keep the path and never the search, the token or a PIN', async () => {
  let written = '';
  const sink = new Writable({
    write(chunk, _encoding, done) {
      written += chunk.toString();
      done();
    },
  });
  const app = Fastify({ logger: loggerOptions(sink) });
  app.post('/v1/auth/driver', async () => ({ ok: true }));
  app.get('/v1/ops/riders', async () => ({ data: [] }));
  await app.inject({
    method: 'GET',
    url: '/v1/ops/riders?q=ama%40example.com',
    headers: { authorization: 'Bearer live-session-token', 'idempotency-key': 'key-123' },
  });
  await app.inject({
    method: 'POST',
    url: '/v1/auth/driver',
    payload: { code: 'DR-7Q4M', pin: '918273', ownDevice: false },
  });
  await app.close();

  assert.match(written, /"path":"\/v1\/ops\/riders"/, 'the route is logged');
  for (const secret of [
    'ama%40',
    'example.com',
    'live-session-token',
    'key-123',
    '918273',
    'DR-7Q4M',
  ])
    assert.equal(written.includes(secret), false, `${secret} reached the log`);
});
