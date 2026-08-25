import { describe, expect, it } from 'vitest';
import { InMemoryPricingRepository } from '../src/modules/payments/pricing.repository';

const ROUTE = '11111111-1111-4111-8111-111111111111';

describe('fare history', () => {
  it('closes the previous fare rather than overwriting it', async () => {
    // The whole point of effective dating: a subscription sold in August has to
    // stay explainable in October, after the unions have announced twice.
    const repo = new InMemoryPricingRepository();
    await repo.setFare(ROUTE, 600, 'initial');
    await repo.setFare(ROUTE, 700, 'fuel adjustment');

    const history = await repo.fareHistory(ROUTE);
    expect(history).toHaveLength(2);
    expect(history[0]!.farePesewas).toBe(700);
    expect(history[0]!.effectiveTo).toBeNull();
    expect(history[1]!.effectiveTo).not.toBeNull();
  });

  it('has exactly one fare in force at a time', async () => {
    const repo = new InMemoryPricingRepository();
    await repo.setFare(ROUTE, 600);
    await repo.setFare(ROUTE, 700);
    await repo.setFare(ROUTE, 800);

    const current = await repo.currentFare(ROUTE);
    expect(current?.farePesewas).toBe(800);
    expect((await repo.fareHistory(ROUTE)).filter((f) => f.effectiveTo === null)).toHaveLength(1);
  });

  it('records why a fare moved', async () => {
    const repo = new InMemoryPricingRepository();
    await repo.setFare(ROUTE, 700, 'GPRTU announcement');
    expect((await repo.currentFare(ROUTE))?.note).toBe('GPRTU announcement');
  });

  it('returns null for a corridor that has never been priced', async () => {
    expect(await new InMemoryPricingRepository().currentFare(ROUTE)).toBeNull();
  });
});

describe('plan pricing', () => {
  it('seeds with the values previously hardcoded, at parity and zero take rate', async () => {
    // Storage changed, behaviour did not. A take rate nobody has agreed with an
    // operator starts at zero — charging a share nobody signed is worse than
    // charging none.
    const repo = new InMemoryPricingRepository();
    const monthly = await repo.planPricing('monthly');
    expect(monthly).toEqual({
      ridesPerPeriod: 44,
      priceMultiplierBp: 10_000,
      takeRateBp: 0,
      creditPesewasPerRide: 45,
    });
  });

  it('updates one lever without disturbing the others', async () => {
    const repo = new InMemoryPricingRepository();
    const updated = await repo.updatePlanPricing('monthly', { takeRateBp: 1_500 });

    expect(updated?.takeRateBp).toBe(1_500);
    expect(updated?.ridesPerPeriod).toBe(44);
    expect(updated?.priceMultiplierBp).toBe(10_000);
  });

  it('returns null for an unknown plan rather than inventing one', async () => {
    const repo = new InMemoryPricingRepository();
    expect(await repo.updatePlanPricing('weekly' as never, { takeRateBp: 1 })).toBeNull();
  });
});
