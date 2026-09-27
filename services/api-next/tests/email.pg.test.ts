import { test, type TestContext } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { setup } from './helpers/financial-fixture.js';
import { FinancialFoundation } from '../src/payments/foundation.js';
import { AccountService } from '../src/account/service.js';
import { TransactionalEmail } from '../src/notifications/email.js';
import {
  EmailSendError,
  type EmailMessage,
  type EmailSender,
} from '../src/notifications/resend.js';

async function fixture(t: TestContext, sender?: EmailSender) {
  const f = await setup(t),
    calls: { message: EmailMessage; key: string }[] = [];
  await f.owner.query('UPDATE app.users SET email=$2 WHERE id=$1', [
    f.actor.userId,
    'rider@example.com',
  ]);
  const email = new TransactionalEmail({
    pool: f.runtime,
    encryptionKey: randomBytes(32),
    staging: true,
    sender: sender ?? {
      send: async (message, key) => {
        calls.push({ message, key });
        return 'provider-id';
      },
    },
  });
  const financial = new FinancialFoundation({
    ...f.dependencies,
    subscriptionActive: email.subscriptionActive,
  });
  const buy = async (paidAt = new Date()) => {
    const p = await financial.checkout(f.actor, f.input, randomUUID(), paidAt);
    await financial.fulfill(f.settle(p, paidAt));
    return p;
  };
  const rows = async () =>
    (await f.owner.query('SELECT * FROM app.email_outbox ORDER BY created_at,id')).rows;
  return { ...f, email, financial, buy, rows, calls };
}

test('EMAIL-01 fulfilment commits one encrypted activation; replay cannot queue or send twice', async (t) => {
  const f = await fixture(t),
    p = await f.buy();
  const before = await f.rows();
  assert.equal(before.length, 1);
  assert.equal(JSON.stringify(before).includes('rider@example.com'), false);
  assert.equal(await f.financial.fulfill(f.settle(p)), 'already_fulfilled');
  assert.equal((await f.rows()).length, 1);
  assert.equal((await f.email.drain()).accepted, 1);
  assert.equal((await f.email.drain()).considered, 0);
  assert.equal(f.calls.length, 1);
  assert.match(f.calls[0]!.message.subject, /STAGING TEST/);
  assert.match(f.calls[0]!.message.text, /Rides added: 44/);
  assert.match(f.calls[0]!.message.text, /GHS 264.00/);
  assert.match(f.calls[0]!.message.text, /Renewal is manual/);
  const row = (await f.rows())[0];
  assert.equal(row.payload_ciphertext, null);
  assert.equal(row.state, 'accepted');
  await assert.rejects(
    f.runtime.query(
      "UPDATE app.email_outbox SET state='pending',payload_ciphertext='restored' WHERE id=$1",
      [row.id],
    ),
    /email_identity_immutable/,
  );
});
test('EMAIL-02 rollback after enqueue leaves no email and no financial effect', async (t) => {
  const f = await fixture(t);
  let injected = false;
  const service = new FinancialFoundation({
    ...f.dependencies,
    subscriptionActive: async (...args) => {
      await f.email.subscriptionActive(...args);
      injected = true;
      throw new Error('controlled fault after enqueue');
    },
  });
  const p = await service.checkout(f.actor, f.input, randomUUID());
  await assert.rejects(service.fulfill(f.settle(p)), /operation could not be completed/);
  assert.equal(injected, true, 'the failure must reach the post-enqueue checkpoint');
  assert.equal((await f.rows()).length, 0);
  assert.equal(
    (await f.owner.query('SELECT count(*)::int AS n FROM app.billing_periods')).rows[0].n,
    0,
  );
  assert.equal(
    (await f.owner.query('SELECT state FROM app.purchases WHERE id=$1', [p.id])).rows[0].state,
    'awaiting_payment',
  );
});
test('EMAIL-03 two workers contend while provider is in flight and only one sends', async (t) => {
  let started!: () => void, release!: () => void;
  const entered = new Promise<void>((r) => (started = r)),
    wait = new Promise<void>((r) => (release = r));
  let sends = 0;
  const f = await fixture(t, {
    send: async () => {
      sends++;
      started();
      await wait;
      return 'accepted';
    },
  });
  await f.buy();
  const first = f.email.drain(1);
  await entered;
  assert.equal((await f.email.drain(1)).considered, 0);
  release();
  assert.equal((await first).accepted, 1);
  assert.equal(sends, 1);
});
test('EMAIL-04 ambiguous provider failure retries identical content and key within the retry window', async (t) => {
  const attempts: { message: EmailMessage; key: string }[] = [];
  const f = await fixture(t, {
    send: async (message, key) => {
      attempts.push({ message, key });
      if (attempts.length === 1) throw new EmailSendError(true);
      return 'accepted';
    },
  });
  await f.buy();
  assert.equal((await f.email.drain(1)).retried, 1);
  assert.equal((await f.email.drain(1)).considered, 0);
  await f.owner.query('UPDATE app.email_outbox SET next_attempt_at=clock_timestamp()');
  assert.equal((await f.email.drain(1)).accepted, 1);
  assert.deepEqual(attempts[0], attempts[1]);
});
test('EMAIL-05 expiry and exhausted provider window erase content without a new send', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const row = (await f.rows())[0];
  // Seed a separate stale row with ciphertext from another id: if the expiry
  // branch is removed it fails invalid_payload, not this expected outcome.
  await f.owner.query(
    `INSERT INTO app.email_outbox(user_id,kind,source_id,dedupe_key,payload_ciphertext,created_at,expires_at)
    VALUES($1,'subscription_active',$2,'expired',$3,transaction_timestamp()-interval '8 days',transaction_timestamp()-interval '1 day')`,
    [f.actor.userId, row.source_id, row.payload_ciphertext],
  );
  await f.owner.query(
    `INSERT INTO app.email_outbox(user_id,kind,source_id,dedupe_key,payload_ciphertext,first_attempt_at)
    VALUES($1,'subscription_active',$2,'uncertain',$3,clock_timestamp()-interval '24 hours')`,
    [f.actor.userId, row.source_id, row.payload_ciphertext],
  );
  const result = await f.email.drain();
  assert.equal(result.accepted, 1);
  assert.equal(result.cancelled, 1);
  assert.equal(result.unknown, 1);
  assert.equal(f.calls.length, 1);
  assert.ok((await f.rows()).every((r) => r.payload_ciphertext === null));
});
test('EMAIL-06 erasure cancels normal mail and retains only an encrypted, short-lived request acknowledgement', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const c = await f.runtime.connect();
  try {
    await c.query('BEGIN');
    await c.query('SELECT id FROM app.users WHERE id=$1 FOR UPDATE', [f.actor.userId]);
    await f.email.erasureRequested(c, f.actor.userId, 'rider@example.com');
    await c.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [
      f.actor.userId,
    ]);
    await c.query('COMMIT');
  } finally {
    c.release();
  }
  assert.equal(
    (await f.rows()).find((r) => r.kind === 'subscription_active').payload_ciphertext,
    null,
  );
  assert.equal((await f.email.drain()).accepted, 1);
  assert.equal(f.calls.length, 1);
  assert.match(f.calls[0]!.message.text, /cleanup may still be processing/);
  assert.equal(
    (await f.owner.query('SELECT email FROM app.users WHERE id=$1', [f.actor.userId])).rows[0]
      .email,
    null,
  );
});
test('EMAIL-07 expiry reminder is deduplicated and cancelled if coverage extends before send', async (t) => {
  const f = await fixture(t);
  const now = new Date();
  // Choose a paid-at date whose monthly end is two days away without assuming
  // every month has 30 days. The period's actual end is the source of truth.
  const paid = new Date(now);
  paid.setUTCDate(1);
  paid.setUTCMonth(paid.getUTCMonth() - 1);
  const p = await f.buy(paid);
  await f.email.drain();
  const end = new Date(now.getTime() + 2 * 86400000);
  await f.owner.query('UPDATE app.billing_periods SET effective_ends_at=$2 WHERE purchase_id=$1', [
    p.id,
    end,
  ]);
  await f.email.prepareReminders();
  await f.email.prepareReminders();
  assert.equal((await f.rows()).filter((r) => r.kind === 'subscription_expiring').length, 1);
  await f.owner.query(
    "UPDATE app.billing_periods SET effective_ends_at=effective_ends_at+interval '10 days' WHERE purchase_id=$1",
    [p.id],
  );
  const result = await f.email.drain();
  assert.equal(result.cancelled, 1);
  assert.equal(f.calls.length, 1);
});
test('EMAIL-08 permanent rejection is terminal and blank addresses never enqueue', async (t) => {
  const f = await fixture(t, {
    send: async () => {
      throw new EmailSendError(false);
    },
  });
  await f.buy();
  assert.equal((await f.email.drain()).failed, 1);
  assert.equal((await f.email.drain()).considered, 0);
  const c = await f.runtime.connect();
  try {
    await f.email.erasureRequested(c, f.other.userId, null);
  } finally {
    c.release();
  }
  assert.equal((await f.rows()).length, 1);
});

test('EMAIL-09 account erasure cancels mail at the SQL boundary even without an email hook', async (t) => {
  const f = await fixture(t);
  await f.buy();
  await f.owner.query('UPDATE app.users SET deleted_at=clock_timestamp() WHERE id=$1', [
    f.actor.userId,
  ]);
  const row = (await f.rows())[0];
  assert.equal(row.state, 'cancelled');
  assert.equal(row.payload_ciphertext, null);
  assert.equal((await f.email.drain()).considered, 0);
  assert.equal(f.calls.length, 0);
});
test('EMAIL-10 expired worker lease recovers using original identity', async (t) => {
  const f = await fixture(t);
  await f.buy();
  const row = (await f.rows())[0];
  await f.owner.query(
    `UPDATE app.email_outbox SET claim_id=$2,lease_until=clock_timestamp()-interval '1 minute',
    first_attempt_at=clock_timestamp()-interval '2 minutes' WHERE id=$1`,
    [row.id, randomUUID()],
  );
  const first = (await f.rows())[0].first_attempt_at;
  assert.equal((await f.email.drain()).accepted, 1);
  assert.equal(f.calls[0]!.key, `trotxi-email/${row.id}`);
  assert.deepEqual((await f.rows())[0].first_attempt_at, first);
  assert.equal((await f.rows())[0].attempts, 1);
});
test('EMAIL-11 real account service wires deletion acknowledgement before erasure; replay stays unique', async (t) => {
  const f = await fixture(t);
  await f.owner.query(
    "INSERT INTO app.auth_sessions(id,user_id,expires_at) VALUES($1,$2,clock_timestamp()+interval '1 hour')",
    [f.actor.sessionId, f.actor.userId],
  );
  const account = new AccountService({
    pool: f.runtime,
    deviceKey: randomBytes(32),
    authorizeSession: f.dependencies.authorizeSession,
    erasureRequested: f.email.erasureRequested,
  });
  const key = randomUUID();
  assert.equal((await account.handle(f.actor, 'eraseAccount', {}, undefined, key)).status, 204);
  assert.equal((await account.handle(f.actor, 'eraseAccount', {}, undefined, key)).status, 204);
  assert.equal((await f.rows()).length, 1);
  assert.equal((await f.email.drain()).accepted, 1);
});
