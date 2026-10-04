import type { Pool } from 'pg';
import { teamLock } from './ops-team.js';
/** Installer-only operation. No public endpoint or environment email allowlist. */
export async function bootstrapSuperadmin(pool: Pool, userId: string, databaseName: string) {
  if (
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(userId) ||
    !databaseName
  )
    throw new Error('Exact account ID and database name required');
  const c = await pool.connect();
  try {
    await c.query('BEGIN');
    await teamLock(c);
    const database = (await c.query('SELECT current_database() AS name')).rows[0].name;
    if (database !== databaseName) throw new Error('Database confirmation does not match');
    if (
      (await c.query('SELECT 1 FROM app.ops_bootstrap')).rowCount ||
      (await c.query('SELECT 1 FROM app.users WHERE is_superadmin')).rowCount
    )
      throw new Error('Superadmin bootstrap already completed');
    const user = (
      await c.query(
        `SELECT id FROM app.users u WHERE id=$1 AND role='admin' AND deleted_at IS NULL AND NOT ops_invite_pending
      AND EXISTS(SELECT 1 FROM app.auth_identities i WHERE i.user_id=u.id AND i.provider='google')
      AND EXISTS(SELECT 1 FROM app.admin_passkeys p WHERE p.user_id=u.id AND p.revoked_at IS NULL)
      AND EXISTS(SELECT 1 FROM app.auth_sessions s WHERE s.user_id=u.id AND s.revoked_at IS NULL AND s.expires_at>clock_timestamp() AND s.admin_verified_at>clock_timestamp()-interval '8 hours') FOR UPDATE`,
        [userId],
      )
    ).rows[0];
    if (!user)
      throw new Error(
        'Target must be an existing Google administrator with a registered passkey and a current elevated session',
      );
    await c.query('INSERT INTO app.ops_bootstrap(user_id) VALUES ($1)', [userId]);
    await c.query('UPDATE app.users SET is_superadmin=true WHERE id=$1', [userId]);
    await c.query(
      "INSERT INTO app.ops_team_events(actor_user_id,target_id,action) VALUES ($1,$1,'bootstrap_superadmin')",
      [userId],
    );
    await c.query('COMMIT');
  } catch (e) {
    await c.query('ROLLBACK');
    throw e;
  } finally {
    c.release();
  }
}
