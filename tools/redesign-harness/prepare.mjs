import { prepareBaseline, command, BASELINE, childEnv } from './support.mjs';
console.log(await prepareBaseline());
// Use the package manager/version and dependency lock from the pinned checkout.
await command('pnpm', ['install', '--frozen-lockfile', '--ignore-scripts'], {
  cwd: BASELINE,
  env: childEnv(),
});
