import { createHash, randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { canonical } from '../transport/service.js';
import type { Actor, Body, Outcome } from '../transport/service.js';
import { fail } from '../transport/errors.js';

export const refundOperations = ['initiateRefund', 'listRefundInitiations'] as const;
export class RefundInitiation {
  constructor(
    private options: {
      pool: Pool;
      authorizeSession: (c: PoolClient, a: Actor) => Promise<void>;
      environment: 'test' | 'live';
      initiate: (reference: string, amount: number, intentId: string) => Promise<string>;
    },
  ) {}
  private async tx<T>(work: (c: PoolClient) => Promise<T>): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await c.query("BEGIN; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='10s'");
      const value = await work(c);
      await c.query('COMMIT');
      return value;
    } catch (e) {
      await c.query('ROLLBACK');
      throw e;
    } finally {
      c.release();
    }
  }
  private async authorize(c: PoolClient, a: Actor) {
    await this.options.authorizeSession(c, a);
    const u = (
      await c.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR SHARE', [
        a.userId,
      ])
    ).rows[0];
    if (!u) fail(401, 'unauthenticated', 'Sign in to continue.');
    if (u.role !== 'admin') fail(403, 'forbidden', 'Operations access required.');
  }
  private id(value: string) {
    if (!/^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(value))
      fail(404, 'not_found', 'Resource not found.');
    return value.toLowerCase();
  }
  private view(r: Record<string, any>): Body {
    return {
      id: r.id,
      purchaseId: r.purchase_id,
      amount: { amountMinor: r.amount_pesewas, currency: 'GHS' },
      reason: r.reason,
      state: r.state,
      providerRefundId: r.provider_refund_id ?? null,
      createdAt: r.created_at.toISOString(),
    };
  }
  async read(actor: Actor, purchaseId: string): Promise<Outcome> {
    return this.tx(async (c) => {
      await this.authorize(c, actor);
      const id = this.id(purchaseId);
      if (!(await c.query('SELECT 1 FROM app.purchases WHERE id=$1', [id])).rowCount)
        fail(404, 'not_found', 'Resource not found.');
      const rows = (
        await c.query('SELECT * FROM app.refund_initiations WHERE purchase_id=$1', [id])
      ).rows;
      return { status: 200, headers: {}, body: { data: { items: rows.map((r) => this.view(r)) } } };
    });
  }
  async initiate(actor: Actor, purchaseId: string, input: Body, key: string): Promise<Outcome> {
    const digest = (s: string) => createHash('sha256').update(s).digest('hex');
    const amount = (input.amount as Body)?.amountMinor,
      reason = typeof input.reason === 'string' ? input.reason.trim() : '';
    if (
      !key ||
      key.length > 128 ||
      !Number.isInteger(amount) ||
      (amount as number) < 1 ||
      (amount as number) > 2147483647 ||
      (input.amount as Body)?.currency !== 'GHS' ||
      !reason ||
      reason.length > 500
    )
      fail(400, 'invalid_request', 'Supply a positive cash amount, reason and request key.');
    const prepared = await this.tx(async (c) => {
      await this.authorize(c, actor);
      if (this.options.environment !== 'test')
        fail(503, 'test_only', 'Refund initiation is enabled for TEST payments only.');
      const id = this.id(purchaseId);
      // All refund evidence processing locks the rider first. Keep that order.
      const purchase = (await c.query('SELECT user_id FROM app.purchases WHERE id=$1', [id]))
        .rows[0];
      if (!purchase) fail(404, 'not_found', 'Resource not found.');
      await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [purchase.user_id]);
      const old = (await c.query('SELECT * FROM app.refund_initiations WHERE purchase_id=$1', [id]))
        .rows[0];
      const inputHash = digest(canonical({ amount: amount as number, reason }));
      if (old) {
        if (old.actor_user_id !== actor.userId || old.key_hash !== digest(key))
          fail(
            409,
            'refund_already_requested',
            'Inspect the existing refund; do not issue it again.',
          );
        if (old.input_hash !== inputHash)
          fail(409, 'idempotency_conflict', 'This key was used for different input.');
        return { row: old, reference: null };
      }
      const collection = (
        await c.query(
          `SELECT c.*,a.reference FROM app.payment_collections c
        JOIN app.payment_attempts a ON a.id=c.attempt_id WHERE c.purchase_id=$1`,
          [id],
        )
      ).rows[0];
      if (!collection || collection.environment !== 'test')
        fail(409, 'payment_not_collected', 'A confirmed TEST collection is required.');
      const total = Number(
        (
          await c.query(
            `SELECT COALESCE(SUM(amount_pesewas),0) n FROM app.payment_refunds
        WHERE purchase_id=$1 AND state<>'failed'`,
            [id],
          )
        ).rows[0].n,
      );
      if ((amount as number) > collection.amount_pesewas - total)
        fail(409, 'refund_exceeds_remaining', 'Amount exceeds remaining collected cash.');
      const row = (
        await c.query(
          `INSERT INTO app.refund_initiations
        (id,purchase_id,collection_id,actor_user_id,amount_pesewas,reason,key_hash,input_hash)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
          [randomUUID(), id, collection.id, actor.userId, amount, reason, digest(key), inputHash],
        )
      ).rows[0];
      return { row, reference: collection.reference as string };
    });
    if (prepared.reference) {
      // The intent is committed before the only external POST. A crash can
      // strand 'submitting', but no replay can spend again. This is visible to ops.
      let providerId: string | null = null;
      try {
        providerId = await this.options.initiate(
          prepared.reference,
          amount as number,
          prepared.row.id,
        );
      } catch {
        /* uncertain: never resubmit */
      }
      const rows = await this.options.pool.query(
        `UPDATE app.refund_initiations SET state=$2,provider_refund_id=$3,
        updated_at=clock_timestamp() WHERE id=$1 AND state='submitting' RETURNING *`,
        [prepared.row.id, providerId ? 'accepted' : 'unknown', providerId],
      );
      if (rows.rows[0]) prepared.row = rows.rows[0];
    }
    return { status: 202, headers: {}, body: { data: this.view(prepared.row) } };
  }
}
