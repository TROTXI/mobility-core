export interface Subscription {
  id: string;
  userId: string;
  plan: string;
  status: string;
  createdAt: Date;
}

export interface NewSubscription {
  userId: string;
  plan: string;
}

export interface SubscriptionRepository {
  create(input: NewSubscription): Promise<Subscription>;
  findActiveByUser(userId: string): Promise<Subscription | null>;
}

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
