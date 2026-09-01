// Daily boarding code (ADR-0014, E4 layer 2). A rider gets a short code when
// they confirm; the driver types it against the manifest to board offline.
// Four characters is still low entropy, so the protection stays layered: it's
// verified only for a specific reservation the driver already sees on the
// manifest, the verify endpoint is driver-gated + rate limited, and the stored
// value is a KEYED hash (HMAC-SHA256 with the server secret) so a DB leak
// doesn't reveal it.

import { createHmac, randomInt, timingSafeEqual } from 'node:crypto';

/**
 * Characters a boarding code can contain.
 *
 * Digits and uppercase letters minus the pairs people misread aloud or mistype
 * off a phone screen: `0`/`O`, `1`/`I`/`L`, and `U` (which turns short codes
 * into words nobody wants to read out). 30 characters gives 810,000 codes
 * against 10,000 for the four-digit PIN this replaced. The full 36-character
 * alphabet would reach 1.68m, but a driver retyping a code at the kerb in the
 * dark is the likelier failure than someone guessing one.
 */
const CODE_ALPHABET = '23456789ABCDEFGHJKMNPQRSTVWXYZ';

/** How many characters a generated boarding code has. */
const CODE_LENGTH = 4;

/**
 * Generate a random boarding code (for example `B7K9`).
 *
 * @returns the plaintext code, uppercase.
 */
export function generatePin(): string {
  let code = '';
  for (let i = 0; i < CODE_LENGTH; i++) {
    code += CODE_ALPHABET[randomInt(0, CODE_ALPHABET.length)];
  }
  return code;
}

/**
 * Canonical form of a code as typed by a driver: trimmed and uppercased.
 *
 * Applied on both sides of the hash, so a driver typing `b7k9` boards the rider
 * and the keypad doesn't have to force case. Digit-only codes issued before the
 * alphanumeric switch are unaffected by uppercasing, so they keep verifying.
 *
 * @param pin - the code as presented.
 * @returns the canonical code.
 */
export function normalizePin(pin: string): string {
  return pin.trim().toUpperCase();
}

/**
 * Keyed hash of a boarding code for storage (HMAC-SHA256 with the server secret).
 *
 * @param pin - the plaintext code.
 * @param secret - the server signing key.
 * @returns the hex-encoded hash.
 */
export function hashPin(pin: string, secret: string): string {
  return createHmac('sha256', secret).update(normalizePin(pin)).digest('hex');
}

/**
 * Constant-time check of a boarding code against a stored hash.
 *
 * @param pin - the presented plaintext code.
 * @param hash - the stored hash (or null when the reservation has no code).
 * @param secret - the server signing key.
 * @returns whether the code matches.
 */
export function verifyPin(pin: string, hash: string | null, secret: string): boolean {
  if (!hash) return false;
  const expected = Buffer.from(hashPin(pin, secret), 'hex');
  const actual = Buffer.from(hash, 'hex');
  return expected.length === actual.length && timingSafeEqual(expected, actual);
}
