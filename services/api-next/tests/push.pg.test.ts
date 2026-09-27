import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { setup } from './helpers/financial-fixture.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { MembershipService } from '../src/membership/service.js';
import { TransportService } from '../src/transport/service.js';
import { AccountService } from '../src/account/service.js';
import { PushNotifications } from '../src/notifications/push.js';
import { PushSendError } from '../src/notifications/fcm.js';
import type { PushSender } from '../src/notifications/fcm.js';

async function driverFixture(t: Parameters<typeof setup>[0], sender: PushSender) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const transport = new TransportService({ ...f.dependencies, cursorSecret: Buffer.alloc(32, 9) });
  await transport.generateTrips(
    { userId: f.adminId, sessionId: f.adminId },
    { serviceDate: new Date(Date.now() + 86400000).toISOString().slice(0, 10) },
  );
  const trip = (await f.owner.query('SELECT id FROM app.trips LIMIT 1')).rows[0].id;
  const user = (
    await f.owner.query(
      "INSERT INTO app.users(role,display_name) VALUES ('driver','Test driver') RETURNING id",
    )
  ).rows[0].id;
  const driver = (
    await f.owner.query(
      "INSERT INTO app.drivers(user_id,name) VALUES ($1,'Test driver') RETURNING id",
      [user],
    )
  ).rows[0].id;
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [user]);
  await f.owner.query(
    "INSERT INTO app.auth_sessions(user_id,expires_at) VALUES ($1,clock_timestamp()+interval '1 hour')",
    [user],
  );
  const account = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: Buffer.alloc(32, 2),
  });
  const device = await account.handle(
    { userId: user, sessionId: user },
    'registerDevice',
    { platform: 'android', token: 'driver-token' },
    undefined,
    randomUUID(),
  );
  const insertEvent = async (operation = 'assign') =>
    (
      await f.owner.query(
        `INSERT INTO app.trip_events(trip_id,actor_user_id,operation,before_state,after_state)
     VALUES ($1,$2,$3,$4,$5) RETURNING id`,
        [
          trip,
          f.adminId,
          operation,
          { assignedDriverId: driver, version: 1 },
          { assignedDriverId: driver, version: 2 },
        ],
      )
    ).rows[0].id;
  return {
    ...f,
    account,
    user,
    driver,
    trip,
    insertEvent,
    deviceId: (device.body as any).data.id,
    push: new PushNotifications({ pool: f.runtime, deviceKey: Buffer.alloc(32, 2), sender }),
  };
}

test('driver assignment, reschedule and cancellation alerts are bounded and deduplicated across workers', async (t) => {
  const sent: string[] = [];
  const f = await driverFixture(t, {
    send: async (token, id, _, kind) => {
      assert.equal(token, 'driver-token');
      assert.equal(kind, 'driver_assignment');
      sent.push(id);
      return 'accepted';
    },
  });
  for (const operation of ['assign', 'reschedule', 'cancel']) await f.insertEvent(operation);
  await Promise.all([f.push.drain(), f.push.drain()]);
  await f.push.drain();
  assert.equal(sent.length, 3);
  assert.equal(new Set(sent).size, 3);
  assert.equal(
    (
      await f.owner.query(
        "SELECT count(*)::integer n FROM app.push_deliveries WHERE state='accepted' AND trip_event_id IS NOT NULL",
      )
    ).rows[0].n,
    3,
  );
});

test('driver alert retries recheck device ownership and session revocation', async (t) => {
  let sends = 0;
  const f = await driverFixture(t, {
    send: async () => {
      sends++;
      throw new PushSendError(true);
    },
  });
  await f.insertEvent();
  await f.push.drain();
  assert.equal(sends, 1);
  await f.account.handle(
    f.other,
    'registerDevice',
    { platform: 'android', token: 'driver-token' },
    undefined,
    randomUUID(),
  );
  await f.owner.query(
    "UPDATE app.push_deliveries SET next_attempt_at=clock_timestamp()-interval '1 second'",
  );
  assert.equal((await f.push.drain()).cancelled, 1);
  assert.equal(sends, 1);
  await f.account.handle(
    { userId: f.user, sessionId: f.user },
    'registerDevice',
    { platform: 'android', token: 'new-driver-token' },
    undefined,
    randomUUID(),
  );
  await f.owner.query(
    'UPDATE app.auth_sessions SET revoked_at=clock_timestamp() WHERE user_id=$1',
    [f.user],
  );
  await f.insertEvent('cancel');
  await f.push.drain();
  assert.equal(sends, 1);
});

test('rolled-back driver events do not send alerts', async (t) => {
  let sends = 0;
  const f = await driverFixture(t, {
    send: async () => {
      sends++;
      return 'accepted';
    },
  });
  const c = await f.owner.connect();
  try {
    await c.query('BEGIN');
    await c.query(
      `INSERT INTO app.trip_events(trip_id,actor_user_id,operation,before_state,after_state)
      VALUES ($1,$2,'assign','{}',$3)`,
      [f.trip, f.adminId, { assignedDriverId: f.driver }],
    );
    await c.query('ROLLBACK');
  } finally {
    c.release();
  }
  await f.push.drain();
  assert.equal(sends, 0);
});

async function fixture(t: Parameters<typeof setup>[0], sender: PushSender) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const admin = { userId: f.adminId, sessionId: f.adminId };
  const membership = new MembershipService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 9),
  });
  const financial = new FinancialFoundation({
    ...f.dependencies,
    assertCheckoutAllowed: membership.assertCheckoutAllowed,
    assertPeriodCanClose: membership.assertPeriodCanClose,
    materializeAssignment: membership.materializeAssignment,
  });
  const now = new Date(),
    day = new Date(Date.now() + 86400000).toISOString().slice(0, 10);
  const purchase = await financial.checkout(f.actor, f.input, randomUUID(), now);
  await financial.fulfill(f.settle(purchase, now));
  const transport = new TransportService({ ...f.dependencies, cursorSecret: Buffer.alloc(32, 9) });
  await transport.generateTrips(admin, { serviceDate: day });
  const asked = await membership.maintenance(admin, 'runAskDispatch', {
    travelDate: day,
    direction: 'outbound',
  });
  assert.equal((asked.body as any).data.succeeded, 1, JSON.stringify(asked.body));
  const reservation = (
    await f.owner.query('SELECT id FROM app.reservations WHERE user_id=$1', [f.actor.userId])
  ).rows[0].id;
  const account = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: Buffer.alloc(32, 2),
  });
  const device = await account.handle(
    f.actor,
    'registerDevice',
    { platform: 'android', token: 'test-token' },
    undefined,
    randomUUID(),
  );
  const push = new PushNotifications({ pool: f.runtime, deviceKey: Buffer.alloc(32, 2), sender });
  return {
    ...f,
    account,
    push,
    membership,
    day,
    reservation,
    deviceId: (device.body as any).data.id,
  };
}
test('PUSH-01 durable prompt sends once per registered device and concurrent workers do not double-send', async (t) => {
  const sent: string[] = [];
  const f = await fixture(t, {
    send: async (token, id) => {
      assert.equal(token, 'test-token');
      sent.push(id);
      return 'projects/test/messages/1';
    },
  });
  await Promise.all([f.push.drain(), f.push.drain()]);
  await f.push.drain();
  assert.equal(sent.length, 1);
  assert.equal(
    (await f.owner.query('SELECT state FROM app.push_deliveries')).rows[0].state,
    'accepted',
  );
});
test('PUSH-02 retry uses stable notification identity; only explicit unregistered tokens are revoked', async (t) => {
  const ids: string[] = [];
  let attempt = 0;
  const f = await fixture(t, {
    send: async (_, id) => {
      ids.push(id);
      if (++attempt === 1) throw new PushSendError(true);
      throw new PushSendError(false, true);
    },
  });
  assert.equal((await f.push.drain()).retried, 1);
  await f.owner.query(
    "UPDATE app.push_deliveries SET next_attempt_at=clock_timestamp()-interval '1 second'",
  );
  assert.equal((await f.push.drain()).failed, 1);
  assert.equal(ids[0], ids[1]);
  const device = (await f.owner.query('SELECT * FROM app.push_devices WHERE id=$1', [f.deviceId]))
    .rows[0];
  assert.equal(device.token_ciphertext, null);
  assert.ok(device.revoked_at);
});
test('PUSH-03 transferred device and decided reservation cancel queued prompts', async (t) => {
  let calls = 0;
  const f = await fixture(t, {
    send: async () => {
      calls++;
      throw new PushSendError(true);
    },
  });
  await f.push.drain();
  await f.account.handle(
    f.other,
    'registerDevice',
    { platform: 'android', token: 'test-token' },
    undefined,
    randomUUID(),
  );
  await f.owner.query(
    "UPDATE app.push_deliveries SET next_attempt_at=clock_timestamp()-interval '1 second'",
  );
  assert.equal((await f.push.drain()).cancelled, 1);
  assert.equal(calls, 1);
  await f.account.handle(
    f.actor,
    'registerDevice',
    { platform: 'android', token: 'another-device' },
    undefined,
    randomUUID(),
  );
  await f.membership.command(
    f.actor,
    'decideReservation',
    undefined,
    { travelDate: f.day, direction: 'outbound', decision: 'decline' },
    randomUUID(),
  );
  await f.push.drain();
  assert.equal(calls, 1);
});
test('PUSH-04 erasure cancels queued delivery and retries stop after five provider failures', async (t) => {
  let calls = 0;
  const f = await fixture(t, {
    send: async () => {
      calls++;
      throw new PushSendError(true);
    },
  });
  for (let i = 0; i < 5; i++) {
    await f.push.drain();
    await f.owner.query(
      "UPDATE app.push_deliveries SET next_attempt_at=clock_timestamp()-interval '1 second' WHERE state='pending'",
    );
  }
  await f.push.drain();
  assert.equal(calls, 5);
  assert.equal(
    (await f.owner.query('SELECT state FROM app.push_deliveries')).rows[0].state,
    'failed',
  );
  await f.account.handle(
    f.actor,
    'registerDevice',
    { platform: 'android', token: 'erase-device' },
    undefined,
    randomUUID(),
  );
  await f.push.drain();
  await f.account.handle(f.actor, 'eraseAccount', {}, undefined, randomUUID());
  await f.owner.query(
    "UPDATE app.push_deliveries SET next_attempt_at=clock_timestamp()-interval '1 second' WHERE state='pending'",
  );
  const before = calls;
  assert.equal((await f.push.drain()).cancelled, 1);
  assert.equal(calls, before);
});
