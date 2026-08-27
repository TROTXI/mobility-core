import { describe, expect, it } from 'vitest';
import {
  addMonthsClamped,
  hasEnded,
  nextPeriod,
  periodFor,
  periodRef,
} from '../src/modules/subscriptions/period';

const iso = (d: Date) => d.toISOString();

describe('addMonthsClamped', () => {
  it('keeps the same day in an ordinary month', () => {
    expect(iso(addMonthsClamped(new Date('2026-08-12T09:00:00Z'), 1))).toBe(
      '2026-09-12T09:00:00.000Z',
    );
  });

  it('clamps 31 Jan to 28 Feb rather than overflowing into March', () => {
    // setUTCMonth would give 3 March. A rider subscribing on the 31st would
    // get a renewal date that drifts a few days further every single cycle.
    expect(iso(addMonthsClamped(new Date('2026-01-31T00:00:00Z'), 1))).toBe(
      '2026-02-28T00:00:00.000Z',
    );
  });

  it('clamps to 29 Feb in a leap year', () => {
    expect(iso(addMonthsClamped(new Date('2028-01-31T00:00:00Z'), 1))).toBe(
      '2028-02-29T00:00:00.000Z',
    );
  });

  it('clamps 31 May to 30 June', () => {
    expect(iso(addMonthsClamped(new Date('2026-05-31T00:00:00Z'), 1))).toBe(
      '2026-06-30T00:00:00.000Z',
    );
  });

  it('crosses a year boundary', () => {
    expect(iso(addMonthsClamped(new Date('2026-12-15T00:00:00Z'), 1))).toBe(
      '2027-01-15T00:00:00.000Z',
    );
  });

  it('adds twelve months for an annual plan', () => {
    expect(iso(addMonthsClamped(new Date('2026-08-12T00:00:00Z'), 12))).toBe(
      '2027-08-12T00:00:00.000Z',
    );
  });
});

describe('periodFor', () => {
  it('gives a monthly plan one month', () => {
    const p = periodFor('monthly', new Date('2026-08-12T09:00:00Z'));
    expect(iso(p.end)).toBe('2026-09-12T09:00:00.000Z');
  });

  it('gives an annual plan a year', () => {
    const p = periodFor('annual', new Date('2026-08-12T09:00:00Z'));
    expect(iso(p.end)).toBe('2027-08-12T09:00:00.000Z');
  });
});

describe('nextPeriod', () => {
  it('starts exactly where the last ended, leaving no gap', () => {
    const first = periodFor('monthly', new Date('2026-08-12T09:00:00Z'));
    const second = nextPeriod('monthly', first);
    expect(iso(second.start)).toBe(iso(first.end));
  });

  it('does not drift when a renewal is processed late', () => {
    // The next period follows the last one, not "now". Renewing three days
    // late must not move a rider's anniversary permanently.
    const first = periodFor('monthly', new Date('2026-01-31T00:00:00Z'));
    const second = nextPeriod('monthly', first); // 28 Feb -> 28 Mar
    const third = nextPeriod('monthly', second);
    expect(iso(second.end)).toBe('2026-03-28T00:00:00.000Z');
    expect(iso(third.end)).toBe('2026-04-28T00:00:00.000Z');
  });
});

describe('hasEnded', () => {
  const p = periodFor('monthly', new Date('2026-08-12T09:00:00Z'));

  it('is false inside the period', () => {
    expect(hasEnded(p, new Date('2026-09-11T23:59:59Z'))).toBe(false);
  });

  it('is true at the exclusive end, not a second later', () => {
    // Half-open: the instant `end` arrives, the period is over.
    expect(hasEnded(p, p.end)).toBe(true);
  });
});

describe('periodRef — the fix at the heart of #162', () => {
  it('differs between consecutive periods of one subscription', () => {
    // The old key was the subscription id alone, so conversion could only ever
    // run ONCE in that subscription's lifetime: it would zero a rider who
    // subscribed days earlier, then no-op forever from month two.
    const first = periodFor('monthly', new Date('2026-08-12T09:00:00Z'));
    const second = nextPeriod('monthly', first);

    expect(periodRef('sub-1', first.end)).not.toBe(periodRef('sub-1', second.end));
  });

  it('is stable within one period, so a retry is still a no-op', () => {
    const p = periodFor('monthly', new Date('2026-08-12T09:00:00Z'));
    expect(periodRef('sub-1', p.end)).toBe(periodRef('sub-1', new Date(p.end)));
  });

  it('differs between subscriptions in the same period', () => {
    const p = periodFor('monthly', new Date('2026-08-12T09:00:00Z'));
    expect(periodRef('sub-1', p.end)).not.toBe(periodRef('sub-2', p.end));
  });
});
