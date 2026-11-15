import { globSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const api = fileURLToPath(new URL('../../services/api-next/', import.meta.url));
const suites = new Set(globSync('tests/*.pg.test.ts', { cwd: api }));
const shards = JSON.parse(readFileSync(new URL('../ci/postgres-shards.json', import.meta.url)));
const assigned = new Set();
const labels = new Set();
const slugs = new Set();

if (!suites.size || !Array.isArray(shards) || !shards.length)
  throw new Error('Expected PostgreSQL tests and at least one shard.');

for (const { part, slug, files } of shards) {
  if (
    typeof part !== 'string' ||
    !part.trim() ||
    labels.has(part) ||
    typeof slug !== 'string' ||
    !/^(part-\d+|financial)$/.test(slug) ||
    slugs.has(slug) ||
    !Array.isArray(files) ||
    !files.length
  )
    throw new Error(`Invalid or duplicate PostgreSQL shard: ${JSON.stringify({ part, slug })}`);
  labels.add(part);
  slugs.add(slug);
  for (const file of files) {
    if (!suites.has(file) || !/^tests\/[\w-]+\.pg\.test\.ts$/.test(file))
      throw new Error(`Unknown PostgreSQL suite: ${file}`);
    if (assigned.has(file)) throw new Error(`PostgreSQL suite assigned more than once: ${file}`);
    assigned.add(file);
  }
}

const missing = [...suites].filter((file) => !assigned.has(file)).sort();
if (missing.length) throw new Error(`Unassigned PostgreSQL suites: ${missing.join(', ')}`);

console.log(
  JSON.stringify({
    include: shards.map(({ part, slug, files }) => ({ part, slug, files: files.join(' ') })),
  }),
);
