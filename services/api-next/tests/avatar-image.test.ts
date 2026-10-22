import assert from 'node:assert/strict';
import test from 'node:test';
import sharp from 'sharp';
import {
  sanitizeAvatar,
  reserveAvatarSanitization,
  MAX_AVATAR_PIXELS,
  MAX_AVATAR_EDGE,
} from '../src/account/avatar-image.js';
import { TransportError } from '../src/transport/errors.js';
import { avatarPng } from './helpers/avatar-fixture.js';

const maxBytes = 2 * 1024 * 1024;
const refused = (error: unknown) => error instanceof TransportError && error.status === 415;

test('avatar reservations release unused capacity once and retain running capacity', async () => {
  const first = reserveAvatarSanitization();
  const second = reserveAvatarSanitization();
  const busy = (e: unknown) => e instanceof TransportError && e.code === 'avatar_processing_busy';
  try {
    assert.throws(reserveAvatarSanitization, busy);
    first.release();
    first.release();
    await assert.rejects(first.run(avatarPng, 'image/png', maxBytes), /already_used/);
    const third = reserveAvatarSanitization();
    try {
      assert.throws(reserveAvatarSanitization, busy);
      const running = third.run(avatarPng, 'image/png', maxBytes);
      third.release();
      assert.throws(reserveAvatarSanitization, busy, 'cannot release an active decoder early');
      await assert.rejects(third.run(avatarPng, 'image/png', maxBytes), /already_used/);
      await running;
      await assert.rejects(third.run(avatarPng, 'image/png', maxBytes), /already_used/);
      await sanitizeAvatar(avatarPng, 'image/png', maxBytes);
    } finally {
      third.release();
    }
  } finally {
    first.release();
    second.release();
  }
});

for (const format of ['jpeg', 'png', 'webp'] as const) {
  test(`avatar ${format}: strips private EXIF/XMP and trailing bytes`, async () => {
    const image = await sharp(avatarPng)
      .withExif({ IFD0: { Artist: 'Private camera owner' } })
      .withXmp('<x:xmpmeta xmlns:x="adobe:ns:meta/">private-location</x:xmpmeta>')
      .toFormat(format)
      .toBuffer();
    assert.ok((await sharp(image).metadata()).exif);
    const dirty = Buffer.concat([image, Buffer.from('private-trailing-payload')]);
    const clean = await sanitizeAvatar(dirty, `image/${format}`, maxBytes);
    const metadata = await sharp(clean).metadata();
    assert.equal(metadata.format, format);
    for (const field of ['exif', 'xmp', 'iptc', 'icc'] as const)
      assert.equal(metadata[field], undefined, field);
    assert.equal(clean.includes(Buffer.from('private-trailing-payload')), false);
    await sharp(clean).raw().toBuffer();
  });
}

test('avatar rotates using EXIF before stripping it and caps output size', async () => {
  const source = await sharp({
    create: {
      width: 2000,
      height: 1000,
      channels: 3,
      background: '#058740',
    },
  })
    .withMetadata({ orientation: 6 })
    .jpeg()
    .toBuffer();
  const clean = await sanitizeAvatar(source, 'image/jpeg', maxBytes);
  const metadata = await sharp(clean).metadata();
  assert.equal(metadata.width, 512);
  assert.equal(metadata.height, 1024);
  assert.equal(metadata.orientation, undefined);
  assert.equal(metadata.exif, undefined);
});

test('avatar rejects header-only files, truncated pixels and mismatched MIME types', async () => {
  for (const [type, hex] of [
    ['image/jpeg', 'ffd8ffe000104a464946'],
    ['image/png', '89504e470d0a1a0a00112233'],
    ['image/webp', '52494646000000005745425000'],
  ])
    await assert.rejects(sanitizeAvatar(Buffer.from(hex!, 'hex'), type!, maxBytes), refused);
  await assert.rejects(sanitizeAvatar(avatarPng.subarray(0, 48), 'image/png', maxBytes), refused);
  await assert.rejects(sanitizeAvatar(avatarPng, 'image/jpeg', maxBytes), refused);
});

test('avatar refuses excessive decoded pixels, dimensions and animation', async () => {
  const wide = await sharp({
    create: {
      width: MAX_AVATAR_EDGE + 1,
      height: 1,
      channels: 3,
      background: 'white',
    },
  })
    .png()
    .toBuffer();
  await assert.rejects(sanitizeAvatar(wide, 'image/png', maxBytes), refused);
  const large = await sharp({
    create: {
      width: 4000,
      height: Math.floor(MAX_AVATAR_PIXELS / 4000) + 1,
      channels: 3,
      background: 'white',
    },
  })
    .png()
    .toBuffer();
  await assert.rejects(sanitizeAvatar(large, 'image/png', maxBytes), refused);
  const frames = Buffer.concat([Buffer.alloc(12, 0), Buffer.alloc(12, 255)]);
  const animated = await sharp(frames, {
    raw: {
      width: 2,
      height: 4,
      pageHeight: 2,
      channels: 3,
    },
  })
    .webp({ loop: 0, delay: [100, 100] })
    .toBuffer();
  assert.equal((await sharp(animated).metadata()).pages, 2);
  await assert.rejects(sanitizeAvatar(animated, 'image/webp', maxBytes), refused);
});

test('avatar bounds concurrent decoding and releases capacity after failure', async () => {
  const first = sanitizeAvatar(avatarPng, 'image/png', maxBytes);
  const second = sanitizeAvatar(avatarPng, 'image/png', maxBytes);
  const third = sanitizeAvatar(avatarPng, 'image/png', maxBytes);
  await assert.rejects(third, (e: unknown) => e instanceof TransportError && e.status === 503);
  await Promise.all([first, second]);
  await assert.rejects(
    sanitizeAvatar(avatarPng, 'image/png', 1),
    (e: unknown) => e instanceof TransportError && e.status === 413,
  );
  await sanitizeAvatar(avatarPng, 'image/png', maxBytes);
});
