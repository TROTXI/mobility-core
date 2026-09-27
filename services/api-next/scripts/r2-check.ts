/**
 * Exercise the avatar store against a real Cloudflare R2 bucket, once.
 *
 * The SigV4 implementation is checked against @smithy/signature-v4 on pinned
 * vectors, which proves the arithmetic. It does not prove Cloudflare accepts
 * it. This does: it stores a small image, fetches it back through a presigned
 * URL with no credentials attached, and removes it again.
 *
 *   R2_ACCOUNT_ID=... R2_ACCESS_KEY_ID=... R2_SECRET_ACCESS_KEY=... R2_BUCKET=... \
 *     node --import tsx scripts/r2-check.ts
 *
 * It writes one object under a random key and deletes it, so it cannot disturb
 * anything already in the bucket. Credentials are read from the environment and
 * are never printed.
 */
import { randomUUID } from 'node:crypto';
import { R2ObjectStore } from '../src/runtime/avatars.js';

const required = (name: string) => {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is required`);
  return value;
};
const store = new R2ObjectStore({
  accountId: required('R2_ACCOUNT_ID'),
  accessKeyId: required('R2_ACCESS_KEY_ID'),
  secretAccessKey: required('R2_SECRET_ACCESS_KEY'),
  bucket: required('R2_BUCKET'),
});

// A real, minimal PNG: the store checks the bytes against the declared type.
const bytes = Buffer.from(
  '89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000a49444154789c6360000002000100' +
    '05fe02fea7b1e3fb0000000049454e44ae426082',
  'hex',
);
const results: { step: string; ok: boolean; detail: string }[] = [];
const record = (step: string, ok: boolean, detail: string) => {
  results.push({ step, ok, detail });
  process.stdout.write(`${ok ? 'ok  ' : 'FAIL'} ${step.padEnd(28)} ${detail}\n`);
};

let objectKey = '';
try {
  const stored = await store.put({ userId: randomUUID(), bytes, contentType: 'image/png' });
  objectKey = stored.objectKey;
  record('put', true, objectKey);
} catch {
  record('put', false, 'object upload failed; raw provider data withheld');
}

if (objectKey) {
  // No credentials on this request: the signature in the query string is the
  // only thing authorising it, which is what a rider's device actually sends.
  const url = store.sign(objectKey, 120)!;
  try {
    const response = await fetch(url, { redirect: 'error', signal: AbortSignal.timeout(10_000) });
    const body = Buffer.from(await response.arrayBuffer());
    record(
      'presigned read',
      response.ok && body.equals(bytes),
      response.ok ? `${body.length} bytes, identical` : `HTTP ${response.status}`,
    );
  } catch {
    record('presigned read', false, 'read failed; signed URL withheld');
  }

  // An expired signature must stop working, or the TTL means nothing.
  try {
    const stale = store.sign(objectKey, 1)!;
    await new Promise((resolve) => setTimeout(resolve, 2500));
    const response = await fetch(stale, { redirect: 'error', signal: AbortSignal.timeout(10_000) });
    record('expired signature refused', response.status === 403, `HTTP ${response.status}`);
  } catch {
    record('expired signature refused', false, 'expiry check failed; signed URL withheld');
  }

  try {
    await store.remove(objectKey);
    const gone = await fetch(store.sign(objectKey, 120)!, {
      redirect: 'error',
      signal: AbortSignal.timeout(10_000),
    });
    record('remove', gone.status === 404, `HTTP ${gone.status} after delete`);
  } catch {
    record('remove', false, 'cleanup failed; signed URL withheld');
  }
}

const failed = results.filter((r) => !r.ok);
process.stdout.write(
  `\n${results.length - failed.length}/${results.length} passed.${objectKey && failed.length ? ` Object ${objectKey} may still exist; inspect cleanup.` : failed.length ? ' Upload outcome is uncertain; no cleanup claim is made.' : ' Probe object removed.'}\n`,
);
process.exitCode = failed.length ? 1 : 0;
