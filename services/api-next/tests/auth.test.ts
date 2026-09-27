import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHash, randomUUID } from 'node:crypto';
import { createLocalJWKSet, exportJWK, generateKeyPair, SignJWT } from 'jose';
import { GoogleIdTokenVerifier } from '../src/auth/id-token-verifier.google.js';
import { AppleIdTokenVerifier } from '../src/auth/id-token-verifier.apple.js';
import { accessTokens, hashToken, newRefresh, providerTokenBox } from '../src/auth/credentials.js';
import {
  generateDriverCode,
  generatePin,
  hashDriverPin,
  isTrivialPin,
  normalizeDriverCode,
  verifyDriverPin,
} from '../src/auth/driver-pin.js';
import { AuthService } from '../src/auth/service.js';
import type { AuthOptions } from '../src/auth/service.js';
import { credentialReplay } from '../src/auth/secret-replay.js';

const pair = await generateKeyPair('RS256'),
  jwk = await exportJWK(pair.publicKey);
const keys = createLocalJWKSet({ keys: [{ ...jwk, kid: 'test' }] });
const google = new GoogleIdTokenVerifier('web-client', keys),
  apple = new AppleIdTokenVerifier(['ios-client', 'web-apple'], keys);

test('DRV-U01: PIN replay ciphertext and input digests are key/context bound', () => {
  const box = credentialReplay(Buffer.alloc(32, 11)),
    secret = { data: { code: 'DR-B7K9', pin: '938755' } },
    cipher = box.seal(secret, 'receipt-one');
  assert.deepEqual(box.open(cipher, 'receipt-one'), secret);
  assert.notEqual(box.seal(secret, 'receipt-one'), cipher);
  assert.throws(() => box.open(cipher, 'receipt-two'));
  assert.throws(() => credentialReplay(Buffer.alloc(32, 12)).open(cipher, 'receipt-one'));
  assert.throws(() => box.open('short', 'receipt-one'));
  assert.throws(() => credentialReplay(Buffer.alloc(1)));
  assert.throws(() => credentialReplay(undefined as unknown as Buffer), /Dedicated 32-byte/);
  const input = JSON.stringify({ currentPin: '938755', newPin: '738194' });
  assert.notEqual(box.digest(input), createHash('sha256').update(input).digest('hex'));
  assert.notEqual(box.digest(input), credentialReplay(Buffer.alloc(32, 12)).digest(input));
  assert.equal(box.digest(input), box.digest(input));
});
async function token(
  issuer: string,
  audience: string,
  claims: Record<string, unknown> = {},
  expired = false,
) {
  return new SignJWT(claims)
    .setProtectedHeader({ alg: 'RS256', kid: 'test' })
    .setSubject('provider-subject')
    .setIssuer(issuer)
    .setAudience(audience)
    .setIssuedAt()
    .setExpirationTime(expired ? '0s' : '5m')
    .sign(pair.privateKey);
}
test('AUTH-U01: Google signature, issuer, audience, expiry and verified email are checked', async () => {
  assert.deepEqual(
    await google.verify(
      await token('https://accounts.google.com', 'web-client', {
        email: 'test@example.invalid',
        email_verified: true,
        name: 'Test',
      }),
    ),
    {
      provider: 'google',
      providerId: 'provider-subject',
      email: 'test@example.invalid',
      displayName: 'Test',
    },
  );
  for (const [issuer, aud, claims, expired] of [
    ['https://evil.invalid', 'web-client', {}, false],
    ['https://accounts.google.com', 'ios-client', {}, false],
    ['https://accounts.google.com', 'web-client', {}, true],
    ['https://accounts.google.com', 'web-client', { email: 'test@example.invalid' }, false],
    [
      'https://accounts.google.com',
      'web-client',
      { email: 'test@example.invalid', email_verified: false },
      false,
    ],
  ] as const)
    await assert.rejects(google.verify(await token(issuer, aud, claims, expired)));
  const valid = await token('https://accounts.google.com', 'web-client');
  const parts = valid.split('.');
  parts[1] = Buffer.from(JSON.stringify({ sub: 'tampered' })).toString('base64url');
  await assert.rejects(google.verify(parts.join('.')));
});
test('AUTH-U02: Apple string booleans, relay address, raw/hashed nonce and multiple audiences', async () => {
  for (const audience of ['ios-client', 'web-apple'])
    for (const nonce of ['raw', createHash('sha256').update('raw').digest('hex')]) {
      const t = await token('https://appleid.apple.com', audience, {
        email: 'relay@privaterelay.appleid.com',
        email_verified: 'true',
        nonce,
      });
      assert.equal((await apple.verify(t, 'raw')).email, 'relay@privaterelay.appleid.com');
      await assert.rejects(apple.verify(t));
      await assert.rejects(apple.verify(t, 'wrong'));
    }
  assert.equal(
    (await apple.verify(await token('https://appleid.apple.com', 'ios-client'))).provider,
    'apple',
  );
  await assert.rejects(
    apple.verify(
      await token('https://appleid.apple.com', 'ios-client', {
        email: 'x',
        email_verified: 'false',
      }),
    ),
  );
  await assert.rejects(apple.verify(await token('https://appleid.apple.com', 'other')));
});
test('AUTH-U03: own access tokens carry a session and cannot be provider tokens or wrong-audience JWTs', async () => {
  const config = {
    secret: Buffer.alloc(32, 4),
    issuer: 'trotxi-api-next',
    audience: 'trotxi-access',
    ttlSeconds: 900,
  };
  const access = accessTokens(config),
    actor = { userId: randomUUID(), sessionId: randomUUID() };
  const now = new Date(),
    expires = new Date(Date.now() + 900000);
  const t = await access.sign(actor, 'admin', now, expires);
  assert.deepEqual(await access.verify(`Bearer ${t}`), actor);
  assert.equal(await accessTokens({ ...config, audience: 'boarding' }).verify(`Bearer ${t}`), null);
  assert.equal(
    await accessTokens({ ...config, secret: Buffer.alloc(32, 8) }).verify(`Bearer ${t}`),
    null,
  );
  assert.equal(
    await access.verify(`Bearer ${await token('https://accounts.google.com', 'web-client')}`),
    null,
  );
  assert.equal(
    await access.verify(`Bearer ${await access.sign(actor, 'admin', new Date(0), new Date(1))}`),
    null,
  );
  const noSid = await new SignJWT({ role: 'admin' })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(actor.userId)
    .setIssuer(config.issuer)
    .setAudience(config.audience)
    .setIssuedAt()
    .setExpirationTime('5m')
    .sign(config.secret);
  assert.equal(await access.verify(`Bearer ${noSid}`), null);
});
test('AUTH-U04: PIN primitives retain the existing format, normalization and weak-PIN rules', () => {
  const secret = 'disposable-unit-key'.repeat(3);
  assert.equal(normalizeDriverCode(' dr - b7k9 '), 'DR-B7K9');
  assert.equal(normalizeDriverCode('b7k9'), 'DR-B7K9');
  // Vector independently evaluated with the deployed driver's helper.
  assert.equal(
    hashDriverPin('938755', secret),
    'f7bfe377746b75fed008250bac5e2771890c9aebb3dde3841f3f2ef9b3c20876',
  );
  assert.equal(verifyDriverPin('938755', hashDriverPin('938755', secret), secret), true);
  assert.equal(verifyDriverPin('938754', hashDriverPin('938755', secret), secret), false);
  for (const pin of ['111111', '123456', '654321', '12x456', '12345'])
    assert.equal(isTrivialPin(pin), true);
  for (let i = 0; i < 50; i++) {
    assert.equal(isTrivialPin(generatePin()), false);
    assert.match(generateDriverCode(), /^DR-[23456789ABCDEFGHJKMNPQRSTVWXYZ]{4}$/);
  }
});
test('AUTH-U05: refresh secrets stay random/hash-only and provider ciphertext is subject-bound', () => {
  const a = newRefresh(),
    b = newRefresh();
  assert.notEqual(a, b);
  assert.equal(Buffer.from(a, 'base64url').length, 32);
  assert.equal(hashToken('known'), createHash('sha256').update('known').digest('hex'));
  const box = providerTokenBox(Buffer.alloc(32, 2)),
    encrypted = box.seal(a, 'subject-a');
  assert.equal(encrypted.includes(a), false);
  assert.equal(box.open(encrypted, 'subject-a'), a);
  assert.throws(() => box.open(encrypted, 'subject-b'));
  assert.throws(() => providerTokenBox(Buffer.alloc(32, 3)).open(encrypted, 'subject-a'));
});
test('AUTH-U06: missing/unsafe runtime configuration fails closed without connecting', () => {
  assert.throws(() =>
    accessTokens({ secret: Buffer.alloc(1), issuer: 'x', audience: 'x', ttlSeconds: 900 }),
  );
  assert.throws(() => new GoogleIdTokenVerifier(''));
  assert.throws(() => new AppleIdTokenVerifier([]));
  assert.throws(() => providerTokenBox(Buffer.alloc(8)));
  assert.throws(
    () =>
      new AuthService({
        access: { secret: Buffer.alloc(32), issuer: 'x', audience: 'x', ttlSeconds: 900 },
        cursorSecret: Buffer.alloc(32),
        pinSecret: 'short',
        refreshTtlDays: 30,
        shiftTtlHours: 12,
      } as unknown as AuthOptions),
  );
});
