// Refresh-token helpers. The raw token is returned to the client exactly once;
// only its SHA-256 hash is stored (sessions.refresh_token_hash), so a database
// leak never exposes usable tokens. See ADR-0007.

import { createHash, randomBytes } from 'node:crypto';

export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

export interface GeneratedRefreshToken {
  /** Raw token — returned to the client, never persisted. */
  token: string;
  /** SHA-256 of the token — what we store and look up by. */
  hash: string;
  expiresAt: Date;
}

export function generateRefreshToken(ttlDays: number): GeneratedRefreshToken {
  const token = randomBytes(32).toString('base64url');
  return {
    token,
    hash: hashToken(token),
    expiresAt: new Date(Date.now() + ttlDays * 24 * 60 * 60 * 1000),
  };
}
