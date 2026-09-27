import { createHash } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { fail } from '../transport/errors.js';
import { canonical } from '../transport/service.js';
import type { Actor, Body, Outcome } from '../transport/service.js';
import { cursorCodec } from '../transport/cursor.js';
import type { PricedTerms } from './terms.js';
import { appliedCredit, MIN_CHARGE_PESEWAS, priceTerms } from './terms.js';

export const pricingOperations = [
  'previewPurchase',
  'listFares',
  'createFare',
  'listPlanPricing',
  'updatePlanPricing',
] as const;
export type PricingOperation = (typeof pricingOperations)[number];

export interface PricingOptions {
  pool: Pool;
  authorizeSession: (client: PoolClient, actor: Actor) => Promise<void>;
  cursorSecret: Buffer;
  now?: () => Date;
}

type Row = Record<string, any>;
const digest = (value: string) => createHash('sha256').update(value).digest('hex');
const iso = (value: Date) => value.toISOString();
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const id = (value: unknown): string => {
  if (typeof value !== 'string' || !uuid.test(value)) fail(404, 'not_found', 'Resource not found.');
  return (value as string).toLowerCase();
};
const plans = ['monthly', 'annual'];
/** The contract carries money as an amount and its currency, never a bare int. */
const money = (amountMinor: number) => ({ amountMinor, currency: 'GHS' });
function minor(value: unknown, field: string): number {
  const amount = (value as { amountMinor?: unknown; currency?: unknown } | undefined) ?? {};
  if (
    !Number.isSafeInteger(amount.amountMinor) ||
    (amount.amountMinor as number) < 0 ||
    (amount.amountMinor as number) > 2147483647 ||
    amount.currency !== 'GHS'
  )
    fail(400, 'invalid_request', `Supply ${field} as whole pesewas in GHS.`);
  return amount.amountMinor as number;
}
const planToken = (r: Row) => `"pricing:${r.plan}:${r.version}"`;

/** The fare a corridor charges and what a plan grants for it. */
export class Pricing {
  private readonly cursors;
  constructor(private readonly options: PricingOptions) {
    this.cursors = cursorCodec(options.cursorSecret);
  }
  private now() {
    return this.options.now?.() ?? new Date();
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
    } catch (error) {
      await c.query('ROLLBACK').catch(() => undefined);
      throw error;
    } finally {
      c.release();
    }
  }
  private async authorize(c: PoolClient, actor: Actor, role = 'admin') {
    await this.options.authorizeSession(c, actor);
    const user = (
      await c.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR SHARE', [
        id(actor.userId),
      ])
    ).rows[0];
    if (!user) fail(401, 'unauthenticated', 'Sign in to continue.');
    if (user.role !== role) fail(403, 'forbidden', 'This operation is not permitted.');
  }

  /** A non-binding read: no purchase, membership, hold, or provider request. */
  async preview(actor: Actor, input: Body): Promise<Outcome> {
    const routeId = id(input.routeId);
    if (!plans.includes(input.plan as string) || typeof input.useCredit !== 'boolean')
      fail(400, 'invalid_request', 'Supply a plan, route and credit preference.');
    return this.tx(async (c) => {
      // Match financial writers' rider-first lock order, without mutating it.
      await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [id(actor.userId)]);
      await this.authorize(c, actor, 'commuter');
      const now = this.now();
      if (
        !(
          await c.query(
            `SELECT r.id FROM app.routes r WHERE r.id=$1 AND r.archived_at IS NULL
        AND EXISTS(SELECT 1 FROM app.route_patterns p JOIN app.route_pattern_versions v ON v.pattern_id=p.id
          WHERE p.route_id=r.id AND v.state IN ('published','retired') AND v.effective_from<=$2
          AND (v.effective_to IS NULL OR v.effective_to>$2)) FOR SHARE OF r`,
            [routeId, now],
          )
        ).rowCount
      )
        fail(404, 'not_found', 'Resource not found.');
      const terms = priceTerms(await this.quote(c, { routeId, plan: input.plan as string, now }));
      const row = (
        await c.query(
          `SELECT
        COALESCE((SELECT SUM(delta_pesewas) FROM app.credit_entries WHERE user_id=$1),0)::text credit,
        COALESCE((SELECT SUM(amount_pesewas) FROM app.credit_holds WHERE user_id=$1 AND state='held'),0)::text held`,
          [actor.userId],
        )
      ).rows[0];
      const credit = Number(row.credit),
        held = Number(row.held),
        available = credit - held;
      if (!Number.isSafeInteger(credit) || !Number.isSafeInteger(held) || held < 0 || available < 0)
        fail(409, 'invalid_credit_balance', 'Credit requires reconciliation.');
      const applied = appliedCredit(terms.pricePesewas, available, input.useCredit as boolean);
      return {
        status: 200,
        headers: {},
        body: {
          data: {
            routeId,
            plan: input.plan as string,
            ridesGranted: terms.ridesGranted,
            fare: money(terms.farePesewas),
            price: money(terms.pricePesewas),
            availableCredit: money(available),
            appliedCredit: money(applied),
            cashDue: money(terms.pricePesewas - applied),
            minimumCashDue: money(MIN_CHARGE_PESEWAS),
            renewalMode: 'manual',
            binding: false,
            quotedAt: iso(now),
          },
        },
      };
    });
  }

  /**
   * The price of a corridor at a moment, composed from the fare in force and
   * what the plan grants for it.
   *
   * Read with the caller's client inside the checkout transaction, so the fare
   * a purchase freezes is the fare that was in force when it was priced, and
   * an ops change committed a moment later cannot reprice it.
   */
  quote = async (
    c: PoolClient,
    input: { routeId: string; plan: string; now: Date },
  ): Promise<PricedTerms> => {
    const plan = (
      await c.query('SELECT * FROM app.plan_pricing WHERE plan=$1 FOR SHARE', [input.plan])
    ).rows[0];
    if (!plan) fail(409, 'pricing_unavailable', 'This plan has no published pricing.');
    const fare = await this.fare(c, id(input.routeId), input.now);
    const terms = {
      ridesGranted: plan.rides_per_period,
      farePesewas: fare,
      priceMultiplierBp: plan.price_multiplier_bp,
      conversionRatePesewas: plan.credit_per_ride_pesewas,
    };
    // The foundation reprices from these and refuses a mismatch, so the
    // arithmetic lives in one place rather than being restated here.
    const price =
      (BigInt(terms.farePesewas) * BigInt(terms.ridesGranted) * BigInt(terms.priceMultiplierBp) +
        5000n) /
      10000n;
    if (price > 2147483647n) fail(409, 'pricing_unavailable', 'This price is out of range.');
    return { ...terms, pricePesewas: Number(price) };
  };

  /** The fare a rider's chosen commute would be charged at, for a transfer. */
  fareForSelection = async (c: PoolClient, selectionId: string): Promise<number> => {
    const selection = (
      await c.query('SELECT route_id FROM app.commute_selections WHERE id=$1', [id(selectionId)])
    ).rows[0];
    if (!selection) fail(404, 'not_found', 'Resource not found.');
    return this.fare(c, selection.route_id, this.now());
  };

  private async fare(c: PoolClient, routeId: string, at: Date): Promise<number> {
    const row = (
      await c.query(
        `SELECT amount_pesewas FROM app.route_fares
        WHERE route_id=$1 AND effective_from<=$2 AND (effective_to IS NULL OR $2<effective_to)
        FOR SHARE`,
        [routeId, at],
      )
    ).rows[0];
    // Fail closed. A corridor with no published fare is not free.
    if (!row) fail(409, 'pricing_unavailable', 'This corridor has no fare in force.');
    return row.amount_pesewas as number;
  }

  private fareView(r: Row): Body {
    return {
      id: r.id,
      routeId: r.route_id,
      amount: money(r.amount_pesewas),
      effectiveFrom: iso(r.effective_from),
      effectiveTo: r.effective_to ? iso(r.effective_to) : null,
      ...(r.note === null ? {} : { note: r.note }),
    };
  }
  private planView(r: Row): Body {
    return {
      plan: r.plan,
      ridesPerPeriod: r.rides_per_period,
      priceMultiplierBp: r.price_multiplier_bp,
      takeRateBp: r.take_rate_bp,
      creditPerRide: money(r.credit_per_ride_pesewas),
      editToken: planToken(r),
      version: r.version,
    };
  }

  async read(
    actor: Actor,
    operation: PricingOperation,
    params: { id?: string },
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    return this.tx(async (c) => {
      await this.authorize(c, actor);
      const limit = query.limit === undefined ? 50 : Number(query.limit);
      if (
        !Number.isInteger(limit) ||
        limit < 1 ||
        limit > 200 ||
        (query.limit !== undefined && !/^[1-9]\d*$/.test(query.limit))
      )
        fail(400, 'invalid_query', 'Invalid page size.');
      if (operation === 'listPlanPricing') {
        // Two plans exist and neither is created or removed at runtime, so the
        // page is the table and a cursor would only be ceremony.
        const rows = (await c.query('SELECT * FROM app.plan_pricing ORDER BY plan')).rows;
        return {
          status: 200,
          body: { data: rows.map((r) => this.planView(r)), page: { nextCursor: null } },
          headers: {},
        };
      }
      const routeId = id(params.id);
      if (!(await c.query('SELECT 1 FROM app.routes WHERE id=$1', [routeId])).rowCount)
        fail(404, 'not_found', 'Resource not found.');
      const context = canonical(['pricing', operation, routeId, 'effective_from,id']);
      const cursor = query.cursor ? this.cursors.decode(query.cursor, context, this.now()) : null;
      const rows = (
        await c.query(
          `SELECT *,to_char(effective_from AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
          FROM app.route_fares
          WHERE route_id=$1
            AND ($2::timestamptz IS NULL OR (effective_from,id)<($2::timestamptz,$3::uuid))
          ORDER BY effective_from DESC,id DESC LIMIT $4`,
          [routeId, cursor?.time ?? null, cursor?.id ?? null, limit + 1],
        )
      ).rows;
      const page = rows.slice(0, limit);
      const last = page[page.length - 1];
      return {
        status: 200,
        body: {
          data: page.map((r) => this.fareView(r)),
          page: {
            nextCursor:
              rows.length > limit && last
                ? this.cursors.encode(last.cursor_time, last.id, context, this.now())
                : null,
          },
        },
        headers: {},
      };
    });
  }

  async command(
    actor: Actor,
    operation: PricingOperation,
    target: string,
    input: Body,
    key: string,
    ifMatch?: string,
  ): Promise<Outcome> {
    if (typeof key !== 'string' || !key.length || key.length > 128)
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key of 1 to 128 characters.');
    const scope =
      operation === 'createFare' ? id(target) : plans.includes(target) ? target : 'unknown';
    if (scope === 'unknown') fail(404, 'not_found', 'Resource not found.');
    const keyHash = digest(`${actor.userId}:${operation}:${scope}:${key}`);
    const inputHash = digest(canonical(input));
    return this.tx(async (c) => {
      await this.authorize(c, actor);
      await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [`pricing:${keyHash}`]);
      const prior = (
        await c.query(
          'SELECT * FROM app.pricing_commands WHERE actor_user_id=$1 AND operation=$2 AND target=$3 AND key_hash=$4',
          [actor.userId, operation, scope, keyHash],
        )
      ).rows[0];
      if (prior) {
        if (prior.input_hash !== inputHash)
          fail(409, 'idempotency_conflict', 'This key was already used for different input.');
        if (this.now().getTime() - prior.created_at.getTime() >= 7 * 86400000)
          fail(409, 'idempotency_expired', 'This replay window has expired.');
        return this.render(c, operation, prior.resource_id, true);
      }
      const change =
        operation === 'createFare'
          ? await this.createFare(c, actor, scope, input)
          : await this.updatePlan(c, actor, scope, input, ifMatch);
      await this.record(c, actor, operation, scope, keyHash, inputHash, change);
      return this.render(c, operation, change.resource, false);
    });
  }

  private async render(
    c: PoolClient,
    operation: PricingOperation,
    resource: string,
    replay: boolean,
  ): Promise<Outcome> {
    void replay;
    if (operation === 'createFare') {
      const row = (await c.query('SELECT * FROM app.route_fares WHERE id=$1', [resource])).rows[0];
      return { status: 201, body: { data: this.fareView(row) }, headers: {} };
    }
    const row = (await c.query('SELECT * FROM app.plan_pricing WHERE plan=$1', [resource])).rows[0];
    return {
      status: 200,
      body: { data: this.planView(row) },
      headers: { ETag: planToken(row) },
    };
  }

  private async record(
    c: PoolClient,
    actor: Actor,
    operation: PricingOperation,
    scope: string,
    keyHash: string,
    inputHash: string,
    change: { resource: string; before: Body; after: Body },
  ) {
    const receipt = (
      await c.query(
        'INSERT INTO app.pricing_commands(actor_user_id,operation,target,key_hash,input_hash,resource_id) VALUES ($1,$2,$3,$4,$5,$6) RETURNING id',
        [actor.userId, operation, scope, keyHash, inputHash, change.resource],
      )
    ).rows[0].id;
    await c.query(
      'INSERT INTO app.pricing_events(command_id,actor_user_id,resource_id,action,before_state,after_state) VALUES ($1,$2,$3,$4,$5,$6)',
      [receipt, actor.userId, change.resource, operation, change.before, change.after],
    );
  }

  /**
   * A new fare closes the one it replaces rather than overwriting it, so a
   * purchase priced yesterday can still be read against the fare it was
   * priced at.
   */
  private async createFare(c: PoolClient, actor: Actor, routeId: string, input: Body) {
    if (!(await c.query('SELECT 1 FROM app.routes WHERE id=$1 FOR SHARE', [routeId])).rowCount)
      fail(404, 'not_found', 'Resource not found.');
    const amount = minor(input.amount, 'a fare');
    if (amount < 1) fail(400, 'invalid_request', 'Supply a fare above zero.');
    const from = new Date(String(input.effectiveFrom));
    if (!Number.isFinite(from.getTime()))
      fail(400, 'invalid_request', 'Supply a real effective date.');
    const open = (
      await c.query(
        'SELECT * FROM app.route_fares WHERE route_id=$1 AND effective_to IS NULL FOR UPDATE',
        [routeId],
      )
    ).rows[0];
    if (open) {
      // A fare cannot start before the one it replaces, and closing the open
      // one is the only edit the schema allows on it.
      if (from <= open.effective_from)
        fail(409, 'fare_conflict', 'A later effective date than the fare in force is required.');
      await c.query('UPDATE app.route_fares SET effective_to=$2 WHERE id=$1', [open.id, from]);
    }
    const row = (
      await c.query(
        'INSERT INTO app.route_fares(route_id,amount_pesewas,effective_from,note,created_by,command_id) VALUES ($1,$2,$3,$4,$5,gen_random_uuid()) RETURNING *',
        [routeId, amount, from, input.note ?? null, actor.userId],
      )
    ).rows[0];
    return {
      resource: row.id as string,
      before: open ? this.fareView(open) : {},
      after: this.fareView(row),
    };
  }

  private async updatePlan(
    c: PoolClient,
    actor: Actor,
    plan: string,
    input: Body,
    ifMatch?: string,
  ) {
    const row = (await c.query('SELECT * FROM app.plan_pricing WHERE plan=$1 FOR UPDATE', [plan]))
      .rows[0];
    if (!row) fail(404, 'not_found', 'Resource not found.');
    if (!ifMatch) fail(428, 'precondition_required', 'Supply the resource edit token in If-Match.');
    if (ifMatch !== planToken(row))
      fail(412, 'precondition_failed', 'The resource changed. Refresh it and try again.');
    const fields: Record<string, string> = {
      ridesPerPeriod: 'rides_per_period',
      priceMultiplierBp: 'price_multiplier_bp',
      takeRateBp: 'take_rate_bp',
      creditPerRide: 'credit_per_ride_pesewas',
    };
    const sets: string[] = [];
    const values: unknown[] = [plan];
    for (const [key, column] of Object.entries(fields)) {
      if (input[key] === undefined) continue;
      const value =
        key === 'creditPerRide'
          ? minor(input[key], 'a credit per ride')
          : Number.isSafeInteger(input[key]) && (input[key] as number) >= 0
            ? (input[key] as number)
            : fail(400, 'invalid_request', `Supply a whole number for ${key}.`);
      values.push(value);
      sets.push(`${column}=$${values.length}`);
    }
    if (!sets.length) fail(400, 'invalid_request', 'Supply at least one pricing field.');
    const updated = (
      await c.query(
        `UPDATE app.plan_pricing SET ${sets.join(',')} WHERE plan=$1 RETURNING *`,
        values,
      )
    ).rows[0];
    return { resource: plan, before: this.planView(row), after: this.planView(updated) };
  }
}
