import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { migration, runtimeRoleIdentifier, validateMigrations } from '../src/db/migrate.js';

test('migration inventory is non-empty, contiguous and hash checked', () => {
  const one = migration('001_first.sql', 'SELECT 1;');
  validateMigrations([one, migration('002_second.sql', 'SELECT 2;')]);
  for (const files of [
    [],
    [migration('002_first.sql', 'SELECT 1')],
    [one, one],
    [migration('../001_first.sql', 'SELECT 1')],
    [{ ...one, sql: 'SELECT 2' }],
  ])
    assert.throws(() => validateMigrations(files));
});

test('runtime role identifier cannot quote SQL or reuse generic owner roles', () => {
  assert.equal(runtimeRoleIdentifier('trotxi_runtime_api'), '"trotxi_runtime_api"');
  for (const name of ['postgres', 'trotxi', 'trotxi_runtime_x;DROP ROLE owner', 'trotxi_runtime_'])
    assert.throws(() => runtimeRoleIdentifier(name));
});

test('installer refuses to fall back to the old DATABASE_URL', () => {
  const result = spawnSync(process.execPath, ['--import', 'tsx', 'src/db/cli.ts'], {
    cwd: new URL('..', import.meta.url),
    env: { PATH: process.env.PATH, DATABASE_URL: 'postgres://do-not-connect.invalid/old' },
    encoding: 'utf8',
  });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /REPLACEMENT_DATABASE_URL is required/);
});
