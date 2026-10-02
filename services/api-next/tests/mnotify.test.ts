import { test } from 'node:test';
import assert from 'node:assert/strict';
import { ghanaPhone, MnotifySender, SmsSendError } from '../src/notifications/mnotify.js';

test('Ghana local and international numbers have one SMS identity', () => {
  for (const phone of ['024 123 4567', '233241234567', '+233241234567'])
    assert.equal(ghanaPhone(phone), '+233241234567');
  for (const phone of [
    '+15551234567',
    '241234567',
    '+2332412345678',
    '0301234567',
    '233301234567',
    '+233301234567',
  ])
    assert.throws(() => ghanaPhone(phone));
});

test('SMS explicit refusals differ from ambiguous responses and never leak provider bodies', async () => {
  for (const status of [400, 401, 402, 403, 404, 413, 422, 429, 500, 502, 408]) {
    const sender = new MnotifySender(
      'private-key',
      'TROTXI',
      (async () => new Response('private-key recipient PIN', { status })) as typeof fetch,
    );
    await assert.rejects(sender.send('0241234567', 'private PIN'), (error: unknown) => {
      assert.ok(error instanceof SmsSendError);
      assert.equal(error.outcome, [500, 502, 408].includes(status) ? 'unknown' : 'rejected');
      assert.ok(!error.message.includes('private'));
      return true;
    });
  }
  for (const [body, outcome] of [
    [{ summary: { total_sent: 0, total_rejected: 1 } }, 'rejected'],
    [{ status: 'error', code: 'undocumented-code' }, 'unknown'],
    [{ summary: { total_sent: 1, total_rejected: 0 } }, 'unknown'],
  ] as const) {
    const sender = new MnotifySender('private-key', 'TROTXI', (async () =>
      Response.json(body)) as typeof fetch);
    await assert.rejects(sender.send('0241234567', 'test'), (error: unknown) => {
      assert.ok(error instanceof SmsSendError);
      assert.equal(error.outcome, outcome);
      return true;
    });
  }
});
test('mNotify sends exactly once as a plain SMS, billed to SMS credits', async () => {
  let calls = 0;
  const sender = new MnotifySender('test-key', 'TROTXI', (async (url, init) => {
    calls++;
    assert.equal(String(url), 'https://api.mnotify.com/api/sms/quick?key=test-key');
    assert.deepEqual(JSON.parse(String(init?.body)), {
      recipient: ['233241234567'],
      sender: 'TROTXI',
      message: 'test code',
      is_schedule: false,
    });
    return Response.json({
      code: '2000',
      status: 'success',
      summary: {
        _id: 'receipt',
        total_sent: 1,
        total_rejected: 0,
      },
    });
  }) as typeof fetch);
  assert.equal(await sender.send('0241234567', 'test code'), 'receipt');
  assert.equal(calls, 1);
});
test('uncertain SMS outcomes never retry or expose secrets', async () => {
  let calls = 0;
  const sender = new MnotifySender('private-key', 'TROTXI', (async () => {
    calls++;
    throw new Error('private-key 0241234567 OTP 123456');
  }) as typeof fetch);
  await assert.rejects(sender.send('0241234567', '123456'), (error: unknown) => {
    assert.ok(error instanceof SmsSendError);
    assert.equal(error.message, 'sms_delivery_unconfirmed');
    return true;
  });
  assert.equal(calls, 1);
});
