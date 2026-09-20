import { test } from 'node:test';
import assert from 'node:assert/strict';
import { generateKeyPairSync } from 'node:crypto';
import { FcmSender, PushSendError } from '../src/notifications/fcm.js';
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
