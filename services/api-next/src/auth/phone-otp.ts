import { createHmac, hkdfSync, randomInt, randomUUID, timingSafeEqual } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { providerTokenBox } from './credentials.js';
import { fail } from '../transport/errors.js';
import { ghanaPhone, SmsSendError, type SmsSender } from '../notifications/mnotify.js';

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
  async request(value: string, sourceIp: string) {
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
      await c.query('BEGIN');
      await c.query("SET LOCAL lock_timeout='3s'");
      await c.query("SELECT pg_advisory_xact_lock(hashtextextended('phone-otp:daily-budget',0))");
      await c.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        `phone-otp:${phoneHash}`,
      ]);
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
          'This connection has reached its daily SMS limit. Try again later or use Google sign-in.',
        );
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
          'Phone sign-in messaging has reached its pilot daily limit. Please try Google sign-in.',
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
        `INSERT INTO app.phone_otp_challenges(id,phone_hash,phone_ciphertext,code_hash,created_at,expires_at,source_hash)
        VALUES ($1,$2,$3,$4,$5,$6,$7)`,
        [
          id,
          phoneHash,
          this.box.seal(phone!, id),
          this.digest(`code:${id}:${code}`),
          now,
          expires,
          sourceHash,
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
        `${this.staging ? '[Trotxi STAGING] ' : 'Trotxi '}${code} is your commuter sign-in code. Expires in 5 minutes. Never share it.`,
        true,
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
        fail(
          503,
          'sms_delivery_rejected',
          'SMS could not be sent. Try again later or use Google sign-in.',
        );
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
    if (!row || row.state !== 'sent' || row.attempts >= 5 || row.expires_at <= row.now) return null;
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
    if (!userId) {
      userId = (
        await c.query(
          "INSERT INTO app.users(role,display_name,phone) VALUES ('commuter','New commuter',$1) RETURNING id",
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
    return user?.role === 'commuter' && !user.deleted_at ? userId : null;
  }
}
