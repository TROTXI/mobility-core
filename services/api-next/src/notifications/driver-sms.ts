import { createCipheriv, createDecipheriv, hkdfSync, randomBytes, randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { z } from 'zod';
import type { CredentialMail, DriverCredentialEmail } from './email.js';
import { ghanaPhone, SmsSendError, type SmsSender } from './mnotify.js';

const payloadSchema = z.strictObject({ phone: z.string(), text: z.string().max(1600) });
export async function cancelCredentialSms(c: PoolClient, userId: string): Promise<void> {
  await c.query(
    `UPDATE app.driver_sms_outbox SET state='cancelled',payload_ciphertext=NULL
    WHERE user_id=$1 AND state IN ('pending','sending')`,
    [userId],
  );
}

/** Same queue boundary as email, but no provider idempotency/retry claim. */
export class DriverSms implements DriverCredentialEmail {
  private readonly key: Buffer;
  constructor(
    private readonly pool: Pool,
    private readonly sender: SmsSender,
    rootKey: Buffer,
    private readonly staging: boolean,
  ) {
    if (rootKey.length !== 32) throw new Error('SMS requires a 32-byte root key');
    this.key = Buffer.from(hkdfSync('sha256', rootKey, 'trotxi:driver-sms:v1', 'outbox', 32));
  }
  queueCredential = async (c: PoolClient, mail: CredentialMail): Promise<string> => {
    const phone = ghanaPhone(mail.to),
      id = randomUUID();
    const payload = payloadSchema.parse({
      phone,
      text:
        `${this.staging ? '[Trotxi STAGING] ' : 'Trotxi '}${mail.kind === 'driver_pin_reset' ? 'PIN reset. Previous PIN and sessions revoked. ' : 'Driver sign-in: '}` +
        `Code ${mail.code}. Temporary PIN ${mail.pin}. Expires ${mail.expiresAt.toISOString()} (UTC). Sign in to Trotxi Driver and choose your own PIN. Never share it.`,
    });
    const iv = randomBytes(12),
      cipher = createCipheriv('aes-256-gcm', this.key, iv);
    cipher.setAAD(Buffer.from(`driver-sms:${id}`));
    const sealed = Buffer.concat([
      iv,
      cipher.update(JSON.stringify(payload)),
      cipher.final(),
      cipher.getAuthTag(),
    ]).toString('base64url');
    await c.query(
      `INSERT INTO app.driver_sms_outbox(id,user_id,driver_id,command_id,pin_version,expires_at,payload_ciphertext)
      VALUES($1,$2,$3,$4,$5,$6,$7)`,
      [id, mail.userId, mail.driverId, mail.commandId, mail.pinVersion, mail.expiresAt, sealed],
    );
    return id;
  };
  sendQueued = async (id: string): Promise<void> => {
    // Commit the claim before any network I/O. Even a process crash cannot
    // return it to pending and resend a PIN that may already have arrived.
    const claimed = (
      await this.pool.query(
        `UPDATE app.driver_sms_outbox SET state='sending',claimed_at=clock_timestamp()
      WHERE id=$1 AND state='pending' RETURNING user_id`,
        [id],
      )
    ).rows[0];
    if (!claimed) return;
    const c = await this.pool.connect();
    try {
      await c.query("BEGIN; SET LOCAL lock_timeout='3s'");
      const user = (
        await c.query('SELECT deleted_at FROM app.users WHERE id=$1 FOR UPDATE', [claimed.user_id])
      ).rows[0];
      const row = (
        await c.query(
          "SELECT *,clock_timestamp() AS now FROM app.driver_sms_outbox WHERE id=$1 AND state='sending' FOR UPDATE",
          [id],
        )
      ).rows[0];
      if (!row) {
        await c.query('COMMIT');
        return;
      }
      const finish = (state: string, provider: string | null = null) =>
        c.query(
          'UPDATE app.driver_sms_outbox SET state=$2,payload_ciphertext=NULL,provider_id=$3 WHERE id=$1',
          [id, state, provider],
        );
      if (!user || user.deleted_at || row.expires_at <= row.now) await finish('cancelled');
      else {
        const bytes = Buffer.from(row.payload_ciphertext, 'base64url');
        const cipher = createDecipheriv('aes-256-gcm', this.key, bytes.subarray(0, 12));
        cipher.setAAD(Buffer.from(`driver-sms:${id}`));
        cipher.setAuthTag(bytes.subarray(-16));
        const payload = payloadSchema.parse(
          JSON.parse(
            Buffer.concat([cipher.update(bytes.subarray(12, -16)), cipher.final()]).toString(),
          ),
        );
        const driver = (
          await c.query(
            `SELECT d.phone FROM app.drivers d JOIN app.driver_credentials cr ON cr.driver_id=d.id
          WHERE d.id=$1 AND d.user_id=$2 AND d.archived_at IS NULL
          AND cr.pin_version=$3 AND cr.must_change_pin AND cr.status='active'
          AND cr.temporary_pin_expires_at>clock_timestamp() FOR SHARE OF d,cr`,
            [row.driver_id, row.user_id, row.pin_version],
          )
        ).rows[0];
        let eligible = false;
        try {
          eligible = !!driver && ghanaPhone(driver.phone) === payload.phone;
        } catch (_) {}
        if (!eligible) await finish('cancelled');
        else {
          try {
            await finish('accepted', await this.sender.send(payload.phone, payload.text));
          } catch (error) {
            await finish(
              error instanceof SmsSendError && error.outcome === 'rejected' ? 'failed' : 'unknown',
            );
          }
        }
      }
      await c.query('COMMIT');
    } catch (error) {
      await c.query('ROLLBACK');
      throw error;
    } finally {
      c.release();
    }
  };
  async drain(limit = 100) {
    if (!Number.isInteger(limit) || limit < 1 || limit > 1000)
      throw new Error('Invalid SMS drain limit');
    // Expired leases are ambiguous, not retryable: scrub instead of resend.
    const reaped = await this.pool.query(
      `UPDATE app.driver_sms_outbox SET state='unknown',payload_ciphertext=NULL WHERE id IN
      (SELECT id FROM app.driver_sms_outbox WHERE state='sending' AND claimed_at<clock_timestamp()-interval '1 minute'
      ORDER BY claimed_at LIMIT $1 FOR UPDATE SKIP LOCKED)`,
      [limit],
    );
    const rows = (
      await this.pool.query(
        "SELECT id FROM app.driver_sms_outbox WHERE state='pending' ORDER BY created_at LIMIT $1",
        [limit],
      )
    ).rows;
    for (const row of rows) await this.sendQueued(row.id);
    const states = (
      await this.pool.query(
        'SELECT state,count(*)::int AS n FROM app.driver_sms_outbox WHERE id=ANY($1::uuid[]) GROUP BY state',
        [rows.map((row) => row.id)],
      )
    ).rows;
    const counts = Object.fromEntries(states.map((row) => [row.state, row.n]));
    return {
      considered: rows.length + (reaped.rowCount ?? 0),
      accepted: counts.accepted ?? 0,
      cancelled: counts.cancelled ?? 0,
      unknown: (counts.unknown ?? 0) + (reaped.rowCount ?? 0),
      failed: counts.failed ?? 0,
      retried: 0,
    };
  }
}
