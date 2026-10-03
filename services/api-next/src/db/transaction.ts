import type { PoolClient } from 'pg';

/** One round trip, with the same transaction-local safety limits everywhere. */
export async function beginTransaction(client: PoolClient, consistentRead = false): Promise<void> {
  await client.query(
    `${consistentRead ? 'BEGIN ISOLATION LEVEL REPEATABLE READ' : 'BEGIN'}; SET LOCAL TIME ZONE 'UTC'; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='10s'`,
  );
}
