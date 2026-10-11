import { expect, it } from 'vitest';
import { planLabel, suggestedCoverageEnd } from './standby-offers';

it('suggests seven days, fourteen days and one calendar month without changing the start', () => {
  expect(suggestedCoverageEnd('2026-12-28', 'weekly')).toBe('2027-01-04');
  expect(suggestedCoverageEnd('2026-12-28', 'biweekly')).toBe('2027-01-11');
  expect(suggestedCoverageEnd('2026-01-31', 'monthly')).toBe('2026-02-28');
  expect(suggestedCoverageEnd('2024-01-31', 'monthly')).toBe('2024-02-29');
  expect(planLabel('weekly')).toBe('Weekly');
  expect(planLabel('biweekly')).toBe('Biweekly');
  expect(planLabel('annual')).toBe('Annual (previous plan)');
});
