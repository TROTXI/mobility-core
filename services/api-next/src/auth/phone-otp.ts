import { createHmac, hkdfSync, randomInt, randomUUID, timingSafeEqual } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { providerTokenBox } from './credentials.js';
import { fail } from '../transport/errors.js';
import { ghanaPhone, SmsSendError, type SmsSender } from '../notifications/mnotify.js';

/** Phone identity lookup must work even when the SMS sender is unavailable. */
export function phoneIdentity(value: string, encryptionKey: Buffer) {
  let phone: string;
  try {
    phone = ghanaPhone(value);
  } catch {
    fail(400, 'invalid_phone', 'Use a valid Ghana phone number.');
  }
  const key = Buffer.from(hkdfSync('sha256', encryptionKey, 'trotxi:phone:v1', 'otp-digest', 32));
  const phoneHash = createHmac('sha256', key).update(`phone:${phone!}`).digest('hex');
  return { phone: phone!, phoneHash };
}

/** Physical cleanup after the rolling abuse budget no longer needs its hash. */
export async function purgeExpiredPhoneOtpChallenges(pool: Pool, limit = 100): Promise<number> {
  const bounded = Math.max(1, Math.min(limit, 1000));
  const result = await pool.query(
    `DELETE FROM app.phone_otp_challenges WHERE id IN (
      SELECT id FROM app.phone_otp_challenges
      WHERE created_at < clock_timestamp() - interval '24 hours'
      ORDER BY created_at,id LIMIT $1 FOR UPDATE SKIP LOCKED)`,
    [bounded],
  );
  return result.rowCount ?? 0;
}

/** Status is readable even when outbound SMS has not been configured. */
export async function phoneVerificationStatus(c: PoolClient, userId: string) {
  const verified = (
    await c.query<{ last_four: string | null; verified_at: Date }>(
      'SELECT last_four,verified_at FROM app.commuter_phone_verifications WHERE user_id=$1 AND revoked_at IS NULL',
      [userId],
    )
  ).rows[0];
  const review = (
    await c.query(
      'SELECT 1 FROM app.phone_verification_reviews WHERE user_id=$1 AND closed_at IS NULL',
      [userId],
    )
  ).rowCount;
  const pending = (
    await c.query(
      `SELECT 1 FROM app.phone_otp_challenges WHERE owner_user_id=$1
       AND purpose='standby_verification' AND state='sent' AND expires_at>clock_timestamp() LIMIT 1`,
      [userId],
    )
  ).rowCount;
  return {
    phone: {
      status: review ? 'review' : pending ? 'pending' : verified ? 'verified' : 'incomplete',
      maskedNumber: verified?.last_four ? `+233 ** *** ${verified.last_four}` : null,
      verifiedAt: verified?.verified_at.toISOString() ?? null,
    },
  };
}

export class PhoneOtp {
  private readonly key: Buffer;
  private readonly box;
  constructor(
    private readonly pool: Pool,
    private readonly sender: SmsSender,
    encryptionKey: Buffer,
    private readonly staging: boolean,
  ) {
    this.key = Buffer.from(hkdfSync('sha256', encryptionKey, 'trotxi:phone:v1', 'otp-digest', 32));
    this.box = providerTokenBox(
      Buffer.from(hkdfSync('sha256', encryptionKey, 'trotxi:phone:v1', 'challenge-phone', 32)),
    );
  }
  private digest(value: string) {
    return createHmac('sha256', this.key).update(value).digest('hex');
  }
  async request(
    value: string,
    sourceIp: string,
    upgrade?: { userId: string; authorize: (client: PoolClient) => Promise<void> },
  ) {
    let phone: string;
    try {
      phone = ghanaPhone(value);
    } catch (_) {
      fail(400, 'invalid_phone', 'Use a valid Ghana phone number.');
    }
    if (!sourceIp)
      fail(503, 'phone_signin_unavailable', 'Phone sign-in is temporarily unavailable.');
    const sourceHash = this.digest(`source:${sourceIp}`);
    const phoneHash = this.digest(`phone:${phone!}`),
      id = randomUUID();
    const code = String(randomInt(1000000)).padStart(6, '0');
    const c = await this.pool.connect();
    let expires: Date;
    try {
      await c.query("BEGIN; SET LOCAL lock_timeout='3s'");
      await c.query("SELECT pg_advisory_xact_lock(hashtextextended('phone-otp:daily-budget',0))");
      await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        `phone-otp:${phoneHash}`,
      ]);
      if (upgrade) {
        await upgrade.authorize(c);
        const user = (
          await c.query('SELECT role,deleted_at FROM app.users WHERE id=$1 FOR SHARE', [
            upgrade.userId,
          ])
        ).rows[0];
        if (user?.role !== 'commuter' || user.deleted_at)
          fail(403, 'forbidden', 'Phone verification is for commuters only.');
      }
      const now = (await c.query('SELECT clock_timestamp() AS now')).rows[0].now as Date;
      // The global lock serializes both rolling budgets across replicas. No
      // raw address is stored; caller supplies Fastify's trusted-proxy result.
      const source = (
        await c.query(
          "SELECT count(*)::int AS n FROM app.phone_otp_challenges WHERE source_hash=$1 AND created_at>$2::timestamptz-interval '24 hours'",
          [sourceHash, now],
        )
      ).rows[0];
      if (source.n >= 50)
        fail(
          429,
          'phone_source_limited',
          'This connection has reached its daily SMS limit. Try again later.',
        );
      if (upgrade) {
        const account = (
          await c.query(
            `SELECT count(*)::int AS n FROM app.phone_otp_challenges
             WHERE owner_user_id=$1 AND created_at>$2::timestamptz-interval '24 hours'`,
            [upgrade.userId, now],
          )
        ).rows[0];
        if (account.n >= 10)
          fail(429, 'phone_account_limited', 'This account has reached its daily SMS limit.');
      }
      const global = (
        await c.query(
          "SELECT count(*)::int AS n FROM app.phone_otp_challenges WHERE created_at > $1::timestamptz - interval '24 hours'",
          [now],
        )
      ).rows[0];
      if (global.n >= 200)
        fail(
          429,
          'sms_daily_limit',
          'Phone verification has reached its daily limit. Please try again later.',
        );
      const recent = (
        await c.query(
          `SELECT count(*) FILTER (WHERE created_at > $2::timestamptz - interval '1 hour')::int AS hourly,
        count(*)::int AS daily,max(created_at) AS latest FROM app.phone_otp_challenges
        WHERE phone_hash=$1 AND created_at > $2::timestamptz - interval '24 hours'`,
          [phoneHash, now],
        )
      ).rows[0];
      if (
        recent.hourly >= 5 ||
        recent.daily >= 10 ||
        (recent.latest && now.getTime() - recent.latest.getTime() < 60000)
      )
        fail(
          429,
          'phone_send_limited',
          'Wait before requesting another code. Maximum five per hour and ten per day.',
        );
      await c.query(
        `DELETE FROM app.phone_otp_challenges WHERE id IN
        (SELECT id FROM app.phone_otp_challenges WHERE created_at < $1::timestamptz - interval '24 hours' ORDER BY created_at LIMIT 100 FOR UPDATE SKIP LOCKED)`,
        [now],
      );
      await c.query(
        `UPDATE app.phone_otp_challenges SET state='failed',phone_ciphertext=NULL,code_hash=NULL
        WHERE phone_hash=$1 AND state IN ('sending','sent')`,
        [phoneHash],
      );
      expires = new Date(now.getTime() + 300000);
      await c.query(
        `INSERT INTO app.phone_otp_challenges(id,phone_hash,phone_ciphertext,code_hash,created_at,expires_at,source_hash,purpose,owner_user_id)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
        [
          id,
          phoneHash,
          this.box.seal(phone!, id),
          this.digest(`code:${id}:${code}`),
          now,
          expires,
          sourceHash,
          upgrade ? 'standby_verification' : 'sign_in',
          upgrade?.userId ?? null,
        ],
      );
      await c.query('COMMIT');
    } catch (error) {
      await c.query('ROLLBACK');
      throw error;
    } finally {
      c.release();
    }
    try {
      await this.sender.send(
        phone!,
        `${this.staging ? '[Trotxi STAGING] ' : 'Trotxi '}${code} is your commuter ${upgrade ? 'phone verification' : 'sign-in'} code. Expires in 5 minutes. Never share it.`,
      );
      const updated = await this.pool.query(
        `UPDATE app.phone_otp_challenges SET state='sent' WHERE id=$1 AND state='sending' RETURNING id`,
        [id],
      );
      if (updated.rowCount !== 1) fail(409, 'otp_superseded', 'Request a fresh sign-in code.');
    } catch (error) {
      await this.pool.query(
        `UPDATE app.phone_otp_challenges SET state='failed',phone_ciphertext=NULL,code_hash=NULL WHERE id=$1 AND state <> 'consumed'`,
        [id],
      );
      if (error instanceof SmsSendError && error.outcome === 'rejected')
        fail(503, 'sms_delivery_rejected', 'SMS could not be sent. Try again later.');
      fail(
        503,
        'sms_delivery_unconfirmed',
        'SMS delivery could not be confirmed. Wait a minute and request a new code.',
      );
    }
    return { challengeId: id, expiresAt: expires!.toISOString(), resendAfterSeconds: 60 };
  }
  /** Caller commits null outcomes too: failed guesses must not roll back. */
  async verify(c: PoolClient, id: string, code: string): Promise<string | null> {
    const hint = (
      await c.query('SELECT phone_hash FROM app.phone_otp_challenges WHERE id=$1', [id])
    ).rows[0];
    if (!hint) return null;
    await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
      `phone-otp:${hint.phone_hash}`,
    ]);
    const row = (
      await c.query(
        `SELECT *,clock_timestamp() AS now FROM app.phone_otp_challenges WHERE id=$1 FOR UPDATE`,
        [id],
      )
    ).rows[0];
    if (
      !row ||
      row.purpose !== 'sign_in' ||
      row.state !== 'sent' ||
      row.attempts >= 5 ||
      row.expires_at <= row.now
    )
      return null;
    const hash = this.digest(`code:${id}:${code}`);
    const correct = timingSafeEqual(Buffer.from(hash, 'hex'), Buffer.from(row.code_hash, 'hex'));
    await c.query('UPDATE app.phone_otp_challenges SET attempts=attempts+1 WHERE id=$1', [id]);
    if (!correct) {
      if (row.attempts === 4)
        await c.query(
          "UPDATE app.phone_otp_challenges SET state='failed',code_hash=NULL,phone_ciphertext=NULL WHERE id=$1",
          [id],
        );
      return null;
    }
    const phone = this.box.open(row.phone_ciphertext, id);
    let userId = (
      await c.query(
        "SELECT user_id FROM app.auth_identities WHERE provider='phone' AND subject=$1",
        [row.phone_hash],
      )
    ).rows[0]?.user_id;
    const verifiedOwner = (
      await c.query(
        'SELECT user_id FROM app.commuter_phone_verifications WHERE phone_hash=$1 AND revoked_at IS NULL',
        [row.phone_hash],
      )
    ).rows[0]?.user_id;
    if (verifiedOwner && verifiedOwner !== userId) {
      await c.query(
        "UPDATE app.phone_otp_challenges SET state='consumed',code_hash=NULL,phone_ciphertext=NULL WHERE id=$1",
        [id],
      );
      return null;
    }
    if (!userId) {
      userId = (
        await c.query(
          "INSERT INTO app.users(role,display_name,phone,phone_registration_pending) VALUES ('commuter','New commuter',$1,true) RETURNING id",
          [phone],
        )
      ).rows[0].id;
      await c.query(
        "INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,'phone',$2)",
        [userId, row.phone_hash],
      );
    }
    const user = (
      await c.query('SELECT role,deleted_at FROM app.users WHERE id=$1 FOR UPDATE', [userId])
    ).rows[0];
    await c.query(
      "UPDATE app.phone_otp_challenges SET state='consumed',code_hash=NULL,phone_ciphertext=NULL WHERE id=$1",
      [id],
    );
    if (user?.role !== 'commuter' || user.deleted_at) return null;
    await c.query(
      `INSERT INTO app.commuter_phone_verifications(user_id,phone_hash,last_four,verified_at,method)
       VALUES ($1,$2,$3,clock_timestamp(),'phone_sign_in')
       ON CONFLICT(user_id) DO UPDATE SET phone_hash=EXCLUDED.phone_hash,
         last_four=EXCLUDED.last_four,verified_at=EXCLUDED.verified_at,method=EXCLUDED.method,
         revoked_at=NULL`,
      [userId, row.phone_hash, phone.slice(-4)],
    );
    return userId;
  }

  /** Caller commits null outcomes: wrong guesses must survive the transaction. */
  async confirmForAccount(
    c: PoolClient,
    actor: { userId: string; sessionId: string },
    challengeId: string,
    code: string,
    authorize: (client: PoolClient) => Promise<void>,
  ): Promise<'verified' | 'review' | null> {
    const hint = (
      await c.query('SELECT phone_hash FROM app.phone_otp_challenges WHERE id=$1', [challengeId])
    ).rows[0];
    if (!hint) return null;
    await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
      `phone-otp:${hint.phone_hash}`,
    ]);
    const challenge = (
      await c.query(
        'SELECT *,clock_timestamp() AS now FROM app.phone_otp_challenges WHERE id=$1 FOR UPDATE',
        [challengeId],
      )
    ).rows[0];
    if (
      !challenge ||
      challenge.purpose !== 'standby_verification' ||
      challenge.owner_user_id !== actor.userId ||
      challenge.state !== 'sent' ||
      challenge.attempts >= 5 ||
      challenge.expires_at <= challenge.now
    )
      return null;
    const user = (
      await c.query('SELECT role,deleted_at FROM app.users WHERE id=$1 FOR UPDATE', [actor.userId])
    ).rows[0];
    await authorize(c);
    if (user?.role !== 'commuter' || user.deleted_at)
      fail(403, 'forbidden', 'Phone verification is for commuters only.');
    const hash = this.digest(`code:${challengeId}:${code}`);
    const correct = timingSafeEqual(
      Buffer.from(hash, 'hex'),
      Buffer.from(challenge.code_hash, 'hex'),
    );
    await c.query('UPDATE app.phone_otp_challenges SET attempts=attempts+1 WHERE id=$1', [
      challengeId,
    ]);
    if (!correct) {
      if (challenge.attempts === 4)
        await c.query(
          "UPDATE app.phone_otp_challenges SET state='failed',code_hash=NULL,phone_ciphertext=NULL WHERE id=$1",
          [challengeId],
        );
      return null;
    }
    const phone = this.box.open(challenge.phone_ciphertext, challengeId);
    await c.query(
      "UPDATE app.phone_otp_challenges SET state='consumed',code_hash=NULL,phone_ciphertext=NULL WHERE id=$1",
      [challengeId],
    );
    const prior = (
      await c.query(
        'SELECT phone_hash FROM app.commuter_phone_verifications WHERE user_id=$1 AND revoked_at IS NULL',
        [actor.userId],
      )
    ).rows[0];
    const phoneIdentity = (
      await c.query(
        "SELECT user_id FROM app.auth_identities WHERE provider='phone' AND subject=$1",
        [challenge.phone_hash],
      )
    ).rows[0];
    const ownPhoneIdentity = (
      await c.query(
        "SELECT subject FROM app.auth_identities WHERE provider='phone' AND user_id=$1",
        [actor.userId],
      )
    ).rows[0];
    const claimed = (
      await c.query(
        'SELECT user_id FROM app.commuter_phone_verifications WHERE phone_hash=$1 AND revoked_at IS NULL',
        [challenge.phone_hash],
      )
    ).rows[0];
    if (
      (phoneIdentity && phoneIdentity.user_id !== actor.userId) ||
      (claimed && claimed.user_id !== actor.userId) ||
      (ownPhoneIdentity && ownPhoneIdentity.subject !== challenge.phone_hash)
    ) {
      await c.query(
        `INSERT INTO app.phone_verification_reviews(user_id,phone_hash) VALUES ($1,$2)
         ON CONFLICT(user_id) DO UPDATE SET phone_hash=EXCLUDED.phone_hash,
           created_at=clock_timestamp(),closed_at=NULL`,
        [actor.userId, challenge.phone_hash],
      );
      return 'review';
    }
    if (prior && prior.phone_hash !== challenge.phone_hash) {
      const recent = (
        await c.query(
          `SELECT 1 FROM app.auth_sessions WHERE id=$1 AND user_id=$2
           AND created_at>clock_timestamp()-interval '10 minutes'`,
          [actor.sessionId, actor.userId],
        )
      ).rowCount;
      if (!recent) fail(403, 'recent_signin_required', 'Sign in again before changing your phone.');
      await c.query(
        'UPDATE app.commuter_phone_verifications SET phone_hash=NULL,last_four=NULL,revoked_at=clock_timestamp() WHERE user_id=$1',
        [actor.userId],
      );
    }
    await c.query(
      `INSERT INTO app.commuter_phone_verifications(user_id,phone_hash,last_four,verified_at,method)
       VALUES ($1,$2,$3,clock_timestamp(),'account_upgrade')
       ON CONFLICT(user_id) DO UPDATE SET phone_hash=EXCLUDED.phone_hash,
         last_four=EXCLUDED.last_four,verified_at=EXCLUDED.verified_at,method=EXCLUDED.method,
         revoked_at=NULL`,
      [actor.userId, challenge.phone_hash, phone.slice(-4)],
    );
    await c.query(
      'UPDATE app.phone_verification_reviews SET phone_hash=NULL,closed_at=clock_timestamp() WHERE user_id=$1 AND closed_at IS NULL',
      [actor.userId],
    );
    await c.query('UPDATE app.users SET phone=$2 WHERE id=$1', [actor.userId, phone]);
    return 'verified';
  }
}
