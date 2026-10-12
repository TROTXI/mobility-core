import type { components } from '../generated/api';

export type StandbyApplication = components['schemas']['StandbyApplication'];
export const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
export const futureDate = (days: number) =>
  new Date(Date.now() + days * 86400000).toISOString().slice(0, 10);

/** Offers sent after this hour (Accra) start one travel day later. */
const LATE_OFFER_HOUR = 18;

/**
 * The first day a new offer should cover: the rider's next travel day after
 * today. Coverage starts at midnight and must be in the future, so today is
 * never possible; tomorrow is, if the rider travels then. After 18:00 the
 * suggestion moves one travel day on, so a rider who sees the offer that
 * evening still has a working day to pay before coverage begins.
 *
 * Accra keeps UTC all year, so UTC dates are Accra dates. Days are ISO
 * weekdays, 1 Monday to 7 Sunday, as in the rider's request.
 */
export function nextTravelDay(travelDays: readonly number[], now = new Date()): string {
  const days = travelDays.length ? travelDays : [1, 2, 3, 4, 5, 6, 7];
  let skip = now.getUTCHours() >= LATE_OFFER_HOUR ? 1 : 0;
  const tomorrow = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1);
  for (let i = 0; i < 21; i++) {
    const day = new Date(tomorrow + i * 86400000);
    if (!days.includes(day.getUTCDay() || 7)) continue;
    if (skip-- > 0) continue;
    return day.toISOString().slice(0, 10);
  }
  return new Date(tomorrow).toISOString().slice(0, 10);
}

export const planLabel = (plan: string) =>
  ({
    weekly: 'Weekly',
    biweekly: 'Biweekly',
    monthly: 'Monthly',
    annual: 'Annual (previous plan)',
  })[plan] ?? plan;

/** Suggested exclusive end. Ops still reviews exact dates and price before sending. */
export function suggestedCoverageEnd(start: string, plan: string): string {
  const date = new Date(`${start}T00:00:00Z`);
  if (!Number.isFinite(date.getTime())) return '';
  if (plan === 'weekly' || plan === 'biweekly') {
    date.setUTCDate(date.getUTCDate() + (plan === 'weekly' ? 7 : 14));
  } else {
    const day = date.getUTCDate();
    date.setUTCDate(1);
    date.setUTCMonth(date.getUTCMonth() + 1);
    const last = new Date(date);
    last.setUTCMonth(last.getUTCMonth() + 1);
    last.setUTCDate(0);
    date.setUTCDate(Math.min(day, last.getUTCDate()));
  }
  return date.toISOString().slice(0, 10);
}

export function pesewas(value: string) {
  if (!/^\d+(\.\d{1,2})?$/.test(value))
    throw new Error('Enter amounts in GHS, with at most two decimal places.');
  const amount = Math.round(Number(value) * 100);
  if (!Number.isSafeInteger(amount) || amount > 2147483647)
    throw new Error('Amount is out of range.');
  return { amountMinor: amount, currency: 'GHS' as const };
}

/** Walk pricing pages completely. Never calculate an offer from a partial fare list. */
export async function pricingPages<T>(
  fetchPage: (cursor?: string) => Promise<{ data: T[]; page: { nextCursor: string | null } }>,
) {
  const rows: T[] = [];
  const seen = new Set<string>();
  let cursor: string | undefined;
  do {
    const page = await fetchPage(cursor);
    rows.push(...page.data);
    cursor = page.page.nextCursor ?? undefined;
    if (cursor && (seen.has(cursor) || seen.size >= 100))
      throw new Error('Could not load complete pricing. Refresh before sending offers.');
    if (cursor) seen.add(cursor);
  } while (cursor);
  return rows;
}

export function estimateOffers(
  application: StandbyApplication,
  pricing: {
    fares: components['schemas']['Fare'][];
    schedules: components['schemas']['Schedule'][];
  },
  coverageStart: string,
  coverageEnd: string,
) {
  return application.selection.legs.map((leg) => {
    const start = new Date(`${coverageStart}T00:00:00Z`).getTime();
    const end = new Date(`${coverageEnd}T00:00:00Z`).getTime();
    const schedule = pricing.schedules.find((s) => s.id === leg.scheduleId);
    // Schedule dates are inclusive; offer coverageEnd is exclusive. Match
    // buildOfferTerms: partial service coverage cannot be offered at all.
    const scheduleCoversPeriod =
      !!schedule &&
      Number.isFinite(start) &&
      end > start &&
      end - start <= 366 * 86400000 &&
      new Date(`${schedule.effectiveFrom}T00:00:00Z`).getTime() <= start &&
      (schedule.effectiveTo === null ||
        new Date(`${schedule.effectiveTo}T00:00:00Z`).getTime() >= end - 86400000);
    const fare = pricing.fares.find(
      (f) =>
        (!f.journey || f.journey.direction === leg.direction) &&
        f.patternVersionId === leg.patternVersionId &&
        f.pickupOccurrenceId === leg.pickupOccurrenceId &&
        f.dropoffOccurrenceId === leg.dropoffOccurrenceId &&
        new Date(f.effectiveFrom).getTime() <= start &&
        (!f.effectiveTo || new Date(f.effectiveTo).getTime() > start),
    );
    let rides = 0;
    if (scheduleCoversPeriod)
      for (let ms = start; ms < end; ms += 86400000) {
        const day = new Date(ms).getUTCDay() || 7;
        if (application.travelDays.includes(day) && schedule?.weekdays.includes(day)) rides++;
      }
    return { direction: leg.direction, fare, rides, schedule, scheduleCoversPeriod };
  });
}
