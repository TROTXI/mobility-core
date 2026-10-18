import type { PoolClient } from 'pg';
import { fail } from '../transport/errors.js';

export const currentCommuterTermsVersion = '2026-10-14';

export async function recordCommuterTermsAcceptance(
  client: PoolClient,
  userId: string,
  input: { acceptedTerms?: unknown; termsVersion?: unknown },
  channel:
    | 'commuter_email_signup'
    | 'commuter_phone_signup'
    | 'commuter_google_signup'
    | 'commuter_apple_signup',
) {
  if (input.acceptedTerms !== true || input.termsVersion !== currentCommuterTermsVersion)
    fail(
      400,
      'terms_acceptance_required',
      'Read and accept the current Terms and Conditions to create an account.',
    );
  await client.query(
    `INSERT INTO app.terms_acceptances(user_id,terms_version,channel)
     VALUES($1,$2,$3) ON CONFLICT (user_id,terms_version) DO NOTHING`,
    [userId, currentCommuterTermsVersion, channel],
  );
}
