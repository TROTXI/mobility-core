import { constants } from 'node:fs';
import { open } from 'node:fs/promises';
import { isAbsolute } from 'node:path';
import { parseEnv } from 'node:util';

/** Validate and read the same open file, never check a path then reopen it. */
export async function readPrivateEnvironment(
  path: string,
): Promise<Record<string, string | undefined>> {
  if (!isAbsolute(path)) throw new Error('The private env path must be absolute');
  const file = await open(path, constants.O_RDONLY | constants.O_NOFOLLOW | constants.O_NONBLOCK);
  try {
    const info = await file.stat();
    const maximum = 1_048_576;
    if (!info.isFile() || (info.mode & 0o077) !== 0 || info.size > maximum)
      throw new Error('Use an ordinary private env file (chmod 600), at most 1 MiB');
    if (!process.getuid || info.uid !== process.getuid())
      throw new Error('The env file must belong to the current user');
    // Bound the actual read as well: a file may grow after fstat. NOFOLLOW
    // rejects final-component symlinks; descriptor reads survive path swaps.
    const buffer = Buffer.alloc(maximum + 1);
    let size = 0;
    while (size < buffer.length) {
      const { bytesRead } = await file.read(buffer, size, buffer.length - size, size);
      if (!bytesRead) break;
      size += bytesRead;
    }
    if (size > maximum) throw new Error('The private env file exceeds 1 MiB');
    const after = await file.stat();
    if (after.size !== size || after.mtimeMs !== info.mtimeMs || after.ctimeMs !== info.ctimeMs)
      throw new Error('The private env file changed while reading');
    try {
      return parseEnv(buffer.subarray(0, size).toString('utf8'));
    } catch {
      throw new Error('Unable to parse the private env file');
    }
  } finally {
    await file.close();
  }
}

/** Never use the downloaded staging connection for local database creation. */
export function localRehearsalAdmin(raw: string | undefined): URL {
  if (!raw) throw new Error('HARNESS_ADMIN_DATABASE_URL is required for local rehearsal');
  let url: URL;
  try {
    url = new URL(raw);
  } catch {
    // URL errors include their input; never leak a malformed connection secret.
    throw new Error('Invalid local rehearsal admin database URL');
  }
  if (
    !['postgres:', 'postgresql:'].includes(url.protocol) ||
    !['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname) ||
    url.pathname !== '/postgres' ||
    url.search ||
    url.hash
  )
    throw new Error('Local rehearsal accepts only a loopback postgres admin database');
  return url;
}

/** Only provider-specific values cross into a rehearsal subprocess. */
export function rehearsalEnvironment(
  source: Record<string, string | undefined>,
  check: 'paystack' | 'r2',
): Record<string, string> {
  const pick = (replacement: string, staging: string): string => {
    const a = source[replacement];
    const b = source[staging];
    if (a && b && a !== b) throw new Error(`Conflicting settings for ${replacement}`);
    const value = a ?? b;
    if (!value || value.includes('\n') || value.includes('\r'))
      throw new Error(`Missing or invalid ${replacement}`);
    return value;
  };
  // This is unconditional, even for an export containing a production opt-in.
  const paystack = pick('REPLACEMENT_PAYSTACK_SECRET_KEY', 'PAYSTACK_SECRET_KEY');
  if (!/^sk_test_[A-Za-z0-9]+$/.test(paystack))
    throw new Error('Provider rehearsal requires a Paystack TEST secret key');
  if (check === 'paystack') return { REPLACEMENT_PAYSTACK_SECRET_KEY: paystack };
  return Object.fromEntries(
    [
      ['R2_ACCOUNT_ID', 'REPLACEMENT_R2_ACCOUNT_ID'],
      ['R2_ACCESS_KEY_ID', 'REPLACEMENT_R2_ACCESS_KEY_ID'],
      ['R2_SECRET_ACCESS_KEY', 'REPLACEMENT_R2_SECRET_ACCESS_KEY'],
      ['R2_BUCKET', 'REPLACEMENT_R2_BUCKET_NAME'],
    ].map(([staging, replacement]) => [staging!, pick(replacement!, staging!)]),
  );
}
