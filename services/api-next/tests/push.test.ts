import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createCipheriv, generateKeyPairSync } from 'node:crypto';
import { setTimeout as delay } from 'node:timers/promises';
import type { Pool } from 'pg';
import { FcmSender, PushSendError } from '../src/notifications/fcm.js';
import { PushNotifications } from '../src/notifications/push.js';
const key = generateKeyPairSync('rsa', { modulusLength: 2048 }).privateKey.export({
  type: 'pkcs8',
  format: 'pem',
});
const credentials = JSON.stringify({
  type: 'service_account',
  project_id: 'trotxi-test',
  client_email: 'test@trotxi-test.iam.gserviceaccount.com',
  private_key: key,
  token_uri: 'https://untrusted.invalid',
});

for (const failure of ['write', 'commit'] as const) {
  test(`push stops new sends before a delayed rollback after ${failure} failure`, async () => {
    const gate = () => {
      let resolve!: () => void;
      const promise = new Promise<void>((done) => {
        resolve = done;
      });
      return { promise, resolve };
    };
    const allEntered = gate(),
      rollbackEntered = gate(),
      finishRollback = gate();
    const finishPeers = gate(),
      peersReleased = gate();
    const deviceKey = Buffer.alloc(32, 2),
      iv = Buffer.alloc(12, 1);
    const cipher = createCipheriv('aes-256-gcm', deviceKey, iv);
    const encrypted = Buffer.concat([cipher.update('test-token'), cipher.final()]);
    const ciphertext = Buffer.concat([iv, cipher.getAuthTag(), encrypted]);
    const candidates = Array.from({ length: 5 }, (_, i) => ({
      id: String(i + 1),
      user_id: String(i + 1),
    }));
    const sent: string[] = [];
    let connections = 0,
      releases = 0,
      peers = 0;
    const pool = {
      options: { max: 4 },
      query: async (sql: string) => ({ rows: sql.includes('SELECT id,user_id') ? candidates : [] }),
      connect: async () => {
        connections++;
        let user = '';
        return {
          query: async (sql: string, params?: unknown[]) => {
            if (sql.includes('FROM app.users WHERE id=')) user = String(params![0]);
            if (
              user === '1' &&
              ((failure === 'write' && sql.includes("SET state='accepted'")) ||
                (failure === 'commit' && sql === 'COMMIT'))
            )
              throw new Error(`database_${failure}_failed`);
            if (sql === 'ROLLBACK' && user === '1') {
              rollbackEntered.resolve();
              await finishRollback.promise;
            }
            if (sql.includes('SELECT * FROM app.push_deliveries'))
              return {
                rows: [
                  { id: user, user_id: user, device_id: user, reservation_id: user, attempts: 0 },
                ],
                rowCount: 1,
              };
            if (sql.includes('SELECT * FROM app.push_devices'))
              return {
                rows: [{ id: user, user_id: user, token_ciphertext: ciphertext }],
                rowCount: 1,
              };
            return { rows: [{ id: user }], rowCount: 1 };
          },
          release: () => {
            releases++;
            if (user !== '1' && ++peers === 3) peersReleased.resolve();
          },
        };
      },
    } as unknown as Pool;
    const push = new PushNotifications({
      pool,
      deviceKey,
      sender: {
        send: async (_, id) => {
          sent.push(id);
          if (sent.length === 4) allEntered.resolve();
          if (id === '1') await allEntered.promise;
          else await finishPeers.promise;
          return `accepted-${id}`;
        },
      },
    });
    let settled = false;
    const rejected = assert
      .rejects(push.drain(), new RegExp(`database_${failure}_failed`))
      .finally(() => {
        settled = true;
      });
    const deadline = new AbortController();
    try {
      await Promise.race([
        (async () => {
          await rollbackEntered.promise;
          finishPeers.resolve();
          await peersReleased.promise;
          await new Promise<void>((done) => setImmediate(done));
          assert.equal(settled, false, 'rollback must finish before drain settles');
          assert.equal(connections, 4, 'no fifth account may be claimed during rollback');
          assert.equal(sent.length, 4, 'no extra provider send while rollback is pending');
        })(),
        delay(5000, null, { signal: deadline.signal }).then(() =>
          assert.fail('rollback test stalled'),
        ),
      ]);
    } finally {
      deadline.abort();
      finishPeers.resolve();
      finishRollback.resolve();
      await rejected;
    }
    assert.equal(releases, 4);
  });
}
test('FCM driver assignment alerts contain no trip, driver, route or rider details', async () => {
  const sender = new FcmSender(credentials, async (url, init) => {
    if (String(url).includes('oauth2'))
      return Response.json({ access_token: 'test', expires_in: 3600 });
    const message = JSON.parse(String(init?.body)).message;
    assert.deepEqual(message.data, { type: 'driver_assignment', notificationId: 'event-delivery' });
    assert.equal(message.notification.title, 'Your schedule changed');
    assert.ok(!JSON.stringify(message).includes('private-trip'));
    return Response.json({ name: 'projects/test/messages/driver' });
  });
  await sender.send('device-token', 'event-delivery', 'private-trip', 'driver_assignment');
});
test('FCM-01 fixed endpoints, scoped OAuth, minimal data and cached short-lived token', async () => {
  const calls: { url: string; init?: RequestInit }[] = [];
  const sender = new FcmSender(credentials, async (url, init) => {
    calls.push({ url: String(url), init });
    if (String(url).includes('oauth2'))
      return Response.json({ access_token: 'test-access', expires_in: 3600 });
    assert.equal(init?.redirect, 'error');
    assert.ok(init?.signal);
    const body = JSON.parse(String(init?.body));
    assert.deepEqual(body.message.data, {
      type: 'reservation_prompt',
      notificationId: 'delivery',
      reservationId: 'reservation',
    });
    assert.equal(body.message.android.collapse_key, 'delivery');
    return Response.json({ name: 'projects/trotxi-test/messages/1' });
  });
  await sender.send('token', 'delivery', 'reservation');
  await sender.send('token', 'delivery', 'reservation');
  assert.equal(calls.length, 3);
  assert.equal(calls[0]!.url, 'https://oauth2.googleapis.com/token');
  assert.ok(
    calls
      .slice(1)
      .every((c) => c.url === 'https://fcm.googleapis.com/v1/projects/trotxi-test/messages:send'),
  );
  const jwt = new URLSearchParams(String(calls[0]!.init!.body)).get('assertion')!;
  const claims = JSON.parse(Buffer.from(jwt.split('.')[1]!, 'base64url').toString());
  assert.equal(claims.scope, 'https://www.googleapis.com/auth/firebase.messaging');
});
test('FCM-02 only UNREGISTERED revokes; transient/auth errors retry, huge responses are bounded', async () => {
  for (const [status, errorCode, retryable, invalid] of [
    [400, 'INVALID_ARGUMENT', false, false],
    [404, 'UNREGISTERED', false, true],
    [429, 'QUOTA_EXCEEDED', true, false],
    [503, 'UNAVAILABLE', true, false],
  ] as const) {
    const s = new FcmSender(credentials, async (url) =>
      String(url).includes('oauth2')
        ? Response.json({ access_token: 'test', expires_in: 3600 })
        : Response.json({ error: { details: [{ errorCode }] } }, { status }),
    );
    await assert.rejects(
      s.send('t', 'd', 'r'),
      (e) => e instanceof PushSendError && e.retryable === retryable && e.invalidToken === invalid,
    );
  }
  const huge = new FcmSender(credentials, async () => new Response('x'.repeat(65537)));
  await assert.rejects(huge.send('t', 'd', 'r'), (e) => e instanceof PushSendError);
  assert.throws(
    () => new FcmSender('{"private_key":"SECRET'),
    /^Error: Invalid FIREBASE_SERVICE_ACCOUNT$/,
  );
});

test('FCM concurrent sends share OAuth refresh and recover after a failed refresh', async () => {
  let refreshes = 0;
  const deliveries: string[] = [];
  const sender = new FcmSender(credentials, async (url, init) => {
    if (String(url).includes('oauth2')) {
      refreshes++;
      if (refreshes === 1) return new Response(null, { status: 503 });
      return Response.json({ access_token: 'refreshed', expires_in: 3600 });
    }
    assert.equal((init?.headers as Record<string, string>).authorization, 'Bearer refreshed');
    const message = JSON.parse(String(init?.body)).message;
    deliveries.push(message.data.notificationId);
    return Response.json({ name: `projects/test/messages/${message.data.notificationId}` });
  });
  const failed = await Promise.allSettled(
    Array.from({ length: 4 }, (_, i) => sender.send(`token-${i}`, `failed-${i}`, `ride-${i}`)),
  );
  assert.equal(refreshes, 1);
  assert.equal(deliveries.length, 0);
  for (const result of failed) {
    assert.equal(result.status, 'rejected');
    if (result.status === 'rejected') assert.ok(result.reason instanceof PushSendError);
  }
  await Promise.all(
    Array.from({ length: 4 }, (_, i) => sender.send(`token-${i}`, `sent-${i}`, `ride-${i}`)),
  );
  assert.equal(refreshes, 2);
  assert.deepEqual(deliveries.sort(), ['sent-0', 'sent-1', 'sent-2', 'sent-3']);
});
