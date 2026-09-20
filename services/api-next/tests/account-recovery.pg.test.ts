import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { setup, files } from './helpers/financial-fixture.js';
import { migrate, grantRuntime } from '../src/db/migrate.js';
import { AccountService } from '../src/account/service.js';
import { accessTokens } from '../src/auth/credentials.js';
import { createTransportApp } from '../src/http/app.js';
import { purgeExpiredCommandPayloads } from '../src/runtime/receipt-retention.js';

function gate() {
  let release!: () => void;
  const promise = new Promise<void>((resolve) => {
    release = resolve;
  });
  return { promise, release };
}
const png = Buffer.from('89504e470d0a1a0a0011223344556677', 'hex');

test('ACR-10 expired command payloads clear under runtime grants without changing identities or audit links', async (t) => {
  const f = await setup(t);
  const driver = (
    await f.owner.query("INSERT INTO app.drivers(name) VALUES ('Receipt fixture') RETURNING id")
  ).rows[0].id;
  for (const expired of [true, false]) {
    const created = expired ? "clock_timestamp()-interval '8 days'" : 'clock_timestamp()';
    await f.owner.query(
      `INSERT INTO app.transport_commands(id,actor_user_id,operation,target,key_hash,input_hash,response_status,response_body,response_headers,created_at,replay_expires_at)
      VALUES(gen_random_uuid(),$1,'createTrip','fixture',$2,repeat('a',64),201,'{"private":"snapshot"}','{"ETag":"old"}',${created},${created}+interval '7 days')`,
      [f.adminId, randomBytes(32).toString('hex')],
    );
    const config = (
      await f.owner.query(
        `INSERT INTO app.config_commands(actor_user_id,operation,target,key_hash,input_hash,response_body,response_etag,created_at)
      VALUES($1,'setFlag','fixture',$2,repeat('a',64),'{"private":"snapshot"}','old',${created}) RETURNING id`,
        [f.adminId, randomBytes(32).toString('hex')],
      )
    ).rows[0].id;
    await f.owner.query(
      "INSERT INTO app.config_events(command_id,actor_user_id,action,target,before_state,after_state) VALUES($1,$2,'setFlag','fixture','{}','{}')",
      [config, f.adminId],
    );
    await f.owner.query(
      `INSERT INTO app.driver_commands(id,actor_user_id,driver_id,operation,target,key_hash,input_hash,response_status,response_body,response_headers,created_at,replay_expires_at)
      VALUES(gen_random_uuid(),$1,$2::uuid,'updateDriver',$2::text,$3,repeat('a',64),200,'{"private":"snapshot"}','{}',${created},${created}+interval '7 days')`,
      [f.adminId, driver, randomBytes(32).toString('hex')],
    );
  }
  const snapshot = async () => {
    const result: Record<string, unknown> = {};
    for (const table of ['transport_commands', 'driver_commands', 'config_commands'])
      result[table] = (
        await f.owner.query(
          `SELECT to_jsonb(t)-ARRAY['response_body','response_headers','response_etag','secret_ciphertext'] AS retained FROM app.${table} t ORDER BY id`,
        )
      ).rows;
    result.events = (await f.owner.query('SELECT * FROM app.config_events ORDER BY id')).rows;
    return result;
  };
  const before = await snapshot();
  assert.equal(await purgeExpiredCommandPayloads(f.runtime, 1), 3);
  assert.equal(await purgeExpiredCommandPayloads(f.runtime, 1), 0);
  assert.deepEqual(await snapshot(), before);
  for (const table of ['transport_commands', 'driver_commands', 'config_commands']) {
    assert.deepEqual(
      (
        await f.owner.query(
          `SELECT count(*) FILTER(WHERE response_body IS NULL)::int AS cleared,count(*) FILTER(WHERE response_body IS NOT NULL)::int AS live FROM app.${table}`,
        )
      ).rows[0],
      { cleared: 1, live: 1 },
    );
    await assert.rejects(
      f.runtime.query(`UPDATE app.${table} SET response_body=NULL WHERE response_body IS NOT NULL`),
      /immutable/,
    );
    await assert.rejects(
      f.runtime.query(`UPDATE app.${table} SET response_body='{}' WHERE response_body IS NULL`),
      /immutable/,
    );
    await assert.rejects(
      f.runtime.query(`UPDATE app.${table} SET input_hash=repeat('b',64)`),
      /permission denied/,
    );
    await assert.rejects(f.runtime.query(`DELETE FROM app.${table}`), /permission denied/);
  }
  await assert.rejects(
    f.runtime.query(
      "INSERT INTO app.config_commands(actor_user_id,operation,target,key_hash,input_hash,response_body) VALUES($1,'setFlag','no-payload',repeat('c',64),repeat('a',64),NULL)",
      [f.adminId],
    ),
    /receipt_response_required/,
  );
  assert.deepEqual(await snapshot(), before);
});

test('ACR-08 forward upgrade scrubs settled task identities and refuses to discard unresolved legacy grants', async (t) => {
  const f = await setup(t, {}, false, 19);
  await f.owner.query(
    `INSERT INTO app.erasure_tasks(user_id,kind,reference,state,completed_at)
    VALUES ($1,'provider_revocation','apple:old-id:private-subject','done',clock_timestamp())`,
    [f.actor.userId],
  );
  await f.owner.query(
    `INSERT INTO app.account_commands(actor_user_id,operation,key_hash,input_hash)
    VALUES ($1,'eraseAccount',repeat('a',64),repeat('b',64))`,
    [f.actor.userId],
  );
  const applied = (
    await f.owner.query('SELECT name,sha256 FROM public._replacement_migrations ORDER BY name')
  ).rows;
  assert.deepEqual(await migrate(f.owner, files), [
    '020_account_recovery.sql',
    '021_receipt_payload_retention.sql',
    '022_transactional_email.sql',
    '023_rider_delivery.sql',
    '024_refund_initiation.sql',
    '025_personal_pauses.sql',
    '026_driver_assignment_delivery.sql',
  ]);
  assert.deepEqual(
    (
      await f.owner.query(
        'SELECT name,sha256 FROM public._replacement_migrations ORDER BY name LIMIT 19',
      )
    ).rows,
    applied,
  );
  const row = (await f.owner.query('SELECT * FROM app.erasure_tasks')).rows[0];
  assert.equal(row.reference, row.id);
  assert.ok(
    (await f.owner.query('SELECT expires_at FROM app.account_commands')).rows[0].expires_at,
  );
  const role = (await f.runtime.query('SELECT current_user AS name')).rows[0].name;
  await grantRuntime(f.owner, role);
  await assert.rejects(
    f.runtime.query("UPDATE app.account_commands SET input_hash=repeat('c',64)"),
    /permission denied/,
  );
  const g = await setup(t, {}, false, 19);
  await g.owner.query(
    "INSERT INTO app.erasure_tasks(user_id,kind,reference) VALUES ($1,'provider_revocation','apple:old-id:unresolved-subject')",
    [g.actor.userId],
  );
  await assert.rejects(
    migrate(g.owner, files),
    /drain_legacy_provider_tasks_before_account_upgrade/,
  );
  assert.equal(
    (await g.owner.query('SELECT reference FROM app.erasure_tasks')).rows[0].reference,
    'apple:old-id:unresolved-subject',
  );
  assert.equal(
    (await g.owner.query('SELECT count(*)::int n FROM public._replacement_migrations')).rows[0].n,
    19,
  );
});

test('ACR-01 stale profile and device retries replay without overwriting later commands', async (t) => {
  const f = await setup(t);
  const service = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
  });
  const key = randomUUID();
  const first = await service.handle(
    f.actor,
    'updateAccount',
    { displayName: 'First' },
    undefined,
    key,
  );
  await service.handle(
    f.actor,
    'updateAccount',
    { displayName: 'Corrected' },
    undefined,
    randomUUID(),
  );
  assert.deepEqual(
    await service.handle(f.actor, 'updateAccount', { displayName: 'First' }, undefined, key),
    first,
  );
  assert.equal(
    (await f.owner.query('SELECT display_name FROM app.users WHERE id=$1', [f.actor.userId]))
      .rows[0].display_name,
    'Corrected',
  );
  const token = randomUUID(),
    deviceKey = randomUUID();
  const device = await service.handle(
    f.actor,
    'registerDevice',
    { token, platform: 'android' },
    undefined,
    deviceKey,
  );
  await service.handle(
    f.other,
    'registerDevice',
    { token, platform: 'ios' },
    undefined,
    randomUUID(),
  );
  assert.deepEqual(
    await service.handle(
      f.actor,
      'registerDevice',
      { token, platform: 'android' },
      undefined,
      deviceKey,
    ),
    device,
  );
  assert.equal(
    (await f.owner.query('SELECT user_id FROM app.push_devices')).rows[0].user_id,
    f.other.userId,
  );
});

test('ACR-02 erasure racing a pending upload leaves durable cleanup and deletes the completed object', async (t) => {
  const f = await setup(t),
    entered = gate(),
    finish = gate();
  const objects = new Set<string>();
  const service = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
    avatars: {
      put: async ({ objectKey }) => {
        entered.release();
        await finish.promise;
        objects.add(objectKey);
        return { objectKey };
      },
      signedUrl: async (key) => `https://private.example/${key}`,
    },
    reach: {
      removeAvatarObject: async (key) => {
        objects.delete(key);
      },
    },
  });
  const upload = service.handle(f.actor, 'uploadAvatar', png, 'image/png', randomUUID()).then(
    () => null,
    (e) => e,
  );
  await entered.promise;
  assert.equal(
    (await service.handle(f.actor, 'eraseAccount', {}, undefined, randomUUID())).status,
    204,
  );
  assert.equal(
    (await f.owner.query("SELECT count(*)::int n FROM app.erasure_tasks WHERE state='uploading'"))
      .rows[0].n,
    1,
    'the pending external write is already discoverable',
  );
  finish.release();
  assert.equal((await upload).status, 401);
  assert.equal(objects.size, 1);
  assert.deepEqual(await service.retryErasures(), { considered: 1, completed: 1, failed: 0 });
  assert.equal(objects.size, 0);
  const task = (await f.owner.query('SELECT * FROM app.erasure_tasks')).rows[0];
  assert.equal(task.reference, task.id);
  assert.equal(task.payload_ciphertext, null);
});

test('ACR-03 revocation identity is encrypted while pending and scrubbed on completion; Google has no grant', async (t) => {
  const f = await setup(t),
    subject = 'sensitive-subject-' + randomUUID();
  await f.owner.query(
    "INSERT INTO app.auth_identities(user_id,provider,subject,provider_token_ciphertext) VALUES ($1,'apple',$2,'sealed-refresh')",
    [f.actor.userId, subject],
  );
  await f.owner.query(
    "INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,'google',$2)",
    [f.actor.userId, randomUUID()],
  );
  let reachable = false;
  const revoked: string[] = [];
  const service = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
    reach: {
      revokeProviderGrant: async (grant) => {
        if (!reachable) throw new Error('offline');
        revoked.push(grant.subject);
        assert.equal(grant.tokenCiphertext, 'sealed-refresh');
      },
    },
  });
  await service.handle(f.actor, 'eraseAccount', {}, undefined, randomUUID());
  const before = (await f.owner.query('SELECT * FROM app.erasure_tasks')).rows;
  assert.equal(before.length, 2);
  assert.equal(before.filter((r) => r.disposition === 'not_applicable').length, 1);
  assert.equal(JSON.stringify(before).includes(subject), false);
  const pending = before.find((r) => r.state === 'unavailable');
  assert.ok(pending.payload_ciphertext);
  assert.equal(pending.payload_ciphertext.includes(Buffer.from(subject)), false);
  assert.ok(
    (await f.owner.query('SELECT provider_token_ciphertext FROM app.auth_identities')).rows.every(
      (r) => r.provider_token_ciphertext === null,
    ),
  );
  reachable = true;
  assert.deepEqual(await service.retryErasures(), { considered: 1, completed: 1, failed: 0 });
  assert.deepEqual(revoked, [subject]);
  for (const row of (await f.owner.query('SELECT * FROM app.erasure_tasks')).rows) {
    assert.equal(row.state, 'done');
    assert.equal(row.reference, row.id);
    assert.equal(row.payload_ciphertext, null);
  }
});

test('ACR-04 committed erasure lease excludes a second worker while external work is blocked', async (t) => {
  const f = await setup(t),
    entered = gate(),
    finish = gate();
  let calls = 0;
  await f.owner.query(
    "INSERT INTO app.erasure_tasks(user_id,kind,reference) VALUES ($1,'avatar_object','object')",
    [f.actor.userId],
  );
  const service = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
    reach: {
      removeAvatarObject: async () => {
        calls++;
        entered.release();
        await finish.promise;
      },
    },
  });
  const a = service.retryErasures();
  await entered.promise;
  assert.ok(
    (await f.owner.query('SELECT claim_id,lease_until FROM app.erasure_tasks')).rows[0].claim_id,
  );
  assert.deepEqual(await service.retryErasures(), { considered: 0, completed: 0, failed: 0 });
  assert.equal(calls, 1);
  finish.release();
  assert.deepEqual(await a, { considered: 1, completed: 1, failed: 0 });
});

test('ACR-05 abandoned upload and expired worker leases are recoverable without retrying PUT', async (t) => {
  const f = await setup(t);
  let removed = 0;
  await f.owner.query(
    `INSERT INTO app.erasure_tasks(user_id,kind,reference,state,command_key_hash,input_hash,available_at,claim_id,lease_until)
    VALUES ($1,'avatar_object','abandoned','uploading',repeat('a',64),repeat('b',64),clock_timestamp()-interval '1 hour',gen_random_uuid(),clock_timestamp()-interval '1 minute')`,
    [f.actor.userId],
  );
  const service = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
    reach: {
      removeAvatarObject: async () => {
        removed++;
      },
    },
  });
  assert.deepEqual(await service.retryErasures(), { considered: 1, completed: 1, failed: 0 });
  assert.equal(removed, 1);
});

test('ACR-06 deletion replay accepts only a valid original JWT/session and exact key over HTTP', async (t) => {
  const f = await setup(t);
  const service = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
  });
  const tokens = accessTokens({
    secret: randomBytes(32),
    issuer: 'test',
    audience: 'test',
    ttlSeconds: 900,
  });
  const app = await createTransportApp({
    pool: f.runtime,
    cursorSecret: randomBytes(32),
    authorizeSession: f.dependencies.authorizeSession,
    coordinateReservations: async () => {},
    account: service,
    verifyAccess: tokens.verify,
    minimumBuilds: { ops: 1, driver: { ios: 1, android: 1 }, commuter: { ios: 1, android: 1 } },
  });
  t.after(() => app.close());
  const now = new Date(),
    token = await tokens.sign(f.actor, 'commuter', now, new Date(now.getTime() + 60000));
  const key = randomUUID();
  const call = (jwt: string, k = key, method: 'DELETE' | 'PATCH' = 'DELETE') =>
    app.inject({
      method,
      url: '/v1/me',
      headers: {
        authorization: `Bearer ${jwt}`,
        'x-trotxi-client': 'commuter',
        'x-trotxi-platform': 'android',
        'x-trotxi-build': '1',
        'idempotency-key': k,
      },
      ...(method === 'PATCH' ? { payload: { displayName: 'resurrect' } } : {}),
    });
  assert.equal((await call(token)).statusCode, 204);
  assert.equal((await call(token)).statusCode, 204);
  assert.equal((await call(token, randomUUID())).statusCode, 401);
  assert.equal((await call(token, key, 'PATCH')).statusCode, 401);
  const otherSession = await tokens.sign(
    { ...f.actor, sessionId: randomUUID() },
    'commuter',
    now,
    new Date(now.getTime() + 60000),
  );
  assert.equal((await call(otherSession)).statusCode, 401);
  const expired = await tokens.sign(
    f.actor,
    'commuter',
    new Date(now.getTime() - 120000),
    new Date(now.getTime() - 60000),
  );
  assert.equal((await call(expired)).statusCode, 401);
  assert.equal((await call(token + 'invalid')).statusCode, 401);
});

test('ACR-07 concurrent same-key uploads write one object and key expiry never reexecutes', async (t) => {
  const f = await setup(t);
  let puts = 0;
  const key = randomUUID(),
    encryptionKey = randomBytes(32);
  const service = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: encryptionKey,
    avatars: {
      put: async ({ objectKey }) => {
        puts++;
        return { objectKey };
      },
      signedUrl: async (k) => `https://private.example/${k}`,
    },
  });
  const result = await Promise.all([
    service.handle(f.actor, 'uploadAvatar', png, 'image/png', key),
    service.handle(f.actor, 'uploadAvatar', png, 'image/png', key),
  ]);
  assert.ok(result.every((r) => r.status === 200));
  assert.equal(puts, 1);
  const future = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: encryptionKey,
    now: () => new Date(Date.now() + 8 * 86400000),
  });
  const renameKey = randomUUID();
  await service.handle(f.actor, 'updateAccount', { displayName: 'Stored' }, undefined, renameKey);
  await assert.rejects(
    future.handle(f.actor, 'updateAccount', { displayName: 'Stored' }, undefined, renameKey),
    (e: any) => e.code === 'idempotency_expired',
  );
  await assert.rejects(
    f.runtime.query("UPDATE app.account_commands SET input_hash=repeat('c',64)"),
    /permission denied/,
  );
});

test('ACR-09 physical receipt cleanup clears only expired payloads and preserves retry tombstones', async (t) => {
  const f = await setup(t);
  const service = new AccountService({
    pool: f.runtime,
    authorizeSession: f.dependencies.authorizeSession,
    deviceKey: randomBytes(32),
  });
  await f.owner.query(
    `INSERT INTO app.account_commands(actor_user_id,operation,key_hash,input_hash,result,response_ciphertext,created_at,expires_at)
    VALUES ($1,'updateAccount',repeat('a',64),repeat('b',64),'old',decode('aa','hex'),clock_timestamp()-interval '8 days',clock_timestamp()-interval '1 day'),
      ($1,'updateAccount',repeat('c',64),repeat('d',64),'fresh',decode('bb','hex'),clock_timestamp(),clock_timestamp()+interval '7 days')`,
    [f.actor.userId],
  );
  assert.equal(await service.purgeExpiredReceipts(1), 1);
  const rows = (
    await f.owner.query(
      'SELECT key_hash,result,response_ciphertext FROM app.account_commands ORDER BY created_at',
    )
  ).rows;
  assert.equal(rows.length, 2);
  assert.equal(rows[0].result, null);
  assert.equal(rows[0].response_ciphertext, null);
  assert.equal(rows[1].result, 'fresh');
  assert.equal(await service.purgeExpiredReceipts(1), 0);
  await assert.rejects(
    f.runtime.query(
      "UPDATE app.account_commands SET response_ciphertext=decode('cc','hex') WHERE key_hash=repeat('a',64)",
    ),
    /immutable_account_command/,
  );
});
