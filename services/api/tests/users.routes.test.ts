import sharp from 'sharp';
import { describe, expect, it } from 'vitest';
import { buildApp } from '../src/app';
import { InMemoryUserRepository } from '../src/modules/users/user.repository';
import { FakeObjectStore, avatarKey } from '../src/storage/object-store';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const auth: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const jwt = createJwtService(auth);
const bearer = (t: string) => ({ authorization: `Bearer ${t}` });

async function setup() {
  const users = new InMemoryUserRepository();
  const objectStore = new FakeObjectStore();
  const user = await users.create({ displayName: 'Ama', role: 'commuter' });
  const app = await buildApp({ auth, users, objectStore });
  const token = await jwt.signAccessToken({ userId: user.id, role: 'commuter' });
  return { users, objectStore, user, app, token };
}

/** Build a multipart/form-data body with a single file part (no extra deps). */
function multipart(bytes: Buffer, filename: string, contentType: string) {
  const boundary = '----trotxitestboundary';
  const head = Buffer.from(
    `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${filename}"\r\n` +
      `Content-Type: ${contentType}\r\n\r\n`,
  );
  const tail = Buffer.from(`\r\n--${boundary}--\r\n`);
  return {
    contentType: `multipart/form-data; boundary=${boundary}`,
    payload: Buffer.concat([head, bytes, tail]),
  };
}

/** POST an avatar upload, merging the bearer header with the multipart type. */
function uploadAvatar(
  app: Awaited<ReturnType<typeof buildApp>>,
  token: string | null,
  bytes: Buffer,
  filename: string,
  contentType: string,
) {
  const mp = multipart(bytes, filename, contentType);
  const headers: Record<string, string> = { 'content-type': mp.contentType };
  if (token) headers.authorization = `Bearer ${token}`;
  return app.inject({ method: 'POST', url: '/me/avatar', headers, payload: mp.payload });
}

const samplePng = () =>
  sharp({ create: { width: 400, height: 400, channels: 3, background: { r: 10, g: 150, b: 90 } } })
    .png()
    .toBuffer();

describe('PATCH /me', () => {
  it('requires authentication', async () => {
    const { app } = await setup();
    const res = await app.inject({ method: 'PATCH', url: '/me', payload: { displayName: 'X' } });
    expect(res.statusCode).toBe(401);
  });

  it('updates the display name', async () => {
    const { app, token, users, user } = await setup();
    const res = await app.inject({
      method: 'PATCH',
      url: '/me',
      headers: bearer(token),
      payload: { displayName: 'Ama Mensah' },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().displayName).toBe('Ama Mensah');
    expect((await users.findById(user.id))?.displayName).toBe('Ama Mensah');
  });

  it('rejects an empty display name (400)', async () => {
    const { app, token } = await setup();
    const res = await app.inject({
      method: 'PATCH',
      url: '/me',
      headers: bearer(token),
      payload: { displayName: '   ' },
    });
    expect(res.statusCode).toBe(400);
  });
});

describe('POST /me/avatar', () => {
  it('requires authentication', async () => {
    const { app } = await setup();
    const res = await uploadAvatar(app, null, await samplePng(), 'a.png', 'image/png');
    expect(res.statusCode).toBe(401);
  });

  it('resizes + re-encodes to a 256px JPEG and stores it', async () => {
    const { app, token, objectStore, user } = await setup();
    const res = await uploadAvatar(app, token, await samplePng(), 'a.png', 'image/png');
    expect(res.statusCode).toBe(200);
    expect(res.json().avatarUrl).toContain(avatarKey(user.id));

    const stored = objectStore.peek(avatarKey(user.id));
    expect(stored?.contentType).toBe('image/jpeg');
    // re-encoded to JPEG (magic bytes FF D8) — EXIF stripped
    expect(stored!.bytes.subarray(0, 2)).toEqual(Buffer.from([0xff, 0xd8]));
    const meta = await sharp(stored!.bytes).metadata();
    expect(meta.format).toBe('jpeg');
    expect(meta.width).toBe(256);
    expect(meta.height).toBe(256);
  });

  it('rejects an unsupported content type (400)', async () => {
    const { app, token } = await setup();
    const res = await uploadAvatar(app, token, Buffer.from('%PDF-1.4'), 'a.pdf', 'application/pdf');
    expect(res.statusCode).toBe(400);
  });

  it('rejects bytes that are not a decodable image (400)', async () => {
    const { app, token } = await setup();
    const res = await uploadAvatar(
      app,
      token,
      Buffer.from('not really a png'),
      'a.png',
      'image/png',
    );
    expect(res.statusCode).toBe(400);
  });
});

describe('GET /me/avatar', () => {
  it('404s when no avatar is set', async () => {
    const { app, token } = await setup();
    const res = await app.inject({ method: 'GET', url: '/me/avatar', headers: bearer(token) });
    expect(res.statusCode).toBe(404);
  });

  it('returns a signed URL after an upload', async () => {
    const { app, token } = await setup();
    await uploadAvatar(app, token, await samplePng(), 'a.png', 'image/png');
    const res = await app.inject({ method: 'GET', url: '/me/avatar', headers: bearer(token) });
    expect(res.statusCode).toBe(200);
    expect(res.json().avatarUrl).toContain('https://');
  });
});

describe('GET /me avatar signing', () => {
  it('returns a signed URL (not the raw key) after an upload', async () => {
    const { app, token, user } = await setup();
    await uploadAvatar(app, token, await samplePng(), 'a.png', 'image/png');
    const me = await app.inject({ method: 'GET', url: '/me', headers: bearer(token) });
    expect(me.statusCode).toBe(200);
    const url = me.json().avatarUrl as string;
    expect(url).toContain('https://');
    expect(url).toContain(avatarKey(user.id));
  });
});
