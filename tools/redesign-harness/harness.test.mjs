import assert from 'node:assert/strict';
import test from 'node:test';
import { spawnSync } from 'node:child_process';
import { scenarios, supplemental, negativeControls, candidateSubstitutions } from './catalog.mjs';
import {
  assertExpected,
  assertInventory,
  validateAdapter,
  InvariantFailure,
  compareCheckpoints,
} from './assertions.mjs';
import { adminUrl, dbIdentifier } from './support.mjs';

test('the required scenario inventory cannot shrink or silently skip', () => {
  assertInventory(scenarios.map((s) => s.id));
  assert.throws(() => assertInventory(scenarios.slice(1).map((s) => s.id)));
  assert.equal(supplemental.length, 4);
  for (const scenario of [...scenarios, ...supplemental])
    assert.ok(scenario.steps.some((s) => s.checkpoint));
});
test('missing candidate operations fail closed', () => {
  assert.throws(() => validateAdapter({}), /missing act/);
});
test('comparison rejects numeric defects and preserves logical attribution', () => {
  assert.throws(
    () => assertExpected({ rides: 88 }, { rides: 44 }, 'PAY-03', 'x'),
    InvariantFailure,
  );
  assert.throws(
    () =>
      assertExpected({ currentPurchase: 'first' }, { currentPurchase: 'renewal' }, 'PAY-05', 'x'),
    InvariantFailure,
  );
  assert.throws(() => assertExpected({}, { required: null }, 'x', 'x'), InvariantFailure);
  assert.throws(() => assertExpected({ list: [1, 2] }, { list: [1] }, 'x', 'x'), InvariantFailure);
});
test('negative controls are tied to exact invariant assertion paths', () => {
  assert.equal(negativeControls.length, 2);
  for (const control of negativeControls) {
    const scenario = scenarios.find((s) => s.id === control.scenario);
    assert.ok(scenario.steps.some((s) => s.checkpoint === control.checkpoint));
    assert.ok(control.expectedPath.startsWith('$.'));
  }
});
test('missing/remote/application database configuration is rejected before mutation', () => {
  assert.throws(() => adminUrl(undefined), /never skip/);
  assert.throws(() => adminUrl('postgres://user:secret@staging.example/postgres'), /loopback/);
  assert.throws(() => adminUrl('postgres://localhost/trotxi'), /named postgres/);
  assert.throws(() => dbIdentifier('postgres'), /Unsafe/);
  assert.throws(
    () => dbIdentifier('trotxi_harness_123456abcdef_a";DROP DATABASE postgres;'),
    /Unsafe/,
  );
  assert.equal(
    dbIdentifier('trotxi_harness_123456abcdef_pay_01'),
    '"trotxi_harness_123456abcdef_pay_01"',
  );
});

test('old-versus-old only checks comparator plumbing; attribution mismatches still fail', () => {
  const points = [
    {
      label: 'identity',
      state: { current: 'second', generatedId: 'ignored' },
      expected: { current: 'second' },
    },
  ];
  compareCheckpoints(points, structuredClone(points), 'PLUMBING');
  assert.throws(
    () => compareCheckpoints(points, [{ ...points[0], state: { current: 'first' } }], 'PLUMBING'),
    InvariantFailure,
  );
  assert.throws(() => compareCheckpoints(points, [], 'PLUMBING'), InvariantFailure);
});

test('CLI rejects missing database/candidate and mistyped mode rather than running a lesser gate', () => {
  const script = new URL('./run.mjs', import.meta.url).pathname;
  const missingDb = spawnSync(process.execPath, [script], {
    env: { PATH: process.env.PATH },
    encoding: 'utf8',
  });
  assert.notEqual(missingDb.status, 0);
  assert.match(missingDb.stderr, /HARNESS_ADMIN_DATABASE_URL is required/);
  const missingCandidate = spawnSync(process.execPath, [script, '--mode=compare'], {
    env: {
      PATH: process.env.PATH,
      HARNESS_ADMIN_DATABASE_URL: 'postgres://localhost/postgres',
      HARNESS_ALLOW_CREATE_DATABASES: '1',
    },
    encoding: 'utf8',
  });
  assert.notEqual(missingCandidate.status, 0);
  assert.match(missingCandidate.stderr, /candidate-adapter.*required/);
  const typo = spawnSync(process.execPath, [script, '--mod=compare'], { encoding: 'utf8' });
  assert.notEqual(typo.status, 0);
  assert.match(typo.stderr, /Unknown option/);
});

test('a substituted case must name what it replaces, why, and prove something', () => {
  // A substitution is the only way a required case may go unrun against the
  // candidate. It is not an exemption: it names the case, states why that
  // case's premise cannot exist in the replacement model, and is itself a
  // scenario with fixed expectations that has to pass.
  const ids = new Set(supplemental.map((s) => s.id));
  for (const entry of candidateSubstitutions) {
    assert.ok(ids.has(entry.replaces), `${entry.id} replaces an unknown case`);
    assert.ok(entry.reason && entry.reason.length > 40, `${entry.id} states no real reason`);
    assert.ok(
      entry.steps.some((step) => step.checkpoint),
      `${entry.id} asserts nothing`,
    );
    assert.ok(!ids.has(entry.id), `${entry.id} must not shadow a required case id`);
  }
  // And it may not quietly stand in for a PAY scenario: those are the gate.
  const required = new Set(scenarios.map((s) => s.id));
  for (const entry of candidateSubstitutions)
    assert.ok(!required.has(entry.replaces), `${entry.id} cannot substitute a PAY scenario`);
});

test('the compare gate refuses a run that covered fewer cases than the baseline', () => {
  // The coverage rule the runner applies, exercised directly: a supplemental
  // case that was neither run nor substituted leaves the gate unsatisfied.
  const standIn = new Map(candidateSubstitutions.map((s) => [s.id, s.replaces]));
  const covered = (ran) => new Set(ran.map((id) => standIn.get(id) ?? id));
  const everything = covered([
    ...supplemental
      .filter((s) => !candidateSubstitutions.some((c) => c.replaces === s.id))
      .map((s) => s.id),
    ...candidateSubstitutions.map((s) => s.id),
  ]);
  assert.ok(supplemental.every((s) => everything.has(s.id)));
  const short = covered(supplemental.slice(1).map((s) => s.id));
  assert.ok(
    supplemental.some((s) => !short.has(s.id)),
    'a dropped case must be visible',
  );
  assert.equal(negativeControls.length, 2);
});
