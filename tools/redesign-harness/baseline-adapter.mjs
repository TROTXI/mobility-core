import { randomUUID } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { BASELINE, PIN } from './support.mjs';

const modules = {};
for (const [file, names] of Object.entries({
  'payments/payment-lifecycle.pg': ['PgPaymentLifecycle'],
  'payments/payment.repository.pg': ['PgPaymentRepository'],
  'payments/payment-webhook.repository.pg': ['PgPaymentWebhookRepository'],
  'payments/paystack.client': ['FakePaystackClient', 'paystackSignature'],
  'payments/payments.service': ['PaymentsService'],
  'payments/pricing.repository.pg': ['PgPricingRepository'],
  'subscriptions/subscription.repository.pg': ['PgSubscriptionRepository'],
  'users/user.repository.pg': ['PgUserRepository'],
  'entitlements/credit-ledger.repository.pg': ['PgCreditLedgerRepository'],
  'entitlements/entitlement-ledger.repository.pg': ['PgEntitlementLedgerRepository'],
})) {
  const imported = await import(
    pathToFileURL(resolve(BASELINE, `services/api/src/modules/${file}.ts`))
  );
  for (const name of names) modules[name] = imported[name];
}
const { default: pg } = await import(
  pathToFileURL(resolve(BASELINE, 'services/api/node_modules/pg/lib/index.js'))
);
const { Pool } = pg;
const normalizedSql = (sql) =>
  String(typeof sql === 'object' ? sql.text : sql)
    .replace(/\s+/g, ' ')
    .trim();
const errorKind = (error) =>
  ({
    PendingSubscriptionPaymentError: 'pending_checkout',
    PeriodCloseBlockedError: 'period_close_blocked',
  })[error.constructor.name] ?? error.constructor.name;
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

export async function createAdapter({ databaseUrl }) {
  const observer = new Pool({
    connectionString: databaseUrl,
    max: 2,
    application_name: 'harness-observer',
    statement_timeout: 15000,
  });
  let workers;
  let pool;
  let lifecycle;
  let service;
  let webhooks;
  let hook = null;
  let result = null;
  const evidence = [];
  const observerErrors = [];
  observer.on('error', (error) => {
    observerErrors.push(error.code ?? error.name);
  });
  const pids = new Set();
  const riders = new Map();
  const references = new Map();
  const providerIds = new Map();
  const fake = new modules.FakePaystackClient('harness-synthetic-secret');
  const providerId = (key) => {
    if (!providerIds.has(key)) providerIds.set(key, String(100000 + providerIds.size));
    return providerIds.get(key);
  };
  const logicalUser = (id) =>
    [...riders].find(([, value]) => value === id)?.[0] ?? `unmapped:${id}`;
  const logicalPurchase = (ref) =>
    [...references].find(([, value]) => value === ref)?.[0] ?? `unmapped:${ref}`;
  const payment = async (name) => {
    const row = (
      await observer.query('SELECT * FROM payments WHERE reference=$1', [references.get(name)])
    ).rows[0];
    if (!row) throw new Error(`Missing purchase ${name}`);
    return row;
  };

  function startWorker() {
    workers = new Pool({
      connectionString: databaseUrl,
      max: 8,
      application_name: 'harness-worker',
      statement_timeout: 15000,
    });
    workers.on('error', (error) => {
      evidence.push({ kind: 'worker-connection-error', code: error.code ?? error.name });
    });
    workers.on('connect', (client) =>
      client.on('error', (error) => {
        // The controlled backend-termination test can emit while a client is
        // checked out (before ROLLBACK can run). Retain evidence; real queries
        // still reject, so this listener cannot turn a failed write into success.
        evidence.push({ kind: 'checked-out-connection-error', code: error.code ?? error.name });
      }),
    );
    pool = {
      async connect() {
        const client = await workers.connect();
        const pid = (await client.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
        pids.add(pid);
        return {
          async query(sql, args) {
            const text = normalizedSql(sql);
            if (hook?.before) await hook.before({ text, client, pid });
            const response = await client.query(sql, args);
            if (hook?.after) await hook.after({ text, client, pid, response });
            return response;
          },
          release() {
            client.release();
          },
        };
      },
      async query(sql, args) {
        const client = await pool.connect();
        try {
          return await client.query(sql, args);
        } finally {
          client.release();
        }
      },
    };
    lifecycle = new modules.PgPaymentLifecycle(pool);
    webhooks = new modules.PgPaymentWebhookRepository(pool);
    service = new modules.PaymentsService({
      lifecycle,
      webhooks,
      paystack: fake,
      ridesPerPeriod: 44,
      payments: new modules.PgPaymentRepository(pool),
      subscriptions: new modules.PgSubscriptionRepository(pool),
      entitlements: new modules.PgEntitlementLedgerRepository(pool),
      credits: new modules.PgCreditLedgerRepository(pool),
      users: new modules.PgUserRepository(pool),
      pricing: new modules.PgPricingRepository(pool),
    });
  }
  startWorker();

  async function charge(name, at) {
    const p = await payment(name);
    return {
      reference: p.reference,
      status: 'success',
      amountPesewas: p.amount,
      currency: p.currency,
      providerTransactionId: providerId(name),
      providerDomain: 'test',
      channel: 'mobile_money',
      feesPesewas: 100,
      paidAt: new Date(at),
    };
  }

  async function contend(step) {
    const blocker = await observer.connect();
    let pending;
    try {
      await blocker.query('BEGIN');
      await blocker.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        riders.get(step.owner),
      ]);
      pending = Promise.allSettled(step.actions.map(act));
      let waiting;
      await until(async () => {
        waiting = (
          await observer.query(`SELECT DISTINCT l.pid, l.locktype FROM pg_locks l
          JOIN pg_stat_activity a ON a.pid=l.pid WHERE a.datname=current_database()
          AND a.application_name='harness-worker' AND NOT l.granted`)
        ).rows;
        return new Set(waiting.map((r) => r.pid)).size >= 2;
      }, 'two distinct workers waiting on database locks');
      evidence.push({ kind: 'database-contention', waiting });
    } finally {
      await blocker.query('ROLLBACK');
      blocker.release();
      // Drain operations even if instrumentation fails; never drop their DB underneath them.
      if (pending) await pending;
    }
    const outcomes = await pending;
    return {
      fulfilled: outcomes.filter((o) => o.status === 'fulfilled').length,
      rejected: outcomes.filter((o) => o.status === 'rejected').length,
      errors: outcomes
        .filter((o) => o.status === 'rejected')
        .map((o) => errorKind(o.reason))
        .sort(),
    };
  }

  async function raceInbox() {
    const claimed = deferred();
    const resume = deferred();
    let firstPid;
    const claims = [];
    hook = {
      after: async ({ text, pid, response }) => {
        if (!text.startsWith('WITH claimed AS')) return;
        claims.push({ pid, claimed: response.rows.length });
        if (response.rows.length && !firstPid) {
          firstPid = pid;
          claimed.resolve();
          await resume.promise;
        }
      },
    };
    const first = service.processWebhookInbox(10);
    // Attach a handler before awaiting the barrier to avoid unhandled rejections.
    const firstSettled = first.then(
      (value) => ({ value }),
      (error) => ({ error }),
    );
    try {
      await until(async () => Boolean(firstPid), 'first worker holding a claimed inbox batch');
      await claimed.promise;
      const second = await service.processWebhookInbox(10);
      evidence.push({
        kind: 'inbox-claim-barrier',
        firstClaimConnection: firstPid,
        claims,
        distinctConnections: claims.length === 2 && claims[1].pid !== firstPid,
        secondProcessedWhileFirstPaused: second.processed,
      });
      if (second.processed !== 0 || claims.length !== 2 || claims[1].pid === firstPid)
        throw new Error('Inbox overlap was not proven');
      resume.resolve();
      const completed = await firstSettled;
      if (completed.error) throw completed.error;
      return {
        processed: completed.value.processed + second.processed,
        failed: completed.value.failed + second.failed,
      };
    } finally {
      resume.resolve();
      await firstSettled;
      hook = null;
    }
  }

  async function act(step) {
    let value = null;
    switch (step.action) {
      case 'rider': {
        const id = randomUUID();
        riders.set(step.name, id);
        await observer.query('INSERT INTO users(id,display_name) VALUES($1,$2)', [
          id,
          `Synthetic ${step.name}`,
        ]);
        if (step.credit)
          await observer.query(
            `INSERT INTO credit_ledger(user_id,delta_pesewas,reason,ref_type,ref_id,idempotency_key)
          VALUES($1,$2,'compensation','test',$3,$3)`,
            [id, step.credit, randomUUID()],
          );
        break;
      }
      case 'checkout': {
        if (!references.has(step.purchase))
          references.set(step.purchase, `harness-${randomUUID()}`);
        const p = await lifecycle.createSubscriptionCheckout({
          userId: riders.get(step.owner),
          reference: references.get(step.purchase),
          purpose: 'subscription',
          plan: step.terms.plan,
          routeId: null,
          currency: 'GHS',
          ridesGranted: step.terms.rides,
          farePesewas: step.terms.fare,
          creditPesewasPerRide: step.terms.conversionRate,
          pricePesewas: step.terms.price,
          now: new Date(step.at),
        });
        value = { cash: p.amount, creditApplied: p.appliedCreditPesewas };
        break;
      }
      case 'fulfill':
        value = await lifecycle.fulfillSubscriptionCharge(await charge(step.purchase, step.at));
        break;
      case 'closeAtBoundary': {
        const p = await payment(step.purchase);
        const end = (
          await observer.query('SELECT period_end FROM subscription_periods WHERE id=$1', [
            p.subscription_period_id,
          ])
        ).rows[0].period_end;
        value = await lifecycle.closeEndedPeriods(new Date(end.getTime() + step.offsetMs), 100);
        break;
      }
      case 'close': {
        value = await lifecycle.closeEndedPeriods(new Date(step.at), 100);
        value.failures = await Promise.all(
          value.failures.map(async (failure) => ({
            reason: failure.reason,
            purchase: logicalPurchase(
              (
                await observer.query(
                  `SELECT p.reference FROM subscription_periods sp JOIN payments p ON p.id=sp.payment_id WHERE sp.id=$1`,
                  [failure.periodId],
                )
              ).rows[0]?.reference,
            ),
          })),
        );
        break;
      }
      case 'consume': {
        const p = await payment(step.purchase);
        await observer.query(
          `INSERT INTO entitlement_ledger(user_id,delta_rides,reason,ref_type,ref_id,idempotency_key,subscription_period_id)
          VALUES($1,$2,'boarding','test',$3,$3,$4)`,
          [p.user_id, -step.rides, randomUUID(), p.subscription_period_id],
        );
        break;
      }
      case 'reserve': {
        const p = await payment(step.purchase);
        await observer.query(
          `INSERT INTO reservations(user_id,travel_date,direction,status,source,subscription_period_id)
          VALUES($1,'2026-01-31','morning','reserved','confirmation',$2)`,
          [p.user_id, p.subscription_period_id],
        );
        break;
      }
      case 'malformRate':
        await observer.query(
          'UPDATE subscription_periods SET credit_pesewas_per_ride=NULL WHERE id=$1',
          [(await payment(step.purchase)).subscription_period_id],
        );
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
        const c = await charge(step.purchase, step.at);
        const body = JSON.stringify({
          event: 'charge.success',
          data: {
            id: c.providerTransactionId,
            reference: c.reference,
            status: c.status,
            amount: c.amountPesewas,
            currency: c.currency,
            domain: 'test',
            channel: c.channel,
            fees: c.feesPesewas,
            paid_at: c.paidAt.toISOString(),
          },
        });
        const signature = modules.paystackSignature(body, 'harness-synthetic-secret');
        await Promise.all(
          Array.from({ length: step.copies ?? 1 }, () => service.acceptWebhook(body, signature)),
        );
        break;
      }
      case 'raceInbox':
        value = await raceInbox();
        break;
      case 'processInbox':
        value = await service.processWebhookInbox(10);
        break;
      case 'claimOnly':
        value = (await webhooks.claimBatch(10, new Date(0))).length;
        break;
      case 'expireLease': {
        await observer.query(
          `UPDATE payment_webhook_events SET processing_at=now()-interval '6 minutes' WHERE status='processing'`,
        );
        evidence.push({
          kind: 'fixture-clock-adjustment',
          field: 'inbox.processing_at',
          reason: 'expire fixed five-minute baseline lease without fake global timers',
        });
        break;
      }
      case 'restartWorker':
        await workers.end();
        startWorker();
        break;
      case 'terminateAfterAllocation': {
        hook = {
          after: async ({ text, client, pid }) => {
            if (
              !text.startsWith('INSERT INTO entitlement_ledger') ||
              !text.includes("'allocation'")
            )
              return;
            hook = null;
            const inside = (
              await client.query(
                `SELECT count(*)::int AS n FROM entitlement_ledger WHERE reason='allocation'`,
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
            // The next real query fails; the server has rolled back the transaction.
          },
        };
        break;
      }
      case 'failAcknowledgement': {
        hook = {
          before: async ({ text }) => {
            if (
              !text.startsWith('UPDATE payment_webhook_events') ||
              !text.includes("status = 'processed'")
            )
              return;
            hook = null;
            evidence.push({ kind: 'injected-acknowledgement-failure' });
            throw new Error('Harness interrupted acknowledgement after committed fulfilment');
          },
        };
        break;
      }
      case 'reconcile': {
        const p = await payment(step.purchase);
        // Own database: no historic cutoff to dodge unrelated test rows. Explicit fixture time.
        await observer.query('UPDATE payments SET created_at=$2 WHERE id=$1', [
          p.id,
          new Date(step.at),
        ]);
        await fake.initializeTransaction({
          email: 'synthetic@example.invalid',
          amountPesewas: p.amount,
          reference: p.reference,
        });
        fake.setTransaction(p.reference, {
          status: 'success',
          providerTransactionId: providerId(step.purchase),
          channel: 'mobile_money',
          feesPesewas: 100,
          paidAt: new Date(step.at),
        });
        value = await service.reconcileUnresolved(new Date(new Date(step.at).getTime() + 3600000));
        break;
      }
      case 'refund': {
        const p = await payment(step.purchase);
        value = await lifecycle.recordRefund({
          eventKey: `${step.identity}-${step.status}`,
          reference: p.reference,
          refundReference: step.identity,
          amountPesewas: step.amount === 'full' ? p.amount : step.amount,
          currency: 'GHS',
          providerDomain: 'test',
          status: step.status,
          payload: { synthetic: true },
        });
        break;
      }
      case 'dispute': {
        const p = await payment(step.purchase);
        value = await lifecycle.recordDispute({
          reference: p.reference,
          providerDisputeId: providerId(step.identity),
          amountPesewas: step.amount,
          currency: 'GHS',
          providerDomain: 'test',
          status: step.status,
          resolution: step.resolution,
          payload: { synthetic: true },
        });
        break;
      }
      case 'moneyMetadata': {
        const fields = {
          cash: 'amount',
          gross: 'gross_amount_pesewas',
          appliedCredit: 'applied_credit_pesewas',
          fare: 'fare_pesewas',
          conversionRate: 'credit_pesewas_per_ride',
          fees: 'fees_pesewas',
          refunded: 'refunded_pesewas',
        };
        const rows = (
          await observer.query(
            `SELECT attname, col_description(attrelid,attnum) AS comment FROM pg_attribute WHERE attrelid='payments'::regclass AND attname=ANY($1::text[])`,
            [Object.values(fields)],
          )
        ).rows;
        evidence.push({ kind: 'money-column-comments', rows });
        value = Object.fromEntries(
          Object.entries(fields).map(([name, column]) => [
            name,
            rows
              .find((r) => r.attname === column)
              ?.comment?.toLowerCase()
              .includes('pesewas')
              ? 'pesewas'
              : 'undocumented',
          ]),
        );
        break;
      }
      default:
        throw new Error(`Unknown domain action ${step.action}`);
    }
    result = value;
    return value;
  }

  async function observe() {
    const tables = {};
    for (const table of [
      'users',
      'payments',
      'subscriptions',
      'subscription_periods',
      'credit_holds',
      'credit_ledger',
      'entitlement_ledger',
      'payment_refunds',
      'payment_disputes',
      'payment_reversal_reviews',
    ])
      tables[table] = (await observer.query(`SELECT * FROM ${table}`)).rows; // Const table allowlist, never request input.
    const inboxRows = (
      await observer.query('SELECT id,status,attempts FROM payment_webhook_events')
    ).rows;
    const sum = (rows, column) => rows.reduce((n, row) => n + Number(row[column]), 0);
    const userStates = {};
    for (const [name, id] of riders) {
      const subscription = tables.subscriptions.find((s) => s.user_id === id);
      const current = tables.subscription_periods.find(
        (p) => p.id === subscription?.current_period_id,
      );
      const currentPayment = tables.payments.find((p) => p.id === current?.payment_id);
      const credit = sum(
        tables.credit_ledger.filter((e) => e.user_id === id),
        'delta_pesewas',
      );
      const held = sum(
        tables.credit_holds.filter((h) => h.user_id === id && h.status === 'held'),
        'amount_pesewas',
      );
      userStates[name] = {
        credit,
        held,
        available: credit - held,
        rides: sum(
          tables.entitlement_ledger.filter((e) => e.user_id === id),
          'delta_rides',
        ),
        membership: subscription?.status ?? null,
        currentPurchase: currentPayment ? logicalPurchase(currentPayment.reference) : null,
      };
    }
    const purchases = {};
    for (const p of tables.payments) {
      const period = tables.subscription_periods.find((sp) => sp.id === p.subscription_period_id);
      const movements = tables.entitlement_ledger.filter(
        (e) => e.subscription_period_id === period?.id,
      );
      const credits = tables.credit_ledger.filter(
        (e) =>
          e.ref_type === 'period' && e.ref_id === period?.id && e.reason === 'month_end_conversion',
      );
      const review = tables.payment_reversal_reviews.find((r) => r.payment_id === p.id);
      const funding = tables.payments.find((row) => row.id === period?.payment_id);
      const membership = tables.subscriptions.find((s) => s.id === period?.subscription_id);
      purchases[logicalPurchase(p.reference)] = {
        owner: logicalUser(p.user_id),
        status: p.status,
        cash: p.amount,
        gross: p.gross_amount_pesewas,
        creditApplied: p.applied_credit_pesewas,
        refunded: p.refunded_pesewas,
        refundEffects: tables.payment_refunds.filter((r) => r.payment_id === p.id).length,
        disputeEffects: tables.payment_disputes.filter((d) => d.payment_id === p.id).length,
        review: review
          ? {
              consumed: review.consumed_rides,
              unrecoveredCredit: review.unrecovered_credit_pesewas,
              estimate: review.estimated_debt_pesewas,
            }
          : null,
        period: period
          ? {
              purchase: funding ? logicalPurchase(funding.reference) : null,
              owner: logicalUser(membership?.user_id),
              status: period.status,
              startsAt: period.period_start.toISOString(),
              endsAt: period.period_end.toISOString(),
              rides: sum(movements, 'delta_rides'),
              consumed:
                0 -
                sum(
                  movements.filter((e) => ['boarding', 'no_show', 'returned'].includes(e.reason)),
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
              conversionEffects: credits.length,
              conversionCredit: sum(credits, 'delta_pesewas'),
              closeRides: period.rides_converted,
              closeCredit: period.credit_granted_pesewas,
            }
          : null,
      };
    }
    const opsReviews = (await lifecycle.listOperationsReviews())
      .map((r) => ({
        purchase: logicalPurchase(r.paymentReference),
        kind: r.kind,
        status: r.status,
        amount: r.amountPesewas,
      }))
      .sort((a, b) => `${a.purchase}/${a.kind}`.localeCompare(`${b.purchase}/${b.kind}`));
    return {
      state: {
        result,
        riders: userStates,
        purchases,
        opsReviews,
        totals: {
          purchases: tables.payments.length,
          periods: tables.subscription_periods.length,
          distinctLinkedPeriods: new Set(
            tables.payments.map((p) => p.subscription_period_id).filter(Boolean),
          ).size,
          heldPayments: tables.credit_holds.filter((h) => h.status === 'held').length,
          allocations: tables.entitlement_ledger.filter((e) => e.reason === 'allocation').length,
          reviews: tables.payment_reversal_reviews.length,
        },
        inbox: Object.fromEntries(
          ['total', 'received', 'processing', 'processed', 'failed'].map((status) => [
            status,
            status === 'total'
              ? inboxRows.length
              : inboxRows.filter((r) => r.status === status).length,
          ]),
        ),
      },
      raw: { ...tables, inbox: inboxRows },
      evidence: structuredClone(evidence),
    };
  }

  return {
    act,
    observe,
    async metadata() {
      return {
        adapter: 'pinned-postgres',
        commit: PIN,
        postgres: (await observer.query('SELECT version()')).rows[0].version,
      };
    },
    async corrupt(kind) {
      const first = await payment('first');
      if (kind === 'double_allocation')
        await observer.query(
          `INSERT INTO entitlement_ledger(user_id,delta_rides,reason,ref_type,ref_id,idempotency_key,subscription_period_id)
        VALUES($1,$2,'allocation','payment',$3,$4,$5)`,
          [
            first.user_id,
            first.rides_granted,
            first.reference,
            randomUUID(),
            first.subscription_period_id,
          ],
        );
      else if (kind === 'wrong_current_purchase')
        await observer.query('UPDATE subscriptions SET current_period_id=$1 WHERE id=$2', [
          first.subscription_period_id,
          first.subscription_id,
        ]);
      else throw new Error('Unknown negative control');
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
