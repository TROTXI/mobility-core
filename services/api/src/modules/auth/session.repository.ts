// Refresh-token sessions. One row per issued refresh token (stored hashed),
// rotated on use and revocable on logout. Backs the refresh half of ADR-0007.

/** A persisted refresh-token session (the token itself is stored hashed). */
export interface Session {
  id: string;
  userId: string;
  /** SHA-256 of the refresh token; the raw token is never stored. */
  refreshTokenHash: string;
  expiresAt: Date;
  /** When the session was revoked (logout/rotation), or null if active. */
  revokedAt: Date | null;
  /** The session this one replaced on rotation, if any. */
  rotatedFrom: string | null;
  createdAt: Date;
}

/** Fields needed to create a session. */
export interface NewSession {
  userId: string;
  /** SHA-256 of the refresh token. */
  refreshTokenHash: string;
  expiresAt: Date;
  /** The prior session id when this is a rotation. */
  rotatedFrom?: string | null;
}

/** Persistence for refresh-token sessions. */
export interface SessionRepository {
  /**
   * Create a new session.
   *
   * @param input - the session to create.
   * @returns the persisted session.
   */
  create(input: NewSession): Promise<Session>;
  /**
   * Look up a session by its refresh-token hash.
   *
   * @param refreshTokenHash - SHA-256 of the presented refresh token.
   * @returns the session, or null if none matches.
   */
  findByHash(refreshTokenHash: string): Promise<Session | null>;
  /**
   * Revoke a session (no-op if already revoked).
   *
   * @param id - the session id to revoke.
   */
  revoke(id: string): Promise<void>;
}

/** In-memory {@link SessionRepository} for dev and unit tests. */
export class InMemorySessionRepository implements SessionRepository {
  private readonly sessions = new Map<string, Session>();

  async create(input: NewSession): Promise<Session> {
    const session: Session = {
      id: crypto.randomUUID(),
      userId: input.userId,
      refreshTokenHash: input.refreshTokenHash,
      expiresAt: input.expiresAt,
      revokedAt: null,
      rotatedFrom: input.rotatedFrom ?? null,
      createdAt: new Date(),
    };
    this.sessions.set(session.id, session);
    return session;
  }

  async findByHash(refreshTokenHash: string): Promise<Session | null> {
    for (const session of this.sessions.values()) {
      if (session.refreshTokenHash === refreshTokenHash) {
        return session;
      }
    }
    return null;
  }

  async revoke(id: string): Promise<void> {
    const session = this.sessions.get(id);
    if (session && !session.revokedAt) {
      session.revokedAt = new Date();
    }
  }
}
