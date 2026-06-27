// AuthService — the first service-layer service (ADR-0009 layering: routes ->
// services -> repositories). It owns the sign-in/refresh/logout *business logic*
// and orchestrates the repos + JWT + verifier; the routes stay thin.
//
// Not wrapped in a DB transaction yet: on a concurrent *first* sign-in for a new
// identity the loser may leave an orphan user row (harmless — never linked), and
// refresh rotation revokes-then-creates (a crash mid-way just forces re-login).
// Transactional sign-in + refresh-reuse detection are slice-3 hardening.

import type { JwtService } from './jwt';
import type { AuthIdentityRepository } from './auth-identity.repository';
import type { IdTokenVerifier, VerifiedIdentity } from './id-token-verifier';
import type { SessionRepository } from './session.repository';
import { generateRefreshToken, hashToken } from './tokens';
import type { User, UserRepository } from '../users/user.repository';

export class SignInNotConfiguredError extends Error {}
export class InvalidRefreshTokenError extends Error {}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface AuthResult extends AuthTokens {
  user: User;
}

export interface AuthServiceDeps {
  users: UserRepository;
  authIdentities: AuthIdentityRepository;
  sessions: SessionRepository;
  jwt: JwtService;
  /** Undefined when sign-in isn't configured (e.g. prod without GOOGLE_CLIENT_ID). */
  verifier?: IdTokenVerifier;
  refreshTtlDays: number;
}

function isUniqueViolation(err: unknown): boolean {
  return (err as { code?: string }).code === '23505';
}

export class AuthService {
  constructor(private readonly deps: AuthServiceDeps) {}

  /** Verify a provider ID token, find-or-create the user, and issue tokens. */
  async signIn(idToken: string): Promise<AuthResult> {
    if (!this.deps.verifier) {
      throw new SignInNotConfiguredError('Sign-in is not configured');
    }
    const identity = await this.deps.verifier.verify(idToken); // throws if invalid
    const user = await this.findOrCreateUser(identity);
    const tokens = await this.issueTokens(user);
    return { user, ...tokens };
  }

  /** Rotate a valid refresh token: revoke the old session, issue a new pair. */
  async refresh(refreshToken: string): Promise<AuthTokens> {
    const session = await this.deps.sessions.findByHash(hashToken(refreshToken));
    if (!session || session.revokedAt !== null || session.expiresAt <= new Date()) {
      throw new InvalidRefreshTokenError('Invalid or expired refresh token');
    }
    const user = await this.deps.users.findById(session.userId);
    if (!user) {
      throw new InvalidRefreshTokenError('Invalid or expired refresh token');
    }
    await this.deps.sessions.revoke(session.id);
    return this.issueTokens(user, session.id);
  }

  /** Revoke the session for a refresh token. Idempotent — unknown tokens no-op. */
  async logout(refreshToken: string): Promise<void> {
    const session = await this.deps.sessions.findByHash(hashToken(refreshToken));
    if (session && session.revokedAt === null) {
      await this.deps.sessions.revoke(session.id);
    }
  }

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
