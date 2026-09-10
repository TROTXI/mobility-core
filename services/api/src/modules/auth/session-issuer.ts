// Minting a session is the same operation whichever door the user came through:
// create a refresh-token row, sign a short-lived access token from the user's
// role. Social sign-in and driver sign-in (#223) share it so there is one place
// where a session's lifetime and claims are decided, rather than two that drift.

import type { JwtService } from './jwt';
import type { SessionRepository } from './session.repository';
import { generateRefreshToken } from './tokens';
import type { User } from '../users/user.repository';

/** An access token (short-lived) paired with a refresh token (long-lived). */
export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

/** What issuing a session needs. */
export interface SessionIssuerDeps {
  sessions: SessionRepository;
  jwt: JwtService;
}

/**
 * Create a session and mint the token pair for a user.
 *
 * @param deps - the session store and the token signer.
 * @param user - the authenticated user.
 * @param opts - lifetime and rotation lineage.
 * @param opts.refreshTtlDays - how long the refresh token lives. Callers vary
 *   this: a driver signing in on a shared depot handset gets a shift, not a
 *   month.
 * @param opts.rotatedFrom - the prior session id when this is a refresh.
 * @returns the new token pair.
 */
export async function issueSessionTokens(
  deps: SessionIssuerDeps,
  user: User,
  opts: { refreshTtlDays: number; rotatedFrom?: string },
): Promise<AuthTokens> {
  const refresh = generateRefreshToken(opts.refreshTtlDays);
  await deps.sessions.create({
    userId: user.id,
    refreshTokenHash: refresh.hash,
    expiresAt: refresh.expiresAt,
    rotatedFrom: opts.rotatedFrom,
  });
  const accessToken = await deps.jwt.signAccessToken({ userId: user.id, role: user.role });
  return { accessToken, refreshToken: refresh.token };
}
