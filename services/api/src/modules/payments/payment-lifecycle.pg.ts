import type { Pool, PoolClient } from 'pg';
import { periodFor } from '../subscriptions/period';
import { PendingSubscriptionPaymentError } from './payment.repository';
import { toPayment, type PaymentRow } from './payment.repository.pg';
import {
  ActiveSubscriptionPaymentError,
  type FulfillmentResult,
  type PaymentLifecycle,
  type PaymentOperationsReview,
  type PeriodCloseResult,
  PeriodCloseBlockedError,
  type ProviderDispute,
  type ProviderRefund,
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
  status: 'open' | 'frozen' | 'closed' | 'reversed';
  credit_pesewas_per_ride: number | null;
  credit_granted_pesewas: number | null;
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
      const paused = await client.query(
        `SELECT 1 FROM subscription_pauses p JOIN subscriptions s ON s.id=p.subscription_id WHERE s.user_id=$1 AND p.resumed_at IS NULL`,
        [input.userId],
      );
      if (paused.rowCount)
        throw new ActiveSubscriptionPaymentError(
          'Resume the paused subscription before starting another checkout',
        );
      const { rows: activeRows } = await client.query<SubscriptionLockRow>(
        `SELECT id, period_end, current_period_id
           FROM subscriptions
          WHERE user_id = $1 AND status IN ('active', 'suspended')
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
        const close = await this.closeOne(client, active.current_period_id);
        if (close.blocked) {
          throw new PeriodCloseBlockedError(
            'The ended period still has reservations awaiting boarding or no-show settlement',
          );
        }
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
           user_id, reference, purpose, plan, route_id, amount, gross_amount_pesewas, currency,
           rides_granted, fare_pesewas, credit_pesewas_per_ride,
           applied_credit_pesewas, pickup_stop_id, dropoff_stop_id, subscription_id
         ) VALUES ($1, $2, 'subscription', $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
         RETURNING *`,
        [
          input.userId,
          input.reference,
          input.plan,
          input.routeId ?? null,
          input.pricePesewas - appliedCreditPesewas,
          input.pricePesewas,
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

  async failPendingPayment(reference: string, code: string, message: string): Promise<boolean> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      const { rows } = await client.query<{ id: string; user_id: string; status: string }>(
        `SELECT id, user_id, status FROM payments WHERE reference = $1 FOR UPDATE`,
        [reference],
      );
      const payment = rows[0];
      if (!payment || !['pending', 'processing'].includes(payment.status)) {
        await client.query('ROLLBACK');
        return false;
      }
      await this.lockUser(client, payment.user_id);
      await client.query(
        `UPDATE credit_holds
            SET status = 'released', released_at = now()
          WHERE payment_id = $1 AND status = 'held'`,
        [payment.id],
      );
      await client.query(
        `UPDATE payments
            SET status = 'failed', failure_code = $2, failure_message = $3, updated_at = now()
          WHERE id = $1`,
        [payment.id, code, message.slice(0, 2_000)],
      );
      await client.query('COMMIT');
      return true;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async recordRefund(refund: ProviderRefund): Promise<boolean> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      const { rows } = await client.query<PaymentRow>(
        `SELECT * FROM payments WHERE reference = $1 FOR UPDATE`,
        [refund.reference],
      );
      const payment = rows[0] ? toPayment(rows[0]) : null;
      if (!payment) {
        await client.query('ROLLBACK');
        return false;
      }
      await this.lockUser(client, payment.userId);
      if (
        refund.amountPesewas <= 0 ||
        refund.amountPesewas > payment.amount ||
        refund.currency.toUpperCase() !== payment.currency.toUpperCase() ||
        (payment.providerDomain !== null && payment.providerDomain !== refund.providerDomain)
      ) {
        await client.query('ROLLBACK');
        return false;
      }
      if (refund.status === 'processed' && !refund.refundReference) {
        throw new Error('Processed Paystack refund has no refund_reference');
      }
      const refundKey = refund.refundReference ?? `event:${refund.eventKey}`;
      await client.query(
        `INSERT INTO payment_refunds (
           payment_id, provider_refund_reference, amount_pesewas, status, payload, processed_at
         ) VALUES ($1, $2, $3, $4, $5::jsonb,
                   CASE WHEN $4 = 'processed' THEN now() ELSE NULL END)
         ON CONFLICT (payment_id, provider_refund_reference) DO UPDATE
           SET amount_pesewas = CASE
                 WHEN CASE payment_refunds.status
                        WHEN 'pending' THEN 0 WHEN 'processing' THEN 1
                        WHEN 'needs_attention' THEN 2 WHEN 'failed' THEN 3 ELSE 4
                      END >=
                      CASE EXCLUDED.status
                        WHEN 'pending' THEN 0 WHEN 'processing' THEN 1
                        WHEN 'needs_attention' THEN 2 WHEN 'failed' THEN 3 ELSE 4
                      END
                 THEN payment_refunds.amount_pesewas ELSE EXCLUDED.amount_pesewas
               END,
               status = CASE
                 WHEN CASE payment_refunds.status
                        WHEN 'pending' THEN 0 WHEN 'processing' THEN 1
                        WHEN 'needs_attention' THEN 2 WHEN 'failed' THEN 3 ELSE 4
                      END >=
                      CASE EXCLUDED.status
                        WHEN 'pending' THEN 0 WHEN 'processing' THEN 1
                        WHEN 'needs_attention' THEN 2 WHEN 'failed' THEN 3 ELSE 4
                      END
                 THEN payment_refunds.status ELSE EXCLUDED.status
               END,
               payload = CASE
                 WHEN CASE payment_refunds.status
                        WHEN 'pending' THEN 0 WHEN 'processing' THEN 1
                        WHEN 'needs_attention' THEN 2 WHEN 'failed' THEN 3 ELSE 4
                      END >=
                      CASE EXCLUDED.status
                        WHEN 'pending' THEN 0 WHEN 'processing' THEN 1
                        WHEN 'needs_attention' THEN 2 WHEN 'failed' THEN 3 ELSE 4
                      END
                 THEN payment_refunds.payload ELSE EXCLUDED.payload
               END,
               processed_at = CASE
                 WHEN EXCLUDED.status = 'processed' THEN COALESCE(payment_refunds.processed_at, now())
                 ELSE payment_refunds.processed_at
               END,
               updated_at = now()`,
        [
          payment.id,
          refundKey,
          refund.amountPesewas,
          refund.status,
          JSON.stringify(refund.payload),
        ],
      );
      const { rows: totals } = await client.query<{ refunded: string }>(
        `SELECT COALESCE(SUM(amount_pesewas), 0)::text AS refunded
           FROM payment_refunds
          WHERE payment_id = $1 AND status = 'processed'`,
        [payment.id],
      );
      const refunded = Number(totals[0]!.refunded);
      if (refunded > payment.amount) throw new Error('Processed refunds exceed the cash payment');
      await client.query(
        `UPDATE payments
            SET refunded_pesewas = $2,
                status = CASE WHEN $2 = amount THEN 'refunded' ELSE status END,
                updated_at = now()
          WHERE id = $1`,
        [payment.id, refunded],
      );

      if (refunded === payment.amount && payment.subscriptionPeriodId) {
        const { rows: periods } = await client.query<PeriodLockRow>(
          `SELECT p.id, p.subscription_id, s.user_id, p.status,
                  p.credit_pesewas_per_ride, p.credit_granted_pesewas
             FROM subscription_periods p
             JOIN subscriptions s ON s.id = p.subscription_id
            WHERE p.id = $1
            FOR UPDATE OF p, s`,
          [payment.subscriptionPeriodId],
        );
        const period = periods[0];
        if (period && period.status !== 'reversed') {
          const { rows: balances } = await client.query<{
            remaining: number;
            consumed: number;
          }>(
            `SELECT COALESCE(SUM(delta_rides), 0)::int AS remaining,
                    GREATEST(0,
                      -COALESCE(SUM(delta_rides) FILTER (
                        WHERE reason IN ('boarding', 'no_show')
                      ), 0)
                      -COALESCE(SUM(delta_rides) FILTER (
                        WHERE reason = 'returned'
                      ), 0)
                    )::int AS consumed
               FROM entitlement_ledger WHERE subscription_period_id = $1`,
            [period.id],
          );
          const remaining = Math.max(0, balances[0]!.remaining);
          const granted = Math.max(0, payment.ridesGranted ?? 0);
          const consumed = balances[0]!.consumed;
          const conversionCredit = Math.max(0, period.credit_granted_pesewas ?? 0);
          const { rows: creditRows } = await client.query<{
            ledger_pesewas: string;
            held_pesewas: string;
          }>(
            `SELECT
               COALESCE((SELECT SUM(delta_pesewas) FROM credit_ledger
                          WHERE user_id = $1), 0)::text AS ledger_pesewas,
               COALESCE((SELECT SUM(amount_pesewas) FROM credit_holds
                          WHERE user_id = $1 AND status = 'held'), 0)::text AS held_pesewas`,
            [payment.userId],
          );
          const availableCredit = Math.max(
            0,
            Number(creditRows[0]!.ledger_pesewas) - Number(creditRows[0]!.held_pesewas),
          );
          const recoveredConversionCredit = Math.min(conversionCredit, availableCredit);
          const unrecoveredConversionCredit = conversionCredit - recoveredConversionCredit;
          if (recoveredConversionCredit > 0) {
            await client.query(
              `INSERT INTO credit_ledger (
                 user_id, delta_pesewas, reason, ref_type, ref_id, idempotency_key
               ) VALUES ($1, $2, 'refund', 'payment', $3, $4)
               ON CONFLICT (idempotency_key) DO NOTHING`,
              [
                payment.userId,
                -recoveredConversionCredit,
                payment.reference,
                `refund-conversion-credit:${payment.reference}`,
              ],
            );
          }
          if (consumed > 0 || unrecoveredConversionCredit > 0) {
            const rideDebtPesewas =
              consumed > 0
                ? Math.max(
                    1,
                    granted > 0
                      ? Math.round((payment.grossAmountPesewas * consumed) / granted)
                      : payment.grossAmountPesewas,
                  )
                : 0;
            const estimatedDebtPesewas = rideDebtPesewas + unrecoveredConversionCredit;
            await client.query(
              `INSERT INTO payment_reversal_reviews (
                 payment_id, subscription_period_id, reason, consumed_rides,
                 unrecovered_credit_pesewas, estimated_debt_pesewas
               ) VALUES ($1, $2, 'consumed_value_after_refund', $3, $4, $5)
               ON CONFLICT (payment_id, reason) DO UPDATE
                 SET consumed_rides = EXCLUDED.consumed_rides,
                     unrecovered_credit_pesewas = EXCLUDED.unrecovered_credit_pesewas,
                     estimated_debt_pesewas = EXCLUDED.estimated_debt_pesewas,
                     updated_at = now()
               WHERE payment_reversal_reviews.status = 'open'`,
              [payment.id, period.id, consumed, unrecoveredConversionCredit, estimatedDebtPesewas],
            );
          }
          if (remaining > 0) {
            await client.query(
              `INSERT INTO entitlement_ledger (
                 user_id, delta_rides, reason, ref_type, ref_id, idempotency_key,
                 subscription_period_id
               ) VALUES ($1, $2, 'refund', 'payment', $3, $4, $5)
               ON CONFLICT (idempotency_key) DO NOTHING`,
              [
                payment.userId,
                -remaining,
                payment.reference,
                `refund-rides:${payment.reference}`,
                period.id,
              ],
            );
          }
          if (payment.appliedCreditPesewas > 0) {
            await client.query(
              `INSERT INTO credit_ledger (
                 user_id, delta_pesewas, reason, ref_type, ref_id, idempotency_key
               ) VALUES ($1, $2, 'refund', 'payment', $3, $4)
               ON CONFLICT (idempotency_key) DO NOTHING`,
              [
                payment.userId,
                payment.appliedCreditPesewas,
                payment.reference,
                `refund-credit:${payment.reference}`,
              ],
            );
          }
          await client.query(
            `UPDATE subscription_periods
                SET status = 'reversed', closed_at = COALESCE(closed_at, now())
              WHERE id = $1`,
            [period.id],
          );
          await client.query(
            `UPDATE subscriptions SET status = 'expired'
              WHERE id = $1 AND current_period_id = $2
                AND status IN ('active', 'suspended')`,
            [period.subscription_id, period.id],
          );
          // A refunded period has no paid time left to preserve. End its
          // commute pause too, without manufacturing an extension or credit.
          await client.query(
            `UPDATE subscription_pauses SET resumed_at=now()
            WHERE period_id=$1 AND resumed_at IS NULL`,
            [period.id],
          );
        }
      } else if (refund.status === 'processed' && payment.subscriptionPeriodId) {
        const { rows: disputeTotals } = await client.query<{
          unresolved: string;
          accepted_pesewas: string;
        }>(
          `SELECT
             COUNT(*) FILTER (
               WHERE status <> 'resolved' OR resolution IS NULL
             )::text AS unresolved,
             COALESCE(SUM(amount_pesewas) FILTER (
               WHERE status = 'resolved' AND resolution = 'merchant-accepted'
             ), 0)::text AS accepted_pesewas
           FROM payment_disputes
          WHERE payment_id = $1`,
          [payment.id],
        );
        const disputes = disputeTotals[0]!;
        const accepted = Number(disputes.accepted_pesewas);
        if (Number(disputes.unresolved) === 0 && accepted > 0 && refunded >= accepted) {
          await client.query(
            `UPDATE payments SET status = 'fulfilled', updated_at = now()
              WHERE id = $1 AND status = 'disputed'`,
            [payment.id],
          );
          await client.query(
            `UPDATE subscription_periods SET status = 'open'
              WHERE id = $1 AND status = 'frozen'`,
            [payment.subscriptionPeriodId],
          );
          await client.query(
            `UPDATE subscriptions SET status = 'active'
              WHERE id = $1 AND current_period_id = $2 AND status = 'suspended'`,
            [payment.subscriptionId, payment.subscriptionPeriodId],
          );
        }
      }
      await client.query('COMMIT');
      return true;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async recordDispute(dispute: ProviderDispute): Promise<boolean> {
    const client = await this.pool.connect();
    try {
      await client.query('BEGIN');
      const { rows } = await client.query<PaymentRow>(
        `SELECT * FROM payments WHERE reference = $1 FOR UPDATE`,
        [dispute.reference],
      );
      const payment = rows[0] ? toPayment(rows[0]) : null;
      if (!payment) {
        await client.query('ROLLBACK');
        return false;
      }
      await this.lockUser(client, payment.userId);
      if (
        dispute.amountPesewas <= 0 ||
        dispute.amountPesewas > payment.amount ||
        dispute.currency.toUpperCase() !== payment.currency.toUpperCase() ||
        (payment.providerDomain !== null && payment.providerDomain !== dispute.providerDomain)
      ) {
        await client.query('ROLLBACK');
        return false;
      }
      const { rows: disputeRows } = await client.query<{
        status: 'created' | 'reminded' | 'resolved';
        resolution: string | null;
      }>(
        `INSERT INTO payment_disputes (
           payment_id, provider_dispute_id, amount_pesewas, status, resolution,
           payload, resolved_at
         ) VALUES ($1, $2::bigint, $3, $4, $5, $6::jsonb,
                   CASE WHEN $4 = 'resolved' THEN now() ELSE NULL END)
         ON CONFLICT (provider_dispute_id) DO UPDATE
           SET amount_pesewas = CASE
                 WHEN CASE payment_disputes.status
                        WHEN 'created' THEN 0 WHEN 'reminded' THEN 1 ELSE 2
                      END >=
                      CASE EXCLUDED.status
                        WHEN 'created' THEN 0 WHEN 'reminded' THEN 1 ELSE 2
                      END
                 THEN payment_disputes.amount_pesewas ELSE EXCLUDED.amount_pesewas
               END,
               status = CASE
                 WHEN CASE payment_disputes.status
                        WHEN 'created' THEN 0 WHEN 'reminded' THEN 1 ELSE 2
                      END >=
                      CASE EXCLUDED.status
                        WHEN 'created' THEN 0 WHEN 'reminded' THEN 1 ELSE 2
                      END
                 THEN payment_disputes.status ELSE EXCLUDED.status
               END,
               resolution = CASE
                 WHEN CASE payment_disputes.status
                        WHEN 'created' THEN 0 WHEN 'reminded' THEN 1 ELSE 2
                      END >=
                      CASE EXCLUDED.status
                        WHEN 'created' THEN 0 WHEN 'reminded' THEN 1 ELSE 2
                      END
                 THEN payment_disputes.resolution ELSE EXCLUDED.resolution
               END,
               payload = CASE
                 WHEN CASE payment_disputes.status
                        WHEN 'created' THEN 0 WHEN 'reminded' THEN 1 ELSE 2
                      END >=
                      CASE EXCLUDED.status
                        WHEN 'created' THEN 0 WHEN 'reminded' THEN 1 ELSE 2
                      END
                 THEN payment_disputes.payload ELSE EXCLUDED.payload
               END,
               resolved_at = CASE
                 WHEN EXCLUDED.status = 'resolved' THEN COALESCE(payment_disputes.resolved_at, now())
                 ELSE payment_disputes.resolved_at
               END,
               updated_at = now()
         RETURNING status, resolution`,
        [
          payment.id,
          dispute.providerDisputeId,
          dispute.amountPesewas,
          dispute.status,
          dispute.resolution,
          JSON.stringify(dispute.payload),
        ],
      );

      const effective = disputeRows[0]!;
      const restore = effective.status === 'resolved' && effective.resolution === 'declined';
      if (restore) {
        await client.query(
          `UPDATE payments SET status = 'fulfilled', updated_at = now()
            WHERE id = $1 AND status = 'disputed'`,
          [payment.id],
        );
        if (payment.subscriptionPeriodId) {
          await client.query(
            `UPDATE subscription_periods SET status = 'open'
              WHERE id = $1 AND status = 'frozen'`,
            [payment.subscriptionPeriodId],
          );
          await client.query(
            `UPDATE subscriptions SET status = 'active'
              WHERE id = $1 AND current_period_id = $2 AND status = 'suspended'`,
            [payment.subscriptionId, payment.subscriptionPeriodId],
          );
        }
      } else {
        await client.query(
          `UPDATE payments SET status = 'disputed', updated_at = now()
            WHERE id = $1 AND status IN ('paid', 'fulfilled', 'disputed')`,
          [payment.id],
        );
        if (payment.subscriptionPeriodId) {
          await client.query(
            `UPDATE subscription_periods SET status = 'frozen'
              WHERE id = $1 AND status = 'open'`,
            [payment.subscriptionPeriodId],
          );
          await client.query(
            `UPDATE subscriptions SET status = 'suspended'
              WHERE id = $1 AND current_period_id = $2 AND status = 'active'`,
            [payment.subscriptionId, payment.subscriptionPeriodId],
          );
        }
      }
      await client.query('COMMIT');
      return true;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async listOperationsReviews(limit = 100): Promise<PaymentOperationsReview[]> {
    const { rows } = await this.pool.query<{
      id: string;
      kind: PaymentOperationsReview['kind'];
      payment_reference: string;
      user_id: string;
      payment_status: string;
      status: string;
      amount_pesewas: number;
      resolution: string | null;
      consumed_rides: number | null;
      unrecovered_credit_pesewas: number | null;
      estimated_debt_pesewas: number | null;
      created_at: Date;
      updated_at: Date;
    }>(
      `SELECT * FROM (
         SELECT 'refund:' || r.id::text AS id, 'refund'::text AS kind,
                p.reference AS payment_reference, p.user_id, p.status AS payment_status,
                r.status, r.amount_pesewas, NULL::text AS resolution,
                NULL::integer AS consumed_rides, NULL::integer AS unrecovered_credit_pesewas,
                NULL::integer AS estimated_debt_pesewas,
                r.created_at, r.updated_at
           FROM payment_refunds r JOIN payments p ON p.id = r.payment_id
          WHERE r.status <> 'processed'
         UNION ALL
         SELECT 'dispute:' || d.id::text, 'dispute', p.reference, p.user_id, p.status,
                d.status, d.amount_pesewas, d.resolution, NULL::integer, NULL::integer,
                NULL::integer,
                d.created_at, d.updated_at
           FROM payment_disputes d JOIN payments p ON p.id = d.payment_id
          WHERE d.status <> 'resolved' OR d.resolution IS NULL
             OR (d.resolution = 'merchant-accepted' AND
                 COALESCE((SELECT SUM(r.amount_pesewas) FROM payment_refunds r
                            WHERE r.payment_id = d.payment_id AND r.status = 'processed'), 0)
                   < d.amount_pesewas)
             OR d.resolution NOT IN ('declined', 'merchant-accepted')
         UNION ALL
         SELECT 'manual:' || m.id::text, 'manual_review', p.reference, p.user_id, p.status,
                m.status, m.estimated_debt_pesewas, NULL::text, m.consumed_rides,
                m.unrecovered_credit_pesewas, m.estimated_debt_pesewas,
                m.created_at, m.updated_at
           FROM payment_reversal_reviews m JOIN payments p ON p.id = m.payment_id
          WHERE m.status = 'open'
       ) reviews
       ORDER BY updated_at DESC
       LIMIT $1`,
      [Math.max(0, Math.floor(limit))],
    );
    return rows.map((row) => ({
      id: row.id,
      kind: row.kind,
      paymentReference: row.payment_reference,
      userId: row.user_id,
      paymentStatus: row.payment_status,
      status: row.status,
      amountPesewas: row.amount_pesewas,
      resolution: row.resolution,
      consumedRides: row.consumed_rides,
      unrecoveredCreditPesewas: row.unrecovered_credit_pesewas,
      estimatedDebtPesewas: row.estimated_debt_pesewas,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    }));
  }

  async closeEndedPeriods(now: Date = new Date(), limit = 100): Promise<PeriodCloseResult> {
    const boundedLimit = Math.max(0, Math.floor(limit));
    const { rows: due } = await this.pool.query<{
      period_id: string;
      user_id: string;
    }>(
      `SELECT p.id AS period_id, s.user_id
         FROM subscription_periods p
         JOIN subscriptions s ON s.id = p.subscription_id
        WHERE p.status = 'open' AND p.period_end <= $1 AND s.status = 'active'
          AND NOT EXISTS (SELECT 1 FROM subscription_pauses pause WHERE pause.subscription_id=s.id AND pause.resumed_at IS NULL)
        ORDER BY EXISTS (
          SELECT 1 FROM reservations r
           WHERE r.subscription_period_id = p.id
             AND r.status IN ('pending', 'reserved')
        ), p.period_end
        LIMIT $2`,
      [now, boundedLimit],
    );
    const totals: PeriodCloseResult = {
      considered: due.length,
      closed: 0,
      blocked: 0,
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
        } else if (result.blocked) {
          totals.blocked++;
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
  ): Promise<{ closed: boolean; blocked: boolean; rides: number; credit: number }> {
    const { rows } = await client.query<PeriodLockRow>(
      `SELECT p.id, p.subscription_id, s.user_id, p.status,
              p.credit_pesewas_per_ride, p.credit_granted_pesewas
         FROM subscription_periods p
         JOIN subscriptions s ON s.id = p.subscription_id
        WHERE p.id = $1
        FOR UPDATE OF p, s`,
      [periodId],
    );
    const period = rows[0];
    if (!period) throw new UnscopedSubscriptionPeriodError(`Period ${periodId} does not exist`);
    if (period.status !== 'open') return { closed: false, blocked: false, rides: 0, credit: 0 };
    const paused = await client.query(
      `SELECT 1 FROM subscription_pauses WHERE subscription_id=$1 AND resumed_at IS NULL`,
      [period.subscription_id],
    );
    if (paused.rowCount) return { closed: false, blocked: true, rides: 0, credit: 0 };
    const { rows: unsettledRows } = await client.query<{ count: string }>(
      `SELECT COUNT(*)::text AS count
         FROM reservations
        WHERE subscription_period_id = $1 AND status IN ('pending', 'reserved')`,
      [period.id],
    );
    if (Number(unsettledRows[0]!.count) > 0) {
      return { closed: false, blocked: true, rides: 0, credit: 0 };
    }
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
    return { closed: true, blocked: false, rides: remaining, credit };
  }

  private async lockUser(client: PoolClient, userId: string): Promise<void> {
    await client.query(`SELECT pg_advisory_xact_lock(hashtextextended($1, 0))`, [userId]);
  }
}
