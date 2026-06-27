// Refresh-token sessions. One row per issued refresh token (stored hashed),
// rotated on use and revocable on logout. Backs the refresh half of ADR-0007.

export interface Session {
  id: string;
  userId: string;
  refreshTokenHash: string;
  expiresAt: Date;
  revokedAt: Date | null;
  rotatedFrom: string | null;
  createdAt: Date;
}

export interface NewSession {
  userId: string;
  refreshTokenHash: string;
  expiresAt: Date;
  rotatedFrom?: string | null;
}

export interface SessionRepository {
  create(input: NewSession): Promise<Session>;
  findByHash(refreshTokenHash: string): Promise<Session | null>;
  revoke(id: string): Promise<void>;
}

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
