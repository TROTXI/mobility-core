import { createCipheriv, createDecipheriv, hkdfSync, randomBytes, randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { z } from 'zod';
import { EmailSendError, type EmailSender, type EmailMessage } from './resend.js';

const payloadSchema = z
  .object({
    from: z.string().min(1).max(200),
    to: z.email().max(320),
    subject: z.string().min(1).max(200),
    text: z.string().min(1).max(8000),
    periodEnd: z.iso.datetime().optional(),
  })
  .strict();
type Payload = z.infer<typeof payloadSchema>;
type Kind = 'subscription_active' | 'subscription_expiring' | 'erasure_requested';
export type EmailStats = {
  considered: number;
  accepted: number;
  cancelled: number;
  failed: number;
  retried: number;
  unknown: number;
};

export class TransactionalEmail {
  private readonly key: Buffer;
  constructor(
    private readonly options: {
      pool: Pool;
      encryptionKey: Buffer;
      sender: EmailSender;
      staging: boolean;
    },
  ) {
    if (options.encryptionKey.length !== 32) throw new Error('Email requires a 32-byte root key');
    this.key = Buffer.from(
      hkdfSync('sha256', options.encryptionKey, 'trotxi:email:v1', 'outbox', 32),
    );
  }
  private seal(payload: Payload, id: string) {
    const iv = randomBytes(12),
      c = createCipheriv('aes-256-gcm', this.key, iv);
    c.setAAD(Buffer.from(`email:${id}`));
    return Buffer.concat([
      iv,
      c.update(JSON.stringify(payload), 'utf8'),
      c.final(),
      c.getAuthTag(),
    ]).toString('base64url');
  }
  private open(value: string, id: string): Payload {
    const b = Buffer.from(value, 'base64url'),
      c = createDecipheriv('aes-256-gcm', this.key, b.subarray(0, 12));
    c.setAAD(Buffer.from(`email:${id}`));
    c.setAuthTag(b.subarray(-16));
    return payloadSchema.parse(
      JSON.parse(Buffer.concat([c.update(b.subarray(12, -16)), c.final()]).toString('utf8')),
    );
  }
  private async enqueue(
    c: PoolClient,
    userId: string,
    kind: Kind,
    source: string,
    email: string | null,
    text: string,
    subject: string,
    suffix = '',
    periodEnd?: string,
  ) {
    if (!email || !z.email().safeParse(email).success) return;
    const id = randomUUID();
    const payload = payloadSchema.parse({
      from: 'Trotxi <hello@notifications.trotxi.com>',
      to: email,
      subject: `${this.options.staging ? '[STAGING TEST] ' : ''}${subject}`,
      text: `${this.options.staging ? 'This is a Trotxi staging test. No real payment was taken.\n\n' : ''}${text}`,
      ...(periodEnd ? { periodEnd } : {}),
    });
    await c.query(
      `INSERT INTO app.email_outbox(id,user_id,kind,source_id,dedupe_key,payload_ciphertext)
      VALUES($1,$2,$3,$4,$5,$6) ON CONFLICT(dedupe_key) DO NOTHING`,
      [id, userId, kind, source, `${kind}:${source}${suffix}`, this.seal(payload, id)],
    );
  }
  // Invoked inside fulfilment's existing transaction, after allocation. A
  // rollback leaves neither the membership effect nor a queued notification.
  subscriptionActive = async (c: PoolClient, userId: string, purchaseId: string) => {
    const row = (
      await c.query(
        `SELECT u.email,p.cash_due_pesewas,p.applied_credit_pesewas,p.rides_granted,b.effective_ends_at
      FROM app.purchases p JOIN app.users u ON u.id=p.user_id AND u.deleted_at IS NULL
      JOIN app.billing_periods b ON b.purchase_id=p.id WHERE p.id=$1 AND p.user_id=$2`,
        [purchaseId, userId],
      )
    ).rows[0];
    if (!row) return;
    await this.enqueue(
      c,
      userId,
      'subscription_active',
      purchaseId,
      row.email,
      `Your subscription is active.\nRides added: ${row.rides_granted}\nPayment: GHS ${(row.cash_due_pesewas / 100).toFixed(2)}\nRide Credit applied: GHS ${(row.applied_credit_pesewas / 100).toFixed(2)}\nCoverage ends: ${row.effective_ends_at.toISOString()}\nRenewal is manual; you will not be automatically charged.`,
      'Your Trotxi subscription is active',
    );
  };
  // Called before account identifiers are scrubbed. This acknowledges the
  // request, never falsely claims external provider erasure has completed.
  erasureRequested = async (c: PoolClient, userId: string, email: string | null) => {
    await c.query(
      `UPDATE app.email_outbox SET state='cancelled',payload_ciphertext=NULL,claim_id=NULL,lease_until=NULL,failure_code='account_closed'
      WHERE user_id=$1 AND state='pending'`,
      [userId],
    );
    await this.enqueue(
      c,
      userId,
      'erasure_requested',
      userId,
      email,
      'Your account-deletion request has been received and sign-in has been disabled. External cleanup may still be processing. Required accounting records are retained; this message is not a claim that every retained record has been deleted.',
      'Your Trotxi deletion request',
    );
  };
  async prepareReminders(limit = 100) {
    this.bound(limit);
    const candidates = (
      await this.options.pool.query(
        `SELECT b.id,b.user_id FROM app.billing_periods b
      JOIN app.users u ON u.id=b.user_id AND u.deleted_at IS NULL AND u.email IS NOT NULL
      WHERE b.state='open' AND b.effective_ends_at>clock_timestamp()
        AND b.effective_ends_at<=clock_timestamp()+interval '3 days'
        AND NOT EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
        AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL)
        AND NOT EXISTS(SELECT 1 FROM app.email_outbox e WHERE e.kind='subscription_expiring' AND e.source_id=b.id
          AND e.dedupe_key='subscription_expiring:'||b.id::text||':'||extract(epoch FROM b.effective_ends_at)::text)
      ORDER BY b.effective_ends_at,b.id LIMIT $1`,
        [limit],
      )
    ).rows;
    for (const row of candidates) {
      const c = await this.options.pool.connect();
      try {
        await c.query('BEGIN');
        const user = (
          await c.query('SELECT email,deleted_at FROM app.users WHERE id=$1 FOR UPDATE', [
            row.user_id,
          ])
        ).rows[0];
        const p = (
          await c.query(
            `SELECT effective_ends_at,extract(epoch FROM effective_ends_at)::text AS epoch FROM app.billing_periods b
          WHERE id=$1 AND state='open' AND effective_ends_at>clock_timestamp() AND effective_ends_at<=clock_timestamp()+interval '3 days'
          AND NOT EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
          AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL)`,
            [row.id],
          )
        ).rows[0];
        if (user && !user.deleted_at && p)
          await this.enqueue(
            c,
            row.user_id,
            'subscription_expiring',
            row.id,
            user.email,
            `Your current coverage ends at ${p.effective_ends_at.toISOString()}. Open Trotxi to review your membership and renew. Renewal is manual; no automatic charge will be taken.`,
            'Your Trotxi coverage ends soon',
            `:${p.epoch}`,
            p.effective_ends_at.toISOString(),
          );
        await c.query('COMMIT');
      } catch (error) {
        await c.query('ROLLBACK');
        throw error;
      } finally {
        c.release();
      }
    }
  }
  private bound(limit: number) {
    if (!Number.isInteger(limit) || limit < 1 || limit > 100)
      throw new Error('Email batch must be between 1 and 100');
  }
  async drain(limit = 100): Promise<EmailStats> {
    this.bound(limit);
    const stats: EmailStats = {
      considered: 0,
      accepted: 0,
      cancelled: 0,
      failed: 0,
      retried: 0,
      unknown: 0,
    };
    // Claim and first-attempt clock are durable BEFORE any network call. A crash
    // cannot reset the provider's 24h idempotency window; use a 23h local ceiling.
    for (let i = 0; i < limit; i++) {
      const claimId = randomUUID();
      const row = (
        await this.options.pool.query(
          `WITH candidate AS (
        SELECT id FROM app.email_outbox WHERE state='pending'
          AND (next_attempt_at<=clock_timestamp() OR expires_at<=clock_timestamp())
          AND (lease_until IS NULL OR lease_until<clock_timestamp())
        ORDER BY next_attempt_at,created_at,id FOR UPDATE SKIP LOCKED LIMIT 1)
        UPDATE app.email_outbox e SET claim_id=$1,lease_until=clock_timestamp()+interval '1 minute',
          first_attempt_at=COALESCE(first_attempt_at,clock_timestamp())
        FROM candidate c WHERE e.id=c.id RETURNING e.*`,
          [claimId],
        )
      ).rows[0];
      if (!row) break;
      stats.considered++;
      const c = await this.options.pool.connect();
      try {
        await c.query('BEGIN');
        // Same user-first lock order as erasure. A send already in flight may
        // finish before erasure; nothing new can start after erasure commits.
        const user = (
          await c.query('SELECT deleted_at FROM app.users WHERE id=$1 FOR UPDATE', [row.user_id])
        ).rows[0];
        const current = (
          await c.query(
            `SELECT *,clock_timestamp() AS now FROM app.email_outbox WHERE id=$1 AND claim_id=$2 AND state='pending' FOR UPDATE`,
            [row.id, claimId],
          )
        ).rows[0];
        if (!current) {
          await c.query('COMMIT');
          continue;
        }
        const terminal = async (
          state: 'accepted' | 'cancelled' | 'failed' | 'unknown',
          code: string | null,
          provider: string | null = null,
        ) => {
          await c.query(
            `UPDATE app.email_outbox SET state=$2,payload_ciphertext=NULL,claim_id=NULL,lease_until=NULL,
            failure_code=$3,provider_id=$4 WHERE id=$1`,
            [row.id, state, code, provider],
          );
          stats[state]++;
        };
        if (current.now - current.first_attempt_at >= 23 * 3600000)
          await terminal('unknown', 'retry_window_elapsed');
        else if (current.now >= current.expires_at) await terminal('cancelled', 'expired');
        else if ((!user || user.deleted_at) && row.kind !== 'erasure_requested')
          await terminal('cancelled', 'account_closed');
        else {
          let payload: Payload | null = null;
          try {
            payload = this.open(current.payload_ciphertext, row.id);
          } catch {
            await terminal('failed', 'invalid_payload');
          }
          if (payload) {
            let eligible = true;
            if (row.kind === 'subscription_expiring')
              eligible = !!(
                await c.query(
                  `SELECT 1 FROM app.billing_periods b WHERE b.id=$1 AND b.state='open'
              AND b.effective_ends_at=$2 AND b.effective_ends_at>clock_timestamp()
              AND NOT EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
              AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL)`,
                  [row.source_id, payload.periodEnd],
                )
              ).rowCount;
            if (!eligible) await terminal('cancelled', 'stale_reminder');
            else {
              const { periodEnd: _, ...message } = payload;
              await c.query('UPDATE app.email_outbox SET attempts=attempts+1 WHERE id=$1', [
                row.id,
              ]);
              try {
                await terminal(
                  'accepted',
                  null,
                  await this.options.sender.send(message as EmailMessage, `trotxi-email/${row.id}`),
                );
              } catch (error) {
                if (error instanceof EmailSendError && !error.retryable)
                  await terminal('failed', 'provider_rejected');
                else if (current.attempts >= 19) await terminal('unknown', 'provider_unavailable');
                else {
                  await c.query(
                    `UPDATE app.email_outbox SET claim_id=NULL,lease_until=NULL,
                    failure_code='provider_unavailable',next_attempt_at=clock_timestamp()+make_interval(secs=>$2) WHERE id=$1`,
                    [row.id, Math.min(3600, 30 * 2 ** current.attempts)],
                  );
                  stats.retried++;
                }
              }
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
    }
    return stats;
  }
}
