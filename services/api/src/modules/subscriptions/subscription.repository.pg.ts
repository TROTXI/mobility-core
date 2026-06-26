import type { Pool } from 'pg';
import type {
  NewSubscription,
  Subscription,
  SubscriptionRepository,
} from './subscription.repository';

interface SubscriptionRow {
  id: string;
  user_id: string;
  plan: string;
  status: string;
  created_at: Date;
}

function toSubscription(row: SubscriptionRow): Subscription {
  return {
    id: row.id,
    userId: row.user_id,
    plan: row.plan,
    status: row.status,
    createdAt: row.created_at,
  };
}

export class PgSubscriptionRepository implements SubscriptionRepository {
  constructor(private readonly pool: Pool) {}

  /** Creates a new subscription for a user with the given plan. Status defaults to 'active'. */
  async create(input: NewSubscription): Promise<Subscription> {
    const { rows } = await this.pool.query<SubscriptionRow>(
      `INSERT INTO subscriptions (user_id, plan)
       VALUES ($1, $2)
       RETURNING *`,
      [input.userId, input.plan],
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
}
