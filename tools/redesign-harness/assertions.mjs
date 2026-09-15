import { isDeepStrictEqual } from 'node:util';

export class InvariantFailure extends Error {
  constructor(scenario, checkpoint, path, expected, actual) {
    super(
      `${scenario}/${checkpoint}: ${path}: expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
    this.name = 'InvariantFailure';
    Object.assign(this, { scenario, checkpoint, path, expected, actual });
  }
}

// Expectations belong to the catalog; adapters only operate/observe storage.
// Objects select contract fields; arrays and scalar leaves are exact, including null.
export function assertExpected(actual, expected, scenario, checkpoint, path = '$') {
  if (expected && typeof expected === 'object' && !Array.isArray(expected)) {
    if (!actual || typeof actual !== 'object')
      throw new InvariantFailure(scenario, checkpoint, path, expected, actual);
    for (const [key, value] of Object.entries(expected)) {
      assertExpected(actual[key], value, scenario, checkpoint, `${path}.${key}`);
    }
  } else if (!isDeepStrictEqual(actual, expected)) {
    throw new InvariantFailure(scenario, checkpoint, path, expected, actual);
  }
}

export const REQUIRED_METHODS = ['act', 'observe', 'metadata', 'dispose'];
export function validateAdapter(adapter) {
  for (const name of REQUIRED_METHODS)
    if (typeof adapter?.[name] !== 'function')
      throw new Error(
        `Adapter is missing ${name}; candidate mode cannot skip unimplemented scenarios`,
      );
}

export function assertInventory(ids) {
  const expected = Array.from({ length: 16 }, (_, i) => `PAY-${String(i + 1).padStart(2, '0')}`);
  if (!isDeepStrictEqual(ids, expected))
    throw new Error('Required PAY-01–16 scenario inventory is incomplete or reordered');
}

export function contractProjection(actual, shape) {
  if (shape && typeof shape === 'object' && !Array.isArray(shape))
    return Object.fromEntries(
      Object.entries(shape).map(([key, value]) => [key, contractProjection(actual[key], value)]),
    );
  return actual;
}

export function compareCheckpoints(baseline, candidate, scenario) {
  assertExpected(
    candidate.map((c) => c.label),
    baseline.map((c) => c.label),
    scenario,
    'checkpoint-inventory',
  );
  for (let i = 0; i < baseline.length; i++) {
    const left = baseline[i];
    const right = candidate[i];
    assertExpected(
      contractProjection(right.state, left.expected),
      contractProjection(left.state, left.expected),
      scenario,
      `comparison:${left.label}`,
    );
  }
}
