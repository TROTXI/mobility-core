import type { PoolClient } from 'pg';
import type { Body } from '../transport/service.js';
import type { CheckoutInput, PurchaseLeg } from '../payments/foundation.js';
import { fail } from '../transport/errors.js';
import { Pricing } from '../payments/pricing.js';

export type Money = { amountMinor: number; currency: 'GHS' };
export interface OfferLeg extends PurchaseLeg {
  pickupName: string;
  dropoffName: string;
  fareId: string;
  fare: Money;
  ridesGranted: number;
  travelDays: number[];
  creditPerUnusedRide: Money;
}
export interface OfferTerms {
  coverageStart: string;
  coverageEnd: string;
  price: Money;
  legs: OfferLeg[];
}
export function travelDays(raw: unknown): number[] {
  if (
    !Array.isArray(raw) ||
    raw.length < 1 ||
    raw.length > 7 ||
    raw.some((day) => !Number.isInteger(day) || day < 1 || day > 7) ||
    new Set(raw).size !== raw.length
  )
    fail(400, 'invalid_travel_days', 'Choose unique weekdays from Monday to Sunday.');
  return [...raw].sort((a, b) => a - b) as number[];
}
function amount(raw: unknown, minimum: number): Money {
  const value = raw as Money;
  if (
    !value ||
    value.currency !== 'GHS' ||
    !Number.isSafeInteger(value.amountMinor) ||
    value.amountMinor < minimum ||
    value.amountMinor > 2147483647
  )
    fail(400, 'invalid_offer_price', 'Use whole pesewas in GHS.');
  return { amountMinor: value.amountMinor, currency: 'GHS' };
}
export function coverageDate(raw: unknown): Date {
  if (typeof raw !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(raw))
    fail(400, 'invalid_offer_dates', 'Choose valid coverage dates.');
  const parsed = new Date(`${raw}T00:00:00Z`);
  if (!Number.isFinite(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== raw)
    fail(400, 'invalid_offer_dates', 'Choose valid coverage dates.');
  return parsed;
}
export function countTravelDays(start: Date, end: Date, days: number[]): number {
  let count = 0;
  for (let ms = start.getTime(); ms < end.getTime(); ms += 86400000)
    if (days.includes(new Date(ms).getUTCDay() || 7)) count++;
  return count;
}

export async function buildOfferTerms(
  c: PoolClient,
  pricing: Pricing,
  selection: CheckoutInput,
  requestedDays: number[],
  input: Body,
  now = new Date(),
): Promise<OfferTerms> {
  const start = coverageDate(input.coverageStart),
    end = coverageDate(input.coverageEnd);
  const expiry = new Date(String(input.expiresAt));
  if (
    start <= now ||
    end <= start ||
    end.getTime() - start.getTime() > 366 * 86400000 ||
    expiry > start
  )
    fail(
      400,
      'invalid_offer_dates',
      'Coverage must start in the future, last at most 366 days, and start after the offer expires.',
    );
  const credits = input.credits as { direction: string; creditPerUnusedRide: Money }[];
  if (
    !Array.isArray(credits) ||
    credits.length !== 2 ||
    new Set(credits.map((l) => l.direction)).size !== 2
  )
    fail(400, 'invalid_offer_credits', 'Set unused-ride credit for both directions.');
  const legs: OfferLeg[] = [];
  for (const leg of selection.legs) {
    const schedule = (
      await c.query(
        `SELECT s.weekdays,s.effective_from::text,s.effective_to::text,v.effective_to AS version_end,v.effective_from AS version_start,
       a.name AS pickup_name,b.name AS dropoff_name
       FROM app.service_schedules s JOIN app.route_pattern_versions v ON v.id=s.pattern_version_id
       JOIN app.route_pattern_stops a ON a.id=$3 AND a.pattern_version_id=v.id
       JOIN app.route_pattern_stops b ON b.id=$4 AND b.pattern_version_id=v.id
       WHERE s.id=$1 AND s.pattern_version_id=$2 AND v.state='published' AND a.ordinal<b.ordinal FOR SHARE OF s,v`,
        [leg.scheduleId, leg.patternVersionId, leg.pickupOccurrenceId, leg.dropoffOccurrenceId],
      )
    ).rows[0];
    if (
      !schedule ||
      schedule.version_start > start ||
      schedule.effective_from > String(input.coverageStart) ||
      (schedule.effective_to &&
        schedule.effective_to < new Date(end.getTime() - 86400000).toISOString().slice(0, 10)) ||
      (schedule.version_end && schedule.version_end < end)
    )
      fail(
        409,
        'offer_service_unavailable',
        'The selected service must cover the complete offer period.',
      );
    const days = requestedDays.filter((d) => schedule.weekdays.includes(d));
    const rides = countTravelDays(start, end, days);
    if (!rides)
      fail(
        409,
        'offer_service_unavailable',
        'Each direction needs at least one service day in this period.',
      );
    const fare = await pricing.quoteJourney(c, selection.routeId, leg, start);
    const credit = amount(
      credits.find((l) => l.direction === leg.direction)?.creditPerUnusedRide,
      0,
    );
    if (credit.amountMinor > fare.amountPesewas)
      fail(400, 'invalid_offer_credits', 'Unused-ride credit cannot exceed the journey fare.');
    legs.push({
      ...leg,
      pickupName: schedule.pickup_name,
      dropoffName: schedule.dropoff_name,
      fareId: fare.fareId,
      fare: { amountMinor: fare.amountPesewas, currency: 'GHS' },
      ridesGranted: rides,
      travelDays: days,
      creditPerUnusedRide: credit,
    });
  }
  const price = amount(input.price, 100);
  if (
    legs.reduce((sum, l) => sum + l.ridesGranted * l.creditPerUnusedRide.amountMinor, 0) >
    price.amountMinor
  )
    fail(
      400,
      'invalid_offer_credits',
      'Total possible unused-ride credit cannot exceed the package price.',
    );
  return {
    coverageStart: String(input.coverageStart),
    coverageEnd: String(input.coverageEnd),
    price,
    legs,
  };
}
