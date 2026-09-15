// Ported from services/api at 43cdae0; provider/PIN behavior retained.
// Real Google ID-token verification: checks the signature against Google's JWKS
// and that the token was minted for OUR client (audience) by Google (issuer).
// The default fetches Google's keys. Tests inject local signed JWKS to exercise
// signature/claim checks without claiming live-provider delivery coverage.

import { createRemoteJWKSet, jwtVerify } from 'jose';
import type { JWTVerifyGetKey } from 'jose';
import { z } from 'zod';
import type { IdTokenVerifier, VerifiedIdentity } from './types.js';

const GOOGLE_JWKS = createRemoteJWKSet(new URL('https://www.googleapis.com/oauth2/v3/certs'));
const GOOGLE_ISSUERS = ['https://accounts.google.com', 'accounts.google.com'];

const googleClaimsSchema = z.object({
  sub: z.string().min(1),
  email: z.string().optional(),
  email_verified: z.boolean().optional(),
  name: z.string().optional(),
});

export class GoogleIdTokenVerifier implements IdTokenVerifier {
  constructor(
    private readonly clientId: string,
    private readonly keys: JWTVerifyGetKey = GOOGLE_JWKS,
  ) {
    if (!clientId.trim()) throw new Error('Google audience required');
  }

  async verify(idToken: string): Promise<VerifiedIdentity> {
    const { payload } = await jwtVerify(idToken, this.keys, {
      algorithms: ['RS256'],
      requiredClaims: ['sub', 'exp', 'iat'],
      issuer: GOOGLE_ISSUERS,
      audience: this.clientId,
    });
    const claims = googleClaimsSchema.parse(payload);
    if (claims.email && claims.email_verified !== true) {
      throw new Error('Google email not verified');
    }
    return {
      provider: 'google',
      providerId: claims.sub,
      email: claims.email ?? null,
      displayName: claims.name ?? null,
    };
  }
}
