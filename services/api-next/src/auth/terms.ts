import type { PoolClient } from 'pg';
import { fail } from '../transport/errors.js';

export const currentCommuterTermsVersion = '2026-10-14';
export const currentDriverTermsVersion = '2026-10-22';

/** Each app has its own terms. Publishing a version means changing it here. */
export const currentTermsVersions = {
  commuter: currentCommuterTermsVersion,
  driver: currentDriverTermsVersion,
} as const;
export type TermsAudience = keyof typeof currentTermsVersions;

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
    `INSERT INTO app.terms_acceptances(user_id,audience,terms_version,channel)
     VALUES($1,'commuter',$2,$3) ON CONFLICT (user_id,audience,terms_version) DO NOTHING`,
    [userId, currentCommuterTermsVersion, channel],
  );
}

function audienceOf(role: string): TermsAudience {
  if (role === 'commuter' || role === 'driver') return role;
  fail(403, 'forbidden', 'Terms acceptance is for riders and drivers.');
}

/** What the app must show: the version in force and whether this user accepted it. */
export async function termsStatus(client: PoolClient, user: { id: string; role: string }) {
  const audience = audienceOf(user.role);
  const currentVersion = currentTermsVersions[audience];
  const accepted = (
    await client.query<{ terms_version: string }>(
      `SELECT terms_version FROM app.terms_acceptances
       WHERE user_id=$1 AND audience=$2 ORDER BY terms_version DESC LIMIT 1`,
      [user.id, audience],
    )
  ).rows[0]?.terms_version;
  return {
    audience,
    currentVersion,
    acceptedVersion: accepted ?? null,
    acceptanceRequired: accepted !== currentVersion,
  };
}

/**
 * Accept the version in force, in the app. Only the current version can be
 * accepted: an app showing an older text is told to fetch the new one.
 * Accepting again changes nothing, so a retried request is harmless.
 */
export async function acceptCurrentTerms(
  client: PoolClient,
  user: { id: string; role: string },
  input: { acceptedTerms?: unknown; termsVersion?: unknown },
) {
  const audience = audienceOf(user.role);
  if (input.acceptedTerms !== true)
    fail(400, 'terms_acceptance_required', 'Read and accept the terms to continue.');
  if (input.termsVersion !== currentTermsVersions[audience])
    fail(409, 'terms_version_outdated', 'The terms have been updated. Read the latest version.');
  await client.query(
    `INSERT INTO app.terms_acceptances(user_id,audience,terms_version,channel)
     VALUES($1,$2,$3,$4) ON CONFLICT (user_id,audience,terms_version) DO NOTHING`,
    [user.id, audience, currentTermsVersions[audience], `${audience}_app`],
  );
  return termsStatus(client, user);
}
