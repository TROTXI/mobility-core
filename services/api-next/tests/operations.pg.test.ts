import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { setup } from './helpers/financial-fixture.js';
import { createTransportApp } from '../src/http/app.js';
import { TransportError } from '../src/transport/errors.js';

async function fixture(t: TestContext) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  await f.owner.query(
    "UPDATE app.users SET display_name='Pilot Operator',email='ops@example.com' WHERE id=$1",
    [f.adminId],
  );
  const actor = { userId: f.adminId, sessionId: f.adminId };
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 29),
    authorizeSession: f.dependencies.authorizeSession,
    verifyAccess: async (header) => (header === 'Bearer ops' ? actor : null),
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
    coordinateReservations: async () => {
      throw new TransportError(503, 'unavailable', 'Not wired in this read-only slice.');
    },
  });
  t.after(() => app.close());
  const get = (url: string) =>
    app.inject({
      method: 'GET',
      url,
      headers: { authorization: 'Bearer ops', 'x-trotxi-client': 'ops', 'x-trotxi-build': '9' },
    });
  return { ...f, get };
}

test('OPS-READ-01 operator, rider, delivery, audit and report reads compile against the reviewed schema', async (t) => {
  const f = await fixture(t);
  await f.owner.query(
    `INSERT INTO app.admin_passkey_events(user_id,actor_user_id,action)
     VALUES ($1,$1,'verified')`,
    [f.adminId],
  );
  await f.owner.query(
    `INSERT INTO app.account_restrictions(user_id,actor_user_id,reason,review_at)
     VALUES ($1,$2,'Support review',clock_timestamp()+interval '7 days')`,
    [f.actor.userId, f.adminId],
  );

  const operators = await f.get('/v1/ops/operators');
  assert.equal(operators.statusCode, 200, operators.body);
  assert.equal(operators.json().data[0].displayName, 'Pilot Operator');

  const rider = await f.get(`/v1/ops/riders/${f.actor.userId}`);
  assert.equal(rider.statusCode, 200, rider.body);
  assert.equal(rider.json().data.restrictions.length, 1);
  assert.equal(rider.json().data.restrictions[0].active, true);

  const deliveries = await f.get('/v1/ops/deliveries?channel=email');
  assert.equal(deliveries.statusCode, 200, deliveries.body);
  assert.deepEqual(deliveries.json().data, []);

  const audit = await f.get('/v1/ops/audit-events?area=security');
  assert.equal(audit.statusCode, 200, audit.body);
  assert.equal(audit.json().data[0].action, 'verified');

  const report = await f.get('/v1/ops/reports/summary?fromDate=2026-01-01&toDate=2026-12-31');
  assert.equal(report.statusCode, 200, report.body);
  assert.equal(report.json().data.riders.restricted, 1);
  assert.deepEqual(report.json().data.payments.collected, { amountMinor: 0, currency: 'GHS' });
});

test('OPS-READ-02 filters are validated and cursors are bound to them', async (t) => {
  const f = await fixture(t);
  assert.equal((await f.get('/v1/ops/deliveries?channel=sms')).statusCode, 400);
  assert.equal((await f.get('/v1/ops/audit-events?area=payments')).statusCode, 400);
  assert.equal(
    (await f.get('/v1/ops/reports/summary?fromDate=2026-12-31&toDate=2026-01-01')).statusCode,
    400,
  );
  assert.equal((await f.get('/v1/ops/riders/not-a-uuid')).statusCode, 404);
});

test('OPS-READ-03 operator counts exclude revoked credentials and sessions', async (t) => {
  const f = await fixture(t);
  for (const [index, revoked] of [false, false, true].entries()) {
    await f.owner.query(
      `INSERT INTO app.admin_passkeys
       (user_id,credential_id,public_key,device_type,backed_up,created_at,last_used_at,revoked_at)
       VALUES ($1,$2,decode(repeat('aa',32),'hex'),'singleDevice',false,
         clock_timestamp()-interval '2 days',
         clock_timestamp()-$3::interval,
         CASE WHEN $4 THEN clock_timestamp() ELSE NULL END)`,
      [f.adminId, `credential-test-${index}`, `${revoked ? 1 : 2} days`, revoked],
    );
  }
  await f.owner.query(
    `INSERT INTO app.auth_sessions(user_id,created_at,expires_at,revoked_at)
     VALUES ($1,clock_timestamp(),clock_timestamp()+interval '1 day',NULL),
            ($1,clock_timestamp(),clock_timestamp()+interval '1 day',clock_timestamp()),
            ($1,clock_timestamp()-interval '1 day',clock_timestamp()-interval '1 minute',NULL)`,
    [f.adminId],
  );
  const response = await f.get('/v1/ops/operators');
  assert.equal(response.statusCode, 200, response.body);
  const admin = response.json().data.find((row: { id: string }) => row.id === f.adminId);
  assert.equal(admin.passkeyCount, 2);
  assert.equal(admin.activeSessions, 1);
  assert.ok(admin.lastPasskeyUsedAt);
  assert.ok(Date.parse(admin.lastPasskeyUsedAt) < Date.now() - 24 * 3600_000);
});
