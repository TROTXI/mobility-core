// Social sign-in verification. The AuthService depends on this interface, not on
// any provider — so Google and Apple are pluggable, and tests use the fake. The
// real implementations (JWKS over the network) live in id-token-verifier.google.ts
// and id-token-verifier.apple.ts. See ADR-0007.

import { z } from 'zod';

export type AuthProvider = 'google' | 'apple';

/** The trustworthy identity extracted from a verified provider ID token. */
export interface VerifiedIdentity {
  provider: AuthProvider;
  /** The provider's stable subject id (auth_identity.provider_id). */
  providerId: string;
  email: string | null;
  displayName: string | null;
}

/** Verifies a provider ID token and extracts the trusted identity. */
export interface IdTokenVerifier {
  /**
   * Verify a provider ID token.
   *
   * @param idToken - the provider-issued ID token to verify.
   * @param expectedNonce - the raw nonce the client generated, where it used one
   *   (Apple). Providers that don't carry a nonce ignore it.
   * @returns the trusted identity extracted from it.
   * @throws if the token is invalid or untrusted.
   */
  verify(idToken: string, expectedNonce?: string): Promise<VerifiedIdentity>;
}

const fakeClaimsSchema = z.object({
  sub: z.string().min(1),
  email: z.string().optional(),
  name: z.string().optional(),
});

/**
 * Dev/test verifier: the "token" is a JSON blob of claims. Lets the API and the
 * mobile app exercise the full sign-in flow with no Google or Apple setup. NEVER
 * used in production — the server only wires this outside production (see
 * server.ts).
 */
export class FakeIdTokenVerifier implements IdTokenVerifier {
  /** @param provider - which provider this fake stands in for. */
  constructor(private readonly provider: AuthProvider = 'google') {}

  async verify(idToken: string): Promise<VerifiedIdentity> {
    let raw: unknown;
    try {
      raw = JSON.parse(idToken);
    } catch {
      throw new Error('fake id token must be JSON');
    }
    const claims = fakeClaimsSchema.parse(raw);
    return {
      provider: this.provider,
      providerId: claims.sub,
      email: claims.email ?? null,
      displayName: claims.name ?? null,
    };
  }
}
