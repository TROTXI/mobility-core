// Real Google ID-token verification: checks the signature against Google's JWKS
// and that the token was minted for OUR client (audience) by Google (issuer).
// Network-bound (fetches Google's keys), so excluded from unit coverage like the
// *.pg.ts adapters — exercised via real sign-in / manual testing.

import { createRemoteJWKSet, jwtVerify } from 'jose';
import { z } from 'zod';
import type { IdTokenVerifier, VerifiedIdentity } from './id-token-verifier';

const GOOGLE_JWKS = createRemoteJWKSet(new URL('https://www.googleapis.com/oauth2/v3/certs'));
const GOOGLE_ISSUERS = ['https://accounts.google.com', 'accounts.google.com'];

const googleClaimsSchema = z.object({
  sub: z.string().min(1),
  email: z.string().optional(),
  email_verified: z.boolean().optional(),
  name: z.string().optional(),
});

export class GoogleIdTokenVerifier implements IdTokenVerifier {
  constructor(private readonly clientId: string) {}

  async verify(idToken: string): Promise<VerifiedIdentity> {
    const { payload } = await jwtVerify(idToken, GOOGLE_JWKS, {
      issuer: GOOGLE_ISSUERS,
      audience: this.clientId,
    });
    const claims = googleClaimsSchema.parse(payload);
    if (claims.email_verified === false) {
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
