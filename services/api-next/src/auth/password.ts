import { argon2, randomBytes, timingSafeEqual } from 'node:crypto';
import { fail } from '../transport/errors.js';

// Bound memory and worker-pool pressure. Never queue unbounded expensive hashes.
let active = 0;
export function validatePassword(value: unknown): asserts value is string {
  if (typeof value !== 'string' || [...value].length < 15 || value.length > 128)
    fail(400, 'invalid_password', 'Use a password of 15 to 128 characters.');
  if (
    /^(.{1,8})\1+$/u.test(value) ||
    [
      'password',
      'passwordpassword',
      'qwerty',
      'qwertyuiop',
      'qwertyuiopasdfgh',
      'letmein',
      'welcome',
      'trotxi',
      'iloveyou',
    ].includes(value.toLowerCase().replace(/[^\p{L}]/gu, '')) ||
    value === '123456789012345'
  )
    fail(400, 'invalid_password', 'Choose a less common password.');
}
async function derive(password: string, salt: Buffer): Promise<Buffer> {
  if (active >= 2) fail(503, 'auth_busy', 'Sign-in is busy. Please try again shortly.');
  active++;
  try {
    return await new Promise<Buffer>((resolve, reject) =>
      argon2(
        'argon2id',
        {
          message: password,
          nonce: salt,
          parallelism: 1,
          memory: 19456,
          passes: 2,
          tagLength: 32,
        },
        (error, key) => (error ? reject(error) : resolve(key)),
      ),
    );
  } finally {
    active--;
  }
}
export async function hashPassword(password: string) {
  validatePassword(password);
  const salt = randomBytes(16);
  return `argon2id-v1$${salt.toString('base64url')}$${(await derive(password, salt)).toString('base64url')}`;
}
export async function checkPassword(password: string, stored: string | null) {
  const parts = stored?.split('$');
  const valid = parts?.length === 3 && parts[0] === 'argon2id-v1';
  const salt = valid ? Buffer.from(parts[1]!, 'base64url') : Buffer.alloc(16, 17);
  const expected = valid ? Buffer.from(parts[2]!, 'base64url') : Buffer.alloc(32);
  const actual = await derive(password.length <= 128 ? password : '', salt);
  return expected.length === actual.length && timingSafeEqual(expected, actual) && !!valid;
}
