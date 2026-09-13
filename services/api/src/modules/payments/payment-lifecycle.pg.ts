import type { Pool, PoolClient } from 'pg';
import { periodFor } from '../subscriptions/period';
import { PendingSubscriptionPaymentError } from './payment.repository';
import { toPayment, type PaymentRow } from './payment.repository.pg';
import {
  ActiveSubscriptionPaymentError,
  type FulfillmentResult,
  type PaymentLifecycle,
  type PeriodCloseResult,
  type SettledCharge,
  type SubscriptionCheckoutInput,
  UnscopedSubscriptionPeriodError,
} from './payment-lifecycle';
import { MIN_CHARGE_PESEWAS } from './pricing';

interface SubscriptionLockRow {
  id: string;
  period_end: Date | null;
  current_period_id: string | null;
}

interface PeriodLockRow {
  id: string;
  subscription_id: string;
  user_id: string;
  status: 'open' | 'closed' | 'reversed';
  credit_pesewas_per_ride: number | null;
}

/** PostgreSQL transaction boundary for every financial state change. */
export class PgPaymentLifecycle implements PaymentLifecycle {
  constructor(private readonly pool: Pool) {}

  async createSubscriptionCheckout(input: SubscriptionCheckoutInput) {
    if (input.pricePesewas < MIN_CHARGE_PESEWAS) {
      throw new Error('Subscription price is below the provider minimum');
    }
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      await this.lockUser(client, input.userId);

      const { rows: unresolved } = await client.query<{ reference: string }>(
        `SELECT reference
           FROM payments
          WHERE user_id = $1 AND purpose = 'subscription'
            AND status IN ('pending', 'processing')
          ORDER BY created_at DESC
          LIMIT 1`,
        [input.userId],
      );
      if (unresolved[0]) throw new PendingSubscriptionPaymentError(unresolved[0].reference);

      const now = input.now ?? new Date();
      const { rows: activeRows } = await client.query<SubscriptionLockRow>(
        `SELECT id, period_end, current_period_id
           FROM subscriptions
          WHERE user_id = $1 AND status = 'active'
          LIMIT 1
          FOR UPDATE`,
        [input.userId],
      );
      let subscriptionId: string | null = null;
      const active = activeRows[0];
      if (active) {
        if (!active.period_end || active.period_end.getTime() > now.getTime()) {
          throw new ActiveSubscriptionPaymentError('An active subscription already exists');
        }
        if (!active.current_period_id) {
          throw new UnscopedSubscriptionPeriodError(
            `Subscription ${active.id} has no current period accounting row`,
          );
        }
        await this.closeOne(client, active.current_period_id);
        subscriptionId = active.id;
      } else {
        const { rows: renewable } = await client.query<{ id: string }>(
          `SELECT id
             FROM subscriptions
            WHERE user_id = $1 AND status = 'expired'
            ORDER BY period_end DESC NULLS LAST, created_at DESC
            LIMIT 1
            FOR UPDATE`,
          [input.userId],
        );
        subscriptionId = renewable[0]?.id ?? null;
      }

      const { rows: balances } = await client.query<{
        ledger_pesewas: string;
        held_pesewas: string;
      }>(
        `SELECT
           COALESCE((SELECT SUM(delta_pesewas) FROM credit_ledger WHERE user_id = $1), 0)::text
             AS ledger_pesewas,
           COALESCE((SELECT SUM(amount_pesewas) FROM credit_holds
                      WHERE user_id = $1 AND status = 'held'), 0)::text
             AS held_pesewas`,
        [input.userId],
      );
      const ledger = Number(balances[0]!.ledger_pesewas);
      const held = Number(balances[0]!.held_pesewas);
      const available = Math.max(0, ledger - held);
      const appliedCreditPesewas = Math.max(
        0,
        Math.min(available, input.pricePesewas - MIN_CHARGE_PESEWAS),
      );

      const { rows } = await client.query<PaymentRow>(
        `INSERT INTO payments (
           user_id, reference, purpose, plan, route_id, amount, currency,
           rides_granted, fare_pesewas, credit_pesewas_per_ride,
           applied_credit_pesewas, pickup_stop_id, dropoff_stop_id, subscription_id
         ) VALUES ($1, $2, 'subscription', $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
         RETURNING *`,
        [
          input.userId,
          input.reference,
          input.plan,
          input.routeId ?? null,
          input.pricePesewas - appliedCreditPesewas,
          input.currency,
          input.ridesGranted ?? null,
          input.farePesewas ?? null,
          input.creditPesewasPerRide ?? null,
          appliedCreditPesewas,
          input.pickupStopId ?? null,
          input.dropoffStopId ?? null,
          subscriptionId,
        ],
      );
      const payment = toPayment(rows[0]!);
      if (appliedCreditPesewas > 0) {
        await client.query(
          `INSERT INTO credit_holds (payment_id, user_id, amount_pesewas)
           VALUES ($1, $2, $3)`,
          [payment.id, payment.userId, appliedCreditPesewas],
        );
      }
      await client.query('COMMIT');
      return payment;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async fulfillSubscriptionCharge(charge: SettledCharge): Promise<FulfillmentResult> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      const { rows } = await client.query<PaymentRow>(
        `SELECT * FROM payments WHERE reference = $1 FOR UPDATE`,
        [charge.reference],
      );
      const payment = rows[0] ? toPayment(rows[0]) : null;
      if (!payment) {
        await client.query('ROLLBACK');
        return 'not_pending';
      }
      await this.lockUser(client, payment.userId);
      if (payment.status === 'fulfilled' || payment.status === 'paid') {
        await client.query('ROLLBACK');
        return 'already_fulfilled';
      }
      if (payment.status !== 'pending') {
        await client.query('ROLLBACK');
        return 'not_pending';
      }
      if (
        payment.purpose !== 'subscription' ||
        !payment.plan ||
        charge.status !== 'success' ||
        charge.amountPesewas !== payment.amount ||
        charge.currency.toUpperCase() !== payment.currency.toUpperCase()
      ) {
        await client.query('ROLLBACK');
        return 'mismatch';
      }

      await client.query(
        `UPDATE payments
            SET status = 'processing', processing_started_at = now(), updated_at = now()
          WHERE id = $1`,
        [payment.id],
      );

      const { rows: holds } = await client.query<{
        id: string;
        amount_pesewas: number;
        status: 'held' | 'captured' | 'released';
      }>(`SELECT id, amount_pesewas, status FROM credit_holds WHERE payment_id = $1 FOR UPDATE`, [
        payment.id,
      ]);
      const hold = holds[0];
      if (payment.appliedCreditPesewas > 0) {
        if (
          !hold ||
          hold.status !== 'held' ||
          hold.amount_pesewas !== payment.appliedCreditPesewas
        ) {
          throw new Error('Payment credit hold does not match its applied credit');
        }
        const { rows: balances } = await client.query<{ balance: string }>(
          `SELECT COALESCE(SUM(delta_pesewas), 0)::text AS balance
             FROM credit_ledger WHERE user_id = $1`,
          [payment.userId],
        );
        if (Number(balances[0]!.balance) < hold.amount_pesewas) {
          throw new Error('Reserved Ride Credit is no longer available');
        }
      } else if (hold) {
        throw new Error('Zero-credit payment unexpectedly has a credit hold');
      }

      const period = periodFor(payment.plan, charge.paidAt);
      let subscriptionId = payment.subscriptionId;
      if (subscriptionId) {
        const { rows: target } = await client.query<{ id: string; status: string }>(
          `SELECT id, status FROM subscriptions WHERE id = $1 FOR UPDATE`,
          [subscriptionId],
        );
        if (!target[0]) throw new Error('Renewal subscription no longer exists');
        if (target[0].status === 'active') {
          throw new ActiveSubscriptionPaymentError('Renewal target already has an active period');
        }
      } else {
        const { rows: created } = await client.query<{ id: string }>(
          `INSERT INTO subscriptions (
             user_id, plan, route_id, pickup_stop_id, dropoff_stop_id,
             price_pesewas, rides_granted, fare_pesewas, credit_pesewas_per_ride,
             period_start, period_end
           ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
           RETURNING id`,
          [
            payment.userId,
            payment.plan,
            payment.routeId,
            payment.pickupStopId,
            payment.dropoffStopId,
            payment.amount + payment.appliedCreditPesewas,
            payment.ridesGranted,
            payment.farePesewas,
            payment.creditPesewasPerRide,
            period.start,
            period.end,
          ],
        );
        subscriptionId = created[0]!.id;
      }

      const { rows: periodRows } = await client.query<{ id: string }>(
        `INSERT INTO subscription_periods (
           subscription_id, payment_id, plan, route_id, pickup_stop_id, dropoff_stop_id,
           period_start, period_end, price_pesewas, cash_pesewas,
           applied_credit_pesewas, rides_granted, fare_pesewas, credit_pesewas_per_ride
         ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
         RETURNING id`,
        [
          subscriptionId,
          payment.id,
          payment.plan,
          payment.routeId,
          payment.pickupStopId,
          payment.dropoffStopId,
          period.start,
          period.end,
          payment.amount + payment.appliedCreditPesewas,
          payment.amount,
          payment.appliedCreditPesewas,
          payment.ridesGranted,
          payment.farePesewas,
          payment.creditPesewasPerRide,
        ],
      );
      const periodId = periodRows[0]!.id;
      await client.query(
        `UPDATE subscriptions
            SET plan = $2, status = 'active', route_id = $3,
                pickup_stop_id = $4, dropoff_stop_id = $5,
                price_pesewas = $6, rides_granted = $7, fare_pesewas = $8,
                credit_pesewas_per_ride = $9, period_start = $10,
                period_end = $11, current_period_id = $12
          WHERE id = $1`,
        [
          subscriptionId,
          payment.plan,
          payment.routeId,
          payment.pickupStopId,
          payment.dropoffStopId,
          payment.amount + payment.appliedCreditPesewas,
          payment.ridesGranted,
          payment.farePesewas,
          payment.creditPesewasPerRide,
          period.start,
          period.end,
          periodId,
        ],
      );

      if (hold) {
        await client.query(
          `INSERT INTO credit_ledger (
             user_id, delta_pesewas, reason, ref_type, ref_id, idempotency_key
           ) VALUES ($1, $2, 'renewal_applied', 'payment', $3, $4)`,
          [payment.userId, -hold.amount_pesewas, payment.reference, `renewal:${payment.reference}`],
        );
        await client.query(
          `UPDATE credit_holds SET status = 'captured', captured_at = now() WHERE id = $1`,
          [hold.id],
        );
      }
      await client.query(
        `INSERT INTO entitlement_ledger (
           user_id, delta_rides, reason, ref_type, ref_id, idempotency_key,
           subscription_period_id
         ) VALUES ($1, $2, 'allocation', 'payment', $3, $4, $5)`,
        [
          payment.userId,
          payment.ridesGranted ?? 0,
          payment.reference,
          `alloc:${payment.reference}`,
          periodId,
        ],
      );
      await client.query(
        `UPDATE payments
            SET status = 'fulfilled', subscription_id = $2, subscription_period_id = $3,
                provider_transaction_id = $4::bigint, provider_domain = $5, channel = $6,
                fees_pesewas = $7, paid_at = $8, fulfilled_at = now(), updated_at = now()
          WHERE id = $1`,
        [
          payment.id,
          subscriptionId,
          periodId,
          charge.providerTransactionId,
          charge.providerDomain,
          charge.channel,
          charge.feesPesewas,
          charge.paidAt,
        ],
      );
      await client.query('COMMIT');
      return 'fulfilled';
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async closeEndedPeriods(now: Date = new Date()): Promise<PeriodCloseResult> {
    const { rows: due } = await this.pool.query<{
      period_id: string;
      user_id: string;
    }>(
      `SELECT p.id AS period_id, s.user_id
         FROM subscription_periods p
         JOIN subscriptions s ON s.id = p.subscription_id
        WHERE p.status = 'open' AND p.period_end <= $1 AND s.status = 'active'
        ORDER BY p.period_end`,
      [now],
    );
    const totals: PeriodCloseResult = {
      considered: due.length,
      closed: 0,
      riders: 0,
      ridesConverted: 0,
      creditPesewas: 0,
    };
    for (const item of due) {
      const client = await this.pool.connect();
      try {
        await client.query('BEGIN');
        await this.lockUser(client, item.user_id);
        const result = await this.closeOne(client, item.period_id);
        await client.query('COMMIT');
        if (result.closed) {
          totals.closed++;
          if (result.rides > 0) totals.riders++;
          totals.ridesConverted += result.rides;
          totals.creditPesewas += result.credit;
        }
      } catch (err) {
        await client.query('ROLLBACK');
        throw err;
      } finally {
        client.release();
      }
    }
    return totals;
  }

  private async closeOne(
    client: PoolClient,
    periodId: string,
  ): Promise<{ closed: boolean; rides: number; credit: number }> {
    const { rows } = await client.query<PeriodLockRow>(
      `SELECT p.id, p.subscription_id, s.user_id, p.status, p.credit_pesewas_per_ride
         FROM subscription_periods p
         JOIN subscriptions s ON s.id = p.subscription_id
        WHERE p.id = $1
        FOR UPDATE OF p, s`,
      [periodId],
    );
    const period = rows[0];
    if (!period) throw new UnscopedSubscriptionPeriodError(`Period ${periodId} does not exist`);
    if (period.status !== 'open') return { closed: false, rides: 0, credit: 0 };
    const { rows: balances } = await client.query<{ rides: number }>(
      `SELECT COALESCE(SUM(delta_rides), 0)::int AS rides
         FROM entitlement_ledger
        WHERE subscription_period_id = $1`,
      [period.id],
    );
    const remaining = Math.max(0, balances[0]!.rides);
    if (remaining > 0 && period.credit_pesewas_per_ride === null) {
      throw new UnscopedSubscriptionPeriodError(
        `Period ${period.id} has rides but no frozen conversion rate`,
      );
    }
    const credit = remaining * (period.credit_pesewas_per_ride ?? 0);
    if (remaining > 0) {
      await client.query(
        `INSERT INTO credit_ledger (
           user_id, delta_pesewas, reason, ref_type, ref_id, idempotency_key
         ) VALUES ($1, $2, 'month_end_conversion', 'period', $3, $4)
         ON CONFLICT (idempotency_key) DO NOTHING`,
        [period.user_id, credit, period.id, `close-credit:${period.id}`],
      );
      await client.query(
        `INSERT INTO entitlement_ledger (
           user_id, delta_rides, reason, ref_type, ref_id, idempotency_key,
           subscription_period_id
         ) VALUES ($1, $2, 'converted', 'period', $3, $4, $5)
         ON CONFLICT (idempotency_key) DO NOTHING`,
        [period.user_id, -remaining, period.id, `close-rides:${period.id}`, period.id],
      );
    }
    await client.query(
      `UPDATE subscription_periods
          SET status = 'closed', rides_converted = $2, credit_granted_pesewas = $3,
              closed_at = now()
        WHERE id = $1`,
      [period.id, remaining, credit],
    );
    await client.query(
      `UPDATE subscriptions SET status = 'expired'
        WHERE id = $1 AND current_period_id = $2 AND status = 'active'`,
      [period.subscription_id, period.id],
    );
    return { closed: true, rides: remaining, credit };
  }

  private async lockUser(client: PoolClient, userId: string): Promise<void> {
    await client.query(`SELECT pg_advisory_xact_lock(hashtextextended($1, 0))`, [userId]);
  }
}
