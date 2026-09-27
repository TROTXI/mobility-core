import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { setup, at } from './helpers/financial-fixture.js';
import { createTransportApp } from '../src/http/app.js';
import { TransportError } from '../src/transport/errors.js';

/**
 * Riders are made through the real checkout and fulfilment, not inserted, so
 * every row the reads see has passed the same guards a paying rider's would.
 * One paid now is active; one paid in January has a period that has since
 * ended, which is exactly what lapsed means.
 */
async function fixture(t: TestContext) {
  const f = await setup(t);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES ($1,true)', [f.adminId]);
  const admin = { userId: f.adminId, sessionId: f.adminId };
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 17),
    authorizeSession: f.dependencies.authorizeSession,
    verifyAccess: async (header) =>
      ({ 'Bearer ops': admin, 'Bearer rider': f.actor })[header as string] ?? null,
    minimumBuilds: { ops: 1, driver: { ios: 3, android: 3 }, commuter: { ios: 2, android: 2 } },
    // These reads never move a seat, so reaching the coordinator is a bug.
    coordinateReservations: async () => {
      throw new TransportError(503, 'unavailable', 'Not wired in this slice.');
    },
  });
  t.after(() => app.close());
  const get = (url: string, who: 'ops' | 'rider' = 'ops') =>
    app.inject({
      method: 'GET',
      url,
      headers: {
        authorization: `Bearer ${who}`,
        'x-trotxi-client': who === 'ops' ? 'ops' : 'commuter',
        'x-trotxi-build': '9',
        ...(who === 'ops' ? {} : { 'x-trotxi-platform': 'android' }),
      },
    });
  const name = (id: string, displayName: string, phone: string, email: string) =>
    f.owner.query('UPDATE app.users SET display_name=$2, phone=$3, email=$4 WHERE id=$1', [
      id,
      displayName,
      phone,
      email,
    ]);
  const subscribe = async (who: typeof f.actor, paidAt: Date) => {
    const purchase = await f.buy(randomUUID(), paidAt, who);
    assert.equal(await f.service.fulfill(f.settle(purchase, paidAt)), 'fulfilled');
  };
  return { ...f, app, get, name, subscribe };
}

test('RID-01 each rider says what they can do today', async (t) => {
  const f = await fixture(t);
  await f.name(f.actor.userId, 'Ama Serwaa', '+233201111111', 'ama@example.com');
  await f.name(f.other.userId, 'Kojo Antwi', '+233202222222', 'kojo@example.com');
  const nobody = (
    await f.owner.query(
      "INSERT INTO app.users(role,display_name,phone) VALUES ('commuter','Esi Mensah','+233203333333') RETURNING id",
    )
  ).rows[0].id as string;
  await f.subscribe(f.actor, new Date());
  await f.subscribe(f.other, at);
  await f.grant(2500, f.actor.userId);

  const response = await f.get('/v1/ops/riders');
  assert.equal(response.statusCode, 200, response.body);
  const byId = new Map(response.json().data.map((r: { id: string }) => [r.id, r]));

  const ama = byId.get(f.actor.userId) as Record<string, any>;
  assert.equal(ama.status, 'active');
  assert.equal(ama.plan, 'monthly');
  assert.ok(ama.ridesLeft > 0, 'a fresh period has its allocation');
  assert.ok(ama.routeName, 'the route the rider paid for');
  assert.deepEqual(ama.availableCredit, { amountMinor: 2500, currency: 'GHS' });
  assert.match(ama.editToken, /^"user:[0-9a-f-]+:\d+"$/);

  const kojo = byId.get(f.other.userId) as Record<string, any>;
  assert.equal(kojo.status, 'lapsed', 'paid in January, so the period has ended');
  // A lapsed rider has no current period, which is not the same as a current
  // period with nothing left in it.
  assert.equal(kojo.ridesLeft, null);
  assert.equal(kojo.plan, null);

  assert.equal((byId.get(nobody) as Record<string, any>).status, 'none');
  assert.equal(byId.has(f.adminId), false, 'staff are not riders');
});

test('RID-02 search matches name, phone or email, and a wildcard is just a character', async (t) => {
  const f = await fixture(t);
  await f.name(f.actor.userId, 'Ama Serwaa', '+233201111111', 'ama@example.com');
  await f.name(f.other.userId, 'Kojo Antwi', '+233202222222', 'kojo@example.com');
  const ids = async (q: string) =>
    (await f.get(`/v1/ops/riders?q=${encodeURIComponent(q)}`))
      .json()
      .data.map((r: { id: string }) => r.id);

  assert.deepEqual(await ids('serwaa'), [f.actor.userId], 'by name, any case');
  assert.deepEqual(await ids('2222222'), [f.other.userId], 'by phone');
  assert.deepEqual(await ids('ama@'), [f.actor.userId], 'by email');
  // Unescaped, "%" would match every rider. Escaped, it matches nobody here.
  assert.deepEqual(await ids('%'), []);
  assert.deepEqual(await ids('_'), []);
  assert.equal((await f.get('/v1/ops/riders?q=')).statusCode, 400, 'an empty search is refused');
});

test('RID-03 pages continue where they left off, and a cursor belongs to its search', async (t) => {
  const f = await fixture(t);
  await f.name(f.actor.userId, 'Ama Serwaa', '+233201111111', 'ama@example.com');
  await f.name(f.other.userId, 'Ama Boateng', '+233202222222', 'boateng@example.com');

  const first = (await f.get('/v1/ops/riders?limit=1')).json();
  assert.equal(first.data.length, 1);
  assert.ok(first.page.nextCursor, 'more remain');
  const second = (
    await f.get(`/v1/ops/riders?limit=1&cursor=${encodeURIComponent(first.page.nextCursor)}`)
  ).json();
  assert.equal(second.data.length, 1);
  assert.notEqual(second.data[0].id, first.data[0].id, 'no rider twice');

  // Replayed against a different search, the cursor would silently skip the
  // riders that search should have shown. It is refused instead.
  const replayed = await f.get(
    `/v1/ops/riders?limit=1&q=ama&cursor=${encodeURIComponent(first.page.nextCursor)}`,
  );
  assert.equal(replayed.statusCode, 400, replayed.body);
});

test('RID-04 the summary agrees with the list, and says nothing rather than zero', async (t) => {
  const f = await fixture(t);
  const empty = (await f.get('/v1/ops/riders/summary')).json().data;
  assert.equal(empty.active, 0);
  assert.equal(empty.averageRidesUsed, null, 'no current riders is not an average of zero');

  await f.subscribe(f.actor, new Date());
  await f.subscribe(f.other, at);
  await f.grant(2500, f.actor.userId);
  await f.grant(1000, f.other.userId);

  const summary = (await f.get('/v1/ops/riders/summary')).json().data;
  assert.equal(summary.active, 1);
  assert.equal(summary.lapsed, 1);
  assert.equal(summary.paused, 0);
  assert.equal(summary.monthly, 1, 'only riders with a current period are split by plan');
  assert.equal(summary.annual, 0);
  // Credit outlives a lapse, so the lapsed rider's counts too.
  assert.deepEqual(summary.creditOutstanding, { amountMinor: 3500, currency: 'GHS' });
  assert.equal(summary.averageRidesUsed, 0, 'one current rider who has not boarded yet');
});

test('RID-05 riders are an operations read, whatever the caller claims', async (t) => {
  const f = await fixture(t);
  // Sent as the rider app, the metadata gate refuses it before identity is
  // even read. The case that matters is a rider's session claiming to be the
  // ops console: the header must not buy the authority.
  const asOps = (url: string) =>
    f.app.inject({
      method: 'GET',
      url,
      headers: { authorization: 'Bearer rider', 'x-trotxi-client': 'ops', 'x-trotxi-build': '9' },
    });
  assert.equal((await asOps('/v1/ops/riders')).statusCode, 403);
  assert.equal((await asOps('/v1/ops/riders/summary')).statusCode, 403);
  assert.equal((await f.get('/v1/ops/riders', 'rider')).statusCode, 400);
  assert.equal(
    (await f.get('/v1/ops/riders/summary?limit=5')).statusCode,
    400,
    'the summary takes no parameters',
  );
});
