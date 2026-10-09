import type { components } from '../generated/api';

export type StandbyApplication = components['schemas']['StandbyApplication'];
export const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
export const futureDate = (days: number) =>
  new Date(Date.now() + days * 86400000).toISOString().slice(0, 10);

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
    if (Number.isFinite(start) && end > start && end - start <= 366 * 86400000)
      for (let ms = start; ms < end; ms += 86400000) {
        const day = new Date(ms).getUTCDay() || 7;
        if (application.travelDays.includes(day) && schedule?.weekdays.includes(day)) rides++;
      }
    return { direction: leg.direction, fare, rides, schedule };
  });
}
