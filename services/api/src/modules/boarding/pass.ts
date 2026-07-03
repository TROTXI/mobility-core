// Boarding passes — short-lived signed tokens a rider shows as a QR (#20). Signed
// with the server key but a distinct audience ('trotxi-pass'), so a pass can't be
// used as an access token (or vice versa). The short TTL makes the QR rotate, so
// a screenshot can't be reused. This is *integrity* only: verifying a pass proves
// it's a genuine, unexpired pass for a rider — eligibility gates (active
// membership, token balance) layer on with the money work (#19/#21).

import { SignJWT, jwtVerify } from 'jose';

const PASS_AUDIENCE = 'trotxi-pass';
const ALG = 'HS256';

/** A signed boarding pass plus how long it stays valid. */
export interface IssuedPass {
  /** The signed pass token — rendered as a QR by the app. */
  pass: string;
  /** Lifetime in seconds; the app refreshes the QR before it lapses. */
  expiresInSeconds: number;
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
 * @returns the rider id the pass was issued to.
 * @throws if the pass is forged, expired, or not a boarding pass (wrong audience).
 */
export async function verifyPass(pass: string, secret: string): Promise<{ userId: string }> {
  const key = new TextEncoder().encode(secret);
  const { payload } = await jwtVerify(pass, key, { audience: PASS_AUDIENCE });
  if (!payload.sub) throw new Error('Pass is missing its subject');
  return { userId: payload.sub };
}
