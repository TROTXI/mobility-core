import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { setTimeout as delay } from 'node:timers/promises';
import pg from 'pg';
import { setup } from './helpers/financial-fixture.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { MembershipService } from '../src/membership/service.js';
import { TransportService } from '../src/transport/service.js';
import { AccountService } from '../src/account/service.js';
import { PushNotifications } from '../src/notifications/push.js';
import { PushSendError } from '../src/notifications/fcm.js';
import type { PushSender } from '../src/notifications/fcm.js';

function deferred() {
  let resolve!: () => void;
  const promise = new Promise<void>((done) => {
    resolve = done;
  });
  return { promise, resolve };
}

async function addDriverRecipient(f: Awaited<ReturnType<typeof driverFixture>>, token: string) {
  const user = (await f.owner.query("INSERT INTO app.users(role) VALUES ('driver') RETURNING id"))
    .rows[0].id;
  const driver = (
    await f.owner.query("INSERT INTO app.drivers(user_id,name) VALUES ($1,'Test') RETURNING id", [
      user,
    ])
  ).rows[0].id;
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [user]);
  await f.owner.query(
    "INSERT INTO app.auth_sessions(user_id,expires_at) VALUES ($1,clock_timestamp()+interval '1 hour')",
    [user],
  );
  await f.account.handle(
    { userId: user, sessionId: user },
    'registerDevice',
    { platform: 'android', token },
    undefined,
    randomUUID(),
  );
  return driver;
}

async function driverEvent(
  f: Awaited<ReturnType<typeof driverFixture>>,
  driver: string,
  version = 1,
) {
  await f.owner.query(
    `INSERT INTO app.trip_events(trip_id,actor_user_id,operation,before_state,after_state)
    VALUES ($1,$2,'assign',$3,$4)`,
    [
      f.trip,
      f.adminId,
      { assignedDriverId: driver, version },
      { assignedDriverId: driver, version: version + 1 },
    ],
  );
}

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

test('PUSH-05 fanout overlaps at most four accounts, keeps each account serial and honors the batch limit', async (t) => {
  const gate = deferred();
  const firstBatch = deferred();
  const active = new Set<string>();
  const sent: string[] = [];
  let peak = 0;
  const f = await driverFixture(t, {
    send: async (token, id) => {
      assert.ok(!active.has(token), 'one account must not send concurrently with itself');
      active.add(token);
      peak = Math.max(peak, active.size);
      if (active.size === 4) firstBatch.resolve();
      await gate.promise;
      sent.push(id);
      active.delete(token);
      return `accepted-${id}`;
    },
  });
  const drivers = [f.driver];
  for (let i = 1; i < 9; i++) {
    drivers.push(await addDriverRecipient(f, `driver-${i}`));
  }
  // Two events per account exercise same-owner serialization as well as fanout.
  for (const driver of drivers) {
    for (const version of [1, 2]) await driverEvent(f, driver, version);
  }
  const draining = f.push.drain(12);
  const deadline = new AbortController();
  try {
    await Promise.race([
      firstBatch.promise,
      delay(5000, null, { signal: deadline.signal }).then(() =>
        assert.fail('fanout remained serial'),
      ),
    ]);
    assert.equal(peak, 4);
  } finally {
    deadline.abort();
    gate.resolve();
    await draining;
  }
  assert.deepEqual(await draining, {
    considered: 12,
    accepted: 12,
    cancelled: 0,
    failed: 0,
    retried: 0,
  });
  await Promise.all([f.push.drain(), f.push.drain()]);
  await f.push.drain();
  assert.equal(sent.length, 18);
  assert.equal(new Set(sent).size, 18);
  assert.equal(active.size, 0);
  assert.equal(
    (
      await f.owner.query(
        "SELECT count(*)::integer n FROM app.push_deliveries WHERE state='accepted'",
      )
    ).rows[0].n,
    18,
  );
});

test('PUSH-06 a locked account is deferred without consuming an attempt', async (t) => {
  let sends = 0;
  const f = await driverFixture(t, {
    send: async () => {
      sends++;
      return 'accepted';
    },
  });
  const event = await f.insertEvent();
  await f.owner.query(
    'INSERT INTO app.push_deliveries(trip_event_id,device_id,user_id) VALUES ($1,$2,$3)',
    [event, f.deviceId, f.user],
  );
  const lock = await f.owner.connect();
  try {
    await lock.query('BEGIN');
    await lock.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [f.user]);
    assert.deepEqual(await f.push.drain(), {
      considered: 0,
      accepted: 0,
      cancelled: 0,
      failed: 0,
      retried: 0,
    });
    assert.equal(sends, 0);
    assert.partialDeepStrictEqual(
      (await f.owner.query('SELECT state,attempts FROM app.push_deliveries')).rows[0],
      { state: 'pending', attempts: 0 },
    );
  } finally {
    await lock.query('ROLLBACK');
    lock.release();
  }
  assert.equal((await f.push.drain()).accepted, 1);
  assert.equal(sends, 1);
});

test('PUSH-07 fanout respects a one-connection pool without queueing competing workers', async (t) => {
  const entered = deferred();
  const gate = deferred();
  const f = await driverFixture(t, { send: async () => 'unused' });
  await f.insertEvent();
  await driverEvent(f, await addDriverRecipient(f, 'small-pool-driver'));
  const pool = new pg.Pool({ ...f.runtime.options, max: 1 });
  t.after(() => pool.end());
  const push = new PushNotifications({
    pool,
    deviceKey: Buffer.alloc(32, 2),
    sender: {
      send: async () => {
        entered.resolve();
        await gate.promise;
        return 'accepted';
      },
    },
  });
  const draining = push.drain();
  try {
    await entered.promise;
    assert.equal(pool.waitingCount, 0, 'workers must not queue behind their own slow send');
  } finally {
    gate.resolve();
    await draining;
  }
  assert.equal((await draining).accepted, 2);
});

test('PUSH-08 database failure waits for started sends and stops claiming additional accounts', async (t) => {
  const inFlight = deferred();
  const gate = deferred();
  const rolledBack = deferred();
  let slowStarted = 0;
  const tokens: string[] = [];
  const f = await driverFixture(t, {
    send: async (token) => {
      tokens.push(token);
      if (token === 'driver-token') await inFlight.promise;
      else {
        if (++slowStarted === 3) inFlight.resolve();
        await gate.promise;
      }
      return 'accepted';
    },
  });
  await f.insertEvent();
  for (let i = 0; i < 4; i++) await driverEvent(f, await addDriverRecipient(f, `slow-${i}`));
  // Candidate order is normally by delivery time/UUID, not event creation.
  // Make the failing account first so all three other lanes are held at failure.
  await f.owner.query(`
    INSERT INTO app.push_deliveries(trip_event_id,device_id,user_id,next_attempt_at)
    SELECT e.id,d.id,u.id,clock_timestamp()-interval '1 hour'
      + row_number() OVER (ORDER BY e.created_at,e.id)*interval '1 second'
    FROM app.trip_events e JOIN app.drivers dr ON dr.id::text=e.after_state->>'assignedDriverId'
    JOIN app.users u ON u.id=dr.user_id JOIN app.push_devices d ON d.user_id=u.id
  `);
  // Fail persistence, not the provider. That must escape deliver's retry path.
  await f.owner.query(`
    CREATE FUNCTION app.test_push_write_failure() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN RAISE EXCEPTION 'test_push_write_failure'; END $$;
    CREATE TRIGGER test_push_write_failure BEFORE UPDATE ON app.push_deliveries
    FOR EACH ROW WHEN (NEW.user_id='${f.user}'::uuid) EXECUTE FUNCTION app.test_push_write_failure();
  `);
  const onRelease = () => {
    if (slowStarted === 3) rolledBack.resolve();
  };
  f.runtime.on('release', onRelease);
  let settled = false;
  const draining = f.push.drain();
  const rejected = assert
    .rejects(draining, /test_push_write_failure|current transaction is aborted/)
    .finally(() => {
      settled = true;
    });
  const deadline = new AbortController();
  try {
    await Promise.race([
      rolledBack.promise,
      delay(5000, null, { signal: deadline.signal }).then(() =>
        assert.fail('database failure did not roll back'),
      ),
    ]);
    await new Promise<void>((done) => setImmediate(done));
    assert.equal(settled, false);
    assert.equal(tokens.length, 4, 'the fifth account must not be claimed');
  } finally {
    deadline.abort();
    gate.resolve();
    await rejected;
    f.runtime.off('release', onRelease);
  }
  assert.equal(f.runtime.waitingCount, 0);
  assert.equal(f.runtime.idleCount, f.runtime.totalCount);
  const rows = (
    await f.owner.query(
      'SELECT state, count(*)::integer n FROM app.push_deliveries GROUP BY state ORDER BY state',
    )
  ).rows;
  assert.deepEqual(rows, [
    { state: 'accepted', n: 3 },
    { state: 'pending', n: 2 },
  ]);
});
