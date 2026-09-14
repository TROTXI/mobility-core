import type { Pool } from 'pg';
import type {
  CurrentSubscription,
  NewSubscription,
  Subscription,
  SubscriptionRepository,
} from './subscription.repository';

import type { SubscriptionPlan, SubscriptionStatus } from './subscription.repository';

interface SubscriptionRow {
  id: string;
  user_id: string;
  plan: SubscriptionPlan;
  status: SubscriptionStatus;
  route_id: string | null;
  pickup_stop_id: string | null;
  dropoff_stop_id: string | null;
  price_pesewas: number | null;
  rides_granted: number | null;
  fare_pesewas: number | null;
  credit_pesewas_per_ride: number | null;
  period_start: Date | null;
  period_end: Date | null;
  current_period_id: string | null;
  created_at: Date;
}

interface CurrentSubscriptionRow extends SubscriptionRow {
  paused: boolean;
}

function toSubscription(row: SubscriptionRow): Subscription {
  return {
    id: row.id,
    userId: row.user_id,
    plan: row.plan,
    status: row.status,
    routeId: row.route_id,
    pickupStopId: row.pickup_stop_id,
    dropoffStopId: row.dropoff_stop_id,
    pricePesewas: row.price_pesewas,
    ridesGranted: row.rides_granted,
    farePesewas: row.fare_pesewas,
    creditPesewasPerRide: row.credit_pesewas_per_ride,
    periodStart: row.period_start,
    periodEnd: row.period_end,
    currentPeriodId: row.current_period_id,
    createdAt: row.created_at,
  };
}

export class PgSubscriptionRepository implements SubscriptionRepository {
  constructor(private readonly pool: Pool) {}

  /** Creates a new subscription for a user with the given plan + route. Status defaults to 'active'. */
  async create(input: NewSubscription): Promise<Subscription> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `INSERT INTO subscriptions (user_id, plan, route_id,
                                  price_pesewas, rides_granted, fare_pesewas, credit_pesewas_per_ride,
                                  period_start, period_end, pickup_stop_id, dropoff_stop_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING *`,
      [
        input.userId,
        input.plan,
        input.routeId ?? null,
        input.pricePesewas ?? null,
        input.ridesGranted ?? null,
        input.farePesewas ?? null,
        input.creditPesewasPerRide ?? null,
        input.periodStart ?? null,
        input.periodEnd ?? null,
        input.pickupStopId ?? null,
        input.dropoffStopId ?? null,
      ],
    );
    return toSubscription(rows[0]!);
  }

  /** Returns the active subscription for the given user, or null if none exists. A unique index guarantees at most one active subscription per user. */
  async findActiveByUser(userId: string): Promise<Subscription | null> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `SELECT * FROM subscriptions s WHERE user_id = $1 AND status = 'active'
       AND NOT EXISTS (SELECT 1 FROM subscription_pauses p WHERE p.subscription_id=s.id AND p.resumed_at IS NULL) LIMIT 1`,
      [userId],
    );
    return rows[0] ? toSubscription(rows[0]) : null;
  }

  /** Current rider-facing membership, including suspended and voluntarily paused states. */
  async findCurrentByUser(userId: string): Promise<CurrentSubscription | null> {
    const { rows } = await this.pool.query<CurrentSubscriptionRow>(
      `SELECT s.*,
              EXISTS (
                SELECT 1 FROM subscription_pauses p
                 WHERE p.subscription_id = s.id AND p.resumed_at IS NULL
              ) AS paused
         FROM subscriptions s
        WHERE s.user_id = $1 AND s.status IN ('active', 'suspended')
        LIMIT 1`,
      [userId],
    );
    if (!rows[0]) return null;
    const subscription = toSubscription(rows[0]);
    if (subscription.status !== 'active' && subscription.status !== 'suspended') return null;
    return { ...subscription, status: subscription.status, paused: rows[0].paused };
  }

  /** Active subscriptions pinned to a route (E3 ask-dispatch targets). */
  async findActiveByRoute(routeId: string, scheduledAt?: Date): Promise<Subscription[]> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `SELECT * FROM subscriptions s WHERE route_id = $1 AND status = 'active'
       AND NOT EXISTS (SELECT 1 FROM subscription_pauses p WHERE p.subscription_id=s.id AND p.resumed_at IS NULL)
       AND ($2::timestamptz IS NULL OR NOT EXISTS (
         SELECT 1 FROM commute_slots c WHERE c.subscription_id=s.id AND c.status='allocated'
         AND to_char($2::timestamptz AT TIME ZONE 'Africa/Accra','HH24:MI') <>
           CASE WHEN EXTRACT(HOUR FROM $2::timestamptz AT TIME ZONE 'Africa/Accra') < 12
             THEN c.morning_departure ELSE c.evening_return END
       ))`,
      [routeId, scheduledAt ?? null],
    );
    return rows.map(toSubscription);
  }

  /** Every active subscription (E5 month-end credit conversion iterates these). */
  async findAllActive(): Promise<Subscription[]> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `SELECT * FROM subscriptions s WHERE status = 'active'
       AND NOT EXISTS (SELECT 1 FROM subscription_pauses p WHERE p.subscription_id=s.id AND p.resumed_at IS NULL)`,
    );
    return rows.map(toSubscription);
  }

  async findEndedPeriods(now: Date): Promise<Subscription[]> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `SELECT * FROM subscriptions s
        WHERE status = 'active' AND period_end IS NOT NULL AND period_end <= $1
        AND NOT EXISTS (SELECT 1 FROM subscription_pauses p WHERE p.subscription_id=s.id AND p.resumed_at IS NULL)
        ORDER BY period_end ASC`,
      [now],
    );
    return rows.map(toSubscription);
  }

  async rollPeriod(
    id: string,
    patch: { periodStart: Date; periodEnd: Date } | { status: 'expired' },
  ): Promise<Subscription | null> {
    const { rows } =
      'status' in patch
        ? await this.pool.query<SubscriptionRow>(
            `UPDATE subscriptions SET status = 'expired' WHERE id = $1 RETURNING *`,
            [id],
          )
        : await this.pool.query<SubscriptionRow>(
            `UPDATE subscriptions SET period_start = $2, period_end = $3 WHERE id = $1 RETURNING *`,
            [id, patch.periodStart, patch.periodEnd],
          );
    return rows[0] ? toSubscription(rows[0]) : null;
  }

  async activatePeriod(
    id: string,
    input: NewSubscription & { currentPeriodId: string },
  ): Promise<Subscription | null> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `UPDATE subscriptions
          SET plan = $2, status = 'active', route_id = $3,
              pickup_stop_id = $4, dropoff_stop_id = $5,
              price_pesewas = $6, rides_granted = $7, fare_pesewas = $8,
              credit_pesewas_per_ride = $9, period_start = $10,
              period_end = $11, current_period_id = $12
        WHERE id = $1
        RETURNING *`,
      [
        id,
        input.plan,
        input.routeId ?? null,
        input.pickupStopId ?? null,
        input.dropoffStopId ?? null,
        input.pricePesewas ?? null,
        input.ridesGranted ?? null,
        input.farePesewas ?? null,
        input.creditPesewasPerRide ?? null,
        input.periodStart ?? null,
        input.periodEnd ?? null,
        input.currentPeriodId,
      ],
    );
    return rows[0] ? toSubscription(rows[0]) : null;
  }
}
