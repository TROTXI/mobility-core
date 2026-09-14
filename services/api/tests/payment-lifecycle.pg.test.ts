import { randomUUID } from 'node:crypto';
import { Pool } from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { PgCreditLedgerRepository } from '../src/modules/entitlements/credit-ledger.repository.pg';
import { PgEntitlementLedgerRepository } from '../src/modules/entitlements/entitlement-ledger.repository.pg';
import { PgPaymentLifecycle } from '../src/modules/payments/payment-lifecycle.pg';
import {
  PeriodCloseBlockedError,
  type ProviderDispute,
  type ProviderRefund,
  type SettledCharge,
  type SubscriptionCheckoutInput,
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

function nextProviderId(): string {
  transactionSequence += 1n;
  return String(BigInt(Date.now()) * 1_000n + transactionSequence);
}

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
  return {
    reference,
    status: 'success',
    amountPesewas,
    currency: 'GHS',
    providerTransactionId: nextProviderId(),
    providerDomain: 'test',
    channel: 'mobile_money',
    feesPesewas: 100,
    paidAt,
  };
}

function paymentService(paystack: FakePaystackClient): PaymentsService {
  return new PaymentsService({
    payments: new PgPaymentRepository(pool),
    subscriptions: new PgSubscriptionRepository(pool),
    entitlements: new PgEntitlementLedgerRepository(pool),
    credits: new PgCreditLedgerRepository(pool),
    paystack,
    users: new PgUserRepository(pool),
    pricing: new PgPricingRepository(pool),
    ridesPerPeriod: 44,
    lifecycle: new PgPaymentLifecycle(pool),
    webhooks: new PgPaymentWebhookRepository(pool),
  });
}

describeWithPostgres('Postgres payment lifecycle', () => {
  beforeAll(async () => {
    const { rows } = await pool.query<{ name: string }>(
      `SELECT name FROM _migrations
        WHERE name IN (
          '039_payment_lifecycle.sql',
          '040_reservation_period_accounting.sql',
          '041_payment_refunds_disputes.sql',
          '044_payment_reconciliation_reversals.sql'
        )
        ORDER BY name`,
    );
    expect(rows.map((row) => row.name)).toEqual([
      '039_payment_lifecycle.sql',
      '040_reservation_period_accounting.sql',
      '041_payment_refunds_disputes.sql',
      '044_payment_reconciliation_reversals.sql',
    ]);
  });

  afterAll(async () => {
    if (createdUserIds.length > 0) {
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        await client.query(
          `DELETE FROM payment_reversal_reviews
            WHERE payment_id IN (SELECT id FROM payments WHERE user_id = ANY($1::uuid[]))`,
          [createdUserIds],
        );
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
            WHERE reference IN (SELECT reference FROM payments WHERE user_id = ANY($1::uuid[]))
               OR payload->'data'->>'transaction_reference' IN (
                    SELECT reference FROM payments WHERE user_id = ANY($1::uuid[])
                  )
               OR payload->'data'->'transaction'->>'reference' IN (
                    SELECT reference FROM payments WHERE user_id = ANY($1::uuid[])
                  )`,
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

  it('documents every payment money snapshot as pesewas', async () => {
    const moneyColumns = [
      'amount',
      'gross_amount_pesewas',
      'applied_credit_pesewas',
      'fare_pesewas',
      'credit_pesewas_per_ride',
      'fees_pesewas',
      'refunded_pesewas',
    ];
    const { rows } = await pool.query<{ name: string; comment: string | null }>(
      `SELECT attname AS name, col_description(attrelid, attnum) AS comment
         FROM pg_attribute
        WHERE attrelid = 'payments'::regclass AND attname = ANY($1::text[])
        ORDER BY attname`,
      [moneyColumns],
    );
    expect(rows).toHaveLength(moneyColumns.length);
    expect(rows.every((row) => row.comment?.toLowerCase().includes('pesewas'))).toBe(true);
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
    const service = paymentService(paystack);
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

  it('fulfils a normal renewal once and advances to a second immutable period', async () => {
    const userId = await createRider();
    const firstReference = `normal-first-${userId}`;
    const renewalReference = `normal-renewal-${userId}`;
    const firstPaidAt = new Date('2026-01-01T00:00:00.000Z');
    const renewalPaidAt = new Date('2026-02-02T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    await lifecycle.createSubscriptionCheckout(checkout(userId, firstReference, firstPaidAt));
    expect(await lifecycle.fulfillSubscriptionCharge(settled(firstReference, firstPaidAt))).toBe(
      'fulfilled',
    );

    const renewal = await lifecycle.createSubscriptionCheckout(
      checkout(userId, renewalReference, renewalPaidAt),
    );
    expect(renewal.subscriptionId).toBeTruthy();
    expect(renewal.appliedCreditPesewas).toBe(44 * 45);
    const renewalCharge = settled(renewalReference, renewalPaidAt, renewal.amount);
    expect(await lifecycle.fulfillSubscriptionCharge(renewalCharge)).toBe('fulfilled');
    expect(await lifecycle.fulfillSubscriptionCharge(renewalCharge)).toBe('already_fulfilled');

    const { rows } = await pool.query<{
      periods: number;
      open_periods: number;
      closed_periods: number;
      linked_payments: number;
      distinct_period_links: number;
      subscription_status: string;
      current_points_to_open: boolean;
      allocations: number;
      conversions: number;
    }>(
      `SELECT
         (SELECT count(*)::int FROM subscription_periods sp
           JOIN subscriptions s ON s.id = sp.subscription_id
          WHERE s.user_id = $1) AS periods,
         (SELECT count(*)::int FROM subscription_periods sp
           JOIN subscriptions s ON s.id = sp.subscription_id
          WHERE s.user_id = $1 AND sp.status = 'open') AS open_periods,
         (SELECT count(*)::int FROM subscription_periods sp
           JOIN subscriptions s ON s.id = sp.subscription_id
          WHERE s.user_id = $1 AND sp.status = 'closed') AS closed_periods,
         (SELECT count(*)::int FROM payments
          WHERE user_id = $1 AND status = 'fulfilled'
            AND subscription_period_id IS NOT NULL) AS linked_payments,
         (SELECT count(DISTINCT subscription_period_id)::int FROM payments
          WHERE user_id = $1 AND status = 'fulfilled') AS distinct_period_links,
         (SELECT status FROM subscriptions WHERE user_id = $1) AS subscription_status,
         EXISTS (
           SELECT 1 FROM subscriptions s
           JOIN subscription_periods current_period ON current_period.id = s.current_period_id
          WHERE s.user_id = $1 AND current_period.status = 'open'
         ) AS current_points_to_open,
         (SELECT count(*)::int FROM entitlement_ledger
          WHERE user_id = $1 AND reason = 'allocation') AS allocations,
         (SELECT count(*)::int FROM credit_ledger
          WHERE user_id = $1 AND reason = 'month_end_conversion') AS conversions`,
      [userId],
    );
    expect(rows[0]).toEqual({
      periods: 2,
      open_periods: 1,
      closed_periods: 1,
      linked_payments: 2,
      distinct_period_links: 2,
      subscription_status: 'active',
      current_points_to_open: true,
      allocations: 2,
      conversions: 1,
    });
  });

  it('closes one period once when two close workers race', async () => {
    const userId = await createRider();
    const reference = `concurrent-close-${userId}`;
    const paidAt = new Date('2026-01-01T00:00:00.000Z');
    const afterPeriod = new Date('2026-02-02T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    expect(await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt))).toBe('fulfilled');

    await Promise.all([
      lifecycle.closeEndedPeriods(afterPeriod, 100),
      lifecycle.closeEndedPeriods(afterPeriod, 100),
    ]);

    const { rows } = await pool.query<{
      period_status: string;
      conversions: number;
      converted_rides: number;
      conversion_credit: number;
    }>(
      `SELECT sp.status AS period_status,
              (SELECT count(*)::int FROM credit_ledger
                WHERE user_id = $1 AND reason = 'month_end_conversion') AS conversions,
              (SELECT COALESCE(-sum(delta_rides), 0)::int FROM entitlement_ledger
                WHERE user_id = $1 AND reason = 'converted') AS converted_rides,
              (SELECT COALESCE(sum(delta_pesewas), 0)::int FROM credit_ledger
                WHERE user_id = $1 AND reason = 'month_end_conversion') AS conversion_credit
         FROM payments p
         JOIN subscription_periods sp ON sp.id = p.subscription_period_id
        WHERE p.reference = $2`,
      [userId, reference],
    );
    expect(rows[0]).toEqual({
      period_status: 'closed',
      conversions: 1,
      converted_rides: 44,
      conversion_credit: 44 * 45,
    });
  });

  it('closes exactly at period end and mints no credit when no rides remain', async () => {
    const userId = await createRider();
    const reference = `zero-rides-${userId}`;
    const paidAt = new Date('2026-01-01T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    expect(await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt))).toBe('fulfilled');
    const payment = await new PgPaymentRepository(pool).findByReference(reference);
    expect(payment?.subscriptionPeriodId).toBeTruthy();
    const { rows: periods } = await pool.query<{ period_end: Date }>(
      `SELECT period_end FROM subscription_periods WHERE id = $1`,
      [payment!.subscriptionPeriodId],
    );
    const periodEnd = periods[0]!.period_end;
    await pool.query(
      `INSERT INTO entitlement_ledger (
         user_id, delta_rides, reason, ref_type, ref_id, idempotency_key,
         subscription_period_id
       ) VALUES ($1, -44, 'boarding', 'test', $2, $2, $3)`,
      [userId, `consume-${userId}`, payment!.subscriptionPeriodId],
    );

    await lifecycle.closeEndedPeriods(new Date(periodEnd.getTime() - 1), 100);
    let state = await pool.query<{ status: string }>(
      `SELECT status FROM subscription_periods WHERE id = $1`,
      [payment!.subscriptionPeriodId],
    );
    expect(state.rows[0]?.status).toBe('open');

    await lifecycle.closeEndedPeriods(periodEnd, 100);
    state = await pool.query(`SELECT status FROM subscription_periods WHERE id = $1`, [
      payment!.subscriptionPeriodId,
    ]);
    expect(state.rows[0]?.status).toBe('closed');
    const { rows } = await pool.query<{
      credit_entries: number;
      converted_entries: number;
      rides_converted: number;
      credit_granted: number;
    }>(
      `SELECT
         (SELECT count(*)::int FROM credit_ledger
           WHERE user_id = $1 AND reason = 'month_end_conversion') AS credit_entries,
         (SELECT count(*)::int FROM entitlement_ledger
           WHERE user_id = $1 AND reason = 'converted') AS converted_entries,
         rides_converted,
         credit_granted_pesewas AS credit_granted
       FROM subscription_periods WHERE id = $2`,
      [userId, payment!.subscriptionPeriodId],
    );
    expect(rows[0]).toEqual({
      credit_entries: 0,
      converted_entries: 0,
      rides_converted: 0,
      credit_granted: 0,
    });
  });

  it('rolls back every close mutation when conversion cannot be priced', async () => {
    const userId = await createRider();
    const reference = `rollback-close-${userId}`;
    const paidAt = new Date('2026-01-01T00:00:00.000Z');
    const afterPeriod = new Date('2026-02-02T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    expect(await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt))).toBe('fulfilled');
    const payment = await new PgPaymentRepository(pool).findByReference(reference);
    expect(payment?.subscriptionPeriodId).toBeTruthy();
    await pool.query(
      `UPDATE subscription_periods SET credit_pesewas_per_ride = NULL WHERE id = $1`,
      [payment!.subscriptionPeriodId],
    );

    await expect(lifecycle.closeEndedPeriods(afterPeriod, 100)).rejects.toThrow(
      'has rides but no frozen conversion rate',
    );

    const { rows } = await pool.query<{
      period_status: string;
      subscription_status: string;
      credit_entries: number;
      converted_entries: number;
    }>(
      `SELECT sp.status AS period_status, s.status AS subscription_status,
              (SELECT count(*)::int FROM credit_ledger
                WHERE user_id = $1 AND reason = 'month_end_conversion') AS credit_entries,
              (SELECT count(*)::int FROM entitlement_ledger
                WHERE user_id = $1 AND reason = 'converted') AS converted_entries
         FROM subscription_periods sp
         JOIN subscriptions s ON s.id = sp.subscription_id
        WHERE sp.id = $2`,
      [userId, payment!.subscriptionPeriodId],
    );
    expect(rows[0]).toEqual({
      period_status: 'open',
      subscription_status: 'active',
      credit_entries: 0,
      converted_entries: 0,
    });

    // Restore the fixture so this intentionally broken period cannot poison a
    // later close worker sharing the same test database.
    await pool.query(`UPDATE subscription_periods SET credit_pesewas_per_ride = 45 WHERE id = $1`, [
      payment!.subscriptionPeriodId,
    ]);
    await lifecycle.closeEndedPeriods(afterPeriod, 100);
  });

  it('keeps an ended period open while a funded reservation is unsettled', async () => {
    const userId = await createRider();
    const reference = `blocked-${userId}`;
    const paidAt = new Date('2026-01-01T00:00:00.000Z');
    const afterPeriod = new Date('2026-02-02T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    expect(await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt))).toBe('fulfilled');
    const payment = await new PgPaymentRepository(pool).findByReference(reference);
    expect(payment?.subscriptionPeriodId).toBeTruthy();
    await pool.query(
      `INSERT INTO reservations (
         user_id, travel_date, direction, status, source, subscription_period_id
       ) VALUES ($1, '2026-01-31', 'morning', 'reserved', 'confirmation', $2)`,
      [userId, payment!.subscriptionPeriodId],
    );

    const close = await lifecycle.closeEndedPeriods(afterPeriod, 100);

    expect(close.blocked).toBeGreaterThanOrEqual(1);
    const { rows } = await pool.query<{
      period_status: string;
      subscription_status: string;
      conversions: number;
    }>(
      `SELECT p.status AS period_status,
              s.status AS subscription_status,
              (SELECT count(*)::int FROM credit_ledger
                WHERE user_id = $1 AND reason = 'month_end_conversion') AS conversions
         FROM subscription_periods p
         JOIN subscriptions s ON s.id = p.subscription_id
        WHERE p.id = $2`,
      [userId, payment!.subscriptionPeriodId],
    );
    expect(rows[0]).toEqual({
      period_status: 'open',
      subscription_status: 'active',
      conversions: 0,
    });
    await expect(
      lifecycle.createSubscriptionCheckout(
        checkout(userId, `renew-blocked-${userId}`, afterPeriod),
      ),
    ).rejects.toBeInstanceOf(PeriodCloseBlockedError);
  });

  it('reconciles a successful provider charge when its webhook never arrived', async () => {
    const userId = await createRider();
    const reference = `reconcile-${userId}`;
    const paidAt = new Date('2026-03-01T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    const payment = await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    // Reconciliation scans every unresolved payment. Backdate only this row so
    // the exact count stays isolated from the other Postgres files running in
    // parallel against the same CI database.
    await pool.query(`UPDATE payments SET created_at = $2 WHERE reference = $1`, [
      reference,
      new Date('2025-01-01T00:00:00.000Z'),
    ]);
    const secret = `secret-${userId}`;
    const paystack = new FakePaystackClient(secret);
    await paystack.initializeTransaction({
      email: `${userId}@users.trotxi.app`,
      amountPesewas: payment.amount,
      reference,
    });
    paystack.setTransaction(reference, {
      status: 'success',
      providerTransactionId: nextProviderId(),
      channel: 'mobile_money',
      feesPesewas: 100,
      paidAt,
    });
    const service = paymentService(paystack);

    const result = await service.reconcileUnresolved(new Date('2025-01-02T00:00:00.000Z'));

    expect(result).toMatchObject({ considered: 1, fulfilled: 1, failed: 0, errors: 0 });
    expect((await new PgPaymentRepository(pool).findByReference(reference))?.status).toBe(
      'fulfilled',
    );
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

  it('applies a full refund once and restores captured Ride Credit', async () => {
    const userId = await createRider();
    const reference = `refund-${userId}`;
    const paidAt = new Date('2026-04-01T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    await pool.query(
      `INSERT INTO credit_ledger (
         user_id, delta_pesewas, reason, ref_type, ref_id, idempotency_key
       ) VALUES ($1, 1000, 'compensation', 'test', $2, $2)`,
      [userId, `refund-credit-${userId}`],
    );
    const payment = await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    expect(payment.appliedCreditPesewas).toBe(1_000);
    expect(
      await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt, payment.amount)),
    ).toBe('fulfilled');
    const refund: ProviderRefund = {
      eventKey: `refund-event-${userId}`,
      reference,
      refundReference: `refund-provider-${userId}`,
      amountPesewas: payment.amount,
      currency: 'GHS',
      providerDomain: 'test',
      status: 'processed',
      payload: { test: true },
    };

    await Promise.all([lifecycle.recordRefund(refund), lifecycle.recordRefund(refund)]);

    expect((await new PgPaymentRepository(pool).findByReference(reference))?.status).toBe(
      'refunded',
    );
    const { rows } = await pool.query<{
      rides: number;
      credit: number;
      refunds: number;
      period_status: string;
      subscription_status: string;
    }>(
      `SELECT
         (SELECT COALESCE(sum(delta_rides), 0)::int FROM entitlement_ledger
           WHERE user_id = $1) AS rides,
         (SELECT COALESCE(sum(delta_pesewas), 0)::int FROM credit_ledger
           WHERE user_id = $1) AS credit,
         (SELECT count(*)::int FROM payment_refunds r
           JOIN payments p ON p.id = r.payment_id WHERE p.reference = $2) AS refunds,
         sp.status AS period_status,
         s.status AS subscription_status
       FROM payments p
       JOIN subscription_periods sp ON sp.id = p.subscription_period_id
       JOIN subscriptions s ON s.id = p.subscription_id
       WHERE p.reference = $2`,
      [userId, reference],
    );
    expect(rows[0]).toEqual({
      rides: 0,
      credit: 1_000,
      refunds: 1,
      period_status: 'reversed',
      subscription_status: 'expired',
    });
  });

  it('freezes a disputed period and restores it after a declined resolution', async () => {
    const userId = await createRider();
    const reference = `dispute-${userId}`;
    const paidAt = new Date('2026-05-01T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    const payment = await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    expect(await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt))).toBe('fulfilled');
    const created: ProviderDispute = {
      reference,
      providerDisputeId: nextProviderId(),
      amountPesewas: payment.amount,
      currency: 'GHS',
      providerDomain: 'test',
      status: 'created',
      resolution: null,
      payload: { test: true },
    };
    const resolved: ProviderDispute = {
      ...created,
      status: 'resolved',
      resolution: 'declined',
    };

    expect(await lifecycle.recordDispute(created)).toBe(true);
    let states = await pool.query<{
      payment_status: string;
      period_status: string;
      subscription_status: string;
    }>(
      `SELECT p.status AS payment_status, sp.status AS period_status,
              s.status AS subscription_status
         FROM payments p
         JOIN subscription_periods sp ON sp.id = p.subscription_period_id
         JOIN subscriptions s ON s.id = p.subscription_id
        WHERE p.reference = $1`,
      [reference],
    );
    expect(states.rows[0]).toEqual({
      payment_status: 'disputed',
      period_status: 'frozen',
      subscription_status: 'suspended',
    });

    expect(await lifecycle.recordDispute(resolved)).toBe(true);
    expect(await lifecycle.recordDispute(resolved)).toBe(true);
    states = await pool.query(
      `SELECT p.status AS payment_status, sp.status AS period_status,
              s.status AS subscription_status
         FROM payments p
         JOIN subscription_periods sp ON sp.id = p.subscription_period_id
         JOIN subscriptions s ON s.id = p.subscription_id
        WHERE p.reference = $1`,
      [reference],
    );
    expect(states.rows[0]).toEqual({
      payment_status: 'fulfilled',
      period_status: 'open',
      subscription_status: 'active',
    });
    const { rows } = await pool.query<{ disputes: number }>(
      `SELECT count(*)::int AS disputes FROM payment_disputes d
        JOIN payments p ON p.id = d.payment_id WHERE p.reference = $1`,
      [reference],
    );
    expect(rows[0]?.disputes).toBe(1);
  });

  it('restores a merchant-accepted dispute after its partial refund is processed', async () => {
    const userId = await createRider();
    const reference = `accepted-dispute-${userId}`;
    const paidAt = new Date('2026-06-01T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    expect(await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt))).toBe('fulfilled');
    const acceptedAmountPesewas = 1_000;
    const dispute: ProviderDispute = {
      reference,
      providerDisputeId: nextProviderId(),
      amountPesewas: acceptedAmountPesewas,
      currency: 'GHS',
      providerDomain: 'test',
      status: 'resolved',
      resolution: 'merchant-accepted',
      payload: { test: true },
    };
    const refund: ProviderRefund = {
      eventKey: `accepted-refund-event-${userId}`,
      reference,
      refundReference: `accepted-refund-provider-${userId}`,
      amountPesewas: acceptedAmountPesewas,
      currency: 'GHS',
      providerDomain: 'test',
      status: 'processed',
      payload: { test: true },
    };

    expect(await lifecycle.recordDispute(dispute)).toBe(true);
    let states = await pool.query<{
      payment_status: string;
      refunded_pesewas: number;
      period_status: string;
      subscription_status: string;
      rides: number;
    }>(
      `SELECT p.status AS payment_status, p.refunded_pesewas,
              sp.status AS period_status, s.status AS subscription_status,
              (SELECT COALESCE(sum(delta_rides), 0)::int FROM entitlement_ledger
                WHERE subscription_period_id = sp.id) AS rides
         FROM payments p
         JOIN subscription_periods sp ON sp.id = p.subscription_period_id
         JOIN subscriptions s ON s.id = p.subscription_id
        WHERE p.reference = $1`,
      [reference],
    );
    expect(states.rows[0]).toEqual({
      payment_status: 'disputed',
      refunded_pesewas: 0,
      period_status: 'frozen',
      subscription_status: 'suspended',
      rides: 44,
    });

    expect(await lifecycle.recordRefund(refund)).toBe(true);
    states = await pool.query(
      `SELECT p.status AS payment_status, p.refunded_pesewas,
              sp.status AS period_status, s.status AS subscription_status,
              (SELECT COALESCE(sum(delta_rides), 0)::int FROM entitlement_ledger
                WHERE subscription_period_id = sp.id) AS rides
         FROM payments p
         JOIN subscription_periods sp ON sp.id = p.subscription_period_id
         JOIN subscriptions s ON s.id = p.subscription_id
        WHERE p.reference = $1`,
      [reference],
    );
    expect(states.rows[0]).toEqual({
      payment_status: 'fulfilled',
      refunded_pesewas: acceptedAmountPesewas,
      period_status: 'open',
      subscription_status: 'active',
      rides: 44,
    });
  });

  it('records consumed-value debt and keeps entitlement non-negative on full refund', async () => {
    const userId = await createRider();
    const reference = `consumed-refund-${userId}`;
    const paidAt = new Date('2026-07-01T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    const payment = await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    expect(payment.grossAmountPesewas).toBe(26_400);
    expect(await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt))).toBe('fulfilled');
    const fulfilled = (await new PgPaymentRepository(pool).findByReference(reference))!;
    await pool.query(
      `INSERT INTO entitlement_ledger (
         user_id, delta_rides, reason, ref_type, ref_id, idempotency_key,
         subscription_period_id
       ) VALUES ($1, -10, 'boarding', 'test', $2, $2, $3)`,
      [userId, `consumed-${userId}`, fulfilled.subscriptionPeriodId],
    );

    expect(
      await lifecycle.recordRefund({
        eventKey: `consumed-refund-event-${userId}`,
        reference,
        refundReference: `consumed-refund-provider-${userId}`,
        amountPesewas: payment.amount,
        currency: 'GHS',
        providerDomain: 'test',
        status: 'processed',
        payload: { test: true },
      }),
    ).toBe(true);

    const { rows } = await pool.query<{
      rides: number;
      consumed_rides: number;
      unrecovered_credit_pesewas: number;
      estimated_debt_pesewas: number;
      reviews: number;
    }>(
      `SELECT
         (SELECT COALESCE(sum(delta_rides), 0)::int FROM entitlement_ledger
           WHERE subscription_period_id = p.subscription_period_id) AS rides,
         r.consumed_rides, r.unrecovered_credit_pesewas, r.estimated_debt_pesewas,
         (SELECT count(*)::int FROM payment_reversal_reviews WHERE payment_id = p.id) AS reviews
       FROM payments p JOIN payment_reversal_reviews r ON r.payment_id = p.id
       WHERE p.reference = $1`,
      [reference],
    );
    expect(rows[0]).toEqual({
      rides: 0,
      consumed_rides: 10,
      unrecovered_credit_pesewas: 0,
      estimated_debt_pesewas: 6_000,
      reviews: 1,
    });
    expect(await lifecycle.listOperationsReviews()).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          kind: 'manual_review',
          paymentReference: reference,
          amountPesewas: 6_000,
          consumedRides: 10,
          unrecoveredCreditPesewas: 0,
          estimatedDebtPesewas: 6_000,
        }),
      ]),
    );
  });

  it('excludes month-end conversion from consumption and claws its credit back on refund', async () => {
    const userId = await createRider();
    const reference = `closed-refund-${userId}`;
    const paidAt = new Date('2026-01-01T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    const payment = await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt));
    await lifecycle.closeEndedPeriods(new Date('2026-02-02T00:00:00.000Z'));

    expect(
      await lifecycle.recordRefund({
        eventKey: `closed-refund-event-${userId}`,
        reference,
        refundReference: `closed-refund-provider-${userId}`,
        amountPesewas: payment.amount,
        currency: 'GHS',
        providerDomain: 'test',
        status: 'processed',
        payload: { test: true },
      }),
    ).toBe(true);

    const { rows } = await pool.query<{
      rides: number;
      credit: number;
      reviews: number;
      period_status: string;
    }>(
      `SELECT
         (SELECT COALESCE(sum(delta_rides), 0)::int FROM entitlement_ledger
           WHERE subscription_period_id = p.subscription_period_id) AS rides,
         (SELECT COALESCE(sum(delta_pesewas), 0)::int FROM credit_ledger
           WHERE user_id = p.user_id) AS credit,
         (SELECT count(*)::int FROM payment_reversal_reviews WHERE payment_id = p.id) AS reviews,
         sp.status AS period_status
       FROM payments p JOIN subscription_periods sp ON sp.id = p.subscription_period_id
       WHERE p.reference = $1`,
      [reference],
    );
    expect(rows[0]).toEqual({ rides: 0, credit: 0, reviews: 0, period_status: 'reversed' });
  });

  it('keeps refund and dispute state monotonic under out-of-order delivery', async () => {
    const userId = await createRider();
    const reference = `out-of-order-${userId}`;
    const paidAt = new Date('2026-08-01T00:00:00.000Z');
    const lifecycle = new PgPaymentLifecycle(pool);
    const payment = await lifecycle.createSubscriptionCheckout(checkout(userId, reference, paidAt));
    await lifecycle.fulfillSubscriptionCharge(settled(reference, paidAt));
    const refund: ProviderRefund = {
      eventKey: `refund-failed-${userId}`,
      reference,
      refundReference: `refund-monotonic-${userId}`,
      amountPesewas: 1_000,
      currency: 'GHS',
      providerDomain: 'test',
      status: 'failed',
      payload: { state: 'failed' },
    };
    await lifecycle.recordRefund(refund);
    await lifecycle.recordRefund({
      ...refund,
      eventKey: `refund-old-${userId}`,
      status: 'pending',
    });
    const dispute: ProviderDispute = {
      reference,
      providerDisputeId: nextProviderId(),
      amountPesewas: 1_000,
      currency: 'GHS',
      providerDomain: 'test',
      status: 'reminded',
      resolution: null,
      payload: { state: 'reminded' },
    };
    await lifecycle.recordDispute(dispute);
    await lifecycle.recordDispute({ ...dispute, status: 'created' });

    expect(await lifecycle.listOperationsReviews()).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ kind: 'refund', paymentReference: reference, status: 'failed' }),
        expect.objectContaining({
          kind: 'dispute',
          paymentReference: reference,
          status: 'reminded',
        }),
      ]),
    );
    expect(payment.amount).toBe(26_400);
  });
});
