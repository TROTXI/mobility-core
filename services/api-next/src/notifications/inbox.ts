import type { Pool, PoolClient } from 'pg';
import { cursorCodec } from '../transport/cursor.js';
import { fail } from '../transport/errors.js';
import type { Actor, Outcome } from '../transport/service.js';

export const inboxOperations = [
  'listNotifications',
  'markNotificationRead',
  'markAllNotificationsRead',
  'getNotificationPreferences',
  'updateNotificationPreferences',
] as const;
export type InboxOperation = (typeof inboxOperations)[number];

type NotificationRow = {
  id: string;
  kind: string;
  target_type: string;
  target_id: string;
  created_at: Date;
  read_at: Date | null;
  cursor_time: string;
};
type Preferences = {
  dailyAskTime: string;
  optionalUpdatesEnabled: boolean;
  updatedAt: string;
  version: number;
};
const uuid = /^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i;
const time = /^(0[6-9]|1\d|20|21):[0-5]\d$/;
const view = (row: NotificationRow) => ({
  id: row.id,
  kind: row.kind,
  target: { type: row.target_type, id: row.target_id },
  createdAt: row.created_at.toISOString(),
  readAt: row.read_at?.toISOString() ?? null,
});

/** The rider's owned, durable inbox. Provider acceptance is deliberately not
 * represented here: a push is only a hint to open this authoritative read. */
export class RiderInbox {
  private readonly cursors;
  constructor(
    private readonly options: {
      pool: Pool;
      cursorSecret: Buffer;
      authorizeSession: (client: PoolClient, actor: Actor) => Promise<void>;
      now?: () => Date;
    },
  ) {
    this.cursors = cursorCodec(options.cursorSecret);
  }
  private now() {
    return this.options.now?.() ?? new Date();
  }
  private async tx<T>(
    actor: Actor,
    write: boolean,
    work: (c: PoolClient) => Promise<T>,
  ): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await c.query(
        "BEGIN; SET LOCAL TIME ZONE 'UTC'; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='10s'",
      );
      const owner = await c.query(
        `SELECT id FROM app.users WHERE id=$1 AND role='commuter' AND deleted_at IS NULL ${write ? 'FOR UPDATE' : 'FOR SHARE'}`,
        [actor.userId],
      );
      if (!owner.rowCount) fail(403, 'forbidden', 'This operation is for commuters only.');
      await this.options.authorizeSession(c, actor);
      const result = await work(c);
      await c.query('COMMIT');
      return result;
    } catch (error) {
      await c.query('ROLLBACK');
      throw error;
    } finally {
      c.release();
    }
  }
  async list(actor: Actor, query: Record<string, string | undefined>): Promise<Outcome> {
    const limit = query.limit === undefined ? 30 : Number(query.limit);
    if (!Number.isInteger(limit) || limit < 1 || limit > 100)
      fail(400, 'invalid_query', 'Limit must be between 1 and 100.');
    const unreadOnly = query.unreadOnly === 'true';
    if (query.unreadOnly !== undefined && !['true', 'false'].includes(query.unreadOnly))
      fail(400, 'invalid_query', 'Invalid unread filter.');
    const context = `${actor.userId}:notifications:${unreadOnly}`;
    const cursor = query.cursor ? this.cursors.decode(query.cursor, context, this.now()) : null;
    return this.tx(actor, false, async (c) => {
      const rows = (
        await c.query<NotificationRow>(
          `SELECT n.*,to_char(n.created_at AT TIME ZONE 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS cursor_time
         FROM app.rider_notifications n WHERE n.user_id=$1
           AND ($2::boolean=false OR n.read_at IS NULL)
           AND ($3::timestamptz IS NULL OR (n.created_at,n.id)<($3::timestamptz,$4::uuid))
         ORDER BY n.created_at DESC,n.id DESC LIMIT $5`,
          [actor.userId, unreadOnly, cursor?.time ?? null, cursor?.id ?? null, limit + 1],
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
                ? this.cursors.encode(last.cursor_time, last.id, context, this.now())
                : null,
          },
        },
      };
    });
  }
  async markRead(actor: Actor, id: string): Promise<Outcome> {
    if (!uuid.test(id)) fail(404, 'not_found', 'Notification not found.');
    return this.tx(actor, true, async (c) => {
      const existing = (
        await c.query<NotificationRow>(
          'SELECT * FROM app.rider_notifications WHERE id=$1 AND user_id=$2 FOR UPDATE',
          [id, actor.userId],
        )
      ).rows[0];
      if (!existing) fail(404, 'not_found', 'Notification not found.');
      const row = existing.read_at
        ? existing
        : (
            await c.query<NotificationRow>(
              'UPDATE app.rider_notifications SET read_at=clock_timestamp() WHERE id=$1 RETURNING *',
              [id],
            )
          ).rows[0]!;
      return { status: 200, headers: {}, body: { data: view(row) } };
    });
  }
  async markAllRead(actor: Actor): Promise<Outcome> {
    return this.tx(actor, true, async (c) => {
      const result = await c.query(
        'UPDATE app.rider_notifications SET read_at=clock_timestamp() WHERE user_id=$1 AND read_at IS NULL',
        [actor.userId],
      );
      return { status: 200, headers: {}, body: { data: { readCount: result.rowCount ?? 0 } } };
    });
  }
  private async preferences(c: PoolClient, userId: string): Promise<Preferences> {
    const row = (
      await c.query<{
        daily_ask_time: string;
        optional_updates_enabled: boolean;
        updated_at: Date;
        version: number;
      }>(
        `SELECT coalesce(p.daily_ask_time,'17:00'::time)::text AS daily_ask_time,
        coalesce(p.optional_updates_enabled,false) AS optional_updates_enabled,
        coalesce(p.updated_at,u.created_at) AS updated_at,coalesce(p.version,1) AS version
       FROM app.users u LEFT JOIN app.rider_notification_preferences p ON p.user_id=u.id WHERE u.id=$1`,
        [userId],
      )
    ).rows[0]!;
    return {
      dailyAskTime: row.daily_ask_time.slice(0, 5),
      optionalUpdatesEnabled: row.optional_updates_enabled,
      updatedAt: row.updated_at.toISOString(),
      version: row.version,
    };
  }
  async getPreferences(actor: Actor): Promise<Outcome> {
    return this.tx(actor, false, async (c) => {
      const data = await this.preferences(c, actor.userId);
      return {
        status: 200,
        headers: { etag: `"notification-preferences:${data.version}"` },
        body: { data },
      };
    });
  }
  async updatePreferences(
    actor: Actor,
    input: {
      dailyAskTime: string;
      optionalUpdatesEnabled: boolean;
    },
    ifMatch: string | undefined,
  ): Promise<Outcome> {
    if (!ifMatch)
      fail(428, 'precondition_required', 'Reload notification preferences and try again.');
    if (!time.test(input.dailyAskTime) || typeof input.optionalUpdatesEnabled !== 'boolean')
      fail(400, 'invalid_request', 'Invalid notification preferences.');
    return this.tx(actor, true, async (c) => {
      const before = await this.preferences(c, actor.userId);
      if (ifMatch !== `"notification-preferences:${before.version}"`)
        fail(412, 'precondition_failed', 'Reload notification preferences and try again.');
      if (
        before.dailyAskTime === input.dailyAskTime &&
        before.optionalUpdatesEnabled === input.optionalUpdatesEnabled
      )
        return { status: 200, headers: { etag: ifMatch }, body: { data: before } };
      await c.query(
        `INSERT INTO app.rider_notification_preferences(user_id,daily_ask_time,optional_updates_enabled,version)
         VALUES ($1,$2,$3,2)
         ON CONFLICT(user_id) DO UPDATE SET daily_ask_time=EXCLUDED.daily_ask_time,
           optional_updates_enabled=EXCLUDED.optional_updates_enabled,
           updated_at=clock_timestamp(),version=app.rider_notification_preferences.version+1`,
        [actor.userId, input.dailyAskTime, input.optionalUpdatesEnabled],
      );
      const data = await this.preferences(c, actor.userId);
      return {
        status: 200,
        headers: { etag: `"notification-preferences:${data.version}"` },
        body: { data },
      };
    });
  }
}
