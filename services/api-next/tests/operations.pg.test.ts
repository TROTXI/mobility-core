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
  assert.equal((await f.get('/v1/ops/audit-events?area=payments')).statusCode, 200);
  assert.equal((await f.get('/v1/ops/audit-events?actorId=not-a-uuid')).statusCode, 400);
  assert.equal((await f.get('/v1/ops/audit-events?fromDate=0000-01-01')).statusCode, 400);
  assert.equal(
    (await f.get('/v1/ops/audit-events?fromDate=2026-12-31&toDate=2026-01-01')).statusCode,
    400,
  );
  await f.owner.query(
    "INSERT INTO app.admin_passkey_events(user_id,actor_user_id,action) VALUES ($1,$1,'verified'),($1,$1,'registered')",
    [f.adminId],
  );
  const first = await f.get('/v1/ops/audit-events?area=security&limit=1');
  assert.equal(first.statusCode, 200, first.body);
  const cursor = first.json().page.nextCursor as string;
  assert.ok(cursor);
  assert.equal(
    (
      await f.get(
        `/v1/ops/audit-events?area=security&action=verified&cursor=${encodeURIComponent(cursor)}`,
      )
    ).statusCode,
    400,
  );
  const byActor = await f.get(
    `/v1/ops/audit-events?area=security&actorId=${f.adminId}&targetId=${f.adminId}`,
  );
  assert.equal(byActor.statusCode, 200, byActor.body);
  assert.equal(byActor.json().data.length, 2);
  assert.deepEqual(
    (await f.get('/v1/ops/audit-events?area=security&fromDate=2020-01-01&toDate=2020-01-31')).json()
      .data,
    [],
  );
  assert.equal(
    (await f.get('/v1/ops/reports/summary?fromDate=2026-12-31&toDate=2026-01-01')).statusCode,
    400,
  );
  assert.equal((await f.get('/v1/ops/riders/not-a-uuid')).statusCode, 404);
});

test('OPS-READ-05 payment decisions and refund intents are visible without receipt payloads', async (t) => {
  const f = await fixture(t);
  const purchase = await f.buy();
  const event = (
    await f.owner.query(
      "INSERT INTO app.payment_events(environment,source,payload_hash,ciphertext) VALUES ('test','verify',repeat('a',64),decode(repeat('ab',29),'hex')) RETURNING id",
    )
  ).rows[0].id as string;
  const review = (
    await f.owner.query(
      "INSERT INTO app.payment_reviews(purchase_id,kind,reason,amount_pesewas,event_id) VALUES ($1,'manual_review','late_success',0,$2) RETURNING id",
      [purchase.id, event],
    )
  ).rows[0].id as string;
  const secretResponse = { privateProviderPayload: 'must-not-appear' };
  await f.owner.query(
    "INSERT INTO app.payment_review_commands(actor_user_id,review_id,key_hash,input_hash,decision,reason,response_body) VALUES ($1,$2,repeat('c',64),repeat('d',64),'resolved','Verified with provider',$3)",
    [f.adminId, review, secretResponse],
  );
  await f.owner.query(
    "UPDATE app.payment_attempts SET state='successful',provider_transaction_id='12345',paid_at=clock_timestamp() WHERE id=$1",
    [purchase.attempt.id],
  );
  const collection = (
    await f.owner.query(
      "INSERT INTO app.payment_collections(attempt_id,purchase_id,user_id,environment,provider_transaction_id,amount_pesewas,currency,paid_at,event_id) VALUES ($1,$2,$3,'test','12345',$4,'GHS',clock_timestamp(),$5) RETURNING id",
      [purchase.attempt.id, purchase.id, f.actor.userId, purchase.cashDuePesewas, event],
    )
  ).rows[0].id as string;
  await f.owner.query(
    "INSERT INTO app.refund_initiations(purchase_id,collection_id,actor_user_id,amount_pesewas,reason,key_hash,input_hash) VALUES ($1,$2,$3,100,'Duplicate test payment',repeat('e',64),repeat('f',64))",
    [purchase.id, collection, f.adminId],
  );
  const response = await f.get(
    `/v1/ops/audit-events?area=payments&actorId=${f.adminId}&action=resolvePaymentReview%3Aresolved&targetId=${review}`,
  );
  assert.equal(response.statusCode, 200, response.body);
  assert.equal(response.json().data.length, 1);
  assert.equal(response.json().data[0].reason, 'Verified with provider');
  assert.equal(response.body.includes('must-not-appear'), false);
  const refunds = await f.get(
    `/v1/ops/audit-events?area=payments&action=initiateRefund&targetId=${purchase.id}`,
  );
  assert.equal(refunds.statusCode, 200, refunds.body);
  assert.equal(refunds.json().data[0].reason, 'Duplicate test payment');
  assert.deepEqual(
    (await f.get(`/v1/ops/audit-events?area=payments&targetId=${f.actor.userId}`)).json().data,
    [],
  );
});

test('OPS-READ-06 role changes retain the actor, target, reason and action in Audit', async (t) => {
  const f = await fixture(t);
  const command = (
    await f.owner.query(
      "INSERT INTO app.config_commands(actor_user_id,operation,target,key_hash,input_hash,response_body) VALUES ($1,'changeRole',$2,repeat('1',64),repeat('2',64),'{}') RETURNING id",
      [f.adminId, f.actor.userId],
    )
  ).rows[0].id as string;
  await f.owner.query(
    "INSERT INTO app.config_events(command_id,actor_user_id,action,target,reason,before_state,after_state) VALUES ($1,$2,'changeRole',$3,'Pilot account administration',$4,$5)",
    [command, f.adminId, f.actor.userId, { role: 'commuter' }, { role: 'admin' }],
  );
  const response = await f.get(
    `/v1/ops/audit-events?area=configuration&actorId=${f.adminId}&action=changeRole&targetId=${f.actor.userId}`,
  );
  assert.equal(response.statusCode, 200, response.body);
  assert.deepEqual(
    response
      .json()
      .data.map((row: { actorId: string; targetId: string; reason: string }) => [
        row.actorId,
        row.targetId,
        row.reason,
      ]),
    [[f.adminId, f.actor.userId, 'Pilot account administration']],
  );
});

test('OPS-READ-07 trip reassignment and configuration changes are traceable by operator', async (t) => {
  const f = await fixture(t);
  const trip = (
    await f.owner.query(
      `INSERT INTO app.trips(schedule_id,pattern_version_id,departure_id,service_date,scheduled_at,status)
       SELECT id,pattern_version_id,departure_id,current_date,clock_timestamp(),'scheduled'
       FROM app.service_schedules WHERE id=$1 RETURNING id`,
      [f.input.legs[0]!.scheduleId],
    )
  ).rows[0].id as string;
  await f.owner.query(
    `INSERT INTO app.trip_events(trip_id,actor_user_id,operation,reason,before_state,after_state)
     VALUES ($1,$2,'assign','Pilot reassignment',$3,$4)`,
    [trip, f.adminId, { driverId: null }, { driverId: f.actor.userId }],
  );
  const command = (
    await f.owner.query(
      `INSERT INTO app.config_commands(actor_user_id,operation,target,key_hash,input_hash,response_body)
       VALUES ($1,'setFlag','pilot_feature',repeat('3',64),repeat('4',64),'{}') RETURNING id`,
      [f.adminId],
    )
  ).rows[0].id as string;
  await f.owner.query(
    `INSERT INTO app.config_events(command_id,actor_user_id,action,target,before_state,after_state)
     VALUES ($1,$2,'setFlag','pilot_feature',$3,$4)`,
    [command, f.adminId, { enabled: false }, { enabled: true }],
  );
  for (const [area, action, targetId] of [
    ['trip', 'assign', trip],
    ['configuration', 'setFlag', 'pilot_feature'],
  ]) {
    const response = await f.get(
      `/v1/ops/audit-events?area=${area}&action=${action}&actorId=${f.adminId}&targetId=${targetId}`,
    );
    assert.equal(response.statusCode, 200, response.body);
    assert.equal(response.json().data.length, 1);
    assert.equal(response.json().data[0].actorId, f.adminId);
  }
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

test('OPS-READ-04 reports a processed refund in its processing window', async (t) => {
  const f = await fixture(t);
  const purchase = await f.buy();
  const event = (
    await f.owner.query(
      `INSERT INTO app.payment_events
       (environment,source,payload_hash,ciphertext,state,processed_at)
       VALUES ('test','webhook',repeat('a',64),decode(repeat('aa',29),'hex'),
         'processed',clock_timestamp()) RETURNING id`,
    )
  ).rows[0].id;
  await f.owner.query(
    `INSERT INTO app.payment_refunds
     (attempt_id,purchase_id,user_id,environment,provider_reference,amount_pesewas,
      state,event_id,created_at,updated_at)
     VALUES ($1,$2,$3,'test','report-refund',100,'processed',$4,
       '2026-01-31T12:00:00Z','2026-02-02T12:00:00Z')`,
    [purchase.attempt.id, purchase.id, f.actor.userId, event],
  );
  const amount = async (from: string, to: string) => {
    const response = await f.get(`/v1/ops/reports/summary?fromDate=${from}&toDate=${to}`);
    assert.equal(response.statusCode, 200, response.body);
    return response.json().data.payments.refunded.amountMinor;
  };
  assert.equal(await amount('2026-01-01', '2026-01-31'), 0);
  assert.equal(await amount('2026-02-01', '2026-02-28'), 100);
});
