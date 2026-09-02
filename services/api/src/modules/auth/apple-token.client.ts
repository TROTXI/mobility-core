// Apple's token endpoints (#213) — the half of the OAuth flow that verifying an
// ID token skips.
//
// Sign-in itself needs none of this: we check the ID token against Apple's JWKS
// and we're done. Revocation does. Apple requires an app offering both Sign in
// with Apple and account deletion to revoke at delete time, and revoking needs a
// token, which only the authorization-code exchange yields.
//
// The real client is network-bound and signs with a private key, so it lives in
// *.apple.ts alongside the verifier and is excluded from unit coverage. The fake
// is what dev and tests run against.

/** What an authorization-code exchange gives us back. */
export interface AppleTokens {
  /** Apple's refresh token, when the exchange returned one. */
  refreshToken: string | null;
}

/** Apple's token and revocation endpoints. */
export interface AppleTokenClient {
  /**
   * Exchange a one-time authorization code for Apple's tokens.
   *
   * @param code - the authorization code from the client.
   * @returns the tokens Apple issued.
   * @throws when Apple rejects the exchange.
   */
  exchangeCode(code: string): Promise<AppleTokens>;
  /**
   * Revoke a refresh token, severing the link at Apple's end.
   *
   * @param refreshToken - the token to revoke.
   * @throws when Apple rejects the revocation.
   */
  revoke(refreshToken: string): Promise<void>;
}

/**
 * Dev/test client: records calls, talks to nobody. Wired outside production so
 * the deletion path is exercisable without Apple credentials.
 */
export class FakeAppleTokenClient implements AppleTokenClient {
  readonly exchanged: string[] = [];
  readonly revoked: string[] = [];

  async exchangeCode(code: string): Promise<AppleTokens> {
    this.exchanged.push(code);
    return { refreshToken: `fake-apple-refresh-${code}` };
  }

  async revoke(refreshToken: string): Promise<void> {
    this.revoked.push(refreshToken);
  }
}
