// Candidate adapter: the replacement backend in services/api-next.
//
// Test infrastructure only. It translates the catalog's domain actions into
// the replacement's own services and reads observations back out of committed
// rows. It never imports the catalog's expectations and performs no arithmetic
// assertion of its own; where the two models represent the same fact
// differently, the mapping is named and recorded as evidence.
import { createHmac, randomUUID } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { ROOT } from './support.mjs';

const NEXT = resolve(ROOT, 'services/api-next');
const load = (file) => import(pathToFileURL(resolve(NEXT, 'src', file)));
const { PaystackEvidence } = await load('payments/provider.ts');
const { FinancialFoundation } = await load('payments/foundation.ts');
const { PaymentRecovery } = await load('payments/recovery.ts');
const { Pricing } = await load('payments/pricing.ts');
const { MembershipService } = await load('membership/service.ts');
const { default: pg } = await import(pathToFileURL(resolve(NEXT, 'node_modules/pg/lib/index.js')));
const { Pool } = pg;

const SECRET = ['sk', 'test', 'harnesssynthetic'].join('_');
const KEY = Buffer.alloc(32, 7);
const hex64 = () => randomUUID().replaceAll('-', '') + randomUUID().replaceAll('-', '');
const normalizedSql = (sql) =>
  String(typeof sql === 'object' ? sql.text : sql)
    .replace(/\s+/g, ' ')
    .trim();
// The catalog names outcomes; each implementation reports them in its own
// words. These are the replacement's words for the same refusals.
const errorKind = (error) =>
  ({
    purchase_unresolved: 'pending_checkout',
    period_service_unsettled: 'period_close_blocked',
    period_paused: 'period_close_blocked',
    period_payment_blocked: 'period_close_blocked',
  })[error?.code] ??
  error?.code ??
  error?.constructor?.name;
const deferred = () => {
  let resolvePromise;
  const promise = new Promise((r) => {
    resolvePromise = r;
  });
  return { promise, resolve: resolvePromise };
};
async function until(check, label) {
  const end = Date.now() + 10000;
  while (Date.now() < end) {
    if (await check()) return;
    await delay(20);
  }
  throw new Error(`Timed out proving ${label}`);
}

/** Paystack with its network calls replaced by the harness's own facts. */
class HarnessEvidence extends PaystackEvidence {
  constructor() {
    super(SECRET, KEY);
    this.facts = new Map();
  }
  async verify(reference) {
    const raw = this.facts.get(reference);
    if (!raw) throw new Error('provider_unavailable');
    return raw;
  }
}

export async function createAdapter({ databaseUrl }) {
  const observer = new Pool({
    connectionString: databaseUrl,
    max: 3,
    application_name: 'harness-candidate-observer',
    statement_timeout: 15000,
  });
  const observerErrors = [];
  observer.on('error', (error) => observerErrors.push(error.code ?? error.name));
  const evidence = [];
  const riders = new Map();
  const purchases = new Map();
  const references = new Map();
  const providerIds = new Map();
  const pids = new Set();
  const provider = new HarnessEvidence();
  let workers;
  let pool;
  let foundation;
  let recovery;
  let membership;
  let pricing;
  let hook = null;
  let result = null;
  let corridor;
  let claim = null;

  const providerId = (key) => {
    if (!providerIds.has(key)) providerIds.set(key, String(100000 + providerIds.size));
    return providerIds.get(key);
  };
  const logicalUser = (id) =>
    [...riders].find(([, value]) => value === id)?.[0] ?? (id ? `unmapped:${id}` : null);
  const logicalPurchase = (id) =>
    [...purchases].find(([, value]) => value === id)?.[0] ?? (id ? `unmapped:${id}` : null);
  const purchaseRow = async (name) => {
    const row = (
      await observer.query('SELECT * FROM app.purchases WHERE id=$1', [purchases.get(name)])
    ).rows[0];
    if (!row) throw new Error(`Missing purchase ${name}`);
    return row;
  };
  const attemptRow = async (name) =>
    (
      await observer.query(
        'SELECT * FROM app.payment_attempts WHERE purchase_id=$1 ORDER BY created_at DESC,id DESC LIMIT 1',
        [purchases.get(name)],
      )
    ).rows[0];
  const actorFor = (name) => ({ userId: riders.get(name), sessionId: riders.get(name) });

  function startWorker() {
    workers = new Pool({
      connectionString: databaseUrl,
      max: 8,
      application_name: 'harness-candidate-worker',
      statement_timeout: 15000,
    });
    workers.on('error', (error) =>
      evidence.push({ kind: 'worker-connection-error', code: error.code ?? error.name }),
    );
    workers.on('connect', (client) =>
      client.on('error', (error) =>
        evidence.push({ kind: 'checked-out-connection-error', code: error.code ?? error.name }),
      ),
    );
    // The same interception the baseline adapter uses, so a fault can be
    // injected at a named statement rather than at a wall-clock moment.
    pool = {
      async connect() {
        const client = await workers.connect();
        const pid = (await client.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
        pids.add(pid);
        return {
          async query(sql, args) {
            const text = normalizedSql(sql);
            if (hook?.before) await hook.before({ text, client, pid });
            const outcome = await client.query(sql, args);
            if (hook?.after) await hook.after({ text, client, pid });
            return outcome;
          },
          release: (...args) => client.release(...args),
        };
      },
      query: (...args) => workers.query(...args),
      end: () => workers.end(),
    };
    const authorizeSession = async (c, actor) => {
      const row = (
        await c.query(
          `SELECT 1 FROM app.auth_sessions WHERE user_id=$1 AND revoked_at IS NULL
          AND expires_at>clock_timestamp() FOR SHARE`,
          [actor.userId],
        )
      ).rowCount;
      if (!row) throw new Error('Harness session revoked');
    };
    pricing = new Pricing({ pool, authorizeSession, cursorSecret: Buffer.alloc(32, 3) });
    membership = new MembershipService({
      pool,
      authorizeSession,
      cursorSecret: Buffer.alloc(32, 3),
      fareForSelection: pricing.fareForSelection,
    });
    foundation = new FinancialFoundation({
      pool,
      environment: 'test',
      authorizeSession,
      assertCheckoutAllowed: membership.assertCheckoutAllowed,
      assertPeriodCanClose: membership.assertPeriodCanClose,
      materializeAssignment: membership.materializeAssignment,
      quote: pricing.quote,
    });
    recovery = new PaymentRecovery({
      pool,
      provider,
      foundation,
      authorizeSession,
      cursorSecret: Buffer.alloc(32, 3),
      reversePeriod: membership.reversePeriod,
    });
  }

  /** One corridor and one published price list, so the quote is authoritative. */
  async function seedCorridor(terms) {
    const id = async (sql, args = []) =>
      (await observer.query(sql + ' RETURNING id', args)).rows[0].id;
    const operator = await id("INSERT INTO app.users(role) VALUES ('admin')");
    const route = await id("INSERT INTO app.routes(name) VALUES ('Harness corridor')");
    const legs = [];
    for (const direction of ['outbound', 'return']) {
      const pattern = await id(
        'INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,$2)',
        [route, direction],
      );
      const version = await id(
        'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1)',
        [pattern],
      );
      const stop = await id(
        "INSERT INTO app.stops(name,latitude,longitude) VALUES ('Harness',5.6,-0.2)",
      );
      const occurrences = [];
      for (let ordinal = 0; ordinal < 2; ordinal++)
        occurrences.push(
          await id(
            `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
            VALUES ($1,$2,$3,'Harness',5.6,-0.2)`,
            [version, stop, ordinal],
          ),
        );
      const geometry = await id(
        `INSERT INTO app.route_geometries(pattern_version_id,source,line)
        VALUES ($1,'configured',ST_GeomFromText('LINESTRING(-0.2 5.6,-0.21 5.6,-0.2 5.6)',4326))`,
        [version],
      );
      for (const [i, occurrence] of occurrences.entries())
        await observer.query('INSERT INTO app.geometry_stop_distances VALUES ($1,$2,$3,$4)', [
          geometry,
          version,
          occurrence,
          i * 1000,
        ]);
      await observer.query("UPDATE app.route_geometries SET state='published' WHERE id=$1", [
        geometry,
      ]);
      await observer.query(
        `UPDATE app.route_pattern_versions SET state='published',geometry_id=$2,
        effective_from='2020-01-01' WHERE id=$1`,
        [version, geometry],
      );
      const departure = await id('INSERT INTO app.service_departures(pattern_id) VALUES ($1)', [
        pattern,
      ]);
      const schedule = await id(
        `INSERT INTO app.service_schedules(departure_id,pattern_id,pattern_version_id,service_window,local_departure,weekdays,effective_from)
        VALUES ($1,$2,$3,$4,'06:30',ARRAY[1,2,3,4,5,6,7]::smallint[],'2020-01-01')`,
        [departure, pattern, version, direction === 'outbound' ? 'morning' : 'evening'],
      );
      legs.push({
        direction,
        scheduleId: schedule,
        patternVersionId: version,
        pickupOccurrenceId: occurrences[0],
        dropoffOccurrenceId: occurrences[1],
      });
    }
    // The replacement prices from the database rather than from the caller, so
    // the catalog's terms are published here and the quote is read back.
    await observer.query(
      `INSERT INTO app.plan_pricing(plan,rides_per_period,price_multiplier_bp,take_rate_bp,credit_per_ride_pesewas)
      VALUES ($1,$2,10000,0,$3)
      ON CONFLICT (plan) DO UPDATE SET rides_per_period=EXCLUDED.rides_per_period,
        price_multiplier_bp=EXCLUDED.price_multiplier_bp,take_rate_bp=EXCLUDED.take_rate_bp,
        credit_per_ride_pesewas=EXCLUDED.credit_per_ride_pesewas`,
      [terms.plan, terms.rides, terms.conversionRate],
    );
    await observer.query(
      `INSERT INTO app.route_fares(route_id,amount_pesewas,effective_from,created_by,command_id)
      VALUES ($1,$2,'2020-01-01',$3,$4)`,
      [route, terms.fare, operator, randomUUID()],
    );
    evidence.push({
      kind: 'authoritative-pricing',
      note: 'Catalog terms published to app.plan_pricing and app.route_fares; the checkout quote is read from them, not passed in.',
      terms,
    });
    corridor = { route, legs, operator };
  }

  const checkoutInput = () => ({
    plan: 'monthly',
    routeId: corridor.route,
    legs: corridor.legs,
    useCredit: true,
  });

  async function settlement(name, at) {
    const attempt = await attemptRow(name);
    return {
      reference: attempt.reference,
      environment: 'test',
      amountPesewas: attempt.amount_pesewas,
      currency: 'GHS',
      transactionId: providerId(name),
      paidAt: new Date(at),
      channel: 'mobile_money',
      feesPesewas: 0,
    };
  }
  const successBody = (s) =>
    JSON.stringify({
      event: 'charge.success',
      data: {
        id: s.transactionId,
        reference: s.reference,
        status: 'success',
        amount: s.amountPesewas,
        currency: 'GHS',
        domain: 'test',
        channel: s.channel,
        fees: s.feesPesewas,
        paid_at: s.paidAt.toISOString(),
      },
    });

  async function contend(step) {
    const outcomes = await Promise.allSettled(step.actions.map((action) => act(action)));
    const errors = outcomes
      .filter((o) => o.status === 'rejected')
      .map((o) => errorKind(o.reason))
      .sort();
    return {
      fulfilled: outcomes.filter((o) => o.status === 'fulfilled').length,
      rejected: outcomes.length - outcomes.filter((o) => o.status === 'fulfilled').length,
      errors,
    };
  }

  /**
   * Prove two workers overlap on one inbox row.
   *
   * The replacement holds its claim in a row lock for the length of the
   * processing transaction rather than in a status column with a lease, so the
   * overlap is proven by blocking inside that transaction and watching the
   * second worker skip the locked row.
   */
  async function raceInbox() {
    const resume = deferred();
    let reached = false;
    hook = {
      after: async ({ text }) => {
        if (reached || !text.includes('FROM app.payment_events') || !text.includes('SKIP LOCKED'))
          return;
        reached = true;
        hook = null;
        await resume.promise;
      },
    };
    const first = recovery.processInbox(10);
    const firstSettled = first.then(
      (value) => ({ value }),
      (error) => ({ error }),
    );
    try {
      await until(() => reached, 'first worker claimed an inbox row');
      const second = await recovery.processInbox(10);
      evidence.push({
        kind: 'inbox-claim-overlap',
        note: 'Second worker ran while the first held the row lock inside its transaction.',
        secondConsidered: second.considered,
      });
      if (second.considered !== 0)
        throw new Error('Inbox overlap was not proven: the second worker claimed the same row');
      resume.resolve();
      const completed = await firstSettled;
      if (completed.error) throw completed.error;
      return {
        processed: completed.value.succeeded + second.succeeded,
        failed: completed.value.failed + second.failed,
      };
    } finally {
      resume.resolve();
      await firstSettled;
      hook = null;
    }
  }

  /** One consumed ride is one boarded reservation, which is what the model says. */
  async function consume(name, rides) {
    const purchase = await purchaseRow(name);
    const period = (
      await observer.query('SELECT * FROM app.billing_periods WHERE purchase_id=$1', [purchase.id])
    ).rows[0];
    const assignment = (
      await observer.query(
        'SELECT * FROM app.commute_assignments WHERE period_id=$1 ORDER BY effective_from LIMIT 1',
        [period.id],
      )
    ).rows[0];
    const legs = (
      await observer.query(
        'SELECT * FROM app.commute_selection_legs WHERE selection_id=$1 ORDER BY direction',
        [assignment.selection_id],
      )
    ).rows;
    const start = new Date(period.starts_at);
    for (let taken = 0; taken < rides; taken++) {
      const leg = legs[taken % legs.length];
      const day = new Date(start.getTime() + Math.floor(taken / legs.length) * 86400000);
      const date = day.toISOString().slice(0, 10);
      const client = await observer.connect();
      try {
        await client.query('BEGIN');
        const vehicle = (
          await client.query(
            'INSERT INTO app.vehicles(plate,capacity) VALUES ($1,18) RETURNING id',
            [`H ${randomUUID().slice(0, 8)}`],
          )
        ).rows[0].id;
        const trip = (
          await client.query(
            `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,vehicle_id)
            SELECT id,departure_id,pattern_version_id,$2::date,$2::date+local_departure,$3
            FROM app.service_schedules WHERE id=$1 RETURNING id`,
            [leg.schedule_id, date, vehicle],
          )
        ).rows[0].id;
        // Charge, attendance and debit commit together, and the charge is
        // only accepted while the seat is still reserved, so the order here
        // is the order the boarding service itself writes them in.
        const reservation = (
          await client.query(
            `INSERT INTO app.reservations(user_id,period_id,assignment_id,selection_id,direction,service_date,
              trip_id,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id,status,source)
            VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,'reserved','confirmation') RETURNING id`,
            [
              purchase.user_id,
              period.id,
              assignment.id,
              assignment.selection_id,
              leg.direction,
              date,
              trip,
              leg.schedule_id,
              leg.pattern_version_id,
              leg.pickup_occurrence_id,
              leg.dropoff_occurrence_id,
            ],
          )
        ).rows[0];
        const command = (
          await client.query(
            `INSERT INTO app.boarding_commands(actor_user_id,operation,target,key_hash,input_hash,response_body)
            VALUES ($1,'boardRider',$2,$3,$4,$5::jsonb) RETURNING id`,
            [
              corridor.operator,
              trip,
              hex64(),
              hex64(),
              JSON.stringify({
                reservationId: reservation.id,
                status: 'boarded',
                alreadyApplied: false,
                chargedRides: 1,
              }),
            ],
          )
        ).rows[0].id;
        await client.query(
          `INSERT INTO app.reservation_charges(reservation_id,period_id,user_id,trip_id,reason,command_id,charged_at)
          VALUES ($1,$2,$3,$4,'boarding',$5,clock_timestamp())`,
          [reservation.id, period.id, purchase.user_id, trip, command],
        );
        await client.query(
          `INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides,reservation_id)
          VALUES ($1,$2,'boarding',-1,$3)`,
          [purchase.user_id, period.id, reservation.id],
        );
        // The settlement guard wants the two timestamps identical, and a
        // timestamp that has been through JavaScript has lost its microseconds.
        await client.query(
          `UPDATE app.reservations r SET status='boarded',settled_at=c.charged_at
          FROM app.reservation_charges c WHERE c.reservation_id=r.id AND r.id=$1`,
          [reservation.id],
        );
        await client.query('COMMIT');
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    }
  }

  async function reserve(name) {
    const purchase = await purchaseRow(name);
    const period = (
      await observer.query('SELECT * FROM app.billing_periods WHERE purchase_id=$1', [purchase.id])
    ).rows[0];
    const assignment = (
      await observer.query('SELECT * FROM app.commute_assignments WHERE period_id=$1 LIMIT 1', [
        period.id,
      ])
    ).rows[0];
    const leg = (
      await observer.query(
        "SELECT * FROM app.commute_selection_legs WHERE selection_id=$1 AND direction='outbound'",
        [assignment.selection_id],
      )
    ).rows[0];
    const date = new Date(new Date(period.effective_ends_at).getTime() - 86400000)
      .toISOString()
      .slice(0, 10);
    const vehicle = (
      await observer.query('INSERT INTO app.vehicles(plate,capacity) VALUES ($1,18) RETURNING id', [
        `H ${randomUUID().slice(0, 8)}`,
      ])
    ).rows[0].id;
    const trip = (
      await observer.query(
        `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,vehicle_id)
        SELECT id,departure_id,pattern_version_id,$2::date,$2::date+local_departure,$3
        FROM app.service_schedules WHERE id=$1 RETURNING id`,
        [leg.schedule_id, date, vehicle],
      )
    ).rows[0].id;
    await observer.query(
      `INSERT INTO app.reservations(user_id,period_id,assignment_id,selection_id,direction,service_date,
        trip_id,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id,status,source)
      VALUES ($1,$2,$3,$4,'outbound',$5,$6,$7,$8,$9,$10,'reserved','confirmation')`,
      [
        purchase.user_id,
        period.id,
        assignment.id,
        assignment.selection_id,
        date,
        trip,
        leg.schedule_id,
        leg.pattern_version_id,
        leg.pickup_occurrence_id,
        leg.dropoff_occurrence_id,
      ],
    );
  }

  async function closeBatch(at) {
    const value = await recovery.closeEndedPeriods(new Date(at), 100);
    return {
      considered: value.considered,
      closed: value.succeeded,
      blocked: value.blocked,
      failed: value.failed,
      failures: await Promise.all(
        value.failures.map(async (failure) => ({
          purchase: logicalPurchase(
            (
              await observer.query('SELECT purchase_id FROM app.billing_periods WHERE id=$1', [
                failure.resourceId,
              ])
            ).rows[0]?.purchase_id,
          ),
          reason:
            failure.reason === 'period_not_convertible' ? 'unconvertible_period' : failure.reason,
        })),
      ),
    };
  }

  async function act(step) {
    let value = null;
    switch (step.action) {
      case 'rider': {
        const id = (
          await observer.query(
            "INSERT INTO app.users(role,display_name) VALUES ('commuter',$1) RETURNING id",
            [`Synthetic ${step.name}`],
          )
        ).rows[0].id;
        riders.set(step.name, id);
        await observer.query(
          `INSERT INTO app.auth_sessions(user_id,expires_at)
          VALUES ($1, clock_timestamp() + interval '2 hours')`,
          [id],
        );
        if (step.credit) {
          const adjustment = (
            await observer.query(
              `INSERT INTO app.credit_adjustments(user_id,actor_user_id,delta_pesewas,reason)
              VALUES ($1,$2,$3,'Harness compensation') RETURNING id`,
              [id, corridor.operator, step.credit],
            )
          ).rows[0].id;
          await observer.query(
            `INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,adjustment_id)
            VALUES ($1,'adjustment',$2,$3)`,
            [id, step.credit, adjustment],
          );
        }
        break;
      }
      case 'checkout': {
        const purchase = await foundation.checkout(
          actorFor(step.owner),
          checkoutInput(),
          randomUUID(),
          new Date(step.at),
        );
        purchases.set(step.purchase, purchase.id);
        references.set(step.purchase, purchase.attempt.reference);
        value = { cash: purchase.cashDuePesewas, creditApplied: purchase.appliedCreditPesewas };
        break;
      }
      case 'fulfill':
        value = await foundation.fulfill(await settlement(step.purchase, step.at));
        break;
      case 'closeAtBoundary': {
        const purchase = await purchaseRow(step.purchase);
        const end = (
          await observer.query(
            'SELECT effective_ends_at FROM app.billing_periods WHERE purchase_id=$1',
            [purchase.id],
          )
        ).rows[0].effective_ends_at;
        value = await closeBatch(new Date(end.getTime() + step.offsetMs));
        break;
      }
      case 'close':
        value = await closeBatch(step.at);
        break;
      case 'consume':
        await consume(step.purchase, step.rides);
        break;
      case 'reserve':
        await reserve(step.purchase);
        break;
      case 'malformRate':
        await malform(step.purchase);
        break;
      case 'contend':
        value = await contend(step);
        break;
      case 'expectRejection': {
        let rejected = false;
        try {
          await act(step.operation);
        } catch (error) {
          rejected = true;
          value = errorKind(error);
        }
        if (!rejected) throw new Error('Operation unexpectedly succeeded');
        break;
      }
      case 'acceptSuccess': {
        const s = await settlement(step.purchase, step.at);
        const body = successBody(s);
        const raw = Buffer.from(body);
        await Promise.all(
          Array.from({ length: step.copies ?? 1 }, () => recovery.acceptWebhook(raw, sign(raw))),
        );
        break;
      }
      case 'raceInbox':
        value = await raceInbox();
        break;
      case 'processInbox': {
        const done = await recovery.processInbox(10);
        value = { processed: done.succeeded, failed: done.failed };
        break;
      }
      case 'claimOnly':
        value = await claimOnly();
        break;
      case 'expireLease':
        value = await releaseStrandedClaim();
        break;
      case 'restartWorker':
        if (claim) {
          claim.release(true);
          claim = null;
        }
        await workers.end();
        startWorker();
        // A failed delivery is retried on an exponential backoff here rather
        // than immediately. The wait is real and is not what these scenarios
        // are about, so the harness moves it, and says so.
        {
          const moved = await observer.query(
            "UPDATE app.payment_events SET available_at=clock_timestamp() WHERE state='ready' AND available_at>clock_timestamp()",
          );
          if (moved.rowCount)
            evidence.push({
              kind: 'fixture-clock-adjustment',
              field: 'payment_events.available_at',
              reason: 'bring a backed-off retry forward without fake global timers',
              rows: moved.rowCount,
            });
        }
        break;
      case 'terminateAfterAllocation': {
        hook = {
          after: async ({ text, client, pid }) => {
            if (!text.startsWith('INSERT INTO app.ride_entries') || !text.includes("'allocation'"))
              return;
            hook = null;
            const inside = (
              await client.query(
                "SELECT count(*)::int AS n FROM app.ride_entries WHERE reason='allocation'",
              )
            ).rows[0].n;
            if (inside < 1) throw new Error('Fault point reached before allocation was written');
            const terminated = (
              await observer.query('SELECT pg_terminate_backend($1) AS terminated', [pid])
            ).rows[0].terminated;
            evidence.push({
              kind: 'backend-terminated-after-write',
              pid,
              visibleAllocationsInsideTransaction: inside,
              terminated,
            });
            if (!terminated) throw new Error('Backend termination failed');
          },
        };
        break;
      }
      case 'failAcknowledgement': {
        hook = {
          before: async ({ text }) => {
            // The acknowledgement is a parameterised update, not a literal.
            // Matching on the word 'processed' would silently never fire.
            if (!text.startsWith('UPDATE app.payment_events SET state=$2')) return;
            hook = null;
            evidence.push({ kind: 'injected-acknowledgement-failure' });
            throw new Error('Harness interrupted acknowledgement after committed fulfilment');
          },
        };
        break;
      }
      case 'reconcile': {
        const attempt = await attemptRow(step.purchase);
        // The baseline backdates the payment row to sit behind the cutoff.
        // Attempt identity is immutable here, so the cutoff moves instead: the
        // same attempt, the same "older than an hour" rule, no rewritten row.
        evidence.push({
          kind: 'reconcile-cutoff-substitution',
          note: 'app.payment_attempts is immutable, so the discovery cutoff is taken from real time rather than by backdating the attempt.',
        });
        const s = await settlement(step.purchase, step.at);
        provider.facts.set(
          attempt.reference,
          Buffer.from(
            JSON.stringify({
              event: 'transaction.verify',
              data: JSON.parse(successBody(s)).data,
            }),
          ),
        );
        const done = await recovery.reconcile(new Date(Date.now() + 3600000), 100);
        value = {
          considered: done.considered,
          fulfilled: done.succeeded,
          failed: done.failed,
          errors: done.failures.length,
        };
        break;
      }
      case 'refund': {
        const attempt = await attemptRow(step.purchase);
        const amount = step.amount === 'full' ? attempt.amount_pesewas : step.amount;
        await deliver({
          event: `refund.${step.status === 'processed' ? 'processed' : step.status}`,
          data: {
            transaction_reference: attempt.reference,
            refund_reference: step.identity,
            status: step.status,
            amount,
            currency: 'GHS',
            domain: 'test',
          },
        });
        value = await drain();
        break;
      }
      case 'dispute': {
        const attempt = await attemptRow(step.purchase);
        const event = {
          created: 'charge.dispute.create',
          reminded: 'charge.dispute.remind',
          resolved: 'charge.dispute.resolve',
        }[step.status];
        await deliver({
          event,
          data: {
            id: providerId(step.identity),
            amount: step.amount,
            currency: 'GHS',
            domain: 'test',
            resolution: step.resolution,
            transaction: { reference: attempt.reference, domain: 'test', currency: 'GHS' },
          },
        });
        value = await drain();
        break;
      }
      case 'moneyMetadata':
        value = await moneyMetadata();
        break;
      default:
        throw new Error(`Unknown domain action ${step.action}`);
    }
    result = value;
    return value;
  }

  /** The provider authenticates the exact bytes; the harness holds the secret. */
  const sign = (raw) => createHmac('sha512', SECRET).update(raw).digest('hex');
  async function deliver(envelope) {
    const raw = Buffer.from(JSON.stringify(envelope));
    await recovery.acceptWebhook(raw, sign(raw));
  }
  /** Provider facts only become effects through the inbox, so drain it. */
  async function drain() {
    const done = await recovery.processInbox(50);
    return { processed: done.succeeded, failed: done.failed };
  }

  /**
   * Hold a claim without doing the work.
   *
   * The baseline writes `processing` into the row and relies on a five-minute
   * lease. This model claims by locking the row inside the processing
   * transaction, so the claim is held here the same way a worker holds it, and
   * is visible to everyone else as a row they must skip.
   */
  async function claimOnly() {
    if (claim) throw new Error('A claim is already held');
    const client = await workers.connect();
    await client.query('BEGIN');
    const rows = (
      await client.query(
        "SELECT id FROM app.payment_events WHERE state='ready' FOR UPDATE SKIP LOCKED",
      )
    ).rows;
    claim = client;
    evidence.push({
      kind: 'inbox-claim-held',
      note: 'Claim held as a row lock inside an open transaction, not as a status column with a lease.',
      claimed: rows.length,
    });
    return rows.length;
  }
  /**
   * The baseline's lease equivalent.
   *
   * There is no lease to expire here: a claim is a row lock inside the
   * processing transaction, so an interrupted worker's claim is released by
   * the server when its backend goes away. This proves that rather than
   * pretending a status column exists.
   */
  async function releaseStrandedClaim() {
    if (!claim) throw new Error('No claim is held');
    const pid = (await claim.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
    const held = claim;
    claim = null;
    // Terminating the holder is what the lease exists to survive. There is no
    // interval to wait out: the server drops the lock when the backend goes,
    // so the row is available to the next worker immediately.
    const terminated = (await observer.query('SELECT pg_terminate_backend($1) AS done', [pid]))
      .rows[0].done;
    held.release(true);
    evidence.push({
      kind: 'claim-release-substitution',
      note: 'No processing lease exists to expire: the claim is a row lock, released by the server when the interrupted backend ends.',
      terminatedBackend: pid,
      terminated,
    });
    return terminated ? 1 : 0;
  }

  async function malform(name) {
    // The baseline nulls the period's own conversion rate. The replacement
    // freezes that rate on the purchase as NOT NULL, so that exact state cannot
    // exist. The equivalent unconvertible period is one holding more rides than
    // were ever purchased, which close refuses for the same reason: its terms
    // cannot produce an honest conversion.
    const purchase = await purchaseRow(name);
    const period = (
      await observer.query('SELECT id FROM app.billing_periods WHERE purchase_id=$1', [purchase.id])
    ).rows[0];
    await observer.query(
      `INSERT INTO app.period_closures(period_id,user_id,rides_converted,conversion_rate_pesewas,credit_granted_pesewas,closed_at)
      VALUES ($1,$2,0,$3,0,clock_timestamp())`,
      [period.id, purchase.user_id, purchase.conversion_rate_pesewas],
    );
    evidence.push({
      kind: 'pay-08-fixture-substitution',
      note: 'The baseline nulls the period conversion rate. Here the rate is frozen NOT NULL on the purchase, the purchase terms are immutable by trigger, and a period carries no copy, so a missing or malformed rate is unrepresentable. The one unconvertible period this schema does permit is a half-written close: a closure row against a period that is still open.',
      periodId: period.id,
    });
  }

  async function moneyMetadata() {
    const fields = {
      cash: ['purchases', 'cash_due_pesewas'],
      gross: ['purchases', 'price_pesewas'],
      appliedCredit: ['purchases', 'applied_credit_pesewas'],
      fare: ['purchases', 'fare_pesewas'],
      conversionRate: ['purchases', 'conversion_rate_pesewas'],
      fees: ['payment_attempts', 'fees_pesewas'],
      refunded: ['payment_refunds', 'amount_pesewas'],
    };
    const rows = (
      await observer.query(
        `SELECT c.relname AS table, a.attname, col_description(a.attrelid,a.attnum) AS comment
        FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid
        JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE n.nspname='app' AND a.attnum>0 AND NOT a.attisdropped`,
      )
    ).rows;
    evidence.push({ kind: 'money-column-comments', rows: rows.filter((r) => r.comment) });
    return Object.fromEntries(
      Object.entries(fields).map(([name, [table, column]]) => [
        name,
        rows
          .find((r) => r.table === table && r.attname === column)
          ?.comment?.toLowerCase()
          .includes('pesewas')
          ? 'pesewas'
          : 'undocumented',
      ]),
    );
  }

  async function observe() {
    const tables = {};
    for (const table of [
      'users',
      'memberships',
      'purchases',
      'payment_attempts',
      'billing_periods',
      'credit_holds',
      'credit_entries',
      'ride_entries',
      'period_closures',
      'payment_refunds',
      'payment_disputes',
      'payment_reversals',
      'payment_reviews',
      'payment_access_blocks',
    ])
      tables[table] = (await observer.query(`SELECT * FROM app.${table}`)).rows;
    const allEvents = (
      await observer.query('SELECT id,source,state,attempts,reason FROM app.payment_events')
    ).rows;
    // Both models call the durable record of provider *deliveries* the inbox.
    // This one also stores evidence it fetched itself, under source 'verify';
    // counting that as a delivery would make a recovered payment look like a
    // webhook that arrived. Verify rows stay in the raw evidence.
    const events = allEvents.filter((e) => e.source === 'webhook');
    // Which rows a worker is holding right now, asked of the lock manager
    // rather than read out of a status column.
    const free = new Set(
      (
        await observer.query(
          "SELECT id FROM app.payment_events WHERE state='ready' FOR UPDATE SKIP LOCKED",
        )
      ).rows.map((r) => r.id),
    );
    const held = new Set(
      events.filter((e) => e.state === 'ready' && !free.has(e.id)).map((e) => e.id),
    );
    const sum = (rows, column) => rows.reduce((n, row) => n + Number(row[column]), 0);
    const riderStates = {};
    for (const [name, id] of riders) {
      const member = tables.memberships.find((m) => m.user_id === id);
      const periods = tables.billing_periods
        .filter((p) => p.membership_id === member?.id)
        .sort((a, b) => a.starts_at - b.starts_at);
      // Two independent facts the baseline keeps in one column. Coverage is
      // live while some period is open; the current purchase is the one whose
      // coverage runs latest. This model stores neither as a pointer, so both
      // are derived, and they are derived separately because they are not the
      // same question.
      const open = periods.find((p) => p.state === 'open');
      const current = periods.at(-1);
      const blocked = tables.payment_access_blocks.some(
        (b) => b.period_id === (open ?? current)?.id && !b.released_at,
      );
      const credit = sum(
        tables.credit_entries.filter((e) => e.user_id === id),
        'delta_pesewas',
      );
      const held = sum(
        tables.credit_holds.filter((h) => h.user_id === id && h.state === 'held'),
        'amount_pesewas',
      );
      riderStates[name] = {
        credit,
        held,
        available: credit - held,
        rides: sum(
          tables.ride_entries.filter((e) => e.user_id === id),
          'delta_rides',
        ),
        // The replacement keeps membership lifecycle and coverage state apart.
        // The baseline's single subscription status is those two facts read
        // together, which is what the catalog names.
        membership: !member ? null : blocked ? 'suspended' : open ? 'active' : 'expired',
        currentPurchase: current ? logicalPurchase(current.purchase_id) : null,
      };
    }
    const purchaseStates = {};
    for (const p of tables.purchases) {
      const period = tables.billing_periods.find((b) => b.purchase_id === p.id);
      const movements = tables.ride_entries.filter((e) => e.period_id === period?.id);
      const closures = tables.period_closures.filter((c) => c.period_id === period?.id);
      const conversion = tables.credit_entries.filter(
        (e) => e.reason === 'month_end_conversion' && closures.some((c) => c.id === e.closure_id),
      );
      const reversal = tables.payment_reversals.find((r) => r.purchase_id === p.id);
      const blocked = tables.payment_access_blocks.some(
        (b) => b.period_id === period?.id && !b.released_at,
      );
      const refunded = sum(
        tables.payment_refunds.filter((r) => r.purchase_id === p.id && r.state === 'processed'),
        'amount_pesewas',
      );
      const review = tables.payment_reviews.find(
        (r) => r.purchase_id === p.id && r.kind === 'manual_review',
      );
      purchaseStates[logicalPurchase(p.id)] = {
        owner: logicalUser(p.user_id),
        // 'processing' is the replacement's word for a purchase whose money is
        // in flight; the catalog's vocabulary calls that pending.
        status:
          p.state === 'awaiting_payment' || p.state === 'processing'
            ? 'pending'
            : blocked || p.state === 'review_required'
              ? 'disputed'
              : reversal
                ? 'refunded'
                : p.state,
        cash: Number(p.cash_due_pesewas),
        gross: Number(p.price_pesewas),
        creditApplied: Number(p.applied_credit_pesewas),
        refunded: Number(refunded),
        refundEffects: tables.payment_refunds.filter((r) => r.purchase_id === p.id).length,
        disputeEffects: tables.payment_disputes.filter((d) => d.purchase_id === p.id).length,
        review: review
          ? {
              consumed: Number(reversal?.consumed_rides ?? 0),
              unrecoveredCredit: reversal
                ? Number(reversal.conversion_credit_pesewas) -
                  Number(reversal.recovered_credit_pesewas)
                : 0,
              estimate: Number(review.amount_pesewas),
            }
          : null,
        period: period
          ? {
              purchase: logicalPurchase(period.purchase_id),
              owner: logicalUser(period.user_id),
              status: blocked ? 'frozen' : period.state,
              startsAt: period.starts_at.toISOString(),
              endsAt: period.effective_ends_at.toISOString(),
              rides: sum(movements, 'delta_rides'),
              consumed:
                0 -
                sum(
                  // Consumption is service the rider actually took. A refund
                  // entry removes what they did not, and counting it would
                  // report a refunded period as fully consumed.
                  movements.filter((e) => ['boarding', 'no_show'].includes(e.reason)),
                  'delta_rides',
                ),
              allocations: movements.filter((e) => e.reason === 'allocation').length,
              allocated: sum(
                movements.filter((e) => e.reason === 'allocation'),
                'delta_rides',
              ),
              convertedRides:
                0 -
                sum(
                  movements.filter((e) => e.reason === 'converted'),
                  'delta_rides',
                ),
              conversionEffects: conversion.length,
              conversionCredit: sum(conversion, 'delta_pesewas'),
              // What a close recorded, for a period that closed. A closure row
              // against a still-open period is not a close that happened.
              closeRides:
                closures.length && period.state !== 'open'
                  ? Number(closures[0].rides_converted)
                  : null,
              closeCredit:
                closures.length && period.state !== 'open'
                  ? Number(closures[0].credit_granted_pesewas)
                  : null,
            }
          : null,
      };
    }
    const opsReviews = tables.payment_reviews
      .filter((r) => r.state === 'open')
      .map((r) => ({
        purchase: logicalPurchase(r.purchase_id),
        kind: r.kind,
        status: reviewStatus(r, tables),
        amount: Number(r.amount_pesewas),
      }))
      .sort((a, b) => `${a.purchase}/${a.kind}`.localeCompare(`${b.purchase}/${b.kind}`));
    return {
      state: {
        result,
        riders: riderStates,
        purchases: purchaseStates,
        opsReviews,
        totals: {
          purchases: tables.purchases.length,
          periods: tables.billing_periods.length,
          distinctLinkedPeriods: new Set(tables.billing_periods.map((p) => p.purchase_id)).size,
          heldPayments: tables.credit_holds.filter((h) => h.state === 'held').length,
          allocations: tables.ride_entries.filter((e) => e.reason === 'allocation').length,
          reviews: tables.payment_reviews.filter((r) => r.kind === 'manual_review').length,
        },
        // ready/processed/quarantined are this model's inbox states; the
        // catalog's vocabulary is received/processed/failed.
        inbox: {
          total: events.length,
          received: events.filter((e) => e.state === 'ready' && e.attempts === 0).length,
          processing: events.filter((e) => held.has(e.id)).length,
          processed: events.filter((e) => e.state === 'processed').length,
          // A delivery this inbox has recorded a failure for. Quarantine is
          // final; a ready row that has already been attempted is the same
          // fact still awaiting retry, which is where this model keeps a
          // rollback the baseline would mark failed outright.
          failed: events.filter((e) => e.state === 'quarantined' || e.attempts > 0).length,
        },
      },
      raw: { ...tables, inbox: allEvents },
      evidence: structuredClone(evidence),
    };
  }
  function reviewStatus(review, tables) {
    if (review.kind === 'refund')
      return tables.payment_refunds.find((r) => r.id === review.refund_id)?.state ?? review.state;
    if (review.kind === 'dispute')
      return tables.payment_disputes.find((d) => d.id === review.dispute_id)?.state ?? review.state;
    return review.state;
  }

  startWorker();
  await seedCorridor({ plan: 'monthly', rides: 44, fare: 600, conversionRate: 45 });
  return {
    act,
    observe,
    async metadata() {
      return {
        adapter: 'replacement-postgres',
        package: '@trotxi/api-next',
        postgres: (await observer.query('SELECT version()')).rows[0].version,
      };
    },
    async corrupt(kind) {
      const first = await purchaseRow('first');
      const period = (
        await observer.query('SELECT id FROM app.billing_periods WHERE purchase_id=$1', [first.id])
      ).rows[0];
      // These controls test the measuring instrument, not the schema. The
      // replacement refuses both of these states through triggers and a unique
      // index, so the harness suspends exactly those protections on its own
      // disposable database to write the wrong row, and records what it
      // suspended. Detection still has to come from the observer and the
      // comparator, never from a SQL error.
      if (kind === 'double_allocation') {
        await observer.query('DROP INDEX app.one_period_allocation');
        await observer.query('ALTER TABLE app.ride_entries DISABLE TRIGGER USER');
        await observer.query(
          `INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides)
          VALUES ($1,$2,'allocation',$3)`,
          [first.user_id, period.id, first.rides_granted],
        );
        await observer.query('ALTER TABLE app.ride_entries ENABLE TRIGGER USER');
        evidence.push({
          kind: 'negative-control-mutation',
          suspended: ['app.one_period_allocation', 'app.ride_entries user triggers'],
          wrote: 'a second full allocation on a period that already had one',
        });
      } else if (kind === 'wrong_current_purchase') {
        const renewal = (
          await observer.query('SELECT * FROM app.billing_periods WHERE purchase_id=$1', [
            purchases.get('renewal'),
          ])
        ).rows[0];
        await observer.query('ALTER TABLE app.billing_periods DISABLE TRIGGER USER');
        await observer.query(
          `UPDATE app.billing_periods
          SET starts_at=$2::timestamptz, original_ends_at=$2::timestamptz+interval '31 days',
            effective_ends_at=$2::timestamptz+interval '31 days'
          WHERE id=$1`,
          [period.id, renewal.effective_ends_at],
        );
        await observer.query('ALTER TABLE app.billing_periods ENABLE TRIGGER USER');
        evidence.push({
          kind: 'negative-control-mutation',
          suspended: ['app.billing_periods user triggers'],
          wrote:
            "the first purchase's coverage moved after the renewal's, so the current period points at the wrong purchase",
        });
      } else throw new Error('Unknown negative control');
    },
    async dispose() {
      try {
        await workers.end();
      } finally {
        await observer.end();
      }
      if (observerErrors.length)
        throw new Error(`Observer connection failed: ${observerErrors.join(',')}`);
    },
  };
}
