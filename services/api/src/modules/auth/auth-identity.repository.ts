// Links a provider identity (google/apple + subject id) to a Trotxi user. The
// (provider, provider_id) pair is unique, so a returning user maps to the same
// account. Backs the social-first sign-in in ADR-0007.

import type { AuthProvider } from './id-token-verifier';

export interface AuthIdentity {
  id: string;
  userId: string;
  provider: AuthProvider;
  providerId: string;
  createdAt: Date;
}

export interface NewAuthIdentity {
  userId: string;
  provider: AuthProvider;
  providerId: string;
}

export interface AuthIdentityRepository {
  findByProvider(provider: AuthProvider, providerId: string): Promise<AuthIdentity | null>;
  create(input: NewAuthIdentity): Promise<AuthIdentity>;
}

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
