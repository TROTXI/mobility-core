// Card auto-renewal.
//
// A rider opts in. The next verified card payment saves that card and
// schedules the renewal of the period it bought. Five days before the period
// ends the rider is reminded; from three days before, the worker renews on the
// same terms (journeys, travel days, price, unused-ride credit) for a period of
// the same length, charges the saved card, and reads the outcome back through
// verified provider evidence. A declined charge is retried daily until the
// period ends. If a fare or the service has changed, the renewal stops and Ops
// sends a new offer instead.
import { createCipheriv, createDecipheriv, hkdfSync, randomBytes } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { beginTransaction } from '../db/transaction.js';
import type { Actor, Body, Outcome } from '../transport/service.js';
import { fail, mapDatabaseError, TransportError } from '../transport/errors.js';
import type {
  CardAuthorization,
  CheckoutInput,
  FinancialFoundation,
  PurchaseLeg,
} from './foundation.js';
import type { Pricing } from './pricing.js';
import { buildOfferTerms, type OfferTerms } from '../membership/offer-terms.js';
import { cursorCodec } from '../transport/cursor.js';

export const autoRenewalOperations = [
  'getAutoRenewal',
  'setAutoRenewal',
  'removeAutoRenewalCard',
  'runAutoRenewals',
  'listOpsAutoRenewals',
] as const;
export type AutoRenewalOperation = (typeof autoRenewalOperations)[number];

const DAY = 86_400_000;
/** The reminder goes out this long before the period ends. */
export const REMIND_BEFORE_DAYS = 5;
/** Charging starts this long before the period ends, then retries daily. */
export const CHARGE_BEFORE_DAYS = 3;
const PENDING = ['scheduled', 'reminded', 'failed'] as const;
/**
 * A pause or payment block that can still move or freeze period b's end.
 * Neither reminding nor renewing is right until it has settled.
 */
const HELD = `(EXISTS(SELECT 1 FROM app.personal_pauses p WHERE p.period_id=b.id AND p.state='planned')
  OR EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
  OR EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL))`;
/** Retries a little under a day apart, so a nightly run never skips a day. */
const RETRY = 23 * 3_600_000;

export type RenewalNoticeReason =
  'declined' | 'unconfirmed' | 'blocked' | 'fare_changed' | 'service_changed';
export interface RenewalNotice {
  userId: string;
  periodId: string;
  kind: 'renewal_upcoming' | 'renewal_failed' | 'renewal_needs_offer';
  card: { brand: string; last4: string } | null;
  /** The package price; `charged` is what a renewal attempt actually asked for. */
  price: number;
  charged?: number;
  periodEnd: Date;
  attempt?: number;
  reason?: RenewalNoticeReason;
  /** No retry follows before coverage ends. */
  lastAttempt?: boolean;
}
export interface RenewalEmail {
  renewalNotice: (c: PoolClient, notice: RenewalNotice) => Promise<string | undefined>;
  sendQueued?: (id: string) => Promise<void>;
}

export interface AutoRenewalOptions {
  pool: Pool;
  environment: 'test' | 'live';
  authorizeSession: (c: PoolClient, actor: Actor) => Promise<void>;
  financial: FinancialFoundation;
  pricing: Pricing;
  /** Seal and open the saved card's secret part, bound to its rider. */
  seal: (raw: Buffer, context: string) => Buffer;
  open: (sealed: Buffer, context: string) => Buffer;
  /** Ask Paystack to charge the saved card. Its answer is not evidence. */
  charge: (request: {
    reference: string;
    amountPesewas: number;
    email: string;
    authorizationCode: string;
  }) => Promise<void>;
  /** Verify the attempt with Paystack and process the evidence. */
  settle: (reference: string) => Promise<void>;
  email?: RenewalEmail;
  /** Signs Ops list cursors to the caller and filter. */
  cursorSecret: Buffer;
  now?: () => Date;
}

type Renewal = {
  id: string;
  user_id: string;
  period_id: string;
  state: string;
  renewal_purchase_id: string | null;
  attempts: number;
};
type Card = {
  id: string;
  ciphertext: Buffer | null;
  last4: string;
  brand: string;
  exp_month: number;
  exp_year: number;
};

const cardContext = (userId: string, environment: string) => `card:${environment}:${userId}`;

/**
 * Seal saved-card secrets under a key derived only for them, bound to the
 * rider and environment, so a sealed card cannot be replayed onto another.
 */
export function cardBox(root: Buffer) {
  if (root.length !== 32) throw new Error('A 32-byte root key is required for saved cards');
  const key = Buffer.from(hkdfSync('sha256', root, 'trotxi:card:v1', 'card-authorization', 32));
  return {
    seal(raw: Buffer, context: string) {
      const iv = randomBytes(12),
        c = createCipheriv('aes-256-gcm', key, iv);
      c.setAAD(Buffer.from(context));
      const payload = Buffer.concat([c.update(raw), c.final()]);
      return Buffer.concat([iv, c.getAuthTag(), payload]);
    },
    open(sealed: Buffer, context: string) {
      const c = createDecipheriv('aes-256-gcm', key, sealed.subarray(0, 12));
      c.setAAD(Buffer.from(context));
      c.setAuthTag(sealed.subarray(12, 28));
      return Buffer.concat([c.update(sealed.subarray(28)), c.final()]);
    },
  };
}
const dateOf = (d: Date) => d.toISOString().slice(0, 10);

const VIEWS = {
  attention: ['failed', 'needs_offer', 'charging'],
  open: ['scheduled', 'reminded', 'charging', 'failed', 'needs_offer'],
  all: [
    'scheduled',
    'reminded',
    'charging',
    'paid',
    'failed',
    'needs_offer',
    'lapsed',
    'cancelled',
  ],
} as const;

export class AutoRenewals {
  private readonly cursors;
  constructor(private readonly options: AutoRenewalOptions) {
    this.cursors = cursorCodec(options.cursorSecret);
  }
  private now() {
    return this.options.now?.() ?? new Date();
  }
  private async tx<T>(work: (c: PoolClient) => Promise<T>): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await beginTransaction(c);
      const out = await work(c);
      await c.query('COMMIT');
      return out;
    } catch (e) {
      await c.query('ROLLBACK');
      throw mapDatabaseError(e);
    } finally {
      c.release();
    }
  }
  private async rider(c: PoolClient, actor: Actor) {
    await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [actor.userId]);
    await this.options.authorizeSession(c, actor);
    const user = (
      await c.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL', [actor.userId])
    ).rows[0];
    if (user?.role !== 'commuter') fail(403, 'forbidden', 'Auto-renewal is for commuter accounts.');
  }
  private async operator(c: PoolClient, actor: Actor) {
    await this.options.authorizeSession(c, actor);
    const user = (
      await c.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL', [actor.userId])
    ).rows[0];
    if (user?.role !== 'admin') fail(403, 'forbidden', 'Operations access required.');
  }
  private async card(c: PoolClient, userId: string): Promise<Card | undefined> {
    return (
      await c.query<Card>(
        'SELECT * FROM app.card_authorizations WHERE user_id=$1 AND environment=$2 AND removed_at IS NULL',
        [userId, this.options.environment],
      )
    ).rows[0];
  }
  private async enabled(c: PoolClient, userId: string) {
    return !!(
      await c.query('SELECT 1 FROM app.auto_renewal_preferences WHERE user_id=$1 AND enabled', [
        userId,
      ])
    ).rowCount;
  }
  /** Stop every renewal that has not been charged yet. */
  private async cancelPending(c: PoolClient, userId: string) {
    await c.query(
      `UPDATE app.auto_renewals SET state='cancelled',next_attempt_at=NULL,updated_at=clock_timestamp()
       WHERE user_id=$1 AND state = ANY($2::text[])`,
      [userId, PENDING],
    );
  }
  /**
   * Schedule the renewal of the rider's latest open period, unless it has
   * already been renewed. Called when a card is saved or auto-renewal is
   * turned back on.
   */
  private async schedule(c: PoolClient, userId: string, periodId?: string) {
    const period = (
      await c.query(
        `SELECT b.id,b.effective_ends_at FROM app.billing_periods b
         JOIN app.purchases p ON p.id=b.purchase_id
         WHERE b.user_id=$1 AND b.state='open' AND p.offer_terms IS NOT NULL
           AND ($2::uuid IS NULL OR b.id=$2)
           AND NOT EXISTS(SELECT 1 FROM app.billing_periods n WHERE n.membership_id=b.membership_id
             AND n.id<>b.id AND n.state='open' AND n.starts_at>=b.effective_ends_at)
         ORDER BY b.starts_at DESC LIMIT 1`,
        [userId, periodId ?? null],
      )
    ).rows[0];
    if (!period) return;
    // No stored first charge date: it follows the period's end, which a
    // personal pause can still move.
    await c.query(
      `INSERT INTO app.auto_renewals(user_id,period_id) VALUES ($1,$2)
       ON CONFLICT (period_id) DO UPDATE SET state='scheduled',next_attempt_at=NULL,
         failure_code=NULL,updated_at=clock_timestamp()
       WHERE app.auto_renewals.state='cancelled'`,
      [userId, period.id],
    );
  }

  /**
   * A verified card payment carried a reusable card. Saved only if the rider
   * asked for auto-renewal; then the period it bought is scheduled to renew.
   * Runs inside the fulfilment transaction.
   */
  purchaseSettled = async (
    c: PoolClient,
    input: {
      userId: string;
      purchaseId: string;
      periodId: string;
      attemptId: string;
      environment: 'test' | 'live';
      authorization?: CardAuthorization;
    },
  ) => {
    await c.query(
      `UPDATE app.auto_renewals SET state='paid',next_attempt_at=NULL,failure_code=NULL,updated_at=clock_timestamp()
       WHERE renewal_purchase_id=$1`,
      [input.purchaseId],
    );
    if (input.environment !== this.options.environment) return;
    if (!(await this.enabled(c, input.userId))) return;
    // Paid some other way: the saved card still renews the new period.
    if (!input.authorization) {
      if (await this.card(c, input.userId)) await this.schedule(c, input.userId, input.periodId);
      return;
    }
    const a = input.authorization;
    const sealed = this.options.seal(
      Buffer.from(JSON.stringify({ code: a.code, email: a.email })),
      cardContext(input.userId, input.environment),
    );
    const current = await this.card(c, input.userId);
    if (current)
      await c.query(
        `UPDATE app.card_authorizations SET removed_at=clock_timestamp(),ciphertext=NULL WHERE id=$1`,
        [current.id],
      );
    await c.query(
      `INSERT INTO app.card_authorizations(user_id,environment,ciphertext,signature,last4,brand,exp_month,exp_year,bank,source_attempt_id)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)`,
      [
        input.userId,
        input.environment,
        sealed,
        a.signature,
        a.last4,
        a.brand,
        a.expMonth,
        a.expYear,
        a.bank,
        input.attemptId,
      ],
    );
    await this.schedule(c, input.userId, input.periodId);
  };

  private async view(c: PoolClient, userId: string): Promise<Body> {
    const card = await this.card(c, userId);
    const renewal = (
      await c.query(
        `SELECT r.state,r.failure_code,r.next_attempt_at,b.effective_ends_at,p.price_pesewas
         FROM app.auto_renewals r JOIN app.billing_periods b ON b.id=r.period_id
         JOIN app.purchases p ON p.id=b.purchase_id
         WHERE r.user_id=$1 AND r.state IN ('scheduled','reminded','charging','failed','needs_offer')
         ORDER BY b.effective_ends_at DESC LIMIT 1`,
        [userId],
      )
    ).rows[0];
    return {
      enabled: await this.enabled(c, userId),
      card: card
        ? {
            brand: card.brand,
            last4: card.last4,
            expMonth: card.exp_month,
            expYear: card.exp_year,
          }
        : null,
      upcoming: renewal
        ? {
            state: renewal.state,
            periodEndsAt: renewal.effective_ends_at.toISOString(),
            chargeFrom: new Date(
              renewal.effective_ends_at.getTime() - CHARGE_BEFORE_DAYS * DAY,
            ).toISOString(),
            nextAttemptAt: renewal.next_attempt_at?.toISOString() ?? null,
            price: { amountMinor: renewal.price_pesewas, currency: 'GHS' },
            failureCode: renewal.failure_code,
          }
        : null,
    };
  }

  async handle(
    actor: Actor,
    operation: AutoRenewalOperation,
    body: Body = {},
    query: Record<string, string | undefined> = {},
  ): Promise<Outcome> {
    if (operation === 'runAutoRenewals') return this.run(actor, body);
    if (operation === 'listOpsAutoRenewals') return this.list(actor, query);
    return this.tx(async (c) => {
      await this.rider(c, actor);
      if (operation === 'setAutoRenewal') {
        if (typeof body.enabled !== 'boolean')
          fail(400, 'invalid_request', 'Say whether auto-renewal is on.');
        await c.query(
          `INSERT INTO app.auto_renewal_preferences(user_id,enabled) VALUES ($1,$2)
           ON CONFLICT (user_id) DO UPDATE SET enabled=EXCLUDED.enabled,updated_at=clock_timestamp()`,
          [actor.userId, body.enabled],
        );
        if (body.enabled) {
          if (await this.card(c, actor.userId)) await this.schedule(c, actor.userId);
        } else await this.cancelPending(c, actor.userId);
      }
      if (operation === 'removeAutoRenewalCard') {
        const card = await this.card(c, actor.userId);
        if (!card) fail(404, 'not_found', 'No saved card.');
        // Our sealed copy is destroyed now, and every renewal checks for it
        // again just before charging. Paystack's own payment evidence keeps
        // its separate retention period.
        await c.query(
          'UPDATE app.card_authorizations SET removed_at=clock_timestamp(),ciphertext=NULL WHERE id=$1',
          [card.id],
        );
        await c.query(
          `INSERT INTO app.auto_renewal_preferences(user_id,enabled) VALUES ($1,false)
           ON CONFLICT (user_id) DO UPDATE SET enabled=false,updated_at=clock_timestamp()`,
          [actor.userId],
        );
        await this.cancelPending(c, actor.userId);
        return { status: 204, headers: {}, body: null };
      }
      return { status: 200, headers: {}, body: { data: await this.view(c, actor.userId) } };
    });
  }

  /**
   * Renewals for Ops, soonest-ending first. The default view is the ones a
   * person has to act on: declined, unconfirmed, or waiting on a new offer.
   */
  private async list(actor: Actor, query: Record<string, string | undefined>): Promise<Outcome> {
    const view = (query.filter ?? 'attention') as keyof typeof VIEWS;
    if (!Object.hasOwn(VIEWS, view)) fail(400, 'invalid_query', 'Unknown renewal filter.');
    const limit = query.limit === undefined ? 50 : Number(query.limit);
    if (!Number.isInteger(limit) || limit < 1 || limit > 200)
      fail(400, 'invalid_query', 'Limit must be between 1 and 200.');
    const context = `${actor.userId}:auto-renewals:${view}`;
    const now = new Date();
    const cursor = query.cursor ? this.cursors.decode(query.cursor, context, now) : null;
    return this.tx(async (c) => {
      await this.operator(c, actor);
      const rows = (
        await c.query(
          `SELECT r.*,u.display_name,b.effective_ends_at,p.price_pesewas,k.brand,k.last4,
             to_char(b.effective_ends_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
           FROM app.auto_renewals r
           JOIN app.users u ON u.id=r.user_id AND u.deleted_at IS NULL
           JOIN app.billing_periods b ON b.id=r.period_id
           JOIN app.purchases p ON p.id=b.purchase_id
           LEFT JOIN app.card_authorizations k ON k.user_id=r.user_id AND k.removed_at IS NULL
           WHERE r.state = ANY($1::text[])
             AND ($2::timestamptz IS NULL OR (b.effective_ends_at,r.id)>($2::timestamptz,$3::uuid))
           ORDER BY b.effective_ends_at,r.id LIMIT $4`,
          [VIEWS[view], cursor?.time ?? null, cursor?.id ?? null, limit + 1],
        )
      ).rows;
      const last = rows[limit - 1];
      return {
        status: 200,
        headers: {},
        body: {
          data: rows.slice(0, limit).map((r) => ({
            id: r.id,
            riderId: r.user_id,
            riderName: r.display_name,
            state: r.state,
            failureCode: r.failure_code,
            attempts: r.attempts,
            periodEndsAt: r.effective_ends_at.toISOString(),
            nextAttemptAt: r.next_attempt_at?.toISOString() ?? null,
            price: { amountMinor: r.price_pesewas, currency: 'GHS' },
            card: r.last4 ? { brand: r.brand, last4: r.last4 } : null,
            renewalPurchaseId: r.renewal_purchase_id,
            updatedAt: r.updated_at.toISOString(),
          })),
          page: {
            nextCursor:
              rows.length > limit && last
                ? this.cursors.encode(last.cursor_time, last.id, context, now)
                : null,
          },
        },
      };
    });
  }

  /** The renewal of a period on the terms the rider paid for it. */
  private async renewalTerms(
    c: PoolClient,
    periodId: string,
  ): Promise<
    | { terms: OfferTerms; input: CheckoutInput; sourcePurchaseId: string; price: number }
    | { stop: 'fare_changed' | 'service_changed' }
  > {
    const source = (
      await c.query(
        `SELECT p.id,p.plan,p.route_id,p.offer_terms,b.effective_ends_at
         FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id WHERE b.id=$1`,
        [periodId],
      )
    ).rows[0]!;
    const old = source.offer_terms as OfferTerms | null;
    const end = source.effective_ends_at as Date;
    // Renewal starts exactly where coverage ends; that must be a Ghana midnight.
    if (!old || end.getTime() % DAY !== 0) return { stop: 'service_changed' };
    const length = Date.parse(old.coverageEnd) - Date.parse(old.coverageStart);
    const legs: PurchaseLeg[] = old.legs.map((leg) => ({
      direction: leg.direction,
      scheduleId: leg.scheduleId,
      patternVersionId: leg.patternVersionId,
      pickupOccurrenceId: leg.pickupOccurrenceId,
      dropoffOccurrenceId: leg.dropoffOccurrenceId,
    }));
    const input: CheckoutInput = {
      plan: source.plan,
      routeId: source.route_id,
      legs,
      useCredit: true,
    };
    let terms: OfferTerms;
    try {
      await c.query('SAVEPOINT renewal_terms');
      terms = await buildOfferTerms(
        c,
        this.options.pricing,
        input,
        [...new Set(old.legs.flatMap((leg) => leg.travelDays))],
        {
          coverageStart: dateOf(end),
          coverageEnd: dateOf(new Date(end.getTime() + length)),
          expiresAt: end.toISOString(),
          price: old.price,
          credits: old.legs.map((leg) => ({
            direction: leg.direction,
            creditPerUnusedRide: leg.creditPerUnusedRide,
          })),
        },
        this.now(),
      );
      await c.query('RELEASE SAVEPOINT renewal_terms');
    } catch (error) {
      if (!(error instanceof TransportError)) throw error;
      await c.query('ROLLBACK TO SAVEPOINT renewal_terms');
      return { stop: 'service_changed' };
    }
    for (const leg of terms.legs) {
      const before = old.legs.find((l) => l.direction === leg.direction)!;
      if (leg.fare.amountMinor !== before.fare.amountMinor) return { stop: 'fare_changed' };
      if (leg.travelDays.join() !== before.travelDays.join()) return { stop: 'service_changed' };
    }
    return { terms, input, sourcePurchaseId: source.id, price: old.price.amountMinor };
  }

  private async notify(
    c: PoolClient,
    r: Renewal,
    kind: 'renewal_upcoming' | 'renewal_failed' | 'renewal_needs_offer',
    reason?: RenewalNoticeReason,
  ) {
    if (!this.options.email) return undefined;
    const period = (
      await c.query(
        `SELECT b.effective_ends_at,p.price_pesewas,
           (SELECT n.cash_due_pesewas FROM app.purchases n WHERE n.id=$2) AS charged
         FROM app.billing_periods b JOIN app.purchases p ON p.id=b.purchase_id WHERE b.id=$1`,
        [r.period_id, r.renewal_purchase_id],
      )
    ).rows[0]!;
    const card = await this.card(c, r.user_id);
    const end = period.effective_ends_at as Date;
    return this.options.email.renewalNotice(c, {
      userId: r.user_id,
      periodId: r.period_id,
      kind,
      card: card ? { brand: card.brand, last4: card.last4 } : null,
      price: period.price_pesewas,
      ...(period.charged === null ? {} : { charged: period.charged }),
      periodEnd: end,
      attempt: r.attempts,
      ...(reason ? { reason } : {}),
      lastAttempt: this.now().getTime() + RETRY >= end.getTime(),
    });
  }

  /** Set a renewal's state, with a reason and the next attempt where one applies. */
  private async mark(
    c: PoolClient,
    id: string,
    state: string,
    failure: string | null = null,
    next: Date | null = null,
  ) {
    await c.query(
      `UPDATE app.auto_renewals SET state=$2,failure_code=$3,next_attempt_at=$4,updated_at=clock_timestamp() WHERE id=$1`,
      [id, state, failure, next],
    );
  }

  private async run(actor: Actor, body: Body): Promise<Outcome> {
    const limit = body.limit === undefined ? 100 : Number(body.limit);
    if (!Number.isInteger(limit) || limit < 1 || limit > 100)
      fail(400, 'invalid_limit', 'Limit must be between 1 and 100.');
    const result = {
      considered: 0,
      succeeded: 0,
      blocked: 0,
      failed: 0,
      failures: [] as { resourceId: string; reason: string }[],
    };
    const now = this.now();
    const sent: string[] = [];
    const due = await this.tx(async (c) => {
      await this.operator(c, actor);
      // A renewal fulfilled since the last run is paid, never lapsed.
      await c.query(
        `UPDATE app.auto_renewals r SET state='paid',next_attempt_at=NULL,updated_at=clock_timestamp()
         FROM app.purchases p WHERE p.id=r.renewal_purchase_id AND p.state='fulfilled' AND r.state<>'paid'`,
      );
      // Ended without a renewal: nothing more to try.
      await c.query(
        `UPDATE app.auto_renewals r SET state='lapsed',next_attempt_at=NULL,updated_at=clock_timestamp()
         FROM app.billing_periods b WHERE b.id=r.period_id AND r.state = ANY($1::text[])
           AND b.effective_ends_at<=$2`,
        [[...PENDING, 'charging'], now],
      );
      // Reminders, once, five days before the end.
      const remind = (
        await c.query<Renewal>(
          `SELECT r.* FROM app.auto_renewals r JOIN app.billing_periods b ON b.id=r.period_id
           WHERE r.state='scheduled' AND b.state='open' AND b.effective_ends_at>$1
             AND b.effective_ends_at<=$1::timestamptz+make_interval(days=>$2)
             AND NOT ${HELD}
           ORDER BY b.effective_ends_at LIMIT $3 FOR UPDATE OF r SKIP LOCKED`,
          [now, REMIND_BEFORE_DAYS, limit],
        )
      ).rows;
      for (const r of remind) {
        const id = await this.notify(c, r, 'renewal_upcoming');
        if (id) sent.push(id);
        await c.query(
          "UPDATE app.auto_renewals SET state='reminded',updated_at=clock_timestamp() WHERE id=$1",
          [r.id],
        );
      }
      return (
        await c.query<Renewal>(
          `SELECT r.* FROM app.auto_renewals r JOIN app.billing_periods b ON b.id=r.period_id
           WHERE b.effective_ends_at>$2 AND (r.state='charging' OR (r.state = ANY($1::text[])
             AND b.effective_ends_at<=$2::timestamptz+make_interval(days=>$4)
             AND (r.next_attempt_at IS NULL OR r.next_attempt_at<=$2)))
           ORDER BY r.next_attempt_at NULLS FIRST,r.id LIMIT $3`,
          [PENDING, now, limit, CHARGE_BEFORE_DAYS],
        )
      ).rows;
    });
    for (const id of sent) await this.options.email?.sendQueued?.(id).catch(() => undefined);
    for (const r of due) {
      result.considered++;
      try {
        const outcome = await this.renew(r, now);
        if (outcome === 'paid') result.succeeded++;
        else if (outcome === 'blocked') result.blocked++;
        else {
          result.failed++;
          result.failures.push({ resourceId: r.id, reason: outcome });
        }
      } catch {
        result.failed++;
        result.failures.push({ resourceId: r.id, reason: 'unexpected_error' });
      }
    }
    return { status: 200, headers: {}, body: { data: result } };
  }

  /** One renewal: prepare and charge, or follow up a charge already made. */
  private async renew(
    r: Renewal,
    now: Date,
  ): Promise<'paid' | 'blocked' | 'card_declined' | 'charge_unconfirmed' | 'stopped'> {
    // A charge already made: its evidence decides, never a second charge.
    if (r.state === 'charging' && r.renewal_purchase_id) return this.followUp(r, now);
    const prepared = await this.tx(async (c) => {
      await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [r.user_id]);
      const current = (
        await c.query<Renewal>('SELECT * FROM app.auto_renewals WHERE id=$1 FOR UPDATE', [r.id])
      ).rows[0]!;
      // Claimed by a run that stopped before recording its purchase: resume
      // that same attempt. Its checkout key returns the same purchase and its
      // reference cannot be charged twice by Paystack.
      const resumed =
        current.state === 'charging' &&
        !current.renewal_purchase_id &&
        (
          await c.query(
            "SELECT 1 FROM app.auto_renewals WHERE id=$1 AND updated_at<clock_timestamp()-interval '10 minutes'",
            [r.id],
          )
        ).rowCount;
      if (!(PENDING as readonly string[]).includes(current.state) && !resumed) return null;
      if (!(await this.enabled(c, r.user_id))) {
        await this.mark(c, r.id, 'cancelled');
        return null;
      }
      const card = await this.card(c, r.user_id);
      if (!card?.ciphertext) {
        await this.mark(c, r.id, 'cancelled', 'no_card');
        return null;
      }
      // A pause or payment block can still move or freeze this period's end;
      // renewing under it would overlap the period it extends. Wait.
      const held = (
        await c.query(`SELECT 1 FROM app.billing_periods b WHERE b.id=$1 AND ${HELD}`, [
          r.period_id,
        ])
      ).rowCount;
      if (held) return null;
      const renewal = await this.renewalTerms(c, r.period_id);
      if ('stop' in renewal) {
        await this.mark(c, r.id, 'needs_offer', renewal.stop);
        return { stop: await this.notify(c, r, 'renewal_needs_offer', renewal.stop) };
      }
      const secret = JSON.parse(
        this.options
          .open(card.ciphertext, cardContext(r.user_id, this.options.environment))
          .toString('utf8'),
      ) as { code: string; email: string };
      const attempt = resumed ? current.attempts : current.attempts + 1;
      // Claimed in the transaction that checked it: a second run sees
      // 'charging' and leaves it alone.
      await c.query(
        `UPDATE app.auto_renewals SET state='charging',attempts=$2,renewal_purchase_id=NULL,
         next_attempt_at=NULL,failure_code=NULL,updated_at=clock_timestamp() WHERE id=$1`,
        [r.id, attempt],
      );
      return { renewal, secret, attempt, cardId: card.id };
    });
    if (!prepared) return 'blocked';
    if ('stop' in prepared) {
      if (prepared.stop) await this.options.email?.sendQueued?.(prepared.stop).catch(() => {});
      return 'stopped';
    }
    let purchase: Awaited<ReturnType<FinancialFoundation['checkout']>>;
    try {
      purchase = await this.options.financial.checkout(
        { userId: r.user_id, sessionId: '' },
        prepared.renewal.input,
        `auto-renewal:${r.period_id}:${prepared.attempt}`,
        now,
        undefined,
        { terms: prepared.renewal.terms, renews: prepared.renewal.sourcePurchaseId },
      );
    } catch (error) {
      if (!(error instanceof TransportError)) throw error;
      // The rider renewed another way: nothing left to do.
      if (['renewal_already_paid', 'coverage_active'].includes(error.code)) {
        await this.tx((c) => this.mark(c, r.id, 'cancelled', 'coverage_conflict'));
        return 'blocked';
      }
      // A checkout in progress, or a block on the account: try again tomorrow,
      // and tell the rider so they can pay another way.
      const notice = await this.tx(async (c) => {
        await this.mark(c, r.id, 'failed', 'renewal_blocked', new Date(now.getTime() + RETRY));
        return this.notify(c, { ...r, attempts: prepared.attempt }, 'renewal_failed', 'blocked');
      });
      if (notice) await this.options.email?.sendQueued?.(notice).catch(() => {});
      return 'blocked';
    }
    const reference = purchase.attempt?.reference as string;
    // Last check before money moves: still opted in, same card, account open,
    // and a purchase that is actually waiting for this payment.
    const go = await this.tx(async (c) => {
      await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [r.user_id]);
      await c.query(
        'UPDATE app.auto_renewals SET renewal_purchase_id=$2,updated_at=clock_timestamp() WHERE id=$1',
        [r.id, purchase.id],
      );
      const consent = (
        await c.query(
          `SELECT 1 FROM app.users u
           JOIN app.auto_renewal_preferences p ON p.user_id=u.id AND p.enabled
           JOIN app.card_authorizations k ON k.id=$2 AND k.user_id=u.id AND k.removed_at IS NULL
           WHERE u.id=$1 AND u.deleted_at IS NULL`,
          [r.user_id, prepared.cardId],
        )
      ).rowCount;
      if (consent && purchase.state === 'awaiting_payment' && purchase.attempt?.state === 'pending')
        return true;
      if (purchase.state === 'awaiting_payment') {
        // Nothing was sent to Paystack: withdraw the purchase and its hold.
        await c.query(
          "UPDATE app.credit_holds SET state='released',settled_at=clock_timestamp() WHERE purchase_id=$1 AND state='held'",
          [purchase.id],
        );
        await c.query(
          "UPDATE app.payment_attempts SET state='failed' WHERE purchase_id=$1 AND state='pending'",
          [purchase.id],
        );
        await c.query(
          "UPDATE app.purchases SET state='cancelled',failure_code='renewal_withdrawn',updated_at=clock_timestamp() WHERE id=$1",
          [purchase.id],
        );
      }
      if (!consent) await this.mark(c, r.id, 'cancelled');
      return false;
    });
    if (!go)
      return purchase.state === 'fulfilled'
        ? this.followUp({ ...r, state: 'charging', renewal_purchase_id: purchase.id }, now)
        : 'blocked';
    try {
      await this.options.charge({
        reference,
        amountPesewas: purchase.cashDuePesewas,
        email: prepared.secret.email,
        authorizationCode: prepared.secret.code,
      });
    } catch {
      // The request may or may not have reached Paystack; evidence decides.
    }
    return this.followUp({ ...r, state: 'charging', renewal_purchase_id: purchase.id }, now);
  }

  /** Read the charge's outcome back through verified evidence. */
  private async followUp(
    r: Renewal,
    now: Date,
  ): Promise<'paid' | 'blocked' | 'card_declined' | 'charge_unconfirmed'> {
    const outcome = await this.readOutcome(r, now);
    if (typeof outcome === 'object') {
      if (outcome.notice) await this.options.email?.sendQueued?.(outcome.notice).catch(() => {});
      return outcome.reason;
    }
    return outcome;
  }
  private async readOutcome(
    r: Renewal,
    now: Date,
  ): Promise<
    | 'paid'
    | 'charge_unconfirmed'
    | { notice: string | undefined; reason: 'card_declined' | 'charge_unconfirmed' }
  > {
    const attempt = (
      await this.options.pool.query(
        `SELECT a.reference,a.state,p.state AS purchase_state FROM app.payment_attempts a
         JOIN app.purchases p ON p.id=a.purchase_id WHERE a.purchase_id=$1
         ORDER BY a.created_at DESC LIMIT 1`,
        [r.renewal_purchase_id],
      )
    ).rows[0];
    if (!attempt) return 'charge_unconfirmed';
    if (['pending', 'unknown'].includes(attempt.state))
      await this.options.settle(attempt.reference).catch(() => undefined);
    return this.tx(async (c) => {
      const current = (
        await c.query<Renewal>('SELECT * FROM app.auto_renewals WHERE id=$1 FOR UPDATE', [r.id])
      ).rows[0]!;
      if (current.state === 'paid') return 'paid';
      const purchase = (
        await c.query('SELECT state FROM app.purchases WHERE id=$1', [r.renewal_purchase_id])
      ).rows[0]!;
      if (purchase.state === 'fulfilled') {
        await this.mark(c, r.id, 'paid');
        return 'paid';
      }
      if (['failed', 'cancelled'].includes(purchase.state)) {
        await this.mark(c, r.id, 'failed', 'card_declined', new Date(now.getTime() + RETRY));
        return {
          notice: await this.notify(c, current, 'renewal_failed', 'declined'),
          reason: 'card_declined',
        };
      }
      // Unconfirmed for a day: the charge most likely never reached Paystack.
      // Withdraw this attempt so the rider can pay another way, and retry.
      // A collection that still arrives later goes to Ops review as late.
      const stale = (
        await c.query(
          `SELECT a.id FROM app.payment_attempts a WHERE a.purchase_id=$1
           AND a.state IN ('pending','unknown') AND a.created_at<=clock_timestamp()-interval '24 hours'`,
          [r.renewal_purchase_id],
        )
      ).rows[0];
      if (!stale) return 'charge_unconfirmed';
      await c.query(
        "UPDATE app.credit_holds SET state='released',settled_at=clock_timestamp() WHERE purchase_id=$1 AND state='held'",
        [r.renewal_purchase_id],
      );
      await c.query(
        "UPDATE app.purchases SET state='failed',failure_code='renewal_unconfirmed',updated_at=clock_timestamp() WHERE id=$1 AND state IN ('awaiting_payment','processing')",
        [r.renewal_purchase_id],
      );
      await this.mark(c, r.id, 'failed', 'charge_unconfirmed', new Date(now.getTime() + RETRY));
      return {
        notice: await this.notify(c, current, 'renewal_failed', 'unconfirmed'),
        reason: 'charge_unconfirmed',
      };
    });
  }
}
