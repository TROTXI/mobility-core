import { describe, expect, it } from 'vitest';
import { accraLocalToIso } from './accra-time';

describe('Accra wall time', () => {
  it('does not reinterpret the input in the browser timezone', () => {
    expect(accraLocalToIso('2026-10-01T08:00')).toBe('2026-10-01T08:00:00.000Z');
  });
  it('rejects impossible dates', () => {
    expect(() => accraLocalToIso('2026-02-30T08:00')).toThrow('Invalid Accra time');
  });
});
