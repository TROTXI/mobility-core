import { test } from 'node:test';
import type { TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomUUID, randomBytes, createHmac } from 'node:crypto';
import { SignJWT } from 'jose';
import { setup, at, files } from './helpers/financial-fixture.js';
import { MembershipService } from '../src/membership/service.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { BoardingService } from '../src/boarding/service.js';
import { createTransportApp } from '../src/http/app.js';
import { migrate, grantRuntime } from '../src/db/migrate.js';
import type { Actor, Body } from '../src/transport/service.js';
import { TransportService, tripEditToken } from '../src/transport/service.js';
import { PaymentRecovery } from '../src/payments/recovery.js';
import { PaystackEvidence } from '../src/payments/provider.js';

const data = (out: any) => out.body.data;
async function fixture(t: TestContext, auxFailure = false, through = files.length) {
  const f = await setup(t, {}, false, through);
  let now = new Date(at);
  const key = randomBytes(32);
  const membership = new MembershipService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 7),
    now: () => now,
    fareForSelection: async () => 600,
  });
  const financial = new FinancialFoundation({
    ...f.dependencies,
    assertCheckoutAllowed: membership.assertCheckoutAllowed,
    assertPeriodCanClose: membership.assertPeriodCanClose,
    materializeAssignment: membership.materializeAssignment,
  });
  const driverId = (
    await f.owner.query(
      "INSERT INTO app.users(role,display_name) VALUES('driver','Driver') RETURNING id",
    )
  ).rows[0].id;
  const foreignId = (
    await f.owner.query("INSERT INTO app.users(role) VALUES('driver') RETURNING id")
  ).rows[0].id;
  const driver = (
    await f.owner.query(
      "INSERT INTO app.drivers(user_id,name) VALUES($1,'Boarding fixture') RETURNING id",
      [driverId],
    )
  ).rows[0].id;
  await f.owner.query("INSERT INTO app.drivers(user_id,name) VALUES($1,'Foreign driver')", [
    foreignId,
  ]);
  await f.owner.query('INSERT INTO app.test_fin_sessions VALUES($1,true),($2,true),($3,true)', [
    driverId,
    foreignId,
    f.adminId,
  ]);
  const actors: Record<string, Actor> = {
    rider: f.actor,
    other: f.other,
    driver: { userId: driverId, sessionId: driverId },
    foreign: { userId: foreignId, sessionId: foreignId },
    ops: { userId: f.adminId, sessionId: f.adminId },
  };
  let scans = 0;
  const boarding = new BoardingService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    proofKey: key,
    now: () => now,
    avatarUrl: async () => 'https://private.example/avatar?expires=120',
    auditScan: async () => {
      scans++;
      if (auxFailure) throw Error('test telemetry unavailable');
    },
  });
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: Buffer.alloc(32, 7),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: membership.coordinateReservations,
    membership,
    boarding,
    verifyAccess: async (h) => actors[h.replace('Bearer ', '')] ?? null,
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
    requestsPerMinute: 2000,
  });
  t.after(() => app.close());
  const headers = (who = 'driver') => ({
    authorization: `Bearer ${who}`,
    'x-trotxi-client':
      who === 'ops' ? 'ops' : ['rider', 'other'].includes(who) ? 'commuter' : 'driver',
    'x-trotxi-build': '1',
    ...(who === 'ops' ? {} : { 'x-trotxi-platform': 'android' }),
  });
  const request = async (
    method: 'GET' | 'POST',
    url: string,
    payload?: unknown,
    who = 'driver',
    expected = 200,
    commandKey = randomUUID(),
  ) => {
    const r = await app.inject({
      method,
      url,
      headers: { ...headers(who), 'idempotency-key': commandKey },
      ...(payload !== undefined ? { payload: payload as any } : {}),
    });
    assert.equal(r.statusCode, expected, r.body);
    return r.json();
  };
  const buy = async (who = f.actor) => {
    const p = await financial.checkout(who, f.input, randomUUID(), now);
    assert.equal(await financial.fulfill(f.settle(p, now)), 'fulfilled');
    return f.period(p.id);
  };
  const trip = async (direction: 'outbound' | 'return' = 'outbound', day = '2026-01-02') => {
    const v = (
      await f.owner.query('INSERT INTO app.vehicles(plate,capacity) VALUES($1,18) RETURNING id', [
        randomUUID().slice(0, 8),
      ])
    ).rows[0].id;
    return (
      await f.owner.query(
        `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,assigned_driver_id,vehicle_id)
     SELECT id,departure_id,pattern_version_id,$2::date,$2::date+local_departure,$3,$4 FROM app.service_schedules WHERE id=$1 RETURNING *`,
        [f.input.legs.find((l) => l.direction === direction)!.scheduleId, day, driver, v],
      )
    ).rows[0];
  };
  const reserve = async (who = f.actor, direction = 'outbound', day = '2026-01-02') =>
    data(
      await membership.command(
        who,
        'decideReservation',
        undefined,
        { travelDate: day, direction, decision: 'confirm' },
        randomUUID(),
      ),
    ).reservation;
  const pass = async (rid: string, who = 'rider') =>
    (await request('POST', `/v1/me/reservations/${rid}/pass`, undefined, who)).data;
  const board = async (
    tid: string,
    proof: Body,
    expected = 200,
    who = 'driver',
    commandKey = randomUUID(),
  ) =>
    (await request('POST', `/v1/driver/trips/${tid}/boardings`, proof, who, expected, commandKey))
      .data;
  const mark = async (tid: string, rid: string, expected = 200) =>
    (
      await request(
        'POST',
        `/v1/driver/trips/${tid}/reservations/${rid}/no-show`,
        undefined,
        'driver',
        expected,
      )
    ).data;
  const counts = async () =>
    (
      await f.owner.query(`SELECT (SELECT count(*)::int FROM app.reservation_charges) charges,
   (SELECT count(*)::int FROM app.ride_entries WHERE reservation_id IS NOT NULL) debits,
   (SELECT count(*)::int FROM app.boarding_commands) commands,
   (SELECT count(*)::int FROM app.boarding_qr_uses) qr,
   (SELECT count(*)::int FROM app.boarding_events) events`)
    ).rows[0];
  return {
    ...f,
    app,
    boarding,
    membership,
    financial,
    key,
    actors,
    driver,
    driverId,
    request,
    buy,
    trip,
    reserve,
    pass,
    board,
    mark,
    counts,
    scans: () => scans,
    setNow: (s: string) => {
      now = new Date(s);
    },
  };
}
async function seat(t: TestContext, aux = false) {
  const f = await fixture(t, aux);
  const period = await f.buy(),
    trip = await f.trip(),
    r = await f.reserve();
  f.setNow('2026-01-02T06:35:00Z');
  return { ...f, period, run: trip, reservation: r };
}

test('BRD-01: issued pass binds reservation/trip and QR commits exactly one owned ride with attendance', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id);
  assert.equal(p.reservationId, f.reservation.id);
  assert.equal(p.tripId, f.run.id);
  assert.match(p.boardingCode, /^[A-Z2-9]{4}$/);
  assert.equal(Date.parse(p.expiresAt), Date.parse('2026-01-02T06:36:00Z'));
  assert.deepEqual(await f.board(f.run.id, { kind: 'qr', token: p.qrToken }), {
    reservationId: f.reservation.id,
    status: 'boarded',
    alreadyApplied: false,
    chargedRides: 1,
  });
  assert.deepEqual(await f.counts(), { charges: 1, debits: 1, commands: 1, qr: 1, events: 1 });
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT user_id,period_id,reason,delta_rides,reservation_id FROM app.ride_entries WHERE reservation_id=$1',
        [f.reservation.id],
      )
    ).rows,
    [
      {
        user_id: f.actor.userId,
        period_id: f.period.id,
        reason: 'boarding',
        delta_rides: -1,
        reservation_id: f.reservation.id,
      },
    ],
  );
  assert.equal(
    (
      await f.owner.query('SELECT status,settled_at FROM app.reservations WHERE id=$1', [
        f.reservation.id,
      ])
    ).rows[0].status,
    'boarded',
  );
});
test('BRD-02: same-key replay and fresh QR never charge twice; reused QR on a fresh key is refused', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id),
    key = randomUUID();
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 200, 'driver', key);
  assert.equal(
    (await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 200, 'driver', key)).chargedRides,
    0,
  );
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 409);
  const fresh = await f.pass(f.reservation.id);
  assert.notEqual(fresh.qrToken, p.qrToken);
  assert.equal((await f.board(f.run.id, { kind: 'qr', token: fresh.qrToken })).chargedRides, 0);
  assert.equal((await f.counts()).debits, 1);
});
test('BRD-03: charged no-show can board late by photo, preserving its debit and settlement time', async (t) => {
  const f = await seat(t);
  await f.mark(f.run.id, f.reservation.id);
  const before = (await f.owner.query('SELECT * FROM app.reservation_charges')).rows;
  f.setNow('2026-01-02T06:40:00Z');
  assert.deepEqual(await f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id }), {
    reservationId: f.reservation.id,
    status: 'boarded',
    alreadyApplied: true,
    chargedRides: 0,
  });
  assert.deepEqual((await f.owner.query('SELECT * FROM app.reservation_charges')).rows, before);
  assert.equal((await f.mark(f.run.id, f.reservation.id)).status, 'boarded');
  assert.equal((await f.counts()).debits, 1);
  assert.equal(
    (await f.owner.query('SELECT reason FROM app.ride_entries WHERE reservation_id IS NOT NULL'))
      .rows[0].reason,
    'no_show',
  );
});
test('BRD-04: code path is case-insensitive, scoped to trip and never returns or persists proof material', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id);
  const ret = await f.trip('return');
  await f.board(ret.id, { kind: 'code', code: p.boardingCode }, 409);
  await f.board(f.run.id, { kind: 'code', code: p.boardingCode.toLowerCase() });
  const stored = JSON.stringify((await f.owner.query('SELECT * FROM app.boarding_commands')).rows);
  assert.ok(!stored.includes(p.boardingCode));
  assert.ok(!stored.includes(p.qrToken));
  assert.equal((await f.counts()).debits, 1);
});
test('BRD-05: ownership and fresh session checks apply before proof/replay, without foreign trip existence leaks', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id),
    key = randomUUID();
  for (const tid of [f.run.id, randomUUID()])
    await f.board(tid, { kind: 'qr', token: p.qrToken }, 404, 'foreign');
  await f.request('POST', `/v1/me/reservations/${f.reservation.id}/pass`, undefined, 'other', 404);
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 200, 'driver', key);
  await f.owner.query('UPDATE app.test_fin_sessions SET active=false WHERE user_id=$1', [
    f.driverId,
  ]);
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 401, 'driver', key);
  assert.equal((await f.counts()).debits, 1);
});
test('BRD-06: manifest is complete, assigned-driver-only, private, and summary counts durable attendance methods', async (t) => {
  const f = await seat(t);
  await f.owner.query(
    "UPDATE app.users SET display_name='Test Rider',avatar_object_key='private/key' WHERE id=$1",
    [f.actor.userId],
  );
  const path = `/v1/driver/trips/${f.run.id}/manifest`;
  await f.request('GET', path, undefined, 'foreign', 404);
  const m = (await f.request('GET', path)).data;
  assert.equal(m.complete, true);
  assert.equal(m.riders.length, 1);
  assert.equal(m.riders[0].displayName, 'Test Rider');
  assert.equal(m.riders[0].avatarUrl, 'https://private.example/avatar?expires=120');
  assert.ok(!JSON.stringify(m).includes('private/key'));
  await f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id });
  assert.deepEqual((await f.request('GET', `/v1/driver/trips/${f.run.id}/summary`)).data, {
    tripId: f.run.id,
    status: 'scheduled',
    boarded: 1,
    noShows: 0,
    unseated: 0,
    scanned: 0,
    codeVerified: 0,
    photoVerified: 1,
  });
});
test('BRD-07: expiry, signature, access-token audience and cross-trip QR are independently refused', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id),
    ret = await f.trip('return');
  await f.board(ret.id, { kind: 'qr', token: p.qrToken }, 409);
  const auth = await new SignJWT({ reservationId: f.reservation.id, tripId: f.run.id })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(f.actor.userId)
    .setAudience('trotxi-access')
    .setIssuer('trotxi-replacement')
    .setJti(randomUUID())
    .setIssuedAt(Date.parse('2026-01-02T06:35:00Z') / 1000)
    .setExpirationTime(Date.parse('2026-01-02T06:36:00Z') / 1000)
    .sign(f.key);
  await f.board(f.run.id, { kind: 'qr', token: auth }, 409);
  const parts = p.qrToken.split('.');
  parts[2] = (parts[2][0] === 'a' ? 'b' : 'a') + parts[2].slice(1);
  await f.board(f.run.id, { kind: 'qr', token: parts.join('.') }, 409);
  f.setNow('2026-01-02T06:37:00Z');
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 409);
  assert.equal((await f.counts()).charges, 0);
});
test('BRD-08/09: no cache dependency; auxiliary telemetry failure cannot roll back durable boarding', async (t) => {
  const f = await seat(t, true),
    p = await f.pass(f.reservation.id);
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken });
  assert.equal(f.scans(), 1);
  assert.equal((await f.counts()).debits, 1);
});
test('BRD-10: competing QR/photo/no-show sessions really contend and converge on one charge', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id),
    lock = await f.lock();
  const jobs = [
    f.board(f.run.id, { kind: 'qr', token: p.qrToken }),
    f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id }),
    f.mark(f.run.id, f.reservation.id),
  ];
  try {
    await f.waiters(3);
  } finally {
    await lock.query('COMMIT');
    lock.release();
  }
  const results = await Promise.all(jobs);
  assert.equal(
    results.reduce((n, r) => n + r.chargedRides, 0),
    1,
  );
  assert.equal((await f.counts()).debits, 1);
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations WHERE id=$1', [f.reservation.id]))
      .rows[0].status,
    'boarded',
  );
});
test('BRD-11: required event failure rolls back source, debit, attendance, QR and key; retry succeeds', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id),
    key = randomUUID();
  await f.owner.query(
    "CREATE FUNCTION app.break_boarding() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'fixture'; END $$; CREATE TRIGGER break_boarding BEFORE INSERT ON app.boarding_events FOR EACH ROW EXECUTE FUNCTION app.break_boarding()",
  );
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 500, 'driver', key);
  assert.deepEqual(await f.counts(), { charges: 0, debits: 0, commands: 0, qr: 0, events: 0 });
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations WHERE id=$1', [f.reservation.id]))
      .rows[0].status,
    'reserved',
  );
  await f.owner.query('DROP TRIGGER break_boarding ON app.boarding_events');
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 200, 'driver', key);
});
test('BRD-12: erasure and account restriction invalidate previously issued proofs', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id);
  const restriction = (
    await f.owner.query(
      "INSERT INTO app.account_restrictions(user_id,actor_user_id,reason,review_at) VALUES($1,$2,'Fixture restriction','2026-02-01') RETURNING id",
      [f.actor.userId, f.adminId],
    )
  ).rows[0].id;
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 409);
  await f.owner.query(
    "UPDATE app.account_restrictions SET released_at=clock_timestamp(),released_by=$2,release_reason='Fixture release' WHERE id=$1",
    [restriction, f.adminId],
  );
  await f.owner.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [
    f.actor.userId,
  ]);
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 409);
  assert.equal((await f.counts()).debits, 0);
});
test('BRD-13: a funded period cannot close before settlement; after boarding only 43 unused rides convert', async (t) => {
  const f = await seat(t);
  await assert.rejects(
    f.financial.closePeriod(f.period.id, new Date('2026-02-02')),
    (e) => (e as any).code === 'period_service_unsettled',
  );
  await f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id });
  assert.equal(await f.financial.closePeriod(f.period.id, new Date('2026-02-02')), true);
  assert.deepEqual(
    (await f.owner.query('SELECT rides_converted,credit_granted_pesewas FROM app.period_closures'))
      .rows,
    [{ rides_converted: 43, credit_granted_pesewas: 43 * 45 }],
  );
});
test('BRD-14: no-show maintenance scopes day/direction/route, is bounded and never charges another direction', async (t) => {
  const f = await seat(t),
    ret = await f.trip('return');
  f.setNow('2026-01-01T00:00:00Z');
  await f.reserve(f.actor, 'return');
  f.setNow('2026-01-02T06:35:00Z');
  const req = {
    travelDate: '2026-01-02',
    direction: 'outbound',
    routeId: f.input.routeId,
    limit: 1,
  };
  const run = () => f.request('POST', '/v1/ops/maintenance/no-shows', req, 'ops');
  assert.deepEqual((await run()).data, {
    considered: 1,
    succeeded: 1,
    blocked: 0,
    failed: 0,
    failures: [],
  });
  assert.equal((await run()).data.considered, 0);
  assert.equal(
    (await f.owner.query('SELECT status FROM app.reservations WHERE trip_id=$1', [ret.id])).rows[0]
      .status,
    'reserved',
  );
  assert.equal((await f.counts()).debits, 1);
});
test('BRD-15: database rejects status-only settlement, second charge and altered settled timestamp', async (t) => {
  const f = await seat(t);
  await assert.rejects(
    f.runtime.query(
      "UPDATE app.reservations SET status='boarded',settled_at=clock_timestamp() WHERE id=$1",
      [f.reservation.id],
    ),
    /reservation_settlement_incomplete/,
  );
  await f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id });
  await assert.rejects(
    f.runtime.query(
      "INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides,reservation_id) VALUES($1,$2,'boarding',-1,$3)",
      [f.actor.userId, f.period.id, f.reservation.id],
    ),
    /unique constraint/,
  );
  await assert.rejects(
    f.runtime.query(
      "UPDATE app.reservations SET settled_at=settled_at+interval '1 second' WHERE id=$1",
      [f.reservation.id],
    ),
    /settlement_immutable/,
  );
});
test('BRD-16: invalid code attempts retain their budget and photo fallback still works', async (t) => {
  const f = await seat(t);
  for (let i = 0; i < 30; i++) await f.board(f.run.id, { kind: 'code', code: '9999' }, 409);
  await f.board(f.run.id, { kind: 'code', code: '9999' }, 429);
  assert.equal(
    (await f.owner.query('SELECT attempts FROM app.boarding_code_attempts')).rows[0].attempts,
    31,
  );
  await f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id });
});
test('BRD-17: 014 to 015 upgrade preserves funded reservations and recorded migration hashes', async (t) => {
  const f = await fixture(t, false, 14),
    period = await f.buy(),
    trip = await f.trip(),
    r = await f.reserve();
  const before = (await f.owner.query('SELECT * FROM app.reservations')).rows;
  const hashes = (
    await f.owner.query('SELECT name,sha256 FROM public._replacement_migrations ORDER BY name')
  ).rows;
  assert.deepEqual(await migrate(f.owner, files), [
    '015_boarding_settlement.sql',
    '016_pricing_and_purchases.sql',
    '017_account_privacy.sql',
    '018_configuration.sql',
  ]);
  await grantRuntime(f.owner, f.role);
  assert.deepEqual((await f.owner.query('SELECT * FROM app.reservations')).rows, before);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT name,sha256 FROM public._replacement_migrations ORDER BY name LIMIT 14',
      )
    ).rows,
    hashes,
  );
  f.setNow('2026-01-02T06:35:00Z');
  await f.board(trip.id, { kind: 'photo', reservationId: r.id });
  assert.equal(
    (
      await f.owner.query(
        'SELECT sum(delta_rides)::int n FROM app.ride_entries WHERE period_id=$1',
        [period.id],
      )
    ).rows[0].n,
    43,
  );
});

async function recovery(f: Awaited<ReturnType<typeof seat>>) {
  const secret = `sk_test_${randomBytes(16).toString('hex')}`;
  const provider = new PaystackEvidence(secret, randomBytes(32), async () => {
    throw Error('No provider network requests in tests');
  });
  const service = new PaymentRecovery({
    pool: f.runtime,
    provider,
    foundation: f.financial,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 8),
    reversePeriod: f.membership.reversePeriod,
  });
  const attempt = (
    await f.owner.query('SELECT * FROM app.payment_attempts WHERE purchase_id=$1', [
      f.period.purchase_id,
    ])
  ).rows[0];
  const enqueue = async (event: string, props: Record<string, unknown>) => {
    const raw = Buffer.from(
      JSON.stringify({ event, data: { domain: 'test', currency: 'GHS', ...props } }),
    );
    await service.acceptWebhook(raw, createHmac('sha512', secret).update(raw).digest('hex'));
  };
  return {
    service,
    attempt,
    enqueue,
    refund: () =>
      enqueue('refund.processed', {
        transaction_reference: attempt.reference,
        amount: attempt.amount_pesewas,
        status: 'processed',
        refund_reference: randomUUID(),
      }),
  };
}
test('BRD-18: settlement racing period close never converts a funded ride twice', async (t) => {
  const f = await seat(t),
    lock = await f.lock();
  const board = f.boarding.command(
    f.actors.driver!,
    'boardRider',
    f.run.id,
    { kind: 'photo', reservationId: f.reservation.id },
    randomUUID(),
  );
  const close = f.financial.closePeriod(f.period.id, new Date('2026-02-02'));
  const results = Promise.allSettled([board, close]);
  try {
    await f.waiters(2);
  } finally {
    await lock.query('COMMIT');
    lock.release();
  }
  const [b, c] = await results;
  assert.equal(b.status, 'fulfilled');
  if (c.status === 'rejected') assert.equal(c.reason.code, 'period_service_unsettled');
  await f.financial.closePeriod(f.period.id, new Date('2026-02-02'));
  assert.deepEqual(
    (await f.owner.query('SELECT rides_converted,credit_granted_pesewas FROM app.period_closures'))
      .rows,
    [{ rides_converted: 43, credit_granted_pesewas: 1935 }],
  );
  assert.equal((await f.counts()).debits, 1);
});
test('BRD-19: full Paystack refund after boarding counts consumed rides separately and reverses only unused rides', async (t) => {
  const f = await seat(t),
    rec = await recovery(f);
  await f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id });
  await rec.refund();
  assert.equal((await rec.service.processInbox()).succeeded, 1);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT rides_removed,consumed_rides,estimated_debt_pesewas FROM app.payment_reversals',
      )
    ).rows,
    [{ rides_removed: 43, consumed_rides: 1, estimated_debt_pesewas: '600' }],
  );
  assert.equal(
    (
      await f.owner.query(
        'SELECT sum(delta_rides)::int n FROM app.ride_entries WHERE period_id=$1',
        [f.period.id],
      )
    ).rows[0].n,
    0,
  );
  await f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id }, 409);
});
test('BRD-20: refund and boarding really contend; refund wins before any charge or records exactly one consumed ride', async (t) => {
  const f = await seat(t),
    rec = await recovery(f);
  await rec.refund();
  const lock = await f.lock();
  const board = f.boarding.command(
    f.actors.driver!,
    'boardRider',
    f.run.id,
    { kind: 'photo', reservationId: f.reservation.id },
    randomUUID(),
  );
  const refund = rec.service.processInbox();
  const pending = Promise.allSettled([board, refund]);
  try {
    await f.waiters(2);
  } finally {
    await lock.query('COMMIT');
    lock.release();
  }
  const [b, r] = await pending;
  assert.equal(r.status, 'fulfilled');
  if (r.status === 'fulfilled') assert.equal(r.value.succeeded, 1);
  const consumed = b.status === 'fulfilled' ? 1 : 0;
  if (b.status === 'rejected') assert.equal(b.reason.code, 'boarding_ineligible');
  const row = (
    await f.owner.query(
      'SELECT rides_removed,consumed_rides,estimated_debt_pesewas FROM app.payment_reversals',
    )
  ).rows[0];
  assert.deepEqual(row, {
    rides_removed: 44 - consumed,
    consumed_rides: consumed,
    estimated_debt_pesewas: String(consumed * 600),
  });
  assert.equal((await f.counts()).debits, consumed);
});
test('BRD-21: dispute blocks an issued pass and declined resolution restores it; cancellation never charges', async (t) => {
  const f = await seat(t),
    rec = await recovery(f),
    p = await f.pass(f.reservation.id);
  const dispute = {
    id: '315',
    amount: rec.attempt.amount_pesewas,
    transaction: { reference: rec.attempt.reference },
  };
  await rec.enqueue('charge.dispute.create', dispute);
  assert.equal((await rec.service.processInbox()).succeeded, 1);
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 409);
  await rec.enqueue('charge.dispute.resolve', { ...dispute, resolution: 'declined' });
  assert.equal((await rec.service.processInbox()).succeeded, 1);
  await f.pass(f.reservation.id);
  const transport = new TransportService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    cursorSecret: Buffer.alloc(32, 7),
    coordinateReservations: f.membership.coordinateReservations,
  });
  await transport.command(
    f.actors.ops!,
    'cancelTrip',
    f.run.id,
    { reason: 'Fixture cancelled run' },
    randomUUID(),
    tripEditToken(f.run),
  );
  await f.board(f.run.id, { kind: 'qr', token: p.qrToken }, 409);
  assert.equal((await f.counts()).debits, 0);
});
test('BRD-22: confirmed seats only; no-show cannot charge declined, pending or unseated reservations', async (t) => {
  const f = await seat(t);
  await f.owner.query("UPDATE app.reservations SET status='declined' WHERE id=$1", [
    f.reservation.id,
  ]);
  for (const status of ['declined', 'pending', 'unseated']) {
    await f.owner.query('UPDATE app.reservations SET status=$2 WHERE id=$1', [
      f.reservation.id,
      status,
    ]);
    await f.mark(f.run.id, f.reservation.id, 409);
    await f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id }, 409);
  }
  assert.deepEqual(await f.counts(), { charges: 0, debits: 0, commands: 0, qr: 0, events: 0 });
});
test('BRD-23: invalid funding and source attribution are refused at the SQL boundary', async (t) => {
  const f = await seat(t);
  await f.owner.query(
    "INSERT INTO app.account_restrictions(user_id,actor_user_id,reason,review_at) VALUES($1,$2,'Fixture restriction','2026-02-01')",
    [f.actor.userId, f.adminId],
  );
  await assert.rejects(
    f.runtime.query(
      "INSERT INTO app.reservation_charges(reservation_id,period_id,user_id,trip_id,reason,command_id,charged_at) VALUES($1,$2,$3,$4,'boarding',$5,clock_timestamp())",
      [f.reservation.id, f.period.id, f.actor.userId, f.run.id, randomUUID()],
    ),
    /boarding_ineligible/,
  );
  await assert.rejects(
    f.runtime.query(
      "INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides,reservation_id) VALUES($1,$2,'boarding',-1,$3)",
      [f.actor.userId, f.period.id, f.reservation.id],
    ),
    /boarding_source_mismatch/,
  );
  assert.equal((await f.counts()).debits, 0);
});

test('BRD-24: same-key changed payload conflicts and a later assignment cannot replay the former driver receipt', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id),
    key = randomUUID();
  await f.board(f.run.id, { kind: 'code', code: p.boardingCode }, 200, 'driver', key);
  assert.equal(
    (
      await f.board(
        f.run.id,
        { kind: 'code', code: p.boardingCode.toLowerCase() },
        200,
        'driver',
        key,
      )
    ).chargedRides,
    0,
  );
  await f.board(f.run.id, { kind: 'photo', reservationId: f.reservation.id }, 409, 'driver', key);
  const other = (
    await f.owner.query('SELECT id FROM app.drivers WHERE user_id=$1', [f.actors.foreign!.userId])
  ).rows[0].id;
  await f.owner.query('UPDATE app.trips SET assigned_driver_id=$2 WHERE id=$1', [f.run.id, other]);
  await f.board(f.run.id, { kind: 'code', code: p.boardingCode }, 404, 'driver', key);
  assert.equal((await f.counts()).debits, 1);
});
test('BRD-25: overdue no-show catch-up works, future departures do not charge, and unrelated routes stay untouched', async (t) => {
  const f = await seat(t);
  const path = '/v1/ops/maintenance/no-shows',
    body = { travelDate: '2026-01-02', direction: 'outbound', limit: 1 };
  f.setNow('2026-01-02T06:00:00Z');
  assert.equal((await f.request('POST', path, body, 'ops')).data.considered, 0);
  f.setNow('2026-01-03T06:35:00Z');
  assert.equal(
    (await f.request('POST', path, { ...body, routeId: randomUUID() }, 'ops')).data.considered,
    0,
  );
  assert.equal((await f.request('POST', path, body, 'ops')).data.succeeded, 1);
  assert.equal((await f.counts()).debits, 1);
});
test('BRD-26: a source plus attendance without its debit cannot commit', async (t) => {
  const f = await seat(t),
    c = await f.runtime.connect();
  try {
    await c.query('BEGIN');
    const command = randomUUID();
    await c.query(
      "INSERT INTO app.boarding_commands(id,actor_user_id,operation,target,key_hash,input_hash,response_body) VALUES($1,$2,'boardRider',$3,repeat('a',64),repeat('b',64),$4)",
      [
        command,
        f.driverId,
        f.run.id,
        {
          reservationId: f.reservation.id,
          status: 'boarded',
          alreadyApplied: false,
          chargedRides: 1,
        },
      ],
    );
    await c.query(
      "INSERT INTO app.reservation_charges(reservation_id,period_id,user_id,trip_id,reason,command_id,charged_at) VALUES($1,$2,$3,$4,'boarding',$5,'2026-01-02T06:35:00Z')",
      [f.reservation.id, f.period.id, f.actor.userId, f.run.id, command],
    );
    await c.query(
      "UPDATE app.reservations SET status='boarded',settled_at='2026-01-02T06:35:00Z' WHERE id=$1",
      [f.reservation.id],
    );
    await assert.rejects(c.query('COMMIT'), /reservation_settlement_incomplete/);
  } finally {
    await c.query('ROLLBACK');
    c.release();
  }
  assert.deepEqual(await f.counts(), { charges: 0, debits: 0, commands: 0, qr: 0, events: 0 });
});
test('BRD-27: proof variants cannot be mixed or renamed to skip validation, over HTTP or direct service calls', async (t) => {
  const f = await seat(t),
    p = await f.pass(f.reservation.id);
  const malformed: Body[] = [
    { kind: 'qr', reservationId: f.reservation.id },
    { kind: 'qr', token: p.qrToken, reservationId: f.reservation.id },
    { kind: 'photo', reservationId: f.reservation.id, token: 'invalid' },
    { kind: 'code', code: p.boardingCode, token: 'invalid' },
    { kind: 'unverified', reservationId: f.reservation.id },
    { kind: 'constructor', reservationId: f.reservation.id },
    { kind: '__proto__', reservationId: f.reservation.id },
  ];
  for (const body of malformed) {
    await f.board(f.run.id, body, 400);
    await assert.rejects(
      f.boarding.command(f.actors.driver!, 'boardRider', f.run.id, body, randomUUID()),
      (err: any) => err.status === 400,
    );
  }
  const valid: Body[] = [
    { kind: 'qr', token: p.qrToken },
    { kind: 'code', code: p.boardingCode },
    { kind: 'photo', reservationId: f.reservation.id },
  ];
  for (const body of valid) await f.board(f.run.id, body, 404, 'foreign');
  assert.deepEqual(await f.counts(), { charges: 0, debits: 0, commands: 0, qr: 0, events: 0 });
});
