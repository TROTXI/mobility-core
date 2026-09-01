// Real Apple ID-token verification: checks the signature against Apple's JWKS
// and that the token was minted for OUR client (audience) by Apple (issuer).
// Network-bound (fetches Apple's keys), so excluded from unit coverage like the
// *.pg.ts adapters — exercised via real sign-in / manual testing.
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
import { z } from 'zod';
import type { IdTokenVerifier, VerifiedIdentity } from './id-token-verifier';

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
  constructor(private readonly clientIds: string[]) {}

  /**
   * Verify an Apple ID token.
   *
   * @param idToken - the token from the client.
   * @param expectedNonce - the raw nonce the client generated, when it used one.
   * @returns the trusted identity.
   */
  async verify(idToken: string, expectedNonce?: string): Promise<VerifiedIdentity> {
    const { payload } = await jwtVerify(idToken, APPLE_JWKS, {
      issuer: APPLE_ISSUER,
      audience: this.clientIds,
    });
    const claims = appleClaimsSchema.parse(payload);

    if (claims.nonce && expectedNonce && !nonceMatches(claims.nonce, expectedNonce)) {
      throw new Error('Apple nonce mismatch');
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
