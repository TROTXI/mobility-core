import { parseArgs } from 'node:util';
import { z } from 'zod';
import { readPrivateEnvironment } from '../src/runtime/rehearsal.js';
import { ResendSender } from '../src/notifications/resend.js';

// Explicit recipient and stable key: running the same command again within
// Resend's 24h window must not send another message. Never logs env or recipient.
try {
  const { values } = parseArgs({
    options: {
      'env-file': { type: 'string' },
      to: { type: 'string' },
      key: { type: 'string' },
    },
    strict: true,
    allowPositionals: false,
  });
  if (
    !values['env-file'] ||
    !z.email().safeParse(values.to).success ||
    !values.key ||
    !/^[a-zA-Z0-9_-]{1,100}$/.test(values.key)
  )
    throw new Error('Explicit private env file, recipient and idempotency key required');
  const env = await readPrivateEnvironment(values['env-file']);
  const sender = new ResendSender(env.RESEND_API_KEY ?? '');
  const id = await sender.send(
    {
      from: 'Trotxi <hello@notifications.trotxi.com>',
      to: values.to!,
      subject: '[STAGING TEST] Trotxi email connection verified',
      text: 'This is the single Trotxi staging email test you approved. Resend is connected to notifications.trotxi.com. No payment, subscription or account change was made. You can ignore this message.',
    },
    `trotxi-test/${values.key}`,
  );
  process.stdout.write(
    JSON.stringify({ accepted: true, providerId: id, delivered: 'not verified' }) + '\n',
  );
} catch {
  process.stderr.write(
    'Email test not confirmed. Check the private configuration and provider dashboard; retry only with the same key within 24 hours.\n',
  );
  process.exitCode = 1;
}
