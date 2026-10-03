import { createHash } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { fail, TransportError } from '../transport/errors.js';
import { canonical, type Actor, type Body, type Outcome } from '../transport/service.js';
import type { Purchases } from '../payments/purchases.js';
import { cursorCodec } from '../transport/cursor.js';

export const standbyOperations = [
  'listMyStandby',
  'joinStandby',
  'withdrawStandby',
  'acceptStandbyOffer',
  'listOpsStandby',
  'offerStandby',
] as const;
export type StandbyOperation = (typeof standbyOperations)[number];
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const identifier = (value: unknown) => {
  if (typeof value !== 'string' || !uuid.test(value)) fail(404, 'not_found', 'Resource not found.');
  return value.toLowerCase();
};
type Row = Record<string, any>;
const view = (row: Row) => ({
  id: row.id as string,
  riderId: row.user_id as string,
  riderName: row.rider_name as string,
  routeName: row.route_name as string,
  state: row.state as string,
  selection: row.selection as Body,
  offer: row.offer_id
    ? {
        id: row.offer_id as string,
        state: row.offer_state as string,
        expiresAt: (row.expires_at as Date).toISOString(),
        purchaseId: (row.purchase_id as string | null) ?? null,
      }
    : null,
  createdAt: (row.created_at as Date).toISOString(),
});

export class StandbyService {
  constructor(
    private readonly options: {
      pool: Pool;
      authorizeSession: (c: PoolClient, actor: Actor) => Promise<void>;
      purchases: Purchases;
      cursorSecret: Buffer;
    },
  ) {}
  private get cursors() {
    return cursorCodec(this.options.cursorSecret);
  }
  private async tx<T>(work: (c: PoolClient) => Promise<T>): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await c.query("BEGIN; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='10s'");
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
  private async authorize(c: PoolClient, actor: Actor, admin = false) {
    await this.options.authorizeSession(c, actor);
    const user = (
      await c.query(
        'SELECT role,display_name FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR SHARE',
        [actor.userId],
      )
    ).rows[0];
    if (user?.role !== (admin ? 'admin' : 'commuter'))
      fail(403, 'forbidden', 'Standby is not available to this account.');
    return user;
  }
  private async eligible(c: PoolClient, actor: Actor) {
    const user = await this.authorize(c, actor);
    if (!user.display_name?.trim() || user.display_name === 'New commuter')
      fail(409, 'standby_profile_incomplete', 'Complete your rider name before joining standby.');
    const verified = (
      await c.query(
        `SELECT 1 FROM app.commuter_phone_verifications
       WHERE user_id=$1 AND phone_hash IS NOT NULL AND revoked_at IS NULL`,
        [actor.userId],
      )
    ).rowCount;
    if (!verified)
      fail(409, 'phone_verification_required', 'Verify your phone before joining standby.');
  }
  private async row(c: PoolClient, id: string, userId?: string, lock = false) {
    // Lock before reading the joined offer. A single SELECT FOR UPDATE OF a
    // can return a stale offer snapshot after waiting for another acceptor.
    if (lock)
      await c.query('SELECT id FROM app.standby_applications WHERE id=$1 FOR UPDATE', [
        identifier(id),
      ]);
    return (
      await c.query(
        `SELECT a.*,u.display_name AS rider_name,r.name AS route_name,
              o.id AS offer_id,o.state AS offer_state,o.expires_at,o.purchase_id,
              o.acceptance_key_hash,o.offer_key_hash,o.offer_receipt
       FROM app.standby_applications a
       JOIN app.users u ON u.id=a.user_id JOIN app.routes r ON r.id=a.route_id
       LEFT JOIN app.standby_offers o ON o.application_id=a.id
       WHERE a.id=$1 AND ($2::uuid IS NULL OR a.user_id=$2)`,
        [identifier(id), userId ?? null],
      )
    ).rows[0];
  }
  async list(
    actor: Actor,
    admin = false,
    query: Record<string, string | undefined> = {},
  ): Promise<Outcome> {
    const limit = query.limit === undefined ? 30 : Number(query.limit);
    if (!Number.isInteger(limit) || limit < 1 || limit > 100)
      fail(400, 'invalid_query', 'Limit must be between 1 and 100.');
    const context = `${actor.userId}:standby:${admin ? 'ops' : 'rider'}`;
    const cursor = query.cursor ? this.cursors.decode(query.cursor, context, new Date()) : null;
    return this.tx(async (c) => {
      await this.authorize(c, actor, admin);
      const rows = (
        await c.query(
          `SELECT a.*,u.display_name AS rider_name,r.name AS route_name,
                o.id AS offer_id,o.state AS offer_state,o.expires_at,o.purchase_id,
                to_char(a.created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
         FROM app.standby_applications a
         JOIN app.users u ON u.id=a.user_id AND u.deleted_at IS NULL
         JOIN app.routes r ON r.id=a.route_id
         LEFT JOIN app.standby_offers o ON o.application_id=a.id
         WHERE ($1::uuid IS NULL OR a.user_id=$1)
           AND ($2::timestamptz IS NULL OR (a.created_at,a.id)<($2::timestamptz,$3::uuid))
         ORDER BY a.created_at DESC,a.id DESC LIMIT $4`,
          [admin ? null : actor.userId, cursor?.time ?? null, cursor?.id ?? null, limit + 1],
        )
      ).rows;
      const last = rows[limit - 1];
      return {
        status: 200,
        headers: {},
        body: {
          data: rows.slice(0, limit).map(view),
          page: {
            nextCursor:
              rows.length > limit && last
                ? this.cursors.encode(last.cursor_time, last.id, context, new Date())
                : null,
          },
        },
      };
    });
  }
  async join(actor: Actor, selection: Body): Promise<Outcome> {
    return this.tx(async (c) => {
      // A user-level lock serializes concurrent applications for the same account.
      await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [actor.userId]);
      await this.eligible(c, actor);
      const routeId = identifier(selection.routeId);
      const existing = (
        await c.query(
          "SELECT id,selection FROM app.standby_applications WHERE user_id=$1 AND state IN ('submitted','offered','checkout_open') FOR UPDATE",
          [actor.userId],
        )
      ).rows[0];
      if (existing) {
        if (canonical(existing.selection) !== canonical(selection))
          fail(409, 'standby_already_joined', 'Withdraw your existing standby application first.');
        return {
          status: 200,
          headers: {},
          body: { data: view((await this.row(c, existing.id, actor.userId))!) },
        };
      }
      if (
        (
          await c.query(
            `SELECT 1 FROM app.billing_periods WHERE user_id=$1 AND state='open'
         AND effective_ends_at>clock_timestamp()`,
            [actor.userId],
          )
        ).rowCount
      )
        fail(409, 'coverage_active', 'You already have active ride coverage.');
      const legs = selection.legs as Body[];
      if (
        !Array.isArray(legs) ||
        legs.length !== 2 ||
        new Set(legs.map((leg) => leg.direction)).size !== 2
      )
        fail(400, 'invalid_selection', 'Select outbound and return service legs.');
      for (const leg of legs) {
        const valid = (
          await c.query(
            `SELECT 1 FROM app.service_schedules s
           JOIN app.route_pattern_versions v ON v.id=s.pattern_version_id
           JOIN app.route_patterns p ON p.id=v.pattern_id
           JOIN app.routes r ON r.id=p.route_id
           JOIN app.route_pattern_stops a ON a.id=$4 AND a.pattern_version_id=v.id
           JOIN app.route_pattern_stops b ON b.id=$5 AND b.pattern_version_id=v.id
           WHERE s.id=$1 AND v.id=$2 AND p.route_id=$3 AND p.direction=$6
             AND a.ordinal<b.ordinal AND r.archived_at IS NULL AND v.state='published'
             AND v.effective_from<=clock_timestamp()
             AND (v.effective_to IS NULL OR v.effective_to>clock_timestamp())
             AND s.effective_from<=(clock_timestamp() AT TIME ZONE 'Africa/Accra')::date
             AND (s.effective_to IS NULL OR s.effective_to>=(clock_timestamp() AT TIME ZONE 'Africa/Accra')::date)`,
            [
              identifier(leg.scheduleId),
              identifier(leg.patternVersionId),
              routeId,
              identifier(leg.pickupOccurrenceId),
              identifier(leg.dropoffOccurrenceId),
              leg.direction,
            ],
          )
        ).rowCount;
        if (!valid) fail(409, 'invalid_selection', 'Select current ordered service stops.');
      }
      const id = (
        await c.query(
          `INSERT INTO app.standby_applications(user_id,route_id,selection)
         VALUES ($1,$2,$3::jsonb) RETURNING id`,
          [actor.userId, routeId, JSON.stringify(selection)],
        )
      ).rows[0].id as string;
      await c.query(
        "INSERT INTO app.standby_events(application_id,actor_user_id,action) VALUES ($1,$2,'join')",
        [id, actor.userId],
      );
      return {
        status: 201,
        headers: {},
        body: { data: view((await this.row(c, id, actor.userId))!) },
      };
    });
  }
  async withdraw(actor: Actor, id: string): Promise<Outcome> {
    return this.tx(async (c) => {
      await this.authorize(c, actor);
      const row = await this.row(c, id, actor.userId, true);
      if (!row) fail(404, 'not_found', 'Resource not found.');
      if (!['submitted', 'offered'].includes(row.state) || row.offer_state === 'accepting')
        fail(409, 'standby_not_withdrawable', 'A checkout already exists for this offer.');
      await c.query(
        "UPDATE app.standby_offers SET state='cancelled' WHERE application_id=$1 AND state='offered'",
        [id],
      );
      await c.query(
        "UPDATE app.standby_applications SET state='withdrawn',updated_at=clock_timestamp() WHERE id=$1",
        [id],
      );
      await c.query(
        "INSERT INTO app.standby_events(application_id,actor_user_id,action) VALUES ($1,$2,'withdraw')",
        [id, actor.userId],
      );
      return {
        status: 200,
        headers: {},
        body: { data: view((await this.row(c, id, actor.userId))!) },
      };
    });
  }
  async offer(actor: Actor, id: string, expiresAt: string, key: string): Promise<Outcome> {
    const keyHash = createHash('sha256').update(key).digest('hex');
    return this.tx(async (c) => {
      await this.authorize(c, actor, true);
      const row = await this.row(c, id, undefined, true);
      if (!row) fail(404, 'not_found', 'Resource not found.');
      const expiry = new Date(expiresAt);
      if (row.offer_id && row.offer_key_hash === keyHash) {
        if (row.expires_at?.getTime() !== expiry.getTime())
          fail(409, 'idempotency_conflict', 'This key was used for a different offer.');
        if (!row.offer_receipt) fail(409, 'offer_unavailable', 'This offer is unavailable.');
        return { status: 201, headers: {}, body: { data: row.offer_receipt } };
      }
      if (row.state !== 'submitted')
        fail(409, 'standby_not_pending', 'This application is not pending.');
      const ms = expiry.getTime() - Date.now();
      if (!Number.isFinite(ms) || ms < 60000 || ms > 7 * 86400000)
        fail(400, 'invalid_offer_expiry', 'Choose an offer expiry within seven days.');
      const offerId = (
        await c.query(
          `INSERT INTO app.standby_offers(application_id,expires_at,offer_key_hash)
           VALUES ($1,$2,$3) RETURNING id`,
          [id, expiry, keyHash],
        )
      ).rows[0].id as string;
      await c.query(
        `INSERT INTO app.rider_notifications(user_id,kind,source_id,target_type,target_id)
         VALUES ($1,'standby_offered',$2,'standby',$3)`,
        [row.user_id, offerId, id],
      );
      await c.query(
        "UPDATE app.standby_applications SET state='offered',updated_at=clock_timestamp() WHERE id=$1",
        [id],
      );
      await c.query(
        "INSERT INTO app.standby_events(application_id,actor_user_id,action) VALUES ($1,$2,'offer')",
        [id, actor.userId],
      );
      const receipt = view((await this.row(c, id))!);
      await c.query('UPDATE app.standby_offers SET offer_receipt=$2::jsonb WHERE id=$1', [
        offerId,
        JSON.stringify(receipt),
      ]);
      return { status: 201, headers: {}, body: { data: receipt } };
    });
  }
  async accept(actor: Actor, id: string, key: string): Promise<Outcome> {
    const keyHash = createHash('sha256').update(key).digest('hex');
    const selection = await this.tx(async (c) => {
      await this.eligible(c, actor);
      const row = await this.row(c, id, actor.userId, true);
      if (!row) fail(404, 'not_found', 'Resource not found.');
      if (row.state === 'offered' && row.offer_state === 'offered') {
        if (row.expires_at <= new Date()) fail(409, 'offer_expired', 'This offer has expired.');
        const claimed = await c.query(
          `UPDATE app.standby_offers SET state='accepting',acceptance_key_hash=$2
           WHERE id=$1 AND state='offered' AND expires_at>clock_timestamp() RETURNING id`,
          [row.offer_id, keyHash],
        );
        if (!claimed.rowCount) fail(409, 'offer_unavailable', 'This offer is unavailable.');
      } else if (
        !['accepting', 'checkout_open'].includes(row.offer_state) ||
        row.acceptance_key_hash !== keyHash
      )
        fail(409, 'offer_unavailable', 'This offer is unavailable.');
      return row.selection as Body;
    });
    // The financial service freezes authoritative price and opens a *new*
    // Paystack checkout. No previous payment reference is reused.
    let purchase: Outcome;
    try {
      purchase = await this.options.purchases.create(actor, selection, key);
    } catch (error) {
      // A definitive refusal happened before a checkout could be returned.
      // Keep uncertain/provider failures locked to the original retry key.
      if (
        error instanceof TransportError &&
        error.status >= 400 &&
        error.status < 500 &&
        error.status !== 429
      ) {
        await this.tx(async (c) => {
          const row = await this.row(c, id, actor.userId, true);
          if (
            row?.offer_state === 'accepting' &&
            row.acceptance_key_hash === keyHash &&
            !row.purchase_id
          ) {
            await c.query(
              "UPDATE app.standby_offers SET state='offered',acceptance_key_hash=NULL WHERE id=$1",
              [row.offer_id],
            );
          }
        });
      }
      throw error;
    }
    const purchaseId = (purchase.body as { data: { id: string } }).data.id;
    await this.tx(async (c) => {
      await this.eligible(c, actor);
      const row = await this.row(c, id, actor.userId, true);
      if (!row || row.acceptance_key_hash !== keyHash)
        fail(409, 'offer_unavailable', 'This offer is unavailable.');
      if (row.purchase_id && row.purchase_id !== purchaseId)
        fail(409, 'offer_conflict', 'This offer already has another purchase.');
      await c.query(
        "UPDATE app.standby_offers SET state='checkout_open',purchase_id=$2 WHERE id=$1",
        [row.offer_id, purchaseId],
      );
      await c.query(
        "UPDATE app.standby_applications SET state='checkout_open',updated_at=clock_timestamp() WHERE id=$1",
        [id],
      );
      if (row.offer_state !== 'checkout_open')
        await c.query(
          "INSERT INTO app.standby_events(application_id,actor_user_id,action) VALUES ($1,$2,'accept')",
          [id, actor.userId],
        );
    });
    return purchase;
  }
}
