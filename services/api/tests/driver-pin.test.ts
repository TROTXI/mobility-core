// Driver credential primitives (#223).

import { describe, expect, it } from 'vitest';
import {
  generateDriverCode,
  generatePin,
  hashDriverPin,
  isTrivialPin,
  normalizeDriverCode,
  verifyDriverPin,
} from '../src/modules/auth/driver-pin';
import { hashPin } from '../src/modules/reservations/pin';

const SECRET = 'test-secret-at-least-32-characters-long-0000';

describe('driver codes', () => {
  it('mints codes without the characters people misread', () => {
    for (let i = 0; i < 200; i++) {
      const code = generateDriverCode();
      expect(code).toMatch(/^DR-[23456789ABCDEFGHJKMNPQRSTVWXYZ]{4}$/);
    }
  });

  it('accepts a code however a driver types it off a slip of paper', () => {
    for (const typed of ['DR-B7K9', 'dr-b7k9', ' b7k9 ', 'B7K9', 'dr- b7k9']) {
      expect(normalizeDriverCode(typed)).toBe('DR-B7K9');
    }
  });
});

describe('driver PINs', () => {
  it('never mints a trivial PIN', () => {
    for (let i = 0; i < 500; i++) {
      expect(isTrivialPin(generatePin())).toBe(false);
    }
  });

  it('refuses the shapes an attacker tries first', () => {
    for (const pin of ['000000', '111111', '123456', '654321', '345678']) {
      expect(isTrivialPin(pin)).toBe(true);
    }
  });

  it('refuses anything that is not six digits', () => {
    for (const pin of ['12345', '1234567', '12a456', '']) {
      expect(isTrivialPin(pin)).toBe(true);
    }
  });

  it('accepts an ordinary PIN', () => {
    expect(isTrivialPin('482913')).toBe(false);
  });

  it('verifies in constant time against the stored hash', () => {
    const hash = hashDriverPin('482913', SECRET);
    expect(verifyDriverPin('482913', hash, SECRET)).toBe(true);
    expect(verifyDriverPin('482914', hash, SECRET)).toBe(false);
  });

  it('is worthless under a different server key', () => {
    const hash = hashDriverPin('482913', SECRET);
    expect(verifyDriverPin('482913', hash, 'another-secret-at-least-32-chars-000')).toBe(false);
  });

  it('does not share a hash space with the boarding code', () => {
    // Both HMAC under the same server key. Without the domain prefix a value
    // lifted from reservations.daily_pin_hash would verify as a driver PIN.
    expect(hashDriverPin('B7K9', SECRET)).not.toBe(hashPin('B7K9', SECRET));
  });
});
