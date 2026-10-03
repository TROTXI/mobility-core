import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { setTimeout as delay } from 'node:timers/promises';
import { setup } from './helpers/financial-fixture.js';
import { MemoryErasureStore } from './helpers/erasure-store.js';
import { ErasureJournal } from '../src/account/erasure-journal.js';
import { ErasureRecovery, assertErasureRuntime } from '../src/account/erasure-recovery.js';
import { AccountService } from '../src/account/service.js';

test('ER-05 prepared restores cannot cross writer generations, but a new writer baseline can', async (t) => {
  const source = await setup(t),
    winner = await setup(t),
    staleIsolated = await setup(t),
    staleReady = await setup(t),
    fresh = await setup(t);
  const device = randomBytes(32);
  const journal = new ErasureJournal(new MemoryErasureStore(), randomUUID(), randomBytes(32));
  const sourceTool = new ErasureRecovery(source.owner, journal, device);
  await sourceTool.initialize();
  const original = (await source.owner.query('SELECT * FROM app.erasure_recovery_control')).rows[0];
  // Control rows model backups from the same original writer, before handover.
  for (const target of [winner, staleIsolated, staleReady])
    await target.owner.query(
      'UPDATE app.erasure_recovery_control SET database_id=$1,database_name=$2,journal_namespace=$3',
      [original.database_id, original.database_name, original.journal_namespace],
    );
  await sourceTool.fence();
  const winnerTool = new ErasureRecovery(winner.owner, journal, device);
  const isolatedTool = new ErasureRecovery(staleIsolated.owner, journal, device);
  const readyTool = new ErasureRecovery(staleReady.owner, journal, device);
  for (const tool of [winnerTool, isolatedTool, readyTool]) {
    await tool.prepare();
    assert.equal((await tool.prepare()).mode, 'isolated');
  }
  await readyTool.replay();
  assert.equal((await readyTool.prepare()).mode, 'ready');
  const prepared = (await staleReady.owner.query('SELECT * FROM app.erasure_recovery_control'))
    .rows[0];
  assert.equal(prepared.source_writer_id, original.database_id);
  assert.equal(prepared.source_database_name, original.database_name);
  await winnerTool.replay();
  await winnerTool.promote();
  await winnerTool.fence();
  const before = await journal.require();
  for (const tool of [isolatedTool, readyTool]) {
    await assert.rejects(tool.prepare(), /wrong_source/);
    // Skipping prepare must not bypass the binding either.
    await assert.rejects(tool.replay(), /wrong_source/);
  }
  await assert.rejects(readyTool.promote(), /wrong_source/);
  assert.deepEqual(await journal.require(), before);
  assert.equal(
    (await staleIsolated.owner.query('SELECT mode FROM app.erasure_recovery_control')).rows[0].mode,
    'isolated',
  );
  assert.deepEqual(
    (await staleReady.owner.query('SELECT * FROM app.erasure_recovery_control')).rows[0],
    prepared,
  );
  // A baseline carrying the current writer's identity remains recoverable.
  const current = (await winner.owner.query('SELECT * FROM app.erasure_recovery_control')).rows[0];
  await fresh.owner.query(
    'UPDATE app.erasure_recovery_control SET database_id=$1,database_name=$2,journal_namespace=$3',
    [current.database_id, current.database_name, current.journal_namespace],
  );
  const freshTool = new ErasureRecovery(fresh.owner, journal, device);
  await freshTool.prepare();
  await freshTool.replay();
  await freshTool.promote();
  await assertErasureRuntime(fresh.runtime, journal, device);
});

test('ER-04 interrupted replay stays isolated and resumes without duplicate local closure', async (t) => {
  const source = await setup(t),
    target = await setup(t),
    device = randomBytes(32);
  const journal = new ErasureJournal(new MemoryErasureStore(), randomUUID(), randomBytes(32));
  const from = new ErasureRecovery(source.owner, journal, device),
    to = new ErasureRecovery(target.owner, journal, device);
  await from.initialize();
  const control = (await source.owner.query('SELECT * FROM app.erasure_recovery_control')).rows[0];
  await target.owner.query(
    'UPDATE app.erasure_recovery_control SET database_id=$1,database_name=$2,journal_namespace=$3',
    [control.database_id, control.database_name, control.journal_namespace],
  );
  for (const actor of [source.actor, source.other])
    await target.owner.query(
      "INSERT INTO app.users(id,role,display_name) VALUES ($1,'commuter','Restore fixture')",
      [actor.userId],
    );
  const account = new AccountService({
    pool: source.runtime,
    deviceKey: device,
    authorizeSession: source.dependencies.authorizeSession,
    erasureJournal: journal,
  });
  for (const actor of [source.actor, source.other])
    await account.handle(actor, 'eraseAccount', {}, undefined, randomUUID());
  await from.fence();
  await to.prepare();
  // Fixed SQL trigger uses a fixture-owned UUID, never caller input.
  await target.owner
    .query(`CREATE FUNCTION app.test_interrupt_replay() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
    IF NEW.user_id='${source.other.userId}'::uuid THEN RAISE EXCEPTION 'test_replay_interrupted'; END IF; RETURN NEW; END $$;
    CREATE TRIGGER test_interrupt_replay BEFORE INSERT ON app.account_erasures FOR EACH ROW EXECUTE FUNCTION app.test_interrupt_replay()`);
  await assert.rejects(to.replay(), /test_replay_interrupted/);
  assert.equal(
    (await target.owner.query('SELECT mode FROM app.erasure_recovery_control')).rows[0].mode,
    'isolated',
  );
  assert.equal(
    (await target.owner.query('SELECT count(*)::int AS n FROM app.account_erasures')).rows[0].n,
    1,
  );
  await assert.rejects(to.promote(), /not_ready/);
  await target.owner.query('DROP TRIGGER test_interrupt_replay ON app.account_erasures');
  await to.replay();
  assert.equal(
    (await target.owner.query('SELECT count(*)::int AS n FROM app.account_erasures')).rows[0].n,
    2,
  );
  await to.promote();
});

test('ER-01 write-ahead capture survives lost acknowledgement and missing storage never becomes success', async (t) => {
  const f = await setup(t),
    store = new MemoryErasureStore(),
    device = randomBytes(32);
  const journal = new ErasureJournal(store, randomUUID(), randomBytes(32));
  const tool = new ErasureRecovery(f.owner, journal, device);
  await tool.initialize();
  const account = new AccountService({
    pool: f.runtime,
    deviceKey: device,
    authorizeSession: f.dependencies.authorizeSession,
    erasureJournal: journal,
  });
  store.loseReply = true;
  await assert.rejects(
    account.handle(f.actor, 'eraseAccount', {}, undefined, randomUUID()),
    (e) => (e as any).code === 'erasure_journal_unavailable',
  );
  assert.equal((await journal.require()).value.entries[0]?.userId, f.actor.userId);
  assert.equal(
    (await f.owner.query('SELECT deleted_at FROM app.users WHERE id=$1', [f.actor.userId])).rows[0]
      .deleted_at,
    null,
  );
  const deletionKey = randomUUID();
  assert.equal(
    (await account.handle(f.actor, 'eraseAccount', {}, undefined, deletionKey)).status,
    204,
  );
  assert.equal((await journal.require()).value.entries.length, 1);
  store.refuse = true;
  await assert.rejects(account.handle(f.other, 'eraseAccount', {}, undefined, randomUUID()));
  assert.equal(
    (await f.owner.query('SELECT deleted_at FROM app.users WHERE id=$1', [f.other.userId])).rows[0]
      .deleted_at,
    null,
  );
  await assert.rejects(
    f.runtime.query("UPDATE app.erasure_recovery_control SET mode='active'"),
    /permission denied/,
  );
  await assert.rejects(account.replayErasure(f.other), /recovery_service_required/);
  const saved = store.value!;
  store.value = null;
  await assert.rejects(
    account.handle(f.actor, 'eraseAccount', {}, undefined, deletionKey),
    (e) => (e as any).code === 'erasure_journal_unavailable',
  );
  await assert.rejects(tool.initialize(), /no_reinitialize/);
  store.value = saved;
  store.refuse = false;
  const row = await journal.require();
  await journal.write({ ...row.value, entries: [] }, row.etag);
  await assert.rejects(
    account.handle(f.actor, 'eraseAccount', {}, undefined, deletionKey),
    (e) => (e as any).code === 'erasure_journal_unavailable',
  );
  store.value = saved;
  assert.equal(
    (await account.handle(f.actor, 'eraseAccount', {}, undefined, deletionKey)).status,
    204,
  );
});

test('ER-02 fence drains a deletion already holding the gate and refuses later requests', async (t) => {
  const f = await setup(t),
    store = new MemoryErasureStore(),
    device = randomBytes(32);
  const journal = new ErasureJournal(store, randomUUID(), randomBytes(32));
  const tool = new ErasureRecovery(f.owner, journal, device);
  await tool.initialize();
  let release!: () => void, entered!: () => void;
  const blocked = new Promise<void>((r) => {
      release = r;
    }),
    reached = new Promise<void>((r) => {
      entered = r;
    });
  const account = new AccountService({
    pool: f.runtime,
    deviceKey: device,
    authorizeSession: f.dependencies.authorizeSession,
    erasureJournal: journal,
    erasureRequested: async () => {
      entered();
      await blocked;
    },
  });
  const deleting = account.handle(f.actor, 'eraseAccount', {}, undefined, randomUUID());
  await reached;
  let finished = false;
  const fencing = tool.fence().then((result) => {
    finished = true;
    return result;
  });
  await delay(30);
  assert.equal(finished, false);
  release();
  await deleting;
  assert.equal((await fencing).captured, 1);
  await assert.rejects(
    account.handle(f.other, 'eraseAccount', {}, undefined, randomUUID()),
    (e) => (e as any).code === 'account_recovery_fenced',
  );
  await assert.rejects(assertErasureRuntime(f.runtime, journal, device), /runtime_fenced/);
  assert.equal((await tool.fence()).captured, 1);
});

test('ER-03 isolated restore replays actual closure, is repeatable, blocks incomplete promotion and fences old writer', async (t) => {
  const source = await setup(t),
    target = await setup(t),
    store = new MemoryErasureStore(),
    device = randomBytes(32);
  const journal = new ErasureJournal(store, randomUUID(), randomBytes(32));
  const sourceTool = new ErasureRecovery(source.owner, journal, device),
    targetTool = new ErasureRecovery(target.owner, journal, device);
  await sourceTool.initialize();
  // Reproduce the account and source control rows from a pre-deletion snapshot
  // in a separate disposable database. This is not a hosted Render restore drill.
  const control = (await source.owner.query('SELECT * FROM app.erasure_recovery_control')).rows[0];
  await target.owner.query(
    'UPDATE app.erasure_recovery_control SET database_id=$1,database_name=$2,journal_namespace=$3',
    [control.database_id, control.database_name, control.journal_namespace],
  );
  await target.owner.query(
    "INSERT INTO app.users(id,role,display_name,email,phone,avatar_object_key) VALUES ($1::uuid,'commuter','Restore fixture','test@example.invalid','test','avatars/'||$1::uuid::text||'/'||$2::text||'.png')",
    [source.actor.userId, randomUUID()],
  );
  await target.owner.query(
    "INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,'google','restore-fixture')",
    [source.actor.userId],
  );
  await target.owner.query(
    "INSERT INTO app.auth_sessions(user_id,expires_at) VALUES ($1,clock_timestamp()+interval '1 day')",
    [source.actor.userId],
  );
  await assert.rejects(assertErasureRuntime(target.runtime, journal, device), /runtime_fenced/);
  await assert.rejects(targetTool.prepare(), /not_fenced/);
  const account = new AccountService({
    pool: source.runtime,
    deviceKey: device,
    authorizeSession: source.dependencies.authorizeSession,
    erasureJournal: journal,
  });
  await account.handle(source.actor, 'eraseAccount', {}, undefined, randomUUID());
  // The second source account did not exist in the snapshot. It must stay absent.
  await account.handle(source.other, 'eraseAccount', {}, undefined, randomUUID());
  await sourceTool.fence();
  await assert.rejects(sourceTool.prepare(), /distinct_database/);
  await targetTool.prepare();
  await assert.rejects(targetTool.promote(), /not_ready/);
  assert.equal((await targetTool.replay()).examined, 2);
  assert.equal((await targetTool.replay()).examined, 2);
  const user = (
    await target.owner.query('SELECT * FROM app.users WHERE id=$1', [source.actor.userId])
  ).rows[0];
  assert.ok(user.deleted_at);
  assert.equal(user.email, null);
  assert.equal(user.phone, null);
  assert.equal(user.avatar_object_key, null);
  assert.equal(
    (
      await target.owner.query(
        'SELECT count(*)::int AS n FROM app.auth_sessions WHERE user_id=$1 AND revoked_at IS NULL',
        [source.actor.userId],
      )
    ).rows[0].n,
    0,
  );
  assert.match(
    (
      await target.owner.query('SELECT subject FROM app.auth_identities WHERE user_id=$1', [
        source.actor.userId,
      ])
    ).rows[0].subject,
    /^erased:/,
  );
  assert.equal(
    (
      await target.owner.query('SELECT count(*)::int AS n FROM app.users WHERE id=$1', [
        source.other.userId,
      ])
    ).rows[0].n,
    0,
  );
  assert.equal(
    (
      await target.owner.query(
        'SELECT count(*)::int AS n FROM app.account_erasures WHERE user_id=$1',
        [source.actor.userId],
      )
    ).rows[0].n,
    1,
  );
  assert.equal(
    (
      await target.owner.query(
        "SELECT count(*)::int AS n FROM app.erasure_tasks WHERE user_id=$1 AND kind='avatar_object' AND state='pending'",
        [source.actor.userId],
      )
    ).rows[0].n,
    1,
  );
  // A changed final delta invalidates ready. Replaying establishes a fresh watermark.
  const snapshot = await journal.require();
  await journal.write({ ...snapshot.value, revision: snapshot.value.revision + 1 }, snapshot.etag);
  await assert.rejects(targetTool.promote(), /promotion_conflict/);
  await targetTool.replay();
  store.loseReply = true;
  await assert.rejects(targetTool.promote(), /lost_reply/);
  await targetTool.promote();
  await assertErasureRuntime(target.runtime, journal, device);
  await assert.rejects(assertErasureRuntime(source.runtime, journal, device), /runtime_fenced/);
  await assert.rejects(
    journal.record(control.database_id, control.database_name, device, randomUUID(), randomUUID()),
    /writer_fenced/,
  );
});
