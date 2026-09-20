import { createDecipheriv } from 'node:crypto';
import type { Pool } from 'pg';
import { PushSendError } from './fcm.js';
import type { PushSender } from './fcm.js';

/** Durable prompt fanout, bounded retries. Provider acceptance is not delivery. */
export class PushNotifications {
  constructor(private options: { pool: Pool; deviceKey: Buffer; sender: PushSender }) {}
  async drain(limit = 100) {
    if (!Number.isInteger(limit) || limit < 1 || limit > 100) throw new Error('invalid_push_limit');
    const { pool } = this.options;
    await pool.query(
      `INSERT INTO app.push_deliveries(reservation_id,device_id,user_id)
      SELECT r.id,d.id,r.user_id FROM app.reservation_prompts p JOIN app.reservations r ON r.id=p.reservation_id
      JOIN app.trips t ON t.id=r.trip_id JOIN app.push_devices d ON d.user_id=r.user_id AND d.revoked_at IS NULL
      JOIN app.users u ON u.id=r.user_id AND u.deleted_at IS NULL
      WHERE r.status='pending' AND t.status='scheduled' AND t.scheduled_at>clock_timestamp()
        AND NOT EXISTS(SELECT 1 FROM app.push_deliveries n WHERE n.reservation_id=r.id AND n.device_id=d.id)
      ORDER BY p.created_at,r.id,d.id LIMIT $1 ON CONFLICT DO NOTHING`,
      [limit],
    );
    const candidates = (
      await pool.query(
        `SELECT id,user_id FROM app.push_deliveries WHERE state='pending'
      AND next_attempt_at<=clock_timestamp() ORDER BY next_attempt_at,id LIMIT $1`,
        [limit],
      )
    ).rows;
    const result = { considered: 0, accepted: 0, cancelled: 0, failed: 0, retried: 0 };
    for (const item of candidates) {
      const c = await pool.connect();
      try {
        await c.query("BEGIN; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='30s'");
        await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [item.user_id]);
        const row = (
          await c.query(
            `SELECT * FROM app.push_deliveries WHERE id=$1 AND state='pending'
          AND next_attempt_at<=clock_timestamp() FOR UPDATE SKIP LOCKED`,
            [item.id],
          )
        ).rows[0];
        if (!row) {
          await c.query('COMMIT');
          continue;
        }
        result.considered++;
        const device = (
          await c.query('SELECT * FROM app.push_devices WHERE id=$1 FOR UPDATE', [row.device_id])
        ).rows[0];
        const eligible = (
          await c.query(
            `SELECT r.id FROM app.reservations r JOIN app.trips t ON t.id=r.trip_id
          JOIN app.billing_periods b ON b.id=r.period_id JOIN app.users u ON u.id=r.user_id
          WHERE r.id=$1 AND r.user_id=$2 AND u.deleted_at IS NULL AND r.status='pending'
            AND t.status='scheduled' AND t.scheduled_at>clock_timestamp() AND b.state='open'
            AND NOT app.personal_pause_blocks(b.id,r.service_date::timestamp AT TIME ZONE 'Africa/Accra')
            AND NOT EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
            AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL)
            AND NOT EXISTS(SELECT 1 FROM app.account_restrictions p WHERE p.user_id=r.user_id AND p.released_at IS NULL)
          FOR SHARE OF r,t,b`,
            [row.reservation_id, row.user_id],
          )
        ).rowCount;
        if (
          !eligible ||
          !device ||
          device.user_id !== row.user_id ||
          device.revoked_at ||
          !device.token_ciphertext
        ) {
          await c.query(
            "UPDATE app.push_deliveries SET state='cancelled',failure_code='ineligible' WHERE id=$1",
            [row.id],
          );
          result.cancelled++;
        } else {
          const attempt = row.attempts + 1;
          try {
            const bytes = device.token_ciphertext as Buffer;
            const cipher = createDecipheriv(
              'aes-256-gcm',
              this.options.deviceKey,
              bytes.subarray(0, 12),
            );
            cipher.setAuthTag(bytes.subarray(12, 28));
            const token = Buffer.concat([
              cipher.update(bytes.subarray(28)),
              cipher.final(),
            ]).toString('utf8');
            const providerId = await this.options.sender.send(token, row.id, row.reservation_id);
            await c.query(
              "UPDATE app.push_deliveries SET state='accepted',attempts=$2,provider_id=$3 WHERE id=$1",
              [row.id, attempt, providerId],
            );
            result.accepted++;
          } catch (error) {
            const dead = error instanceof PushSendError && error.invalidToken;
            if (dead)
              await c.query(
                'UPDATE app.push_devices SET revoked_at=clock_timestamp(),token_ciphertext=NULL WHERE id=$1',
                [device.id],
              );
            const retry = error instanceof PushSendError && error.retryable && !dead && attempt < 5;
            await c.query(
              `UPDATE app.push_deliveries SET state=$2,attempts=$3,failure_code=$4,
              next_attempt_at=clock_timestamp()+interval '1 minute' * $5 WHERE id=$1`,
              [
                row.id,
                retry ? 'pending' : 'failed',
                attempt,
                dead ? 'invalid_token' : 'provider_unavailable',
                2 ** attempt,
              ],
            );
            if (retry) result.retried++;
            else result.failed++;
          }
        }
        await c.query('COMMIT');
      } catch (e) {
        await c.query('ROLLBACK');
        throw e;
      } finally {
        c.release();
      }
    }
    return result;
  }
}
