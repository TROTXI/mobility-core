import { execFileSync, spawn } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFile, mkdir, access } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

export const PIN = '43cdae0b437e70ca146704eb4201a2325c9d9327';
export const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
export const ARTIFACTS = resolve(ROOT, '.harness-artifacts');
export const BASELINE = resolve(ARTIFACTS, 'baseline');
export const hash = (bytes) => createHash('sha256').update(bytes).digest('hex');
export const git = (...args) =>
  execFileSync('git', args, { cwd: ROOT, maxBuffer: 100 * 1024 * 1024 });

// No inherited DATABASE_URL, provider keys, .env or production integration config.
export function childEnv(extra = {}) {
  return { PATH: process.env.PATH, HOME: process.env.HOME, CI: 'true', TZ: 'UTC', ...extra };
}

export async function command(file, args, options = {}) {
  return new Promise((resolvePromise, reject) => {
    const child = spawn(file, args, { stdio: 'inherit', env: childEnv(), ...options });
    child.once('error', reject);
    child.once('exit', (code, signal) =>
      code === 0 ? resolvePromise() : reject(new Error(`${file} failed (${code ?? signal})`)),
    );
  });
}

export async function verifyBaseline() {
  try {
    await access(resolve(BASELINE, 'services/api/.env'));
    throw new Error('A local .env is forbidden in the frozen harness checkout');
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
  // Verify every tracked regular file, not just a revision marker or the lockfile.
  const entries = git('ls-tree', '-rz', PIN).toString().split('\0').filter(Boolean);
  for (const entry of entries) {
    const [header, path] = entry.split('\t');
    const [mode, kind, expected] = header.split(' ');
    if (kind !== 'blob' || mode === '120000') throw new Error(`Unsupported baseline entry ${path}`);
    const bytes = await readFile(resolve(BASELINE, path));
    const actual = createHash('sha1').update(`blob ${bytes.length}\0`).update(bytes).digest('hex');
    if (actual !== expected) throw new Error(`Frozen baseline changed: ${path}`);
  }
  return {
    commit: PIN,
    filesVerified: entries.length,
    lockSha256: hash(await readFile(resolve(BASELINE, 'pnpm-lock.yaml'))),
  };
}

export async function prepareBaseline() {
  await mkdir(ARTIFACTS, { recursive: true });
  try {
    await readFile(resolve(BASELINE, 'pnpm-lock.yaml'));
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
    await mkdir(BASELINE, { recursive: true });
    execFileSync('tar', ['-xf', '-', '-C', BASELINE], {
      input: git('archive', PIN),
      maxBuffer: 100 * 1024 * 1024,
    });
  }
  return verifyBaseline();
}

export function adminUrl(value) {
  if (!value) throw new Error('HARNESS_ADMIN_DATABASE_URL is required; database tests never skip');
  const url = new URL(value);
  if (
    !['postgres:', 'postgresql:'].includes(url.protocol) ||
    !['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname) ||
    url.pathname !== '/postgres'
  )
    throw new Error(
      'Harness requires a loopback disposable Postgres admin database named postgres',
    );
  if (url.search || url.hash) throw new Error('Database URL options are not accepted');
  if (process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
    throw new Error('Set HARNESS_ALLOW_CREATE_DATABASES=1 only for disposable local/CI Postgres');
  return url;
}

export function dbIdentifier(name) {
  if (!/^trotxi_harness_[a-f0-9]{12}_[a-z0-9_]+$/.test(name))
    throw new Error('Unsafe harness database name');
  return `"${name}"`;
}
