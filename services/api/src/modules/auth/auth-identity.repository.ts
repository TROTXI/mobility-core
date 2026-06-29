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
  createdAt: Date;
}

/** Fields needed to link a new provider identity to a user. */
export interface NewAuthIdentity {
  userId: string;
  provider: AuthProvider;
  providerId: string;
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
      createdAt: new Date(),
    };
    this.identities.set(this.key(input.provider, input.providerId), identity);
    return identity;
  }
}
