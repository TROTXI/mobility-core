import { createHash, randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import type { Actor } from '../transport/service.js';
import { canonical } from '../transport/service.js';
import { fail, mapDatabaseError } from '../transport/errors.js';
import { billingEnd, MIN_CHARGE_PESEWAS, priceTerms, whole } from './terms.js';
import type { Plan, PricedTerms } from './terms.js';

export interface PurchaseLeg {
  direction: 'outbound' | 'return';
  scheduleId: string;
  patternVersionId: string;
  pickupOccurrenceId: string;
  dropoffOccurrenceId: string;
}
export interface CheckoutInput {
  plan: Plan;
  routeId: string;
  legs: PurchaseLeg[];
  useCredit: boolean;
}
export interface Settlement {
  reference: string;
  environment: 'test' | 'live';
  amountPesewas: number;
  currency: string;
  transactionId: string;
  paidAt: Date;
  channel: string | null;
  feesPesewas: number | null;
}
interface Boundary {
  userId: string;
  membershipId: string;
  now: Date;
}
export interface FinancialDependencies {
  pool: Pool;
  environment: 'test' | 'live';
  authorizeSession: (client: PoolClient, actor: Actor) => Promise<void>;
  // These MUST use this transaction client. No HTTP/provider calls or commits.
  // 012 supplies applicable account/period blocks; 013 supplies pause/reservation
  // facts and assignment materialization. Missing adapters fail closed.
  assertCheckoutAllowed?: (client: PoolClient, input: Boundary) => Promise<void>;
  assertPeriodCanClose?: (
    client: PoolClient,
    input: Boundary & { periodId: string },
  ) => Promise<void>;
  materializeAssignment?: (
    client: PoolClient,
    input: Boundary & { purchaseId: string; periodId: string },
  ) => Promise<void>;
  quote?: (client: PoolClient, input: CheckoutInput & Boundary) => Promise<PricedTerms>;
}
type PurchaseRow = {
  id: string;
  membership_id: string;
  user_id: string;
  state: string;
  plan: Plan;
  price_pesewas: number;
  cash_due_pesewas: number;
  applied_credit_pesewas: number;
  rides_granted: number;
  conversion_rate_pesewas: number;
  input_hash: string;
  created_at: Date;
};
const digest = (value: string) => createHash('sha256').update(value).digest('hex');
const normalized = (input: CheckoutInput): CheckoutInput => ({
  ...input,
  routeId: input.routeId.toLowerCase(),
  legs: input.legs
    .map((l) => ({
      ...l,
      scheduleId: l.scheduleId.toLowerCase(),
      patternVersionId: l.patternVersionId.toLowerCase(),
      pickupOccurrenceId: l.pickupOccurrenceId.toLowerCase(),
      dropoffOccurrenceId: l.dropoffOccurrenceId.toLowerCase(),
    }))
    .sort((a, b) => a.direction.localeCompare(b.direction)),
});

export class FinancialFoundation {
  constructor(private readonly options: FinancialDependencies) {
    if (!['test', 'live'].includes(options.environment))
      throw new Error('Explicit payment environment required');
  }
  private async tx<T>(work: (c: PoolClient) => Promise<T>): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await c.query('BEGIN');
      await c.query("SET LOCAL TIME ZONE 'UTC'");
      await c.query("SET LOCAL lock_timeout='3s'");
      await c.query("SET LOCAL statement_timeout='10s'");
      const result = await work(c);
      await c.query('COMMIT');
      return result;
    } catch (e) {
      await c.query('ROLLBACK');
      throw mapDatabaseError(e);
    } finally {
      c.release();
    }
  }
  private async lock(c: PoolClient, userId: string) {
    const user = (
      await c.query('SELECT id FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR UPDATE', [
        userId,
      ])
    ).rows[0];
    if (!user) fail(401, 'unauthenticated', 'Account unavailable.');
  }
  private async balances(c: PoolClient, userId: string) {
    const r = (
      await c.query(
        `SELECT
    COALESCE((SELECT SUM(delta_pesewas) FROM app.credit_entries WHERE user_id=$1),0)::text AS credit,
    COALESCE((SELECT SUM(amount_pesewas) FROM app.credit_holds WHERE user_id=$1 AND state='held'),0)::text AS held`,
        [userId],
      )
    ).rows[0];
    const credit = Number(r.credit),
      held = Number(r.held);
    if (!Number.isSafeInteger(credit) || !Number.isSafeInteger(held) || credit < held || held < 0)
      fail(409, 'invalid_credit_balance', 'Credit requires reconciliation.');
    return { credit, held, available: credit - held };
  }
  async checkout(actor: Actor, raw: CheckoutInput, key: string, now = new Date()) {
    if (!key || key.length > 128 || !Number.isFinite(now.getTime()))
      fail(400, 'invalid_request', 'Invalid checkout request.');
    const input = normalized(raw),
      hash = digest(canonical({ ...input, legs: input.legs.map((leg) => ({ ...leg })) }));
    if (
      !['monthly', 'annual'].includes(input.plan) ||
      typeof input.useCredit !== 'boolean' ||
      input.legs.length !== 2
    )
      fail(400, 'invalid_request', 'Invalid purchase selection.');
    return this.tx(async (c) => {
      await this.lock(c, actor.userId);
      await this.options.authorizeSession(c, actor);
      const old = (
        await c.query<PurchaseRow>(
          'SELECT * FROM app.purchases WHERE user_id=$1 AND checkout_key_hash=$2',
          [actor.userId, digest(key)],
        )
      ).rows[0];
      if (old) {
        if (old.input_hash !== hash)
          fail(409, 'idempotency_conflict', 'This key was used for different input.');
        const clock = (await c.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
        if (clock.getTime() - old.created_at.getTime() >= 7 * 86400000)
          fail(409, 'idempotency_expired', 'Use a new request key.');
        return this.purchaseResult(c, old);
      }
      if (!this.options.assertCheckoutAllowed || !this.options.quote)
        fail(503, 'financial_dependencies_unavailable', 'Checkout is not configured.');
      if (
        (
          await c.query(
            "SELECT id FROM app.purchases WHERE user_id=$1 AND state IN ('awaiting_payment','processing','review_required')",
            [actor.userId],
          )
        ).rowCount
      )
        fail(409, 'purchase_unresolved', 'Resolve the existing purchase first.');
      let membership = (
        await c.query('SELECT * FROM app.memberships WHERE user_id=$1 FOR UPDATE', [actor.userId])
      ).rows[0];
      if (membership?.lifecycle === 'ended')
        fail(409, 'membership_ended', 'Membership requires an explicit new-service decision.');
      if (!membership)
        membership = (
          await c.query('INSERT INTO app.memberships(user_id) VALUES ($1) RETURNING *', [
            actor.userId,
          ])
        ).rows[0];
      const boundary = { userId: actor.userId, membershipId: membership.id, now };
      await this.options.assertCheckoutAllowed(c, boundary);
      const open = (
        await c.query(
          "SELECT id,effective_ends_at FROM app.billing_periods WHERE membership_id=$1 AND state='open' FOR UPDATE",
          [membership.id],
        )
      ).rows[0];
      if (open) {
        if (open.effective_ends_at > now)
          fail(409, 'coverage_active', 'Current paid coverage has not ended.');
        await this.closeOne(c, open.id, boundary);
      }
      // Validate the immutable transport references before freezing the quote.
      for (const leg of input.legs) {
        const r = (
          await c.query(
            `SELECT s.id FROM app.service_schedules s
     JOIN app.route_pattern_versions v ON v.id=s.pattern_version_id JOIN app.route_patterns p ON p.id=v.pattern_id
     JOIN app.routes r ON r.id=p.route_id JOIN app.route_pattern_stops a ON a.id=$4 AND a.pattern_version_id=v.id
     JOIN app.route_pattern_stops b ON b.id=$5 AND b.pattern_version_id=v.id
     WHERE s.id=$1 AND v.id=$2 AND p.route_id=$3 AND p.direction=$6 AND a.ordinal<b.ordinal
     AND r.archived_at IS NULL AND v.state='published' AND v.effective_from<=$7
     AND (v.effective_to IS NULL OR v.effective_to>$7)
     AND s.effective_from<=($7::timestamptz AT TIME ZONE 'Africa/Accra')::date
     AND (s.effective_to IS NULL OR s.effective_to>=($7::timestamptz AT TIME ZONE 'Africa/Accra')::date)
     FOR SHARE OF s,v,p,r`,
            [
              leg.scheduleId,
              leg.patternVersionId,
              input.routeId,
              leg.pickupOccurrenceId,
              leg.dropoffOccurrenceId,
              leg.direction,
              now,
            ],
          )
        ).rowCount;
        if (!r)
          fail(409, 'invalid_commute_selection', 'Select current ordered stops and service legs.');
      }
      const quoted = await this.options.quote(c, { ...input, ...boundary }),
        terms = priceTerms(quoted);
      if (terms.pricePesewas !== quoted.pricePesewas)
        fail(409, 'invalid_quote', 'Price does not match its terms.');
      const balances = await this.balances(c, actor.userId);
      const applied = input.useCredit
        ? Math.min(balances.available, terms.pricePesewas - MIN_CHARGE_PESEWAS)
        : 0;
      const p = (
        await c.query<PurchaseRow>(
          `INSERT INTO app.purchases(membership_id,user_id,route_id,plan,price_pesewas,
    applied_credit_pesewas,cash_due_pesewas,currency,rides_granted,fare_pesewas,price_multiplier_bp,conversion_rate_pesewas,checkout_key_hash,input_hash)
    VALUES ($1,$2,$3,$4,$5,$6,$7,'GHS',$8,$9,$10,$11,$12,$13) RETURNING *`,
          [
            membership.id,
            actor.userId,
            input.routeId,
            input.plan,
            terms.pricePesewas,
            applied,
            terms.pricePesewas - applied,
            terms.ridesGranted,
            terms.farePesewas,
            terms.priceMultiplierBp,
            terms.conversionRatePesewas,
            digest(key),
            hash,
          ],
        )
      ).rows[0]!;
      for (const l of input.legs)
        await c.query('INSERT INTO app.purchase_legs VALUES ($1,$2,$3,$4,$5,$6)', [
          p.id,
          l.direction,
          l.scheduleId,
          l.patternVersionId,
          l.pickupOccurrenceId,
          l.dropoffOccurrenceId,
        ]);
      if (applied > 0)
        await c.query(
          'INSERT INTO app.credit_holds(purchase_id,user_id,amount_pesewas) VALUES ($1,$2,$3)',
          [p.id, actor.userId, applied],
        );
      const reference = 'tx-' + randomUUID().replaceAll('-', '');
      await c.query(
        "INSERT INTO app.payment_attempts(purchase_id,user_id,provider,environment,reference,amount_pesewas,currency) VALUES ($1,$2,'paystack',$3,$4,$5,'GHS')",
        [p.id, actor.userId, this.options.environment, reference, p.cash_due_pesewas],
      );
      return this.purchaseResult(c, p);
    });
  }
  private async purchaseResult(c: PoolClient, p: PurchaseRow) {
    const attempt = (
      await c.query(
        'SELECT id,reference,state FROM app.payment_attempts WHERE purchase_id=$1 ORDER BY created_at DESC,id DESC LIMIT 1',
        [p.id],
      )
    ).rows[0];
    return {
      id: p.id,
      membershipId: p.membership_id,
      state: p.state,
      pricePesewas: p.price_pesewas,
      appliedCreditPesewas: p.applied_credit_pesewas,
      cashDuePesewas: p.cash_due_pesewas,
      attempt,
    };
  }
  async fulfill(
    s: Settlement,
  ): Promise<'fulfilled' | 'already_fulfilled' | 'not_pending' | 'mismatch'> {
    return this.tx((c) => this.fulfillInTransaction(c, s));
  }
  // Inbox processing owns the transaction: effect and acknowledgement commit
  // together. No nested transaction, network call or independent pool query.
  async fulfillInTransaction(
    c: PoolClient,
    s: Settlement,
  ): Promise<'fulfilled' | 'already_fulfilled' | 'not_pending' | 'mismatch'> {
    if (
      s.environment !== this.options.environment ||
      s.currency !== 'GHS' ||
      !s.transactionId ||
      !Number.isFinite(s.paidAt.getTime())
    )
      return 'mismatch';
    try {
      whole(s.amountPesewas, 100);
      if (s.feesPesewas !== null) whole(s.feesPesewas);
    } catch {
      return 'mismatch';
    }
    const peek = (
      await c.query(
        "SELECT user_id FROM app.payment_attempts WHERE provider='paystack' AND environment=$1 AND reference=$2",
        [s.environment, s.reference],
      )
    ).rows[0];
    if (!peek) return 'not_pending';
    await this.lock(c, peek.user_id);
    const a = (
      await c.query(
        "SELECT * FROM app.payment_attempts WHERE provider='paystack' AND environment=$1 AND reference=$2 FOR UPDATE",
        [s.environment, s.reference],
      )
    ).rows[0];
    if (a.amount_pesewas !== s.amountPesewas || a.currency !== s.currency) return 'mismatch';
    const p = (
      await c.query<PurchaseRow>('SELECT * FROM app.purchases WHERE id=$1 FOR UPDATE', [
        a.purchase_id,
      ])
    ).rows[0]!;
    if (a.state === 'successful')
      return a.provider_transaction_id === s.transactionId && p.state === 'fulfilled'
        ? 'already_fulfilled'
        : 'mismatch';
    if (
      !['pending', 'unknown'].includes(a.state) ||
      !['awaiting_payment', 'processing'].includes(p.state)
    )
      return 'not_pending';
    if (!this.options.materializeAssignment)
      fail(503, 'financial_dependencies_unavailable', 'Fulfilment is not configured.');
    const now = (await c.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
    await c.query(
      "UPDATE app.payment_attempts SET state='successful',provider_transaction_id=$2,paid_at=$3,channel=$4,fees_pesewas=$5 WHERE id=$1",
      [a.id, s.transactionId, s.paidAt, s.channel, s.feesPesewas],
    );
    await c.query("UPDATE app.purchases SET state='fulfilled',updated_at=$2 WHERE id=$1", [
      p.id,
      now,
    ]);
    const end = billingEnd(p.plan, s.paidAt);
    const period = (
      await c.query(
        `INSERT INTO app.billing_periods(purchase_id,membership_id,user_id,starts_at,original_ends_at,effective_ends_at)
    VALUES ($1,$2,$3,$4,$5,$5) RETURNING id`,
        [p.id, p.membership_id, p.user_id, s.paidAt, end],
      )
    ).rows[0];
    if (p.applied_credit_pesewas > 0) {
      await this.balances(c, p.user_id);
      const hold = await c.query(
        "UPDATE app.credit_holds SET state='captured',settled_at=$2 WHERE purchase_id=$1 AND state='held' RETURNING amount_pesewas",
        [p.id, now],
      );
      if (hold.rowCount !== 1 || hold.rows[0].amount_pesewas !== p.applied_credit_pesewas)
        fail(409, 'credit_hold_missing', 'Reserved credit requires reconciliation.');
      await c.query(
        "INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,purchase_id) VALUES ($1,'purchase_applied',$2,$3)",
        [p.user_id, -p.applied_credit_pesewas, p.id],
      );
    }
    await c.query(
      "INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides) VALUES ($1,$2,'allocation',$3)",
      [p.user_id, period.id, p.rides_granted],
    );
    await this.options.materializeAssignment(c, {
      userId: p.user_id,
      membershipId: p.membership_id,
      purchaseId: p.id,
      periodId: period.id,
      now: s.paidAt,
    });
    return 'fulfilled';
  }
  private async closeOne(c: PoolClient, periodId: string, b: Boundary) {
    if (!this.options.assertPeriodCanClose)
      fail(503, 'financial_dependencies_unavailable', 'Period close is not configured.');
    const period = (
      await c.query('SELECT * FROM app.billing_periods WHERE id=$1 FOR UPDATE', [periodId])
    ).rows[0];
    if (!period || period.user_id !== b.userId || period.membership_id !== b.membershipId)
      fail(409, 'invalid_period_owner', 'Invalid period.');
    if (period.state !== 'open' || period.effective_ends_at > b.now) return false;
    if (
      (
        await c.query(
          'SELECT 1 FROM app.payment_access_blocks WHERE period_id=$1 AND released_at IS NULL LIMIT 1',
          [periodId],
        )
      ).rowCount
    )
      fail(409, 'period_payment_blocked', 'A payment dispute blocks this period.');
    await this.options.assertPeriodCanClose(c, { ...b, periodId });
    const p = (
      await c.query<PurchaseRow>('SELECT * FROM app.purchases WHERE id=$1', [period.purchase_id])
    ).rows[0]!;
    const rides = Number(
      (
        await c.query(
          'SELECT COALESCE(SUM(delta_rides),0)::text AS rides FROM app.ride_entries WHERE period_id=$1',
          [periodId],
        )
      ).rows[0].rides,
    );
    if (!Number.isSafeInteger(rides) || rides < 0 || rides > p.rides_granted)
      fail(409, 'invalid_ride_balance', 'Period requires reconciliation.');
    const credit = whole(rides * p.conversion_rate_pesewas);
    const close = (
      await c.query(
        `INSERT INTO app.period_closures(period_id,user_id,rides_converted,conversion_rate_pesewas,credit_granted_pesewas,closed_at)
   VALUES ($1,$2,$3,$4,$5,$6) RETURNING id`,
        [periodId, b.userId, rides, p.conversion_rate_pesewas, credit, b.now],
      )
    ).rows[0];
    if (rides > 0)
      await c.query(
        "INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides,closure_id) VALUES ($1,$2,'converted',$3,$4)",
        [b.userId, periodId, -rides, close.id],
      );
    if (credit > 0)
      await c.query(
        "INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,closure_id) VALUES ($1,'month_end_conversion',$2,$3)",
        [b.userId, credit, close.id],
      );
    await c.query("UPDATE app.billing_periods SET state='closed' WHERE id=$1", [periodId]);
    return true;
  }
  async closePeriod(periodId: string, now = new Date()) {
    return this.tx(async (c) => {
      const p = (
        await c.query('SELECT user_id,membership_id FROM app.billing_periods WHERE id=$1', [
          periodId,
        ])
      ).rows[0];
      if (!p) fail(404, 'not_found', 'Period not found.');
      await this.lock(c, p.user_id);
      return this.closeOne(c, periodId, { userId: p.user_id, membershipId: p.membership_id, now });
    });
  }
  async balance(actor: Actor) {
    return this.tx(async (c) => {
      await this.lock(c, actor.userId);
      await this.options.authorizeSession(c, actor);
      return this.balances(c, actor.userId);
    });
  }
}
