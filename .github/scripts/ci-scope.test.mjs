import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, renameSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { changedPaths, scopeForPaths } from './ci-scope.mjs';

const full = { backend: true, node: true, mobile: true };

test('PR scope includes affected suites and expands to full CI on shared or unknown inputs', () => {
  const backend = 'services/api-next/src/notifications/inbox.ts';
  const mobile = 'apps/trotxi_client/lib/trotxi_client.dart';
  assert.deepEqual(scopeForPaths([backend]), { backend: true, node: true, mobile: false });
  assert.deepEqual(scopeForPaths(['apps/ops/src/App.tsx']), {
    backend: false,
    node: true,
    mobile: false,
  });
  assert.deepEqual(scopeForPaths([mobile]), { backend: false, node: false, mobile: true });
  assert.deepEqual(scopeForPaths([backend, mobile]), full);
  assert.deepEqual(scopeForPaths(['docs/development.md']), {
    backend: false,
    node: false,
    mobile: false,
  });
  for (const path of [
    '.github/workflows/ci.yml',
    'services/api-next/src/http/contract.json',
    'docs/design/contracts/target-contract.mjs',
    'maps/styles.json',
    'pnpm-lock.yaml',
    'tool/mobile_package.py',
    'apps/a-new-app/lib/main.dart',
  ])
    assert.deepEqual(scopeForPaths([path]), full, path);
  assert.deepEqual(scopeForPaths([]), full);
  assert.deepEqual(scopeForPaths(null), full);
});

test('actual PR diff sees a backend move even when its destination is documentation', (t) => {
  const cwd = mkdtempSync(join(tmpdir(), 'trotxi-ci-diff-'));
  t.after(() => rmSync(cwd, { recursive: true, force: true }));
  const git = (...args) =>
    execFileSync(
      'git',
      [
        '-c',
        'user.name=CI Fixture',
        '-c',
        'user.email=ci@example.invalid',
        '-c',
        'commit.gpgsign=false',
        '-c',
        'core.hooksPath=/dev/null',
        ...args,
      ],
      {
        cwd,
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'pipe'],
      },
    ).trim();
  const original = 'services/api-next/src/inbox.ts';
  const moved = 'docs/inbox draft\npart.md';
  git('init', '-q');
  mkdirSync(join(cwd, 'services/api-next/src'), { recursive: true });
  mkdirSync(join(cwd, 'docs'));
  writeFileSync(join(cwd, original), 'export const inbox = true;\n');
  git('add', '.');
  git('commit', '-qm', 'Base');
  const base = git('rev-parse', 'HEAD');
  renameSync(join(cwd, original), join(cwd, moved));
  git('add', '-A');
  git('commit', '-qm', 'Move backend file');
  const diff = changedPaths(base, cwd);
  assert.deepEqual([...diff].sort(), [moved, original].sort());
  assert.deepEqual(scopeForPaths(diff), { backend: true, node: true, mobile: false });
  assert.equal(
    changedPaths(git('rev-parse', 'HEAD'), cwd),
    null,
    'A stale event must use full CI.',
  );

  const script = fileURLToPath(new URL('./ci-scope.mjs', import.meta.url));
  const scope = execFileSync(process.execPath, [script, base], {
    cwd,
    env: { ...process.env, GITHUB_EVENT_NAME: 'merge_group' },
    encoding: 'utf8',
  });
  assert.equal(scope.trim(), 'backend=true\nnode=true\nmobile=true');
});
