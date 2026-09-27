// Port of the existing integer-basis-point and UTC calendar rules, with safe
// intermediate arithmetic. No HTTP caller supplies these priced terms.
export type Plan = 'monthly' | 'annual';
export const MIN_CHARGE_PESEWAS = 100;
export const MAX_MONEY = 2147483647;
/** Shared by preview and checkout: keep the provider's minimum cash charge. */
export function appliedCredit(price: number, available: number, useCredit: boolean): number {
  whole(price, MIN_CHARGE_PESEWAS);
  if (!Number.isSafeInteger(available) || available < 0) throw new Error('invalid_credit_balance');
  return useCredit ? Math.min(available, price - MIN_CHARGE_PESEWAS) : 0;
}
export interface Pricing {
  ridesGranted: number;
  farePesewas: number;
  priceMultiplierBp: number;
  conversionRatePesewas: number;
}
export interface PricedTerms extends Pricing {
  pricePesewas: number;
}
export function whole(value: number, min = 0, max = MAX_MONEY): number {
  if (!Number.isSafeInteger(value) || value < min || value > max)
    throw new Error('invalid_financial_integer');
  return value;
}
export function priceTerms(input: Pricing): PricedTerms {
  const fare = whole(input.farePesewas, 1),
    rides = whole(input.ridesGranted, 1),
    bp = whole(input.priceMultiplierBp, 1),
    rate = whole(input.conversionRatePesewas);
  const price = (BigInt(fare) * BigInt(rides) * BigInt(bp) + 5000n) / 10000n;
  if (
    price < BigInt(MIN_CHARGE_PESEWAS) ||
    price > BigInt(MAX_MONEY) ||
    BigInt(rate) * BigInt(rides) > BigInt(MAX_MONEY)
  )
    throw new Error('invalid_financial_integer');
  return { ...input, pricePesewas: Number(price) };
}
export function billingEnd(plan: Plan, start: Date): Date {
  if (!Number.isFinite(start.getTime()) || !['monthly', 'annual'].includes(plan))
    throw new Error('invalid_billing_period');
  const end = new Date(start);
  end.setUTCDate(1);
  end.setUTCMonth(end.getUTCMonth() + (plan === 'annual' ? 12 : 1));
  const last = new Date(end);
  last.setUTCMonth(last.getUTCMonth() + 1);
  last.setUTCDate(0);
  end.setUTCDate(Math.min(start.getUTCDate(), last.getUTCDate()));
  return end;
}
