import { createCipheriv, createDecipheriv, hkdfSync, randomBytes, randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { z } from 'zod';
import { EmailSendError, type EmailSender, type EmailMessage } from './resend.js';
import { ghanaTime } from './format.js';
import { renderHtml, renderText, type EmailContent } from './layout.js';
import type { RenewalNotice } from '../payments/auto-renewal.js';

// A rider who has already paid for the period that follows has renewed. The
// reminder exists to prompt a renewal, so it must not go to them.
const RENEWED = `EXISTS(SELECT 1 FROM app.billing_periods n WHERE n.membership_id=b.membership_id
  AND n.id<>b.id AND n.state='open' AND n.starts_at>=b.effective_ends_at)`;
// A period set to renew by card gets renewal mail instead of "renew it yourself".
/** Pesewas as Ghana cedis, e.g. GHS 1,260.00. */
const ghs = (pesewas: number) =>
  `GHS ${(pesewas / 100).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
const AUTO_RENEWING = `EXISTS(SELECT 1 FROM app.auto_renewals r WHERE r.period_id=b.id
  AND r.state IN ('scheduled','reminded','charging','failed'))`;

const payloadSchema = z
  .object({
    from: z.string().min(1).max(200),
    to: z.email().max(320),
    subject: z.string().min(1).max(200),
    text: z.string().min(1).max(8000),
    // Absent on messages queued before HTML mail; those send as text only.
    html: z.string().min(1).max(100000).optional(),
    periodEnd: z.iso.datetime().optional(),
    // Credential mail only: which credential version the message describes.
    driverId: z.uuid().optional(),
    pinVersion: z.number().int().positive().optional(),
  })
  .strict();
type Payload = z.infer<typeof payloadSchema>;
type Kind =
  | 'commuter_email_access'
  | 'commuter_password_changed'
  | 'ops_invitation'
  | 'subscription_active'
  | 'subscription_expiring'
  | 'erasure_requested'
  | 'driver_credentials_issued'
  | 'driver_pin_reset'
  | 'renewal_upcoming'
  | 'renewal_failed'
  | 'renewal_needs_offer';
export const credentialKinds = ['driver_credentials_issued', 'driver_pin_reset'] as const;
export type CredentialKind = (typeof credentialKinds)[number];
/** What a queued credential message is for, bound to one credential version. */
export interface CredentialMail {
  kind: CredentialKind;
  userId: string;
  driverId: string;
  commandId: string;
  to: string;
  name: string;
  code: string;
  pin: string;
  pinVersion: number;
  expiresAt: Date;
}
/**
 * Queue-time contract the driver service depends on. Absent when email is not
 * configured, so a request for delivery is refused instead of pretended.
 */
export interface DriverCredentialEmail {
  queueCredential(c: PoolClient, mail: CredentialMail): Promise<string>;
  /**
   * Try one queued message now, after its transaction has committed. The
   * same checks and retries as the worker apply; a failure leaves it queued.
   */
  sendQueued?(id: string): Promise<void>;
}
/**
 * Any credential message still waiting describes a PIN that is about to stop
 * being current, or an address that is about to change. Cancelled in the
 * caller's transaction, before that change commits. Plain SQL on purpose: it
 * must run even where email sending is not configured.
 */
export async function cancelCredentialMail(c: PoolClient, userId: string): Promise<number> {
  const result = await c.query(
    `UPDATE app.email_outbox SET state='cancelled',payload_ciphertext=NULL,claim_id=NULL,
      lease_until=NULL,failure_code='stale_credential'
    WHERE user_id=$1 AND state='pending' AND kind = ANY($2::text[])`,
    [userId, credentialKinds],
  );
  return result.rowCount ?? 0;
}
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
      /** Public web origin serving email images (the Ops site). */
      assetOrigin?: string;
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
    content: EmailContent,
    subject: string,
    suffix = '',
    extra: { periodEnd?: string; driverId?: string; pinVersion?: number; expiresAt?: Date } = {},
  ): Promise<string | undefined> {
    if (!email || !z.email().safeParse(email).success) return undefined;
    const id = randomUUID();
    // Staging mail says so, in words that fit what the message is about.
    const stagingNote = kind.startsWith('commuter_')
      ? 'This email is for a Trotxi staging test account, not production.'
      : kind === 'ops_invitation'
        ? 'This invitation is for Trotxi staging, not production.'
        : kind.startsWith('driver_')
          ? 'This is a Trotxi staging test account. It is not for live operations.'
          : 'This is a Trotxi staging test. No real payment was taken.';
    const theme = {
      ...(this.options.staging ? { stagingNote } : {}),
      ...(this.options.assetOrigin
        ? { logoUrl: new URL('/email/trotxi-logo-white.png', this.options.assetOrigin).href }
        : {}),
    };
    const { expiresAt, ...bound } = extra;
    const payload = payloadSchema.parse({
      from: 'Trotxi <hello@notifications.trotxi.com>',
      to: email,
      subject: `${this.options.staging ? '[STAGING TEST] ' : ''}${subject}`,
      text: renderText(content, theme),
      html: renderHtml(content, theme),
      ...Object.fromEntries(Object.entries(bound).filter(([, value]) => value !== undefined)),
    });
    const inserted = await c.query(
      `INSERT INTO app.email_outbox(id,user_id,kind,source_id,dedupe_key,payload_ciphertext,expires_at)
      VALUES($1,$2,$3,$4,$5,$6,COALESCE($7::timestamptz,transaction_timestamp()+interval '7 days'))
      ON CONFLICT(dedupe_key) DO NOTHING RETURNING id`,
      [
        id,
        userId,
        kind,
        source,
        `${kind}:${source}${suffix}`,
        this.seal(payload, id),
        expiresAt ?? null,
      ],
    );
    return inserted.rows[0]?.id as string | undefined;
  }
  /**
   * Queued inside the transaction that issues or resets the credential, so a
   * rollback leaves neither. The PIN exists only inside the encrypted payload;
   * the row carries the command as its source, which makes a replayed command
   * find the message it already queued rather than add a second one. The
   * message expires with the temporary PIN it describes.
   */
  queueCredential = async (c: PoolClient, mail: CredentialMail): Promise<string> => {
    const reset = mail.kind === 'driver_pin_reset';
    const content: EmailContent = {
      preview: reset
        ? 'Your driver PIN was reset. Sign in with the temporary PIN inside.'
        : 'Your driver account is ready. Your sign-in details are inside.',
      heading: reset ? 'Your driver PIN has been reset' : 'Your driver account is ready',
      greeting: `Hello ${mail.name},`,
      paragraphs: [
        reset
          ? 'Trotxi operations has reset your driver PIN. Your previous PIN no longer works, and any device that was signed in has been signed out.'
          : 'Trotxi operations has set up your driver account.',
        'Sign in to the Trotxi Driver app with:',
      ],
      highlight: [
        ['Driver code', mail.code],
        ['Temporary PIN', mail.pin],
      ],
      closing: [
        `This temporary PIN works until ${ghanaTime(mail.expiresAt)}. After signing in, the app asks you to choose your own six-digit PIN before you can start work. Operations cannot see the PIN you choose.`,
      ],
      notes: [
        'Keep this email private and delete it once you have set your own PIN. Trotxi will never ask you to reply with your PIN.',
        'If the temporary PIN has expired, or you did not expect this email, contact Trotxi operations and ask for a new temporary PIN.',
      ],
    };
    const id = await this.enqueue(
      c,
      mail.userId,
      mail.kind,
      mail.commandId,
      mail.to,
      content,
      reset ? 'Your new temporary Trotxi driver PIN' : 'Your Trotxi driver sign-in details',
      '',
      { driverId: mail.driverId, pinVersion: mail.pinVersion, expiresAt: mail.expiresAt },
    );
    if (!id) throw new Error('Credential email was not queued');
    return id;
  };

  queueInvitation = async (
    c: PoolClient,
    mail: {
      ownerId: string;
      id: string;
      version: number;
      email: string;
      name: string;
      token: string;
      expiresAt: Date;
      origin: string;
    },
  ): Promise<string> => {
    const link = new URL('/', mail.origin);
    link.hash = `invite=${mail.token}`;
    const id = await this.enqueue(
      c,
      mail.ownerId,
      'ops_invitation',
      mail.id,
      mail.email,
      {
        preview: 'You have been invited to Trotxi Operations.',
        heading: 'You are invited to Trotxi Operations',
        greeting: `Hello ${mail.name},`,
        paragraphs: ['You have been invited to Trotxi Operations.'],
        action: { label: 'Accept invitation', url: link.href },
        closing: [
          `Sign in with the Google account for ${mail.email}, then create a passkey to activate your administrator access. No password or PIN is provided.`,
        ],
        notes: [
          `This invitation expires on ${ghanaTime(mail.expiresAt)} and works only with the invited account. If you did not expect it, ignore this email or contact your organisation's superadmin.`,
        ],
      },
      'Your invitation to Trotxi Operations',
      `:${mail.version}`,
      { expiresAt: mail.expiresAt },
    );
    if (!id) throw new Error('Invitation email was not queued');
    return id;
  };

  queueEmailAccess = async (
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
  ) => {
    const url = new URL('/account-access', mail.origin);
    url.hash = new URLSearchParams({ token: mail.token, purpose: mail.purpose }).toString();
    const heading = mail.purpose === 'reset' ? 'Reset your password' : 'Verify your email';
    const id = await this.enqueue(
      c,
      mail.userId,
      'commuter_email_access',
      mail.challengeId,
      mail.email,
      {
        preview: heading,
        heading,
        paragraphs: [
          mail.purpose === 'link'
            ? 'Open Trotxi on the device where you started linking your email. Paste the verification code below to set your password.'
            : mail.purpose === 'contact'
              ? 'Use this secure link to verify your contact and recovery email. Your password was already set in the app.'
              : 'Use this secure link to choose your Trotxi password. Opening the link alone does not change your account.',
        ],
        ...(mail.purpose === 'link'
          ? { highlight: [['Verification code', mail.token] as [string, string]] }
          : { action: { label: heading, url: url.toString() } }),
        notes: [
          'This link or code expires in 30 minutes and works once. If you did not request it, ignore this email. Never share it.',
        ],
      },
      heading,
      '',
      { expiresAt: mail.expiresAt },
    );
    if (!id) throw new Error('Email access message was not queued');
    return id;
  };
  queuePasswordChanged = async (c: PoolClient, userId: string, email: string, source: string) => {
    await this.enqueue(
      c,
      userId,
      'commuter_password_changed',
      source,
      email,
      {
        preview: 'Your Trotxi password has been set',
        heading: 'Your password has been set',
        paragraphs: [
          'Your Trotxi password has been set or changed. All previous app sessions have been signed out. Sign in again with your new password.',
        ],
        notes: [
          'If this was not you, use Forgot password in the Trotxi app immediately and contact support.',
        ],
      },
      'Your Trotxi password has been set',
    );
  };

  // Invoked inside fulfilment's existing transaction, after allocation. A
  // rollback leaves neither the membership effect nor a queued notification.
  subscriptionActive = async (c: PoolClient, userId: string, purchaseId: string) => {
    const row = (
      await c.query(
        `SELECT u.email,p.cash_due_pesewas,p.applied_credit_pesewas,p.rides_granted,b.starts_at,b.effective_ends_at,
        (SELECT c.brand||' ending '||c.last4 FROM app.auto_renewals r JOIN app.card_authorizations c
          ON c.user_id=r.user_id AND c.removed_at IS NULL WHERE r.period_id=b.id AND r.state='scheduled') AS renewing_card
      FROM app.purchases p JOIN app.users u ON u.id=p.user_id AND u.deleted_at IS NULL
      JOIN app.billing_periods b ON b.purchase_id=p.id WHERE p.id=$1 AND p.user_id=$2`,
        [purchaseId, userId],
      )
    ).rows[0];
    if (!row) return;
    const upcoming = row.starts_at > new Date();
    await this.enqueue(
      c,
      userId,
      'subscription_active',
      purchaseId,
      row.email,
      {
        preview: upcoming
          ? `Your subscription is paid. Coverage starts ${ghanaTime(row.starts_at)}.`
          : `Your subscription is active until ${ghanaTime(row.effective_ends_at)}.`,
        heading: upcoming ? 'Your upcoming subscription is paid' : 'Your subscription is active',
        paragraphs: [
          upcoming
            ? 'Thank you for subscribing to Trotxi. Your rides become available when coverage starts.'
            : 'Thank you for subscribing to Trotxi. Your rides are ready to use.',
        ],
        details: [
          ['Rides included', String(row.rides_granted)],
          ['Payment', ghs(row.cash_due_pesewas)],
          ['Ride Credit applied', ghs(row.applied_credit_pesewas)],
          ['Coverage starts', ghanaTime(row.starts_at)],
          ['Coverage ends', ghanaTime(row.effective_ends_at)],
        ],
        closing: [
          row.renewing_card
            ? `Auto-renewal is on. Your ${row.renewing_card} will be charged for the next period from 3 days before this one ends. You can turn this off in the app at any time.`
            : 'Renewal is manual; you will not be automatically charged.',
        ],
      },
      upcoming ? 'Your upcoming Trotxi subscription is paid' : 'Your Trotxi subscription is active',
    );
  };
  /**
   * Auto-renewal mail, deduplicated per period and kind (and per attempt for
   * a decline). Queued in the renewal worker's transaction.
   */
  renewalNotice = async (c: PoolClient, n: RenewalNotice): Promise<string | undefined> => {
    const user = (
      await c.query('SELECT email FROM app.users WHERE id=$1 AND deleted_at IS NULL', [n.userId])
    ).rows[0];
    if (!user) return undefined;
    const card = n.card ? `${n.card.brand} ending ${n.card.last4}` : 'saved card';
    const money = ghs;
    const ends = ghanaTime(n.periodEnd);
    const next = n.lastAttempt
      ? `That was the last attempt. Your coverage ends on ${ends}; to keep riding, open Trotxi and request a new offer.`
      : `We will try again tomorrow, until your coverage ends on ${ends}. To renew now another way, open Trotxi.`;
    const [subject, text] =
      n.kind === 'renewal_upcoming'
        ? [
            'Your Trotxi subscription renews soon',
            `Your coverage ends on ${ends}. Auto-renewal is on, so from 3 days before then we will charge your ${card} ${money(n.price)}, less any Ride Credit you have, for the next period on the same journeys and travel days.\nTo stop this, turn off auto-renewal in the app before then.`,
          ]
        : n.kind === 'renewal_failed'
          ? [
              'We could not renew your Trotxi subscription',
              n.reason === 'blocked'
                ? `We could not start your renewal because something on your account needs attention first, such as a payment still in progress. Nothing was charged.\n${next}`
                : n.reason === 'unconfirmed'
                  ? `We could not confirm the charge of ${money(n.charged ?? n.price)} to your ${card}, so we have cancelled that attempt. If your bank shows it as taken, Trotxi operations will review it.\n${next}`
                  : `We tried to charge your ${card} ${money(n.charged ?? n.price)} to renew your subscription and the payment did not go through.\n${next}`,
            ]
          : [
              'Your Trotxi renewal needs a new offer',
              `Your coverage ends on ${ends}. We did not renew it automatically because ${n.reason === 'fare_changed' ? 'the fare for your journeys has changed' : 'the service for your journeys has changed'}, and we only renew on the terms you agreed to. No payment has been taken.\nOpen Trotxi to request a new offer.`,
            ];
    const paragraphs = text.split('\n');
    return this.enqueue(
      c,
      n.userId,
      n.kind,
      n.periodId,
      user.email,
      {
        preview: paragraphs[0]!,
        // The logo already says Trotxi; the heading need not repeat it.
        heading: subject.replace(' Trotxi ', ' '),
        paragraphs,
      },
      subject,
      n.kind === 'renewal_failed' ? `:${n.attempt ?? 0}` : '',
      // Outlives neither the period it describes nor the outbox's 7-day limit.
      { expiresAt: new Date(Math.min(n.periodEnd.getTime(), Date.now() + 7 * 86400000 - 60000)) },
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
      {
        preview: 'We received your request to delete your Trotxi account.',
        heading: 'We received your deletion request',
        paragraphs: [
          'Your account-deletion request has been received and sign-in has been disabled.',
          'External cleanup may still be processing. Required accounting records are retained; this message is not a claim that every retained record has been deleted.',
        ],
      },
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
        AND NOT EXISTS(SELECT 1 FROM app.personal_pauses p WHERE p.period_id=b.id AND p.state='planned')
        AND NOT EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
        AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL)
        AND NOT ${RENEWED}
        AND NOT ${AUTO_RENEWING}
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
          AND NOT EXISTS(SELECT 1 FROM app.personal_pauses p WHERE p.period_id=b.id AND p.state='planned')
          AND NOT EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
          AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL)
          AND NOT ${RENEWED} AND NOT ${AUTO_RENEWING}`,
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
            {
              preview: `Your coverage ends on ${ghanaTime(p.effective_ends_at)}.`,
              heading: 'Your coverage ends soon',
              paragraphs: [
                `Your current coverage ends on ${ghanaTime(p.effective_ends_at)}. Open Trotxi to review your membership and renew.`,
              ],
              details: [['Coverage ends', ghanaTime(p.effective_ends_at)]],
              closing: ['Renewal is manual; no automatic charge will be taken.'],
            },
            'Your Trotxi coverage ends soon',
            `:${p.epoch}`,
            { periodEnd: p.effective_ends_at.toISOString() },
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
  /**
   * Deliver one message as soon as the transaction that queued it has
   * committed, instead of waiting for the next worker run. It goes through
   * the same claim, recheck and retry path as the worker, so a message that
   * became stale in the meantime is cancelled, and one the provider refuses
   * for now stays queued for the worker.
   */
  sendQueued = async (id: string): Promise<void> => {
    await this.drain(1, id);
  };
  async drain(limit = 100, only?: string): Promise<EmailStats> {
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
        SELECT id FROM app.email_outbox WHERE state='pending' AND ($2::uuid IS NULL OR id=$2)
          AND (next_attempt_at<=clock_timestamp() OR expires_at<=clock_timestamp())
          AND (lease_until IS NULL OR lease_until<clock_timestamp())
        ORDER BY next_attempt_at,created_at,id FOR UPDATE SKIP LOCKED LIMIT 1)
        UPDATE app.email_outbox e SET claim_id=$1,lease_until=clock_timestamp()+interval '1 minute',
          first_attempt_at=COALESCE(first_attempt_at,clock_timestamp())
        FROM candidate c WHERE e.id=c.id RETURNING e.*`,
          [claimId, only ?? null],
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
            if (row.kind === 'commuter_email_access')
              eligible = !!(
                await c.query(
                  `SELECT 1 FROM app.email_auth_challenges a
                JOIN app.email_credentials e ON e.user_id=a.user_id
                WHERE a.id=$1 AND a.user_id=$2 AND e.email=$3 AND a.token_hash IS NOT NULL
                  AND a.consumed_at IS NULL AND a.expires_at>clock_timestamp() AND a.credential_version=e.version
                  AND (a.session_id IS NULL OR EXISTS (SELECT 1 FROM app.auth_sessions s
                    WHERE s.id=a.session_id AND s.revoked_at IS NULL AND s.expires_at>clock_timestamp()))`,
                  [row.source_id, row.user_id, payload.to],
                )
              ).rowCount;
            if (row.kind === 'ops_invitation')
              eligible = !!(
                await c.query(
                  `SELECT 1 FROM app.ops_invitations WHERE id=$1 AND state='pending' AND expires_at>clock_timestamp() AND email=$2 AND $3='ops_invitation:'||id::text||':'||version::text`,
                  [row.source_id, payload.to, current.dedupe_key],
                )
              ).rowCount;
            if (row.kind === 'subscription_expiring')
              eligible = !!(
                await c.query(
                  `SELECT 1 FROM app.billing_periods b WHERE b.id=$1 AND b.state='open'
              AND b.effective_ends_at=$2 AND b.effective_ends_at>clock_timestamp()
              AND NOT EXISTS(SELECT 1 FROM app.personal_pauses p WHERE p.period_id=b.id AND p.state='planned')
              AND NOT EXISTS(SELECT 1 FROM app.membership_pauses p WHERE p.period_id=b.id AND p.ended_at IS NULL)
              AND NOT EXISTS(SELECT 1 FROM app.payment_access_blocks p WHERE p.period_id=b.id AND p.released_at IS NULL)
              AND NOT ${RENEWED} AND NOT ${AUTO_RENEWING}`,
                  [row.source_id, payload.periodEnd],
                )
              ).rowCount;
            // Renewal mail is only true while the renewal it describes is.
            if (row.kind === 'renewal_upcoming')
              eligible = !!(
                await c.query(
                  `SELECT 1 FROM app.auto_renewals WHERE period_id=$1 AND state IN ('scheduled','reminded')`,
                  [row.source_id],
                )
              ).rowCount;
            if (row.kind === 'renewal_failed' || row.kind === 'renewal_needs_offer')
              eligible = !!(
                await c.query(
                  `SELECT 1 FROM app.billing_periods b WHERE b.id=$1 AND b.state='open'
                  AND b.effective_ends_at>clock_timestamp() AND NOT ${RENEWED}`,
                  [row.source_id],
                )
              ).rowCount;
            let stale: 'stale_reminder' | 'stale_credential' = 'stale_reminder';
            if ((credentialKinds as readonly string[]).includes(row.kind)) {
              // Still the credential, driver and address this message was
              // written for, and the temporary PIN in it still works.
              stale = 'stale_credential';
              eligible = !!(
                await c.query(
                  `SELECT 1 FROM app.drivers d JOIN app.driver_credentials cr ON cr.driver_id=d.id
                  WHERE d.id=$1 AND d.user_id=$2 AND d.archived_at IS NULL AND d.email=$3
                    AND cr.pin_version=$4 AND cr.must_change_pin
                    AND cr.temporary_pin_expires_at>clock_timestamp()
                  FOR SHARE OF d, cr`,
                  [payload.driverId, row.user_id, payload.to, payload.pinVersion],
                )
              ).rowCount;
            }
            if (!eligible) await terminal('cancelled', stale);
            else {
              const { periodEnd: _, driverId: _d, pinVersion: _v, ...message } = payload;
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
