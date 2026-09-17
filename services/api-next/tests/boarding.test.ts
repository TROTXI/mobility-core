import { test } from 'node:test';
import assert from 'node:assert/strict';
import type { Pool } from 'pg';
import { createReplacementApp } from '../src/http/replacement.js';

const options = () => ({
  pool: {
    connect: () => {
      throw new Error('Preflight must not touch the database');
    },
  } as unknown as Pool,
  cursorSecret: Buffer.alloc(32, 1),
  credentialReplayKey: Buffer.alloc(32, 2),
  coordinateReservations: async () => {
    throw new Error('No fake booking coordinator');
  },
  minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
  identity: {
    access: {
      secret: Buffer.alloc(32, 3),
      issuer: 'boarding-unit',
      audience: 'boarding-unit-access',
      ttlSeconds: 900,
    },
    pinSecret: 'p'.repeat(32),
    providerEncryptionKey: Buffer.alloc(32, 4),
    refreshTtlDays: 30,
    shiftTtlHours: 12,
  },
  boarding: { proofKey: Buffer.alloc(32, 5), avatarUrl: async () => null },
});
test('BRD-U01: composed boarding key cannot reuse access, PIN, cursor, replay or provider encryption secrets', () => {
  const config = options();
  for (const proofKey of [
    config.identity.access.secret,
    Buffer.from(config.identity.pinSecret),
    config.cursorSecret,
    config.credentialReplayKey,
    config.identity.providerEncryptionKey,
  ])
    assert.throws(
      () => createReplacementApp({ ...config, boarding: { ...config.boarding, proofKey } }),
      /Boarding proof key must be separate/,
    );
  assert.throws(
    () =>
      createReplacementApp({
        ...config,
        boarding: { ...config.boarding, proofKey: Buffer.alloc(8) },
      }),
    /Dedicated 32-byte boarding proof key/,
  );
});
test('BRD-U02: missing proof configuration does not expose boarding; real composition keeps authentication mandatory', async () => {
  const config = options(),
    unconfigured = await createReplacementApp({ ...config, boarding: undefined }),
    configured = await createReplacementApp(config);
  try {
    const url = '/v1/me/reservations/00000000-0000-0000-0000-000000000001/pass';
    assert.equal((await unconfigured.inject({ method: 'POST', url })).statusCode, 404);
    assert.equal((await configured.inject({ method: 'POST', url })).statusCode, 401);
  } finally {
    await unconfigured.close();
    await configured.close();
  }
});
