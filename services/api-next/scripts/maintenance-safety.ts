import type { Pool } from 'pg';

export type FailureCategory =
  | 'configuration'
  | 'database'
  | 'transport'
  | 'http'
  | 'response_contract'
  | 'partial_batch'
  | 'session_revocation'
  | 'internal';

export class MaintenanceFailure extends Error {
  constructor(readonly category: FailureCategory) {
    super(`Staging maintenance failed: ${category}`);
  }
}

export async function guarded<T>(category: FailureCategory, work: () => Promise<T>): Promise<T> {
  try {
    return await work();
  } catch {
    throw new MaintenanceFailure(category);
  }
}

export function failureLine(error: unknown): string {
  return JSON.stringify({
    status: 'failed',
    category: error instanceof MaintenanceFailure ? error.category : 'internal',
  });
}

export function maintenanceUserId(env: NodeJS.ProcessEnv): string {
  const id = env.REPLACEMENT_MAINTENANCE_USER_ID ?? '';
  if (!/^[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i.test(id))
    throw new MaintenanceFailure('configuration');
  return id;
}

/** A service identity has no email, phone, external login or driver credentials.
 * Never borrow a human administrator or create an account during a retry run.
 */
export async function assertMaintenanceIdentity(pool: Pool, userId: string): Promise<void> {
  const result = await guarded('database', () =>
    pool.query(
      `SELECT u.id FROM app.users u
     WHERE u.id=$1 AND u.role='admin' AND u.deleted_at IS NULL
       AND u.email IS NULL AND u.phone IS NULL
       AND NOT EXISTS (SELECT 1 FROM app.auth_identities i WHERE i.user_id=u.id)
       AND NOT EXISTS (SELECT 1 FROM app.drivers d WHERE d.user_id=u.id)
       AND NOT EXISTS (SELECT 1 FROM app.auth_sessions s
                       WHERE s.user_id=u.id AND s.issued_for='interactive')`,
      [userId],
    ),
  );
  if (result.rows.length !== 1) throw new MaintenanceFailure('configuration');
}
