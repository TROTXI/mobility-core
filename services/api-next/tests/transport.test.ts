import { test } from 'node:test';
import assert from 'node:assert/strict';
import { Pool } from 'pg';
import { canonical, tripEditToken } from '../src/transport/service.js';
import { cursorCodec } from '../src/transport/cursor.js';
import { createTransportApp } from '../src/http/app.js';
import type { AppOptions } from '../src/http/app.js';
import { TransportError } from '../src/transport/errors.js';

const rejectBookingChanges = async () => {
  throw new Error('This pure-test adapter must never perform booking work');
};

test('application refuses an absent or non-callable coordinator before startup or database work', async () => {
  const pool = new Pool();
  try {
    for (const coordinateReservations of [undefined, null, false, {}]) {
      await assert.rejects(
        createTransportApp({
          pool,
          cursorSecret: Buffer.alloc(32, 9),
          verifyAccess: async () => {
            throw new Error('must not verify access');
          },
          authorizeSession: async () => {
            throw new Error('must not query session');
          },
          minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 } },
          // Deliberately bypass TS as a JS/misconfigured bootstrap caller could.
          coordinateReservations,
        } as AppOptions),
        /^Error: Transactional reservation coordinator required before application startup$/,
      );
    }
    assert.equal(pool.totalCount, 0);
  } finally {
    await pool.end();
  }
});

test('command normalization is property-order independent but distinguishes changed input', () => {
  assert.equal(
    canonical({ b: [2, 1], a: { z: false, x: null } }),
    canonical({ a: { x: null, z: false }, b: [2, 1] }),
  );
  assert.notEqual(canonical({ a: 1 }), canonical({ a: 2 }));
  assert.notEqual(tripEditToken({ id: 'a', version: 1 }), tripEditToken({ id: 'b', version: 1 }));
});
test('cursor fits the contract, preserves PostgreSQL microseconds, and binds owner/filter and expiry', () => {
  const codec = cursorCodec(Buffer.alloc(32, 4)),
    now = new Date('2026-09-15T12:00:00Z');
  const id = '11111111-1111-4111-8111-111111111111',
    time = '2026-09-15T06:30:00.123456Z';
  const token = codec.encode(time, id, 'caller-1:route-a', now);
  assert.ok(token.length <= 128);
  assert.deepEqual(codec.decode(token, 'caller-1:route-a', now), { time, id });
  const invalid = (fn: () => unknown) =>
    assert.throws(fn, (e: unknown) => e instanceof TransportError && e.code === 'invalid_cursor');
  invalid(() => codec.decode(token, 'caller-2:route-a', now));
  invalid(() => codec.decode(token, 'caller-1:route-b', now));
  invalid(() => codec.decode(token, 'caller-1:route-a', new Date(now.getTime() + 86400000)));
  invalid(() => codec.decode(token.slice(0, -3) + 'abc', 'caller-1:route-a', now));
  invalid(() => codec.decode('bad', 'caller-1:route-a', now));
});
test('HTTP factory compiles reviewed schemas and has no unauthenticated or guessed-header fallback', async () => {
  const pool = new Pool();
  const app = await createTransportApp({
    pool,
    coordinateReservations: rejectBookingChanges,
    cursorSecret: Buffer.alloc(32, 9),
    verifyAccess: async () => null,
    authorizeSession: async () => {
      throw new Error('must not query a session without verified access');
    },
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 } },
  });
  try {
    await app.ready();
    const response = await app.inject({
      method: 'GET',
      url: '/v1/driver/trips',
      headers: { 'x-user-id': 'spoofed', 'x-user-role': 'admin' },
    });
    assert.equal(response.statusCode, 401);
    assert.equal(response.json().error.code, 'unauthenticated');
    assert.equal(response.headers['cache-control'], 'no-store');
  } finally {
    await app.close();
    await pool.end();
  }
});

test('IP admission runs before verification and forged forwarded headers cannot evade it', async () => {
  const pool = new Pool();
  let verified = 0;
  const app = await createTransportApp({
    pool,
    coordinateReservations: rejectBookingChanges,
    cursorSecret: Buffer.alloc(32, 9),
    requestsPerIpPerMinute: 1,
    verifyAccess: async () => {
      verified++;
      return null;
    },
    authorizeSession: async () => {
      throw new Error('must not access the database');
    },
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 } },
  });
  try {
    const first = await app.inject({
      method: 'GET',
      url: '/v1/driver/trips',
      headers: { authorization: 'Bearer invalid-one' },
    });
    assert.equal(first.statusCode, 401);
    const second = await app.inject({
      method: 'GET',
      url: '/v1/ops/trips',
      headers: { authorization: 'Bearer invalid-two', 'x-forwarded-for': '192.0.2.3' },
    });
    assert.equal(second.statusCode, 429);
    assert.equal(second.json().error.code, 'rate_limited');
    assert.ok(Number(second.headers['retry-after']) > 0);
    assert.equal(verified, 1);
  } finally {
    await app.close();
    await pool.end();
  }
});
