// Local, dependency-free app construction: no server, external database or secrets.
// Run with Node 24 and the API's tsx loader; output is a generated review artifact.
import { mkdir } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { buildApp } from '../../../services/api/src/app.ts';
import { writeArtifact } from './artifact-io.mjs';

const root = fileURLToPath(new URL('../../../', import.meta.url));
// Never label changed runtime code as the frozen baseline.
execFileSync(
  'git',
  ['diff', '--exit-code', '43cdae0b437e70ca146704eb4201a2325c9d9327', '--', 'services/api/src'],
  { cwd: root, stdio: 'pipe' },
);
const app = await buildApp({ logger: false });
try {
  await app.ready();
  const spec = app.swagger();
  const dir = new URL('../contracts/', import.meta.url);
  await mkdir(dir, { recursive: true });
  const index = {
    baselineCommit: '43cdae0b437e70ca146704eb4201a2325c9d9327',
    fullSpecSha256: createHash('sha256').update(JSON.stringify(spec)).digest('hex'),
    paths: {},
  };
  const methods = new Set(['get', 'post', 'put', 'patch', 'delete', 'head', 'options']);
  const operations = Object.entries(spec.paths)
    .flatMap(([path, item]) =>
      Object.entries(item)
        .filter(([method]) => methods.has(method))
        .map(([method, op]) => ({
          method: method.toUpperCase(),
          path,
          tags: op.tags ?? [],
          security: op.security ?? [],
          request: op.requestBody ?? null,
          parameters: op.parameters ?? [],
          responses: Object.keys(op.responses),
        })),
    )
    .sort((a, b) => a.path.localeCompare(b.path) || a.method.localeCompare(b.method));
  for (const op of operations)
    (index.paths[op.path] ??= {})[op.method.toLowerCase()] = {
      tags: op.tags,
      security: op.security,
      responses: Object.fromEntries(op.responses.map((code) => [code, {}])),
    };
  await writeArtifact(new URL('baseline.operations.json', dir), index);
  console.log(`Exported ${operations.length} operations to ${fileURLToPath(dir)}`);
} finally {
  await app.close();
}
