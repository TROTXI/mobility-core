import { createHmac, randomUUID } from 'node:crypto';
import { z } from 'zod';
import type { Pool, PoolClient } from 'pg';
import type { Actor } from '../transport/service.js';
import { fail, mapDatabaseError } from '../transport/errors.js';
import { beginTransaction } from '../db/transaction.js';
import { sharedAdmission } from '../runtime/admission.js';
import { hashToken, newRefresh } from './credentials.js';
import { fullName } from './full-name.js';
import { checkPassword, hashPassword } from './password.js';

export const publicEmailOperations = [
  'requestEmailSignup',
  'signInEmail',
  'requestPasswordReset',
  'completeEmailAccess',
  'confirmContactEmail',
] as const;
export const emailOperations = [
  ...publicEmailOperations,
  'getEmailAccess',
  'resendContactEmail',
  'startEmailLink',
  'finishEmailLink',
  'changePassword',
] as const;
export type EmailOperation = (typeof emailOperations)[number];
export interface CommuterEmail {
  queueEmailAccess(
    c: PoolClient,
    mail: {
      userId: string;
      challengeId: string;
      email: string;
      token: string;
      purpose: string;
      expiresAt: Date;
      origin: string;
    },
  ): Promise<string>;
  queuePasswordChanged(c: PoolClient, userId: string, email: string, source: string): Promise<void>;
  sendQueued?(id: string): Promise<void>;
}
export const normalizeEmail = (value: unknown) => {
  const email = typeof value === 'string' ? value.trim().toLowerCase() : '';
  if (email.length > 320 || !z.email().safeParse(email).success)
    fail(400, 'invalid_email', 'Enter a valid email address.');
  return email;
};
const invalid = () =>
  fail(
    400,
    'invalid_email_link',
    'This link is invalid, expired or already used. Request a new email.',
  );

export class EmailAuth {
  constructor(
    private readonly options: {
      pool: Pool;
      secret: Buffer;
      mail?: CommuterEmail;
      origin?: string;
      authorize: (c: PoolClient, actor: Actor) => Promise<void>;
      issue: (c: PoolClient, userId: string) => Promise<unknown>;
    },
  ) {}
  private async tx<T>(work: (c: PoolClient) => Promise<T>): Promise<T> {
    const c = await this.options.pool.connect();
    try {
      await beginTransaction(c);
      const data = await work(c);
      await c.query('COMMIT');
      return data;
    } catch (e) {
      await c.query('ROLLBACK');
      throw mapDatabaseError(e);
    } finally {
      c.release();
    }
  }
  private async budget(email: string, ip: string) {
    const subject = createHmac('sha256', this.options.secret)
      .update(`${email}\0${ip}`)
      .digest('hex');
    if ((await sharedAdmission(this.options.pool).spend(`email-auth:${subject}`)).count > 6)
      fail(429, 'rate_limited', 'Too many attempts. Please wait a minute.');
  }
  private mail() {
    if (!this.options.mail || !this.options.origin)
      fail(503, 'email_unavailable', 'Email access is temporarily unavailable.');
    return this.options.mail;
  }
  private async owner(c: PoolClient, actor: Actor, recent = false) {
    // Exclusive user lock comes before session/credential locks, including erasure.
    const user = (
      await c.query('SELECT * FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR UPDATE', [
        actor.userId,
      ])
    ).rows[0];
    await this.options.authorize(c, actor);
    if (!user || user.role !== 'commuter')
      fail(403, 'forbidden', 'This feature is for commuter accounts.');
    if (
      recent &&
      !(
        await c.query(
          "SELECT 1 FROM app.auth_sessions WHERE id=$1 AND created_at>clock_timestamp()-interval '15 minutes'",
          [actor.sessionId],
        )
      ).rowCount
    )
      fail(403, 'recent_signin_required', 'Sign in again before changing your sign-in methods.');
    return user;
  }
  private async revoke(c: PoolClient, id: string) {
    await c.query(
      'UPDATE app.auth_sessions SET revoked_at=COALESCE(revoked_at,clock_timestamp()) WHERE user_id=$1',
      [id],
    );
    await c.query(
      'UPDATE app.email_auth_challenges SET token_hash=NULL,consumed_at=COALESCE(consumed_at,clock_timestamp()) WHERE user_id=$1 AND token_hash IS NOT NULL',
      [id],
    );
  }
  private async challenge(
    c: PoolClient,
    userId: string,
    email: string,
    version: number,
    purpose: string,
    sessionId: string | null,
  ) {
    // No rapid resends and no unbounded mail to a single account. Re-requesting
    // never invalidates an earlier link; only successful completion does.
    const recent = (
      await c.query(
        `SELECT count(*)::int AS count,
      count(*) FILTER (WHERE created_at>clock_timestamp()-interval '1 minute')::int AS minute
      FROM app.email_auth_challenges WHERE user_id=$1 AND created_at>clock_timestamp()-interval '1 hour'`,
        [userId],
      )
    ).rows[0];
    if (recent.minute || recent.count >= 5) return;
    const id = randomUUID(),
      token = newRefresh();
    const row = (
      await c.query(
        `INSERT INTO app.email_auth_challenges(id,user_id,purpose,token_hash,credential_version,session_id,expires_at)
      VALUES($1,$2,$3,$4,$5,$6,clock_timestamp()+interval '30 minutes') RETURNING expires_at`,
        [id, userId, purpose, hashToken(token), version, sessionId],
      )
    ).rows[0];
    // A newly issued challenge gets its full lifetime, even when the pending
    // registration/link was first requested more than a day ago. This runs
    // only after resend admission and rolls back if enqueueing fails.
    await c.query(
      'UPDATE app.email_credentials SET created_at=clock_timestamp() WHERE user_id=$1 AND version=$2 AND password_hash IS NULL',
      [userId, version],
    );
    return this.mail().queueEmailAccess(c, {
      userId,
      challengeId: id,
      email,
      token,
      purpose,
      expiresAt: row.expires_at,
      origin: this.options.origin!,
    });
  }

  /** Caller holds the user lock. A phone password is independent of email proof. */
  async queueContactProof(c: PoolClient, userId: string): Promise<string | undefined> {
    const credential = (
      await c.query(
        'SELECT email,version,password_hash,verified_at FROM app.email_credentials WHERE user_id=$1 FOR UPDATE',
        [userId],
      )
    ).rows[0];
    if (!credential?.email || !credential.password_hash)
      fail(409, 'email_unavailable', 'Add an email and password before verifying an address.');
    if (credential.verified_at) return;
    return this.challenge(c, userId, credential.email, credential.version, 'contact', null);
  }

  private async confirmContact(token: unknown) {
    const code = typeof token === 'string' && /^[A-Za-z0-9_-]{43}$/.test(token) ? token : invalid();
    const snapshot = (
      await this.options.pool.query(
        `SELECT a.id,a.user_id,e.email FROM app.email_auth_challenges a
         JOIN app.email_credentials e ON e.user_id=a.user_id
         WHERE a.token_hash=$1 AND a.purpose='contact' AND a.consumed_at IS NULL
           AND a.expires_at>clock_timestamp() AND a.credential_version=e.version`,
        [hashToken(code)],
      )
    ).rows[0];
    if (!snapshot?.email) invalid();
    await this.tx(async (c) => {
      await c.query("SELECT pg_advisory_xact_lock(hashtextextended('email-auth:'||$1,0))", [
        snapshot.email,
      ]);
      const user = (
        await c.query(
          "SELECT id FROM app.users WHERE id=$1 AND role='commuter' AND deleted_at IS NULL FOR UPDATE",
          [snapshot.user_id],
        )
      ).rows[0];
      if (!user) invalid();
      const credential = (
        await c.query('SELECT * FROM app.email_credentials WHERE user_id=$1 FOR UPDATE', [user.id])
      ).rows[0];
      const challenge = (
        await c.query(
          `SELECT 1 FROM app.email_auth_challenges WHERE id=$1 AND token_hash=$2
           AND purpose='contact' AND consumed_at IS NULL AND expires_at>clock_timestamp()
           AND credential_version=$3 FOR UPDATE`,
          [snapshot.id, hashToken(code), credential?.version],
        )
      ).rows[0];
      if (
        !challenge ||
        !credential?.password_hash ||
        credential.email !== snapshot.email ||
        credential.verified_at
      )
        invalid();
      if (
        (
          await c.query(
            `SELECT 1 FROM app.users WHERE id<>$1 AND lower(email)=$2 AND deleted_at IS NULL
             UNION ALL SELECT 1 FROM app.email_credentials WHERE user_id<>$1 AND email=$2 AND verified_at IS NOT NULL`,
            [user.id, credential.email],
          )
        ).rowCount
      )
        fail(409, 'email_unavailable', 'This address belongs to another account.');
      await c.query(
        'UPDATE app.email_credentials SET verified_at=clock_timestamp(),version=version+1 WHERE user_id=$1',
        [user.id],
      );
      await c.query('UPDATE app.users SET email=$2 WHERE id=$1', [user.id, credential.email]);
      await c.query(
        'UPDATE app.email_auth_challenges SET token_hash=NULL,consumed_at=COALESCE(consumed_at,clock_timestamp()) WHERE user_id=$1 AND token_hash IS NOT NULL',
        [user.id],
      );
    });
  }
  private async request(body: any, reset: boolean, actor?: Actor) {
    this.mail();
    const email = normalizeEmail(body.email);
    const names = !reset && !actor ? fullName(body) : null;
    const queued = await this.tx(async (c) => {
      await c.query("SELECT pg_advisory_xact_lock(hashtextextended('email-auth:'||$1,0))", [email]);
      let userId: string;
      if (actor) {
        await this.owner(c, actor, true);
        const other = await c.query(
          'SELECT 1 FROM app.users WHERE lower(email)=$1 AND id<>$2 AND deleted_at IS NULL',
          [email, actor.userId],
        );
        if (other.rowCount)
          fail(
            409,
            'email_unavailable',
            'This email cannot be linked. Sign in to the account that already uses it.',
          );
        userId = actor.userId;
      } else {
        const cr = (
          await c.query(
            `SELECT user_id,password_hash,signup_pending FROM app.email_credentials WHERE email=$1
              AND (signup_pending OR verified_at IS NOT NULL) ORDER BY verified_at DESC NULLS LAST LIMIT 1`,
            [email],
          )
        ).rows[0];
        if (reset) {
          if (!cr?.password_hash) return;
          userId = cr.user_id;
        } else if (cr) {
          if (cr.password_hash || !cr.signup_pending) return;
          userId = cr.user_id;
        } else {
          // Contact addresses are not authentication proof. Never merge a
          // Google/phone account into a public registration based on an email.
          if (
            (
              await c.query(
                'SELECT 1 FROM app.users WHERE lower(email)=$1 AND deleted_at IS NULL',
                [email],
              )
            ).rowCount
          )
            return;
          userId = (
            await c.query(
              `INSERT INTO app.users(role,display_name,first_name,last_name,other_names)
            VALUES('commuter',$1,$2,$3,$4) RETURNING id`,
              [names!.displayName, names!.firstName, names!.lastName, names!.otherNames],
            )
          ).rows[0].id;
        }
      }
      const user = (
        await c.query('SELECT role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR UPDATE', [
          userId,
        ])
      ).rows[0];
      if (user?.role !== 'commuter') return;
      const old = (
        await c.query('SELECT * FROM app.email_credentials WHERE user_id=$1 FOR UPDATE', [userId])
      ).rows[0];
      if (actor && old?.password_hash)
        fail(409, 'email_already_linked', 'This account already has email sign-in.');
      let version = old?.version ?? 1;
      if (actor && old && old.email !== email) {
        version++;
        await c.query('UPDATE app.email_credentials SET email=$2,version=$3 WHERE user_id=$1', [
          userId,
          email,
          version,
        ]);
        await c.query(
          'UPDATE app.email_auth_challenges SET token_hash=NULL,consumed_at=COALESCE(consumed_at,clock_timestamp()) WHERE user_id=$1 AND token_hash IS NOT NULL',
          [userId],
        );
      }
      if (!old)
        await c.query(
          'INSERT INTO app.email_credentials(user_id,email,signup_pending) VALUES($1,$2,$3)',
          [userId, email, !actor && !reset],
        );
      return this.challenge(
        c,
        userId,
        email,
        version,
        reset ? 'reset' : actor ? 'link' : 'signup',
        actor?.sessionId ?? null,
      );
    });
    // Never expose provider latency through a non-enumerating request response.
    // The durable outbox survives shutdown while this best-effort send runs.
    if (queued) void this.options.mail?.sendQueued?.(queued).catch(() => {});
    return {
      message:
        'If this email can be used, an email will arrive shortly. Check your inbox and spam folder.',
    };
  }
  private async complete(body: any, actor?: Actor) {
    const token =
      typeof body.token === 'string' && /^[A-Za-z0-9_-]{43}$/.test(body.token)
        ? body.token
        : invalid();
    const snapshot = (
      await this.options.pool.query(
        `SELECT a.*,e.password_hash,e.email FROM app.email_auth_challenges a
      JOIN app.email_credentials e ON e.user_id=a.user_id WHERE a.token_hash=$1 AND a.expires_at>clock_timestamp()
      AND a.consumed_at IS NULL AND a.credential_version=e.version`,
        [hashToken(token)],
      )
    ).rows[0];
    if (
      !snapshot ||
      !['signup', 'link', 'reset'].includes(snapshot.purpose) ||
      (snapshot.purpose === 'link') !== !!actor ||
      (actor && (snapshot.user_id !== actor.userId || snapshot.session_id !== actor.sessionId))
    )
      invalid();
    // Expensive hashing is deliberately outside user locks and pool leases.
    const password = await hashPassword(body.password);
    await this.tx(async (c) => {
      await c.query("SELECT pg_advisory_xact_lock(hashtextextended('email-auth:'||$1,0))", [
        snapshot.email,
      ]);
      const user = (
        await c.query('SELECT * FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR UPDATE', [
          snapshot.user_id,
        ])
      ).rows[0];
      if (user?.role !== 'commuter') invalid();
      // Recent sign-in was required at issuance. Completion remains bound to
      // that same live session and the challenge's advertised 30-minute expiry.
      if (actor) await this.owner(c, actor);
      const cr = (
        await c.query('SELECT * FROM app.email_credentials WHERE user_id=$1 FOR UPDATE', [user.id])
      ).rows[0];
      const current = (
        await c.query(
          `SELECT * FROM app.email_auth_challenges WHERE id=$1 AND token_hash=$2
        AND consumed_at IS NULL AND expires_at>clock_timestamp() FOR UPDATE`,
          [snapshot.id, hashToken(token)],
        )
      ).rows[0];
      if (
        !current ||
        current.credential_version !== cr?.version ||
        (current.purpose === 'signup' && !cr.signup_pending)
      )
        invalid();
      if (
        current.purpose !== 'reset' &&
        (
          await c.query(
            `SELECT 1 FROM app.users WHERE id<>$1 AND lower(email)=$2 AND deleted_at IS NULL
        UNION ALL SELECT 1 FROM app.email_credentials WHERE user_id<>$1 AND email=$2 AND verified_at IS NOT NULL`,
            [user.id, cr.email],
          )
        ).rowCount
      )
        fail(
          409,
          'email_unavailable',
          'This email now belongs to another account. Sign in to that account instead.',
        );
      await c.query(
        'UPDATE app.email_credentials SET password_hash=$2,verified_at=COALESCE(verified_at,clock_timestamp()),signup_pending=false,version=version+1 WHERE user_id=$1',
        [user.id, password],
      );
      await c.query('UPDATE app.users SET email=$2 WHERE id=$1', [user.id, cr.email]);
      await this.revoke(c, user.id);
      await this.options.mail?.queuePasswordChanged(c, user.id, cr.email, current.id);
    });
  }
  async handle(name: EmailOperation, actor: Actor | undefined, body: any, ip: string) {
    if (
      name === 'requestEmailSignup' ||
      name === 'requestPasswordReset' ||
      name === 'signInEmail'
    ) {
      const email = normalizeEmail(body.email);
      await this.budget(email, ip);
      if (name !== 'signInEmail') return this.request(body, name === 'requestPasswordReset');
      const cr = (
        await this.options.pool.query(
          `SELECT e.* FROM app.email_credentials e JOIN app.users u ON u.id=e.user_id
        WHERE e.email=$1 AND u.deleted_at IS NULL AND u.role='commuter' AND e.verified_at IS NOT NULL`,
          [email],
        )
      ).rows[0];
      const ok = await checkPassword(
        typeof body.password === 'string' ? body.password : '',
        cr?.password_hash ?? null,
      );
      if (!ok) fail(401, 'invalid_credentials', 'Email or password is incorrect.');
      return this.tx(async (c) => {
        const user = (
          await c.query(
            "SELECT id FROM app.users WHERE id=$1 AND role='commuter' AND deleted_at IS NULL FOR UPDATE",
            [cr.user_id],
          )
        ).rows[0];
        const live = (
          await c.query(
            'SELECT version,password_hash FROM app.email_credentials WHERE user_id=$1 FOR SHARE',
            [cr.user_id],
          )
        ).rows[0];
        if (!user || live?.version !== cr.version || live?.password_hash !== cr.password_hash)
          fail(401, 'invalid_credentials', 'Email or password is incorrect.');
        return this.options.issue(c, user.id);
      });
    }
    if (name === 'completeEmailAccess') return this.complete(body);
    if (name === 'confirmContactEmail') return this.confirmContact(body.token);
    if (!actor) fail(401, 'unauthenticated', 'Sign in to continue.');
    if (name === 'resendContactEmail') {
      const queued = await this.tx(async (c) => {
        await this.owner(c, actor);
        return this.queueContactProof(c, actor.userId);
      });
      if (queued) void this.options.mail?.sendQueued?.(queued).catch(() => {});
      return { message: 'If your email is unverified, a new link will arrive shortly.' };
    }
    if (name === 'startEmailLink') return this.request(body, false, actor);
    if (name === 'finishEmailLink') return this.complete(body, actor);
    if (name === 'getEmailAccess')
      return this.tx(async (c) => {
        await this.owner(c, actor);
        const cr = (
          await c.query(
            'SELECT email,verified_at,password_hash FROM app.email_credentials WHERE user_id=$1',
            [actor.userId],
          )
        ).rows[0];
        return {
          email: cr?.email ?? null,
          passwordEnabled: !!cr?.password_hash,
          emailVerified: !!cr?.verified_at,
        };
      });
    // Password changes need both a recent session and the current password.
    const cr = await this.tx(async (c) => {
      await this.owner(c, actor, true);
      return (await c.query('SELECT * FROM app.email_credentials WHERE user_id=$1', [actor.userId]))
        .rows[0];
    });
    if (!(await checkPassword(body.currentPassword, cr?.password_hash ?? null)))
      fail(401, 'invalid_credentials', 'Current password is incorrect.');
    const password = await hashPassword(body.password);
    await this.tx(async (c) => {
      await this.owner(c, actor, true);
      const live = (
        await c.query('SELECT * FROM app.email_credentials WHERE user_id=$1 FOR UPDATE', [
          actor.userId,
        ])
      ).rows[0];
      if (live?.version !== cr.version)
        fail(409, 'credentials_changed', 'Sign in again and retry.');
      await c.query(
        'UPDATE app.email_credentials SET password_hash=$2,version=version+1 WHERE user_id=$1',
        [actor.userId, password],
      );
      await this.revoke(c, actor.userId);
      if (cr.verified_at)
        await this.options.mail?.queuePasswordChanged(c, actor.userId, cr.email, randomUUID());
    });
  }
}

/** Expired secrets and never-activated registrations are not permanent PII. */
export async function purgeExpiredEmailAccess(pool: Pool, limit = 100) {
  if (!Number.isInteger(limit) || limit < 1 || limit > 1000)
    throw new Error('Invalid email cleanup batch');
  // Separate short transaction: never hold a challenge lock while acquiring
  // its user lock (completion and erasure lock users first).
  const expired = await pool.query(
    `UPDATE app.email_auth_challenges SET token_hash=NULL,consumed_at=COALESCE(consumed_at,clock_timestamp())
    WHERE id IN (SELECT id FROM app.email_auth_challenges WHERE token_hash IS NOT NULL AND expires_at<=clock_timestamp()
      ORDER BY expires_at LIMIT $1 FOR UPDATE SKIP LOCKED)`,
    [limit],
  );
  const c = await pool.connect();
  try {
    await beginTransaction(c);
    // Never remove a previously activated account. A pending signup has never
    // owned a session or identity; restored expired links remain unusable too.
    const users = (
      await c.query(
        `SELECT u.id FROM app.users u JOIN app.email_credentials e ON e.user_id=u.id
      WHERE e.email IS NOT NULL AND e.password_hash IS NULL AND e.created_at<clock_timestamp()-interval '1 day'
      AND u.deleted_at IS NULL ORDER BY e.created_at LIMIT $1 FOR UPDATE OF u SKIP LOCKED`,
        [limit],
      )
    ).rows;
    for (const user of users) {
      const cr = (
        await c.query(
          `SELECT signup_pending FROM app.email_credentials WHERE user_id=$1 AND password_hash IS NULL
        AND created_at<clock_timestamp()-interval '1 day' FOR UPDATE`,
          [user.id],
        )
      ).rows[0];
      if (!cr) continue;
      await c.query(
        'UPDATE app.email_auth_challenges SET token_hash=NULL,consumed_at=COALESCE(consumed_at,clock_timestamp()) WHERE user_id=$1 AND token_hash IS NOT NULL',
        [user.id],
      );
      await c.query(
        'UPDATE app.email_credentials SET email=NULL,version=version+1,signup_pending=false WHERE user_id=$1',
        [user.id],
      );
      if (cr.signup_pending)
        await c.query(
          `UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1
        AND NOT EXISTS(SELECT 1 FROM app.auth_sessions WHERE user_id=$1)
        AND NOT EXISTS(SELECT 1 FROM app.auth_identities WHERE user_id=$1)`,
          [user.id],
        );
    }
    await c.query('COMMIT');
    return { expired: expired.rowCount ?? 0, pending: users.length };
  } catch (e) {
    await c.query('ROLLBACK');
    throw e;
  } finally {
    c.release();
  }
}
