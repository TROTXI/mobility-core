import type { Pool } from 'pg';
import { runtimeRoleIdentifier } from '../db/migrate.js';
// Separate until 010 and 011 are installed together. Call AFTER grantRuntime;
// integrator must wire this into the real installer before enabling the service.
export async function grantFinancialRuntime(pool: Pool, role: string) {
  await pool.query(`REVOKE UPDATE ON app.purchase_legs,app.credit_entries,app.ride_entries,
 app.credit_adjustments,app.period_closures FROM ${runtimeRoleIdentifier(role)}`);
}
