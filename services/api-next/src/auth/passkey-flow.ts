// Passkey registration, verification, reset and the admin elevation they grant.
import type { PoolClient } from 'pg';
import { fail } from '../transport/errors.js';
import type { Actor } from '../transport/service.js';
import type { AuthService } from './service.js';
import type { AuthenticationResponseJSON, RegistrationResponseJSON } from '@simplewebauthn/server';
import type { StoredPasskey } from './passkeys.js';
import { teamLock, requireRecentPasskey, requireSuperadmin, finishInvitation } from './ops-team.js';
import {
  ADMIN_ELEVATION_HOURS,
  PASSKEY_CHALLENGE_SECONDS,
  result,
  type PasskeyOperation,
} from './service.js';

export async function passkeyCeremony(
  auth: AuthService,
  name: PasskeyOperation,
  actor: Actor,
  body: any,
  target: string | undefined,
) {
  const relyingParty = auth.options.passkeys;
  if (!relyingParty)
    fail(503, 'passkeys_unavailable', 'Passkey authentication is not configured here.');
  return auth.transaction(async (client) => {
    await teamLock(client);
    const user = await auth.user(client, actor.userId, true);

    if (name === 'resetOperatorPasskeys') {
      await auth.authorizeSession(client, actor);
      await requireSuperadmin(client, actor);
      await requireRecentPasskey(client, actor);
      if (user.role !== 'admin')
        fail(403, 'forbidden', 'This operation is not available to your account.');
      return resetPasskeys(auth, client, actor, target);
    }

    await auth.authorizeSession(client, actor, { allowUnelevated: true });
    if (user.role !== 'admin') fail(403, 'forbidden', 'Passkeys are for operations accounts.');

    const now = await auth.now(client);
    const credentials = (
      await client.query(
        `SELECT credential_id,public_key,signature_counter,transports
         FROM app.admin_passkeys
         WHERE user_id=$1 AND revoked_at IS NULL
         ORDER BY created_at,id FOR UPDATE`,
        [user.id],
      )
    ).rows;
    const stored = credentials.map((row): StoredPasskey => ({
      id: row.credential_id,
      publicKey: Uint8Array.from(row.public_key),
      counter: Number(row.signature_counter),
      transports: row.transports,
    }));
    const elevated =
      (
        await client.query(
          `SELECT (admin_verified_at IS NOT NULL
            AND admin_verified_at > $2::timestamptz - make_interval(hours => ${ADMIN_ELEVATION_HOURS}))
            AS elevated
           FROM app.auth_sessions WHERE id=$1 AND user_id=$3`,
          [actor.sessionId, now, actor.userId],
        )
      ).rows[0]?.elevated === true;

    if (name === 'getPasskeyStatus') {
      const pending =
        (
          await client.query(
            `SELECT 1 FROM app.admin_passkey_challenges
             WHERE session_id=$1 AND user_id=$2 AND purpose='registration'
               AND consumed_at IS NULL AND expires_at>$3 LIMIT 1`,
            [actor.sessionId, user.id, now],
          )
        ).rowCount === 1;
      return result({
        registered: stored.length > 0,
        passkeyCount: stored.length,
        registrationPending: pending,
        verified: elevated,
      });
    }

    if (name === 'startPasskeyRegistration') {
      if (stored.length && !elevated)
        fail(403, 'passkey_required', 'Use an existing passkey before adding another.');
      const options = await relyingParty.registrationOptions({
        userId: user.id,
        userName: user.email ?? user.id,
        displayName: user.display_name ?? user.email ?? 'Trotxi operator',
        credentials: stored,
      });
      await savePasskeyChallenge(auth, client, actor, 'registration', options.challenge, now);
      await passkeyEvent(auth, client, user.id, user.id, 'registration_started');
      return result(options);
    }

    if (name === 'finishPasskeyRegistration') {
      if (stored.length && !elevated)
        fail(403, 'passkey_required', 'Use an existing passkey before adding another.');
      const challenge = await passkeyChallenge(auth, client, actor, 'registration', now);
      let registered;
      try {
        registered = await relyingParty.verifyRegistration(
          body as RegistrationResponseJSON,
          challenge,
        );
      } catch {
        fail(400, 'passkey_verification_failed', 'The passkey could not be verified.');
      }
      await client.query(
        `INSERT INTO app.admin_passkeys(
           user_id,credential_id,public_key,signature_counter,transports,
           device_type,backed_up,created_at
         ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
        [
          user.id,
          registered.id,
          Buffer.from(registered.publicKey),
          registered.counter,
          registered.transports ?? [],
          registered.deviceType,
          registered.backedUp,
          now,
        ],
      );
      await consumePasskeyChallenge(auth, client, actor, 'registration');
      await finishInvitation(client, user.id);
      await elevate(auth, client, actor, now);
      await passkeyEvent(auth, client, user.id, user.id, 'registered');
      return result();
    }

    if (!stored.length)
      fail(409, 'passkey_not_registered', 'Register a passkey before continuing.');

    if (name === 'startPasskeyAuthentication') {
      const options = await relyingParty.authenticationOptions(stored);
      await savePasskeyChallenge(auth, client, actor, 'authentication', options.challenge, now);
      return result(options);
    }

    const challenge = await passkeyChallenge(auth, client, actor, 'authentication', now);
    const credentialRow = credentials.find((row) => row.credential_id === String(body?.id ?? ''));
    if (!credentialRow)
      fail(400, 'passkey_verification_failed', 'The passkey could not be verified.');
    const credential: StoredPasskey = {
      id: credentialRow.credential_id,
      publicKey: Uint8Array.from(credentialRow.public_key),
      counter: Number(credentialRow.signature_counter),
      transports: credentialRow.transports,
    };
    let verified;
    try {
      verified = await relyingParty.verifyAuthentication(
        body as AuthenticationResponseJSON,
        challenge,
        credential,
      );
    } catch {
      fail(400, 'passkey_verification_failed', 'The passkey could not be verified.');
    }
    await client.query(
      `UPDATE app.admin_passkeys
       SET signature_counter=$2,device_type=$3,backed_up=$4,last_used_at=$5
       WHERE user_id=$1 AND credential_id=$6 AND revoked_at IS NULL`,
      [user.id, verified.newCounter, verified.deviceType, verified.backedUp, now, credential.id],
    );
    await consumePasskeyChallenge(auth, client, actor, 'authentication');
    await finishInvitation(client, user.id);
    await elevate(auth, client, actor, now);
    await passkeyEvent(auth, client, user.id, user.id, 'verified');
    return result();
  });
}

export async function savePasskeyChallenge(
  auth: AuthService,
  client: PoolClient,
  actor: Actor,
  purpose: 'registration' | 'authentication',
  challenge: string,
  now: Date,
) {
  const expires = new Date(now.getTime() + PASSKEY_CHALLENGE_SECONDS * 1000);
  await client.query(
    `INSERT INTO app.admin_passkey_challenges(
       session_id,user_id,purpose,challenge,created_at,expires_at,consumed_at
     ) VALUES ($1,$2,$3,$4,$5,$6,NULL)
     ON CONFLICT (session_id,purpose) DO UPDATE
     SET user_id=EXCLUDED.user_id,challenge=EXCLUDED.challenge,
         created_at=EXCLUDED.created_at,expires_at=EXCLUDED.expires_at,
         consumed_at=NULL`,
    [actor.sessionId, actor.userId, purpose, challenge, now, expires],
  );
}

export async function passkeyChallenge(
  auth: AuthService,
  client: PoolClient,
  actor: Actor,
  purpose: 'registration' | 'authentication',
  now: Date,
): Promise<string> {
  const row = (
    await client.query(
      `SELECT challenge FROM app.admin_passkey_challenges
       WHERE session_id=$1 AND user_id=$2 AND purpose=$3
         AND consumed_at IS NULL AND expires_at>$4
       FOR UPDATE`,
      [actor.sessionId, actor.userId, purpose, now],
    )
  ).rows[0];
  if (!row) fail(409, 'passkey_challenge_missing', 'Start the passkey check again.');
  return row.challenge;
}

export async function consumePasskeyChallenge(
  auth: AuthService,
  client: PoolClient,
  actor: Actor,
  purpose: 'registration' | 'authentication',
) {
  await client.query(
    `UPDATE app.admin_passkey_challenges SET consumed_at=clock_timestamp()
     WHERE session_id=$1 AND user_id=$2 AND purpose=$3 AND consumed_at IS NULL`,
    [actor.sessionId, actor.userId, purpose],
  );
}

export async function resetPasskeys(
  auth: AuthService,
  client: PoolClient,
  actor: Actor,
  target: string | undefined,
) {
  if (!target || !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(target))
    fail(400, 'invalid_request', 'Invalid account identifier.');
  if (target.toLowerCase() === actor.userId.toLowerCase())
    fail(403, 'self_reset_forbidden', 'Another verified administrator must reset your passkeys.');
  const subject = (
    await client.query(
      'SELECT id,role FROM app.users WHERE id=$1 AND deleted_at IS NULL FOR UPDATE',
      [target],
    )
  ).rows[0];
  if (!subject) fail(404, 'not_found', 'Resource not found.');
  if (subject.role !== 'admin')
    fail(409, 'not_an_operator', 'Only operations accounts have passkeys to reset.');
  const now = await auth.now(client);
  await client.query(
    'UPDATE app.admin_passkeys SET revoked_at=COALESCE(revoked_at,$2) WHERE user_id=$1',
    [subject.id, now],
  );
  await client.query(
    `UPDATE app.admin_passkey_challenges
     SET consumed_at=COALESCE(consumed_at,$2) WHERE user_id=$1`,
    [subject.id, now],
  );
  await client.query(
    'UPDATE app.auth_sessions SET revoked_at=COALESCE(revoked_at,$2) WHERE user_id=$1',
    [subject.id, now],
  );
  await passkeyEvent(auth, client, subject.id, actor.userId, 'reset');
  return result();
}

export async function elevate(auth: AuthService, client: PoolClient, actor: Actor, now: Date) {
  await client.query(
    'UPDATE app.auth_sessions SET admin_verified_at=$3 WHERE id=$1 AND user_id=$2',
    [actor.sessionId, actor.userId, now],
  );
}

export async function passkeyEvent(
  auth: AuthService,
  client: PoolClient,
  userId: string,
  actorId: string,
  action: 'registration_started' | 'registered' | 'verified' | 'reset',
) {
  await client.query(
    'INSERT INTO app.admin_passkey_events(user_id,actor_user_id,action) VALUES ($1,$2,$3)',
    [userId, actorId, action],
  );
}
