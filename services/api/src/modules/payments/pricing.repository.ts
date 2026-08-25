// Persistence for the money levers (#103, ADR-0015): per-corridor regulated
// fares and per-plan pricing configuration.
//
// Repository pattern (ADR-0009): interface + InMemory here, Postgres in *.pg.ts.

import type { SubscriptionPlan } from '../subscriptions/subscription.repository';
import type { PlanPricing } from './pricing';

/** A corridor fare and the window it applies to. */
export interface CorridorFare {
  id: string;
  routeId: string;
  farePesewas: number;
  effectiveFrom: Date;
  /** Null while this is the fare in force. */
  effectiveTo: Date | null;
  note: string | null;
}

/** Persistence for fares and plan pricing. */
export interface PricingRepository {
  /**
   * The fare in force for a corridor.
   *
   * @param routeId - the corridor.
   * @returns the current fare, or null when none has been set.
   */
  currentFare(routeId: string): Promise<CorridorFare | null>;
  /**
   * Every fare recorded for a corridor, newest first — the audit trail that
   * answers "why did this rider pay that in August".
   *
   * @param routeId - the corridor.
   * @returns the fare history.
   */
  fareHistory(routeId: string): Promise<CorridorFare[]>;
  /**
   * Set a corridor's fare, closing the previous one.
   *
   * Closing rather than overwriting is the point: a fare change is a new row,
   * so the old price stays explainable after the union announces again.
   *
   * @param routeId - the corridor.
   * @param farePesewas - the new fare.
   * @param note - why it changed (announcement, fuel adjustment, correction).
   * @returns the newly effective fare.
   */
  setFare(routeId: string, farePesewas: number, note?: string): Promise<CorridorFare>;
  /**
   * The pricing levers for a plan.
   *
   * @param plan - the plan tier.
   * @returns the configured levers, or null when unconfigured.
   */
  planPricing(plan: SubscriptionPlan): Promise<PlanPricing | null>;
  /**
   * Every plan's levers, for the ops screen.
   *
   * @returns all configured plans.
   */
  allPlanPricing(): Promise<(PlanPricing & { plan: SubscriptionPlan })[]>;
  /**
   * Update a plan's levers.
   *
   * @param plan - the plan tier.
   * @param patch - the fields to change; omitted fields are left alone.
   * @returns the updated levers, or null when the plan is unknown.
   */
  updatePlanPricing(
    plan: SubscriptionPlan,
    patch: Partial<PlanPricing>,
  ): Promise<PlanPricing | null>;
}

/** In-memory {@link PricingRepository} for dev and unit tests. */
export class InMemoryPricingRepository implements PricingRepository {
  private readonly fares: CorridorFare[] = [];
  private readonly plans = new Map<SubscriptionPlan, PlanPricing>([
    [
      'monthly',
      { ridesPerPeriod: 44, priceMultiplierBp: 10_000, takeRateBp: 0, creditPesewasPerRide: 45 },
    ],
    [
      'annual',
      { ridesPerPeriod: 528, priceMultiplierBp: 10_000, takeRateBp: 0, creditPesewasPerRide: 45 },
    ],
  ]);

  async currentFare(routeId: string): Promise<CorridorFare | null> {
    return this.fares.find((f) => f.routeId === routeId && f.effectiveTo === null) ?? null;
  }

  async fareHistory(routeId: string): Promise<CorridorFare[]> {
    return this.fares
      .filter((f) => f.routeId === routeId)
      .sort((a, b) => b.effectiveFrom.getTime() - a.effectiveFrom.getTime());
  }

  async setFare(routeId: string, farePesewas: number, note?: string): Promise<CorridorFare> {
    const now = new Date();
    const current = await this.currentFare(routeId);
    if (current) current.effectiveTo = now;

    const fare: CorridorFare = {
      id: crypto.randomUUID(),
      routeId,
      farePesewas,
      effectiveFrom: now,
      effectiveTo: null,
      note: note ?? null,
    };
    this.fares.push(fare);
    return fare;
  }

  async planPricing(plan: SubscriptionPlan): Promise<PlanPricing | null> {
    return this.plans.get(plan) ?? null;
  }

  async allPlanPricing(): Promise<(PlanPricing & { plan: SubscriptionPlan })[]> {
    return [...this.plans.entries()].map(([plan, pricing]) => ({ plan, ...pricing }));
  }

  async updatePlanPricing(
    plan: SubscriptionPlan,
    patch: Partial<PlanPricing>,
  ): Promise<PlanPricing | null> {
    const existing = this.plans.get(plan);
    if (!existing) return null;
    const updated = { ...existing, ...patch };
    this.plans.set(plan, updated);
    return updated;
  }
}
