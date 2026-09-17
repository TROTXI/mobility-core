import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFile, readdir } from 'node:fs/promises';
import { resolve } from 'node:path';
import { ROOT } from './support.mjs';

const paths = [
  'services/api-next',
  'tools/redesign-harness',
  'pnpm-lock.yaml',
  'pnpm-workspace.yaml',
  'package.json',
];
/** Bind actual input bytes to a commit, independently before and after execution. */
export async function verifyCandidate(revision, root = ROOT) {
  const git = (...args) => execFileSync('git', args, { cwd: root, maxBuffer: 100 * 1024 * 1024 });
  const entries = git('ls-tree', '-rz', revision, '--', ...paths)
    .toString()
    .split('\0')
    .filter(Boolean);
  if (!entries.length) throw new Error('Candidate source inventory is empty');
  const expectedPaths = new Set(),
    digest = createHash('sha256');
  for (const entry of entries) {
    const [header, path] = entry.split('\t'),
      [mode, kind, expected] = header.split(' ');
    if (kind !== 'blob' || mode === '120000')
      throw new Error(`Unsupported candidate entry ${path}`);
    const bytes = await readFile(resolve(root, path));
    const actual = createHash('sha1').update(`blob ${bytes.length}\0`).update(bytes).digest('hex');
    if (actual !== expected)
      throw new Error(`Candidate source differs from declared revision: ${path}`);
    expectedPaths.add(path);
    digest.update(path).update('\0').update(bytes).update('\0');
  }
  // An untracked runtime module or migration must not slip outside the manifest.
  async function check(dir) {
    for (const entry of await readdir(resolve(root, dir), { withFileTypes: true })) {
      if (entry.name === 'node_modules') continue;
      const path = `${dir}/${entry.name}`;
      if (entry.isDirectory()) await check(path);
      else if (!expectedPaths.has(path)) throw new Error(`Untracked candidate source: ${path}`);
    }
  }
  for (const dir of [
    'services/api-next/src',
    'services/api-next/migrations',
    'tools/redesign-harness',
  ])
    await check(dir);
  return { commit: revision, filesVerified: entries.length, sourceSha256: digest.digest('hex') };
}
