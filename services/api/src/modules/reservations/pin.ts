// Daily boarding PIN (ADR-0014, E4 layer 2). A rider gets a 4-digit code when
// they confirm; the driver types it against the manifest to board offline. Low
// entropy by design (4 digits), so the protection is layered: it's verified only
// for a specific reservation the driver already sees on the manifest, the
// verify endpoint is driver-gated + rate limited, and the stored value is a
// KEYED hash (HMAC-SHA256 with the server secret) so a DB leak doesn't reveal it.

import { createHmac, randomInt, timingSafeEqual } from 'node:crypto';

/**
 * Generate a random 4-digit PIN (`"0000"`–`"9999"`).
 *
 * @returns the plaintext PIN.
 */
export function generatePin(): string {
  return String(randomInt(0, 10000)).padStart(4, '0');
}

/**
 * Keyed hash of a PIN for storage (HMAC-SHA256 with the server secret).
 *
 * @param pin - the plaintext PIN.
 * @param secret - the server signing key.
 * @returns the hex-encoded hash.
 */
export function hashPin(pin: string, secret: string): string {
  return createHmac('sha256', secret).update(pin).digest('hex');
}

/**
 * Constant-time check of a PIN against a stored hash.
 *
 * @param pin - the presented plaintext PIN.
 * @param hash - the stored hash (or null when the reservation has no PIN).
 * @param secret - the server signing key.
 * @returns whether the PIN matches.
 */
export function verifyPin(pin: string, hash: string | null, secret: string): boolean {
  if (!hash) return false;
  const expected = Buffer.from(hashPin(pin, secret), 'hex');
  const actual = Buffer.from(hash, 'hex');
  return expected.length === actual.length && timingSafeEqual(expected, actual);
}
