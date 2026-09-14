import { randomUUID } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { Pool } from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { PgCommuteService } from '../src/modules/commute/commute.service.pg';
import { PgSubscriptionRepository } from '../src/modules/subscriptions/subscription.repository.pg';
import { PgReservationRepository } from '../src/modules/reservations/reservation.repository.pg';
import { PgPaymentLifecycle } from '../src/modules/payments/payment-lifecycle.pg';
import { buildApp } from '../src/app';
import { createJwtService } from '../src/modules/auth/jwt';

const databaseUrl = process.env['DATABASE_URL'];
const suite = databaseUrl ? describe : describe.skip;
const schema = `commute_test_${randomUUID().replaceAll('-', '')}`;
const root = new Pool({ connectionString: databaseUrl });
const pool = new Pool({
  connectionString: databaseUrl,
  options: `-c search_path=${schema},public`,
});
const service = new PgCommuteService(pool);
const subs = new PgSubscriptionRepository(pool);
const admin = randomUUID();
const today = () => new Date().toISOString().slice(0, 10);
const auth = {
  secret: 'commute-test-secret-at-least-32-characters',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};

// Isolated relational prerequisites let these transaction tests also run on
// local Postgres without PostGIS. CI separately migrates the full real schema.
suite('commute workflow on real Postgres', () => {
  beforeAll(async () => {
    await root.query(`CREATE SCHEMA ${schema}`);
    await pool.query(`
      CREATE TABLE users(id uuid PRIMARY KEY,display_name text NOT NULL,role text DEFAULT 'commuter',deleted_at timestamptz);
      CREATE TABLE routes(id uuid PRIMARY KEY,name text NOT NULL);
      CREATE TABLE stops(id uuid PRIMARY KEY,name text NOT NULL);
      CREATE TABLE route_stops(route_id uuid REFERENCES routes,stop_id uuid REFERENCES stops,seq integer);
      CREATE TABLE subscriptions(id uuid PRIMARY KEY,user_id uuid REFERENCES users,status text DEFAULT 'active',route_id uuid REFERENCES routes,
        pickup_stop_id uuid,dropoff_stop_id uuid,current_period_id uuid,period_start timestamptz DEFAULT now(),period_end timestamptz,
        fare_pesewas integer,price_pesewas integer DEFAULT 26400,rides_granted integer DEFAULT 44,
        credit_pesewas_per_ride integer DEFAULT 45,plan text DEFAULT 'monthly',created_at timestamptz DEFAULT now());
      CREATE UNIQUE INDEX one_active ON subscriptions(user_id) WHERE status='active';
      CREATE TABLE subscription_periods(id uuid PRIMARY KEY,subscription_id uuid REFERENCES subscriptions,status text DEFAULT 'open',period_end timestamptz,route_id uuid,price_pesewas integer DEFAULT 26400);
      CREATE TABLE trips(id uuid PRIMARY KEY,route_id uuid REFERENCES routes,scheduled_at timestamptz,status text DEFAULT 'scheduled');
      CREATE TABLE reservations(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid REFERENCES users,trip_id uuid REFERENCES trips,status text,
        direction text DEFAULT 'morning',subscription_period_id uuid,pickup_stop_id uuid,dropoff_stop_id uuid,updated_at timestamptz DEFAULT now(),
        travel_date date,source text DEFAULT 'confirmation',daily_pin_hash text,confirmed_at timestamptz,created_at timestamptz DEFAULT now(),UNIQUE(user_id,travel_date,direction));
      CREATE TABLE payments(user_id uuid,purpose text,status text,reference text,created_at timestamptz);
      CREATE TABLE corridor_fares(route_id uuid REFERENCES routes,fare_pesewas integer,effective_from timestamptz DEFAULT now(),effective_to timestamptz);
      CREATE TABLE entitlement_ledger(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid,subscription_period_id uuid,delta_rides integer);
    `);
    await pool.query(
      await readFile(
        new URL('../src/db/migrations/043_commute_change_requests.sql', import.meta.url),
        'utf8',
      ),
    );
    await pool.query(`INSERT INTO users VALUES($1,'Test operator','admin',NULL)`, [admin]);
  });
  afterAll(async () => {
    await pool.end();
    await root.query(`DROP SCHEMA ${schema} CASCADE`);
    await root.end();
  });
  async function fixture(target?: { route: string; pickup: string; dropoff: string }) {
    const user = randomUUID(),
      sub = randomUUID(),
      period = randomUUID(),
      old = randomUUID();
    const route = target?.route ?? randomUUID(),
      pickup = target?.pickup ?? randomUUID(),
      dropoff = target?.dropoff ?? randomUUID();
    await pool.query(`INSERT INTO users(id,display_name) VALUES($1,'Test rider');`, [user]);
    await pool.query(`INSERT INTO routes VALUES($1,'Original route')`, [old]);
    if (!target) {
      await pool.query(`INSERT INTO routes VALUES($1,'Requested route')`, [route]);
      await pool.query(`INSERT INTO stops VALUES($1,'Pickup'),($2,'Destination')`, [
        pickup,
        dropoff,
      ]);
      await pool.query(`INSERT INTO route_stops VALUES($1,$2,0),($1,$3,4)`, [
        route,
        pickup,
        dropoff,
      ]);
      await pool.query(`INSERT INTO corridor_fares(route_id,fare_pesewas) VALUES($1,600)`, [route]);
    }
    await pool.query(
      `INSERT INTO subscriptions(id,user_id,route_id,current_period_id,period_end,fare_pesewas) VALUES($1,$2,$3,$4,now()+interval '20 days',600)`,
      [sub, user, old, period],
    );
    await pool.query(
      `INSERT INTO subscription_periods(id,subscription_id,route_id,period_end) VALUES($1,$2,$3,now()+interval '20 days')`,
      [period, sub, old],
    );
    await pool.query(
      `INSERT INTO entitlement_ledger(user_id,subscription_period_id,delta_rides) VALUES($1,$2,35)`,
      [user, period],
    );
    const input = {
      routeId: route,
      pickupStopId: pickup,
      dropoffStopId: dropoff,
      morningDeparture: '06:30',
      eveningReturn: '17:30',
      requestedDate: today(),
      pauseIfWaitlisted: true,
      note: 'Moving home',
    };
    return { user, sub, period, old, route, pickup, dropoff, input };
  }
  const decision = (
    id: string,
    action: 'waitlist' | 'pause' | 'resume' | 'apply' | 'cancel' | 'reject',
  ) => service.decide(id, admin, { action, note: 'Reviewed by operations' });
  const slot = (route: string) =>
    service.createSlot(admin, {
      routeId: route,
      morningDeparture: '06:30',
      eveningReturn: '17:30',
      availableFrom: today(),
    });
  const approve = (id: string, slotId: string) =>
    service.decide(id, admin, {
      action: 'approve',
      slotId,
      effectiveDate: today(),
      note: 'Seat verified',
    });

  it('serializes duplicate submissions and leaves current assignment untouched', async () => {
    const f = await fixture();
    const results = await Promise.allSettled([
      service.submit(f.user, f.input),
      service.submit(f.user, f.input),
    ]);
    expect(results.filter((r) => r.status === 'fulfilled')).toHaveLength(1);
    expect((await subs.findActiveByUser(f.user))?.routeId).toBe(f.old);
    expect(await service.list(f.user)).toHaveLength(1);
  });
  it('only one of two riders can hold the last recurring slot', async () => {
    const a = await fixture(),
      b = await fixture(a);
    const ra = await service.submit(a.user, a.input),
      rb = await service.submit(b.user, b.input),
      place = await slot(a.route);
    const results = await Promise.allSettled([approve(ra.id, place.id), approve(rb.id, place.id)]);
    expect(results.filter((r) => r.status === 'fulfilled')).toHaveLength(1);
    expect(
      (await pool.query(`SELECT status FROM commute_slots WHERE id=$1`, [place.id])).rows[0]
        ?.status,
    ).toBe('held');
  });
  it('requires consent, preserves rides and paid time, skips dispatch and expiry while paused', async () => {
    const f = await fixture();
    const no = await service.submit(f.user, { ...f.input, pauseIfWaitlisted: false });
    await decision(no.id, 'waitlist');
    await expect(decision(no.id, 'pause')).rejects.toMatchObject({ code: 'pause_not_authorized' });
    await decision(no.id, 'cancel');
    const request = await service.submit(f.user, f.input);
    await decision(request.id, 'waitlist');
    await decision(request.id, 'pause');
    expect(await subs.findActiveByUser(f.user)).toBeNull();
    expect((await subs.findActiveByRoute(f.old)).some((s) => s.id === f.sub)).toBe(false);
    expect((await subs.findEndedPeriods(new Date('2099-01-01'))).some((s) => s.id === f.sub)).toBe(
      false,
    );
    const lifecycle = new PgPaymentLifecycle(pool);
    await expect(
      lifecycle.createSubscriptionCheckout({
        userId: f.user,
        reference: 'pause-checkout',
        purpose: 'subscription',
        plan: 'monthly',
        routeId: f.route,
        currency: 'GHS',
        pricePesewas: 26400,
        ridesGranted: 44,
        farePesewas: 600,
        creditPesewasPerRide: 45,
        now: new Date('2099-01-01'),
      }),
    ).rejects.toThrow('Resume the paused subscription');
    // Force its original deadline into the past: the real maintenance entry
    // point must not convert a paused balance even when that deadline passes.
    await pool.query(
      `UPDATE subscription_periods SET period_end=now()-interval '1 day' WHERE id=$1`,
      [f.period],
    );
    expect((await lifecycle.closeEndedPeriods()).considered).toBe(0);
    await expect(
      service.decide(request.id, f.user, { action: 'cancel', note: 'withdraw' }, true),
    ).rejects.toMatchObject({ code: 'resume_required' });
    await pool.query(
      `UPDATE subscription_pauses SET started_at=started_at-interval '2 days' WHERE subscription_id=$1`,
      [f.sub],
    );
    await decision(request.id, 'resume');
    const extension = await pool.query(
      `SELECT EXTRACT(EPOCH FROM(extended_period_end-original_period_end))::float8 AS seconds FROM subscription_pauses WHERE subscription_id=$1`,
      [f.sub],
    );
    expect(extension.rows[0]?.seconds).toBeGreaterThanOrEqual(172800);
    expect(extension.rows[0]?.seconds).toBeLessThan(172805);
    expect(
      (
        await pool.query(
          `SELECT sum(delta_rides)::int AS rides FROM entitlement_ledger WHERE user_id=$1`,
          [f.user],
        )
      ).rows[0]?.rides,
    ).toBe(35);
    expect(await subs.findActiveByUser(f.user)).not.toBeNull();
  });
  it('applies once, cancels future old bookings, preserves period pricing and enforces new route/time', async () => {
    const f = await fixture(),
      trip = randomUUID();
    await pool.query(
      `INSERT INTO trips(id,route_id,scheduled_at) VALUES($1,$2,now()+interval '5 days')`,
      [trip, f.old],
    );
    await pool.query(
      `INSERT INTO reservations(user_id,trip_id,status,travel_date) VALUES($1,$2,'reserved',$3)`,
      [f.user, trip, today()],
    );
    const request = await service.submit(f.user, f.input),
      place = await slot(f.route);
    await approve(request.id, place.id);
    await decision(request.id, 'apply');
    await decision(request.id, 'apply');
    expect((await subs.findActiveByUser(f.user))?.routeId).toBe(f.route);
    expect(
      (await pool.query(`SELECT status FROM reservations WHERE user_id=$1`, [f.user])).rows[0]
        ?.status,
    ).toBe('operator_cancelled');
    expect(
      (
        await pool.query(`SELECT route_id,price_pesewas FROM subscription_periods WHERE id=$1`, [
          f.period,
        ])
      ).rows[0],
    ).toEqual({ route_id: f.old, price_pesewas: 26400 });
    await expect(
      pool.query(`INSERT INTO reservations(user_id,trip_id,status) VALUES($1,$2,'reserved')`, [
        f.user,
        trip,
      ]),
    ).rejects.toMatchObject({ code: 'P0001' });
    const next = randomUUID();
    await pool.query(`INSERT INTO trips(id,route_id,scheduled_at) VALUES($1,$2,$3::timestamptz)`, [
      next,
      f.route,
      `${today()}T06:30:00Z`,
    ]);
    const booking = await new PgReservationRepository(pool).createPending({
      userId: f.user,
      tripId: next,
      travelDate: today(),
      direction: 'morning',
    });
    expect(booking).toMatchObject({
      status: 'pending',
      tripId: next,
      pickupStopId: f.pickup,
      dropoffStopId: f.dropoff,
      subscriptionPeriodId: f.period,
    });
    expect(
      (await subs.findActiveByRoute(f.route, new Date(`${today()}T06:30:00Z`))).some(
        (s) => s.id === f.sub,
      ),
    ).toBe(true);
    expect(
      (await subs.findActiveByRoute(f.route, new Date(`${today()}T07:30:00Z`))).some(
        (s) => s.id === f.sub,
      ),
    ).toBe(false);
    await pool.query(`UPDATE trips SET scheduled_at=scheduled_at+interval '1 hour' WHERE id=$1`, [
      next,
    ]);
    await expect(
      pool.query(`INSERT INTO reservations(user_id,trip_id,status) VALUES($1,$2,'reserved')`, [
        f.user,
        next,
      ]),
    ).rejects.toMatchObject({ code: 'P0001' });
    expect((await service.events(request.id)).filter((e) => e.action === 'apply')).toHaveLength(1);
  });
  it('blocks unsettled trips and different fares without partial changes', async () => {
    const f = await fixture(),
      request = await service.submit(f.user, f.input),
      place = await slot(f.route);
    await pool.query(`UPDATE corridor_fares SET fare_pesewas=700 WHERE route_id=$1`, [f.route]);
    await expect(approve(request.id, place.id)).rejects.toMatchObject({
      code: 'fare_review_required',
    });
    await pool.query(`UPDATE corridor_fares SET fare_pesewas=600 WHERE route_id=$1`, [f.route]);
    await approve(request.id, place.id);
    const trip = randomUUID();
    await pool.query(
      `INSERT INTO trips(id,route_id,scheduled_at,status) VALUES($1,$2,now(),'active')`,
      [trip, f.old],
    );
    await pool.query(`INSERT INTO reservations(user_id,trip_id,status) VALUES($1,$2,'reserved')`, [
      f.user,
      trip,
    ]);
    await expect(decision(request.id, 'apply')).rejects.toMatchObject({ code: 'unsettled_trip' });
    expect((await subs.findActiveByUser(f.user))?.routeId).toBe(f.old);
    expect((await service.list(f.user))[0]?.status).toBe('approved');
  });
  it('expiry/refund closes pauses and approvals and releases held capacity', async () => {
    const f = await fixture(),
      request = await service.submit(f.user, f.input),
      place = await slot(f.route);
    await decision(request.id, 'waitlist');
    await decision(request.id, 'pause');
    await approve(request.id, place.id);
    await pool.query(`UPDATE subscriptions SET status='expired' WHERE id=$1`, [f.sub]);
    const row = (await service.list(f.user))[0];
    expect(row).toMatchObject({ status: 'cancelled', paused: false });
    expect((await service.slots()).find((s) => s.id === place.id)?.status).toBe('available');
  });
  it('erasure scrubs rider notes, closes requests and releases held slots', async () => {
    const f = await fixture(),
      request = await service.submit(f.user, f.input),
      place = await slot(f.route);
    await approve(request.id, place.id);
    await pool.query(`UPDATE users SET deleted_at=now() WHERE id=$1`, [f.user]);
    expect(await service.list(f.user)).toHaveLength(0);
    expect(
      (
        await pool.query(`SELECT status,note,decision_note FROM commute_requests WHERE id=$1`, [
          request.id,
        ])
      ).rows[0],
    ).toEqual({ status: 'cancelled', note: '', decision_note: null });
    expect((await service.events(request.id)).every((event) => event.note === '')).toBe(true);
    expect((await service.slots()).find((s) => s.id === place.id)?.status).toBe('available');
  });
  it('rejects unauthorized decisions, reversed stops and past dates', async () => {
    const f = await fixture();
    await expect(
      service.submit(f.user, { ...f.input, pickupStopId: f.dropoff, dropoffStopId: f.pickup }),
    ).rejects.toMatchObject({ code: 'invalid_stops' });
    await expect(
      service.submit(f.user, { ...f.input, requestedDate: '2000-01-01' }),
    ).rejects.toMatchObject({ code: 'past_date' });
    const request = await service.submit(f.user, f.input);
    await expect(
      service.decide(request.id, f.user, { action: 'approve', note: 'self approve' }),
    ).rejects.toMatchObject({ code: 'forbidden' });
    await expect(
      service.decide(request.id, randomUUID(), { action: 'cancel', note: 'withdraw' }, true),
    ).rejects.toMatchObject({ code: 'not_found' });
  });
  it('HTTP roles, validation, durable submit, rider isolation and ops decision work together', async () => {
    const f = await fixture(),
      other = await fixture(),
      app = await buildApp({ auth, commuteService: service });
    try {
      const jwt = createJwtService(auth);
      const headers = {
        authorization: `Bearer ${await jwt.signAccessToken({ userId: f.user, role: 'commuter' })}`,
      };
      const ops = {
        authorization: `Bearer ${await jwt.signAccessToken({ userId: admin, role: 'admin' })}`,
      };
      expect((await app.inject({ method: 'GET', url: '/me/commute-requests' })).statusCode).toBe(
        401,
      );
      expect(
        (await app.inject({ method: 'GET', url: '/admin/commute-requests', headers })).statusCode,
      ).toBe(403);
      expect(
        (
          await app.inject({
            method: 'POST',
            url: '/me/commute-requests',
            headers,
            payload: { ...f.input, morningDeparture: '17:00' },
          })
        ).statusCode,
      ).toBe(400);
      const response = await app.inject({
        method: 'POST',
        url: '/me/commute-requests',
        headers,
        payload: f.input,
      });
      expect(response.statusCode, response.body).toBe(200);
      const id = response.json<{ id: string }>().id;
      await service.submit(other.user, other.input);
      const mine = await app.inject({ method: 'GET', url: '/me/commute-requests', headers });
      expect(mine.json().requests).toHaveLength(1);
      const result = await app.inject({
        method: 'POST',
        url: `/admin/commute-requests/${id}/decision`,
        headers: ops,
        payload: { action: 'waitlist', note: 'No slot yet' },
      });
      expect(result.statusCode, result.body).toBe(200);
      expect((await service.list(f.user))[0]?.status).toBe('waitlisted');
    } finally {
      await app.close();
    }
  });
});
