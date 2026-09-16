import { lstat, readFile } from 'node:fs/promises';
import { isAbsolute } from 'node:path';
import { parseEnv } from 'node:util';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { rehearsalEnvironment } from '../src/runtime/rehearsal.js';

// An explicit exported file, never shell `source`, ambient credentials or a
// database URL. Usage errors must not silently downgrade into another check.
const args = process.argv.slice(2);
if (
  args.length !== 4 ||
  args[0] !== '--env-file' ||
  !isAbsolute(args[1] ?? '') ||
  args[2] !== '--check' ||
  !['preflight', 'paystack', 'r2'].includes(args[3] ?? '')
) {
  process.stderr.write(
    'Usage: provider-rehearsal --env-file /absolute/private.env --check preflight|paystack|r2\n',
  );
  process.exit(2);
}
try {
  const info = await lstat(args[1]!);
  if (!info.isFile() || (info.mode & 0o077) !== 0 || info.size > 1_048_576)
    throw new Error('Use an ordinary private env file (chmod 600), at most 1 MiB');
  if (process.getuid && info.uid !== process.getuid())
    throw new Error('The env file must belong to the current user');
  let source: Record<string, string>;
  try {
    source = parseEnv(await readFile(args[1]!, 'utf8'));
  } catch {
    throw new Error('Unable to parse the private env file');
  }
  const check = args[3]!;
  if (check === 'preflight') {
    rehearsalEnvironment(source, 'paystack');
    rehearsalEnvironment(source, 'r2');
    process.stdout.write(
      'TEST Paystack and R2 settings present. No provider request or database connection made.\n',
    );
  } else {
    const env = rehearsalEnvironment(source, check as 'paystack' | 'r2');
    const script = check === 'paystack' ? 'paystack-test-mode.ts' : 'r2-check.ts';
    const child = spawnSync(process.execPath, ['--import', 'tsx', `scripts/${script}`], {
      cwd: fileURLToPath(new URL('..', import.meta.url)),
      env: { PATH: process.env.PATH, ...env },
      stdio: 'inherit',
      timeout: 90_000,
    });
    if (child.error || child.signal) throw new Error('Provider check failed to finish');
    process.exitCode = child.status === 0 ? 0 : 1;
  }
} catch (error) {
  // Only our bounded errors above; no file content or provider response here.
  const message =
    error instanceof Error && !('code' in error)
      ? error.message
      : 'Unable to read or run private provider configuration';
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
}
