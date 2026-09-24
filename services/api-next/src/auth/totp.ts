import {
  createCipheriv,
  createDecipheriv,
  createHmac,
  randomBytes,
  timingSafeEqual,
} from 'node:crypto';

/**
 * Time-based one-time codes (RFC 6238), the kind an authenticator app shows.
 *
 * Thirty-second steps and six digits because that is what the apps implement.
 * Google Authenticator ignores any other period, so a longer one would put a
 * code on the phone that the server never accepts.
 */
export const STEP_SECONDS = 30;
const DIGITS = 6;
/** One step either side: a phone clock a few seconds off still signs in. */
const WINDOW = 1;
const ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

export function base32Encode(bytes: Buffer): string {
  let bits = 0,
    value = 0,
    out = '';
  for (const byte of bytes) {
    value = (value << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      out += ALPHABET[(value >>> (bits - 5)) & 31];
      bits -= 5;
    }
  }
  if (bits > 0) out += ALPHABET[(value << (5 - bits)) & 31];
  return out;
}

export function base32Decode(text: string): Buffer {
  const clean = text.toUpperCase().replace(/[\s=-]/g, '');
  let bits = 0,
    value = 0;
  const out: number[] = [];
  for (const char of clean) {
    const index = ALPHABET.indexOf(char);
    if (index < 0) throw new Error('Invalid base32');
    value = (value << 5) | index;
    bits += 5;
    if (bits >= 8) {
      out.push((value >>> (bits - 8)) & 255);
      bits -= 8;
    }
  }
  return Buffer.from(out);
}

/** 160 bits, the length RFC 4226 recommends for HMAC-SHA1. */
export const newSecret = () => randomBytes(20);

export const stepAt = (time: Date) => Math.floor(time.getTime() / 1000 / STEP_SECONDS);

export function codeAt(secret: Buffer, step: number): string {
  const counter = Buffer.alloc(8);
  counter.writeBigUInt64BE(BigInt(step));
  const mac = createHmac('sha1', secret).update(counter).digest();
  const offset = mac[mac.length - 1]! & 0x0f;
  const value = (mac.readUInt32BE(offset) & 0x7fffffff) % 10 ** DIGITS;
  return String(value).padStart(DIGITS, '0');
}

/**
 * The step a code belongs to, or null.
 *
 * A step at or before the last one accepted is refused, so a code seen over a
 * shoulder or replayed from a log is dead the moment it has been used once,
 * even though it is still inside its thirty seconds.
 */
export function matchStep(
  secret: Buffer,
  code: string,
  now: Date,
  lastUsedStep: number | null,
): number | null {
  if (!/^\d{6}$/.test(code)) return null;
  const current = stepAt(now);
  let matched: number | null = null;
  // Every candidate is compared, match or not, so how long this takes does not
  // say which step was right.
  for (let step = current - WINDOW; step <= current + WINDOW; step++) {
    const equal = timingSafeEqual(Buffer.from(codeAt(secret, step)), Buffer.from(code));
    if (equal && matched === null && (lastUsedStep === null || step > lastUsedStep)) matched = step;
  }
  return matched;
}

/** What the enrolment QR code encodes. Every authenticator app reads this. */
export function otpauthUri(secret: Buffer, account: string, issuer = 'Trotxi Ops'): string {
  const params = new URLSearchParams({
    secret: base32Encode(secret),
    issuer,
    algorithm: 'SHA1',
    digits: String(DIGITS),
    period: String(STEP_SECONDS),
  });
  return `otpauth://totp/${encodeURIComponent(`${issuer}:${account}`)}?${params}`;
}

/**
 * Ten codes of eight characters, 40 bits each. The lockout stops anyone
 * guessing at that, and each is single use.
 */
export function newRecoveryCodes(count = 10): string[] {
  return Array.from({ length: count }, () => {
    const code = base32Encode(randomBytes(5)).toLowerCase();
    return `${code.slice(0, 4)}-${code.slice(4, 8)}`;
  });
}

/** Typed with or without the hyphen, in any case, with stray spaces. */
export const normalizeRecoveryCode = (code: string) => code.toLowerCase().replace(/[\s-]/g, '');

/**
 * Keyed, so a copy of the database alone cannot be used to test guesses
 * offline against the stored hashes.
 */
export function recoveryCodeHash(key: Buffer, code: string): string {
  return createHmac('sha256', key)
    .update(`trotxi:mfa-recovery:v1:${normalizeRecoveryCode(code)}`)
    .digest('hex');
}

/**
 * The secret at rest. Bound to its owner by associated data, the same way the
 * Apple credentials are, so a ciphertext moved onto another account fails to
 * open rather than lending that account a working authenticator.
 */
export function totpSecretBox(key: Buffer) {
  if (key.length !== 32) throw new Error('A separate 32-byte two-factor key is required');
  const aad = (userId: string) => Buffer.from(`totp:${userId}`);
  return {
    seal(secret: Buffer, userId: string): string {
      const iv = randomBytes(12),
        cipher = createCipheriv('aes-256-gcm', key, iv);
      cipher.setAAD(aad(userId));
      return Buffer.concat([
        iv,
        cipher.update(secret),
        cipher.final(),
        cipher.getAuthTag(),
      ]).toString('base64url');
    },
    open(value: string, userId: string): Buffer {
      const bytes = Buffer.from(value, 'base64url');
      if (bytes.length < 29) throw new Error('Invalid sealed two-factor secret');
      const cipher = createDecipheriv('aes-256-gcm', key, bytes.subarray(0, 12));
      cipher.setAAD(aad(userId));
      cipher.setAuthTag(bytes.subarray(-16));
      return Buffer.concat([cipher.update(bytes.subarray(12, -16)), cipher.final()]);
    },
  };
}
