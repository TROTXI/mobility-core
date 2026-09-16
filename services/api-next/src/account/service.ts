import { createHash, createCipheriv, randomBytes, randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { fail } from '../transport/errors.js';
import type { Actor, Body, Outcome } from '../transport/service.js';

export const accountOperations = [
  'updateAccount',
  'eraseAccount',
  'getAvatar',
  'uploadAvatar',
  'registerDevice',
] as const;
export type AccountOperation = (typeof accountOperations)[number];

/** Where an avatar lives, and how a private one is handed to its owner. */
export interface AvatarStore {
  put(request: {
    userId: string;
    bytes: Buffer;
    contentType: string;
  }): Promise<{ objectKey: string }>;
  signedUrl(objectKey: string, expiresInSeconds: number): Promise<string | null>;
}
/** External work erasure cannot finish by committing. */
export interface ErasureReach {
  revokeProviderGrant?: (request: {
    provider: string;
    subject: string;
    tokenCiphertext: string | null;
  }) => Promise<void>;
  removeAvatarObject?: (objectKey: string) => Promise<void>;
}
export interface AccountOptions {
  pool: Pool;
  authorizeSession: (client: PoolClient, actor: Actor) => Promise<void>;
  deviceKey: Buffer;
  avatars?: AvatarStore;
  reach?: ErasureReach;
  avatarUrlTtlSeconds?: number;
  maxAvatarBytes?: number;
  now?: () => Date;
}

type Row = Record<string, any>;
const digest = (value: Buffer | string) => createHash('sha256').update(value).digest('hex');
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const id = (value: unknown): string => {
  if (typeof value !== 'string' || !uuid.test(value)) fail(404, 'not_found', 'Resource not found.');
  return (value as string).toLowerCase();
};
/** What a stored avatar may be. Anything else is refused, not transcoded. */
const IMAGE_TYPES: Record<string, (bytes: Buffer) => boolean> = {
  'image/jpeg': (b) => b.length > 3 && b[0] === 0xff && b[1] === 0xd8 && b[2] === 0xff,
  'image/png': (b) =>
    b.length > 8 && b.subarray(0, 8).equals(Buffer.from('89504e470d0a1a0a', 'hex')),
  'image/webp': (b) =>
    b.length > 12 &&
    b.subarray(0, 4).toString('ascii') === 'RIFF' &&
    b.subarray(8, 12).toString('ascii') === 'WEBP',
};

export class AccountService {
  constructor(private readonly options: AccountOptions) {
    if (!Buffer.isBuffer(options.deviceKey) || options.deviceKey.length !== 32)
      throw new Error('A dedicated 32-byte device token key is required');
  }
  private now() {
    return this.options.now?.() ?? new Date();
  }
  private get maxAvatarBytes() {
    return this.options.maxAvatarBytes ?? 2 * 1024 * 1024;
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
  /** The account lock, taken before the session check, as auth does. */
  private async owner(c: PoolClient, actor: Actor): Promise<Row> {
    const user = (
      await c.query('SELECT * FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR UPDATE', [
        id(actor.userId),
      ])
    ).rows[0];
    if (!user) fail(401, 'unauthenticated', 'Sign in to continue.');
    await this.options.authorizeSession(c, actor);
    return user;
  }
  private seal(token: string) {
    const iv = randomBytes(12),
      cipher = createCipheriv('aes-256-gcm', this.options.deviceKey, iv);
    const payload = Buffer.concat([cipher.update(token, 'utf8'), cipher.final()]);
    return Buffer.concat([iv, cipher.getAuthTag(), payload]);
  }

  async handle(
    actor: Actor,
    operation: AccountOperation,
    input: Body | Buffer,
    contentType?: string,
  ): Promise<Outcome> {
    if (operation === 'updateAccount') return this.rename(actor, input as Body);
    if (operation === 'registerDevice') return this.register(actor, input as Body);
    if (operation === 'getAvatar') return this.avatar(actor);
    if (operation === 'uploadAvatar') return this.upload(actor, input as Buffer, contentType);
    return this.erase(actor);
  }

  private async rename(actor: Actor, input: Body): Promise<Outcome> {
    const name = typeof input.displayName === 'string' ? input.displayName.trim() : '';
    if (!name.length || name.length > 100)
      fail(400, 'invalid_request', 'Supply a display name of 1 to 100 characters.');
    return this.tx(async (c) => {
      const user = await this.owner(c, actor);
      const row = (
        await c.query('UPDATE app.users SET display_name=$2 WHERE id=$1 RETURNING *', [
          user.id,
          name,
        ])
      ).rows[0];
      return {
        status: 200,
        body: { data: await this.view(row) },
        headers: {},
      } as Outcome;
    });
  }

  private async view(user: Row): Promise<Body> {
    const url = user.avatar_object_key
      ? await this.options.avatars?.signedUrl(
          user.avatar_object_key,
          this.options.avatarUrlTtlSeconds ?? 300,
        )
      : null;
    return {
      id: user.id,
      displayName: user.display_name || 'New user',
      phone: user.phone ?? null,
      avatarUrl: url ?? null,
      role: user.role,
      createdAt: (user.created_at as Date).toISOString(),
    };
  }

  /**
   * A device token identifies one handset install, not one account. When the
   * same token appears under a different account the device moves, because the
   * alternative is a handset that keeps receiving a previous owner's trips.
   */
  private async register(actor: Actor, input: Body): Promise<Outcome> {
    const token = typeof input.token === 'string' ? input.token : '';
    const platform = String(input.platform);
    if (!token.length || token.length > 4096)
      fail(400, 'invalid_request', 'Supply a device token of 1 to 4096 characters.');
    if (!['ios', 'android'].includes(platform))
      fail(400, 'invalid_request', 'Supply a supported device platform.');
    return this.tx(async (c) => {
      const user = await this.owner(c, actor);
      const fingerprint = digest(token);
      const sealed = this.seal(token);
      const row = (
        await c.query(
          `INSERT INTO app.push_devices(user_id,platform,token_digest,token_ciphertext)
          VALUES ($1,$2,$3,$4)
          ON CONFLICT (token_digest) DO UPDATE
            SET user_id=EXCLUDED.user_id,platform=EXCLUDED.platform,
                token_ciphertext=EXCLUDED.token_ciphertext
          RETURNING *`,
          [user.id, platform, fingerprint, sealed],
        )
      ).rows[0];
      return {
        status: 200,
        body: {
          data: {
            id: row.id,
            platform: row.platform,
            updatedAt: (row.updated_at as Date).toISOString(),
          },
        },
        headers: {},
      } as Outcome;
    });
  }

  private async avatar(actor: Actor): Promise<Outcome> {
    return this.tx(async (c) => {
      const user = await this.owner(c, actor);
      if (!user.avatar_object_key) fail(404, 'not_found', 'Resource not found.');
      if (!this.options.avatars)
        fail(503, 'avatar_store_unavailable', 'Avatars are temporarily unavailable.');
      const seconds = this.options.avatarUrlTtlSeconds ?? 300;
      const url = await this.options.avatars.signedUrl(user.avatar_object_key, seconds);
      if (!url) fail(503, 'avatar_store_unavailable', 'Avatars are temporarily unavailable.');
      return {
        status: 200,
        body: {
          data: { url, expiresAt: new Date(this.now().getTime() + seconds * 1000).toISOString() },
        },
        headers: {},
      } as Outcome;
    });
  }

  /**
   * The object is written before the account points at it, so a failed store
   * leaves an unreferenced object rather than an account referring to nothing.
   */
  private async upload(actor: Actor, bytes: Buffer, contentType?: string): Promise<Outcome> {
    if (!this.options.avatars)
      fail(503, 'avatar_store_unavailable', 'Avatars are temporarily unavailable.');
    const type = String(contentType ?? '')
      .split(';')[0]!
      .trim()
      .toLowerCase();
    const recognises = IMAGE_TYPES[type];
    if (!recognises) fail(415, 'unsupported_media_type', 'Supply a JPEG, PNG or WebP image.');
    if (!Buffer.isBuffer(bytes) || !bytes.length)
      fail(400, 'invalid_request', 'Supply an image to upload.');
    if (bytes.length > this.maxAvatarBytes)
      fail(413, 'payload_too_large', 'That image is larger than the accepted size.');
    // The declared type has to be what the bytes actually are.
    if (!recognises(bytes))
      fail(415, 'unsupported_media_type', 'That file is not the type it claims.');
    const owner = await this.tx((c) => this.owner(c, actor));
    const stored = await this.options.avatars.put({
      userId: owner.id,
      bytes,
      contentType: type,
    });
    await this.tx(async (c) => {
      const user = await this.owner(c, actor);
      await c.query('UPDATE app.users SET avatar_object_key=$2 WHERE id=$1', [
        user.id,
        stored.objectKey,
      ]);
    });
    // The contract answers an upload with the private URL, not the account.
    return this.avatar(actor);
  }

  /**
   * Erase the account.
   *
   * Everything this database can finish, it finishes in one transaction:
   * sessions and refresh credentials stop working, device tokens stop
   * existing, identity is scrubbed, and 013's triggers clear what the rider
   * had booked. What lives outside it is written down as a task, so a provider
   * that is unreachable leaves work to retry rather than an erasure that
   * quietly did not happen. Accounting we are required to keep is kept.
   */
  private async erase(actor: Actor): Promise<Outcome> {
    const outstanding = await this.tx(async (c) => {
      const user = await this.owner(c, actor);
      const sessions = await c.query(
        'UPDATE app.auth_sessions SET revoked_at=clock_timestamp() WHERE user_id=$1 AND revoked_at IS NULL',
        [user.id],
      );
      await c.query(
        `UPDATE app.refresh_credentials SET consumed_at=clock_timestamp()
        WHERE session_id IN (SELECT id FROM app.auth_sessions WHERE user_id=$1)
          AND consumed_at IS NULL`,
        [user.id],
      );
      const devices = await c.query(
        `UPDATE app.push_devices SET revoked_at=clock_timestamp(),token_ciphertext=NULL
        WHERE user_id=$1 AND revoked_at IS NULL`,
        [user.id],
      );
      const identities = (
        await c.query(
          'SELECT id,provider,subject,provider_token_ciphertext FROM app.auth_identities WHERE user_id=$1',
          [user.id],
        )
      ).rows;
      for (const identity of identities)
        await c.query(
          'UPDATE app.auth_identities SET subject=$2,provider_token_ciphertext=NULL WHERE id=$1',
          [identity.id, `erased:${randomUUID()}`],
        );
      const objectKey = user.avatar_object_key as string | null;
      // 013's trigger fires on this transition and clears slots, pauses,
      // requests, assignments, reservations and rider notes.
      await c.query(
        `UPDATE app.users SET deleted_at=clock_timestamp(),display_name=NULL,email=NULL,
          phone=NULL,avatar_object_key=NULL WHERE id=$1`,
        [user.id],
      );
      await c.query(
        `INSERT INTO app.account_erasures(user_id,session_id,sessions_revoked,devices_revoked,identities_scrubbed)
        VALUES ($1,$2,$3,$4,$5)`,
        [
          user.id,
          id(actor.sessionId),
          sessions.rowCount ?? 0,
          devices.rowCount ?? 0,
          identities.length,
        ],
      );
      const tasks: { kind: string; reference: string }[] = [];
      for (const identity of identities)
        tasks.push({
          kind: 'provider_revocation',
          reference: `${identity.provider}:${identity.id}`,
        });
      if (objectKey) tasks.push({ kind: 'avatar_object', reference: objectKey });
      for (const task of tasks)
        await c.query(
          'INSERT INTO app.erasure_tasks(user_id,kind,reference) VALUES ($1,$2,$3) ON CONFLICT DO NOTHING',
          [user.id, task.kind, task.reference],
        );
      return { userId: user.id as string, tasks };
    });
    // Attempted once here so an ordinary erasure finishes now. A failure is
    // already recorded, and the maintenance worker owns the retry.
    for (const task of outstanding.tasks) await this.attempt(outstanding.userId, task);
    return { status: 204, body: null, headers: {} } as Outcome;
  }

  private async attempt(userId: string, task: { kind: string; reference: string }) {
    const reach = this.options.reach;
    const settle = (state: 'done' | 'unavailable', failure: string | null) =>
      this.tx((c) =>
        c.query(
          `UPDATE app.erasure_tasks
          SET state=$4,attempts=attempts+1,last_failure=$5,
              completed_at=CASE WHEN $4='done' THEN clock_timestamp() ELSE NULL END
          WHERE user_id=$1 AND kind=$2 AND reference=$3 AND state<>'done'`,
          [userId, task.kind, task.reference, state, failure],
        ),
      ).catch(() => undefined);
    try {
      if (task.kind === 'avatar_object') {
        if (!reach?.removeAvatarObject) return settle('unavailable', 'no_object_reach');
        await reach.removeAvatarObject(task.reference);
      } else {
        if (!reach?.revokeProviderGrant) return settle('unavailable', 'no_provider_reach');
        const [provider] = task.reference.split(':');
        await reach.revokeProviderGrant({
          provider: provider!,
          subject: task.reference,
          tokenCiphertext: null,
        });
      }
      return settle('done', null);
    } catch (error) {
      return settle('unavailable', (error instanceof Error ? error.name : 'unknown').slice(0, 200));
    }
  }

  /** Retry what erasure could not finish. Bounded, and never invents success. */
  async retryErasures(limit = 50): Promise<{ considered: number; completed: number }> {
    const due = await this.tx((c) =>
      c.query(
        `SELECT user_id,kind,reference FROM app.erasure_tasks
        WHERE state<>'done' ORDER BY created_at,id LIMIT $1`,
        [Math.max(1, Math.min(limit, 100))],
      ),
    );
    let completed = 0;
    for (const task of due.rows) {
      await this.attempt(task.user_id, task);
      const state = await this.tx((c) =>
        c.query(
          'SELECT state FROM app.erasure_tasks WHERE user_id=$1 AND kind=$2 AND reference=$3',
          [task.user_id, task.kind, task.reference],
        ),
      );
      if (state.rows[0]?.state === 'done') completed += 1;
    }
    return { considered: due.rowCount ?? 0, completed };
  }
}
