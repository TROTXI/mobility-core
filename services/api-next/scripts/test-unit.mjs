import { spawnSync } from 'node:child_process';
import { globSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const cwd = fileURLToPath(new URL('../', import.meta.url));
const files = globSync('tests/*.test.ts', { cwd, exclude: ['tests/*.pg.test.ts'] }).sort();
if (!files.length) throw new Error('No API unit test files found.');

const result = spawnSync(
  process.execPath,
  ['--import', 'tsx', '--test', ...process.argv.slice(2), ...files],
  { cwd, stdio: 'inherit' },
);
if (result.error) throw result.error;
process.exitCode = result.status ?? 1;
