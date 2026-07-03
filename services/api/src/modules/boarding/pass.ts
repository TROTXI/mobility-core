// Boarding passes — short-lived signed tokens a rider shows as a QR (#20). Signed
// with the server key but a distinct audience ('trotxi-pass'), so a pass can't be
// used as an access token (or vice versa). The short TTL makes the QR rotate, and
// each pass carries a unique `jti` so a scan can be marked consumed (single-use).
// This is *integrity* only: verifying a pass proves it's a genuine, unexpired
// pass for a rider — eligibility gates (active membership, token balance) layer
// on with the money work (#19/#21).

import { SignJWT, jwtVerify } from 'jose';

/** The JWT audience that marks a token as a boarding pass (never an access token). */
export const PASS_AUDIENCE = 'trotxi-pass';
const ALG = 'HS256';

// Verifier leeway for issuer/verifier clock drift across instances. With only a
// 60s TTL, drift would otherwise eat a real chunk of the pass's usable lifetime.
const CLOCK_TOLERANCE_SECONDS = 5;

/** A signed boarding pass plus how long it stays valid. */
export interface IssuedPass {
  /** The signed pass token — rendered as a QR by the app. */
  pass: string;
  /** Lifetime in seconds; the app refreshes the QR before it lapses. */
  expiresInSeconds: number;
}

/** The claims recovered from a verified pass. */
export interface VerifiedPass {
  /** The rider the pass was issued to. */
  userId: string;
  /** The pass's unique id — the single-use key. */
  jti: string;
}

/**
 * Sign a short-lived boarding pass for a rider.
 *
 * @param userId - the rider the pass belongs to.
 * @param secret - the server signing key.
 * @param ttlSeconds - pass lifetime (default 60s, so the QR rotates).
 * @returns the signed pass token and its lifetime.
 */
export async function signPass(
  userId: string,
  secret: string,
  ttlSeconds = 60,
): Promise<IssuedPass> {
  const key = new TextEncoder().encode(secret);
  const pass = await new SignJWT({})
    .setProtectedHeader({ alg: ALG })
    .setSubject(userId)
    .setJti(crypto.randomUUID())
    .setIssuedAt()
    .setAudience(PASS_AUDIENCE)
    .setExpirationTime(`${ttlSeconds}s`)
    .sign(key);
  return { pass, expiresInSeconds: ttlSeconds };
}

/**
 * Verify a scanned boarding pass.
 *
 * @param pass - the token decoded from the scanned QR.
 * @param secret - the server signing key.
 * @returns the rider id the pass was issued to and the pass's unique jti.
 * @throws if the pass is forged, expired, or not a boarding pass (wrong audience).
 */
export async function verifyPass(pass: string, secret: string): Promise<VerifiedPass> {
  const key = new TextEncoder().encode(secret);
  const { payload } = await jwtVerify(pass, key, {
    audience: PASS_AUDIENCE,
    clockTolerance: CLOCK_TOLERANCE_SECONDS,
  });
  if (!payload.sub || !payload.jti) throw new Error('Pass is missing its subject or jti');
  return { userId: payload.sub, jti: payload.jti };
}
