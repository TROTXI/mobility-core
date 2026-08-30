// CI gate for the generated styles.
//
// Two failure modes, both silent in the browser: a style that violates the spec
// renders a blank canvas rather than throwing, and a committed style that no
// longer matches the generator means someone hand-edited dist/ and the next
// build will quietly revert them.

import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, readdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));

const scratch = mkdtempSync(join(tmpdir(), 'trotxi-styles-'));
execFileSync('node', [join(HERE, 'build-styles.mjs')], {
  env: { ...process.env, OUT_DIR: scratch },
  stdio: 'inherit',
});

let failed = false;
for (const file of readdirSync(scratch)) {
  const fresh = readFileSync(join(scratch, file), 'utf8');
  let committed;
  try {
    committed = readFileSync(join(HERE, 'dist', file), 'utf8');
  } catch {
    console.error(`✗ ${file} is missing from maps/dist — run \`pnpm --filter @trotxi/maps build\``);
    failed = true;
    continue;
  }
  if (fresh !== committed) {
    console.error(`✗ ${file} in maps/dist does not match the generator.`);
    console.error('  Edit build-styles.mjs, not dist/, then rebuild.');
    failed = true;
  } else {
    console.log(`✓ ${file} matches the generator`);
  }
}

execFileSync('node', [join(HERE, 'validate-styles.mjs')], { stdio: 'inherit' });
process.exit(failed ? 1 : 0);
