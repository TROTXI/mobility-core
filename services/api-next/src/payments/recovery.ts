import { createHash } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import type { Actor } from '../transport/service.js';
import { canonical } from '../transport/service.js';
import { fail, TransportError } from '../transport/errors.js';
import { cursorCodec } from '../transport/cursor.js';
import { FinancialFoundation } from './foundation.js';
import {
  PaystackEvidence,
  InvalidProviderFacts,
  parseProviderFact,
  refundRank,
  disputeRank,
} from './provider.js';
import type { ProviderFact } from './provider.js';

export interface RecoveryDependencies {
  pool: Pool;
  provider: PaystackEvidence;
  foundation: FinancialFoundation;
  authorizeSession: (c: PoolClient, actor: Actor) => Promise<void>;
  cursorSecret: Buffer;
  // 013 supplies reservation/pause coordination. Never commit or call an
  // external service here: a thrown error must roll back the complete reversal.
  reversePeriod: (
    c: PoolClient,
    period: { userId: string; periodId: string; purchaseId: string },
  ) => Promise<void>;
  // Deliberately bounded metadata, never raw provider payloads or credentials.
  onFailure?: (event: { resourceId: string; reason: string }) => void;
}
export interface MaintenanceResult {
  considered: number;
  succeeded: number;
  blocked: number;
  failed: number;
  failures: { resourceId: string; reason: string }[];
}
const empty = (): MaintenanceResult => ({
  considered: 0,
  succeeded: 0,
  blocked: 0,
  failed: 0,
  failures: [],
});
const digest = (s: string) => createHash('sha256').update(s).digest('hex');
const limitOf = (n: number) => {
  if (!Number.isInteger(n) || n < 1 || n > 100)
    fail(400, 'invalid_limit', 'Limit must be between 1 and 100.');
  return n;
};
type Attempt = {
  id: string;
  purchase_id: string;
  user_id: string;
  environment: string;
  state: string;
  amount_pesewas: number;
  currency: string;
  provider_transaction_id: string | null;
};
type EventRow = {
  id: string;
  environment: 'test' | 'live';
  source: 'webhook' | 'verify';
  payload_hash: string;
  ciphertext: Buffer;
  attempts: number;
};
class Conflict extends Error {}
class AwaitingCollection extends Error {}
const context = (e: Pick<EventRow, 'environment' | 'source' | 'payload_hash'>) =>
  `${e.environment}:${e.source}:${e.payload_hash}`;

export function reversalDebt(
  price: number,
  consumed: number,
  granted: number,
  unrecovered: number,
) {
  if (
    ![price, consumed, granted, unrecovered].every(Number.isSafeInteger) ||
    price < 0 ||
    consumed < 0 ||
    granted < 1 ||
    consumed > granted ||
    unrecovered < 0
  )
    throw new Error('invalid_reversal_arithmetic');
  const value =
    (BigInt(price) * BigInt(consumed) * 2n + BigInt(granted)) / (BigInt(granted) * 2n) +
    BigInt(unrecovered);
  if (value > BigInt(Number.MAX_SAFE_INTEGER)) throw new Error('invalid_reversal_arithmetic');
  return Number(value);
}

export class PaymentRecovery {
  private readonly cursors;
  constructor(private readonly options: RecoveryDependencies) {
    if (typeof options.reversePeriod !== 'function')
      throw new Error('Transactional period reversal coordinator required');
    this.cursors = cursorCodec(options.cursorSecret);
  }
  private async tx<T>(work: (c: PoolClient) => Promise<T>) {
    const c = await this.options.pool.connect();
    try {
      await c.query('BEGIN');
      await c.query("SET LOCAL lock_timeout='3s'");
      await c.query("SET LOCAL statement_timeout='10s'");
      const result = await work(c);
      await c.query('COMMIT');
      return result;
    } catch (e) {
      await c.query('ROLLBACK');
      throw e;
    } finally {
      c.release();
    }
  }
  private async admin(c: PoolClient, actor: Actor) {
    const r = (
      await c.query('SELECT role,deleted_at FROM app.users WHERE id=$1 FOR SHARE', [actor.userId])
    ).rows[0];
    await this.options.authorizeSession(c, actor);
    if (!r || r.deleted_at) fail(401, 'unauthenticated', 'Account unavailable.');
    if (r.role !== 'admin') fail(403, 'forbidden', 'Operations access required.');
  }
  private async enqueue(raw: Buffer, source: 'webhook' | 'verify') {
    if (raw.length < 1 || raw.length > 1048576)
      fail(400, 'invalid_evidence', 'Invalid evidence size.');
    const environment = this.options.provider.environment,
      payload_hash = this.options.provider.hash(raw);
    const ciphertext = this.options.provider.seal(
      raw,
      context({ environment, source, payload_hash }),
    );
    const row = (
      await this.options.pool.query(
        `INSERT INTO app.payment_events(environment,source,payload_hash,ciphertext)
   VALUES ($1,$2,$3,$4) ON CONFLICT(environment,source,payload_hash) DO NOTHING RETURNING id`,
        [environment, source, payload_hash, ciphertext],
      )
    ).rows[0];
    if (row) return row.id as string;
    return (
      await this.options.pool.query(
        'SELECT id FROM app.payment_events WHERE environment=$1 AND source=$2 AND payload_hash=$3',
        [environment, source, payload_hash],
      )
    ).rows[0].id as string;
  }
  async acceptWebhook(raw: Buffer, signature: unknown) {
    if (!this.options.provider.authenticate(raw, signature))
      fail(401, 'invalid_signature', 'Invalid webhook signature.');
    await this.enqueue(raw, 'webhook');
    // Durable acknowledgement only. Processing happens in the bounded worker.
    return { received: true };
  }
  private async finish(
    c: PoolClient,
    id: string,
    state: 'processed' | 'quarantined',
    reason: string | null = null,
  ) {
    await c.query(
      'UPDATE app.payment_events SET state=$2,reason=$3,processed_at=clock_timestamp() WHERE id=$1',
      [id, state, reason],
    );
    return state === 'processed' ? ('succeeded' as const) : ('failed' as const);
  }
  private async eventReview(c: PoolClient, a: Attempt, e: EventRow, reason: string) {
    await c.query(
      `INSERT INTO app.payment_reviews(purchase_id,kind,reason,amount_pesewas,event_id)
   VALUES ($1,'manual_review',$2,$3,$4) ON CONFLICT(event_id,reason) DO NOTHING`,
      [a.purchase_id, reason, a.amount_pesewas, e.id],
    );
  }
  private async process(
    id: string,
  ): Promise<{ outcome: 'succeeded' | 'blocked' | 'failed' | 'skipped'; reason?: string }> {
    try {
      return await this.tx(async (c) => {
        const e = (
          await c.query<EventRow>(
            "SELECT * FROM app.payment_events WHERE id=$1 AND state='ready' AND available_at<=clock_timestamp() FOR UPDATE SKIP LOCKED",
            [id],
          )
        ).rows[0];
        if (!e) return { outcome: 'skipped' };
        let fact: ProviderFact | null;
        try {
          fact = parseProviderFact(this.options.provider.open(e.ciphertext, context(e)), e.source);
        } catch (error) {
          if (!(error instanceof InvalidProviderFacts)) throw error;
          await this.finish(c, id, 'quarantined', 'invalid_facts');
          return { outcome: 'failed', reason: 'invalid_facts' };
        }
        if (!fact) {
          await this.finish(c, id, 'quarantined', 'unsupported_event');
          return { outcome: 'failed', reason: 'unsupported_event' };
        }
        if (fact.environment !== e.environment) {
          await this.finish(c, id, 'quarantined', 'invalid_facts');
          return { outcome: 'failed', reason: 'invalid_facts' };
        }
        const a = (
          await c.query<Attempt>(
            "SELECT * FROM app.payment_attempts WHERE environment=$1 AND reference=$2 AND provider='paystack'",
            [e.environment, fact.reference],
          )
        ).rows[0];
        if (!a) {
          await this.finish(c, id, 'quarantined', 'unknown_reference');
          return { outcome: 'failed', reason: 'unknown_reference' };
        }
        // Lock order: inbox row, rider, attempt/purchase, period. No other path takes
        // an inbox lock while holding the rider; Verify is always outside this TX.
        const user = (
          await c.query('SELECT deleted_at FROM app.users WHERE id=$1 FOR UPDATE', [a.user_id])
        ).rows[0];
        Object.assign(
          a,
          (await c.query('SELECT * FROM app.payment_attempts WHERE id=$1 FOR UPDATE', [a.id]))
            .rows[0],
        );
        if (
          fact.currency !== a.currency ||
          fact.amountPesewas > a.amount_pesewas ||
          (['success', 'failure', 'unresolved'].includes(fact.kind) &&
            fact.amountPesewas !== a.amount_pesewas)
        ) {
          await this.eventReview(c, a, e, 'provider_conflict');
          await this.finish(c, id, 'quarantined', 'provider_conflict');
          return { outcome: 'failed', reason: 'provider_conflict' };
        }
        if (fact.kind === 'success') {
          const old = (
            await c.query(
              'SELECT * FROM app.payment_collections WHERE attempt_id=$1 OR (environment=$2 AND provider_transaction_id=$3)',
              [a.id, a.environment, fact.transactionId],
            )
          ).rows;
          if (
            old.some(
              (r) => r.attempt_id !== a.id || r.provider_transaction_id !== fact.transactionId,
            ) ||
            (a.state === 'successful' && a.provider_transaction_id !== fact.transactionId)
          )
            throw new Conflict();
          if (!old.length)
            await c.query(
              `INSERT INTO app.payment_collections(attempt_id,purchase_id,user_id,environment,provider_transaction_id,amount_pesewas,currency,paid_at,event_id)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
              [
                a.id,
                a.purchase_id,
                a.user_id,
                a.environment,
                fact.transactionId,
                fact.amountPesewas,
                fact.currency,
                fact.paidAt,
                e.id,
              ],
            );
          if (user.deleted_at) {
            await this.eventReview(c, a, e, 'account_unavailable');
            await this.finish(c, id, 'quarantined', 'account_unavailable');
            return { outcome: 'failed', reason: 'account_unavailable' };
          }
          const result = await this.options.foundation.fulfillInTransaction(c, fact);
          if (result === 'mismatch') throw new Conflict();
          if (result === 'not_pending') {
            // A new purchase may already exist. Do not move the old failed purchase
            // into the single unresolved slot, or silently grant another period.
            await this.eventReview(c, a, e, 'late_success');
            await this.finish(c, id, 'quarantined', 'late_success');
            return { outcome: 'failed', reason: 'late_success' };
          }
        } else if (fact.kind === 'failure') {
          if (['pending', 'unknown'].includes(a.state)) {
            await c.query(
              "UPDATE app.credit_holds SET state='released',settled_at=clock_timestamp() WHERE purchase_id=$1 AND state='held'",
              [a.purchase_id],
            );
            await c.query("UPDATE app.payment_attempts SET state='failed' WHERE id=$1", [a.id]);
            await c.query(
              "UPDATE app.purchases SET state='failed',failure_code='provider_failed',updated_at=clock_timestamp() WHERE id=$1 AND state IN ('awaiting_payment','processing')",
              [a.purchase_id],
            );
          }
        } else if (fact.kind === 'unresolved') {
          await this.finish(c, id, 'processed');
          return { outcome: 'blocked' };
        } else {
          // Out-of-order refund/dispute before charge: keep durable work retryable.
          if (
            a.state !== 'successful' &&
            !(await c.query('SELECT 1 FROM app.payment_collections WHERE attempt_id=$1', [a.id]))
              .rowCount
          )
            throw new AwaitingCollection();
          if (fact.kind === 'refund') await this.refund(c, a, e, fact);
          else await this.dispute(c, a, e, fact);
        }
        await this.finish(c, id, 'processed');
        return { outcome: 'succeeded' };
      });
    } catch (error) {
      const conflict = error instanceof Conflict,
        waiting = error instanceof AwaitingCollection;
      // Another worker may have succeeded since rollback. Never overwrite its
      // committed acknowledgement. No side effect survived our failed TX.
      await this.options.pool.query(
        `UPDATE app.payment_events SET attempts=attempts+1,
    state=CASE WHEN $2 OR attempts>=9 THEN 'quarantined' ELSE 'ready' END,
    reason=CASE WHEN $2 THEN 'provider_conflict' WHEN attempts>=9 THEN 'retry_exhausted' ELSE 'unexpected_error' END,
    processed_at=CASE WHEN $2 OR attempts>=9 THEN clock_timestamp() ELSE NULL END,
    available_at=clock_timestamp()+interval '1 minute'*LEAST(60,power(2,attempts))
    WHERE id=$1 AND state='ready'`,
        [id, conflict],
      );
      const reason = conflict
        ? 'provider_conflict'
        : waiting
          ? 'awaiting_collection'
          : 'unexpected_error';
      this.options.onFailure?.({ resourceId: id, reason });
      return { outcome: waiting ? 'blocked' : 'failed', reason };
    }
  }
  async processInbox(limit = 100): Promise<MaintenanceResult> {
    const result = empty();
    const rows = (
      await this.options.pool.query(
        "SELECT id FROM app.payment_events WHERE state='ready' AND available_at<=clock_timestamp() ORDER BY available_at,id LIMIT $1",
        [limitOf(limit)],
      )
    ).rows;
    for (const r of rows) {
      const done = await this.process(r.id);
      if (done.outcome === 'skipped') continue;
      result.considered++;
      result[done.outcome]++;
      if (done.outcome === 'failed')
        result.failures.push({ resourceId: r.id, reason: done.reason ?? 'unexpected_error' });
    }
    return result;
  }
  async reconcile(before: Date, limit = 100): Promise<MaintenanceResult> {
    if (!Number.isFinite(before.getTime())) fail(400, 'invalid_cutoff', 'Invalid cutoff.');
    const result = empty();
    const rows = (
      await this.options.pool.query(
        "SELECT id,reference FROM app.payment_attempts WHERE environment=$1 AND state IN ('pending','unknown') AND created_at<$2 ORDER BY created_at,id LIMIT $3",
        [this.options.provider.environment, before, limitOf(limit)],
      )
    ).rows;
    for (const row of rows) {
      result.considered++;
      try {
        const raw = await this.options.provider.verify(row.reference),
          id = await this.enqueue(raw, 'verify'),
          done = await this.process(id);
        // Identical pending evidence may already be processed. Re-reading it must
        // not count as a successful settlement or release the hold.
        const state = (
          await this.options.pool.query('SELECT state FROM app.payment_attempts WHERE id=$1', [
            row.id,
          ])
        ).rows[0].state;
        if (done.outcome === 'failed') {
          result.failed++;
          result.failures.push({ resourceId: row.id, reason: done.reason ?? 'unexpected_error' });
        } else if (['pending', 'unknown'].includes(state)) result.blocked++;
        else result.succeeded++;
      } catch {
        result.failed++;
        result.failures.push({ resourceId: row.id, reason: 'verification_unavailable' });
      }
    }
    return result;
  }
  private async sourceReview(
    c: PoolClient,
    a: Attempt,
    kind: 'refund' | 'dispute',
    sourceId: string,
    amount: number,
    complete: boolean,
  ) {
    // Column is a closed internal enum, not caller input. A replay cannot reopen
    // an ops decision. Amount means the value under review, never gross by accident.
    const column = kind === 'refund' ? 'refund_id' : 'dispute_id';
    await c.query(
      `INSERT INTO app.payment_reviews(purchase_id,kind,reason,amount_pesewas,${column},state)
   VALUES ($1,$2,$3,$4,$5,$6) ON CONFLICT(${column}) DO UPDATE SET amount_pesewas=EXCLUDED.amount_pesewas,state=EXCLUDED.state
   WHERE app.payment_reviews.state='open'`,
      [a.purchase_id, kind, kind + '_progress', amount, sourceId, complete ? 'resolved' : 'open'],
    );
  }
  private async refund(
    c: PoolClient,
    a: Attempt,
    e: EventRow,
    f: Extract<ProviderFact, { kind: 'refund' }>,
  ) {
    let r = (
      await c.query(
        'SELECT * FROM app.payment_refunds WHERE environment=$1 AND provider_reference=$2',
        [a.environment, f.providerReference],
      )
    ).rows[0];
    if (r && (r.attempt_id !== a.id || r.amount_pesewas !== f.amountPesewas)) throw new Conflict();
    if (!r)
      r = (
        await c.query(
          `INSERT INTO app.payment_refunds(attempt_id,purchase_id,user_id,environment,provider_reference,amount_pesewas,state,event_id)
   VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
          [
            a.id,
            a.purchase_id,
            a.user_id,
            a.environment,
            f.providerReference,
            f.amountPesewas,
            f.state,
            e.id,
          ],
        )
      ).rows[0];
    else if (refundRank[f.state] > refundRank[r.state as keyof typeof refundRank])
      r = (
        await c.query(
          'UPDATE app.payment_refunds SET state=$2,event_id=$3,updated_at=clock_timestamp() WHERE id=$1 RETURNING *',
          [r.id, f.state, e.id],
        )
      ).rows[0];
    await this.sourceReview(c, a, 'refund', r.id, r.amount_pesewas, r.state === 'processed');
    const total = Number(
      (
        await c.query(
          "SELECT COALESCE(SUM(amount_pesewas),0) AS total FROM app.payment_refunds WHERE purchase_id=$1 AND state='processed'",
          [a.purchase_id],
        )
      ).rows[0].total,
    );
    if (total > a.amount_pesewas) throw new Conflict();
    if (total === a.amount_pesewas && r.state === 'processed') await this.reverse(c, a, r.id);
    await this.releaseAccepted(c, a.purchase_id, total);
  }
  private async reverse(c: PoolClient, a: Attempt, refundId: string) {
    if (
      (await c.query('SELECT 1 FROM app.payment_reversals WHERE purchase_id=$1', [a.purchase_id]))
        .rowCount
    )
      return;
    const p = (await c.query('SELECT * FROM app.purchases WHERE id=$1', [a.purchase_id])).rows[0];
    // A refunded late collection may never have granted coverage or captured
    // credit. Record that cash reversal without inventing entitlement effects.
    if (p.state !== 'fulfilled') return;
    const b = (
      await c.query('SELECT * FROM app.billing_periods WHERE purchase_id=$1 FOR UPDATE', [p.id])
    ).rows[0];
    if (!b) throw new AwaitingCollection();
    const ledger = (
      await c.query(
        `SELECT COALESCE(SUM(delta_rides),0) AS rides,
   GREATEST(0,-COALESCE(SUM(delta_rides) FILTER(WHERE reason IN ('boarding','no_show','returned')),0)) AS consumed
   FROM app.ride_entries WHERE period_id=$1`,
        [b.id],
      )
    ).rows[0];
    const converted = Number(
      (
        await c.query(
          'SELECT COALESCE(SUM(credit_granted_pesewas),0) AS credit FROM app.period_closures WHERE period_id=$1',
          [b.id],
        )
      ).rows[0].credit,
    );
    const available = Number(
      (
        await c.query(
          `SELECT COALESCE((SELECT SUM(delta_pesewas) FROM app.credit_entries WHERE user_id=$1),0)-
   COALESCE((SELECT SUM(amount_pesewas) FROM app.credit_holds WHERE user_id=$1 AND state='held'),0) AS available`,
          [a.user_id],
        )
      ).rows[0].available,
    );
    if (!Number.isSafeInteger(available) || available < 0)
      throw new Error('invalid_credit_balance');
    const recovered = Math.min(converted, available),
      consumed = Number(ledger.consumed),
      rides = Number(ledger.rides);
    const debt = reversalDebt(p.price_pesewas, consumed, p.rides_granted, converted - recovered);
    const r = (
      await c.query(
        `INSERT INTO app.payment_reversals(purchase_id,user_id,period_id,refund_id,rides_removed,consumed_rides,
   conversion_credit_pesewas,recovered_credit_pesewas,restored_credit_pesewas,estimated_debt_pesewas)
   VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING id`,
        [
          p.id,
          a.user_id,
          b.id,
          refundId,
          rides,
          consumed,
          converted,
          recovered,
          p.applied_credit_pesewas,
          debt,
        ],
      )
    ).rows[0];
    // Claw back available conversion credit BEFORE restoring captured credit.
    // Otherwise a refund could recover its own credit restoration.
    if (recovered)
      await c.query(
        "INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,reversal_id) VALUES ($1,'refund_conversion_recovered',$2,$3)",
        [a.user_id, -recovered, r.id],
      );
    if (rides)
      await c.query(
        "INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides,reversal_id) VALUES ($1,$2,'refund',$3,$4)",
        [a.user_id, b.id, -rides, r.id],
      );
    if (p.applied_credit_pesewas)
      await c.query(
        "INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,reversal_id) VALUES ($1,'refund_restored',$2,$3)",
        [a.user_id, p.applied_credit_pesewas, r.id],
      );
    await this.options.reversePeriod(c, { periodId: b.id, purchaseId: p.id, userId: a.user_id });
    await c.query("UPDATE app.billing_periods SET state='reversed' WHERE id=$1", [b.id]);
    if (consumed || debt)
      await c.query(
        `INSERT INTO app.payment_reviews(purchase_id,kind,reason,amount_pesewas,reversal_id)
   VALUES ($1,'manual_review','consumed_value_after_refund',$2,$3)`,
        [p.id, debt, r.id],
      );
  }
  private async dispute(
    c: PoolClient,
    a: Attempt,
    e: EventRow,
    f: Extract<ProviderFact, { kind: 'dispute' }>,
  ) {
    let d = (
      await c.query('SELECT * FROM app.payment_disputes WHERE environment=$1 AND provider_id=$2', [
        a.environment,
        f.providerId,
      ])
    ).rows[0];
    if (d && d.attempt_id !== a.id) throw new Conflict();
    if (
      d &&
      disputeRank[d.state as keyof typeof disputeRank] === disputeRank[f.state] &&
      (d.resolution !== f.resolution || d.amount_pesewas !== f.amountPesewas)
    )
      throw new Conflict();
    if (!d)
      d = (
        await c.query(
          `INSERT INTO app.payment_disputes(attempt_id,purchase_id,user_id,environment,provider_id,amount_pesewas,state,resolution,event_id)
   VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,
          [
            a.id,
            a.purchase_id,
            a.user_id,
            a.environment,
            f.providerId,
            f.amountPesewas,
            f.state,
            f.resolution,
            e.id,
          ],
        )
      ).rows[0];
    else if (disputeRank[f.state] > disputeRank[d.state as keyof typeof disputeRank])
      d = (
        await c.query(
          'UPDATE app.payment_disputes SET state=$2,resolution=$3,amount_pesewas=$4,event_id=$5,updated_at=clock_timestamp() WHERE id=$1 RETURNING *',
          [d.id, f.state, f.resolution, f.amountPesewas, e.id],
        )
      ).rows[0];
    const b = (
      await c.query('SELECT id FROM app.billing_periods WHERE purchase_id=$1', [a.purchase_id])
    ).rows[0];
    if (!b) {
      await this.sourceReview(
        c,
        a,
        'dispute',
        d.id,
        d.amount_pesewas,
        d.state === 'resolved' && d.resolution === 'declined',
      );
      return;
    }
    await c.query(
      `INSERT INTO app.payment_access_blocks(period_id,purchase_id,user_id,dispute_id)
   VALUES ($1,$2,$3,$4) ON CONFLICT(dispute_id) DO NOTHING`,
      [b.id, a.purchase_id, a.user_id, d.id],
    );
    const declined = d.state === 'resolved' && d.resolution === 'declined';
    if (declined)
      await c.query(
        'UPDATE app.payment_access_blocks SET released_at=clock_timestamp() WHERE dispute_id=$1 AND released_at IS NULL',
        [d.id],
      );
    const total = Number(
      (
        await c.query(
          "SELECT COALESCE(SUM(amount_pesewas),0) AS total FROM app.payment_refunds WHERE purchase_id=$1 AND state='processed'",
          [a.purchase_id],
        )
      ).rows[0].total,
    );
    await this.releaseAccepted(c, a.purchase_id, total);
    const blocked = !!(
      await c.query(
        'SELECT 1 FROM app.payment_access_blocks WHERE dispute_id=$1 AND released_at IS NULL',
        [d.id],
      )
    ).rowCount;
    await this.sourceReview(c, a, 'dispute', d.id, d.amount_pesewas, !blocked);
  }
  private async releaseAccepted(c: PoolClient, purchaseId: string, refunded: number) {
    const accepted = Number(
      (
        await c.query(
          "SELECT COALESCE(SUM(amount_pesewas),0) AS amount FROM app.payment_disputes WHERE purchase_id=$1 AND state='resolved' AND resolution='merchant-accepted'",
          [purchaseId],
        )
      ).rows[0].amount,
    );
    if (accepted > 0 && refunded >= accepted) {
      await c.query(
        `UPDATE app.payment_access_blocks SET released_at=clock_timestamp() WHERE released_at IS NULL AND dispute_id IN
    (SELECT id FROM app.payment_disputes WHERE purchase_id=$1 AND state='resolved' AND resolution='merchant-accepted')`,
        [purchaseId],
      );
      await c.query(
        `UPDATE app.payment_reviews SET state='resolved' WHERE state='open' AND dispute_id IN
    (SELECT id FROM app.payment_disputes WHERE purchase_id=$1 AND state='resolved' AND resolution='merchant-accepted')`,
        [purchaseId],
      );
    }
  }
  async closeEndedPeriods(now = new Date(), limit = 100): Promise<MaintenanceResult> {
    const result = empty();
    const rows = (
      await this.options.pool.query(
        "SELECT id FROM app.billing_periods WHERE state='open' AND effective_ends_at<=$1 ORDER BY effective_ends_at,id LIMIT $2",
        [now, limitOf(limit)],
      )
    ).rows;
    for (const row of rows) {
      result.considered++;
      try {
        if (await this.options.foundation.closePeriod(row.id, now)) result.succeeded++;
        else result.blocked++;
      } catch (e) {
        if (
          e instanceof TransportError &&
          ['period_payment_blocked', 'period_close_blocked'].includes(e.code)
        )
          result.blocked++;
        else {
          result.failed++;
          result.failures.push({ resourceId: row.id, reason: 'unexpected_error' });
          this.options.onFailure?.({ resourceId: row.id, reason: 'unexpected_error' });
        }
      }
    }
    return result;
  }
  async maintenance(
    actor: Actor,
    kind: 'inbox' | 'reconciliation' | 'periods' | 'all',
    limit = 100,
  ) {
    limitOf(limit);
    await this.tx((c) => this.admin(c, actor));
    const now = new Date();
    if (kind === 'inbox') return this.processInbox(limit);
    if (kind === 'reconciliation') return this.reconcile(new Date(now.getTime() - 3600000), limit);
    if (kind === 'periods') return this.closeEndedPeriods(now, limit);
    return {
      inbox: await this.processInbox(limit),
      reconciliation: await this.reconcile(new Date(now.getTime() - 3600000), limit),
      periods: await this.closeEndedPeriods(now, limit),
    };
  }
  private review(row: Record<string, any>) {
    return {
      id: row.id,
      kind: row.kind,
      purchaseId: row.purchase_id,
      status: row.state,
      amount: { currency: 'GHS', amountMinor: Number(row.amount_pesewas) },
      reason: row.reason,
      updatedAt: row.updated_at.toISOString(),
      editToken: `"payment-review:${row.id}:${row.version}"`,
    };
  }
  async reviews(actor: Actor, limit = 50, cursor?: string) {
    limitOf(limit);
    return this.tx(async (c) => {
      await this.admin(c, actor);
      const now = new Date(),
        ctx = `payment-reviews:${actor.userId}`,
        after = cursor ? this.cursors.decode(cursor, ctx, now) : null;
      const rows = (
        await c.query(
          `SELECT *,to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
    FROM app.payment_reviews WHERE state='open' AND ($1::timestamptz IS NULL OR (created_at,id)<($1::timestamptz,$2::uuid))
    ORDER BY created_at DESC,id DESC LIMIT $3`,
          [after?.time ?? null, after?.id ?? null, limit + 1],
        )
      ).rows;
      const page = rows.slice(0, limit),
        last = page.at(-1);
      return {
        items: page.map((r) => this.review(r)),
        nextCursor:
          rows.length > limit && last
            ? this.cursors.encode(last.cursor_time, last.id, ctx, now)
            : null,
      };
    });
  }
  async decide(
    actor: Actor,
    id: string,
    body: { decision: 'resolved' | 'waived'; reason: string },
    key: string,
    ifMatch: string | undefined,
  ) {
    id = id.toLowerCase();
    if (
      !key ||
      key.length > 128 ||
      !['resolved', 'waived'].includes(body.decision) ||
      !body.reason?.trim() ||
      body.reason.length > 2000
    )
      fail(400, 'invalid_request', 'A decision, reason and idempotency key are required.');
    const keyHash = digest(key),
      input = digest(canonical(body));
    return this.tx(async (c) => {
      await this.admin(c, actor);
      await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        JSON.stringify([actor.userId, id, keyHash]),
      ]);
      const row = (await c.query('SELECT * FROM app.payment_reviews WHERE id=$1 FOR UPDATE', [id]))
        .rows[0];
      if (!row) fail(404, 'not_found', 'Review not found.');
      const old = (
        await c.query(
          'SELECT * FROM app.payment_review_commands WHERE actor_user_id=$1 AND review_id=$2 AND key_hash=$3',
          [actor.userId, id, keyHash],
        )
      ).rows[0];
      if (old) {
        if (old.input_hash !== input)
          fail(409, 'idempotency_conflict', 'This key was used for different input.');
        return old.response_body;
      }
      if (!ifMatch) fail(428, 'precondition_required', 'An edit token is required.');
      if (ifMatch !== this.review(row).editToken)
        fail(412, 'precondition_failed', 'The review changed.');
      if (row.state !== 'open') fail(409, 'review_decided', 'This review already has a decision.');
      const updated = (
        await c.query(
          'UPDATE app.payment_reviews SET state=$2,decided_by=$3,decision_reason=$4 WHERE id=$1 RETURNING *',
          [id, body.decision, actor.userId, body.reason],
        )
      ).rows[0];
      const response = this.review(updated);
      await c.query(
        `INSERT INTO app.payment_review_commands(actor_user_id,review_id,key_hash,input_hash,decision,reason,response_body)
    VALUES ($1,$2,$3,$4,$5,$6,$7)`,
        [actor.userId, id, keyHash, input, body.decision, body.reason, response],
      );
      return response;
    });
  }
}
