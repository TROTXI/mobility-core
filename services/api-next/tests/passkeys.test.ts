import { test } from 'node:test';
import assert from 'node:assert/strict';
import { webAuthnRelyingParty } from '../src/auth/passkeys.js';

test('PASSKEY-U01 registration and authentication require discoverable user verification', async () => {
  const relyingParty = webAuthnRelyingParty('https://ops.trotxi.com');
  const registration = await relyingParty.registrationOptions({
    userId: '11111111-1111-4111-8111-111111111111',
    userName: 'operator@trotxi.com',
    displayName: 'Test operator',
    credentials: [],
  });
  assert.equal(registration.rp.id, 'ops.trotxi.com');
  assert.equal(registration.authenticatorSelection?.residentKey, 'required');
  assert.equal(registration.authenticatorSelection?.userVerification, 'required');
  assert.equal(registration.attestation, 'none');

  const authentication = await relyingParty.authenticationOptions([
    { id: 'Y3JlZGVudGlhbC1pZC0x', transports: ['internal'] },
  ]);
  assert.equal(authentication.rpId, 'ops.trotxi.com');
  assert.equal(authentication.userVerification, 'required');
  assert.deepEqual(authentication.allowCredentials?.[0], {
    id: 'Y3JlZGVudGlhbC1pZC0x',
    type: 'public-key',
    transports: ['internal'],
  });
});

test('PASSKEY-U02 relying-party origin is exact, HTTPS and carries no path', () => {
  assert.doesNotThrow(() => webAuthnRelyingParty('https://ops.trotxi.com'));
  assert.doesNotThrow(() => webAuthnRelyingParty('http://localhost:5173'));
  assert.throws(() => webAuthnRelyingParty('http://ops.trotxi.com'));
  assert.throws(() => webAuthnRelyingParty('https://ops.trotxi.com/auth'));
  assert.throws(() => webAuthnRelyingParty('https://ops.trotxi.com?next=evil'));
});
