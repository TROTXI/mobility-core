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
  /** Where the rider boards (#204); null for subscriptions predating it. */
  pickupStopId: string | null;
  /** Where the rider alights (#204). */
  dropoffStopId: string | null;
  /** What this rider actually paid, frozen at activation (#103). */
  pricePesewas: number | null;
  /** Rides granted for the period, frozen at activation. */
  ridesGranted: number | null;
  /** The corridor fare the price was derived from — the audit trail. */
  farePesewas: number | null;
  /** Ride Credit value per unused ride, frozen at activation. */
  creditPesewasPerRide: number | null;
  /** Start of the current billing period, inclusive (#162). */
  periodStart: Date | null;
  /** End of the current period, EXCLUSIVE — drives renewal and expiry. */
  periodEnd: Date | null;
  createdAt: Date;
}

/** Fields needed to create a subscription. */
export interface NewSubscription {
  /** Where the rider boards (#204). */
  pickupStopId?: string | null;
  /** Where the rider alights (#204). */
  dropoffStopId?: string | null;
  userId: string;
  plan: SubscriptionPlan;
  routeId?: string | null;
  pricePesewas?: number | null;
  ridesGranted?: number | null;
  farePesewas?: number | null;
  creditPesewasPerRide?: number | null;
  periodStart?: Date | null;
  periodEnd?: Date | null;
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
  /**
   * Every active subscription — the month-end credit conversion job iterates
   * these to convert each rider's unused rides (E5).
   *
   * @returns all active subscriptions.
   */
  findAllActive(): Promise<Subscription[]>;
  /**
   * Active subscriptions whose period has ended (#162) — the expiry sweep's
   * input. Without it a lapsed row stays active and, via the one-active index,
   * blocks the rider from subscribing again.
   *
   * @param now - the instant to compare against.
   * @returns active subscriptions with `periodEnd <= now`.
   */
  findEndedPeriods(now: Date): Promise<Subscription[]>;
  /**
   * Move a subscription into its next period, or mark it expired.
   *
   * @param id - the subscription.
   * @param patch - the new period, or the terminal status.
   * @returns the updated subscription, or null if not found.
   */
  rollPeriod(
    id: string,
    patch: { periodStart: Date; periodEnd: Date } | { status: 'expired' },
  ): Promise<Subscription | null>;
}

/** In-memory {@link SubscriptionRepository} for dev and unit tests. */
export class InMemorySubscriptionRepository implements SubscriptionRepository {
  private readonly subscriptions = new Map<string, Subscription>();

  async create(input: NewSubscription): Promise<Subscription> {
    // Mirror the Postgres one-active-per-user partial unique index (ADR-0009:
    // in-memory repos should behave like the real adapter). A duplicate active
    // subscription throws the same SQLSTATE the service's replay-guard expects.
    if (await this.findActiveByUser(input.userId)) {
      throw Object.assign(new Error('duplicate active subscription'), { code: '23505' });
    }
    const subscription: Subscription = {
      id: crypto.randomUUID(),
      userId: input.userId,
      plan: input.plan,
      status: 'active',
      routeId: input.routeId ?? null,
      pickupStopId: input.pickupStopId ?? null,
      dropoffStopId: input.dropoffStopId ?? null,
      pricePesewas: input.pricePesewas ?? null,
      ridesGranted: input.ridesGranted ?? null,
      farePesewas: input.farePesewas ?? null,
      creditPesewasPerRide: input.creditPesewasPerRide ?? null,
      periodStart: input.periodStart ?? null,
      periodEnd: input.periodEnd ?? null,
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

  async findAllActive(): Promise<Subscription[]> {
    return Array.from(this.subscriptions.values()).filter((s) => s.status === 'active');
  }
  async findEndedPeriods(now: Date): Promise<Subscription[]> {
    return [...this.subscriptions.values()].filter(
      (s) =>
        s.status === 'active' && s.periodEnd !== null && s.periodEnd.getTime() <= now.getTime(),
    );
  }

  async rollPeriod(
    id: string,
    patch: { periodStart: Date; periodEnd: Date } | { status: 'expired' },
  ): Promise<Subscription | null> {
    const existing = this.subscriptions.get(id);
    if (!existing) return null;
    const updated: Subscription = { ...existing, ...patch };
    this.subscriptions.set(id, updated);
    return updated;
  }
}
