import { expect, it } from 'vitest';
import { nextTravelDay, planLabel, suggestedCoverageEnd } from './standby-offers';

it('suggests seven days, fourteen days and one calendar month without changing the start', () => {
  expect(suggestedCoverageEnd('2026-12-28', 'weekly')).toBe('2027-01-04');
  expect(suggestedCoverageEnd('2026-12-28', 'biweekly')).toBe('2027-01-11');
  expect(suggestedCoverageEnd('2026-01-31', 'monthly')).toBe('2026-02-28');
  expect(suggestedCoverageEnd('2024-01-31', 'monthly')).toBe('2024-02-29');
  expect(planLabel('weekly')).toBe('Weekly');
  expect(planLabel('biweekly')).toBe('Biweekly');
  expect(planLabel('annual')).toBe('Annual (previous plan)');
});

it("starts an offer on the rider's next travel day, a day later after 18:00", () => {
  const weekdays = [1, 2, 3, 4, 5];
  // Monday 12 Oct 2026, morning: Tuesday.
  expect(nextTravelDay(weekdays, new Date('2026-10-12T09:00:00Z'))).toBe('2026-10-13');
  // Monday evening: past 18:00, so Wednesday.
  expect(nextTravelDay(weekdays, new Date('2026-10-12T18:30:00Z'))).toBe('2026-10-14');
  // Friday morning: the weekend is skipped, so Monday.
  expect(nextTravelDay(weekdays, new Date('2026-10-16T09:00:00Z'))).toBe('2026-10-19');
  // Friday evening: Monday is the late-day buffer, so Tuesday.
  expect(nextTravelDay(weekdays, new Date('2026-10-16T19:00:00Z'))).toBe('2026-10-20');
  // A Saturday-only rider on Monday: the coming Saturday.
  expect(nextTravelDay([6], new Date('2026-10-12T09:00:00Z'))).toBe('2026-10-17');
  // No days on record: tomorrow.
  expect(nextTravelDay([], new Date('2026-10-12T09:00:00Z'))).toBe('2026-10-13');
});
