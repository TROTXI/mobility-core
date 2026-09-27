// Ported from services/api at 43cdae0; provider/PIN behavior retained.
// Real Apple ID-token verification: checks the signature against Apple's JWKS
// and that the token was minted for OUR client (audience) by Apple (issuer).
// The default fetches Apple's keys. Tests inject local signed JWKS to exercise
// signature/claim checks without claiming live-provider delivery coverage.
//
// Two things differ from Google and both bite in production:
//
// 1. Apple's ID token carries NO name. The name is returned once, outside the
//    token, on the very first authorization only. Capturing it is the client's
//    job (see `POST /auth/apple`), not this verifier's.
// 2. Apple sends `email_verified` and `is_private_email` as either booleans or
//    the STRINGS "true"/"false", depending on the flow. Parsing them strictly as
//    booleans rejects real sign-ins.

import { createHash } from 'node:crypto';
import { createRemoteJWKSet, jwtVerify } from 'jose';
import type { JWTVerifyGetKey } from 'jose';
import { z } from 'zod';
import type { IdTokenVerifier, VerifiedIdentity } from './types.js';

const APPLE_JWKS = createRemoteJWKSet(new URL('https://appleid.apple.com/auth/keys'));
const APPLE_ISSUER = 'https://appleid.apple.com';

/** Apple's booleans arrive as `true` or as `"true"`. Accept both, default false. */
const appleBoolean = z
  .union([z.boolean(), z.enum(['true', 'false'])])
  .optional()
  .transform((v) => v === true || v === 'true');

const appleClaimsSchema = z.object({
  sub: z.string().min(1),
  email: z.string().optional(),
  email_verified: appleBoolean,
  is_private_email: appleBoolean,
  nonce: z.string().optional(),
});

/** Verifies Apple ID tokens for one or more of our client ids. */
export class AppleIdTokenVerifier implements IdTokenVerifier {
  /**
   * @param clientIds - every audience we accept: the iOS bundle id for native
   *   sign-in and the Services ID for the web/Android flow. They differ, and an
   *   app that ships on both platforms presents both.
   */
  constructor(
    private readonly clientIds: string[],
    private readonly keys: JWTVerifyGetKey = APPLE_JWKS,
  ) {
    if (!clientIds.length || clientIds.some((id) => !id.trim()))
      throw new Error('Apple audiences required');
  }

  /**
   * Verify an Apple ID token.
   *
   * @param idToken - the token from the client.
   * @param expectedNonce - the raw nonce the client generated, when it used one.
   * @returns the trusted identity.
   */
  async verify(idToken: string, expectedNonce?: string): Promise<VerifiedIdentity> {
    const { payload } = await jwtVerify(idToken, this.keys, {
      algorithms: ['RS256'],
      requiredClaims: ['sub', 'exp', 'iat'],
      issuer: APPLE_ISSUER,
      audience: this.clientIds,
    });
    const claims = appleClaimsSchema.parse(payload);

    assertNonce(claims.nonce, expectedNonce);

    // Same rule Google gets: an address Apple has not verified is not evidence
    // of anything, and we store it as the rider's contact detail.
    if (claims.email && !claims.email_verified) {
      throw new Error('Apple email not verified');
    }

    // A private-relay address is a real, deliverable address that forwards to
    // the rider. Treating it as absent would make them uncontactable for the
    // sake of tidiness.
    return {
      provider: 'apple',
      providerId: claims.sub,
      email: claims.email ?? null,
      displayName: null,
    };
  }
}

/**
 * Enforce the token's nonce against the one the client says it generated.
 *
 * A token carrying a nonce MUST be matched. Comparing only when both sides
 * happened to supply a value made replay protection opt-in for the attacker:
 * anyone holding a captured ID token simply omitted `nonce` from the request
 * and the comparison was skipped entirely.
 *
 * A token with no nonce claim is left alone; some Apple flows do not set one,
 * and rejecting those would break sign-in rather than harden it.
 *
 * @param claim - the `nonce` claim from the verified token, if it has one.
 * @param expected - the raw nonce the client sent with the request.
 * @throws when the token is nonced and the request cannot account for it.
 */
export function assertNonce(claim: string | undefined, expected: string | undefined): void {
  if (!claim) return;
  if (!expected) {
    throw new Error('Apple token carries a nonce but the request sent none');
  }
  if (!nonceMatches(claim, expected)) {
    throw new Error('Apple nonce mismatch');
  }
}

/**
 * Whether a token's nonce claim corresponds to the nonce the client generated.
 *
 * Apple echoes back exactly what the client sent, and clients differ: Apple's
 * own guidance is to send the SHA-256 of a random string, which is what the
 * Flutter and iOS SDKs do, while some send the raw value. Accepting either is
 * the difference between replay protection that works and a login screen that
 * rejects half our users.
 *
 * @param claim - the `nonce` claim from the verified token.
 * @param expected - the raw nonce the client generated.
 * @returns whether they correspond.
 */
export function nonceMatches(claim: string, expected: string): boolean {
  if (claim === expected) return true;
  return claim === createHash('sha256').update(expected).digest('hex');
}
