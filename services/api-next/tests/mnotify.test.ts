import { test } from 'node:test';
import assert from 'node:assert/strict';
import { ghanaPhone, MnotifySender, SmsSendError } from '../src/notifications/mnotify.js';

test('Ghana local and international numbers have one SMS identity', () => {
  for (const phone of ['024 123 4567', '233241234567', '+233241234567'])
    assert.equal(ghanaPhone(phone), '+233241234567');
  for (const phone of ['+15551234567', '241234567', '+2332412345678'])
    assert.throws(() => ghanaPhone(phone));
});
test('mNotify OTP sends exactly once using the documented recipient and OTP format', async () => {
  let calls = 0;
  const sender = new MnotifySender('test-key', 'TROTXI', (async (url, init) => {
    calls++;
    assert.equal(String(url), 'https://api.mnotify.com/api/sms/quick?key=test-key');
    assert.deepEqual(JSON.parse(String(init?.body)), {
      recipient: ['233241234567'],
      sender: 'TROTXI',
      message: 'test code',
      is_schedule: false,
      sms_type: 'otp',
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
  assert.equal(await sender.send('0241234567', 'test code', true), 'receipt');
  assert.equal(calls, 1);
});
test('uncertain SMS outcomes never retry or expose secrets', async () => {
  let calls = 0;
  const sender = new MnotifySender('private-key', 'TROTXI', (async () => {
    calls++;
    throw new Error('private-key 0241234567 OTP 123456');
  }) as typeof fetch);
  await assert.rejects(sender.send('0241234567', '123456', true), (error: unknown) => {
    assert.ok(error instanceof SmsSendError);
    assert.equal(error.message, 'sms_delivery_unconfirmed');
    return true;
  });
  assert.equal(calls, 1);
});
