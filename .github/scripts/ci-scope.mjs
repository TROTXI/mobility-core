import { execFileSync } from 'node:child_process';

const full = { backend: true, node: true, mobile: true };

export function scopeForPaths(paths) {
  // An empty, unavailable, or ambiguous diff runs everything.
  if (!paths?.length) return full;
  const selected = { backend: false, node: false, mobile: false };
  for (const path of paths) {
    if (path === 'services/api-next/src/http/contract.json') return full;
    if (path.startsWith('services/api-next/')) {
      selected.backend = true;
      selected.node = true;
    } else if (path.startsWith('apps/ops/')) {
      selected.node = true;
    } else if (
      /^apps\/(api_client|trotxi_client|trotxi_commuter|trotxi_diagnostics|trotxi_driver|trotxi_map)\//.test(
        path,
      )
    ) {
      selected.mobile = true;
    } else if (
      path === 'README.md' ||
      path === 'CONTRIBUTING.md' ||
      (path.startsWith('docs/') && !path.startsWith('docs/design/') && path.endsWith('.md'))
    ) {
      // Format, contract, lockfile, release guard, and security checks still run.
    } else {
      // Shared tooling, schemas, maps, dependencies, CI and future paths.
      return full;
    }
  }
  return selected;
}

export function changedPaths(base, cwd = process.cwd()) {
  if (!/^[a-f0-9]{40}$/.test(base ?? '')) return null;
  const git = (args) =>
    execFileSync('git', args, { cwd, encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 });
  try {
    // Compare the tested snapshot with its PR base. GitHub may have refreshed
    // the test merge since the event was sent. In that case use full CI.
    if (git(['rev-parse', 'HEAD^1']).trim() !== base) return null;
    // Report both sides of a rename, including removed paths.
    const diff = git([
      'diff',
      '--no-ext-diff',
      '--no-renames',
      '--name-only',
      '-z',
      base,
      'HEAD',
      '--',
    ]);
    return diff ? diff.slice(0, -1).split('\0') : [];
  } catch {
    return null;
  }
}

if (import.meta.main) {
  const scope =
    process.env.GITHUB_EVENT_NAME === 'pull_request'
      ? scopeForPaths(changedPaths(process.argv[2]))
      : full;
  for (const [area, selected] of Object.entries(scope)) console.log(`${area}=${selected}`);
}
