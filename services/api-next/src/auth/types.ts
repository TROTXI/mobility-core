export type Provider = 'google' | 'apple';
export interface VerifiedIdentity {
  provider: Provider;
  providerId: string;
  email: string | null;
  displayName: string | null;
}
export interface IdTokenVerifier {
  verify(token: string, nonce?: string): Promise<VerifiedIdentity>;
}
