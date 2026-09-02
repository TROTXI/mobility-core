// AuthService — sign-in/refresh/logout, orchestrating the repos + JWT +
// verifier. Reuse detection (#83): replaying an already-rotated refresh token
// revokes every session for the user.
//
// Not yet transactional: a concurrent FIRST sign-in can leave an orphan user row
// (harmless — never linked), and rotation revokes-then-creates, so a crash
// mid-way just forces re-login.

import type { JwtService } from './jwt';
import type { AuthIdentityRepository } from './auth-identity.repository';
import type { AppleTokenClient } from './apple-token.client';
import type { AuthProvider, IdTokenVerifier, VerifiedIdentity } from './id-token-verifier';
import type { Session, SessionRepository } from './session.repository';
import { generateRefreshToken, hashToken } from './tokens';
import type { User, UserRepository } from '../users/user.repository';

/** Thrown when sign-in is attempted for a provider with no verifier configured (prod without GOOGLE_CLIENT_ID / APPLE_CLIENT_ID). Routes map it to 503. */
export class SignInNotConfiguredError extends Error {}

/**
 * The longest display name we'll accept from a client.
 *
 * Apple's name arrives as client-supplied input rather than a signed claim (see
 * {@link AuthService.signIn}), so it needs a bound. Long enough for real Ghanaian
 * names, which are routinely four or five parts.
 */
const MAX_DISPLAY_NAME = 80;

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
  /**
   * True only on the sign-in that created the account (#182). Lets callers
   * branch on first contact — welcome flows, onboarding, activation metrics —
   * without a second round trip to guess from `createdAt`.
   */
  isNewUser: boolean;
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
  /**
   * One verifier per provider. A provider absent from the map has sign-in
   * disabled and its route answers 503, so Apple being unconfigured never takes
   * Google down with it.
   */
  verifiers?: Partial<Record<AuthProvider, IdTokenVerifier>>;
  /**
   * Apple's token endpoints (#213). Undefined when the signing key isn't
   * configured, in which case codes are simply not exchanged and sign-in works
   * exactly as before.
   */
  appleTokens?: AppleTokenClient;
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

/**
 * Trim and bound a client-supplied display name, or null when there isn't one.
 *
 * @param name - the raw name from the request body.
 * @returns a safe display name, or null.
 */
function cleanDisplayName(name?: string): string | null {
  const trimmed = name?.trim();
  return trimmed ? trimmed.slice(0, MAX_DISPLAY_NAME) : null;
}

/** Sign-in, refresh, and logout orchestration (see the file header). */
export class AuthService {
  /** @param deps - repositories, the JWT service, and the ID-token verifier. */
  constructor(private readonly deps: AuthServiceDeps) {}

  /**
   * Verify a provider ID token, find-or-create the matching user, and issue a
   * fresh access + refresh token pair.
   *
   * `opts.displayName` exists for Apple, which returns the user's name exactly
   * once — on the first authorization, outside the ID token — and never again.
   * It is therefore client-supplied rather than a signed claim, so it is capped
   * and used ONLY when creating the account. It can never rename an existing
   * user, which is the difference between capturing a name we'd otherwise lose
   * forever and letting any caller relabel someone else's account.
   *
   * @param idToken - the provider ID token from the client.
   * @param provider - which provider minted it.
   * @param opts - optional extras the token itself cannot carry.
   * @param opts.displayName - the name Apple returned on first authorization.
   * @param opts.nonce - the raw nonce the client generated, for replay checking.
   * @param opts.authorizationCode - Apple's one-time code, exchanged for the
   *   refresh token we need to revoke access when the account is deleted.
   * @returns the user and their new tokens.
   * @throws SignInNotConfiguredError when that provider has no verifier wired.
   * @throws when the ID token is invalid/untrusted (from the verifier).
   */
  async signIn(
    idToken: string,
    provider: AuthProvider = 'google',
    opts: { displayName?: string; nonce?: string; authorizationCode?: string } = {},
  ): Promise<AuthResult> {
    const verifier = this.deps.verifiers?.[provider];
    if (!verifier) {
      throw new SignInNotConfiguredError('Sign-in is not configured');
    }
    const identity = await verifier.verify(idToken, opts.nonce); // throws if invalid
    const providerRefreshToken = await this.exchangeAppleCode(provider, opts.authorizationCode);
    const { user, isNewUser } = await this.findOrCreateUser(
      {
        ...identity,
        displayName: identity.displayName ?? cleanDisplayName(opts.displayName),
      },
      providerRefreshToken,
    );
    const tokens = await this.issueTokens(user);
    return { user, isNewUser, ...tokens };
  }

  /**
   * Trade Apple's authorization code for the refresh token we need at deletion.
   *
   * Best effort on purpose. A rider signing in should not be turned away because
   * Apple's token endpoint is having a bad minute; the cost of failing is that we
   * cannot revoke later, which is worth strictly less than the sign-in itself.
   *
   * @param provider - the provider being signed in with.
   * @param code - the authorization code, when the client sent one.
   * @returns the refresh token, or null when there is nothing to exchange.
   */
  private async exchangeAppleCode(provider: AuthProvider, code?: string): Promise<string | null> {
    if (provider !== 'apple' || !code || !this.deps.appleTokens) return null;
    try {
      return (await this.deps.appleTokens.exchangeCode(code)).refreshToken;
    } catch {
      return null;
    }
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
   * List a user's active sessions (their logged-in devices) for account-security
   * display.
   *
   * @param userId - the authenticated user.
   * @returns the user's active sessions.
   */
  async listSessions(userId: string): Promise<Session[]> {
    return this.deps.sessions.listActiveForUser(userId);
  }

  /**
   * Revoke one of the user's sessions ("log out this device"). A no-op if the
   * session is unknown or belongs to someone else, so a user can only revoke
   * their own.
   *
   * @param userId - the authenticated user.
   * @param sessionId - the session to revoke.
   */
  async revokeSession(userId: string, sessionId: string): Promise<void> {
    const session = await this.deps.sessions.findById(sessionId);
    if (session && session.userId === userId) {
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
   * @param providerRefreshToken - Apple's refresh token, when we obtained one.
   * @returns the existing or newly created user.
   */
  private async findOrCreateUser(
    identity: VerifiedIdentity,
    providerRefreshToken: string | null = null,
  ): Promise<{ user: User; isNewUser: boolean }> {
    const existing = await this.deps.authIdentities.findByProvider(
      identity.provider,
      identity.providerId,
    );
    if (existing) {
      // Backfill for anyone who linked Apple before we started asking for codes:
      // their next sign-in is the only chance to become revocable.
      if (providerRefreshToken) {
        await this.deps.authIdentities.saveRefreshToken(existing.id, providerRefreshToken);
      }
      const user = await this.deps.users.findById(existing.userId);
      // Backfill the verified email for anyone who signed up before #182, so
      // existing riders become reachable on their next sign-in rather than
      // staying permanently uncontactable. Never overwrites a stored value.
      if (user) return { user: await this.backfillEmail(user, identity), isNewUser: false };
    }

    const user = await this.deps.users.create({
      displayName: identity.displayName ?? 'New User',
      email: identity.email,
    });
    try {
      await this.deps.authIdentities.create({
        userId: user.id,
        provider: identity.provider,
        providerId: identity.providerId,
        providerRefreshToken,
      });
    } catch (err) {
      // Lost a concurrent first sign-in race — the identity now exists; reuse it.
      if (isUniqueViolation(err)) {
        const winner = await this.deps.authIdentities.findByProvider(
          identity.provider,
          identity.providerId,
        );
        const user2 = winner && (await this.deps.users.findById(winner.userId));
        if (user2) return { user: user2, isNewUser: false };
      }
      throw err;
    }
    return { user, isNewUser: true };
  }

  /**
   * Fill in a missing email from the verified identity. A no-op when the user
   * already has one or the provider did not supply one.
   *
   * @param user - the signing-in user.
   * @param identity - the verified provider identity.
   * @returns the user, updated when a backfill happened.
   */
  private async backfillEmail(user: User, identity: VerifiedIdentity): Promise<User> {
    if (user.email || !identity.email) return user;
    return (await this.deps.users.backfillContact(user.id, { email: identity.email })) ?? user;
  }
}
