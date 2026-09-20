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
