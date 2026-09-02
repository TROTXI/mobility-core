// Links a provider identity (google/apple + subject id) to a Trotxi user. The
// (provider, provider_id) pair is unique, so a returning user maps to the same
// account. Backs the social-first sign-in in ADR-0007.

import type { AuthProvider } from './id-token-verifier';

/** Links a provider account (provider + subject id) to a Trotxi user. */
export interface AuthIdentity {
  id: string;
  userId: string;
  provider: AuthProvider;
  /** The provider's stable subject id. */
  providerId: string;
  /**
   * The provider's own refresh token, where we hold one (#213).
   *
   * Apple only, and only when the client sent an authorization code. Kept so
   * account deletion can revoke our access at Apple rather than just forgetting
   * the link locally. Null everywhere else.
   */
  providerRefreshToken: string | null;
  createdAt: Date;
}

/** Fields needed to link a new provider identity to a user. */
export interface NewAuthIdentity {
  userId: string;
  provider: AuthProvider;
  providerId: string;
  providerRefreshToken?: string | null;
}

/** Persistence for provider-identity links; `(provider, providerId)` is unique. */
export interface AuthIdentityRepository {
  /**
   * Find the identity for a provider account.
   *
   * @param provider - the auth provider (e.g. `google`).
   * @param providerId - the provider's subject id.
   * @returns the linked identity, or null if this account is new.
   */
  findByProvider(provider: AuthProvider, providerId: string): Promise<AuthIdentity | null>;
  /**
   * Link a provider identity to a user.
   *
   * @param input - the user id, provider, and provider subject id.
   * @returns the persisted identity.
   * @throws on a unique-violation if the identity already exists (race).
   */
  create(input: NewAuthIdentity): Promise<AuthIdentity>;
  /**
   * Remove every provider link for a user (#30). Called on account deletion so a
   * returning person signs up as a NEW account rather than resurrecting the
   * anonymised one their ledger history is attached to.
   *
   * @param userId - the user whose identities to unlink.
   */
  deleteForUser(userId: string): Promise<void>;
  /**
   * Every provider link for a user, read before deletion so we know what to
   * revoke upstream (#213).
   *
   * @param userId - the user whose identities to list.
   * @returns the user's linked identities.
   */
  listForUser(userId: string): Promise<AuthIdentity[]>;
  /**
   * Store (or replace) the provider refresh token on an existing link.
   *
   * Separate from `create` because a rider who signed in before we asked for
   * authorization codes already has an identity row, and their next sign-in is
   * the only chance to backfill it.
   *
   * @param id - the auth identity to update.
   * @param refreshToken - the provider refresh token to keep.
   */
  saveRefreshToken(id: string, refreshToken: string): Promise<void>;
}

/** In-memory {@link AuthIdentityRepository} for dev and unit tests. */
export class InMemoryAuthIdentityRepository implements AuthIdentityRepository {
  private readonly identities = new Map<string, AuthIdentity>();

  private key(provider: AuthProvider, providerId: string): string {
    return `${provider}:${providerId}`;
  }

  async findByProvider(provider: AuthProvider, providerId: string): Promise<AuthIdentity | null> {
    return this.identities.get(this.key(provider, providerId)) ?? null;
  }

  async create(input: NewAuthIdentity): Promise<AuthIdentity> {
    const identity: AuthIdentity = {
      id: crypto.randomUUID(),
      userId: input.userId,
      provider: input.provider,
      providerId: input.providerId,
      providerRefreshToken: input.providerRefreshToken ?? null,
      createdAt: new Date(),
    };
    this.identities.set(this.key(input.provider, input.providerId), identity);
    return identity;
  }

  async deleteForUser(userId: string): Promise<void> {
    for (const [key, identity] of this.identities) {
      if (identity.userId === userId) this.identities.delete(key);
    }
  }

  async listForUser(userId: string): Promise<AuthIdentity[]> {
    return [...this.identities.values()].filter((i) => i.userId === userId);
  }

  async saveRefreshToken(id: string, refreshToken: string): Promise<void> {
    for (const identity of this.identities.values()) {
      if (identity.id === id) identity.providerRefreshToken = refreshToken;
    }
  }
}
