import { describe, expect, it } from 'vitest';
import { normaliseGhanaPhone } from '../src/lib/phone';

describe('normaliseGhanaPhone', () => {
  // The whole reason this exists: users.phone is UNIQUE, and Paystack returns
  // the same handset in whichever shape the payer typed. Without normalisation
  // one person occupies three rows, or collides with themselves.
  it('resolves every shape of one number to a single value', () => {
    const expected = '+233244123456';
    for (const raw of [
      '0244123456',
      '244123456',
      '233244123456',
      '+233244123456',
      '+233 244 123 456',
      '(024) 412-3456',
      '  0244123456  ',
    ]) {
      expect(normaliseGhanaPhone(raw), raw).toBe(expected);
    }
  });

  it('passes through an explicitly international number rather than forcing +233', () => {
    expect(normaliseGhanaPhone('+2348012345678')).toBe('+2348012345678');
  });

  it('returns null for input it cannot recognise, so callers skip the write', () => {
    for (const raw of [null, undefined, '', '   ', 'not a phone', '12', '0244']) {
      expect(normaliseGhanaPhone(raw), String(raw)).toBeNull();
    }
  });
});
