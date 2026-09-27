import type { Pool } from 'pg';

// Identifiers are closed source constants, never request-controlled SQL.
const stores = [
  [
    'transport_commands',
    'replay_expires_at',
    'response_body=NULL,response_headers=NULL',
    'response_body IS NOT NULL',
  ],
  [
    'driver_commands',
    'replay_expires_at',
    'response_body=NULL,secret_ciphertext=NULL',
    'response_body IS NOT NULL OR secret_ciphertext IS NOT NULL',
  ],
  [
    'boarding_commands',
    "created_at+interval '7 days'",
    'response_body=NULL',
    'response_body IS NOT NULL',
  ],
  [
    'payment_review_commands',
    "created_at+interval '7 days'",
    'response_body=NULL',
    'response_body IS NOT NULL',
  ],
  [
    'config_commands',
    "created_at+interval '7 days'",
    'response_body=NULL,response_etag=NULL',
    'response_body IS NOT NULL',
  ],
] as const;

export async function purgeExpiredCommandPayloads(pool: Pool, limit = 100): Promise<number> {
  if (!Number.isInteger(limit) || limit < 1 || limit > 1000)
    throw new Error('Invalid receipt cleanup limit');
  let cleared = 0;
  for (const [table, deadline, clear, present] of stores) {
    const result = await pool.query(
      `WITH due AS (SELECT id FROM app.${table}
      WHERE (${present}) AND ${deadline}<=clock_timestamp() ORDER BY ${deadline},id
      LIMIT $1 FOR UPDATE SKIP LOCKED)
      UPDATE app.${table} SET ${clear} WHERE id IN (SELECT id FROM due)`,
      [limit],
    );
    cleared += result.rowCount ?? 0;
  }
  return cleared;
}
