import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { ErasureJournal, keyHash, type Journal } from '../src/account/erasure-journal.js';
import { MemoryErasureStore } from './helpers/erasure-store.js';
import { R2ErasureJournalStore } from '../src/runtime/erasure-journal-store.js';
import { readErasureJournalConfiguration } from '../src/runtime/config.js';

test('journal authenticates scope and content, creates once, and cannot lose concurrent entries', async () => {
  const store = new MemoryErasureStore(),
    namespace = randomUUID(),
    key = randomBytes(32),
    device = randomBytes(32);
  const journal = new ErasureJournal(store, namespace, key);
  const initial: Journal = {
    version: 1,
    namespace,
    writer: randomUUID(),
    database: 'source',
    revision: 0,
    fenced: false,
    deviceKeyHash: keyHash(device),
    entries: [],
  };
  await journal.write(initial, null);
  await assert.rejects(journal.write(initial, null), /conflict/);
  const snapshot = await journal.require();
  const user = randomUUID();
  await journal.record(initial.writer, 'source', device, user, randomUUID());
  await assert.rejects(journal.write(initial, snapshot.etag), /conflict/);
  assert.equal((await journal.require()).value.entries[0]?.userId, user);
  await assert.rejects(new ErasureJournal(store, randomUUID(), key).read());
  await assert.rejects(new ErasureJournal(store, namespace, randomBytes(32)).read());
  store.value!.bytes[30] = store.value!.bytes[30]! ^ 1;
  await assert.rejects(journal.read());
});

test('R2 journal signs conditional writes, bounds reads and refuses redirects or unsuccessful writes', async () => {
  const config = {
    accountId: 'a'.repeat(32),
    accessKeyId: 'test',
    secretAccessKey: 'test',
    bucket: 'test-erasure',
    namespace: randomUUID(),
    key: randomBytes(32),
  };
  const seen: RequestInit[] = [];
  let status = 200;
  const store = new R2ErasureJournalStore(config, async (_url, options) => {
    seen.push(options!);
    return new Response(status === 200 ? new Uint8Array([1, 2, 3]) : null, {
      status,
      headers: { etag: '"abc"' },
    });
  });
  await store.replace(Buffer.from('encrypted'), null);
  const create = seen[0]!.headers as Record<string, string>;
  assert.equal(create['if-none-match'], '*');
  assert.match(create.authorization!, /SignedHeaders=.*if-none-match/);
  assert.equal(seen[0]!.redirect, 'error');
  await store.replace(Buffer.from('next'), '"abc"');
  assert.equal((seen[1]!.headers as Record<string, string>)['if-match'], '"abc"');
  assert.deepEqual((await store.read())?.bytes, Buffer.from([1, 2, 3]));
  status = 412;
  await assert.rejects(store.replace(Buffer.from('stale'), '"abc"'), /conflict/);
  const big = new R2ErasureJournalStore(
    config,
    async () => new Response(new Uint8Array(2 * 1024 * 1024 + 1), { headers: { etag: '"big"' } }),
  );
  await assert.rejects(big.read(), /too_large/);
});

test('journal configuration is opt-in but partial or shared-bucket configuration fails closed', () => {
  assert.equal(readErasureJournalConfiguration({}), undefined);
  assert.throws(
    () => readErasureJournalConfiguration({ ERASURE_JOURNAL_BUCKET: 'test' }),
    /required/,
  );
  const config = {
    ERASURE_JOURNAL_ACCOUNT_ID: 'a'.repeat(32),
    ERASURE_JOURNAL_ACCESS_KEY_ID: 'test',
    ERASURE_JOURNAL_SECRET_ACCESS_KEY: 'test',
    ERASURE_JOURNAL_BUCKET: 'separate',
    ERASURE_JOURNAL_NAMESPACE: randomUUID(),
    ERASURE_JOURNAL_KEY: randomBytes(32).toString('hex'),
  };
  assert.equal(readErasureJournalConfiguration(config)?.bucket, 'separate');
  assert.throws(
    () => readErasureJournalConfiguration({ ...config, REPLACEMENT_R2_BUCKET_NAME: 'separate' }),
    /separate private bucket/,
  );
});
