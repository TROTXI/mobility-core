import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { setup } from './helpers/financial-fixture.js';
import { RiderInbox } from '../src/notifications/inbox.js';
import { TransportError } from '../src/transport/errors.js';
import { createTransportApp } from '../src/http/app.js';

const data = (result: Awaited<ReturnType<RiderInbox['list']>>) => result.body as any;

test('rider inbox is owned, paginated, audited and idempotently read', async (t) => {
  const f = await setup(t);
  const inbox = new RiderInbox({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 19),
    authorizeSession: f.dependencies.authorizeSession,
  });
  const first = randomUUID(),
    second = randomUUID();
  await f.owner.query(
    `INSERT INTO app.rider_notifications(user_id,kind,source_id,target_type,target_id)
     VALUES ($1,'seat_ask',$2,'reservation',$2),($1,'trip_changed',$3,'reservation',$2)`,
    [f.actor.userId, first, second],
  );
  const page = data(await inbox.list(f.actor, { limit: '1' }));
  assert.equal(page.data.length, 1);
  assert.ok(page.page.nextCursor);
  const next = data(await inbox.list(f.actor, { limit: '1', cursor: page.page.nextCursor }));
  assert.equal(next.data.length, 1);
  assert.notEqual(page.data[0].id, next.data[0].id);
  assert.equal(data(await inbox.list(f.other, {})).data.length, 0);
  await assert.rejects(
    inbox.markRead(f.other, page.data[0].id),
    (e: unknown) => e instanceof TransportError && e.status === 404,
  );
  const read = (await inbox.markRead(f.actor, page.data[0].id)).body as any;
  assert.ok(read.data.readAt);
  const repeated = (await inbox.markRead(f.actor, page.data[0].id)).body as any;
  assert.equal(repeated.data.readAt, read.data.readAt);
  assert.equal(((await inbox.markAllRead(f.actor)).body as any).data.readCount, 1);
  assert.equal(((await inbox.markAllRead(f.actor)).body as any).data.readCount, 0);
  const audit = (
    await f.owner.query(
      'SELECT action,count(*)::int AS n FROM app.rider_notification_events GROUP BY action ORDER BY action',
    )
  ).rows;
  assert.deepEqual(audit, [
    { action: 'created', n: 2 },
    { action: 'read', n: 2 },
  ]);
  await assert.rejects(
    f.runtime.query('UPDATE app.rider_notifications SET kind=$1 WHERE user_id=$2', [
      'ride_used',
      f.actor.userId,
    ]),
    /immutable_rider_notification/,
  );
});

test('preferences require a current edit token and cannot mute mandatory notices', async (t) => {
  const f = await setup(t);
  const inbox = new RiderInbox({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 19),
    authorizeSession: f.dependencies.authorizeSession,
  });
  const initial = await inbox.getPreferences(f.actor);
  assert.equal((initial.body as any).data.dailyAskTime, '17:00');
  assert.equal((initial.body as any).data.optionalUpdatesEnabled, false);
  const updated = await inbox.updatePreferences(
    f.actor,
    { dailyAskTime: '18:30', optionalUpdatesEnabled: true },
    initial.headers.etag,
  );
  assert.equal((updated.body as any).data.dailyAskTime, '18:30');
  assert.notEqual(updated.headers.etag, initial.headers.etag);
  await assert.rejects(
    inbox.updatePreferences(
      f.actor,
      { dailyAskTime: '07:00', optionalUpdatesEnabled: false },
      initial.headers.etag,
    ),
    (e: unknown) => e instanceof TransportError && e.status === 412,
  );
  await assert.rejects(
    inbox.updatePreferences(
      f.actor,
      { dailyAskTime: '22:00', optionalUpdatesEnabled: true },
      updated.headers.etag,
    ),
    (e: unknown) => e instanceof TransportError && e.status === 400,
  );
});

test('published rider routes validate the response and reject another client', async (t) => {
  const f = await setup(t);
  const inbox = new RiderInbox({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 19),
    authorizeSession: f.dependencies.authorizeSession,
  });
  const app = await createTransportApp({
    ...f.dependencies,
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 19),
    inbox,
    coordinateReservations: async () => undefined,
    verifyAccess: async (value) => (value === 'Bearer rider' ? f.actor : null),
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
  });
  t.after(() => app.close());
  const headers = {
    authorization: 'Bearer rider',
    'x-trotxi-client': 'commuter',
    'x-trotxi-build': '1',
    'x-trotxi-platform': 'ios',
  };
  const list = await app.inject({ method: 'GET', url: '/v1/me/notifications', headers });
  assert.equal(list.statusCode, 200, list.body);
  assert.deepEqual(list.json(), { data: [], page: { nextCursor: null } });
  const preferences = await app.inject({
    method: 'GET',
    url: '/v1/me/notification-preferences',
    headers,
  });
  assert.equal(preferences.statusCode, 200, preferences.body);
  assert.equal(preferences.json().data.dailyAskTime, '17:00');
  const updated = await app.inject({
    method: 'PATCH',
    url: '/v1/me/notification-preferences',
    headers: { ...headers, 'if-match': preferences.headers.etag! },
    payload: { dailyAskTime: '18:00', optionalUpdatesEnabled: false },
  });
  assert.equal(updated.statusCode, 200, updated.body);
  assert.equal(updated.json().data.dailyAskTime, '18:00');
  const wrongClient = await app.inject({
    method: 'GET',
    url: '/v1/me/notifications',
    headers: { ...headers, 'x-trotxi-client': 'driver' },
  });
  assert.equal(wrongClient.statusCode, 400);
});
