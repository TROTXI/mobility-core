import { describe, expect, it } from 'vitest';
import { accraLocalToIso, formatAccraClock, formatAccraTime } from './accra-time';

describe('Accra wall time', () => {
  it('does not reinterpret the input in the browser timezone', () => {
    expect(accraLocalToIso('2026-10-01T08:00')).toBe('2026-10-01T08:00:00.000Z');
  });
  it('rejects impossible dates', () => {
    expect(() => accraLocalToIso('2026-02-30T08:00')).toThrow('Invalid Accra time');
  });
  it('displays an Accra departure on its service day regardless of the browser timezone', () => {
    expect(formatAccraTime('2026-09-25T06:30:00Z')).toBe('25 Sept 2026, 6:30 am GMT');
    expect(formatAccraClock('2026-09-25T06:30:00Z')).toBe('06:30 am GMT');
  });
});
