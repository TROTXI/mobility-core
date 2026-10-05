// Driver sign-in with a driver code and PIN, and its lockout.
import { TransportError } from '../transport/errors.js';
import type { AuthService } from './service.js';
import { normalizeDriverCode, verifyDriverPin } from './driver-pin.js';
import { DriverLockedError, denied } from './service.js';

export async function driverSignIn(
  auth: AuthService,
  input: { code: string; pin: string; ownDevice: boolean },
) {
  const output = await auth.transaction(async (client) => {
    const match = (
      await client.query(
        `SELECT d.user_id FROM app.driver_credentials c JOIN app.drivers d ON d.id=c.driver_id WHERE c.driver_code=$1`,
        [normalizeDriverCode(input.code)],
      )
    ).rows[0];
    if (!match?.user_id) {
      verifyDriverPin(input.pin, '0'.repeat(64), auth.options.pinSecret);
      return denied();
    }
    const user = await auth.user(client, match.user_id, true);
    const row = (
      await client.query(
        `SELECT c.*,d.name,d.archived_at FROM app.driver_credentials c JOIN app.drivers d ON d.id=c.driver_id
      WHERE d.user_id=$1 AND c.driver_code=$2 FOR UPDATE OF c FOR SHARE OF d`,
        [user.id, normalizeDriverCode(input.code)],
      )
    ).rows[0];
    if (!row || user.role !== 'driver' || row.archived_at) return denied();
    if (row.status !== 'active')
      return new TransportError(403, 'driver_suspended', 'This driver account is suspended.');
    const now = await auth.now(client);
    if (row.locked_until && row.locked_until > now)
      return new DriverLockedError(
        Math.max(1, Math.ceil((row.locked_until.getTime() - now.getTime()) / 1000)),
      );
    if (!verifyDriverPin(input.pin, row.pin_hash, auth.options.pinSecret)) {
      const attempts = Number(row.failed_attempts) + 1;
      await client.query(
        `UPDATE app.driver_credentials SET failed_attempts=$2,
        locked_until=CASE WHEN $2>=5 THEN $3::timestamptz+interval '15 minutes' ELSE locked_until END,updated_at=$3 WHERE driver_id=$1`,
        [row.driver_id, attempts, now],
      );
      return attempts >= 5 ? new DriverLockedError(900) : denied();
    }
    await client.query(
      'UPDATE app.driver_credentials SET failed_attempts=0,locked_until=NULL,updated_at=$2 WHERE driver_id=$1',
      [row.driver_id, now],
    );
    // Checked only once the PIN is right, so the answer tells nobody else
    // anything. An expired temporary PIN opens no session at all.
    if (row.must_change_pin && row.temporary_pin_expires_at <= now)
      return new TransportError(
        403,
        'temporary_pin_expired',
        'Your temporary PIN has expired. Ask Trotxi operations for a new one.',
      );
    const tokens = await auth.newSession(
      client,
      user,
      input.ownDevice
        ? auth.options.refreshTtlDays * 86400000
        : auth.options.shiftTtlHours * 3600000,
      input.ownDevice,
    );
    return {
      ...tokens,
      driver: { id: row.driver_id, name: row.name },
      mustChangePin: row.must_change_pin,
      temporaryPinExpiresAt: row.temporary_pin_expires_at
        ? new Date(row.temporary_pin_expires_at).toISOString()
        : null,
    };
  });
  // Expected rejection follows COMMIT, so lockout counters cannot roll back.
  if (output instanceof TransportError) throw output;
  return output;
}
