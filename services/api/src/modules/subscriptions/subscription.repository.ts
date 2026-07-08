export type SubscriptionPlan = 'monthly' | 'annual';
export type SubscriptionStatus = 'active' | 'cancelled' | 'expired';

/** A user's platform membership. */
export interface Subscription {
  id: string;
  userId: string;
  plan: SubscriptionPlan;
  status: SubscriptionStatus;
  /** The rider's pinned route/corridor (E3); null for pre-E3 subscriptions. */
  routeId: string | null;
  createdAt: Date;
}

/** Fields needed to create a subscription. */
export interface NewSubscription {
  userId: string;
  plan: SubscriptionPlan;
  routeId?: string | null;
}

/** Persistence for memberships; one active subscription per user. */
export interface SubscriptionRepository {
  /**
   * Create a subscription (active).
   *
   * @param input - the user, plan, and pinned route.
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
  /**
   * Active subscriptions pinned to a route — who the ask-dispatch prompts for
   * that route's trips (E3).
   *
   * @param routeId - the route/corridor.
   * @returns the active subscriptions on that route.
   */
  findActiveByRoute(routeId: string): Promise<Subscription[]>;
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
      routeId: input.routeId ?? null,
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

  async findActiveByRoute(routeId: string): Promise<Subscription[]> {
    return Array.from(this.subscriptions.values()).filter(
      (s) => s.status === 'active' && s.routeId === routeId,
    );
  }
}
