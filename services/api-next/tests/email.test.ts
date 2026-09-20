import { test } from 'node:test';
import assert from 'node:assert/strict';
import { ResendSender, EmailSendError } from '../src/notifications/resend.js';
import { jobFailed } from '../src/runtime/job-outcome.js';

const message = {
  from: 'Trotxi <hello@notifications.trotxi.com>',
  to: 'delivered@resend.dev',
  subject: 'Test',
  text: 'No payment was taken.',
};
test('EMAIL-U1 Resend sends fixed-origin authenticated requests with stable idempotency and no redirects', async () => {
  const calls: RequestInit[] = [];
  const sender = new ResendSender('re_fixture', async (url, init) => {
    assert.equal(url, 'https://api.resend.com/emails');
    calls.push(init!);
    return new Response(JSON.stringify({ id: 'provider-id' }), { status: 200 });
  });
  assert.equal(await sender.send(message, 'stable-key'), 'provider-id');
  await sender.send(message, 'stable-key');
  assert.deepEqual(calls[0]!.headers, calls[1]!.headers);
  assert.equal((calls[0]!.headers as any)['Idempotency-Key'], 'stable-key');
  assert.equal(calls[0]!.redirect, 'error');
  assert.ok(calls[0]!.signal instanceof AbortSignal);
  assert.deepEqual(JSON.parse(String(calls[0]!.body)), { ...message, to: [message.to] });
});
test('EMAIL-U2 provider errors are sanitized, classify retries, and never leak addresses or keys', async () => {
  for (const status of [400, 401, 403, 422, 429, 409, 500, 503]) {
    const sender = new ResendSender(
      're_fixture',
      async () => new Response('private recipient/key', { status }),
    );
    await assert.rejects(
      sender.send(message, 'key'),
      (e: unknown) =>
        e instanceof EmailSendError &&
        e.retryable === (status === 429 || status === 409 || status >= 500) &&
        !String(e).includes('private'),
    );
  }
  for (const response of [
    () => {
      throw new Error('secret from network');
    },
    () => new Response('{}'),
  ]) {
    const sender = new ResendSender('re_fixture', async () => response());
    await assert.rejects(
      sender.send(message, 'key'),
      (e: unknown) => e instanceof EmailSendError && e.retryable && !String(e).includes('secret'),
    );
  }
});
test('EMAIL-U3 worker marks retries and unknown outcomes non-successful instead of hiding them', () => {
  const body = { considered: 1, accepted: 1, cancelled: 0, failed: 0, retried: 0, unknown: 0 };
  assert.equal(jobFailed({ job: 'emails', status: 200, body }), false);
  for (const key of ['failed', 'retried', 'unknown'])
    assert.equal(jobFailed({ job: 'emails', status: 200, body: { ...body, [key]: 1 } }), true);
  assert.throws(
    () => jobFailed({ job: 'emails', status: 200, body: { sent: 1 } }),
    /contract_drift/,
  );
});
