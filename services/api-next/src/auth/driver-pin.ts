// Ported from services/api at 43cdae0; provider/PIN behavior retained.
// Driver credential primitives (#223): the ops-issued code a driver types, the
// PIN behind it, and the keyed hash we store instead of the PIN.
//
// The PIN is hashed the same way the daily boarding code is (HMAC-SHA256 under
// the server secret, compared in constant time), with one difference: the input
// is domain-separated. Both live under the same key, and without a prefix a
// stored boarding-code hash and a stored PIN hash occupy the same space, so a
// value lifted from one table would verify against the other.

import { createHmac, randomInt, timingSafeEqual } from 'node:crypto';

/** Separates this HMAC's input space from the boarding code's (see the header). */
const PIN_DOMAIN = 'trotxi:driver-pin:v1';

/**
 * Characters a driver code can contain: digits and uppercase letters minus the
 * pairs people misread. Ops reads these down a phone line to a driver standing
 * next to a running engine, so `0`/`O` and `1`/`I`/`L` are not worth the risk.
 */
const CODE_ALPHABET = '23456789ABCDEFGHJKMNPQRSTVWXYZ';

/** Characters after the `DR-` prefix. 30^4 is 810,000 codes. */
const CODE_LENGTH = 4;

/** Digits in a driver PIN. */
export const PIN_LENGTH = 6;

/**
 * Mint a driver code, for example `DR-B7K9`.
 *
 * The prefix is there so a code is recognisable as one when it turns up in a
 * WhatsApp message or written on a depot whiteboard, which is where these will
 * actually live.
 *
 * @returns the code, uppercase.
 */
export function generateDriverCode(): string {
  let code = '';
  for (let i = 0; i < CODE_LENGTH; i++) {
    code += CODE_ALPHABET[randomInt(0, CODE_ALPHABET.length)];
  }
  return `DR-${code}`;
}

/**
 * Canonical form of a code as typed: trimmed, uppercased, and tolerant of a
 * missing or lowercase prefix, because a driver reading `DR-B7K9` off a slip
 * will type `dr-b7k9` or just `b7k9` about as often as not.
 *
 * @param code - the code as presented.
 * @returns the canonical code.
 */
export function normalizeDriverCode(code: string): string {
  const trimmed = code.trim().toUpperCase().replace(/\s+/g, '');
  return trimmed.startsWith('DR-') ? trimmed : `DR-${trimmed}`;
}

/**
 * Mint a PIN that is not one of the obvious ones.
 *
 * @returns a six-digit PIN.
 */
export function generatePin(): string {
  let pin = '';
  do {
    pin = '';
    for (let i = 0; i < PIN_LENGTH; i++) pin += String(randomInt(0, 10));
  } while (isTrivialPin(pin));
  return pin;
}

/**
 * Whether a PIN is one an attacker would try first.
 *
 * Covers the shapes that make up a wildly disproportionate share of real PIN
 * choices: every digit the same, and runs in either direction. Five attempts
 * against a lockout is plenty of budget for a handful of guesses, so the cheap
 * ones have to be off the table.
 *
 * @param pin - the candidate PIN.
 * @returns whether it should be refused.
 */
export function isTrivialPin(pin: string): boolean {
  if (!/^\d+$/.test(pin) || pin.length !== PIN_LENGTH) return true;
  if (new Set(pin).size === 1) return true;

  let ascending = true;
  let descending = true;
  for (let i = 1; i < pin.length; i++) {
    const step = Number(pin[i]) - Number(pin[i - 1]);
    if (step !== 1) ascending = false;
    if (step !== -1) descending = false;
  }
  return ascending || descending;
}

/**
 * Keyed hash of a PIN for storage.
 *
 * @param pin - the plaintext PIN.
 * @param secret - the server signing key.
 * @returns the hex-encoded hash.
 */
export function hashDriverPin(pin: string, secret: string): string {
  return createHmac('sha256', secret).update(`${PIN_DOMAIN}:${pin.trim()}`).digest('hex');
}

/**
 * Constant-time check of a PIN against a stored hash.
 *
 * @param pin - the presented PIN.
 * @param hash - the stored hash.
 * @param secret - the server signing key.
 * @returns whether it matches.
 */
export function verifyDriverPin(pin: string, hash: string, secret: string): boolean {
  const expected = Buffer.from(hashDriverPin(pin, secret), 'hex');
  const actual = Buffer.from(hash, 'hex');
  return expected.length === actual.length && timingSafeEqual(expected, actual);
}
