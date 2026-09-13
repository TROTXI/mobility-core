import { randomUUID } from 'node:crypto';
import { Pool } from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { PgCreditLedgerRepository } from '../src/modules/entitlements/credit-ledger.repository.pg';
import { PgEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository.pg';
import { PgPaymentLifecycle } from '../src/modules/payments/payment-lifecycle.pg';
import type {
  SettledCharge,
  SubscriptionCheckoutInput,
} from '../src/modules/payments/payment-lifecycle';
import { PgPaymentRepository } from '../src/modules/payments/payment.repository.pg';
import { PgPaymentWebhookRepository } from '../src/modules/payments/payment-webhook.repository.pg';
import { FakePaystackClient, paystackSignature } from '../src/modules/payments/paystack.client';
import { PaymentsService } from '../src/modules/payments/payments.service';
import { PgPricingRepository } from '../src/modules/payments/pricing.repository.pg';
import { PgSubscriptionRepository } from '../src/modules/subscriptions/subscription.repository.pg';
import { PgUserRepository } from '../src/modules/users/user.repository.pg';

const databaseUrl = process.env['DATABASE_URL'];
const describeWithPostgres = databaseUrl ? describe : describe.skip;
const pool = new Pool({ connectionString: databaseUrl ?? 'postgres://postgres.invalid/test' });
const createdUserIds: string[] = [];
let transactionSequence = 0n;

async function createRider(): Promise<string> {
  const id = randomUUID();
  await pool.query(`INSERT INTO users (id, display_name) VALUES ($1, $2)`, [
    id,
    `Payment concurrency test ${id}`,
  ]);
  createdUserIds.push(id);
  return id;
}

function checkout(userId: string, reference: string, now = new Date()): SubscriptionCheckoutInput {
  return {
    userId,
    reference,
    purpose: 'subscription',
    plan: 'monthly',
    routeId: null,
    currency: 'GHS',
    ridesGranted: 44,
    farePesewas: 600,
    creditPesewasPerRide: 45,
    pricePesewas: 26_400,
    now,
  };
}

function settled(reference: string, paidAt: Date, amountPesewas = 26_400): SettledCharge {
  transactionSequence += 1n;
  return {
    reference,
    status: 'success',
    amountPesewas,
    currency: 'GHS',
    providerTransactionId: String(BigInt(Date.now()) * 1_000n + transactionSequence),
    providerDomain: 'test',
    channel: 'mobile_money',
    feesPesewas: 100,
    paidAt,
  };
}

describeWithPostgres('Postgres payment lifecycle concurrency', () => {
  beforeAll(async () => {
    const { rows } = await pool.query<{ name: string }>(
      `SELECT name FROM _migrations
        WHERE name IN (
          '039_payment_lifecycle.sql',
          '040_reservation_period_accounting.sql',
          '041_payment_refunds_disputes.sql'
        )
        ORDER BY name`,
    );
    expect(rows.map((row) => row.name)).toEqual([
      '039_payment_lifecycle.sql',
      '040_reservation_period_accounting.sql',
      '041_payment_refunds_disputes.sql',
    ]);
  });

  afterAll(async () => {
    if (createdUserIds.length > 0) {
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        await client.query(
          `DELETE FROM payment_refunds
            WHERE payment_id IN (SELECT id FROM payments WHERE user_id = ANY($1::uuid[]))`,
          [createdUserIds],
        );
        await client.query(
          `DELETE FROM payment_disputes
            WHERE payment_id IN (SELECT id FROM payments WHERE user_id = ANY($1::uuid[]))`,
          [createdUserIds],
        );
        await client.query(
          `DELETE FROM payment_webhook_events
            WHERE reference IN (SELECT reference FROM payments WHERE user_id = ANY($1::uuid[]))`,
          [createdUserIds],
        );
        await client.query(
          `DELETE FROM reservations
            WHERE subscription_period_id IN (
              SELECT sp.id FROM subscription_periods sp
              JOIN subscriptions s ON s.id = sp.subscription_id
              WHERE s.user_id = ANY($1::uuid[])
            )`,
          [createdUserIds],
        );
        await client.query(`DELETE FROM credit_holds WHERE user_id = ANY($1::uuid[])`, [
          createdUserIds,
        ]);
        await client.query(`DELETE FROM entitlement_ledger WHERE user_id = ANY($1::uuid[])`, [
          createdUserIds,
        ]);
        await client.query(`DELETE FROM credit_ledger WHERE user_id = ANY($1::uuid[])`, [
          createdUserIds,
        ]);
        await client.query(
          `UPDATE payments
              SET subscription_id = NULL, subscription_period_id = NULL
            WHERE user_id = ANY($1::uuid[])`,
          [createdUserIds],
        );
        await client.query(
          `UPDATE subscriptions SET current_period_id = NULL
            WHERE user_id = ANY($1::uuid[])`,
          [createdUserIds],
        );
        await client.query(
          `DELETE FROM subscription_periods
            WHERE subscription_id IN (
              SELECT id FROM subscriptions WHERE user_id = ANY($1::uuid[])
            )`,
          [createdUserIds],
        );
        await client.query(`DELETE FROM payments WHERE user_id = ANY($1::uuid[])`, [
          createdUserIds,
        ]);
        await client.query(`DELETE FROM subscriptions WHERE user_id = ANY($1::uuid[])`, [
          createdUserIds,
        ]);
        await client.query(`DELETE FROM users WHERE id = ANY($1::uuid[])`, [createdUserIds]);
        await client.query('COMMIT');
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    }
    await pool.end();
  });

  it('lets only one concurrent checkout reserve a rider credit balance', async () => {
    const userId = await createRider();
    const lifecycle = new PgPaymentLifecycle(pool);
    await pool.query(
      `INSERT INTO credit_ledger (
         user_id, delta_pesewas, reason, ref_type, ref_id, idempotency_key
       ) VALUES ($1, 1000, 'compensation', 'test', $2, $2)`,
      [userId, `credit-${userId}`],
    );

    const attempts = await Promise.allSettled([
      lifecycle.createSubscriptionCheckout(checkout(userId, `checkout-a-${userId}`)),
      lifecycle.createSubscriptionCheckout(checkout(userId, `checkout-b-${userId}`)),
    ]);

    expect(attempts.filter((attempt) => attempt.status === 'fulfilled')).toHaveLength(1);
    expect(attempts.filter((attempt) => attempt.status === 'rejected')).toHaveLength(1);
    const { rows } = await pool.query<{ payments: number; holds: number; held: number }>(
      `SELECT count(DISTINCT p.id)::int AS payments,
              count(DISTINCT h.id)::int AS holds,
              COALESCE(sum(DISTINCT h.amount_pesewas), 0)::int AS held
         FROM payments p
         LEFT JOIN credit_holds h ON h.payment_id = p.id
        WHERE p.user_id = $1`,
      [userId],
    );
    expect(rows[0]).toEqual({ payments: 1, holds: 1, held: 1_000 });
  });

  it('fulfils one reference once under concurrent webhook workers', async () => {
    const userId = await createRider();
    const reference = `webhook-${userId}`;
    const lifecycle = new PgPaymentLifecycle(pool);
    await lifecycle.createSubscriptionCheckout(checkout(userId, reference));

    const secret = `secret-${userId}`;
    const paystack = new FakePaystackClient(secret);
    const payments = new PgPaymentRepository(pool);
    const subscriptions = new PgSubscriptionRepository(pool);
    const service = new PaymentsService({
      payments,
      subscriptions,
      entitlements: new PgEntitlementLedgerRepository(pool),
      credits: new PgCreditLedgerRepository(pool),
      paystack,
      users: new PgUserRepository(pool),
      pricing: new PgPricingRepository(pool),
      ridesPerPeriod: 44,
      lifecycle,
      webhooks: new PgPaymentWebhookRepository(pool),
    });
    const charge = settled(reference, new Date('2099-01-01T00:00:00.000Z'));
    const rawBody = JSON.stringify({
      event: 'charge.success',
      data: {
        id: charge.providerTransactionId,
        reference,
        status: 'success',
        amount: charge.amountPesewas,
        currency: charge.currency,
        domain: charge.providerDomain,
        channel: charge.channel,
        fees: charge.feesPesewas,
        paid_at: charge.paidAt.toISOString(),
      },
    });
    const signature = paystackSignature(rawBody, secret);

    await Promise.all([
      service.acceptWebhook(rawBody, signature),
      service.acceptWebhook(rawBody, signature),
    ]);
    const workers = await Promise.all([
      service.processWebhookInbox(10),
      service.processWebhookInbox(10),
    ]);

    expect(workers.reduce((total, worker) => total + worker.processed, 0)).toBe(1);
    expect((await payments.findByReference(reference))?.status).toBe('fulfilled');
    expect((await subscriptions.findActiveByUser(userId))?.currentPeriodId).toBeTruthy();
    const { rows } = await pool.query<{ allocations: number; periods: number }>(
      `SELECT
         (SELECT count(*)::int FROM entitlement_ledger
           WHERE user_id = $1 AND reason = 'allocation') AS allocations,
         (SELECT count(*)::int FROM subscription_periods sp
           JOIN subscriptions s ON s.id = sp.subscription_id
          WHERE s.user_id = $1) AS periods`,
      [userId],
    );
    expect(rows[0]).toEqual({ allocations: 1, periods: 1 });
  });

  it('closes an ended period exactly once while renewal checkout races it', async () => {
    const userId = await createRider();
    const firstReference = `first-${userId}`;
    const renewalReference = `renewal-${userId}`;
    const paidAt = new Date('2026-01-01T00:00:00.000Z');
    const afterPeriod = new Date('2026-02-02T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    await lifecycle.createSubscriptionCheckout(checkout(userId, firstReference, paidAt));
    expect(await lifecycle.fulfillSubscriptionCharge(settled(firstReference, paidAt))).toBe(
      'fulfilled',
    );

    const [close, renewal] = await Promise.all([
      lifecycle.closeEndedPeriods(afterPeriod, 100),
      lifecycle.createSubscriptionCheckout(checkout(userId, renewalReference, afterPeriod)),
    ]);

    expect(close.closed).toBeLessThanOrEqual(1);
    expect(renewal.appliedCreditPesewas).toBe(44 * 45);
    const { rows } = await pool.query<{
      closed_periods: number;
      conversions: number;
      converted_rides: number;
      renewal_payments: number;
    }>(
      `SELECT
         (SELECT count(*)::int FROM subscription_periods sp
           JOIN subscriptions s ON s.id = sp.subscription_id
          WHERE s.user_id = $1 AND sp.status = 'closed') AS closed_periods,
         (SELECT count(*)::int FROM credit_ledger
          WHERE user_id = $1 AND reason = 'month_end_conversion') AS conversions,
         (SELECT COALESCE(-sum(delta_rides), 0)::int FROM entitlement_ledger
          WHERE user_id = $1 AND reason = 'converted') AS converted_rides,
         (SELECT count(*)::int FROM payments
          WHERE user_id = $1 AND reference = $2 AND status = 'pending') AS renewal_payments`,
      [userId, renewalReference],
    );
    expect(rows[0]).toEqual({
      closed_periods: 1,
      conversions: 1,
      converted_rides: 44,
      renewal_payments: 1,
    });
  });
});
