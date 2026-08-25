import type { Pool } from 'pg';
import type {
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
  price_pesewas: number | null;
  rides_granted: number | null;
  fare_pesewas: number | null;
  credit_pesewas_per_ride: number | null;
  created_at: Date;
}

function toSubscription(row: SubscriptionRow): Subscription {
  return {
    id: row.id,
    userId: row.user_id,
    plan: row.plan,
    status: row.status,
    routeId: row.route_id,
    pricePesewas: row.price_pesewas,
    ridesGranted: row.rides_granted,
    farePesewas: row.fare_pesewas,
    creditPesewasPerRide: row.credit_pesewas_per_ride,
    createdAt: row.created_at,
  };
}

export class PgSubscriptionRepository implements SubscriptionRepository {
  constructor(private readonly pool: Pool) {}

  /** Creates a new subscription for a user with the given plan + route. Status defaults to 'active'. */
  async create(input: NewSubscription): Promise<Subscription> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `INSERT INTO subscriptions (user_id, plan, route_id,
                                  price_pesewas, rides_granted, fare_pesewas, credit_pesewas_per_ride)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        input.userId,
        input.plan,
        input.routeId ?? null,
        input.pricePesewas ?? null,
        input.ridesGranted ?? null,
        input.farePesewas ?? null,
        input.creditPesewasPerRide ?? null,
      ],
    );
    return toSubscription(rows[0]!);
  }

  /** Returns the active subscription for the given user, or null if none exists. A unique index guarantees at most one active subscription per user. */
  async findActiveByUser(userId: string): Promise<Subscription | null> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `SELECT * FROM subscriptions WHERE user_id = $1 AND status = 'active' LIMIT 1`,
      [userId],
    );
    return rows[0] ? toSubscription(rows[0]) : null;
  }

  /** Active subscriptions pinned to a route (E3 ask-dispatch targets). */
  async findActiveByRoute(routeId: string): Promise<Subscription[]> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `SELECT * FROM subscriptions WHERE route_id = $1 AND status = 'active'`,
      [routeId],
    );
    return rows.map(toSubscription);
  }

  /** Every active subscription (E5 month-end credit conversion iterates these). */
  async findAllActive(): Promise<Subscription[]> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `SELECT * FROM subscriptions WHERE status = 'active'`,
    );
    return rows.map(toSubscription);
  }
}
