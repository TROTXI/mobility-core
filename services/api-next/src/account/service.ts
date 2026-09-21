import {
  createHash,
  createCipheriv,
  createDecipheriv,
  hkdfSync,
  randomBytes,
  randomUUID,
} from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { fail } from '../transport/errors.js';
import type { Actor, Body, Outcome } from '../transport/service.js';

export const accountOperations = [
  'updateAccount',
  'eraseAccount',
  'getAvatar',
  'uploadAvatar',
  'registerDevice',
  'deleteAvatar',
] as const;
export type AccountOperation = (typeof accountOperations)[number];

/** Where an avatar lives, and how a private one is handed to its owner. */
export interface AvatarStore {
  put(request: {
    userId: string;
    /** Allocated durably before the first external write; the store must use it. */
    objectKey: string;
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
  erasureRequested?: (client: PoolClient, userId: string, email: string | null) => Promise<void>;
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
/**
 * What a stored avatar may be. Anything else is refused, not transcoded.
 *
 * Each type has its own static call site rather than a function looked up by
 * the declared type: a request field must never choose what gets called.
 */
const isJpeg = (b: Buffer) => b.length > 3 && b[0] === 0xff && b[1] === 0xd8 && b[2] === 0xff;
const isPng = (b: Buffer) =>
  b.length > 8 && b.subarray(0, 8).equals(Buffer.from('89504e470d0a1a0a', 'hex'));
const isWebp = (b: Buffer) =>
  b.length > 12 &&
  b.subarray(0, 4).toString('ascii') === 'RIFF' &&
  b.subarray(8, 12).toString('ascii') === 'WEBP';
function looksLike(type: string, bytes: Buffer): boolean {
  switch (type) {
    case 'image/jpeg':
      return isJpeg(bytes);
    case 'image/png':
      return isPng(bytes);
    case 'image/webp':
      return isWebp(bytes);
    default:
      return false;
  }
}
const IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

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
  private async tx<T>(work: (c: PoolClient) => Promise<T>, existing?: PoolClient): Promise<T> {
    const c = existing ?? (await this.options.pool.connect());
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
      if (!existing) c.release();
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

  private box(value: unknown, context: string): Buffer {
    const key = Buffer.from(
      hkdfSync('sha256', this.options.deviceKey, '', 'account-recovery-v1', 32),
    );
    const iv = randomBytes(12),
      cipher = createCipheriv('aes-256-gcm', key, iv);
    cipher.setAAD(Buffer.from(context));
    return Buffer.concat([
      iv,
      cipher.update(JSON.stringify(value)),
      cipher.final(),
      cipher.getAuthTag(),
    ]);
  }
  private unbox(value: Buffer, context: string): any {
    const key = Buffer.from(
      hkdfSync('sha256', this.options.deviceKey, '', 'account-recovery-v1', 32),
    );
    const cipher = createDecipheriv('aes-256-gcm', key, value.subarray(0, 12));
    cipher.setAAD(Buffer.from(context));
    cipher.setAuthTag(value.subarray(-16));
    return JSON.parse(
      Buffer.concat([cipher.update(value.subarray(12, -16)), cipher.final()]).toString(),
    );
  }

  async handle(
    actor: Actor,
    operation: AccountOperation,
    input: Body | Buffer,
    contentType?: string,
    key?: string,
  ): Promise<Outcome> {
    if (operation === 'getAvatar') return this.avatar(actor);
    if (typeof key !== 'string' || !key.length || key.length > 128)
      fail(400, 'idempotency_key_required', 'Supply an Idempotency-Key of 1 to 128 characters.');
    if (operation === 'updateAccount') return this.rename(actor, input as Body, key);
    if (operation === 'registerDevice') return this.register(actor, input as Body, key);
    if (operation === 'deleteAvatar') return this.deleteAvatar(actor, key);
    if (operation === 'uploadAvatar') return this.upload(actor, input as Buffer, contentType, key);
    return this.erase(actor, key);
  }

  /**
   * A replay never mutates current state, even if another command has run since.
   * Expired keys remain tombstones; clearing payloads must not enable execution.
   */
  private async receipt(
    c: PoolClient,
    actor: Actor,
    operation: AccountOperation,
    key: string,
    input: string,
  ): Promise<{ replay: string | null; outcome: Outcome | null } | null> {
    const prior = (
      await c.query(
        'SELECT * FROM app.account_commands WHERE actor_user_id=$1 AND operation=$2 AND key_hash=$3',
        [actor.userId, operation, digest(key)],
      )
    ).rows[0];
    if (!prior) return null;
    if (prior.input_hash !== digest(input))
      fail(409, 'idempotency_conflict', 'This key was already used for different input.');
    if (prior.expires_at <= this.now()) fail(409, 'idempotency_expired', 'Use a new request key.');
    return {
      replay: prior.result,
      outcome: prior.response_ciphertext
        ? this.unbox(
            prior.response_ciphertext,
            `receipt:${actor.userId}:${operation}:${digest(key)}`,
          )
        : null,
    };
  }
  private async record(
    c: PoolClient,
    actor: Actor,
    operation: AccountOperation,
    key: string,
    input: string,
    result: string | null,
    outcome?: Outcome,
  ) {
    await c.query(
      'INSERT INTO app.account_commands(actor_user_id,operation,key_hash,input_hash,result,response_ciphertext) VALUES ($1,$2,$3,$4,$5,$6)',
      [
        actor.userId,
        operation,
        digest(key),
        digest(input),
        result,
        outcome ? this.box(outcome, `receipt:${actor.userId}:${operation}:${digest(key)}`) : null,
      ],
    );
  }

  private async rename(actor: Actor, input: Body, key: string): Promise<Outcome> {
    const name = typeof input.displayName === 'string' ? input.displayName.trim() : '';
    if (!name.length || name.length > 100)
      fail(400, 'invalid_request', 'Supply a display name of 1 to 100 characters.');
    return this.tx(async (c) => {
      const user = await this.owner(c, actor);
      const prior = await this.receipt(c, actor, 'updateAccount', key, name);
      if (prior) {
        if (!prior.outcome) fail(409, 'idempotency_expired', 'Use a new request key.');
        return prior.outcome;
      }
      const row = (
        await c.query('UPDATE app.users SET display_name=$2 WHERE id=$1 RETURNING *', [
          user.id,
          name,
        ])
      ).rows[0];
      const outcome = {
        status: 200,
        body: { data: await this.view(row) },
        headers: {},
      } as Outcome;
      await this.record(c, actor, 'updateAccount', key, name, null, outcome);
      return outcome;
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
      email: user.email ?? null,
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
  private async register(actor: Actor, input: Body, key: string): Promise<Outcome> {
    const token = typeof input.token === 'string' ? input.token : '';
    const platform = String(input.platform);
    if (!token.length || token.length > 4096)
      fail(400, 'invalid_request', 'Supply a device token of 1 to 4096 characters.');
    if (!['ios', 'android'].includes(platform))
      fail(400, 'invalid_request', 'Supply a supported device platform.');
    return this.tx(async (c) => {
      const user = await this.owner(c, actor);
      const prior = await this.receipt(c, actor, 'registerDevice', key, `${platform}:${token}`);
      if (prior) {
        if (!prior.outcome) fail(409, 'idempotency_expired', 'Use a new request key.');
        return prior.outcome;
      }
      const fingerprint = digest(token);
      const sealed = this.seal(token);
      const row = (
        await c.query(
          `INSERT INTO app.push_devices(user_id,platform,token_digest,token_ciphertext)
          VALUES ($1,$2,$3,$4)
          ON CONFLICT (token_digest) DO UPDATE
            SET user_id=EXCLUDED.user_id,platform=EXCLUDED.platform,
                token_ciphertext=EXCLUDED.token_ciphertext,revoked_at=NULL
          RETURNING *`,
          [user.id, platform, fingerprint, sealed],
        )
      ).rows[0];
      const outcome = {
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
      await this.record(c, actor, 'registerDevice', key, `${platform}:${token}`, row.id, outcome);
      return outcome;
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

  private async deleteAvatar(actor: Actor, key: string): Promise<Outcome> {
    return this.tx(async (c) => {
      const user = await this.owner(c, actor);
      const prior = await this.receipt(c, actor, 'deleteAvatar', key, '');
      if (prior) return { status: 204, body: null, headers: {} };
      if (user.avatar_object_key) {
        await c.query(
          `INSERT INTO app.erasure_tasks(user_id,kind,reference) VALUES ($1,'avatar_object',$2) ON CONFLICT DO NOTHING`,
          [user.id, user.avatar_object_key],
        );
        await c.query('UPDATE app.users SET avatar_object_key=NULL WHERE id=$1', [user.id]);
      }
      await this.record(c, actor, 'deleteAvatar', key, '', null);
      return { status: 204, body: null, headers: {} };
    });
  }

  /** Reserve cleanup before PUT. A crash may lose the response, never the key. */
  private async upload(
    actor: Actor,
    bytes: Buffer,
    contentType: string | undefined,
    key: string,
  ): Promise<Outcome> {
    if (!this.options.avatars)
      fail(503, 'avatar_store_unavailable', 'Avatars are temporarily unavailable.');
    const type = String(contentType ?? '')
      .split(';')[0]!
      .trim()
      .toLowerCase();
    if (!IMAGE_TYPES.includes(type))
      fail(415, 'unsupported_media_type', 'Supply a JPEG, PNG or WebP image.');
    if (!Buffer.isBuffer(bytes) || !bytes.length)
      fail(400, 'invalid_request', 'Supply an image to upload.');
    if (bytes.length > this.maxAvatarBytes)
      fail(413, 'payload_too_large', 'That image is larger than the accepted size.');
    // The declared type has to be what the bytes actually are.
    if (!looksLike(type, bytes))
      fail(415, 'unsupported_media_type', 'That file is not the type it claims.');
    const fingerprint = digest(bytes);
    const input = `${type}:${fingerprint}`;
    // Session lock spans network I/O, not a transaction. Cleanup takes the same
    // lock before claiming an abandoned intent. Process death releases it.
    const lock = await this.options.pool.connect();
    const lockKey = `avatar:${id(actor.userId)}:${digest(key)}`;
    let task: Row | undefined;
    let putFinished = false;
    try {
      await lock.query("SET lock_timeout='3s'");
      await lock.query('SELECT pg_advisory_lock(hashtextextended($1,0))', [lockKey]);
      const prepared = await this.tx(async (c) => {
        await this.owner(c, actor);
        const prior = await this.receipt(c, actor, 'uploadAvatar', key, input);
        if (prior) return null;
        const existing = (
          await c.query(
            'SELECT * FROM app.erasure_tasks WHERE user_id=$1 AND command_key_hash=$2 FOR UPDATE',
            [actor.userId, digest(key)],
          )
        ).rows[0];
        if (existing) {
          if (existing.input_hash !== digest(input))
            fail(409, 'idempotency_conflict', 'This key was used for another image.');
          // Once recovery claimed a failed upload, the same key can never PUT again.
          if (
            existing.state !== 'uploading' ||
            existing.claim_id ||
            existing.available_at <= this.now()
          )
            fail(409, 'idempotency_expired', 'Retry this upload with a new key.');
          return existing;
        }
        const extension = type === 'image/jpeg' ? 'jpg' : type === 'image/png' ? 'png' : 'webp';
        const objectKey = `avatars/${actor.userId}/${randomUUID()}.${extension}`;
        return (
          await c.query(
            `INSERT INTO app.erasure_tasks(user_id,kind,reference,state,command_key_hash,input_hash,available_at)
          VALUES ($1,'avatar_object',$2,'uploading',$3,$4,clock_timestamp()+interval '5 minutes') RETURNING *`,
            [actor.userId, objectKey, digest(key), digest(input)],
          )
        ).rows[0];
      }, lock);
      if (!prepared) return this.avatar(actor);
      task = prepared;
      const stored = await this.options.avatars.put({
        userId: actor.userId,
        objectKey: prepared.reference,
        bytes,
        contentType: type,
      });
      putFinished = true;
      if (stored.objectKey !== prepared.reference)
        throw new Error('avatar_store_changed_reserved_key');
      await this.tx(async (c) => {
        const user = await this.owner(c, actor);
        const displaced = user.avatar_object_key as string | null;
        await c.query('UPDATE app.users SET avatar_object_key=$2 WHERE id=$1', [
          user.id,
          stored.objectKey,
        ]);
        await this.record(c, actor, 'uploadAvatar', key, input, stored.objectKey);
        await c.query(
          `UPDATE app.erasure_tasks SET state='cancelled',reference=id::text,
          disposition='attached',completed_at=clock_timestamp() WHERE id=$1 AND state='uploading'`,
          [prepared.id],
        );
        if (displaced && displaced !== stored.objectKey)
          await c.query(
            `INSERT INTO app.erasure_tasks(user_id,kind,reference) VALUES ($1,'avatar_object',$2) ON CONFLICT DO NOTHING`,
            [user.id, displaced],
          );
      }, lock);
    } catch (error) {
      if (task)
        await this.tx(
          (c) =>
            c.query(
              `UPDATE app.erasure_tasks SET state='pending',
        available_at=CASE WHEN $2 THEN clock_timestamp() ELSE available_at END
        WHERE id=$1 AND state='uploading'`,
              [task!.id, putFinished],
            ),
          lock,
        );
      throw error;
    } finally {
      // A connection whose unlock fails must not return a session lock to the pool.
      let broken = false;
      try {
        await lock.query('SELECT pg_advisory_unlock(hashtextextended($1,0))', [lockKey]);
        await lock.query('RESET lock_timeout');
      } catch {
        broken = true;
      }
      lock.release(broken);
    }
    await this.retryErasures(10);
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
  private async erase(actor: Actor, key: string): Promise<Outcome> {
    const outstanding = await this.tx(async (c) => {
      await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [id(actor.userId)]);
      // verifyAccess already checked signature, issuer, audience and expiry.
      // This exception is bound to the original deletion session AND exact key;
      // it grants no refresh or access to any other operation.
      const erased = (
        await c.query(
          `SELECT e.session_id FROM app.account_erasures e
        JOIN app.users u ON u.id=e.user_id WHERE e.user_id=$1 AND u.deleted_at IS NOT NULL`,
          [id(actor.userId)],
        )
      ).rows[0];
      if (erased) {
        if (erased.session_id !== id(actor.sessionId))
          fail(401, 'unauthenticated', 'Sign in to continue.');
        const prior = await this.receipt(c, actor, 'eraseAccount', key, actor.userId);
        if (!prior) fail(401, 'unauthenticated', 'Sign in to continue.');
        return false;
      }
      const user = await this.owner(c, actor);
      await this.receipt(c, actor, 'eraseAccount', key, user.id);
      await this.options.erasureRequested?.(c, user.id, user.email ?? null);
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
      // The subject goes now, so signing in again is a new account. The token
      // stays only until the grant it opens has actually been revoked.
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
      for (const identity of identities) {
        const taskId = randomUUID();
        // Google sign-in supplies an ID token, not an OAuth refresh grant.
        const applicable = identity.provider === 'apple' && !!identity.provider_token_ciphertext;
        await c.query(
          `INSERT INTO app.erasure_tasks(id,user_id,kind,reference,payload_ciphertext,state,completed_at,disposition)
          VALUES ($1::uuid,$2,'provider_revocation',$1::text,$3,$4,CASE WHEN $4='done' THEN clock_timestamp() END,$5)`,
          [
            taskId,
            user.id,
            applicable
              ? this.box(
                  {
                    provider: identity.provider,
                    subject: identity.subject,
                    tokenCiphertext: identity.provider_token_ciphertext,
                  },
                  `task:${taskId}`,
                )
              : null,
            applicable ? 'pending' : 'done',
            applicable ? null : 'not_applicable',
          ],
        );
      }
      if (objectKey)
        await c.query(
          `INSERT INTO app.erasure_tasks(user_id,kind,reference) VALUES ($1,'avatar_object',$2) ON CONFLICT DO NOTHING`,
          [user.id, objectKey],
        );
      // A driver's own record carries a name, a phone number and a licence.
      // Closing the account closes that too, or erasure is only half done.
      await c.query(
        `UPDATE app.drivers SET name='Erased driver',phone=NULL,license_number=NULL,
          archived_at=coalesce(archived_at,clock_timestamp()) WHERE user_id=$1`,
        [user.id],
      );
      await this.record(c, actor, 'eraseAccount', key, user.id, null);
      await c.query(
        `UPDATE app.driver_commands SET response_body=NULL,secret_ciphertext=NULL
        WHERE driver_id IN (SELECT id FROM app.drivers WHERE user_id=$1)
        AND (response_body IS NOT NULL OR secret_ciphertext IS NOT NULL)`,
        [user.id],
      );
      await c.query(
        'UPDATE app.account_commands SET result=NULL,response_ciphertext=NULL WHERE actor_user_id=$1 AND (result IS NOT NULL OR response_ciphertext IS NOT NULL)',
        [user.id],
      );
      return true;
    });
    // Attempted once here so an ordinary erasure finishes now. A failure is
    // already recorded, and the maintenance worker owns the retry.
    if (outstanding) await this.retryErasures(50, actor.userId);
    return { status: 204, body: null, headers: {} } as Outcome;
  }

  private async attempt(task: Row) {
    const reach = this.options.reach;
    const settle = async (state: 'done' | 'unavailable', failure: string | null) => {
      const done = await this.tx((c) =>
        c.query(
          `UPDATE app.erasure_tasks SET state=$3,last_failure=$4,
            reference=CASE WHEN $3='done' THEN id::text ELSE reference END,
            payload_ciphertext=CASE WHEN $3='done' THEN NULL ELSE payload_ciphertext END,
            disposition=CASE WHEN $3='done' THEN $5 ELSE NULL END,
            completed_at=CASE WHEN $3='done' THEN clock_timestamp() ELSE NULL END,
            claim_id=NULL,lease_until=NULL
          WHERE id=$1 AND claim_id=$2 AND state NOT IN ('done','cancelled')`,
          [
            task.id,
            task.claim_id,
            state,
            failure,
            task.kind === 'avatar_object' ? 'removed' : 'revoked',
          ],
        ),
      );
      return (done.rowCount ?? 0) > 0 && state === 'done';
    };
    try {
      if (task.kind === 'avatar_object') {
        if (!reach?.removeAvatarObject) return settle('unavailable', 'no_object_reach');
        await reach.removeAvatarObject(task.reference);
      } else {
        if (!reach?.revokeProviderGrant) return settle('unavailable', 'no_provider_reach');
        if (!task.payload_ciphertext) return settle('unavailable', 'missing_provider_payload');
        await reach.revokeProviderGrant(this.unbox(task.payload_ciphertext, `task:${task.id}`));
      }
      return settle('done', null);
    } catch (error) {
      return settle('unavailable', (error instanceof Error ? error.name : 'unknown').slice(0, 200));
    }
  }

  /** Retry what erasure could not finish. Bounded, and never invents success. */
  async retryErasures(
    limit = 50,
    userId?: string,
  ): Promise<{ considered: number; completed: number; failed: number }> {
    let completed = 0,
      considered = 0,
      failed = 0;
    const handled = new Set<string>();
    for (let taken = 0; taken < Math.max(1, Math.min(limit, 100)); taken++) {
      // Persist the lease before network I/O. SKIP LOCKED alone stops protecting
      // the task as soon as this transaction commits. Expired leases recover a
      // dead worker, while claim_id prevents its late completion stealing a claim.
      const claimed = await this.tx(async (c) => {
        const row = (
          await c.query(
            `SELECT * FROM app.erasure_tasks
            WHERE state NOT IN ('done','cancelled') AND NOT (id = ANY($1::uuid[]))
              AND ($2::uuid IS NULL OR user_id=$2) AND available_at<=clock_timestamp()
              AND (lease_until IS NULL OR lease_until<=clock_timestamp())
              AND (command_key_hash IS NULL OR pg_try_advisory_xact_lock(hashtextextended('avatar:'||user_id::text||':'||command_key_hash,0)))
            ORDER BY attempts,created_at,id LIMIT 1 FOR UPDATE SKIP LOCKED`,
            [[...handled], userId ?? null],
          )
        ).rows[0];
        if (!row) return null;
        return (
          await c.query(
            `UPDATE app.erasure_tasks SET state='pending',attempts=least(attempts+1,1000),claim_id=$2,
            lease_until=clock_timestamp()+interval '5 minutes' WHERE id=$1 RETURNING *`,
            [row.id, randomUUID()],
          )
        ).rows[0];
      });
      if (!claimed) break;
      handled.add(claimed.id);
      considered += 1;
      if (await this.attempt(claimed)) completed += 1;
      else failed += 1;
    }
    return { considered, completed, failed };
  }

  /** Scrub expired response bodies; key tombstones continue refusing reexecution. */
  async purgeExpiredReceipts(limit = 100): Promise<number> {
    return this.tx(
      async (c) =>
        (
          await c.query(
            `WITH expired AS (
      SELECT id FROM app.account_commands WHERE expires_at<=clock_timestamp()
        AND (result IS NOT NULL OR response_ciphertext IS NOT NULL)
      ORDER BY expires_at,id LIMIT $1 FOR UPDATE SKIP LOCKED)
      UPDATE app.account_commands SET result=NULL,response_ciphertext=NULL WHERE id IN (SELECT id FROM expired)`,
            [Math.max(1, Math.min(limit, 1000))],
          )
        ).rowCount ?? 0,
    );
  }
}
