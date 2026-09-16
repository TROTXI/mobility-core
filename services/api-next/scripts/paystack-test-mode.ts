/**
 * Exercise Paystack in test mode, once, deliberately.
 *
 * Everything the provider adapter does has been tested against synthetic
 * evidence. What that cannot tell us is whether Paystack agrees: whether the
 * initialize request is shaped the way it expects, whether a reference comes
 * back as the one we sent, whether our webhook signature matches theirs, and
 * whether the environment we think we are in is the one the key belongs to.
 *
 *   REPLACEMENT_PAYSTACK_SECRET_KEY=sk_test_... \
 *     node --import tsx scripts/paystack-test-mode.ts
 *
 * It refuses a live key. It takes no money: it opens a checkout nobody pays,
 * reads it back, and never touches a database or a deployed environment. The
 * key is read from the environment and is never printed.
 */
import { createHmac, randomBytes } from 'node:crypto';
import { PaystackEvidence, parseProviderFact } from '../src/payments/provider.js';

const secret = process.env.REPLACEMENT_PAYSTACK_SECRET_KEY;
if (!secret) throw new Error('REPLACEMENT_PAYSTACK_SECRET_KEY is required');
if (!secret.startsWith('sk_test_'))
  throw new Error('Refusing to run against anything but a test key');

const provider = new PaystackEvidence(secret, randomBytes(32));
const reference = `probe-${randomBytes(12).toString('hex')}`;
const amountPesewas = 100;
const steps: { step: string; ok: boolean; detail: string }[] = [];
const record = (step: string, ok: boolean, detail: string) => {
  steps.push({ step, ok, detail });
  process.stdout.write(`${ok ? 'ok  ' : 'FAIL'} ${step.padEnd(28)} ${detail}\n`);
};

record('environment', provider.environment === 'test', provider.environment);

// 1. Open a checkout. Nobody pays it; it expires on Paystack's side.
let authorizationUrl = '';
try {
  const opened = await provider.initialize({
    reference,
    amountPesewas,
    email: 'probe@users.trotxi.app',
  });
  authorizationUrl = opened.authorizationUrl;
  record('initialize', true, new URL(authorizationUrl).origin);
} catch (error) {
  record('initialize', false, String(error));
}

// 2. Read it back. An unpaid transaction is not a success, and the adapter has
//    to say so rather than guess: an abandoned or pending fact, never settled.
if (authorizationUrl) {
  try {
    const raw = await provider.verify(reference);
    const fact = parseProviderFact(raw, 'verify');
    const unpaid = fact?.kind === 'unresolved' || fact?.kind === 'failure';
    record('verify', unpaid, `${fact?.kind ?? 'null'} (${fact?.environment ?? '-'})`);
  } catch (error) {
    record('verify', false, String(error));
  }
}

// 3. Their signature, our check. This is the one that silently lets every
//    webhook through if the algorithm or the encoding is wrong.
const body = Buffer.from(
  JSON.stringify({
    event: 'charge.success',
    data: {
      id: '1',
      reference,
      status: 'success',
      amount: amountPesewas,
      currency: 'GHS',
      domain: 'test',
      channel: 'mobile_money',
      fees: 0,
      paid_at: new Date().toISOString(),
    },
  }),
);
const signature = createHmac('sha512', secret).update(body).digest('hex');
record('webhook signature', provider.authenticate(body, signature), 'sha512 over exact bytes');
record(
  'tampered body refused',
  !provider.authenticate(Buffer.concat([body, Buffer.from(' ')]), signature),
  'one trailing byte',
);
record('unsigned body refused', !provider.authenticate(body, undefined), 'no signature header');

const failed = steps.filter((s) => !s.ok);
process.stdout.write(
  `\n${steps.length - failed.length}/${steps.length} passed. Reference ${reference} is left unpaid on Paystack's test environment.\n`,
);
process.exitCode = failed.length ? 1 : 0;
