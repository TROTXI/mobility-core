import { test } from 'node:test';
import assert from 'node:assert/strict';
import { randomBytes, createHmac } from 'node:crypto';
import {
  PaystackEvidence,
  parseProviderFact,
  InvalidProviderFacts,
} from '../src/payments/provider.js';
import { reversalDebt } from '../src/payments/recovery.js';
const raw = (event: string, data: unknown) => Buffer.from(JSON.stringify({ event, data }));
const fields = {
  domain: 'test',
  currency: 'GHS',
  amount: 100,
  reference: 'tx-example',
  id: 1,
  paid_at: '2026-01-01T00:00:00Z',
  status: 'success',
};
test('PROV-REF: refund POST is TEST-only, bounded, exact-reference and never follows redirects', async () => {
  let count = 0,
    domain = 'test';
  const p = new PaystackEvidence('sk_test_fixture', randomBytes(32), async (url, init) => {
    count++;
    assert.equal(url, 'https://api.paystack.co/refund');
    assert.equal(init?.redirect, 'error');
    assert.deepEqual(JSON.parse(String(init?.body)), {
      transaction: 'tx-example',
      amount: 100,
      currency: 'GHS',
      merchant_note: 'trotxi-refund:11111111-1111-4111-8111-111111111111',
    });
    return Response.json({
      status: true,
      data: {
        id: 55,
        domain,
        currency: 'GHS',
        amount: 100,
        transaction: { reference: 'tx-example', domain },
      },
    });
  });
  assert.equal(
    await p.initiateRefund('tx-example', 100, '11111111-1111-4111-8111-111111111111'),
    '55',
  );
  domain = 'live';
  await assert.rejects(p.initiateRefund('tx-example', 100, '11111111-1111-4111-8111-111111111111'));
  const live = new PaystackEvidence('sk_live_fixture', randomBytes(32), async () => {
    count++;
    throw Error('must not call');
  });
  await assert.rejects(
    live.initiateRefund('tx-example', 100, '11111111-1111-4111-8111-111111111111'),
  );
  assert.equal(count, 2);
});
test('PROV-01: exact raw HMAC and authenticated encryption bind both ciphertext and context', () => {
  const p = new PaystackEvidence('sk_test_fixture', randomBytes(32));
  const bytes = raw('charge.success', fields);
  const signature = createHmac('sha512', 'sk_test_fixture').update(bytes).digest('hex');
  assert.equal(p.authenticate(bytes, signature), true);
  assert.equal(p.authenticate(Buffer.concat([bytes, Buffer.from(' ')]), signature), false);
  assert.equal(p.authenticate(bytes, 'x'.repeat(128)), false);
  const encrypted = p.seal(bytes, 'test:webhook:hash');
  assert.deepEqual(p.open(encrypted, 'test:webhook:hash'), bytes);
  assert.throws(() => p.open(encrypted, 'live:webhook:hash'));
  encrypted[29] = encrypted[29]! ^ 1;
  assert.throws(() => p.open(encrypted, 'test:webhook:hash'));
});
test('PROV-02: invalid money, absent refund identity and inconsistent events are refused', () => {
  for (const amount of [0, -1, 1.5, Number.MAX_SAFE_INTEGER + 1])
    assert.throws(
      () => parseProviderFact(raw('charge.success', { ...fields, amount }), 'webhook'),
      InvalidProviderFacts,
    );
  assert.throws(
    () => parseProviderFact(raw('charge.success', { ...fields, status: 'failed' }), 'webhook'),
    InvalidProviderFacts,
  );
  assert.throws(
    () =>
      parseProviderFact(
        raw('refund.processed', {
          ...fields,
          id: undefined,
          transaction_reference: 'tx-example',
          status: 'processed',
        }),
        'webhook',
      ),
    InvalidProviderFacts,
  );
  assert.throws(
    () =>
      parseProviderFact(raw('refund.constructor', { ...fields, status: 'constructor' }), 'webhook'),
    InvalidProviderFacts,
  );
  assert.equal(parseProviderFact(raw('charge.failed', fields), 'webhook'), null);
  assert.equal(
    parseProviderFact(raw('transaction.verify', { ...fields, status: 'failed' }), 'verify')?.kind,
    'failure',
  );
  assert.equal(
    parseProviderFact(raw('transaction.verify', { ...fields, status: 'ongoing' }), 'verify')?.kind,
    'unresolved',
  );
});
test('PROV-REF-ID: null pending reference and later reference share the stable refund id', () => {
  const refund = (state: string, id: unknown, reference: unknown) =>
    raw(`refund.${state}`, {
      domain: 'test',
      currency: 'GHS',
      amount: 26400,
      transaction_reference: 'tx-example',
      status: state,
      id,
      refund_reference: reference,
    });
  const pending = parseProviderFact(refund('pending', '12345', null), 'webhook');
  const processed = parseProviderFact(refund('processed', 12345, 'bank-ref-123'), 'webhook');
  assert.equal(pending?.kind, 'refund');
  assert.equal(processed?.kind, 'refund');
  if (pending?.kind !== 'refund' || processed?.kind !== 'refund') assert.fail('refund facts');
  assert.equal(pending.providerReference, 'paystack-refund-id:12345');
  assert.equal(processed.providerReference, pending.providerReference);
  assert.equal(pending.state, 'pending');
  assert.equal(processed.state, 'processed');
  for (const id of [-1, 1.5, true, '', 'not-an-id', Number.MAX_SAFE_INTEGER + 1])
    assert.throws(
      () => parseProviderFact(refund('pending', id, 'valid-ref'), 'webhook'),
      InvalidProviderFacts,
    );
  assert.throws(
    () => parseProviderFact(refund('pending', undefined, null), 'webhook'),
    InvalidProviderFacts,
  );
  const legacy = parseProviderFact(refund('processed', undefined, 'existing-ref'), 'webhook');
  assert.equal(legacy?.kind === 'refund' && legacy.providerReference, 'existing-ref');
});
test('PROV-03: Verify is exact-reference, exact-environment, size-bounded and never follows redirects', async () => {
  let data = { ...fields };
  let seen: RequestInit | undefined;
  const p = new PaystackEvidence('sk_test_fixture', randomBytes(32), async (url, init) => {
    assert.equal(url, 'https://api.paystack.co/transaction/verify/tx-example');
    seen = init;
    return Response.json({ status: true, data });
  });
  assert.equal(parseProviderFact(await p.verify('tx-example'), 'verify')?.kind, 'success');
  assert.equal(seen?.redirect, 'error');
  assert.ok(seen?.signal);
  data = { ...fields, reference: 'wrong' };
  await assert.rejects(p.verify('tx-example'));
  data = { ...fields, domain: 'live' };
  await assert.rejects(p.verify('tx-example'));
  const oversized = new PaystackEvidence(
    'sk_test_fixture',
    randomBytes(32),
    async () => new Response('x'.repeat(1048577)),
  );
  await assert.rejects(oversized.verify('tx-example'));
});
test('PROV-04: consumed-value estimation uses exact rounding, not converted rides', () => {
  assert.equal(reversalDebt(26400, 10, 44, 0), 6000);
  assert.equal(reversalDebt(26400, 0, 44, 1980), 1980);
  assert.equal(reversalDebt(101, 1, 2, 0), 51);
  assert.throws(() => reversalDebt(26400, 45, 44, 0));
});
