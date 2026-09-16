import { randomBytes } from 'node:crypto';
import { readFile, readdir, mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import {
  PIN,
  ROOT,
  BASELINE,
  ARTIFACTS,
  git,
  hash,
  command,
  childEnv,
  verifyBaseline,
  adminUrl,
  dbIdentifier,
} from './support.mjs';
import { scenarios, supplemental, negativeControls, candidateSubstitutions } from './catalog.mjs';
import {
  assertExpected,
  assertInventory,
  validateAdapter,
  InvariantFailure,
  compareCheckpoints,
} from './assertions.mjs';

const parsed = parseArgs({
  options: {
    mode: { type: 'string', default: 'baseline' },
    'candidate-adapter': { type: 'string' },
    'candidate-migrations': { type: 'string' },
    'candidate-commit': { type: 'string' },
  },
  allowPositionals: false,
});
const args = new Map(Object.entries(parsed.values).map(([key, value]) => [`--${key}`, value]));
const mode = args.get('--mode') ?? 'baseline';
if (!['baseline', 'compare'].includes(mode)) throw new Error('Mode must be baseline or compare');
const source = adminUrl(process.env.HARNESS_ADMIN_DATABASE_URL);
assertInventory(scenarios.map((s) => s.id));
let candidate;
let candidateMigrations;
let candidateRevision;
if (mode === 'compare') {
  for (const flag of ['--candidate-adapter', '--candidate-migrations', '--candidate-commit'])
    if (!args.get(flag))
      throw new Error(
        `${flag} is required; missing candidate code never produces a passing comparison`,
      );
  candidateRevision = git(
    'rev-parse',
    '--verify',
    '--end-of-options',
    `${args.get('--candidate-commit')}^{commit}`,
  )
    .toString()
    .trim();
  candidate = await import(pathToFileURL(resolve(args.get('--candidate-adapter'))));
  if (typeof candidate.createAdapter !== 'function')
    throw new Error('Candidate must export createAdapter');
  candidateMigrations = resolve(args.get('--candidate-migrations'));
}
const baselineIdentity = await verifyBaseline();
const { default: pg } = await import(
  pathToFileURL(resolve(BASELINE, 'services/api/node_modules/pg/lib/index.js'))
);
const { Pool } = pg;
const { createAdapter } = await import('./baseline-adapter.mjs');
const runId = randomBytes(6).toString('hex');
const output = resolve(ARTIFACTS, `run-${runId}`);
await mkdir(output, { recursive: true });
const admin = new Pool({ connectionString: source.href, max: 2, connectionTimeoutMillis: 10000 });
const created = new Set();
const template = `trotxi_harness_${runId}_template`;
const report = {
  version: 1,
  mode,
  status: 'running',
  startedAt: new Date().toISOString(),
  harnessRevision: git('rev-parse', 'HEAD').toString().trim(),
  harnessSourceSha256: hash(
    Buffer.concat(
      await Promise.all(
        (await readdir(resolve(ROOT, 'tools/redesign-harness')))
          .filter((f) => /\.(mjs|ts)$/.test(f))
          .sort()
          .map((f) => readFile(resolve(ROOT, 'tools/redesign-harness', f))),
      ),
    ),
  ),
  baseline: baselineIdentity,
  candidateRevision: candidateRevision ?? null,
  originalSuite: null,
  requiredScenarios: scenarios.map((s) => s.id),
  requiredSupplemental: supplemental.map((s) => s.id),
  scenarios: [],
  supplemental: [],
  negativeControls: [],
  candidateSupplemental: [],
  candidateNegativeControls: [],
  substitutions: [],
  cleanup: [],
};
// A substitution stands in for a supplemental case whose baseline premise the
// candidate model makes unrepresentable. It must name the case it replaces and
// why, and it is still a scenario that has to pass: this is the only way a
// supplemental case may go unrun against the candidate, and never silently.
const substituted = new Map(candidateSubstitutions.map((s) => [s.replaces, s]));
for (const entry of candidateSubstitutions) {
  const known =
    supplemental.some((s) => s.id === entry.replaces) ||
    scenarios.some((s) => s.id === entry.replaces);
  if (!known)
    throw new Error(`Substitution ${entry.id} replaces an unknown case ${entry.replaces}`);
  if (!entry.reason?.trim()) throw new Error(`Substitution ${entry.id} states no reason`);
}
const connection = (name) => {
  const url = new URL(source);
  url.pathname = `/${name}`;
  return url.href;
};
async function createDatabase(name, from) {
  await admin.query(
    `CREATE DATABASE ${dbIdentifier(name)}${from ? ` TEMPLATE ${dbIdentifier(from)}` : ''}`,
  );
  created.add(name);
  return connection(name);
}
async function dropDatabase(name) {
  if (!created.has(name)) throw new Error('Refusing to drop a database not created by this run');
  // Pool shutdown can precede the server observing socket closure. PostgreSQL's
  // ordinary DROP waits for disconnect; do not kill stray/unmanaged sessions.
  await admin.query(`DROP DATABASE ${dbIdentifier(name)}`);
  created.delete(name);
  report.cleanup.push(name);
}
async function migrationsAt(dir) {
  const files = (await readdir(dir)).filter((f) => f.endsWith('.sql')).sort();
  if (!files.length)
    throw new Error('Missing migrations: database coverage cannot run against an empty schema');
  return Promise.all(
    files.map(async (name) => ({ name, sha256: hash(await readFile(resolve(dir, name))) })),
  );
}
const baselineMigrations = resolve(BASELINE, 'services/api/src/db/migrations');
report.baseline.migrations = await migrationsAt(baselineMigrations);
if (candidateMigrations) report.candidateMigrations = await migrationsAt(candidateMigrations);
await writeFile(resolve(ARTIFACTS, 'latest-report.json'), JSON.stringify(report, null, 2) + '\n');

async function applyCandidate(databaseUrl) {
  const pool = new Pool({ connectionString: databaseUrl });
  try {
    for (const entry of report.candidateMigrations) {
      const sql = await readFile(resolve(candidateMigrations, entry.name), 'utf8');
      if (hash(sql) !== entry.sha256) throw new Error('Candidate migrations changed during run');
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        await client.query(sql);
        await client.query('COMMIT');
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    }
  } finally {
    await pool.end();
  }
}

async function runScenario(scenario, factory, suffix, negative) {
  const name = `trotxi_harness_${runId}_${suffix.replaceAll('-', '_')}_${scenario.id.toLowerCase().replaceAll('-', '_')}`;
  const databaseUrl = await createDatabase(name, factory === createAdapter ? template : undefined);
  let adapter;
  const entry = {
    id: scenario.id,
    title: scenario.title,
    category: scenario.category ?? 'preservation',
    status: 'running',
    inputs: scenario.steps.filter((s) => s.action),
    checkpoints: [],
    database: name,
  };
  try {
    if (factory !== createAdapter) await applyCandidate(databaseUrl);
    adapter = await factory({ databaseUrl });
    validateAdapter(adapter);
    entry.adapter = await adapter.metadata();
    for (const step of scenario.steps) {
      if (step.action) {
        await adapter.act(step);
        continue;
      }
      if (negative?.checkpoint === step.checkpoint) {
        if (typeof adapter.corrupt !== 'function')
          throw new Error('Negative-control adapter cannot mutate persisted state');
        await adapter.corrupt(negative.mutation);
      }
      const observed = await adapter.observe();
      entry.checkpoints.push({ label: step.checkpoint, expected: step.expected, ...observed });
      assertExpected(observed.state, step.expected, scenario.id, step.checkpoint);
    }
    if (negative) throw new Error(`Negative control ${negative.id} escaped detection`);
    entry.status = 'passed';
  } catch (error) {
    entry.status = 'failed';
    entry.failure = {
      name: error.name,
      message: error.message,
      checkpoint: error.checkpoint,
      path: error.path,
      expected: error.expected,
      actual: error.actual,
    };
    if (
      negative &&
      error instanceof InvariantFailure &&
      error.checkpoint === negative.checkpoint &&
      error.path === negative.expectedPath
    ) {
      entry.status = 'detected';
      entry.control = negative;
    }
  } finally {
    try {
      if (adapter) await adapter.dispose();
    } catch (error) {
      entry.status = 'failed';
      entry.cleanupError = error.message;
    }
    try {
      await dropDatabase(name);
    } catch (error) {
      entry.status = 'failed';
      entry.cleanupError = error.message;
    }
  }
  await writeFile(
    resolve(output, `${suffix}-${scenario.id}.json`),
    JSON.stringify(entry, null, 2) + '\n',
  );
  console.log(
    `${suffix} ${scenario.id}: ${entry.status}${entry.failure ? ` — ${entry.failure.message}` : ''}`,
  );
  return entry;
}

try {
  await createDatabase(template);
  const env = childEnv({ DATABASE_URL: connection(template) });
  const tsx = resolve(BASELINE, 'services/api/node_modules/tsx/dist/loader.mjs');
  const api = resolve(BASELINE, 'services/api');
  for (let i = 0; i < 2; i++)
    await command(process.execPath, ['--import', tsx, 'src/db/migrate.ts'], { cwd: api, env });
  const templatePool = new Pool({ connectionString: connection(template) });
  try {
    const names = (await templatePool.query('SELECT name FROM _migrations ORDER BY name')).rows.map(
      (r) => r.name,
    );
    assertExpected(
      names,
      report.baseline.migrations.map((m) => m.name),
      'PROVISION',
      'pinned-migrations',
    );
    report.postgis = (
      await templatePool.query('SELECT postgis_version() AS version')
    ).rows[0].version;
  } finally {
    await templatePool.end();
  }

  const original = `trotxi_harness_${runId}_original`;
  const originalUrl = await createDatabase(original, template);
  const originalReport = resolve(output, 'original-suite.json');
  try {
    await command(
      process.execPath,
      [
        'node_modules/vitest/vitest.mjs',
        'run',
        'tests/payment-lifecycle.pg.test.ts',
        '--reporter=json',
        `--outputFile=${originalReport}`,
      ],
      { cwd: api, env: childEnv({ DATABASE_URL: originalUrl }) },
    );
    const suite = JSON.parse(await readFile(originalReport, 'utf8'));
    const assertions = suite.testResults.flatMap((s) => s.assertionResults);
    assertExpected(
      {
        success: suite.success,
        count: assertions.length,
        passed: assertions.filter((a) => a.status === 'passed').length,
      },
      { success: true, count: 16, passed: 16 },
      'ORIGINAL',
      'no-skips',
    );
    report.originalSuite = { status: 'passed', count: 16, titles: assertions.map((a) => a.title) };
  } finally {
    await dropDatabase(original);
  }

  for (const scenario of scenarios) {
    const entry = await runScenario(scenario, createAdapter, 'baseline');
    report.scenarios.push(entry);
    if (!candidate) continue;
    const stand = substituted.get(scenario.id);
    if (stand) {
      // A payment scenario whose premise the candidate model makes
      // unrepresentable. The baseline still runs it unchanged; the candidate
      // runs the declared substitute, which carries its own fixed expectations
      // and has to pass on its own. Two different scenarios cannot be compared
      // checkpoint for checkpoint, so the comparison is named for what it is.
      report.substitutions.push({
        id: stand.id,
        replaces: stand.replaces,
        gate: stand.gate ?? 'supplemental',
        reason: stand.reason,
      });
      entry.candidate = await runScenario(stand, candidate.createAdapter, 'candidate');
      entry.comparison = 'substituted';
      continue;
    }
    const other = await runScenario(scenario, candidate.createAdapter, 'candidate');
    entry.candidate = other;
    // Both sides must satisfy the same independently fixed contract. Different
    // legal race winners are permitted; full observations remain in evidence.
    entry.comparison = 'failed';
    if (entry.status === 'passed' && other.status === 'passed') {
      compareCheckpoints(entry.checkpoints, other.checkpoints, scenario.id);
      entry.comparison = 'passed';
    }
  }
  for (const scenario of supplemental) {
    report.supplemental.push(await runScenario(scenario, createAdapter, 'supplemental'));
    if (!candidate) continue;
    const stand = substituted.get(scenario.id);
    if (stand) {
      report.substitutions.push({
        id: stand.id,
        replaces: stand.replaces,
        gate: stand.gate ?? 'supplemental',
        reason: stand.reason,
      });
      report.candidateSupplemental.push(
        await runScenario(stand, candidate.createAdapter, 'candidate-supplemental'),
      );
    } else
      report.candidateSupplemental.push(
        await runScenario(scenario, candidate.createAdapter, 'candidate-supplemental'),
      );
  }
  for (const control of negativeControls) {
    const scenario = scenarios.find((s) => s.id === control.scenario);
    report.negativeControls.push(
      await runScenario(scenario, createAdapter, control.id.toLowerCase(), control),
    );
    if (candidate)
      report.candidateNegativeControls.push(
        await runScenario(
          scenario,
          candidate.createAdapter,
          `candidate-${control.id.toLowerCase()}`,
          control,
        ),
      );
  }
  // The candidate is the working tree, not a verified export, so the least the
  // report can do is say what it ran and refuse a tree that changed partway.
  if (candidate) {
    const digests = new Set(
      [...report.scenarios.map((s) => s.candidate), ...report.candidateSupplemental]
        .filter(Boolean)
        .map((entry) => entry.adapter?.sourceSha256)
        .filter(Boolean),
    );
    if (digests.size > 1) throw new Error('Candidate source changed during the run');
    report.candidateSourceSha256 = [...digests][0] ?? null;
    if (!report.candidateSourceSha256)
      throw new Error('Candidate adapter reported no source digest');
  }
  // Every required case is accounted for on both sides. A candidate run that
  // covered fewer cases than the baseline is a failed gate, not a shorter one.
  const standIn = new Map(candidateSubstitutions.map((s) => [s.id, s.replaces]));
  const covered = new Set(
    report.candidateSupplemental.map((entry) => standIn.get(entry.id) ?? entry.id),
  );
  if (
    report.scenarios.some(
      (s) =>
        s.status !== 'passed' ||
        s.comparison === 'failed' ||
        (candidate && s.candidate?.status !== 'passed'),
    ) ||
    report.supplemental.some((s) => s.status !== 'passed') ||
    report.negativeControls.some((s) => s.status !== 'detected') ||
    (candidate &&
      (report.candidateSupplemental.some((s) => s.status !== 'passed') ||
        report.candidateNegativeControls.some((s) => s.status !== 'detected') ||
        supplemental.some((s) => !covered.has(s.id))))
  )
    throw new Error('Harness gate failed; inspect scenario evidence');
  await verifyBaseline();
  report.status = 'passed';
} catch (error) {
  report.status = 'failed';
  report.error = { name: error.name, message: error.message };
  process.exitCode = 1;
} finally {
  for (const name of [...created].reverse()) {
    try {
      await dropDatabase(name);
    } catch (error) {
      report.status = 'failed';
      process.exitCode = 1;
      report.cleanupError = error.message;
    }
  }
  await admin.end();
  report.completedAt = new Date().toISOString();
  await writeFile(resolve(output, 'report.json'), JSON.stringify(report, null, 2) + '\n');
  // Stable path for artifact upload; contains synthetic data only, never URLs/credentials.
  await writeFile(resolve(ARTIFACTS, 'latest-report.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(`Harness ${report.status}; evidence: ${output}`);
}
