import { randomUUID } from 'node:crypto';
import type { Pool, PoolClient } from 'pg';
import { AccountService } from './service.js';
import { ErasureJournal, journalHash, keyHash, type Journal } from './erasure-journal.js';

const contentHash = (value: Journal) =>
  journalHash({
    ...value,
    writer: '00000000-0000-4000-8000-000000000000',
    database: 'content',
    revision: 0,
    fenced: true,
  });

export async function assertErasureRuntime(
  pool: Pool,
  journal: ErasureJournal | undefined,
  deviceKey: Buffer,
) {
  const c = (
    await pool.query(
      'SELECT *,current_database() AS actual FROM app.erasure_recovery_control WHERE singleton',
    )
  ).rows[0];
  if (!c || c.mode !== 'active' || c.database_name !== c.actual)
    throw new Error('erasure_recovery_runtime_fenced');
  if (!c.journal_namespace && !journal) return;
  if (!journal || journal.namespace !== c.journal_namespace)
    throw new Error('erasure_journal_configuration_required');
  journal.assertWriter((await journal.require()).value, c.database_id, c.actual, deviceKey);
}

/** Owner-only offline orchestration. No HTTP routes, notification ports or provider calls. */
export class ErasureRecovery {
  constructor(
    private readonly pool: Pool,
    private readonly journal: ErasureJournal,
    private readonly deviceKey: Buffer,
  ) {}

  private async locked<T>(work: (client: PoolClient, control: any) => Promise<T>): Promise<T> {
    const client = await this.pool.connect();
    try {
      await client.query("BEGIN; SET LOCAL lock_timeout='10s'");
      await client.query(
        "SELECT pg_advisory_xact_lock(hashtextextended('trotxi:erasure-recovery',0))",
      );
      const row = (
        await client.query(
          'SELECT *,current_database() AS actual FROM app.erasure_recovery_control WHERE singleton FOR UPDATE',
        )
      ).rows[0];
      if (!row) throw new Error('erasure_recovery_control_missing');
      const result = await work(client, row);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
  async initialize() {
    return this.locked(async (c, control) => {
      if (control.mode !== 'active' || control.database_name !== control.actual)
        throw new Error('erasure_source_not_active');
      if (control.journal_namespace && control.journal_namespace !== this.journal.namespace)
        throw new Error('erasure_namespace_mismatch');
      const existing = await this.journal.read();
      if (control.journal_namespace && !existing)
        throw new Error('erasure_journal_missing_no_reinitialize');
      if (existing)
        this.journal.assertWriter(
          existing.value,
          control.database_id,
          control.actual,
          this.deviceKey,
        );
      const entries = (
        await c.query(
          'SELECT user_id AS "userId",session_id AS "sessionId" FROM app.account_erasures ORDER BY user_id',
        )
      ).rows;
      const combined = new Map((existing?.value.entries ?? []).map((e) => [e.userId, e]));
      for (const entry of entries)
        if (!combined.has(entry.userId)) combined.set(entry.userId, entry);
      const value: Journal = {
        version: 1,
        namespace: this.journal.namespace,
        writer: control.database_id,
        database: control.actual,
        deviceKeyHash: keyHash(this.deviceKey),
        revision: (existing?.value.revision ?? -1) + 1,
        fenced: false,
        entries: [...combined.values()],
      };
      await this.journal.write(value, existing?.etag ?? null);
      await c.query(
        'UPDATE app.erasure_recovery_control SET journal_namespace=$1 WHERE singleton',
        [this.journal.namespace],
      );
      return { captured: value.entries.length, revision: value.revision };
    });
  }
  async fence() {
    return this.locked(async (c, control) => {
      if (control.database_name !== control.actual || !['active', 'fenced'].includes(control.mode))
        throw new Error('erasure_source_mismatch');
      const row = await this.journal.require();
      if (
        control.journal_namespace !== this.journal.namespace ||
        row.value.writer !== control.database_id ||
        row.value.database !== control.actual ||
        row.value.deviceKeyHash !== keyHash(this.deviceKey)
      )
        throw new Error('erasure_source_mismatch');
      // Verify historical coverage too; a new binary must not silently omit
      // deletions made by an old binary during the activation window.
      const captured = new Set(row.value.entries.map((e) => e.userId));
      const facts = (await c.query('SELECT user_id FROM app.account_erasures')).rows;
      if (facts.some((e) => !captured.has(e.user_id)))
        throw new Error('erasure_capture_incomplete');
      const value = row.value.fenced
        ? row.value
        : { ...row.value, fenced: true, revision: row.value.revision + 1 };
      if (!row.value.fenced) await this.journal.write(value, row.etag);
      await c.query("UPDATE app.erasure_recovery_control SET mode='fenced' WHERE singleton");
      return { revision: value.revision, captured: value.entries.length };
    });
  }
  private checkSnapshot(value: Journal) {
    if (!value.fenced || value.deviceKeyHash !== keyHash(this.deviceKey))
      throw new Error('erasure_recovery_snapshot_not_fenced');
  }
  private checkSource(value: Journal, control: any) {
    if (
      control.source_writer_id !== value.writer ||
      control.source_database_name !== value.database
    )
      throw new Error('erasure_restore_wrong_source');
  }
  async prepare() {
    return this.locked(async (c, control) => {
      const { value } = await this.journal.require();
      this.checkSnapshot(value);
      if (value.database === control.actual)
        throw new Error('restore_requires_distinct_database_name');
      if (control.mode === 'isolated' || control.mode === 'ready') {
        if (
          control.journal_namespace !== this.journal.namespace ||
          control.database_name !== control.actual
        )
          throw new Error('erasure_restore_mismatch');
        this.checkSource(value, control);
        return { mode: control.mode };
      }
      // Restore must contain the source identity, not an unrelated database.
      if (
        control.database_id !== value.writer ||
        control.journal_namespace !== this.journal.namespace
      )
        throw new Error('erasure_restore_wrong_source');
      await c.query(
        "UPDATE app.erasure_recovery_control SET database_id=$1,database_name=current_database(),source_writer_id=$2,source_database_name=$3,mode='isolated',replay_revision=NULL,replay_hash=NULL WHERE singleton",
        [randomUUID(), value.writer, value.database],
      );
      return { mode: 'isolated' };
    });
  }
  async replay() {
    const { value } = await this.journal.require();
    this.checkSnapshot(value);
    await this.locked(async (c, control) => {
      if (
        control.journal_namespace !== this.journal.namespace ||
        control.database_name !== control.actual ||
        !['isolated', 'ready'].includes(control.mode)
      )
        throw new Error('erasure_restore_not_isolated');
      this.checkSource(value, control);
      await c.query(
        "UPDATE app.erasure_recovery_control SET mode='isolated',replay_revision=NULL,replay_hash=NULL WHERE singleton",
      );
    });
    const account = new AccountService({
      pool: this.pool,
      deviceKey: this.deviceKey,
      recoveryOnly: true,
      authorizeSession: async () => {
        throw new Error('recovery_does_not_authenticate_sessions');
      },
    });
    for (const entry of value.entries) await account.replayErasure(entry);
    return this.locked(async (c, control) => {
      const current = (await this.journal.require()).value;
      if (journalHash(current) !== journalHash(value) || control.mode !== 'isolated')
        throw new Error('erasure_recovery_snapshot_changed');
      this.checkSource(current, control);
      const present = (
        await c.query(
          'SELECT count(*)::int AS n FROM app.users WHERE id=ANY($1::uuid[]) AND deleted_at IS NULL',
          [value.entries.map((e) => e.userId)],
        )
      ).rows[0].n;
      if (present) throw new Error('erasure_replay_incomplete');
      await c.query(
        "UPDATE app.erasure_recovery_control SET mode='ready',replay_revision=$1,replay_hash=$2 WHERE singleton",
        [value.revision, contentHash(value)],
      );
      return { examined: value.entries.length, revision: value.revision, mode: 'ready' };
    });
  }
  async promote() {
    return this.locked(async (c, control) => {
      if (
        control.mode !== 'ready' ||
        control.database_name !== control.actual ||
        control.journal_namespace !== this.journal.namespace
      )
        throw new Error('erasure_restore_not_ready');
      const { value, etag } = await this.journal.require();
      // A completed remote handover may be retried only by its exact target
      // below. Every still-fenced handover must come from the prepared source.
      if (value.fenced) this.checkSource(value, control);
      if (
        value.deviceKeyHash !== keyHash(this.deviceKey) ||
        contentHash(value) !== control.replay_hash
      )
        throw new Error('erasure_replay_watermark_mismatch');
      const active = (
        await c.query(
          'SELECT count(*)::int AS n FROM app.users WHERE id=ANY($1::uuid[]) AND deleted_at IS NULL',
          [value.entries.map((e) => e.userId)],
        )
      ).rows[0].n;
      if (active) throw new Error('erasure_replay_incomplete');
      if (value.fenced && value.revision === Number(control.replay_revision)) {
        await this.journal.write(
          {
            ...value,
            writer: control.database_id,
            database: control.actual,
            fenced: false,
            revision: value.revision + 1,
          },
          etag,
        );
      } else if (
        value.fenced ||
        value.writer !== control.database_id ||
        value.database !== control.actual ||
        value.revision !== Number(control.replay_revision) + 1
      ) {
        // Lost response after remote promotion can finish the SQL gate only
        // for exactly the same target and replayed revision, never another writer.
        throw new Error('erasure_promotion_conflict');
      }
      await c.query("UPDATE app.erasure_recovery_control SET mode='active' WHERE singleton");
      return { mode: 'active' };
    });
  }
}
