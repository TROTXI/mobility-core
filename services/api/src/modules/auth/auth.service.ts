// AuthService — the first service-layer service (ADR-0009 layering: routes ->
// services -> repositories). It owns the sign-in/refresh/logout *business logic*
// and orchestrates the repos + JWT + verifier; the routes stay thin.
//
// Not wrapped in a DB transaction yet: on a concurrent *first* sign-in for a new
// identity the loser may leave an orphan user row (harmless — never linked), and
// refresh rotation revokes-then-creates (a crash mid-way just forces re-login).
// Transactional sign-in is slice-3 hardening. Refresh-token reuse detection is
// implemented (#83): replaying an already-rotated token revokes every session
// for the user.

import type { JwtService } from './jwt';
import type { AuthIdentityRepository } from './auth-identity.repository';
import type { IdTokenVerifier, VerifiedIdentity } from './id-token-verifier';
import type { SessionRepository } from './session.repository';
import { generateRefreshToken, hashToken } from './tokens';
import type { User, UserRepository } from '../users/user.repository';

/** Thrown when sign-in is attempted but no verifier is configured (prod without GOOGLE_CLIENT_ID). Routes map it to 503. */
export class SignInNotConfiguredError extends Error {}

/** Thrown when a refresh/logout token is missing, expired, or revoked. Routes map it to 401. */
export class InvalidRefreshTokenError extends Error {}

/** An access token (short-lived) paired with a refresh token (long-lived). */
export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

/** A successful sign-in: the user plus their fresh token pair. */
export interface AuthResult extends AuthTokens {
  user: User;
}

/** Collaborators for {@link AuthService}, injected at app wiring (app.ts). */
export interface AuthServiceDeps {
  /** User records. */
  users: UserRepository;
  /** Links a provider identity (e.g. Google) to a user. */
  authIdentities: AuthIdentityRepository;
  /** Refresh-token sessions (hashed, rotated, revocable). */
  sessions: SessionRepository;
  /** Signs/verifies access tokens. */
  jwt: JwtService;
  /** Undefined when sign-in isn't configured (e.g. prod without GOOGLE_CLIENT_ID). */
  verifier?: IdTokenVerifier;
  /** Refresh-token lifetime in days. */
  refreshTtlDays: number;
}

/**
 * True when a pg error is a unique-constraint violation (SQLSTATE 23505).
 *
 * @param err - the caught error (unknown shape).
 * @returns whether it is a Postgres unique-violation.
 */
function isUniqueViolation(err: unknown): boolean {
  return (err as { code?: string }).code === '23505';
}

/** Sign-in, refresh, and logout orchestration (see the file header). */
export class AuthService {
  /** @param deps - repositories, the JWT service, and the ID-token verifier. */
  constructor(private readonly deps: AuthServiceDeps) {}

  /**
   * Verify a provider ID token, find-or-create the matching user, and issue a
   * fresh access + refresh token pair.
   *
   * @param idToken - the provider ID token from the client.
   * @returns the user and their new tokens.
   * @throws SignInNotConfiguredError when no verifier is wired.
   * @throws when the ID token is invalid/untrusted (from the verifier).
   */
  async signIn(idToken: string): Promise<AuthResult> {
    if (!this.deps.verifier) {
      throw new SignInNotConfiguredError('Sign-in is not configured');
    }
    const identity = await this.deps.verifier.verify(idToken); // throws if invalid
    const user = await this.findOrCreateUser(identity);
    const tokens = await this.issueTokens(user);
    return { user, ...tokens };
  }

  /**
   * Rotate a valid refresh token: revoke the presented session and issue a new
   * token pair (single-use refresh tokens). Detects **reuse** — if an
   * already-rotated (consumed) token is replayed, every session for that user is
   * revoked, since a valid refresh token appearing after rotation signals theft.
   *
   * @param refreshToken - the raw refresh token presented by the client.
   * @returns a new access + refresh token pair.
   * @throws InvalidRefreshTokenError if the token is unknown, revoked, or expired.
   */
  async refresh(refreshToken: string): Promise<AuthTokens> {
    const session = await this.deps.sessions.findByHash(hashToken(refreshToken));
    if (!session || session.expiresAt <= new Date()) {
      throw new InvalidRefreshTokenError('Invalid or expired refresh token');
    }
    if (session.revokedAt !== null) {
      // A revoked token was presented. If it was consumed by *rotation* (a newer
      // session was rotated from it), this is refresh-token reuse — a compromise
      // signal — so revoke every session for the user (kills both the attacker's
      // and the victim's tokens; everyone must re-authenticate). A token revoked
      // by *logout* has no descendant, so it's just an invalid token.
      if (await this.deps.sessions.wasRotated(session.id)) {
        await this.deps.sessions.revokeAllForUser(session.userId);
      }
      throw new InvalidRefreshTokenError('Invalid or expired refresh token');
    }
    const user = await this.deps.users.findById(session.userId);
    if (!user) {
      throw new InvalidRefreshTokenError('Invalid or expired refresh token');
    }
    await this.deps.sessions.revoke(session.id);
    return this.issueTokens(user, session.id);
  }

  /**
   * Revoke the session behind a refresh token. Idempotent — an unknown or
   * already-revoked token is a no-op.
   *
   * @param refreshToken - the raw refresh token to invalidate.
   */
  async logout(refreshToken: string): Promise<void> {
    const session = await this.deps.sessions.findByHash(hashToken(refreshToken));
    if (session && session.revokedAt === null) {
      await this.deps.sessions.revoke(session.id);
    }
  }

  /**
   * Create a session and mint the access + refresh token pair for a user.
   *
   * @param user - the authenticated user.
   * @param rotatedFrom - the prior session id when this is a refresh rotation.
   * @returns the new token pair.
   */
  private async issueTokens(user: User, rotatedFrom?: string): Promise<AuthTokens> {
    const refresh = generateRefreshToken(this.deps.refreshTtlDays);
    await this.deps.sessions.create({
      userId: user.id,
      refreshTokenHash: refresh.hash,
      expiresAt: refresh.expiresAt,
      rotatedFrom,
    });
    const accessToken = await this.deps.jwt.signAccessToken({ userId: user.id, role: user.role });
    return { accessToken, refreshToken: refresh.token };
  }

  /**
   * Resolve the user for a verified identity, creating the user + auth_identity
   * on first sign-in. Handles the concurrent-first-sign-in race by reusing the
   * winner's identity.
   *
   * @param identity - the verified provider identity.
   * @returns the existing or newly created user.
   */
  private async findOrCreateUser(identity: VerifiedIdentity): Promise<User> {
    const existing = await this.deps.authIdentities.findByProvider(
      identity.provider,
      identity.providerId,
    );
    if (existing) {
      const user = await this.deps.users.findById(existing.userId);
      if (user) return user;
    }

    const user = await this.deps.users.create({ displayName: identity.displayName ?? 'New User' });
    try {
      await this.deps.authIdentities.create({
        userId: user.id,
        provider: identity.provider,
        providerId: identity.providerId,
      });
    } catch (err) {
      // Lost a concurrent first sign-in race — the identity now exists; reuse it.
      if (isUniqueViolation(err)) {
        const winner = await this.deps.authIdentities.findByProvider(
          identity.provider,
          identity.providerId,
        );
        const user2 = winner && (await this.deps.users.findById(winner.userId));
        if (user2) return user2;
      }
      throw err;
    }
    return user;
  }
}
