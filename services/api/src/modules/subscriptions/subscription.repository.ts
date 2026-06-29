export type SubscriptionPlan = 'monthly' | 'annual';
export type SubscriptionStatus = 'active' | 'cancelled' | 'expired';

/** A user's platform membership. */
export interface Subscription {
  id: string;
  userId: string;
  plan: SubscriptionPlan;
  status: SubscriptionStatus;
  createdAt: Date;
}

/** Fields needed to create a subscription. */
export interface NewSubscription {
  userId: string;
  plan: SubscriptionPlan;
}

/** Persistence for memberships; one active subscription per user. */
export interface SubscriptionRepository {
  /**
   * Create a subscription (active).
   *
   * @param input - the user and plan to subscribe.
   * @returns the persisted subscription.
   * @throws on a unique-violation if the user already has an active subscription.
   */
  create(input: NewSubscription): Promise<Subscription>;
  /**
   * Find a user's active subscription, if any.
   *
   * @param userId - the user to check.
   * @returns the active subscription, or null.
   */
  findActiveByUser(userId: string): Promise<Subscription | null>;
}

/** In-memory {@link SubscriptionRepository} for dev and unit tests. */
export class InMemorySubscriptionRepository implements SubscriptionRepository {
  private readonly subscriptions = new Map<string, Subscription>();

  async create(input: NewSubscription): Promise<Subscription> {
    const subscription: Subscription = {
      id: crypto.randomUUID(),
      userId: input.userId,
      plan: input.plan,
      status: 'active',
      createdAt: new Date(),
    };
    this.subscriptions.set(subscription.id, subscription);
    return subscription;
  }

  async findActiveByUser(userId: string): Promise<Subscription | null> {
    for (const subscription of this.subscriptions.values()) {
      if (subscription.userId === userId && subscription.status === 'active') {
        return subscription;
      }
    }
    return null;
  }
}
