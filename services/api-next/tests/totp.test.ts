import assert from 'node:assert/strict';
import test from 'node:test';
import { randomBytes } from 'node:crypto';
import {
  base32Decode,
  base32Encode,
  codeAt,
  matchStep,
  newRecoveryCodes,
  otpauthUri,
  recoveryCodeHash,
  stepAt,
  totpSecretBox,
} from '../src/auth/totp.js';

// RFC 6238 Appendix B, SHA-1. The RFC prints eight digits; six-digit codes are
// the same value mod 10^6, which is its last six digits.
const RFC_SECRET = Buffer.from('12345678901234567890');
const RFC_VECTORS: [number, string][] = [
  [59, '287082'],
  [1111111109, '081804'],
  [1111111111, '050471'],
  [1234567890, '005924'],
  [2000000000, '279037'],
  [20000000000, '353130'],
];

test('TOTP-01 codes match the RFC 6238 test vectors', () => {
  for (const [seconds, expected] of RFC_VECTORS)
    assert.equal(codeAt(RFC_SECRET, stepAt(new Date(seconds * 1000))), expected, `t=${seconds}`);
});

test('TOTP-02 base32 round-trips and matches what authenticator apps expect', () => {
  // The RFC secret in base32, as it would appear in a QR code.
  assert.equal(base32Encode(RFC_SECRET), 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ');
  for (let i = 0; i < 50; i++) {
    const bytes = randomBytes(20);
    assert.deepEqual(base32Decode(base32Encode(bytes)), bytes);
  }
  assert.deepEqual(base32Decode('gezd gnbv-gy3tqojq gezdgnbvgy3tqojq'), RFC_SECRET);
});

test('TOTP-03 a phone clock a step off still works, two steps off does not', () => {
  const now = new Date(1234567890 * 1000);
  const step = stepAt(now);
  assert.equal(matchStep(RFC_SECRET, codeAt(RFC_SECRET, step), now, null), step);
  assert.equal(matchStep(RFC_SECRET, codeAt(RFC_SECRET, step - 1), now, null), step - 1);
  assert.equal(matchStep(RFC_SECRET, codeAt(RFC_SECRET, step + 1), now, null), step + 1);
  assert.equal(matchStep(RFC_SECRET, codeAt(RFC_SECRET, step - 2), now, null), null);
  assert.equal(matchStep(RFC_SECRET, codeAt(RFC_SECRET, step + 2), now, null), null);
});

test('TOTP-04 a code is dead once used, even inside its thirty seconds', () => {
  const now = new Date(1234567890 * 1000);
  const step = stepAt(now);
  const code = codeAt(RFC_SECRET, step);
  assert.equal(matchStep(RFC_SECRET, code, now, step), null, 'the same step again');
  assert.equal(
    matchStep(RFC_SECRET, codeAt(RFC_SECRET, step - 1), now, step),
    null,
    'an older one',
  );
});

test('TOTP-05 anything that is not six digits is refused before any comparison', () => {
  const now = new Date();
  for (const bad of ['', '12345', '1234567', 'abcdef', '12 345', ' 123456'])
    assert.equal(matchStep(RFC_SECRET, bad, now, null), null, JSON.stringify(bad));
});

test('TOTP-06 the enrolment link carries what every authenticator app needs', () => {
  const uri = new URL(otpauthUri(RFC_SECRET, 'ops@trotxi.com'));
  assert.equal(uri.protocol, 'otpauth:');
  assert.equal(uri.host, 'totp');
  assert.equal(decodeURIComponent(uri.pathname), '/Trotxi Ops:ops@trotxi.com');
  assert.equal(uri.searchParams.get('secret'), base32Encode(RFC_SECRET));
  assert.equal(uri.searchParams.get('issuer'), 'Trotxi Ops');
  assert.equal(uri.searchParams.get('period'), '30');
  assert.equal(uri.searchParams.get('digits'), '6');
});

test('TOTP-07 recovery codes are distinct, and typed any reasonable way they still match', () => {
  const codes = newRecoveryCodes();
  assert.equal(codes.length, 10);
  assert.equal(new Set(codes).size, 10);
  for (const code of codes) assert.match(code, /^[a-z2-7]{4}-[a-z2-7]{4}$/);
  const key = randomBytes(32);
  const code = codes[0]!;
  const stored = recoveryCodeHash(key, code);
  for (const typed of [code.toUpperCase(), code.replace('-', ''), ` ${code} `])
    assert.equal(recoveryCodeHash(key, typed), stored, typed);
  assert.notEqual(recoveryCodeHash(randomBytes(32), code), stored, 'the hash is keyed');
});

test('TOTP-08 a sealed secret opens only for the account it was sealed to', () => {
  const box = totpSecretBox(randomBytes(32));
  const secret = randomBytes(20);
  const sealed = box.seal(secret, 'user-a');
  assert.deepEqual(box.open(sealed, 'user-a'), secret);
  assert.throws(() => box.open(sealed, 'user-b'), 'moved onto another account');
  assert.equal(sealed.includes(base32Encode(secret)), false);
});
