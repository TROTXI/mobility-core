// Real Apple token client: exchanges authorization codes and revokes tokens.
// Network-bound and key-signing, so excluded from unit coverage like the other
// *.apple.ts / *.google.ts adapters — exercised against Apple directly.

import { SignJWT, importPKCS8 } from 'jose';
import type { AppleTokenClient, AppleTokens } from './apple-token.client';

const APPLE_TOKEN_URL = 'https://appleid.apple.com/auth/token';
const APPLE_REVOKE_URL = 'https://appleid.apple.com/auth/revoke';

/** Apple caps the client secret at 6 months; 10 minutes is all a request needs. */
const CLIENT_SECRET_TTL = '10m';

/** Credentials for signing the client secret Apple's token endpoints require. */
export interface AppleTokenClientConfig {
  /** The Services ID or bundle id the code was issued to. */
  clientId: string;
  /** The Apple Developer team id. */
  teamId: string;
  /** The Key ID of the Sign in with Apple `.p8` key. */
  keyId: string;
  /** The `.p8` private key, PKCS#8 PEM. A SECRET — dashboard only. */
  privateKey: string;
}

/** Apple's real token and revocation endpoints, authenticated with the `.p8`. */
export class AppleHttpTokenClient implements AppleTokenClient {
  /** @param config - the client id and signing credentials. */
  constructor(private readonly config: AppleTokenClientConfig) {}

  async exchangeCode(code: string): Promise<AppleTokens> {
    const body = new URLSearchParams({
      client_id: this.config.clientId,
      client_secret: await this.clientSecret(),
      code,
      grant_type: 'authorization_code',
    });
    const res = await fetch(APPLE_TOKEN_URL, {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body,
    });
    if (!res.ok) {
      throw new Error(`Apple code exchange failed (${res.status})`);
    }
    const json = (await res.json()) as { refresh_token?: string };
    return { refreshToken: json.refresh_token ?? null };
  }

  async revoke(refreshToken: string): Promise<void> {
    const body = new URLSearchParams({
      client_id: this.config.clientId,
      client_secret: await this.clientSecret(),
      token: refreshToken,
      token_type_hint: 'refresh_token',
    });
    const res = await fetch(APPLE_REVOKE_URL, {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body,
    });
    if (!res.ok) {
      throw new Error(`Apple revocation failed (${res.status})`);
    }
  }

  /**
   * Mint the short-lived ES256 JWT Apple takes in place of a client secret.
   *
   * @returns the signed client secret.
   */
  private async clientSecret(): Promise<string> {
    const key = await importPKCS8(this.config.privateKey, 'ES256');
    return new SignJWT({})
      .setProtectedHeader({ alg: 'ES256', kid: this.config.keyId })
      .setIssuer(this.config.teamId)
      .setAudience('https://appleid.apple.com')
      .setSubject(this.config.clientId)
      .setIssuedAt()
      .setExpirationTime(CLIENT_SECRET_TTL)
      .sign(key);
  }
}
