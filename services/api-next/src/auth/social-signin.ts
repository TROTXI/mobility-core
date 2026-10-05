// Google and Apple sign-in, for riders and for invited operators.
import { fail } from '../transport/errors.js';
import type { AuthService } from './service.js';
import { errors as joseErrors } from 'jose';
import { ZodError } from 'zod';
import type { Provider, VerifiedIdentity } from './types.js';
import { claimInvitation } from './ops-team.js';
import { denied, type User } from './service.js';

export async function socialSignIn(
  auth: AuthService,
  provider: Provider,
  input: {
    idToken: string;
    nonce?: string;
    displayName?: string;
    authorizationCode?: string;
    invitationToken?: string;
  },
  opsOnly = false,
) {
  const verifier = auth.options[provider];
  if (!verifier) fail(503, 'provider_unavailable', 'This sign-in provider is not configured.');
  let identity: VerifiedIdentity;
  try {
    identity = await verifier.verify(input.idToken, input.nonce);
  } catch (error) {
    if (
      (error instanceof joseErrors.JOSEError && !(error instanceof joseErrors.JWKSTimeout)) ||
      error instanceof ZodError ||
      (error instanceof Error &&
        /^(Apple (email not verified|nonce mismatch|token carries a nonce)|Google email not verified)/.test(
          error.message,
        ))
    )
      throw denied();
    fail(503, 'provider_unavailable', 'The sign-in provider is temporarily unavailable.');
  }
  if (identity.provider !== provider || !identity.providerId || identity.providerId.length > 1024)
    throw denied();
  // Match the existing best-effort Apple code capture. Never hold SQL locks
  // during provider calls. Erasure/revocation orchestration is a later slice.
  let encrypted: string | null = null;
  if (provider === 'apple' && input.authorizationCode && auth.options.appleTokens) {
    try {
      const token = await auth.options.appleTokens.exchangeCode(input.authorizationCode);
      if (token.refreshToken) encrypted = auth.box!.seal(token.refreshToken, identity.providerId);
    } catch {
      /* Invalid/already-used optional code never invalidates a verified ID token. */
    }
  }
  return auth.transaction(async (client) => {
    // Prevent concurrent first sign-ins from leaving an unlinked user behind.
    await client.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
      JSON.stringify(['auth-identity', provider, identity.providerId]),
    ]);
    const existing = (
      await client.query(
        'SELECT user_id FROM app.auth_identities WHERE provider=$1 AND subject=$2',
        [provider, identity.providerId],
      )
    ).rows[0];
    let user: User;
    if (opsOnly && input.invitationToken) {
      const userId = await claimInvitation(
        client,
        identity,
        input.invitationToken,
        existing?.user_id,
      );
      if (!existing)
        await client.query(
          'INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,$2,$3)',
          [userId, provider, identity.providerId],
        );
      user = await auth.user(client, userId, true);
    } else if (existing) {
      user = await auth.user(client, existing.user_id, true);
      if (!user.email && identity.email)
        await client.query('UPDATE app.users SET email=$2 WHERE id=$1', [user.id, identity.email]);
      if (encrypted)
        await client.query(
          'UPDATE app.auth_identities SET provider_token_ciphertext=$3 WHERE provider=$1 AND subject=$2',
          [provider, identity.providerId, encrypted],
        );
    } else {
      if (opsOnly)
        fail(403, 'ops_access_required', 'This account has not been invited to Trotxi Operations.');
      const displayName =
        (identity.displayName || (provider === 'apple' ? input.displayName : '') || 'New user')
          .trim()
          .slice(0, 200) || 'New user';
      user = (
        await client.query<User>(
          `INSERT INTO app.users(role,display_name,email) VALUES ('commuter',$1,$2) RETURNING *`,
          [displayName, identity.email],
        )
      ).rows[0]!;
      await client.query(
        'INSERT INTO app.auth_identities(user_id,provider,subject,provider_token_ciphertext) VALUES ($1,$2,$3,$4)',
        [user.id, provider, identity.providerId, encrypted],
      );
    }
    if (opsOnly && user.role !== 'admin')
      fail(403, 'ops_access_required', 'This account has not been invited to Trotxi Operations.');
    await auth.driverAllowed(client, user);
    return auth.newSession(client, user, auth.options.refreshTtlDays * 86400000);
  });
}
