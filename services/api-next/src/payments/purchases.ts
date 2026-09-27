import type { Pool, PoolClient } from 'pg';
import { fail } from '../transport/errors.js';
import { canonical } from '../transport/service.js';
import type { Actor, Body, Outcome } from '../transport/service.js';
import { cursorCodec } from '../transport/cursor.js';
import type { FinancialFoundation } from './foundation.js';

export const purchaseOperations = [
  'listPurchases',
  'createPurchase',
  'getPurchase',
  'listOpsPurchases',
  'getOpsPurchase',
  'listRideEntries',
  'listCreditEntries',
] as const;
export type PurchaseOperation = (typeof purchaseOperations)[number];

/** Where the provider wants the rider sent. Called outside any transaction. */
export interface CheckoutTarget {
  authorizationUrl: string;
  expiresAt?: Date | null;
}
export interface PurchaseOptions {
  pool: Pool;
  financial: FinancialFoundation;
  authorizeSession: (client: PoolClient, actor: Actor) => Promise<void>;
  cursorSecret: Buffer;
  initializeCheckout?: (request: {
    reference: string;
    amountPesewas: number;
    purchaseId: string;
    userId: string;
  }) => Promise<CheckoutTarget>;
  now?: () => Date;
}

type Row = Record<string, any>;
const iso = (value: Date) => value.toISOString();
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const id = (value: unknown): string => {
  if (typeof value !== 'string' || !uuid.test(value)) fail(404, 'not_found', 'Resource not found.');
  return (value as string).toLowerCase();
};
const money = (amountMinor: number) => ({ amountMinor, currency: 'GHS' });
const ops = (operation: PurchaseOperation) =>
  operation === 'listOpsPurchases' || operation === 'getOpsPurchase';

export class Purchases {
  private readonly cursors;
  constructor(private readonly options: PurchaseOptions) {
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
  private async authorize(c: PoolClient, actor: Actor, operation: PurchaseOperation) {
    await this.options.authorizeSession(c, actor);
    const user = (
      await c.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR SHARE', [
        id(actor.userId),
      ])
    ).rows[0];
    if (!user) fail(401, 'unauthenticated', 'Sign in to continue.');
    if (user.role !== (ops(operation) ? 'admin' : 'commuter'))
      fail(403, 'forbidden', 'This operation is not permitted.');
  }

  /**
   * One purchase as its owner sees it: what it cost, what it is doing, and
   * where to go to pay. No provider reference, no rider identity, no attempt
   * history; those are the ops view.
   */
  private view(p: Row, latest: Row | undefined, session: Row | undefined): Body {
    return {
      id: p.id,
      plan: p.plan,
      state: p.state,
      collectionState: latest?.state ?? 'pending',
      price: money(p.price_pesewas),
      appliedCredit: money(p.applied_credit_pesewas),
      cashDue: money(p.cash_due_pesewas),
      checkout: session
        ? {
            url: session.authorization_url,
            expiresAt: session.expires_at ? iso(session.expires_at) : null,
          }
        : null,
      billingPeriodId: p.billing_period_id ?? null,
      failureCode: p.failure_code ?? null,
      createdAt: iso(p.created_at),
    };
  }

  private async compose(c: PoolClient, rows: Row[], admin: boolean): Promise<Body[]> {
    if (!rows.length) return [];
    const ids = rows.map((r) => r.id);
    const attempts = (
      await c.query(
        `SELECT * FROM app.payment_attempts WHERE purchase_id=ANY($1::uuid[])
        ORDER BY purchase_id,created_at DESC,id DESC`,
        [ids],
      )
    ).rows;
    const sessions = (
      await c.query('SELECT * FROM app.checkout_sessions WHERE purchase_id=ANY($1::uuid[])', [ids])
    ).rows;
    return rows.map((p) => {
      const mine = attempts.filter((a) => a.purchase_id === p.id);
      const latest = mine[0];
      const session = sessions.find((s) => s.attempt_id === latest?.id);
      const base = this.view(p, latest, session);
      if (!admin) return base;
      return {
        ...base,
        riderId: p.user_id,
        attempts: mine.map((a) => ({
          id: a.id,
          providerReference: a.reference,
          providerTransactionId: a.provider_transaction_id ?? null,
          environment: a.environment,
          status: a.state,
          receivedAmount: a.paid_at ? money(a.amount_pesewas) : null,
        })),
      };
    });
  }

  async read(
    actor: Actor,
    operation: PurchaseOperation,
    params: { id?: string },
    query: Record<string, string | undefined>,
  ): Promise<Outcome> {
    return this.tx(async (c) => {
      await this.authorize(c, actor, operation);
      const admin = ops(operation);
      if (operation === 'listRideEntries' || operation === 'listCreditEntries') {
        const limit = query.limit === undefined ? 50 : Number(query.limit);
        if (
          !Number.isInteger(limit) ||
          limit < 1 ||
          limit > 200 ||
          (query.limit !== undefined && !/^[1-9]\d*$/.test(query.limit))
        )
          fail(400, 'invalid_query', 'Invalid page size.');
        const context = canonical(['ledger', operation, actor.userId, 'created_at,id']);
        const cursor = query.cursor ? this.cursors.decode(query.cursor, context, this.now()) : null;
        const table = operation === 'listRideEntries' ? 'ride_entries' : 'credit_entries';
        const rows = (
          await c.query(
            `SELECT *,to_char(created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') cursor_time
          FROM app.${table} WHERE user_id=$1 AND ($2::timestamptz IS NULL OR (created_at,id)<($2::timestamptz,$3::uuid))
          ORDER BY created_at DESC,id DESC LIMIT $4`,
            [actor.userId, cursor?.time ?? null, cursor?.id ?? null, limit + 1],
          )
        ).rows;
        const page = rows.slice(0, limit),
          last = page.at(-1);
        return {
          status: 200,
          headers: {},
          body: {
            data: page.map((r): Body =>
              operation === 'listRideEntries'
                ? {
                    id: r.id,
                    deltaRides: r.delta_rides,
                    reason: r.reason,
                    billingPeriodId: r.period_id,
                    createdAt: iso(r.created_at),
                  }
                : {
                    id: r.id,
                    deltaMinor: r.delta_pesewas,
                    currency: 'GHS',
                    reason: r.reason,
                    createdAt: iso(r.created_at),
                  },
            ),
            page: {
              nextCursor:
                rows.length > limit && last
                  ? this.cursors.encode(last.cursor_time, last.id, context, this.now())
                  : null,
            },
          },
        };
      }
      if (operation === 'getPurchase' || operation === 'getOpsPurchase') {
        const row = (
          await c.query(
            `SELECT p.*,b.id AS billing_period_id FROM app.purchases p
            LEFT JOIN app.billing_periods b ON b.purchase_id=p.id
            WHERE p.id=$1 AND ($2::uuid IS NULL OR p.user_id=$2)`,
            [id(params.id), admin ? null : actor.userId],
          )
        ).rows[0];
        if (!row) fail(404, 'not_found', 'Resource not found.');
        const data = (await this.compose(c, [row], admin))[0]!;
        return { status: 200, body: { data }, headers: {} } as Outcome;
      }
      const limit = query.limit === undefined ? 50 : Number(query.limit);
      if (
        !Number.isInteger(limit) ||
        limit < 1 ||
        limit > 200 ||
        (query.limit !== undefined && !/^[1-9]\d*$/.test(query.limit))
      )
        fail(400, 'invalid_query', 'Invalid page size.');
      const calendar = (value: string | undefined, name: string) => {
        if (value === undefined) return null;
        if (
          !/^(?!0000)\d{4}-\d\d-\d\d$/.test(value) ||
          Number.isNaN(Date.parse(value)) ||
          new Date(value).toISOString().slice(0, 10) !== value
        )
          fail(400, 'invalid_query', `Supply a calendar date for ${name}.`);
        return value;
      };
      const from = calendar(query.fromDate, 'fromDate'),
        to = calendar(query.toDate, 'toDate');
      if (from && to && from > to)
        fail(400, 'invalid_query', 'Supply an ordered purchase-date range.');
      // The window is part of the signed context: a cursor from one query must
      // not decode against another and silently hide purchases.
      const context = canonical([
        'purchases',
        operation,
        admin ? null : actor.userId,
        'created_at,id',
        { from, to },
      ]);
      const cursor = query.cursor ? this.cursors.decode(query.cursor, context, this.now()) : null;
      const rows = (
        await c.query(
          `SELECT p.*,b.id AS billing_period_id,
            to_char(p.created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
          FROM app.purchases p
          LEFT JOIN app.billing_periods b ON b.purchase_id=p.id
          WHERE ($1::uuid IS NULL OR p.user_id=$1)
            AND ($2::date IS NULL OR (p.created_at AT TIME ZONE 'UTC')::date>=$2)
            AND ($3::date IS NULL OR (p.created_at AT TIME ZONE 'UTC')::date<=$3)
            AND ($4::timestamptz IS NULL OR (p.created_at,p.id)<($4::timestamptz,$5::uuid))
          ORDER BY p.created_at DESC,p.id DESC LIMIT $6`,
          [
            admin ? null : actor.userId,
            from,
            to,
            cursor?.time ?? null,
            cursor?.id ?? null,
            limit + 1,
          ],
        )
      ).rows;
      const page = rows.slice(0, limit);
      const last = page[page.length - 1];
      return {
        status: 200,
        body: {
          data: await this.compose(c, page, admin),
          page: {
            nextCursor:
              rows.length > limit && last
                ? this.cursors.encode(last.cursor_time, last.id, context, this.now())
                : null,
          },
        },
        headers: {},
      } as Outcome;
    });
  }

  /**
   * Buy a period.
   *
   * The financial foundation owns the money: it prices the purchase from
   * authoritative pricing, freezes those terms, places the credit hold and
   * opens the attempt, all in one transaction. Asking the provider where to
   * send the rider is a network call, so it happens after that commits and is
   * recorded separately. A retry with the same key returns the same purchase
   * and, if the first attempt to reach the provider failed, tries again for
   * the target rather than stranding a payable purchase with nowhere to pay.
   */
  async create(actor: Actor, input: Body, key: string): Promise<Outcome> {
    const purchase = await this.options.financial.checkout(actor, input as never, key, this.now());
    await this.target(actor, purchase);
    return this.tx(async (c) => {
      const row = (
        await c.query(
          `SELECT p.*,b.id AS billing_period_id FROM app.purchases p
          LEFT JOIN app.billing_periods b ON b.purchase_id=p.id WHERE p.id=$1`,
          [purchase.id],
        )
      ).rows[0];
      const data = (await this.compose(c, [row], false))[0]!;
      return { status: 201, body: { data }, headers: {} };
    });
  }

  private async target(
    actor: Actor,
    purchase: {
      id: string;
      cashDuePesewas: number;
      attempt?: { id: string; reference: string; state: string };
    },
  ) {
    const attempt = purchase.attempt;
    if (!this.options.initializeCheckout || !attempt || attempt.state !== 'pending') return;
    const existing = await this.tx((c) =>
      c.query('SELECT 1 FROM app.checkout_sessions WHERE attempt_id=$1', [attempt.id]),
    );
    if (existing.rowCount) return;
    let destination: CheckoutTarget;
    try {
      destination = await this.options.initializeCheckout({
        reference: attempt.reference,
        amountPesewas: purchase.cashDuePesewas,
        purchaseId: purchase.id,
        userId: actor.userId,
      });
    } catch {
      // The purchase and its attempt are committed and recoverable. A retry
      // with the same key comes back here; unresolved-payment discovery still
      // owns the attempt either way.
      return;
    }
    if (!/^https:\/\/\S{1,480}$/.test(destination.authorizationUrl)) return;
    await this.tx((c) =>
      c.query(
        `INSERT INTO app.checkout_sessions(attempt_id,purchase_id,user_id,authorization_url,expires_at)
        SELECT a.id,a.purchase_id,a.user_id,$2,$3 FROM app.payment_attempts a WHERE a.id=$1
        ON CONFLICT (attempt_id) DO NOTHING`,
        [attempt.id, destination.authorizationUrl, destination.expiresAt ?? null],
      ),
    );
  }
}
