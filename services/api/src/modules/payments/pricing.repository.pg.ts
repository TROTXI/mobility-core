// Postgres pricing adapter (#103). Fares are effective-dated; setting a new one
// closes the previous row rather than overwriting it, so the price a rider paid
// stays explainable after the fare has moved.

import type { Pool } from 'pg';
import type { SubscriptionPlan } from '../subscriptions/subscription.repository';
import type { PlanPricing } from './pricing';
import type { CorridorFare, PricingRepository } from './pricing.repository';

interface FareRow {
  id: string;
  route_id: string;
  fare_pesewas: number;
  effective_from: Date;
  effective_to: Date | null;
  note: string | null;
}

interface PlanRow {
  plan: SubscriptionPlan;
  rides_per_period: number;
  price_multiplier_bp: number;
  take_rate_bp: number;
  credit_pesewas_per_ride: number;
}

function toFare(row: FareRow): CorridorFare {
  return {
    id: row.id,
    routeId: row.route_id,
    farePesewas: row.fare_pesewas,
    effectiveFrom: row.effective_from,
    effectiveTo: row.effective_to,
    note: row.note,
  };
}

function toPricing(row: PlanRow): PlanPricing {
  return {
    ridesPerPeriod: row.rides_per_period,
    priceMultiplierBp: row.price_multiplier_bp,
    takeRateBp: row.take_rate_bp,
    creditPesewasPerRide: row.credit_pesewas_per_ride,
  };
}

export class PgPricingRepository implements PricingRepository {
  constructor(private readonly pool: Pool) {}

  async currentFare(routeId: string): Promise<CorridorFare | null> {
    const { rows } = await this.pool.query<FareRow>(
      `SELECT * FROM corridor_fares WHERE route_id = $1 AND effective_to IS NULL`,
      [routeId],
    );
    return rows[0] ? toFare(rows[0]) : null;
  }

  async fareHistory(routeId: string): Promise<CorridorFare[]> {
    const { rows } = await this.pool.query<FareRow>(
      `SELECT * FROM corridor_fares WHERE route_id = $1 ORDER BY effective_from DESC`,
      [routeId],
    );
    return rows.map(toFare);
  }

  async setFare(routeId: string, farePesewas: number, note?: string): Promise<CorridorFare> {
    const client = await this.pool.connect();
    try {
      // One transaction: a partial unique index enforces one open fare per
      // corridor, so closing and opening must happen together or the insert
      // collides with the row it is replacing.
      await client.query('BEGIN');
      await client.query(
        `UPDATE corridor_fares SET effective_to = now()
          WHERE route_id = $1 AND effective_to IS NULL`,
        [routeId],
      );
      const { rows } = await client.query<FareRow>(
        `INSERT INTO corridor_fares (route_id, fare_pesewas, note)
         VALUES ($1, $2, $3) RETURNING *`,
        [routeId, farePesewas, note ?? null],
      );
      await client.query('COMMIT');
      return toFare(rows[0]!);
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  async planPricing(plan: SubscriptionPlan): Promise<PlanPricing | null> {
    const { rows } = await this.pool.query<PlanRow>(`SELECT * FROM plan_pricing WHERE plan = $1`, [
      plan,
    ]);
    return rows[0] ? toPricing(rows[0]) : null;
  }

  async allPlanPricing(): Promise<(PlanPricing & { plan: SubscriptionPlan })[]> {
    const { rows } = await this.pool.query<PlanRow>(`SELECT * FROM plan_pricing ORDER BY plan`);
    return rows.map((r) => ({ plan: r.plan, ...toPricing(r) }));
  }

  async updatePlanPricing(
    plan: SubscriptionPlan,
    patch: Partial<PlanPricing>,
  ): Promise<PlanPricing | null> {
    // COALESCE so an omitted field is left alone rather than nulled — the ops
    // screen edits one lever at a time.
    const { rows } = await this.pool.query<PlanRow>(
      `UPDATE plan_pricing
          SET rides_per_period        = COALESCE($2, rides_per_period),
              price_multiplier_bp     = COALESCE($3, price_multiplier_bp),
              take_rate_bp            = COALESCE($4, take_rate_bp),
              credit_pesewas_per_ride = COALESCE($5, credit_pesewas_per_ride),
              updated_at              = now()
        WHERE plan = $1
        RETURNING *`,
      [
        plan,
        patch.ridesPerPeriod ?? null,
        patch.priceMultiplierBp ?? null,
        patch.takeRateBp ?? null,
        patch.creditPesewasPerRide ?? null,
      ],
    );
    return rows[0] ? toPricing(rows[0]) : null;
  }
}
